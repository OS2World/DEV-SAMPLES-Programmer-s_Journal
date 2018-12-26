386_trap.obj:	386_trap.asm
	masm 386_trap/mx/zi;

386_asm.obj:	386_asm.asm
	masm 386_asm/mx/zi;

386_asm.exe:	386_asm.obj 386_trap.obj
	link 386_asm+386_trap/co;

386_msc.obj:	386_msc.asm
	masm 386_msc/mx/zi;

386_c.exe:	386_c.c 386_msc.obj 386_trap.obj
	cl 386_c.c 386_msc.obj 386_trap.obj /Zi
