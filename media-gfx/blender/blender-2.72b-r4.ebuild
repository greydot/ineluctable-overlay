# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
PYTHON_COMPAT=( python3_{4,5,6} )

#inherit multilib xdg-utils gnome2-utils cmake-utils eutils python-single-r1 versionator flag-o-matic toolchain-funcs pax-utils check-reqs
inherit check-reqs cmake-utils xdg-utils flag-o-matic gnome2-utils \
          pax-utils python-single-r1 toolchain-funcs versionator

DESCRIPTION="3D Creation/Animation/Publishing System"
HOMEPAGE="http://www.blender.org"
SRC_URI="http://download.blender.org/source/${P}.tar.gz"

#if [[ -n ${PATCHSET} ]]; then
#	SRC_URI+=" https://dev.gentoo.org/~flameeyes/${PN}/${P}-patches-${PATCHSET}.tar.xz"
#fi

SLOT="0"
LICENSE="|| ( GPL-2 BL )"
KEYWORDS="amd64 x86"
IUSE="+boost +bullet collada colorio cycles +dds debug doc +elbeem ffmpeg fftw \
	+game-engine jack jpeg2k libav ndof nls openal openimageio +opennl openmp \
	+openexr player redcode sdl sndfile cpu_flags_x86_sse cpu_flags_x86_sse2 \
	tiff jemalloc"

RESTRICT="mirror test"

REQUIRED_USE="${PYTHON_REQUIRED_USE}
	player? ( game-engine )
	redcode? ( jpeg2k ffmpeg )
	cycles? ( boost openexr tiff openimageio )
	nls? ( boost )
	colorio? ( boost )
	openal? ( boost )
	game-engine? ( boost )
	?? ( ffmpeg libav )"

RDEPEND="
	${PYTHON_DEPS}
	dev-python/numpy[${PYTHON_USEDEP}]
	dev-python/requests[${PYTHON_USEDEP}]
	>=media-libs/freetype-2.0:2
	media-libs/glew:0=
	media-libs/libpng:0
	media-libs/libsamplerate
	sys-libs/zlib
	virtual/glu
	virtual/jpeg:0
	virtual/libintl
	virtual/opengl
	x11-libs/libX11
	x11-libs/libXi
	x11-libs/libXxf86vm
	boost? ( >=dev-libs/boost-1.44[nls?,threads(+)] )
	collada? ( >=media-libs/opencollada-1.6.18 )
	colorio? ( >=media-libs/opencolorio-1.0.9-r2 )
	cycles? (
		media-libs/openimageio
	)
	ffmpeg? ( media-video/ffmpeg:0=[x264,mp3,encode,theora,jpeg2k?] )
	libav? ( >=media-video/libav-11.3:0=[x264,mp3,encode,theora,jpeg2k?] )
	fftw? ( sci-libs/fftw:3.0 )
	jack? ( media-sound/jack-audio-connection-kit )
	jpeg2k? ( media-libs/openjpeg:0 )
	ndof? (
		app-misc/spacenavd
		dev-libs/libspnav
	)
	nls? ( virtual/libiconv )
	openal? ( >=media-libs/openal-1.6.372 )
	openimageio? ( media-libs/openimageio )
	openexr? ( media-libs/ilmbase media-libs/openexr )
	sdl? ( media-libs/libsdl[sound,joystick] )
	sndfile? ( media-libs/libsndfile )
	tiff? ( media-libs/tiff:0 )
	jemalloc? ( dev-libs/jemalloc:= )"
DEPEND="${RDEPEND}
	doc? (
		app-doc/doxygen[-nodot(-),dot(+)]
		dev-python/sphinx
	)
	nls? ( sys-devel/gettext )"

