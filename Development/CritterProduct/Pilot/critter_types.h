#ifndef CRITTER_TYPES_H
#define CRITTER_TYPES_H

#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>
#include <math.h>

#define CRITTER_MEMORY_MAX_CAPACITY 100U
#define CRITTER_MAX_SAMPLE_TOTAL 1000000000U
/* H01: Arithmetic envelope, not a sensor accuracy/range specification. */
#define CRITTER_NUMERIC_LIMIT 1.0e100

#ifdef __cplusplus
extern "C" {
#endif

typedef enum
{
    TEMPERATURE_SOURCE_UNKNOWN = 0,
    TEMPERATURE_SOURCE_SENSE_HAT = 1,
    TEMPERATURE_SOURCE_DATA = 2,
    TEMPERATURE_SOURCE_CPU = 3
} critter_temperature_source_t;

typedef struct
{
    double timestamp_s;
    double temperature_c;
    double humidity_percent;
    double pressure_hpa;
    critter_temperature_source_t source;
    bool has_humidity;
    bool has_pressure;
} critter_sample_t;

/* H01/H03: Share validation at acquisition, persistence and memory boundaries. */
static inline int critter_sample_valid(const critter_sample_t *sample)
{
    return sample != NULL && isfinite(sample->timestamp_s) &&
           sample->timestamp_s > 0.0 && sample->timestamp_s <= CRITTER_NUMERIC_LIMIT &&
           isfinite(sample->temperature_c) && fabs(sample->temperature_c) <= CRITTER_NUMERIC_LIMIT &&
           sample->source >= TEMPERATURE_SOURCE_SENSE_HAT && sample->source <= TEMPERATURE_SOURCE_CPU &&
           (!sample->has_humidity || (isfinite(sample->humidity_percent) &&
             sample->humidity_percent >= 0.0 && sample->humidity_percent <= 100.0)) &&
           (!sample->has_pressure || (isfinite(sample->pressure_hpa) &&
             sample->pressure_hpa > 0.0 && sample->pressure_hpa <= CRITTER_NUMERIC_LIMIT));
}

typedef struct
{
    size_t sample_count;
    size_t valid_sample_count;
    size_t outlier_count;
    size_t sample_count_by_source[4];
    double min_temperature_c;
    double max_temperature_c;
    double mean_temperature_c;
    double median_temperature_c;
    double stddev_temperature_c;
    double first_timestamp_s;
    double first_temperature_c;
    double last_timestamp_s;
    double retained_ratio;
    critter_temperature_source_t source;
    double latest_temperature_c;
} critter_window_summary_t;

typedef struct
{
    double current_temperature_c;
    double trend_c_per_s;
    double rate_of_change_c_per_s;
    double predicted_temperature_c;
    double prediction_horizon_s;
    double analysis_timestamp_s;
    double slope_c_per_s;
    double intercept_c;
    double variance_c;
    double recent_delta_c;
    bool stable;
    bool rising;
    bool falling;
    bool likely_hvac_active;
    bool likely_cooling;
    bool likely_heating;
    critter_temperature_source_t source;
} critter_analysis_result_t;

#ifdef __cplusplus
}
#endif

#endif
