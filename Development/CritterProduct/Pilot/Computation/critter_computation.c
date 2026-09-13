#include "critter_computation.h"

#include <math.h>



_Static_assert(sizeof(((critter_analysis_result_t *)0)->analysis_timestamp_s)    >= sizeof(double), "analysis_timestamp_s narrower than double (FLP34-C)");
_Static_assert(sizeof(((critter_analysis_result_t *)0)->current_temperature_c)   >= sizeof(double), "current_temperature_c narrower than double (FLP34-C)");
_Static_assert(sizeof(((critter_analysis_result_t *)0)->prediction_horizon_s)    >= sizeof(double), "prediction_horizon_s narrower than double (FLP34-C)");
_Static_assert(sizeof(((critter_analysis_result_t *)0)->trend_c_per_s)           >= sizeof(double), "trend_c_per_s narrower than double (FLP34-C)");
_Static_assert(sizeof(((critter_analysis_result_t *)0)->rate_of_change_c_per_s)  >= sizeof(double), "rate_of_change_c_per_s narrower than double (FLP34-C)");
_Static_assert(sizeof(((critter_analysis_result_t *)0)->slope_c_per_s)           >= sizeof(double), "slope_c_per_s narrower than double (FLP34-C)");
_Static_assert(sizeof(((critter_analysis_result_t *)0)->intercept_c)             >= sizeof(double), "intercept_c narrower than double (FLP34-C)");
_Static_assert(sizeof(((critter_analysis_result_t *)0)->variance_c)              >= sizeof(double), "variance_c narrower than double (FLP34-C)");
_Static_assert(sizeof(((critter_analysis_result_t *)0)->recent_delta_c)          >= sizeof(double), "recent_delta_c narrower than double (FLP34-C)");
_Static_assert(sizeof(((critter_analysis_result_t *)0)->predicted_temperature_c) >= sizeof(double), "predicted_temperature_c narrower than double (FLP34-C)");



int critter_compute_analysis(const critter_window_summary_t *summary,
                            double prediction_horizon_s,
                            critter_analysis_result_t *result)
{
    double delta_t;
    double slope;
    double intercept;
    double recent_delta_c;
    double variance;

    if (summary == NULL || result == NULL || summary->sample_count == 0U || !isfinite(prediction_horizon_s))
        return -1;

    result->analysis_timestamp_s = summary->last_timestamp_s;
    result->current_temperature_c = summary->latest_temperature_c;
    result->source = summary->source;
    result->prediction_horizon_s = prediction_horizon_s;

    delta_t = summary->last_timestamp_s - summary->first_timestamp_s;
    if (delta_t <= 0.0)
        delta_t = 1.0;

    slope = (summary->latest_temperature_c - summary->mean_temperature_c) / delta_t;
    intercept = summary->latest_temperature_c - slope * summary->last_timestamp_s;
    recent_delta_c = summary->latest_temperature_c - summary->min_temperature_c;
    variance = summary->stddev_temperature_c * summary->stddev_temperature_c;

    result->trend_c_per_s = slope;
    result->rate_of_change_c_per_s = slope;
    result->slope_c_per_s = slope;
    result->intercept_c = intercept;
    result->variance_c = variance;
    result->recent_delta_c = recent_delta_c;
    result->predicted_temperature_c = summary->latest_temperature_c + slope * prediction_horizon_s;
    result->stable = fabs(slope) < 0.05 && summary->stddev_temperature_c < 0.5;
    result->rising = slope > 0.02;
    result->falling = slope < -0.02;
    result->likely_hvac_active = fabs(slope) > 0.05 || summary->stddev_temperature_c > 0.5;
    result->likely_heating = slope > 0.03 && summary->latest_temperature_c > summary->mean_temperature_c;
    result->likely_cooling = slope < -0.03 && summary->latest_temperature_c < summary->mean_temperature_c;

    return 0;
}
