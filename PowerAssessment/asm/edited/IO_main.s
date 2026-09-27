	.arch armv8-a
	.file	"IO_main.c"
// GNU C11 (Debian 14.2.0-19) version 14.2.0 (aarch64-linux-gnu)
//	compiled by GNU C version 14.2.0, GMP version 6.3.0, MPFR version 4.2.1, MPC version 1.3.1, isl version isl-0.27-GMP

// warning: MPFR header version 4.2.1 differs from library version 4.2.2.
// GGC heuristics: --param ggc-min-expand=100 --param ggc-min-heapsize=131072
// options passed: -mlittle-endian -mabi=lp64 -O0 -std=c11 -fasynchronous-unwind-tables
	.text
	.section	.rodata
	.align	3
.LC0:
	.string	"failed to start one-minute collection window\n"
	.align	3
.LC1:
	.string	"failed to read sample during one-minute collection\n"
	.align	3
.LC2:
	.string	"failed to save sample during one-minute collection\n"
	.align	3
.LC3:
	.string	"failed to read time during one-minute collection\n"
	.align	3
.LC4:
	.string	"\rCollecting: %02d:%02d / 01:00"
	.align	3
.LC5:
	.string	"\nsample delay interrupted\n"
	.align	3
.LC6:
	.string	"\rCollecting: 01:00 / 01:00"
	.align	3
.LC7:
	.string	"io: reads=%zu rate=%.2fHz sense_hat=%zu data=%zu cpu=%zu\n"
	.text
	.align	2
	.global	main
	.type	main, %function
main:
.LFB0:
	.cfi_startproc
	stp	x29, x30, [sp, -208]!	//,,,
	.cfi_def_cfa_offset 208
	.cfi_offset 29, -208
	.cfi_offset 30, -200
	mov	x29, sp	//,
// PowerAssessment/IO/IO_main.c:12:     const double collection_window_s = 60.0;
	mov	x0, 4633641066610819072	// tmp235,
	fmov	d31, x0	// tmp149, tmp235
	str	d31, [sp, 176]	// tmp149, collection_window_s
