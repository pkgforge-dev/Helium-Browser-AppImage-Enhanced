#!/bin/sh

set -eu

ARCH=$(uname -m)

echo "Installing package dependencies..."
echo "---------------------------------------------------------------"
pacman -Syu --noconfirm \
	flac                \
	glu                 \
	gvfs                \
	libepoxy            \
	libheif             \
	libsm               \
	librsvg             \
	libtiff             \
	nss                 \
	pipewire-audio      \
	pipewire-jack       \
	pulseaudio-alsa     \
	vulkan-mesa-layers  \
	wget                \
	xcb-util-cursor     \
	xcb-util-keysyms    \
	xcb-util-wm         \
	zsync

if [ "$ARCH" = 'x86_64' ]; then
		pacman -Syu --noconfirm libva-intel-driver
fi

echo "Installing debloated packages..."
echo "---------------------------------------------------------------"
get-debloated-pkgs --add-common --prefer-nano intel-media-driver-mini ffmpeg-mini

# Comment this out if you need an AUR package
#make-aur-package PACKAGENAME

echo "Getting binary..."
echo "---------------------------------------------------------------"
case "$ARCH" in
	aarch64) farch=arm64;;
	x86_64)  farch=$ARCH;;
esac

HELIUM_URL=$(wget https://api.github.com/repos/imputnet/helium-linux/releases -O - \
	| sed 's/[()",{} ]/\n/g' | grep -oi -m 1 "https.*-$farch.*.tar.xz$"
)

mkdir -p ./AppDir/bin
wget --retry-connrefused --tries=30 "$HELIUM_URL"
tar xvf ./*.tar.xz
rm -f ./*.tar.xz
mv -v ./helium*linux/* ./AppDir/bin

# we need to remove this because chrome otherwise dlopen libQt5Core on the host
# when present, we can only bunle libqt6 or libqt5 but not both
rm -f ./AppDir/bin/libqt5_shim.so

echo "$HELIUM_URL" | awk -F'-|/' 'NR==1 {print $(NF-3)}' > ~/version

# if you also have to make nightly releases check for DEVEL_RELEASE = 1
#
# if [ "${DEVEL_RELEASE-}" = 1 ]; then
# 	nightly build steps
# else
# 	regular build steps
# fi
