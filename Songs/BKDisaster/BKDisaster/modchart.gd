## // CLASS // ##
extends Node

## // VARIABLES // ##

static var PlayState : Node
static var Root : Node2D
static var stage : Node2D


## // FUNCTIONS // ##
static func Loaded(conductorObject):
	print("Mod chart loaded")
	
	PlayState = conductorObject.get_parent().get_node("PlayState")
	Root = conductorObject.get_parent().get_parent()
	

static func Started():
	# Connect Beat
	
	PlayState.connect("Beat", Beat)
	
	stage = Root.get_node("Stage")
	
static func Beat(beatBig, Beat, _c):
	pass
	
