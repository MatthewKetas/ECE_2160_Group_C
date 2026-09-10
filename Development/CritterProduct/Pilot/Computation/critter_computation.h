#ifndef CRITTER_COMPUTATION_H
#define CRITTER_COMPUTATION_H

#include "../critter_types.h"

#ifdef __cplusplus
extern "C" {
#endif

int critter_compute_analysis(const critter_window_summary_t *summary,
                            double prediction_horizon_s,
                            critter_analysis_result_t *result);

#ifdef __cplusplus
}
#endif

#endif
