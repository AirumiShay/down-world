extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	GlobalVar.Player = $Player
	GlobalVar.UI = $UI.get_node("UI").get_node("HP_bar")
#	GlobalVar.Level = $UI/UI/Level
	


func _on_SpellTimer_timeout():
	GlobalVar.SpellTime = true # Replace with function body.
