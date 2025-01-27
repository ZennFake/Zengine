## // SPRITE // ##
extends Node

## // SIGNALS // ##

signal chartRequest
signal songBegan
signal cleanupNoteRequest

## // TYPES // ##

"""
t : number, -- TIME OF HIT
d : IntValue, -- LANE NUMBER, 0-3 ENEMY, 4-7 PLR
l : number, -- LENGTH OF THE NOTE IF ITS A HOLE (0 = DEFAULT)
k : string, -- NOTE TYPE
p : SharedTable -- IDK
"""

## // VARIABLES // ##

var songData : Dictionary

var pMS : float
var inputOffset : float
var visualOffset : float

var conducterObj

var data : Dictionary
var noteData : Array
var assetsToMove : Array

var songRunning : bool

var currentSongPosition

@onready var Root = get_parent().get_parent().get_parent()

## // FUNCTIONS // ##

func initiateChart(conducter):
	
	# Init Vars
	self.conducterObj = conducter
	self.data = conducter.chartData
		
	self.noteData = self.data["notes"]
	
	self.pMS = 0.45
	self.inputOffset = 25
	self.visualOffset = 20
	
	self.assetsToMove = []
	self.currentSongPosition = 0
	
	return self
	
func _on_song_began():
	self.songRunning = true
	
func _process(dt):
	if self.songRunning:
		self.updateChart(dt)

## // OBJECT FUNCTIONS // ##


## Gets the lane of the note with the given note data
func GetLane(noteData):
	
	var lane = Root.get_node("PlayerLanes").has_node(str(noteData.d))
	
	if not lane:
		lane = Root.get_node("EnemyLanes").get_node(str(noteData.d - 4))
	else:
		lane = Root.get_node("PlayerLanes").get_node(str(noteData.d))
		
	return lane
	
# Creates the notes asset and adds it to the assets to move list
func noteMade(noteData):
	
	# Get Lane
	var lane = GetLane(noteData)
	
	if not lane:
		## NOTE NOT IN A SUPPORTED LANE
		return false
		
	# Clone Asset
	
	var noteBase : AnimatedSprite2D = lane.get_node("NoteBase").duplicate()
	lane.get_node("NoteHolder").add_child(noteBase)
	
	# Asset Setup
	var animationName = ""
	if noteData.d > 3:
		animationName = str(noteData.d - 4)
	else:
		animationName = str(noteData.d)
	
	noteBase.play(animationName)
	
	noteBase.position = Vector2(84, 1080)
	noteBase.visible = true
	
	self.assetsToMove.append({
		Data = noteData,
		Asset = noteBase,
		BarAsset = null
	})
	
func cleanupNote(noteAsset, pressed = false):
	if not pressed:
		self.assetsToMove.remove_at(self.assetsToMove.find(noteAsset))
		
	if noteAsset.BarAsset != null:
		print("todo")
	else:
		noteAsset.Asset.queue_free()

# Goes through all note assets and updates the positions on the screen, ALSO initializes any notes that arent already on screen
func updateChart(dt : float):
	# Convert DT to MS
	dt *= 1000
	
	# Update Song Position
	self.currentSongPosition += dt
	
	for note in self.noteData:
		
		var timePos = note.t
		var y = self.getNoteY(timePos)
		
		if y > -0.1 and y < 1.1: # NOTE IS IN BOUNDS FOR RENDER
			self.noteMade(note)
			
			self.noteData.remove_at(self.noteData.find(note)) # Remove note from the data as we dont need it anymore.
		
	# Update on screen notes
	
	for note in self.assetsToMove:
		
		note.Asset.position = Vector2(84, self.getNoteY(note.Data.t) * 1080)
		
		if note.Asset.position.y / 1080 < -0.1:
			self.cleanupNote(note)
		

# Calculates the notes Y position
func getNoteY(timePosition):
	return (self.pMS * (self.currentSongPosition - timePosition - self.visualOffset) * self.data.scrollSpeed * -1) / 1080	
