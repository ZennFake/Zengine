## // SPRITE // ##

extends Node

## // SIGNALS // ##

## // TYPES // ##

## // VARIABLES // ##

@onready var root = get_parent().get_parent().get_parent()
@onready var UI = root.get_node("UILock").get_node("UI")

var conductor
var metaData
var stage

## // FUNCTIONS // ##

# Starts the stage manager
func startSong(conductorObject):
	# Init vars
	self.conductor = conductorObject
	self.metaData = self.conductor["meta"]
	
	var stageString : String = self.metaData["stage"]
	
	var stageWeek = stageString.split("/")
	var stagePath = "res://Assets/Object Scenes/Stages/" + stageWeek[0] + "/" + stageWeek[1] + ".tscn"
	
	var packedStageScene : PackedScene = load(stagePath)
	
	self.stage = packedStageScene.instantiate()
	
	root.add_child(self.stage)
	
	
	
	
func beatChanged(beatMajor, beat):
	self.UI.get_node("BumpAnimator").stop()
	if beatMajor:
		self.UI.get_node("BumpAnimator").play("BumpIntense")
	else:
		self.UI.get_node("BumpAnimator").play("BumpBasic")

## // OBJECT FUNCTIONS // ##
