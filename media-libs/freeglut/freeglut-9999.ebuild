
# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

DESCRIPTION="A completely OpenSourced alternative to the OpenGL Utility Toolkit (GLUT) library"
HOMEPAGE="http://freeglut.sourceforge.net/"
LICENSE="MIT"
SLOT="0"
KEYWORDS="alpha amd64 arm ~arm64 hppa ~ia64 ~mips ppc ppc64 ~s390 ~sh ~sparc x86 ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos"
IUSE="X debug static-libs wayland"

# enabling GLES support seems to cause build failures
RDEPEND=">=virtual/glu-9.0-r1[${MULTILIB_USEDEP}]
	>=virtual/opengl-7.0-r1[${MULTILIB_USEDEP}]
	X? ( >=x11-libs/libX11-1.6.2[${MULTILIB_USEDEP}] )
	X? ( >=x11-libs/libXext-1.3.2[${MULTILIB_USEDEP}] )
	X? ( >=x11-libs/libXi-1.7.2[${MULTILIB_USEDEP}] )
	X? ( >=x11-libs/libXrandr-1.4.2[${MULTILIB_USEDEP}] )
	>=x11-libs/libXxf86vm-1.1.3[${MULTILIB_USEDEP}]
	abi_x86_32? ( !app-emulation/emul-linux-x86-opengl[-abi_x86_32(-)] )"
# gles? ( media-libs/mesa[gles1,${MULTILIB_USEDEP}] )
DEPEND="${RDEPEND}
	virtual/pkgconfig
	>=x11-proto/inputproto-2.3[${MULTILIB_USEDEP}]
	>=x11-proto/xproto-7.0.24[${MULTILIB_USEDEP}]
  wayland? dev-libs/wayland
  wayland? x11-libs/libxkbcommon"
SRC_URI="git://github.com/dcnieho/FreeGLUT.git"
cd freeglut/freeglut
HTML_DOCS=( doc/. )

src_configure() {
	local mycmakeargs=(
    "-DFREEGLUT_WAYLAND=$(usex wayland ON OFF)"
		"-DFREEGLUT_GLES=OFF"
		"-DFREEGLUT_BUILD_STATIC_LIBS=$(usex static-libs ON OFF)"
	)
#	$(cmake-utils_use gles FREEGLUT_GLES)
	cmake-multilib_src_configure
}
