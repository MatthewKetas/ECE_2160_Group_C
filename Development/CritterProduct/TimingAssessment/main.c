#define _POSIX_C_SOURCE 200809L
#include <errno.h>
#include <inttypes.h>
#include <math.h>
#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <unistd.h>
#include "IO/critter_io.h"
#include "Memory/critter_memory.h"
#include "Computation/critter_computation.h"

typedef struct {
    int64_t start, acquired, saved, finish, cpu;
    int read_ok, save_ok, filter_ok, source, outlier;
} timing_row;

static volatile sig_atomic_t interrupted = 0;
static void on_signal(int sig) { (void)sig; interrupted = 1; }

static int64_t now_ns(clockid_t clock_id)
{
    struct timespec ts;
    if (clock_gettime(clock_id, &ts) != 0) { perror("clock_gettime"); exit(1); }
    return (int64_t)ts.tv_sec * INT64_C(1000000000) + ts.tv_nsec;
}

static int wait_until(int64_t target)
{
    while (!interrupted) {
        int64_t left = target - now_ns(CLOCK_MONOTONIC);
        if (left <= 0) return 0;
#ifdef __linux__
        struct timespec ts = {target / INT64_C(1000000000), target % INT64_C(1000000000)};
        int rc = clock_nanosleep(CLOCK_MONOTONIC, TIMER_ABSTIME, &ts, NULL);
        if (rc && rc != EINTR) { errno = rc; perror("clock_nanosleep"); return -1; }
#else
        struct timespec ts = {left / INT64_C(1000000000), left % INT64_C(1000000000)};
        if (nanosleep(&ts, NULL) && errno != EINTR) { perror("nanosleep"); return -1; }
#endif
    }
    return -1;
}

static double number(const char *s)
{
    char *end;
    double value = strtod(s, &end);
    if (!*s || *end || !isfinite(value) || value <= 0) {
        fprintf(stderr, "invalid positive number: %s\n", s); exit(2);
    }
    return value;
}

