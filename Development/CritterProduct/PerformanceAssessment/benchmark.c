#define _POSIX_C_SOURCE 200809L

#include <errno.h>
#include <inttypes.h>
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

#include "Computation/critter_computation.h"
#include "IO/critter_io.h"
#include "Memory/critter_memory.h"
#include "replay_sensor.h"

#define IO_UNIT 1
#define MEMORY_UNIT 2
#define COMPUTATION_UNIT 3
#define PIPELINE_UNIT 4

#ifndef BENCH_SENSOR_REAL
#define BENCH_SENSOR_REAL 0
#endif
#define HAS_IO (BENCH_UNIT == IO_UNIT || BENCH_UNIT == PIPELINE_UNIT)
#define HAS_MEMORY (BENCH_UNIT == MEMORY_UNIT || BENCH_UNIT == PIPELINE_UNIT)
#define LIVE_IO (BENCH_SENSOR_REAL && HAS_IO)

enum { CASES = 6, SAMPLES = 600, CAPACITY = 100 };
#if BENCH_UNIT == COMPUTATION_UNIT || BENCH_UNIT == PIPELINE_UNIT
static const double prediction_horizon_s = 30.0;
#endif

typedef struct
{
    size_t retained;
    size_t rejected;
    size_t outliers;
    size_t heating;
    size_t cooling;
    size_t stable;
    size_t sense_hat_samples;
    double summary_checksum;
    double prediction_checksum;
} benchmark_result_t;

#if LIVE_IO
static critter_sample_t *captured_samples;
static bool checking_capture;

static int transfer_capture(size_t samples, bool read_capture)
{
    const char *path = getenv("CRITTER_CAPTURE_FILE");
    if (path == NULL)
        return -1;
    FILE *file = fopen(path, read_capture ? "rb" : "wb");
    if (file == NULL)
        return -1;
    size_t count = read_capture
        ? fread(captured_samples, sizeof(*captured_samples), samples, file)
        : fwrite(captured_samples, sizeof(*captured_samples), samples, file);
    int status = count == samples ? 0 : -1;
    if (read_capture && fgetc(file) != EOF)
        status = -1;
    if (ferror(file))
        status = -1;
    if (fclose(file) != 0)
        status = -1;
    return status;
}
#endif

#if BENCH_UNIT == COMPUTATION_UNIT
static critter_window_summary_t inputs[CASES][SAMPLES];
#elif !LIVE_IO
static critter_sample_t inputs[CASES][SAMPLES];
#endif

static void prepare_inputs(bool training)
{
#if LIVE_IO
    (void)training;
#else
    const double slopes[] = {0.0, 0.017, -0.019};

    for (size_t pattern = 0; pattern < CASES; ++pattern)
    {
        const double base = (training ? 23.8 : 22.5) + 0.4 * (double)pattern;
        const double slope = slopes[(pattern + (training ? 1U : 0U)) % 3U];
        const double step = slope * (training ? 0.92 : 1.0);

        for (size_t i = 0; i < SAMPLES; ++i)
        {
            const double jitter = 0.004 * (double)((i * 7U + pattern) % 13U);
#if BENCH_UNIT == COMPUTATION_UNIT
            /* Vary the inputs to the existing predictor independently of memory timing. */
            const double last = 1010.0 + (double)i * 0.1;
            const double mean = base + step * (double)i + jitter;
            inputs[pattern][i] = (critter_window_summary_t){
                .source = TEMPERATURE_SOURCE_SENSE_HAT, .sample_count = CAPACITY,
                .first_timestamp_s = last - 9.9, .last_timestamp_s = last,
                .latest_temperature_c = mean + step * 49.0, .mean_temperature_c = mean,
                .min_temperature_c = mean - 1.0,
                .stddev_temperature_c = step == 0.0 ? 0.03 : 0.53
            };
#else
            const size_t outlier_period = training ? 89U : 97U;
            const bool spike = i % outlier_period == outlier_period - 1U;
            inputs[pattern][i] = (critter_sample_t){
                .source = TEMPERATURE_SOURCE_SENSE_HAT,
                .temperature_c = base + step * (double)i + jitter + (spike ? 8.0 : 0.0),
                .humidity_percent = 32.0 + jitter,
                .pressure_hpa = 982.0 + jitter,
                .has_humidity = true, .has_pressure = true
            };
#endif
        }
    }
#endif
}

