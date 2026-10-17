extends Control

signal completed(reward: int)

const REWARD := 85
const WINNING_LINES := [
	[0, 1, 2], [3, 4, 5], [6, 7, 8],
	[0, 3, 6], [1, 4, 7], [2, 5, 8],
	[0, 4, 8], [2, 4, 6],
]

@onready var status_label: Label = $Layout/Status
@onready var board_grid: GridContainer = $Layout/Board
@onready var retry_button: Button = $Layout/Retry

var board: Array[String] = []
var board_buttons: Array[Button] = []
var round_over := false

func _ready() -> void:
	for cell in 9:
		board.append("")
		var button := Button.new()
		button.custom_minimum_size = Vector2(58, 42)
		button.add_theme_font_size_override("font_size", 24)
		button.pressed.connect(_on_cell_pressed.bind(cell))
		board_buttons.append(button)
		board_grid.add_child(button)

	retry_button.pressed.connect(_start_new_round)
	_start_new_round()

func _start_new_round() -> void:
	for cell in 9:
		board[cell] = ""
		board_buttons[cell].text = ""
		board_buttons[cell].disabled = false

	round_over = false
	status_label.text = "Tú eres X. Elige una casilla."
	retry_button.hide()

func _on_cell_pressed(cell: int) -> void:
	if round_over or not board[cell].is_empty():
		return

	_play_mark(cell, "X")
	if _has_won("X"):
		_finish_game("¡Ganaste!", true)
		return
	if _is_board_full():
		_finish_game("Empate. Intenta otra vez.", false)
		return

	status_label.text = "Turno de la computadora…"
	var empty_cells: Array[int] = []
	for index in 9:
		if board[index].is_empty():
			empty_cells.append(index)
	_play_mark(empty_cells.pick_random(), "O")

	if _has_won("O"):
		_finish_game("Ganó la computadora. Intenta otra vez.", false)
	elif _is_board_full():
		_finish_game("Empate. Intenta otra vez.", false)
	else:
		status_label.text = "Tu turno. Elige una casilla."

func _play_mark(cell: int, mark: String) -> void:
	board[cell] = mark
	board_buttons[cell].text = mark
	board_buttons[cell].disabled = true

func _has_won(mark: String) -> bool:
	for line in WINNING_LINES:
		if board[line[0]] == mark and board[line[1]] == mark and board[line[2]] == mark:
			return true
	return false

func _is_board_full() -> bool:
	for mark in board:
		if mark.is_empty():
			return false
	return true

func _finish_game(message: String, player_won: bool) -> void:
	round_over = true
	status_label.text = message
	for button in board_buttons:
		button.disabled = true

	if player_won:
		completed.emit(REWARD)
	else:
		retry_button.show()
