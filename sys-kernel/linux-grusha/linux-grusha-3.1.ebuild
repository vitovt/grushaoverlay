# Copyright 2004-2011 Sabayon
# Distributed under the terms of the GNU General Public License v2

ETYPE="sources"
K_SABKERNEL_SELF_TARBALL_NAME="fusion"
K_REQUIRED_LINUX_FIRMWARE_VER="20111025"
K_SABKERNEL_FORCE_SUBLEVEL="0"
inherit grusha-kernel

KEYWORDS="~amd64 ~x86"
DESCRIPTION="Official Grusha Linux Fusion (on steroids) kernel image"
RESTRICT="mirror"

src_unpack() {
	grusha-kernel_src_unpack
	# fixup EXTRAVERSION, we don't want anything to append stuff
	sed -i "s/^EXTRAVERSION :=.*//" "${S}/Makefile" || die
	#copying correct config 
	#cp "${FILESDIR}/grusha-3.1-x86.config" ${S}/sabayon/config/
	einfo "applying ${K_SABKERNEL_NAME}-${PV}-${ARCH}.config"
	cp "${FILESDIR}/${K_SABKERNEL_NAME}-${PV}-${ARCH}.config" ${S}/sabayon/config/
}
