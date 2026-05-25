// SPDX-License-Identifier: MIT
// Copyright (c) 2020-2026 RVX Project Contributors

#include "rvx.h"

// Pointer to the UART controller registers.
RvxUartRegs *uart_controller = (RvxUartRegs *)RVX_UART_CONTROLLER_ADDRESS;

// Pointer to the I2C controller registers.
RvxI2cRegs *i2c_controller = (RvxI2cRegs *)RVX_I2C_CONTROLLER_ADDRESS;

void print_byte(const uint8_t read_data);

void main(void)
{
  // Initialize UART at 9600 baud (assuming clock frequency is 12 MHz)
  rvx_uart_set_baud_rate(uart_controller, 9600, 12000000);

  // Print welcome message
  rvx_uart_send_string(uart_controller, "RVX I2C Example Project\n\n");
  rvx_uart_send_string(uart_controller, "This example reads the ID from BME280 - Temperature Sensor\n");

  // Adjust I2C frequency by setting the clock divider (if RVX clock is 12 MHz, this sets I2C speed to 100 kHz)
  rvx_i2c_set_divider(i2c_controller, 1200);

  const uint8_t bme280_peripheral_address = 0b1110110;
  const uint8_t bme280_id_reg_address = 0xD0;
  uint8_t bme280_id_value = 0;

  rvx_uart_send_string(uart_controller, "\nReading BME280 ID register over I2C...\n");
  rvx_i2c_write_read(i2c_controller, bme280_peripheral_address, &bme280_id_reg_address, 1, &bme280_id_value, 1);

  // Print BME280 ID
  print_byte(bme280_id_value);
}

void print_byte(const uint8_t read_data)
{
  uint8_t high_nibble = (read_data >> 4) & 0x0F;
  uint8_t low_nibble = read_data & 0x0F;
  char str_val[5];
  str_val[0] = '0';
  str_val[1] = 'x';
  str_val[2] = high_nibble < 10 ? high_nibble + '0' : high_nibble - 10 + 'a';
  str_val[3] = low_nibble < 10 ? low_nibble + '0' : low_nibble - 10 + 'a';
  str_val[4] = '\0';
  rvx_uart_send_string(uart_controller, "\nRead value: ");
  rvx_uart_send_string(uart_controller, str_val);
  rvx_uart_send_string(uart_controller, "\n");
}