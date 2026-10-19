/* Mac-only link substitute. Never selected by the Linux CMake build. */
#include "sense_hat_environment.h"
int sense_hat_environment_init(sense_hat_environment_t *s, const char *p,
    sense_hat_hts_odr_t h, sense_hat_pressure_odr_t r)
{ (void)s; (void)p; (void)h; (void)r; return -1; }
int sense_hat_environment_read(sense_hat_environment_t *s,
    sense_hat_environment_reading_t *r)
{ (void)s; (void)r; return -1; }
void sense_hat_environment_close(sense_hat_environment_t *s) { (void)s; }
