# Copyright 2004-2008 Sabayon Linux
# Distributed under the terms of the GNU General Public License v2

inherit eutils versionator

DESCRIPTION="Grusha Extra Artwork, Including Compiz/Emerald Themes and misc others"
HOMEPAGE="http://www.grusha.org.ua/"
SRC_URI="http://distfiles.grusha.org.ua/${CATEGORY}/${PN}/${P}.tar.bz2"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE=""
RESTRICT="nomirror"
RDEPEND="!x11-themes/sabayonlinux-artwork
	!x11-themes/sabayon-artwork-extra
	~x11-themes/grusha-artwork-core-${PV}"

S="${WORKDIR}/${PN}"

src_install () {
	# Compiz cube theme
	cd ${S}/compiz
	dodir /usr/share/compiz
	insinto /usr/share/compiz/
	doins *.jpg

	# Emerald theme
	cd ${S}/emerald
	dodir /usr/share/emerald/themes
	insinto /usr/share/emerald/themes/
	doins -r ./
}
