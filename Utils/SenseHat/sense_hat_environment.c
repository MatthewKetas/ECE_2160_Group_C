#include "sense_hat_environment.h"

#include <fcntl.h>
#include <errno.h>
#include <math.h>
/* A15: Linux owns I2C; host builds return unsupported and exercise fallback. */
#ifdef __linux__
#include <linux/i2c-dev.h>
#endif
#include <stddef.h>
#include <string.h>
#include <sys/ioctl.h>
#include <unistd.h>

#define HTS221_ADDRESS 0x5F
#define LPS25H_ADDRESS 0x5C

#define WHO_AM_I 0x0F
#define HTS221_WHO_AM_I_VALUE 0xBC
#define LPS25H_WHO_AM_I_VALUE 0xBD

#define HTS221_CTRL_REG1 0x20
#define HTS221_HUMIDITY_OUT_L 0x28
#define HTS221_HUMIDITY_OUT_H 0x29
#define HTS221_TEMP_OUT_L 0x2A
#define HTS221_TEMP_OUT_H 0x2B
#define HTS221_H0_RH_X2 0x30
#define HTS221_H1_RH_X2 0x31
#define HTS221_T0_DEGC_X8 0x32
#define HTS221_T1_DEGC_X8 0x33
#define HTS221_T1_T0_MSB 0x35
#define HTS221_H0_T0_OUT_L 0x36
#define HTS221_H0_T0_OUT_H 0x37
#define HTS221_H1_T0_OUT_L 0x3A
#define HTS221_H1_T0_OUT_H 0x3B
#define HTS221_T0_OUT_L 0x3C
#define HTS221_T0_OUT_H 0x3D
#define HTS221_T1_OUT_L 0x3E
#define HTS221_T1_OUT_H 0x3F

#define LPS25H_CTRL_REG1 0x20
#define LPS25H_PRESS_OUT_XL 0x28
#define LPS25H_PRESS_OUT_L 0x29
#define LPS25H_PRESS_OUT_H 0x2A

#define CTRL_POWER_ON 0x80
#define CTRL_BDU 0x04

static int open_sensor(const char *i2c_device, uint8_t address)
{
    if (i2c_device == NULL || i2c_device[0] == '\0')
        return -1;
#ifdef __linux__
    int fd = open(i2c_device, O_RDWR);
    if (fd < 0)
        return -1;
    if (ioctl(fd, I2C_SLAVE, address) < 0)
    {
        (void)close(fd); /* A05: Error already propagates; do not retry close. */
        return -1;
    }
    return fd;
#else
    (void)address;
    errno = ENOTSUP;
    return -1;
#endif
}

static int write_register(int fd, uint8_t reg, uint8_t value)
{
    uint8_t data[2] = {reg, value};
    return write(fd, data, sizeof(data)) == (ssize_t)sizeof(data) ? 0 : -1;
}

static int read_register(int fd, uint8_t reg, uint8_t *value)
{
    if (value == NULL)
        return -1;

    if (write(fd, &reg, 1) != 1)
        return -1;

    return read(fd, value, 1) == 1 ? 0 : -1;
}

static int read_int16(int fd, uint8_t low_reg, uint8_t high_reg, int16_t *value)
{
    uint8_t low;
    uint8_t high;

    if (value == NULL || read_register(fd, low_reg, &low) != 0 || read_register(fd, high_reg, &high) != 0)
        return -1;

    /* H06: Decode signed wire values without an out-of-range unsigned-to-signed cast. */
    uint32_t bits = ((uint32_t)high << 8) | (uint32_t)low;
    int32_t signed_value = (int32_t)bits;
    if (bits >= 0x8000U)
        signed_value -= 65536;
    *value = (int16_t)signed_value;
    return 0;
}

static int validate_device(int fd, uint8_t expected_id)
{
    uint8_t id;
    return read_register(fd, WHO_AM_I, &id) == 0 && id == expected_id ? 0 : -1;
}

