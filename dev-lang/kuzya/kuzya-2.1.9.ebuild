# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils qt4

DESCRIPTION="Kuzya is simple crossplatform IDE for people who study programming"
HOMEPAGE="http://kuzya.sourceforge.net"
SRC_URI="http://mantis.net.ua/${P}.tar.gz"

LICENSE="GPL"
SLOT="0"
KEYWORDS="x86"
IUSE=""

RDEPEND="x11-libs/qscintilla
        x11-libs/qt-core"

DEPEND="${RDEPEND}"

src_compile() {
        cd ${WORKDIR}/${P}/trunc/
        eqmake4
        emake || die "emake failed"
}

src_install() {
	cd ${WORKDIR}/${P}/trunc/
	emake install || die
#DESTDIR="${WORKDIR}/${PN}/trunc/" install || die
}

