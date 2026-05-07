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
  rvx_uart_send_string(RVX_UART_ADDRESS, "This example reads the ID from BMP280 - Digital Pressure Sensor\n");

  // Set I2C prescale to 10 kHz for 12 MHz
  rvx_i2c_set_divider(RVX_I2C_ADDRESS, 1200);

  const uint8_t bmp280_slave_addr = 0b1110110; // Or 0b1110111
  const uint8_t bmp280_id_reg_addr = 0xD0;
  uint8_t bmp280_id_value = 0u;

  rvx_uart_send_string(RVX_UART_ADDRESS, "\nReading Manufacturer ID from I2C BMP280...\n");
  // Start condition
  rvx_i2c_run_start(RVX_I2C_ADDRESS);
  // Write ID register address to BMP280
  rvx_i2c_write_to(RVX_I2C_ADDRESS, bmp280_slave_addr, &bmp280_id_reg_addr, 1);
  rvx_i2c_run_restart(RVX_I2C_ADDRESS);
  // Read ID register from BMP280
  rvx_i2c_reade_from(RVX_I2C_ADDRESS, bmp280_slave_addr, &bmp280_id_value, 1);
  // Stop condition
  rvx_i2c_run_stop(RVX_I2C_ADDRESS);

  // Print Manufacturer ID
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