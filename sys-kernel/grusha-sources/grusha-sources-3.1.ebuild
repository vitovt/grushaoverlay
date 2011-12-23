# Copyright 2004-2011 Sabayon
# Distributed under the terms of the GNU General Public License v2

ETYPE="sources"
K_SABKERNEL_NAME="grusha"
K_SABKERNEL_URI_CONFIG="yes"
K_SABKERNEL_SELF_TARBALL_NAME="fusion"
K_ONLY_SOURCES="1"
K_SABKERNEL_FORCE_SUBLEVEL="0"
inherit sabayon-kernel
KEYWORDS="~amd64 ~x86"
DESCRIPTION="Official Grusha Linux Fusion (on steroids) kernel sources"
RESTRICT="mirror"
IUSE="sources_standalone"

DEPEND="${DEPEND}
	sources_standalone? ( !=sys-kernel/linux-grusha-${PVR} )
	!sources_standalone? ( =sys-kernel/linux-grusha-${PVR} )"

src_unpack() {
	sabayon-kernel_src_unpack
	# fixup EXTRAVERSION, we don't want anything to append stuff
	sed -i "s/^EXTRAVERSION :=.*//" "${S}/Makefile" || die
	#copying correct config
	einfo "applying ${K_SABKERNEL_NAME}-${PV}-${ARCH}.config"
	cp "${FILESDIR}/${K_SABKERNEL_NAME}-${PV}-${ARCH}.config" ${S}/sabayon/config/
}
