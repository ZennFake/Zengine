## // SPRITE // ##

extends Panel

## // SIGNALS // ##

## // TYPES // ##

## // VARIABLES // ##

@onready var camera : Camera2D = get_parent().get_node("Camera2D")

## // FUNCTIONS // ##

func _process(delta):
	$".".position = camera.offset
	$".".scale = Vector2(1, 1) - (Vector2((camera.zoom.x - 1) / 2, (camera.zoom.y - 1) / 2))
	
## // OBJECT FUNCTIONS // ##
