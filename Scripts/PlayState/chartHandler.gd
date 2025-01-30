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

# Sets up song variables and runs the chart
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

# Start the song
func _on_song_began():
	self.songRunning = true

# Updates the chart every frame
func _process(dt):
	if self.songRunning:
		self.updateChart(dt)

## // OBJECT FUNCTIONS // ##

func handlePause(paused):
	self.songRunning = not paused

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

# Checks if a note is valid and on screen
func checkIfNoteIsValid(noteAssetObject):
	if not is_instance_valid(noteAssetObject.Asset):
		if not is_instance_valid(noteAssetObject.BarAsset):
			return false
		else:
			return false
	else:
		return true

# Removes an enemy note when it hits the key.
func handleEnemyNote(noteAssetObject : Dictionary):
	
	# Get the notes lane
	var keyLanes : Node2D = Root.get_node("PlayerLanes")
	
	if self.conducterObj.player == 2:
		keyLanes = Root.get_node("EnemyLanes")
	
	if not keyLanes:
		print("LANE NOT FOUND FOR KEY")
		return
		
	var laneInput = noteAssetObject.Data.d
	
	if self.conducterObj.player == 2:
		laneInput -= 4
	
	# Get the lanes key for animation
	var lane : Panel = keyLanes.get_node(str(laneInput))
	var key : AnimatedSprite2D = lane.get_node("Key")
	
	# Play a hit
	key.play("PressHit")
	
	# Cleanup and unpressing
	if noteAssetObject.Data.l == 0: # Normal note
		self.assetsToMove.remove_at(self.assetsToMove.find(noteAssetObject))
		cleanupNote(noteAssetObject, true)
		await get_tree().create_timer(0.1).timeout # wait 0.1 seconds to clean animation
		key.play("Idle")
	else: # Bar note
		cleanupNote(noteAssetObject, true)
		await get_tree().create_timer(noteAssetObject.Data.l / 1000).timeout # wait the length of the note seconds to clean animation
		key.play("Idle")

# Removes the note from the screen and moves bars to the bar frame
func cleanupNote(noteAsset, pressed = false):
	if not pressed:
		self.assetsToMove.remove_at(self.assetsToMove.find(noteAsset))
		
	if noteAsset.BarAsset != null:
		if pressed:
			noteAsset.Asset.visible = false
			noteAsset.BarAsset.reparent(noteAsset.BarAsset.get_parent().get_parent().get_node("BarHolder"))
		else:
			noteAsset.Asset.queue_free()
			noteAsset.BarAsset.queue_free()
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
		
		# Check for enemy notes
		
		if note.Data.d > 3 and self.conducterObj.player == 2 or note.Data.d <= 3 and self.conducterObj.player == 1: # In enemy lane
			if note.Data.t <= self.currentSongPosition and checkIfNoteIsValid(note):
				if note.Data.l > 0:
					if note.Asset.visible != false: # Long note isnt pressed
						handleEnemyNote(note)
				else:
					handleEnemyNote(note)
				
			
		# Go back to note handling
		
		if note.Data.l > 0: #Bar note
			if not note.BarAsset: # Create a bar for the note
				note.BarAsset = note.Asset.get_parent().get_parent().get_node("Bar").duplicate() # Get the lane the note is in and copy its bar asset
				
				note.Asset.get_parent().add_child(note.BarAsset)
				note.BarAsset.visible = true
				
			note.BarAsset.position = Vector2(51.655, note.Asset.position.y)
			
			if note.BarAsset.get_parent().name == "BarHolder": # Is Pressed
				note.Asset.position.y += 143.42 # Account for clip offset
			
			note.BarAsset.size = Vector2(55, (self.getNoteY(note.Data.t + note.Data.l)  * 1080) - note.Asset.position.y)
			note.BarAsset.get_node("BarEnding").position = Vector2(1, note.BarAsset.size.y)
			
			if note.BarAsset.get_node("BarEnding").position.y / 1080 < -0.1:
				self.cleanupNote(note)
			
			continue
		
		if note.Asset.position.y / 1080 < -0.1:
			self.cleanupNote(note)
		

# Calculates the notes Y position
func getNoteY(timePosition):
	return (self.pMS * (self.currentSongPosition - timePosition - self.visualOffset) * self.data.scrollSpeed * -1 + 130) / 1080
