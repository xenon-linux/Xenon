#!/bin/bash

REPO_PWD=`pwd`

check_exists(){
    if [ ! -e $1 ]; then
        echo "FATAL: $1 not found! Exiting. "
        exit 1
    else
        echo "OK: $1 found. Proceeding."
    fi
}

var_exists(){
    if [ ! "${1+defined}" ]; then
        echo "FATAL: Configuration/Variable $2 not found! Exiting."
        exit 1
    else
        echo "OK: Configuration/Variable $2 found. Proceeding"
    fi
}

divider(){
    echo "==========================="
}

check_exists $REPO_PWD/configuration
source $REPO_PWD/configuration


var_exists $REPO_PWD "REPO_PWD"
var_exists $XENON_BINS "XENON_BINS"

check_exists $XENON_BINS
check_exists $XENON_BINS/busybox
check_exists $XENON_BINS/linux_kernel

mkdir -p $XENON_BINS/extra $XENON_BINS/lib

echo
echo "Assertions done. Making squashfs and initramfs..."
divider

INITRD="$REPO_PWD/initrd"
XENON="$REPO_PWD/xenon"
SRC="$REPO_PWD/src"

mkdir -p $INITRD $XENON

echo "Making Initramfs directory:"
cd $INITRD
# Begin work on Initrd
cp $XENON_BINS/busybox .
mkdir -p ./bin
ln -sf /busybox ./bin/sh
cp $SRC/initrd.init ./init
# End work
cd -

echo "Making Xenon squashfs directory:"
cd $XENON
# Begin work on Xenon Squashfs
cp $XENON_BINS/busybox .
mkdir -p ./bin
ln -sf /busybox ./bin/sh
cp $SRC/xenon.init ./init
cp -r $SRC/etc/ .
cp -r $SRC/root/ .

cp -r $XENON_BINS/lib .
cp $XENON_BINS/extra/* ./bin/ 2> /dev/null > /dev/null
# End work
cd -

divider

$REPO_PWD/cpio
$REPO_PWD/sfs

cp $XENON_BINS/linux_kernel $REPO_PWD/kernel
rm -rf $XENON $INITRD
