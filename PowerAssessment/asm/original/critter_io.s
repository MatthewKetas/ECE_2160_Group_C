	.arch armv8-a
	.file	"critter_io.c"
// GNU C11 (Debian 14.2.0-19) version 14.2.0 (aarch64-linux-gnu)
//	compiled by GNU C version 14.2.0, GMP version 6.3.0, MPFR version 4.2.1, MPC version 1.3.1, isl version isl-0.27-GMP

// warning: MPFR header version 4.2.1 differs from library version 4.2.2.
// GGC heuristics: --param ggc-min-expand=100 --param ggc-min-heapsize=131072
// options passed: -mlittle-endian -mabi=lp64 -O0 -std=c11 -fasynchronous-unwind-tables
	.text
	.section	.rodata
	.align	3
.LC0:
	.string	"/dev/i2c-1"
	.text
	.align	2
	.type	critter_read_sense_hat_environment, %function
critter_read_sense_hat_environment:
.LFB0:
	.cfi_startproc
	stp	x29, x30, [sp, -80]!	//,,,
	.cfi_def_cfa_offset 80
	.cfi_offset 29, -80
	.cfi_offset 30, -72
	mov	x29, sp	//,
	str	x0, [sp, 40]	// temperature_c, temperature_c
	str	x1, [sp, 32]	// humidity_percent, humidity_percent
	str	x2, [sp, 24]	// pressure_hpa, pressure_hpa
// Development/CritterProduct/Pilot/IO/critter_io.c:29:     sense_hat_environment_reading_t reading = {0};
	stp	xzr, xzr, [sp, 56]	// reading
	str	xzr, [sp, 72]	//, reading
// Development/CritterProduct/Pilot/IO/critter_io.c:31:     if (!initialized)
	adrp	x0, initialized.3	// tmp110,
	add	x0, x0, :lo12:initialized.3	// tmp109, tmp110,
	ldrb	w0, [x0]	// initialized.0_1, initialized
	eor	w0, w0, 1	// tmp111, initialized.0_1,
	and	w0, w0, 255	// _2, tmp111
// Development/CritterProduct/Pilot/IO/critter_io.c:31:     if (!initialized)
	and	w0, w0, 1	// tmp112, _2,
	cmp	w0, 0	// tmp112,
	beq	.L2		//,
// Development/CritterProduct/Pilot/IO/critter_io.c:33:         if (sense_hat_environment_init(&sensor, "/dev/i2c-1",
	mov	w3, 4	//,
	mov	w2, 3	//,
	adrp	x0, .LC0	// tmp113,
	add	x1, x0, :lo12:.LC0	//, tmp113,
	adrp	x0, sensor.2	// tmp114,
	add	x0, x0, :lo12:sensor.2	//, tmp114,
	bl	sense_hat_environment_init		//
// Development/CritterProduct/Pilot/IO/critter_io.c:33:         if (sense_hat_environment_init(&sensor, "/dev/i2c-1",
	cmp	w0, 0	// _3,
	beq	.L3		//,
// Development/CritterProduct/Pilot/IO/critter_io.c:37:             return -1;
	mov	w0, -1	// _8,
	b	.L9		//
.L3:
// Development/CritterProduct/Pilot/IO/critter_io.c:39:         initialized = true;
	adrp	x0, initialized.3	// tmp116,
	add	x0, x0, :lo12:initialized.3	// tmp115, tmp116,
	mov	w1, 1	// tmp117,
	strb	w1, [x0]	// tmp117, initialized
.L2:
// Development/CritterProduct/Pilot/IO/critter_io.c:42:     if (sense_hat_environment_read(&sensor, &reading) == 0)
	add	x0, sp, 56	// tmp118,,
	mov	x1, x0	//, tmp118
	adrp	x0, sensor.2	// tmp119,
	add	x0, x0, :lo12:sensor.2	//, tmp119,
	bl	sense_hat_environment_read		//
// Development/CritterProduct/Pilot/IO/critter_io.c:42:     if (sense_hat_environment_read(&sensor, &reading) == 0)
	cmp	w0, 0	// _4,
	bne	.L5		//,
// Development/CritterProduct/Pilot/IO/critter_io.c:44:         if (temperature_c != NULL)
	ldr	x0, [sp, 40]	// tmp120, temperature_c
	cmp	x0, 0	// tmp120,
	beq	.L6		//,
// Development/CritterProduct/Pilot/IO/critter_io.c:45:             *temperature_c = reading.temperature_c;
	ldr	d31, [sp, 56]	// _5, reading.temperature_c
// Development/CritterProduct/Pilot/IO/critter_io.c:45:             *temperature_c = reading.temperature_c;
	ldr	x0, [sp, 40]	// tmp121, temperature_c
	str	d31, [x0]	// _5, *temperature_c_23(D)
.L6:
// Development/CritterProduct/Pilot/IO/critter_io.c:46:         if (humidity_percent != NULL)
	ldr	x0, [sp, 32]	// tmp122, humidity_percent
	cmp	x0, 0	// tmp122,
	beq	.L7		//,
// Development/CritterProduct/Pilot/IO/critter_io.c:47:             *humidity_percent = reading.humidity_percent;
	ldr	d31, [sp, 64]	// _6, reading.humidity_percent
// Development/CritterProduct/Pilot/IO/critter_io.c:47:             *humidity_percent = reading.humidity_percent;
	ldr	x0, [sp, 32]	// tmp123, humidity_percent
	str	d31, [x0]	// _6, *humidity_percent_25(D)
.L7:
// Development/CritterProduct/Pilot/IO/critter_io.c:48:         if (pressure_hpa != NULL)
	ldr	x0, [sp, 24]	// tmp124, pressure_hpa
	cmp	x0, 0	// tmp124,
	beq	.L8		//,
// Development/CritterProduct/Pilot/IO/critter_io.c:49:             *pressure_hpa = reading.pressure_hpa;
	ldr	d31, [sp, 72]	// _7, reading.pressure_hpa
// Development/CritterProduct/Pilot/IO/critter_io.c:49:             *pressure_hpa = reading.pressure_hpa;
	ldr	x0, [sp, 24]	// tmp125, pressure_hpa
	str	d31, [x0]	// _7, *pressure_hpa_27(D)
.L8:
// Development/CritterProduct/Pilot/IO/critter_io.c:50:         return 0;
	mov	w0, 0	// _8,
	b	.L9		//
.L5:
// Development/CritterProduct/Pilot/IO/critter_io.c:53:     sense_hat_environment_close(&sensor);
	adrp	x0, sensor.2	// tmp126,
	add	x0, x0, :lo12:sensor.2	//, tmp126,
	bl	sense_hat_environment_close		//
// Development/CritterProduct/Pilot/IO/critter_io.c:54:     initialized = false;
	adrp	x0, initialized.3	// tmp128,
	add	x0, x0, :lo12:initialized.3	// tmp127, tmp128,
	strb	wzr, [x0]	//, initialized
// Development/CritterProduct/Pilot/IO/critter_io.c:55:     return -1;
	mov	w0, -1	// _8,
.L9:
// Development/CritterProduct/Pilot/IO/critter_io.c:56: }
	ldp	x29, x30, [sp], 80	//,,,
	.cfi_restore 30
	.cfi_restore 29
	.cfi_def_cfa_offset 0
	ret	
	.cfi_endproc
.LFE0:
	.size	critter_read_sense_hat_environment, .-critter_read_sense_hat_environment
	.align	2
	.type	critter_read_sense_hat_temperature, %function
critter_read_sense_hat_temperature:
.LFB1:
	.cfi_startproc
	stp	x29, x30, [sp, -32]!	//,,,
	.cfi_def_cfa_offset 32
	.cfi_offset 29, -32
	.cfi_offset 30, -24
	mov	x29, sp	//,
	str	x0, [sp, 24]	// temperature_c, temperature_c
// Development/CritterProduct/Pilot/IO/critter_io.c:60:     if (temperature_c == NULL)
	ldr	x0, [sp, 24]	// tmp102, temperature_c
	cmp	x0, 0	// tmp102,
	bne	.L11		//,
// Development/CritterProduct/Pilot/IO/critter_io.c:61:         return -1;
	mov	w0, -1	// _1,
	b	.L12		//
.L11:
// Development/CritterProduct/Pilot/IO/critter_io.c:63:     return critter_read_sense_hat_environment(temperature_c, NULL, NULL);
	mov	x2, 0	//,
	mov	x1, 0	//,
	ldr	x0, [sp, 24]	//, temperature_c
	bl	critter_read_sense_hat_environment		//
.L12:
// Development/CritterProduct/Pilot/IO/critter_io.c:64: }
	ldp	x29, x30, [sp], 32	//,,,
	.cfi_restore 30
	.cfi_restore 29
	.cfi_def_cfa_offset 0
	ret	
	.cfi_endproc
.LFE1:
	.size	critter_read_sense_hat_temperature, .-critter_read_sense_hat_temperature
	.section	.rodata
	.align	3
.LC1:
	.string	"CRITTER_DATA_FILE"
	.align	3
.LC2:
	.string	"Development/Data/temperature_samples.csv"
	.align	3
.LC3:
	.string	"r"
	.align	3
.LC4:
	.string	"%*[^,],%lf"
	.text
	.align	2
	.type	critter_read_data_temperature, %function
critter_read_data_temperature:
.LFB2:
	.cfi_startproc
	stp	x29, x30, [sp, -320]!	//,,,
	.cfi_def_cfa_offset 320
	.cfi_offset 29, -320
	.cfi_offset 30, -312
	mov	x29, sp	//,
	str	x0, [sp, 24]	// temperature_c, temperature_c
// Development/CritterProduct/Pilot/IO/critter_io.c:70:     const char *path = getenv("CRITTER_DATA_FILE");
	adrp	x0, .LC1	// tmp112,
	add	x0, x0, :lo12:.LC1	//, tmp112,
	bl	getenv		//
	str	x0, [sp, 312]	//, path
// Development/CritterProduct/Pilot/IO/critter_io.c:72:     double value = 0.0;
	str	xzr, [sp, 288]	//, value
// Development/CritterProduct/Pilot/IO/critter_io.c:75:     if (temperature_c == NULL)
	ldr	x0, [sp, 24]	// tmp113, temperature_c
	cmp	x0, 0	// tmp113,
	bne	.L14		//,
// Development/CritterProduct/Pilot/IO/critter_io.c:76:         return -1;
	mov	w0, -1	// _12,
	b	.L26		//
