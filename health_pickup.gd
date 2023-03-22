extends "res://PickUp.gd"
	
func on_pickup():
	print("Heal Player")
	player._health = player._health_max
