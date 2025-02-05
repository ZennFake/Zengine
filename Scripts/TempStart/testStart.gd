extends Node2D

signal keyPressed

var currentButton : Button 
var currentDifficulty = "hard"

func _ready() -> void:
	var list = DirAccess.get_directories_at("res://Songs/")
	for folder in list:
		makeWeekButton(folder)
	
	keybindButtonSetup($"Keybinds/0")
	keybindButtonSetup($"Keybinds/1")
	keybindButtonSetup($"Keybinds/2")
	keybindButtonSetup($"Keybinds/3")
	
	checkIfValid(true)
	
	$Week/LineEdit.connect("text_changed", checkIfValid)
	$Song/LineEdit.connect("text_changed", checkIfValid)

func makeWeekButton(week):
	var clone = $WeekPicker/ScrollContainer/VBoxContainer/WeekBase.duplicate()
	clone.name = "WeekButtonClone"
	clone.text = week
	clone.visible = true
	$WeekPicker/ScrollContainer/VBoxContainer.add_child(clone)
	while $'.':
		await clone.button_up
		$Week/LineEdit.text = week
		updateSongSelection(week)
	
func updateSongSelection(week):
	for child in $SongSelection/ScrollContainer/VBoxContainer.get_children():
		if child.name != "WeekBase":
			child.queue_free()
	
	var list = DirAccess.get_directories_at("res://Songs/" + week)
	for folder in list:
		makeSongButton(folder)
		
func makeSongButton(song):
	var clone = $SongSelection/ScrollContainer/VBoxContainer/WeekBase.duplicate()
	clone.name = "WeekButtonClone"
	clone.text = song
	clone.visible = true
	$SongSelection/ScrollContainer/VBoxContainer.add_child(clone)
	while $'.':
		await clone.button_up
		$Song/LineEdit.text = song
		checkIfValid(true)

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
	
