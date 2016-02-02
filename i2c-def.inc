; --- Status Codes for Transmission Beginning ---
.EQU I2C_START_SENT    = 0x08
.EQU I2C_RE_START_SENT = 0x10

; --- Direction Flags in Master Mode ---
.EQU I2C_READ  = 1
.EQU I2C_WRITE = 0

; --- Acknowledge Bit Values ---
.EQU I2C_SEND_ACK  = (1 << TWEA)
.EQU I2C_SEND_NACK = (0 << TWEA)

; --- Status Codes for Master Transmitter ---
.EQU I2C_MT_SLA_SENT_ACK   = 0x18
.EQU I2C_MT_SLA_SENT_NACK  = 0x20
.EQU I2C_MT_DATA_SENT_ACK  = 0x28
.EQU I2C_MT_DATA_SENT_NACK = 0x30

; --- Status Codes for Master Receiver ---
.EQU I2C_MR_SLA_SENT_ACK   = 0x40
.EQU I2C_MR_SLA_SENT_NACK  = 0x48
.EQU I2C_MR_DATA_RECV_ACK  = 0x50
.EQU I2C_MR_DATA_RECV_NACK = 0x58

; --- Register Values for Transmission ---
.EQU I2C_START = (1 << TWINT) | (1 << TWSTA) | (1 << TWEN)
.EQU I2C_STOP  = (1 << TWINT) | (1 << TWSTO) | (1 << TWEN)
.EQU I2C_SEND  = (1 << TWINT) | (1 << TWEN)
