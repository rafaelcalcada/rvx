// SPDX-License-Identifier: MIT
// Copyright (c) 2020-2026 RVX Project Contributors

#include "rvx.h"
#include "rvx_sdk_test_framework.h"

static void i2c_test_frequency_configuration(RvxTestSuite *suite)
{
  static const struct
  {
    uint32_t requested_frequency;
    uint16_t expected_divider;
    uint32_t expected_register;
  } cases[] = {
      {100000U, 500U, 249U},
      {10400000U, 6U, 2U},
      {25000000U, 2U, 0U},
      {1U, 65534U, 32766U},
      {0U, 0U, 123U},
      {25000001U, 0U, 123U},
  };

  for (size_t index = 0; index < RVX_ARRAY_SIZE(cases); index++)
  {
    RvxI2c i2c = {.RVX_I2C_DIVIDER_REG = 123U};
    const uint16_t selected_divider = rvx_i2c_set_frequency(&i2c, cases[index].requested_frequency);

    RVX_TEST_ASSERT_EQ(suite, selected_divider, cases[index].expected_divider);
    RVX_TEST_ASSERT_EQ(suite, i2c.RVX_I2C_DIVIDER_REG, cases[index].expected_register);
    RVX_TEST_ASSERT_EQ(suite, i2c.RVX_I2C_DATA_REG, 0U);
    RVX_TEST_ASSERT_EQ(suite, i2c.RVX_I2C_COMMAND_REG, 0U);
    RVX_TEST_ASSERT_EQ(suite, i2c.RVX_I2C_STATUS_REG, 0U);
  }
}

static const RvxTestCase i2c_test_cases[] = {
    {"Configure the I2C clock frequency.", i2c_test_frequency_configuration},
};

const RvxTestSuiteDescriptor rvx_sdk_i2c_test_suite = {
    .name = "RVX SDK - I2C tests",
    .test_cases = i2c_test_cases,
    .test_case_count = RVX_ARRAY_SIZE(i2c_test_cases),
};
