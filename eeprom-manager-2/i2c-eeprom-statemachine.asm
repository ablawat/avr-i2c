                                ; --- Read TWI Status into Hardware Interrupt Flag ---
                                in      r16, TWCR
                                bst     r16, TWINT
                                bld     I2C_STATUS, I2C_HINT
                                
                                ; --- Check State Machine Entry Condition ---
                                mov     r16, I2C_STATUS
                                andi    r16, I2C_SM_ENTER_MASK
                                cpi     r16, I2C_SM_ENTER_MASK
                                brne    i2c_eeprom_statemachine_END
                                
                                [TBD][Handle I2C State Machine]
                                
i2c_eeprom_statemachine_END:
