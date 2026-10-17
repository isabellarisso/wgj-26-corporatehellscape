extends Control

signal completed(reward: int)

const REWARD := 85
const MAX_ATTEMPTS := 4

@onready var message_label: Label = $Layout/Message
@onready var attempts_label: Label = $Layout/Attempts
@onready var number_grid: GridContainer = $Layout/NumberGrid
@onready var retry_button: Button = $Layout/Retry

var target_number: int
var attempts_left := MAX_ATTEMPTS
var round_over := false

func _ready() -> void:
	for number in range(1, 11):
		var button := Button.new()
		button.text = str(number)
		button.custom_minimum_size = Vector2(48, 34)
		button.pressed.connect(_on_number_pressed.bind(number))
		number_grid.add_child(button)

	retry_button.pressed.connect(_start_new_round)
	_start_new_round()

func _start_new_round() -> void:
	var previous_number := target_number if target_number > 0 else 0
	target_number = randi_range(1, 10)
	while target_number == previous_number:
		target_number = randi_range(1, 10)

	attempts_left = MAX_ATTEMPTS
	round_over = false
	message_label.text = "Adivina el número del 1 al 10"
	attempts_label.text = "Intentos: %d" % attempts_left
	retry_button.hide()
	_set_number_buttons_enabled(true)

func _on_number_pressed(number: int) -> void:
	if round_over:
		return

	if number == target_number:
		round_over = true
		message_label.text = "¡Adivinaste!"
		attempts_label.text = ""
		_set_number_buttons_enabled(false)
		completed.emit(REWARD)
		return

	attempts_left -= 1
	attempts_label.text = "Intentos: %d" % attempts_left
	if attempts_left == 0:
		round_over = true
		message_label.text = "Era el %d. ¡Intenta con otro número!" % target_number
		_set_number_buttons_enabled(false)
		retry_button.show()
	elif number < target_number:
		message_label.text = "Es más alto."
	else:
		message_label.text = "Es más bajo."

func _set_number_buttons_enabled(enabled: bool) -> void:
	for button in number_grid.get_children():
		button.disabled = not enabled
