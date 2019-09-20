#
# Copyright(c) 2019 Hao Peng<ph1994wh@gmail.com>.
# Distributed under the BSD License 
#
cmake_minimum_required(VERSION 3.0.0)

#Options
option(USE_STATIC_LIBRARY "Use library as static library" OFF)
option(ELIB_WITH_EIGEN "Use Eigen as the stanard math library" ON)
option(ELIB_WITH_THREAD "Use C++ 11 thread" ON)
option(ELIB_EXPORT_TARGETS "Export easylib Cmake targets" OFF)

#Path configurations
set(ELIB_ROOT_DIR "${CMAKE_CURRENT_LIST_DIR}/..")
set(ELIB_SOURCE_DIR "${ELIB_ROOT_DIR}/include")
set(ELIB_EXTERNAL_DIR "${ELIB_ROOT_DIR}/external")

#Static compile
if(USE_STATIC_LIBRARY)
    set(ELIB_SCOPE PUBLIC)
else()
    set(ELIB_SCOPE INTERFACE)
endif()

#Update and upgrade third party libraries
list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_LIST_DIR} ${CMAKE_CURRENT_LIST_DIR}/thirdparty)
include(RequireExternal)
include(DownloadCache)
#Common configuration
add_library(elib_common INTERFACE)
set_property(TARGET elib_common PROPERTY EXPORT_NAME elib::common)

#Add include dir
target_include_directories(elib_common SYSTEM INTERFACE
$<BUILD_INTERFACE:${ELIB_SOURCE_DIR}>
$<INSTALL_INTERFACE:include>
)

#Common static configuration
if(USE_STATIC_LIBRARY)
    target_compile_definitions(elib_common INTERFACE -DELIB_STATIC_LIBRARY)
endif()

#Common C++ features 
include(CXXFeatures) 
target_compile_features(elib_common INTERFACE ${CXX11_FEATURES})

#Common cross-platfrom features
if(MSVC)
  # Enable parallel compilation for Visual Studio
  target_compile_options(elib_common INTERFACE /MP /bigobj)
  target_compile_definitions(elib_common INTERFACE -DNOMINMAX)
endif()

# http://lists.llvm.org/pipermail/llvm-commits/Week-of-Mon-20160425/351643.html
if(APPLE)
  if(NOT CMAKE_LIBTOOL)
    find_program(CMAKE_LIBTOOL NAMES libtool)
  endif()
  if(CMAKE_LIBTOOL)
    set(CMAKE_LIBTOOL ${CMAKE_LIBTOOL} CACHE PATH "libtool executable")
    message(STATUS "Found libtool - ${CMAKE_LIBTOOL}")
    get_property(languages GLOBAL PROPERTY ENABLED_LANGUAGES)
    foreach(lang ${languages})
      # Added -c
      set(CMAKE_${lang}_CREATE_STATIC_LIBRARY
        "${CMAKE_LIBTOOL} -c -static -o <TARGET> <LINK_FLAGS> <OBJECTS> ")
    endforeach()
  endif()
endif()

if(UNIX)
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fPIC")
  set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -fPIC")
endif()

#common shared library property
if(BUILD_SHARED_LIBS)
  # Generate position independent code
  set_target_properties(elib_common PROPERTIES INTERFACE_POSITION_INDEPENDENT_CODE ON)
endif()

# Set Eigen as global math library
if(ELIB_WITH_EIGEN)
	if(TARGET Eigen3::Eigen)
	  # If an imported target already exists, use it
	  target_link_libraries(elib_common INTERFACE Eigen3::Eigen)
	else()
	  download_eigen()
	  target_include_directories(elib_common SYSTEM INTERFACE
	    $<BUILD_INTERFACE:${EXTERNAL_DIR}/eigen>
	    $<INSTALL_INTERFACE:include>
	  )
	endif()
endif()

# Set C++ 11 thread library
if(ELIB_WITH_THREAD)
	find_package(Threads REQUIRED)
	target_link_libraries(elib_common INTERFACE ${CMAKE_THREAD_LIBS_INIT})
endif()

# Include Module Compile function at CompileModule.cmake
include(CompileModule)
include(MsvcHelper)
# Add elib::core library at first
compile_module("core")

# Add third party module 
include(OptionCache)

### Install and export all modules

if(NOT ELIB_EXPORT_TARGETS)
  return()
endif()

function(install_dir_files dir_name)
  if (dir_name STREQUAL "core")
    set(subpath "easylib")
  else()
    set(subpath "${dir_name}")
  endif()

  file(GLOB public_headers
    ${CMAKE_CURRENT_SOURCE_DIR}/include/${subpath}/*.h
    ${CMAKE_CURRENT_SOURCE_DIR}/include/${subpath}/*.hpp
  )

  set(files_to_install ${public_headers})

  if(NOT USE_STATIC_LIBRARY)
    file(GLOB public_sources
      ${CMAKE_CURRENT_SOURCE_DIR}/include/${subpath}/*.cpp
      ${CMAKE_CURRENT_SOURCE_DIR}/include/${subpath}/*.c
      ${CMAKE_CURRENT_SOURCE_DIR}/include/${subpath}/*.cc
      ${CMAKE_CURRENT_SOURCE_DIR}/include/${subpath}/*.cxx
    )
  endif()
  list(APPEND files_to_install ${public_sources})

  install(
    FILES ${files_to_install}
    DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/${subpath}
  )
endfunction()

include(GNUInstallDirs)
include(CMakePackageConfigHelpers)

# Install and export core library
install(
   TARGETS
     elib_core
     elib_common
   EXPORT elib-export
   PUBLIC_HEADER DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
   LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
   RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
   ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
)

export(
  TARGETS
    elib_core
    elib_common
  FILE easylib-export.cmake
)

# Install headers for core library
install_dir_files(core)

# Write package configuration file
configure_package_config_file(
  ${CMAKE_CURRENT_LIST_DIR}/easylib-config.cmake.in
  ${CMAKE_BINARY_DIR}/easylib-config.cmake
  INSTALL_DESTINATION ${CMAKE_INSTALL_DATAROOTDIR}/easylib/cmake
)
install(
  FILES
    ${CMAKE_BINARY_DIR}/easylib-config.cmake
  DESTINATION
    ${CMAKE_INSTALL_DATADIR}/easylib/cmake
)

# Write export file
export(EXPORT elib-export
  FILE "${CMAKE_BINARY_DIR}/easylib-export.cmake"
)
install(EXPORT elib-export DESTINATION ${CMAKE_INSTALL_DATADIR}/easylib/cmake FILE easylib-export.cmake)
export(PACKAGE easylib)

