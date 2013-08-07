#!/bin/sh

BASE_URL="http://developer.nvidia.com/sites/default/files/akamai/mobile/files/L4T"
FILE_T30_R16="cardhu_Tegra-Linux-codecs-R16.3.0_armhf.tbz2"
SHA1_T30_R16="93aea55ff10d6359dfea00a1d344f4ec84a2cbb8"
DST="tegra30-r16/nvidia-rootfs"
SRC="restricted_codecs.tbz2"
TEGRA_LIBDIR="usr/lib/tegra30"
DEBIAN_XORG_ABI="12"

if [ ! -f $FILE_T30_R16 ]
then
  wget $BASE_URL/$FILE_T30_R16
else
  echo "$FILE_T30_R16 found, not downloading."
fi

echo "$SHA1_T30_R16  $FILE_T30_R16" > $FILE_T30_R16.sha1sum 

if ! sha1sum -c $FILE_T30_R16.sha1sum
then
  echo "ERROR: sha1sum mismatch"
  exit
fi

echo "Extracting binaries..."
tar jxf $FILE_T30_R16

mkdir -p $DST

tar jxf $SRC -C $DST
cp Tegra_Software_License_Agreement-Tegra-Linux-codecs.txt $DST

echo "Binaries extracted"
