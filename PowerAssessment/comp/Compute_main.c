#define _POSIX_C_SOURCE 200809L

#include <stdio.h>
#include <time.h>

#include "Computation/critter_computation.h"
#include "compute_input.h"

int main(void)
{
    critter_analysis_result_t analysis;
    const double prediction_horizon_s = 30.0;
    struct timespec start_ts;
    struct timespec end_ts;

    if (clock_gettime(CLOCK_MONOTONIC, &start_ts) != 0)
    {
        fprintf(stderr, "failed to read start time\n");
        return 1;
    }
    /* One real prediction call, just as in Pilot; no repetition or padding. */
    if (critter_compute_analysis(&compute_input, prediction_horizon_s, &analysis) != 0)
    {
        fprintf(stderr, "failed to compute analysis\n");
        return 1;
    }
    if (clock_gettime(CLOCK_MONOTONIC, &end_ts) != 0)
    {
        fprintf(stderr, "failed to read end time\n");
        return 1;
    }

    printf("analysis: current=%.2f predicted=%.6f trend=%.6f rate=%.6f hvac=%s heating=%s cooling=%s stable=%s\n",
           analysis.current_temperature_c, analysis.predicted_temperature_c,
           analysis.trend_c_per_s, analysis.rate_of_change_c_per_s,
           analysis.likely_hvac_active ? "true" : "false",
           analysis.likely_heating ? "true" : "false",
           analysis.likely_cooling ? "true" : "false",
           analysis.stable ? "true" : "false");
    printf("one prediction: %.0f ns (limited by clock resolution/overhead; not energy)\n",
           (double)(end_ts.tv_sec - start_ts.tv_sec) * 1000000000.0
           + (double)(end_ts.tv_nsec - start_ts.tv_nsec));
    return 0;
}
