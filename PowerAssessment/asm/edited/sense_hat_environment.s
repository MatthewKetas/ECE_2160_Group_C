	.arch armv8-a
	.file	"sense_hat_environment.c"
// GNU C11 (Debian 14.2.0-19) version 14.2.0 (aarch64-linux-gnu)
//	compiled by GNU C version 14.2.0, GMP version 6.3.0, MPFR version 4.2.1, MPC version 1.3.1, isl version isl-0.27-GMP

// warning: MPFR header version 4.2.1 differs from library version 4.2.2.
// GGC heuristics: --param ggc-min-expand=100 --param ggc-min-heapsize=131072
// options passed: -mlittle-endian -mabi=lp64 -O0 -std=c11 -fasynchronous-unwind-tables
	.text
	.align	2
	.type	open_sensor, %function
open_sensor:
.LFB0:
	.cfi_startproc
	stp	x29, x30, [sp, -48]!	//,,,
	.cfi_def_cfa_offset 48
	.cfi_offset 29, -48
	.cfi_offset 30, -40
	mov	x29, sp	//,
	str	x0, [sp, 24]	// i2c_device, i2c_device
	strb	w1, [sp, 23]	// address, address
// Utils/SenseHat/sense_hat_environment.c:46:     int fd = open(i2c_device, O_RDWR);
	mov	w1, 2	//,
	ldr	x0, [sp, 24]	//, i2c_device
	bl	open		//
	str	w0, [sp, 44]	//, fd
// Utils/SenseHat/sense_hat_environment.c:47:     if (fd < 0)
	ldr	w0, [sp, 44]	// tmp104, fd
	cmp	w0, 0	// tmp104,
	bge	.L2		//,
// Utils/SenseHat/sense_hat_environment.c:48:         return -1;
	mov	w0, -1	// _3,
	b	.L3		//
.L2:
// Utils/SenseHat/sense_hat_environment.c:50:     if (ioctl(fd, I2C_SLAVE, address) < 0)
	ldrb	w0, [sp, 23]	// _1, address
	mov	w2, w0	//, _1
	mov	x1, 1795	//,
	ldr	w0, [sp, 44]	//, fd
	bl	ioctl		//
// Utils/SenseHat/sense_hat_environment.c:50:     if (ioctl(fd, I2C_SLAVE, address) < 0)
	cmp	w0, 0	// _2,
	bge	.L4		//,
// Utils/SenseHat/sense_hat_environment.c:52:         close(fd);
	ldr	w0, [sp, 44]	//, fd
	bl	close		//
// Utils/SenseHat/sense_hat_environment.c:53:         return -1;
	mov	w0, -1	// _3,
	b	.L3		//
.L4:
// Utils/SenseHat/sense_hat_environment.c:56:     return fd;
	ldr	w0, [sp, 44]	// _3, fd
.L3:
// Utils/SenseHat/sense_hat_environment.c:57: }
	ldp	x29, x30, [sp], 48	//,,,
	.cfi_restore 30
	.cfi_restore 29
	.cfi_def_cfa_offset 0
	ret	
	.cfi_endproc
.LFE0:
	.size	open_sensor, .-open_sensor
	.align	2
	.type	write_register, %function
write_register:
.LFB1:
	.cfi_startproc
	stp	x29, x30, [sp, -48]!	//,,,
	.cfi_def_cfa_offset 48
	.cfi_offset 29, -48
	.cfi_offset 30, -40
	mov	x29, sp	//,
	str	w0, [sp, 28]	// fd, fd
	strb	w1, [sp, 27]	// reg, reg
	strb	w2, [sp, 26]	// value, value
// Utils/SenseHat/sense_hat_environment.c:61:     uint8_t data[2] = {reg, value};
	ldrb	w0, [sp, 27]	// tmp103, reg
	strb	w0, [sp, 40]	// tmp103, data[0]
	ldrb	w0, [sp, 26]	// tmp104, value
	strb	w0, [sp, 41]	// tmp104, data[1]
// Utils/SenseHat/sense_hat_environment.c:62:     return write(fd, data, sizeof(data)) == (ssize_t)sizeof(data) ? 0 : -1;
	add	x0, sp, 40	// tmp105,,
	mov	x2, 2	//,
	mov	x1, x0	//, tmp105
	ldr	w0, [sp, 28]	//, fd
	bl	write		//
// Utils/SenseHat/sense_hat_environment.c:62:     return write(fd, data, sizeof(data)) == (ssize_t)sizeof(data) ? 0 : -1;
	cmp	x0, 2	// _1,
	bne	.L6		//,
	mov	w0, 0	// iftmp.0_2,
// Utils/SenseHat/sense_hat_environment.c:62:     return write(fd, data, sizeof(data)) == (ssize_t)sizeof(data) ? 0 : -1;
	b	.L8		//
.L6:
// Utils/SenseHat/sense_hat_environment.c:62:     return write(fd, data, sizeof(data)) == (ssize_t)sizeof(data) ? 0 : -1;
	mov	w0, -1	// iftmp.0_2,
.L8:
// Utils/SenseHat/sense_hat_environment.c:63: }
	ldp	x29, x30, [sp], 48	//,,,
	.cfi_restore 30
	.cfi_restore 29
	.cfi_def_cfa_offset 0
	ret	
	.cfi_endproc
.LFE1:
	.size	write_register, .-write_register
	.align	2
	.type	read_register, %function
read_register:
.LFB2:
	.cfi_startproc
	stp	x29, x30, [sp, -32]!	//,,,
	.cfi_def_cfa_offset 32
	.cfi_offset 29, -32
	.cfi_offset 30, -24
	mov	x29, sp	//,
	str	w0, [sp, 28]	// fd, fd
	strb	w1, [sp, 27]	// reg, reg
	str	x2, [sp, 16]	// value, value
// Utils/SenseHat/sense_hat_environment.c:67:     if (value == NULL)
	ldr	x0, [sp, 16]	// tmp104, value
	cmp	x0, 0	// tmp104,
	bne	.L10		//,
// Utils/SenseHat/sense_hat_environment.c:68:         return -1;
	mov	w0, -1	// iftmp.1_4,
	b	.L11		//
.L10:
// Utils/SenseHat/sense_hat_environment.c:70:     if (write(fd, &reg, 1) != 1)
	add	x0, sp, 27	// tmp105,,
	mov	x2, 1	//,
	mov	x1, x0	//, tmp105
	ldr	w0, [sp, 28]	//, fd
	bl	write		//
// Utils/SenseHat/sense_hat_environment.c:70:     if (write(fd, &reg, 1) != 1)
	cmp	x0, 1	// _1,
	beq	.L12		//,
// Utils/SenseHat/sense_hat_environment.c:71:         return -1;
	mov	w0, -1	// iftmp.1_4,
	b	.L11		//
.L12:
// Utils/SenseHat/sense_hat_environment.c:73:     return read(fd, value, 1) == 1 ? 0 : -1;
	mov	x2, 1	//,
	ldr	x1, [sp, 16]	//, value
	ldr	w0, [sp, 28]	//, fd
	bl	read		//
// Utils/SenseHat/sense_hat_environment.c:73:     return read(fd, value, 1) == 1 ? 0 : -1;
	cmp	x0, 1	// _2,
	bne	.L13		//,
	mov	w0, 0	// iftmp.1_4,
// Utils/SenseHat/sense_hat_environment.c:73:     return read(fd, value, 1) == 1 ? 0 : -1;
	b	.L11		//
.L13:
// Utils/SenseHat/sense_hat_environment.c:73:     return read(fd, value, 1) == 1 ? 0 : -1;
	mov	w0, -1	// iftmp.1_4,
.L11:
// Utils/SenseHat/sense_hat_environment.c:74: }
	ldp	x29, x30, [sp], 32	//,,,
	.cfi_restore 30
	.cfi_restore 29
	.cfi_def_cfa_offset 0
	ret	
	.cfi_endproc
.LFE2:
	.size	read_register, .-read_register
	.align	2
	.type	read_int16, %function
read_int16:
.LFB3:
	.cfi_startproc
	stp	x29, x30, [sp, -48]!	//,,,
	.cfi_def_cfa_offset 48
	.cfi_offset 29, -48
	.cfi_offset 30, -40
	mov	x29, sp	//,
	str	w0, [sp, 28]	// fd, fd
	strb	w1, [sp, 27]	// low_reg, low_reg
	strb	w2, [sp, 26]	// high_reg, high_reg
	str	x3, [sp, 16]	// value, value
// Utils/SenseHat/sense_hat_environment.c:81:     if (value == NULL || read_register(fd, low_reg, &low) != 0 || read_register(fd, high_reg, &high) != 0)
	ldr	x0, [sp, 16]	// tmp110, value
	cmp	x0, 0	// tmp110,
	beq	.L16		//,
// Utils/SenseHat/sense_hat_environment.c:81:     if (value == NULL || read_register(fd, low_reg, &low) != 0 || read_register(fd, high_reg, &high) != 0)
	add	x0, sp, 47	// tmp111,,
	mov	x2, x0	//, tmp111
	ldrb	w1, [sp, 27]	//, low_reg
	ldr	w0, [sp, 28]	//, fd
	bl	read_register		//
// Utils/SenseHat/sense_hat_environment.c:81:     if (value == NULL || read_register(fd, low_reg, &low) != 0 || read_register(fd, high_reg, &high) != 0)
	cmp	w0, 0	// _1,
	bne	.L16		//,
