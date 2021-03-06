# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5
PYTHON_COMPAT=( python{2_7,3_3,3_4,3_5} )

inherit toolchain-funcs cmake-utils python-single-r1 java-pkg-opt-2 java-ant-2

DESCRIPTION="A collection of algorithms and sample code for various computer vision problems"
HOMEPAGE="http://opencv.org"

SRC_URI="
	mirror://sourceforge/opencvlibrary/opencv-unix/${PV}/${P}.zip
	https://github.com/Itseez/${PN}/archive/${PV}.zip -> ${P}.zip
	contrib? ( https://github.com/Itseez/${PN}_contrib/archive/cd5993c6576267875adac300b9ddd1f881bb1766.zip -> ${P}_contrib.zip )" #commit from Sun, 27 Mar 2016 17:31:51

LICENSE="BSD"
SLOT="0/3.1" # subslot = libopencv* soname version
KEYWORDS="~amd64 ~arm ~ppc ~ppc64 ~x86 ~amd64-linux"
IUSE="contrib cuda doc +eigen examples ffmpeg gdal gphoto2 gstreamer gtk ieee1394 ipp jpeg jpeg2k libav opencl openexr opengl openmp pch png +python qt4 qt5 testprograms threads tiff vaapi v4l vtk webp xine"
REQUIRED_USE="
	python? ( ${PYTHON_REQUIRED_USE} )
	?? ( qt4 qt5 )
"

# The following logic is intrinsic in the build system, but we do not enforce
# it on the useflags since this just blocks emerging pointlessly:
#	gtk? ( !qt4 )
#	opengl? ( || ( gtk qt4 ) )
#	openmp? ( !threads )

RDEPEND="
	app-arch/bzip2
	sys-libs/zlib
	cuda? ( >=dev-util/nvidia-cuda-toolkit-5.5 )
	ffmpeg? (
		libav? ( media-video/libav:0= )
		!libav? ( media-video/ffmpeg:0= )
	)
	gdal? ( sci-libs/gdal )
	gphoto2? ( media-libs/libgphoto2 )
	gstreamer? (
		media-libs/gstreamer:1.0
		media-libs/gst-plugins-base:1.0
	)
	gtk? (
		dev-libs/glib:2
		x11-libs/gtk+:2
		opengl? ( x11-libs/gtkglext )
	)
	java? ( >=virtual/jre-1.6:* )
	jpeg? ( virtual/jpeg:0 )
	jpeg2k? ( media-libs/jasper )
	ieee1394? (
		media-libs/libdc1394
		sys-libs/libraw1394
	)
	ipp? ( sci-libs/ipp )
	opencl? ( virtual/opencl )
	openexr? ( media-libs/openexr )
	opengl? ( virtual/opengl virtual/glu )
	png? ( media-libs/libpng:0= )
	python? ( ${PYTHON_DEPS} dev-python/numpy[${PYTHON_USEDEP}] )
	qt4? (
		dev-qt/qtgui:4
		dev-qt/qttest:4
		opengl? ( dev-qt/qtopengl:4 )
	)
	qt5? (
		dev-qt/qtgui:5
		dev-qt/qttest:5
		dev-qt/qtconcurrent:5
		opengl? ( dev-qt/qtopengl:5 )
	)
	threads? ( dev-cpp/tbb )
	tiff? ( media-libs/tiff:0 )
	v4l? ( >=media-libs/libv4l-0.8.3 )
	vtk? ( sci-libs/vtk[rendering] )
	webp? ( media-libs/libwebp )
	xine? ( media-libs/xine-lib )
"
DEPEND="${RDEPEND}
	virtual/pkgconfig
	eigen? ( dev-cpp/eigen:3 )
	java? ( >=virtual/jdk-1.6 )
"

pkg_setup() {
	use python && python-single-r1_pkg_setup
	java-pkg-opt-2_pkg_setup
}

src_prepare() {

	epatch "${FILESDIR}/${PN}-3.0.0-gles.patch" \
		"${FILESDIR}/${PN}-3.1.0-cmake-no-opengl.patch" \
		"${FILESDIR}/${P}-git-autodetect.patch"

	# remove bundled stuff
	rm -rf 3rdparty
	sed -i \
		-e '/add_subdirectory(.*3rdparty.*)/ d' \
		CMakeLists.txt cmake/*cmake || die

	java-pkg-opt-2_src_prepare
}

src_configure() {
	if use openmp; then
		tc-has-openmp || die "Please switch to an openmp compatible compiler"
	fi

	JAVA_ANT_ENCODING="iso-8859-1"
	# set encoding so even this cmake build will pick it up.
	export ANT_OPTS+=" -Dfile.encoding=iso-8859-1"
	java-ant-2_src_configure

	# please dont sort here, order is the same as in CMakeLists.txt
	local mycmakeargs=(
	# the optinal dependency libraries
		$(cmake-utils_use_with ieee1394 1394)
		-DWITH_AVFOUNDATION=OFF # IOS
		-DWITH_CARBON=OFF # APPLE
		$(cmake-utils_use_with eigen)
		$(cmake-utils_use_with ffmpeg)
		-DWITH_VFW=OFF     # video windows support
		$(cmake-utils_use_with gstreamer)
		-DWITH_GSTREAMER_0_10=OFF
		$(cmake-utils_use_with gtk)
		-DWITH_GTK_2_X=OFF
		$(cmake-utils_use_with ipp)
		$(cmake-utils_use_with java)
		$(cmake-utils_use_with jpeg2k JASPER)
		$(cmake-utils_use_with jpeg)
		$(cmake-utils_use_with webp)
		$(cmake-utils_use_with opencl)
		$(cmake-utils_use_with gphoto2)
		$(cmake-utils_use_with openexr)
		$(cmake-utils_use_with opengl)
		$(cmake-utils_use_with openmp)
		-DWITH_OPENNI=OFF 	#not packaged
		-DWITH_OPENNI2=OFF	#not packaged
		$(cmake-utils_use_with png)
		$(cmake-utils_use_build python opencv_python)
		-DWITH_PVAPI=OFF					# not packaged
		-DWITH_GIGEAPI=OFF
		-DWITH_QUICKTIME=OFF
		-DWITH_WIN32UI=OFF
		$(cmake-utils_use_with threads TBB)
		-DWITH_CSTRIPES=OFF
		-DWITH_PTHREADS_PF=ON
		$(cmake-utils_use_with tiff)
		-DWITH_UNICAP=OFF					# not packaged
		$(cmake-utils_use_with v4l V4L)
		$(cmake-utils_use_with vtk VTK)
		-DWITH_LIBV4L=ON
		-DWITH_DSHOW=ON               # direct show supp
		-DWITH_MSMF=OFF
		-DWITH_VIDEOINPUT=OFF					# windows only
		-DWITH_XIMEA=OFF # windows only
		$(cmake-utils_use_with xine)
		-DWITH_CLP=OFF
		$(cmake-utils_use_with opencl)
		-DWITH_OPENCL_SVM=OFF
		$(cmake-utils_use_with opencl OPENCLAMDFFT)
		$(cmake-utils_use_with opencl OPENCLAMDBLAS)
		-DWITH_DIRECTX=OFF
		-DWITH_INTELPERC=OFF
		-DWITH_IPP_A=OFF
		-DWITH_MATLAB=ON #default
		$(cmake-utils_use_with vaapi VA)
		$(cmake-utils_use_with vaapi VA_INTEL)
		$(cmake-utils_use_with gdal gdal)
		#
		# OpenCV build components
		-DBUILD_SHARED_LIBS=ON
		-DBUILD_ANDROID_EXAMPLES=OFF
		$(cmake-utils_use_build doc DOCS)
		$(cmake-utils_use_build examples)
		$(cmake-utils_use_build java opencv_java)		#for -java bug #555650
		-DBUILD_PERF_TESTS=OFF
		$(cmake-utils_use_build testprograms TESTS)
	# install examples, tests etc
		$(cmake-utils_use examples INSTALL_C_EXAMPLES)
		$(cmake-utils_use testprograms INSTALL_TESTS)
	# build options
		$(cmake-utils_use_enable pch PRECOMPILED_HEADERS)
		-DOPENCV_EXTRA_FLAGS_RELEASE=""				# black magic
	)

	if use qt4; then
		mycmakeargs+=( "-DWITH_QT=4" )
	elif use qt5; then
		mycmakeargs+=( "-DWITH_QT=5" )
	else
		mycmakeargs+=( "-DWITH_QT=OFF" )
	fi

	if use contrib; then
		mycmakeargs+=( "-DOPENCV_EXTRA_MODULES_PATH=../opencv_contrib-${PV}/modules" )
	fi

	if use cuda; then
		mycmakeargs+=( "-DWITH_CUDA=ON" )
		mycmakeargs+=( "-DWITH_CUBLAS=ON" )
		mycmakeargs+=( "-DWITH_CUFFT=ON" )
		mycmakeargs+=( "-DWITH_NVCUVID=ON" ) #Nvidia video decoding library supp
	else
		mycmakeargs+=( "-DWITH_CUDA=OFF" )
		mycmakeargs+=( "-DWITH_CUBLAS=OFF" )
		mycmakeargs+=( "-DWITH_CUFFT=OFF" )
		mycmakeargs+=( "-DWITH_NVCUVID=OFF" )
	fi

	if use examples && use python; then
		mycmakeargs+=( "-DINSTALL_PYTHON_EXAMPLES=ON" )
	else
		mycmakeargs+=( "-DINSTALL_PYTHON_EXAMPLES=OFF" )
	fi

	# things we want to be hard off or not yet figured out
	mycmakeargs+=(
		"-DOPENCV_BUILD_3RDPARTY_LIBS=OFF"
		"-DBUILD_LATEX_DOCS=OFF"
		"-DBUILD_PACKAGE=OFF"
		"-DENABLE_PROFILING=OFF"
	)

	# things we want to be hard enabled not worth useflag
	mycmakeargs+=(
		"-DCMAKE_SKIP_RPATH=ON"
		"-DOPENCV_DOC_INSTALL_PATH=${EPREFIX}/usr/share/doc/${PF}"
	)

	# hardcode cuda paths
	mycmakeargs+=(
		"-DCUDA_NPP_LIBRARY_ROOT_DIR=/opt/cuda"
	)

	# workaround for bug 413429
	tc-export CC CXX

	cmake-utils_src_configure
}
