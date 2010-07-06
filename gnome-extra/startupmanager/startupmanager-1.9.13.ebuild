# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

PYTHON_DEPEND="2"

inherit distutils

DESCRIPTION="A gui tool for changing settings for Grub, Grub2, Usplash and Splashy"
HOMEPAGE="http://web.telia.com/~u88005282/sum/index.html"
SRC_URI="mirror://sourceforge/startup-manager/${PN}_${PV}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE=""

#		dev-python/gnome-python-desktop
#		dev-python/gnome-python-extras

RDEPEND="dev-python/pygtk
		gnome-extra/yelp
		media-gfx/imagemagick"
DEPEND="${RDEPEND}
		sys-devel/gettext
		>=dev-util/intltool-0.35"
