# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"
inherit subversion
DESCRIPTION="Quick and dirty script to download and install various redistributable runtime libraries"
HOMEPAGE="http://winetricks.org"
ESVN_REPO_URI="http://winetricks.googlecode.com/svn/trunk/"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE=""

DEPEND="gnome-extra/zenity"
RDEPEND="${DEPEND}"

src_install() 	{
	dobin src/${PN} || die
				}
