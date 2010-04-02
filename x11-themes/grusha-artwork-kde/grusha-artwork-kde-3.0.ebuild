# Copyright 1999-2009 Sabayon Linux
# Distributed under the terms of the GNU General Public License v2

EAPI=2
inherit eutils kde4-base

DESCRIPTION="Grusha Linux Official KDE artwork"
HOMEPAGE="http://grusha.org.ua/"
SRC_URI="http://distfiles.grusha.org.ua/${CATEGORY}/${PN}/${P}.tar.bz2"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE="gtk"
RESTRICT="nomirror"
RDEPEND="~x11-themes/grusha-artwork-core-${PV}
	 !x11-themes/sabayon-artwork-kde
	|| ( >=kde-base/kwin-4.4.0 x11-themes/aurorae )
	gtk? ( x11-themes/qtcurve-qt4 kde-misc/kcm_gtk )"

S="${WORKDIR}/${PN}"

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
	dodir ${KDEDIR}/share/apps/ksplash/Themes
	cd ${S}/ksplash
	insinto ${KDEDIR}/share/apps/ksplash/Themes
	doins -r ./

	# KDE icons
	dodir ${KDEDIR}/share/icons
	cd ${S}/icons
	insinto ${KDEDIR}/share/icons
	doins -r ./
}
