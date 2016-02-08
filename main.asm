                .INCLUDE "include/m8def.inc"
                .INCLUDE "i2c-def.inc"
                
                .EQU EEPROM_DEV_ADDR = 0xA0
                
                .EQU EEPROM_BYTE1_ADDR = 0x0010
                .EQU EEPROM_BYTE2_ADDR = 0x1020
                
                .EQU WAIT_TIME_MS = 1000
                
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
                
                ; --- Wait 1 second ---
main_start:     ldi     r24,  LOW(WAIT_TIME_MS)
                ldi     r25, HIGH(WAIT_TIME_MS)
                rcall   delay_ms
                
                ; --- Write Byte1 to EEPROM ---
                ldi     r24,  LOW(EEPROM_BYTE1_ADDR)
                ldi     r25, HIGH(EEPROM_BYTE1_ADDR)
                rcall   i2c_eeprom_write_byte
                
                rjmp    main_start
                
                .INCLUDE "i2c-eeprom-write-byte.asm"
                .INCLUDE "avr-lib/delay-ms-1m.asm"
