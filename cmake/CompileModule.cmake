#
# Copyright(c) 2019 Hao Peng<ph1994wh@gmail.com>.
# Distributed under the BSD License
# Creates an Interface Library as the module of a third party library. 
#An INTERFACE library target does not directly create build output, though it may have properties set on it and it may be installed, exported and imported.
#See https://cmake.org/cmake/help/latest/command/add_library.html?highlight=add_library
#
macro(COMPILE_MODULE module_name)

  if(${module_name} STREQUAL "core")
    file(GLOB SOURCES_ELIB_${module_name} 
          "${ELIB_SOURCE_DIR}/easylib/*.cc" "${ELIB_SOURCE_DIR}/easylib/*.cpp" "${ELIB_SOURCE_DIR}/easylib/*.cxx" "${ELIB_SOURCE_DIR}/easylib/*.h" "${ELIB_SOURCE_DIR}/easylib/*.hpp")
  else()
    file(GLOB SOURCES_ELIB_${module_name}
    "${ELIB_SOURCE_DIR}/${module_dir}/*.cpp" "${ELIB_SOURCE_DIR}/${module_dir}/*.cc" "${ELIB_SOURCE_DIR}/${module_dir}/*.cxx" "${ELIB_SOURCE_DIR}/${module_dir}/*.h" "${ELIB_SOURCE_DIR}/${module_dir}/*.hpp")
    
  endif()
  
  set(elib_module_name "elib_${module_name}")
  string(TOUPPER ${module_name} SCOPE_NAME)
  if(NOT ${SOURCES_ELIB_${module_name}} STREQUAL "")
    if(USE_STATIC_LIBRARY )
      set(ELIB_SCOPE_WITH_${SCOPE_NAME} PUBLIC)
      add_library(${elib_module_name} STATIC ${SOURCES_ELIB_${module_name}})
      if(MSVC)
        target_compile_options(${elib_module_name} PRIVATE /w) # disable all warnings (not ideal but...)
      endif()
    else() 
      set(ELIB_SCOPE_WITH_${SCOPE_NAME} INTERFACE)
      add_library(${elib_module_name} INTERFACE)
    endif()
  else()
    set(ELIB_SCOPE_WITH_${SCOPE_NAME} INTERFACE)
    add_library(${elib_module_name} INTERFACE)
  endif()

  if(${module_name} STREQUAL "core")
    target_link_libraries(${elib_module_name} ELIB_SCOPE_WITH_${SCOPE_NAME} elib_common) 
  else()
    target_link_libraries(${elib_module_name} ELIB_SCOPE_WITH_${SCOPE_NAME} elib_core) 
  endif()

  message(STATUS "Creating target: elib::${module_name} (${elib_module_name})")
  add_library(elib::${module_name} ALIAS ${elib_module_name})
  set_property(TARGET ${elib_module_name} PROPERTY EXPORT_NAME elib::${module_name})
endmacro()