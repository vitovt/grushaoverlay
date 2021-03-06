# Copyright 1999-2009 Sabayon Linux
# Distributed under the terms of the GNU General Public License v2
#

MY_PN="grusha-artwork-kde"
EAPI=3
inherit eutils kde4-base

DESCRIPTION="Grusha Linux Official KDE artwork"
HOMEPAGE="http://grusha.org.ua/"
SRC_URI="http://distfiles.grusha.org.ua/${MY_PN}-3.5.tar.bz2"
LICENSE="CCPL-Attribution-ShareAlike-3.0"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE="+ksplash"
RESTRICT="nomirror"
RDEPEND=""

S="${WORKDIR}/${MY_PN}"

src_configure() {
	einfo "nothing to configure"
}

src_compile() {
	einfo "nothing to compile"
}

src_install() {
	# KDM
	dodir ${KDEDIR}/share/apps/kdm/themes
	cd ${S}/kdm
	insinto ${KDEDIR}/share/apps/kdm/themes
	doins -r ./

	# Kwin
	dodir ${KDEDIR}/share/apps/aurorae/themes/
	cd ${S}/kwin
	insinto ${KDEDIR}/share/apps/aurorae/themes/
	doins -r ./

	# KSplash
	if use ksplash; then
		dodir ${KDEDIR}/share/apps/ksplash/Themes
		cd ${S}/ksplash
		insinto ${KDEDIR}/share/apps/ksplash/Themes
		doins -r ./
	fi
	# KDE icons
	dodir ${KDEDIR}/share/icons
	cd ${S}/icons
	insinto ${KDEDIR}/share/icons
	doins -r ./
}

pkg_postinst()
{
	einfo "Clearing Plasma Wallpaper Cache"
	for i in /home/*; do
		rm -rf /home/$i/.kde4/cache-*/plasma-wallpapers/usr/share/backgrounds/sabayon*
	done
}
