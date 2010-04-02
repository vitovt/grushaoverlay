# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils

MY_P="tr-2.2.1"
DESCRIPTION="Java-based Getting Things Done (GTD) application"
HOMEPAGE="http://thinkingrock.com.au/"
SRC_URI="mirror://sourceforge/thinkingrock/${MY_P}.tar.gz"
#http://sourceforge.net/projects/thinkingrock/files/ThinkingRock/TR%202.2.1/tr-2.2.1.tar.gz/download
#http://sourceforge.net/projects/thinkingrock/files/ThinkingRock/TR%202.2.1/tr-2.2.1-source.zip/download
LICENSE="CDDL"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND=">=virtual/jre-1.5.0"
DEPEND="${DEPEND}
	app-arch/unzip"

S=${WORKDIR}/${MY_P}

src_install() {
	local installDir=/opt/${MY_P}

	insinto /opt
	doins -r "${S}"
	fperms a+rx ${installDir}/bin/thinkingrock ${installDir}/bin/xdg-email ${installDir}/bin/xdg-open
	# Symlink the wrapper script
	dosym ${installDir}/bin/thinkingrock /usr/bin/thinkingrock
	# Symlink the directory and the jar to have them without version number
	dosym ${installDir} /opt/${PN}

	newicon thinkingrock/resource/images/logo.png thinking-rock.png
	newmenu "${FILESDIR}"/thinking-rock-2.0.desktop thinking-rock.desktop
}
