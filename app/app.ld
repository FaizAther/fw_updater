/* NUCLEO-F401RE (STM32F401RET6) — application linker script.
 *
 * 512K flash @ 0x08000000, 96K RAM @ 0x20000000.
 * For a bootloader split later, move APP_FLASH to 0x08004000 (16K bootloader),
 * set SCB_VTOR in firmware.c, and flash with: st-flash write firmware.bin 0x08004000
 */
EXTERN(vector_table)
ENTRY(reset_handler)

APP_FLASH = 0x08000000;
APP_RAM   = 0x20000000;

MEMORY
{
	rom (rx)  : ORIGIN = APP_FLASH, LENGTH = 512K
	ram (rwx) : ORIGIN = APP_RAM,   LENGTH = 96K
}

SECTIONS
{
	.text : {
		*(.vectors)
		*(.text*)
		. = ALIGN(4);
		*(.rodata*)
		. = ALIGN(4);
	} >rom

	.preinit_array : {
		. = ALIGN(4);
		__preinit_array_start = .;
		KEEP (*(.preinit_array))
		__preinit_array_end = .;
	} >rom

	.init_array : {
		. = ALIGN(4);
		__init_array_start = .;
		KEEP (*(SORT(.init_array.*)))
		KEEP (*(.init_array))
		__init_array_end = .;
	} >rom

	.fini_array : {
		. = ALIGN(4);
		__fini_array_start = .;
		KEEP (*(.fini_array))
		KEEP (*(SORT(.fini_array.*)))
		__fini_array_end = .;
	} >rom

	.ARM.extab : { *(.ARM.extab*) } >rom
	.ARM.exidx : {
		__exidx_start = .;
		*(.ARM.exidx*)
		__exidx_end = .;
	} >rom

	. = ALIGN(4);
	_etext = .;

	.noinit (NOLOAD) : { *(.noinit*) } >ram

	. = ALIGN(4);
	.data : {
		_data = .;
		*(.data*)
		*(.ramtext*)
		. = ALIGN(4);
		_edata = .;
	} >ram AT >rom
	_data_loadaddr = LOADADDR(.data);

	.bss : {
		*(.bss*)
		*(COMMON)
		. = ALIGN(4);
		_ebss = .;
	} >ram

	/DISCARD/ : { *(.eh_frame) }

	. = ALIGN(4);
	end = .;
}

PROVIDE(_stack = ORIGIN(ram) + LENGTH(ram));
