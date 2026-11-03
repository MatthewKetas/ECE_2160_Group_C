/* Mac development only: Pi measurements compile the real Linux sensor utility. */
#include "sense_hat_environment.h"
#include <string.h>
int sense_hat_environment_init(sense_hat_environment_t *s, const char *d,
    sense_hat_hts_odr_t h, sense_hat_pressure_odr_t p) {
    (void)s; (void)d; (void)h; (void)p; return -1;
}
int sense_hat_environment_read(sense_hat_environment_t *s, sense_hat_environment_reading_t *r) {
    (void)s; (void)r; return -1;
}
void sense_hat_environment_close(sense_hat_environment_t *s) { memset(s,0,sizeof(*s)); }
