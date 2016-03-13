                            ; --- Set Return Status to I2C_STATUS_OK ---
i2c_eeprom_read_byte:       clr     I2C_RET_STAT
                            
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
                            
                            ; --- Check that Slave Addres + Write was sent ---
                            in      r16, TWSR
                            cpi     r16, TWI_MT_SLA_SENT_ACK
                            brne    i2c_eeprom_read_byte_E1
                            
                            ; --- Send High Byte of EEPROM Address ---
                            out     TWDR, I2C_ARG_ADDR_H
                            ldi     r16, TWI_SEND
                            out     TWCR, r16
                            
                            ; --- Wait ---
i2c_eeprom_read_byte_W3:    in      r16, TWCR
                            sbrs    r16, TWINT
                            rjmp    i2c_eeprom_read_byte_W3
                            
                            ; --- Check that Address High Byte was sent ---
                            in      r16, TWSR
                            cpi     r16, TWI_MT_DATA_SENT_ACK
                            brne    i2c_eeprom_read_byte_E1
                            
                            ; --- Send Low Byte of EEPROM Address ---
                            out     TWDR, I2C_ARG_ADDR_L
                            ldi     r16, TWI_SEND
                            out     TWCR, r16
                            
                            ; --- Wait ---
i2c_eeprom_read_byte_W4:    in      r16, TWCR
                            sbrs    r16, TWINT
                            rjmp    i2c_eeprom_read_byte_W4
                            
                            ; --- Check that Address Low Byte was sent ---
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
                            cpi     r16, TWI_RESTART_SENT
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
                            
                            ; --- Check that Slave Addres + Read was sent ---
                            in      r16, TWSR
                            cpi     r16, TWI_MR_SLA_SENT_ACK
                            brne    i2c_eeprom_read_byte_E1
                            
                            ; --- Receive Data Byte ---
                            ldi     r16, TWI_RECV_NACK
                            out     TWCR, r16
                            
                            ; --- Wait ---
i2c_eeprom_read_byte_W7:    in      r16, TWCR
                            sbrs    r16, TWINT
                            rjmp    i2c_eeprom_read_byte_W7
                            
                            ; --- Check that Data Byte was received ---
                            in      r16, TWSR
                            cpi     r16, TWI_MR_DATA_RECV_NACK
                            brne    i2c_eeprom_read_byte_E1
                            
                            ; --- Return Data Byte ---
                            in      I2C_ARG_DATA, TWDR
                            
                            ; --- Skip Error Status ---
                            rjmp    i2c_eeprom_read_byte_W8
                            
                            ; --- Set Return Status to Error ---
i2c_eeprom_read_byte_E1:    ldi     I2C_RET_STAT, I2C_STATUS_ERR
                            
                            ; --- Send STOP Condition ---
i2c_eeprom_read_byte_W8:    ldi     r16, TWI_STOP
                            out     TWCR, r16
                            
                            ret
