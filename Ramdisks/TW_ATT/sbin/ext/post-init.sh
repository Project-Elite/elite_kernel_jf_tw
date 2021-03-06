#!/sbin/busybox sh
#
#Set Max Mhz for GPU
echo 400000000 > /sys/devices/platform/kgsl-3d0.0/kgsl/kgsl-3d0/max_gpuclk

#Set Max Mhz speed and booted flag to set Super Max
echo 1890000 > /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq;

# Remount FileSys RW
/sbin/busybox mount -t rootfs -o remount,rw rootfs

## Create the kernel data directory
if [ ! -d /data/.elite ];
then
  mkdir /data/.elite
  chmod 777 /data/.elite
fi

## Enable "post-init" ...
if [ -f /data/.elite/post-init.log ];
then
  # BackUp old post-init log
  mv /data/.elite/post-init.log /data/.elite/post-init.log.BAK
fi

# Start logging
date >/data/.elite/post-init.log
exec >>/data/.elite/post-init.log 2>&1

echo "Running Post-Init Script"

## Testing: Check for ExFat SD Card
#
SDTYPE1=`blkid /dev/block/mmcblk1  | awk '{ print $3 }' | sed -e 's|TYPE=||g' -e 's|\"||g'`
SDTYPE2=`blkid /dev/block/mmcblk1p1  | awk '{ print $3 }' | sed -e 's|TYPE=||g' -e 's|\"||g'`

if [ "${SDTYPE1}" == "exfat" ];
then
  echo "ExFat-Debug: SD-Card is type ExFAT"
  echo "ExFat-Debug: trying to mount via fuse"
  mount.exfat-fuse /dev/block/mmcblk1 /storage/extSdCard
else
  echo "ExFat-Debug: SD-Card is type1: ${SDTYPE1}"
fi
if [ "${SDTYPE2}" == "exfat" ];
then
  echo "ExFat-Debug: SD-Card is type ExFAT"
  echo "ExFat-Debug: trying to mount via fuse"
  mount.exfat-fuse /dev/block/mmcblk1p1 /storage/extSdCard
else
  echo "ExFat-Debug: SD-Card is type2: ${SDTYPE2}"
fi

# Remount FileSys RO
/sbin/busybox mount -t rootfs -o remount,ro rootfs

echo $(date) END of post-init.sh
