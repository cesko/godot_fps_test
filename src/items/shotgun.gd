class_name Shotgun extends Weapon

@export var projectiles_per_shot:int = 8

func shoot():
	# check if ready to shoot:
	if _cooling_down():
		return 
		
	if current_magazin <= 0:
		magazin_empty_effect()
		return
	
	current_magazin += projectiles_per_shot-1
	for p in range(projectiles_per_shot):
		# current_magazin += 1
		_cooldown_until = -1
		super()
		