// Utils/SenseHat/sense_hat_environment.c:81:     if (value == NULL || read_register(fd, low_reg, &low) != 0 || read_register(fd, high_reg, &high) != 0)
	add	x0, sp, 46	// tmp112,,
	mov	x2, x0	//, tmp112
	ldrb	w1, [sp, 26]	//, high_reg
	ldr	w0, [sp, 28]	//, fd
	bl	read_register		//
// Utils/SenseHat/sense_hat_environment.c:81:     if (value == NULL || read_register(fd, low_reg, &low) != 0 || read_register(fd, high_reg, &high) != 0)
	cmp	w0, 0	// _2,
	beq	.L17		//,
.L16:
// Utils/SenseHat/sense_hat_environment.c:82:         return -1;
	mov	w0, -1	// _9,
	b	.L19		//
.L17:
// Utils/SenseHat/sense_hat_environment.c:84:     *value = (int16_t)(((uint16_t)high << 8) | low);
	ldrb	w0, [sp, 46]	// high.2_3, high
	sxth	w0, w0	// _4, high.2_3
	ubfiz	w0, w0, 8, 8	// _5, _4,,
	sxth	w1, w0	// _5, _5
	ldrb	w0, [sp, 47]	// low.3_6, low
	sxth	w0, w0	// _7, low.3_6
	orr	w0, w1, w0	// tmp114, _5, _7
	sxth	w1, w0	// _8, tmp114
// Utils/SenseHat/sense_hat_environment.c:84:     *value = (int16_t)(((uint16_t)high << 8) | low);
	ldr	x0, [sp, 16]	// tmp115, value
	strh	w1, [x0]	// tmp116, *value_12(D)
// Utils/SenseHat/sense_hat_environment.c:85:     return 0;
	mov	w0, 0	// _9,
.L19:
// Utils/SenseHat/sense_hat_environment.c:86: }
	ldp	x29, x30, [sp], 48	//,,,
	.cfi_restore 30
	.cfi_restore 29
	.cfi_def_cfa_offset 0
	ret	
	.cfi_endproc
.LFE3:
	.size	read_int16, .-read_int16
	.align	2
	.type	validate_device, %function
validate_device:
.LFB4:
	.cfi_startproc
	stp	x29, x30, [sp, -48]!	//,,,
	.cfi_def_cfa_offset 48
	.cfi_offset 29, -48
	.cfi_offset 30, -40
	mov	x29, sp	//,
	str	w0, [sp, 28]	// fd, fd
	strb	w1, [sp, 27]	// expected_id, expected_id
// Utils/SenseHat/sense_hat_environment.c:91:     return read_register(fd, WHO_AM_I, &id) == 0 && id == expected_id ? 0 : -1;
	add	x0, sp, 47	// tmp104,,
	mov	x2, x0	//, tmp104
	mov	w1, 15	//,
	ldr	w0, [sp, 28]	//, fd
	bl	read_register		//
// Utils/SenseHat/sense_hat_environment.c:91:     return read_register(fd, WHO_AM_I, &id) == 0 && id == expected_id ? 0 : -1;
	cmp	w0, 0	// _1,
	bne	.L21		//,
// Utils/SenseHat/sense_hat_environment.c:91:     return read_register(fd, WHO_AM_I, &id) == 0 && id == expected_id ? 0 : -1;
	ldrb	w0, [sp, 47]	// id.5_2, id
// Utils/SenseHat/sense_hat_environment.c:91:     return read_register(fd, WHO_AM_I, &id) == 0 && id == expected_id ? 0 : -1;
	ldrb	w1, [sp, 27]	// tmp105, expected_id
	cmp	w1, w0	// tmp105, id.5_2
	bne	.L21		//,
// Utils/SenseHat/sense_hat_environment.c:91:     return read_register(fd, WHO_AM_I, &id) == 0 && id == expected_id ? 0 : -1;
	mov	w0, 0	// iftmp.4_3,
// Utils/SenseHat/sense_hat_environment.c:91:     return read_register(fd, WHO_AM_I, &id) == 0 && id == expected_id ? 0 : -1;
	b	.L23		//
.L21:
// Utils/SenseHat/sense_hat_environment.c:91:     return read_register(fd, WHO_AM_I, &id) == 0 && id == expected_id ? 0 : -1;
	mov	w0, -1	// iftmp.4_3,
.L23:
// Utils/SenseHat/sense_hat_environment.c:92: }
	ldp	x29, x30, [sp], 48	//,,,
	.cfi_restore 30
	.cfi_restore 29
	.cfi_def_cfa_offset 0
	ret	
	.cfi_endproc
.LFE4:
	.size	validate_device, .-validate_device
	.align	2
	.type	load_hts221_calibration, %function
load_hts221_calibration:
.LFB5:
	.cfi_startproc
	stp	x29, x30, [sp, -48]!	//,,,
	.cfi_def_cfa_offset 48
	.cfi_offset 29, -48
	.cfi_offset 30, -40
	mov	x29, sp	//,
	str	x0, [sp, 24]	// sensor, sensor
// Utils/SenseHat/sense_hat_environment.c:102:     if (read_register(sensor->hts_fd, HTS221_H0_RH_X2, &h0_x2) != 0 ||
	ldr	x0, [sp, 24]	// tmp156, sensor
	ldr	w0, [x0]	// _1, sensor_61(D)->hts_fd
	add	x1, sp, 43	// tmp157,,
	mov	x2, x1	//, tmp157
	mov	w1, 48	//,
	bl	read_register		//
// Utils/SenseHat/sense_hat_environment.c:102:     if (read_register(sensor->hts_fd, HTS221_H0_RH_X2, &h0_x2) != 0 ||
	cmp	w0, 0	// _2,
	bne	.L25		//,
// Utils/SenseHat/sense_hat_environment.c:103:         read_register(sensor->hts_fd, HTS221_H1_RH_X2, &h1_x2) != 0 ||
	ldr	x0, [sp, 24]	// tmp158, sensor
	ldr	w0, [x0]	// _3, sensor_61(D)->hts_fd
	add	x1, sp, 42	// tmp159,,
	mov	x2, x1	//, tmp159
	mov	w1, 49	//,
	bl	read_register		//
// Utils/SenseHat/sense_hat_environment.c:102:     if (read_register(sensor->hts_fd, HTS221_H0_RH_X2, &h0_x2) != 0 ||
	cmp	w0, 0	// _4,
	bne	.L25		//,
// Utils/SenseHat/sense_hat_environment.c:104:         read_register(sensor->hts_fd, HTS221_T0_DEGC_X8, &t0_lsb) != 0 ||
	ldr	x0, [sp, 24]	// tmp160, sensor
	ldr	w0, [x0]	// _5, sensor_61(D)->hts_fd
	add	x1, sp, 41	// tmp161,,
	mov	x2, x1	//, tmp161
	mov	w1, 50	//,
	bl	read_register		//
// Utils/SenseHat/sense_hat_environment.c:103:         read_register(sensor->hts_fd, HTS221_H1_RH_X2, &h1_x2) != 0 ||
	cmp	w0, 0	// _6,
	bne	.L25		//,
// Utils/SenseHat/sense_hat_environment.c:105:         read_register(sensor->hts_fd, HTS221_T1_DEGC_X8, &t1_lsb) != 0 ||
	ldr	x0, [sp, 24]	// tmp162, sensor
	ldr	w0, [x0]	// _7, sensor_61(D)->hts_fd
	add	x1, sp, 40	// tmp163,,
	mov	x2, x1	//, tmp163
	mov	w1, 51	//,
	bl	read_register		//
// Utils/SenseHat/sense_hat_environment.c:104:         read_register(sensor->hts_fd, HTS221_T0_DEGC_X8, &t0_lsb) != 0 ||
	cmp	w0, 0	// _8,
	bne	.L25		//,
// Utils/SenseHat/sense_hat_environment.c:106:         read_register(sensor->hts_fd, HTS221_T1_T0_MSB, &t_msb) != 0)
	ldr	x0, [sp, 24]	// tmp164, sensor
	ldr	w0, [x0]	// _9, sensor_61(D)->hts_fd
	add	x1, sp, 39	// tmp165,,
	mov	x2, x1	//, tmp165
	mov	w1, 53	//,
	bl	read_register		//
// Utils/SenseHat/sense_hat_environment.c:105:         read_register(sensor->hts_fd, HTS221_T1_DEGC_X8, &t1_lsb) != 0 ||
	cmp	w0, 0	// _10,
	beq	.L26		//,
.L25:
// Utils/SenseHat/sense_hat_environment.c:108:         return -1;
	mov	w0, -1	// iftmp.12_56,
	b	.L32		//
.L26:
// Utils/SenseHat/sense_hat_environment.c:111:     uint16_t t0_x8 = ((uint16_t)(t_msb & 0x03) << 8) | t0_lsb;
	ldrb	w0, [sp, 39]	// t_msb.6_11, t_msb
	sxth	w0, w0	// _12, t_msb.6_11
	ubfiz	w0, w0, 8, 8	// _13, _12,,
	sxth	w0, w0	// _13, _13
	and	w0, w0, 768	// tmp167, _13,
	sxth	w1, w0	// _14, tmp167
// Utils/SenseHat/sense_hat_environment.c:111:     uint16_t t0_x8 = ((uint16_t)(t_msb & 0x03) << 8) | t0_lsb;
	ldrb	w0, [sp, 41]	// t0_lsb.7_15, t0_lsb
	sxth	w0, w0	// _16, t0_lsb.7_15
	orr	w0, w1, w0	// tmp168, _14, _16
	sxth	w0, w0	// _17, tmp168
