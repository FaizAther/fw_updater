# FW Update

Target board: **NUCLEO-F401RE** (MCU **STM32F401RET6**).

| Item | Value |
|------|--------|
| Flash | 512 KB @ `0x08000000` |
| RAM | 96 KB @ `0x20000000` |
| User LED | **LD2** (green) on **PA5** |
| Debugger | Built-in **ST-LINK/V2.1** (USB port **CN1**) |

## Description

[Blinky To Bootloader](<https://www.youtube.com/watch?v=uQQsDWLRDuI&list=PLP29wDx6QmW7HaCrRydOnxcy8QmW0SNdQ>)

```sh
sudo apt install stlink-tools openocd gcc-arm-none-eabi gdb-multiarch
sudo st-info --probe
Found 1 stlink programmers
  version:    V2J44S29
  serial:     066BFF555185754867155637
  flash:      524288 (pagesize: 16384)
  sram:       98304
  chipid:     0x433
  dev-type:   STM32F401xD_xE
```

## Build

```sh
cd libopencm3 && make -j$(nproc)   # once
cd ..
make                               # app/src/firmware.c → firmware.elf (app/app.ld)
make flash                         # OpenOCD
make flash-stlink                  # st-flash @ 0x08000000
```

Linker script: **`app/app.ld`**. Entry is `main()` in **`app/src/firmware.c`**.

No board-specific Makefile changes needed — `DEVICE=stm32f401ret6`, **PA5** LED, and your `st-info` output already match this Nucleo.

**Flash/debug:** plug USB into **CN1** (ST-LINK, not CN2 target USB). Press **BLACK** reset if the LED does not update after flashing.

## USB permissions (required for VS Code / no sudo)

Without this, `make flash` and `make flash-stlink` fail with `LIBUSB_ERROR_ACCESS`:

```sh
sudo cp udev/99-stlink.rules /etc/udev/rules.d/
sudo udevadm control --reload-rules && sudo udevadm trigger
# unplug and replug the ST-LINK
```

With `sudo`, flash works — `shutdown command invoked` at the end is **normal success**, not an abort. You should also see `==> Flash OK` from the Makefile. Check with `make flash; echo exit:$?` — **`exit:0` means success**.

If flash succeeds but **no LED blink**, press reset and confirm **LD2** (green, PA5) — not LD3 (red, PB13, serial activity).

## VS Code

1. Install recommended extensions: **Cortex-Debug**, **C/C++**
2. Apply udev rules above (OpenOCD cannot run as root from the debugger)
3. **Build:** `Ctrl+Shift+B` (runs `make`)
4. **Flash:** Run Task → *Flash (OpenOCD)* or *Flash (st-flash)*
5. **Debug:** *Debug (ST-LINK + OpenOCD)* — breaks at `main`