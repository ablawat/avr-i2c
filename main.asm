                .INCLUDE "include/m8def.inc"
                .INCLUDE "i2c-def.inc"
                
                .EQU EEPROM_DEV_ADDR = 0xA0
                
                .EQU EEPROM_BYTE1_ADDR = 0x0010
                .EQU EEPROM_BYTE2_ADDR = 0x1020
                
                ; --- Beginning of Code Segment ---
                .CSEG
                .ORG    0x00
                
                ; --- Initialize Stack Pointer ---
                ldi     r16, HIGH(RAMEND)
                out     SPH, r16
                ldi     r16, LOW(RAMEND)
                out     SPL, r16
                
                ; --- Initialize I2C Frequency ---
                ; SCL = 50kHz on CPU = 1MHz
                ldi     r16, 2
                out     TWBR, r16
                
                ; --- Wait 4 seconds ---
main_start:     ; Delay Function
                
                ; --- Write Byte1 to EEPROM ---
                ldi     r25, HIGH(EEPROM_BYTE1_ADDR)
                ldi     r24,  LOW(EEPROM_BYTE1_ADDR)
                call    i2c_eeprom_write_byte
                
                rjmp    main_start
                
                .INCLUDE "i2c-eeprom-write-byte.asm"