PATCHES=(
	"${FILESDIR}"/${PN}-2.68-doxyfile.patch
	"${FILESDIR}"/${PN}-2.68-fix-install-rules.patch
	"${FILESDIR}"/${PN}-2.70-sse2.patch
	"${FILESDIR}"/${PN}-2.72-T42797.diff
	"${FILESDIR}"/${P}-fix-util_simd.patch
	"${FILESDIR}"/${P}-gcc6-fixes.patch
	"${FILESDIR}"/${P}-boost.patch
)

pkg_pretend() {
	if use openmp && ! tc-has-openmp; then
		eerror "You are using gcc built without 'openmp' USE."
		eerror "Switch CXX to an OpenMP capable compiler."
		die "Need openmp"
	fi

	if use doc; then
		CHECKREQS_DISK_BUILD="4G" check-reqs_pkg_pretend
	fi
}

pkg_setup() {
	python-single-r1_pkg_setup
}

src_prepare() {
	default

	# we don't want static glew, but it's scattered across
	# thousand files
	# !!!CHECK THIS SED ON EVERY VERSION BUMP!!!
	sed -i \
		-e '/-DGLEW_STATIC/d' \
		$(find . -type f -name "CMakeLists.txt") || die

	# linguas cleanup
	local i
	if ! use nls; then
		rm -r "${S}"/release/datafiles/locale || die
	else
		if [[ -n "${LINGUAS+x}" ]] ; then
			cd "${S}"/release/datafiles/locale/po
			for i in *.po ; do
				mylang=${i%.po}
				has ${mylang} ${LINGUAS} || { rm -r ${i} || die ; }
			done
		fi
	fi
}

src_configure() {
	# FIX: forcing '-funsigned-char' fixes an anti-aliasing issue with menu
	# shadows, see bug #276338 for reference
	append-flags -funsigned-char
	append-lfs-flags
	append-ldflags $(no-as-needed)

	# WITH_PYTHON_SECURITY
	# WITH_PYTHON_SAFETY
	local mycmakeargs=(
		-DCMAKE_INSTALL_PREFIX=/usr
		-DWITH_INSTALL_PORTABLE=OFF
		-DWITH_BOOST=$(usex boost ON OFF )
		-DWITH_CYCLES=$(usex cycles ON OFF )
		-DWITH_OPENCOLLADA=$(usex collada ON OFF )
		-DWITH_IMAGE_DDS=$(usex dds ON OFF )
		-DWITH_MOD_FLUID=$(usex elbeem ON OFF )
		-DWITH_CODEC_FFMPEG=$(usex ffmpeg ON OFF )
		-DWITH_FFTW3=$(usex fftw ON OFF )
		-DWITH_MOD_OCEANSIM=$(usex fftw ON OFF )
		-DWITH_GAMEENGINE=$(usex game-engine ON OFF )
		-DWITH_INTERNATIONAL=$(usex nls ON OFF )
		-DWITH_JACK=$(usex jack ON OFF )
		-DWITH_IMAGE_OPENJPEG=$(usex jpeg2k ON OFF )
		-DWITH_OPENIMAGEIO=$(usex openimageio ON OFF )
		-DWITH_OPENAL=$(usex openal ON OFF )
		-DWITH_IMAGE_OPENEXR=$(usex openexr ON OFF )
		-DWITH_OPENMP=$(usex openmp ON OFF )
		-DWITH_OPENNL=$(usex opennl ON OFF )
		-DWITH_PLAYER=$(usex player ON OFF )
		-DWITH_IMAGE_REDCODE=$(usex redcode ON OFF )
		-DWITH_SDL=$(usex sdl ON OFF )
		-DWITH_CODEC_SNDFILE=$(usex sndfile ON OFF )
		-DWITH_RAYOPTIMIZATION=$(usex cpu_flags_x86_sse ON OFF )
		-DWITH_SSE2=$(usex cpu_flags_x86_sse2 ON OFF )
		-DWITH_BULLET=$(usex bullet ON OFF )
		-DWITH_IMAGE_TIFF=$(usex tiff ON OFF )
		-DWITH_OPENCOLORIO=$(usex colorio ON OFF )
		-DWITH_INPUT_NDOF=$(usex ndof ON OFF )
		-DWITH_CXX_GUARDEDALLOC=$(usex debug ON OFF )
		-DWITH_ASSERT_ABORT=$(usex debug ON OFF )
		-DWITH_MEM_JEMALLOC=$(usex jemalloc ON OFF)
		-DWITH_PYTHON_INSTALL=OFF
		-DWITH_PYTHON_INSTALL_NUMPY=OFF
		-DWITH_STATIC_LIBS=OFF
		-DWITH_SYSTEM_GLEW=ON
		-DWITH_SYSTEM_OPENJPEG=ON
		-DWITH_SYSTEM_BULLET=OFF
		-DPYTHON_VERSION="${EPYTHON/python/}"
		-DPYTHON_LIBRARY="$(python_get_library_path)"
		-DPYTHON_INCLUDE_DIR="$(python_get_includedir)"
	)
	cmake-utils_src_configure
}

