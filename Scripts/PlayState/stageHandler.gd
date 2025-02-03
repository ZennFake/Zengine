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

func createPlayer(playerString, characterName):
	var spawn = self.stage.get_node("Spawns").get_node(playerString)
	var characterPathString = "res://Assets/Characters/" + characterName + "/Character.tscn"
	print("res://Assets/Characters/" + characterName + "/Character.tscn")
	
	characterPathString = load(characterPathString)
	var character = characterPathString.instantiate()
	
	spawn.add_child(character)
	character.position = spawn.position
	
	

# Starts the stage manager
func startSong(conductorObject):
	# Init vars
	self.conductor = conductorObject
	self.metaData = self.conductor["meta"]
	
	var stageString : String = self.metaData["stage"]
	
	var stageWeek = stageString.split("/")
	var stagePath = "res://Assets/Stages/" + stageWeek[0] + "/" + stageWeek[1] + ".tscn"
	
	var packedStageScene : PackedScene = load(stagePath)
	
	self.stage = packedStageScene.instantiate()
	
	root.add_child(self.stage)
	
	createPlayer("p2", self.metaData["p2"])
	
	
func beatChanged(beatMajor, beat):
	self.UI.get_node("BumpAnimator").stop()
	if beatMajor:
		self.UI.get_node("BumpAnimator").play("BumpIntense")
	else:
		self.UI.get_node("BumpAnimator").play("BumpBasic")

## // OBJECT FUNCTIONS // ##
