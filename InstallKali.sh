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
		wget "https://kali.download/nethunter-images/kali-2026.2/rootfs/kali-nethunter-rootfs-minimal-arm64.tar.xz" -O $tarball
	fi
	cur=$(pwd)
	mkdir -p "$folder"
	cd "$folder"
	echo -e "\e[32m[*] \e[34mDecompressing RootFS..."
	proot --link2symlink tar -xf ${cur}/${tarball} || (echo -e "\e[91mFailed to decompress RootFS!"; echo; exit 1)
	cd "$cur"
fi
mkdir -p kali-binds
bin="start-kali.sh"
echo -e "\e[32m[*] \e[34mCreating startup script..."
cat > $bin <<- EOM
#!/data/data/com.termux/files/usr/bin/bash

cd \$(dirname \$0)
## unset LD_PRELOAD in case termux-exec is installed
unset LD_PRELOAD
command="proot"
command+=" --link2symlink"
command+=" -0"
command+=" -r $folder"
if [ -n "\$(ls -A kali-binds)" ]; then
    for f in kali-binds/* ;do
      . \$f
    done
fi
command+=" -b /dev"
command+=" -b /proc"
command+=" -b kali-fs/tmp:/dev/shm"
## uncomment the following line to have access to the home directory of termux
#command+=" -b /data/data/com.termux/files/home:/root"
## uncomment the following line to mount /sdcard directly to / 
command+=" -b /sdcard"
command+=" -w /root"
command+=" /usr/bin/env -i"
command+=" HOME=/root"
command+=" PATH=/usr/local/sbin:/usr/local/bin:/bin:/usr/bin:/sbin:/usr/sbin:/usr/games:/usr/local/games"
command+=" TERM=\$TERM"
command+=" LANG=C.UTF-8"
command+=" /bin/bash --login"
com="\$@"
if [ -z "\$1" ];then
    exec \$command
else
    \$command -c "\$com"
fi
EOM
echo -e "\e[32m[*] \e[34mConfiguring Shebang..."
termux-fix-shebang $bin
echo -e "\e[32m[*] \e[34mSetting execution permissions..."
chmod +x $bin
echo -e "\e[32m[*] \e[34mRemoving RootFS image..."
rm -rf $tarball
echo
echo -e "\e[32mKali Linux was successfully installed!\e[39m"
echo -e "\e[32mYou can now launch it by executing ./${bin} command.\e[39m"
