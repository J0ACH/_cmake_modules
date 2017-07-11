################################################################################################
#[[

	prvni verze prece s registry
	
	RegisterAdd(
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

	RegisterCheckFunctionRequiredKeys(
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

function (RegisterCheckFunctionRequiredKeys)

	set(oneValueArgs FUNCTION)
	set(multiValueArgs KEYS)
	set(options VERBATIM)

    cmake_parse_arguments( RegisterCheckRequiredKeys "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN} )

	if(RegisterCheckRequiredKeys_FUNCTION)
		if(RegisterCheckRequiredKeys_VERBATIM)
			message(STATUS "\t${RegisterCheckRequiredKeys_FUNCTION} keys:")
		endif(RegisterCheckRequiredKeys_VERBATIM)
	else()
		message( FATAL_ERROR "RegisterCheckRequiredKeys: 'FUNCTION' argument required." )
	endif(RegisterCheckRequiredKeys_FUNCTION)

	foreach(oneKey ${RegisterCheckRequiredKeys_KEYS})
		set(oneVar ${RegisterCheckRequiredKeys_FUNCTION}_${oneKey})
		if(${oneVar})
			if(RegisterCheckRequiredKeys_VERBATIM)
				message( STATUS "\t\t- " ${oneKey} ": " ${${oneVar}})
			endif()
		else()
			message( FATAL_ERROR "RegisterAdd: '" ${oneKey} "' argument required." )
		endif(${oneVar})
	endforeach(oneKey)
endfunction (RegisterCheckFunctionRequiredKeys)

################################################################################################

function (RegisterAdd)

	message(STATUS "")	
	message(STATUS "RegisterAdd macro init")

	set(oneValueArgs NAME KEY VALUE)
	set(multiValueArgs )
	set(options PATH VERBATIM)

    cmake_parse_arguments( RegisterAdd "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN} )

	RegisterCheckFunctionRequiredKeys(
		FUNCTION RegisterAdd
		KEYS NAME KEY VALUE
		VERBATIM TRUE
	)

	set(reg_path HKEY_CURRENT_USER\\Software\\Kitware\\CMake\\Packages\\${RegisterAdd_NAME})
	if (WIN32)
		execute_process (
			COMMAND reg add ${reg_path} /v ${RegisterAdd_KEY} /d ${RegisterAdd_VALUE} /t REG_SZ /f
			RESULT_VARIABLE RT
			ERROR_VARIABLE  ERR
			OUTPUT_QUIET
		)

		if (RT EQUAL 0)
			message (STATUS "\t- key [" ${RegisterAdd_KEY} "] added to register with value: " ${RegisterAdd_VALUE})
		else ()
			string (STRIP "${ERR}" ERR)
			message (STATUS "Register: Failed to add registry entry: ${ERR}")
		endif ()
	endif (WIN32)

	if (UNIX)
		message(STATUS "RegisterAdd: chybi definice pro Linux...\n")

		#[[
			if (WIN32)
				.......
			elseif (IS_DIRECTORY "$ENV{HOME}")
			file (WRITE "${BINARY_CONFIG_DIR}/${PackageName}RegistryFile" "${PackageConfig_Dir}")
			install (
				FILES       "${BINARY_CONFIG_DIR}/${PackageName}RegistryFile"
				DESTINATION "$ENV{HOME}/.cmake/packages/${PackageName}"
				RENAME      "${CMAKE_CONFIGURATION_TYPES}"
			)
			endif ()
		#]]

	endif (UNIX)
	
	message(STATUS "RegisterAdd macro done...\n")
endfunction (RegisterAdd)

################################################################################################

FUNCTION (RegisterGet)

	message(STATUS "")	
	message(STATUS "RegisterGet macro init")

	set(oneValueArgs NAME KEY RETURN)
	set(multiValueArgs )
	set(options VERBATIM)

    cmake_parse_arguments( RegisterGet "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN} )

	RegisterCheckFunctionRequiredKeys(
		FUNCTION RegisterGet
		KEYS NAME KEY
		VERBATIM TRUE
	)

	set(reg_path HKEY_CURRENT_USER\\Software\\Kitware\\CMake\\Packages\\${RegisterGet_NAME})
	get_filename_component(value "[${reg_path};${RegisterGet_KEY}]" ABSOLUTE)
	
	if(value STREQUAL "/registry")
		set(value "-NOTFOUND")
	endif(value STREQUAL "/registry")

	set(${RegisterGet_RETURN} ${value} PARENT_SCOPE)

	if(RegisterGet_VERBATIM)
		MESSAGE (STATUS "\t- key [" ${RegisterGet_KEY} "] get value from register: " ${value})
	endif(RegisterGet_VERBATIM)
	
	message(STATUS "RegisterGet macro done...\n")
ENDFUNCTION (RegisterGet)