                .INCLUDE "../../include/m8def.inc"
                .INCLUDE "twi-def.inc"
                .INCLUDE "i2c-def.inc"
                
                .EQU EEPROM_DEV_ADDR = 0xA0
                
                .EQU EEPROM_ADDR_START = 0x0200
                .EQU EEPROM_ADDR_SHIFT = 4
                
                .EQU WAIT_TIME1_MS = 500
                .EQU WAIT_TIME2_MS = 250
                
                .DEF EEPROM_DATA = r0
                
                .DEF EEPROM_ADDR_L = r26
                .DEF EEPROM_ADDR_H = r27
                
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
                
                ; --- Temporary set pull-up registers ---
                sbi     PORTC, PORTC4
                sbi     PORTC, PORTC5
                
                ; --- Load Address Shift Value ---
                ldi     r16,  LOW(EEPROM_ADDR_SHIFT)
                mov     r2, r16
                ldi     r16, HIGH(EEPROM_ADDR_SHIFT)
                mov     r3, r16
                
                ; --- Load Byte Start Address ---
                ldi     EEPROM_ADDR_L,  LOW(EEPROM_ADDR_START)
                ldi     EEPROM_ADDR_H, HIGH(EEPROM_ADDR_START)
                
                ; --- Set Byte Initial Value ---
                clr     EEPROM_DATA
                
                ; --- Turn On Debug Indications ---
main_start:     sbi     PORTD, DEBUG_PIN1
                sbi     PORTD, DEBUG_PIN2
                
                ; --- Wait 1 second ---
                ldi     r24,  LOW(WAIT_TIME2_MS)
                ldi     r25, HIGH(WAIT_TIME2_MS)
                rcall   delay_ms
                
                ; --- Turn Off Debug Indications ---
                cbi     PORTD, DEBUG_PIN1
                cbi     PORTD, DEBUG_PIN2
                
                ; --- Wait 1 second ---
                ldi     r24,  LOW(WAIT_TIME2_MS)
                ldi     r25, HIGH(WAIT_TIME2_MS)
                rcall   delay_ms
                
                ; --- Write Byte to EEPROM ---
                mov     r18, EEPROM_DATA
                mov     r24, EEPROM_ADDR_L
                mov     r25, EEPROM_ADDR_H
                rcall   i2c_eeprom_write_byte
                
                ; --- Check Return Status ---
                cpi     r22, I2C_STATUS_OK
                breq    main_W1
                sbi     PORTD, DEBUG_PIN1
                
                ; --- Wait 1 second ---
main_W1:        ldi     r24,  LOW(WAIT_TIME1_MS)
                ldi     r25, HIGH(WAIT_TIME1_MS)
                rcall   delay_ms
                
                ; --- Overwrite Byte Value ---
                neg     r18
                
                ; --- Read Byte from EEPROM ---
                mov     r24, EEPROM_ADDR_L
                mov     r25, EEPROM_ADDR_H
                rcall   i2c_eeprom_read_byte
                
                ; --- Check Return Status ---
                cpi     r22, I2C_STATUS_OK
                breq    main_W2
                sbi     PORTD, DEBUG_PIN1
                
                ; --- Wait 1 second ---
main_W2:        ldi     r24,  LOW(WAIT_TIME1_MS)
                ldi     r25, HIGH(WAIT_TIME1_MS)
                rcall   delay_ms
                
                ; --- Compare EEPROM Values ---
                cp      r18, EEPROM_DATA
                brne    main_W3
                sbi     PORTD, DEBUG_PIN2
                
                ; --- Wait 1 second ---
main_W3:        ldi     r24,  LOW(WAIT_TIME1_MS)
                ldi     r25, HIGH(WAIT_TIME1_MS)
                rcall   delay_ms
                
                ; --- Change EEPROM Byte Value ---
                inc     EEPROM_DATA
                
                ; --- Change EEPROM Byte Address ---
                add     EEPROM_ADDR_L, r2
                adc     EEPROM_ADDR_H, r3
                
                rjmp    main_start
                
                .INCLUDE "i2c-eeprom-write-byte.asm"
                .INCLUDE "i2c-eeprom-read-byte.asm"
                .INCLUDE "avr-lib/delay-ms-1m.asm"
