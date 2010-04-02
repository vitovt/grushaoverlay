# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/taglib/taglib-1.6.ebuild,v 1.1 2009/10/02 00:40:21 jmbsvicetto Exp $

EAPI="2"

inherit base autotools

DESCRIPTION="A library for reading and editing audio meta data"
HOMEPAGE="http://developer.kde.org/~wheeler/taglib.html"
SRC_URI="http://developer.kde.org/~wheeler/files/src/${P}.tar.gz"

LICENSE="GPL-2"
KEYWORDS="~alpha amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~sh ~sparc x86 ~x86-fbsd"
SLOT="0"
IUSE="debug examples static-libs test rcc"

DEPEND="
	dev-util/pkgconfig
	test? ( dev-util/cppunit )
	rcc? ( app-i18n/librcc )
"
RDEPEND="rcc? ( app-i18n/librcc )"

src_unpack() {
	unpack ${A}
	cd "${S}"

	use rcc && (
	    epatch ${FILESDIR}/taglib-1.6-ds-rusxmms.patch || die
	    aclocal
	    automake
	    autoconf
#	    causes version mistmatch problems
#	    eautoreconf || die
	)

}

src_configure() {
	econf \
		--enable-asf \
		--enable-mp4 \
		$(use_enable debug) \
		$(use_enable static-libs static)
}

src_compile() {
	base_src_compile

	if use examples; then
		emake examples || die "emake examples failed"
	fi
}

src_install() {
	base_src_install

	dodoc AUTHORS NEWS || die "dodoc failed"
	dohtml doc/* || die "dohtml failed"

	if use examples; then
		cd examples && emake DESTDIR="${D}" install || die "emake examples install failed"
	fi
}
