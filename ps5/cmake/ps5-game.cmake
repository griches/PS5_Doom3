# Doom 3 BFG for the PlayStation 5 - what the console adds to RBDoom3BFG's own build.
#
# tools/build.sh configures vendor/RBDOOM-3-BFG/neo itself with the payload
# SDK's toolchain, and names this file as CMAKE_PROJECT_RBDoom3BFG_INCLUDE:
# CMake includes it right after the project() call, before the build reads its
# options and looks for its dependencies. It provides:
#
#   SDL2     .deps/SDL2, patched (tools/setup-sdl.sh), with the drivers in ps5/sdl
#   OpenAL   openal-soft (tools/setup-openal.sh), static, playing through SDL2
#   Vulkan   the Vulkan-Headers NVRHI carries (the driver, RADV, is linked by
#            tools/link-title.sh, and every command comes from its entry point)
#   zlib     the headers of the zlib inside the RADV archive
#   options  the console's choices among RBDoom3BFG's own
#
# and makes the executable's link PS5_Vulkan's (tools/link-title.sh, with RADV).
# The shaders are not built here: tools/shaders.sh compiles them on the build
# host into the title's base/renderprogs2/spirv.
#
# SPDX-License-Identifier: GPL-3.0-or-later

foreach(required PS5_PORT_DIR PS5_VULKAN_DIR SDL_DIR OPENAL_DIR)
	if(NOT ${required})
		message(FATAL_ERROR "ps5-game.cmake: ${required} is not set (use ps5/tools/build.sh)")
	endif()
endforeach()
set(ps5 ${PS5_PORT_DIR}/ps5)

# -fno-omit-frame-pointer: the console's crash backtraces are frame-pointer walks.
add_compile_options(-g1 -ffunction-sections -fdata-sections -fno-omit-frame-pointer)
# The console's CPU is a Zen 2: the toolchain's default is the first x86-64.
add_compile_options(-march=znver2)
# An init array, in the order the source has: tools/cc-init-array.sh has the reason
set(CMAKE_C_COMPILER_LAUNCHER sh ${ps5}/tools/cc-init-array.sh)
set(CMAKE_CXX_COMPILER_LAUNCHER sh ${ps5}/tools/cc-init-array.sh)
set(CMAKE_POLICY_DEFAULT_CMP0077 NEW)
set(BUILD_SHARED_LIBS OFF)
set(CMAKE_CXX_SCAN_FOR_MODULES OFF)
# Headers a Linux game expects that the console's C library has elsewhere (ps5/include/malloc.h)
include_directories(BEFORE ${ps5}/include)

# The platform archive, by its file and not its target: it is linked whole into the title (below)
set(ps5_platform_archive ${CMAKE_BINARY_DIR}/libps5_platform.a)

# zlib is in the RADV archive already (Mesa's own): its headers, and nothing to link.
# With it "found", the game leaves its own copy of zlib out (it keeps minizip).
set(ZLIB_INCLUDE_DIR ${PS5_VULKAN_DIR}/.deps/native/zlib/root/usr/include CACHE PATH "" FORCE)
set(ZLIB_LIBRARY ${ps5_platform_archive} CACHE FILEPATH "" FORCE)

# The console: klog, the pad, and the libc names a title cannot import
add_library(ps5_platform STATIC ${ps5}/src/platform.c ${ps5}/src/shims.c ${ps5}/src/startup.c
	${ps5}/src/devloop_shot.c)
target_include_directories(ps5_platform PUBLIC ${ps5}/src)
file(READ ${ps5}/sce_sys/param.json param_json)
string(JSON PS5_TITLE_NAME GET "${param_json}" localizedParameters en-US titleName)
target_compile_definitions(ps5_platform PRIVATE "PS5_TITLE_NAME=\"${PS5_TITLE_NAME}\"")
target_include_directories(ps5_platform PRIVATE ${ZLIB_INCLUDE_DIR})
set_target_properties(ps5_platform PROPERTIES ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR})

