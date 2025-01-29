extends Node2D

signal keyPressed

var currentButton : Button 

func _ready() -> void:
	keybindButtonSetup($"Keybinds/0")
	keybindButtonSetup($"Keybinds/1")
	keybindButtonSetup($"Keybinds/2")
	keybindButtonSetup($"Keybinds/3")

func StartPressed():
	var path = "res://Scenes/States/PlayState.tscn"
	var scene = load(path)
	scene = scene.instantiate()
	for asset in $".".get_children():
		asset.hide()
		
	$".".add_child(scene)
	
	var songData = {
		"Week" = $".".get_node("Week/LineEdit").text,
		"Song" = $".".get_node("Song/LineEdit").text,
		"Player" = 2
	}
	
	if $".".get_node("LeftSideToggle/CheckBox").button_pressed:
		songData["Player"] = 1
	
	scene.get_node("Scripts").get_node("Conductor").emit_signal("songRequested", songData)

func _input(event: InputEvent) -> void:
	if event is InputEvent and event.is_released():
		$".".emit_signal("keyPressed", event)

func buttonPressed(buttonAsset):
	var key : InputEvent = await $".".keyPressed
	
	while key.as_text().length() > 1:
		key = await $".".keyPressed
	
	buttonAsset.text = key.as_text()
	InputMap.action_erase_events(buttonAsset.name)
	InputMap.action_add_event(buttonAsset.name, key)
	

func keybindButtonSetup(buttonAsset : Button):
	while $'.':
		await buttonAsset.button_up
		buttonPressed(buttonAsset)
	
