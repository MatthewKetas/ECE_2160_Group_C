#include <math.h>
#include <stdio.h>
#include <stdlib.h>

#include "Memory/critter_memory.h"
#include "Computation/critter_computation.h"

int main(void)
{
    critter_sample_t samples[6] = {
        {.timestamp_s = 1.0, .temperature_c = 20.0, .source = TEMPERATURE_SOURCE_DATA},
        {.timestamp_s = 2.0, .temperature_c = 20.5, .source = TEMPERATURE_SOURCE_DATA},
        {.timestamp_s = 3.0, .temperature_c = 21.0, .source = TEMPERATURE_SOURCE_DATA},
        {.timestamp_s = 4.0, .temperature_c = 21.5, .source = TEMPERATURE_SOURCE_DATA},
        {.timestamp_s = 5.0, .temperature_c = 22.0, .source = TEMPERATURE_SOURCE_DATA},
        {.timestamp_s = 6.0, .temperature_c = 90.0, .source = TEMPERATURE_SOURCE_DATA}
    };

    critter_memory_t memory;
    if (critter_memory_init(&memory, 5) != 0)
    {
        fprintf(stderr, "memory init failed\n");
        return 1;
    }

    for (size_t i = 0; i < 6; ++i)
    {
        critter_memory_add_sample(&memory, &samples[i]);
    }

    if (memory.total_valid_samples != 6)
    {
        fprintf(stderr, "expected 6 valid samples (including 1 outlier), got %zu\n", memory.total_valid_samples);
        return 1;
    }

    if (memory.total_outliers != 1)
    {
        fprintf(stderr, "expected 1 outlier, got %zu\n", memory.total_outliers);
        return 1;
    }

    critter_window_summary_t summary = {0};
    if (critter_memory_build_summary(&memory, &summary) != 0)
    {
        fprintf(stderr, "summary build failed\n");
        return 1;
    }

    if (summary.sample_count != 5)
    {
        fprintf(stderr, "expected summary count 5, got %zu\n", summary.sample_count);
        return 1;
    }

    critter_analysis_result_t result = {0};
    if (critter_compute_analysis(&summary, 10.0, &result) != 0)
    {
        fprintf(stderr, "analysis failed\n");
        return 1;
    }

    if (!isfinite(result.predicted_temperature_c) || !isfinite(result.rate_of_change_c_per_s))
    {
        fprintf(stderr, "analysis values are not finite\n");
        return 1;
    }

    puts("critter pilot tests passed");
    return 0;
}
