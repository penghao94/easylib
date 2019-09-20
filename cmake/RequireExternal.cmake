#
# Copyright(c) 2019 Hao Peng<ph1994wh@gmail.com>.
# Distributed under the BSD License

# Import the third party libraries from thirdparty/*.json and then rebuild them as download function. 
#

set(DOWNLOAD_CACHE "${CMAKE_CURRENT_LIST_DIR}/DownloadCache.cmake")
message(STATUS "Generate download cache at ${DOWNLOAD_CACHE}")
string(TIMESTAMP CACHE_DATE "%Y-%m-%d %H:%M:%S")
set(DOWNLOAD_PREFIX 
"#
# Copyright(c) 2019 Hao Peng<ph1994wh@gmail.com>.
# Distributed under the BSD License
# Import the third party libraries from thirdparty/*.json and then rebuild them as download function. 
# Generating at ${CACHE_DATE}.
#

include(DownloadProject)
# With CMake 3.8 and above, we can hide warnings about git being in a
# detached head by passing an extra GIT_CONFIG option.
set(ELIB_EXTRA_OPTIONS TLS_VERIFY OFF)
if(NOT (\${CMAKE_VERSION} VERSION_LESS \"3.8.0\"))
	list(APPEND ELIB_EXTRA_OPTIONS GIT_CONFIG advice.detachedHead=false)
endif()

# On CMake 3.6.3 and above, there is an option to use shallow clones of git repositories.
# The shallow clone option only works with real tags, not SHA1, so we use a separate option.
set(ELIB_BRANCH_OPTIONS)
if(NOT (\${CMAKE_VERSION} VERSION_LESS \"3.6.3\"))
    # Disabled for now until we can make sure that it has no adverse effects
	# (Downside is that the eigen mirror is huge again)
	# list(APPEND LIB_BRANCH_OPTIONS GIT_SHALLOW 1)
endif()


option(ELIB_SKIP_DOWNLOAD \"Skip downloading external libraries\" OFF)

# Shortcut functions
function(download_project_aux name source)
	if(NOT ELIB_SKIP_DOWNLOAD)
		download_project(
			PROJ         \${name}
			SOURCE_DIR   \"\${source}\"
			DOWNLOAD_DIR \"\${ELIB_EXTERNAL_DIR}/.cache/\${name}\"
			QUIET
			\${ELIB_EXTRA_OPTIONS}
			\${ARGN}
		)
	endif()
endfunction()

function(elib_download_project name)
	download_project_aux(\${name} \"\${ELIB_EXTERNAL_DIR}/\${name}\" \${ARGN})
endfunction()

#Third party library download functions
")
file(WRITE ${DOWNLOAD_CACHE} ${DOWNLOAD_PREFIX})

#Find all thirdparty download files.
file(GLOB DOWNLOAD_FILES "${CMAKE_CURRENT_LIST_DIR}/thirdparty/*.json")
foreach(filename ${DOWNLOAD_FILES})
    file(STRINGS ${filename} DOWNLOAD_INFO)
    string(REGEX MATCHALL "\"([^\"]*)\"" INFO ${DOWNLOAD_INFO})
    list(GET INFO 1 LIB_NAME)
    string(REGEX REPLACE "\"" "" LIB_NAME ${LIB_NAME})
    list(GET INFO 3 REPO_URL)
    string(REGEX REPLACE "\"" "" REPO_URL ${REPO_URL})
    list(GET INFO 5 REPO_TAG)
    string(REGEX REPLACE "\"" "" REPO_TAG ${REPO_TAG})
    list(GET INFO 7 ARGN)
    string(REGEX REPLACE "\"" "" ARGN ${ARGN})

    set(FUNC 
"function(download_${LIB_NAME})
	message(STATUS \"downloading ${LIB_NAME}...\")
	elib_download_project(${LIB_NAME}
		GIT_REPOSITORY ${REPO_URL}
		GIT_TAG        ${REPO_TAG}
		${ARGN}
	)
endfunction()
"   )
	 file(APPEND ${DOWNLOAD_CACHE} ${FUNC})
endforeach()


#Add third party libraryoptions to easylib.camke
message(STATUS "Generate download cache at ${DOWNLOAD_CACHE}")
set(OPTION_CACHE "${CMAKE_CURRENT_LIST_DIR}/OptionCache.cmake")
set(OPTION_PREFIX "
#
# Copyright(c) 2019 Hao Peng<ph1994wh@gmail.com>.
# Distributed under the BSD License
# Add third party library options to easylib.camke
# Generating at ${CACHE_DATE}.
#")

file(WRITE ${OPTION_CACHE} ${OPTION_PREFIX})
file(GLOB_RECURSE EASYCMAKE_FILES "${CMAKE_CURRENT_LIST_DIR}/thirdparty/*.cmake" )
foreach(filename ${EASYCMAKE_FILES})
	string(REGEX REPLACE "${CMAKE_CURRENT_LIST_DIR}/thirdparty/Easy" "" LIB_NAME ${filename})
	string(REGEX REPLACE ".cmake" "" LIB_NAME ${LIB_NAME})
	string(TOUPPER ${LIB_NAME} LIB_NAME_UPPER)

	set(EXTERNAL_OPTION "

#Add ${LIB_NAME}
option(ELIB_WITH_${LIB_NAME_UPPER}     \"Use ${LIB_NAME} in easylib\"     OFF)
if(ELIB_WITH_${LIB_NAME_UPPER})
	include(Easy${LIB_NAME})
endif()")
	file(APPEND ${OPTION_CACHE} ${EXTERNAL_OPTION})
endforeach()