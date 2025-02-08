## // SPRITE // ##
extends Node

## // SIGNALS // ##

signal songBegan
signal Unpause

## // TYPES // ##

## // VARIABLES // ##

@onready var PlayStateParent = get_parent()

var paused = false
var currentLoading : CanvasLayer
var debounce = false

## // FUNCTIONS // ##

# Loads the pause screen into the scene
func loadPauseScreen():
	var path = "res://Scenes/States/Paused.tscn"
	var packed : PackedScene = load(path)
	var scene = packed.instantiate()
	scene.visible = false
	PlayStateParent.get_parent().get_parent().add_child(scene)
	
	var animator : AnimationPlayer = scene.get_node("PauseAnimation")
	
	animator.play("Paused")
	currentLoading = scene
	currentLoading.get_node("Scrollable").emit_signal("openMenuS", self)

func unpauseS(isReset = false):
	paused = false
	if not isReset:
		PlayStateParent.emit_signal("Pause", paused)
	get_tree().paused = paused
	var animator : AnimationPlayer = currentLoading.get_node("PauseAnimation")
	
	animator.play("Unpause")
	await animator.animation_finished
	debounce = false
	currentLoading.queue_free()
	
# Checks if pause was pressed
func _process(_delta):
	if Input.is_action_just_pressed("Pause"):
		if paused == false and not debounce:
			paused = true
			debounce = true
			get_tree().paused = paused
			PlayStateParent.emit_signal("Pause", paused)
			loadPauseScreen()

## // OBJECT FUNCTIONS // ##
