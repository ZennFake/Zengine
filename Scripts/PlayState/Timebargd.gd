## // SPRITE // ##
extends Node2D

## // SIGNALS // ##

signal updateTime

## // FUNCTIONS // ##

func newTime(timeMS : float, songLength):
	var timeSeconds = round(timeMS)
	var minutes = floor(timeSeconds / 60)
	timeSeconds -= minutes * 60
	
	var songLengthSeconds = round(songLength)
	var songLengthMinutes = floor(songLengthSeconds / 60)
	songLengthSeconds -= songLengthMinutes * 60
	
	var finalLabel = str(minutes)
	if timeSeconds < 10:
		finalLabel += ":0" + str(timeSeconds)
	else :
		finalLabel += ":" + str(timeSeconds)
	finalLabel += "/" + str(songLengthMinutes)
	if songLengthSeconds < 10:
		finalLabel += ":0" + str(songLengthSeconds)
	else :
		finalLabel += ":" + str(songLengthSeconds)
	
	var ratio = timeMS / songLength
	
	$TimebarMain/Timebar/Inner.size = Vector2($TimebarMain/Timebar.size.x * ratio, $TimebarMain/Timebar.size.y)
	$TimebarMain/Timebar/Label.text = finalLabel
