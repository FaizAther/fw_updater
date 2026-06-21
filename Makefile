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

# Always link stm32f4 lib even before first build (genlink skips -l if .a is missing).
OPENCM3_LIB = $(OPENCM3_DIR)/lib/libopencm3_$(genlink_family).a
LIBDEPS := $(OPENCM3_LIB)
LDLIBS := $(filter-out -l -lopencm3_$(genlink_family),$(LDLIBS)) -lopencm3_$(genlink_family)

JOBS ?= $(shell nproc 2>/dev/null || echo 1)

.DEFAULT_GOAL := all

.PHONY: all clean flash flash-stlink libopencm3 libopencm3-clean compile_db

all: $(OPENCM3_LIB) $(PROJECT).elf $(PROJECT).bin

$(OPENCM3_LIB):
	@echo "==> Building libopencm3 ($(genlink_family))..."
	$(MAKE) -C $(OPENCM3_DIR) -j$(JOBS)

clean: libopencm3-clean
	$(RM) $(PROJECT).elf $(PROJECT).bin $(PROJECT).hex firmware.o firmware.d

libopencm3:
	$(MAKE) -C $(OPENCM3_DIR) -j$(JOBS)

libopencm3-clean:
	@echo "==> Cleaning libopencm3..."
	$(MAKE) -C $(OPENCM3_DIR) clean

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

# IDE: regenerate compile_commands.json + .clangd (clang/clangd, not arm-none-eabi-gcc)
compile_db:
	@PROJECT_ROOT="$(CURDIR)" CC="$(CC)" OPENCM3_DIR="$(OPENCM3_DIR)" python3 scripts/gen_compile_db.py
