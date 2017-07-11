################################################################################################
#[[

	prvni verze prece v configuration processu cmakeu
	
	GitClone(
		NAME "Pokus"
			- nazev folderu v cilove ceste registru
		KEY "treba_aaa"
			- nazev klice
		VALUE "C:/aaa"
		- hodnota klice
	)

	RegisterGet(
		NAME "Pokus"
			- nazev folderu v cilove ceste registru
		KEY "treba_aaa"
			- nazev klice
		RETURN TEST_var
		- promena, ktera bude vyplnena dotazovanou hodnotou
	)

	CheckFunctionRequiredKeys(
		FUNCTION RegisterAdd
			- nazev kontrolavane funkce 
		KEYS NAME KEY VALUE
			- nazev kontrolavane klicu
		VERBATIM TRUE || FALSE
			- tisk hodnot
	)

#]]
################################################################################################

message(STATUS "Module ${CMAKE_CURRENT_LIST_FILE} loaded")

function (CheckRequiredKeys)

	set(oneValueArgs FUNCTION)
	set(multiValueArgs KEYS)
	set(options VERBATIM)

    cmake_parse_arguments( CheckRequiredKeys "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN} )

	if(CheckRequiredKeys_FUNCTION)
		if(CheckRequiredKeys_VERBATIM)
			message(STATUS "\t${CheckRequiredKeys_FUNCTION} keys:")
		endif(CheckRequiredKeys_VERBATIM)
	else()
		message( FATAL_ERROR "CheckRequiredKeys: 'FUNCTION' argument required." )
	endif(CheckRequiredKeys_FUNCTION)

	foreach(oneKey ${CheckRequiredKeys_KEYS})
		set(oneVar ${CheckRequiredKeys_FUNCTION}_${oneKey})
		if(${oneVar})
			if(CheckRequiredKeys_VERBATIM)
				message( STATUS "\t\t- " ${oneKey} ": " ${${oneVar}})
			endif()
		else()
			message( FATAL_ERROR "CheckRequiredKeys at function " ${CheckRequiredKeys_FUNCTION} ": '" ${oneKey} "' argument required." )
		endif(${oneVar})
	endforeach(oneKey)
endfunction (CheckRequiredKeys)

################################################################################################

function (GitClone)

	message(STATUS "")	
	message(STATUS "GitClone macro init")

	set(oneValueArgs NAME GIT PATH)
	set(multiValueArgs )
	set(options VERBATIM)

    cmake_parse_arguments( GitClone "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN} )

	CheckRequiredKeys(
		FUNCTION GitClone
		KEYS NAME GIT PATH
		VERBATIM TRUE
	)

	set(_GitMainDir ${GitClone_PATH}/${GitClone_NAME})
	set(_GitDownloadDir ${_GitMainDir}/download)
	set(_GitSourceDir ${_GitMainDir}/src)
	set(_GitCacheDir ${_GitMainDir}/cache)
	message(STATUS "GitInitBuildFile: " ${_GitDownloadDir})

	file(MAKE_DIRECTORY ${GitClone_PATH})
	setDier
	
	set(BuildFile 
		"cmake_minimum_required(VERSION 2.8.2)\n"
		"project(${GitClone_NAME}-download NONE)\n"

		"include(ExternalProject)"
		"ExternalProject_Add(${GitClone_NAME}-download"
			"\tGIT_REPOSITORY      ${GitClone_GIT}"
			"\tGIT_TAG			   master"
			#"\tPREFIX		       ${_GitDownloadDir}"
			"\tDOWNLOAD_DIR		   ${_GitCacheDir}" 
			"\tSOURCE_DIR          ${_GitSourceDir}"
			#"\tSOURCE_DIR          ${_GitMainDir}"
			"\tBINARY_DIR          ${_GitCacheDir}"
			"\tINSTALL_DIR          ${_GitCacheDir}"
			#"\tCONFIGURE_COMMAND   \"\""
			#"\tBUILD_COMMAND       \"\""
			#"\tINSTALL_COMMAND     \"\""
			#"\tTEST_COMMAND        \"\""
			#"\tCMAKE_ARGS		   -DCMAKE_BINARY_DIR=${_GitCacheDir}"
			#"-DCMAKE_SOURCE_DIR=${_GitMainDir}"
		")"
	)

	set(ConfigTxt "") 
	message(STATUS "\t - ConfigTxt:")
	foreach(oneLine ${BuildFile})
	 	message(STATUS "\t\t - " ${oneLine})
		set(ConfigTxt "${ConfigTxt} ${oneLine} \n")
	endforeach(oneLine)
	
	file(WRITE ${_GitDownloadDir}/CMakeLists.txt ${ConfigTxt})

	#[[
    execute_process(
		COMMAND ${CMAKE_COMMAND} -G ${CMAKE_GENERATOR}
		RESULT_VARIABLE result
        WORKING_DIRECTORY ${_GitDownloadDir}
    )
    if(result)
        message(FATAL_ERROR "CMake step for ${GitClone_NAME} failed: ${result}")
    endif()

	execute_process(
		COMMAND ${CMAKE_COMMAND} --build .
		RESULT_VARIABLE result
		WORKING_DIRECTORY ${_GitDownloadDir}
	)
	if(result)
        message(FATAL_ERROR "Build step for ${GitClone_NAME} failed: ${result}")
    endif()
	#]]
	#[[
	
		INCLUDE(ExternalProject)
		ExternalProject_Add ( SharedLib
			GIT_REPOSITORY https://github.com/J0ACH/_template_SharedLib.git
			GIT_TAG "master"
			SOURCE_DIR "${CMAKE_BINARY_DIR}/SharedLib-src"
			BINARY_DIR "${CMAKE_BINARY_DIR}/SharedLib-build"
			UPDATE_COMMAND ""
			CMAKE_GENERATOR "Visual Studio 15 2017 Win64"
	
			#DOWNLOAD_DIR
			#INSTALL_DIR ${BUILD_DIR}
			#INSTALL_COMMAND ${SharedLib_inst_comm} 
			#INSTALL_DIR ${BUILD_DIR}/install
  			CMAKE_ARGS
			"-DCMAKE_CONFIGURATION_TYPES=${CMAKE_CONFIGURATION_TYPES}"
			"-DBUILD_DIR=${EXTERNAL_BUILD_LOCATION}"
			"-DCMAKE_INSTALL_PREFIX=${BUILD_DIR}"
		)
		configure_file(CMakeLists.txt.in googletest-download/CMakeLists.txt)
		execute_process(COMMAND "${CMAKE_COMMAND}" -G "${CMAKE_GENERATOR}" .
		WORKING_DIRECTORY "${CMAKE_BINARY_DIR}/googletest-download" )
		execute_process(COMMAND "${CMAKE_COMMAND}" --build .
		WORKING_DIRECTORY "${CMAKE_BINARY_DIR}/googletest-download" )
	#]]

	message(STATUS "GitClone macro done...\n")
endfunction (GitClone)