// Utils/SenseHat/sense_hat_environment.c:111:     uint16_t t0_x8 = ((uint16_t)(t_msb & 0x03) << 8) | t0_lsb;
	strh	w0, [sp, 46]	// tmp169, t0_x8
// Utils/SenseHat/sense_hat_environment.c:112:     uint16_t t1_x8 = ((uint16_t)(t_msb & 0x0C) << 6) | t1_lsb;
	ldrb	w0, [sp, 39]	// t_msb.8_18, t_msb
	sxth	w0, w0	// _19, t_msb.8_18
	ubfiz	w0, w0, 6, 10	// _20, _19,,
	sxth	w0, w0	// _20, _20
	and	w0, w0, 768	// tmp171, _20,
	sxth	w1, w0	// _21, tmp171
// Utils/SenseHat/sense_hat_environment.c:112:     uint16_t t1_x8 = ((uint16_t)(t_msb & 0x0C) << 6) | t1_lsb;
	ldrb	w0, [sp, 40]	// t1_lsb.9_22, t1_lsb
	sxth	w0, w0	// _23, t1_lsb.9_22
	orr	w0, w1, w0	// tmp172, _21, _23
	sxth	w0, w0	// _24, tmp172
// Utils/SenseHat/sense_hat_environment.c:112:     uint16_t t1_x8 = ((uint16_t)(t_msb & 0x0C) << 6) | t1_lsb;
	strh	w0, [sp, 44]	// tmp173, t1_x8
// Utils/SenseHat/sense_hat_environment.c:114:     sensor->h0_percent = h0_x2 / 2.0;
	ldrb	w0, [sp, 43]	// h0_x2.10_25, h0_x2
	scvtf	d30, w0	// _27, _26
	fmov	d31, 2.0e+0	// tmp174,
	fdiv	d31, d30, d31	// _28, _27, tmp174
// Utils/SenseHat/sense_hat_environment.c:114:     sensor->h0_percent = h0_x2 / 2.0;
	ldr	x0, [sp, 24]	// tmp175, sensor
	str	d31, [x0, 40]	// _28, sensor_61(D)->h0_percent
// Utils/SenseHat/sense_hat_environment.c:115:     sensor->h1_percent = h1_x2 / 2.0;
	ldrb	w0, [sp, 42]	// h1_x2.11_29, h1_x2
	scvtf	d30, w0	// _31, _30
	fmov	d31, 2.0e+0	// tmp176,
	fdiv	d31, d30, d31	// _32, _31, tmp176
// Utils/SenseHat/sense_hat_environment.c:115:     sensor->h1_percent = h1_x2 / 2.0;
	ldr	x0, [sp, 24]	// tmp177, sensor
	str	d31, [x0, 48]	// _32, sensor_61(D)->h1_percent
// Utils/SenseHat/sense_hat_environment.c:116:     sensor->t0_c = t0_x8 / 8.0;
	ldrh	w0, [sp, 46]	// _33, t0_x8
	scvtf	d30, w0	// _34, _33
	fmov	d31, 8.0e+0	// tmp178,
	fdiv	d31, d30, d31	// _35, _34, tmp178
// Utils/SenseHat/sense_hat_environment.c:116:     sensor->t0_c = t0_x8 / 8.0;
	ldr	x0, [sp, 24]	// tmp179, sensor
	str	d31, [x0, 16]	// _35, sensor_61(D)->t0_c
// Utils/SenseHat/sense_hat_environment.c:117:     sensor->t1_c = t1_x8 / 8.0;
	ldrh	w0, [sp, 44]	// _36, t1_x8
	scvtf	d30, w0	// _37, _36
	fmov	d31, 8.0e+0	// tmp180,
	fdiv	d31, d30, d31	// _38, _37, tmp180
// Utils/SenseHat/sense_hat_environment.c:117:     sensor->t1_c = t1_x8 / 8.0;
	ldr	x0, [sp, 24]	// tmp181, sensor
	str	d31, [x0, 24]	// _38, sensor_61(D)->t1_c
// Utils/SenseHat/sense_hat_environment.c:119:     if (read_int16(sensor->hts_fd, HTS221_H0_T0_OUT_L, HTS221_H0_T0_OUT_H, &sensor->h0_out) != 0 ||
	ldr	x0, [sp, 24]	// tmp182, sensor
	ldr	w4, [x0]	// _39, sensor_61(D)->hts_fd
	ldr	x0, [sp, 24]	// tmp183, sensor
	add	x0, x0, 56	// _40, tmp183,
	mov	x3, x0	//, _40
	mov	w2, 55	//,
	mov	w1, 54	//,
	mov	w0, w4	//, _39
	bl	read_int16		//
// Utils/SenseHat/sense_hat_environment.c:119:     if (read_int16(sensor->hts_fd, HTS221_H0_T0_OUT_L, HTS221_H0_T0_OUT_H, &sensor->h0_out) != 0 ||
	cmp	w0, 0	// _41,
	bne	.L28		//,
// Utils/SenseHat/sense_hat_environment.c:120:         read_int16(sensor->hts_fd, HTS221_H1_T0_OUT_L, HTS221_H1_T0_OUT_H, &sensor->h1_out) != 0 ||
	ldr	x0, [sp, 24]	// tmp184, sensor
	ldr	w4, [x0]	// _42, sensor_61(D)->hts_fd
	ldr	x0, [sp, 24]	// tmp185, sensor
	add	x0, x0, 58	// _43, tmp185,
	mov	x3, x0	//, _43
	mov	w2, 59	//,
	mov	w1, 58	//,
	mov	w0, w4	//, _42
	bl	read_int16		//
// Utils/SenseHat/sense_hat_environment.c:119:     if (read_int16(sensor->hts_fd, HTS221_H0_T0_OUT_L, HTS221_H0_T0_OUT_H, &sensor->h0_out) != 0 ||
	cmp	w0, 0	// _44,
	bne	.L28		//,
// Utils/SenseHat/sense_hat_environment.c:121:         read_int16(sensor->hts_fd, HTS221_T0_OUT_L, HTS221_T0_OUT_H, &sensor->t0_out) != 0 ||
	ldr	x0, [sp, 24]	// tmp186, sensor
	ldr	w4, [x0]	// _45, sensor_61(D)->hts_fd
	ldr	x0, [sp, 24]	// tmp187, sensor
	add	x0, x0, 32	// _46, tmp187,
	mov	x3, x0	//, _46
	mov	w2, 61	//,
	mov	w1, 60	//,
	mov	w0, w4	//, _45
	bl	read_int16		//
// Utils/SenseHat/sense_hat_environment.c:120:         read_int16(sensor->hts_fd, HTS221_H1_T0_OUT_L, HTS221_H1_T0_OUT_H, &sensor->h1_out) != 0 ||
	cmp	w0, 0	// _47,
	bne	.L28		//,
// Utils/SenseHat/sense_hat_environment.c:122:         read_int16(sensor->hts_fd, HTS221_T1_OUT_L, HTS221_T1_OUT_H, &sensor->t1_out) != 0)
	ldr	x0, [sp, 24]	// tmp188, sensor
	ldr	w4, [x0]	// _48, sensor_61(D)->hts_fd
	ldr	x0, [sp, 24]	// tmp189, sensor
	add	x0, x0, 34	// _49, tmp189,
	mov	x3, x0	//, _49
	mov	w2, 63	//,
	mov	w1, 62	//,
	mov	w0, w4	//, _48
	bl	read_int16		//
// Utils/SenseHat/sense_hat_environment.c:121:         read_int16(sensor->hts_fd, HTS221_T0_OUT_L, HTS221_T0_OUT_H, &sensor->t0_out) != 0 ||
	cmp	w0, 0	// _50,
	beq	.L29		//,
.L28:
// Utils/SenseHat/sense_hat_environment.c:124:         return -1;
	mov	w0, -1	// iftmp.12_56,
	b	.L32		//
.L29:
// Utils/SenseHat/sense_hat_environment.c:127:     return sensor->h1_out != sensor->h0_out && sensor->t1_out != sensor->t0_out ? 0 : -1;
	ldr	x0, [sp, 24]	// tmp190, sensor
	ldrsh	w1, [x0, 58]	// _51, sensor_61(D)->h1_out
// Utils/SenseHat/sense_hat_environment.c:127:     return sensor->h1_out != sensor->h0_out && sensor->t1_out != sensor->t0_out ? 0 : -1;
	ldr	x0, [sp, 24]	// tmp191, sensor
	ldrsh	w0, [x0, 56]	// _52, sensor_61(D)->h0_out
// Utils/SenseHat/sense_hat_environment.c:127:     return sensor->h1_out != sensor->h0_out && sensor->t1_out != sensor->t0_out ? 0 : -1;
	cmp	w1, w0	// _51, _52
	beq	.L30		//,
// Utils/SenseHat/sense_hat_environment.c:127:     return sensor->h1_out != sensor->h0_out && sensor->t1_out != sensor->t0_out ? 0 : -1;
	ldr	x0, [sp, 24]	// tmp192, sensor
	ldrsh	w1, [x0, 34]	// _53, sensor_61(D)->t1_out
// Utils/SenseHat/sense_hat_environment.c:127:     return sensor->h1_out != sensor->h0_out && sensor->t1_out != sensor->t0_out ? 0 : -1;
	ldr	x0, [sp, 24]	// tmp193, sensor
	ldrsh	w0, [x0, 32]	// _54, sensor_61(D)->t0_out