#if BENCH_UNIT == COMPUTATION_UNIT || BENCH_UNIT == PIPELINE_UNIT
static void record_decisions(benchmark_result_t *result, const critter_analysis_result_t *analysis)
{
    result->heating += analysis->likely_heating;
    result->cooling += analysis->likely_cooling;
    result->stable += analysis->stable;
}
#endif

static int run_window(size_t window, benchmark_result_t *result)
{
#if !LIVE_IO
    const size_t pattern = window % CASES;
#endif

#if BENCH_UNIT == COMPUTATION_UNIT
    critter_analysis_result_t analysis;
    double predictions = 0.0;

    for (size_t i = 0; i < SAMPLES; ++i)
    {
        if (critter_compute_analysis(&inputs[pattern][i], prediction_horizon_s, &analysis) != 0)
            return -1;
        /* Keep all result fields observable even when LTO inlines the predictor. */
        __asm__ volatile("" : : "m"(analysis));
        predictions += analysis.predicted_temperature_c;
    }
    result->prediction_checksum += predictions;
    record_decisions(result, &analysis);
    return 0;
#else
    int status = 0;
#if HAS_MEMORY
    critter_memory_t memory;
    critter_window_summary_t summary;

    if (critter_memory_init(&memory, CAPACITY) != 0)
        return -1;
#elif !LIVE_IO
    (void)result;
#endif

    for (size_t i = 0; i < SAMPLES; ++i)
    {
        const size_t index = window * SAMPLES + i;
#if LIVE_IO
        critter_sample_t sample = {0};
        if (checking_capture)
            sample = captured_samples[index];
        else
        {
            if (critter_io_read_sample(&sample) != 0 || sample.source != TEMPERATURE_SOURCE_SENSE_HAT)
            {
                fprintf(stderr, "Sense HAT acquisition failed at sample %zu. Check I2C and sensor access.\n", index);
                status = -1;
                break;
            }
            captured_samples[index] = sample;
        }
        if (sample.source != TEMPERATURE_SOURCE_SENSE_HAT ||
            !sample.has_humidity || !sample.has_pressure ||
            !isfinite(sample.timestamp_s) || sample.timestamp_s <= 0.0 ||
            !isfinite(sample.temperature_c) || !isfinite(sample.humidity_percent) ||
            sample.humidity_percent < 0.0 || sample.humidity_percent > 100.0 ||
            !isfinite(sample.pressure_hpa) || sample.pressure_hpa <= 0.0)
        {
            fprintf(stderr, "Invalid Sense HAT reading at sample %zu\n", index);
            status = -1;
            break;
        }
        result->sense_hat_samples += 1U;
#else
        critter_sample_t sample = inputs[pattern][i];
        const double timestamp = 1000.0 + (double)index / 10.0;

#if HAS_IO
        replay_set_sample(&sample);
        if (critter_io_read_sample(&sample) != 0 || sample.source != TEMPERATURE_SOURCE_SENSE_HAT)
        {
            status = -1;
            break;
        }
#endif
        /* Preserve sample order and nominal spacing across builds. */
        sample.timestamp_s = timestamp;
#endif
#if HAS_IO
        if (critter_io_save_sample(&sample) != 0)
        {
            status = -1;
            break;
        }
#endif
#if HAS_MEMORY
        if (critter_memory_add_sample(&memory, &sample) != 0)
        {
            status = -1;
            break;
        }
#endif
    }

#if HAS_MEMORY
    if (status == 0)
        status = critter_memory_build_summary(&memory, &summary);
    if (status == 0)
    {
        result->retained += summary.sample_count;
        result->rejected += memory.total_rejected_samples;
        result->outliers += memory.total_outliers;
        result->summary_checksum += summary.min_temperature_c + summary.max_temperature_c
            + summary.mean_temperature_c + summary.median_temperature_c
            + summary.stddev_temperature_c + summary.latest_temperature_c;
#if BENCH_UNIT == PIPELINE_UNIT
        critter_analysis_result_t analysis;
        status = critter_compute_analysis(&summary, prediction_horizon_s, &analysis);
        if (status == 0)
        {
            result->prediction_checksum += analysis.predicted_temperature_c;
            record_decisions(result, &analysis);
            double sample_rate_hz = 10.0;
#if LIVE_IO
            const double duration = captured_samples[(window + 1U) * SAMPLES - 1U].timestamp_s
                                  - captured_samples[window * SAMPLES].timestamp_s;
            sample_rate_hz = duration > 0.0 ? (double)(SAMPLES - 1U) / duration : 0.0;
#endif
            status = critter_io_save_metrics(&summary, &analysis, SAMPLES,
                memory.total_valid_samples, memory.total_rejected_samples, memory.total_outliers, sample_rate_hz);
        }
#endif
    }
    critter_memory_free(&memory);
#endif
    return status;
#endif
}

