# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=3

inherit qt4-r2

DESCRIPTION="Lightweight and cross-platform clipboard history applet."
HOMEPAGE="http://code.google.com/p/qlipper/"
SRC_URI="http://qlipper.googlecode.com/files/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE=""

DEPEND="x11-libs/qt-gui:4"
RDEPEND="${DEPEND}"

src_prepare() {
	elog "Nothing to prepare"
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
}
