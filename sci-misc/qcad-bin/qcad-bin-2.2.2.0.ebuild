# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=2
inherit eutils

MY_P=${P/-bin}-1-demo.linux.x86

DESCRIPTION="A 2D CAD package based upon Qt."
HOMEPAGE="http://www.ribbonsoft.com/qcad.html"
#SRC_URI="ftp://anonymous:anonymous@ribbonsoft.com/archives/${PN}/${MY_P}.tar.gz"
SRC_URI="ftp://anonymous:anonymous@ribbonsoft.com/archives/qcad/qcad-2.2.2.0-1-demo.linux.x86.tar.gz"
LICENSE=""
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND="amd64? ( app-emulation/emul-linux-x86-baselibs
	app-emulation/emul-linux-x86-xlibs )
	x86? ( >=media-libs/freetype-2
		media-libs/fontconfig
		x11-libs/libSM
		x11-libs/libXrender
		x11-libs/libICE
		x11-libs/libXext
		x11-libs/libXrandr
		x11-libs/libXi
		dev-libs/glib:2 )"

S=${WORKDIR}/${MY_P}

RESTRICT="mirror"

QA_PRESTRIPPED="opt/${MY_P}/qcad_demo
	opt/${MY_P}/bin/assistant"

src_install() {
	dodir /opt/${MY_P}
	cp -dpR * "${D}"/opt/${MY_P} || die

	make_wrapper qcad_demo ./qcad_demo /opt/${MY_P}

	newicon doc/img/logo.png ${PN}.png
	make_desktop_entry qcad_demo QCad ${PN} Office
}
