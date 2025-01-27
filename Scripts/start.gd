extends Node

func _ready():
	
	get_parent().get_node("Conductor").emit_signal("songRequested", "Breaker_Bundle", "Gamebreaker")
