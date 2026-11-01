#define _GNU_SOURCE
#include <mpi.h>
#include <dlfcn.h>
#include <link.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>
static char ucp_path[4096];
static int locate(struct dl_phdr_info *info, size_t size, void *data) {
    (void)size; (void)data;
    if (info->dlpi_name && strstr(info->dlpi_name, "libucp.so")) {
        snprintf(ucp_path, sizeof(ucp_path), "%s", info->dlpi_name);
        return 1;
    }
    return 0;
}
int main(int argc, char **argv) {
    int rank, size, sum;
    char host[256];
    MPI_Init(&argc, &argv);
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Comm_size(MPI_COMM_WORLD, &size);
    MPI_Allreduce(&rank, &sum, 1, MPI_INT, MPI_SUM, MPI_COMM_WORLD);
    gethostname(host, sizeof host);
    host[sizeof host - 1] = 0;
    dl_iterate_phdr(locate, NULL);
    void *handle = ucp_path[0] ? dlopen(ucp_path, RTLD_NOW | RTLD_NOLOAD) : NULL;
    const char *(*version)(void) = handle ? dlsym(handle, "ucp_get_version_string") : NULL;
    char receipt[8192];
    int wrote = 0;
    if (argc > 1) {
        snprintf(receipt, sizeof receipt, "%s/rank-%d.txt", argv[1], rank);
        FILE *out = fopen(receipt, "wx");
        if (out) {
            fprintf(out, "COLLECTIVE_MPI_RUNTIME rank=%d size=%d host=%s path=%s version=%s sum=%d\n",
                    rank, size, host, ucp_path[0] ? ucp_path : "MISSING",
                    version ? version() : "MISSING", sum);
            wrote = fclose(out) == 0;
        }
    }
    if (handle) dlclose(handle);
    MPI_Finalize();
    return size == 5 && sum == 10 && ucp_path[0] && version && wrote ? 0 : 1;
}
