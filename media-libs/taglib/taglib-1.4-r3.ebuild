# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/taglib/taglib-1.4-r1.ebuild,v 1.11 2008/01/06 23:27:56 philantrop Exp $

inherit autotools libtool eutils

DESCRIPTION="A library for reading and editing audio meta data"
HOMEPAGE="http://developer.kde.org/~wheeler/taglib.html"
SRC_URI="http://developer.kde.org/~wheeler/files/src/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 ~mips ppc ppc64 sh sparc x86 ~x86-fbsd"
IUSE="debug rcc"

DEPEND="sys-libs/zlib
	rcc? ( app-i18n/librcc )"

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${P}-dirtypointer.patch
	# Fixes bug 203635.
	epatch "${FILESDIR}"/${P}-gcc-4.3-include.patch

#SDS
	use rcc && (
	    epatch ${FILESDIR}/taglib-ds-rcc.patch || die
	    eautoreconf || die
	)
#EDS

	elibtoolize
}

src_compile() {
	econf $(use_enable debug) || die
	emake || die
#SDS
	emake -C examples || die
#EDS
}

src_install() {
	emake DESTDIR="${D}" install || die
#SDS
	emake -C examples DESTDIR=${D} install || die
#EDS
	dodoc AUTHORS ChangeLog README TODO
}
