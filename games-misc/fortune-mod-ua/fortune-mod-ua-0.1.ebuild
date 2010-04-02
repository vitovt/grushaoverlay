# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/games-misc/fortune-mod-humorixfortunes/fortune-mod-humorixfortunes-1.4-r1.ebuild,v 1.12 2010/01/03 11:59:49 fauli Exp $

DESCRIPTION="Extra Ukrainian fortune cookies for fortune"
HOMEPAGE="http://grusha.org.ua"
SRC_URI="http://distfiles.grusha.org.ua/${P}.tar.gz"

LICENSE="as-is"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 m68k mips ppc ppc64 s390 sh sparc x86 ~x86-fbsd ~x86-freebsd ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x86-macos"
IUSE=""

RDEPEND="games-misc/fortune-mod"

src_install() {
	insinto /usr/share/fortune
	doins fortunesua fortunesua.u8 fortunesua.dat || die
}

pkg_postinst () {
ewarn "Installation completed"
}

