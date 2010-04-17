# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/flac/flac-1.2.1-r1.ebuild,v 1.10 2007/11/01 19:07:17 armin76 Exp $

inherit autotools eutils

DESCRIPTION="free lossless audio encoder and decoder plugin for xmms"
HOMEPAGE="http://flac.sourceforge.net"
SRC_URI="mirror://sourceforge/flac/flac-${PV}.tar.gz"

LICENSE="GPL-2 LGPL-2"
SLOT="0"
KEYWORDS="alpha amd64 ~arm hppa ia64 ~mips ppc ppc64 ~sh sparc x86 ~x86-fbsd"
IUSE="3dnow altivec debug doc ogg sse"

RDEPEND="ogg? ( >=media-libs/libogg-1.1.3 )"
DEPEND="${RDEPEND}
	x86? ( dev-lang/nasm )
	sys-apps/gawk
	sys-devel/gettext
	dev-util/pkgconfig
	media-libs/flac
	media-sound/xmms"

S="${WORKDIR}/flac-${PV}"

src_unpack() {
	unpack ${A}
	cd "${S}"

	# Stop using upstream CFLAGS. Fix building with
	# ldflag asneeded on non glibc systems. Fix
	# broken asm causing text relocations.
	epatch "${FILESDIR}"/flac-${PV}-asneeded.patch
	epatch "${FILESDIR}"/flac-${PV}-cflags.patch
	epatch "${FILESDIR}"/flac-${PV}-asm.patch

	AT_M4DIR="m4" eautoreconf
}

src_compile() {
	econf $(use_enable ogg) \
		$(use_enable sse) \
		$(use_enable 3dnow) \
		$(use_enable altivec) \
		$(use_enable debug) \
		--disable-doxygen-docs \
		--disable-dependency-tracking \
		--enable-xmms-plugin

	emake || die "emake failed."
}

src_install() {
    mkdir -p "${D}/usr/lib/xmms/Input"
    install -c -m 755 src/plugin_xmms/.libs/libxmms-flac.so "${D}/usr/lib/xmms/Input"
    install -c -m 755 src/plugin_xmms/.libs/libxmms-flac.la "${D}/usr/lib/xmms/Input"
}
