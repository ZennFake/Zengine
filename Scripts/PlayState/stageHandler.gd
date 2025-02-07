## // SPRITE // ##

extends Node

## // SIGNALS // ##

@warning_ignore("unused_signal")
signal noteHitSignal
@warning_ignore("unused_signal")
signal noteEndedSignal
@warning_ignore("unused_signal")
signal focusCamSignal
@warning_ignore("unused_signal")
signal zoomCamSignal

## // TYPES // ##

## // VARIABLES // ##

@onready var root = get_parent().get_parent().get_parent()
var UI
@onready var Camera : Camera2D = root.get_node("Camera2D")

var conductor
var metaData : Dictionary
var stage
var characterList : Dictionary

var bumpZoom = Vector2.ZERO
var baseZoom = Vector2.ONE

## // FUNCTIONS // ##

# Creates a player asset and places them on the node based on the stage.
func createPlayer(playerString, characterName):
	var spawn = self.stage.get_node("Spawns").get_node(playerString)
	var characterPathString = "res://Assets/Characters/" + characterName + "/Character.tscn"
	var offsetPathString = "res://Assets/Characters/" + characterName + "/offsets.json"
	
	
	characterPathString = load(characterPathString)
	var character = characterPathString.instantiate()
	
	spawn.add_child(character)
	character.position = spawn.position
	
	if playerString == "p2":
		character.get_node("Sprite").flip_h = not character.get_node("Sprite").flip_h
	
	self.characterList[playerString] = {
		notePressing = false,
		keysPressing = [],
		sprite = character,
		timesincePress = Time.get_ticks_msec(),
		offsets = {},
		originalPosition = spawn
	}
	
	if FileAccess.file_exists(offsetPathString) == true:
		self.characterList[playerString].offsets = self.conductor.util.readJson(offsetPathString)
	

# Starts the stage manager
func startSong(conductorObject):
	# Init vars
	self.UI =  root.get_node("UILock").get_node("UI")
	self.conductor = conductorObject
	self.metaData = self.conductor["meta"]
	
	var stageString : String = self.metaData["stage"]
	
	var stageWeek = stageString.split("/")
	var stagePath = "res://Assets/Stages/" + stageWeek[0] + "/" + stageWeek[1] + ".tscn"
	
	var packedStageScene : PackedScene = load(stagePath)
	
	self.stage = packedStageScene.instantiate()
	
	self.stage.name = "Stage"
	
	root.add_child(self.stage)
	
	self.characterList = {}
	
	if self.metaData.has("p1"):
		createPlayer("p1", self.metaData["p1"])
	
	
	if self.metaData.has("p2"):
		createPlayer("p2", self.metaData["p2"])
	
	
# Resets character idles and makes the screen bump
func beatChanged(beatMajor, beat):
	# UI Beat
	self.UI.get_node("BumpAnimator").stop()
	if beatMajor:
		self.UI.get_node("BumpAnimator").play("BumpIntense")
	else:
		self.UI.get_node("BumpAnimator").play("BumpBasic")
		
	# Camera Beat
	
	var strength = 0.012
	
	if beatMajor:
		strength = 0.03
	
	var cameraTween = get_tree().create_tween()
	cameraTween.set_ease(Tween.EASE_OUT)
	cameraTween.set_trans(Tween.TRANS_CUBIC)
	cameraTween.tween_property(self, "bumpZoom", Vector2(strength, strength), 0)
	cameraTween.tween_property(self, "bumpZoom", Vector2.ZERO, 1)
	cameraTween.play()
	
	# Character Bot
	
	for playerString in characterList:
		if characterList[playerString]["notePressing"]:
			continue
		if Time.get_ticks_msec() - characterList[playerString]["timesincePress"] < 300:
			continue # Beat too close
		var character = characterList[playerString]["sprite"]
		character.get_node("Sprite").stop()
		playAnimation(characterList[playerString], "idle")

# Makes the player animate based off of the direction hit
func noteHit(player, Direction):
	
	var string = "p" + str(player)
	
	if not characterList.has(string):
		return
	
	characterList[string]["sprite"].get_node("Sprite").stop()
	playAnimation(characterList[string], Direction)
	characterList[string]["timesincePress"] = Time.get_ticks_msec()
	characterList[string]["notePressing"] = true
	characterList[string]["keysPressing"].append(Direction)

# Stops the animation
func noteEnded(player, Direction):
	
	var string = "p" + str(player)
	
	if not characterList.has(string):
		return
		
	characterList[string]["keysPressing"].remove_at(characterList[string]["keysPressing"].find(Direction))
	if len(characterList[string]["keysPressing"]) == 0:
		characterList[string]["notePressing"] = false
		

# Focuses the camera based off of the event value
func FocusCamera(v):
	v = v["char"]
	var characterString = "p"
	if v == 0:
		characterString += "2"
	else:
		characterString += "1"
	
	if not characterList.has(characterString):
		return
	
	var characterAsset = characterList[characterString]["sprite"]
	
	var cameraTween = get_tree().create_tween()
	cameraTween.set_ease(Tween.EASE_OUT)
	cameraTween.set_trans(Tween.TRANS_EXPO)
	cameraTween.tween_property(Camera, "offset", characterAsset.position - Vector2(0, 300), 2)
	cameraTween.play()

# Zooms the camera in based off of the event
func ZoomCamera(v):
	var newZoom = v["zoom"]
	var speed = v["duration"]
	var ease = v["ease"]
	
	var cameraTween = get_tree().create_tween().set_parallel(true)
	cameraTween.set_ease(Tween.EASE_IN_OUT)
	cameraTween.set_trans(Tween.TRANS_ELASTIC)
	cameraTween.tween_property(self, "baseZoom", Vector2(newZoom, newZoom), speed)
	cameraTween.play()

# Updates the camera zoom with the new variables for the zoom.
func _process(delta: float) -> void:
	Camera.zoom = baseZoom + bumpZoom
	
func playAnimation(playerDict,animationName):
	
	if playerDict.offsets != {}: # Offsets found
		var offsetAnimation = playerDict.offsets["animations"]
		
		for offset in offsetAnimation:
			if offset.name == animationName: # Animation found
				offsetAnimation = offset
				break
		
		if not offsetAnimation:
			playerDict.sprite.get_node("Sprite").play(animationName)
			return false
		else:
			playerDict.sprite.get_node("Sprite").play(animationName)
			playerDict.sprite.position = playerDict.originalPosition.position + Vector2(-offsetAnimation.offsets[0], -offsetAnimation.offsets[1])
			
			return true
	else:
		playerDict.sprite.get_node("Sprite").play(animationName)
		return false
	
## // OBJECT FUNCTIONS // ##
