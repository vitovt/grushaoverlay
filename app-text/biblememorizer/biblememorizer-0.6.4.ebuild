# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

DESCRIPTION="BibleMemorizer is a program to help with scripture memorization."
HOMEPAGE="http://biblememorizer.sourceforge.net"
SRC_URI="mirror://sourceforge/biblememorizer/${P}.tar.gz"

LICENSE="MIT GPL-2"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE="sword qt4 debug"

DEPEND="qt4? (
				|| ( ( x11-libs/qt-core
					x11-libs/qt-gui
					x11-libs/qt-qt3support )
					>=x11-libs/qt-4.4 )
		)
		!qt4? ( =x11-libs/qt-3* )
		sword? ( >=app-text/sword-1.5.8 )"
RDEPEND="${DEPEND}"

src_compile()
{
	if use qt4
	then
		export PATH="/usr/bin:$PATH"
	else
		export PATH="/usr/qt/3/bin:$PATH"
	fi
	econf $(use_enable sword) $(use_enable debug)
	#Fix sandbox issues
	addwrite "${QTDIR}/etc/settings"
	emake || die "emake failed"
}

src_install()
{
	emake INSTALL_ROOT="${D}" install || die "install failed"
	dodoc AUTHORS CREDITS README TODO || die
}