// Utils/SenseHat/sense_hat_environment.c:127:     return sensor->h1_out != sensor->h0_out && sensor->t1_out != sensor->t0_out ? 0 : -1;
	cmp	w1, w0	// _53, _54
	beq	.L30		//,
// Utils/SenseHat/sense_hat_environment.c:127:     return sensor->h1_out != sensor->h0_out && sensor->t1_out != sensor->t0_out ? 0 : -1;
	mov	w0, 0	// iftmp.12_56,
// Utils/SenseHat/sense_hat_environment.c:127:     return sensor->h1_out != sensor->h0_out && sensor->t1_out != sensor->t0_out ? 0 : -1;
	b	.L32		//
.L30:
// Utils/SenseHat/sense_hat_environment.c:127:     return sensor->h1_out != sensor->h0_out && sensor->t1_out != sensor->t0_out ? 0 : -1;
	mov	w0, -1	// iftmp.12_56,
.L32:
// Utils/SenseHat/sense_hat_environment.c:128: }
	ldp	x29, x30, [sp], 48	//,,,
	.cfi_restore 30
	.cfi_restore 29
	.cfi_def_cfa_offset 0
	ret	
	.cfi_endproc
.LFE5:
	.size	load_hts221_calibration, .-load_hts221_calibration
	.align	2
	.global	sense_hat_environment_set_hts_odr
	.type	sense_hat_environment_set_hts_odr, %function
sense_hat_environment_set_hts_odr:
.LFB6:
	.cfi_startproc
	stp	x29, x30, [sp, -48]!	//,,,
	.cfi_def_cfa_offset 48
	.cfi_offset 29, -48
	.cfi_offset 30, -40
	mov	x29, sp	//,
	str	x0, [sp, 24]	// sensor, sensor
	str	w1, [sp, 20]	// odr, odr
// Utils/SenseHat/sense_hat_environment.c:132:     if (sensor == NULL || sensor->hts_fd < 0 || odr < SENSE_HAT_HTS_ODR_1_HZ || odr > SENSE_HAT_HTS_ODR_12_5_HZ)
	ldr	x0, [sp, 24]	// tmp105, sensor
	cmp	x0, 0	// tmp105,
	beq	.L34		//,
// Utils/SenseHat/sense_hat_environment.c:132:     if (sensor == NULL || sensor->hts_fd < 0 || odr < SENSE_HAT_HTS_ODR_1_HZ || odr > SENSE_HAT_HTS_ODR_12_5_HZ)
	ldr	x0, [sp, 24]	// tmp106, sensor
	ldr	w0, [x0]	// _1, sensor_6(D)->hts_fd
// Utils/SenseHat/sense_hat_environment.c:132:     if (sensor == NULL || sensor->hts_fd < 0 || odr < SENSE_HAT_HTS_ODR_1_HZ || odr > SENSE_HAT_HTS_ODR_12_5_HZ)
	cmp	w0, 0	// _1,
	blt	.L34		//,
// Utils/SenseHat/sense_hat_environment.c:132:     if (sensor == NULL || sensor->hts_fd < 0 || odr < SENSE_HAT_HTS_ODR_1_HZ || odr > SENSE_HAT_HTS_ODR_12_5_HZ)
	ldr	w0, [sp, 20]	// tmp107, odr
	cmp	w0, 0	// tmp107,
	beq	.L34		//,
// Utils/SenseHat/sense_hat_environment.c:132:     if (sensor == NULL || sensor->hts_fd < 0 || odr < SENSE_HAT_HTS_ODR_1_HZ || odr > SENSE_HAT_HTS_ODR_12_5_HZ)
	ldr	w0, [sp, 20]	// tmp108, odr
	cmp	w0, 3	// tmp108,
	bls	.L35		//,
.L34:
// Utils/SenseHat/sense_hat_environment.c:133:         return -1;
	mov	w0, -1	// _4,
	b	.L36		//
.L35:
// Utils/SenseHat/sense_hat_environment.c:135:     uint8_t ctrl = CTRL_POWER_ON | CTRL_BDU | (uint8_t)odr;
	ldr	w0, [sp, 20]	// tmp109, odr
	and	w1, w0, 255	// _2, tmp109
// Utils/SenseHat/sense_hat_environment.c:135:     uint8_t ctrl = CTRL_POWER_ON | CTRL_BDU | (uint8_t)odr;
	mov	w0, -124	// tmp111,
	orr	w0, w1, w0	// tmp110, _2, tmp111
	strb	w0, [sp, 47]	// tmp112, ctrl
// Utils/SenseHat/sense_hat_environment.c:136:     return write_register(sensor->hts_fd, HTS221_CTRL_REG1, ctrl);
	ldr	x0, [sp, 24]	// tmp113, sensor
	ldr	w0, [x0]	// _3, sensor_6(D)->hts_fd
	ldrb	w2, [sp, 47]	//, ctrl
	mov	w1, 32	//,
	bl	write_register		//
.L36:
// Utils/SenseHat/sense_hat_environment.c:137: }
	ldp	x29, x30, [sp], 48	//,,,
	.cfi_restore 30
	.cfi_restore 29
	.cfi_def_cfa_offset 0
	ret	
	.cfi_endproc
.LFE6:
	.size	sense_hat_environment_set_hts_odr, .-sense_hat_environment_set_hts_odr
	.align	2
	.global	sense_hat_environment_set_pressure_odr
	.type	sense_hat_environment_set_pressure_odr, %function
sense_hat_environment_set_pressure_odr:
.LFB7:
	.cfi_startproc
	stp	x29, x30, [sp, -48]!	//,,,
	.cfi_def_cfa_offset 48
	.cfi_offset 29, -48
	.cfi_offset 30, -40
	mov	x29, sp	//,
	str	x0, [sp, 24]	// sensor, sensor
	str	w1, [sp, 20]	// odr, odr
// Utils/SenseHat/sense_hat_environment.c:141:     if (sensor == NULL || sensor->pressure_fd < 0 || odr < SENSE_HAT_PRESSURE_ODR_1_HZ || odr > SENSE_HAT_PRESSURE_ODR_25_HZ)
	ldr	x0, [sp, 24]	// tmp107, sensor
	cmp	x0, 0	// tmp107,
	beq	.L38		//,
// Utils/SenseHat/sense_hat_environment.c:141:     if (sensor == NULL || sensor->pressure_fd < 0 || odr < SENSE_HAT_PRESSURE_ODR_1_HZ || odr > SENSE_HAT_PRESSURE_ODR_25_HZ)
	ldr	x0, [sp, 24]	// tmp108, sensor
	ldr	w0, [x0, 4]	// _1, sensor_8(D)->pressure_fd
// Utils/SenseHat/sense_hat_environment.c:141:     if (sensor == NULL || sensor->pressure_fd < 0 || odr < SENSE_HAT_PRESSURE_ODR_1_HZ || odr > SENSE_HAT_PRESSURE_ODR_25_HZ)
	cmp	w0, 0	// _1,
	blt	.L38		//,
// Utils/SenseHat/sense_hat_environment.c:141:     if (sensor == NULL || sensor->pressure_fd < 0 || odr < SENSE_HAT_PRESSURE_ODR_1_HZ || odr > SENSE_HAT_PRESSURE_ODR_25_HZ)
	ldr	w0, [sp, 20]	// tmp109, odr
	cmp	w0, 0	// tmp109,
	beq	.L38		//,
// Utils/SenseHat/sense_hat_environment.c:141:     if (sensor == NULL || sensor->pressure_fd < 0 || odr < SENSE_HAT_PRESSURE_ODR_1_HZ || odr > SENSE_HAT_PRESSURE_ODR_25_HZ)
	ldr	w0, [sp, 20]	// tmp110, odr
	cmp	w0, 4	// tmp110,
	bls	.L39		//,
.L38:
// Utils/SenseHat/sense_hat_environment.c:142:         return -1;
	mov	w0, -1	// _6,
	b	.L40		//
.L39:
// Utils/SenseHat/sense_hat_environment.c:144:     uint8_t ctrl = CTRL_POWER_ON | CTRL_BDU | ((uint8_t)odr << 4);
	ldr	w0, [sp, 20]	// tmp111, odr
	sxtb	w0, w0	// _2, tmp111
	ubfiz	w0, w0, 4, 4	// _3, _2,,
	sxtb	w1, w0	// _3, _3
	mov	w0, -124	// tmp114,
	orr	w0, w1, w0	// tmp113, _3, tmp114
	sxtb	w0, w0	// _4, tmp113
// Utils/SenseHat/sense_hat_environment.c:144:     uint8_t ctrl = CTRL_POWER_ON | CTRL_BDU | ((uint8_t)odr << 4);
	strb	w0, [sp, 47]	// tmp115, ctrl
// Utils/SenseHat/sense_hat_environment.c:145:     return write_register(sensor->pressure_fd, LPS25H_CTRL_REG1, ctrl);
	ldr	x0, [sp, 24]	// tmp116, sensor
	ldr	w0, [x0, 4]	// _5, sensor_8(D)->pressure_fd
	ldrb	w2, [sp, 47]	//, ctrl
	mov	w1, 32	//,
	bl	write_register		//
.L40:
// Utils/SenseHat/sense_hat_environment.c:146: }
	ldp	x29, x30, [sp], 48	//,,,
	.cfi_restore 30
	.cfi_restore 29
	.cfi_def_cfa_offset 0
	ret	
	.cfi_endproc
.LFE7:
	.size	sense_hat_environment_set_pressure_odr, .-sense_hat_environment_set_pressure_odr
	.align	2
	.global	sense_hat_environment_init
	.type	sense_hat_environment_init, %function
