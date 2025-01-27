## // SPRITE // ##
extends Node

## // SIGNALS // ##

signal songBegan

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

var rankOffset = 0

@onready var Root = get_parent().get_parent().get_parent()
@onready var chartHandler = get_parent().get_node("ChartHandler")

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
	self.inputOffset = 150
	self.pressedKeys = []
	self.playing = true
	
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

func pause(paused):
	self.playing = not paused 

func inputBegan(inputLane):
	
	self.pressedKeys.append(inputLane)
	
	var hit = checkHit(inputLane)
	
	var keyLanes : Node2D = Root.get_node("PlayerLanes")
	
	if self.player == 1:
		keyLanes = Root.get_node("EnemyLanes")
	
	if not keyLanes:
		print("LANE NOT FOUND FOR KEY")
		return
		
	var lane : Panel = keyLanes.get_node(str(inputLane))
	var key : AnimatedSprite2D = lane.get_node("Key")
	
	if hit:
		key.play("PressHit")
	else:
		key.play("Press")
	
func inputEnded(inputLane):
	
	if self.pressedKeys.find(inputLane) != null: # Key is pressed
		
		self.pressedKeys.remove_at(self.pressedKeys.find(inputLane))
		
		var keyLanes : Node2D = Root.get_node("PlayerLanes")
	
		if self.player == 1:
			keyLanes = Root.get_node("EnemyLanes")
			
		var lane : Panel = keyLanes.get_node(str(inputLane))
		var key : AnimatedSprite2D = lane.get_node("Key")
	
		key.play("Idle")
		
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
			
			if closestNote.Data.l == 0:
				notes.remove_at(notes.find(closestNote))
			self.chartHandler.emit_signal("cleanupNoteRequest", closestNote, true)
			return true
