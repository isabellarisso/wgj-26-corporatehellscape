extends PanelContainer

signal completed(reward: int)

const CARD_SIZE := Vector2(320, 240)
const RESULT_DISPLAY_SECONDS := 1.2

var card_content: Control
var game_viewport: SubViewport
var result_overlay: ColorRect
var result_label: Label

func _ready() -> void:
	custom_minimum_size = CARD_SIZE

	card_content = Control.new()
	card_content.custom_minimum_size = CARD_SIZE
	add_child(card_content)

	var viewport_container := SubViewportContainer.new()
	viewport_container.stretch = true
	viewport_container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	card_content.add_child(viewport_container)

	game_viewport = SubViewport.new()
	game_viewport.size = Vector2i(CARD_SIZE)
	game_viewport.transparent_bg = true
	viewport_container.add_child(game_viewport)

	result_overlay = ColorRect.new()
	result_overlay.color = Color(0.0, 0.0, 0.0, 0.82)
	result_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	result_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	result_overlay.visible = false
	card_content.add_child(result_overlay)

	result_label = Label.new()
	result_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	result_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	result_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	result_label.add_theme_color_override("font_color", Color(0.35, 1.0, 0.45))
	result_label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	result_overlay.add_child(result_label)

func setup(minigame_scene: PackedScene) -> void:
	var minigame := minigame_scene.instantiate()
	game_viewport.add_child(minigame)
	if minigame.has_signal("completed"):
		minigame.connect("completed", _on_minigame_completed)

func _on_minigame_completed(reward: int) -> void:
	result_label.text = "¡Correcto! Ganaste %d chauchas." % reward
	result_overlay.show()
	completed.emit(reward)
	await get_tree().create_timer(RESULT_DISPLAY_SECONDS).timeout
	if is_instance_valid(self):
		queue_free()
