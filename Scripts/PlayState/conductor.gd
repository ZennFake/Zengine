## // SPRITE // ##
extends Node

## // SIGNALS // ##

signal songRequested
signal songBegan

## // VARIABLES // ##

var songDataPath : String
var songData : Dictionary
var chartData : Dictionary
var player : int

var songTracks : Dictionary

## // SCRIPTS // ##
@onready var playState = get_parent().get_node("PlayState")

@onready var util = get_parent().get_node("Util")
@onready var chartHandler = playState.get_node("ChartHandler")
@onready var inputHandler = playState.get_node("InputHandler")

## // FUNCTIONS // ##

# Finds the song in the songs folder and loads the chart and songs
func _on_song_requested(Week, Song):
	
	print("Song request created, initiating conductor")
	
	# Init Vars
	
	self.songDataPath = "res://Songs/" + Week + "/" + Song + "/Song.json"
	self.player = 2
	
	# Setup data
	
	self.songData = util.readJson(self.songDataPath)
	print(self.songData["Chart Data"])
	
	self.chartData = util.readJson(self.songData["Chart Data"])
	
	self.loadMusic()
	chartHandler.emit_signal("chartRequest", self)
	
	self.emit_signal("songBegan")
	
	
	
## // OBJECT FUNCTION // ##

# Runs through the song data and loads them as an AudioStream
func loadMusic():
	
	var songTracks = self.songData["Audio Tracks"]
	
	for trackName in songTracks:
		var trackPath = songTracks[trackName]
		
		var songData = load(trackPath)
		var songObject = AudioStreamPlayer2D.new()
		
		songObject.stream = songData
		add_child(songObject)
		
		self.songTracks[trackName] = songObject

func pauseMusic(paused):
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
	chartHandler.emit_signal("songBegan")
	inputHandler.emit_signal("songBegan", self)