static int load_hts221_calibration(sense_hat_environment_t *sensor)
{
    uint8_t h0_x2;
    uint8_t h1_x2;
    uint8_t t0_lsb;
    uint8_t t1_lsb;
    uint8_t t_msb;

    if (read_register(sensor->hts_fd, HTS221_H0_RH_X2, &h0_x2) != 0 ||
        read_register(sensor->hts_fd, HTS221_H1_RH_X2, &h1_x2) != 0 ||
        read_register(sensor->hts_fd, HTS221_T0_DEGC_X8, &t0_lsb) != 0 ||
        read_register(sensor->hts_fd, HTS221_T1_DEGC_X8, &t1_lsb) != 0 ||
        read_register(sensor->hts_fd, HTS221_T1_T0_MSB, &t_msb) != 0)
    {
        return -1;
    }

    /* H13: Assemble promoted masks in an unsigned type without implicit narrowing. */
    uint32_t t0_x8 = ((uint32_t)(t_msb & 0x03U) << 8) | t0_lsb;
    uint32_t t1_x8 = ((uint32_t)(t_msb & 0x0CU) << 6) | t1_lsb;

    sensor->h0_percent = h0_x2 / 2.0;
    sensor->h1_percent = h1_x2 / 2.0;
    sensor->t0_c = t0_x8 / 8.0;
    sensor->t1_c = t1_x8 / 8.0;

    if (read_int16(sensor->hts_fd, HTS221_H0_T0_OUT_L, HTS221_H0_T0_OUT_H, &sensor->h0_out) != 0 ||
        read_int16(sensor->hts_fd, HTS221_H1_T0_OUT_L, HTS221_H1_T0_OUT_H, &sensor->h1_out) != 0 ||
        read_int16(sensor->hts_fd, HTS221_T0_OUT_L, HTS221_T0_OUT_H, &sensor->t0_out) != 0 ||
        read_int16(sensor->hts_fd, HTS221_T1_OUT_L, HTS221_T1_OUT_H, &sensor->t1_out) != 0)
    {
        return -1;
    }

    return sensor->h1_out != sensor->h0_out && sensor->t1_out != sensor->t0_out ? 0 : -1;
}

/* S04: This operation does not modify the handle. */
int sense_hat_environment_set_hts_odr(const sense_hat_environment_t *sensor, sense_hat_hts_odr_t odr)
{
    if (sensor == NULL || sensor->hts_fd < 0 || odr < SENSE_HAT_HTS_ODR_1_HZ || odr > SENSE_HAT_HTS_ODR_12_5_HZ)
        return -1;

    uint8_t ctrl = CTRL_POWER_ON | CTRL_BDU | (uint8_t)odr;
    return write_register(sensor->hts_fd, HTS221_CTRL_REG1, ctrl);
}

/* S05: This operation does not modify the handle. */
int sense_hat_environment_set_pressure_odr(const sense_hat_environment_t *sensor, sense_hat_pressure_odr_t odr)
{
    if (sensor == NULL || sensor->pressure_fd < 0 || odr < SENSE_HAT_PRESSURE_ODR_1_HZ || odr > SENSE_HAT_PRESSURE_ODR_25_HZ)
        return -1;

    /* H13: Validated ODR 1..4 and fixed masks fit in eight bits. */
    uint8_t ctrl = (uint8_t)(CTRL_POWER_ON | CTRL_BDU | ((uint32_t)odr << 4));
    return write_register(sensor->pressure_fd, LPS25H_CTRL_REG1, ctrl);
}

int sense_hat_environment_init(sense_hat_environment_t *sensor,
                               const char *i2c_device,
                               sense_hat_hts_odr_t hts_odr,
                               sense_hat_pressure_odr_t pressure_odr)
{
    if (sensor == NULL || i2c_device == NULL)
        return -1;

    (void)memset(sensor, 0, sizeof(*sensor));
    sensor->hts_fd = -1;
    sensor->pressure_fd = -1;

    /* A16: Structured cleanup replaces all three prohibited goto branches. */
    sensor->hts_fd = open_sensor(i2c_device, HTS221_ADDRESS);
    if (sensor->hts_fd < 0)
        return -1;
    sensor->pressure_fd = open_sensor(i2c_device, LPS25H_ADDRESS);

    if (sensor->pressure_fd < 0 ||
        validate_device(sensor->hts_fd, HTS221_WHO_AM_I_VALUE) != 0 ||
        validate_device(sensor->pressure_fd, LPS25H_WHO_AM_I_VALUE) != 0 ||
        load_hts221_calibration(sensor) != 0 ||
        sense_hat_environment_set_hts_odr(sensor, hts_odr) != 0 ||
        sense_hat_environment_set_pressure_odr(sensor, pressure_odr) != 0)
    {
        (void)sense_hat_environment_close(sensor);
        return -1;
    }

    sensor->initialized = true;
    return 0;

}

