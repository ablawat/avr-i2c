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
                                
                                ; --- X ---
                                clr     I2C_SM_BYTES
                                ldi     XL,  LOW(eeprom_cache)
                                ldi     XH, HIGH(eeprom_cache)
                                
                                ; --- Receive Data Byte ---
                                ldi     r16, TWI_RECV_ACK
                                out     TWCR, r16
                                
                                ; --- [BREAK] ---
                                rjmp    i2c_eeprom_statemachine_END
                                
                                ; --- [CASE] Data Byte was sent --- ACK was received ---
i2c_eeprom_statemachine_ST5:    ldi     r16, TWI_MT_DATA_SENT_ACK
                                cp      r16, I2C_SM_HSTAT
                                brne    i2c_eeprom_statemachine_ST6
                                
                                ; --- [IF] I2C State is Master Transmitter Entered ---
                                ldi     r16, I2C_STATE_MT_ENTERED
                                cp      r16, I2C_SM_STATE
                                brne    i2c_eeprom_statemachine_IF1
                                
                                ; --- Change Communication State ---
                                ldi     r16, I2C_STATE_EEP_ADDR_H_SENT
                                mov     I2C_SM_STATE, r16
                                
                                ; --- Send Low Byte of EEPROM Address ---
                                ldi     r16, I2C_SM_EEPROM_ADDR_L
                                out     TWDR, r16
                                ldi     r16, TWI_SEND
                                out     TWCR, r16
                                
                                ; --- [END] ---
                                rjmp    [X]
                                
                                ; --- [ELSE IF] I2C State is EEPROM Address High Sent ---
i2c_eeprom_statemachine_IF1:    ldi     r16, I2C_STATE_EEP_ADDR_H_SENT
                                cp      r16, I2C_SM_STATE
                                brne    i2c_eeprom_statemachine_IF2
                                
                                ; --- Change Communication State ---
                                ldi     r16, I2C_STATE_EEP_ADDR_L_SENT
                                mov     I2C_SM_STATE, r16
                                
                                ; --- [IF] I2C Mode is Write ---
                                sbrs    I2C_SM_FLAGS, I2C_MODE
                                rjmp    i2c_eeprom_statemachine_MD1
                                
                                ; --- Send First Byte from Cache ---
                                ldi     XH, I2C_SM_EEPROM_ADDR_H
                                ldi     XL, I2C_SM_EEPROM_ADDR_L
                                ld      r16, X
                                out     TWDR, r16
                                ldi     r16, TWI_SEND
                                out     TWCR, r16
                                
                                ; --- [ END IF] ---
                                rjmp    i2c_eeprom_statemachine_MD2
                                
                                ; --- [ELSE] Send Repeated START Condition ---
i2c_eeprom_statemachine_MD1:    ldi     r16, TWI_START
                                out     TWCR, r16
                                
                                ; --- [END] ---
i2c_eeprom_statemachine_MD2:    rjmp    [X]
                                
                                ; --- [ELSE IF] I2C State is EEPROM Address Low Sent ---
i2c_eeprom_statemachine_IF2:    ldi     r16, I2C_STATE_EEP_ADDR_L_SENT
                                cp      r16, I2C_SM_STATE
                                brne    i2c_eeprom_statemachine_IF3
                                
                                ; --- Change Communication State ---
                                ldi     r16, I2C_STATE_DATA_SENT
                                mov     I2C_SM_STATE, r16
                                
                                ; --- X ---
                                [INCREMENT NUMBER OF TRANSMITTED BYTES]
                                [INCREMENT EEPROM ADDRESS]
                                
                                ; --- Send Second Byte from Cache ---
                                ldi     XH, I2C_SM_EEPROM_ADDR_H
                                ldi     XL, I2C_SM_EEPROM_ADDR_L
                                ld      r16, X
                                out     TWDR, r16
                                ldi     r16, TWI_SEND
                                out     TWCR, r16
                                
                                ; --- [END] ---
                                rjmp    [X]
                                
                                ; --- [ELSE IF] I2C State is EEPROM Data Sent ---
i2c_eeprom_statemachine_IF3:    ldi     r16, I2C_STATE_DATA_SENT
                                cp      r16, I2C_SM_STATE
                                brne    [X]
                                
                                ; --- Then ---
                                []
                                
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
