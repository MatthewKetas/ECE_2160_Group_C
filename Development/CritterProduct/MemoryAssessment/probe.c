#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include "support.h"
static struct { void *p; size_t bytes; } live[256];
static size_t calls, frees, current, peak;
static void remember(void *p, size_t n)
{
    if (!p) return;
    for (size_t i=0; i<256; ++i) if (!live[i].p) {
        live[i].p=p; live[i].bytes=n; current+=n;
        if (current>peak) peak=current;
        return;
    }
    fprintf(stderr, "allocation probe full\n"); exit(20);
}
void *assessment_malloc(size_t n) { ++calls; void *p=malloc(n); remember(p,n); return p; }
void *assessment_calloc(size_t n,size_t s) {
    ++calls;
    if (s && n>SIZE_MAX/s) return NULL;
    void *p=calloc(n,s); remember(p,n*s); return p;
}
void assessment_free(void *p) {
    if (!p) return;
    ++frees;
    for (size_t i=0;i<256;++i) if (live[i].p==p) {
        current-=live[i].bytes; live[i].p=NULL; free(p); return;
    }
    fprintf(stderr, "untracked free\n"); exit(21);
}
void assessment_probe_report(void) {
    printf("{\"allocation_calls\":%zu,\"free_calls\":%zu,\"requested_peak_bytes\":%zu,\"requested_remaining_bytes\":%zu}\n",
        calls,frees,peak,current);
}
