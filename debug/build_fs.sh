OUT_DIR=out_dir
IMAGE_DIR=my-fs

rm -rf ${OUT_DIR} ${IMAGE_DIR}

mkdir -p ${OUT_DIR}
cd busybox-1.35.0
make O=../${OUT_DIR} defconfig
# 必须静态链接
make O=../${OUT_DIR} menuconfig
cd ../${OUT_DIR}
make -j12
make install

cd ..
mkdir -p ${IMAGE_DIR}
cd ${IMAGE_DIR}
mkdir -pv {bin,dev,sbin,etc,proc,sys/kernel/debug,usr/{bin,sbin},lib,lib64,mnt/root,root}
cp -av /dev/{null,console,tty,sda1} dev
cd ..
cp -av ${OUT_DIR}/_install/* ${IMAGE_DIR}
cd ${IMAGE_DIR}

echo "#!/bin/sh" >> init 

mkdir -p etc/init.d/
tee etc/init.d/rcS <<EOF
#!/bin/sh

echo "INIT From /etc/init.d/rcS"
echo "$id"
mkdir /tmp
mount -t proc none /proc
mount -t sysfs none /sys
mount -t devtmpfs none /dev
mount -t debugfs none /sys/kernel/debug
mount -t tmpfs none /tmp

cat <<!

Boot took $(cut -d' ' -f1 /proc/uptime) seconds

        _       _     __ _                  
  /\/\ (_)_ __ (_)   / /(_)_ __  _   ___  __
 /    \| | '_ \| |  / / | | '_ \| | | \ \/ /
/ /\/\ \ | | | | | / /__| | | | | |_| |>  < 
\/    \/_|_| |_|_| \____/_|_| |_|\__,_/_/\_\ 


Welcome to mini_linux

!

setsid /bin/cttyhack setuidgid 0 /bin/sh
EOF
chmod +x etc/init.d/rcS

tee pack.sh <<EOF
find . | cpio -o --format=newc > ../rootfs.img
cd ..
bash ./start.sh
EOF

find . | cpio -H newc -o > ../rootfs.img