.L14:
// Development/CritterProduct/Pilot/IO/critter_io.c:78:     if (path == NULL || path[0] == '\0')
	ldr	x0, [sp, 312]	// tmp114, path
	cmp	x0, 0	// tmp114,
	beq	.L16		//,
// Development/CritterProduct/Pilot/IO/critter_io.c:78:     if (path == NULL || path[0] == '\0')
	ldr	x0, [sp, 312]	// tmp115, path
	ldrb	w0, [x0]	// _1, *path_18
// Development/CritterProduct/Pilot/IO/critter_io.c:78:     if (path == NULL || path[0] == '\0')
	cmp	w0, 0	// _1,
	bne	.L17		//,
.L16:
// Development/CritterProduct/Pilot/IO/critter_io.c:80:         path = "Development/Data/temperature_samples.csv";
	adrp	x0, .LC2	// tmp117,
	add	x0, x0, :lo12:.LC2	// tmp116, tmp117,
	str	x0, [sp, 312]	// tmp116, path
.L17:
// Development/CritterProduct/Pilot/IO/critter_io.c:83:     file = fopen(path, "r");
	adrp	x0, .LC3	// tmp118,
	add	x1, x0, :lo12:.LC3	//, tmp118,
	ldr	x0, [sp, 312]	//, path
	bl	fopen		//
	str	x0, [sp, 304]	// tmp119, file
// Development/CritterProduct/Pilot/IO/critter_io.c:84:     if (file == NULL)
	ldr	x0, [sp, 304]	// tmp120, file
	cmp	x0, 0	// tmp120,
	bne	.L20		//,
// Development/CritterProduct/Pilot/IO/critter_io.c:86:         if (initialized)
	adrp	x0, initialized.1	// tmp122,
	add	x0, x0, :lo12:initialized.1	// tmp121, tmp122,
	ldrb	w0, [x0]	// initialized.1_2, initialized
// Development/CritterProduct/Pilot/IO/critter_io.c:86:         if (initialized)
	and	w0, w0, 1	// tmp123, initialized.1_2,
	cmp	w0, 0	// tmp123,
	beq	.L19		//,
// Development/CritterProduct/Pilot/IO/critter_io.c:88:             *temperature_c = last_value;
	adrp	x0, last_value.0	// tmp125,
	add	x0, x0, :lo12:last_value.0	// tmp124, tmp125,
	ldr	d31, [x0]	// last_value.2_3, last_value
	ldr	x0, [sp, 24]	// tmp126, temperature_c
	str	d31, [x0]	// last_value.2_3, *temperature_c_20(D)
// Development/CritterProduct/Pilot/IO/critter_io.c:89:             return 0;
	mov	w0, 0	// _12,
	b	.L26		//
.L19:
// Development/CritterProduct/Pilot/IO/critter_io.c:91:         return -1;
	mov	w0, -1	// _12,
	b	.L26		//
.L24:
// Development/CritterProduct/Pilot/IO/critter_io.c:96:         char *newline = strchr(buffer, '\n');
	add	x0, sp, 32	// tmp127,,
	mov	w1, 10	//,
	bl	strchr		//
	str	x0, [sp, 296]	//, newline
// Development/CritterProduct/Pilot/IO/critter_io.c:97:         if (newline != NULL)
	ldr	x0, [sp, 296]	// tmp128, newline
	cmp	x0, 0	// tmp128,
	beq	.L21		//,
// Development/CritterProduct/Pilot/IO/critter_io.c:98:             *newline = '\0';
	ldr	x0, [sp, 296]	// tmp129, newline
	strb	wzr, [x0]	//, *newline_29
.L21:
// Development/CritterProduct/Pilot/IO/critter_io.c:100:         if (strchr(buffer, ',') == NULL)
	add	x0, sp, 32	// tmp130,,
	mov	w1, 44	//,
	bl	strchr		//
// Development/CritterProduct/Pilot/IO/critter_io.c:100:         if (strchr(buffer, ',') == NULL)
	cmp	x0, 0	// _4,
	beq	.L27		//,
// Development/CritterProduct/Pilot/IO/critter_io.c:103:         if (sscanf(buffer, "%*[^,],%lf", &value) == 1)
	add	x0, sp, 288	// tmp131,,
	add	x3, sp, 32	// tmp132,,
	mov	x2, x0	//, tmp131
	adrp	x0, .LC4	// tmp133,
	add	x1, x0, :lo12:.LC4	//, tmp133,
	mov	x0, x3	//, tmp132
	bl	__isoc99_sscanf		//
// Development/CritterProduct/Pilot/IO/critter_io.c:103:         if (sscanf(buffer, "%*[^,],%lf", &value) == 1)
	cmp	w0, 1	// _5,
	bne	.L20		//,
// Development/CritterProduct/Pilot/IO/critter_io.c:105:             fclose(file);
	ldr	x0, [sp, 304]	//, file
	bl	fclose		//
// Development/CritterProduct/Pilot/IO/critter_io.c:106:             initialized = true;
	adrp	x0, initialized.1	// tmp135,
	add	x0, x0, :lo12:initialized.1	// tmp134, tmp135,
	mov	w1, 1	// tmp136,
	strb	w1, [x0]	// tmp136, initialized
// Development/CritterProduct/Pilot/IO/critter_io.c:107:             last_value = value;
	ldr	d31, [sp, 288]	// value.3_6, value
	adrp	x0, last_value.0	// tmp138,
	add	x0, x0, :lo12:last_value.0	// tmp137, tmp138,
	str	d31, [x0]	// value.3_6, last_value
// Development/CritterProduct/Pilot/IO/critter_io.c:108:             *temperature_c = value;
	ldr	d31, [sp, 288]	// value.4_7, value
	ldr	x0, [sp, 24]	// tmp139, temperature_c
	str	d31, [x0]	// value.4_7, *temperature_c_20(D)
// Development/CritterProduct/Pilot/IO/critter_io.c:109:             return 0;
	mov	w0, 0	// _12,
	b	.L26		//
.L27:
// Development/CritterProduct/Pilot/IO/critter_io.c:101:             continue;
	nop	
.L20:
// Development/CritterProduct/Pilot/IO/critter_io.c:94:     while (fgets(buffer, sizeof(buffer), file) != NULL)
	add	x0, sp, 32	// tmp140,,
	ldr	x2, [sp, 304]	//, file
	mov	w1, 256	//,
	bl	fgets		//
// Development/CritterProduct/Pilot/IO/critter_io.c:94:     while (fgets(buffer, sizeof(buffer), file) != NULL)
	cmp	x0, 0	// _8,
	bne	.L24		//,
// Development/CritterProduct/Pilot/IO/critter_io.c:113:     fclose(file);
	ldr	x0, [sp, 304]	//, file
	bl	fclose		//
// Development/CritterProduct/Pilot/IO/critter_io.c:114:     if (initialized)
	adrp	x0, initialized.1	// tmp142,
	add	x0, x0, :lo12:initialized.1	// tmp141, tmp142,
	ldrb	w0, [x0]	// initialized.5_9, initialized
// Development/CritterProduct/Pilot/IO/critter_io.c:114:     if (initialized)
	and	w0, w0, 1	// tmp143, initialized.5_9,
	cmp	w0, 0	// tmp143,
	beq	.L25		//,
// Development/CritterProduct/Pilot/IO/critter_io.c:116:         *temperature_c = last_value;
	adrp	x0, last_value.0	// tmp145,
	add	x0, x0, :lo12:last_value.0	// tmp144, tmp145,
	ldr	d31, [x0]	// last_value.6_10, last_value
	ldr	x0, [sp, 24]	// tmp146, temperature_c
	str	d31, [x0]	// last_value.6_10, *temperature_c_20(D)
// Development/CritterProduct/Pilot/IO/critter_io.c:117:         return 0;
	mov	w0, 0	// _12,
	b	.L26		//
.L25:
// Development/CritterProduct/Pilot/IO/critter_io.c:120:     return -1;
	mov	w0, -1	// _12,
.L26:
// Development/CritterProduct/Pilot/IO/critter_io.c:121: }
	ldp	x29, x30, [sp], 320	//,,,
	.cfi_restore 30
	.cfi_restore 29
	.cfi_def_cfa_offset 0
	ret	
	.cfi_endproc
.LFE2:
	.size	critter_read_data_temperature, .-critter_read_data_temperature
	.section	.rodata
	.align	3
.LC5:
	.string	"/sys/class/thermal/thermal_zone0/temp"
	.align	3
.LC6:
	.string	"%d"
	.text
	.align	2
	.type	critter_read_cpu_temperature, %function
critter_read_cpu_temperature:
.LFB3:
	.cfi_startproc
	stp	x29, x30, [sp, -48]!	//,,,
	.cfi_def_cfa_offset 48
	.cfi_offset 29, -48
	.cfi_offset 30, -40
	mov	x29, sp	//,
	str	x0, [sp, 24]	// temperature_c, temperature_c
// Development/CritterProduct/Pilot/IO/critter_io.c:128:     if (temperature_c == NULL)
	ldr	x0, [sp, 24]	// tmp106, temperature_c
	cmp	x0, 0	// tmp106,
	bne	.L29		//,
// Development/CritterProduct/Pilot/IO/critter_io.c:129:         return -1;
	mov	w0, -1	// _5,
	b	.L33		//
.L29:
// Development/CritterProduct/Pilot/IO/critter_io.c:131:     file = fopen("/sys/class/thermal/thermal_zone0/temp", "r");
	adrp	x0, .LC3	// tmp107,
	add	x1, x0, :lo12:.LC3	//, tmp107,
	adrp	x0, .LC5	// tmp108,
	add	x0, x0, :lo12:.LC5	//, tmp108,
	bl	fopen		//
	str	x0, [sp, 40]	// tmp109, file
// Development/CritterProduct/Pilot/IO/critter_io.c:132:     if (file == NULL)
	ldr	x0, [sp, 40]	// tmp110, file
	cmp	x0, 0	// tmp110,
	bne	.L31		//,
// Development/CritterProduct/Pilot/IO/critter_io.c:133:         return -1;
	mov	w0, -1	// _5,
	b	.L33		//
