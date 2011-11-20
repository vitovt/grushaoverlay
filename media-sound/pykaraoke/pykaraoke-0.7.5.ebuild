EAPI=2
DESCRIPTION="PyKaraoke is a free karaoke player"
HOMEPAGE="http://kibosh.org/pykaraoke/index.php"
SRC_URI="mirror://sourceforge/${PN}/${P}.zip"
LICENSE="GPL"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE="mutagen"
inherit distutils
DEPEND="dev-lang/python
	dev-python/pygame
	dev-python/wxpython
	media-libs/sdl-mixer[timidity]
	media-libs/libsdl
	mutagen? ( media-libs/mutagen )"
RDEPEND="${DEPEND}"
src_install() {
	distutils_src_install
	newicon icons/pykaraoke.xpm ${PN}.xpm
}
