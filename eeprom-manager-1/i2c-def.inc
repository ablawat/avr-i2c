; --- Input/Output Register Defines ---
.DEF I2C_ARG_ADDR_L = r24
.DEF I2C_ARG_ADDR_H = r25
.DEF I2C_ARG_DATA   = r18
.DEF I2C_RET_STAT   = r22

; --- Return Status Codes ---
.EQU I2C_STATUS_OK  = 0
.EQU I2C_STATUS_ERR = 1

; --- Define Device Address ---
.EQU EEPROM_DEV_ADDR = MAIN_EEPROM_DEVICE_ADDR