.L31:
// Development/CritterProduct/Pilot/IO/critter_io.c:135:     if (fscanf(file, "%d", &raw_millicelsius) != 1)
	add	x0, sp, 36	// tmp111,,
	mov	x2, x0	//, tmp111
	adrp	x0, .LC6	// tmp112,
	add	x1, x0, :lo12:.LC6	//, tmp112,
	ldr	x0, [sp, 40]	//, file
	bl	__isoc99_fscanf		//
// Development/CritterProduct/Pilot/IO/critter_io.c:135:     if (fscanf(file, "%d", &raw_millicelsius) != 1)
	cmp	w0, 1	// _1,
	beq	.L32		//,
// Development/CritterProduct/Pilot/IO/critter_io.c:137:         fclose(file);
	ldr	x0, [sp, 40]	//, file
	bl	fclose		//
// Development/CritterProduct/Pilot/IO/critter_io.c:138:         return -1;
	mov	w0, -1	// _5,
	b	.L33		//
.L32:
// Development/CritterProduct/Pilot/IO/critter_io.c:141:     fclose(file);
	ldr	x0, [sp, 40]	//, file
	bl	fclose		//
// Development/CritterProduct/Pilot/IO/critter_io.c:142:     *temperature_c = (double)raw_millicelsius / 1000.0;
	ldr	w0, [sp, 36]	// raw_millicelsius.7_2, raw_millicelsius
	scvtf	d31, w0	// _3, raw_millicelsius.7_2
// Development/CritterProduct/Pilot/IO/critter_io.c:142:     *temperature_c = (double)raw_millicelsius / 1000.0;
	mov	x0, 70368744177664	// tmp116,
	movk	x0, 0x408f, lsl 48	// tmp116,,
	fmov	d30, x0	// tmp113, tmp116
	fdiv	d31, d31, d30	// _4, _3, tmp113
// Development/CritterProduct/Pilot/IO/critter_io.c:142:     *temperature_c = (double)raw_millicelsius / 1000.0;
	ldr	x0, [sp, 24]	// tmp114, temperature_c
	str	d31, [x0]	// _4, *temperature_c_7(D)
// Development/CritterProduct/Pilot/IO/critter_io.c:143:     return 0;
	mov	w0, 0	// _5,
.L33:
// Development/CritterProduct/Pilot/IO/critter_io.c:144: }
	ldp	x29, x30, [sp], 48	//,,,
	.cfi_restore 30
	.cfi_restore 29
	.cfi_def_cfa_offset 0
	ret	
	.cfi_endproc
.LFE3:
	.size	critter_read_cpu_temperature, .-critter_read_cpu_temperature
	.section	.rodata
	.align	3
.LC7:
	.string	"/proc/self/exe"
	.align	3
.LC8:
	.string	"%s"
	.text
	.align	2
	.type	critter_resolve_executable_directory, %function
critter_resolve_executable_directory:
.LFB4:
	.cfi_startproc
	mov	x12, 4144	//,
	sub	sp, sp, x12	//,,
	.cfi_def_cfa_offset 4144
	stp	x29, x30, [sp]	//,,
	.cfi_offset 29, -4144
	.cfi_offset 30, -4136
	mov	x29, sp	//,
	str	x0, [sp, 24]	// buffer, buffer
	str	x1, [sp, 16]	// buffer_size, buffer_size
// Development/CritterProduct/Pilot/IO/critter_io.c:152:     if (buffer == NULL || buffer_size == 0U)
	ldr	x0, [sp, 24]	// tmp104, buffer
	cmp	x0, 0	// tmp104,
	beq	.L35		//,
// Development/CritterProduct/Pilot/IO/critter_io.c:152:     if (buffer == NULL || buffer_size == 0U)
	ldr	x0, [sp, 16]	// tmp105, buffer_size
	cmp	x0, 0	// tmp105,
	bne	.L36		//,
.L35:
// Development/CritterProduct/Pilot/IO/critter_io.c:153:         return -1;
	mov	w0, -1	// _3,
	b	.L41		//
.L36:
// Development/CritterProduct/Pilot/IO/critter_io.c:155:     length = readlink("/proc/self/exe", exe_path, sizeof(exe_path) - 1U);
	add	x0, sp, 32	// tmp106,,
	mov	x2, 4095	//,
	mov	x1, x0	//, tmp106
	adrp	x0, .LC7	// tmp107,
	add	x0, x0, :lo12:.LC7	//, tmp107,
	bl	readlink		//
	str	x0, [sp, 4136]	//, length
// Development/CritterProduct/Pilot/IO/critter_io.c:156:     if (length < 0)
	ldr	x0, [sp, 4136]	// tmp108, length
	cmp	x0, 0	// tmp108,
	bge	.L38		//,
// Development/CritterProduct/Pilot/IO/critter_io.c:157:         return -1;
	mov	w0, -1	// _3,
	b	.L41		//
.L38:
// Development/CritterProduct/Pilot/IO/critter_io.c:159:     exe_path[length] = '\0';
	ldr	x0, [sp, 4136]	// tmp109, length
	add	x1, sp, 32	// tmp110,,
	strb	wzr, [x1, x0]	//, exe_path[length_9]
// Development/CritterProduct/Pilot/IO/critter_io.c:160:     slash = strrchr(exe_path, '/');
	add	x0, sp, 32	// tmp111,,
	mov	w1, 47	//,
	bl	strrchr		//
	str	x0, [sp, 4128]	//, slash
// Development/CritterProduct/Pilot/IO/critter_io.c:161:     if (slash == NULL)
	ldr	x0, [sp, 4128]	// tmp112, slash
	cmp	x0, 0	// tmp112,
	bne	.L39		//,
// Development/CritterProduct/Pilot/IO/critter_io.c:162:         return -1;
	mov	w0, -1	// _3,
	b	.L41		//
.L39:
// Development/CritterProduct/Pilot/IO/critter_io.c:164:     *slash = '\0';
	ldr	x0, [sp, 4128]	// tmp113, slash
	strb	wzr, [x0]	//, *slash_11
// Development/CritterProduct/Pilot/IO/critter_io.c:166:     if (snprintf(buffer, buffer_size, "%s", exe_path) >= (int)buffer_size)
	add	x0, sp, 32	// tmp114,,
	mov	x3, x0	//, tmp114
	adrp	x0, .LC8	// tmp115,
	add	x2, x0, :lo12:.LC8	//, tmp115,
	ldr	x1, [sp, 16]	//, buffer_size
	ldr	x0, [sp, 24]	//, buffer
	bl	snprintf		//
	mov	w1, w0	// _1,
// Development/CritterProduct/Pilot/IO/critter_io.c:166:     if (snprintf(buffer, buffer_size, "%s", exe_path) >= (int)buffer_size)
	ldr	x0, [sp, 16]	// tmp116, buffer_size
// Development/CritterProduct/Pilot/IO/critter_io.c:166:     if (snprintf(buffer, buffer_size, "%s", exe_path) >= (int)buffer_size)
	cmp	w1, w0	// _1, _2
	blt	.L40		//,
// Development/CritterProduct/Pilot/IO/critter_io.c:167:         return -1;
	mov	w0, -1	// _3,
	b	.L41		//
.L40:
// Development/CritterProduct/Pilot/IO/critter_io.c:169:     return 0;
	mov	w0, 0	// _3,
.L41:
// Development/CritterProduct/Pilot/IO/critter_io.c:170: }
	ldp	x29, x30, [sp]	//,,
	mov	x12, 4144	//,
	add	sp, sp, x12	//,,
	.cfi_restore 29
	.cfi_restore 30
	.cfi_def_cfa_offset 0
	ret	
	.cfi_endproc
.LFE4:
	.size	critter_resolve_executable_directory, .-critter_resolve_executable_directory
	.section	.rodata
	.align	3
.LC9:
	.string	"%s/Data/temperature_samples.csv"
	.text
	.align	2
	.type	critter_resolve_runtime_data_path, %function
critter_resolve_runtime_data_path:
.LFB5:
	.cfi_startproc
	mov	x12, 4144	//,
	sub	sp, sp, x12	//,,
	.cfi_def_cfa_offset 4144
	stp	x29, x30, [sp]	//,,
	.cfi_offset 29, -4144
	.cfi_offset 30, -4136
	mov	x29, sp	//,
	str	x0, [sp, 24]	// buffer, buffer
	str	x1, [sp, 16]	// buffer_size, buffer_size
// Development/CritterProduct/Pilot/IO/critter_io.c:177:     if (buffer == NULL || buffer_size == 0U)
	ldr	x0, [sp, 24]	// tmp104, buffer
	cmp	x0, 0	// tmp104,
	beq	.L43		//,
// Development/CritterProduct/Pilot/IO/critter_io.c:177:     if (buffer == NULL || buffer_size == 0U)
	ldr	x0, [sp, 16]	// tmp105, buffer_size
	cmp	x0, 0	// tmp105,
	bne	.L44		//,
.L43:
// Development/CritterProduct/Pilot/IO/critter_io.c:178:         return -1;
	mov	w0, -1	// _3,
	b	.L49		//
.L44:
// Development/CritterProduct/Pilot/IO/critter_io.c:180:     if (critter_resolve_executable_directory(app_dir, sizeof(app_dir)) != 0)
	add	x0, sp, 40	// tmp106,,
	mov	x1, 4096	//,
	bl	critter_resolve_executable_directory		//
// Development/CritterProduct/Pilot/IO/critter_io.c:180:     if (critter_resolve_executable_directory(app_dir, sizeof(app_dir)) != 0)
	cmp	w0, 0	// _1,
	beq	.L46		//,
// Development/CritterProduct/Pilot/IO/critter_io.c:181:         return -1;
	mov	w0, -1	// _3,
	b	.L49		//
.L46:
// Development/CritterProduct/Pilot/IO/critter_io.c:183:     written = snprintf(buffer, buffer_size, "%s/Data/temperature_samples.csv", app_dir);
	add	x0, sp, 40	// tmp107,,
	mov	x3, x0	//, tmp107
	adrp	x0, .LC9	// tmp108,
	add	x2, x0, :lo12:.LC9	//, tmp108,
	ldr	x1, [sp, 16]	//, buffer_size
	ldr	x0, [sp, 24]	//, buffer
	bl	snprintf		//
	str	w0, [sp, 4140]	//, written
// Development/CritterProduct/Pilot/IO/critter_io.c:184:     if (written < 0 || (size_t)written >= buffer_size)
	ldr	w0, [sp, 4140]	// tmp109, written
	cmp	w0, 0	// tmp109,
	blt	.L47		//,
