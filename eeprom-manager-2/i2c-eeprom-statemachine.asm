                                ; --- Read TWI Status into Hardware Interrupt Flag ---
                                in      r16, TWCR
                                bst     r16, TWINT
                                bld     I2C_SM_FLAGS, I2C_HINT
                                
                                ; --- Check State Machine Entry Condition ---
                                mov     r16, I2C_SM_FLAGS
                                andi    r16, I2C_SM_ENTER_MASK
                                cpi     r16, I2C_SM_ENTER_MASK
                                brne    i2c_eeprom_statemachine_END
                                
                                ; --- [SWITCH] TWI Status ---
                                in      I2C_SM_HSTAT, TWSR
                                
                                ; --- [CASE] START Condition was sent ---
i2c_eeprom_statemachine_ST1:    ldi     r16, TWI_START_SENT
                                cp      r16, I2C_SM_HSTAT
                                brne    i2c_eeprom_statemachine_ST2
                                
                                ; --- Change Communication State ---
                                ldi     r16, I2C_STATE_STARTED
                                mov     I2C_SM_STATE, r16
                                
                                ; --- Send Slave Device Address + Write ---
                                ldi     r16, EEPROM_DEV_ADDR | TWI_WRITE
                                out     TWDR, r16
                                ldi     r16, TWI_SEND
                                out     TWCR, r16
                                
                                ; --- [BREAK] ---
                                rjmp    i2c_eeprom_statemachine_END
                                
                                ; --- [CASE] Repeated START Condition was sent ---
i2c_eeprom_statemachine_ST2:    ldi     r16, TWI_RESTART_SENT
                                cp      r16, I2C_SM_HSTAT
                                brne    i2c_eeprom_statemachine_ST3
                                
                                ; --- Change Communication State ---
                                ldi     r16, I2C_STATE_RESTARTED
                                mov     I2C_SM_STATE, r16
                                
                                ; --- Send Slave Device Address + Read ---
                                ldi     r16, EEPROM_DEV_ADDR | TWI_READ
                                out     TWDR, r16
                                ldi     r16, TWI_SEND
                                out     TWCR, r16
                                
                                ; --- [BREAK] ---
                                rjmp    i2c_eeprom_statemachine_END
                                
                                ; --- [CASE] Slave Addres + Write was sent ---
i2c_eeprom_statemachine_ST3:    ldi     r16, TWI_MT_SLA_SENT_ACK
                                cp      r16, I2C_SM_HSTAT
                                brne    i2c_eeprom_statemachine_ST4
                                
                                ; --- Change Communication State ---
                                ldi     r16, I2C_STATE_MT_ENTERED
                                mov     I2C_SM_STATE, r16
                                
                                ; --- Send High Byte of EEPROM Address ---
                                ldi     r16, I2C_SM_EEPROM_ADDR_H
                                out     TWDR, r16
                                ldi     r16, TWI_SEND
                                out     TWCR, r16
                                
                                ; --- [BREAK] ---
                                rjmp    i2c_eeprom_statemachine_END
                                
                                ; --- [CASE] Slave Addres + Read was sent ---
i2c_eeprom_statemachine_ST4:    ldi     r16, TWI_MR_SLA_SENT_ACK
                                cp      r16, I2C_SM_HSTAT
                                brne    i2c_eeprom_statemachine_ST5
                                
                                ; --- Change Communication State ---
                                ldi     r16, I2C_STATE_MR_ENTERED
                                mov     I2C_SM_STATE, r16
                                
                                ; --- Comment ---
                                [TBD][Read first byte from SRAM CACHE]
                                
                                ; --- [BREAK] ---
                                rjmp    i2c_eeprom_statemachine_END
                                
                                ; --- [CASE] Data Byte was sent --- ACK was received ---
i2c_eeprom_statemachine_ST5:    ldi     r16, TWI_MT_DATA_SENT_ACK
                                cp      r16, I2C_SM_HSTAT
                                brne    i2c_eeprom_statemachine_ST6
                                
                                ; --- Comment ---
                                [TBD][Handle State Function]
                                
                                ; --- [BREAK] ---
                                rjmp    i2c_eeprom_statemachine_END
                                
                                ; --- [CASE] Data Byte was received --- ACK was sent ---
i2c_eeprom_statemachine_ST6:    ldi     r16, TWI_MR_DATA_RECV_ACK
                                cp      r16, I2C_SM_HSTAT
                                brne    i2c_eeprom_statemachine_ST7
                                
                                ; --- Comment ---
                                [TBD][Handle State Function]
                                
                                ; --- [BREAK] ---
                                rjmp    i2c_eeprom_statemachine_END
                                
                                ; --- [CASE] Data Byte was received --- NACK was sent ---
i2c_eeprom_statemachine_ST7:    ldi     r16, TWI_MR_DATA_RECV_NACK
                                cp      r16, I2C_SM_HSTAT
                                brne    [[X]]
                                
                                ; --- Change Communication State ---
                                ldi     r16, I2C_STATE_IDLE
                                mov     I2C_SM_STATE, r16
                                
                                ; --- Send STOP Condition ---
                                ldi     r16, TWI_STOP
                                out     TWCR, r16
                                
                                ; --- [BREAK] ---
                                rjmp    i2c_eeprom_statemachine_END
                                
i2c_eeprom_statemachine_END:
