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
	set(multiValueArgs GIT_FOLDERS)
	set(options VERBATIM)

    CMAKE_PARSE_ARGUMENTS( RegisterAdd "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN} )

	RegisterCheckFunctionRequiredKeys(
		FUNCTION RegisterAdd
		KEYS NAME KEY VALUE
		VERBATIM TRUE
	)

	
	message(STATUS "RegisterAdd macro done...\n")
	

ENDFUNCTION (RegisterAdd)