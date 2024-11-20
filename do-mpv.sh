#!/bin/sh

# Dependencies: meson ninja-build yasm autoconf autoconf-archive libtool pkgconf pkg-config python3-docutils spirv-cross wayland-protocols debhelper-compat libfreetype-dev libfribidi-dev libharfbuzz-dev libfontconfig-dev libjpeg-dev libx11-dev libarchive-dev libasound2-dev libass-dev libavcodec-dev libavdevice-dev libavfilter-dev libavformat-dev libavutil-dev libbluray-dev libcaca-dev libcdio-dev libcdio-paranoia-dev libdrm-dev libdvdnav-dev libegl-dev libffmpeg-nvenc-dev libgbm-dev libgl-dev libjack-dev liblcms2-dev liblua5.2-dev libmujs-dev libpipewire-0.3-dev libplacebo-dev libpulse-dev librubberband-dev libsdl2-dev libsixel-dev libspirv-cross-c-shared-dev libswscale-dev libuchardet-dev libva-dev libvdpau-dev libvulkan-dev libwayland-dev libxinerama-dev libxkbcommon-dev libxpresent-dev libxrandr-dev libxss-dev libxv-dev libzimg-dev

TMP_DIR="/media/ramdisk/mpv-build"
BIN_DIR="/home/pintcat/ubin"

CLEAN(){
	printf "\n\033[0;32mCleaning up... "
	cd $TMP_DIR/..
	rm -rf $TMP_DIR
	printf "done.\033[0m\n"
}

FAIL(){
	printf "\n\033[0;31mError - $1 :(\033[0m\n"
	CLEAN
	exit 1
}

if [ -d "$TMP_DIR" ]; then
	printf "\n\033[0;32mFolder \""$TMP_DIR"\" already exists and it's content will be deleted. Continue (Y/n)? \033[0m"
	read YN
	case $YN in
		n|N)
			printf "\n\033[0;32mDone - nothing changed.\033[0m\n\n"
			exit
			;;
		*)
			CLEAN
			;;
	esac
fi
printf "\n\033[0;32mDownloading build scripts...\033[0m\n\n"
if git clone https://github.com/mpv-player/mpv-build.git $TMP_DIR; then
	printf "\n\033[0;32mDownloading and building components and linking final binary...\033[0m\n\n"
	cd $TMP_DIR
	./use-ffmpeg-release
	printf "--disable-avisynth\n--enable-nonfree\n--enable-version3\n--enable-static\n--enable-runtime-cpudetect" >> ffmpeg_options
#	printf "--Dcdda=enabled\n--Ddvdnav=enabled\n--Dsdl2=enabled" >> mpv_options
	if ./rebuild -j$(grep -m 1 "siblings" /proc/cpuinfo | awk '{print $3}'); then
   		printf "\n\033[0;32mCompressing and installing binary to \"$BIN_DIR\".\033[0m\n\n"
		if [ -f "$BIN_DIR/mpv~" ]; then rm -f $BIN_DIR/mpv~; fi
		if [ -f "$BIN_DIR/mpv" ]; then mv $BIN_DIR/mpv $BIN_DIR/mpv~; fi
		upx --lzma -9 mpv/build/mpv -o $BIN_DIR/mpv
		CLEAN
	else
		FAIL "building mpv binary failed."
	fi
else
	FAIL "unable to obtain source."
fi
echo
