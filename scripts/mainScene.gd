extends Node2D

## Add each playable minigame scene here in the Inspector. The first scene is
## loaded when the hub starts; more can be added without changing this script.
@export var minigame_scenes: Array[PackedScene] = []

@onready var minigame_grid: GridContainer = $MinigameGrid

var current_minigame: Node2D

func _ready() -> void:
	if minigame_scenes.is_empty():
		push_warning("No minigame scenes configured on MainScene.")
		return

	show_minigame(0)

func show_minigame(index: int) -> void:
	if index < 0 or index >= minigame_scenes.size():
		push_error("Minigame index %d is out of range." % index)
		return

	for child in minigame_grid.get_children():
		child.queue_free()

	var minigame_card := PanelContainer.new()
	minigame_card.custom_minimum_size = Vector2(320, 240)
	minigame_grid.add_child(minigame_card)

	var viewport_container := SubViewportContainer.new()
	viewport_container.stretch = true
	minigame_card.add_child(viewport_container)

	var viewport := SubViewport.new()
	viewport.size = Vector2i(320, 240)
	viewport.transparent_bg = true
	viewport_container.add_child(viewport)

	var instance := minigame_scenes[index].instantiate()
	viewport.add_child(instance)
	if instance is Node2D:
		current_minigame = instance
