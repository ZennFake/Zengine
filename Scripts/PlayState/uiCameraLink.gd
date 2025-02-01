## // SPRITE // ##

extends CanvasGroup

## // SIGNALS // ##

## // TYPES // ##

## // VARIABLES // ##

## // FUNCTIONS // ##

func _process(delta):
	$".".position = get_parent().get_node("Camera2D").offset - Vector2(960, 540)
	var x = (get_parent().get_node("Camera2D").zoom).x - 1
	var y = (get_parent().get_node("Camera2D").zoom).y - 1
	$".".scale = Vector2(0.97 - x, 0.97 - y)
	
## // OBJECT FUNCTIONS // ##
