/* Run with: python3 PowerAssessment/asm/test_equivalence.py
 * Compares the original and edited ARM instructions, including error paths.
 * Hardware register reads are mocked; no sensors or power settings are changed.
 */
#include <assert.h>
#include <float.h>
#include <math.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <fenv.h>
#include "Memory/critter_memory.h"
#include "Computation/critter_computation.h"
#include "Utils/SenseHat/sense_hat_environment.h"
#include "PowerAssessment/mem/memory_dataset.h"
#include "PowerAssessment/comp/compute_input.h"
#define DECL(p) \
int p##critter_memory_init(critter_memory_t *, size_t); \
void p##critter_memory_free(critter_memory_t *); \
int p##critter_memory_add_sample(critter_memory_t *, const critter_sample_t *); \
int p##critter_memory_build_summary(const critter_memory_t *, critter_window_summary_t *); \
int p##critter_compute_analysis(const critter_window_summary_t *, double, critter_analysis_result_t *); \
double p##critter_median(double *, size_t); \
double p##critter_stddev(double *, size_t, double); \
int p##pressure(sense_hat_environment_t *, double *);
DECL(orig_)
DECL(edit_)
void orig_sleep(struct timespec *);
void edit_sleep(struct timespec *);
_Static_assert(sizeof(critter_sample_t) == 40, "assembly sample layout");
_Static_assert(sizeof(critter_memory_t) == 72, "assembly memory layout");
_Static_assert(sizeof(critter_window_summary_t) == 136, "assembly summary layout");
_Static_assert(sizeof(critter_analysis_result_t) == 96, "assembly result layout");
static int fail_allocation;
void *mock_malloc(size_t size) {
    if (fail_allocation) { fail_allocation = 0; return NULL; }
    return malloc(size);
}
void *mock_calloc(size_t count, size_t size) {
    if (fail_allocation) { fail_allocation = 0; return NULL; }
    return calloc(count, size);
}
static uint64_t seed = UINT64_C(0xc001d00d12345678);
static uint64_t rng(void) { seed ^= seed << 13; seed ^= seed >> 7; seed ^= seed << 17; return seed; }
static uint32_t pressure_raw;
static int pressure_fail, pressure_reads;
int mock_read_register(int fd, uint8_t reg, uint8_t *value) {
    assert(fd == 7 && reg >= 0x28 && reg <= 0x2a);
    if (++pressure_reads == pressure_fail) return -1;
    *value = (uint8_t)(pressure_raw >> ((reg - 0x28) * 8));
    return 0;
}
static void equal_bytes(const void *a, const void *b, size_t size, const char *what) {
    if (memcmp(a, b, size) != 0) { fprintf(stderr, "Mismatch: %s\n", what); abort(); }
}
static void check_compute(const critter_window_summary_t *s, double horizon) {
    critter_analysis_result_t a, b;
    memset(&a, 0xa5, sizeof a); memset(&b, 0xa5, sizeof b);
    int ra = orig_critter_compute_analysis(s, horizon, &a);
    int rb = edit_critter_compute_analysis(s, horizon, &b);
    assert(ra == rb);
    equal_bytes(&a, &b, sizeof a, "compute result");
}
static void check_summary(critter_memory_t *a, critter_memory_t *b) {
    critter_window_summary_t sa, sb;
    memset(&sa, 0xa5, sizeof sa); memset(&sb, 0xa5, sizeof sb);
    int ra = orig_critter_memory_build_summary(a, &sa);
    int rb = edit_critter_memory_build_summary(b, &sb);
    assert(ra == rb);
    equal_bytes(&sa, &sb, sizeof sa, "memory summary");
    if (!ra) check_compute(&sb, 30.0);
}
static void check_memory_state(critter_memory_t *a, critter_memory_t *b) {
    critter_memory_t copy = *a;
    copy.buffer = b->buffer;
    equal_bytes(&copy, b, sizeof copy, "memory state");
    if (a->buffer) equal_bytes(a->buffer, b->buffer, a->capacity * sizeof *a->buffer, "ring contents");
}
int main(void) {
    struct timespec ta, tb;
    orig_sleep(&ta); edit_sleep(&tb);
    equal_bytes(&ta, &tb, sizeof ta, "sleep interval");
    assert(tb.tv_sec == 0 && tb.tv_nsec == 100000000);
    assert(orig_critter_memory_init(NULL, 100) == -1);
    assert(edit_critter_memory_init(NULL, 100) == -1);
    assert(orig_critter_memory_add_sample(NULL, NULL) == -1);
    assert(edit_critter_memory_add_sample(NULL, NULL) == -1);
    assert(orig_critter_memory_build_summary(NULL, NULL) == -1);
    assert(edit_critter_memory_build_summary(NULL, NULL) == -1);
    orig_critter_memory_free(NULL); edit_critter_memory_free(NULL);
    const size_t capacities[] = {1, 2, 3, 5, 17, 99, 100, 101};
    for (size_t k = 0; k < sizeof capacities / sizeof *capacities; ++k) {
        critter_memory_t a, b;
        assert(!orig_critter_memory_init(&a, capacities[k]));
        assert(!edit_critter_memory_init(&b, capacities[k]));
        check_summary(&a, &b);
        for (size_t i = 0; i < 650; ++i) {
            critter_sample_t s = {0};
            s.timestamp_s = 1000.0 + i * 0.1;
            s.temperature_c = 22.0 + ((int)(rng() % 100) - 50) / 100.0;
            s.source = (critter_temperature_source_t)(1 + rng() % 3);
            s.has_humidity = i % 2; s.humidity_percent = 40.0;
            s.has_pressure = i % 3 != 0; s.pressure_hpa = 1013.0;
            if (i % 37 == 0) s.temperature_c += 90.0;
            if (i % 67 == 0) s.temperature_c = NAN;
            if (i % 71 == 0) s.timestamp_s = -1.0;
            if (i % 73 == 0) s.source = TEMPERATURE_SOURCE_UNKNOWN;
            if (i % 79 == 0) s.humidity_percent = INFINITY;
            if (i % 83 == 0) s.pressure_hpa = -1.0;
            assert(orig_critter_memory_add_sample(&a, &s) == edit_critter_memory_add_sample(&b, &s));
            check_memory_state(&a, &b);
            if (i % 19 == 0) check_summary(&a, &b);
        }
        check_summary(&a, &b);
        orig_critter_memory_free(&a); edit_critter_memory_free(&b);
    }
    // Original fixed experiment, checked after every input.
    critter_memory_t a, b;
    assert(!orig_critter_memory_init(&a, 100)); assert(!edit_critter_memory_init(&b, 100));
    for (size_t i = 0; i < MEMORY_SAMPLE_COUNT; ++i) {
        critter_sample_t s = { .timestamp_s = MEMORY_FIRST_TIMESTAMP_S + i * 0.1,
            .temperature_c = memory_temperatures_c[i], .source = TEMPERATURE_SOURCE_DATA };
        assert(!orig_critter_memory_add_sample(&a, &s)); assert(!edit_critter_memory_add_sample(&b, &s));
        check_memory_state(&a, &b);
    }
    assert(b.total_outliers == 6 && b.count == 100 && b.total_valid_samples == 600);
    check_summary(&a, &b);
    // Preserve allocation-failure behavior for both summary and outlier checking.
    critter_window_summary_t sa, sb;
    memset(&sa, 0xa5, sizeof sa); memset(&sb, 0xa5, sizeof sb);
    fail_allocation = 1;
    assert(orig_critter_memory_build_summary(&a, &sa) == -1);
    fail_allocation = 1;
    assert(edit_critter_memory_build_summary(&b, &sb) == -1);
    equal_bytes(&sa, &sb, sizeof sa, "failed summary output");
    critter_sample_t next = {.timestamp_s = 10000.0, .temperature_c = 25.0,
                            .source = TEMPERATURE_SOURCE_DATA};
    fail_allocation = 1;
    assert(!orig_critter_memory_add_sample(&a, &next));
    fail_allocation = 1;
    assert(!edit_critter_memory_add_sample(&b, &next));
    check_memory_state(&a, &b);
    orig_critter_memory_free(&a); edit_critter_memory_free(&b);
    fail_allocation = 1;
    assert(orig_critter_memory_init(&a, 100) == -1);
    fail_allocation = 1;
    assert(edit_critter_memory_init(&b, 100) == -1);
    check_memory_state(&a, &b);
    // Check sorting contents and ordered variance on odd/even windows, including signed zero.
    for (size_t n = 0; n <= 101; ++n) {
        double va[101], vb[101];
        for (size_t i = 0; i < n; ++i) va[i] = vb[i] = (int)(rng() % 21) - 10.0;
        if (n > 2) { va[0] = vb[0] = -0.0; va[1] = vb[1] = 0.0; }
        double ma = orig_critter_median(va, n), mb = edit_critter_median(vb, n);
        equal_bytes(&ma, &mb, sizeof ma, "median");
        equal_bytes(va, vb, n * sizeof *va, "sort contents");
        ma = orig_critter_stddev(va, n, 0.125); mb = edit_critter_stddev(vb, n, 0.125);
        equal_bytes(&ma, &mb, sizeof ma, "stddev");
    }
    check_compute(NULL, 30.0);
    assert(orig_critter_compute_analysis(&compute_input, 30.0, NULL) == -1);
    assert(edit_critter_compute_analysis(&compute_input, 30.0, NULL) == -1);
    const double special[] = {-INFINITY, -DBL_MAX, -1.0, -0.05, -0.03, -0.02, -0.0, 0.0,
        0.02, 0.03, 0.05, 0.5, 1.0, DBL_MAX, INFINITY, NAN};
    for (size_t i = 0; i < sizeof special / sizeof *special; ++i) {
        for (size_t j = 0; j < sizeof special / sizeof *special; ++j) {
            critter_window_summary_t s = compute_input;
            s.first_timestamp_s = 1.0; s.last_timestamp_s = 2.0;
            s.mean_temperature_c = 0.0; s.latest_temperature_c = special[i];
            s.stddev_temperature_c = special[j];
            check_compute(&s, 30.0);
            s.last_timestamp_s = special[j]; check_compute(&s, 30.0);
            check_compute(&s, special[i]);
        }
    }
    // Check exact threshold equality and its immediate floating-point neighbors.
    const double thresholds[] = {-0.05, -0.03, -0.02, 0.02, 0.03, 0.05};
    for (size_t i = 0; i < sizeof thresholds / sizeof *thresholds; ++i) {
        for (int direction = -1; direction <= 1; ++direction) {
            critter_window_summary_t s = compute_input;
            s.first_timestamp_s = 1.0; s.last_timestamp_s = 2.0;
            s.mean_temperature_c = 0.0;
            s.latest_temperature_c = direction ? nextafter(thresholds[i], direction < 0 ? -INFINITY : INFINITY) : thresholds[i];
            s.stddev_temperature_c = 0.5;
            check_compute(&s, 30.0);
            s.stddev_temperature_c = nextafter(0.5, 0.0); check_compute(&s, 30.0);
            s.stddev_temperature_c = nextafter(0.5, INFINITY); check_compute(&s, 30.0);
        }
    }
    for (int i = 0; i < 10000; ++i) {
        critter_window_summary_t s = compute_input;
        s.first_timestamp_s = (double)(rng() % 100000);
        s.last_timestamp_s = s.first_timestamp_s + (int)(rng() % 200) - 100;
        s.latest_temperature_c = ((int)(rng() % 100000) - 50000) / 100.0;
        s.mean_temperature_c = ((int)(rng() % 100000) - 50000) / 100.0;
        s.stddev_temperature_c = (rng() % 2000) / 1000.0;
        s.sample_count = rng() % 101;
        check_compute(&s, ((int)(rng() % 20000) - 10000) / 100.0);
    }
    // Mock only hardware reads; run the real pressure conversion instructions.
    sense_hat_environment_t sensor = {.pressure_fd = 7, .initialized = true};
    const uint32_t edges[] = {0, 1, 0x7fffff, 0x800000, 0xfffffe, 0xffffff};
    for (int i = 0; i < 50006; ++i) {
        pressure_raw = i < 6 ? edges[i] : (uint32_t)rng() & 0xffffff;
        double da = 999.0, db = 999.0;
        pressure_fail = 0; pressure_reads = 0;
        assert(!orig_pressure(&sensor, &da)); assert(pressure_reads == 3);
        pressure_reads = 0;
        assert(!edit_pressure(&sensor, &db)); assert(pressure_reads == 3);
        equal_bytes(&da, &db, sizeof da, "pressure");
    }
    for (pressure_fail = 1; pressure_fail <= 3; ++pressure_fail) {
        double da = 999.0, db = 999.0;
        pressure_reads = 0; assert(orig_pressure(&sensor, &da) == -1);
        assert(pressure_reads == pressure_fail);
        pressure_reads = 0; assert(edit_pressure(&sensor, &db) == -1);
        assert(pressure_reads == pressure_fail);
        equal_bytes(&da, &db, sizeof da, "pressure failure output");
    }
    double d;
    assert(orig_pressure(NULL, &d) == edit_pressure(NULL, &d));
    assert(orig_pressure(&sensor, NULL) == edit_pressure(&sensor, NULL));
    sensor.initialized = false;
    assert(orig_pressure(&sensor, &d) == edit_pressure(&sensor, &d));
    const int rounding_modes[] = {FE_TONEAREST, FE_DOWNWARD, FE_UPWARD, FE_TOWARDZERO};
    for (size_t i = 0; i < sizeof rounding_modes / sizeof *rounding_modes; ++i) {
        assert(fesetround(rounding_modes[i]) == 0);
        check_compute(&compute_input, 30.0);
        orig_sleep(&ta); edit_sleep(&tb);
        equal_bytes(&ta, &tb, sizeof ta, "sleep interval rounding");
        double va[] = {0x1p-1074, 0x1p-1073}, vb[] = {0x1p-1074, 0x1p-1073};
        double ma = orig_critter_median(va, 2), mb = edit_critter_median(vb, 2);
        equal_bytes(&ma, &mb, sizeof ma, "subnormal median rounding");
    }
    assert(fesetround(FE_TONEAREST) == 0);
    puts("PASS: original vs edited ARM instructions: dataset, rings, summaries, sorting, stddev, compute boundaries/random inputs, pressure conversion/errors.");
}
