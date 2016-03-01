WINE    = wine
AS      = avrasm2.exe
FLAGS   = -f I

INCLUDE = -I ~/avr-include -I ..


eeprom-manager-1: *.asm *.inc
	$(WINE) $(AS) $(INCLUDE) $(FLAGS) -o eeprom-manager-1.hex main.asm

clean:
	rm -f eeprom-manager-1.hex
