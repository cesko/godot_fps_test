extends PickUp

@onready var audio = $AudioStreamPlayer3D

func on_pickup():
	print("Fill Ammunition")
	player._ammu_reserve = clamp(player._ammu_reserve + 56 + player._ammu_gun, 0, player._ammu_max)
	if not audio.playing:
		audio.play()
