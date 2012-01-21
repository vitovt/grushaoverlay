# Copyright 1999-2011 Sabayon Promotion
# Distributed under the terms of the GNU General Public License v2
#
MY_PN="grusha-artwork-core"

EAPI=4
inherit eutils mount-boot sabayon-artwork


DESCRIPTION="Grusha Core Artwork, contains Gensplash, Wallpapers and Mouse themes, Sabayon replacement"
HOMEPAGE="http://www.grusha.org.ua/"
#SRC_URI="http://distfiles.grusha.org.ua/${CATEGORY}/${PN}/${P}.tar.bz2"
#SRC_URI="http://distfiles.grusha.org.ua/${MY_PN}-${PV}.tar.bz2"
SRC_URI="http://distfiles.grusha.org.ua/${MY_PN}-3.5.tar.bz2"
LICENSE="CCPL-Attribution-ShareAlike-3.0"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE=""
RESTRICT="nomirror"
RDEPEND="sys-apps/findutils
	!<sys-boot/grub-0.97-r22
"

S="${WORKDIR}/${MY_PN}"

src_install() {
	# Fbsplash theme
	cd ${S}/gensplash
	dodir /etc/splash/sabayon
	cp -r ${S}/gensplash/sabayon/* ${D}/etc/splash/sabayon

	# Cursors
	cd ${S}/mouse/entis/cursors/
	dodir /usr/share/cursors/xorg-x11/entis/cursors
	insinto /usr/share/cursors/xorg-x11/entis/cursors/
	doins -r ./

	# Wallpaper
	cd ${S}/backgrounds
	insinto /usr/share/backgrounds
	doins *.png *.jpg
	newins sabayonlinux.png sabayonlinux-nvidia.png

	# Wallpaper
	cd ${S}/sounds
	insinto /usr/share/sounds
	doins *.ogg

	# Wallpaper2
	cd ${S}/wallpapers
	insinto /usr/share/wallpapers
	doins *.png *.jpg

	# Grub
	dodir /boot/grub
	insinto /boot/grub
	doins "${FILESDIR}/5.0/splash.xpm.gz"
}

pkg_postinst() {
	# mount boot first
	mount-boot_mount_boot_partition

	# Update Sabayon initramfs images
	update_sabayon_kernel_initramfs_splash

	ewarn "Please report bugs or glitches to"
	ewarn "bugs.grusha.org.ua"
}
