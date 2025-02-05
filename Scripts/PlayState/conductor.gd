## // SPRITE // ##
extends Node

## // SIGNALS // ##

signal songRequested
signal songBegan
signal songEnded

## // VARIABLES // ##

var songDataPath : String
var songData : Dictionary
var chartData : Dictionary
var player : int
var songPlaying : bool
var meta : Dictionary
var timeline : Array
var bpm : int
var beat : int
var msPerBeat : float
var deltaSinceLastBeat : float
var majorBeatTime : int
var songInfo
var style

var songTracks : Dictionary
var events : Array

## // SCRIPTS // ##
@onready var root = get_parent().get_parent()
@onready var playState = get_parent().get_node("PlayState")
var UI 

@onready var util = get_parent().get_node("Util")
@onready var chartHandler = playState.get_node("ChartHandler")
@onready var inputHandler = playState.get_node("InputHandler")
@onready var stageHandler = playState.get_node("StageHandler")

var timebarHandler

## // FUNCTIONS // ##

# Finds the song in the songs folder and loads the chart and songs
func _on_song_requested(SongInfo):
	
	print("Song request created, initiating conductor")
	
	# Init Vars
	self.songInfo = SongInfo
	self.songDataPath = "res://Songs/" + SongInfo["Week"] + "/" + SongInfo["Song"] + "/Song.json"
	self.player = SongInfo["Player"]
	
	# Setup data
	
	self.songData = util.readJson(self.songDataPath)
	self.meta = self.songData["meta"]
	self.timeline = self.meta["timeline"]
	self.style = self.meta["style"]
	
	# Set style
	
	self.UI = updateStyle(self.style).get_node("UI")
	root.set_meta("Style", self.style)
	
	# return
	
	self.timebarHandler = UI.get_node("Timebar")
	self.chartData = util.readJson(self.songData["Chart Data"])
	self.events = self.chartData["events"] 
	
	self.bpm = 0
	self.msPerBeat = 0
	self.deltaSinceLastBeat = 0
	self.majorBeatTime = 4
	self.beat = 0
	
	self.loadMusic()
	playState.emit_signal("Initiate", self)
	
	#await self.stageHandler.loaded
	
	self.emit_signal("songBegan")
	
	await self.songTracks.values()[0].finished
	
	$".".emit_signal("songEnded")
	
## // OBJECT FUNCTION // ##

# Adds the ui in the style selected
func updateStyle(style):
	var path = "res://Assets/Object Scenes/Playstate/Styles/" + style
	print(path)
	if false: # MAKE CHECK LATER
		print("STYLE NOT FOUND")
		path = "res://Assets/Object Scenes/Playstate/Styles/funkin/"
	
	var scenePath = path + "/playstateUI.tscn"
	var scene = load(scenePath)
	scene = scene.instantiate()
	scene.name = "UILock"
	root.add_child(scene)
	
	return scene
	
# Updates the time of the timebar every frame
func _process(delta: float):
	if self.songPlaying:
		timebarHandler.emit_signal("updateTime", self.songTracks.values()[0].get_playback_position(), self.songTracks.values()[0].stream.get_length())
		
		# Check for timeline events
		for time in self.timeline:
			if time["t"] < self.chartHandler["currentSongPosition"]:
				self.bpm = time["bpm"] # Set values for the timeline event
				self.msPerBeat = (60 / time["bpm"]) * 1000
				
				self.timeline.erase(time)
				break # We can skip because we have the one for the current timestamp
				
		self.deltaSinceLastBeat += delta * 1000
		if self.deltaSinceLastBeat >= self.msPerBeat:
			self.deltaSinceLastBeat = 0
			self.beat += 1
			
			self.playState.emit_signal("Beat", int(self.beat) % self.majorBeatTime == 0, self.beat)

# Runs through the song data and loads them as an AudioStream
func loadMusic():
	
	var songTracks = self.songData["Audio Tracks"]
	
	for trackName in songTracks:
		var trackPath = songTracks[trackName]
		
		var songData = load(trackPath)
		var songObject = AudioStreamPlayer2D.new()
		
		songObject.stream = songData
		songObject.panning_strength = 0
		songObject.max_distance = 999999
		add_child(songObject)
		
		self.songTracks[trackName] = songObject

# Pauses the song stream
func pauseMusic(paused):
	self.songPlaying = not paused
	for trackName in self.songTracks:
		var songObject : AudioStreamPlayer2D = self.songTracks[trackName]
		
		songObject.stream_paused = paused

# Runs all music and starts running the chart 
func songStarted():
	
	print("SONG BEGAN")
	
	# Start Music
	for trackName in self.songTracks:
		var songObject : AudioStreamPlayer2D = self.songTracks[trackName]
		
		songObject.play()
	
	# Initiate play state modules
	playState.emit_signal("Start", self)
	
	self.songPlaying = true
