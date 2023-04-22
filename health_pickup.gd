extends "res://PickUp.gd"

@onready var audio = $AudioStreamPlayer3D
@onready var mesh = $MeshInstance3D
	
func on_pickup():
	if pickup_enabled:
		print("Heal Player")
		player.health = player.health_max
		if not audio.playing:
			audio.play()
		disable_pickup()