int main(int argc, char **argv)
{
    double duration_s = 60, period_ms = 100, deadline_ms = 100;
    const char *output = NULL, *input = NULL, *source = "data", *schedule = "periodic";
    char sample_path[4096], trace_path[4096], info_path[4096];
    for (int i = 1; i < argc; i += 2) {
        if (i + 1 == argc) { fprintf(stderr, "every option needs a value\n"); return 2; }
        if (!strcmp(argv[i], "--duration")) duration_s = number(argv[i + 1]);
        else if (!strcmp(argv[i], "--period-ms")) period_ms = number(argv[i + 1]);
        else if (!strcmp(argv[i], "--deadline-ms")) deadline_ms = number(argv[i + 1]);
        else if (!strcmp(argv[i], "--output")) output = argv[i + 1];
        else if (!strcmp(argv[i], "--input")) input = argv[i + 1];
        else if (!strcmp(argv[i], "--source")) source = argv[i + 1];
        else if (!strcmp(argv[i], "--schedule")) schedule = argv[i + 1];
        else { fprintf(stderr, "unknown option: %s\n", argv[i]); return 2; }
    }
    int source_id = !strcmp(source, "data") ? TEMPERATURE_SOURCE_DATA :
        !strcmp(source, "cpu") ? TEMPERATURE_SOURCE_CPU :
        !strcmp(source, "sense_hat") ? TEMPERATURE_SOURCE_SENSE_HAT : 0;
    if (!output || !source_id || (!strcmp(source, "data") && !input) ||
        (strcmp(schedule, "periodic") && strcmp(schedule, "relative")) ||
        duration_s > 3600 || period_ms < 1 || period_ms > 3600000 || deadline_ms < 1 || deadline_ms > period_ms) {
        fprintf(stderr, "required: --output existing-directory --input csv (for data); "
            "source data|cpu|sense_hat; schedule periodic|relative; "
            "duration <=3600s; 1ms <= period; deadline <= period\n");
        return 2;
    }
    int64_t duration = llround(duration_s * 1e9), period = llround(period_ms * 1e6);
    int64_t deadline = llround(deadline_ms * 1e6);
    if (duration < period || duration % period != 0 || duration / period > 1000000) {
        fprintf(stderr, "duration must contain 1..1000000 whole periods\n"); return 2;
    }
    size_t count = (size_t)(duration / period);
    timing_row *rows = calloc(count, sizeof(*rows));
    critter_memory_t memory;
    if (!rows || critter_memory_init(&memory, 100U)) { free(rows); return 1; }
    /* Touch timing pages before the measured interval. -1 denotes an unattempted slot. */
    for (size_t i = 0; i < count; ++i)
        rows[i].start = rows[i].acquired = rows[i].saved = rows[i].finish = rows[i].cpu = -1;
    if (snprintf(sample_path, sizeof(sample_path), "%s/samples.csv", output) >= (int)sizeof(sample_path) ||
        snprintf(trace_path, sizeof(trace_path), "%s/timing.csv", output) >= (int)sizeof(trace_path) ||
        snprintf(info_path, sizeof(info_path), "%s/experiment.json", output) >= (int)sizeof(info_path)) {
        fprintf(stderr, "output path too long\n"); free(rows); critter_memory_free(&memory); return 2;
    }
    if (!access(sample_path, F_OK) || !access(trace_path, F_OK) || !access(info_path, F_OK)) {
        fprintf(stderr, "output directory contains earlier measurement files; use a fresh directory\n");
        free(rows); critter_memory_free(&memory); return 2;
    }
    if (setenv("CRITTER_OUTPUT_FILE", sample_path, 1) ||
        (input && setenv("CRITTER_INPUT_FILE", input, 1))) { perror("setenv"); return 1; }
    signal(SIGINT, on_signal);
    signal(SIGTERM, on_signal);
    int failed = 0;
    int64_t t0 = now_ns(CLOCK_MONOTONIC) + INT64_C(100000000);
    int64_t real0 = now_ns(CLOCK_REALTIME);
    for (size_t k = 0; k < count && !interrupted; ++k) {
        if (!strcmp(schedule, "periodic") || k == 0) {
            if (wait_until(t0 + (int64_t)k * period)) { failed = 1; break; }
        }
        if (now_ns(CLOCK_MONOTONIC) >= t0 + duration) break;
        timing_row *r = &rows[k];
        critter_sample_t sample = {0};
        r->start = now_ns(CLOCK_MONOTONIC) - t0;
        int64_t cpu0 = now_ns(CLOCK_PROCESS_CPUTIME_ID);
        int read_result;
        if (source_id == TEMPERATURE_SOURCE_SENSE_HAT) {
            read_result = critter_io_read_sample(&sample);
            if (sample.source != TEMPERATURE_SOURCE_SENSE_HAT) read_result = -1;
        } else {
            read_result = critter_io_get_temperature_from_source(&sample.temperature_c, source_id);
            sample.source = (critter_temperature_source_t)source_id;
            sample.timestamp_s = (double)now_ns(CLOCK_REALTIME) / 1e9;
        }
        r->source = sample.source;
        r->read_ok = read_result == 0;
        if (r->read_ok) {
            r->acquired = now_ns(CLOCK_MONOTONIC) - t0;
            r->save_ok = critter_io_save_sample(&sample) == 0;
            r->saved = now_ns(CLOCK_MONOTONIC) - t0;
            size_t previous_outliers = memory.total_outliers;
            r->filter_ok = critter_memory_add_sample(&memory, &sample) == 0;
            r->outlier = memory.total_outliers > previous_outliers;
        }
        r->cpu = now_ns(CLOCK_PROCESS_CPUTIME_ID) - cpu0;
        r->finish = now_ns(CLOCK_MONOTONIC) - t0;
        if (!r->read_ok || !r->save_ok || !r->filter_ok) failed = 1;
        if (!strcmp(schedule, "periodic")) {
            /* Never catch up with a burst: releases already passed are recorded as skipped. */
            size_t next = (size_t)((r->finish + period - 1) / period);
            if (next > k + 1) k = next - 1;
        } else {
            if (wait_until(now_ns(CLOCK_MONOTONIC) + period)) { failed = 1; break; }
        }
    }
    if (!interrupted && wait_until(t0 + duration)) failed = 1;
    int64_t collection_end = now_ns(CLOCK_MONOTONIC) - t0;
    int64_t analysis_start = now_ns(CLOCK_MONOTONIC);
    critter_window_summary_t summary = {0};
    critter_analysis_result_t analysis = {0};
    int analysis_ok = critter_memory_build_summary(&memory, &summary) == 0 &&
        critter_compute_analysis(&summary, 30, &analysis) == 0;
    int64_t analysis_ns = now_ns(CLOCK_MONOTONIC) - analysis_start;
    FILE *trace = fopen(trace_path, "w");
    if (!trace) { perror(trace_path); free(rows); critter_memory_free(&memory); return 1; }
    fprintf(trace, "slot,release_ns,start_ns,acquired_ns,saved_ns,finish_ns,cpu_ns,read_ok,save_ok,filter_ok,source,outlier\n");
    for (size_t k = 0; k < count; ++k) {
        timing_row *r = &rows[k];
        fprintf(trace, "%zu,%" PRId64 ",%" PRId64 ",%" PRId64 ",%" PRId64 ",%" PRId64
            ",%" PRId64 ",%d,%d,%d,%d,%d\n", k, (int64_t)k * period,
            r->start, r->acquired, r->saved, r->finish, r->cpu,
            r->read_ok, r->save_ok, r->filter_ok, r->source, r->outlier);
    }
    int trace_error = ferror(trace);
    if (fclose(trace) || trace_error) failed = 1;
    FILE *info = fopen(info_path, "w");
    if (!info) { perror(info_path); free(rows); critter_memory_free(&memory); return 1; }
    fprintf(info, "{\"schema\":1,\"pid\":%ld,\"duration_ns\":%" PRId64
        ",\"period_ns\":%" PRId64 ",\"deadline_ns\":%" PRId64
        ",\"start_monotonic_ns\":%" PRId64 ",\"setup_realtime_ns\":%" PRId64
        ",\"collection_end_ns\":%" PRId64 ",\"schedule\":\"%s\",\"source\":\"%s\""
        ",\"interrupted\":%s,\"operation_failed\":%s,\"analysis_ok\":%s,\"analysis_ns\":%" PRId64
        ",\"summary_count\":%zu,\"valid_inputs\":%zu,\"outliers\":%zu,\"prediction_c\":%.9g}\n",
        (long)getpid(), duration, period, deadline, t0, real0, collection_end, schedule, source,
        interrupted ? "true" : "false", failed ? "true" : "false", analysis_ok ? "true" : "false",
        analysis_ns, summary.sample_count, memory.total_valid_samples, memory.total_outliers,
        analysis.predicted_temperature_c);
    int info_error = ferror(info);
    if (fclose(info) || info_error) failed = 1;
    free(rows);
    critter_memory_free(&memory);
    return interrupted ? 130 : failed || !analysis_ok ? 1 : 0;
}
