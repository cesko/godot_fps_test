class_name Shotgun extends Weapon

@export var projectiles_per_shot:int = 8

var is_reloading:bool = false
var wants_to_shoot:bool = false

func _process(delta):
	
	if is_reloading == true:
		if Input.is_action_pressed("shoot"):
			is_reloading = false
			wants_to_shoot = true
		reload()
		
	if wants_to_shoot:
		shoot()
		
	super(delta)
	

func shoot():
	# check if ready to shoot:
	if _cooling_down():
		return 
	
	wants_to_shoot = false
	
	if current_magazin <= 0:
		if ammunition_reserve.get_bullets(ammunition_type) > 0:
			reload()
		else:
			magazin_empty_effect()
		return
	
	current_magazin += projectiles_per_shot-1
	for p in range(projectiles_per_shot):
		# current_magazin += 1
		_cooldown_until = -1
		super()
		

func reload():
	print("Haha!")
	
	if _cooling_down():
		return
		
	if current_magazin >= magazin_size:
		# gun already full -> no reloading
		is_reloading = false
		pass
	elif ammunition_reserve.get_bullets(ammunition_type) == 0:
		is_reloading = false
		pass
	else:
		var reload_bullets = 1
		ammunition_reserve.change_bullets(ammunition_type, -reload_bullets)
		current_magazin += reload_bullets
		_set_cooldown(reload_time_msec)
		reaload_effects()
		is_reloading = true
	

		
