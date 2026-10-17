extends Node2D
@onready var tab_scene = preload("res://scenes/Tab.tscn")
var instance = tab_scene.instantiate()
	
func _ready() -> void:
	tab_scene
