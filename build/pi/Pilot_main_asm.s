	.file	"Pilot_main_asm.c"
	.file	1 "/Users/matthewketas/Desktop/University of Pittsburgh/Senior Year/7th Semester/Embedded Systems/ECE_2160_Group_C" "build/pi/Pilot_main_asm.c"
	.file	2 "/Users/matthewketas/Desktop/University of Pittsburgh/Senior Year/7th Semester/Embedded Systems/ECE_2160_Group_C" "Development/CritterProduct/Pilot/Computation/../critter_types.h"
	.text
	.globl	main                            // -- Begin function main
	.p2align	2
	.type	main,@function
main:                                   // @main
.Lfunc_begin0:
	.loc	1 13 0                          // build/pi/Pilot_main_asm.c:13:0
	.cfi_startproc
// %bb.0:
	stp	x29, x30, [sp, #-32]!           // 16-byte Folded Spill
	.cfi_def_cfa_offset 32
	str	x28, [sp, #16]                  // 8-byte Folded Spill
	mov	x29, sp
	.cfi_def_cfa w29, 32
	.cfi_offset w28, -16
	.cfi_offset w30, -24
	.cfi_offset w29, -32
	sub	sp, sp, #1056
	adrp	x8, :got:__stack_chk_guard
	ldr	x8, [x8, :got_lo12:__stack_chk_guard]
	ldr	x8, [x8]
	stur	x8, [x29, #-8]
	str	wzr, [sp, #652]
.Ltmp0:
	.loc	1 18 18 prologue_end            // build/pi/Pilot_main_asm.c:18:18
	mov	x8, #4633641066610819072        // =0x404e000000000000
	fmov	d0, x8
	str	d0, [sp, #640]
	.loc	1 19 18                         // build/pi/Pilot_main_asm.c:19:18
	fmov	d0, #5.00000000
	str	d0, [sp, #632]
	.loc	1 20 18                         // build/pi/Pilot_main_asm.c:20:18
	fmov	d0, #30.00000000
	str	d0, [sp, #624]
	movi	d0, #0000000000000000
	.loc	1 25 12                         // build/pi/Pilot_main_asm.c:25:12
	str	d0, [sp, #616]
	.loc	1 26 12                         // build/pi/Pilot_main_asm.c:26:12
	str	d0, [sp, #608]
	.loc	1 27 12                         // build/pi/Pilot_main_asm.c:27:12
	str	xzr, [sp, #600]
	.loc	1 28 12                         // build/pi/Pilot_main_asm.c:28:12
	str	xzr, [sp, #592]
	.loc	1 29 12                         // build/pi/Pilot_main_asm.c:29:12
	str	xzr, [sp, #584]
	.loc	1 30 12                         // build/pi/Pilot_main_asm.c:30:12
	str	xzr, [sp, #576]
	.loc	1 31 12                         // build/pi/Pilot_main_asm.c:31:12
	str	d0, [sp, #568]
.Ltmp1:
	.loc	1 33 9                          // build/pi/Pilot_main_asm.c:33:9
	sub	x0, x29, #216
	mov	x1, #100                        // =0x64
	bl	critter_memory_init
	.loc	1 33 44 is_stmt 0               // build/pi/Pilot_main_asm.c:33:44
	cbz	w0, .LBB0_4
	b	.LBB0_1
.LBB0_1:
.Ltmp2:
	.loc	1 35 17 is_stmt 1               // build/pi/Pilot_main_asm.c:35:17
	adrp	x8, :got:stderr
	ldr	x8, [x8, :got_lo12:stderr]
	ldr	x8, [x8]
	str	x8, [sp, #544]                  // 8-byte Folded Spill
	.loc	1 35 9 is_stmt 0                // build/pi/Pilot_main_asm.c:35:9
	cbnz	x8, .LBB0_3
	b	.LBB0_2
.LBB0_2:
	adrp	x0, .L__unnamed_1
	add	x0, x0, :lo12:.L__unnamed_1
	bl	__ubsan_handle_nonnull_arg
	b	.LBB0_3
.LBB0_3:
	.loc	1 0 9                           // build/pi/Pilot_main_asm.c:0:9
	ldr	x0, [sp, #544]                  // 8-byte Folded Reload
	.loc	1 35 9                          // build/pi/Pilot_main_asm.c:35:9
	adrp	x1, .L.str
	add	x1, x1, :lo12:.L.str
	bl	fprintf
	.loc	1 36 9 is_stmt 1                // build/pi/Pilot_main_asm.c:36:9
	mov	w8, #1                          // =0x1
	str	w8, [sp, #652]
	b	.LBB0_118
.Ltmp3:
.LBB0_4:
	.loc	1 39 9                          // build/pi/Pilot_main_asm.c:39:9
	add	x8, sp, #728
	cbnz	x8, .LBB0_6
	b	.LBB0_5
.LBB0_5:
	adrp	x0, .L__unnamed_2
	add	x0, x0, :lo12:.L__unnamed_2
	bl	__ubsan_handle_nonnull_arg
	b	.LBB0_6
.LBB0_6:
	mov	w0, #1                          // =0x1
	add	x1, sp, #728
	bl	clock_gettime
	.loc	1 39 51 is_stmt 0               // build/pi/Pilot_main_asm.c:39:51
	cbz	w0, .LBB0_10
	b	.LBB0_7
.LBB0_7:
.Ltmp4:
	.loc	1 41 17 is_stmt 1               // build/pi/Pilot_main_asm.c:41:17
	adrp	x8, :got:stderr
	ldr	x8, [x8, :got_lo12:stderr]
	ldr	x8, [x8]
	str	x8, [sp, #536]                  // 8-byte Folded Spill
	.loc	1 41 9 is_stmt 0                // build/pi/Pilot_main_asm.c:41:9
	cbnz	x8, .LBB0_9
	b	.LBB0_8
.LBB0_8:
	adrp	x0, .L__unnamed_3
	add	x0, x0, :lo12:.L__unnamed_3
	bl	__ubsan_handle_nonnull_arg
	b	.LBB0_9
.LBB0_9:
	.loc	1 0 9                           // build/pi/Pilot_main_asm.c:0:9
	ldr	x0, [sp, #536]                  // 8-byte Folded Reload
	.loc	1 41 9                          // build/pi/Pilot_main_asm.c:41:9
	adrp	x1, .L.str.3
	add	x1, x1, :lo12:.L.str.3
	bl	fprintf
	.loc	1 42 9 is_stmt 1                // build/pi/Pilot_main_asm.c:42:9
	sub	x0, x29, #216
	bl	critter_memory_free
	.loc	1 43 9                          // build/pi/Pilot_main_asm.c:43:9
	mov	w8, #1                          // =0x1
	str	w8, [sp, #652]
	b	.LBB0_118
.Ltmp5:
.LBB0_10:
	.loc	1 46 5                          // build/pi/Pilot_main_asm.c:46:5
	b	.LBB0_11
.LBB0_11:                               // =>This Inner Loop Header: Depth=1
	.loc	1 46 12 is_stmt 0               // build/pi/Pilot_main_asm.c:46:12
	ldr	d0, [sp, #616]
	.loc	1 46 22                         // build/pi/Pilot_main_asm.c:46:22
	mov	x8, #4633641066610819072        // =0x404e000000000000
	fmov	d1, x8
	.loc	1 46 5                          // build/pi/Pilot_main_asm.c:46:5
	fcmp	d0, d1
	b.pl	.LBB0_71
	b	.LBB0_12
.LBB0_12:                               //   in Loop: Header=BB0_11 Depth=1
.Ltmp6:
	.loc	1 51 29 is_stmt 1               // build/pi/Pilot_main_asm.c:51:29
	ldr	x8, [sp, #600]
	add	x8, x8, #1
	str	x8, [sp, #600]
.Ltmp7:
	.loc	1 53 13                         // build/pi/Pilot_main_asm.c:53:13
	add	x0, sp, #672
	bl	critter_io_read_sample
	.loc	1 53 45 is_stmt 0               // build/pi/Pilot_main_asm.c:53:45
	cbz	w0, .LBB0_16
	b	.LBB0_13
.LBB0_13:
.Ltmp8:
	.loc	1 55 21 is_stmt 1               // build/pi/Pilot_main_asm.c:55:21
	adrp	x8, :got:stderr
	ldr	x8, [x8, :got_lo12:stderr]
	ldr	x8, [x8]
	str	x8, [sp, #528]                  // 8-byte Folded Spill
	.loc	1 55 13 is_stmt 0               // build/pi/Pilot_main_asm.c:55:13
	cbnz	x8, .LBB0_15
	b	.LBB0_14
.LBB0_14:
	adrp	x0, .L__unnamed_4
	add	x0, x0, :lo12:.L__unnamed_4
	bl	__ubsan_handle_nonnull_arg
	b	.LBB0_15
.LBB0_15:
	.loc	1 0 13                          // build/pi/Pilot_main_asm.c:0:13
	ldr	x0, [sp, #528]                  // 8-byte Folded Reload
	.loc	1 55 13                         // build/pi/Pilot_main_asm.c:55:13
	adrp	x1, .L.str.4
	add	x1, x1, :lo12:.L.str.4
	bl	fprintf
	.loc	1 56 13 is_stmt 1               // build/pi/Pilot_main_asm.c:56:13
	sub	x0, x29, #216
	bl	critter_memory_free
	.loc	1 57 13                         // build/pi/Pilot_main_asm.c:57:13
	mov	w8, #1                          // =0x1
	str	w8, [sp, #652]
	b	.LBB0_118
.Ltmp9:
.LBB0_16:                               //   in Loop: Header=BB0_11 Depth=1
	.loc	1 60 13                         // build/pi/Pilot_main_asm.c:60:13
	add	x0, sp, #672
	bl	critter_io_save_sample
	.loc	1 60 45 is_stmt 0               // build/pi/Pilot_main_asm.c:60:45
	cbz	w0, .LBB0_20
	b	.LBB0_17
.LBB0_17:
.Ltmp10:
	.loc	1 62 21 is_stmt 1               // build/pi/Pilot_main_asm.c:62:21
	adrp	x8, :got:stderr
	ldr	x8, [x8, :got_lo12:stderr]
	ldr	x8, [x8]
	str	x8, [sp, #520]                  // 8-byte Folded Spill
	.loc	1 62 13 is_stmt 0               // build/pi/Pilot_main_asm.c:62:13
	cbnz	x8, .LBB0_19
	b	.LBB0_18
.LBB0_18:
	adrp	x0, .L__unnamed_5
	add	x0, x0, :lo12:.L__unnamed_5
	bl	__ubsan_handle_nonnull_arg
	b	.LBB0_19
.LBB0_19:
	.loc	1 0 13                          // build/pi/Pilot_main_asm.c:0:13
	ldr	x0, [sp, #520]                  // 8-byte Folded Reload
	.loc	1 62 13                         // build/pi/Pilot_main_asm.c:62:13
	adrp	x1, .L.str.5
	add	x1, x1, :lo12:.L.str.5
	bl	fprintf
	.loc	1 63 13 is_stmt 1               // build/pi/Pilot_main_asm.c:63:13
	sub	x0, x29, #216
	bl	critter_memory_free
	.loc	1 64 13                         // build/pi/Pilot_main_asm.c:64:13
	mov	w8, #1                          // =0x1
	str	w8, [sp, #652]
	b	.LBB0_118
.Ltmp11:
.LBB0_20:                               //   in Loop: Header=BB0_11 Depth=1
	.loc	1 67 22                         // build/pi/Pilot_main_asm.c:67:22
	sub	x0, x29, #216
	add	x1, sp, #672
	bl	critter_memory_add_sample
	.loc	1 67 20 is_stmt 0               // build/pi/Pilot_main_asm.c:67:20
	str	w0, [sp, #564]
.Ltmp12:
	.loc	1 69 13 is_stmt 1               // build/pi/Pilot_main_asm.c:69:13
	ldr	w8, [sp, #564]
	.loc	1 69 24 is_stmt 0               // build/pi/Pilot_main_asm.c:69:24
	cbnz	w8, .LBB0_22
	b	.LBB0_21
.LBB0_21:                               //   in Loop: Header=BB0_11 Depth=1
.Ltmp13:
	.loc	1 71 33 is_stmt 1               // build/pi/Pilot_main_asm.c:71:33
	ldr	x8, [sp, #592]
	add	x8, x8, #1
	str	x8, [sp, #592]
	.loc	1 72 9                          // build/pi/Pilot_main_asm.c:72:9
	b	.LBB0_23
.Ltmp14:
.LBB0_22:                               //   in Loop: Header=BB0_11 Depth=1
	.loc	1 75 36                         // build/pi/Pilot_main_asm.c:75:36
	ldr	x8, [sp, #584]
	add	x8, x8, #1
	str	x8, [sp, #584]
	b	.LBB0_23
.Ltmp15:
.LBB0_23:                               //   in Loop: Header=BB0_11 Depth=1
	.loc	1 78 33                         // build/pi/Pilot_main_asm.c:78:33
	sub	x8, x29, #216
	add	x8, x8, #56
	str	x8, [sp, #512]                  // 8-byte Folded Spill
	and	x8, x8, #0x7
	cbz	x8, .LBB0_25
	b	.LBB0_24
.LBB0_24:                               //   in Loop: Header=BB0_11 Depth=1
	.loc	1 0 33 is_stmt 0                // build/pi/Pilot_main_asm.c:0:33
	ldr	x1, [sp, #512]                  // 8-byte Folded Reload
	.loc	1 78 33                         // build/pi/Pilot_main_asm.c:78:33
	adrp	x0, .L__unnamed_6
	add	x0, x0, :lo12:.L__unnamed_6
	bl	__ubsan_handle_type_mismatch_v1
	b	.LBB0_25
.LBB0_25:                               //   in Loop: Header=BB0_11 Depth=1
	ldur	x8, [x29, #-160]
	.loc	1 78 24                         // build/pi/Pilot_main_asm.c:78:24
	str	x8, [sp, #576]
.Ltmp16:
	.loc	1 80 13 is_stmt 1               // build/pi/Pilot_main_asm.c:80:13
	add	x8, sp, #712
	cbnz	x8, .LBB0_27
	b	.LBB0_26
.LBB0_26:                               //   in Loop: Header=BB0_11 Depth=1
	adrp	x0, .L__unnamed_7
	add	x0, x0, :lo12:.L__unnamed_7
	bl	__ubsan_handle_nonnull_arg
	b	.LBB0_27
.LBB0_27:                               //   in Loop: Header=BB0_11 Depth=1
	mov	w0, #1                          // =0x1
	add	x1, sp, #712
	bl	clock_gettime
	.loc	1 80 53 is_stmt 0               // build/pi/Pilot_main_asm.c:80:53
	cbz	w0, .LBB0_31
	b	.LBB0_28
.LBB0_28:
.Ltmp17:
	.loc	1 82 21 is_stmt 1               // build/pi/Pilot_main_asm.c:82:21
	adrp	x8, :got:stderr
	ldr	x8, [x8, :got_lo12:stderr]
	ldr	x8, [x8]
	str	x8, [sp, #504]                  // 8-byte Folded Spill
	.loc	1 82 13 is_stmt 0               // build/pi/Pilot_main_asm.c:82:13
	cbnz	x8, .LBB0_30
	b	.LBB0_29
.LBB0_29:
	adrp	x0, .L__unnamed_8
	add	x0, x0, :lo12:.L__unnamed_8
	bl	__ubsan_handle_nonnull_arg
	b	.LBB0_30
.LBB0_30:
	.loc	1 0 13                          // build/pi/Pilot_main_asm.c:0:13
	ldr	x0, [sp, #504]                  // 8-byte Folded Reload
	.loc	1 82 13                         // build/pi/Pilot_main_asm.c:82:13
	adrp	x1, .L.str.6
	add	x1, x1, :lo12:.L.str.6
	bl	fprintf
	.loc	1 83 13 is_stmt 1               // build/pi/Pilot_main_asm.c:83:13
	sub	x0, x29, #216
	bl	critter_memory_free
	.loc	1 84 13                         // build/pi/Pilot_main_asm.c:84:13
	mov	w8, #1                          // =0x1
	str	w8, [sp, #652]
	b	.LBB0_118
.Ltmp18:
.LBB0_31:                               //   in Loop: Header=BB0_11 Depth=1
	.loc	1 87 37                         // build/pi/Pilot_main_asm.c:87:37
	ldr	x8, [sp, #712]
	str	x8, [sp, #480]                  // 8-byte Folded Spill
	.loc	1 87 55 is_stmt 0               // build/pi/Pilot_main_asm.c:87:55
	ldr	x9, [sp, #728]
	str	x9, [sp, #488]                  // 8-byte Folded Spill
	.loc	1 87 44                         // build/pi/Pilot_main_asm.c:87:44
	subs	x8, x8, x9
	str	x8, [sp, #496]                  // 8-byte Folded Spill
	cset	w8, vs
	tbz	w8, #0, .LBB0_33
	b	.LBB0_32
.LBB0_32:                               //   in Loop: Header=BB0_11 Depth=1
	.loc	1 0 44                          // build/pi/Pilot_main_asm.c:0:44
	ldr	x2, [sp, #488]                  // 8-byte Folded Reload
	ldr	x1, [sp, #480]                  // 8-byte Folded Reload
	.loc	1 87 44                         // build/pi/Pilot_main_asm.c:87:44
	adrp	x0, .L__unnamed_9
	add	x0, x0, :lo12:.L__unnamed_9
	bl	__ubsan_handle_sub_overflow
	b	.LBB0_33
.LBB0_33:                               //   in Loop: Header=BB0_11 Depth=1
	.loc	1 0 44                          // build/pi/Pilot_main_asm.c:0:44
	ldr	x8, [sp, #496]                  // 8-byte Folded Reload
	.loc	1 87 21                         // build/pi/Pilot_main_asm.c:87:21
	scvtf	d0, x8
	str	d0, [sp, #464]                  // 8-byte Folded Spill
	.loc	1 88 37 is_stmt 1               // build/pi/Pilot_main_asm.c:88:37
	add	x8, sp, #712
	add	x8, x8, #8
	str	x8, [sp, #472]                  // 8-byte Folded Spill
	and	x8, x8, #0x7
	cbz	x8, .LBB0_35
	b	.LBB0_34
.LBB0_34:                               //   in Loop: Header=BB0_11 Depth=1
	.loc	1 0 37 is_stmt 0                // build/pi/Pilot_main_asm.c:0:37
	ldr	x1, [sp, #472]                  // 8-byte Folded Reload
	.loc	1 88 37                         // build/pi/Pilot_main_asm.c:88:37
	adrp	x0, .L__unnamed_10
	add	x0, x0, :lo12:.L__unnamed_10
	bl	__ubsan_handle_type_mismatch_v1
	b	.LBB0_35
.LBB0_35:                               //   in Loop: Header=BB0_11 Depth=1
	ldr	x8, [sp, #720]
	str	x8, [sp, #448]                  // 8-byte Folded Spill
	.loc	1 88 56                         // build/pi/Pilot_main_asm.c:88:56
	add	x8, sp, #728
	add	x8, x8, #8
	str	x8, [sp, #456]                  // 8-byte Folded Spill
	and	x8, x8, #0x7
	cbz	x8, .LBB0_37
	b	.LBB0_36
.LBB0_36:                               //   in Loop: Header=BB0_11 Depth=1
	.loc	1 0 56                          // build/pi/Pilot_main_asm.c:0:56
	ldr	x1, [sp, #456]                  // 8-byte Folded Reload
	.loc	1 88 56                         // build/pi/Pilot_main_asm.c:88:56
	adrp	x0, .L__unnamed_11
	add	x0, x0, :lo12:.L__unnamed_11
	bl	__ubsan_handle_type_mismatch_v1
	b	.LBB0_37
.LBB0_37:                               //   in Loop: Header=BB0_11 Depth=1
	.loc	1 0 56                          // build/pi/Pilot_main_asm.c:0:56
	ldr	x8, [sp, #448]                  // 8-byte Folded Reload
	.loc	1 88 56                         // build/pi/Pilot_main_asm.c:88:56
	ldr	x9, [sp, #736]
	str	x9, [sp, #432]                  // 8-byte Folded Spill
	.loc	1 88 45                         // build/pi/Pilot_main_asm.c:88:45
	subs	x8, x8, x9
	str	x8, [sp, #440]                  // 8-byte Folded Spill
	cset	w8, vs
	tbz	w8, #0, .LBB0_39
	b	.LBB0_38
.LBB0_38:                               //   in Loop: Header=BB0_11 Depth=1
	.loc	1 0 45                          // build/pi/Pilot_main_asm.c:0:45
	ldr	x2, [sp, #432]                  // 8-byte Folded Reload
	ldr	x1, [sp, #448]                  // 8-byte Folded Reload
	.loc	1 88 45                         // build/pi/Pilot_main_asm.c:88:45
	adrp	x0, .L__unnamed_12
	add	x0, x0, :lo12:.L__unnamed_12
	bl	__ubsan_handle_sub_overflow
	b	.LBB0_39
.LBB0_39:                               //   in Loop: Header=BB0_11 Depth=1
	.loc	1 0 45                          // build/pi/Pilot_main_asm.c:0:45
	ldr	d0, [sp, #464]                  // 8-byte Folded Reload
	ldr	x8, [sp, #440]                  // 8-byte Folded Reload
	.loc	1 88 21                         // build/pi/Pilot_main_asm.c:88:21
	scvtf	d1, x8
	.loc	1 88 65                         // build/pi/Pilot_main_asm.c:88:65
	mov	x8, #225833675390976            // =0xcd6500000000
	movk	x8, #16845, lsl #48
	fmov	d2, x8
	fdiv	d1, d1, d2
	.loc	1 88 19                         // build/pi/Pilot_main_asm.c:88:19
	fadd	d0, d0, d1
	.loc	1 87 19 is_stmt 1               // build/pi/Pilot_main_asm.c:87:19
	str	d0, [sp, #616]
.Ltmp19:
	.loc	1 90 13                         // build/pi/Pilot_main_asm.c:90:13
	ldr	d0, [sp, #616]
	.loc	1 90 26 is_stmt 0               // build/pi/Pilot_main_asm.c:90:26
	ldr	d1, [sp, #608]
	.loc	1 90 40                         // build/pi/Pilot_main_asm.c:90:40
	fmov	d2, #5.00000000
	fadd	d1, d1, d2
	.loc	1 90 23                         // build/pi/Pilot_main_asm.c:90:23
	fcmp	d0, d1
	b.lt	.LBB0_50
	b	.LBB0_40
.LBB0_40:                               //   in Loop: Header=BB0_11 Depth=1
.Ltmp20:
	.loc	1 92 40 is_stmt 1               // build/pi/Pilot_main_asm.c:92:40
	ldr	d0, [sp, #616]
	str	d0, [sp, #424]                  // 8-byte Folded Spill
	.loc	1 92 35 is_stmt 0               // build/pi/Pilot_main_asm.c:92:35
	mov	x8, #2097152                    // =0x200000
	movk	x8, #49632, lsl #48
	fmov	d1, x8
	fcmp	d0, d1
	b.le	.LBB0_42
	b	.LBB0_41
.LBB0_41:                               //   in Loop: Header=BB0_11 Depth=1
	.loc	1 0 35                          // build/pi/Pilot_main_asm.c:0:35
	ldr	d0, [sp, #424]                  // 8-byte Folded Reload
	.loc	1 92 35                         // build/pi/Pilot_main_asm.c:92:35
	mov	x8, #4746794007248502784        // =0x41e0000000000000
	fmov	d1, x8
	fcmp	d0, d1
	b.mi	.LBB0_43
	b	.LBB0_42
.LBB0_42:                               //   in Loop: Header=BB0_11 Depth=1
	.loc	1 0 35                          // build/pi/Pilot_main_asm.c:0:35
	ldr	d0, [sp, #424]                  // 8-byte Folded Reload
	.loc	1 92 35                         // build/pi/Pilot_main_asm.c:92:35
	adrp	x0, .L__unnamed_13
	add	x0, x0, :lo12:.L__unnamed_13
	fmov	x1, d0
	bl	__ubsan_handle_float_cast_overflow
	b	.LBB0_43
.LBB0_43:                               //   in Loop: Header=BB0_11 Depth=1
	.loc	1 0 35                          // build/pi/Pilot_main_asm.c:0:35
	ldr	d0, [sp, #424]                  // 8-byte Folded Reload
	.loc	1 92 35                         // build/pi/Pilot_main_asm.c:92:35
	fcvtzs	w8, d0
	.loc	1 92 17                         // build/pi/Pilot_main_asm.c:92:17
	str	w8, [sp, #560]
	.loc	1 93 27 is_stmt 1               // build/pi/Pilot_main_asm.c:93:27
	ldr	w8, [sp, #560]
                                        // kill: def $x8 killed $w8
	str	x8, [sp, #408]                  // 8-byte Folded Spill
	.loc	1 93 43 is_stmt 0               // build/pi/Pilot_main_asm.c:93:43
	mov	w9, #-2147483648                // =0x80000000
	subs	w8, w8, w9
	cset	w9, ne
	mov	w8, #1                          // =0x1
	orr	w9, w9, #0x1
	str	w9, [sp, #420]                  // 4-byte Folded Spill
	tbz	w8, #0, .LBB0_45
	b	.LBB0_44
.LBB0_44:                               //   in Loop: Header=BB0_11 Depth=1
	.loc	1 0 43                          // build/pi/Pilot_main_asm.c:0:43
	ldr	w8, [sp, #420]                  // 4-byte Folded Reload
	.loc	1 93 43                         // build/pi/Pilot_main_asm.c:93:43
	tbnz	w8, #0, .LBB0_46
	b	.LBB0_45
.LBB0_45:                               //   in Loop: Header=BB0_11 Depth=1
	.loc	1 0 43                          // build/pi/Pilot_main_asm.c:0:43
	ldr	x1, [sp, #408]                  // 8-byte Folded Reload
	.loc	1 93 43                         // build/pi/Pilot_main_asm.c:93:43
	adrp	x0, .L__unnamed_14
	add	x0, x0, :lo12:.L__unnamed_14
	mov	x2, #60                         // =0x3c
	bl	__ubsan_handle_divrem_overflow
	b	.LBB0_46
.LBB0_46:                               //   in Loop: Header=BB0_11 Depth=1
	.loc	1 0 43                          // build/pi/Pilot_main_asm.c:0:43
	ldr	x8, [sp, #408]                  // 8-byte Folded Reload
	.loc	1 93 43                         // build/pi/Pilot_main_asm.c:93:43
	mov	w9, #60                         // =0x3c
	sdiv	w8, w8, w9
	.loc	1 93 17                         // build/pi/Pilot_main_asm.c:93:17
	str	w8, [sp, #556]
	.loc	1 94 27 is_stmt 1               // build/pi/Pilot_main_asm.c:94:27
	ldr	w8, [sp, #560]
                                        // kill: def $x8 killed $w8
	str	x8, [sp, #392]                  // 8-byte Folded Spill
	.loc	1 94 43 is_stmt 0               // build/pi/Pilot_main_asm.c:94:43
	mov	w9, #-2147483648                // =0x80000000
	subs	w8, w8, w9
	cset	w9, ne
	mov	w8, #1                          // =0x1
	orr	w9, w9, #0x1
	str	w9, [sp, #404]                  // 4-byte Folded Spill
	tbz	w8, #0, .LBB0_48
	b	.LBB0_47
.LBB0_47:                               //   in Loop: Header=BB0_11 Depth=1
	.loc	1 0 43                          // build/pi/Pilot_main_asm.c:0:43
	ldr	w8, [sp, #404]                  // 4-byte Folded Reload
	.loc	1 94 43                         // build/pi/Pilot_main_asm.c:94:43
	tbnz	w8, #0, .LBB0_49
	b	.LBB0_48
.LBB0_48:                               //   in Loop: Header=BB0_11 Depth=1
	.loc	1 0 43                          // build/pi/Pilot_main_asm.c:0:43
	ldr	x1, [sp, #392]                  // 8-byte Folded Reload
	.loc	1 94 43                         // build/pi/Pilot_main_asm.c:94:43
	adrp	x0, .L__unnamed_15
	add	x0, x0, :lo12:.L__unnamed_15
	mov	x2, #60                         // =0x3c
	bl	__ubsan_handle_divrem_overflow
	b	.LBB0_49
.LBB0_49:                               //   in Loop: Header=BB0_11 Depth=1
	.loc	1 0 43                          // build/pi/Pilot_main_asm.c:0:43
	ldr	x8, [sp, #392]                  // 8-byte Folded Reload
	.loc	1 94 43                         // build/pi/Pilot_main_asm.c:94:43
	mov	w10, #60                        // =0x3c
	sdiv	w9, w8, w10
	mul	w9, w9, w10
	subs	w8, w8, w9
	.loc	1 94 17                         // build/pi/Pilot_main_asm.c:94:17
	str	w8, [sp, #552]
	.loc	1 96 55 is_stmt 1               // build/pi/Pilot_main_asm.c:96:55
	ldr	w1, [sp, #556]
	.loc	1 96 64 is_stmt 0               // build/pi/Pilot_main_asm.c:96:64
	ldr	w2, [sp, #552]
	.loc	1 96 13                         // build/pi/Pilot_main_asm.c:96:13
	adrp	x0, .L.str.7
	add	x0, x0, :lo12:.L.str.7
	bl	printf
	.loc	1 97 20 is_stmt 1               // build/pi/Pilot_main_asm.c:97:20
	adrp	x8, :got:stdout
	ldr	x8, [x8, :got_lo12:stdout]
	ldr	x0, [x8]
	.loc	1 97 13 is_stmt 0               // build/pi/Pilot_main_asm.c:97:13
	bl	fflush
	.loc	1 99 29 is_stmt 1               // build/pi/Pilot_main_asm.c:99:29
	ldr	d0, [sp, #616]
	.loc	1 99 27 is_stmt 0               // build/pi/Pilot_main_asm.c:99:27
	str	d0, [sp, #608]
	.loc	1 100 9 is_stmt 1               // build/pi/Pilot_main_asm.c:100:9
	b	.LBB0_50
.Ltmp21:
.LBB0_50:                               //   in Loop: Header=BB0_11 Depth=1
	.loc	1 102 13                        // build/pi/Pilot_main_asm.c:102:13
	ldr	d0, [sp, #616]
	.loc	1 102 23 is_stmt 0              // build/pi/Pilot_main_asm.c:102:23
	mov	x8, #4633641066610819072        // =0x404e000000000000
	fmov	d1, x8
	fcmp	d0, d1
	b.pl	.LBB0_56
	b	.LBB0_51
.LBB0_51:                               //   in Loop: Header=BB0_11 Depth=1
.Ltmp22:
	.loc	1 104 29 is_stmt 1              // build/pi/Pilot_main_asm.c:104:29
	adrp	x8, .L__const.main.sleep_ts
	add	x8, x8, :lo12:.L__const.main.sleep_ts
	ldr	q0, [x8]
	add	x0, sp, #656
	str	q0, [sp, #656]
.Ltmp23:
	.loc	1 106 17                        // build/pi/Pilot_main_asm.c:106:17
	mov	x1, xzr
	bl	nanosleep
	.loc	1 106 44 is_stmt 0              // build/pi/Pilot_main_asm.c:106:44
	cbz	w0, .LBB0_55
	b	.LBB0_52
.LBB0_52:
.Ltmp24:
	.loc	1 108 25 is_stmt 1              // build/pi/Pilot_main_asm.c:108:25
	adrp	x8, :got:stderr
	ldr	x8, [x8, :got_lo12:stderr]
	ldr	x8, [x8]
	str	x8, [sp, #384]                  // 8-byte Folded Spill
	.loc	1 108 17 is_stmt 0              // build/pi/Pilot_main_asm.c:108:17
	cbnz	x8, .LBB0_54
	b	.LBB0_53
.LBB0_53:
	adrp	x0, .L__unnamed_16
	add	x0, x0, :lo12:.L__unnamed_16
	bl	__ubsan_handle_nonnull_arg
	b	.LBB0_54
.LBB0_54:
	.loc	1 0 17                          // build/pi/Pilot_main_asm.c:0:17
	ldr	x0, [sp, #384]                  // 8-byte Folded Reload
	.loc	1 108 17                        // build/pi/Pilot_main_asm.c:108:17
	adrp	x1, .L.str.8
	add	x1, x1, :lo12:.L.str.8
	bl	fprintf
	.loc	1 109 17 is_stmt 1              // build/pi/Pilot_main_asm.c:109:17
	sub	x0, x29, #216
	bl	critter_memory_free
	.loc	1 110 17                        // build/pi/Pilot_main_asm.c:110:17
	mov	w8, #1                          // =0x1
	str	w8, [sp, #652]
	b	.LBB0_118
.Ltmp25:
.LBB0_55:                               //   in Loop: Header=BB0_11 Depth=1
	.loc	1 112 9                         // build/pi/Pilot_main_asm.c:112:9
	b	.LBB0_56
.Ltmp26:
.LBB0_56:                               //   in Loop: Header=BB0_11 Depth=1
	.loc	1 114 13                        // build/pi/Pilot_main_asm.c:114:13
	add	x8, sp, #712
	cbnz	x8, .LBB0_58
	b	.LBB0_57
.LBB0_57:                               //   in Loop: Header=BB0_11 Depth=1
	adrp	x0, .L__unnamed_17
	add	x0, x0, :lo12:.L__unnamed_17
	bl	__ubsan_handle_nonnull_arg
	b	.LBB0_58
.LBB0_58:                               //   in Loop: Header=BB0_11 Depth=1
	mov	w0, #1                          // =0x1
	add	x1, sp, #712
	bl	clock_gettime
	.loc	1 114 53 is_stmt 0              // build/pi/Pilot_main_asm.c:114:53
	cbz	w0, .LBB0_62
	b	.LBB0_59
.LBB0_59:
.Ltmp27:
	.loc	1 116 21 is_stmt 1              // build/pi/Pilot_main_asm.c:116:21
	adrp	x8, :got:stderr
	ldr	x8, [x8, :got_lo12:stderr]
	ldr	x8, [x8]
	str	x8, [sp, #376]                  // 8-byte Folded Spill
	.loc	1 116 13 is_stmt 0              // build/pi/Pilot_main_asm.c:116:13
	cbnz	x8, .LBB0_61
	b	.LBB0_60
.LBB0_60:
	adrp	x0, .L__unnamed_18
	add	x0, x0, :lo12:.L__unnamed_18
	bl	__ubsan_handle_nonnull_arg
	b	.LBB0_61
.LBB0_61:
	.loc	1 0 13                          // build/pi/Pilot_main_asm.c:0:13
	ldr	x0, [sp, #376]                  // 8-byte Folded Reload
	.loc	1 116 13                        // build/pi/Pilot_main_asm.c:116:13
	adrp	x1, .L.str.6
	add	x1, x1, :lo12:.L.str.6
	bl	fprintf
	.loc	1 117 13 is_stmt 1              // build/pi/Pilot_main_asm.c:117:13
	sub	x0, x29, #216
	bl	critter_memory_free
	.loc	1 118 13                        // build/pi/Pilot_main_asm.c:118:13
	mov	w8, #1                          // =0x1
	str	w8, [sp, #652]
	b	.LBB0_118
.Ltmp28:
.LBB0_62:                               //   in Loop: Header=BB0_11 Depth=1
	.loc	1 121 37                        // build/pi/Pilot_main_asm.c:121:37
	ldr	x8, [sp, #712]
	str	x8, [sp, #352]                  // 8-byte Folded Spill
	.loc	1 121 55 is_stmt 0              // build/pi/Pilot_main_asm.c:121:55
	ldr	x9, [sp, #728]
	str	x9, [sp, #360]                  // 8-byte Folded Spill
	.loc	1 121 44                        // build/pi/Pilot_main_asm.c:121:44
	subs	x8, x8, x9
	str	x8, [sp, #368]                  // 8-byte Folded Spill
	cset	w8, vs
	tbz	w8, #0, .LBB0_64
	b	.LBB0_63
.LBB0_63:                               //   in Loop: Header=BB0_11 Depth=1
	.loc	1 0 44                          // build/pi/Pilot_main_asm.c:0:44
	ldr	x2, [sp, #360]                  // 8-byte Folded Reload
	ldr	x1, [sp, #352]                  // 8-byte Folded Reload
	.loc	1 121 44                        // build/pi/Pilot_main_asm.c:121:44
	adrp	x0, .L__unnamed_19
	add	x0, x0, :lo12:.L__unnamed_19
	bl	__ubsan_handle_sub_overflow
	b	.LBB0_64
.LBB0_64:                               //   in Loop: Header=BB0_11 Depth=1
	.loc	1 0 44                          // build/pi/Pilot_main_asm.c:0:44
	ldr	x8, [sp, #368]                  // 8-byte Folded Reload
	.loc	1 121 21                        // build/pi/Pilot_main_asm.c:121:21
	scvtf	d0, x8
	str	d0, [sp, #336]                  // 8-byte Folded Spill
	.loc	1 122 37 is_stmt 1              // build/pi/Pilot_main_asm.c:122:37
	add	x8, sp, #712
	add	x8, x8, #8
	str	x8, [sp, #344]                  // 8-byte Folded Spill
	and	x8, x8, #0x7
	cbz	x8, .LBB0_66
	b	.LBB0_65
.LBB0_65:                               //   in Loop: Header=BB0_11 Depth=1
	.loc	1 0 37 is_stmt 0                // build/pi/Pilot_main_asm.c:0:37
	ldr	x1, [sp, #344]                  // 8-byte Folded Reload
	.loc	1 122 37                        // build/pi/Pilot_main_asm.c:122:37
	adrp	x0, .L__unnamed_20
	add	x0, x0, :lo12:.L__unnamed_20
	bl	__ubsan_handle_type_mismatch_v1
	b	.LBB0_66
.LBB0_66:                               //   in Loop: Header=BB0_11 Depth=1
	ldr	x8, [sp, #720]
	str	x8, [sp, #320]                  // 8-byte Folded Spill
	.loc	1 122 56                        // build/pi/Pilot_main_asm.c:122:56
	add	x8, sp, #728
	add	x8, x8, #8
	str	x8, [sp, #328]                  // 8-byte Folded Spill
	and	x8, x8, #0x7
	cbz	x8, .LBB0_68
	b	.LBB0_67
.LBB0_67:                               //   in Loop: Header=BB0_11 Depth=1
	.loc	1 0 56                          // build/pi/Pilot_main_asm.c:0:56
	ldr	x1, [sp, #328]                  // 8-byte Folded Reload
	.loc	1 122 56                        // build/pi/Pilot_main_asm.c:122:56
	adrp	x0, .L__unnamed_21
	add	x0, x0, :lo12:.L__unnamed_21
	bl	__ubsan_handle_type_mismatch_v1
	b	.LBB0_68
.LBB0_68:                               //   in Loop: Header=BB0_11 Depth=1
	.loc	1 0 56                          // build/pi/Pilot_main_asm.c:0:56
	ldr	x8, [sp, #320]                  // 8-byte Folded Reload
	.loc	1 122 56                        // build/pi/Pilot_main_asm.c:122:56
	ldr	x9, [sp, #736]
	str	x9, [sp, #304]                  // 8-byte Folded Spill
	.loc	1 122 45                        // build/pi/Pilot_main_asm.c:122:45
	subs	x8, x8, x9
	str	x8, [sp, #312]                  // 8-byte Folded Spill
	cset	w8, vs
	tbz	w8, #0, .LBB0_70
	b	.LBB0_69
.LBB0_69:                               //   in Loop: Header=BB0_11 Depth=1
	.loc	1 0 45                          // build/pi/Pilot_main_asm.c:0:45
	ldr	x2, [sp, #304]                  // 8-byte Folded Reload
	ldr	x1, [sp, #320]                  // 8-byte Folded Reload
	.loc	1 122 45                        // build/pi/Pilot_main_asm.c:122:45
	adrp	x0, .L__unnamed_22
	add	x0, x0, :lo12:.L__unnamed_22
	bl	__ubsan_handle_sub_overflow
	b	.LBB0_70
.LBB0_70:                               //   in Loop: Header=BB0_11 Depth=1
	.loc	1 0 45                          // build/pi/Pilot_main_asm.c:0:45
	ldr	d0, [sp, #336]                  // 8-byte Folded Reload
	ldr	x8, [sp, #312]                  // 8-byte Folded Reload
	.loc	1 122 21                        // build/pi/Pilot_main_asm.c:122:21
	scvtf	d1, x8
	.loc	1 122 65                        // build/pi/Pilot_main_asm.c:122:65
	mov	x8, #225833675390976            // =0xcd6500000000
	movk	x8, #16845, lsl #48
	fmov	d2, x8
	fdiv	d1, d1, d2
	.loc	1 122 19                        // build/pi/Pilot_main_asm.c:122:19
	fadd	d0, d0, d1
	.loc	1 121 19 is_stmt 1              // build/pi/Pilot_main_asm.c:121:19
	str	d0, [sp, #616]
.Ltmp29:
	.loc	1 46 5                          // build/pi/Pilot_main_asm.c:46:5
	b	.LBB0_11
.LBB0_71:
	.loc	1 125 5                         // build/pi/Pilot_main_asm.c:125:5
	adrp	x0, .L.str.9
	add	x0, x0, :lo12:.L.str.9
	bl	printf
.Ltmp30:
	.loc	1 127 9                         // build/pi/Pilot_main_asm.c:127:9
	sub	x0, x29, #216
	sub	x1, x29, #144
	bl	critter_memory_build_summary
	.loc	1 127 57 is_stmt 0              // build/pi/Pilot_main_asm.c:127:57
	cbz	w0, .LBB0_75
	b	.LBB0_72
.LBB0_72:
.Ltmp31:
	.loc	1 129 17 is_stmt 1              // build/pi/Pilot_main_asm.c:129:17
	adrp	x8, :got:stderr
	ldr	x8, [x8, :got_lo12:stderr]
	ldr	x8, [x8]
	str	x8, [sp, #296]                  // 8-byte Folded Spill
	.loc	1 129 9 is_stmt 0               // build/pi/Pilot_main_asm.c:129:9
	cbnz	x8, .LBB0_74
	b	.LBB0_73
.LBB0_73:
	adrp	x0, .L__unnamed_23
	add	x0, x0, :lo12:.L__unnamed_23
	bl	__ubsan_handle_nonnull_arg
	b	.LBB0_74
.LBB0_74:
	.loc	1 0 9                           // build/pi/Pilot_main_asm.c:0:9
	ldr	x0, [sp, #296]                  // 8-byte Folded Reload
	.loc	1 129 9                         // build/pi/Pilot_main_asm.c:129:9
	adrp	x1, .L.str.10
	add	x1, x1, :lo12:.L.str.10
	bl	fprintf
	.loc	1 130 9 is_stmt 1               // build/pi/Pilot_main_asm.c:130:9
	sub	x0, x29, #216
	bl	critter_memory_free
	.loc	1 131 9                         // build/pi/Pilot_main_asm.c:131:9
	mov	w8, #1                          // =0x1
	str	w8, [sp, #652]
	b	.LBB0_118
.Ltmp32:
.LBB0_75:
	.loc	1 134 9                         // build/pi/Pilot_main_asm.c:134:9
	sub	x0, x29, #144
	fmov	d0, #30.00000000
	add	x1, sp, #744
	bl	critter_compute_analysis
	.loc	1 134 77 is_stmt 0              // build/pi/Pilot_main_asm.c:134:77
	cbz	w0, .LBB0_79
	b	.LBB0_76
.LBB0_76:
.Ltmp33:
	.loc	1 136 17 is_stmt 1              // build/pi/Pilot_main_asm.c:136:17
	adrp	x8, :got:stderr
	ldr	x8, [x8, :got_lo12:stderr]
	ldr	x8, [x8]
	str	x8, [sp, #288]                  // 8-byte Folded Spill
	.loc	1 136 9 is_stmt 0               // build/pi/Pilot_main_asm.c:136:9
	cbnz	x8, .LBB0_78
	b	.LBB0_77
.LBB0_77:
	adrp	x0, .L__unnamed_24
	add	x0, x0, :lo12:.L__unnamed_24
	bl	__ubsan_handle_nonnull_arg
	b	.LBB0_78
.LBB0_78:
	.loc	1 0 9                           // build/pi/Pilot_main_asm.c:0:9
	ldr	x0, [sp, #288]                  // 8-byte Folded Reload
	.loc	1 136 9                         // build/pi/Pilot_main_asm.c:136:9
	adrp	x1, .L.str.11
	add	x1, x1, :lo12:.L.str.11
	bl	fprintf
	.loc	1 137 9 is_stmt 1               // build/pi/Pilot_main_asm.c:137:9
	sub	x0, x29, #216
	bl	critter_memory_free
	.loc	1 138 9                         // build/pi/Pilot_main_asm.c:138:9
	mov	w8, #1                          // =0x1
	str	w8, [sp, #652]
	b	.LBB0_118
.Ltmp34:
.LBB0_79:
	.loc	1 141 9                         // build/pi/Pilot_main_asm.c:141:9
	ldr	d0, [sp, #616]
	.loc	1 141 19 is_stmt 0              // build/pi/Pilot_main_asm.c:141:19
	fcmp	d0, #0.0
	b.le	.LBB0_81
	b	.LBB0_80
.LBB0_80:
	.loc	1 142 36 is_stmt 1              // build/pi/Pilot_main_asm.c:142:36
	ldr	d0, [sp, #600]
	.loc	1 142 28 is_stmt 0              // build/pi/Pilot_main_asm.c:142:28
	ucvtf	d0, d0
	.loc	1 142 58                        // build/pi/Pilot_main_asm.c:142:58
	ldr	d1, [sp, #616]
	.loc	1 142 56                        // build/pi/Pilot_main_asm.c:142:56
	fdiv	d0, d0, d1
	.loc	1 142 26                        // build/pi/Pilot_main_asm.c:142:26
	str	d0, [sp, #568]
	.loc	1 142 9                         // build/pi/Pilot_main_asm.c:142:9
	b	.LBB0_81
.Ltmp35:
.LBB0_81:
	.loc	1 145 12 is_stmt 1              // build/pi/Pilot_main_asm.c:145:12
	ldr	x8, [sp, #600]
	str	x8, [sp, #240]                  // 8-byte Folded Spill
	.loc	1 146 12                        // build/pi/Pilot_main_asm.c:146:12
	ldr	x8, [sp, #592]
	str	x8, [sp, #248]                  // 8-byte Folded Spill
	.loc	1 147 12                        // build/pi/Pilot_main_asm.c:147:12
	ldr	x8, [sp, #584]
	str	x8, [sp, #256]                  // 8-byte Folded Spill
	.loc	1 148 12                        // build/pi/Pilot_main_asm.c:148:12
	ldr	x8, [sp, #576]
	str	x8, [sp, #264]                  // 8-byte Folded Spill
	.loc	1 149 12                        // build/pi/Pilot_main_asm.c:149:12
	ldr	d0, [sp, #568]
	str	d0, [sp, #272]                  // 8-byte Folded Spill
	.loc	1 150 20                        // build/pi/Pilot_main_asm.c:150:20
	sub	x8, x29, #144
	add	x8, x8, #112
	str	x8, [sp, #280]                  // 8-byte Folded Spill
	and	x8, x8, #0x7
	cbz	x8, .LBB0_83
	b	.LBB0_82
.LBB0_82:
	.loc	1 0 20 is_stmt 0                // build/pi/Pilot_main_asm.c:0:20
	ldr	x1, [sp, #280]                  // 8-byte Folded Reload
	.loc	1 150 20                        // build/pi/Pilot_main_asm.c:150:20
	adrp	x0, .L__unnamed_25
	add	x0, x0, :lo12:.L__unnamed_25
	bl	__ubsan_handle_type_mismatch_v1
	b	.LBB0_83
.LBB0_83:
	.loc	1 0 20                          // build/pi/Pilot_main_asm.c:0:20
	ldr	d0, [sp, #272]                  // 8-byte Folded Reload
	ldr	x4, [sp, #264]                  // 8-byte Folded Reload
	ldr	x3, [sp, #256]                  // 8-byte Folded Reload
	ldr	x2, [sp, #248]                  // 8-byte Folded Reload
	ldr	x1, [sp, #240]                  // 8-byte Folded Reload
	.loc	1 150 20                        // build/pi/Pilot_main_asm.c:150:20
	ldur	d1, [x29, #-32]
	.loc	1 144 5 is_stmt 1               // build/pi/Pilot_main_asm.c:144:5
	adrp	x0, .L.str.12
	add	x0, x0, :lo12:.L.str.12
	bl	printf
	sub	x8, x29, #144
	.loc	1 153 20                        // build/pi/Pilot_main_asm.c:153:20
	ldur	x9, [x29, #-144]
	str	x9, [sp, #224]                  // 8-byte Folded Spill
	.loc	1 154 20                        // build/pi/Pilot_main_asm.c:154:20
	add	x8, x8, #56
	str	x8, [sp, #232]                  // 8-byte Folded Spill
	and	x8, x8, #0x7
	cbz	x8, .LBB0_85
	b	.LBB0_84
.LBB0_84:
	.loc	1 0 20 is_stmt 0                // build/pi/Pilot_main_asm.c:0:20
	ldr	x1, [sp, #232]                  // 8-byte Folded Reload
	.loc	1 154 20                        // build/pi/Pilot_main_asm.c:154:20
	adrp	x0, .L__unnamed_26
	add	x0, x0, :lo12:.L__unnamed_26
	bl	__ubsan_handle_type_mismatch_v1
	b	.LBB0_85
.LBB0_85:
	ldur	d0, [x29, #-88]
	str	d0, [sp, #208]                  // 8-byte Folded Spill
	.loc	1 155 20 is_stmt 1              // build/pi/Pilot_main_asm.c:155:20
	sub	x8, x29, #144
	add	x8, x8, #64
	str	x8, [sp, #216]                  // 8-byte Folded Spill
	and	x8, x8, #0x7
	cbz	x8, .LBB0_87
	b	.LBB0_86
.LBB0_86:
	.loc	1 0 20 is_stmt 0                // build/pi/Pilot_main_asm.c:0:20
	ldr	x1, [sp, #216]                  // 8-byte Folded Reload
	.loc	1 155 20                        // build/pi/Pilot_main_asm.c:155:20
	adrp	x0, .L__unnamed_27
	add	x0, x0, :lo12:.L__unnamed_27
	bl	__ubsan_handle_type_mismatch_v1
	b	.LBB0_87
.LBB0_87:
	ldur	d0, [x29, #-80]
	str	d0, [sp, #192]                  // 8-byte Folded Spill
	.loc	1 156 20 is_stmt 1              // build/pi/Pilot_main_asm.c:156:20
	sub	x8, x29, #144
	add	x8, x8, #72
	str	x8, [sp, #200]                  // 8-byte Folded Spill
	and	x8, x8, #0x7
	cbz	x8, .LBB0_89
	b	.LBB0_88
.LBB0_88:
	.loc	1 0 20 is_stmt 0                // build/pi/Pilot_main_asm.c:0:20
	ldr	x1, [sp, #200]                  // 8-byte Folded Reload
	.loc	1 156 20                        // build/pi/Pilot_main_asm.c:156:20
	adrp	x0, .L__unnamed_28
	add	x0, x0, :lo12:.L__unnamed_28
	bl	__ubsan_handle_type_mismatch_v1
	b	.LBB0_89
.LBB0_89:
	ldur	d0, [x29, #-72]
	str	d0, [sp, #176]                  // 8-byte Folded Spill
	.loc	1 157 20 is_stmt 1              // build/pi/Pilot_main_asm.c:157:20
	sub	x8, x29, #144
	add	x8, x8, #80
	str	x8, [sp, #184]                  // 8-byte Folded Spill
	and	x8, x8, #0x7
	cbz	x8, .LBB0_91
	b	.LBB0_90
.LBB0_90:
	.loc	1 0 20 is_stmt 0                // build/pi/Pilot_main_asm.c:0:20
	ldr	x1, [sp, #184]                  // 8-byte Folded Reload
	.loc	1 157 20                        // build/pi/Pilot_main_asm.c:157:20
	adrp	x0, .L__unnamed_29
	add	x0, x0, :lo12:.L__unnamed_29
	bl	__ubsan_handle_type_mismatch_v1
	b	.LBB0_91
.LBB0_91:
	ldur	d0, [x29, #-64]
	str	d0, [sp, #160]                  // 8-byte Folded Spill
	.loc	1 158 20 is_stmt 1              // build/pi/Pilot_main_asm.c:158:20
	sub	x8, x29, #144
	add	x8, x8, #88
	str	x8, [sp, #168]                  // 8-byte Folded Spill
	and	x8, x8, #0x7
	cbz	x8, .LBB0_93
	b	.LBB0_92
.LBB0_92:
	.loc	1 0 20 is_stmt 0                // build/pi/Pilot_main_asm.c:0:20
	ldr	x1, [sp, #168]                  // 8-byte Folded Reload
	.loc	1 158 20                        // build/pi/Pilot_main_asm.c:158:20
	adrp	x0, .L__unnamed_30
	add	x0, x0, :lo12:.L__unnamed_30
	bl	__ubsan_handle_type_mismatch_v1
	b	.LBB0_93
.LBB0_93:
	ldur	d0, [x29, #-56]
	str	d0, [sp, #144]                  // 8-byte Folded Spill
	.loc	1 159 25 is_stmt 1              // build/pi/Pilot_main_asm.c:159:25
	sub	x8, x29, #144
	add	x8, x8, #120
	str	x8, [sp, #152]                  // 8-byte Folded Spill
	and	x8, x8, #0x7
	cbz	x8, .LBB0_95
	b	.LBB0_94
.LBB0_94:
	.loc	1 0 25 is_stmt 0                // build/pi/Pilot_main_asm.c:0:25
	ldr	x1, [sp, #152]                  // 8-byte Folded Reload
	.loc	1 159 25                        // build/pi/Pilot_main_asm.c:159:25
	adrp	x0, .L__unnamed_31
	add	x0, x0, :lo12:.L__unnamed_31
	bl	__ubsan_handle_type_mismatch_v1
	b	.LBB0_95
.LBB0_95:
	.loc	1 0 25                          // build/pi/Pilot_main_asm.c:0:25
	ldr	d4, [sp, #144]                  // 8-byte Folded Reload
	ldr	d3, [sp, #160]                  // 8-byte Folded Reload
	ldr	d2, [sp, #176]                  // 8-byte Folded Reload
	ldr	d1, [sp, #192]                  // 8-byte Folded Reload
	ldr	d0, [sp, #208]                  // 8-byte Folded Reload
	ldr	x1, [sp, #224]                  // 8-byte Folded Reload
	.loc	1 159 25                        // build/pi/Pilot_main_asm.c:159:25
	ldur	w2, [x29, #-24]
	.loc	1 152 5 is_stmt 1               // build/pi/Pilot_main_asm.c:152:5
	adrp	x0, .L.str.13
	add	x0, x0, :lo12:.L.str.13
	bl	printf
	add	x8, sp, #744
	.loc	1 162 21                        // build/pi/Pilot_main_asm.c:162:21
	ldr	d0, [sp, #744]
	str	d0, [sp, #128]                  // 8-byte Folded Spill
	.loc	1 163 21                        // build/pi/Pilot_main_asm.c:163:21
	add	x8, x8, #24
	str	x8, [sp, #136]                  // 8-byte Folded Spill
	and	x8, x8, #0x7
	cbz	x8, .LBB0_97
	b	.LBB0_96
.LBB0_96:
	.loc	1 0 21 is_stmt 0                // build/pi/Pilot_main_asm.c:0:21
	ldr	x1, [sp, #136]                  // 8-byte Folded Reload
	.loc	1 163 21                        // build/pi/Pilot_main_asm.c:163:21
	adrp	x0, .L__unnamed_32
	add	x0, x0, :lo12:.L__unnamed_32
	bl	__ubsan_handle_type_mismatch_v1
	b	.LBB0_97
.LBB0_97:
	ldr	d0, [sp, #768]
	str	d0, [sp, #112]                  // 8-byte Folded Spill
	.loc	1 164 21 is_stmt 1              // build/pi/Pilot_main_asm.c:164:21
	add	x8, sp, #744
	add	x8, x8, #8
	str	x8, [sp, #120]                  // 8-byte Folded Spill
	and	x8, x8, #0x7
	cbz	x8, .LBB0_99
	b	.LBB0_98
.LBB0_98:
	.loc	1 0 21 is_stmt 0                // build/pi/Pilot_main_asm.c:0:21
	ldr	x1, [sp, #120]                  // 8-byte Folded Reload
	.loc	1 164 21                        // build/pi/Pilot_main_asm.c:164:21
	adrp	x0, .L__unnamed_33
	add	x0, x0, :lo12:.L__unnamed_33
	bl	__ubsan_handle_type_mismatch_v1
	b	.LBB0_99
.LBB0_99:
	ldr	d0, [sp, #752]
	str	d0, [sp, #96]                   // 8-byte Folded Spill
	.loc	1 165 21 is_stmt 1              // build/pi/Pilot_main_asm.c:165:21
	add	x8, sp, #744
	add	x8, x8, #16
	str	x8, [sp, #104]                  // 8-byte Folded Spill
	and	x8, x8, #0x7
	cbz	x8, .LBB0_101
	b	.LBB0_100
.LBB0_100:
	.loc	1 0 21 is_stmt 0                // build/pi/Pilot_main_asm.c:0:21
	ldr	x1, [sp, #104]                  // 8-byte Folded Reload
	.loc	1 165 21                        // build/pi/Pilot_main_asm.c:165:21
	adrp	x0, .L__unnamed_34
	add	x0, x0, :lo12:.L__unnamed_34
	bl	__ubsan_handle_type_mismatch_v1
	b	.LBB0_101
.LBB0_101:
	ldr	d0, [sp, #760]
	str	d0, [sp, #80]                   // 8-byte Folded Spill
	.loc	1 166 21 is_stmt 1              // build/pi/Pilot_main_asm.c:166:21
	ldrb	w8, [sp, #827]
                                        // kill: def $x8 killed $w8
	str	x8, [sp, #88]                   // 8-byte Folded Spill
	subs	w8, w8, #1
	b.ls	.LBB0_103
	b	.LBB0_102
.LBB0_102:
	.loc	1 0 21 is_stmt 0                // build/pi/Pilot_main_asm.c:0:21
	ldr	x1, [sp, #88]                   // 8-byte Folded Reload
	.loc	1 166 21                        // build/pi/Pilot_main_asm.c:166:21
	adrp	x0, .L__unnamed_35
	add	x0, x0, :lo12:.L__unnamed_35
	bl	__ubsan_handle_load_invalid_value
	b	.LBB0_103
.LBB0_103:
	.loc	1 0 21                          // build/pi/Pilot_main_asm.c:0:21
	ldr	x10, [sp, #88]                  // 8-byte Folded Reload
	.loc	1 166 12                        // build/pi/Pilot_main_asm.c:166:12
	adrp	x9, .L.str.16
	add	x9, x9, :lo12:.L.str.16
	adrp	x8, .L.str.15
	add	x8, x8, :lo12:.L.str.15
	and	w10, w10, #0x1
	ands	w10, w10, #0x1
	csel	x8, x8, x9, ne
	str	x8, [sp, #64]                   // 8-byte Folded Spill
	.loc	1 167 21 is_stmt 1              // build/pi/Pilot_main_asm.c:167:21
	ldrb	w8, [sp, #829]
                                        // kill: def $x8 killed $w8
	str	x8, [sp, #72]                   // 8-byte Folded Spill
	subs	w8, w8, #1
	b.ls	.LBB0_105
	b	.LBB0_104
.LBB0_104:
	.loc	1 0 21 is_stmt 0                // build/pi/Pilot_main_asm.c:0:21
	ldr	x1, [sp, #72]                   // 8-byte Folded Reload
	.loc	1 167 21                        // build/pi/Pilot_main_asm.c:167:21
	adrp	x0, .L__unnamed_36
	add	x0, x0, :lo12:.L__unnamed_36
	bl	__ubsan_handle_load_invalid_value
	b	.LBB0_105
.LBB0_105:
	.loc	1 0 21                          // build/pi/Pilot_main_asm.c:0:21
	ldr	x10, [sp, #72]                  // 8-byte Folded Reload
	.loc	1 167 12                        // build/pi/Pilot_main_asm.c:167:12
	adrp	x9, .L.str.16
	add	x9, x9, :lo12:.L.str.16
	adrp	x8, .L.str.15
	add	x8, x8, :lo12:.L.str.15
	and	w10, w10, #0x1
	ands	w10, w10, #0x1
	csel	x8, x8, x9, ne
	str	x8, [sp, #48]                   // 8-byte Folded Spill
	.loc	1 168 21 is_stmt 1              // build/pi/Pilot_main_asm.c:168:21
	add	x8, sp, #744
	add	x8, x8, #84
	str	x8, [sp, #56]                   // 8-byte Folded Spill
	and	x8, x8, #0x3
	cbz	x8, .LBB0_107
	b	.LBB0_106
.LBB0_106:
	.loc	1 0 21 is_stmt 0                // build/pi/Pilot_main_asm.c:0:21
	ldr	x1, [sp, #56]                   // 8-byte Folded Reload
	.loc	1 168 21                        // build/pi/Pilot_main_asm.c:168:21
	adrp	x0, .L__unnamed_37
	add	x0, x0, :lo12:.L__unnamed_37
	bl	__ubsan_handle_type_mismatch_v1
	b	.LBB0_107
.LBB0_107:
	ldrb	w8, [sp, #828]
                                        // kill: def $x8 killed $w8
	str	x8, [sp, #40]                   // 8-byte Folded Spill
	subs	w8, w8, #1
	b.ls	.LBB0_109
	b	.LBB0_108
.LBB0_108:
	.loc	1 0 21                          // build/pi/Pilot_main_asm.c:0:21
	ldr	x1, [sp, #40]                   // 8-byte Folded Reload
	.loc	1 168 21                        // build/pi/Pilot_main_asm.c:168:21
	adrp	x0, .L__unnamed_38
	add	x0, x0, :lo12:.L__unnamed_38
	bl	__ubsan_handle_load_invalid_value
	b	.LBB0_109
.LBB0_109:
	.loc	1 0 21                          // build/pi/Pilot_main_asm.c:0:21
	ldr	x10, [sp, #40]                  // 8-byte Folded Reload
	.loc	1 168 12                        // build/pi/Pilot_main_asm.c:168:12
	adrp	x9, .L.str.16
	add	x9, x9, :lo12:.L.str.16
	adrp	x8, .L.str.15
	add	x8, x8, :lo12:.L.str.15
	and	w10, w10, #0x1
	ands	w10, w10, #0x1
	csel	x8, x8, x9, ne
	str	x8, [sp, #24]                   // 8-byte Folded Spill
	.loc	1 169 21 is_stmt 1              // build/pi/Pilot_main_asm.c:169:21
	add	x8, sp, #744
	add	x8, x8, #80
	str	x8, [sp, #32]                   // 8-byte Folded Spill
	and	x8, x8, #0x7
	cbz	x8, .LBB0_111
	b	.LBB0_110
.LBB0_110:
	.loc	1 0 21 is_stmt 0                // build/pi/Pilot_main_asm.c:0:21
	ldr	x1, [sp, #32]                   // 8-byte Folded Reload
	.loc	1 169 21                        // build/pi/Pilot_main_asm.c:169:21
	adrp	x0, .L__unnamed_39
	add	x0, x0, :lo12:.L__unnamed_39
	bl	__ubsan_handle_type_mismatch_v1
	b	.LBB0_111
.LBB0_111:
	ldrb	w8, [sp, #824]
                                        // kill: def $x8 killed $w8
	str	x8, [sp, #16]                   // 8-byte Folded Spill
	subs	w8, w8, #1
	b.ls	.LBB0_113
	b	.LBB0_112
.LBB0_112:
	.loc	1 0 21                          // build/pi/Pilot_main_asm.c:0:21
	ldr	x1, [sp, #16]                   // 8-byte Folded Reload
	.loc	1 169 21                        // build/pi/Pilot_main_asm.c:169:21
	adrp	x0, .L__unnamed_40
	add	x0, x0, :lo12:.L__unnamed_40
	bl	__ubsan_handle_load_invalid_value
	b	.LBB0_113
.LBB0_113:
	.loc	1 0 21                          // build/pi/Pilot_main_asm.c:0:21
	ldr	x3, [sp, #24]                   // 8-byte Folded Reload
	ldr	x2, [sp, #48]                   // 8-byte Folded Reload
	ldr	x1, [sp, #64]                   // 8-byte Folded Reload
	ldr	d3, [sp, #80]                   // 8-byte Folded Reload
	ldr	d2, [sp, #96]                   // 8-byte Folded Reload
	ldr	d1, [sp, #112]                  // 8-byte Folded Reload
	ldr	d0, [sp, #128]                  // 8-byte Folded Reload
	ldr	x10, [sp, #16]                  // 8-byte Folded Reload
	.loc	1 169 12                        // build/pi/Pilot_main_asm.c:169:12
	adrp	x9, .L.str.16
	add	x9, x9, :lo12:.L.str.16
	adrp	x8, .L.str.15
	add	x8, x8, :lo12:.L.str.15
	and	w10, w10, #0x1
	ands	w10, w10, #0x1
	csel	x4, x8, x9, ne
	.loc	1 161 5 is_stmt 1               // build/pi/Pilot_main_asm.c:161:5
	adrp	x0, .L.str.14
	add	x0, x0, :lo12:.L.str.14
	bl	printf
.Ltmp36:
	.loc	1 173 33                        // build/pi/Pilot_main_asm.c:173:33
	ldr	x2, [sp, #600]
	.loc	1 174 33                        // build/pi/Pilot_main_asm.c:174:33
	ldr	x3, [sp, #592]
	.loc	1 175 33                        // build/pi/Pilot_main_asm.c:175:33
	ldr	x4, [sp, #584]
	.loc	1 176 33                        // build/pi/Pilot_main_asm.c:176:33
	ldr	x5, [sp, #576]
	.loc	1 177 33                        // build/pi/Pilot_main_asm.c:177:33
	ldr	d0, [sp, #568]
	.loc	1 171 9                         // build/pi/Pilot_main_asm.c:171:9
	sub	x0, x29, #144
	add	x1, sp, #744
	bl	critter_io_save_metrics
	.loc	1 177 51                        // build/pi/Pilot_main_asm.c:177:51
	cbz	w0, .LBB0_117
	b	.LBB0_114
.LBB0_114:
.Ltmp37:
	.loc	1 179 17                        // build/pi/Pilot_main_asm.c:179:17
	adrp	x8, :got:stderr
	ldr	x8, [x8, :got_lo12:stderr]
	ldr	x8, [x8]
	str	x8, [sp, #8]                    // 8-byte Folded Spill
	.loc	1 179 9 is_stmt 0               // build/pi/Pilot_main_asm.c:179:9
	cbnz	x8, .LBB0_116
	b	.LBB0_115
.LBB0_115:
	adrp	x0, .L__unnamed_41
	add	x0, x0, :lo12:.L__unnamed_41
	bl	__ubsan_handle_nonnull_arg
	b	.LBB0_116
.LBB0_116:
	.loc	1 0 9                           // build/pi/Pilot_main_asm.c:0:9
	ldr	x0, [sp, #8]                    // 8-byte Folded Reload
	.loc	1 179 9                         // build/pi/Pilot_main_asm.c:179:9
	adrp	x1, .L.str.17
	add	x1, x1, :lo12:.L.str.17
	bl	fprintf
	.loc	1 180 5 is_stmt 1               // build/pi/Pilot_main_asm.c:180:5
	b	.LBB0_117
.Ltmp38:
.LBB0_117:
	.loc	1 182 5                         // build/pi/Pilot_main_asm.c:182:5
	sub	x0, x29, #216
	bl	critter_memory_free
	.loc	1 183 5                         // build/pi/Pilot_main_asm.c:183:5
	str	wzr, [sp, #652]
	b	.LBB0_118
.LBB0_118:
	.loc	1 184 1                         // build/pi/Pilot_main_asm.c:184:1
	ldr	w8, [sp, #652]
	str	w8, [sp, #4]                    // 4-byte Folded Spill
	ldur	x9, [x29, #-8]
	adrp	x8, :got:__stack_chk_guard
	ldr	x8, [x8, :got_lo12:__stack_chk_guard]
	ldr	x8, [x8]
	subs	x8, x8, x9
	b.eq	.LBB0_120
	b	.LBB0_119
.LBB0_119:
	bl	__stack_chk_fail
.LBB0_120:
	.loc	1 0 1 is_stmt 0                 // build/pi/Pilot_main_asm.c:0:1
	ldr	w0, [sp, #4]                    // 4-byte Folded Reload
	.loc	1 184 1 epilogue_begin          // build/pi/Pilot_main_asm.c:184:1
	add	sp, sp, #1056
	.cfi_def_cfa wsp, 32
	ldr	x28, [sp, #16]                  // 8-byte Folded Reload
	ldp	x29, x30, [sp], #32             // 16-byte Folded Reload
	.cfi_def_cfa_offset 0
	.cfi_restore w28
	.cfi_restore w30
	.cfi_restore w29
	ret
.Ltmp39:
.Lfunc_end0:
	.size	main, .Lfunc_end0-main
	.cfi_endproc
                                        // -- End function
	.type	.L.src,@object                  // @.src
	.section	.rodata.str1.1,"aMS",@progbits,1
.L.src:
	.asciz	"build/pi/Pilot_main_asm.c"
	.size	.L.src, 26

	.type	.L.src.1,@object                // @.src.1
.L.src.1:
	.asciz	"/private/tmp/zig-aarch64-macos-0.16.0/lib/libc/include/generic-glibc/stdio.h"
	.size	.L.src.1, 77

	.type	.L__unnamed_1,@object           // @0
	.data
	.p2align	4, 0x0
.L__unnamed_1:
	.xword	.L.src
	.word	35                              // 0x23
	.word	17                              // 0x11
	.xword	.L.src.1
	.word	365                             // 0x16d
	.word	45                              // 0x2d
	.word	1                               // 0x1
	.zero	4
	.size	.L__unnamed_1, 40

	.type	.L.str,@object                  // @.str
	.section	.rodata.str1.1,"aMS",@progbits,1
.L.str:
	.asciz	"failed to initialize memory\n"
	.size	.L.str, 29

	.type	.L.src.2,@object                // @.src.2
.L.src.2:
	.asciz	"/private/tmp/zig-aarch64-macos-0.16.0/lib/libc/include/generic-glibc/time.h"
	.size	.L.src.2, 76

	.type	.L__unnamed_2,@object           // @1
	.data
	.p2align	4, 0x0
.L__unnamed_2:
	.xword	.L.src
	.word	39                              // 0x27
	.word	40                              // 0x28
	.xword	.L.src.2
	.word	298                             // 0x12a
	.word	14                              // 0xe
	.word	2                               // 0x2
	.zero	4
	.size	.L__unnamed_2, 40

	.type	.L__unnamed_3,@object           // @2
	.p2align	4, 0x0
.L__unnamed_3:
	.xword	.L.src
	.word	41                              // 0x29
	.word	17                              // 0x11
	.xword	.L.src.1
	.word	365                             // 0x16d
	.word	45                              // 0x2d
	.word	1                               // 0x1
	.zero	4
	.size	.L__unnamed_3, 40

	.type	.L.str.3,@object                // @.str.3
	.section	.rodata.str1.1,"aMS",@progbits,1
.L.str.3:
	.asciz	"failed to start one-minute collection window\n"
	.size	.L.str.3, 46

	.type	.L__unnamed_4,@object           // @3
	.data
	.p2align	4, 0x0
.L__unnamed_4:
	.xword	.L.src
	.word	55                              // 0x37
	.word	21                              // 0x15
	.xword	.L.src.1
	.word	365                             // 0x16d
	.word	45                              // 0x2d
	.word	1                               // 0x1
	.zero	4
	.size	.L__unnamed_4, 40

	.type	.L.str.4,@object                // @.str.4
	.section	.rodata.str1.1,"aMS",@progbits,1
.L.str.4:
	.asciz	"failed to read sample during one-minute collection\n"
	.size	.L.str.4, 52

	.type	.L__unnamed_5,@object           // @4
	.data
	.p2align	4, 0x0
.L__unnamed_5:
	.xword	.L.src
	.word	62                              // 0x3e
	.word	21                              // 0x15
	.xword	.L.src.1
	.word	365                             // 0x16d
	.word	45                              // 0x2d
	.word	1                               // 0x1
	.zero	4
	.size	.L__unnamed_5, 40

	.type	.L.str.5,@object                // @.str.5
	.section	.rodata.str1.1,"aMS",@progbits,1
.L.str.5:
	.asciz	"failed to save sample during one-minute collection\n"
	.size	.L.str.5, 52

	.type	.L__unnamed_42,@object          // @5
	.section	.rodata,"a",@progbits
	.p2align	4, 0x0
.L__unnamed_42:
	.hword	0                               // 0x0
	.hword	12                              // 0xc
	.asciz	"'size_t' (aka 'unsigned long')"
	.zero	1
	.size	.L__unnamed_42, 36

	.type	.L__unnamed_6,@object           // @6
	.data
	.p2align	4, 0x0
.L__unnamed_6:
	.xword	.L.src
	.word	78                              // 0x4e
	.word	33                              // 0x21
	.xword	.L__unnamed_42
	.byte	3                               // 0x3
	.byte	0                               // 0x0
	.zero	6
	.size	.L__unnamed_6, 32

	.type	.L__unnamed_7,@object           // @7
	.p2align	4, 0x0
.L__unnamed_7:
	.xword	.L.src
	.word	80                              // 0x50
	.word	44                              // 0x2c
	.xword	.L.src.2
	.word	298                             // 0x12a
	.word	14                              // 0xe
	.word	2                               // 0x2
	.zero	4
	.size	.L__unnamed_7, 40

	.type	.L__unnamed_8,@object           // @8
	.p2align	4, 0x0
.L__unnamed_8:
	.xword	.L.src
	.word	82                              // 0x52
	.word	21                              // 0x15
	.xword	.L.src.1
	.word	365                             // 0x16d
	.word	45                              // 0x2d
	.word	1                               // 0x1
	.zero	4
	.size	.L__unnamed_8, 40

	.type	.L.str.6,@object                // @.str.6
	.section	.rodata.str1.1,"aMS",@progbits,1
.L.str.6:
	.asciz	"failed to read time during one-minute collection\n"
	.size	.L.str.6, 50

	.type	.L__unnamed_43,@object          // @9
	.section	.rodata,"a",@progbits
	.p2align	4, 0x0
.L__unnamed_43:
	.hword	0                               // 0x0
	.hword	13                              // 0xd
	.asciz	"'__time_t' (aka 'long')"
	.size	.L__unnamed_43, 28

	.type	.L__unnamed_9,@object           // @10
	.data
	.p2align	4, 0x0
.L__unnamed_9:
	.xword	.L.src
	.word	87                              // 0x57
	.word	44                              // 0x2c
	.xword	.L__unnamed_43
	.size	.L__unnamed_9, 24

	.type	.L__unnamed_44,@object          // @11
	.section	.rodata,"a",@progbits
	.p2align	4, 0x0
.L__unnamed_44:
	.hword	0                               // 0x0
	.hword	13                              // 0xd
	.asciz	"'__syscall_slong_t' (aka 'long')"
	.zero	1
	.size	.L__unnamed_44, 38

	.type	.L__unnamed_10,@object          // @12
	.data
	.p2align	4, 0x0
.L__unnamed_10:
	.xword	.L.src
	.word	88                              // 0x58
	.word	37                              // 0x25
	.xword	.L__unnamed_44
	.byte	3                               // 0x3
	.byte	0                               // 0x0
	.zero	6
	.size	.L__unnamed_10, 32

	.type	.L__unnamed_11,@object          // @13
	.p2align	4, 0x0
.L__unnamed_11:
	.xword	.L.src
	.word	88                              // 0x58
	.word	56                              // 0x38
	.xword	.L__unnamed_44
	.byte	3                               // 0x3
	.byte	0                               // 0x0
	.zero	6
	.size	.L__unnamed_11, 32

	.type	.L__unnamed_12,@object          // @14
	.p2align	4, 0x0
.L__unnamed_12:
	.xword	.L.src
	.word	88                              // 0x58
	.word	45                              // 0x2d
	.xword	.L__unnamed_44
	.size	.L__unnamed_12, 24

	.type	.L__unnamed_45,@object          // @15
	.section	.rodata,"a",@progbits
	.p2align	3, 0x0
.L__unnamed_45:
	.hword	1                               // 0x1
	.hword	64                              // 0x40
	.asciz	"'double'"
	.zero	1
	.size	.L__unnamed_45, 14

	.type	.L__unnamed_46,@object          // @16
	.p2align	3, 0x0
.L__unnamed_46:
	.hword	0                               // 0x0
	.hword	11                              // 0xb
	.asciz	"'int'"
	.size	.L__unnamed_46, 10

	.type	.L__unnamed_13,@object          // @17
	.data
	.p2align	4, 0x0
.L__unnamed_13:
	.xword	.L.src
	.word	92                              // 0x5c
	.word	35                              // 0x23
	.xword	.L__unnamed_45
	.xword	.L__unnamed_46
	.size	.L__unnamed_13, 32

	.type	.L__unnamed_14,@object          // @18
	.p2align	4, 0x0
.L__unnamed_14:
	.xword	.L.src
	.word	93                              // 0x5d
	.word	43                              // 0x2b
	.xword	.L__unnamed_46
	.size	.L__unnamed_14, 24

	.type	.L__unnamed_15,@object          // @19
	.p2align	4, 0x0
.L__unnamed_15:
	.xword	.L.src
	.word	94                              // 0x5e
	.word	43                              // 0x2b
	.xword	.L__unnamed_46
	.size	.L__unnamed_15, 24

	.type	.L.str.7,@object                // @.str.7
	.section	.rodata.str1.1,"aMS",@progbits,1
.L.str.7:
	.asciz	"\rCollecting: %02d:%02d / 01:00"
	.size	.L.str.7, 31

	.type	.L__const.main.sleep_ts,@object // @__const.main.sleep_ts
	.section	.rodata.cst16,"aM",@progbits,16
	.p2align	3, 0x0
.L__const.main.sleep_ts:
	.xword	0                               // 0x0
	.xword	100000000                       // 0x5f5e100
	.size	.L__const.main.sleep_ts, 16

	.type	.L__unnamed_16,@object          // @20
	.data
	.p2align	4, 0x0
.L__unnamed_16:
	.xword	.L.src
	.word	108                             // 0x6c
	.word	25                              // 0x19
	.xword	.L.src.1
	.word	365                             // 0x16d
	.word	45                              // 0x2d
	.word	1                               // 0x1
	.zero	4
	.size	.L__unnamed_16, 40

	.type	.L.str.8,@object                // @.str.8
	.section	.rodata.str1.1,"aMS",@progbits,1
.L.str.8:
	.asciz	"\nsample delay interrupted\n"
	.size	.L.str.8, 27

	.type	.L__unnamed_17,@object          // @21
	.data
	.p2align	4, 0x0
.L__unnamed_17:
	.xword	.L.src
	.word	114                             // 0x72
	.word	44                              // 0x2c
	.xword	.L.src.2
	.word	298                             // 0x12a
	.word	14                              // 0xe
	.word	2                               // 0x2
	.zero	4
	.size	.L__unnamed_17, 40

	.type	.L__unnamed_18,@object          // @22
	.p2align	4, 0x0
.L__unnamed_18:
	.xword	.L.src
	.word	116                             // 0x74
	.word	21                              // 0x15
	.xword	.L.src.1
	.word	365                             // 0x16d
	.word	45                              // 0x2d
	.word	1                               // 0x1
	.zero	4
	.size	.L__unnamed_18, 40

	.type	.L__unnamed_19,@object          // @23
	.p2align	4, 0x0
.L__unnamed_19:
	.xword	.L.src
	.word	121                             // 0x79
	.word	44                              // 0x2c
	.xword	.L__unnamed_43
	.size	.L__unnamed_19, 24

	.type	.L__unnamed_20,@object          // @24
	.p2align	4, 0x0
.L__unnamed_20:
	.xword	.L.src
	.word	122                             // 0x7a
	.word	37                              // 0x25
	.xword	.L__unnamed_44
	.byte	3                               // 0x3
	.byte	0                               // 0x0
	.zero	6
	.size	.L__unnamed_20, 32

	.type	.L__unnamed_21,@object          // @25
	.p2align	4, 0x0
.L__unnamed_21:
	.xword	.L.src
	.word	122                             // 0x7a
	.word	56                              // 0x38
	.xword	.L__unnamed_44
	.byte	3                               // 0x3
	.byte	0                               // 0x0
	.zero	6
	.size	.L__unnamed_21, 32

	.type	.L__unnamed_22,@object          // @26
	.p2align	4, 0x0
.L__unnamed_22:
	.xword	.L.src
	.word	122                             // 0x7a
	.word	45                              // 0x2d
	.xword	.L__unnamed_44
	.size	.L__unnamed_22, 24

	.type	.L.str.9,@object                // @.str.9
	.section	.rodata.str1.1,"aMS",@progbits,1
.L.str.9:
	.asciz	"\rCollecting: 01:00 / 01:00\n"
	.size	.L.str.9, 28

	.type	.L__unnamed_23,@object          // @27
	.data
	.p2align	4, 0x0
.L__unnamed_23:
	.xword	.L.src
	.word	129                             // 0x81
	.word	17                              // 0x11
	.xword	.L.src.1
	.word	365                             // 0x16d
	.word	45                              // 0x2d
	.word	1                               // 0x1
	.zero	4
	.size	.L__unnamed_23, 40

	.type	.L.str.10,@object               // @.str.10
	.section	.rodata.str1.1,"aMS",@progbits,1
.L.str.10:
	.asciz	"failed to build summary\n"
	.size	.L.str.10, 25

	.type	.L__unnamed_24,@object          // @28
	.data
	.p2align	4, 0x0
.L__unnamed_24:
	.xword	.L.src
	.word	136                             // 0x88
	.word	17                              // 0x11
	.xword	.L.src.1
	.word	365                             // 0x16d
	.word	45                              // 0x2d
	.word	1                               // 0x1
	.zero	4
	.size	.L__unnamed_24, 40

	.type	.L.str.11,@object               // @.str.11
	.section	.rodata.str1.1,"aMS",@progbits,1
.L.str.11:
	.asciz	"failed to compute analysis\n"
	.size	.L.str.11, 28

	.type	.L.str.12,@object               // @.str.12
.L.str.12:
	.asciz	"metrics: reads=%zu valid=%zu rejected=%zu outliers=%zu rate=%.2fHz retained=%.2f\n"
	.size	.L.str.12, 82

	.type	.L__unnamed_25,@object          // @29
	.data
	.p2align	4, 0x0
.L__unnamed_25:
	.xword	.L.src
	.word	150                             // 0x96
	.word	20                              // 0x14
	.xword	.L__unnamed_45
	.byte	3                               // 0x3
	.byte	0                               // 0x0
	.zero	6
	.size	.L__unnamed_25, 32

	.type	.L.str.13,@object               // @.str.13
	.section	.rodata.str1.1,"aMS",@progbits,1
.L.str.13:
	.asciz	"summary: count=%zu min=%.2f max=%.2f mean=%.2f median=%.2f stddev=%.3f source=%d\n"
	.size	.L.str.13, 82

	.type	.L__unnamed_26,@object          // @30
	.data
	.p2align	4, 0x0
.L__unnamed_26:
	.xword	.L.src
	.word	154                             // 0x9a
	.word	20                              // 0x14
	.xword	.L__unnamed_45
	.byte	3                               // 0x3
	.byte	0                               // 0x0
	.zero	6
	.size	.L__unnamed_26, 32

	.type	.L__unnamed_27,@object          // @31
	.p2align	4, 0x0
.L__unnamed_27:
	.xword	.L.src
	.word	155                             // 0x9b
	.word	20                              // 0x14
	.xword	.L__unnamed_45
	.byte	3                               // 0x3
	.byte	0                               // 0x0
	.zero	6
	.size	.L__unnamed_27, 32

	.type	.L__unnamed_28,@object          // @32
	.p2align	4, 0x0
.L__unnamed_28:
	.xword	.L.src
	.word	156                             // 0x9c
	.word	20                              // 0x14
	.xword	.L__unnamed_45
	.byte	3                               // 0x3
	.byte	0                               // 0x0
	.zero	6
	.size	.L__unnamed_28, 32

	.type	.L__unnamed_29,@object          // @33
	.p2align	4, 0x0
.L__unnamed_29:
	.xword	.L.src
	.word	157                             // 0x9d
	.word	20                              // 0x14
	.xword	.L__unnamed_45
	.byte	3                               // 0x3
	.byte	0                               // 0x0
	.zero	6
	.size	.L__unnamed_29, 32

	.type	.L__unnamed_30,@object          // @34
	.p2align	4, 0x0
.L__unnamed_30:
	.xword	.L.src
	.word	158                             // 0x9e
	.word	20                              // 0x14
	.xword	.L__unnamed_45
	.byte	3                               // 0x3
	.byte	0                               // 0x0
	.zero	6
	.size	.L__unnamed_30, 32

	.type	.L__unnamed_47,@object          // @35
	.section	.rodata,"a",@progbits
	.p2align	4, 0x0
.L__unnamed_47:
	.hword	0                               // 0x0
	.hword	10                              // 0xa
	.asciz	"'critter_temperature_source_t'"
	.zero	1
	.size	.L__unnamed_47, 36

	.type	.L__unnamed_31,@object          // @36
	.data
	.p2align	4, 0x0
.L__unnamed_31:
	.xword	.L.src
	.word	159                             // 0x9f
	.word	25                              // 0x19
	.xword	.L__unnamed_47
	.byte	3                               // 0x3
	.byte	0                               // 0x0
	.zero	6
	.size	.L__unnamed_31, 32

	.type	.L.str.14,@object               // @.str.14
	.section	.rodata.str1.1,"aMS",@progbits,1
.L.str.14:
	.asciz	"analysis: current=%.2f predicted=%.2f trend=%.4f rate=%.4f hvac=%s heating=%s cooling=%s stable=%s\n"
	.size	.L.str.14, 100

	.type	.L__unnamed_32,@object          // @37
	.data
	.p2align	4, 0x0
.L__unnamed_32:
	.xword	.L.src
	.word	163                             // 0xa3
	.word	21                              // 0x15
	.xword	.L__unnamed_45
	.byte	3                               // 0x3
	.byte	0                               // 0x0
	.zero	6
	.size	.L__unnamed_32, 32

	.type	.L__unnamed_33,@object          // @38
	.p2align	4, 0x0
.L__unnamed_33:
	.xword	.L.src
	.word	164                             // 0xa4
	.word	21                              // 0x15
	.xword	.L__unnamed_45
	.byte	3                               // 0x3
	.byte	0                               // 0x0
	.zero	6
	.size	.L__unnamed_33, 32

	.type	.L__unnamed_34,@object          // @39
	.p2align	4, 0x0
.L__unnamed_34:
	.xword	.L.src
	.word	165                             // 0xa5
	.word	21                              // 0x15
	.xword	.L__unnamed_45
	.byte	3                               // 0x3
	.byte	0                               // 0x0
	.zero	6
	.size	.L__unnamed_34, 32

	.type	.L__unnamed_48,@object          // @40
	.section	.rodata,"a",@progbits
	.p2align	3, 0x0
.L__unnamed_48:
	.hword	0                               // 0x0
	.hword	6                               // 0x6
	.asciz	"'_Bool'"
	.size	.L__unnamed_48, 12

	.type	.L__unnamed_35,@object          // @41
	.data
	.p2align	4, 0x0
.L__unnamed_35:
	.xword	.L.src
	.word	166                             // 0xa6
	.word	21                              // 0x15
	.xword	.L__unnamed_48
	.size	.L__unnamed_35, 24

	.type	.L.str.15,@object               // @.str.15
	.section	.rodata.str1.1,"aMS",@progbits,1
.L.str.15:
	.asciz	"true"
	.size	.L.str.15, 5

	.type	.L.str.16,@object               // @.str.16
.L.str.16:
	.asciz	"false"
	.size	.L.str.16, 6

	.type	.L__unnamed_36,@object          // @42
	.data
	.p2align	4, 0x0
.L__unnamed_36:
	.xword	.L.src
	.word	167                             // 0xa7
	.word	21                              // 0x15
	.xword	.L__unnamed_48
	.size	.L__unnamed_36, 24

	.type	.L__unnamed_37,@object          // @43
	.p2align	4, 0x0
.L__unnamed_37:
	.xword	.L.src
	.word	168                             // 0xa8
	.word	21                              // 0x15
	.xword	.L__unnamed_48
	.byte	2                               // 0x2
	.byte	0                               // 0x0
	.zero	6
	.size	.L__unnamed_37, 32

	.type	.L__unnamed_38,@object          // @44
	.p2align	4, 0x0
.L__unnamed_38:
	.xword	.L.src
	.word	168                             // 0xa8
	.word	21                              // 0x15
	.xword	.L__unnamed_48
	.size	.L__unnamed_38, 24

	.type	.L__unnamed_39,@object          // @45
	.p2align	4, 0x0
.L__unnamed_39:
	.xword	.L.src
	.word	169                             // 0xa9
	.word	21                              // 0x15
	.xword	.L__unnamed_48
	.byte	3                               // 0x3
	.byte	0                               // 0x0
	.zero	6
	.size	.L__unnamed_39, 32

	.type	.L__unnamed_40,@object          // @46
	.p2align	4, 0x0
.L__unnamed_40:
	.xword	.L.src
	.word	169                             // 0xa9
	.word	21                              // 0x15
	.xword	.L__unnamed_48
	.size	.L__unnamed_40, 24

	.type	.L__unnamed_41,@object          // @47
	.p2align	4, 0x0
.L__unnamed_41:
	.xword	.L.src
	.word	179                             // 0xb3
	.word	17                              // 0x11
	.xword	.L.src.1
	.word	365                             // 0x16d
	.word	45                              // 0x2d
	.word	1                               // 0x1
	.zero	4
	.size	.L__unnamed_41, 40

	.type	.L.str.17,@object               // @.str.17
	.section	.rodata.str1.1,"aMS",@progbits,1
.L.str.17:
	.asciz	"failed to save metrics during one-minute collection\n"
	.size	.L.str.17, 53

	.file	3 "/Users/matthewketas/Desktop/University of Pittsburgh/Senior Year/7th Semester/Embedded Systems/ECE_2160_Group_C" "Development/CritterProduct/Pilot/Memory/critter_memory.h"
	.file	4 "/private/tmp/zig-aarch64-macos-0.16.0/lib/include" "__stddef_size_t.h"
	.file	5 "/private/tmp/zig-aarch64-macos-0.16.0/lib/libc/include/generic-glibc/bits" "types.h"
	.file	6 "/private/tmp/zig-aarch64-macos-0.16.0/lib/libc/include/generic-glibc/bits/types" "struct_timespec.h"
	.section	.debug_abbrev,"",@progbits
	.byte	1                               // Abbreviation Code
	.byte	17                              // DW_TAG_compile_unit
	.byte	1                               // DW_CHILDREN_yes
	.byte	37                              // DW_AT_producer
	.byte	14                              // DW_FORM_strp
	.byte	19                              // DW_AT_language
	.byte	5                               // DW_FORM_data2
	.byte	3                               // DW_AT_name
	.byte	14                              // DW_FORM_strp
	.byte	16                              // DW_AT_stmt_list
	.byte	23                              // DW_FORM_sec_offset
	.byte	27                              // DW_AT_comp_dir
	.byte	14                              // DW_FORM_strp
	.byte	17                              // DW_AT_low_pc
	.byte	1                               // DW_FORM_addr
	.byte	18                              // DW_AT_high_pc
	.byte	6                               // DW_FORM_data4
	.byte	0                               // EOM(1)
	.byte	0                               // EOM(2)
	.byte	2                               // Abbreviation Code
	.byte	52                              // DW_TAG_variable
	.byte	0                               // DW_CHILDREN_no
	.byte	73                              // DW_AT_type
	.byte	19                              // DW_FORM_ref4
	.byte	58                              // DW_AT_decl_file
	.byte	11                              // DW_FORM_data1
	.byte	59                              // DW_AT_decl_line
	.byte	11                              // DW_FORM_data1
	.byte	2                               // DW_AT_location
	.byte	24                              // DW_FORM_exprloc
	.byte	0                               // EOM(1)
	.byte	0                               // EOM(2)
	.byte	3                               // Abbreviation Code
	.byte	1                               // DW_TAG_array_type
	.byte	1                               // DW_CHILDREN_yes
	.byte	73                              // DW_AT_type
	.byte	19                              // DW_FORM_ref4
	.byte	0                               // EOM(1)
	.byte	0                               // EOM(2)
	.byte	4                               // Abbreviation Code
	.byte	33                              // DW_TAG_subrange_type
	.byte	0                               // DW_CHILDREN_no
	.byte	73                              // DW_AT_type
	.byte	19                              // DW_FORM_ref4
	.byte	55                              // DW_AT_count
	.byte	11                              // DW_FORM_data1
	.byte	0                               // EOM(1)
	.byte	0                               // EOM(2)
	.byte	5                               // Abbreviation Code
	.byte	36                              // DW_TAG_base_type
	.byte	0                               // DW_CHILDREN_no
	.byte	3                               // DW_AT_name
	.byte	14                              // DW_FORM_strp
	.byte	62                              // DW_AT_encoding
	.byte	11                              // DW_FORM_data1
	.byte	11                              // DW_AT_byte_size
	.byte	11                              // DW_FORM_data1
	.byte	0                               // EOM(1)
	.byte	0                               // EOM(2)
	.byte	6                               // Abbreviation Code
	.byte	36                              // DW_TAG_base_type
	.byte	0                               // DW_CHILDREN_no
	.byte	3                               // DW_AT_name
	.byte	14                              // DW_FORM_strp
	.byte	11                              // DW_AT_byte_size
	.byte	11                              // DW_FORM_data1
	.byte	62                              // DW_AT_encoding
	.byte	11                              // DW_FORM_data1
	.byte	0                               // EOM(1)
	.byte	0                               // EOM(2)
	.byte	7                               // Abbreviation Code
	.byte	4                               // DW_TAG_enumeration_type
	.byte	1                               // DW_CHILDREN_yes
	.byte	73                              // DW_AT_type
	.byte	19                              // DW_FORM_ref4
	.byte	11                              // DW_AT_byte_size
	.byte	11                              // DW_FORM_data1
	.byte	58                              // DW_AT_decl_file
	.byte	11                              // DW_FORM_data1
	.byte	59                              // DW_AT_decl_line
	.byte	11                              // DW_FORM_data1
	.byte	0                               // EOM(1)
	.byte	0                               // EOM(2)
	.byte	8                               // Abbreviation Code
	.byte	40                              // DW_TAG_enumerator
	.byte	0                               // DW_CHILDREN_no
	.byte	3                               // DW_AT_name
	.byte	14                              // DW_FORM_strp
	.byte	28                              // DW_AT_const_value
	.byte	15                              // DW_FORM_udata
	.byte	0                               // EOM(1)
	.byte	0                               // EOM(2)
	.byte	9                               // Abbreviation Code
	.byte	46                              // DW_TAG_subprogram
	.byte	1                               // DW_CHILDREN_yes
	.byte	17                              // DW_AT_low_pc
	.byte	1                               // DW_FORM_addr
	.byte	18                              // DW_AT_high_pc
	.byte	6                               // DW_FORM_data4
	.byte	64                              // DW_AT_frame_base
	.byte	24                              // DW_FORM_exprloc
	.byte	3                               // DW_AT_name
	.byte	14                              // DW_FORM_strp
	.byte	58                              // DW_AT_decl_file
	.byte	11                              // DW_FORM_data1
	.byte	59                              // DW_AT_decl_line
	.byte	11                              // DW_FORM_data1
	.byte	39                              // DW_AT_prototyped
	.byte	25                              // DW_FORM_flag_present
	.byte	73                              // DW_AT_type
	.byte	19                              // DW_FORM_ref4
	.byte	63                              // DW_AT_external
	.byte	25                              // DW_FORM_flag_present
	.byte	0                               // EOM(1)
	.byte	0                               // EOM(2)
	.byte	10                              // Abbreviation Code
	.byte	52                              // DW_TAG_variable
	.byte	0                               // DW_CHILDREN_no
	.byte	2                               // DW_AT_location
	.byte	24                              // DW_FORM_exprloc
	.byte	3                               // DW_AT_name
	.byte	14                              // DW_FORM_strp
	.byte	58                              // DW_AT_decl_file
	.byte	11                              // DW_FORM_data1
	.byte	59                              // DW_AT_decl_line
	.byte	11                              // DW_FORM_data1
	.byte	73                              // DW_AT_type
	.byte	19                              // DW_FORM_ref4
	.byte	0                               // EOM(1)
	.byte	0                               // EOM(2)
	.byte	11                              // Abbreviation Code
	.byte	11                              // DW_TAG_lexical_block
	.byte	1                               // DW_CHILDREN_yes
	.byte	17                              // DW_AT_low_pc
	.byte	1                               // DW_FORM_addr
	.byte	18                              // DW_AT_high_pc
	.byte	6                               // DW_FORM_data4
	.byte	0                               // EOM(1)
	.byte	0                               // EOM(2)
	.byte	12                              // Abbreviation Code
	.byte	22                              // DW_TAG_typedef
	.byte	0                               // DW_CHILDREN_no
	.byte	73                              // DW_AT_type
	.byte	19                              // DW_FORM_ref4
	.byte	3                               // DW_AT_name
	.byte	14                              // DW_FORM_strp
	.byte	58                              // DW_AT_decl_file
	.byte	11                              // DW_FORM_data1
	.byte	59                              // DW_AT_decl_line
	.byte	11                              // DW_FORM_data1
	.byte	0                               // EOM(1)
	.byte	0                               // EOM(2)
	.byte	13                              // Abbreviation Code
	.byte	19                              // DW_TAG_structure_type
	.byte	1                               // DW_CHILDREN_yes
	.byte	11                              // DW_AT_byte_size
	.byte	11                              // DW_FORM_data1
	.byte	58                              // DW_AT_decl_file
	.byte	11                              // DW_FORM_data1
	.byte	59                              // DW_AT_decl_line
	.byte	11                              // DW_FORM_data1
	.byte	0                               // EOM(1)
	.byte	0                               // EOM(2)
	.byte	14                              // Abbreviation Code
	.byte	13                              // DW_TAG_member
	.byte	0                               // DW_CHILDREN_no
	.byte	3                               // DW_AT_name
	.byte	14                              // DW_FORM_strp
	.byte	73                              // DW_AT_type
	.byte	19                              // DW_FORM_ref4
	.byte	58                              // DW_AT_decl_file
	.byte	11                              // DW_FORM_data1
	.byte	59                              // DW_AT_decl_line
	.byte	11                              // DW_FORM_data1
	.byte	56                              // DW_AT_data_member_location
	.byte	11                              // DW_FORM_data1
	.byte	0                               // EOM(1)
	.byte	0                               // EOM(2)
	.byte	15                              // Abbreviation Code
	.byte	15                              // DW_TAG_pointer_type
	.byte	0                               // DW_CHILDREN_no
	.byte	73                              // DW_AT_type
	.byte	19                              // DW_FORM_ref4
	.byte	0                               // EOM(1)
	.byte	0                               // EOM(2)
	.byte	16                              // Abbreviation Code
	.byte	38                              // DW_TAG_const_type
	.byte	0                               // DW_CHILDREN_no
	.byte	73                              // DW_AT_type
	.byte	19                              // DW_FORM_ref4
	.byte	0                               // EOM(1)
	.byte	0                               // EOM(2)
	.byte	17                              // Abbreviation Code
	.byte	19                              // DW_TAG_structure_type
	.byte	1                               // DW_CHILDREN_yes
	.byte	3                               // DW_AT_name
	.byte	14                              // DW_FORM_strp
	.byte	11                              // DW_AT_byte_size
	.byte	11                              // DW_FORM_data1
	.byte	58                              // DW_AT_decl_file
	.byte	11                              // DW_FORM_data1
	.byte	59                              // DW_AT_decl_line
	.byte	11                              // DW_FORM_data1
	.byte	0                               // EOM(1)
	.byte	0                               // EOM(2)
	.byte	0                               // EOM(3)
	.section	.debug_info,"",@progbits
.Lcu_begin0:
	.word	.Ldebug_info_end0-.Ldebug_info_start0 // Length of Unit
.Ldebug_info_start0:
	.hword	4                               // DWARF version number
	.word	.debug_abbrev                   // Offset Into Abbrev. Section
	.byte	8                               // Address Size (in bytes)
	.byte	1                               // Abbrev [1] 0xb:0x67b DW_TAG_compile_unit
	.word	.Linfo_string0                  // DW_AT_producer
	.hword	29                              // DW_AT_language
	.word	.Linfo_string1                  // DW_AT_name
	.word	.Lline_table_start0             // DW_AT_stmt_list
	.word	.Linfo_string2                  // DW_AT_comp_dir
	.xword	.Lfunc_begin0                   // DW_AT_low_pc
	.word	.Lfunc_end0-.Lfunc_begin0       // DW_AT_high_pc
	.byte	2                               // Abbrev [2] 0x2a:0x11 DW_TAG_variable
	.word	59                              // DW_AT_type
	.byte	1                               // DW_AT_decl_file
	.byte	35                              // DW_AT_decl_line
	.byte	9                               // DW_AT_location
	.byte	3
	.xword	.L.str
	.byte	3                               // Abbrev [3] 0x3b:0xc DW_TAG_array_type
	.word	71                              // DW_AT_type
	.byte	4                               // Abbrev [4] 0x40:0x6 DW_TAG_subrange_type
	.word	78                              // DW_AT_type
	.byte	29                              // DW_AT_count
	.byte	0                               // End Of Children Mark
	.byte	5                               // Abbrev [5] 0x47:0x7 DW_TAG_base_type
	.word	.Linfo_string3                  // DW_AT_name
	.byte	8                               // DW_AT_encoding
	.byte	1                               // DW_AT_byte_size
	.byte	6                               // Abbrev [6] 0x4e:0x7 DW_TAG_base_type
	.word	.Linfo_string4                  // DW_AT_name
	.byte	8                               // DW_AT_byte_size
	.byte	7                               // DW_AT_encoding
	.byte	2                               // Abbrev [2] 0x55:0x11 DW_TAG_variable
	.word	102                             // DW_AT_type
	.byte	1                               // DW_AT_decl_file
	.byte	41                              // DW_AT_decl_line
	.byte	9                               // DW_AT_location
	.byte	3
	.xword	.L.str.3
	.byte	3                               // Abbrev [3] 0x66:0xc DW_TAG_array_type
	.word	71                              // DW_AT_type
	.byte	4                               // Abbrev [4] 0x6b:0x6 DW_TAG_subrange_type
	.word	78                              // DW_AT_type
	.byte	46                              // DW_AT_count
	.byte	0                               // End Of Children Mark
	.byte	2                               // Abbrev [2] 0x72:0x11 DW_TAG_variable
	.word	131                             // DW_AT_type
	.byte	1                               // DW_AT_decl_file
	.byte	55                              // DW_AT_decl_line
	.byte	9                               // DW_AT_location
	.byte	3
	.xword	.L.str.4
	.byte	3                               // Abbrev [3] 0x83:0xc DW_TAG_array_type
	.word	71                              // DW_AT_type
	.byte	4                               // Abbrev [4] 0x88:0x6 DW_TAG_subrange_type
	.word	78                              // DW_AT_type
	.byte	52                              // DW_AT_count
	.byte	0                               // End Of Children Mark
	.byte	2                               // Abbrev [2] 0x8f:0x11 DW_TAG_variable
	.word	131                             // DW_AT_type
	.byte	1                               // DW_AT_decl_file
	.byte	62                              // DW_AT_decl_line
	.byte	9                               // DW_AT_location
	.byte	3
	.xword	.L.str.5
	.byte	2                               // Abbrev [2] 0xa0:0x11 DW_TAG_variable
	.word	177                             // DW_AT_type
	.byte	1                               // DW_AT_decl_file
	.byte	82                              // DW_AT_decl_line
	.byte	9                               // DW_AT_location
	.byte	3
	.xword	.L.str.6
	.byte	3                               // Abbrev [3] 0xb1:0xc DW_TAG_array_type
	.word	71                              // DW_AT_type
	.byte	4                               // Abbrev [4] 0xb6:0x6 DW_TAG_subrange_type
	.word	78                              // DW_AT_type
	.byte	50                              // DW_AT_count
	.byte	0                               // End Of Children Mark
	.byte	2                               // Abbrev [2] 0xbd:0x11 DW_TAG_variable
	.word	206                             // DW_AT_type
	.byte	1                               // DW_AT_decl_file
	.byte	96                              // DW_AT_decl_line
	.byte	9                               // DW_AT_location
	.byte	3
	.xword	.L.str.7
	.byte	3                               // Abbrev [3] 0xce:0xc DW_TAG_array_type
	.word	71                              // DW_AT_type
	.byte	4                               // Abbrev [4] 0xd3:0x6 DW_TAG_subrange_type
	.word	78                              // DW_AT_type
	.byte	31                              // DW_AT_count
	.byte	0                               // End Of Children Mark
	.byte	2                               // Abbrev [2] 0xda:0x11 DW_TAG_variable
	.word	235                             // DW_AT_type
	.byte	1                               // DW_AT_decl_file
	.byte	108                             // DW_AT_decl_line
	.byte	9                               // DW_AT_location
	.byte	3
	.xword	.L.str.8
	.byte	3                               // Abbrev [3] 0xeb:0xc DW_TAG_array_type
	.word	71                              // DW_AT_type
	.byte	4                               // Abbrev [4] 0xf0:0x6 DW_TAG_subrange_type
	.word	78                              // DW_AT_type
	.byte	27                              // DW_AT_count
	.byte	0                               // End Of Children Mark
	.byte	2                               // Abbrev [2] 0xf7:0x11 DW_TAG_variable
	.word	264                             // DW_AT_type
	.byte	1                               // DW_AT_decl_file
	.byte	125                             // DW_AT_decl_line
	.byte	9                               // DW_AT_location
	.byte	3
	.xword	.L.str.9
	.byte	3                               // Abbrev [3] 0x108:0xc DW_TAG_array_type
	.word	71                              // DW_AT_type
	.byte	4                               // Abbrev [4] 0x10d:0x6 DW_TAG_subrange_type
	.word	78                              // DW_AT_type
	.byte	28                              // DW_AT_count
	.byte	0                               // End Of Children Mark
	.byte	2                               // Abbrev [2] 0x114:0x11 DW_TAG_variable
	.word	293                             // DW_AT_type
	.byte	1                               // DW_AT_decl_file
	.byte	129                             // DW_AT_decl_line
	.byte	9                               // DW_AT_location
	.byte	3
	.xword	.L.str.10
	.byte	3                               // Abbrev [3] 0x125:0xc DW_TAG_array_type
	.word	71                              // DW_AT_type
	.byte	4                               // Abbrev [4] 0x12a:0x6 DW_TAG_subrange_type
	.word	78                              // DW_AT_type
	.byte	25                              // DW_AT_count
	.byte	0                               // End Of Children Mark
	.byte	2                               // Abbrev [2] 0x131:0x11 DW_TAG_variable
	.word	264                             // DW_AT_type
	.byte	1                               // DW_AT_decl_file
	.byte	136                             // DW_AT_decl_line
	.byte	9                               // DW_AT_location
	.byte	3
	.xword	.L.str.11
	.byte	2                               // Abbrev [2] 0x142:0x11 DW_TAG_variable
	.word	339                             // DW_AT_type
	.byte	1                               // DW_AT_decl_file
	.byte	144                             // DW_AT_decl_line
	.byte	9                               // DW_AT_location
	.byte	3
	.xword	.L.str.12
	.byte	3                               // Abbrev [3] 0x153:0xc DW_TAG_array_type
	.word	71                              // DW_AT_type
	.byte	4                               // Abbrev [4] 0x158:0x6 DW_TAG_subrange_type
	.word	78                              // DW_AT_type
	.byte	82                              // DW_AT_count
	.byte	0                               // End Of Children Mark
	.byte	2                               // Abbrev [2] 0x15f:0x11 DW_TAG_variable
	.word	339                             // DW_AT_type
	.byte	1                               // DW_AT_decl_file
	.byte	152                             // DW_AT_decl_line
	.byte	9                               // DW_AT_location
	.byte	3
	.xword	.L.str.13
	.byte	2                               // Abbrev [2] 0x170:0x11 DW_TAG_variable
	.word	385                             // DW_AT_type
	.byte	1                               // DW_AT_decl_file
	.byte	161                             // DW_AT_decl_line
	.byte	9                               // DW_AT_location
	.byte	3
	.xword	.L.str.14
	.byte	3                               // Abbrev [3] 0x181:0xc DW_TAG_array_type
	.word	71                              // DW_AT_type
	.byte	4                               // Abbrev [4] 0x186:0x6 DW_TAG_subrange_type
	.word	78                              // DW_AT_type
	.byte	100                             // DW_AT_count
	.byte	0                               // End Of Children Mark
	.byte	2                               // Abbrev [2] 0x18d:0x11 DW_TAG_variable
	.word	414                             // DW_AT_type
	.byte	1                               // DW_AT_decl_file
	.byte	166                             // DW_AT_decl_line
	.byte	9                               // DW_AT_location
	.byte	3
	.xword	.L.str.15
	.byte	3                               // Abbrev [3] 0x19e:0xc DW_TAG_array_type
	.word	71                              // DW_AT_type
	.byte	4                               // Abbrev [4] 0x1a3:0x6 DW_TAG_subrange_type
	.word	78                              // DW_AT_type
	.byte	5                               // DW_AT_count
	.byte	0                               // End Of Children Mark
	.byte	2                               // Abbrev [2] 0x1aa:0x11 DW_TAG_variable
	.word	443                             // DW_AT_type
	.byte	1                               // DW_AT_decl_file
	.byte	166                             // DW_AT_decl_line
	.byte	9                               // DW_AT_location
	.byte	3
	.xword	.L.str.16
	.byte	3                               // Abbrev [3] 0x1bb:0xc DW_TAG_array_type
	.word	71                              // DW_AT_type
	.byte	4                               // Abbrev [4] 0x1c0:0x6 DW_TAG_subrange_type
	.word	78                              // DW_AT_type
	.byte	6                               // DW_AT_count
	.byte	0                               // End Of Children Mark
	.byte	2                               // Abbrev [2] 0x1c7:0x11 DW_TAG_variable
	.word	472                             // DW_AT_type
	.byte	1                               // DW_AT_decl_file
	.byte	179                             // DW_AT_decl_line
	.byte	9                               // DW_AT_location
	.byte	3
	.xword	.L.str.17
	.byte	3                               // Abbrev [3] 0x1d8:0xc DW_TAG_array_type
	.word	71                              // DW_AT_type
	.byte	4                               // Abbrev [4] 0x1dd:0x6 DW_TAG_subrange_type
	.word	78                              // DW_AT_type
	.byte	53                              // DW_AT_count
	.byte	0                               // End Of Children Mark
	.byte	7                               // Abbrev [7] 0x1e4:0x21 DW_TAG_enumeration_type
	.word	517                             // DW_AT_type
	.byte	4                               // DW_AT_byte_size
	.byte	2                               // DW_AT_decl_file
	.byte	12                              // DW_AT_decl_line
	.byte	8                               // Abbrev [8] 0x1ec:0x6 DW_TAG_enumerator
	.word	.Linfo_string6                  // DW_AT_name
	.byte	0                               // DW_AT_const_value
	.byte	8                               // Abbrev [8] 0x1f2:0x6 DW_TAG_enumerator
	.word	.Linfo_string7                  // DW_AT_name
	.byte	1                               // DW_AT_const_value
	.byte	8                               // Abbrev [8] 0x1f8:0x6 DW_TAG_enumerator
	.word	.Linfo_string8                  // DW_AT_name
	.byte	2                               // DW_AT_const_value
	.byte	8                               // Abbrev [8] 0x1fe:0x6 DW_TAG_enumerator
	.word	.Linfo_string9                  // DW_AT_name
	.byte	3                               // DW_AT_const_value
	.byte	0                               // End Of Children Mark
	.byte	5                               // Abbrev [5] 0x205:0x7 DW_TAG_base_type
	.word	.Linfo_string5                  // DW_AT_name
	.byte	7                               // DW_AT_encoding
	.byte	4                               // DW_AT_byte_size
	.byte	5                               // Abbrev [5] 0x20c:0x7 DW_TAG_base_type
	.word	.Linfo_string10                 // DW_AT_name
	.byte	4                               // DW_AT_encoding
	.byte	8                               // DW_AT_byte_size
	.byte	5                               // Abbrev [5] 0x213:0x7 DW_TAG_base_type
	.word	.Linfo_string11                 // DW_AT_name
	.byte	5                               // DW_AT_encoding
	.byte	4                               // DW_AT_byte_size
	.byte	9                               // Abbrev [9] 0x21a:0x17f DW_TAG_subprogram
	.xword	.Lfunc_begin0                   // DW_AT_low_pc
	.word	.Lfunc_end0-.Lfunc_begin0       // DW_AT_high_pc
	.byte	1                               // DW_AT_frame_base
	.byte	109
	.word	.Linfo_string12                 // DW_AT_name
	.byte	1                               // DW_AT_decl_file
	.byte	12                              // DW_AT_decl_line
                                        // DW_AT_prototyped
	.word	531                             // DW_AT_type
                                        // DW_AT_external
	.byte	10                              // Abbrev [10] 0x233:0xf DW_TAG_variable
	.byte	3                               // DW_AT_location
	.byte	145
	.ascii	"\250~"
	.word	.Linfo_string13                 // DW_AT_name
	.byte	1                               // DW_AT_decl_file
	.byte	14                              // DW_AT_decl_line
	.word	921                             // DW_AT_type
	.byte	10                              // Abbrev [10] 0x242:0xf DW_TAG_variable
	.byte	3                               // DW_AT_location
	.byte	145
	.ascii	"\360~"
	.word	.Linfo_string36                 // DW_AT_name
	.byte	1                               // DW_AT_decl_file
	.byte	15                              // DW_AT_decl_line
	.word	1186                            // DW_AT_type
	.byte	10                              // Abbrev [10] 0x251:0xf DW_TAG_variable
	.byte	3                               // DW_AT_location
	.byte	145
	.ascii	"\310}"
	.word	.Linfo_string50                 // DW_AT_name
	.byte	1                               // DW_AT_decl_file
	.byte	16                              // DW_AT_decl_line
	.word	1382                            // DW_AT_type
	.byte	10                              // Abbrev [10] 0x260:0xf DW_TAG_variable
	.byte	3                               // DW_AT_location
	.byte	145
	.ascii	"\340|"
	.word	.Linfo_string68                 // DW_AT_name
	.byte	1                               // DW_AT_decl_file
	.byte	18                              // DW_AT_decl_line
	.word	1602                            // DW_AT_type
	.byte	10                              // Abbrev [10] 0x26f:0xf DW_TAG_variable
	.byte	3                               // DW_AT_location
	.byte	145
	.ascii	"\330|"
	.word	.Linfo_string69                 // DW_AT_name
	.byte	1                               // DW_AT_decl_file
	.byte	19                              // DW_AT_decl_line
	.word	1602                            // DW_AT_type
	.byte	10                              // Abbrev [10] 0x27e:0xf DW_TAG_variable
	.byte	3                               // DW_AT_location
	.byte	145
	.ascii	"\320|"
	.word	.Linfo_string55                 // DW_AT_name
	.byte	1                               // DW_AT_decl_file
	.byte	20                              // DW_AT_decl_line
	.word	1602                            // DW_AT_type
	.byte	10                              // Abbrev [10] 0x28d:0xf DW_TAG_variable
	.byte	3                               // DW_AT_location
	.byte	145
	.ascii	"\270}"
	.word	.Linfo_string70                 // DW_AT_name
	.byte	1                               // DW_AT_decl_file
	.byte	22                              // DW_AT_decl_line
	.word	1607                            // DW_AT_type
	.byte	10                              // Abbrev [10] 0x29c:0xf DW_TAG_variable
	.byte	3                               // DW_AT_location
	.byte	145
	.ascii	"\250}"
	.word	.Linfo_string77                 // DW_AT_name
	.byte	1                               // DW_AT_decl_file
	.byte	23                              // DW_AT_decl_line
	.word	1607                            // DW_AT_type
	.byte	10                              // Abbrev [10] 0x2ab:0xf DW_TAG_variable
	.byte	3                               // DW_AT_location
	.byte	145
	.ascii	"\310|"
	.word	.Linfo_string78                 // DW_AT_name
	.byte	1                               // DW_AT_decl_file
	.byte	25                              // DW_AT_decl_line
	.word	524                             // DW_AT_type
	.byte	10                              // Abbrev [10] 0x2ba:0xf DW_TAG_variable
	.byte	3                               // DW_AT_location
	.byte	145
	.ascii	"\300|"
	.word	.Linfo_string79                 // DW_AT_name
	.byte	1                               // DW_AT_decl_file
	.byte	26                              // DW_AT_decl_line
	.word	524                             // DW_AT_type
	.byte	10                              // Abbrev [10] 0x2c9:0xf DW_TAG_variable
	.byte	3                               // DW_AT_location
	.byte	145
	.ascii	"\270|"
	.word	.Linfo_string80                 // DW_AT_name
	.byte	1                               // DW_AT_decl_file
	.byte	27                              // DW_AT_decl_line
	.word	1168                            // DW_AT_type
	.byte	10                              // Abbrev [10] 0x2d8:0xf DW_TAG_variable
	.byte	3                               // DW_AT_location
	.byte	145
	.ascii	"\260|"
	.word	.Linfo_string31                 // DW_AT_name
	.byte	1                               // DW_AT_decl_file
	.byte	28                              // DW_AT_decl_line
	.word	1168                            // DW_AT_type
	.byte	10                              // Abbrev [10] 0x2e7:0xf DW_TAG_variable
	.byte	3                               // DW_AT_location
	.byte	145
	.ascii	"\250|"
	.word	.Linfo_string32                 // DW_AT_name
	.byte	1                               // DW_AT_decl_file
	.byte	29                              // DW_AT_decl_line
	.word	1168                            // DW_AT_type
	.byte	10                              // Abbrev [10] 0x2f6:0xf DW_TAG_variable
	.byte	3                               // DW_AT_location
	.byte	145
	.ascii	"\240|"
	.word	.Linfo_string33                 // DW_AT_name
	.byte	1                               // DW_AT_decl_file
	.byte	30                              // DW_AT_decl_line
	.word	1168                            // DW_AT_type
	.byte	10                              // Abbrev [10] 0x305:0xf DW_TAG_variable
	.byte	3                               // DW_AT_location
	.byte	145
	.ascii	"\230|"
	.word	.Linfo_string81                 // DW_AT_name
	.byte	1                               // DW_AT_decl_file
	.byte	31                              // DW_AT_decl_line
	.word	524                             // DW_AT_type
	.byte	11                              // Abbrev [11] 0x314:0x84 DW_TAG_lexical_block
	.xword	.Ltmp6                          // DW_AT_low_pc
	.word	.Ltmp29-.Ltmp6                  // DW_AT_high_pc
	.byte	10                              // Abbrev [10] 0x321:0xf DW_TAG_variable
	.byte	3                               // DW_AT_location
	.byte	145
	.ascii	"\200}"
	.word	.Linfo_string82                 // DW_AT_name
	.byte	1                               // DW_AT_decl_file
	.byte	48                              // DW_AT_decl_line
	.word	1050                            // DW_AT_type
	.byte	10                              // Abbrev [10] 0x330:0xf DW_TAG_variable
	.byte	3                               // DW_AT_location
	.byte	145
	.ascii	"\224|"
	.word	.Linfo_string83                 // DW_AT_name
	.byte	1                               // DW_AT_decl_file
	.byte	49                              // DW_AT_decl_line
	.word	531                             // DW_AT_type
	.byte	11                              // Abbrev [11] 0x33f:0x3b DW_TAG_lexical_block
	.xword	.Ltmp20                         // DW_AT_low_pc
	.word	.Ltmp21-.Ltmp20                 // DW_AT_high_pc
	.byte	10                              // Abbrev [10] 0x34c:0xf DW_TAG_variable
	.byte	3                               // DW_AT_location
	.byte	145
	.ascii	"\220|"
	.word	.Linfo_string84                 // DW_AT_name
	.byte	1                               // DW_AT_decl_file
	.byte	92                              // DW_AT_decl_line
	.word	531                             // DW_AT_type
	.byte	10                              // Abbrev [10] 0x35b:0xf DW_TAG_variable
	.byte	3                               // DW_AT_location
	.byte	145
	.ascii	"\214|"
	.word	.Linfo_string85                 // DW_AT_name
	.byte	1                               // DW_AT_decl_file
	.byte	93                              // DW_AT_decl_line
	.word	531                             // DW_AT_type
	.byte	10                              // Abbrev [10] 0x36a:0xf DW_TAG_variable
	.byte	3                               // DW_AT_location
	.byte	145
	.ascii	"\210|"
	.word	.Linfo_string86                 // DW_AT_name
	.byte	1                               // DW_AT_decl_file
	.byte	94                              // DW_AT_decl_line
	.word	531                             // DW_AT_type
	.byte	0                               // End Of Children Mark
	.byte	11                              // Abbrev [11] 0x37a:0x1d DW_TAG_lexical_block
	.xword	.Ltmp22                         // DW_AT_low_pc
	.word	.Ltmp26-.Ltmp22                 // DW_AT_high_pc
	.byte	10                              // Abbrev [10] 0x387:0xf DW_TAG_variable
	.byte	3                               // DW_AT_location
	.byte	145
	.ascii	"\360|"
	.word	.Linfo_string87                 // DW_AT_name
	.byte	1                               // DW_AT_decl_file
	.byte	104                             // DW_AT_decl_line
	.word	1607                            // DW_AT_type
	.byte	0                               // End Of Children Mark
	.byte	0                               // End Of Children Mark
	.byte	0                               // End Of Children Mark
	.byte	12                              // Abbrev [12] 0x399:0xb DW_TAG_typedef
	.word	932                             // DW_AT_type
	.word	.Linfo_string35                 // DW_AT_name
	.byte	3                               // DW_AT_decl_file
	.byte	21                              // DW_AT_decl_line
	.byte	13                              // Abbrev [13] 0x3a4:0x71 DW_TAG_structure_type
	.byte	72                              // DW_AT_byte_size
	.byte	3                               // DW_AT_decl_file
	.byte	10                              // DW_AT_decl_line
	.byte	14                              // Abbrev [14] 0x3a8:0xc DW_TAG_member
	.word	.Linfo_string14                 // DW_AT_name
	.word	1045                            // DW_AT_type
	.byte	3                               // DW_AT_decl_file
	.byte	12                              // DW_AT_decl_line
	.byte	0                               // DW_AT_data_member_location
	.byte	14                              // Abbrev [14] 0x3b4:0xc DW_TAG_member
	.word	.Linfo_string25                 // DW_AT_name
	.word	1168                            // DW_AT_type
	.byte	3                               // DW_AT_decl_file
	.byte	13                              // DW_AT_decl_line
	.byte	8                               // DW_AT_data_member_location
	.byte	14                              // Abbrev [14] 0x3c0:0xc DW_TAG_member
	.word	.Linfo_string28                 // DW_AT_name
	.word	1168                            // DW_AT_type
	.byte	3                               // DW_AT_decl_file
	.byte	14                              // DW_AT_decl_line
	.byte	16                              // DW_AT_data_member_location
	.byte	14                              // Abbrev [14] 0x3cc:0xc DW_TAG_member
	.word	.Linfo_string29                 // DW_AT_name
	.word	1168                            // DW_AT_type
	.byte	3                               // DW_AT_decl_file
	.byte	15                              // DW_AT_decl_line
	.byte	24                              // DW_AT_data_member_location
	.byte	14                              // Abbrev [14] 0x3d8:0xc DW_TAG_member
	.word	.Linfo_string30                 // DW_AT_name
	.word	1168                            // DW_AT_type
	.byte	3                               // DW_AT_decl_file
	.byte	16                              // DW_AT_decl_line
	.byte	32                              // DW_AT_data_member_location
	.byte	14                              // Abbrev [14] 0x3e4:0xc DW_TAG_member
	.word	.Linfo_string31                 // DW_AT_name
	.word	1168                            // DW_AT_type
	.byte	3                               // DW_AT_decl_file
	.byte	17                              // DW_AT_decl_line
	.byte	40                              // DW_AT_data_member_location
	.byte	14                              // Abbrev [14] 0x3f0:0xc DW_TAG_member
	.word	.Linfo_string32                 // DW_AT_name
	.word	1168                            // DW_AT_type
	.byte	3                               // DW_AT_decl_file
	.byte	18                              // DW_AT_decl_line
	.byte	48                              // DW_AT_data_member_location
	.byte	14                              // Abbrev [14] 0x3fc:0xc DW_TAG_member
	.word	.Linfo_string33                 // DW_AT_name
	.word	1168                            // DW_AT_type
	.byte	3                               // DW_AT_decl_file
	.byte	19                              // DW_AT_decl_line
	.byte	56                              // DW_AT_data_member_location
	.byte	14                              // Abbrev [14] 0x408:0xc DW_TAG_member
	.word	.Linfo_string34                 // DW_AT_name
	.word	524                             // DW_AT_type
	.byte	3                               // DW_AT_decl_file
	.byte	20                              // DW_AT_decl_line
	.byte	64                              // DW_AT_data_member_location
	.byte	0                               // End Of Children Mark
	.byte	15                              // Abbrev [15] 0x415:0x5 DW_TAG_pointer_type
	.word	1050                            // DW_AT_type
	.byte	12                              // Abbrev [12] 0x41a:0xb DW_TAG_typedef
	.word	1061                            // DW_AT_type
	.word	.Linfo_string24                 // DW_AT_name
	.byte	2                               // DW_AT_decl_file
	.byte	29                              // DW_AT_decl_line
	.byte	13                              // Abbrev [13] 0x425:0x59 DW_TAG_structure_type
	.byte	40                              // DW_AT_byte_size
	.byte	2                               // DW_AT_decl_file
	.byte	20                              // DW_AT_decl_line
	.byte	14                              // Abbrev [14] 0x429:0xc DW_TAG_member
	.word	.Linfo_string15                 // DW_AT_name
	.word	524                             // DW_AT_type
	.byte	2                               // DW_AT_decl_file
	.byte	22                              // DW_AT_decl_line
	.byte	0                               // DW_AT_data_member_location
	.byte	14                              // Abbrev [14] 0x435:0xc DW_TAG_member
	.word	.Linfo_string16                 // DW_AT_name
	.word	524                             // DW_AT_type
	.byte	2                               // DW_AT_decl_file
	.byte	23                              // DW_AT_decl_line
	.byte	8                               // DW_AT_data_member_location
	.byte	14                              // Abbrev [14] 0x441:0xc DW_TAG_member
	.word	.Linfo_string17                 // DW_AT_name
	.word	524                             // DW_AT_type
	.byte	2                               // DW_AT_decl_file
	.byte	24                              // DW_AT_decl_line
	.byte	16                              // DW_AT_data_member_location
	.byte	14                              // Abbrev [14] 0x44d:0xc DW_TAG_member
	.word	.Linfo_string18                 // DW_AT_name
	.word	524                             // DW_AT_type
	.byte	2                               // DW_AT_decl_file
	.byte	25                              // DW_AT_decl_line
	.byte	24                              // DW_AT_data_member_location
	.byte	14                              // Abbrev [14] 0x459:0xc DW_TAG_member
	.word	.Linfo_string19                 // DW_AT_name
	.word	1150                            // DW_AT_type
	.byte	2                               // DW_AT_decl_file
	.byte	26                              // DW_AT_decl_line
	.byte	32                              // DW_AT_data_member_location
	.byte	14                              // Abbrev [14] 0x465:0xc DW_TAG_member
	.word	.Linfo_string21                 // DW_AT_name
	.word	1161                            // DW_AT_type
	.byte	2                               // DW_AT_decl_file
	.byte	27                              // DW_AT_decl_line
	.byte	36                              // DW_AT_data_member_location
	.byte	14                              // Abbrev [14] 0x471:0xc DW_TAG_member
	.word	.Linfo_string23                 // DW_AT_name
	.word	1161                            // DW_AT_type
	.byte	2                               // DW_AT_decl_file
	.byte	28                              // DW_AT_decl_line
	.byte	37                              // DW_AT_data_member_location
	.byte	0                               // End Of Children Mark
	.byte	12                              // Abbrev [12] 0x47e:0xb DW_TAG_typedef
	.word	484                             // DW_AT_type
	.word	.Linfo_string20                 // DW_AT_name
	.byte	2                               // DW_AT_decl_file
	.byte	18                              // DW_AT_decl_line
	.byte	5                               // Abbrev [5] 0x489:0x7 DW_TAG_base_type
	.word	.Linfo_string22                 // DW_AT_name
	.byte	2                               // DW_AT_encoding
	.byte	1                               // DW_AT_byte_size
	.byte	12                              // Abbrev [12] 0x490:0xb DW_TAG_typedef
	.word	1179                            // DW_AT_type
	.word	.Linfo_string27                 // DW_AT_name
	.byte	4                               // DW_AT_decl_file
	.byte	18                              // DW_AT_decl_line
	.byte	5                               // Abbrev [5] 0x49b:0x7 DW_TAG_base_type
	.word	.Linfo_string26                 // DW_AT_name
	.byte	7                               // DW_AT_encoding
	.byte	8                               // DW_AT_byte_size
	.byte	12                              // Abbrev [12] 0x4a2:0xb DW_TAG_typedef
	.word	1197                            // DW_AT_type
	.word	.Linfo_string49                 // DW_AT_name
	.byte	2                               // DW_AT_decl_file
	.byte	47                              // DW_AT_decl_line
	.byte	13                              // Abbrev [13] 0x4ad:0xad DW_TAG_structure_type
	.byte	136                             // DW_AT_byte_size
	.byte	2                               // DW_AT_decl_file
	.byte	31                              // DW_AT_decl_line
	.byte	14                              // Abbrev [14] 0x4b1:0xc DW_TAG_member
	.word	.Linfo_string37                 // DW_AT_name
	.word	1168                            // DW_AT_type
	.byte	2                               // DW_AT_decl_file
	.byte	33                              // DW_AT_decl_line
	.byte	0                               // DW_AT_data_member_location
	.byte	14                              // Abbrev [14] 0x4bd:0xc DW_TAG_member
	.word	.Linfo_string38                 // DW_AT_name
	.word	1168                            // DW_AT_type
	.byte	2                               // DW_AT_decl_file
	.byte	34                              // DW_AT_decl_line
	.byte	8                               // DW_AT_data_member_location
	.byte	14                              // Abbrev [14] 0x4c9:0xc DW_TAG_member
	.word	.Linfo_string39                 // DW_AT_name
	.word	1168                            // DW_AT_type
	.byte	2                               // DW_AT_decl_file
	.byte	35                              // DW_AT_decl_line
	.byte	16                              // DW_AT_data_member_location
	.byte	14                              // Abbrev [14] 0x4d5:0xc DW_TAG_member
	.word	.Linfo_string40                 // DW_AT_name
	.word	1370                            // DW_AT_type
	.byte	2                               // DW_AT_decl_file
	.byte	36                              // DW_AT_decl_line
	.byte	24                              // DW_AT_data_member_location
	.byte	14                              // Abbrev [14] 0x4e1:0xc DW_TAG_member
	.word	.Linfo_string41                 // DW_AT_name
	.word	524                             // DW_AT_type
	.byte	2                               // DW_AT_decl_file
	.byte	37                              // DW_AT_decl_line
	.byte	56                              // DW_AT_data_member_location
	.byte	14                              // Abbrev [14] 0x4ed:0xc DW_TAG_member
	.word	.Linfo_string42                 // DW_AT_name
	.word	524                             // DW_AT_type
	.byte	2                               // DW_AT_decl_file
	.byte	38                              // DW_AT_decl_line
	.byte	64                              // DW_AT_data_member_location
	.byte	14                              // Abbrev [14] 0x4f9:0xc DW_TAG_member
	.word	.Linfo_string43                 // DW_AT_name
	.word	524                             // DW_AT_type
	.byte	2                               // DW_AT_decl_file
	.byte	39                              // DW_AT_decl_line
	.byte	72                              // DW_AT_data_member_location
	.byte	14                              // Abbrev [14] 0x505:0xc DW_TAG_member
	.word	.Linfo_string44                 // DW_AT_name
	.word	524                             // DW_AT_type
	.byte	2                               // DW_AT_decl_file
	.byte	40                              // DW_AT_decl_line
	.byte	80                              // DW_AT_data_member_location
	.byte	14                              // Abbrev [14] 0x511:0xc DW_TAG_member
	.word	.Linfo_string45                 // DW_AT_name
	.word	524                             // DW_AT_type
	.byte	2                               // DW_AT_decl_file
	.byte	41                              // DW_AT_decl_line
	.byte	88                              // DW_AT_data_member_location
	.byte	14                              // Abbrev [14] 0x51d:0xc DW_TAG_member
	.word	.Linfo_string46                 // DW_AT_name
	.word	524                             // DW_AT_type
	.byte	2                               // DW_AT_decl_file
	.byte	42                              // DW_AT_decl_line
	.byte	96                              // DW_AT_data_member_location
	.byte	14                              // Abbrev [14] 0x529:0xc DW_TAG_member
	.word	.Linfo_string34                 // DW_AT_name
	.word	524                             // DW_AT_type
	.byte	2                               // DW_AT_decl_file
	.byte	43                              // DW_AT_decl_line
	.byte	104                             // DW_AT_data_member_location
	.byte	14                              // Abbrev [14] 0x535:0xc DW_TAG_member
	.word	.Linfo_string47                 // DW_AT_name
	.word	524                             // DW_AT_type
	.byte	2                               // DW_AT_decl_file
	.byte	44                              // DW_AT_decl_line
	.byte	112                             // DW_AT_data_member_location
	.byte	14                              // Abbrev [14] 0x541:0xc DW_TAG_member
	.word	.Linfo_string19                 // DW_AT_name
	.word	1150                            // DW_AT_type
	.byte	2                               // DW_AT_decl_file
	.byte	45                              // DW_AT_decl_line
	.byte	120                             // DW_AT_data_member_location
	.byte	14                              // Abbrev [14] 0x54d:0xc DW_TAG_member
	.word	.Linfo_string48                 // DW_AT_name
	.word	524                             // DW_AT_type
	.byte	2                               // DW_AT_decl_file
	.byte	46                              // DW_AT_decl_line
	.byte	128                             // DW_AT_data_member_location
	.byte	0                               // End Of Children Mark
	.byte	3                               // Abbrev [3] 0x55a:0xc DW_TAG_array_type
	.word	1168                            // DW_AT_type
	.byte	4                               // Abbrev [4] 0x55f:0x6 DW_TAG_subrange_type
	.word	78                              // DW_AT_type
	.byte	4                               // DW_AT_count
	.byte	0                               // End Of Children Mark
	.byte	12                              // Abbrev [12] 0x566:0xb DW_TAG_typedef
	.word	1393                            // DW_AT_type
	.word	.Linfo_string67                 // DW_AT_name
	.byte	2                               // DW_AT_decl_file
	.byte	68                              // DW_AT_decl_line
	.byte	13                              // Abbrev [13] 0x571:0xd1 DW_TAG_structure_type
	.byte	96                              // DW_AT_byte_size
	.byte	2                               // DW_AT_decl_file
	.byte	49                              // DW_AT_decl_line
	.byte	14                              // Abbrev [14] 0x575:0xc DW_TAG_member
	.word	.Linfo_string51                 // DW_AT_name
	.word	524                             // DW_AT_type
	.byte	2                               // DW_AT_decl_file
	.byte	51                              // DW_AT_decl_line
	.byte	0                               // DW_AT_data_member_location
	.byte	14                              // Abbrev [14] 0x581:0xc DW_TAG_member
	.word	.Linfo_string52                 // DW_AT_name
	.word	524                             // DW_AT_type
	.byte	2                               // DW_AT_decl_file
	.byte	52                              // DW_AT_decl_line
	.byte	8                               // DW_AT_data_member_location
	.byte	14                              // Abbrev [14] 0x58d:0xc DW_TAG_member
	.word	.Linfo_string53                 // DW_AT_name
	.word	524                             // DW_AT_type
	.byte	2                               // DW_AT_decl_file
	.byte	53                              // DW_AT_decl_line
	.byte	16                              // DW_AT_data_member_location
	.byte	14                              // Abbrev [14] 0x599:0xc DW_TAG_member
	.word	.Linfo_string54                 // DW_AT_name
	.word	524                             // DW_AT_type
	.byte	2                               // DW_AT_decl_file
	.byte	54                              // DW_AT_decl_line
	.byte	24                              // DW_AT_data_member_location
	.byte	14                              // Abbrev [14] 0x5a5:0xc DW_TAG_member
	.word	.Linfo_string55                 // DW_AT_name
	.word	524                             // DW_AT_type
	.byte	2                               // DW_AT_decl_file
	.byte	55                              // DW_AT_decl_line
	.byte	32                              // DW_AT_data_member_location
	.byte	14                              // Abbrev [14] 0x5b1:0xc DW_TAG_member
	.word	.Linfo_string56                 // DW_AT_name
	.word	524                             // DW_AT_type
	.byte	2                               // DW_AT_decl_file
	.byte	56                              // DW_AT_decl_line
	.byte	40                              // DW_AT_data_member_location
	.byte	14                              // Abbrev [14] 0x5bd:0xc DW_TAG_member
	.word	.Linfo_string57                 // DW_AT_name
	.word	524                             // DW_AT_type
	.byte	2                               // DW_AT_decl_file
	.byte	57                              // DW_AT_decl_line
	.byte	48                              // DW_AT_data_member_location
	.byte	14                              // Abbrev [14] 0x5c9:0xc DW_TAG_member
	.word	.Linfo_string58                 // DW_AT_name
	.word	524                             // DW_AT_type
	.byte	2                               // DW_AT_decl_file
	.byte	58                              // DW_AT_decl_line
	.byte	56                              // DW_AT_data_member_location
	.byte	14                              // Abbrev [14] 0x5d5:0xc DW_TAG_member
	.word	.Linfo_string59                 // DW_AT_name
	.word	524                             // DW_AT_type
	.byte	2                               // DW_AT_decl_file
	.byte	59                              // DW_AT_decl_line
	.byte	64                              // DW_AT_data_member_location
	.byte	14                              // Abbrev [14] 0x5e1:0xc DW_TAG_member
	.word	.Linfo_string60                 // DW_AT_name
	.word	524                             // DW_AT_type
	.byte	2                               // DW_AT_decl_file
	.byte	60                              // DW_AT_decl_line
	.byte	72                              // DW_AT_data_member_location
	.byte	14                              // Abbrev [14] 0x5ed:0xc DW_TAG_member
	.word	.Linfo_string61                 // DW_AT_name
	.word	1161                            // DW_AT_type
	.byte	2                               // DW_AT_decl_file
	.byte	61                              // DW_AT_decl_line
	.byte	80                              // DW_AT_data_member_location
	.byte	14                              // Abbrev [14] 0x5f9:0xc DW_TAG_member
	.word	.Linfo_string62                 // DW_AT_name
	.word	1161                            // DW_AT_type
	.byte	2                               // DW_AT_decl_file
	.byte	62                              // DW_AT_decl_line
	.byte	81                              // DW_AT_data_member_location
	.byte	14                              // Abbrev [14] 0x605:0xc DW_TAG_member
	.word	.Linfo_string63                 // DW_AT_name
	.word	1161                            // DW_AT_type
	.byte	2                               // DW_AT_decl_file
	.byte	63                              // DW_AT_decl_line
	.byte	82                              // DW_AT_data_member_location
	.byte	14                              // Abbrev [14] 0x611:0xc DW_TAG_member
	.word	.Linfo_string64                 // DW_AT_name
	.word	1161                            // DW_AT_type
	.byte	2                               // DW_AT_decl_file
	.byte	64                              // DW_AT_decl_line
	.byte	83                              // DW_AT_data_member_location
	.byte	14                              // Abbrev [14] 0x61d:0xc DW_TAG_member
	.word	.Linfo_string65                 // DW_AT_name
	.word	1161                            // DW_AT_type
	.byte	2                               // DW_AT_decl_file
	.byte	65                              // DW_AT_decl_line
	.byte	84                              // DW_AT_data_member_location
	.byte	14                              // Abbrev [14] 0x629:0xc DW_TAG_member
	.word	.Linfo_string66                 // DW_AT_name
	.word	1161                            // DW_AT_type
	.byte	2                               // DW_AT_decl_file
	.byte	66                              // DW_AT_decl_line
	.byte	85                              // DW_AT_data_member_location
	.byte	14                              // Abbrev [14] 0x635:0xc DW_TAG_member
	.word	.Linfo_string19                 // DW_AT_name
	.word	1150                            // DW_AT_type
	.byte	2                               // DW_AT_decl_file
	.byte	67                              // DW_AT_decl_line
	.byte	88                              // DW_AT_data_member_location
	.byte	0                               // End Of Children Mark
	.byte	16                              // Abbrev [16] 0x642:0x5 DW_TAG_const_type
	.word	524                             // DW_AT_type
	.byte	17                              // Abbrev [17] 0x647:0x21 DW_TAG_structure_type
	.word	.Linfo_string76                 // DW_AT_name
	.byte	16                              // DW_AT_byte_size
	.byte	6                               // DW_AT_decl_file
	.byte	11                              // DW_AT_decl_line
	.byte	14                              // Abbrev [14] 0x64f:0xc DW_TAG_member
	.word	.Linfo_string71                 // DW_AT_name
	.word	1640                            // DW_AT_type
	.byte	6                               // DW_AT_decl_file
	.byte	16                              // DW_AT_decl_line
	.byte	0                               // DW_AT_data_member_location
	.byte	14                              // Abbrev [14] 0x65b:0xc DW_TAG_member
	.word	.Linfo_string74                 // DW_AT_name
	.word	1658                            // DW_AT_type
	.byte	6                               // DW_AT_decl_file
	.byte	21                              // DW_AT_decl_line
	.byte	8                               // DW_AT_data_member_location
	.byte	0                               // End Of Children Mark
	.byte	12                              // Abbrev [12] 0x668:0xb DW_TAG_typedef
	.word	1651                            // DW_AT_type
	.word	.Linfo_string73                 // DW_AT_name
	.byte	5                               // DW_AT_decl_file
	.byte	160                             // DW_AT_decl_line
	.byte	5                               // Abbrev [5] 0x673:0x7 DW_TAG_base_type
	.word	.Linfo_string72                 // DW_AT_name
	.byte	5                               // DW_AT_encoding
	.byte	8                               // DW_AT_byte_size
	.byte	12                              // Abbrev [12] 0x67a:0xb DW_TAG_typedef
	.word	1651                            // DW_AT_type
	.word	.Linfo_string75                 // DW_AT_name
	.byte	5                               // DW_AT_decl_file
	.byte	197                             // DW_AT_decl_line
	.byte	0                               // End Of Children Mark
.Ldebug_info_end0:
	.section	.debug_str,"MS",@progbits,1
.Linfo_string0:
	.asciz	"clang version 21.1.0"          // string offset=0
.Linfo_string1:
	.asciz	"build/pi/Pilot_main_asm.c"     // string offset=21
.Linfo_string2:
	.asciz	"/Users/matthewketas/Desktop/University of Pittsburgh/Senior Year/7th Semester/Embedded Systems/ECE_2160_Group_C" // string offset=47
.Linfo_string3:
	.asciz	"char"                          // string offset=159
.Linfo_string4:
	.asciz	"__ARRAY_SIZE_TYPE__"           // string offset=164
.Linfo_string5:
	.asciz	"unsigned int"                  // string offset=184
.Linfo_string6:
	.asciz	"TEMPERATURE_SOURCE_UNKNOWN"    // string offset=197
.Linfo_string7:
	.asciz	"TEMPERATURE_SOURCE_SENSE_HAT"  // string offset=224
.Linfo_string8:
	.asciz	"TEMPERATURE_SOURCE_DATA"       // string offset=253
.Linfo_string9:
	.asciz	"TEMPERATURE_SOURCE_CPU"        // string offset=277
.Linfo_string10:
	.asciz	"double"                        // string offset=300
.Linfo_string11:
	.asciz	"int"                           // string offset=307
.Linfo_string12:
	.asciz	"main"                          // string offset=311
.Linfo_string13:
	.asciz	"memory"                        // string offset=316
.Linfo_string14:
	.asciz	"buffer"                        // string offset=323
.Linfo_string15:
	.asciz	"timestamp_s"                   // string offset=330
.Linfo_string16:
	.asciz	"temperature_c"                 // string offset=342
.Linfo_string17:
	.asciz	"humidity_percent"              // string offset=356
.Linfo_string18:
	.asciz	"pressure_hpa"                  // string offset=373
.Linfo_string19:
	.asciz	"source"                        // string offset=386
.Linfo_string20:
	.asciz	"critter_temperature_source_t"  // string offset=393
.Linfo_string21:
	.asciz	"has_humidity"                  // string offset=422
.Linfo_string22:
	.asciz	"_Bool"                         // string offset=435
.Linfo_string23:
	.asciz	"has_pressure"                  // string offset=441
.Linfo_string24:
	.asciz	"critter_sample_t"              // string offset=454
.Linfo_string25:
	.asciz	"capacity"                      // string offset=471
.Linfo_string26:
	.asciz	"unsigned long"                 // string offset=480
.Linfo_string27:
	.asciz	"size_t"                        // string offset=494
.Linfo_string28:
	.asciz	"head"                          // string offset=501
.Linfo_string29:
	.asciz	"count"                         // string offset=506
.Linfo_string30:
	.asciz	"total_received_samples"        // string offset=512
.Linfo_string31:
	.asciz	"total_valid_samples"           // string offset=535
.Linfo_string32:
	.asciz	"total_rejected_samples"        // string offset=555
.Linfo_string33:
	.asciz	"total_outliers"                // string offset=578
.Linfo_string34:
	.asciz	"last_timestamp_s"              // string offset=593
.Linfo_string35:
	.asciz	"critter_memory_t"              // string offset=610
.Linfo_string36:
	.asciz	"summary"                       // string offset=627
.Linfo_string37:
	.asciz	"sample_count"                  // string offset=635
.Linfo_string38:
	.asciz	"valid_sample_count"            // string offset=648
.Linfo_string39:
	.asciz	"outlier_count"                 // string offset=667
.Linfo_string40:
	.asciz	"sample_count_by_source"        // string offset=681
.Linfo_string41:
	.asciz	"min_temperature_c"             // string offset=704
.Linfo_string42:
	.asciz	"max_temperature_c"             // string offset=722
.Linfo_string43:
	.asciz	"mean_temperature_c"            // string offset=740
.Linfo_string44:
	.asciz	"median_temperature_c"          // string offset=759
.Linfo_string45:
	.asciz	"stddev_temperature_c"          // string offset=780
.Linfo_string46:
	.asciz	"first_timestamp_s"             // string offset=801
.Linfo_string47:
	.asciz	"retained_ratio"                // string offset=819
.Linfo_string48:
	.asciz	"latest_temperature_c"          // string offset=834
.Linfo_string49:
	.asciz	"critter_window_summary_t"      // string offset=855
.Linfo_string50:
	.asciz	"analysis"                      // string offset=880
.Linfo_string51:
	.asciz	"current_temperature_c"         // string offset=889
.Linfo_string52:
	.asciz	"trend_c_per_s"                 // string offset=911
.Linfo_string53:
	.asciz	"rate_of_change_c_per_s"        // string offset=925
.Linfo_string54:
	.asciz	"predicted_temperature_c"       // string offset=948
.Linfo_string55:
	.asciz	"prediction_horizon_s"          // string offset=972
.Linfo_string56:
	.asciz	"analysis_timestamp_s"          // string offset=993
.Linfo_string57:
	.asciz	"slope_c_per_s"                 // string offset=1014
.Linfo_string58:
	.asciz	"intercept_c"                   // string offset=1028
.Linfo_string59:
	.asciz	"variance_c"                    // string offset=1040
.Linfo_string60:
	.asciz	"recent_delta_c"                // string offset=1051
.Linfo_string61:
	.asciz	"stable"                        // string offset=1066
.Linfo_string62:
	.asciz	"rising"                        // string offset=1073
.Linfo_string63:
	.asciz	"falling"                       // string offset=1080
.Linfo_string64:
	.asciz	"likely_hvac_active"            // string offset=1088
.Linfo_string65:
	.asciz	"likely_cooling"                // string offset=1107
.Linfo_string66:
	.asciz	"likely_heating"                // string offset=1122
.Linfo_string67:
	.asciz	"critter_analysis_result_t"     // string offset=1137
.Linfo_string68:
	.asciz	"collection_window_s"           // string offset=1163
.Linfo_string69:
	.asciz	"report_interval_s"             // string offset=1183
.Linfo_string70:
	.asciz	"start_ts"                      // string offset=1201
.Linfo_string71:
	.asciz	"tv_sec"                        // string offset=1210
.Linfo_string72:
	.asciz	"long"                          // string offset=1217
.Linfo_string73:
	.asciz	"__time_t"                      // string offset=1222
.Linfo_string74:
	.asciz	"tv_nsec"                       // string offset=1231
.Linfo_string75:
	.asciz	"__syscall_slong_t"             // string offset=1239
.Linfo_string76:
	.asciz	"timespec"                      // string offset=1257
.Linfo_string77:
	.asciz	"now_ts"                        // string offset=1266
.Linfo_string78:
	.asciz	"elapsed_s"                     // string offset=1273
.Linfo_string79:
	.asciz	"last_report_s"                 // string offset=1283
.Linfo_string80:
	.asciz	"total_read_attempts"           // string offset=1297
.Linfo_string81:
	.asciz	"sampling_rate_hz"              // string offset=1317
.Linfo_string82:
	.asciz	"sample"                        // string offset=1334
.Linfo_string83:
	.asciz	"add_result"                    // string offset=1341
.Linfo_string84:
	.asciz	"elapsed_seconds"               // string offset=1352
.Linfo_string85:
	.asciz	"minutes"                       // string offset=1368
.Linfo_string86:
	.asciz	"seconds"                       // string offset=1376
.Linfo_string87:
	.asciz	"sleep_ts"                      // string offset=1384
	.ident	"clang version 21.1.0"
	.section	".note.GNU-stack","",@progbits
	.addrsig
	.addrsig_sym critter_memory_init
	.addrsig_sym fprintf
	.addrsig_sym __ubsan_handle_nonnull_arg
	.addrsig_sym clock_gettime
	.addrsig_sym critter_memory_free
	.addrsig_sym critter_io_read_sample
	.addrsig_sym critter_io_save_sample
	.addrsig_sym critter_memory_add_sample
	.addrsig_sym __ubsan_handle_type_mismatch_v1
	.addrsig_sym __ubsan_handle_sub_overflow
	.addrsig_sym __ubsan_handle_float_cast_overflow
	.addrsig_sym __ubsan_handle_divrem_overflow
	.addrsig_sym printf
	.addrsig_sym fflush
	.addrsig_sym nanosleep
	.addrsig_sym critter_memory_build_summary
	.addrsig_sym critter_compute_analysis
	.addrsig_sym __ubsan_handle_load_invalid_value
	.addrsig_sym critter_io_save_metrics
	.addrsig_sym stderr
	.addrsig_sym stdout
	.section	.debug_line,"",@progbits
.Lline_table_start0:
