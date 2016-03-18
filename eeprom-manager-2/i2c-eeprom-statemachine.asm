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
i2c_eeprom_statemachine_ST1:    cpi     I2C_SM_HSTAT, TWI_START_SENT
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
i2c_eeprom_statemachine_ST2:    cpi     I2C_SM_HSTAT, TWI_RESTART_SENT
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
i2c_eeprom_statemachine_ST3:    cpi     I2C_SM_HSTAT, TWI_MT_SLA_SENT_ACK
                                brne    i2c_eeprom_statemachine_ST4
                                
                                ; --- Change Communication State ---
                                ldi     r16, I2C_STATE_MT_ENTERED
                                mov     I2C_SM_STATE, r16
                                
                                ; --- Send High Byte of EEPROM Address ---
                                ldi     r16, [[X]]
                                out     TWDR, r16
                                ldi     r16, TWI_SEND
                                out     TWCR, r16
                                
                                ; --- [BREAK] ---
                                rjmp    i2c_eeprom_statemachine_END
                                
                                ; --- [CASE] Slave Addres + Read was sent ---
i2c_eeprom_statemachine_ST4:    cpi     I2C_SM_HSTAT, TWI_MR_SLA_SENT_ACK
                                brne    [[X]]
                                
                                ; --- Change Communication State ---
                                ldi     r16, I2C_STATE_MR_ENTERED
                                mov     I2C_SM_STATE, r16
                                
                                ; --- Comment ---
                                [TBD][Read first byte from SRAM CACHE]
                                
                                ; --- [BREAK] ---
                                rjmp    i2c_eeprom_statemachine_END
i2c_eeprom_statemachine_END:
