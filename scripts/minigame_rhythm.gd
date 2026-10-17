extends Control

signal completed(reward: int)

const REWARD := 85
const SEQUENCE_LENGTH := 8
const MAX_MISSES := 3
const HIT_LINE_X := 270.0
const HIT_WINDOW := 34.0
const ARROW_SPEED := 225.0
const SPAWN_INTERVAL := 1.15

const DIRECTIONS := ["left", "down", "up", "right"]
const ARROW_GLYPHS := {
	"left": "←",
	"down": "↓",
	"up": "↑",
	"right": "→",
}

@onready var status_label: Label = $Layout/Status
@onready var score_label: Label = $Layout/Score
@onready var playfield: Control = $Layout/Playfield
@onready var retry_button: Button = $Layout/Retry

var target_line: ColorRect
var active_arrow: Label
var active_direction := ""
var spawn_count := 0
var resolved_count := 0
var hit_count := 0
var miss_count := 0
var spawn_cooldown := 0.0
var game_over := false

func _ready() -> void:
	target_line = ColorRect.new()
	target_line.color = Color(1.0, 0.85, 0.2, 0.9)
	target_line.position = Vector2(HIT_LINE_X, 8.0)
	target_line.size = Vector2(3.0, 96.0)
	playfield.add_child(target_line)

	retry_button.pressed.connect(_start_round)
	_start_round()
	grab_focus()

func _process(delta: float) -> void:
	if game_over:
		return

	spawn_cooldown -= delta
	if is_instance_valid(active_arrow):
		active_arrow.position.x += ARROW_SPEED * delta
		if _arrow_center_x() > HIT_LINE_X + HIT_WINDOW:
			_register_miss()

	if active_arrow == null and spawn_cooldown <= 0.0 and spawn_count < SEQUENCE_LENGTH:
		_spawn_arrow()

func _input(event: InputEvent) -> void:
	if game_over or not event is InputEventKey or not event.pressed or event.echo:
		return

	var pressed_direction := _direction_for_key(event as InputEventKey)
	if pressed_direction.is_empty() or not is_instance_valid(active_arrow):
		return

	if absf(_arrow_center_x() - HIT_LINE_X) > HIT_WINDOW:
		return

	if pressed_direction == active_direction:
		_register_hit()
	else:
		_register_miss()

func _direction_for_key(event: InputEventKey) -> String:
	match event.keycode:
		KEY_LEFT:
			return "left"
		KEY_DOWN:
			return "down"
		KEY_UP:
			return "up"
		KEY_RIGHT:
			return "right"

	match event.physical_keycode:
		KEY_A:
			return "left"
		KEY_S:
			return "down"
		KEY_W:
			return "up"
		KEY_D:
			return "right"
	return ""

func _start_round() -> void:
	if is_instance_valid(active_arrow):
		active_arrow.queue_free()
	active_arrow = null
	active_direction = ""
	spawn_count = 0
	resolved_count = 0
	hit_count = 0
	miss_count = 0
	spawn_cooldown = 0.0
	game_over = false
	status_label.text = "Pulsa la dirección cuando la flecha llegue a la línea."
	retry_button.hide()
	_update_score()
	grab_focus()

func _spawn_arrow() -> void:
	active_direction = DIRECTIONS.pick_random()
	active_arrow = Label.new()
	active_arrow.text = ARROW_GLYPHS[active_direction]
	active_arrow.position = Vector2(12.0, maxf(0.0, (playfield.size.y - 42.0) / 2.0))
	active_arrow.size = Vector2(36.0, 42.0)
	active_arrow.add_theme_font_size_override("font_size", 34)
	active_arrow.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	active_arrow.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	playfield.add_child(active_arrow)
	spawn_count += 1
	spawn_cooldown = SPAWN_INTERVAL
	status_label.text = "¡Prepárate! Usa flechas o WASD."

func _arrow_center_x() -> float:
	return active_arrow.position.x + active_arrow.size.x / 2.0

func _register_hit() -> void:
	hit_count += 1
	resolved_count += 1
	_remove_active_arrow()
	status_label.text = "¡A tiempo!"
	_update_score()
	_check_sequence_end()

func _register_miss() -> void:
	miss_count += 1
	resolved_count += 1
	_remove_active_arrow()
	status_label.text = "¡Fallaste el ritmo!"
	_update_score()
	if miss_count >= MAX_MISSES:
		_finish_failure()
	else:
		_check_sequence_end()

func _remove_active_arrow() -> void:
	if is_instance_valid(active_arrow):
		active_arrow.queue_free()
	active_arrow = null
	active_direction = ""

func _update_score() -> void:
	score_label.text = "Aciertos: %d / %d    Fallos: %d / %d" % [hit_count, SEQUENCE_LENGTH, miss_count, MAX_MISSES]

func _check_sequence_end() -> void:
	if resolved_count >= SEQUENCE_LENGTH:
		_finish_success()

func _finish_success() -> void:
	game_over = true
	status_label.text = "¡Secuencia completada!"
	completed.emit(REWARD)

func _finish_failure() -> void:
	game_over = true
	status_label.text = "Se acabó la secuencia. ¡Intenta otra vez!"
	retry_button.show()
