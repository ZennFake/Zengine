## // SPRITE // ##
extends Node

## // SIGNALS // ##

## // VARIABLES // ##

## // FUNCTIONS // ##

# Reads the given json and returns it as a dictionary
static func readJson(jsonFile : String):
	var file = jsonFile
	var json_as_text = FileAccess.get_file_as_string(file)
	var json_as_dict = JSON.parse_string(json_as_text)
	
	if json_as_dict:
		return json_as_dict

# Checks if a note is a bar note.
static func checkIfLong(noteAsset):
	if noteAsset.Data.has("l"):
		if noteAsset.Data["l"] > 0:
			return true
	else:
		return false
	return false
