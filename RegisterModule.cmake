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

FUNCTION (RegisterCheckFunctionRequiredKeys)

	set(oneValueArgs FUNCTION)
	set(multiValueArgs KEYS)
	set(options VERBATIM)

    CMAKE_PARSE_ARGUMENTS( RegisterCheckRequiredKeys "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN} )

	if(RegisterCheckRequiredKeys_FUNCTION)
		if(RegisterCheckRequiredKeys_VERBATIM)
			message(STATUS "\t${RegisterCheckRequiredKeys_FUNCTION} keys:")
		endif(RegisterCheckRequiredKeys_VERBATIM)
	else()
		message( FATAL_ERROR "RegisterCheckRequiredKeys: 'FUNCTION' argument required." )
	endif(RegisterCheckRequiredKeys_FUNCTION)

	FOREACH(oneKey ${RegisterCheckRequiredKeys_KEYS})
		set(oneVar ${RegisterCheckRequiredKeys_FUNCTION}_${oneKey})
		if(${oneVar})
			if(RegisterCheckRequiredKeys_VERBATIM)
				message( STATUS "\t\t- " ${oneKey} ": " ${${oneVar}})
			endif()
		else()
			message( FATAL_ERROR "RegisterAdd: '" ${oneKey} "' argument required." )
		endif(${oneVar})
	ENDFOREACH(oneKey)

ENDFUNCTION (RegisterCheckFunctionRequiredKeys)

################################################################################################

FUNCTION (RegisterAdd)

	message(STATUS "")	
	message(STATUS "RegisterAdd macro init")

	set(oneValueArgs NAME KEY VALUE)
	set(multiValueArgs )
	set(options VERBATIM)

    CMAKE_PARSE_ARGUMENTS( RegisterAdd "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN} )

	RegisterCheckFunctionRequiredKeys(
		FUNCTION RegisterAdd
		KEYS NAME KEY VALUE
		VERBATIM TRUE
	)

	set(reg_path HKEY_CURRENT_USER\\Software\\Kitware\\CMake\\Packages\\${RegisterAdd_NAME})
	IF (WIN32)
		EXECUTE_PROCESS (
			COMMAND reg add ${reg_path} /v ${RegisterAdd_KEY} /d ${RegisterAdd_VALUE} /t REG_SZ /f
			RESULT_VARIABLE RT
			ERROR_VARIABLE  ERR
			OUTPUT_QUIET
		)

		IF (RT EQUAL 0)
			MESSAGE (STATUS "\t- key [" ${RegisterAdd_KEY} "] added to register with value: " ${RegisterAdd_VALUE})
		ELSE ()
			STRING (STRIP "${ERR}" ERR)
			MESSAGE (STATUS "Register: Failed to add registry entry: ${ERR}")
		ENDIF ()
	ENDIF (WIN32)
	
	message(STATUS "RegisterAdd macro done...\n")
	

ENDFUNCTION (RegisterAdd)

################################################################################################

FUNCTION (RegisterGet)

	message(STATUS "")	
	message(STATUS "RegisterGet macro init")

	set(oneValueArgs NAME KEY RETURN)
	set(multiValueArgs )
	set(options VERBATIM)

    CMAKE_PARSE_ARGUMENTS( RegisterGet "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN} )

	RegisterCheckFunctionRequiredKeys(
		FUNCTION RegisterGet
		KEYS NAME KEY
		VERBATIM TRUE
	)

	set(reg_path HKEY_CURRENT_USER\\Software\\Kitware\\CMake\\Packages\\${RegisterGet_NAME})
	GET_FILENAME_COMPONENT(value "[${reg_path};${RegisterGet_KEY}]" ABSOLUTE)
	set(${RegisterGet_RETURN} ${value} PARENT_SCOPE)

	if(RegisterGet_VERBATIM)
		MESSAGE (STATUS "\t- key [" ${RegisterGet_KEY} "] get value from register: " ${value})
	endif(RegisterGet_VERBATIM)
	
	message(STATUS "RegisterGet macro done...\n")
	

ENDFUNCTION (RegisterGet)