// Development/CritterProduct/Pilot/IO/critter_io.c:184:     if (written < 0 || (size_t)written >= buffer_size)
	ldrsw	x0, [sp, 4140]	// _2, written
// Development/CritterProduct/Pilot/IO/critter_io.c:184:     if (written < 0 || (size_t)written >= buffer_size)
	ldr	x1, [sp, 16]	// tmp110, buffer_size
	cmp	x1, x0	// tmp110, _2
	bhi	.L48		//,
.L47:
// Development/CritterProduct/Pilot/IO/critter_io.c:185:         return -1;
	mov	w0, -1	// _3,
	b	.L49		//
.L48:
// Development/CritterProduct/Pilot/IO/critter_io.c:187:     return 0;
	mov	w0, 0	// _3,
.L49:
// Development/CritterProduct/Pilot/IO/critter_io.c:188: }
	ldp	x29, x30, [sp]	//,,
	mov	x12, 4144	//,
	add	sp, sp, x12	//,,
	.cfi_restore 29
	.cfi_restore 30
	.cfi_def_cfa_offset 0
	ret	
	.cfi_endproc
.LFE5:
	.size	critter_resolve_runtime_data_path, .-critter_resolve_runtime_data_path
	.section	.rodata
	.align	3
.LC10:
	.string	"%s/Data"
	.text
	.align	2
	.type	critter_ensure_runtime_data_directory, %function
critter_ensure_runtime_data_directory:
.LFB6:
	.cfi_startproc
	mov	x12, 8336	//,
	sub	sp, sp, x12	//,,
	.cfi_def_cfa_offset 8336
	stp	x29, x30, [sp]	//,,
	.cfi_offset 29, -8336
	.cfi_offset 30, -8328
	mov	x29, sp	//,
// Development/CritterProduct/Pilot/IO/critter_io.c:196:     if (critter_resolve_executable_directory(app_dir, sizeof(app_dir)) != 0)
	add	x0, sp, 4096	// tmp110,,
	add	x0, x0, 144	// tmp110, tmp110,
	mov	x1, 4096	//,
	bl	critter_resolve_executable_directory		//
// Development/CritterProduct/Pilot/IO/critter_io.c:196:     if (critter_resolve_executable_directory(app_dir, sizeof(app_dir)) != 0)
	cmp	w0, 0	// _1,
	beq	.L51		//,
// Development/CritterProduct/Pilot/IO/critter_io.c:197:         return -1;
	mov	w0, -1	// _9,
	b	.L56		//
.L51:
// Development/CritterProduct/Pilot/IO/critter_io.c:199:     if (snprintf(data_dir, sizeof(data_dir), "%s/Data", app_dir) >= (int)sizeof(data_dir))
	add	x0, sp, 4096	// tmp111,,
	add	x0, x0, 144	// tmp111, tmp111,
	add	x4, sp, 144	// tmp112,,
	mov	x3, x0	//, tmp111
	adrp	x0, .LC10	// tmp113,
	add	x2, x0, :lo12:.LC10	//, tmp113,
	mov	x1, 4096	//,
	mov	x0, x4	//, tmp112
	bl	snprintf		//
// Development/CritterProduct/Pilot/IO/critter_io.c:199:     if (snprintf(data_dir, sizeof(data_dir), "%s/Data", app_dir) >= (int)sizeof(data_dir))
	cmp	w0, 4095	// _2,
	ble	.L53		//,
// Development/CritterProduct/Pilot/IO/critter_io.c:200:         return -1;
	mov	w0, -1	// _9,
	b	.L56		//
.L53:
// Development/CritterProduct/Pilot/IO/critter_io.c:202:     if (stat(data_dir, &info) != 0)
	add	x1, sp, 16	// tmp114,,
	add	x0, sp, 144	// tmp115,,
	bl	stat		//
// Development/CritterProduct/Pilot/IO/critter_io.c:202:     if (stat(data_dir, &info) != 0)
	cmp	w0, 0	// _3,
	beq	.L54		//,
// Development/CritterProduct/Pilot/IO/critter_io.c:204:         if (mkdir(data_dir, 0777) != 0 && errno != EEXIST)
	add	x0, sp, 144	// tmp116,,
	mov	w1, 511	//,
	bl	mkdir		//
// Development/CritterProduct/Pilot/IO/critter_io.c:204:         if (mkdir(data_dir, 0777) != 0 && errno != EEXIST)
	cmp	w0, 0	// _4,
	beq	.L55		//,
// Development/CritterProduct/Pilot/IO/critter_io.c:204:         if (mkdir(data_dir, 0777) != 0 && errno != EEXIST)
	bl	__errno_location		//
	ldr	w0, [x0]	// _6, *_5
// Development/CritterProduct/Pilot/IO/critter_io.c:204:         if (mkdir(data_dir, 0777) != 0 && errno != EEXIST)
	cmp	w0, 17	// _6,
	beq	.L55		//,
// Development/CritterProduct/Pilot/IO/critter_io.c:205:             return -1;
	mov	w0, -1	// _9,
	b	.L56		//
.L54:
// Development/CritterProduct/Pilot/IO/critter_io.c:207:     else if (!S_ISDIR(info.st_mode))
	ldr	w0, [sp, 32]	// _7, info.st_mode
	and	w0, w0, 61440	// _8, _7,
// Development/CritterProduct/Pilot/IO/critter_io.c:207:     else if (!S_ISDIR(info.st_mode))
	cmp	w0, 16384	// _8,
	beq	.L55		//,
// Development/CritterProduct/Pilot/IO/critter_io.c:209:         return -1;
	mov	w0, -1	// _9,
	b	.L56		//
.L55:
// Development/CritterProduct/Pilot/IO/critter_io.c:212:     return 0;
	mov	w0, 0	// _9,
.L56:
// Development/CritterProduct/Pilot/IO/critter_io.c:213: }
	ldp	x29, x30, [sp]	//,,
	mov	x12, 8336	//,
	add	sp, sp, x12	//,,
	.cfi_restore 29
	.cfi_restore 30
	.cfi_def_cfa_offset 0
	ret	
	.cfi_endproc
.LFE6:
	.size	critter_ensure_runtime_data_directory, .-critter_ensure_runtime_data_directory
	.align	2
	.global	critter_io_get_temperature_from_source
	.type	critter_io_get_temperature_from_source, %function
critter_io_get_temperature_from_source:
.LFB7:
	.cfi_startproc
	stp	x29, x30, [sp, -32]!	//,,,
	.cfi_def_cfa_offset 32
	.cfi_offset 29, -32
	.cfi_offset 30, -24
	mov	x29, sp	//,
	str	x0, [sp, 24]	// temperature_c, temperature_c
	str	w1, [sp, 20]	// source, source
// Development/CritterProduct/Pilot/IO/critter_io.c:217:     if (temperature_c == NULL)
	ldr	x0, [sp, 24]	// tmp102, temperature_c
	cmp	x0, 0	// tmp102,
	bne	.L58		//,
// Development/CritterProduct/Pilot/IO/critter_io.c:218:         return -1;
	mov	w0, -1	// _1,
	b	.L59		//
.L58:
// Development/CritterProduct/Pilot/IO/critter_io.c:220:     switch (source)
	ldr	w0, [sp, 20]	// tmp103, source
	cmp	w0, 3	// tmp103,
	beq	.L60		//,
	ldr	w0, [sp, 20]	// tmp104, source
	cmp	w0, 3	// tmp104,
	bhi	.L61		//,
	ldr	w0, [sp, 20]	// tmp105, source
	cmp	w0, 1	// tmp105,
	beq	.L62		//,
	ldr	w0, [sp, 20]	// tmp106, source
	cmp	w0, 2	// tmp106,
	beq	.L63		//,
	b	.L61		//
.L62:
// Development/CritterProduct/Pilot/IO/critter_io.c:223:             return critter_read_sense_hat_temperature(temperature_c);
	ldr	x0, [sp, 24]	//, temperature_c
	bl	critter_read_sense_hat_temperature		//
	b	.L59		//
.L63:
// Development/CritterProduct/Pilot/IO/critter_io.c:225:             return critter_read_data_temperature(temperature_c);
	ldr	x0, [sp, 24]	//, temperature_c
	bl	critter_read_data_temperature		//
	b	.L59		//
.L60:
// Development/CritterProduct/Pilot/IO/critter_io.c:227:             return critter_read_cpu_temperature(temperature_c);
	ldr	x0, [sp, 24]	//, temperature_c
	bl	critter_read_cpu_temperature		//
	b	.L59		//
.L61:
// Development/CritterProduct/Pilot/IO/critter_io.c:229:             return -1;
	mov	w0, -1	// _1,
.L59:
// Development/CritterProduct/Pilot/IO/critter_io.c:231: }
	ldp	x29, x30, [sp], 32	//,,,
	.cfi_restore 30
	.cfi_restore 29
	.cfi_def_cfa_offset 0
	ret	
	.cfi_endproc
.LFE7:
	.size	critter_io_get_temperature_from_source, .-critter_io_get_temperature_from_source
	.align	2
	.global	critter_io_get_temperature
	.type	critter_io_get_temperature, %function
critter_io_get_temperature:
.LFB8:
	.cfi_startproc
	stp	x29, x30, [sp, -32]!	//,,,
	.cfi_def_cfa_offset 32
	.cfi_offset 29, -32
	.cfi_offset 30, -24
	mov	x29, sp	//,
	str	x0, [sp, 24]	// temperature_c, temperature_c
	str	x1, [sp, 16]	// source, source
// Development/CritterProduct/Pilot/IO/critter_io.c:235:     if (temperature_c == NULL || source == NULL)
	ldr	x0, [sp, 24]	// tmp105, temperature_c
	cmp	x0, 0	// tmp105,
	beq	.L65		//,
// Development/CritterProduct/Pilot/IO/critter_io.c:235:     if (temperature_c == NULL || source == NULL)
	ldr	x0, [sp, 16]	// tmp106, source
	cmp	x0, 0	// tmp106,
	bne	.L66		//,
.L65:
// Development/CritterProduct/Pilot/IO/critter_io.c:236:         return -1;
	mov	w0, -1	// _4,
	b	.L67		//
.L66:
// Development/CritterProduct/Pilot/IO/critter_io.c:238:     if (critter_io_get_temperature_from_source(temperature_c, TEMPERATURE_SOURCE_SENSE_HAT) == 0)
	mov	w1, 1	//,
	ldr	x0, [sp, 24]	//, temperature_c
	bl	critter_io_get_temperature_from_source		//
