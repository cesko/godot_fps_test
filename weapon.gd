extends Node3D

class_name Weapon

@export var damage:float = 1.0
@export var magazin_capacity:int = 1000
@export var automatic:bool = false
@export var cool_down_time:float = 1.0
@export var reload_time:float = 3.0
@onready var aiming_ray_cast = $AimingRayCast

var magazin_current = 1000

var _cooldown = false
var _cooldown_until = 0.0

enum MoveState {IDLE, WALK, RUN, JUMP}
var _move_state:MoveState = MoveState.IDLE

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	move_effects()

func cooled_down() -> bool:
	return _cooldown_until <= Time.get_ticks_msec()

func shoot():
	if cooled_down():
		if aiming_ray_cast.is_colliding():
			var target = aiming_ray_cast.get_collider()
			print("Hit " + str(target))
			if target.has_method("hit"):
				target.call("hit", generate_hit_info())
		else:
			print("No hit :(")
		# todo: check bullets
		play_shoot_effects()
		
func generate_hit_info() -> HitInfo:
	var hit_info = HitInfo.new()
	hit_info.damage = damage
	hit_info.collision_point = aiming_ray_cast.get_collision_point()
	hit_info.collision_normal = aiming_ray_cast.get_collision_normal()
	hit_info.collision_dir = (aiming_ray_cast.global_position - aiming_ray_cast.get_collision_point()).normalized()
	return hit_info

func reload():
	pass


func play_shoot_effects():
	pass
	
func play_reload_effects():
	# use custom effects
	pass
	
func move_effects():
	pass
