IMAGE := kernel.elf

# Supported boards: mps2-an505, stm32u545board

ifndef BOARD
BOARD = mps2-an505
endif

ifndef CROSS_COMPILE
CROSS_COMPILE = ./arm-gnu-toolchain-14.2.rel1-x86_64-arm-none-eabi/bin/arm-none-eabi-
endif

ifndef QEMU
QEMU = qemu-system-arm
endif

CC = $(CROSS_COMPILE)gcc
LD = $(CROSS_COMPILE)ld
GDB = $(CROSS_COMPILE)gdb
OBJDUMP = $(CROSS_COMPILE)objdump
READELF = $(CROSS_COMPILE)readelf
LINKER_SCRIPT = kernel_mps.ld
ifeq (stm32u545board, $(BOARD))
	LINKER_SCRIPT = kernel_stm.ld
	BOARD_DEFS = -DSTM32U545XX
else
	BOARD_DEFS = -DMPS2AN505
endif

CFLAGS = -mcpu=cortex-m33 -g -nostdlib -nostartfiles -ffreestanding -DBOARD=$(BOARD) $(BOARD_DEFS)
all: $(IMAGE)

OBJS = main.o

boot.o: boot.s
	$(CC) -mcpu=cortex-m33 -g -O0 -c boot.s -o boot.o

$(IMAGE): $(LINKER_SCRIPT) boot.o $(OBJS)
	$(LD) boot.o $(OBJS) -T $(LINKER_SCRIPT) -o $(IMAGE)
	$(OBJDUMP) -d $(IMAGE) > kernel.list
	$(OBJDUMP) -t $(IMAGE) | sed '1,/SYMBOL TABLE/d; s/ .* / /; /^$$/d' > kernel.sym
	$(READELF) -A $(IMAGE)

dumpvmstate:
	$(QEMU) -machine $(BOARD) -cpu cortex-m33 \
	                    -m 16 \
			    -nographic -serial mon:stdio \
	                    -kernel $(IMAGE) \
			    -dump-vmstate vmstate.json 

qemu:
	@$(QEMU) -M ? | grep $(BOARD) >/dev/null || exit
	$(QEMU) -machine $(BOARD) -cpu cortex-m33 -semihosting \
	                    -m 16 \
			    -nographic -serial mon:stdio \
	                    -kernel $(IMAGE) 

gdbserver:
	$(QEMU) -machine $(BOARD) -cpu cortex-m33 -semihosting \
	                    -m 16 \
			    -nographic -serial mon:stdio \
	                    -kernel $(IMAGE) \
			    -S -s 
gdb: $(IMAGE)
	$(GDB) $^ -ex "target remote:1234"


gdbqemu:
	gdb --args $(QEMU) -machine $(BOARD) -cpu cortex-m33 -semihosting -m 16 -nographic -serial mon:stdio -kernel kernel.elf


			    
clean:
	rm -f $(IMAGE) *.o *.list *.sym

.PHONY: all qemu clean