// Development/CritterProduct/Pilot/IO/critter_io.c:238:     if (critter_io_get_temperature_from_source(temperature_c, TEMPERATURE_SOURCE_SENSE_HAT) == 0)
	cmp	w0, 0	// _1,
	bne	.L68		//,
// Development/CritterProduct/Pilot/IO/critter_io.c:240:         *source = TEMPERATURE_SOURCE_SENSE_HAT;
	ldr	x0, [sp, 16]	// tmp107, source
	mov	w1, 1	// tmp108,
	str	w1, [x0]	// tmp108, *source_7(D)
// Development/CritterProduct/Pilot/IO/critter_io.c:241:         return 0;
	mov	w0, 0	// _4,
	b	.L67		//
.L68:
// Development/CritterProduct/Pilot/IO/critter_io.c:244:     if (critter_io_get_temperature_from_source(temperature_c, TEMPERATURE_SOURCE_DATA) == 0)
	mov	w1, 2	//,
	ldr	x0, [sp, 24]	//, temperature_c
	bl	critter_io_get_temperature_from_source		//
// Development/CritterProduct/Pilot/IO/critter_io.c:244:     if (critter_io_get_temperature_from_source(temperature_c, TEMPERATURE_SOURCE_DATA) == 0)
	cmp	w0, 0	// _2,
	bne	.L69		//,
// Development/CritterProduct/Pilot/IO/critter_io.c:246:         *source = TEMPERATURE_SOURCE_DATA;
	ldr	x0, [sp, 16]	// tmp109, source
	mov	w1, 2	// tmp110,
	str	w1, [x0]	// tmp110, *source_7(D)
// Development/CritterProduct/Pilot/IO/critter_io.c:247:         return 0;
	mov	w0, 0	// _4,
	b	.L67		//
.L69:
// Development/CritterProduct/Pilot/IO/critter_io.c:250:     if (critter_io_get_temperature_from_source(temperature_c, TEMPERATURE_SOURCE_CPU) == 0)
	mov	w1, 3	//,
	ldr	x0, [sp, 24]	//, temperature_c
	bl	critter_io_get_temperature_from_source		//
// Development/CritterProduct/Pilot/IO/critter_io.c:250:     if (critter_io_get_temperature_from_source(temperature_c, TEMPERATURE_SOURCE_CPU) == 0)
	cmp	w0, 0	// _3,
	bne	.L70		//,
// Development/CritterProduct/Pilot/IO/critter_io.c:252:         *source = TEMPERATURE_SOURCE_CPU;
	ldr	x0, [sp, 16]	// tmp111, source
	mov	w1, 3	// tmp112,
	str	w1, [x0]	// tmp112, *source_7(D)
// Development/CritterProduct/Pilot/IO/critter_io.c:253:         return 0;
	mov	w0, 0	// _4,
	b	.L67		//
.L70:
// Development/CritterProduct/Pilot/IO/critter_io.c:256:     return -1;
	mov	w0, -1	// _4,
.L67:
// Development/CritterProduct/Pilot/IO/critter_io.c:257: }
	ldp	x29, x30, [sp], 32	//,,,
	.cfi_restore 30
	.cfi_restore 29
	.cfi_def_cfa_offset 0
	ret	
	.cfi_endproc
.LFE8:
	.size	critter_io_get_temperature, .-critter_io_get_temperature
	.align	2
	.global	critter_io_read_sample
	.type	critter_io_read_sample, %function
critter_io_read_sample:
.LFB9:
	.cfi_startproc
	stp	x29, x30, [sp, -80]!	//,,,
	.cfi_def_cfa_offset 80
	.cfi_offset 29, -80
	.cfi_offset 30, -72
	mov	x29, sp	//,
	str	x0, [sp, 24]	// sample, sample
// Development/CritterProduct/Pilot/IO/critter_io.c:261:     double temperature_c = 0.0;
	str	xzr, [sp, 72]	//, temperature_c
// Development/CritterProduct/Pilot/IO/critter_io.c:262:     critter_temperature_source_t source = TEMPERATURE_SOURCE_UNKNOWN;
	str	wzr, [sp, 68]	//, source
// Development/CritterProduct/Pilot/IO/critter_io.c:263:     double humidity = 0.0;
	str	xzr, [sp, 56]	//, humidity
// Development/CritterProduct/Pilot/IO/critter_io.c:264:     double pressure = 0.0;
	str	xzr, [sp, 48]	//, pressure
// Development/CritterProduct/Pilot/IO/critter_io.c:267:     if (sample == NULL)
	ldr	x0, [sp, 24]	// tmp116, sample
	cmp	x0, 0	// tmp116,
	bne	.L72		//,
// Development/CritterProduct/Pilot/IO/critter_io.c:268:         return -1;
	mov	w0, -1	// _15,
	b	.L79		//
.L72:
// Development/CritterProduct/Pilot/IO/critter_io.c:270:     if (critter_io_get_temperature(&temperature_c, &source) != 0)
	add	x1, sp, 68	// tmp117,,
	add	x0, sp, 72	// tmp118,,
	bl	critter_io_get_temperature		//
// Development/CritterProduct/Pilot/IO/critter_io.c:270:     if (critter_io_get_temperature(&temperature_c, &source) != 0)
	cmp	w0, 0	// _1,
	beq	.L74		//,
// Development/CritterProduct/Pilot/IO/critter_io.c:271:         return -1;
	mov	w0, -1	// _15,
	b	.L79		//
.L74:
// Development/CritterProduct/Pilot/IO/critter_io.c:273:     if (source == TEMPERATURE_SOURCE_SENSE_HAT)
	ldr	w0, [sp, 68]	// source.8_2, source
// Development/CritterProduct/Pilot/IO/critter_io.c:273:     if (source == TEMPERATURE_SOURCE_SENSE_HAT)
	cmp	w0, 1	// source.8_2,
	bne	.L75		//,
// Development/CritterProduct/Pilot/IO/critter_io.c:275:         if (critter_read_sense_hat_environment(&temperature_c, &humidity, &pressure) != 0)
	add	x2, sp, 48	// tmp119,,
	add	x1, sp, 56	// tmp120,,
	add	x0, sp, 72	// tmp121,,
	bl	critter_read_sense_hat_environment		//
// Development/CritterProduct/Pilot/IO/critter_io.c:275:         if (critter_read_sense_hat_environment(&temperature_c, &humidity, &pressure) != 0)
	cmp	w0, 0	// _3,
	beq	.L76		//,
// Development/CritterProduct/Pilot/IO/critter_io.c:276:             return -1;
	mov	w0, -1	// _15,
	b	.L79		//
.L76:
// Development/CritterProduct/Pilot/IO/critter_io.c:277:         sample->has_humidity = true;
	ldr	x0, [sp, 24]	// tmp122, sample
	mov	w1, 1	// tmp123,
	strb	w1, [x0, 36]	// tmp123, sample_23(D)->has_humidity
// Development/CritterProduct/Pilot/IO/critter_io.c:278:         sample->has_pressure = true;
	ldr	x0, [sp, 24]	// tmp124, sample
	mov	w1, 1	// tmp125,
	strb	w1, [x0, 37]	// tmp125, sample_23(D)->has_pressure
	b	.L77		//
.L75:
// Development/CritterProduct/Pilot/IO/critter_io.c:282:         sample->has_humidity = false;
	ldr	x0, [sp, 24]	// tmp126, sample
	strb	wzr, [x0, 36]	//, sample_23(D)->has_humidity
// Development/CritterProduct/Pilot/IO/critter_io.c:283:         sample->has_pressure = false;
	ldr	x0, [sp, 24]	// tmp127, sample
	strb	wzr, [x0, 37]	//, sample_23(D)->has_pressure
.L77:
// Development/CritterProduct/Pilot/IO/critter_io.c:286:     if (clock_gettime(CLOCK_REALTIME, &timestamp_ts) != 0)
	add	x0, sp, 32	// tmp128,,
	mov	x1, x0	//, tmp128
	mov	w0, 0	//,
	bl	clock_gettime		//
// Development/CritterProduct/Pilot/IO/critter_io.c:286:     if (clock_gettime(CLOCK_REALTIME, &timestamp_ts) != 0)
	cmp	w0, 0	// _4,
	beq	.L78		//,
// Development/CritterProduct/Pilot/IO/critter_io.c:287:         return -1;
	mov	w0, -1	// _15,
	b	.L79		//
.L78:
// Development/CritterProduct/Pilot/IO/critter_io.c:289:     sample->timestamp_s = (double)timestamp_ts.tv_sec +
	ldr	d31, [sp, 32]	// _5, timestamp_ts.tv_sec
// Development/CritterProduct/Pilot/IO/critter_io.c:289:     sample->timestamp_s = (double)timestamp_ts.tv_sec +
	scvtf	d30, d31	// _6, _5
// Development/CritterProduct/Pilot/IO/critter_io.c:290:                           (double)timestamp_ts.tv_nsec / 1000000000.0;
	ldr	d31, [sp, 40]	// _7, timestamp_ts.tv_nsec
// Development/CritterProduct/Pilot/IO/critter_io.c:290:                           (double)timestamp_ts.tv_nsec / 1000000000.0;
	scvtf	d31, d31	// _8, _7
// Development/CritterProduct/Pilot/IO/critter_io.c:290:                           (double)timestamp_ts.tv_nsec / 1000000000.0;
	mov	x0, 225833675390976	// tmp136,
	movk	x0, 0x41cd, lsl 48	// tmp136,,
	fmov	d29, x0	// tmp129, tmp136
	fdiv	d31, d31, d29	// _9, _8, tmp129
// Development/CritterProduct/Pilot/IO/critter_io.c:289:     sample->timestamp_s = (double)timestamp_ts.tv_sec +
	fadd	d31, d30, d31	// _10, _6, _9
// Development/CritterProduct/Pilot/IO/critter_io.c:289:     sample->timestamp_s = (double)timestamp_ts.tv_sec +
	ldr	x0, [sp, 24]	// tmp130, sample
	str	d31, [x0]	// _10, sample_23(D)->timestamp_s
// Development/CritterProduct/Pilot/IO/critter_io.c:292:     sample->temperature_c = temperature_c;
	ldr	d31, [sp, 72]	// temperature_c.9_11, temperature_c
	ldr	x0, [sp, 24]	// tmp131, sample
	str	d31, [x0, 8]	// temperature_c.9_11, sample_23(D)->temperature_c
