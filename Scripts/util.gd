## // SPRITE // ##
extends Node

## // SIGNALS // ##

## // VARIABLES // ##

## // FUNCTIONS // ##

static func readJson(jsonFile : String):
	var file = jsonFile
	var json_as_text = FileAccess.get_file_as_string(file)
	var json_as_dict = JSON.parse_string(json_as_text)
	
	if json_as_dict:
		return json_as_dict
