#!/bin/sh

BASE_URL="http://developer.nvidia.com/sites/default/files/akamai/mobile/files/L4T"
FILE_T30_R16="cardhu_Tegra-Linux-R16.3.0_armhf.tbz2"
SHA1_T30_R16="3562703ca78e0fb7bdf877bb0d9353e4c82f6c97"
DST="tegra30-r16/nvidia-rootfs"
SRC="Linux_for_Tegra"
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

tar jxf $SRC/nv_tegra/nvidia_drivers.tbz2 -C $DST

tar jxf $SRC/nv_tegra/config.tbz2 -C $DST --exclude=etc/wpa_supplicant.conf --exclude=etc/init --exclude=etc/X11

tar jxf $SRC/nv_tegra/nv_sample_apps/nvgstapps.tbz2 -C $DST

mv $DST/usr/lib/xorg/modules/drivers/tegra_drv.abi$DEBIAN_XORG_ABI.so $DST/usr/lib/xorg/modules/drivers/tegra_drv.so
rm $DST/usr/lib/xorg/modules/drivers/tegra_drv.abi*.so

mkdir -p $DST/$TEGRA_LIBDIR
mv $DST/usr/lib/lib*so* $DST/$TEGRA_LIBDIR

ln -s libEGL.so.1 $DST/$TEGRA_LIBDIR/libEGL.so
ln -s libGLESv1_CM.so.1 $DST/$TEGRA_LIBDIR/libGLESv1_CM.so
ln -s libGLESv2.so.2 $DST/$TEGRA_LIBDIR/libGLESv2.so

cp $SRC/nv_tegra/LICENSE* $DST/

echo "Binaries extracted"
