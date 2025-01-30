## // SPRITE // ##

extends Node

## // SIGNALS // ##

signal start

## // TYPES // ##

## // VARIABLES // ##

@onready var stage = get_parent().get_parent().get_parent()
var conductor

## // FUNCTIONS // ##

# Starts the stage manager
func startSong(conductorObject):
	# Init vars
	self.conductor = conductorObject
	
func beatChanged(beatMajor, beat):
	self.stage.get_node("BumpAnimator").stop()
	if beatMajor:
		self.stage.get_node("BumpAnimator").play("BumpIntense")
	else:
		self.stage.get_node("BumpAnimator").play("BumpBasic")

## // OBJECT FUNCTIONS // ##
