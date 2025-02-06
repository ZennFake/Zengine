## // SPRITE // ##
extends Node2D

## // SIGNALS // ##

signal updateScore

## // VARIABLES // ##

@onready var label = $"Label"
var seperator = " | "
var infoTable = {
	"Score" = 0,
	"Combo Breaks" = 0
}

## // FUNCTIONS // ##

func updateScoreF(UpdatedName, UpdatedValue):
	
	infoTable[UpdatedName] = UpdatedValue
	
	var finalString = ""
	
	for Title in infoTable:
		var Value = infoTable[Title]
		
		finalString += Title + ": " + str(Value)
		
		finalString += seperator
		
	finalString = finalString.substr(0, len(finalString) - len(seperator)) # Remove the final seperator
	
	label.text = finalString
	#Updated!
