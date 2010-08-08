# Copyright 1999-2002 Gentoo Technologies, Inc.
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils flag-o-matic

DESCRIPTION="Gimp Animation Package"
SRC_URI="ftp://ftp.gimp.org/pub/gimp/plug-ins/v2.6/gap/${P}.tar.bz2"
HOMEPAGE="http://www.gimp.org/"

KEYWORDS="~x86 ~amd64 ~ppc"
SLOT="0"
LICENSE="GPL-2"
IUSE="mpeg xanim wavplay sox mp3"

DEPEND=">=media-gfx/gimp-2.4
	mpeg? ( media-libs/xvid )"
RDEPEND="${DEPEND}
	wavplay? ( >=media-sound/wavplay-1.4 )
	mplayer? ( media-video/mplayer )
	xanim? ( >=media-video/xanim-2.80.1 )
	sox? ( >=media-sound/sox-12.17 )
	mp3? ( >=media-sound/lame-3.9 )"
#	x264? ( media-video/x264-encoder)"

src_compile() {
#	epatch ${FILESDIR}/extern_lib_fix.patch
#	CFLAGS="-fPIC" econf --disable-libmpeg3 || die "econf failed"
	CFLAGS="-fPIC" econf || die "econf failed"
	emake || die "emake failed"
}

src_install() {
	make DESTDIR=${D} install || die "install failed"
	dodoc AUTHORS ChangeLog* NEWS README
	docinto howto
	dodoc docs/howto/txt/*.txt
	docinto reference
	dodoc docs/reference/txt/*.txt
}

