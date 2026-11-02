#define _POSIX_C_SOURCE 200809L
#include <mpi.h>
#include <errno.h>
#include <fcntl.h>
#include <inttypes.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <unistd.h>

/* C-only process-local PMPI timing. Timed wrappers perform no I/O or MPI. */
enum call_id {
    C_WAIT, C_WAITALL, C_WAITANY, C_TEST, C_TESTALL,
    C_ALLREDUCE, C_BARRIER, C_BCAST, C_REDUCE,
    C_ISEND, C_IRECV, C_SEND, C_RECV, C_SENDRECV, C_COUNT
};
static const char *const call_name[C_COUNT] = {
    "MPI_Wait", "MPI_Waitall", "MPI_Waitany", "MPI_Test", "MPI_Testall",
    "MPI_Allreduce", "MPI_Barrier", "MPI_Bcast", "MPI_Reduce",
    "MPI_Isend", "MPI_Irecv", "MPI_Send", "MPI_Recv", "MPI_Sendrecv"
};
struct counter { uint64_t count, total_ns, max_ns; };
#define BUCKET_SECONDS 10
#define BUCKET_COUNT 360
static struct counter counters[C_COUNT];
static struct counter buckets[BUCKET_COUNT][C_COUNT];
static _Thread_local int inside_wrapper;
static uint64_t started_ns;
static int world_rank = -1;

static uint64_t monotonic_ns(void) {
    struct timespec t;
    if (clock_gettime(CLOCK_MONOTONIC, &t) != 0) return 0;
    return (uint64_t)t.tv_sec * UINT64_C(1000000000) + (uint64_t)t.tv_nsec;
}
static void add_counter(struct counter *counter, uint64_t duration) {
    __atomic_fetch_add(&counter->count, 1, __ATOMIC_RELAXED);
    __atomic_fetch_add(&counter->total_ns, duration, __ATOMIC_RELAXED);
    uint64_t previous = __atomic_load_n(&counter->max_ns, __ATOMIC_RELAXED);
    while (previous < duration &&
           !__atomic_compare_exchange_n(&counter->max_ns, &previous,
                                        duration, 1, __ATOMIC_RELAXED,
                                        __ATOMIC_RELAXED)) {}
}
static void record_call(enum call_id id, uint64_t begin_ns, uint64_t duration) {
    add_counter(&counters[id], duration);
    uint64_t offset = begin_ns >= started_ns ? begin_ns - started_ns : 0;
    uint64_t bucket = offset / (UINT64_C(1000000000) * BUCKET_SECONDS);
    if (bucket >= BUCKET_COUNT) bucket = BUCKET_COUNT - 1;
    add_counter(&buckets[bucket][id], duration);
}
static void write_report(uint64_t stopped_ns) {
    const char *dir = getenv("PMPI_TIMING_DIR");
    if (!dir || !*dir || world_rank < 0 || !started_ns) return;
    char path[4096], host[256];
    if (gethostname(host, sizeof(host)) != 0) strcpy(host, "unknown");
    host[sizeof(host)-1] = '\0';
    int n = snprintf(path, sizeof(path), "%s/rank-%06d.csv", dir, world_rank);
    if (n < 0 || (size_t)n >= sizeof(path)) return;
    int fd = open(path, O_WRONLY | O_CREAT | O_EXCL, 0644);
    if (fd < 0) {
        fprintf(stderr, "PMPI_TIMING_REPORT_ERROR rank=%d errno=%d\n", world_rank, errno);
        return;
    }
    dprintf(fd, "rank,host,pid,elapsed_ns,call,count,total_ns,max_ns\n");
    uint64_t elapsed = stopped_ns >= started_ns ? stopped_ns - started_ns : 0;
    for (int i = 0; i < C_COUNT; ++i) {
        dprintf(fd, "%d,%s,%ld,%" PRIu64 ",%s,%" PRIu64 ",%" PRIu64 ",%" PRIu64 "\n",
                world_rank, host, (long)getpid(), elapsed, call_name[i],
                __atomic_load_n(&counters[i].count, __ATOMIC_RELAXED),
                __atomic_load_n(&counters[i].total_ns, __ATOMIC_RELAXED),
                __atomic_load_n(&counters[i].max_ns, __ATOMIC_RELAXED));
    }
    close(fd);
    n = snprintf(path, sizeof(path), "%s/rank-%06d-buckets.csv", dir, world_rank);
    if (n < 0 || (size_t)n >= sizeof(path)) return;
    fd = open(path, O_WRONLY | O_CREAT | O_EXCL, 0644);
    if (fd < 0) {
        fprintf(stderr, "PMPI_TIMING_BUCKET_ERROR rank=%d errno=%d\n", world_rank, errno);
        return;
    }
    dprintf(fd, "rank,window_start_s,call,count,total_ns,max_ns\n");
    for (int bucket = 0; bucket < BUCKET_COUNT; ++bucket) {
        for (int i = 0; i < C_COUNT; ++i) {
            uint64_t count = __atomic_load_n(&buckets[bucket][i].count, __ATOMIC_RELAXED);
            if (!count) continue;
            dprintf(fd, "%d,%d,%s,%" PRIu64 ",%" PRIu64 ",%" PRIu64 "\n",
                    world_rank, bucket * BUCKET_SECONDS, call_name[i], count,
                    __atomic_load_n(&buckets[bucket][i].total_ns, __ATOMIC_RELAXED),
                    __atomic_load_n(&buckets[bucket][i].max_ns, __ATOMIC_RELAXED));
        }
    }
    close(fd);
}
int MPI_Init(int *argc, char ***argv) {
    int rc = PMPI_Init(argc, argv);
    if (rc == MPI_SUCCESS) {
        PMPI_Comm_rank(MPI_COMM_WORLD, &world_rank);
        started_ns = monotonic_ns();
    }
    return rc;
}
int MPI_Init_thread(int *argc, char ***argv, int required, int *provided) {
    int rc = PMPI_Init_thread(argc, argv, required, provided);
    if (rc == MPI_SUCCESS) {
        PMPI_Comm_rank(MPI_COMM_WORLD, &world_rank);
        started_ns = monotonic_ns();
    }
    return rc;
}
int MPI_Finalize(void) {
    uint64_t stopped_ns = monotonic_ns();
    int rc = PMPI_Finalize();
    write_report(stopped_ns);
    return rc;
}
#define TIMED_WRAPPER(name, id, signature, arguments) \
int MPI_##name signature { \
    int timed = (inside_wrapper++ == 0 && started_ns != 0); \
    uint64_t begin = timed ? monotonic_ns() : 0; \
    int rc = PMPI_##name arguments; \
    if (timed) record_call(id, begin, monotonic_ns() - begin); \
    --inside_wrapper; \
    return rc; \
}
TIMED_WRAPPER(Wait, C_WAIT,
              (MPI_Request *request, MPI_Status *status), (request, status))
