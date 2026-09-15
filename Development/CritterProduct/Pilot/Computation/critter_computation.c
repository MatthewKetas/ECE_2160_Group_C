#include "critter_computation.h"

#include <math.h>

/* H09: Validate every arithmetic input before computing or modifying outputs. */
static int critter_summary_valid(const critter_window_summary_t *summary, double horizon)
{
    if (summary == NULL || summary->sample_count == 0U ||
        summary->sample_count > CRITTER_MEMORY_MAX_CAPACITY ||
        !isfinite(horizon) || horizon < 0.0 || horizon > CRITTER_NUMERIC_LIMIT)
        return 0;
    const double values[] = {summary->first_timestamp_s, summary->last_timestamp_s,
        summary->first_temperature_c, summary->latest_temperature_c, summary->mean_temperature_c,
        summary->min_temperature_c, summary->max_temperature_c, summary->stddev_temperature_c};
    for (size_t i = 0U; i < sizeof(values) / sizeof(values[0]); ++i)
    {
        if (!isfinite(values[i]) || fabs(values[i]) > CRITTER_NUMERIC_LIMIT)
            return 0;
    }
    return summary->first_timestamp_s > 0.0 && summary->last_timestamp_s >= summary->first_timestamp_s &&
           (summary->sample_count == 1U || summary->last_timestamp_s - summary->first_timestamp_s >= 1.0e-6) &&
           summary->min_temperature_c <= summary->max_temperature_c && summary->stddev_temperature_c >= 0.0 &&
           summary->first_temperature_c >= summary->min_temperature_c && summary->first_temperature_c <= summary->max_temperature_c &&
           summary->latest_temperature_c >= summary->min_temperature_c && summary->latest_temperature_c <= summary->max_temperature_c &&
           summary->mean_temperature_c >= summary->min_temperature_c && summary->mean_temperature_c <= summary->max_temperature_c &&
           summary->source >= TEMPERATURE_SOURCE_UNKNOWN && summary->source <= TEMPERATURE_SOURCE_CPU;
}

int critter_compute_analysis(const critter_window_summary_t *summary,
                            double prediction_horizon_s,
                            critter_analysis_result_t *result)
{
    if (result == NULL || !critter_summary_valid(summary, prediction_horizon_s))
        return -1;
    critter_analysis_result_t computed = {0};
    computed.analysis_timestamp_s = summary->last_timestamp_s;
    computed.current_temperature_c = summary->latest_temperature_c;
    computed.source = summary->source;
    computed.prediction_horizon_s = prediction_horizon_s;
    /* A18: Endpoint slope reproduces a linear ramp; latest-minus-mean halved it. */
    double delta_t = summary->last_timestamp_s - summary->first_timestamp_s;
    double slope = summary->sample_count == 1U ? 0.0 :
        (summary->latest_temperature_c - summary->first_temperature_c) / delta_t;
    computed.trend_c_per_s = slope;
    computed.rate_of_change_c_per_s = slope;
    computed.slope_c_per_s = slope;
    computed.intercept_c = summary->latest_temperature_c - slope * summary->last_timestamp_s;
    computed.variance_c = summary->stddev_temperature_c * summary->stddev_temperature_c;
    computed.recent_delta_c = summary->latest_temperature_c - summary->first_temperature_c;
    computed.predicted_temperature_c = summary->latest_temperature_c + slope * prediction_horizon_s;
    computed.stable = fabs(slope) < 0.05 && summary->stddev_temperature_c < 0.5;
    computed.rising = slope > 0.02;
    computed.falling = slope < -0.02;
    /* A19: CPU and mixed-source readings cannot establish ambient HVAC activity. */
    if (summary->source == TEMPERATURE_SOURCE_SENSE_HAT || summary->source == TEMPERATURE_SOURCE_DATA)
    {
        computed.likely_heating = slope > 0.03 && summary->latest_temperature_c > summary->mean_temperature_c;
        computed.likely_cooling = slope < -0.03 && summary->latest_temperature_c < summary->mean_temperature_c;
        /* A26: Heating/cooling cannot be asserted while HVAC activity is false. */
        computed.likely_hvac_active = computed.likely_heating || computed.likely_cooling ||
            fabs(slope) > 0.05 || summary->stddev_temperature_c > 0.5;
    }
    *result = computed;
    return 0;
}