sense_hat_environment_init:
.LFB8:
	.cfi_startproc
	stp	x29, x30, [sp, -48]!	//,,,
	.cfi_def_cfa_offset 48
	.cfi_offset 29, -48
	.cfi_offset 30, -40
	mov	x29, sp	//,
	str	x0, [sp, 40]	// sensor, sensor
	str	x1, [sp, 32]	// i2c_device, i2c_device
	str	w2, [sp, 28]	// hts_odr, hts_odr
	str	w3, [sp, 24]	// pressure_odr, pressure_odr
// Utils/SenseHat/sense_hat_environment.c:153:     if (sensor == NULL || i2c_device == NULL)
	ldr	x0, [sp, 40]	// tmp113, sensor
	cmp	x0, 0	// tmp113,
	beq	.L42		//,
// Utils/SenseHat/sense_hat_environment.c:153:     if (sensor == NULL || i2c_device == NULL)
	ldr	x0, [sp, 32]	// tmp114, i2c_device
	cmp	x0, 0	// tmp114,
	bne	.L43		//,
.L42:
// Utils/SenseHat/sense_hat_environment.c:154:         return -1;
	mov	w0, -1	// _12,
	b	.L44		//
.L43:
// Utils/SenseHat/sense_hat_environment.c:156:     memset(sensor, 0, sizeof(*sensor));
	mov	x2, 64	//,
	mov	w1, 0	//,
	ldr	x0, [sp, 40]	//, sensor
	bl	memset		//
// Utils/SenseHat/sense_hat_environment.c:157:     sensor->hts_fd = -1;
	ldr	x0, [sp, 40]	// tmp115, sensor
	mov	w1, -1	// tmp116,
	str	w1, [x0]	// tmp116, sensor_16(D)->hts_fd
// Utils/SenseHat/sense_hat_environment.c:158:     sensor->pressure_fd = -1;
	ldr	x0, [sp, 40]	// tmp117, sensor
	mov	w1, -1	// tmp118,
	str	w1, [x0, 4]	// tmp118, sensor_16(D)->pressure_fd
// Utils/SenseHat/sense_hat_environment.c:160:     sensor->hts_fd = open_sensor(i2c_device, HTS221_ADDRESS);
	mov	w1, 95	//,
	ldr	x0, [sp, 32]	//, i2c_device
	bl	open_sensor		//
	mov	w1, w0	// _1,
// Utils/SenseHat/sense_hat_environment.c:160:     sensor->hts_fd = open_sensor(i2c_device, HTS221_ADDRESS);
	ldr	x0, [sp, 40]	// tmp119, sensor
	str	w1, [x0]	// _1, sensor_16(D)->hts_fd
// Utils/SenseHat/sense_hat_environment.c:161:     if (sensor->hts_fd < 0)
	ldr	x0, [sp, 40]	// tmp120, sensor
	ldr	w0, [x0]	// _2, sensor_16(D)->hts_fd
// Utils/SenseHat/sense_hat_environment.c:161:     if (sensor->hts_fd < 0)
	cmp	w0, 0	// _2,
	blt	.L50		//,
// Utils/SenseHat/sense_hat_environment.c:164:     sensor->pressure_fd = open_sensor(i2c_device, LPS25H_ADDRESS);
	mov	w1, 92	//,
	ldr	x0, [sp, 32]	//, i2c_device
	bl	open_sensor		//
	mov	w1, w0	// _3,
// Utils/SenseHat/sense_hat_environment.c:164:     sensor->pressure_fd = open_sensor(i2c_device, LPS25H_ADDRESS);
	ldr	x0, [sp, 40]	// tmp121, sensor
	str	w1, [x0, 4]	// _3, sensor_16(D)->pressure_fd
// Utils/SenseHat/sense_hat_environment.c:165:     if (sensor->pressure_fd < 0)
	ldr	x0, [sp, 40]	// tmp122, sensor
	ldr	w0, [x0, 4]	// _4, sensor_16(D)->pressure_fd
// Utils/SenseHat/sense_hat_environment.c:165:     if (sensor->pressure_fd < 0)
	cmp	w0, 0	// _4,
	blt	.L51		//,
// Utils/SenseHat/sense_hat_environment.c:168:     if (validate_device(sensor->hts_fd, HTS221_WHO_AM_I_VALUE) != 0 ||
	ldr	x0, [sp, 40]	// tmp123, sensor
	ldr	w0, [x0]	// _5, sensor_16(D)->hts_fd
	mov	w1, -68	//,
	bl	validate_device		//
// Utils/SenseHat/sense_hat_environment.c:168:     if (validate_device(sensor->hts_fd, HTS221_WHO_AM_I_VALUE) != 0 ||
	cmp	w0, 0	// _6,
	bne	.L52		//,
// Utils/SenseHat/sense_hat_environment.c:169:         validate_device(sensor->pressure_fd, LPS25H_WHO_AM_I_VALUE) != 0 ||
	ldr	x0, [sp, 40]	// tmp124, sensor
	ldr	w0, [x0, 4]	// _7, sensor_16(D)->pressure_fd
	mov	w1, -67	//,
	bl	validate_device		//
// Utils/SenseHat/sense_hat_environment.c:168:     if (validate_device(sensor->hts_fd, HTS221_WHO_AM_I_VALUE) != 0 ||
	cmp	w0, 0	// _8,
	bne	.L52		//,
// Utils/SenseHat/sense_hat_environment.c:170:         load_hts221_calibration(sensor) != 0 ||
	ldr	x0, [sp, 40]	//, sensor
	bl	load_hts221_calibration		//
// Utils/SenseHat/sense_hat_environment.c:169:         validate_device(sensor->pressure_fd, LPS25H_WHO_AM_I_VALUE) != 0 ||
	cmp	w0, 0	// _9,
	bne	.L52		//,
// Utils/SenseHat/sense_hat_environment.c:171:         sense_hat_environment_set_hts_odr(sensor, hts_odr) != 0 ||
	ldr	w1, [sp, 28]	//, hts_odr
	ldr	x0, [sp, 40]	//, sensor
	bl	sense_hat_environment_set_hts_odr		//
// Utils/SenseHat/sense_hat_environment.c:170:         load_hts221_calibration(sensor) != 0 ||
	cmp	w0, 0	// _10,
	bne	.L52		//,
// Utils/SenseHat/sense_hat_environment.c:172:         sense_hat_environment_set_pressure_odr(sensor, pressure_odr) != 0)
	ldr	w1, [sp, 24]	//, pressure_odr
	ldr	x0, [sp, 40]	//, sensor
	bl	sense_hat_environment_set_pressure_odr		//
// Utils/SenseHat/sense_hat_environment.c:171:         sense_hat_environment_set_hts_odr(sensor, hts_odr) != 0 ||
	cmp	w0, 0	// _11,
	bne	.L52		//,
// Utils/SenseHat/sense_hat_environment.c:177:     sensor->initialized = true;
	ldr	x0, [sp, 40]	// tmp125, sensor
	mov	w1, 1	// tmp126,
	strb	w1, [x0, 8]	// tmp126, sensor_16(D)->initialized
// Utils/SenseHat/sense_hat_environment.c:178:     return 0;
	mov	w0, 0	// _12,
	b	.L44		//
.L50:
// Utils/SenseHat/sense_hat_environment.c:162:         goto fail;
	nop	
	b	.L46		//
.L51:
// Utils/SenseHat/sense_hat_environment.c:166:         goto fail;
	nop	
	b	.L46		//
.L52:
// Utils/SenseHat/sense_hat_environment.c:174:         goto fail;
	nop	
.L46:
// Utils/SenseHat/sense_hat_environment.c:181:     sense_hat_environment_close(sensor);
	ldr	x0, [sp, 40]	//, sensor
	bl	sense_hat_environment_close		//
// Utils/SenseHat/sense_hat_environment.c:182:     return -1;
	mov	w0, -1	// _12,
.L44:
// Utils/SenseHat/sense_hat_environment.c:183: }
	ldp	x29, x30, [sp], 48	//,,,
	.cfi_restore 30
	.cfi_restore 29
	.cfi_def_cfa_offset 0
	ret	
	.cfi_endproc
.LFE8:
	.size	sense_hat_environment_init, .-sense_hat_environment_init
	.align	2
	.global	sense_hat_environment_close
	.type	sense_hat_environment_close, %function
sense_hat_environment_close:
.LFB9:
	.cfi_startproc
	stp	x29, x30, [sp, -32]!	//,,,
	.cfi_def_cfa_offset 32
	.cfi_offset 29, -32
	.cfi_offset 30, -24
	mov	x29, sp	//,
	str	x0, [sp, 24]	// sensor, sensor
// Utils/SenseHat/sense_hat_environment.c:187:     if (sensor == NULL)
	ldr	x0, [sp, 24]	// tmp104, sensor
	cmp	x0, 0	// tmp104,
	beq	.L58		//,
// Utils/SenseHat/sense_hat_environment.c:190:     if (sensor->hts_fd >= 0)
	ldr	x0, [sp, 24]	// tmp105, sensor
	ldr	w0, [x0]	// _1, sensor_8(D)->hts_fd
// Utils/SenseHat/sense_hat_environment.c:190:     if (sensor->hts_fd >= 0)
	cmp	w0, 0	// _1,
	blt	.L56		//,
// Utils/SenseHat/sense_hat_environment.c:191:         close(sensor->hts_fd);
	ldr	x0, [sp, 24]	// tmp106, sensor
	ldr	w0, [x0]	// _2, sensor_8(D)->hts_fd
	bl	close		//