// Development/CritterProduct/Pilot/IO/critter_io.c:293:     sample->source = source;
	ldr	w1, [sp, 68]	// source.10_12, source
	ldr	x0, [sp, 24]	// tmp132, sample
	str	w1, [x0, 32]	// source.10_12, sample_23(D)->source
// Development/CritterProduct/Pilot/IO/critter_io.c:294:     sample->humidity_percent = humidity;
	ldr	d31, [sp, 56]	// humidity.11_13, humidity
	ldr	x0, [sp, 24]	// tmp133, sample
	str	d31, [x0, 16]	// humidity.11_13, sample_23(D)->humidity_percent
// Development/CritterProduct/Pilot/IO/critter_io.c:295:     sample->pressure_hpa = pressure;
	ldr	d31, [sp, 48]	// pressure.12_14, pressure
	ldr	x0, [sp, 24]	// tmp134, sample
	str	d31, [x0, 24]	// pressure.12_14, sample_23(D)->pressure_hpa
// Development/CritterProduct/Pilot/IO/critter_io.c:297:     return 0;
	mov	w0, 0	// _15,
.L79:
// Development/CritterProduct/Pilot/IO/critter_io.c:298: }
	ldp	x29, x30, [sp], 80	//,,,
	.cfi_restore 30
	.cfi_restore 29
	.cfi_def_cfa_offset 0
	ret	
	.cfi_endproc
.LFE9:
	.size	critter_io_read_sample, .-critter_io_read_sample
	.section	.rodata
	.align	3
.LC11:
	.string	"a"
	.align	3
.LC12:
	.string	"timestamp_s,temperature_c,humidity_percent,pressure_hpa,source,has_humidity,has_pressure\n"
	.align	3
.LC13:
	.string	"sense_hat"
	.align	3
.LC14:
	.string	"data"
	.align	3
.LC15:
	.string	"cpu"
	.align	3
.LC16:
	.string	"unknown"
	.align	3
.LC17:
	.string	"%.6f,%.6f,%.6f,%.6f,%s,%d,%d\n"
	.text
	.align	2
	.global	critter_io_save_sample
	.type	critter_io_save_sample, %function
critter_io_save_sample:
.LFB10:
	.cfi_startproc
	mov	x12, 4160	//,
	sub	sp, sp, x12	//,,
	.cfi_def_cfa_offset 4160
	stp	x29, x30, [sp]	//,,
	.cfi_offset 29, -4160
	.cfi_offset 30, -4152
	mov	x29, sp	//,
	str	x0, [sp, 24]	// sample, sample
// Development/CritterProduct/Pilot/IO/critter_io.c:302:     const char *env_path = getenv("CRITTER_DATA_FILE");
	adrp	x0, .LC1	// tmp115,
	add	x0, x0, :lo12:.LC1	//, tmp115,
	bl	getenv		//
	str	x0, [sp, 4144]	//, env_path
// Development/CritterProduct/Pilot/IO/critter_io.c:307:     if (sample == NULL)
	ldr	x0, [sp, 24]	// tmp116, sample
	cmp	x0, 0	// tmp116,
	bne	.L81		//,
// Development/CritterProduct/Pilot/IO/critter_io.c:308:         return -1;
	mov	w0, -1	// _15,
	b	.L93		//
.L81:
// Development/CritterProduct/Pilot/IO/critter_io.c:310:     if (env_path != NULL && env_path[0] != '\0')
	ldr	x0, [sp, 4144]	// tmp117, env_path
	cmp	x0, 0	// tmp117,
	beq	.L83		//,
// Development/CritterProduct/Pilot/IO/critter_io.c:310:     if (env_path != NULL && env_path[0] != '\0')
	ldr	x0, [sp, 4144]	// tmp118, env_path
	ldrb	w0, [x0]	// _1, *env_path_21
// Development/CritterProduct/Pilot/IO/critter_io.c:310:     if (env_path != NULL && env_path[0] != '\0')
	cmp	w0, 0	// _1,
	beq	.L83		//,
// Development/CritterProduct/Pilot/IO/critter_io.c:312:         snprintf(path, sizeof(path), "%s", env_path);
	add	x4, sp, 40	// tmp119,,
	ldr	x3, [sp, 4144]	//, env_path
	adrp	x0, .LC8	// tmp120,
	add	x2, x0, :lo12:.LC8	//, tmp120,
	mov	x1, 4096	//,
	mov	x0, x4	//, tmp119
	bl	snprintf		//
	b	.L84		//
.L83:
// Development/CritterProduct/Pilot/IO/critter_io.c:316:         if (critter_resolve_runtime_data_path(path, sizeof(path)) != 0)
	add	x0, sp, 40	// tmp121,,
	mov	x1, 4096	//,
	bl	critter_resolve_runtime_data_path		//
// Development/CritterProduct/Pilot/IO/critter_io.c:316:         if (critter_resolve_runtime_data_path(path, sizeof(path)) != 0)
	cmp	w0, 0	// _2,
	beq	.L85		//,
// Development/CritterProduct/Pilot/IO/critter_io.c:317:             return -1;
	mov	w0, -1	// _15,
	b	.L93		//
.L85:
// Development/CritterProduct/Pilot/IO/critter_io.c:318:         if (critter_ensure_runtime_data_directory() != 0)
	bl	critter_ensure_runtime_data_directory		//
// Development/CritterProduct/Pilot/IO/critter_io.c:318:         if (critter_ensure_runtime_data_directory() != 0)
	cmp	w0, 0	// _3,
	beq	.L84		//,
// Development/CritterProduct/Pilot/IO/critter_io.c:319:             return -1;
	mov	w0, -1	// _15,
	b	.L93		//
.L84:
// Development/CritterProduct/Pilot/IO/critter_io.c:322:     file = fopen(path, "a");
	add	x2, sp, 40	// tmp122,,
	adrp	x0, .LC11	// tmp123,
	add	x1, x0, :lo12:.LC11	//, tmp123,
	mov	x0, x2	//, tmp122
	bl	fopen		//
	str	x0, [sp, 4136]	// tmp124, file
// Development/CritterProduct/Pilot/IO/critter_io.c:323:     if (file == NULL)
	ldr	x0, [sp, 4136]	// tmp125, file
	cmp	x0, 0	// tmp125,
	bne	.L86		//,
// Development/CritterProduct/Pilot/IO/critter_io.c:324:         return -1;
	mov	w0, -1	// _15,
	b	.L93		//
.L86:
// Development/CritterProduct/Pilot/IO/critter_io.c:326:     if (ftell(file) == 0L)
	ldr	x0, [sp, 4136]	//, file
	bl	ftell		//
// Development/CritterProduct/Pilot/IO/critter_io.c:326:     if (ftell(file) == 0L)
	cmp	x0, 0	// _4,
	bne	.L87		//,
// Development/CritterProduct/Pilot/IO/critter_io.c:328:         fprintf(file,
	ldr	x3, [sp, 4136]	//, file
	mov	x2, 89	//,
	mov	x1, 1	//,
	adrp	x0, .LC12	// tmp126,
	add	x0, x0, :lo12:.LC12	//, tmp126,
	bl	fwrite		//
.L87:
// Development/CritterProduct/Pilot/IO/critter_io.c:332:     switch (sample->source)
	ldr	x0, [sp, 24]	// tmp127, sample
	ldr	w0, [x0, 32]	// _5, sample_22(D)->source
// Development/CritterProduct/Pilot/IO/critter_io.c:332:     switch (sample->source)
	cmp	w0, 3	// _5,
	beq	.L88		//,
	cmp	w0, 3	// _5,
	bhi	.L89		//,
	cmp	w0, 1	// _5,
	beq	.L90		//,
	cmp	w0, 2	// _5,
	beq	.L91		//,
	b	.L89		//
.L90:
// Development/CritterProduct/Pilot/IO/critter_io.c:335:             source_name = "sense_hat";
	adrp	x0, .LC13	// tmp129,
	add	x0, x0, :lo12:.LC13	// tmp128, tmp129,
	str	x0, [sp, 4152]	// tmp128, source_name
// Development/CritterProduct/Pilot/IO/critter_io.c:336:             break;
	b	.L92		//
.L91:
// Development/CritterProduct/Pilot/IO/critter_io.c:338:             source_name = "data";
	adrp	x0, .LC14	// tmp131,
	add	x0, x0, :lo12:.LC14	// tmp130, tmp131,
	str	x0, [sp, 4152]	// tmp130, source_name
// Development/CritterProduct/Pilot/IO/critter_io.c:339:             break;
	b	.L92		//
.L88:
// Development/CritterProduct/Pilot/IO/critter_io.c:341:             source_name = "cpu";
	adrp	x0, .LC15	// tmp133,
	add	x0, x0, :lo12:.LC15	// tmp132, tmp133,
	str	x0, [sp, 4152]	// tmp132, source_name
// Development/CritterProduct/Pilot/IO/critter_io.c:342:             break;
	b	.L92		//
.L89:
// Development/CritterProduct/Pilot/IO/critter_io.c:344:             source_name = "unknown";
	adrp	x0, .LC16	// tmp135,
	add	x0, x0, :lo12:.LC16	// tmp134, tmp135,
	str	x0, [sp, 4152]	// tmp134, source_name
// Development/CritterProduct/Pilot/IO/critter_io.c:345:             break;
	nop	
.L92:
// Development/CritterProduct/Pilot/IO/critter_io.c:350:             sample->timestamp_s,
	ldr	x0, [sp, 24]	// tmp136, sample
	ldr	d31, [x0]	// _6, sample_22(D)->timestamp_s
// Development/CritterProduct/Pilot/IO/critter_io.c:351:             sample->temperature_c,
	ldr	x0, [sp, 24]	// tmp137, sample
	ldr	d30, [x0, 8]	// _7, sample_22(D)->temperature_c
// Development/CritterProduct/Pilot/IO/critter_io.c:352:             sample->humidity_percent,
	ldr	x0, [sp, 24]	// tmp138, sample
	ldr	d29, [x0, 16]	// _8, sample_22(D)->humidity_percent
// Development/CritterProduct/Pilot/IO/critter_io.c:353:             sample->pressure_hpa,
	ldr	x0, [sp, 24]	// tmp139, sample
	ldr	d28, [x0, 24]	// _9, sample_22(D)->pressure_hpa
