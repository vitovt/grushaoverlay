# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils

MY_PV="${PV//./}"
DESCRIPTION="Zoiper - Free SIP and IAX client"
HOMEPAGE="http://www.zoiper.com/zlinux.php"
SRC_URI="http://www.zoiper.com/downloads/free/linux/zoiper${MY_PV}-linux.tar.gz"

LICENSE=""
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE=""
RESTRICT="strip"
DEPEND=""
RDEPEND="
		x86? ( 
			x11-libs/libX11
        	x11-libs/libXext
        	x11-libs/libXrandr
        	x11-libs/libXft
        	x11-libs/libXi
        	x11-libs/libXrender
        	x11-libs/libXcursor
        	>=x11-libs/gtk+-2
        	dev-libs/atk
        	x11-libs/pango
        	dev-libs/glib
        	>=dev-libs/expat-2.0.0
		)
		amd64? (
			app-emulation/emul-linux-x86-gtklibs
			app-emulation/emul-linux-x86-soundlibs
		)"

S="${WORKDIR}"

src_install() {
	into /opt/zoiper
	dobin zoiper
	domenu ${FILESDIR}/zoiper.desktop
	doicon ${FILESDIR}/zoiper.png
}