# SDL2: threads, time and files as a FreeBSD has them; video, input and audio from ps5/sdl
set(SDL_PS5_PORT_DIR ${ps5}/sdl CACHE INTERNAL "")
set(SDL_PS5_PLATFORM_DIR ${ps5}/src CACHE INTERNAL "")
set(SDL_STATIC ON CACHE BOOL "" FORCE)
set(SDL2_DISABLE_SDL2MAIN ON CACHE BOOL "" FORCE)
set(SDL2_DISABLE_INSTALL ON CACHE BOOL "" FORCE)
set(SDL2_DISABLE_UNINSTALL ON CACHE BOOL "" FORCE)
foreach(off SDL_SHARED SDL_TEST SDL_TESTS
		SDL_X11 SDL_WAYLAND SDL_KMSDRM SDL_RPI SDL_VIVANTE SDL_OFFSCREEN SDL_DUMMYVIDEO SDL_DIRECTFB
		SDL_OPENGL SDL_OPENGLES SDL_VULKAN
		SDL_OSS SDL_ALSA SDL_JACK SDL_ESD SDL_ARTS SDL_NAS SDL_PIPEWIRE SDL_PULSEAUDIO SDL_SNDIO SDL_FUSIONSOUND
		SDL_DISKAUDIO SDL_DUMMYAUDIO SDL_LIBSAMPLERATE
		SDL_DBUS SDL_IBUS SDL_LIBUDEV SDL_HIDAPI SDL_HIDAPI_LIBUSB SDL_HIDAPI_JOYSTICK SDL_VIRTUAL_JOYSTICK
		SDL_SYSTEM_ICONV SDL_LIBICONV SDL_RPATH SDL_SENSOR SDL_HAPTIC SDL_POWER)
	set(${off} OFF CACHE BOOL "" FORCE)
endforeach()
# (SDL_LOADSO stays on: without it SDL drops its Vulkan support. SDL_VULKAN is SDL's switch for a
# desktop's loader: ps5/patches/sdl.patch turns Vulkan on for the console itself)
add_subdirectory(${SDL_DIR} ${CMAKE_BINARY_DIR}/SDL2 EXCLUDE_FROM_ALL)
target_include_directories(ps5_platform PRIVATE ${SDL_DIR}/include)
if(NOT TARGET SDL2::SDL2)
	add_library(SDL2::SDL2 ALIAS SDL2-static)
endif()
# <SDL.h> and <SDL2/SDL.h> both: the build tree has its headers under include/SDL2
set(SDL2_INCLUDE_DIRS ${CMAKE_BINARY_DIR}/SDL2/include ${CMAKE_BINARY_DIR}/SDL2/include/SDL2
	${CMAKE_BINARY_DIR}/SDL2/include-config-release)
include_directories(${SDL2_INCLUDE_DIRS})
# find_package(SDL2) in the game and in openal-soft: the target above (ps5/cmake/sdl2/SDL2Config.cmake)
set(SDL2_DIR ${ps5}/cmake/sdl2 CACHE PATH "" FORCE)

# Vulkan: the headers NVRHI carries, vulkan.hpp with them. No loader and no
# prototypes: vulkan.hpp's dynamic dispatcher, NVRHI and VMA take every command from
# RADV's entry point (vk_icdGetInstanceProcAddr, the game's DeviceManager_VK.cpp).
set(ps5_vulkan_headers ${CMAKE_SOURCE_DIR}/extern/nvrhi/thirdparty/Vulkan-Headers/include)
set(Vulkan_INCLUDE_DIR ${ps5_vulkan_headers} CACHE PATH "" FORCE)
set(Vulkan_LIBRARY ${ps5_platform_archive} CACHE FILEPATH "" FORCE)
include_directories(SYSTEM ${ps5_vulkan_headers})
add_compile_definitions(VK_NO_PROTOTYPES)

