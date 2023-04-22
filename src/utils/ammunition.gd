extends Resource

class_name Ammunition

enum Type {NONE, PISTOL, ASSAULT, SHOTGUN}

@export var pistol_bullets : int 
@export var pistol_bullets_max : int 

@export var assault_bullets : int
@export var assault_bullets_max : int

@export var shotgun_shells : int
@export var shotgun_shells_max : int

func is_full(type:Type) -> bool:
	match type:
		Type.PISTOL:
			return pistol_bullets >= pistol_bullets_max
		Type.ASSAULT:
			return assault_bullets >= assault_bullets_max
		Type.SHOTGUN:
			return shotgun_shells >= shotgun_shells_max
	return false

func get_bullets (type:Type) -> int:
	match type:
		Type.PISTOL:
			return pistol_bullets
		Type.ASSAULT:
			return assault_bullets
		Type.SHOTGUN:
			return shotgun_shells
	return 0

func change_bullets (type:Type, change:int):
	match type:
		Type.PISTOL:
			pistol_bullets += change
		Type.ASSAULT:
			assault_bullets += change
		Type.SHOTGUN:
			shotgun_shells += change
	clamp_bullets()

func set_bullets (type:Type, new_count:int):
	match type:
		Type.PISTOL:
			pistol_bullets = new_count
		Type.ASSAULT:
			assault_bullets = new_count
		Type.SHOTGUN:
			shotgun_shells = new_count
	clamp_bullets()

func clamp_bullets():
	pistol_bullets = min(pistol_bullets, pistol_bullets_max)
	assault_bullets  = min(assault_bullets, assault_bullets_max)
	shotgun_shells  = min(shotgun_shells, shotgun_shells_max)
