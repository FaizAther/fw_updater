PROJECT     = firmware
OPENCM3_DIR = libopencm3
# NUCLEO-F401RE (STM32F401RET6, 512K flash, 96K RAM)
DEVICE      = stm32f401ret6

VPATH += app/src
OBJS = firmware.o

CFLAGS   += -Os -Wall -Wextra -ggdb3
CPPFLAGS += -MD
LDFLAGS  += -nostartfiles
LDLIBS   += -Wl,--start-group -lc -lgcc -lnosys -Wl,--end-group

APP_FLASH_ADDR = 0x08000000

OOCD_INTERFACE = stlink
OOCD_TARGET    = stm32f4x

include $(OPENCM3_DIR)/mk/genlink-config.mk
LDSCRIPT = app/app.ld
include $(OPENCM3_DIR)/mk/gcc-config.mk

.PHONY: all clean flash flash-stlink

all: $(PROJECT).elf $(PROJECT).bin

clean:
	$(RM) $(PROJECT).elf $(PROJECT).bin $(PROJECT).hex firmware.o firmware.d

flash: $(PROJECT).elf
	@echo "==> Flashing $< via OpenOCD..."
	openocd -f interface/$(OOCD_INTERFACE).cfg -f target/$(OOCD_TARGET).cfg \
		-c "program $(realpath $<) verify reset exit"
	@echo "==> Flash OK — verified and reset. MCU is running."

flash-stlink: $(PROJECT).bin
	@echo "==> Flashing $< @ $(APP_FLASH_ADDR) via st-flash..."
	st-flash write $< $(APP_FLASH_ADDR)
	@echo "==> Flash OK — verified. MCU is running."

include $(OPENCM3_DIR)/mk/gcc-rules.mk
