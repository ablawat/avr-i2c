; --- Enable Internal PULL-UP Resistors on I2C Lines ---
#define MAIN_I2C_PULL_UP

; --- 16-bit Start Address and Shift Value ---
#define MAIN_EEPROM_ADDR_START 0x0200
#define MAIN_EEPROM_ADDR_SHIFT 4

; --- 16-bit Timeouts ---
#define MAIN_WAIT_TIME1_MS 500
#define MAIN_WAIT_TIME2_MS 250

; --- 7-bit I2C Slave Address ---
#define MAIN_EEPROM_DEVICE_ADDR 0xA0
