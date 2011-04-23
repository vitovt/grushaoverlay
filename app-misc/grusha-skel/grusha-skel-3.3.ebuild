# Copyright 1999-2009 SabayonLinux
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"
#EGIT_COMMIT="${PVR}"
EGIT_REPO_URI="git://git.grusha.org.ua/skel.git"
inherit eutils git fdo-mime

DESCRIPTION="Grusha Linux skel tree"
HOMEPAGE="http://www.grusha.org.ua"
#SRC_URI="http://distfiles.grusha.org.ua/${CATEGORY}/${PN}/${P}.tar.bz2"
RESTRICT="nomirror"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE=""
RDEPEND="!app-misc/sabayonlinux-skel
	sys-apps/findutils
	!app-misc/sabayon-skel"

S="${WORKDIR}/${PN}"

src_install () {

	dodir /etc
#	cp ${S}/skel ${D}/etc -Ra
	cp ${S}/ ${D}/etc/skel -Ra

	# Sabayon Menu
	dodir /usr/share/desktop-directories
	cp ${FILESDIR}/3.0.0/xdg/*.directory ${D}/usr/share/desktop-directories/
	dodir /usr/share/sabayon
	cp -a "${FILESDIR}"/3.0.0/* ${D}/usr/share/sabayon/
	doicon "${FILESDIR}"/3.0.0/img/sabayon-weblink.png

	chown root:root "${D}"/etc/skel -R

}

pkg_postinst () {

	if [ -x "/usr/bin/xdg-desktop-menu" ]; then
		# Manual install otherwise it wont be set up correctly
		xdg-desktop-menu install \
			/usr/share/sabayon/xdg/sabayon-sabayon.directory \
			/usr/share/sabayon/xdg/*.desktop
	fi

	# Workaround for buggy mime dir stuff stored in $HOME, sigh!
	# >=x11-misc/shared-mime-info-0.70 breaks
	# find "${ROOT}"home/*/.local/share -name "mime" -type d | xargs rm -rf

	fdo-mime_desktop_database_update
	ewarn "Please bugs report to bugs.grusha.org.ua"
	ewarn "for Vitovt's attention"
}


pkg_prerm() {
	if [ -x "/usr/bin/xdg-desktop-menu" ]; then
		xdg-desktop-menu uninstall /usr/share/sabayon/xdg/sabayon-sabayon.directory /usr/share/sabayon/xdg/*.desktop
	fi
}
