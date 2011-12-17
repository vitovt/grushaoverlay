# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="3"

inherit cmake-utils

DESCRIPTION="A simple Qt4/X11 window manager"
HOMEPAGE="http://www.antico.netsons.org/"
EGIT_REPO_URI="git://github.com/Razor-qt/razor-qt"
SRC_URI="http://razor-qt.org/install/razorqt-${PV}.tar.bz2"

DEPEND="x11-libs/qt-gui:4
    x11-libs/libX11
    x11-libs/libXext"
RDEPEND="${DEPEND}"


LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86 ~amd64"
