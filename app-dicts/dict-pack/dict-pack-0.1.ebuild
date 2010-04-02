# Copyright 1999-2010 Grusha Linux
# Distributed under the terms of the GNU General Public License v2
EAPI="2"
inherit eutils

DESCRIPTION="StarDict additional dictionaries"
SRC_URI="http://distfiles.grusha.org.ua/stardict-ru-ua-en.pack.tar.bz2"
HOMEPAGE="http://grusha.org.ua"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE=""
RESTRICT="nomirror"


S="${WORKDIR}/dic"


src_install ()
{
	cd $S
	insinto /usr/share/stardict/dic
	doins *.ifo *.idx *.dz
}

pkg_postinst () {
ewarn "Installation completed"
}
