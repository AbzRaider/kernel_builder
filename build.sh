

#!/usr/bin/env bash

# clone repo
git clone --depth=1 https://github.com/AbzRaider/android_kernel_realme_RMX2001.git -b Q
cd android_kernel_realme_RMX2001
# Dependencies
deps() {
        echo "Cloning dependencies"

        if [ ! -d "clang" ]; then
                mkdir clang && cd clang
               git clone --depth=1 https://github.com/kdrag0n/proton-clang.git 
	       mkdir llvm-project && cd llvm-project
	       git clone https://github.com/llvm/llvm-project.git
               cmake -DLLVM_ENABLE_PROJECTS=clang -DCMAKE_BUILD_TYPE=Release -G "Unix Makefiles" ../llvm
	       make clang
                cd ../


        fi
        echo "Done"
}

                      ARCH=arm64 \
                      CC="clang" \
                      LD=ld.lld \
		      AR=llvm-ar \
		      NM=llvm-nm \
		      OBJCOPY=llvm-objcopy \
		      OBJDUMP=llvm-objdump \
                      CLANG_TRIPLE=aarch64-linux-gnu- \
                      CROSS_COMPILE="${PWD}/clang/bin/aarch64-linux-gnu-" \
                      CROSS_COMPILE_ARM32="${PWD}/clang/bin/arm-linux-gnueabi-" \
                      CONFIG_NO_ERROR_ON_MISMATCH=y

IMAGE=$(pwd)/out/arch/arm64/boot/Image.gz-dtb
DATE=$(date +"%Y%m%d-%H%M")
START=$(date +"%s")
KERNEL_DIR=$(pwd)
CACHE=1
export CACHE
PATH="${PWD}/clang/bin:${PATH}"
export KBUILD_COMPILER_STRING
export ARCH
KBUILD_BUILD_HOST=AbzRaider
export KBUILD_BUILD_HOST
KBUILD_BUILD_USER="AbzRaider"
export KBUILD_BUILD_USER
DEFCONFIG="RMX2001_defconfig"
export DEFCONFIG
PROCS=$(nproc --all)
export PROCS
source "${HOME}"/.bashrc && source "${HOME}"/.profile

# Compile plox
compile() {

        if [ -d "out" ]; then
                rm -rf out && mkdir -p out
        fi

        make O=out ARCH=arm64 RMX2001_defconfig

        make -j"${PROCS}" O=out \
                ARCH=arm64 \
                      CC="clang" \
                      LD=ld.lld \
		      AR=llvm-ar \
		      NM=llvm-nm \
		      OBJCOPY=llvm-objcopy \
		      OBJDUMP=llvm-objdump \
                      CLANG_TRIPLE=aarch64-linux-gnu- \
                      CROSS_COMPILE="${PWD}/clang/bin/aarch64-linux-gnu-" \
                      CROSS_COMPILE_ARM32="${PWD}/clang/bin/arm-linux-gnueabi-" \
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
        zip -r9 Azrael-Test-OSS-KERNEL-"${CODENAME}"-"${DATE}".zip ./*
        curl -sL https://git.io/file-transfer | sh
        ./transfer wet Azrael-Test-OSS-KERNEL-"${CODENAME}"-"${DATE}".zip
        cd ..
}

deps
compile
zipping
END=$(date +"%s")
DIFF=$(($END - $START))









