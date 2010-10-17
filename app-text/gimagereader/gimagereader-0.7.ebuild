# Copyright 2008-2010 Linux Grusha Community
# $Header: /var/cvsroot/gentoo-x86/app-text/gimagereader/gimagereader-0.7.ebuild, 2010/10/14 6:02:16 hwoarang Exp $

EAPI="2"

inherit eutils

DESCRIPTION="A graphical GTK frontend to tesseract-ocr"
HOMEPAGE="http://gimagereader.sourceforge.net/"
SRC_URI="http://ovh.dl.sourceforge.net/project/gimagereader/0.7/gimagereader-0.7.tar.gz"

LICENSE="GPL-1"
SLOT="0"
KEYWORDS="amd64 x86"

IUSE="linguas_en linguas_uk linguas_ru"

DEPEND="dev-lang/python
	dev-python/pygtk
	dev-python/pycairo
	dev-python/gtkspell-python
	dev-python/pyenchant
	app-text/tesseract
	media-gfx/imagemagick
	linguas_uk? ( app-dicts/myspell-uk )
	linguas_ru? ( app-dicts/myspell-ru )
	linguas_en? ( app-dicts/myspell-en )"
RDEPEND="${DEPEND}"

