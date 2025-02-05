extends Node2D

signal keyPressed

var currentButton : Button 
var currentDifficulty = "hard"

func _ready() -> void:
	keybindButtonSetup($"Keybinds/0")
	keybindButtonSetup($"Keybinds/1")
	keybindButtonSetup($"Keybinds/2")
	keybindButtonSetup($"Keybinds/3")
	
	checkIfValid(true)
	
	$Week/LineEdit.connect("text_changed", checkIfValid)
	$Song/LineEdit.connect("text_changed", checkIfValid)

func StartPressed():
	var path = "res://Scenes/States/PlayState.tscn"
	var scene = load(path)
	scene = scene.instantiate()
	for asset in $".".get_children():
		if asset.has_method("hide"):
			asset.hide()
		
	$".".add_child(scene)
	
	var songData = {
		"Week" = $".".get_node("Week/LineEdit").text,
		"Song" = $".".get_node("Song/LineEdit").text,
		"Player" = 2,
		"Difficulty" = currentDifficulty
	}
	
	if $".".get_node("LeftSideToggle/CheckBox").button_pressed:
		songData["Player"] = 1
	
	scene.get_node("Scripts").get_node("Conductor").emit_signal("songRequested", songData)
	
	await scene.get_node("Scripts").get_node("Conductor").songEnded
	
	scene.queue_free()
	
	for asset in $".".get_children():
		if asset.has_method("show"):
			asset.show()

func buttonHandler(button):
	while button.get_parent() != null:
		await button.pressed
		currentDifficulty = button.name

func checkIfValid(_a):
	var SongInfo = {
		"Week" = $".".get_node("Week/LineEdit").text,
		"Song" = $".".get_node("Song/LineEdit").text,
		"Player" = 2
	}
	for node in $Difficulty/Holder.get_children():
			if node.name != "Base":
				node.queue_free()
	
	if ResourceLoader.exists("res://Songs/" + SongInfo["Week"] + "/" + SongInfo["Song"] + "/Song.json"):
		# get difficulties
		
		var loadedFile = $Util.readJson("res://Songs/" + SongInfo["Week"] + "/" + SongInfo["Song"] + "/Song.json")
		loadedFile = loadedFile["meta"]
		
		var curX = 30
		var mult = 160
				
		if loadedFile.has("difficulties"):
			$"Difficulty/Waiting".visible = false
			for difficulty in loadedFile["difficulties"]:
				var index = loadedFile["difficulties"].find(difficulty)
				var baseClone : Button = $"Difficulty/Holder/Base".duplicate()
				
				baseClone.text = difficulty
				baseClone.position = Vector2(curX + (mult * index), 535)
				
				baseClone.name = difficulty
				baseClone.visible = true
				$"Difficulty/Holder".add_child(baseClone)
				buttonHandler(baseClone)
					
		else:
			
			$"Difficulty/Waiting".visible = true
			currentDifficulty = null
	else:
		
		$"Difficulty/Waiting".visible = true
		currentDifficulty = null
		
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
	
