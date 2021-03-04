
FROM ubuntu

ARG USERNAME=johndev
ARG PREFIX=/home/$USERNAME/opt/cross
ARG TARGET=i686-elf

ARG BINUTILS_MIRROR=https://ftp.gnu.org/gnu/binutils
ARG BINUTILS_VERSION=2.35.1

ARG GCC_VERSION=10.2.0
ARG GCC_URL=https://ftp.gnu.org/gnu/gcc/gcc-$GCC_VERSION/gcc-$GCC_VERSION.tar.gz

RUN apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install build-essential bison flex libgmp3-dev libmpc-dev libmpfr-dev texinfo wget git

RUN useradd -d /home/$USERNAME -s /bin/bash $USERNAME
RUN mkdir -p /home/$USERNAME
RUN chown -R $USERNAME /home/$USERNAME
USER $USERNAME

WORKDIR /home/$USERNAME
RUN wget $BINUTILS_MIRROR/binutils-$BINUTILS_VERSION.tar.gz
RUN tar -xzvf binutils-$BINUTILS_VERSION.tar.gz


RUN wget $GCC_URL
RUN tar -xzvf gcc-$GCC_VERSION.tar.gz

RUN mkdir build-binutils
RUN mkdir build-gcc
WORKDIR build-binutils
RUN ../binutils-$BINUTILS_VERSION/configure --target=$TARGET --prefix=$PREFIX --with-sysroot --disable-nls --disable-werror
RUN make && make install

WORKDIR ../gcc-$GCC_VERSION
RUN ./contrib/download_prerequisites

WORKDIR ../build-gcc
ENV PATH="$PREFIX/bin:$PATH"
RUN ../gcc-$GCC_VERSION/configure --target=$TARGET --prefix=$PREFIX --disable-nls --enable-languages=c,c++ --without-headers
RUN make all-gcc
RUN make all-target-libgcc
RUN make install-gcc
RUN make install-target-libgcc
