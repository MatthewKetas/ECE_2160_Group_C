#define _POSIX_C_SOURCE 200809L
#include <errno.h>
#include <math.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <unistd.h>
#include <sys/resource.h>
#ifdef ASSESS_DLOPEN
#include <dlfcn.h>
#endif
#include "Memory/critter_memory.h"
#include "IO/critter_io.h"
#include "Computation/critter_computation.h"
#include "support.h"

#ifndef ASSESS_UNIT
#define ASSESS_UNIT 4
#endif
#ifndef ASSESS_CAPACITY
#define ASSESS_CAPACITY 100
#endif
#ifdef ASSESS_CONTEXT
assessment_io_context_t *assessment_io_state;
#endif
static const char *phase_file;
static void phase(const char *name)
{
    if (phase_file) {
        FILE *f = fopen(phase_file, "w");
        if (!f) exit(10);
        fprintf(f, "%ld %s\n", (long)getpid(), name);
        fclose(f);
        struct timespec pause = {0, 150000000};
        nanosleep(&pause, NULL);
    }
}
static int set_limit(int which, const char *name)
{
    const char *value = getenv(name);
    struct rlimit r;
    if (!value) return 0;
    if (getrlimit(which, &r)) return -1;
    r.rlim_cur = (rlim_t)strtoull(value, NULL, 10);
    if (r.rlim_max != RLIM_INFINITY && r.rlim_cur > r.rlim_max) return -1;
    return setrlimit(which, &r);
}
#if ASSESS_UNIT == 3 || ASSESS_UNIT == 4
#ifdef ASSESS_DLOPEN
static void *prediction_handle;
static int (*prediction_fn)(const critter_window_summary_t *, double, critter_analysis_result_t *);
#endif
static int prediction(const critter_window_summary_t *s, double h, critter_analysis_result_t *a)
{
#ifdef ASSESS_DLOPEN
    if (!prediction_handle) {
        prediction_handle = dlopen("./libprediction.so", RTLD_NOW | RTLD_LOCAL);
        if (!prediction_handle) { fprintf(stderr, "%s\n", dlerror()); return -1; }
        *(void **)(&prediction_fn) = dlsym(prediction_handle, "critter_compute_analysis");
        if (!prediction_fn) return -1;
        phase("prediction_loaded");
    }
    return prediction_fn(s, h, a);
#else
    return critter_compute_analysis(s, h, a);
#endif
}
#endif
#if ASSESS_UNIT == 4
static int verify(void)
{
    int failures = 0;
    for (int k = 0; k < 8; ++k) {
        critter_memory_t m;
        critter_sample_t s = {.timestamp_s = 1, .temperature_c = 22.5,
            .source = TEMPERATURE_SOURCE_DATA};
        if (critter_memory_init(&m, ASSESS_CAPACITY)) return 11;
        switch (k) {
            case 0: s.temperature_c = strtod("nan", NULL); break;
            case 1: s.temperature_c = strtod("inf", NULL); break;
            case 2: s.timestamp_s = strtod("nan", NULL); break;
            case 3: s.timestamp_s = 0; break;
            case 4: s.has_humidity = true; s.humidity_percent = 101; break;
            case 5: s.has_pressure = true; s.pressure_hpa = -1; break;
            case 6: s.source = (critter_temperature_source_t)9; break;
            case 7: s.has_pressure = true; s.pressure_hpa = strtod("inf", NULL); break;
        }
        if (critter_memory_add_sample(&m, &s) != -1 || m.total_rejected_samples != 1) ++failures;
        critter_memory_free(&m);
    }
    critter_window_summary_t s = {.sample_count = 1};
    critter_analysis_result_t a;
    if (prediction(&s, strtod("nan", NULL), &a) != -1) ++failures;
    printf("{\"verify_failures\":%d}\n", failures);
    return failures ? 12 : 0;
}
#endif
int main(int argc, char **argv)
{
    if (set_limit(RLIMIT_STACK, "ASSESS_STACK_BYTES") ||
        set_limit(RLIMIT_DATA, "ASSESS_DATA_BYTES")) {
        perror("resource limit"); return 9;
    }
#ifdef ASSESS_CONTEXT
    assessment_io_context_t io_state = {0};
    assessment_io_state = &io_state;
#endif
#if ASSESS_UNIT == 4
    if (argc > 1 && !strcmp(argv[1], "--verify")) return verify();
#endif
    size_t rounds = argc > 1 ? strtoul(argv[1], NULL, 10) : 1;
    if (!rounds || rounds > 100000) return 2;
    phase_file = getenv("ASSESS_PHASE_FILE");
    phase("startup");
    critter_window_summary_t summary = {0};
    critter_analysis_result_t analysis = {0};
    double checksum = 0;
    size_t rejected = 0, outliers = 0;
#if ASSESS_UNIT == 2 || ASSESS_UNIT == 4
    critter_memory_t memory;
    if (critter_memory_init(&memory, ASSESS_CAPACITY)) return 3;
    phase("initialized");
#endif
#if ASSESS_UNIT != 3
    for (size_t i = 0; i < rounds * 600; ++i) {
        size_t j = i % 200;
        double base = 22.5;
#if ASSESS_UNIT == 1 || ASSESS_UNIT == 4
        if (critter_io_get_temperature_from_source(&base, TEMPERATURE_SOURCE_DATA)) return 4;
#endif
        critter_sample_t sample = {.timestamp_s = 1000 + i * 0.1,
            .temperature_c = base + (j < 100 ? j : 200-j) * 0.001 + (i % 97 == 96 ? 20 : 0),
            .source = TEMPERATURE_SOURCE_DATA};
#if ASSESS_UNIT == 1 || ASSESS_UNIT == 4
        if (critter_io_save_sample(&sample)) return 5;
#endif
#if ASSESS_UNIT == 2 || ASSESS_UNIT == 4
        if (critter_memory_add_sample(&memory, &sample)) return 6;
#endif
        checksum += sample.temperature_c;
        if (i == 150) phase("working");
        const char *pace = getenv("ASSESS_PACE_NS");
        if (pace) { struct timespec p = {0, strtol(pace, NULL, 10)}; nanosleep(&p, NULL); }
    }
#endif
#if ASSESS_UNIT == 2 || ASSESS_UNIT == 4
    if (critter_memory_build_summary(&memory, &summary)) return 7;
    rejected = memory.total_rejected_samples;
    outliers = memory.total_outliers;
    phase("summarized");
#endif
#if ASSESS_UNIT == 3
    summary = (critter_window_summary_t){.sample_count=100, .first_timestamp_s=1000,
        .last_timestamp_s=1010, .latest_temperature_c=23, .mean_temperature_c=22.5,
        .min_temperature_c=22, .stddev_temperature_c=0.1, .source=TEMPERATURE_SOURCE_DATA};
    for (size_t i = 0; i < rounds * 10000; ++i) {
        summary.latest_temperature_c = 23 + (i % 17) * 0.0001;
        if (prediction(&summary, 30, &analysis)) return 8;
        checksum += analysis.predicted_temperature_c;
    }
#elif ASSESS_UNIT == 4
    if (prediction(&summary, 30, &analysis)) return 8;
    if (critter_io_save_metrics(&summary, &analysis, rounds*600, rounds*600,
        rejected, outliers, 10)) return 5;
#endif
    phase("finished_work");
#ifdef ASSESS_DLOPEN
#if ASSESS_UNIT == 3 || ASSESS_UNIT == 4
    if (prediction_handle) { dlclose(prediction_handle); prediction_handle = NULL; phase("prediction_closed"); }
#endif
#endif
    printf("{\"unit\":%d,\"rounds\":%zu,\"capacity\":%d,\"sample_bytes\":%zu,"
        "\"record_bytes\":%zu,\"memory_state_bytes\":%zu,\"checksum\":%.17g,"
        "\"count\":%zu,\"rejected\":%zu,\"outliers\":%zu,\"mean\":%.17g,"
        "\"median\":%.17g,\"stddev\":%.17g,\"first\":%.17g,\"last\":%.17g,"
        "\"prediction\":%.17g,\"trend\":%.17g,\"stable\":%d,\"hvac\":%d}\n",
        ASSESS_UNIT, rounds, ASSESS_CAPACITY, sizeof(critter_sample_t),
        sizeof(*((critter_memory_t *)0)->buffer), sizeof(critter_memory_t), checksum,
        summary.sample_count, rejected, outliers, summary.mean_temperature_c,
        summary.median_temperature_c, summary.stddev_temperature_c,
        summary.first_timestamp_s, summary.last_timestamp_s, analysis.predicted_temperature_c,
        analysis.trend_c_per_s, analysis.stable, analysis.likely_hvac_active);
#if ASSESS_UNIT == 2 || ASSESS_UNIT == 4
    critter_memory_free(&memory);
#endif
#ifdef ASSESS_PROBE
    assessment_probe_report();
#endif
    phase("released");
    return 0;
}
