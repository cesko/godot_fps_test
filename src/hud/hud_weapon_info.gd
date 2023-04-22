extends Control

@onready var ammunition_label = $MarginContainer/Label

func update_ammunition(magazin:int, reserve:int):
	ammunition_label.set_text(str(magazin) + " / " + str(reserve))