// Development/CritterProduct/Pilot/IO/critter_io.c:355:             sample->has_humidity ? 1 : 0,
	ldr	x0, [sp, 24]	// tmp140, sample
	ldrb	w0, [x0, 36]	// _10, sample_22(D)->has_humidity
// Development/CritterProduct/Pilot/IO/critter_io.c:348:     fprintf(file,
	mov	w1, w0	// _11, _10
// Development/CritterProduct/Pilot/IO/critter_io.c:356:             sample->has_pressure ? 1 : 0);
	ldr	x0, [sp, 24]	// tmp141, sample
	ldrb	w0, [x0, 37]	// _12, sample_22(D)->has_pressure
// Development/CritterProduct/Pilot/IO/critter_io.c:348:     fprintf(file,
	mov	w4, w0	//, _13
	mov	w3, w1	//, _11
	ldr	x2, [sp, 4152]	//, source_name
	fmov	d3, d28	//, _9
	fmov	d2, d29	//, _8
	fmov	d1, d30	//, _7
	fmov	d0, d31	//, _6
	adrp	x0, .LC17	// tmp142,
	add	x1, x0, :lo12:.LC17	//, tmp142,
	ldr	x0, [sp, 4136]	//, file
	bl	fprintf		//
// Development/CritterProduct/Pilot/IO/critter_io.c:358:     fclose(file);
	ldr	x0, [sp, 4136]	//, file
	bl	fclose		//
// Development/CritterProduct/Pilot/IO/critter_io.c:359:     return 0;
	mov	w0, 0	// _15,
.L93:
// Development/CritterProduct/Pilot/IO/critter_io.c:360: }
	ldp	x29, x30, [sp]	//,,
	mov	x12, 4160	//,
	add	sp, sp, x12	//,,
	.cfi_restore 29
	.cfi_restore 30
	.cfi_def_cfa_offset 0
	ret	
	.cfi_endproc
.LFE10:
	.size	critter_io_save_sample, .-critter_io_save_sample
	.section	.rodata
	.align	3
.LC18:
	.string	"CRITTER_METRICS_FILE"
	.align	3
.LC19:
	.string	"collection_metrics.csv"
	.align	3
.LC20:
	.ascii	"timestamp_s,reads_attempted,valid_samples,rejected_samples,o"
	.ascii	"utlier_count,sample_rate_hz,retained_ratio,s"
	.string	"ummary_count,min_temperature_c,max_temperature_c,mean_temperature_c,median_temperature_c,stddev_temperature_c,source,current_temperature_c,predicted_temperature_c,trend_c_per_s,rate_of_change_c_per_s,likely_hvac_active,likely_heating,likely_cooling,stable\n"
	.align	3
.LC21:
	.string	"%.6f,%zu,%zu,%zu,%zu,%.6f,%.6f,%zu,%.6f,%.6f,%.6f,%.6f,%.6f,%s,%.6f,%.6f,%.6f,%.6f,%d,%d,%d,%d\n"
	.text
	.align	2
	.global	critter_io_save_metrics
	.type	critter_io_save_metrics, %function
critter_io_save_metrics:
.LFB11:
	.cfi_startproc
	mov	x12, 4288	//,
	sub	sp, sp, x12	//,,
	.cfi_def_cfa_offset 4288
	stp	x29, x30, [sp, 64]	//,,
	.cfi_offset 29, -4224
	.cfi_offset 30, -4216
	add	x29, sp, 64	//,,
	str	x19, [sp, 80]	//,
	.cfi_offset 19, -4208
	str	x0, [sp, 152]	// summary, summary
	str	x1, [sp, 144]	// analysis, analysis
	str	x2, [sp, 136]	// reads_attempted, reads_attempted
	str	x3, [sp, 128]	// valid_samples, valid_samples
	str	x4, [sp, 120]	// rejected_samples, rejected_samples
	str	x5, [sp, 112]	// outlier_count, outlier_count
	str	d0, [sp, 104]	// sample_rate_hz, sample_rate_hz
// Development/CritterProduct/Pilot/IO/critter_io.c:370:     const char *env_path = getenv("CRITTER_METRICS_FILE");
	adrp	x0, .LC18	// tmp133,
	add	x0, x0, :lo12:.LC18	//, tmp133,
	bl	getenv		//
	str	x0, [sp, 4272]	//, env_path
// Development/CritterProduct/Pilot/IO/critter_io.c:375:     if (summary == NULL || analysis == NULL)
	ldr	x0, [sp, 152]	// tmp134, summary
	cmp	x0, 0	// tmp134,
	beq	.L95		//,
// Development/CritterProduct/Pilot/IO/critter_io.c:375:     if (summary == NULL || analysis == NULL)
	ldr	x0, [sp, 144]	// tmp135, analysis
	cmp	x0, 0	// tmp135,
	bne	.L96		//,
.L95:
// Development/CritterProduct/Pilot/IO/critter_io.c:376:         return -1;
	mov	w0, -1	// _33,
	b	.L110		//
.L96:
// Development/CritterProduct/Pilot/IO/critter_io.c:378:     if (env_path != NULL && env_path[0] != '\0')
	ldr	x0, [sp, 4272]	// tmp136, env_path
	cmp	x0, 0	// tmp136,
	beq	.L98		//,
// Development/CritterProduct/Pilot/IO/critter_io.c:378:     if (env_path != NULL && env_path[0] != '\0')
	ldr	x0, [sp, 4272]	// tmp137, env_path
	ldrb	w0, [x0]	// _1, *env_path_40
// Development/CritterProduct/Pilot/IO/critter_io.c:378:     if (env_path != NULL && env_path[0] != '\0')
	cmp	w0, 0	// _1,
	beq	.L98		//,
// Development/CritterProduct/Pilot/IO/critter_io.c:380:         snprintf(path, sizeof(path), "%s", env_path);
	add	x4, sp, 160	// tmp138,,
	ldr	x3, [sp, 4272]	//, env_path
	adrp	x0, .LC8	// tmp139,
	add	x2, x0, :lo12:.LC8	//, tmp139,
	mov	x1, 4096	//,
	mov	x0, x4	//, tmp138
	bl	snprintf		//
	b	.L99		//
.L98:
// Development/CritterProduct/Pilot/IO/critter_io.c:384:         if (critter_resolve_runtime_data_path(path, sizeof(path)) != 0)
	add	x0, sp, 160	// tmp140,,
	mov	x1, 4096	//,
	bl	critter_resolve_runtime_data_path		//
// Development/CritterProduct/Pilot/IO/critter_io.c:384:         if (critter_resolve_runtime_data_path(path, sizeof(path)) != 0)
	cmp	w0, 0	// _2,
	beq	.L100		//,
// Development/CritterProduct/Pilot/IO/critter_io.c:385:             return -1;
	mov	w0, -1	// _33,
	b	.L110		//
.L100:
// Development/CritterProduct/Pilot/IO/critter_io.c:386:         if (critter_ensure_runtime_data_directory() != 0)
	bl	critter_ensure_runtime_data_directory		//
// Development/CritterProduct/Pilot/IO/critter_io.c:386:         if (critter_ensure_runtime_data_directory() != 0)
	cmp	w0, 0	// _3,
	beq	.L101		//,
// Development/CritterProduct/Pilot/IO/critter_io.c:387:             return -1;
	mov	w0, -1	// _33,
	b	.L110		//
.L101:
// Development/CritterProduct/Pilot/IO/critter_io.c:389:         if (strrchr(path, '/') != NULL)
	add	x0, sp, 160	// tmp141,,
	mov	w1, 47	//,
	bl	strrchr		//
// Development/CritterProduct/Pilot/IO/critter_io.c:389:         if (strrchr(path, '/') != NULL)
	cmp	x0, 0	// _4,
	beq	.L102		//,
// Development/CritterProduct/Pilot/IO/critter_io.c:391:             char *last_slash = strrchr(path, '/');
	add	x0, sp, 160	// tmp142,,
	mov	w1, 47	//,
	bl	strrchr		//
	str	x0, [sp, 4264]	//, last_slash
// Development/CritterProduct/Pilot/IO/critter_io.c:392:             if (last_slash != NULL)
	ldr	x0, [sp, 4264]	// tmp143, last_slash
	cmp	x0, 0	// tmp143,
	beq	.L102		//,
// Development/CritterProduct/Pilot/IO/critter_io.c:394:                 *(last_slash + 1) = '\0';
	ldr	x0, [sp, 4264]	// tmp144, last_slash
	add	x0, x0, 1	// _5, tmp144,
// Development/CritterProduct/Pilot/IO/critter_io.c:394:                 *(last_slash + 1) = '\0';
	strb	wzr, [x0]	//, *_5
.L102:
// Development/CritterProduct/Pilot/IO/critter_io.c:397:         snprintf(path + strlen(path), sizeof(path) - strlen(path), "collection_metrics.csv");
	add	x0, sp, 160	// tmp145,,
	bl	strlen		//
	mov	x1, x0	// _6,
// Development/CritterProduct/Pilot/IO/critter_io.c:397:         snprintf(path + strlen(path), sizeof(path) - strlen(path), "collection_metrics.csv");
	add	x0, sp, 160	// tmp146,,
	add	x19, x0, x1	// _7, tmp146, _6
// Development/CritterProduct/Pilot/IO/critter_io.c:397:         snprintf(path + strlen(path), sizeof(path) - strlen(path), "collection_metrics.csv");
	add	x0, sp, 160	// tmp147,,
	bl	strlen		//
	mov	x1, x0	// _8,
// Development/CritterProduct/Pilot/IO/critter_io.c:397:         snprintf(path + strlen(path), sizeof(path) - strlen(path), "collection_metrics.csv");
	mov	x0, 4096	// tmp148,
	sub	x1, x0, x1	// _9, tmp148, _8
	adrp	x0, .LC19	// tmp149,
	add	x2, x0, :lo12:.LC19	//, tmp149,
	mov	x0, x19	//, _7
	bl	snprintf		//
.L99:
// Development/CritterProduct/Pilot/IO/critter_io.c:400:     file = fopen(path, "a");
	add	x2, sp, 160	// tmp150,,
	adrp	x0, .LC11	// tmp151,
	add	x1, x0, :lo12:.LC11	//, tmp151,
	mov	x0, x2	//, tmp150
	bl	fopen		//
	str	x0, [sp, 4256]	// tmp152, file
