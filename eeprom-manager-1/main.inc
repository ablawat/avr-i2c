; --- Enable Internal PULL-UP Resistors on I2C Lines ---
#define I2C_PULL_UP

; --- Start Address and Shift Value ---
.EQU EEPROM_ADDR_START = 0x0200
.EQU EEPROM_ADDR_SHIFT = 4

; --- Timeouts ---
.EQU WAIT_TIME1_MS = 500
.EQU WAIT_TIME2_MS = 250
