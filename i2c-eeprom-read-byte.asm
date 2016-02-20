                            ; --- Set Return Status to I2C_STATUS_OK ---
i2c_eeprom_read_byte:       clr     r22
                            
                            ; --- Send START Condition ---
                            ldi     r16, TWI_START
                            out     TWCR, r16
                            
                            ; --- Wait ---
i2c_eeprom_read_byte_W1:    in      r16, TWCR
                            sbrs    r16, TWINT
                            rjmp    i2c_eeprom_read_byte_W1
                            
                            ; --- Check that START Condition was sent ---
                            in      r16, TWSR
                            cpi     r16, TWI_START_SENT
                            brne    i2c_eeprom_read_byte_E1
                            
                            ; --- Send Slave Device Address + Write ---
                            ldi     r16, EEPROM_DEV_ADDR | TWI_WRITE
                            out     TWDR, r16
                            ldi     r16, TWI_SEND
                            out     TWCR, r16
                            
                            ; --- Wait ---
i2c_eeprom_read_byte_W2:    in      r16, TWCR
                            sbrs    r16, TWINT
                            rjmp    i2c_eeprom_read_byte_W2
                            
                            ; --- Check that ... ---
                            in      r16, TWSR
                            cpi     r16, TWI_MT_SLA_SENT_ACK
                            brne    i2c_eeprom_read_byte_E1
                            
                            ; --- Send High Byte of EEPROM Address ---
                            out     TWDR, r25
                            ldi     r16, TWI_SEND
                            out     TWCR, r16
                            
                            ; --- Wait ---
i2c_eeprom_read_byte_W3:    in      r16, TWCR
                            sbrs    r16, TWINT
                            rjmp    i2c_eeprom_read_byte_W3
                            
                            ; --- Check that ... ---
                            in      r16, TWSR
                            cpi     r16, TWI_MT_DATA_SENT_ACK
                            brne    i2c_eeprom_read_byte_E1
                            
                            ; --- Send Low Byte of EEPROM Address ---
                            out     TWDR, r24
                            ldi     r16, TWI_SEND
                            out     TWCR, r16
                            
                            ; --- Wait ---
i2c_eeprom_read_byte_W4:    in      r16, TWCR
                            sbrs    r16, TWINT
                            rjmp    i2c_eeprom_read_byte_W4
                            
                            ; --- Check that ... ---
                            in      r16, TWSR
                            cpi     r16, TWI_MT_DATA_SENT_ACK
                            brne    i2c_eeprom_read_byte_E1
                            
                            ; --- Send Repeated START Condition ---
                            ldi     r16, TWI_START
                            out     TWCR, r16
                            
                            ; --- Wait ---
i2c_eeprom_read_byte_W5:    in      r16, TWCR
                            sbrs    r16, TWINT
                            rjmp    i2c_eeprom_read_byte_W5
                            
                            ; --- Check that Repeated START Condition was sent ---
                            in      r16, TWSR
                            cpi     r16, TWI_RE_START_SENT
                            brne    i2c_eeprom_read_byte_E1
                            
                            ; --- Send Slave Device Address + Read ---
                            ldi     r16, EEPROM_DEV_ADDR | TWI_Read
                            out     TWDR, r16
                            ldi     r16, TWI_SEND
                            out     TWCR, r16
                            
                            ; --- Wait ---
i2c_eeprom_read_byte_W6:    in      r16, TWCR
                            sbrs    r16, TWINT
                            rjmp    i2c_eeprom_read_byte_W6
                            
                            ; --- Check that ... ---
                            in      r16, TWSR
                            cpi     r16, TWI_MR_SLA_SENT_ACK
                            brne    i2c_eeprom_read_byte_E1
                            
                            ; --- Read Data Byte ---
                            ldi     r16, TWI_SEND | TWI_SEND_NACK
                            out     TWCR, r16
                            
                            ; --- Wait ---
i2c_eeprom_read_byte_W7:    in      r16, TWCR
                            sbrs    r16, TWINT
                            rjmp    i2c_eeprom_read_byte_W7
                            
                            ; --- Check that ... ---
                            in      r16, TWSR
                            cpi     r16, TWI_MR_DATA_RECV_NACK
                            brne    i2c_eeprom_read_byte_E1
                            
                            ; --- Return Data Byte ---
                            in      r18, TWDR
                            
                            ; --- Skip Error Status ---
                            rjmp    i2c_eeprom_read_byte_W8
                            
                            ; --- Set Return Status to Error ---
i2c_eeprom_read_byte_E1:    ldi     r22, I2C_STATUS_ERR
                            
                            ; --- Send STOP Condition ---
i2c_eeprom_read_byte_W8:    ldi     r16, TWI_STOP
                            out     TWCR, r16
                            
                            ret
