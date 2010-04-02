# Copyright 2010 Grusha Linux team
# Distributed under the terms of the GNU General Public License v2
# $Header: $

MY_PN="cmyktool"
MY_P=${MY_PN}-${PV}
EAPI="2"

inherit eutils multilib toolchain-funcs


DESCRIPTION="CMYKTool is a colour conversion utility for the GIMP."
HOMEPAGE="http://www.blackfiveimaging.co.uk"
SRC_URI="http://www.blackfiveimaging.co.uk/cmyktool/cmyktool-${PV}.tar.gz"

LICENSE="GPL-2 Adobe"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND="media-gfx/gimp"
DEPEND="${RDEPEND}"

S="${WORKDIR}"/${P}

src_prepare() {
#	epatch "${FILESDIR}"/${PV}-Makefile.patch
#	sed -e "s:GENTOOLIBDIR:$(get_libdir):g" -i Makefile || die
	cd "${S}"
econf || die "configuration failed" 
}

src_compile() {
	emake || die "compilation failed"
}

src_install() {
#	emake PREFIX="${D}/usr" install || die "emake install failed"
#	emake install || die "emake install failed"
	make install DESTDIR=${D}
}
