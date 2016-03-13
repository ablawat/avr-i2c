; --- Status Codes for Transmission Beginning ---
.EQU TWI_START_SENT   = 0x08
.EQU TWI_RESTART_SENT = 0x10

; --- Direction Flags in Master Mode ---
.EQU TWI_READ  = 1
.EQU TWI_WRITE = 0

; --- Status Codes for Master Transmitter ---
.EQU TWI_MT_SLA_SENT_ACK   = 0x18
.EQU TWI_MT_SLA_SENT_NACK  = 0x20
.EQU TWI_MT_DATA_SENT_ACK  = 0x28
.EQU TWI_MT_DATA_SENT_NACK = 0x30

; --- Status Codes for Master Receiver ---
.EQU TWI_MR_SLA_SENT_ACK   = 0x40
.EQU TWI_MR_SLA_SENT_NACK  = 0x48
.EQU TWI_MR_DATA_RECV_ACK  = 0x50
.EQU TWI_MR_DATA_RECV_NACK = 0x58

; --- Register Values for Transmission Control ---
.EQU TWI_START = (1 << TWINT) | (1 << TWSTA) | (1 << TWEN)
.EQU TWI_STOP  = (1 << TWINT) | (1 << TWSTO) | (1 << TWEN)

; --- Register Values for Data Transmission ---
.EQU TWI_SEND      = (1 << TWINT) | (1 << TWEN)
.EQU TWI_RECV_ACK  = (1 << TWINT) | (1 << TWEA) | (1 << TWEN)
.EQU TWI_RECV_NACK = (1 << TWINT) | (0 << TWEA) | (1 << TWEN)
