#if defined _err_api_included
	#endinput
#endif
#define _err_api_included

/**
	*  This native is for compatibility purpose.
	*  You search for a default string and it will point you to the new one.
	*  Example: →  models/v_ak47.mdl(old string) models/v_m4a1.mdl(new string)
				→ By searching for models/v_ak47.mdl you will get models/v_m4a1.mdl
	*
	*  @param Input            The string that you want to search for.
	*  @param Output           The buffer in which the found string will be saved.  
	*  @return                 -1 on failure, 1 otherwise
*/
native err_find_replaced_string(const Input[], const Output[])

/**
	*  Return replacement type
	*  Check replacement type before using err_find_replaced_string

	*  @return    →  -1 on failure. 
				→  1 for complete replace 
				→  2 for dynamic replace 
				→  3 for both
*/
native err_find_replace_type()