static uint64_t now_ns(clockid_t clock)
{
    struct timespec time;
    if (clock_gettime(clock, &time) != 0)
    {
        perror("clock_gettime");
        exit(EXIT_FAILURE);
    }
    return (uint64_t)time.tv_sec * 1000000000U + (uint64_t)time.tv_nsec;
}

int main(int argc, char **argv)
{
    if (argc != 3 || (strcmp(argv[1], "train") != 0 && strcmp(argv[1], "evaluate") != 0
#if LIVE_IO
                     && strcmp(argv[1], "check") != 0
#endif
                     ))
    {
        fprintf(stderr, "usage: benchmark train|evaluate windows\n");
        return EXIT_FAILURE;
    }

    char *end;
    errno = 0;
    unsigned long windows = strtoul(argv[2], &end, 10);
    if (errno || end == argv[2] || *end != '\0' || windows < 1 || windows > 200000)
    {
        fprintf(stderr, "invalid window count\n");
        return EXIT_FAILURE;
    }

    benchmark_result_t result = {0};
#if LIVE_IO
    const size_t samples = (size_t)windows * SAMPLES;
    captured_samples = calloc(samples, sizeof(*captured_samples));
    if (captured_samples == NULL)
    {
        fprintf(stderr, "failed to allocate sensor capture\n");
        return EXIT_FAILURE;
    }
    checking_capture = strcmp(argv[1], "check") == 0;
    if (checking_capture && transfer_capture(samples, true) != 0)
    {
        fprintf(stderr, "failed to read exact sensor capture\n");
        free(captured_samples);
        return EXIT_FAILURE;
    }
#endif
    prepare_inputs(strcmp(argv[1], "train") == 0);
    const uint64_t cpu_start = now_ns(CLOCK_PROCESS_CPUTIME_ID);
    const uint64_t wall_start = now_ns(CLOCK_MONOTONIC);

    for (size_t window = 0; window < windows; ++window)
    {
        if (run_window(window, &result) != 0)
        {
            fprintf(stderr, "Critter workload failed in window %zu\n", window);
#if LIVE_IO
            free(captured_samples);
#endif
            return EXIT_FAILURE;
        }
    }

    const uint64_t wall_ns = now_ns(CLOCK_MONOTONIC) - wall_start;
    const uint64_t cpu_ns = now_ns(CLOCK_PROCESS_CPUTIME_ID) - cpu_start;
#if LIVE_IO
    if (!checking_capture && transfer_capture(samples, false) != 0)
    {
        fprintf(stderr, "failed to save exact sensor capture\n");
        free(captured_samples);
        return EXIT_FAILURE;
    }
    free(captured_samples);
#endif
    printf("{\"wall_ns\":%" PRIu64 ",\"cpu_ns\":%" PRIu64 ",\"retained\":%zu,"
           "\"rejected\":%zu,\"outliers\":%zu,\"heating_windows\":%zu,\"cooling_windows\":%zu,"
           "\"stable_windows\":%zu,\"summary_checksum\":%.17g,\"prediction_checksum\":%.17g,"
           "\"sense_hat_samples\":%zu}\n",
           wall_ns, cpu_ns, result.retained, result.rejected, result.outliers, result.heating,
           result.cooling, result.stable, result.summary_checksum, result.prediction_checksum,
           result.sense_hat_samples);
    return EXIT_SUCCESS;
}