src_compile() {
	cmake-utils_src_compile

	if use doc; then
		# Workaround for binary drivers.
		cards=( /dev/ati/card* /dev/nvidia* )
		for card in "${cards[@]}"; do addpredict "${card}"; done

		einfo "Generating Blender C/C++ API docs ..."
		cd "${CMAKE_USE_DIR}"/doc/doxygen || die
		doxygen -u Doxyfile
		doxygen || die "doxygen failed to build API docs."

		cd "${CMAKE_USE_DIR}" || die
		einfo "Generating (BPY) Blender Python API docs ..."
		"${BUILD_DIR}"/bin/blender --background --python doc/python_api/sphinx_doc_gen.py -noaudio || die "blender failed."

		cd "${CMAKE_USE_DIR}"/doc/python_api || die
		sphinx-build sphinx-in BPY_API || die "sphinx failed."
	fi
}

src_install() {
	local i

	# Pax mark blender for hardened support.
	pax-mark m "${CMAKE_BUILD_DIR}"/bin/blender

	if use doc; then
		docinto "html/API/python"
		dodoc -r "${CMAKE_USE_DIR}"/doc/python_api/BPY_API/*

		docinto "html/API/blender"
		dodoc -r "${CMAKE_USE_DIR}"/doc/doxygen/html/*
	fi

	# fucked up cmake will relink binary for no reason
	emake -C "${CMAKE_BUILD_DIR}" DESTDIR="${D}" install/fast

	# fix doc installdir
	docinto "html"
	dodoc "${CMAKE_USE_DIR}"/release/text/readme.html
	rm -rf "${ED%/}"/usr/share/doc/blender

	python_fix_shebang "${ED%/}"/usr/bin/blender-thumbnailer.py
	python_optimize "${ED%/}"/usr/share/blender/${PV}/scripts
}

pkg_preinst() {
	gnome2_icon_savelist
}

pkg_postinst() {
	elog
	elog "Blender uses python integration. As such, may have some"
	elog "inherit risks with running unknown python scripting."
	elog
	elog "It is recommended to change your blender temp directory"
	elog "from /tmp to /home/user/tmp or another tmp file under your"
	elog "home directory. This can be done by starting blender, then"
	elog "dragging the main menu down do display all paths."
	elog
	ewarn
	ewarn "This ebuild does not unbundle the massive amount of 3rd party"
	ewarn "libraries which are shipped with blender. Note that"
	ewarn "these have caused security issues in the past."
	ewarn "If you are concerned about security, file a bug upstream:"
	ewarn "  https://developer.blender.org/"
	ewarn

	gnome2_icon_cache_update
	xdg_mimeinfo_database_update
}

pkg_postrm() {
	gnome2_icon_cache_update
	xdg_mimeinfo_database_update

	ewarn
	ewarn "You may want to remove the following directory."
	ewarn "~/.config/${PN}/${MY_PV}/cache/"
	ewarn "It may contain extra render kernels not tracked by portage"
	ewarn
}