# OpenAL: openal-soft, static, with SDL2 for its only backend
set(LIBTYPE STATIC CACHE STRING "" FORCE)
set(CMAKE_DISABLE_FIND_PACKAGE_SDL3 ON)
foreach(off ALSOFT_UTILS ALSOFT_EXAMPLES ALSOFT_TESTS ALSOFT_INSTALL ALSOFT_INSTALL_CONFIG
		ALSOFT_INSTALL_HRTF_DATA ALSOFT_INSTALL_AMBDEC_PRESETS ALSOFT_INSTALL_EXAMPLES ALSOFT_INSTALL_UTILS
		ALSOFT_UPDATE_BUILD_VERSION ALSOFT_DLOPEN ALSOFT_EAX
		ALSOFT_BACKEND_PIPEWIRE ALSOFT_BACKEND_PULSEAUDIO ALSOFT_BACKEND_ALSA ALSOFT_BACKEND_OSS
		ALSOFT_BACKEND_SOLARIS ALSOFT_BACKEND_SNDIO ALSOFT_BACKEND_JACK ALSOFT_BACKEND_PORTAUDIO
		ALSOFT_BACKEND_WAVE ALSOFT_BACKEND_SDL3)
	set(${off} OFF CACHE BOOL "" FORCE)
endforeach()
set(ALSOFT_BACKEND_SDL2 ON CACHE BOOL "" FORCE)
set(ALSOFT_REQUIRE_SDL2 ON CACHE BOOL "" FORCE)
set(ALSOFT_EMBED_HRTF_DATA ON CACHE BOOL "" FORCE)
add_subdirectory(${OPENAL_DIR} ${CMAKE_BINARY_DIR}/openal-soft EXCLUDE_FROM_ALL)
# FindOpenAL, as the game calls it, answered by the target
set(OPENAL_INCLUDE_DIR ${OPENAL_DIR}/include CACHE PATH "" FORCE)
set(OPENAL_LIBRARY OpenAL CACHE STRING "" FORCE)
include_directories(${OPENAL_DIR}/include)
add_compile_definitions(AL_LIBTYPE_STATIC)

# RBDoom3BFG's options, as the console has them
set(OPENAL ON CACHE BOOL "" FORCE)
set(FFMPEG OFF CACHE BOOL "" FORCE)
set(BINKDEC ON CACHE BOOL "" FORCE)
set(DOOM_CLASSIC ON CACHE BOOL "" FORCE)
set(USE_VULKAN ON CACHE BOOL "" FORCE)
set(USE_VMA ON CACHE BOOL "" FORCE)
set(USE_SYSTEM_ZLIB ON CACHE BOOL "" FORCE)
set(OPTICK OFF CACHE BOOL "" FORCE)
set(ONATIVE OFF CACHE BOOL "" FORCE)
# the precompiled header is made by a command of its own, outside the toolchain's launcher
set(USE_PRECOMPILED_HEADERS OFF CACHE BOOL "" FORCE)
# ShaderMake is built for the build host by tools/shaders.sh, not here: nothing to look for
set(SHADERMAKE_FIND_FXC OFF CACHE BOOL "" FORCE)
set(SHADERMAKE_FIND_DXC OFF CACHE BOOL "" FORCE)
set(SHADERMAKE_FIND_DXC_SPIRV OFF CACHE BOOL "" FORCE)

# The link: every object and archive CMake would hand the linker goes to
# PS5_Vulkan's recipe instead (RADV, the platform layer, the CRT, the fake SELF)
set(CMAKE_CXX_LINK_EXECUTABLE
	"bash ${ps5}/tools/link-title.sh ${CMAKE_BINARY_DIR} ${PS5_VULKAN_DIR} ${PS5_PAYLOAD_SDK} --whole-archive ${ps5_platform_archive} --no-whole-archive <OBJECTS> <LINK_LIBRARIES>")
# (the start-up constructor in the platform archive has no caller: hence whole)

# The platform archive and OpenAL are named by file or name in the link, so the
# game does not depend on them by itself (the game's target exists once its
# CMakeLists.txt has run)
function(ps5_late_fixes)
	add_dependencies(RBDoom3BFG ps5_platform OpenAL)
	set_property(TARGET RBDoom3BFG APPEND PROPERTY LINK_DEPENDS ${ps5_platform_archive})
endfunction()
cmake_language(DEFER DIRECTORY ${CMAKE_SOURCE_DIR} CALL ps5_late_fixes)