.L56:
// Utils/SenseHat/sense_hat_environment.c:193:     if (sensor->pressure_fd >= 0)
	ldr	x0, [sp, 24]	// tmp107, sensor
	ldr	w0, [x0, 4]	// _3, sensor_8(D)->pressure_fd
// Utils/SenseHat/sense_hat_environment.c:193:     if (sensor->pressure_fd >= 0)
	cmp	w0, 0	// _3,
	blt	.L57		//,
// Utils/SenseHat/sense_hat_environment.c:194:         close(sensor->pressure_fd);
	ldr	x0, [sp, 24]	// tmp108, sensor
	ldr	w0, [x0, 4]	// _4, sensor_8(D)->pressure_fd
	bl	close		//
.L57:
// Utils/SenseHat/sense_hat_environment.c:196:     memset(sensor, 0, sizeof(*sensor));
	mov	x2, 64	//,
	mov	w1, 0	//,
	ldr	x0, [sp, 24]	//, sensor
	bl	memset		//
// Utils/SenseHat/sense_hat_environment.c:197:     sensor->hts_fd = -1;
	ldr	x0, [sp, 24]	// tmp109, sensor
	mov	w1, -1	// tmp110,
	str	w1, [x0]	// tmp110, sensor_8(D)->hts_fd
// Utils/SenseHat/sense_hat_environment.c:198:     sensor->pressure_fd = -1;
	ldr	x0, [sp, 24]	// tmp111, sensor
	mov	w1, -1	// tmp112,
	str	w1, [x0, 4]	// tmp112, sensor_8(D)->pressure_fd
	b	.L53		//
.L58:
// Utils/SenseHat/sense_hat_environment.c:188:         return;
	nop	
.L53:
// Utils/SenseHat/sense_hat_environment.c:199: }
	ldp	x29, x30, [sp], 32	//,,,
	.cfi_restore 30
	.cfi_restore 29
	.cfi_def_cfa_offset 0
	ret	
	.cfi_endproc
.LFE9:
	.size	sense_hat_environment_close, .-sense_hat_environment_close
	.align	2
	.global	sense_hat_environment_read_temperature
	.type	sense_hat_environment_read_temperature, %function
sense_hat_environment_read_temperature:
.LFB10:
	.cfi_startproc
	stp	x29, x30, [sp, -48]!	//,,,
	.cfi_def_cfa_offset 48
	.cfi_offset 29, -48
	.cfi_offset 30, -40
	mov	x29, sp	//,
	str	x0, [sp, 24]	// sensor, sensor
	str	x1, [sp, 16]	// temperature_c, temperature_c
// Utils/SenseHat/sense_hat_environment.c:205:     if (sensor == NULL || temperature_c == NULL || !sensor->initialized ||
	ldr	x0, [sp, 24]	// tmp125, sensor
	cmp	x0, 0	// tmp125,
	beq	.L60		//,
// Utils/SenseHat/sense_hat_environment.c:205:     if (sensor == NULL || temperature_c == NULL || !sensor->initialized ||
	ldr	x0, [sp, 16]	// tmp126, temperature_c
	cmp	x0, 0	// tmp126,
	beq	.L60		//,
// Utils/SenseHat/sense_hat_environment.c:205:     if (sensor == NULL || temperature_c == NULL || !sensor->initialized ||
	ldr	x0, [sp, 24]	// tmp127, sensor
	ldrb	w0, [x0, 8]	// _1, sensor_27(D)->initialized
// Utils/SenseHat/sense_hat_environment.c:205:     if (sensor == NULL || temperature_c == NULL || !sensor->initialized ||
	eor	w0, w0, 1	// tmp128, _1,
	and	w0, w0, 255	// _2, tmp128
// Utils/SenseHat/sense_hat_environment.c:205:     if (sensor == NULL || temperature_c == NULL || !sensor->initialized ||
	and	w0, w0, 1	// tmp129, _2,
	cmp	w0, 0	// tmp129,
	bne	.L60		//,
// Utils/SenseHat/sense_hat_environment.c:206:         read_int16(sensor->hts_fd, HTS221_TEMP_OUT_L, HTS221_TEMP_OUT_H, &raw) != 0)
	ldr	x0, [sp, 24]	// tmp130, sensor
	ldr	w0, [x0]	// _3, sensor_27(D)->hts_fd
	add	x1, sp, 46	// tmp131,,
	mov	x3, x1	//, tmp131
	mov	w2, 43	//,
	mov	w1, 42	//,
	bl	read_int16		//
// Utils/SenseHat/sense_hat_environment.c:205:     if (sensor == NULL || temperature_c == NULL || !sensor->initialized ||
	cmp	w0, 0	// _4,
	beq	.L61		//,
.L60:
// Utils/SenseHat/sense_hat_environment.c:208:         return -1;
	mov	w0, -1	// _24,
	b	.L63		//
.L61:
// Utils/SenseHat/sense_hat_environment.c:211:     *temperature_c = sensor->t0_c +
	ldr	x0, [sp, 24]	// tmp132, sensor
	ldr	d30, [x0, 16]	// _5, sensor_27(D)->t0_c
// Utils/SenseHat/sense_hat_environment.c:212:                      ((double)(raw - sensor->t0_out) * (sensor->t1_c - sensor->t0_c)) /
	ldrsh	w0, [sp, 46]	// raw.13_6, raw
	mov	w1, w0	// _7, raw.13_6
// Utils/SenseHat/sense_hat_environment.c:212:                      ((double)(raw - sensor->t0_out) * (sensor->t1_c - sensor->t0_c)) /
	ldr	x0, [sp, 24]	// tmp133, sensor
	ldrsh	w0, [x0, 32]	// _8, sensor_27(D)->t0_out
// Utils/SenseHat/sense_hat_environment.c:212:                      ((double)(raw - sensor->t0_out) * (sensor->t1_c - sensor->t0_c)) /
	sub	w0, w1, w0	// _10, _7, _9
// Utils/SenseHat/sense_hat_environment.c:212:                      ((double)(raw - sensor->t0_out) * (sensor->t1_c - sensor->t0_c)) /
	scvtf	d29, w0	// _11, _10
// Utils/SenseHat/sense_hat_environment.c:212:                      ((double)(raw - sensor->t0_out) * (sensor->t1_c - sensor->t0_c)) /
	ldr	x0, [sp, 24]	// tmp134, sensor
	ldr	d28, [x0, 24]	// _12, sensor_27(D)->t1_c
// Utils/SenseHat/sense_hat_environment.c:212:                      ((double)(raw - sensor->t0_out) * (sensor->t1_c - sensor->t0_c)) /
	ldr	x0, [sp, 24]	// tmp135, sensor
	ldr	d31, [x0, 16]	// _13, sensor_27(D)->t0_c
// Utils/SenseHat/sense_hat_environment.c:212:                      ((double)(raw - sensor->t0_out) * (sensor->t1_c - sensor->t0_c)) /
	fsub	d31, d28, d31	// _14, _12, _13
// Utils/SenseHat/sense_hat_environment.c:212:                      ((double)(raw - sensor->t0_out) * (sensor->t1_c - sensor->t0_c)) /
	fmul	d29, d29, d31	// _15, _11, _14
// Utils/SenseHat/sense_hat_environment.c:213:                      (double)(sensor->t1_out - sensor->t0_out);
	ldr	x0, [sp, 24]	// tmp136, sensor
	ldrsh	w0, [x0, 34]	// _16, sensor_27(D)->t1_out
	mov	w1, w0	// _17, _16
// Utils/SenseHat/sense_hat_environment.c:213:                      (double)(sensor->t1_out - sensor->t0_out);
	ldr	x0, [sp, 24]	// tmp137, sensor
	ldrsh	w0, [x0, 32]	// _18, sensor_27(D)->t0_out
// Utils/SenseHat/sense_hat_environment.c:213:                      (double)(sensor->t1_out - sensor->t0_out);
	sub	w0, w1, w0	// _20, _17, _19
// Utils/SenseHat/sense_hat_environment.c:213:                      (double)(sensor->t1_out - sensor->t0_out);
	scvtf	d31, w0	// _21, _20
// Utils/SenseHat/sense_hat_environment.c:212:                      ((double)(raw - sensor->t0_out) * (sensor->t1_c - sensor->t0_c)) /
	fdiv	d31, d29, d31	// _22, _15, _21
// Utils/SenseHat/sense_hat_environment.c:211:     *temperature_c = sensor->t0_c +
	fadd	d31, d30, d31	// _23, _5, _22
// Utils/SenseHat/sense_hat_environment.c:211:     *temperature_c = sensor->t0_c +
	ldr	x0, [sp, 16]	// tmp138, temperature_c
	str	d31, [x0]	// _23, *temperature_c_29(D)
// Utils/SenseHat/sense_hat_environment.c:214:     return 0;
	mov	w0, 0	// _24,
.L63:
// Utils/SenseHat/sense_hat_environment.c:215: }
	ldp	x29, x30, [sp], 48	//,,,
	.cfi_restore 30
	.cfi_restore 29
	.cfi_def_cfa_offset 0
	ret	
	.cfi_endproc
.LFE10:
	.size	sense_hat_environment_read_temperature, .-sense_hat_environment_read_temperature
	.align	2
	.global	sense_hat_environment_read_humidity
	.type	sense_hat_environment_read_humidity, %function
