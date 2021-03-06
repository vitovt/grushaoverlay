# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-editors/kile/kile-2.1_beta4.ebuild,v 1.7 2010/10/07 21:22:43 reavertm Exp $

EAPI=3

KMNAME="extragear/office"

if [[ ${PV} != *9999* ]]; then
	KDE_DOC_DIRS="doc"
	KDE_HANDBOOK="optional"
	MY_P=${P/_beta/b}
	SRC_URI="mirror://sourceforge/${PN}/${MY_P}.tar.bz2"
fi

inherit kde4-base

DESCRIPTION="A Latex Editor and TeX shell for KDE"
HOMEPAGE="http://kile.sourceforge.net/"

LICENSE="FDL-1.2 GPL-2"
KEYWORDS="amd64 ~ppc ~ppc64 x86"
SLOT="4"
IUSE="debug +pdf +png"

DEPEND="
	x11-misc/shared-mime-info
"
RDEPEND="${DEPEND}
	$(add_kdebase_dep kdebase-data)
	|| (
		$(add_kdebase_dep okular 'pdf?,ps')
		app-text/acroread
	)
	virtual/latex-base
	virtual/tex-base
	pdf? (
		app-text/dvipdfmx
		app-text/ghostscript-gpl
	)
	png? (
		app-text/dvipng
		media-gfx/imagemagick[png]
	)
"

S=${WORKDIR}/${MY_P}

DOCS=( kile-remote-control.txt )

src_prepare() {
	kde4-base_src_prepare

	# I know upstream wants to help us but it doesn't work..
	sed -e '/INSTALL( FILES AUTHORS/s/^/#DISABLED /' \
		-i CMakeLists.txt || die

	use handbook || rm -fr doc
}

#src_install()
#{
#		emake DESTDIR="${D}" install || die "Install failed"
#		turn
#	}

pkg_preinst() {
einfo "installing ukrainian translation" 
		insinto /usr/share/locale/uk/LC_MESSAGES
		doins "${FILESDIR}/kile.mo"
	    einfo "installint ukrainian handbook" 
		insinto /usr/share/doc/kde/HTML/uk/kile
		doins "${FILESDIR}/index.cache.bz2"
		doins "${FILESDIR}/index.docbook"
}


pkg_postinst() { 
	einfo "installation completed"
} 
