

#!/usr/bin/env bash

# clone repo
git clone --depth=1 https://github.com/AbzRaider/android-kernel_Azrael-RM6785.git -b oc
cd android-kernel_Azrael-RM6785
# Dependencies
deps() {
        echo "Cloning dependencies"

        if [ ! -d "clang" ]; then
                mkdir clang && cd clang
                wget https://raw.githubusercontent.com/Neutron-Toolchains/antman/main/antman
                chmod 744 antman && ./antman -S && cd ../
                KBUILD_COMPILER_STRING="Neutron Clang 16"
        fi
        echo "Done"
}

IMAGE=$(pwd)/out/arch/arm64/boot/Image.gz-dtb
DATE=$(date +"%Y%m%d-%H%M")
START=$(date +"%s")
KERNEL_DIR=$(pwd)
CACHE=1
export CACHE
PATH="${PWD}/clang/bin:${PATH}"
export KBUILD_COMPILER_STRING
ARCH=arm64
export ARCH
KBUILD_BUILD_HOST=AbzRaider
export KBUILD_BUILD_HOST
KBUILD_BUILD_USER="AbzRaider"
export KBUILD_BUILD_USER
DEFCONFIG="RM6785_defconfig"
export DEFCONFIG
PROCS=$(nproc --all)
export PROCS
source "${HOME}"/.bashrc && source "${HOME}"/.profile

# Compile plox
compile() {

        if [ -d "out" ]; then
                rm -rf out && mkdir -p out
        fi

        make O=out ARCH="${ARCH}" "${DEFCONFIG}"

        make -j"${PROCS}" O=out \
                ARCH=$ARCH \
                CC="clang" \
                LD=ld.lld \
                CROSS_COMPILE=aarch64-linux-gnu- \
                CROSS_COMPILE_ARM32=arm-linux-gnueabi- \
                AR=llvm-ar \
                NM=llvm-nm \
                OBJCOPY=llvm-objcopy \
                OBJDUMP=llvm-objdump \
                STRIP=llvm-strip
        CONFIG_NO_ERROR_ON_MISMATCH=y 2>&1 | tee error.log

        if ! [ -a "$IMAGE" ]; then
                exit 1
        fi

        git clone --depth=1 https://github.com/AbzRaider/AnyKernel33 AnyKernel
        cp out/arch/arm64/boot/Image.gz-dtb AnyKernel
}
# Zipping
zipping() {
        cd AnyKernel || exit 1
        zip -r9 Azrael-OSS-KERNEL-"${CODENAME}"-"${DATE}".zip ./*
        curl -sL https://git.io/file-transfer | sh
        ./transfer wet Azrael-OSS-KERNEL-"${CODENAME}"-"${DATE}".zip
        cd ..
}

deps
compile
zipping
END=$(date +"%s")
DIFF=$(($END - $START))









