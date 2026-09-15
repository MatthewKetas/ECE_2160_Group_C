#define _POSIX_C_SOURCE 200809L
#ifdef NDEBUG
#undef NDEBUG
#endif
#include <assert.h>
#include <stdint.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include "sense_hat_environment.h"

static uint8_t registers[2][256];
static uint8_t selected_register;
static int fail_pressure;
static ssize_t simulated_write(int fd, const void *buffer, size_t count)
{
    const uint8_t *bytes = buffer;
    if (fd < 0 || (fd == 11 && fail_pressure))
        return -1;
    if (count == 1U)
        selected_register = bytes[0];
    return (ssize_t)count;
}
static ssize_t simulated_read(int fd, void *buffer, size_t count)
{
    if (fd < 0 || count != 1U || (fd == 11 && fail_pressure))
        return -1;
    *(uint8_t *)buffer = registers[fd == 11 ? 1 : 0][selected_register];
    return 1;
}
#define write simulated_write
#define read simulated_read
#include "../../../../Utils/SenseHat/sense_hat_environment.c"
#undef write
#undef read

int main(void)
{
    int16_t decoded = 0;
    const uint32_t cases[] = {0U, 32767U, 32768U, 65535U};
    const int32_t expected[] = {0, 32767, -32768, -1};
    for (size_t i = 0U; i < 4U; ++i)
    {
        registers[0][1] = (uint8_t)(cases[i] & 255U);
        registers[0][2] = (uint8_t)(cases[i] >> 8);
        assert(read_int16(10, 1, 2, &decoded) == 0);
        assert(decoded == expected[i]);
    }
    sense_hat_environment_t handle = {.initialized = true, .hts_fd = 10, .pressure_fd = 11,
        .t0_c = 0.0, .t1_c = 100.0, .t0_out = 0, .t1_out = 1000,
        .h0_percent = 0.0, .h1_percent = 100.0, .h0_out = 0, .h1_out = 1000};
    registers[0][HTS221_TEMP_OUT_L] = 200U;
    registers[0][HTS221_TEMP_OUT_H] = 0U;
    double value = 0.0;
    assert(sense_hat_environment_read_temperature(&handle, &value) == 0 && value == 20.0);
    registers[1][LPS25H_PRESS_OUT_XL] = 255U;
    registers[1][LPS25H_PRESS_OUT_L] = 255U;
    registers[1][LPS25H_PRESS_OUT_H] = 255U;
    assert(sense_hat_environment_read_pressure(&handle, &value) == 0 && value == -1.0 / 4096.0);
    fail_pressure = 1;
    sense_hat_environment_reading_t reading;
    assert(sense_hat_environment_read(&handle, &reading) == 0);
    assert(reading.temperature_c == 20.0 && isnan(reading.pressure_hpa));
    handle.t1_out = handle.t0_out;
    assert(sense_hat_environment_read_temperature(&handle, &value) == -1);
    puts("simulated signed decoding, calibration and optional-channel failures passed");
    return 0;
}
