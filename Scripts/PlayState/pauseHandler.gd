## // SPRITE // ##
extends Node

## // SIGNALS // ##

signal songBegan

## // TYPES // ##

## // VARIABLES // ##

@onready var PlayStateParent = get_parent()

var paused = false
var currentLoading : CanvasLayer

## // FUNCTIONS // ##

# Loads the pause screen into the scene
func loadPauseScreen():
	var path = "res://Scenes/States/Paused.tscn"
	var packed : PackedScene = load(path)
	var scene = packed.instantiate()
	
	PlayStateParent.get_parent().get_parent().add_child(scene)
	scene.get_node("PauseAnimation").play("Paused")
	currentLoading = scene

# Checks if pause was pressed
func _process(_delta):
	if Input.is_action_just_pressed("Pause"):
		paused = not paused
		PlayStateParent.emit_signal("Pause", paused)
		if paused:
			loadPauseScreen()
		else:
			currentLoading.queue_free()

## // OBJECT FUNCTIONS // ##