sense_hat_environment_read_humidity:
.LFB11:
	.cfi_startproc
	stp	x29, x30, [sp, -48]!	//,,,
	.cfi_def_cfa_offset 48
	.cfi_offset 29, -48
	.cfi_offset 30, -40
	mov	x29, sp	//,
	str	x0, [sp, 24]	// sensor, sensor
	str	x1, [sp, 16]	// humidity_percent, humidity_percent
// Utils/SenseHat/sense_hat_environment.c:221:     if (sensor == NULL || humidity_percent == NULL || !sensor->initialized ||
	ldr	x0, [sp, 24]	// tmp127, sensor
	cmp	x0, 0	// tmp127,
	beq	.L65		//,
// Utils/SenseHat/sense_hat_environment.c:221:     if (sensor == NULL || humidity_percent == NULL || !sensor->initialized ||
	ldr	x0, [sp, 16]	// tmp128, humidity_percent
	cmp	x0, 0	// tmp128,
	beq	.L65		//,
// Utils/SenseHat/sense_hat_environment.c:221:     if (sensor == NULL || humidity_percent == NULL || !sensor->initialized ||
	ldr	x0, [sp, 24]	// tmp129, sensor
	ldrb	w0, [x0, 8]	// _1, sensor_30(D)->initialized
// Utils/SenseHat/sense_hat_environment.c:221:     if (sensor == NULL || humidity_percent == NULL || !sensor->initialized ||
	eor	w0, w0, 1	// tmp130, _1,
	and	w0, w0, 255	// _2, tmp130
// Utils/SenseHat/sense_hat_environment.c:221:     if (sensor == NULL || humidity_percent == NULL || !sensor->initialized ||
	and	w0, w0, 1	// tmp131, _2,
	cmp	w0, 0	// tmp131,
	bne	.L65		//,
// Utils/SenseHat/sense_hat_environment.c:222:         read_int16(sensor->hts_fd, HTS221_HUMIDITY_OUT_L, HTS221_HUMIDITY_OUT_H, &raw) != 0)
	ldr	x0, [sp, 24]	// tmp132, sensor
	ldr	w0, [x0]	// _3, sensor_30(D)->hts_fd
	add	x1, sp, 46	// tmp133,,
	mov	x3, x1	//, tmp133
	mov	w2, 41	//,
	mov	w1, 40	//,
	bl	read_int16		//
// Utils/SenseHat/sense_hat_environment.c:221:     if (sensor == NULL || humidity_percent == NULL || !sensor->initialized ||
	cmp	w0, 0	// _4,
	beq	.L66		//,
.L65:
// Utils/SenseHat/sense_hat_environment.c:224:         return -1;
	mov	w0, -1	// _26,
	b	.L72		//
.L66:
// Utils/SenseHat/sense_hat_environment.c:227:     *humidity_percent = sensor->h0_percent +
	ldr	x0, [sp, 24]	// tmp134, sensor
	ldr	d30, [x0, 40]	// _5, sensor_30(D)->h0_percent
// Utils/SenseHat/sense_hat_environment.c:228:                         ((double)(raw - sensor->h0_out) * (sensor->h1_percent - sensor->h0_percent)) /
	ldrsh	w0, [sp, 46]	// raw.14_6, raw
	mov	w1, w0	// _7, raw.14_6
// Utils/SenseHat/sense_hat_environment.c:228:                         ((double)(raw - sensor->h0_out) * (sensor->h1_percent - sensor->h0_percent)) /
	ldr	x0, [sp, 24]	// tmp135, sensor
	ldrsh	w0, [x0, 56]	// _8, sensor_30(D)->h0_out
// Utils/SenseHat/sense_hat_environment.c:228:                         ((double)(raw - sensor->h0_out) * (sensor->h1_percent - sensor->h0_percent)) /
	sub	w0, w1, w0	// _10, _7, _9
// Utils/SenseHat/sense_hat_environment.c:228:                         ((double)(raw - sensor->h0_out) * (sensor->h1_percent - sensor->h0_percent)) /
	scvtf	d29, w0	// _11, _10
// Utils/SenseHat/sense_hat_environment.c:228:                         ((double)(raw - sensor->h0_out) * (sensor->h1_percent - sensor->h0_percent)) /
	ldr	x0, [sp, 24]	// tmp136, sensor
	ldr	d28, [x0, 48]	// _12, sensor_30(D)->h1_percent
// Utils/SenseHat/sense_hat_environment.c:228:                         ((double)(raw - sensor->h0_out) * (sensor->h1_percent - sensor->h0_percent)) /
	ldr	x0, [sp, 24]	// tmp137, sensor
	ldr	d31, [x0, 40]	// _13, sensor_30(D)->h0_percent
// Utils/SenseHat/sense_hat_environment.c:228:                         ((double)(raw - sensor->h0_out) * (sensor->h1_percent - sensor->h0_percent)) /
	fsub	d31, d28, d31	// _14, _12, _13
// Utils/SenseHat/sense_hat_environment.c:228:                         ((double)(raw - sensor->h0_out) * (sensor->h1_percent - sensor->h0_percent)) /
	fmul	d29, d29, d31	// _15, _11, _14
// Utils/SenseHat/sense_hat_environment.c:229:                         (double)(sensor->h1_out - sensor->h0_out);
	ldr	x0, [sp, 24]	// tmp138, sensor
	ldrsh	w0, [x0, 58]	// _16, sensor_30(D)->h1_out
	mov	w1, w0	// _17, _16
// Utils/SenseHat/sense_hat_environment.c:229:                         (double)(sensor->h1_out - sensor->h0_out);
	ldr	x0, [sp, 24]	// tmp139, sensor
	ldrsh	w0, [x0, 56]	// _18, sensor_30(D)->h0_out
// Utils/SenseHat/sense_hat_environment.c:229:                         (double)(sensor->h1_out - sensor->h0_out);
	sub	w0, w1, w0	// _20, _17, _19
// Utils/SenseHat/sense_hat_environment.c:229:                         (double)(sensor->h1_out - sensor->h0_out);
	scvtf	d31, w0	// _21, _20
// Utils/SenseHat/sense_hat_environment.c:228:                         ((double)(raw - sensor->h0_out) * (sensor->h1_percent - sensor->h0_percent)) /
	fdiv	d31, d29, d31	// _22, _15, _21
// Utils/SenseHat/sense_hat_environment.c:227:     *humidity_percent = sensor->h0_percent +
	fadd	d31, d30, d31	// _23, _5, _22
// Utils/SenseHat/sense_hat_environment.c:227:     *humidity_percent = sensor->h0_percent +
	ldr	x0, [sp, 16]	// tmp140, humidity_percent
	str	d31, [x0]	// _23, *humidity_percent_32(D)
// Utils/SenseHat/sense_hat_environment.c:231:     if (*humidity_percent < 0.0)
	ldr	x0, [sp, 16]	// tmp141, humidity_percent
	ldr	d31, [x0]	// _24, *humidity_percent_32(D)
// Utils/SenseHat/sense_hat_environment.c:231:     if (*humidity_percent < 0.0)
	fcmpe	d31, #0.0	// _24
	bmi	.L73		//,
	b	.L75		//
.L73:
// Utils/SenseHat/sense_hat_environment.c:232:         *humidity_percent = 0.0;
	ldr	x0, [sp, 16]	// tmp142, humidity_percent
	str	xzr, [x0]	//, *humidity_percent_32(D)
	b	.L70		//
.L75:
// Utils/SenseHat/sense_hat_environment.c:233:     else if (*humidity_percent > 100.0)
	ldr	x0, [sp, 16]	// tmp143, humidity_percent
	ldr	d31, [x0]	// _25, *humidity_percent_32(D)
// Utils/SenseHat/sense_hat_environment.c:233:     else if (*humidity_percent > 100.0)
	mov	x0, 4636737291354636288	// tmp149,
	fmov	d30, x0	// tmp144, tmp149
	fcmpe	d31, d30	// _25, tmp144
	bgt	.L74		//,
	b	.L70		//
.L74:
// Utils/SenseHat/sense_hat_environment.c:234:         *humidity_percent = 100.0;
	ldr	x0, [sp, 16]	// tmp145, humidity_percent
	mov	x1, 4636737291354636288	// tmp148,
	fmov	d31, x1	// tmp146, tmp148
	str	d31, [x0]	// tmp146, *humidity_percent_32(D)
.L70:
// Utils/SenseHat/sense_hat_environment.c:236:     return 0;
	mov	w0, 0	// _26,
.L72:
// Utils/SenseHat/sense_hat_environment.c:237: }
	ldp	x29, x30, [sp], 48	//,,,
	.cfi_restore 30
	.cfi_restore 29
	.cfi_def_cfa_offset 0
	ret	
	.cfi_endproc
.LFE11:
	.size	sense_hat_environment_read_humidity, .-sense_hat_environment_read_humidity
	.align	2
	.global	sense_hat_environment_read_pressure
	.type	sense_hat_environment_read_pressure, %function
sense_hat_environment_read_pressure:
.LFB12:
	.cfi_startproc
	stp	x29, x30, [sp, -48]!	//,,,
	.cfi_def_cfa_offset 48
	.cfi_offset 29, -48
	.cfi_offset 30, -40
	mov	x29, sp	//,
	str	x0, [sp, 24]	// sensor, sensor
	str	x1, [sp, 16]	// pressure_hpa, pressure_hpa
// Utils/SenseHat/sense_hat_environment.c:245:     if (sensor == NULL || pressure_hpa == NULL || !sensor->initialized ||
	ldr	x0, [sp, 24]	// tmp124, sensor
	cmp	x0, 0	// tmp124,
	beq	.L77		//,
