#define _GNU_SOURCE
/* MPI-only placement receipt: pre/post MPI_Init masks; no OpenFOAM run. */
#include <mpi.h>
#include <sched.h>
#include <dlfcn.h>
#include <link.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>
static char ucp_path[4096];
static int locate(struct dl_phdr_info *i,size_t n,void *p){
    (void)n;(void)p;
    if(i->dlpi_name && strstr(i->dlpi_name,"libucp.so")){
        snprintf(ucp_path,sizeof ucp_path,"%s",i->dlpi_name);return 1;
    }return 0;
}
static void mask(FILE *f,cpu_set_t *s){
    int sep=0;fputc('[',f);
    for(int i=0;i<CPU_SETSIZE;i++)if(CPU_ISSET(i,s)){fprintf(f,"%s%d",sep?",":"",i);sep=1;}
    fputc(']',f);
}
int main(int argc,char **argv){
    cpu_set_t pre,post;CPU_ZERO(&pre);CPU_ZERO(&post);
    int pre_ok=sched_getaffinity(0,sizeof pre,&pre)==0;
    MPI_Init(&argc,&argv);
    int rank,size,sum,got,local_ok,all_ok;
    MPI_Comm_rank(MPI_COMM_WORLD,&rank);MPI_Comm_size(MPI_COMM_WORLD,&size);
    int post_ok=sched_getaffinity(0,sizeof post,&post)==0;
    MPI_Allreduce(&rank,&sum,1,MPI_INT,MPI_SUM,MPI_COMM_WORLD);
    MPI_Sendrecv(&rank,1,MPI_INT,(rank+1)%size,7,&got,1,MPI_INT,(rank+size-1)%size,7,MPI_COMM_WORLD,MPI_STATUS_IGNORE);
    dl_iterate_phdr(locate,NULL);
    void *h=ucp_path[0]?dlopen(ucp_path,RTLD_NOW|RTLD_NOLOAD):NULL;
    const char *(*version)(void)=h?dlsym(h,"ucp_get_version_string"):NULL;
    char host[256],path[8192];gethostname(host,sizeof host);host[255]=0;
    local_ok=argc==2 && size==416 && sum==86320 && got==(rank+size-1)%size && pre_ok && post_ok && ucp_path[0] && version;
    if(argc==2){
        snprintf(path,sizeof path,"%s/rank-%d.json",argv[1],rank);FILE *f=fopen(path,"wx");
        if(!f)local_ok=0;
        else{
            fprintf(f,"{\"rank\":%d,\"size\":%d,\"host\":\"%s\",\"sum\":%d,\"ring_from\":%d,\"pre_cpus\":",rank,size,host,sum,got);
            mask(f,&pre);fputs(",\"post_cpus\":",f);mask(f,&post);
            fprintf(f,",\"ucp_path\":\"%s\",\"ucp_version\":\"%s\"}\n",ucp_path,version?version():"MISSING");
            if(fclose(f))local_ok=0;
        }
    }
    MPI_Allreduce(&local_ok,&all_ok,1,MPI_INT,MPI_MIN,MPI_COMM_WORLD);
    if(h)dlclose(h);MPI_Finalize();return all_ok?0:1;
}
