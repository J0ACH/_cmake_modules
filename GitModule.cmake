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

	set(oneValueArgs NAME GIT PATH BRANCH)
	set(multiValueArgs )
	set(options VERBATIM)

	cmake_parse_arguments( GitClone "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN} )

	if(NOT GitClone_BRANCH)
		set(GitClone_BRANCH "master")
	endif(NOT GitClone_BRANCH)

	CheckRequiredKeys(
		FUNCTION GitClone
		KEYS NAME GIT BRANCH PATH
		VERBATIM TRUE
	)

	set(_GitMainDir ${GitClone_PATH}/${GitClone_NAME})
	set(_GitDownloadDir ${_GitMainDir}/download)
	set(_GitSourceDir ${_GitMainDir}/src)
	set(_GitCacheDir ${_GitMainDir}/cache)
	message(STATUS "GitInitBuildFile: " ${_GitDownloadDir})
	
	file(MAKE_DIRECTORY ${GitClone_PATH})
	
	set(BuildFile 
		"cmake_minimum_required(VERSION 2.8.2)\n"
		"project(${GitClone_NAME}-download NONE)\n"

		"include(ExternalProject)"
		"ExternalProject_Add(${GitClone_NAME}-download"
			"\tGIT_REPOSITORY      ${GitClone_GIT}"
			"\tGIT_TAG			   ${GitClone_BRANCH}"
			"\tDOWNLOAD_DIR		   ${_GitCacheDir}" 
			"\tSOURCE_DIR          ${_GitSourceDir}"
			"\tBINARY_DIR          ${_GitCacheDir}"
			"\tCMAKE_ARGS		   -DCMAKE_INSTALL_PREFIX=${_GitMainDir}"
		")"
	)

	set(ConfigTxt "") 
	#message(STATUS "\t - ConfigTxt:")
	foreach(oneLine ${BuildFile})
	 	#message(STATUS "\t\t - " ${oneLine})
		set(ConfigTxt "${ConfigTxt} ${oneLine} \n")
	endforeach(oneLine)
	
	file(WRITE ${_GitDownloadDir}/CMakeLists.txt ${ConfigTxt})

    execute_process(
		COMMAND ${CMAKE_COMMAND} -G ${CMAKE_GENERATOR}
		RESULT_VARIABLE result
        WORKING_DIRECTORY ${_GitDownloadDir}
    )
    if(result)
        message(FATAL_ERROR "CMake step for ${GitClone_NAME} failed: ${result}")
    endif()

	execute_process(
		COMMAND ${CMAKE_COMMAND} 
			--build .
			--config Release
		RESULT_VARIABLE result
		WORKING_DIRECTORY ${_GitDownloadDir}
	)
	if(result)
        message(FATAL_ERROR "Build step for ${GitClone_NAME} failed: ${result}")
    endif()
	
	message(STATUS "GitClone macro done...\n")
endfunction (GitClone)