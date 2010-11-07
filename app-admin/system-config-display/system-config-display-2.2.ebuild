# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-admin/system-config-display/Attic/system-config-display-1.0.51.ebuild,v 1.5 2009/07/30 12:47:44 ssuominen dead $

inherit python rpm

# Tag for which Fedora Core version it's from
FCVER="12"
# Revision of the RPM. Shouldn't affect us, as we're just grabbing the source
# tarball out of it
RPMREV="1"

DESCRIPTION="A graphical interface for configuring the X Window System display"
HOMEPAGE="http://fedoraproject.org/wiki/SystemConfig/display"
SRC_URI="ftp://ftp.icm.edu.pl/vol/rzm1/linux-fedora/linux/releases/13/Everything/source/SRPMS/${P}-${RPMREV}.fc${FCVER}.src.rpm"
#SRC_URI="ftp://ftp.chg.ru/.0/Linux/fedora/linux/development/rawhide/source/SRPMS/${P}-${RPMREV}.fc${FCVER}.src.rpm"
#SRC_URI="mirror://fedora/development/rawhide/source/SRPMS/${P}-${RPMREV}.fc${FCVER}.src.rpm"
#SRC_URI="mirror://fedora/development/source/SRPMS/${P}-${RPMREV}.fc${FCVER}.src.rpm"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~x86"
IUSE=""

#	sys-apps/usermode
#	sys-apps/hwdata-redhat
#sys-apps/hwdata-redhat
	#dev-python/pyxf86config
	#dev-python/rhpl
#	>=dev-python/rhpxl-0.34
RDEPEND="=dev-python/pygtk-2*
	>=x11-libs/gtk+-2.6
	dev-lang/python
	dev-util/desktop-file-utils
	x11-base/xorg-server
	x11-themes/hicolor-icon-theme"
DEPEND="${RDEPEND}
	sys-devel/gettext
	dev-util/intltool"

src_install() {
	emake INSTROOT="${D}" install || die "emake install failed"

	make_desktop_entry /usr/bin/${PN}

	fperms 644 /etc/pam.d/${PN}
}

pkg_postinst() {
	elog "If you want card autodetection to work optimally, you must reinstall"
	elog "any video driver packages that did not install a *.xinf file"
	elog "to /usr/share/hwdata/videoaliases/"
}

pkg_postrm() {
	python_mod_cleanup /usr/share/${PN}
}
