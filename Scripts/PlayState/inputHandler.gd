## // SPRITE // ##
extends Node

## // SIGNALS // ##

## // TYPES // ##

"""
t : number, -- TIME OF HIT
d : IntValue, -- LANE NUMBER, 0-3 ENEMY, 4-7 PLR
l : number, -- LENGTH OF THE NOTE IF ITS A HOLE (0 = DEFAULT)
k : string, -- NOTE TYPE
p : SharedTable -- IDK
"""

"""
Data : rawNoteData,
Asset : ImageLabel,
BarAsset : Frame
"""
## // VARIABLES // ##

var inputOffset : float
var conducterObj
var player : int
var playing : bool

var pressedKeys : Array

var offsetRank = [ # 4 - Sick 3 - Good 2 - Ok, 1 - Horrible
	45,
	90,
	135,
	160,
]

var rankPoints = [ # 4 - Sick 3 - Good 2 - Ok, 1 - Horrible
	500,
	354,
	38,
	9
]

var laneToDir = [
	"Left",
	"Down",
	"Up",
	"Right",
	"Left",
	"Down",
	"Up",
	"Right"
]

var rankOffset = 0

@onready var Root = get_parent().get_parent().get_parent()
@onready var UI = Root.get_node("UILock").get_node("UI")
@onready var chartHandler = get_parent().get_node("ChartHandler")
@onready var stageHandler = get_parent().get_node("StageHandler")

## // FUNCTIONS // ##

# Get the rank with the offset
func getRank(offset):
	offset -= self.chartHandler.inputOffset
	for value in offsetRank:
		var rank = offsetRank.find(value)
		if offset <= value + rankOffset:
			return 5 - rank
	return null # Miss

# Creates connections for the chart and initializes the module
func initiateInputs(conducter):
	
	# Init Vars
	self.conducterObj = conducter
	self.player = conducterObj.player
	self.inputOffset = 0
	self.pressedKeys = []
	self.playing = true
	
# Checks if any actions are pressed every frame
func _process(_delta):
	
	for i in range(4):
		if Input.is_action_just_released(str(i)):
			inputEnded(i)
	
	if not self.playing:
		return
	
	for i in range(4):
		if Input.is_action_just_pressed(str(i)):
			inputBegan(i)

## // OBJECT FUNCTIONS // ##

# Pauses the song
func pause(paused):
	self.playing = not paused 
	if pause:
		for i in range(4):
			inputEnded(i)

# Checks to see if a note is valid in the givin lane and handles pressing
func inputBegan(inputLane):
	
	self.pressedKeys.append(inputLane)
	
	var hit = checkHit(inputLane)
	
	var keyLanes : Node2D = UI.get_node("PlayerLanes")
	
	if self.player == 1:
		keyLanes = UI.get_node("EnemyLanes")
	
	if not keyLanes:
		print("LANE NOT FOUND FOR KEY")
		return
		
	var lane : Panel = keyLanes.get_node(str(inputLane))
	var key : AnimatedSprite2D = lane.get_node("Key")
	
	if hit:
		key.play("PressHit")
		stageHandler.emit_signal("noteHitSignal", self.conducterObj.player, laneToDir[inputLane])
	else:
		key.play("Press")
		stageHandler.emit_signal("noteHitSignal", self.conducterObj.player,  laneToDir[inputLane])
	
# Unpresses the key and updates the animation
func inputEnded(inputLane):
	
	if self.pressedKeys.find(inputLane) != -1: # Key is pressed
		
		self.pressedKeys.remove_at(self.pressedKeys.find(inputLane))
		
		var keyLanes : Node2D = UI.get_node("PlayerLanes")
	
		if self.player == 1:
			keyLanes = UI.get_node("EnemyLanes")
			
		var lane : Panel = keyLanes.get_node(str(inputLane))
		var key : AnimatedSprite2D = lane.get_node("Key")
	
		key.play("Idle")
		
		stageHandler.emit_signal("noteEndedSignal", self.conducterObj.player,  laneToDir[inputLane])

# Checks if any notes are able to be pressed
func checkHit(lane):
	
	if self.player == 1:
		lane += 4
	
	var time = self.chartHandler.currentSongPosition
	var notes = self.chartHandler.assetsToMove
	
	var closestMS = 100000
	var closestNote
	
	for note in notes:
		
		if note.Data.d != lane:
			continue
		
		if closestMS > note.Data.t - time:
			closestMS = abs(note.Data.t - time)
			closestNote = note
			
	if closestNote:
		var result = getRank(abs(closestMS))
		
		if result != null:
			
			if not self.conducterObj.util.checkIfLong(closestNote):
				notes.remove_at(notes.find(closestNote))
			self.chartHandler.emit_signal("cleanupNoteRequest", closestNote, true)
			UI.get_node("Score").emit_signal("newScore", result)
			
			return [true, closestNote]
			
	
