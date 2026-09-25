#ifndef COMPUTE_INPUT_H
#define COMPUTE_INPUT_H

#include "critter_types.h"

/* Saved summary from all 600 memory_dataset.h samples through the real memory
 * functions (capacity 100). No memory processing runs in the compute driver.
 */
static const critter_window_summary_t compute_input = {
    .sample_count = 100U,
    .valid_sample_count = 100U,
    .outlier_count = 6U,
    .sample_count_by_source = {0U, 0U, 100U, 0U},
    .min_temperature_c = 24.48,
    .max_temperature_c = 25.005,
    .mean_temperature_c = 24.74235,
    .median_temperature_c = 24.7425,
    .stddev_temperature_c = 0.14573169696397553,
    .first_timestamp_s = 1700000049.8,
    .last_timestamp_s = 1700000059.8,
    .retained_ratio = 1.0 / 6.0,
    .source = TEMPERATURE_SOURCE_DATA,
    .latest_temperature_c = 24.99
};

#endif
