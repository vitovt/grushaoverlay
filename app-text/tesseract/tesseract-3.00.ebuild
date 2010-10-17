# Copyright 1999-2010 Grusha Linux Team

EAPI="2"

inherit eutils

DESCRIPTION="An OCR Engine that was developed at HP and now at Google"
HOMEPAGE="http://code.google.com/p/tesseract-ocr/"
SRC_URI="http://tesseract-ocr.googlecode.com/files/${P}.tar.gz
	http://tesseract-ocr.googlecode.com/files/eng.traineddata.gz
	linguas_de? ( http://tesseract-ocr.googlecode.com/files/deu.traineddata.gz )
	linguas_es? ( http://tesseract-ocr.googlecode.com/files/spa.traineddata.gz )
	linguas_fr? ( http://tesseract-ocr.googlecode.com/files/fra.traineddata.gz )
	linguas_it? ( http://tesseract-ocr.googlecode.com/files/ita.traineddata.gz )
	linguas_nl? ( http://tesseract-ocr.googlecode.com/files/nld.traineddata.gz )
	linguas_pt_BR? ( http://tesseract-ocr.googlecode.com/files/por.traineddata.gz )
	linguas_vi? ( http://tesseract-ocr.googlecode.com/files/vie.traineddata.gz )
	linguas_ru? ( http://tesseract-ocr.googlecode.com/files/rus.traineddata.gz )
	linguas_uk? ( http://tesseract-ocr.googlecode.com/files/ukr.traineddata.gz )"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="alpha amd64 ~mips ppc ppc64 sparc x86"
IUSE="examples tiff linguas_de linguas_eu linguas_es linguas_fr linguas_it linguas_nl linguas_pt_BR linguas_vi linguas_uk linguas_ru"

DEPEND="tiff? ( media-libs/tiff )"
RDEPEND="${DEPEND}"

src_configure() {
	econf $(use_with tiff libtiff) \
		--disable-dependency-tracking
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install filed"

	insinto /usr/share/tessdata
	doins ${WORKDIR}/*.traineddata
	dosym /usr/share/tessdata /usr/local/share/tessdata

	dodoc AUTHORS ChangeLog NEWS README ReleaseNotes || die "dodoc failed"

	if use examples; then
		insinto /usr/share/doc/${PF}/examples
		doins eurotext.tif phototest.tif || die "doins failed"
	fi
}
