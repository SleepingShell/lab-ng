rm -rf /var/lib/rook
ls /dev/mapper/ceph-* | xargs -I% -- dmsetup remove %
rm -rf /dev/ceph-*

hdds=("sdc" "sde" "sdf" "sdg" "sdh")
ssds=("sda" "sdb" "nvme1n1")
for ssd in "${ssds[@]}"
do
  sgdisk --zap-all "/dev/$ssd"
  blkdiscard "/dev/$ssd"
  partprobe "/dev/$ssd"
done

for hdd in "${hdds[@]}"
do
  sgdisk --zap-all "/dev/$hdd"
  dd if=/dev/zero of="/dev/$hdd" bs=1M count=100 oflag=direct,dsync
  partprobe "/dev/$ssd"
done