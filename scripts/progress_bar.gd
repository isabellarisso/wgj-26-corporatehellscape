extends ProgressBar

@onready var progress_bar: ProgressBar = self
@onready var test_button: Button = $Button 

var current_chauchas : int = 0
var goal_chauchas : int = 1000

@onready var chauchas_text: Label = $ChauchasText

func _ready() -> void:
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
	

	if current_chauchas >= goal_chauchas:
		on_money_complete()
	
func update_chauchas_text() -> void:
	if chauchas_text:
		chauchas_text.text = "Chauchas: %d / %d" % [current_chauchas, goal_chauchas]


func on_money_complete() -> void:
	chauchas_text.text = "El ahorro de chauchas ha sido exitoso!"
