extends Control

signal completed(reward: int)

const REWARD := 85
const WORDS_TO_WIN := 5
const ROUND_SECONDS := 25.0
const WORD_LIST := [
	"oficina", "reunion", "correo", "teclado", "proyecto",
	"empresa", "urgente", "archivo", "ventana", "trabajo",
	"deadline", "feedback", "benchmark", "onboarding", "briefing",
	"networking", "stakeholder", "coaching", "mentoring", "marketing"
]

@onready var word_label: Label = $Layout/Word
@onready var status_label: Label = $Layout/Status
@onready var progress_label: Label = $Layout/Progress
@onready var time_label: Label = $Layout/Time
@onready var word_input: LineEdit = $Layout/WordInput
@onready var retry_button: Button = $Layout/Retry
@onready var round_timer: Timer = $RoundTimer

var words_completed := 0
var target_word := ""
var round_over := false

func _ready() -> void:
	word_input.text_submitted.connect(_on_word_submitted)
	retry_button.pressed.connect(_start_round)
	round_timer.timeout.connect(_on_round_timeout)
	_start_round()

func _process(_delta: float) -> void:
	if not round_over:
		time_label.text = "Tiempo: %d s" % ceili(round_timer.time_left)

func _start_round() -> void:
	words_completed = 0
	round_over = false
	status_label.text = "Escribe cada palabra y presiona Enter."
	progress_label.text = "Palabras: 0 / %d" % WORDS_TO_WIN
	time_label.text = "Tiempo: %d s" % int(ROUND_SECONDS)
	retry_button.hide()
	word_input.editable = true
	word_input.clear()
	_choose_next_word()
	round_timer.start(ROUND_SECONDS)
	word_input.grab_focus()

func _choose_next_word() -> void:
	var previous_word := target_word
	target_word = WORD_LIST.pick_random()
	while target_word == previous_word:
		target_word = WORD_LIST.pick_random()
	word_label.text = target_word

func _on_word_submitted(typed_word: String) -> void:
	if round_over:
		return

	if typed_word.strip_edges().to_lower() == target_word:
		words_completed += 1
		progress_label.text = "Palabras: %d / %d" % [words_completed, WORDS_TO_WIN]
		if words_completed >= WORDS_TO_WIN:
			_finish_success()
			return
		status_label.text = "¡Bien! Sigue con la próxima palabra."
		_choose_next_word()
	else:
		status_label.text = "No coincide. Inténtalo otra vez."

	word_input.clear()

func _on_round_timeout() -> void:
	if round_over:
		return
	round_over = true
	status_label.text = "¡Se acabó el tiempo! Intenta otra vez."
	word_input.editable = false
	retry_button.show()

func _finish_success() -> void:
	round_over = true
	round_timer.stop()
	status_label.text = "¡Ronda completada!"
	time_label.text = ""
	word_input.editable = false
	completed.emit(REWARD)
