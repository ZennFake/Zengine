## // SPRITE // ##

extends Node

## // SIGNALS // ##

signal newScore

## // TYPES // ##

## // VARIABLES // ##

# Objects
@onready var Spawn = self.get_node("Spawn")
@onready var root = get_parent().get_parent().get_parent()

# Ranks
var Ranks = [ # 4 - Sick 3 - Good 2 - Ok, 1 - Shit
	"Shit",
	"Bad",
	"Good",
	"Sick",
]

## // FUNCTIONS // ##

# Makes a new score ui
func scoreNew(scoreRank):
	var newRankBase = load("res://Assets/Object Scenes/Playstate/Styles/" + root.get_meta("Style") + "/Rank.tscn")
	newRankBase = newRankBase.instantiate()
	Spawn.add_child(newRankBase)
	newRankBase = newRankBase.get_node("RankSpawn")
	
	var AnimationName = Ranks[scoreRank - 2]
	newRankBase.get_node("BaseRank").play(AnimationName)
	
	var animationPlayer : AnimationPlayer = newRankBase.get_node("ScoreAnimation")
	animationPlayer.play("Spawn")
	
	await animationPlayer.animation_started
	newRankBase.visible = true
	
	await animationPlayer.animation_finished
	newRankBase.get_parent().queue_free()

## // OBJECT FUNCTIONS // ##
