# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit java-pkg-2 java-ant-2

DESCRIPTION="A desktop replacement for Microsoft Project. It is capable of sharing files with Microsoft Project and has very similar functionality (Gantt, PERT diagram, histogram, charts, reports, detailed usage), as well as tree views which aren't in MS Project"
HOMEPAGE="http://www.openproj.org/openproj"
SRC_URI="mirror://sourceforge/openproj/openproj-${PV}-src.tar.gz"

LICENSE="CPL-1.0"

SLOT="0"
IUSE=""

KEYWORDS="~amd64 ~x86"

DEPEND=">=virtual/jdk-1.6 dev-java/ant-core"
RDEPEND=">=virtual/jdk-1.6"

S="${WORKDIR}/openproj-${PV}-src"

src_unpack() {
	unpack ${A}
	cd "${S}/openproj_build/resources"

	epatch "${FILESDIR}/openproj-${PV}-fix-launcher.patch"
}

src_compile() {
	JAVA_ANT_ENCODING="UTF-8"

	cd "${S}/openproj_contrib"
	ant build-contrib build-script build-exchange build-reports

	JAVA_OPTS="-Xmx128m"
	java $JAVA_OPTS -jar ant-lib/proguard.jar @openproj_contrib.conf
	java $JAVA_OPTS -jar ant-lib/proguard.jar @openproj_script.conf
	java $JAVA_OPTS -jar ant-lib/proguard.jar @openproj_exchange.conf
	java $JAVA_OPTS -jar ant-lib/proguard.jar @openproj_exchange2.conf
	java $JAVA_OPTS -jar ant-lib/proguard.jar @openproj_reports.conf

	cd "${S}/openproj_build"
	ant -Dbuild_contrib=false
}

src_install() {
	java-pkg_jarinto "/usr/share/${PN}/lib/"
	java-pkg_dojar ${S}/openproj_build/dist/lib/*.jar

	java-pkg_jarinto "/usr/share/${PN}/"
	java-pkg_dojar ${S}/openproj_build/dist/${PN}.jar

	insinto "/usr/share/${PN}/"

	doins ${S}/openproj_build/resources/openproj.sh
	fperms a+rx "/usr/share/${PN}/openproj.sh"
	dosym "/usr/share/${PN}/openproj.sh" /usr/bin/openproj

	domenu ${S}/openproj_build/resources/openproj.desktop
	doicon ${S}/openproj_build/resources/openproj.png
}
