## // CLASS // ##

extends Panel

## // SIGNAL // ##

signal enterPressed
signal openMenuS

## // VARIABLES // ##

var pauseOptions = {
	"RESUME" = Unpause,
	"RESTART SONG" = nothing,
	"CHANGE DIFFICULTY" = nothing,
	"SETTINGS" = nothing,
	"EXIT TO MENU" = Exit
}
var items = [
	
]

var currentOption = 0
var menuOpen = true
var pauseHandler

## // FUNCTIONS // ##

func _input(event: InputEvent):
	if event.is_action_pressed("Pause"):
		# run function
		
		items[currentOption][0].call()
	elif event.is_action_pressed("MenuDown"):
		if currentOption + 1 > len(items) - 1:
			currentOption = 0
		else:
			currentOption += 1
		updateSelection()
	elif event.is_action_pressed("MenuUp"):
		if currentOption - 1 < 0:
			currentOption = len(items) - 1
		else:
			currentOption -= 1
		updateSelection()

func updateSelection():
	playScroll()
	var tween = $'.'.create_tween().set_parallel(true)
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_EXPO)
	tween.tween_property($"ScrollContainer", "scroll_vertical", items[currentOption][1].position.y, 0.5)
	for content in $"ScrollContainer/BoxContainer".get_children():
		if items[currentOption][1] == content:
			tween.tween_property(content, "modulate", Color(1, 1, 1), 0.3)
		else:
			tween.tween_property(content, "modulate", Color(0.5, 0.5, 0.5), 0.3)
	tween.play()

func createButton(option):
	
	var newContainer : Panel = $ScrollContainer/BoxContainer/ContentHolderBase.duplicate()
	
	newContainer.name = option
	newContainer.visible = true
	newContainer.get_node("Text").text = option
	newContainer.modulate = Color(0.5, 0.5, 0.5)
	$"ScrollContainer/BoxContainer".add_child(newContainer)
	
	items.append([pauseOptions[option], newContainer])


func Initiate(pauseHandlerrea):
	
	pauseHandler = pauseHandlerrea
	
	for option in pauseOptions:
		
		createButton(option)
		
	updateSelection()
	
func playScroll():
	$'ScrollMenu'.play()

func playBack():
	$'CancelMenu'.play()


func Unpause():
	playBack()
	menuOpen = false
	pauseHandler.emit_signal("Unpause")

func Exit():
	playBack()
	menuOpen = false
	pauseHandler.emit_signal("Unpause")
	pauseHandler.get_parent().get_parent().get_node("Conductor").emit_signal("songEnded")

func nothing():
	pass
