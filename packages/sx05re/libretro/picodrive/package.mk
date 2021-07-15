PKG_NAME="picodrive"
PKG_VERSION="56b24717adf4b0a43d548fad21abe3c8e1b99848"
PKG_SHA256="775ec23ecde0a3209abe99d5970e19ac7e3b3cac7aaa94d3037e86e545699004"
PKG_LICENSE="MAME"
PKG_SITE="https://github.com/irixxxx/picodrive"
PKG_URL="$PKG_SITE/archive/$PKG_VERSION.tar.gz"
PKG_DEPENDS_TARGET="toolchain $PKG_NAME:host"
PKG_DEPENDS_HOST="cyclone68000"
PKG_LONGDESC="Fast MegaDrive/MegaCD/32X emulator"
PKG_TOOLCHAIN="manual"
PKG_BUILD_FLAGS="-gold"
PKG_GIT_BRANCH="libretro"

pre_build_host() {
  cp -a $(get_build_dir cyclone68000)/* $PKG_BUILD/cpu/cyclone/
}

pre_configure_host() {
  # fails to build in subdirs
  cd $PKG_BUILD
  rm -rf .$HOST_NAME
}

make_host() {
  if [ "$ARCH" == "arm" ]; then
    make -C cpu/cyclone CONFIG_FILE=../cyclone_config.h
  fi
}

pre_configure_target() {
  # fails to build in subdirs
  cd $PKG_BUILD
  rm -rf .$TARGET_NAME
}

post_configure_target() {
  sed -e "s|^GIT_VERSION :=.*$|GIT_VERSION := \" ${PKG_VERSION:0:7}\"|" -i Makefile.libretro
}

make_target() {
  R= make -f Makefile.libretro platform=armv ARM_ASM=1 use_fame=0 use_cyclone=1 use_sh2drc=1 use_svpdrc=1 use_cz80=1 use_drz80=0
}

makeinstall_target() {
  mkdir -p $INSTALL/usr/lib/libretro
  cp $PKG_BUILD/picodrive_libretro.so $INSTALL/usr/lib/libretro/
}