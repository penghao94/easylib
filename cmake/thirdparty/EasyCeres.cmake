#
# Copyright(c) 2019 Hao Peng<ph1994wh@gmail.com>.
# Distributed under the BSD License 
#

#Set Ceres root dir
set(CERES_ROOT_DIR "${ELIB_EXTERNAL_DIR}/ceres")

if(NOT TARGET  elib::ceres)
   if(UNIX)
      find_package(Ceres REQUIRED)
      if(NOT CERES_FOUND)
         message("
         Cerse can be easily installed on linux, you can follow these instructions(http://www.ceres-solver.org/installation.html#linux):
         # google-glog + gflags
         sudo apt-get install libgoogle-glog-dev
         # BLAS & LAPACK
         sudo apt-get install libatlas-base-dev
         # Eigen3
         sudo apt-get install libeigen3-dev
         # SuiteSparse and CXSparse (optional)
         # - If you want to build Ceres as a *static* library (the default)
         #   you can use the SuiteSparse package in the main Ubuntu package
         #   repository:
         sudo apt-get install libsuitesparse-dev
         # - However, if you want to build Ceres as a *shared* library, you must
         #   add the following PPA:
         sudo add-apt-repository ppa:bzindovic/suitesparse-bugfix-1319687
         sudo apt-get update
         sudo apt-get install libsuitesparse-dev

         tar zxf ceres-solver-1.14.0.tar.gz
         mkdir ceres-bin
         cd ceres-bin
         cmake ../ceres-solver-1.14.0
         make -j3
         make test
         # Optionally install Ceres, it can also be exported using CMake which
         # allows Ceres to be used without requiring installation, see the documentation
         # for the EXPORT_BUILD_DIR option for more information.
         make install
         ")
         message(FATEL_ERROR "Please install Ceres first..")
      endif()    
   endif()

   if(APPLE)
      find_package(Ceres REQUIRED)
      if(NOT CERES_FOUND)
      message("
      Cerse can be easily installed on linux, you can follow these instructions(http://www.ceres-solver.org/installation.html#mac-os-x):
      (1) If using MacPorts, then
      sudo port install ceres-solver

      (2)If using Homebrew and assuming that you have the homebrew/science tap enabled, then
      brew install ceres-solver
      # CMake
      brew install cmake
      # google-glog and gflags
      brew install glog
      # Eigen3
      brew install eigen
      # SuiteSparse and CXSparse
      brew install suite-sparse
      tar zxf ceres-solver-1.14.0.tar.gz
      mkdir ceres-bin
      cd ceres-bin
      cmake ../ceres-solver-1.14.0
      make -j3
      make test
      # Optionally install Ceres, it can also be exported using CMake which
      # allows Ceres to be used without requiring installation, see the
      # documentation for the EXPORT_BUILD_DIR option for more information.
      make install
      ")
      message(FATEL_ERROR "Please install Ceres first..")
      endif(NOT CERES_FOUND)
   endif()

   if(WIN32)
      #Install Ceres on windows is a little difficult..
      message(STATUS "\nDownloading ceres to ${CERES_ROOT_DIR}\n")
      download_ceres()
      #Install dependencies
      include(EasySuiteSparse)
      include(EasyGlog)

      #Because The interface between suitesparse and ceres are differet, I have to hack and repair ceres cmakelists

      #Hack <prefix>/CMakelists.txt
      file(STRINGS ${CERES_ROOT_DIR}/CMakeLists.txt content NEWLINE_CONSUME)
      string(REGEX MATCH "LAPACK CONFIG QUIET" is_write ${content})
      if(NOT is_write)
         message(STATUS "Hack <prefix>/CMakelists.txt\n")
         string(REGEX REPLACE ";" "\\\\\\\\\\\\\\\\\\\;" content ${content})#CMake will eat ; ╮(╯▽╰)╭... each REGEX need '\\\\'
         string(REGEX REPLACE "LAPACK QUIET" "LAPACK CONFIG QUIET" content ${content})
         string(REGEX REPLACE "find_package\\(SuiteSparse\\)" "find_package(SuiteSparse CONFIG)\n\tset(SUITESPARSE_FOUND \${SuiteSparse_FOUND})\n\tset(SUITESPARSE_INCLUDE_DIRS \${SuiteSparse_INCLUDE_DIRS})\n\tset(SUITESPARSE_LIBRARIES \${SuiteSparse_LIBRARIES})\n" content ${content})
         string(REGEX REPLACE "find_package\\(Glog\\)" "find_package(Glog CONFIG)\nset(GLOG_FOUND \${Glog_FOUND})\nset(GLOG_LIBRARIES glog::glog)\n" 
         content ${content})

         set(GFLAGS_TARGET_NAMESPACE "gflags")
         string(REGEX REPLACE "find_package\\(Gflags\\)" "find_package(Gflags CONFIG)\nset(GFLAGS_FOUND \${Gflags_FOUND})\nset(GFLAGS_NAMESPACE ${GFLAGS_TARGET_NAMESPACE})\nset(GFLAGS_INCLUDE_DIRS \${GFLAGS_INCLUDE_DIR})\n" content ${content})
         file(WRITE ${CERES_ROOT_DIR}/CMakeLists.txt ${content})
      endif()

      unset(content)
      unset(is_write)
      #Hack <prefix>/cmake/CeresConfig.cmake.in
      cmake_policy(SET CMP0053 NEW)
      file(STRINGS ${CERES_ROOT_DIR}/cmake/CeresConfig.cmake.in content NEWLINE_CONSUME)
      string(REGEX MATCH "CERES_USE_SUITESPARSE" is_write ${content})
      if(NOT is_write)
         message(STATUS "Hack <prefix>/cmake/CeresConfig.cmake.in\n")
         string(REGEX REPLACE ";" "\\\\\\\;" content ${content})#CMake will eat ; ╮(╯▽╰)╭...
         string(REGEX REPLACE "# Import exported Ceres targets, if they have not already been imported." "set(CERES_USE_SUITESPARSE @SUITESPARSE@)\nif(CERES_USE_SUITESPARSE)\n\tset(SuiteSparse_DIR @SuiteSparse_DIR@)\n\tfind_package(SuiteSparse CONFIG REQUIRED)\n\tlist(APPEND CERES_INCLUDE_DIRS \${SuiteSparse_INCLUDE_DIRS})\nendif(CERES_USE_SUITESPARSE)\n\n# Import exported Ceres targets, if they have not already been imported." content ${content})
         file(WRITE ${CERES_ROOT_DIR}/cmake/CeresConfig.cmake.in ${content})
      endif()

      unset(is_write)
      unset(content)
   
      if(MSVC)
         #Configure Ceres
         message(STATUS "\n${CMAKE_COMMAND} -S ${CERES_ROOT_DIR} -B ${CERES_ROOT_DIR}/ceres-build -G ${VS_TOOLSET} -A ${VS_ARCH} -DCMAKE_INSTALL_PREFIX=${CERES_ROOT_DIR}/install -DSUITESPARSE=true -DLAPACK=FALSE -DLAPACK_DIR=${LAPACK_DIR} -DEIGEN_INCLUDE_DIR=${EIGEN_ROOT_DIR} -DSuiteSparse_DIR=${SuiteSparse_DIR} -DFOUND_INSTALLED_GFLAGS_CMAKE_CONFIGURATION=TRUE -DFOUND_INSTALLED_GLOG_CMAKE_CONFIGURATION=TRUE -DGflags_DIR=${gflags_DIR} -Dgflags_DIR=${gflags_DIR} -DGlog_DIR=${glog_DIR} -DGLOG_INCLUDE_DIRS=${GLOG_INSTALL_PREFIX}/include -DBUILD_TESTING=FALSE -DBUILD_BENCHMARKS=FALSE -DBUILD_EXAMPLES=FALSE\n" )
         execute_process(COMMAND ${CMAKE_COMMAND} -S ${CERES_ROOT_DIR} -B ${CERES_ROOT_DIR}/ceres-build -G ${VS_TOOLSET} -A ${VS_ARCH} -DCMAKE_INSTALL_PREFIX=${CERES_ROOT_DIR}/install -DSUITESPARSE=true -DLAPACK=FALSE -DLAPACK_DIR=${LAPACK_DIR} -DEIGEN_INCLUDE_DIR=${EIGEN_ROOT_DIR} -DSuiteSparse_DIR=${SuiteSparse_DIR} -DFOUND_INSTALLED_GFLAGS_CMAKE_CONFIGURATION=TRUE -DFOUND_INSTALLED_GLOG_CMAKE_CONFIGURATION=TRUE -DGflags_DIR=${gflags_DIR} -Dgflags_DIR=${gflags_DIR} -DGlog_DIR=${glog_DIR} -DGLOG_INCLUDE_DIRS=${GLOG_INSTALL_PREFIX}/include -DBUILD_TESTING=FALSE -DBUILD_BENCHMARKS=FALSE -DBUILD_EXAMPLES=FALSE WORKING_DIRECTORY ${CERES_ROOT_DIR} OUTPUT_QUIET ERROR_QUIET)

         #Build and install Ceres
         set(CERES_BUILD_TYPE "Debug" "Release")
         file(GLOB LAPACK_DLL ${LAPACK_DIR}/*.dll)

         foreach(cbt ${SUITESPARSE_BUILD_TYPE})
            message(STATUS "${CMAKE_COMMAND} --build . --target INSTALL --config ${cbt}\n" )
            execute_process(COMMAND ${CMAKE_COMMAND} --build . --target INSTALL --config ${cbt} WORKING_DIRECTORY ${CERES_ROOT_DIR}/ceres-build OUTPUT_QUIET)
            ##For windows,we have to copy ${LAPACK_DIR}/*.dll to CMAKE_RUNTIME_OUTPUT_DIRECTORY
            execute_process(COMMAND ${CMAKE_COMMAND} -E copy_if_different ${LAPACK_DLL} ${CMAKE_BINARY_DIR}/${cbt} WORKING_DIRECTORY ${CERES_ROOT_DIR}/ceres-build OUTPUT_QUIET)
         endforeach()
      else()
        message(FATEL_ERROR "Sorry, we just support MSVC complier on Windows platform...")
        endif(MSVC)
   endif(WIN32)
   # Check for Ceres and dependencies.
   set(CERES_INSTALL_PREFIX ${CERES_ROOT_DIR}/install)
   get_config_path(NAME Ceres INSTALL_PREFIX ${CERES_INSTALL_PREFIX})
   find_package(Ceres REQUIRED)
   if (Ceres_FOUND)
       compile_module("ceres")
       target_include_directories(elib_ceres ${ELIB_SCOPE_WITH_CERES} ${CERES_INCLUDE_DIRS})
       target_link_libraries( elib_ceres ${ELIB_SCOPE_WITH_CERES} ${CERES_LIBRARIES})
      
   endif()
endif(NOT TARGET elib::ceres)
