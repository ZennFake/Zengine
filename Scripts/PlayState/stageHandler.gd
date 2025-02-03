## // SPRITE // ##

extends Node

## // SIGNALS // ##

signal noteHitSignal
signal noteEndedSignal

## // TYPES // ##

## // VARIABLES // ##

@onready var root = get_parent().get_parent().get_parent()
@onready var UI = root.get_node("UILock").get_node("UI")
@onready var Camera : Camera2D = root.get_node("Camera2D")

var conductor
var metaData : Dictionary
var stage
var characterList : Dictionary

## // FUNCTIONS // ##

func createPlayer(playerString, characterName):
	var spawn = self.stage.get_node("Spawns").get_node(playerString)
	var characterPathString = "res://Assets/Characters/" + characterName + "/Character.tscn"
	print("res://Assets/Characters/" + characterName + "/Character.tscn")
	
	characterPathString = load(characterPathString)
	var character = characterPathString.instantiate()
	
	spawn.add_child(character)
	character.position = spawn.position
	
	if playerString == "p2":
		character.get_node("Sprite").flip_h = not character.get_node("Sprite").flip_h
	
	self.characterList[playerString] = {
		notePressing = false,
		keysPressing = [],
		sprite = character
	}
	

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
	
	self.characterList = {}
	
	if self.metaData.has("p1"):
		createPlayer("p1", self.metaData["p1"])
		
	createPlayer("p2", self.metaData["p2"])
	
	
func beatChanged(beatMajor, beat):
	# UI Beat
	self.UI.get_node("BumpAnimator").stop()
	if beatMajor:
		self.UI.get_node("BumpAnimator").play("BumpIntense")
	else:
		self.UI.get_node("BumpAnimator").play("BumpBasic")
	
	# Camera Beat
	
	var cameraTween = get_tree().create_tween()
	cameraTween.tween_property(Camera, "zoom", Vector2(1.05, 1.05), 0)
	cameraTween.tween_property(Camera, "zoom", Vector2.ONE, 1)
	cameraTween.play()
	
	# Character Bot
	
	for playerString in characterList:
		if characterList[playerString]["notePressing"]:
			continue
		var character = characterList[playerString]["sprite"]
		character.get_node("Sprite").stop()
		character.get_node("Sprite").play("Idle")

func noteHit(player, Direction):
	
	var string = "p" + str(player)
	
	if not characterList.has(string):
		print("CHARACTER NOT FOUND")
		return
	
	characterList[string]["sprite"].get_node("Sprite").stop()
	characterList[string]["sprite"].get_node("Sprite").play(Direction)
	characterList[string]["notePressing"] = true
	characterList[string]["keysPressing"].append(Direction)

func noteEnded(player, Direction):
	
	var string = "p" + str(player)
	
	if not characterList.has(string):
		print("CHARACTER NOT FOUND")
		return
		
	characterList[string]["keysPressing"].remove_at(characterList[string]["keysPressing"].find(Direction))
	if len(characterList[string]["keysPressing"]) == 0:
		characterList[string]["notePressing"] = false
	

## // OBJECT FUNCTIONS // ##
