i2c_eeprom_write_byte:      push    r16
                            
                            ; --- Set Return Status to No Error ---
                            clr     r22
                            
                            ; --- Send START Condition ---
                            ldi     r16, I2C_START
                            out     TWCR, r16
                            
                            ; --- Wait ---
i2c_eeprom_write_byte_W1:   in      r16, TWCR
                            sbrs    r16, TWINT
                            rjmp    i2c_eeprom_write_byte_W1
                            
                            ; --- Check that START Condition was sent ---
                            in      r16, TWSR
                            cpi     r16, I2C_START_SENT
                            brne    i2c_eeprom_write_byte_E1
                            
                            ; --- Send Slave Device Address + Write ---
                            ldi     r16, EEPROM_DEV_ADDR | I2C_WRITE
                            out     TWDR, r16
                            ldi     r16, I2C_SEND
                            out     TWCR, r16
                            
                            ; --- Wait ---
i2c_eeprom_write_byte_W2:   in      r16, TWCR
                            sbrs    r16, TWINT
                            rjmp    i2c_eeprom_write_byte_W2
                            
                            ; --- Check that Slave Addres + Write was sent ---
                            in      r16, TWSR
                            cpi     r16, I2C_MT_SLA_SENT_ACK
                            brne    i2c_eeprom_write_byte_E1
                            
                            ; --- Send High Byte of EEPROM Address ---
                            out     TWDR, r25
                            ldi     r16, I2C_SEND
                            out     TWCR, r16
                            
                            ; --- Wait ---
i2c_eeprom_write_byte_W3:   in      r16, TWCR
                            sbrs    r16, TWINT
                            rjmp    i2c_eeprom_write_byte_W3
                            
                            ; --- Check that Address High Byte was sent ---
                            in      r16, TWSR
                            cpi     r16, I2C_MT_DATA_SENT_ACK
                            brne    i2c_eeprom_write_byte_E1
                            
                            ; --- Send Low Byte of EEPROM Address ---
                            out     TWDR, r24
                            ldi     r16, I2C_SEND
                            out     TWCR, r16
                            
                            ; --- Wait ---
i2c_eeprom_write_byte_W4:   in      r16, TWCR
                            sbrs    r16, TWINT
                            rjmp    i2c_eeprom_write_byte_W4
                            
                            ; --- Check that Address Low Byte was sent ---
                            in      r16, TWSR
                            cpi     r16, I2C_MT_DATA_SENT_ACK
                            brne    i2c_eeprom_write_byte_E1
                            
                            ; --- Send Data Byte ---
                            out     TWDR, r18
                            ldi     r16, I2C_SEND
                            out     TWCR, r16
                            
                            ; --- Wait ---
i2c_eeprom_write_byte_W5:   in      r16, TWCR
                            sbrs    r16, TWINT
                            rjmp    i2c_eeprom_write_byte_W5
                            
                            ; --- Check that ... ---
                            in      r16, TWSR
                            cpi     r16, I2C_MT_DATA_SENT_ACK
                            brne    i2c_eeprom_write_byte_E1
                            
                            ; --- Skip Error Status ---
                            rjmp    i2c_eeprom_write_byte_W6
                            
                            ; --- Set Return Status to Error ---
i2c_eeprom_write_byte_E1:   ldi     r22, 0x01
                            
                            ; --- Send STOP Condition ---
i2c_eeprom_write_byte_W6:   ldi     r16, I2C_STOP
                            out     TWCR, r16
                            
                            pop     r16
                            
                            ret
