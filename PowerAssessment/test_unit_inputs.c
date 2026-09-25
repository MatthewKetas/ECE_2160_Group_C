/* Replay without sleeps to check the fixed dataset and saved compute input. */
#include <assert.h>
#include <math.h>
#include <stdio.h>
#include "Memory/critter_memory.h"
#include "Computation/critter_computation.h"
#include "mem/memory_dataset.h"
#include "comp/compute_input.h"

int main(void)
{
    critter_memory_t memory;
    critter_window_summary_t summary;
    critter_analysis_result_t analysis;
    assert(MEMORY_SAMPLE_COUNT == 600U);
    assert(critter_memory_init(&memory, 100U) == 0);
    for (size_t i = 0; i < MEMORY_SAMPLE_COUNT; ++i)
    {
        critter_sample_t sample = {
            .timestamp_s = MEMORY_FIRST_TIMESTAMP_S + i * 0.1,
            .temperature_c = memory_temperatures_c[i],
            .source = TEMPERATURE_SOURCE_DATA
        };
        assert(critter_memory_add_sample(&memory, &sample) == 0);
    }
    assert(memory.total_received_samples == 600U);
    assert(memory.total_valid_samples == 600U);
    assert(memory.total_rejected_samples == 0U);
    assert(memory.total_outliers == 6U);
    assert(critter_memory_build_summary(&memory, &summary) == 0);
    assert(summary.sample_count == compute_input.sample_count);
    assert(summary.valid_sample_count == compute_input.valid_sample_count);
    assert(summary.outlier_count == compute_input.outlier_count);
    assert(summary.source == compute_input.source);
    for (size_t i = 0; i < 4U; ++i)
        assert(summary.sample_count_by_source[i] == compute_input.sample_count_by_source[i]);
#define CHECK_FIELD(field) assert(fabs(summary.field - compute_input.field) < 1e-10)
    CHECK_FIELD(min_temperature_c);
    CHECK_FIELD(max_temperature_c);
    CHECK_FIELD(mean_temperature_c);
    CHECK_FIELD(median_temperature_c);
    CHECK_FIELD(stddev_temperature_c);
    CHECK_FIELD(first_timestamp_s);
    CHECK_FIELD(last_timestamp_s);
    CHECK_FIELD(retained_ratio);
    CHECK_FIELD(latest_temperature_c);
#undef CHECK_FIELD
    assert(critter_compute_analysis(&compute_input, 30.0, &analysis) == 0);
    assert(fabs(analysis.predicted_temperature_c - 25.73295) < 1e-10);
    assert(analysis.stable && analysis.rising && !analysis.falling);
    assert(!analysis.likely_hvac_active && !analysis.likely_heating && !analysis.likely_cooling);
    critter_memory_free(&memory);
    puts("Dataset, memory summary, and single prediction checks passed.");
    return 0;
}
