chmod u+x c_check
chmod u+x f_check
chmod u+x exports/gensymbol
# Replace void returns by int returns
sed -ri 's/void(\s+)BLASFUNC/int\1BLASFUNC/g' common_interface.h
sed -ri 's/void(\s+)cblas_/int\1cblas_/g' cblas.h ctest/*.c
sed -ri 's/void(\s+)(C?NAME)/int\1\2/g' interface/*.c
sed -ri 's/((extern)?.+) void ([a-z0-9]+_)/\1\2 int \3/g' lapack-netlib/SRC/*.c \
    lapack-netlib/SRC/DEPRECATED/*.c
# For some functions (mostly handling complex I think) f2c actually
# generate a function that returns void so I need to revert the void to int
# change the previous line does.
sed -ri 's@int ([cz](dotc|dotu|ladiv))@void \1@g' lapack-netlib/SRC/*.c\
    lapack-netlib/SRC/DEPRECATED/*.c

emmake make libs shared CC=emcc HOSTCC=gcc TARGET=RISCV64_GENERIC NOFORTRAN=1 NO_LAPACKE=1 \
    USE_THREAD=0 LDFLAGS="$EM_FORGE_SIDE_MODULE_LDFLAGS"
mkdir -p dist
# Add libf2c symbols to libopenblas.so
emcc $PREFIX/lib/libf2c.a libopenblas.a $EM_FORGE_SIDE_MODULE_LDFLAGS \
    -o libopenblas.so

cp libopenblas.so dist
emmake make install PREFIX=$PREFIX