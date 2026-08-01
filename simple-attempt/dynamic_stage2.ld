ENTRY(start)
OUTPUT_FORMAT("binary")

SECTIONS
{
	/* 1st stage address */
	. = 0x7C00;

	.stage1 : {
		stage1.o(.text*)
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

	/* AT syntax is .thing LMA : AT(VMA) */
	.stage2 0x0500 : AT(0x7E00) {
		__s2_start = .
		stage2.o(.text*)
		stage2.o(.data*)
		stage2.o(.rodata*)
		stage2.o(.bss*)
		__s2_end = .
	}
	
	/* stage2 size in sectors! */
	__stage2_size = __s2_end - __s2_start
	__stage2_sectors = (__stage2_size + 511)/512
}
