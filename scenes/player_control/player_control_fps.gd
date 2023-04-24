extends PlayerControlBase

class_name PlayerControlFps

# Parameter
@export var speed = 5.0
@export var jump_speed = 4.5
@export var ammunition:Ammunition

@export var pistol:Weapon
@export var has_pistol:bool 
@export var rifle:Weapon
@export var has_rifle:bool 
@export var shotgun:Weapon
@export var has_shotgun:bool = true
@export var debug_gun:Weapon
@export var has_debug_gun:bool = true

@onready var fps_camera = $Camera3D/SubViewportContainer/SubViewport/FpsCamera


# Internals
var weapon_equipped:Weapon

@onready var all_weapons = {"pistol":pistol, "rifle":rifle, "shotgun":shotgun, "debug_gun":debug_gun}
@onready var has_weapons = {"pistol":has_pistol, "rifle":has_rifle, "shotgun":has_shotgun, "debug_gun":has_debug_gun}

var _sprint_meter = 0.75
var sprint_meter_max = 0.75
var sprint_meter_refill_rate = 0.35
var sprint_speed = 2*speed
var _is_dashing = false

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	audio_stream = $AudioStreamPool
	for w in all_weapons:
		var weapon = all_weapons[w]
		weapon.ammunition_reserve = ammunition
		weapon.ammunition_updated.connect(GameManager.hud.update_ammunition)
	equip_weapon("pistol")
	super()
	

func _unhandled_input(event):	
	if active and event is InputEventMouseMotion:
		rotate_y(-event.relative.x * Settings.mouse_sensitivity)
		camera.rotate_x(-event.relative.y * Settings.mouse_sensitivity)
		camera.rotation.x = clamp(camera.rotation.x, -PI/2, PI/2)
		
	if Input.is_action_just_pressed("equip_pistol"):
		equip_weapon("pistol")

	if Input.is_action_just_pressed("equip_rifle"):
		equip_weapon("rifle")
	
	if Input.is_action_just_pressed("equip_shotgun"):
		equip_weapon("shotgun")

	if Input.is_action_just_pressed("equip_debug_gun"):
		equip_weapon("debug_gun")
	
	if Input.is_action_just_pressed("sprint"):
		_is_dashing = true
	
	if Input.is_action_just_pressed("grenade"):
		throw_grenade()
	

func _process(delta):
	fps_camera.global_transform = camera.global_transform
	pass
	if _sprint_meter < sprint_meter_max:
		if _is_dashing == false:
			_sprint_meter += sprint_meter_refill_rate * delta
			_sprint_meter = min(_sprint_meter, sprint_meter_max)
	

func _physics_process(delta):
	var current_speed = speed
	var current_jump_speed = jump_speed

	if _is_dashing:
		if _sprint_meter > 0.0:
			_sprint_meter -= delta
			current_speed = sprint_speed
			current_jump_speed = jump_speed * speed/sprint_speed
		else:
			_is_dashing = false
		
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = current_jump_speed

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("strafe_left", "strafe_right", "forward", "backward")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)

	apply_movement()

func equip_weapon(weapon_name:String):
	if has_weapons[weapon_name] == false:
		print("Weapon not in inventory")
		return
		
	var weapon = all_weapons[weapon_name]
	print("equipping weapon: " + str(weapon))
	if weapon_equipped == weapon:
		return
	
	if weapon_equipped:
		weapon_equipped.unequip()
		await weapon_equipped.unequipped
		weapon_equipped.hide()
	
	weapon_equipped = weapon
	weapon_equipped.show()
	weapon_equipped.equip()


func handle_event(event:TriggerEvent) -> bool:
	print("FPS handle event")
	if super(event) == true:
		return true
	
	print("FPS handle event")
	
	if event is	TriggerEventPickupAmmunition:
		if not ammunition.is_full(event.type):
			ammunition.change_bullets(event.type, event.amount)
			if audio_stream:
				audio_stream.play(preload("res://assets/audio/ammu_pickup.mp3"))
	
	if event is TriggerEventPickupWeapon:
		has_weapons[event.weapon] = true
		if audio_stream:
			audio_stream.play(preload("res://assets/audio/ammu_pickup.mp3"))	
	
	else:
		print("unhandled event: " + str(event.get_class()))
	
	return true

func _on_health_changed(health:float):
	# update UI
	GameManager.hud.update_health(health, attributes.health.maximum)

	if alive and health <= 0:
		alive = false
		$Camera3D/AnimationPlayer.play("Dying")
		weapon_equipped.unequip()
		died.emit()
	

func throw_grenade():
	print("Throw Grenade!")
	var grenade_scene = preload("res://scenes/items/weapons/water_bomb.tscn")
	var grenade = grenade_scene.instantiate()
	GameManager.world.add_child(grenade)
	grenade.global_transform = camera.global_transform
	grenade.apply_impulse( 10 * (camera.global_transform.basis * Vector3.FORWARD))