int sense_hat_environment_close(sense_hat_environment_t *sensor)
{
    if (sensor == NULL)
        return -1;
    /* A05: Close both handles, report failure and invalidate ownership exactly once. */
    int status = 0;
    if (sensor->hts_fd >= 0 && close(sensor->hts_fd) != 0)
        status = -1;
    if (sensor->pressure_fd >= 0 && close(sensor->pressure_fd) != 0)
        status = -1;
    *sensor = (sense_hat_environment_t){.hts_fd = -1, .pressure_fd = -1};
    return status;
}

/* S06: This operation does not modify the handle. */
int sense_hat_environment_read_temperature(const sense_hat_environment_t *sensor, double *temperature_c)
{
    int16_t raw;

    /* H07: Public handles must still have nondegenerate finite calibration. */
    if (sensor == NULL || temperature_c == NULL || !sensor->initialized ||
        sensor->t1_out == sensor->t0_out || !isfinite(sensor->t0_c) || !isfinite(sensor->t1_c) ||
        fabs(sensor->t0_c) > 1000.0 || fabs(sensor->t1_c) > 1000.0 ||
        read_int16(sensor->hts_fd, HTS221_TEMP_OUT_L, HTS221_TEMP_OUT_H, &raw) != 0)
    {
        return -1;
    }

    *temperature_c = sensor->t0_c +
                     ((double)(raw - sensor->t0_out) * (sensor->t1_c - sensor->t0_c)) /
                     (double)(sensor->t1_out - sensor->t0_out);
    return 0;
}

/* S07: This operation does not modify the handle. */
int sense_hat_environment_read_humidity(const sense_hat_environment_t *sensor, double *humidity_percent)
{
    int16_t raw;

    /* H07: Reject zero calibration spans before division. */
    if (sensor == NULL || humidity_percent == NULL || !sensor->initialized ||
        sensor->h1_out == sensor->h0_out || !isfinite(sensor->h0_percent) || !isfinite(sensor->h1_percent) ||
        sensor->h0_percent < 0.0 || sensor->h0_percent > 100.0 ||
        sensor->h1_percent < 0.0 || sensor->h1_percent > 100.0 ||
        read_int16(sensor->hts_fd, HTS221_HUMIDITY_OUT_L, HTS221_HUMIDITY_OUT_H, &raw) != 0)
    {
        return -1;
    }

    *humidity_percent = sensor->h0_percent +
                        ((double)(raw - sensor->h0_out) * (sensor->h1_percent - sensor->h0_percent)) /
                        (double)(sensor->h1_out - sensor->h0_out);

    if (*humidity_percent < 0.0)
        *humidity_percent = 0.0;
    else if (*humidity_percent > 100.0)
        *humidity_percent = 100.0;

    return 0;
}

/* S08: This operation does not modify the handle. */
int sense_hat_environment_read_pressure(const sense_hat_environment_t *sensor, double *pressure_hpa)
{
    uint8_t xl;
    uint8_t low;
    uint8_t high;

    if (sensor == NULL || pressure_hpa == NULL || !sensor->initialized ||
        read_register(sensor->pressure_fd, LPS25H_PRESS_OUT_XL, &xl) != 0 ||
        read_register(sensor->pressure_fd, LPS25H_PRESS_OUT_L, &low) != 0 ||
        read_register(sensor->pressure_fd, LPS25H_PRESS_OUT_H, &high) != 0)
    {
        return -1;
    }

    uint32_t raw24 = ((uint32_t)high << 16) | ((uint32_t)low << 8) | xl;
    /* H08: Subtract the sign weight in a type that represents both outcomes. */
    int32_t raw = (int32_t)raw24;
    if ((raw24 & 0x00800000U) != 0U)
        raw -= 16777216;

    *pressure_hpa = raw / 4096.0;
    return 0;
}

/* A17: This operation does not modify the handle. */
int sense_hat_environment_read(const sense_hat_environment_t *sensor, sense_hat_environment_reading_t *reading)
{
    if (sensor == NULL || reading == NULL)
        return -1;

    sense_hat_environment_reading_t acquired = {0};
    if (sense_hat_environment_read_temperature(sensor, &acquired.temperature_c) != 0)
        return -1;
    /* A17: Optional humidity/pressure failures must not discard valid temperature. */
    if (sense_hat_environment_read_humidity(sensor, &acquired.humidity_percent) != 0)
        acquired.humidity_percent = NAN;
    if (sense_hat_environment_read_pressure(sensor, &acquired.pressure_hpa) != 0)
        acquired.pressure_hpa = NAN;
    *reading = acquired;

    return 0;
}
