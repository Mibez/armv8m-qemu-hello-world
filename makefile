IMAGE := kernel.elf

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

CFLAGS = -mcpu=cortex-m33 -g -nostdlib -nostartfiles -ffreestanding
all: $(IMAGE)

OBJS = main.o

boot.o: boot.s
	$(CC) -mcpu=cortex-m33 -g -c boot.s -o boot.o

$(IMAGE): kernel.ld boot.o $(OBJS)
	$(LD) boot.o $(OBJS) -T kernel.ld -o $(IMAGE)
	$(OBJDUMP) -d $(IMAGE) > kernel.list
	$(OBJDUMP) -t $(IMAGE) | sed '1,/SYMBOL TABLE/d; s/ .* / /; /^$$/d' > kernel.sym
	$(READELF) -A $(IMAGE)

dumpvmstate:
	$(QEMU) -machine mps2-an505 -cpu cortex-m33 \
	                    -m 16 \
			    -nographic -serial mon:stdio \
	                    -kernel $(IMAGE) \
			    -dump-vmstate vmstate.json 

qemu:
	@$(QEMU) -M ? | grep mps2-an505 >/dev/null || exit
	$(QEMU) -machine mps2-an505 -cpu cortex-m33 -semihosting \
	                    -m 16 \
			    -nographic -serial mon:stdio \
	                    -kernel $(IMAGE) 

gdbserver:
	$(QEMU) -machine mps2-an505 -cpu cortex-m33 -semihosting \
	                    -m 16 \
			    -nographic -serial mon:stdio \
	                    -kernel $(IMAGE) \
			    -S -s 
gdb: $(IMAGE)
	$(GDB) $^ -ex "target remote:1234"


gdbqemu:
	gdb --args $(QEMU) -machine mps2-an505 -cpu cortex-m33 -semihosting -m 16 -nographic -serial mon:stdio -kernel kernel.elf


			    
clean:
	rm -f $(IMAGE) *.o *.list *.sym

.PHONY: all qemu clean
