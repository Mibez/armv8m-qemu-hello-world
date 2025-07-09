
armv8m-qemu-hello-world
---

Prerequisites
---

Download and extract your favorite cross-compile toolchain from https://developer.arm.com/downloads/-/arm-gnu-toolchain-downloads

(tested on ```arm-gnu-toolchain-14.2.rel1-x86_64-arm-none-eabi```)
```
wget https://developer.arm.com/-/media/Files/downloads/gnu/14.2.rel1/binrel/arm-gnu-toolchain-14.2.rel1-x86_64-arm-none-eabi.tar.xz
tar -xvf arm-gnu-toolchain-14.2.rel1-x86_64-arm-none-eabi.tar.xz
```

Build or install QEMU

Build:
```
$ git clone https://github.com/qemu/qemu.git
$ cd qemu	
$ mkdir build
$ cd build
$ ../configure --enable-debug
$ make
$ make install
```

Install:
```
sudo apt install qemu-system
```

Make sure the board you're targeting is supported by using qemu-system-arm after building qemu

```
$ qemu-system-arm -machine help
```

Quick Start
---

* run
```
$ cd armv8m-hello
$ make
$ make qemu
```

* debug qemu with kernel.elf

```
$ make
$ make gdbqemu

qemu-system-arm -machine mps2-an505 -cpu cortex-m33 -semihosting \
                    -m 16 \
                    -nographic -serial mon:stdio \
                    -kernel kernel.elf 
Hello World!
```

* debug kernel.elf in qemu

a terminal for the gdb server
```
$ make
$ make gdbserver
```

a terminal for gdb

```
$ make gdb
```

STM32 board
---

In order to run the example with STM32U545 board, compile the custom QEMU version from
https://github.com/Mibez/qemu

After this, run the same Make command with path to QEMU and provide the BOARD, for example

```
$ QEMU=../qemu/build/qemu-system-arm BOARD=stm32u545board make
```





