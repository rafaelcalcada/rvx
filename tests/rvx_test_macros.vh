`ifndef __RVX__TEST_MACROS_VH__
`define __RVX__TEST_MACROS_VH__

`define RVX_ASSERT(cond, msg)                               \
  if (!(cond)) begin                                        \
    $display("");                                           \
    $display("Assertion FAILED.");                          \
    $display("  Condition: %s", `"cond`");                  \
    $display("  Message: %s", msg);                         \
    error_count = error_count + 1;                          \
    $stop();                                                \
  end                                                       \
  else begin                                                \
    $display("Passed: %s", `"cond`");                       \
  end

`endif