// PowerAssessment/IO/IO_main.c:13:     const double sample_interval_s = 0.1;
	adrp	x0, .LC8	// tmp237,
	ldr	d31, [x0, #:lo12:.LC8]	// tmp150,
	str	d31, [sp, 168]	// tmp150, sample_interval_s
// PowerAssessment/IO/IO_main.c:14:     const double report_interval_s = 5.0;
	fmov	d31, 5.0e+0	// tmp151,
	str	d31, [sp, 160]	// tmp151, report_interval_s
// PowerAssessment/IO/IO_main.c:19:     double elapsed_s = 0.0;
	str	xzr, [sp, 200]	//, elapsed_s
// PowerAssessment/IO/IO_main.c:20:     double last_report_s = 0.0;
	str	xzr, [sp, 192]	//, last_report_s
// PowerAssessment/IO/IO_main.c:21:     size_t total_read_attempts = 0U;
	str	xzr, [sp, 184]	//, total_read_attempts
// PowerAssessment/IO/IO_main.c:22:     size_t source_counts[4] = {0};
	add	x0, sp, 80	// tmp153,,
	adrp	x1, .LC9	// tmp238,
	add	x1, x1, :lo12:.LC9	// tmp238, tmp238,
	ld1	{v30.16b - v31.16b}, [x1]	// tmp154,
	st1	{v30.16b - v31.16b}, [x0]	// tmp154, source_counts
// PowerAssessment/IO/IO_main.c:24:     if (clock_gettime(CLOCK_MONOTONIC, &start_ts) != 0)
	add	x0, sp, 128	// tmp155,,
	mov	x1, x0	//, tmp155
	mov	w0, 1	//,
	bl	clock_gettime		//
// PowerAssessment/IO/IO_main.c:24:     if (clock_gettime(CLOCK_MONOTONIC, &start_ts) != 0)
	cmp	w0, 0	// _1,
	beq	.L4		//,
// PowerAssessment/IO/IO_main.c:26:         fprintf(stderr, "failed to start one-minute collection window\n");
	adrp	x0, :got:stderr;ldr	x0, [x0, :got_lo12:stderr]	// tmp156,
	ldr	x0, [x0]	// stderr.0_2, stderr
	mov	x3, x0	//, stderr.0_2
	mov	x2, 45	//,
	mov	x1, 1	//,
	adrp	x0, .LC0	// tmp157,
	add	x0, x0, :lo12:.LC0	//, tmp157,
	bl	fwrite		//
// PowerAssessment/IO/IO_main.c:27:         return 1;
	mov	w0, 1	// _52,
	b	.L16		//
.L15:
// PowerAssessment/IO/IO_main.c:34:         total_read_attempts += 1U;
	ldr	x0, [sp, 184]	// tmp159, total_read_attempts
	add	x0, x0, 1	// total_read_attempts_71, tmp159,
	str	x0, [sp, 184]	// total_read_attempts_71, total_read_attempts
// PowerAssessment/IO/IO_main.c:36:         if (critter_io_read_sample(&sample) != 0)
	add	x0, sp, 24	// tmp160,,
	bl	critter_io_read_sample		//
// PowerAssessment/IO/IO_main.c:36:         if (critter_io_read_sample(&sample) != 0)
	cmp	w0, 0	// _3,
	beq	.L5		//,
// PowerAssessment/IO/IO_main.c:38:             fprintf(stderr, "failed to read sample during one-minute collection\n");
	adrp	x0, :got:stderr;ldr	x0, [x0, :got_lo12:stderr]	// tmp161,
	ldr	x0, [x0]	// stderr.1_4, stderr
	mov	x3, x0	//, stderr.1_4
	mov	x2, 51	//,
	mov	x1, 1	//,
	adrp	x0, .LC1	// tmp162,
	add	x0, x0, :lo12:.LC1	//, tmp162,
	bl	fwrite		//
// PowerAssessment/IO/IO_main.c:39:             return 1;
	mov	w0, 1	// _52,
	b	.L16		//
.L5:
// PowerAssessment/IO/IO_main.c:42:         source_counts[sample.source] += 1U;
	ldr	w1, [sp, 56]	// _5, sample.source
// PowerAssessment/IO/IO_main.c:42:         source_counts[sample.source] += 1U;
	add	x0, sp, 80	// tmp164,,
	uxtw	x1, w1	// tmp165, _5
	ldr	x0, [x0, x1, lsl 3]	// _6, source_counts[_5]
// PowerAssessment/IO/IO_main.c:42:         source_counts[sample.source] += 1U;
	ldr	w1, [sp, 56]	// _7, sample.source
// PowerAssessment/IO/IO_main.c:42:         source_counts[sample.source] += 1U;
	add	x2, x0, 1	// _8, _6,
	add	x0, sp, 80	// tmp167,,
	uxtw	x1, w1	// tmp168, _7
	str	x2, [x0, x1, lsl 3]	// _8, source_counts[_7]
// PowerAssessment/IO/IO_main.c:44:         if (critter_io_save_sample(&sample) != 0)
	add	x0, sp, 24	// tmp169,,
	bl	critter_io_save_sample		//
// PowerAssessment/IO/IO_main.c:44:         if (critter_io_save_sample(&sample) != 0)
	cmp	w0, 0	// _9,
	beq	.L7		//,
// PowerAssessment/IO/IO_main.c:46:             fprintf(stderr, "failed to save sample during one-minute collection\n");
	adrp	x0, :got:stderr;ldr	x0, [x0, :got_lo12:stderr]	// tmp170,
	ldr	x0, [x0]	// stderr.2_10, stderr
	mov	x3, x0	//, stderr.2_10
	mov	x2, 51	//,
	mov	x1, 1	//,
	adrp	x0, .LC2	// tmp171,
	add	x0, x0, :lo12:.LC2	//, tmp171,
	bl	fwrite		//
// PowerAssessment/IO/IO_main.c:47:             return 1;
	mov	w0, 1	// _52,
	b	.L16		//
.L7:
// PowerAssessment/IO/IO_main.c:50:         if (clock_gettime(CLOCK_MONOTONIC, &now_ts) != 0)
	add	x0, sp, 112	// tmp172,,
	mov	x1, x0	//, tmp172
	mov	w0, 1	//,
	bl	clock_gettime		//
// PowerAssessment/IO/IO_main.c:50:         if (clock_gettime(CLOCK_MONOTONIC, &now_ts) != 0)
	cmp	w0, 0	// _11,
	beq	.L8		//,
// PowerAssessment/IO/IO_main.c:52:             fprintf(stderr, "failed to read time during one-minute collection\n");
	adrp	x0, :got:stderr;ldr	x0, [x0, :got_lo12:stderr]	// tmp173,
	ldr	x0, [x0]	// stderr.3_12, stderr
	mov	x3, x0	//, stderr.3_12
	mov	x2, 49	//,
	mov	x1, 1	//,
	adrp	x0, .LC3	// tmp174,
	add	x0, x0, :lo12:.LC3	//, tmp174,
	bl	fwrite		//
// PowerAssessment/IO/IO_main.c:53:             return 1;
	mov	w0, 1	// _52,
	b	.L16		//
.L8:
// PowerAssessment/IO/IO_main.c:56:         elapsed_s = (double)(now_ts.tv_sec - start_ts.tv_sec)
	ldr	x1, [sp, 112]	// _13, now_ts.tv_sec
// PowerAssessment/IO/IO_main.c:56:         elapsed_s = (double)(now_ts.tv_sec - start_ts.tv_sec)
	ldr	x0, [sp, 128]	// _14, start_ts.tv_sec
// PowerAssessment/IO/IO_main.c:56:         elapsed_s = (double)(now_ts.tv_sec - start_ts.tv_sec)
	sub	x0, x1, x0	// _15, _13, _14
	fmov	d31, x0	// _15, _15
// PowerAssessment/IO/IO_main.c:56:         elapsed_s = (double)(now_ts.tv_sec - start_ts.tv_sec)
	scvtf	d30, d31	// _16, _15
// PowerAssessment/IO/IO_main.c:57:                   + (double)(now_ts.tv_nsec - start_ts.tv_nsec) / 1000000000.0;
	ldr	x1, [sp, 120]	// _17, now_ts.tv_nsec
// PowerAssessment/IO/IO_main.c:57:                   + (double)(now_ts.tv_nsec - start_ts.tv_nsec) / 1000000000.0;
	ldr	x0, [sp, 136]	// _18, start_ts.tv_nsec
// PowerAssessment/IO/IO_main.c:57:                   + (double)(now_ts.tv_nsec - start_ts.tv_nsec) / 1000000000.0;
	sub	x0, x1, x0	// _19, _17, _18
	fmov	d31, x0	// _19, _19
// PowerAssessment/IO/IO_main.c:57:                   + (double)(now_ts.tv_nsec - start_ts.tv_nsec) / 1000000000.0;
	scvtf	d31, d31	// _20, _19
// PowerAssessment/IO/IO_main.c:57:                   + (double)(now_ts.tv_nsec - start_ts.tv_nsec) / 1000000000.0;
	mov	x0, 225833675390976	// tmp234,
	movk	x0, 0x41cd, lsl 48	// tmp234,,
	fmov	d29, x0	// tmp175, tmp234
	fdiv	d31, d31, d29	// _21, _20, tmp175
// PowerAssessment/IO/IO_main.c:56:         elapsed_s = (double)(now_ts.tv_sec - start_ts.tv_sec)
	fadd	d31, d30, d31	// elapsed_s_76, _16, _21
	str	d31, [sp, 200]	// elapsed_s_76, elapsed_s
// PowerAssessment/IO/IO_main.c:59:         if (elapsed_s >= last_report_s + report_interval_s)
	ldr	d30, [sp, 192]	// tmp177, last_report_s
	ldr	d31, [sp, 160]	// tmp178, report_interval_s
	fadd	d31, d30, d31	// _22, tmp177, tmp178
// PowerAssessment/IO/IO_main.c:59:         if (elapsed_s >= last_report_s + report_interval_s)
	ldr	d30, [sp, 200]	// tmp179, elapsed_s
	fcmpe	d30, d31	// tmp179, _22
	bge	.L17		//,
	b	.L9		//
.L17:
// PowerAssessment/IO/IO_main.c:61:             int elapsed_seconds = (int)elapsed_s;
	ldr	d31, [sp, 200]	// tmp181, elapsed_s
	fcvtzs	w0, d31	// tmp180, tmp181
	str	w0, [sp, 156]	// tmp180, elapsed_seconds
// PowerAssessment/IO/IO_main.c:62:             int minutes = elapsed_seconds / 60;
	ldr	w0, [sp, 156]	// tmp183, elapsed_seconds
	mov	w1, 34953	// tmp185,
	movk	w1, 0x8888, lsl 16	// tmp185,,
	smull	x1, w0, w1	// tmp184, tmp183, tmp185
	lsr	x1, x1, 32	// tmp186, tmp184,
	add	w1, w0, w1	// tmp187, tmp183, tmp188
	asr	w1, w1, 5	// tmp189, tmp187,
	asr	w0, w0, 31	// tmp190, tmp183,
	sub	w0, w1, w0	// minutes_78, tmp189, tmp190
	str	w0, [sp, 152]	// minutes_78, minutes
// PowerAssessment/IO/IO_main.c:63:             int seconds = elapsed_seconds % 60;
	ldr	w0, [sp, 156]	// tmp192, elapsed_seconds
	mov	w1, 34953	// tmp194,
	movk	w1, 0x8888, lsl 16	// tmp194,,
	smull	x1, w0, w1	// tmp193, tmp192, tmp194
	lsr	x1, x1, 32	// tmp195, tmp193,
	add	w1, w0, w1	// tmp196, tmp192, tmp197
	asr	w2, w1, 5	// tmp198, tmp196,
	asr	w1, w0, 31	// tmp199, tmp192,
	sub	w2, w2, w1	// tmp191, tmp198, tmp199
	mov	w1, 60	// tmp201,
	mul	w1, w2, w1	// tmp200, tmp191, tmp201
	sub	w0, w0, w1	// seconds_79, tmp192, tmp200
	str	w0, [sp, 148]	// seconds_79, seconds
// PowerAssessment/IO/IO_main.c:65:             printf("\rCollecting: %02d:%02d / 01:00", minutes, seconds);
	ldr	w2, [sp, 148]	//, seconds
	ldr	w1, [sp, 152]	//, minutes
	adrp	x0, .LC4	// tmp203,
	add	x0, x0, :lo12:.LC4	//, tmp203,
	bl	printf		//
// PowerAssessment/IO/IO_main.c:66:             fflush(stdout);
	adrp	x0, :got:stdout;ldr	x0, [x0, :got_lo12:stdout]	// tmp204,
	ldr	x0, [x0]	// stdout.4_23, stdout
	bl	fflush		//
// PowerAssessment/IO/IO_main.c:68:             last_report_s = elapsed_s;
	ldr	d31, [sp, 200]	// tmp205, elapsed_s
	str	d31, [sp, 192]	// tmp205, last_report_s
.L9:
// PowerAssessment/IO/IO_main.c:71:         if (elapsed_s < collection_window_s)
	ldr	d30, [sp, 200]	// tmp206, elapsed_s
	ldr	d31, [sp, 176]	// tmp207, collection_window_s
	fcmpe	d30, d31	// tmp206, tmp207
	bmi	.L18		//,
	b	.L11		//
.L18:
// Assembly optimization: the configured interval is exactly 100 ms.
	mov	x0, #0xe100
	movk	x0, #0x05f5, lsl #16
	stp	xzr, x0, [sp, 64]   // tv_sec = 0; tv_nsec = 100000000
// PowerAssessment/IO/IO_main.c:79:             if (nanosleep(&sleep_ts, NULL) != 0)
	add	x0, sp, 64	// tmp211,,
	mov	x1, 0	//,
	bl	nanosleep		//
// PowerAssessment/IO/IO_main.c:79:             if (nanosleep(&sleep_ts, NULL) != 0)
	cmp	w0, 0	// _30,
	beq	.L11		//,
// PowerAssessment/IO/IO_main.c:81:                 fprintf(stderr, "\nsample delay interrupted\n");
	adrp	x0, :got:stderr;ldr	x0, [x0, :got_lo12:stderr]	// tmp212,
	ldr	x0, [x0]	// stderr.5_31, stderr
	mov	x3, x0	//, stderr.5_31
	mov	x2, 26	//,
	mov	x1, 1	//,
	adrp	x0, .LC5	// tmp213,
	add	x0, x0, :lo12:.LC5	//, tmp213,
	bl	fwrite		//
// PowerAssessment/IO/IO_main.c:82:                 return 1;
	mov	w0, 1	// _52,
// PowerAssessment/IO/IO_main.c:39:             return 1;
	b	.L16		//
.L11:
// PowerAssessment/IO/IO_main.c:86:         if (clock_gettime(CLOCK_MONOTONIC, &now_ts) != 0)
	add	x0, sp, 112	// tmp214,,
	mov	x1, x0	//, tmp214
	mov	w0, 1	//,
	bl	clock_gettime		//
// PowerAssessment/IO/IO_main.c:86:         if (clock_gettime(CLOCK_MONOTONIC, &now_ts) != 0)
	cmp	w0, 0	// _32,
	beq	.L14		//,
// PowerAssessment/IO/IO_main.c:88:             fprintf(stderr, "failed to read time during one-minute collection\n");
	adrp	x0, :got:stderr;ldr	x0, [x0, :got_lo12:stderr]	// tmp215,
	ldr	x0, [x0]	// stderr.6_33, stderr
	mov	x3, x0	//, stderr.6_33
	mov	x2, 49	//,
	mov	x1, 1	//,
	adrp	x0, .LC3	// tmp216,
	add	x0, x0, :lo12:.LC3	//, tmp216,
	bl	fwrite		//
// PowerAssessment/IO/IO_main.c:89:             return 1;
	mov	w0, 1	// _52,
	b	.L16		//
.L14:
// PowerAssessment/IO/IO_main.c:92:         elapsed_s = (double)(now_ts.tv_sec - start_ts.tv_sec)
	ldr	x1, [sp, 112]	// _34, now_ts.tv_sec
// PowerAssessment/IO/IO_main.c:92:         elapsed_s = (double)(now_ts.tv_sec - start_ts.tv_sec)
	ldr	x0, [sp, 128]	// _35, start_ts.tv_sec
// PowerAssessment/IO/IO_main.c:92:         elapsed_s = (double)(now_ts.tv_sec - start_ts.tv_sec)
	sub	x0, x1, x0	// _36, _34, _35
	fmov	d31, x0	// _36, _36
// PowerAssessment/IO/IO_main.c:92:         elapsed_s = (double)(now_ts.tv_sec - start_ts.tv_sec)
	scvtf	d30, d31	// _37, _36
// PowerAssessment/IO/IO_main.c:93:                   + (double)(now_ts.tv_nsec - start_ts.tv_nsec) / 1000000000.0;
	ldr	x1, [sp, 120]	// _38, now_ts.tv_nsec
// PowerAssessment/IO/IO_main.c:93:                   + (double)(now_ts.tv_nsec - start_ts.tv_nsec) / 1000000000.0;
	ldr	x0, [sp, 136]	// _39, start_ts.tv_nsec
// PowerAssessment/IO/IO_main.c:93:                   + (double)(now_ts.tv_nsec - start_ts.tv_nsec) / 1000000000.0;
	sub	x0, x1, x0	// _40, _38, _39
	fmov	d31, x0	// _40, _40
// PowerAssessment/IO/IO_main.c:93:                   + (double)(now_ts.tv_nsec - start_ts.tv_nsec) / 1000000000.0;
	scvtf	d31, d31	// _41, _40
// PowerAssessment/IO/IO_main.c:93:                   + (double)(now_ts.tv_nsec - start_ts.tv_nsec) / 1000000000.0;
	mov	x0, 225833675390976	// tmp232,
	movk	x0, 0x41cd, lsl 48	// tmp232,,
	fmov	d29, x0	// tmp217, tmp232
	fdiv	d31, d31, d29	// _42, _41, tmp217
// PowerAssessment/IO/IO_main.c:92:         elapsed_s = (double)(now_ts.tv_sec - start_ts.tv_sec)
	fadd	d31, d30, d31	// elapsed_s_91, _37, _42
	str	d31, [sp, 200]	// elapsed_s_91, elapsed_s
.L4:
// PowerAssessment/IO/IO_main.c:30:     while (elapsed_s < collection_window_s)
	ldr	d30, [sp, 200]	// tmp219, elapsed_s
	ldr	d31, [sp, 176]	// tmp220, collection_window_s
	fcmpe	d30, d31	// tmp219, tmp220
	bmi	.L15		//,
// PowerAssessment/IO/IO_main.c:96:     printf("\rCollecting: 01:00 / 01:00\n");
	adrp	x0, .LC6	// tmp221,
	add	x0, x0, :lo12:.LC6	//, tmp221,
	bl	puts		//
// PowerAssessment/IO/IO_main.c:98:     printf("io: reads=%zu rate=%.2fHz sense_hat=%zu data=%zu cpu=%zu\n",
	ldr	d31, [sp, 184]	// tmp222, total_read_attempts
	ucvtf	d30, d31	// _43, tmp222
	ldr	d31, [sp, 200]	// tmp223, elapsed_s
	fdiv	d31, d30, d31	// _44, _43, tmp223
	add	x0, sp, 80	// tmp225,,
	ldr	x1, [x0, 8]	// _45, source_counts[1]
	add	x0, sp, 80	// tmp227,,
	ldr	x2, [x0, 16]	// _46, source_counts[2]
	add	x0, sp, 80	// tmp229,,
	ldr	x0, [x0, 24]	// _47, source_counts[3]
	mov	x4, x0	//, _47
	mov	x3, x2	//, _46
	mov	x2, x1	//, _45
	fmov	d0, d31	//, _44
	ldr	x1, [sp, 184]	//, total_read_attempts
	adrp	x0, .LC7	// tmp230,
	add	x0, x0, :lo12:.LC7	//, tmp230,
	bl	printf		//
// PowerAssessment/IO/IO_main.c:103:     return 0;
	mov	w0, 0	// _52,
.L16:
// PowerAssessment/IO/IO_main.c:104: }
	ldp	x29, x30, [sp], 208	//,,,
	.cfi_restore 30
	.cfi_restore 29
	.cfi_def_cfa_offset 0
	ret	
	.cfi_endproc
.LFE0:
	.size	main, .-main
	.section	.rodata
	.align	3
.LC8:
	.word	-1717986918
	.word	1069128089
	.align	4
.LC9:
	.xword	0
	.xword	0
	.xword	0
	.xword	0
	.ident	"GCC: (Debian 14.2.0-19) 14.2.0"
	.section	.note.GNU-stack,"",@progbits
