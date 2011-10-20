# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=3

DESCRIPTION="Addes tabs support to Skype for Linux."
HOMEPAGE="http://code.google.com/p/skypetab/"
SRC_URI="http://skypetab.googlecode.com/files/skypetab.for_maintainers.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86 ~zmd64"
IUSE=""

DEPEND="net-im/skype"
RDEPEND="${DEPEND}"

src_compile() {
cd skypetab
emake || die "Error: emake failed!"
}

src_install() {
emake DESTDIR="${D}" install

#add skype icon
insinto /usr/share/pixmaps/
doins "${FILESDIR}/skype.png"
}
