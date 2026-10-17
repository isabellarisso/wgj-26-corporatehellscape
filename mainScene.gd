extends Node2D

var chauchas : int = 0
@export var chauchas_text : Label

func increase_money(ammount):
	chauchas += ammount
	chauchas_text.text = str("Chauchas: ", chauchas)
	
