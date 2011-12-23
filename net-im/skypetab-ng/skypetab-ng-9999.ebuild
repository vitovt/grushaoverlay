# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=3
LANGSLONG="ar_SA bg_BG cs_CZ de_DE el_GR it_IT lt_LT ru_RU uk_UA vi_VN zh_CN"

inherit qt4-edge git

DESCRIPTION="Tab support for Skype for Linux.NG - new generation"
HOMEPAGE="git://github.com/kekekeks/skypetab-ng"
EGIT_REPO_URI="git://github.com/kekekeks/skypetab-ng"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE=""

DEPEND="net-im/skype"
RDEPEND="${DEPEND}"

src_prepare() {
	elog "/var/tmp/portage/net-im/skypetab-ng-9999/work/skypetab-ng-9999"
	elog ${S}
}

src_configure() {
	einfo "Configuring"
	eqmake4
}

src_compile() {
	emake
#	use doc && emake docs
}

src_install() {
	einfo "Installing"
	qt4-r2_src_install

	#add skype icon
	insinto /usr/share/pixmaps/
	doins "${FILESDIR}/skype.png"
}
