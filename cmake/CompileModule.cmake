#
# Copyright(c) 2019 Hao Peng<ph1994wh@gmail.com>.
# Distributed under the BSD License
# Creates an Interface Library as the module of a third party library. 
#An INTERFACE library target does not directly create build output, though it may have properties set on it and it may be installed, exported and imported.
#See https://cmake.org/cmake/help/latest/command/add_library.html?highlight=add_library
#
function(compile_module module_name)

  if(module_name STREQUAL "core")
    set(elib_module_name "elib_core")
  else()
    set(elib_module_name "elib_${module_name}")
  endif()

  if(USE_STATIC_LIBRARY)
    if(module_name STREQUAL "core")
      file(GLOB_RECURSE SOURCES_ELIB_${module_name}
          "${ELIB_SOURCE_DIR}/easylib/*.cpp")
    else()
      file(GLOB_RECURSE SOURCES_ELIB_${module_name}
          "${ELIB_SOURCE_DIR}/${module_dir}/*.cpp")
    endif()
    add_library(${elib_module_name} STATIC ${SOURCES_ELIB_${module_name}} ${ARGN})
    if(MSVC)
      target_compile_options(${elib_module_name} PRIVATE /w) # disable all warnings (not ideal but...)
    endif()
  else() 
     add_library(${elib_module_name} INTERFACE)
  endif()

  target_link_libraries(${elib_module_name} ${ELIB_SCOPE} elib_common)
  if(NOT module_name STREQUAL "core")
    target_link_libraries(${elib_module_name} ${ELIB_SCOPE} elib_core)
  endif()

  message(STATUS "Creating target: elib::${module_name} (${elib_module_name})")
  add_library(elib::${module_name} ALIAS ${elib_module_name})
  set_property(TARGET ${elib_module_name} PROPERTY EXPORT_NAME elib::${module_name})
endfunction()