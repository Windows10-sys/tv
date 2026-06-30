#!/data/data/com.termux/files/usr/bin/bash

echo
echo -e "\e[93mThis script will install Kali Linux in Termux."
echo
echo -e "\e[32m[*] \e[34mChecking for RootFS..."
folder="kali-fs"
if [ -d $folder ]; then
	skip=1
	echo -e "\e[32m[*] \e[34mRootFS is already downloaded, skipping download..."
fi

tarball="kali-rootfs.tar.xz"
if [ "$skip" != 1 ]; then
	if [ ! -f $tarball ]; then
		echo -e "\e[32m[*] \e[34mDownloading RootFS for arm64..."
        # Đã sửa lại cú pháp wget tại đây
		wget "https://kali.download/nethunter-images/kali-2026.2/rootfs/kali-nethunter-rootfs-full-arm64.tar.xz" -O $tarball
	fi
	cur=$(pwd)
	mkdir -p "$folder"
	echo -e "\e[32m[*] \e[34mDecompressing RootFS (vui lòng chờ)..."
	proot --link2symlink tar -xf ${cur}/${tarball} -C "$folder" || (echo -e "\e[91mFailed to decompress RootFS!"; exit 1)
fi

mkdir -p kali-binds
bin="start-kali.sh"
echo -e "\e[32m[*] \e[34mCreating startup script..."
cat > $bin <<- EOM
#!/data/data/com.termux/files/usr/bin/bash
cd \$(dirname \$0)
unset LD_PRELOAD
command="proot --link2symlink -0 -r $folder"
command+=" -b /dev -b /proc -b /sys -b /sdcard"
command+=" -w /root /usr/bin/env -i HOME=/root PATH=/usr/local/sbin:/usr/local/bin:/bin:/usr/bin:/sbin:/usr/sbin TERM=\$TERM LANG=C.UTF-8 /bin/bash --login"
\$command
EOM

termux-fix-shebang $bin
chmod +x $bin
rm -rf $tarball
echo
echo -e "\e[32mKali Linux was successfully installed!\e[39m"
echo -e "\e[32mYou can now launch it by executing ./${bin} command.\e[39m"