TIMED_WRAPPER(Waitall, C_WAITALL,
              (int count, MPI_Request requests[], MPI_Status statuses[]),
              (count, requests, statuses))
TIMED_WRAPPER(Waitany, C_WAITANY,
              (int count, MPI_Request requests[], int *index, MPI_Status *status),
              (count, requests, index, status))
TIMED_WRAPPER(Test, C_TEST,
              (MPI_Request *request, int *flag, MPI_Status *status),
              (request, flag, status))
TIMED_WRAPPER(Testall, C_TESTALL,
              (int count, MPI_Request requests[], int *flag, MPI_Status statuses[]),
              (count, requests, flag, statuses))
TIMED_WRAPPER(Allreduce, C_ALLREDUCE,
              (const void *sendbuf, void *recvbuf, int count, MPI_Datatype datatype,
               MPI_Op op, MPI_Comm comm),
              (sendbuf, recvbuf, count, datatype, op, comm))
TIMED_WRAPPER(Barrier, C_BARRIER, (MPI_Comm comm), (comm))
TIMED_WRAPPER(Bcast, C_BCAST,
              (void *buffer, int count, MPI_Datatype datatype, int root, MPI_Comm comm),
              (buffer, count, datatype, root, comm))
TIMED_WRAPPER(Reduce, C_REDUCE,
              (const void *sendbuf, void *recvbuf, int count, MPI_Datatype datatype,
               MPI_Op op, int root, MPI_Comm comm),
              (sendbuf, recvbuf, count, datatype, op, root, comm))
TIMED_WRAPPER(Isend, C_ISEND,
              (const void *buf, int count, MPI_Datatype datatype, int dest, int tag,
               MPI_Comm comm, MPI_Request *request),
              (buf, count, datatype, dest, tag, comm, request))
TIMED_WRAPPER(Irecv, C_IRECV,
              (void *buf, int count, MPI_Datatype datatype, int source, int tag,
               MPI_Comm comm, MPI_Request *request),
              (buf, count, datatype, source, tag, comm, request))
TIMED_WRAPPER(Send, C_SEND,
              (const void *buf, int count, MPI_Datatype datatype, int dest, int tag,
               MPI_Comm comm), (buf, count, datatype, dest, tag, comm))
TIMED_WRAPPER(Recv, C_RECV,
              (void *buf, int count, MPI_Datatype datatype, int source, int tag,
               MPI_Comm comm, MPI_Status *status),
              (buf, count, datatype, source, tag, comm, status))
TIMED_WRAPPER(Sendrecv, C_SENDRECV,
              (const void *sendbuf, int sendcount, MPI_Datatype sendtype,
               int dest, int sendtag, void *recvbuf, int recvcount,
               MPI_Datatype recvtype, int source, int recvtag, MPI_Comm comm,
               MPI_Status *status),
              (sendbuf, sendcount, sendtype, dest, sendtag, recvbuf,
               recvcount, recvtype, source, recvtag, comm, status))
