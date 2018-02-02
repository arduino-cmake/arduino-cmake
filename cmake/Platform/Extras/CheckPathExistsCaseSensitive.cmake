#=============================================================================#
# _CHECK_PATH_EXISTS_CASE_SENSITIVE_BRUTE_FORCE
# [PRIVATE/INTERNAL]
#
# _CHECK_PATH_EXISTS_CASE_SENSITIVE_BRUTE_FORCE(result_var_ absolute_path_)
#
#        result_var_ - A variable in parent scope that is assigned the result
#                      of the check. The result is TRUE if the file 
#                      is found with a case sensitive check, otherwise FALSE.
#        absolute_path_ 
#                    - The absoute path of a file or directory.
#
# Checks if a path exists in a case sensitive fashion.
# This is the brute force version of the check that is used when
# there are no other means available.
#
# This is necessary because CMake's if(EXISTS ...) is not case sensitive
# on Windows (at least not up to CMake version 3.9.6).
#
# Important: Do not use this function directly but prefer to use 
#            _CHECK_PATH_EXISTS_CASE_SENSITIVE
#=============================================================================#
function(_CHECK_PATH_EXISTS_CASE_SENSITIVE_BRUTE_FORCE result_var_ absolute_path_)

   # We recursively traverse the absolute_path_ from its root and
   # check it any path token cannot be found (early exit)

   string(REPLACE "/" ";" path_tokens "${absolute_path_}") 
   
   list(LENGTH path_tokens n_tokens__)
   math(EXPR n_tokens "${n_tokens__} - 1")
   
   set(cur_path "/")
   foreach(id RANGE 0 ${n_tokens})
   
      list(GET path_tokens ${id} cur_token)
      
      if("${cur_token}" STREQUAL "")
         continue()
      endif()
   
      file(GLOB dir_entries RELATIVE "${cur_path}" "${cur_path}*")

      list(FIND dir_entries "${cur_token}" index)
      if(NOT ${index} GREATER -1)
         message("- ${absolute_path_}")
         set(${result_var_} FALSE PARENT_SCOPE)
         return()
      endif()
      
      set(cur_path "${cur_path}${cur_token}/")
   endforeach()
         
   message("+ ${absolute_path_}")
   set(${result_var_} TRUE PARENT_SCOPE)
endfunction()
   
#=============================================================================#
# _CHECK_PATH_EXISTS_CASE_SENSITIVE
# [PRIVATE/INTERNAL]
#
# _CHECK_PATH_EXISTS_CASE_SENSITIVE(result_var_ absolute_path_)
#
#        result_var_ - A variable in parent scope that is assigned the result
#                      of the check. The result is TRUE if the file 
#                      is found with a case sensitive check, otherwise FALSE.
#        absolute_path_ 
#                    - The absoute path of a file or directory.
#
# Checks if a path exists in a case sensitive fashion.
#
# This is necessary because CMake's if(EXISTS ...) is not case sensitive
# on Windows (at least not up to CMake version 3.9.6).
#=============================================================================#
function(_CHECK_PATH_EXISTS_CASE_SENSITIVE result_var_ absolute_path_)
   
   # Important: First check for APPLE as CMAKE_HOST_UNIX reports true even 
   #            if CMAKE_HOST_APPLE is true
   #
   if(CMAKE_HOST_APPLE)
   
      # On MacOS there is no appropriate command that enables a safe check
      # for a path to exist given a case sensitive name. This is because
      # MacOS file systems are mostly case insensitive by default.
      # That's why we fall back to brute force directory comparison.
      #
      _CHECK_PATH_EXISTS_CASE_SENSITIVE_BRUTE_FORCE(tmp_result "${absolute_path_}")
      set(${result_var_} ${tmp_result} PARENT_SCOPE)
      
      return()

   elseif(CMAKE_HOST_UNIX)
   
      if(EXISTS "${absolute_path_}")
         set(${result_var_} TRUE PARENT_SCOPE)
      else()
         set(${result_var_} FALSE PARENT_SCOPE)
      endif()
      
      return()
      
   elseif(CMAKE_HOST_WIN32)
   
      # From this point on, we only deal with Windows
      
      file(TO_NATIVE_PATH "${absolute_path_}" native_path)
      string(REPLACE "/" "\\" native_path "${native_path}")
      
      # Check what is found when a globbing expression is used to 
      # find the file. The output (actual_path) will be the case 
      # sensitive path name or nothing.
      #
      execute_process(
         ERROR_QUIET
         OUTPUT_VARIABLE actual_path
         OUTPUT_STRIP_TRAILING_WHITESPACE
         COMMAND cmd /C dir /S /B "${native_path}" 
      )

      if("${actual_path}" STREQUAL "${native_path}")
         set(${result_var_} TRUE PARENT_SCOPE)
      else()
         set(${result_var_} FALSE PARENT_SCOPE)
      endif()
      
      return()

   endif()
   
   message(FATAL_ERROR "Strange host system")
      
endfunction()