#ifndef _COMPLIANCE_MODEL_H
#define _COMPLIANCE_MODEL_H

#ifdef TARGET_SIMULATOR_RVX
// For RVX Simulator, 0 means "stop execution and return EXIT_SUCCESS to host"
#define EXIT_VALUE 0
#elifdef TARGET_SIMULATOR_SPIKE
// For Spike simulator, 1 means just "stop execution and return to host" - no success/failure indication
#define EXIT_VALUE 1
#else
#error "Unknown simulator target. Compile with -DTARGET_SIMULATOR_RVX or -DTARGET_SIMULATOR_SPIKE."
#endif

#define RVMODEL_HALT                                                                                                   \
  /* tell simulation about location of begin_signature */                                                              \
  la t0, begin_signature;                                                                                              \
  la t1, begin_signature_pointer;                                                                                      \
  sw t0, 0(t1);                                                                                                        \
  /* tell simulation about location of end_signature */                                                                \
  la t0, end_signature;                                                                                                \
  la t1, end_signature_pointer;                                                                                        \
  sw t0, 0(t1);                                                                                                        \
  /* tell simulation that test has ended */                                                                            \
  li t0, EXIT_VALUE;                                                                                                   \
  la t1, tohost;                                                                                                       \
  sw t0, 0(t1);                                                                                                        \
  ecall;                                                                                                               \
  eternal_loop:                                                                                                        \
  j eternal_loop;

#define RVMODEL_DATA_BEGIN                                                                                             \
  .align 4;                                                                                                            \
  .global begin_signature;                                                                                             \
  begin_signature:

#define RVMODEL_DATA_END                                                                                               \
  .align 4;                                                                                                            \
  .global end_signature;                                                                                               \
  end_signature:

// Unused macros
#define RVMODEL_SET_MSW_INT
#define RVMODEL_CLEAR_MSW_INT
#define RVMODEL_CLEAR_MTIMER_INT
#define RVMODEL_CLEAR_MEXT_INT
#define RVMODEL_BOOT
#define RVMODEL_IO_WRITE_STR(_SP, _STR)
#define RVMODEL_IO_ASSERT_GPR_EQ(_SP, _R, _I)

#endif // _COMPLIANCE_MODEL_H