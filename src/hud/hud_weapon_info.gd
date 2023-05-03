extends Control

@onready var ammunition_label = $MarginContainer/VBoxContainer/AmmuLabel
@onready var grenade_label = $MarginContainer/VBoxContainer/GrenadeLabel

func update_ammunition(magazin:int, reserve:int):
	ammunition_label.set_text(str(magazin) + " / " + str(reserve))

func update_grenades(amount:int):
	grenade_label.set_text("Grenades: " + str(amount))
