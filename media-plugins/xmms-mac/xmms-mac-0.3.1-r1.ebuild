# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: current version of ebuild http://atrey.karlin.mff.cuni.cz/~sanda/mac/$

IUSE=""

DESCRIPTION="Plugin to listen ape files (monkey audio codec) files on xmms"
HOMEPAGE="http://sourceforge.net/projects/mac-port/"
SRC_URI="http://dside.dyndns.org/files/darklin/${P}.tar.gz"

SLOT="0"
KEYWORDS="x86 amd64"
LICENSE="MAC"

DEPEND="media-sound/xmms media-libs/mac"

src_compile () {
	econf --with-prefix=`xmms-config --prefix` --with-exec-prefix=`xmms-config --exec-prefix`|| die 'Configure failed'
	emake || die "Error compiling"
}

src_install()
{
	einstall DESTDIR="${D}" || die
	dodoc AUTHORS BUGS ChangeLog NEWS README TODO COPYING
}
