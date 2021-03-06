# Copyright 1999-2009 Sabayon Linux
# Distributed under the terms of the GNU General Public License v2
EAPI="2"
inherit eutils multilib

DESCRIPTION="Grusha Linux OpenOffice Artwork"
HOMEPAGE="http://www.grusha.org.ua/"
SRC_URI="http://distfiles.grusha.org.ua/${CATEGORY}/${PN}/${P}.tar.bz2"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE=""
RESTRICT="nomirror"
# Temporary to ease transition
DEPEND=">=app-office/libreoffice-3.3.1"
RDEPEND="!x11-themes/sabayon-artwork-loo"


S="${WORKDIR}/${PN}"

src_install () {
	cd "${S}"
	insinto /usr/$(get_libdir)/libreoffice/program
	doins *.png *.bmp sofficerc
}

pkg_postinst () {
	ewarn "Please report bugs or glitches to"
	ewarn "bugs.grusha.org.ua"
}