// Development/CritterProduct/Pilot/IO/critter_io.c:401:     if (file == NULL)
	ldr	x0, [sp, 4256]	// tmp153, file
	cmp	x0, 0	// tmp153,
	bne	.L103		//,
// Development/CritterProduct/Pilot/IO/critter_io.c:402:         return -1;
	mov	w0, -1	// _33,
	b	.L110		//
.L103:
// Development/CritterProduct/Pilot/IO/critter_io.c:404:     if (ftell(file) == 0L)
	ldr	x0, [sp, 4256]	//, file
	bl	ftell		//
// Development/CritterProduct/Pilot/IO/critter_io.c:404:     if (ftell(file) == 0L)
	cmp	x0, 0	// _10,
	bne	.L104		//,
// Development/CritterProduct/Pilot/IO/critter_io.c:406:         fprintf(file,
	ldr	x3, [sp, 4256]	//, file
	mov	x2, 360	//,
	mov	x1, 1	//,
	adrp	x0, .LC20	// tmp154,
	add	x0, x0, :lo12:.LC20	//, tmp154,
	bl	fwrite		//
.L104:
// Development/CritterProduct/Pilot/IO/critter_io.c:410:     switch (summary->source)
	ldr	x0, [sp, 152]	// tmp155, summary
	ldr	w0, [x0, 120]	// _11, summary_41(D)->source
// Development/CritterProduct/Pilot/IO/critter_io.c:410:     switch (summary->source)
	cmp	w0, 3	// _11,
	beq	.L105		//,
	cmp	w0, 3	// _11,
	bhi	.L106		//,
	cmp	w0, 1	// _11,
	beq	.L107		//,
	cmp	w0, 2	// _11,
	beq	.L108		//,
	b	.L106		//
.L107:
// Development/CritterProduct/Pilot/IO/critter_io.c:413:             source_name = "sense_hat";
	adrp	x0, .LC13	// tmp157,
	add	x0, x0, :lo12:.LC13	// tmp156, tmp157,
	str	x0, [sp, 4280]	// tmp156, source_name
// Development/CritterProduct/Pilot/IO/critter_io.c:414:             break;
	b	.L109		//
.L108:
// Development/CritterProduct/Pilot/IO/critter_io.c:416:             source_name = "data";
	adrp	x0, .LC14	// tmp159,
	add	x0, x0, :lo12:.LC14	// tmp158, tmp159,
	str	x0, [sp, 4280]	// tmp158, source_name
// Development/CritterProduct/Pilot/IO/critter_io.c:417:             break;
	b	.L109		//
.L105:
// Development/CritterProduct/Pilot/IO/critter_io.c:419:             source_name = "cpu";
	adrp	x0, .LC15	// tmp161,
	add	x0, x0, :lo12:.LC15	// tmp160, tmp161,
	str	x0, [sp, 4280]	// tmp160, source_name
// Development/CritterProduct/Pilot/IO/critter_io.c:420:             break;
	b	.L109		//
.L106:
// Development/CritterProduct/Pilot/IO/critter_io.c:422:             source_name = "unknown";
	adrp	x0, .LC16	// tmp163,
	add	x0, x0, :lo12:.LC16	// tmp162, tmp163,
	str	x0, [sp, 4280]	// tmp162, source_name
// Development/CritterProduct/Pilot/IO/critter_io.c:423:             break;
	nop	
.L109:
// Development/CritterProduct/Pilot/IO/critter_io.c:428:             analysis->analysis_timestamp_s,
	ldr	x0, [sp, 144]	// tmp164, analysis
	ldr	d31, [x0, 40]	// _12, analysis_42(D)->analysis_timestamp_s
// Development/CritterProduct/Pilot/IO/critter_io.c:434:             summary->retained_ratio,
	ldr	x0, [sp, 152]	// tmp165, summary
	ldr	d30, [x0, 112]	// _13, summary_41(D)->retained_ratio
// Development/CritterProduct/Pilot/IO/critter_io.c:435:             summary->sample_count,
	ldr	x0, [sp, 152]	// tmp166, summary
	ldr	x1, [x0]	// _14, summary_41(D)->sample_count
// Development/CritterProduct/Pilot/IO/critter_io.c:436:             summary->min_temperature_c,
	ldr	x0, [sp, 152]	// tmp167, summary
	ldr	d29, [x0, 56]	// _15, summary_41(D)->min_temperature_c
// Development/CritterProduct/Pilot/IO/critter_io.c:437:             summary->max_temperature_c,
	ldr	x0, [sp, 152]	// tmp168, summary
	ldr	d28, [x0, 64]	// _16, summary_41(D)->max_temperature_c
// Development/CritterProduct/Pilot/IO/critter_io.c:438:             summary->mean_temperature_c,
	ldr	x0, [sp, 152]	// tmp169, summary
	ldr	d27, [x0, 72]	// _17, summary_41(D)->mean_temperature_c
// Development/CritterProduct/Pilot/IO/critter_io.c:439:             summary->median_temperature_c,
	ldr	x0, [sp, 152]	// tmp170, summary
	ldr	d26, [x0, 80]	// _18, summary_41(D)->median_temperature_c
// Development/CritterProduct/Pilot/IO/critter_io.c:440:             summary->stddev_temperature_c,
	ldr	x0, [sp, 152]	// tmp171, summary
	ldr	d25, [x0, 88]	// _19, summary_41(D)->stddev_temperature_c
// Development/CritterProduct/Pilot/IO/critter_io.c:442:             analysis->current_temperature_c,
	ldr	x0, [sp, 144]	// tmp172, analysis
	ldr	d24, [x0]	// _20, analysis_42(D)->current_temperature_c
// Development/CritterProduct/Pilot/IO/critter_io.c:443:             analysis->predicted_temperature_c,
	ldr	x0, [sp, 144]	// tmp173, analysis
	ldr	d23, [x0, 24]	// _21, analysis_42(D)->predicted_temperature_c
// Development/CritterProduct/Pilot/IO/critter_io.c:444:             analysis->trend_c_per_s,
	ldr	x0, [sp, 144]	// tmp174, analysis
	ldr	d22, [x0, 8]	// _22, analysis_42(D)->trend_c_per_s
// Development/CritterProduct/Pilot/IO/critter_io.c:445:             analysis->rate_of_change_c_per_s,
	ldr	x0, [sp, 144]	// tmp175, analysis
	ldr	d21, [x0, 16]	// _23, analysis_42(D)->rate_of_change_c_per_s
// Development/CritterProduct/Pilot/IO/critter_io.c:446:             analysis->likely_hvac_active ? 1 : 0,
	ldr	x0, [sp, 144]	// tmp176, analysis
	ldrb	w0, [x0, 83]	// _24, analysis_42(D)->likely_hvac_active
// Development/CritterProduct/Pilot/IO/critter_io.c:426:     fprintf(file,
	mov	w2, w0	// _25, _24
// Development/CritterProduct/Pilot/IO/critter_io.c:447:             analysis->likely_heating ? 1 : 0,
	ldr	x0, [sp, 144]	// tmp177, analysis
	ldrb	w0, [x0, 85]	// _26, analysis_42(D)->likely_heating
// Development/CritterProduct/Pilot/IO/critter_io.c:426:     fprintf(file,
	mov	w3, w0	// _27, _26
// Development/CritterProduct/Pilot/IO/critter_io.c:448:             analysis->likely_cooling ? 1 : 0,
	ldr	x0, [sp, 144]	// tmp178, analysis
	ldrb	w0, [x0, 84]	// _28, analysis_42(D)->likely_cooling
// Development/CritterProduct/Pilot/IO/critter_io.c:426:     fprintf(file,
	mov	w4, w0	// _29, _28
// Development/CritterProduct/Pilot/IO/critter_io.c:449:             analysis->stable ? 1 : 0);
	ldr	x0, [sp, 144]	// tmp179, analysis
	ldrb	w0, [x0, 80]	// _30, analysis_42(D)->stable
// Development/CritterProduct/Pilot/IO/critter_io.c:426:     fprintf(file,
	str	w0, [sp, 56]	// _31,
	str	w4, [sp, 48]	// _29,
	str	w3, [sp, 40]	// _27,
	str	w2, [sp, 32]	// _25,
	str	d21, [sp, 24]	// _23,
	str	d22, [sp, 16]	// _22,
	str	d23, [sp, 8]	// _21,
	str	d24, [sp]	// _20,
	ldr	x7, [sp, 4280]	//, source_name
	fmov	d7, d25	//, _19
	fmov	d6, d26	//, _18
	fmov	d5, d27	//, _17
	fmov	d4, d28	//, _16
	fmov	d3, d29	//, _15
	mov	x6, x1	//, _14
	fmov	d2, d30	//, _13
	ldr	d1, [sp, 104]	//, sample_rate_hz
	ldr	x5, [sp, 112]	//, outlier_count
	ldr	x4, [sp, 120]	//, rejected_samples
	ldr	x3, [sp, 128]	//, valid_samples
	ldr	x2, [sp, 136]	//, reads_attempted
	fmov	d0, d31	//, _12
	adrp	x0, .LC21	// tmp180,
	add	x1, x0, :lo12:.LC21	//, tmp180,
	ldr	x0, [sp, 4256]	//, file
	bl	fprintf		//
// Development/CritterProduct/Pilot/IO/critter_io.c:451:     fclose(file);
	ldr	x0, [sp, 4256]	//, file
	bl	fclose		//
// Development/CritterProduct/Pilot/IO/critter_io.c:452:     return 0;
	mov	w0, 0	// _33,
.L110:
// Development/CritterProduct/Pilot/IO/critter_io.c:453: }
	ldp	x29, x30, [sp, 64]	//,,
	ldr	x19, [sp, 80]	//,
	mov	x12, 4288	//,
	add	sp, sp, x12	//,,
	.cfi_restore 19
	.cfi_restore 29
	.cfi_restore 30
	.cfi_def_cfa_offset 0
	ret	
	.cfi_endproc
.LFE11:
	.size	critter_io_save_metrics, .-critter_io_save_metrics
	.local	initialized.3
	.comm	initialized.3,1,1
	.local	sensor.2
	.comm	sensor.2,64,8
	.local	initialized.1
	.comm	initialized.1,1,1
	.data
	.align	3
	.type	last_value.0, %object
	.size	last_value.0, 8
last_value.0:
	.word	0
	.word	1077149696
	.ident	"GCC: (Debian 14.2.0-19) 14.2.0"
	.section	.note.GNU-stack,"",@progbits
