
# source this file

# <1> toolchain

VER_BINUTILS=2.40

# note : gcc-pch.patch -- https://gcc.gnu.org/bugzilla/show_bug.cgi?id=14940
VER_GCC=13.0.1
#VER_GCC=10.3.0
# gdb 11.1/11.2 build error, readline not found
# VER_GDB=11.2
# VER_GDB=10.2
VER_GDB=13.1
VER_GMP=6.2.1
VER_MPFR=4.2.0
VER_MPC=1.3.1

# https://gcc.gnu.org/pub/gcc/infrastructure/
# note isl 0.14 cause cloog error,
# VER_ISL=0.12.2
# VER_CLOOG=0.18.1
# note gcc 5 no longer need cloog
# note isl 0.15 cause gcc 5.2.0 error, gcc 5.3.0 ok
VER_ISL=0.24

VER_MINGW64=10.0.0
# make 4.3 build error, fcntl conflict
# VER_MAKE=4.3
# VER_MAKE=4.2.1
VER_MAKE=4.4
VER_YASM=1.3.0
# nsam 2.16.01 faild, fatal error: asm/warnings.c: No such file or directory
# VER_NASM=2.16.01
VER_NASM=2.15.05


