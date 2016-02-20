                            ; --- Set Return Status to I2C_STATUS_OK ---
i2c_eeprom_write_byte:      clr     r22
                            
                            ; --- Send START Condition ---
                            ldi     r16, TWI_START
                            out     TWCR, r16
                            
                            ; --- Wait ---
i2c_eeprom_write_byte_W1:   in      r16, TWCR
                            sbrs    r16, TWINT
                            rjmp    i2c_eeprom_write_byte_W1
                            
                            ; --- Check that START Condition was sent ---
                            in      r16, TWSR
                            cpi     r16, TWI_START_SENT
                            brne    i2c_eeprom_write_byte_E1
                            
                            ; --- Send Slave Device Address + Write ---
                            ldi     r16, EEPROM_DEV_ADDR | TWI_WRITE
                            out     TWDR, r16
                            ldi     r16, TWI_SEND
                            out     TWCR, r16
                            
                            ; --- Wait ---
i2c_eeprom_write_byte_W2:   in      r16, TWCR
                            sbrs    r16, TWINT
                            rjmp    i2c_eeprom_write_byte_W2
                            
                            ; --- Check that Slave Addres + Write was sent ---
                            in      r16, TWSR
                            cpi     r16, TWI_MT_SLA_SENT_ACK
                            brne    i2c_eeprom_write_byte_E1
                            
                            ; --- Send High Byte of EEPROM Address ---
                            out     TWDR, r25
                            ldi     r16, TWI_SEND
                            out     TWCR, r16
                            
                            ; --- Wait ---
i2c_eeprom_write_byte_W3:   in      r16, TWCR
                            sbrs    r16, TWINT
                            rjmp    i2c_eeprom_write_byte_W3
                            
                            ; --- Check that Address High Byte was sent ---
                            in      r16, TWSR
                            cpi     r16, TWI_MT_DATA_SENT_ACK
                            brne    i2c_eeprom_write_byte_E1
                            
                            ; --- Send Low Byte of EEPROM Address ---
                            out     TWDR, r24
                            ldi     r16, TWI_SEND
                            out     TWCR, r16
                            
                            ; --- Wait ---
i2c_eeprom_write_byte_W4:   in      r16, TWCR
                            sbrs    r16, TWINT
                            rjmp    i2c_eeprom_write_byte_W4
                            
                            ; --- Check that Address Low Byte was sent ---
                            in      r16, TWSR
                            cpi     r16, TWI_MT_DATA_SENT_ACK
                            brne    i2c_eeprom_write_byte_E1
                            
                            ; --- Send Data Byte ---
                            out     TWDR, r18
                            ldi     r16, TWI_SEND
                            out     TWCR, r16
                            
                            ; --- Wait ---
i2c_eeprom_write_byte_W5:   in      r16, TWCR
                            sbrs    r16, TWINT
                            rjmp    i2c_eeprom_write_byte_W5
                            
                            ; --- Check that ... ---
                            in      r16, TWSR
                            cpi     r16, TWI_MT_DATA_SENT_ACK
                            brne    i2c_eeprom_write_byte_E1
                            
                            ; --- Skip Error Status ---
                            rjmp    i2c_eeprom_write_byte_W6
                            
                            ; --- Set Return Status to Error ---
i2c_eeprom_write_byte_E1:   ldi     r22, I2C_STATUS_ERR
                            
                            ; --- Send STOP Condition ---
i2c_eeprom_write_byte_W6:   ldi     r16, TWI_STOP
                            out     TWCR, r16
                            
                            ret
