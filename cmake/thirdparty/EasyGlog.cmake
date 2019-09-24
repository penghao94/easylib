#
# Copyright(c) 2019 Hao Peng<ph1994wh@gmail.com>.
# Distributed under the BSD License 
#

#set glog root dir
set(GLOG_ROOT_DIR ${ELIB_EXTERNAL_DIR}/glog)

if(NOT TARGET  elib::glog)
    message(STATUS "\nDownloading glog to ${GLOG_ROOT_DIR}")
    download_glog()

    include(EasyGflags)

    if(WIN32)
        if(MSVC)

        # #Hack <prefix>/glog-config.cmake.in
        # cmake_policy(SET CMP0053 NEW)
        # file(STRINGS ${GLOG_ROOT_DIR}/glog-config.cmake.in content NEWLINE_CONSUME)
        # string(REGEX MATCH "CERES_USE_SUITESPARSE" is_write ${content})
        # if(NOT is_write)
        #     message(STATUS "Hack <prefix>/glog-config.cmake.in\n")
        #     string(REGEX REPLACE ";" "\\\\\\\;" content ${content})#CMake will eat ; ╮(╯▽╰)╭...
        #     string(REGEX REPLACE "include \\(CMakeFindDependencyMacro\\)" "include (CMakeFindDependencyMacro)\n\nset(gflags_DIR @gflags_DIR@)" content ${content})
        #     file(WRITE ${GLOG_ROOT_DIR}/glog-config.cmake.in ${content})
        # endif()

        # unset(is_write)
        # unset(content)


            #Configure glog
            message(STATUS "\ncmake -S ${GLOG_ROOT_DIR} -B ${GLOG_ROOT_DIR}/glog-build -G ${VS_TOOLSET} -A ${VS_ARCH} -DCMAKE_INSTALL_PREFIX=${GLOG_ROOT_DIR}/glog-install -DWITH_GFLAGS=true -DGFLAGS_DIR=${GFLAGS_DIR}\n")
            execute_process(COMMAND cmake -S ${GLOG_ROOT_DIR} -B ${GLOG_ROOT_DIR}/glog-build -G ${VS_TOOLSET} -A ${VS_ARCH} -DCMAKE_INSTALL_PREFIX=${GLOG_ROOT_DIR}/glog-install -DWITH_GFLAGS=true -Dgflags_DIR=${GFLAGS_DIR}  -DBUILD_TESTING=false WORKING_DIRECTORY ${GLOG_ROOT_DIR} OUTPUT_QUIET)

            #Build and install glog
            set(GFLAGS_BUILD_TYPE "Debug" "Release")
            foreach(glbt ${GFLAGS_BUILD_TYPE})
                message(STATUS "cmake -S  execute_process(COMMAND cmake --build . --target INSTALL --config ${glbt}\n")
                execute_process(COMMAND cmake --build . --target INSTALL --config ${glbt} WORKING_DIRECTORY ${GLOG_ROOT_DIR}/glog-build OUTPUT_QUIET )
            endforeach()
        else()
            message(FATEL_ERROR "Sorry, we just support MSVC complier on Windows platform...")
        endif()
    else()
        #Configure glog
        message(STATUS "cmake -S ${GLOG_ROOT_DIR} -B ${GLOG_ROOT_DIR}/glog-build -DCMAKE_INSTALL_PREFIX=${GLOG_ROOT_DIR}/glog-install -DWITH_GFLAGS=true -DGFLAGS_DIR=${GFLAGS_DIR}  -DBUILD_TESTING=false\n")
        execute_process(COMMAND cmake -S ${GLOG_ROOT_DIR} -B ${GLOG_ROOT_DIR}/glog-build -DCMAKE_INSTALL_PREFIX=${GLOG_ROOT_DIR}/glog-install -DWITH_GFLAGS=true -Dgflags_DIR=${GFLAGS_DIR}  -DBUILD_TESTING=false WORKING_DIRECTORY ${GLOG_ROOT_DIR} OUTPUT_QUIET)

        #Build and install glog
        set(GFLAGS_BUILD_TYPE "Debug" "Release")
        foreach(glbt ${GFLAGS_BUILD_TYPE})
            message(STATUS "cmake --build . --config ${glbt}\n")
            execute_process(COMMAND cmake --build . --config ${glbt} WORKING_DIRECTORY ${GLOG_ROOT_DIR}/glog-build OUTPUT_QUIET)
        endforeach()
    endif()

    # Check for Gflags and dependencies
    set(GLOG_INSTALL_PREFIX ${GLOG_ROOT_DIR}/glog-install)
    get_config_path(NAME glog INSTALL_PREFIX ${GLOG_INSTALL_PREFIX})
    find_package(glog CONFIG )

    if(glog_FOUND)
        compile_module("glog")
        target_link_libraries(elib_glog ${ELIB_SCOPE} glog::glog)
    endif()
endif()