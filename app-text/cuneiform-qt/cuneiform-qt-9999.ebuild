# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="1"

inherit qt4 git

EGIT_REPO_URI="git://git.altlinux.org/people/cas/packages/${PN}.git"

DESCRIPTION="Qt interface for Cuneiform"
HOMEPAGE="http://www.altlinux.org/Cuneiform-Qt"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="x11-libs/qt-gui:4
	app-text/cuneiform"
RDEPEND="${DEPEND}"

src_compile () {
	cd ${PN}
	sed 's:/share/apps/cuneiform-qt/:/share/cuneiform-qt/:' -i cuneiform-qt.pro || die "Cannot patch cuneiform-qt.pro"
	PREFIX="/usr" eqmake4
	emake || die "Cannot run make"
}

src_install() {
	cd ${PN}
	dodoc AUTHORS README TODO || die "Cannot install docs"
	INSTALL_ROOT="${D}" emake install || die "Cannot install"
}

