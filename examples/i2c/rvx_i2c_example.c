// SPDX-License-Identifier: MIT
// Copyright (c) 2020-2026 RVX Project Contributors

#include "rvx.h"

void print_byte(const uint8_t read_data);

void main(void)
{
  // Initialize UART at 9600 baud (assuming clock frequency is 12 MHz)
  rvx_uart_init(RVX_UART_ADDRESS, 9600, 12000000);

  // Print welcome message
  rvx_uart_send_string(RVX_UART_ADDRESS, "RVX I2C Example Project\n\n");
  rvx_uart_send_string(RVX_UART_ADDRESS, "This example reads the ID from BME280 - Digital Pressure Sensor\n");

  // Adjust I2C frequency by setting the clock divider (assuming 12 MHz clock, this sets I2C to 100 kHz)
  rvx_i2c_set_divider(RVX_I2C_ADDRESS, 1200);

  const uint8_t bmp280_slave_addr = 0b1110110;
  const uint8_t bmp280_id_reg_addr = 0xD0;
  uint8_t bmp280_id_value = 0;

  rvx_uart_send_string(RVX_UART_ADDRESS, "\nReading BME280 ID register over I2C...\n");
  rvx_i2c_write_read(RVX_I2C_ADDRESS, bmp280_slave_addr, &bmp280_id_reg_addr, 1, &bmp280_id_value, 1);

  // Print BME280 ID
  print_byte(bmp280_id_value);

  rvx_wait_for_interrupt();
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
  rvx_uart_send_string(RVX_UART_ADDRESS, "\nRead value: ");
  rvx_uart_send_string(RVX_UART_ADDRESS, str_val);
  rvx_uart_send_string(RVX_UART_ADDRESS, "\n");
}