# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils git
EAPI="2"
DESCRIPTION="Antico is a Qt4/X11 Desktop/Window Manager (i.e. KDE+KWin)
The goal is to create a Window/Desktop manager simple and fast."
HOMEPAGE="http://www.antico.netsons.org/"
GIT_ECLASS="git"
#EGIT_COMMIT=""
EGIT_REPO_URI="git://github.com/antico/antico.git"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86"
IUSE=""

DEPEND="x11-libs/qt-gui:4
	x11-libs/libX11
	x11-libs/libXext"
RDEPEND="${DEPEND}"

src_compile() {
	#cd "${S}"
    qmake || die "qmake failed"
    make || die "make failed"
	}

src_install() {
	cd "${S}"
	/bin/bash install || die "Cannot install files"
src_install() {
        # install binaries with slotted filenames
        newbin mail/biff biff-${SLOT} || die "Cannot install binary biff"

        # install man page with slotted filename
        newman qlwm.1 qlwm-${SLOT}.1 || die "Cannot install manual file"

        # renaming defaults file
        mv files/defaults.in files/defaults || die "Cannot rename default config"
        # disable font name entries in default config file
        sed -i -e 's!^\(\S*FontName\S*\)\b!# \1!g;
                   s!^\(Style \)!# \1!g' \
           files/defaults || die "Cannot fix font names in default configuration"
        # rename entries for dclock and biff to match $SLOT
        sed -i -e 's!\S*\(dclock\|biff\)\b!/usr/bin/\1-'${SLOT}'!g' \
           files/defaults || die "Cannot fix font names in default configuration"

        # install config files and images
        insinto /usr/share/${PN}-${SLOT}
        doins -r files/ || die "Cannot install shared files"

        # install documentation
        dodoc README CHANGES || die "Cannot install documentation"



    ln -s ${PWD}/antico /usr/bin/antico
    cp antico-gdm.desktop /etc/X11/sessions/
    cp antico-kdm.desktop /usr/share/xsessions/
    cp antico-kdm.desktop /usr/share/apps/kdm/sessions/


}




