extends ProgressBar

@onready var progress_bar: ProgressBar = self
@onready var test_button: Button = $Button 

var current_chauchas : int = 0
var goal_chauchas : int = 1000

@onready var chauchas_text: Label = $ChauchasText

const FILL_COLOR := Color(0.427, 1.0, 0.275, 1.0)
var fill_style: StyleBoxFlat

func _ready() -> void:
	fill_style = get_theme_stylebox("fill").duplicate() as StyleBoxFlat
	add_theme_stylebox_override("fill", fill_style)

	# initializar progress bar limites
	progress_bar.min_value = 0.0
	progress_bar.max_value = goal_chauchas
	progress_bar.value = current_chauchas
	
	test_button.pressed.connect(_on_button_pressed)
	
	update_chauchas_text()

func _on_button_pressed() -> void:
	increase_money(15) 
	


func increase_money(amount:int):
	current_chauchas += amount
	current_chauchas = mini(current_chauchas, goal_chauchas)
	
	progress_bar.value = current_chauchas
	update_chauchas_text()
	_flash_reward()
	

	if current_chauchas >= goal_chauchas:
		on_money_complete()

func _flash_reward() -> void:
	var tween := create_tween()
	tween.tween_property(fill_style, "bg_color", Color(0.85, 1.0, 0.25, 1.0), 0.12)
	tween.tween_property(fill_style, "bg_color", FILL_COLOR, 0.45)
	
func update_chauchas_text() -> void:
	if chauchas_text:
		chauchas_text.text = "Chauchas: %d / %d" % [current_chauchas, goal_chauchas]


func on_money_complete() -> void:
	chauchas_text.text = "El ahorro de chauchas ha sido exitoso!"
