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

var songTracks : Dictionary

## // SCRIPTS // ##
@onready var playState = get_parent().get_node("PlayState")

@onready var util = get_parent().get_node("Util")
@onready var chartHandler = playState.get_node("ChartHandler")
@onready var inputHandler = playState.get_node("InputHandler")
@onready var timebarHandler = get_parent().get_parent().get_node("Timebar")

## // FUNCTIONS // ##

# Finds the song in the songs folder and loads the chart and songs
func _on_song_requested(SongInfo):
	
	print("Song request created, initiating conductor")
	
	# Init Vars
	
	self.songDataPath = "res://Songs/" + SongInfo["Week"] + "/" + SongInfo["Song"] + "/Song.json"
	self.player = SongInfo["Player"]
	self.songPlaying = true
	
	# Setup data
	
	self.songData = util.readJson(self.songDataPath)
	print(self.songData["Chart Data"])
	
	self.chartData = util.readJson(self.songData["Chart Data"])
	
	self.loadMusic()
	chartHandler.emit_signal("chartRequest", self)
	
	self.emit_signal("songBegan")
	
	await self.songTracks.values()[0].finished
	
	$".".emit_signal("songEnded")
	
## // OBJECT FUNCTION // ##

func _process(delta: float):
	if self.songPlaying:
		timebarHandler.emit_signal("updateTime", self.songTracks.values()[0].get_playback_position(), self.songTracks.values()[0].stream.get_length())

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
