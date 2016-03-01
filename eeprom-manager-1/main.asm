                .INCLUDE "devices/m8def.inc"
                .INCLUDE "avr-lib/delay-def.inc"
                .INCLUDE "twi-def.inc"
                .INCLUDE "i2c-def.inc"
                
                ; --- Start Address and Shift Value ---
                .EQU EEPROM_ADDR_START = 0x0200
                .EQU EEPROM_ADDR_SHIFT = 4
                
                ; --- Timeouts ---
                .EQU WAIT_TIME1_MS = 500
                .EQU WAIT_TIME2_MS = 250
                
                ; --- EEPROM Register Defines ---
                .DEF EEPROM_DATA = r0
                
                .DEF EEPROM_ADDR_L = r2
                .DEF EEPROM_ADDR_H = r3
                
                .DEF ADDR_SHIFT_L = r4
                .DEF ADDR_SHIFT_H = r5
                
                ; --- Debug Output Pins ---
                .EQU DEBUG_PIN1 = PORTD6
                .EQU DEBUG_PIN2 = PORTD7
                
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
                
                ; --- Setup Debug Output Pins ---
                sbi     DDRD, DEBUG_PIN1
                sbi     DDRD, DEBUG_PIN2
                
                ; --- [TEMPORARY ENABLE PULL-UP RESISTORS] ---
                sbi     PORTC, PORTC4
                sbi     PORTC, PORTC5
                
                ; --- Load Address Shift Value ---
                ldi     r16,  LOW(EEPROM_ADDR_SHIFT)
                mov     ADDR_SHIFT_L, r16
                ldi     r16, HIGH(EEPROM_ADDR_SHIFT)
                mov     ADDR_SHIFT_H, r16
                
                ; --- Load Byte Start Address ---
                ldi     r16,  LOW(EEPROM_ADDR_START)
                mov     EEPROM_ADDR_L, r16
                ldi     r16, HIGH(EEPROM_ADDR_START)
                mov     EEPROM_ADDR_H, r16
                
                ; --- Set Byte Initial Value ---
                clr     EEPROM_DATA
                
                ; --- Set Debug Pins to High ---
main_start:     sbi     PORTD, DEBUG_PIN1
                sbi     PORTD, DEBUG_PIN2
                
                ; --- Wait ---
                ldi     DELAY_ARG_TIME_L,  LOW(WAIT_TIME2_MS)
                ldi     DELAY_ARG_TIME_H, HIGH(WAIT_TIME2_MS)
                rcall   delay_ms
                
                ; --- Set Debug Pins to Low ---
                cbi     PORTD, DEBUG_PIN1
                cbi     PORTD, DEBUG_PIN2
                
                ; --- Wait ---
                ldi     DELAY_ARG_TIME_L,  LOW(WAIT_TIME2_MS)
                ldi     DELAY_ARG_TIME_H, HIGH(WAIT_TIME2_MS)
                rcall   delay_ms
                
                ; --- Write Byte to EEPROM ---
                mov     I2C_ARG_ADDR_L, EEPROM_ADDR_L
                mov     I2C_ARG_ADDR_H, EEPROM_ADDR_H
                mov     I2C_ARG_DATA, EEPROM_DATA
                rcall   i2c_eeprom_write_byte
                
                ; --- Check Return Status ---
                cpi     I2C_RET_STAT, I2C_STATUS_OK
                breq    main_W1
                sbi     PORTD, DEBUG_PIN1
                
                ; --- Wait ---
main_W1:        ldi     DELAY_ARG_TIME_L,  LOW(WAIT_TIME1_MS)
                ldi     DELAY_ARG_TIME_H, HIGH(WAIT_TIME1_MS)
                rcall   delay_ms
                
                ; --- Overwrite Byte Value ---
                neg     I2C_ARG_DATA
                
                ; --- Read Byte from EEPROM ---
                mov     I2C_ARG_ADDR_L, EEPROM_ADDR_L
                mov     I2C_ARG_ADDR_H, EEPROM_ADDR_H
                rcall   i2c_eeprom_read_byte
                
                ; --- Check Return Status ---
                cpi     I2C_RET_STAT, I2C_STATUS_OK
                breq    main_W2
                sbi     PORTD, DEBUG_PIN1
                
                ; --- Wait ---
main_W2:        ldi     DELAY_ARG_TIME_L,  LOW(WAIT_TIME1_MS)
                ldi     DELAY_ARG_TIME_H, HIGH(WAIT_TIME1_MS)
                rcall   delay_ms
                
                ; --- Compare EEPROM Values ---
                cp      I2C_ARG_DATA, EEPROM_DATA
                breq    main_W3
                sbi     PORTD, DEBUG_PIN1
                
                ; --- Wait ---
main_W3:        ldi     DELAY_ARG_TIME_L,  LOW(WAIT_TIME1_MS)
                ldi     DELAY_ARG_TIME_H, HIGH(WAIT_TIME1_MS)
                rcall   delay_ms
                
                ; --- Change EEPROM Byte Value ---
                inc     EEPROM_DATA
                
                ; --- Change EEPROM Byte Address ---
                add     EEPROM_ADDR_L, ADDR_SHIFT_L
                adc     EEPROM_ADDR_H, ADDR_SHIFT_H
                
                rjmp    main_start
                
                .INCLUDE "i2c-eeprom-write-byte.asm"
                .INCLUDE "i2c-eeprom-read-byte.asm"
                .INCLUDE "avr-lib/delay-ms-1m.asm"
