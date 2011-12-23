# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=3
LANGSLONG="ar_SA bg_BG cs_CZ de_DE el_GR it_IT lt_LT ru_RU uk_UA vi_VN zh_CN"

inherit qt4-edge

DESCRIPTION="The keypad switch written on Qt4."
HOMEPAGE="http://code.google.com/p/qxkb/"
SRC_URI="http://qxkb.googlecode.com/files/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE=""

DEPEND="x11-libs/qt-gui:4"
RDEPEND="${DEPEND}"

src_prepare() {
	elog "Preparing sources"
	epatch "${FILESDIR}/main.cpp.patch"
	cp "${FILESDIR}/QXKB.pro" ${S}/
}

src_configure() {
	einfo "Configuring"
	eqmake4
}

src_compile() {
	emake
#	use doc && emake docs
}

src_install() {
	einfo "Installing"
	qt4-r2_src_install

	#add skype icon
	insinto /usr/share/pixmaps/
	doins "${FILESDIR}/skype.png"
}
