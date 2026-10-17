extends Node2D

## Add playable minigame scenes here in the Inspector.
@export var minigame_scenes: Array[PackedScene] = []

const MINIGAME_CARD_SCENE: PackedScene = preload("res://scenes/minigame_card.tscn")

@onready var minigame_grid: GridContainer = $MinigameGrid
@onready var chauchas_progress: ProgressBar = $ProgressBar

func _ready() -> void:
	if minigame_scenes.is_empty():
		push_warning("No minigame scenes configured on MainScene.")
		return

	for minigame_scene in minigame_scenes:
		var minigame_card := MINIGAME_CARD_SCENE.instantiate()
		minigame_card.connect("completed", Callable(chauchas_progress, "increase_money"))
		minigame_grid.add_child(minigame_card)
		minigame_card.call("setup", minigame_scene)
