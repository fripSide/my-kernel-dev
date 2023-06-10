qemu-system-x86_64 \        
-kernel bzImage \          
-initrd rootfs.img \        
-append "console=ttyS0 root=/dev/ram rdinit=/sbin/init quiet" \       
-cpu qemu64,+smep,+smap \ 
-nographic \             
-gdb tcp::1234