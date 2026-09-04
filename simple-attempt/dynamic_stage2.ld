ENTRY(start)
OUTPUT_FORMAT("binary")

SECTIONS
{
	/* 1st stage address */
	. = 0x7C00;

	.stage1 : {
		first_stage.o(.text)
	}

	/* Padding up to boot sector signature */
	. = 0x7C00 + 510;

	/* */
	.bootsig : {
		SHORT(0xAA55)
	}

	/* 2nd stage address
	   I decided on putting it between 
	   0x00000500 and 0x00007BFF
	   it's 29.75KiB
	*/

	/* AT syntax is .thing VMA : AT(LMA) */
	.stage2 0x0500 : AT(0x7E00) {
		__s2_start = .;
		second_stage.o(.text)
		second_stage.o(.data)
		second_stage.o(.rodata)
		second_stage.o(.bss)

		. = ALIGN(512);

		__s2_end = .;
	}

	.
	/* Kernel */
	.kernel 0x00104000 : AT(LOADADDR(.stage2) + SIZEOF(.stage2)){
		__k_start = .;
		kernel.o(.text)
		kernel.o(.data)
		kernel.o(.rodata)
		kernel.o(.bss)

		. = ALIGN(512);
		__k_end = .;
	}


	/* Stage2 size in sectors! */
	__s2_size = __s2_end - __s2_start;
	__s2_sectors = (__s2_size + 511)/512;

	/* Same for Kernel */
	__k_size = __k_end - __k_start;
	__k_sectors = (__k_size + 511)/512;
}
