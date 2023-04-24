extends Node3D

class_name Weapon

signal unequipped
signal ammunition_updated(magazin:int, reserve:int)
signal spread_updated(spread:float)

# Parameter
@export var ammunition_type:Ammunition.Type
@export var magazin_size:int = 7
@export var damage:float = 1
@export var current_magazin:int = 7
@export var reload_time_msec:int = 1500
@export var shoot_time_msec:int = 200
@export var automatic:bool = false
@export var burst:bool = false
@export var burst_shots:int = 3
@export var spread:float = 0.0 # 1/100 * degrees
@export var spread_increase_per_shot:float = 20 # 1/100 * degrees
@export var spread_max:float = 100 # 1/100 * degrees
@export var spread_decrease_time_msec:float = 500

@export var ray_cast:RayCast3D = null
@export var animation_player:AnimationPlayer = null
@export var audio_player:AudioStreamPool = null

var ammunition_reserve:Ammunition = null

var anim_idle = "idle"
var anim_shoot = "shoot"
var anim_reload = "reload"
var anim_equip = "equip"
var anim_unequip = "unequip"

@export var sfx_shoot: AudioStream
@export var sfx_reload: AudioStream
@export var sfx_empty: AudioStream

# Internals
var _cooldown_until:int = -1
var _equipped:bool = false
var _bursting:bool = false
var _burst_counter:int = 0

var _current_spread:float

func _ready():
	if not ray_cast:
		push_error("Weapon without RayCast is invalid")
	
	_current_spread = spread

func _process(delta):
	
	# decrease spread angle over time
	if _current_spread > spread:
		if _cooling_down() == false:
			_current_spread -= (spread_max - spread) * 1000 * delta/spread_decrease_time_msec
			_current_spread = max(_current_spread, spread)
			spread_updated.emit(_current_spread)
	else:
		pass # print("not decreasing: " + str(_current_spread) + ">" + str(spread))
	
	if _equipped:
		
		ammunition_updated.emit(current_magazin, ammunition_reserve.get_bullets(ammunition_type))
		
		if Input.is_action_just_pressed("shoot"):
			_bursting = true
			_burst_counter = 0
			shoot()
		
		if burst:
			if _bursting and _burst_counter < burst_shots:
				shoot()
		
		if automatic:
			if Input.is_action_pressed("shoot"):
				shoot()
		
		if Input.is_action_just_pressed("reload"):
			reload()
			

func _cooling_down() -> bool:
	if _cooldown_until <= Time.get_ticks_msec():
		return false
	return true

func _set_cooldown(cooldown_msec:int):
	_cooldown_until = Time.get_ticks_msec() + cooldown_msec

func shoot():
	# check if ready to shoot:
	if _cooling_down():
		return 
	
	if current_magazin > 0:
		current_magazin -= 1
#		ammunition_updated.emit(current_magazin, 999)
		_burst_counter += 1
		
		# Apply inaccuracy 
		if 	_current_spread > 0.0:
			var original_ray_cast_tf = ray_cast.get_global_transform() 
			var horizontal_spread = deg_to_rad(0.01 * randf_range(-_current_spread, _current_spread))
			var vertical_spread = deg_to_rad(0.01 * randf_range(-_current_spread, _current_spread))
			print("Inaccuracy: " + str(_current_spread) + " - " + str(rad_to_deg(horizontal_spread)) + "deg; " + str(rad_to_deg(vertical_spread)) + "deg")
			ray_cast.rotate_object_local(Vector3.UP, vertical_spread)
			ray_cast.rotate_object_local(Vector3.RIGHT, horizontal_spread)
			# ray_cast.force_update_transform()
			ray_cast.force_raycast_update()
			ray_cast.set_global_transform(original_ray_cast_tf)
		_current_spread += spread_increase_per_shot
		_current_spread = min(_current_spread, spread_max)
		spread_updated.emit(_current_spread)

		if ray_cast.is_colliding():
			var hit_info = HitInfo.new()
			hit_info.from_ray_cast(ray_cast)
			hit_info.hit_type = HitInfo.DEFAULT
			hit_info.hit_value = damage
			
			var target = ray_cast.get_collider()
			# if GameManager.hud.push_notification:
				# GameManager.hud.push_notification.print("hit " + str(target))
			if target.has_method("hit"):
				target.hit(hit_info)
			else:
				EffectsManager.world_hit(hit_info)
			
		shoot_effects()	
	
	else:
		magazin_empty_effect()
		_burst_counter = burst_shots
	_set_cooldown(shoot_time_msec)
	
func reload():
	if _cooling_down():
		return
		
	if current_magazin >= magazin_size:
		# gun already full -> no reloading
		pass
	elif ammunition_reserve.get_bullets(ammunition_type) == 0:
		pass
	else:
		var reload_bullets = min(ammunition_reserve.get_bullets(ammunition_type) + current_magazin, magazin_size)
		reload_bullets -= current_magazin
		ammunition_reserve.change_bullets(ammunition_type, -reload_bullets)
		current_magazin += reload_bullets
		_set_cooldown(reload_time_msec)
		reaload_effects()
	pass

func equip():
	_equipped = true
	spread_updated.emit(_current_spread)
#	ammunition_updated.emit(current_magazin, 999)
	equip_effects()
	
func unequip():
	_equipped = false
	unequip_effects()
	await get_tree().create_timer(0.5).timeout
	unequipped.emit()

func shoot_effects():
	if animation_player:
		animation_player.stop()
		animation_player.play(anim_shoot)
	
	if audio_player and sfx_shoot:
		audio_player.play(sfx_shoot)

func magazin_empty_effect():
	if audio_player and sfx_empty:
		audio_player.play(sfx_empty)
	
	
func reaload_effects():
	if animation_player:
		animation_player.play(anim_reload)
	
	if audio_player and sfx_reload:
		audio_player.play(sfx_reload)
	
func equip_effects():
	if animation_player:
		animation_player.play(anim_equip)
	
func unequip_effects():
	if animation_player:
		animation_player.play(anim_unequip)
