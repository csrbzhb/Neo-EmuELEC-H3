# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2016 Stephan Raue (stephan@openelec.tv)
# Copyright (C) 2016-2018 Team LibreELEC (https://libreelec.tv)
# Copyright (C) 2018-present Team CoreELEC (https://coreelec.org)

PKG_NAME="pulseaudio"
PKG_VERSION="13.0"
PKG_SHA256="961b23ca1acfd28f2bc87414c27bb40e12436efcf2158d29721b1e89f3f28057"
PKG_LICENSE="GPL"
PKG_SITE="http://pulseaudio.org/"
PKG_URL="http://www.freedesktop.org/software/pulseaudio/releases/$PKG_NAME-$PKG_VERSION.tar.xz"
PKG_DEPENDS_TARGET="toolchain alsa-lib dbus libcap libsndfile libtool openssl soxr systemd glib:host meson:host glib"
PKG_LONGDESC="PulseAudio is a sound system for POSIX OSes, meaning that it is a proxy for your sound applications."
PKG_BUILD_FLAGS="+pic -lto"
PKG_TOOLCHAIN="configure"

if [ "$BLUETOOTH_SUPPORT" = "yes" ]; then
  PKG_DEPENDS_TARGET="$PKG_DEPENDS_TARGET sbc"
  PKG_PULSEAUDIO_BLUETOOTH="--enable-bluez5"
else
  PKG_PULSEAUDIO_BLUETOOTH="--disable-bluez5"
fi

if [ "$AVAHI_DAEMON" = "yes" ]; then
  PKG_DEPENDS_TARGET="$PKG_DEPENDS_TARGET avahi"
  PKG_PULSEAUDIO_AVAHI="--enable-avahi"
else
  PKG_PULSEAUDIO_AVAHI="--disable-avahi"
fi

# PulseAudio fails to build on aarch64 when NEON is enabled, so don't enable NEON for aarch64 until upstream supports it
if [ "$TARGET_ARCH" = "arm" ] && target_has_feature neon; then
  PKG_PULSEAUDIO_NEON="--enable-neon-opt"
else
  PKG_PULSEAUDIO_NEON="--disable-neon-opt"
fi

PKG_CONFIGURE_OPTS_TARGET="--disable-silent-rules \
                           --disable-nls \
                           --enable-largefile \
                           --disable-rpath \
                           $PKG_PULSEAUDIO_NEON \
                           --disable-x11 \
                           --disable-tests \
                           --disable-samplerate \
                           --disable-oss-output \
                           --disable-oss-wrapper \
                           --disable-coreaudio-output \
                           --enable-alsa \
                           --disable-esound \
                           --disable-solaris \
                           --disable-waveout \
                           --enable-glib2 \
                           --disable-gtk3 \
                           --disable-gconf \
                           $PKG_PULSEAUDIO_AVAHI \
                           --disable-jack \
                           --disable-asyncns \
                           --disable-tcpwrap \
                           --disable-lirc \
                           --enable-dbus \
                           --disable-bluez4 \
                           $PKG_PULSEAUDIO_BLUETOOTH \
                           --disable-bluez5-ofono-headset \
                           --disable-bluez5-native-headset \
                           --enable-udev \
                           --with-udev-rules-dir=/usr/lib/udev/rules.d \
                           --disable-hal-compat \
                           --enable-ipv6 \
                           --enable-openssl \
                           --disable-tdb \                           
                           --disable-orc \
                           --disable-manpages \
                           --disable-per-user-esound-socket \
                           --disable-default-build-tests \
                           --disable-legacy-database-entry-format \
                           --with-system-user=root \
                           --with-system-group=root \
                           --with-access-group=root \
                           --without-caps \
                           --without-fftw \
                           --without-speex \
                           --with-soxr \
                           --with-module-dir=/usr/lib/pulse
                           CPPFLAGS=-I${SYSROOT_PREFIX}/usr/include"

pre_configure_target() {
  export CFLAGS="$CFLAGS -fopenmp"
  sed -e 's|; remixing-use-all-sink-channels = yes|; remixing-use-all-sink-channels = no|' \
      -i $PKG_BUILD/src/daemon/daemon.conf.in
}

post_makeinstall_target() {
  rm -rf $INSTALL/usr/bin/esdcompat
  rm -rf $INSTALL/usr/include
  rm -rf $INSTALL/usr/lib/cmake
  rm -rf $INSTALL/usr/lib/pkgconfig
  rm -rf $INSTALL/usr/lib/systemd
  rm -rf $INSTALL/usr/share/vala
  rm -rf $INSTALL/usr/share/zsh
  rm -rf $INSTALL/usr/share/bash-completion

  cp $PKG_DIR/config/system.pa $INSTALL/etc/pulse/
  cp $PKG_DIR/config/pulseaudio-system.conf $INSTALL/etc/dbus-1/system.d/

  mkdir -p $INSTALL/usr/config
    cp -PR $PKG_DIR/config/pulse-daemon.conf.d $INSTALL/usr/config

  ln -sf /storage/.config/pulse-daemon.conf.d $INSTALL/etc/pulse/daemon.conf.d


	sed '56,58 s/^/#/' -i $INSTALL/etc/pulse/system.pa
	sed '60,62 s/^/#/' -i $INSTALL/etc/pulse/system.pa
	sed '64,66 s/^/#/' -i $INSTALL/etc/pulse/system.pa
	mv $INSTALL/etc/pulse/system.pa $INSTALL/usr/config
	ln -sf /storage/.config/system.pa $INSTALL/etc/pulse/system.pa
}

post_install() {
:
# enable_service pulseaudio.service
}