// Utils/SenseHat/sense_hat_environment.c:245:     if (sensor == NULL || pressure_hpa == NULL || !sensor->initialized ||
	ldr	x0, [sp, 16]	// tmp125, pressure_hpa
	cmp	x0, 0	// tmp125,
	beq	.L77		//,
// Utils/SenseHat/sense_hat_environment.c:245:     if (sensor == NULL || pressure_hpa == NULL || !sensor->initialized ||
	ldr	x0, [sp, 24]	// tmp126, sensor
	ldrb	w0, [x0, 8]	// _1, sensor_26(D)->initialized
// Utils/SenseHat/sense_hat_environment.c:245:     if (sensor == NULL || pressure_hpa == NULL || !sensor->initialized ||
	eor	w0, w0, 1	// tmp127, _1,
	and	w0, w0, 255	// _2, tmp127
// Utils/SenseHat/sense_hat_environment.c:245:     if (sensor == NULL || pressure_hpa == NULL || !sensor->initialized ||
	and	w0, w0, 1	// tmp128, _2,
	cmp	w0, 0	// tmp128,
	bne	.L77		//,
// Utils/SenseHat/sense_hat_environment.c:246:         read_register(sensor->pressure_fd, LPS25H_PRESS_OUT_XL, &xl) != 0 ||
	ldr	x0, [sp, 24]	// tmp129, sensor
	ldr	w0, [x0, 4]	// _3, sensor_26(D)->pressure_fd
	add	x1, sp, 39	// tmp130,,
	mov	x2, x1	//, tmp130
	mov	w1, 40	//,
	bl	read_register		//
// Utils/SenseHat/sense_hat_environment.c:245:     if (sensor == NULL || pressure_hpa == NULL || !sensor->initialized ||
	cmp	w0, 0	// _4,
	bne	.L77		//,
// Utils/SenseHat/sense_hat_environment.c:247:         read_register(sensor->pressure_fd, LPS25H_PRESS_OUT_L, &low) != 0 ||
	ldr	x0, [sp, 24]	// tmp131, sensor
	ldr	w0, [x0, 4]	// _5, sensor_26(D)->pressure_fd
	add	x1, sp, 38	// tmp132,,
	mov	x2, x1	//, tmp132
	mov	w1, 41	//,
	bl	read_register		//
// Utils/SenseHat/sense_hat_environment.c:246:         read_register(sensor->pressure_fd, LPS25H_PRESS_OUT_XL, &xl) != 0 ||
	cmp	w0, 0	// _6,
	bne	.L77		//,
// Utils/SenseHat/sense_hat_environment.c:248:         read_register(sensor->pressure_fd, LPS25H_PRESS_OUT_H, &high) != 0)
	ldr	x0, [sp, 24]	// tmp133, sensor
	ldr	w0, [x0, 4]	// _7, sensor_26(D)->pressure_fd
	add	x1, sp, 37	// tmp134,,
	mov	x2, x1	//, tmp134
	mov	w1, 42	//,
	bl	read_register		//
// Utils/SenseHat/sense_hat_environment.c:247:         read_register(sensor->pressure_fd, LPS25H_PRESS_OUT_L, &low) != 0 ||
	cmp	w0, 0	// _8,
	beq	.L78		//,
.L77:
// Utils/SenseHat/sense_hat_environment.c:250:         return -1;
	mov	w0, -1	// _22,
	b	.L82		//
.L78:
// Utils/SenseHat/sense_hat_environment.c:253:     uint32_t raw24 = ((uint32_t)high << 16) | ((uint32_t)low << 8) | xl;
	ldrb	w0, [sp, 37]	// high.15_9, high
// Utils/SenseHat/sense_hat_environment.c:253:     uint32_t raw24 = ((uint32_t)high << 16) | ((uint32_t)low << 8) | xl;
	lsl	w1, w0, 16	// _11, _10,
// Utils/SenseHat/sense_hat_environment.c:253:     uint32_t raw24 = ((uint32_t)high << 16) | ((uint32_t)low << 8) | xl;
	ldrb	w0, [sp, 38]	// low.16_12, low
// Utils/SenseHat/sense_hat_environment.c:253:     uint32_t raw24 = ((uint32_t)high << 16) | ((uint32_t)low << 8) | xl;
	lsl	w0, w0, 8	// _14, _13,
// Utils/SenseHat/sense_hat_environment.c:253:     uint32_t raw24 = ((uint32_t)high << 16) | ((uint32_t)low << 8) | xl;
	orr	w0, w1, w0	// _15, _11, _14
// Utils/SenseHat/sense_hat_environment.c:253:     uint32_t raw24 = ((uint32_t)high << 16) | ((uint32_t)low << 8) | xl;
	ldrb	w1, [sp, 39]	// xl.17_16, xl
// Utils/SenseHat/sense_hat_environment.c:253:     uint32_t raw24 = ((uint32_t)high << 16) | ((uint32_t)low << 8) | xl;
	orr	w0, w0, w1	// raw24_32, _15, _17
// Assembly optimization: exact signed 24-bit conversion with 12 fractional bits.
	sbfx	w0, w0, #0, #24
	scvtf	d31, w0, #12
// Utils/SenseHat/sense_hat_environment.c:256:     *pressure_hpa = raw / 4096.0;
	ldr	x0, [sp, 16]	// tmp140, pressure_hpa
	str	d31, [x0]	// _21, *pressure_hpa_28(D)
// Utils/SenseHat/sense_hat_environment.c:257:     return 0;
	mov	w0, 0	// _22,
.L82:
// Utils/SenseHat/sense_hat_environment.c:258: }
	ldp	x29, x30, [sp], 48	//,,,
	.cfi_restore 30
	.cfi_restore 29
	.cfi_def_cfa_offset 0
	ret	
	.cfi_endproc
.LFE12:
	.size	sense_hat_environment_read_pressure, .-sense_hat_environment_read_pressure
	.align	2
	.global	sense_hat_environment_read
	.type	sense_hat_environment_read, %function
sense_hat_environment_read:
.LFB13:
	.cfi_startproc
	stp	x29, x30, [sp, -32]!	//,,,
	.cfi_def_cfa_offset 32
	.cfi_offset 29, -32
	.cfi_offset 30, -24
	mov	x29, sp	//,
	str	x0, [sp, 24]	// sensor, sensor
	str	x1, [sp, 16]	// reading, reading
// Utils/SenseHat/sense_hat_environment.c:262:     if (sensor == NULL || reading == NULL)
	ldr	x0, [sp, 24]	// tmp108, sensor
	cmp	x0, 0	// tmp108,
	beq	.L84		//,
// Utils/SenseHat/sense_hat_environment.c:262:     if (sensor == NULL || reading == NULL)
	ldr	x0, [sp, 16]	// tmp109, reading
	cmp	x0, 0	// tmp109,
	bne	.L85		//,
.L84:
// Utils/SenseHat/sense_hat_environment.c:263:         return -1;
	mov	w0, -1	// _7,
	b	.L86		//
.L85:
// Utils/SenseHat/sense_hat_environment.c:265:     if (sense_hat_environment_read_temperature(sensor, &reading->temperature_c) != 0 ||
	ldr	x0, [sp, 16]	// _1, reading
	mov	x1, x0	//, _1
	ldr	x0, [sp, 24]	//, sensor
	bl	sense_hat_environment_read_temperature		//
// Utils/SenseHat/sense_hat_environment.c:265:     if (sense_hat_environment_read_temperature(sensor, &reading->temperature_c) != 0 ||
	cmp	w0, 0	// _2,
	bne	.L87		//,
// Utils/SenseHat/sense_hat_environment.c:266:         sense_hat_environment_read_humidity(sensor, &reading->humidity_percent) != 0 ||
	ldr	x0, [sp, 16]	// tmp110, reading
	add	x0, x0, 8	// _3, tmp110,
	mov	x1, x0	//, _3
	ldr	x0, [sp, 24]	//, sensor
	bl	sense_hat_environment_read_humidity		//
// Utils/SenseHat/sense_hat_environment.c:265:     if (sense_hat_environment_read_temperature(sensor, &reading->temperature_c) != 0 ||
	cmp	w0, 0	// _4,
	bne	.L87		//,
// Utils/SenseHat/sense_hat_environment.c:267:         sense_hat_environment_read_pressure(sensor, &reading->pressure_hpa) != 0)
	ldr	x0, [sp, 16]	// tmp111, reading
	add	x0, x0, 16	// _5, tmp111,
	mov	x1, x0	//, _5
	ldr	x0, [sp, 24]	//, sensor
	bl	sense_hat_environment_read_pressure		//
// Utils/SenseHat/sense_hat_environment.c:266:         sense_hat_environment_read_humidity(sensor, &reading->humidity_percent) != 0 ||
	cmp	w0, 0	// _6,
	beq	.L88		//,
.L87:
// Utils/SenseHat/sense_hat_environment.c:269:         return -1;
	mov	w0, -1	// _7,
	b	.L86		//
.L88:
// Utils/SenseHat/sense_hat_environment.c:272:     return 0;
	mov	w0, 0	// _7,
.L86:
// Utils/SenseHat/sense_hat_environment.c:273: }
	ldp	x29, x30, [sp], 32	//,,,
	.cfi_restore 30
	.cfi_restore 29
	.cfi_def_cfa_offset 0
	ret	
	.cfi_endproc
.LFE13:
	.size	sense_hat_environment_read, .-sense_hat_environment_read
	.ident	"GCC: (Debian 14.2.0-19) 14.2.0"
	.section	.note.GNU-stack,"",@progbits
