# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils qt4 subversion

DESCRIPTION="Kuzya is simple crossplatform IDE for people who study programming"
HOMEPAGE="http://kuzya.sourceforge.net"
ESVN_REPO_URI="http://kuzya.svn.sourceforge.net/svnroot/kuzya/tags/2.1.11/"


LICENSE="GPL"
SLOT="0"
KEYWORDS="x86 amd64"
IUSE=""

RDEPEND="x11-libs/qscintilla
        x11-libs/qt-core"

DEPEND="${RDEPEND}"


src_compile() {
	elog "_-_-_ WORKDIR = ${WORKDIR}  \n _-_-_ P = ${P}"
	cd ${WORKDIR}/${P}
	ewarn ${PWD}
        eqmake4 || die "qmake failed!!! You are LOOSER"
        emake || die "emake failed"
}
src_install() {
	emake INSTALL_ROOT="${D}" install
}


