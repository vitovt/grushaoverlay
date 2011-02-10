# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

EGIT_REPO_URI="git://git.kde.org/apper"


KMNAME="playground/sysadmin"
inherit kde4-base git

DESCRIPTION="KDE-based PackageKit frontend"
HOMEPAGE="http://www.kde-apps.org/content/show.php/show.php?content=84745"

LICENSE="GPL-2"
KEYWORDS="~x86 ~amd64"
SLOT="4"
IUSE="debug"

DEPEND=">=app-admin/packagekit-qt4-0.6.4"
RDEPEND="${DEPEND}"

src_install() {
	kde4-base_src_install
	# fix dbus service path otherwise conflicting with gnome-packagekit one
	mv "${D}/usr/share/dbus-1/services/org.freedesktop.PackageKit.service" \
		"${D}"/usr/share/dbus-1/services/kde-org.freedesktop.PackageKit.service || \
		die "cannot hackily move packagekit dbus service file"
}
