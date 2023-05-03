extends Resource

class_name AmmunitionInventory

enum Type {NONE, PISTOL, ASSAULT, SHOTGUN, GRENADES}

@export var pistol_ammu : Capacity
@export var assault_ammu : Capacity
@export var shotgun_ammu : Capacity
@export var grenade_ammu : Capacity

func load_default_capacity():
	
	if pistol_ammu == null:
		pistol_ammu = Capacity.new(70)
	if assault_ammu == null:
		assault_ammu = Capacity.new(60)
	if shotgun_ammu == null:
		shotgun_ammu = Capacity.new(52)
	if grenade_ammu == null:
		grenade_ammu = Capacity.new(5)
	

func _get_by_type(type:Type) -> Capacity:
	var capacity = null
	match type:
		Type.PISTOL:
			capacity = pistol_ammu
		Type.ASSAULT:
			capacity = assault_ammu
		Type.SHOTGUN:
			capacity = shotgun_ammu
		Type.GRENADES:
			capacity = grenade_ammu
	
	if capacity == null:
		load_default_capacity()
		capacity = _get_by_type(type)
	
	return capacity


func is_full(type:Type) -> bool:
	return _get_by_type(type).is_full()

func get_bullets (type:Type) -> int:
	return _get_by_type(type).amount

func change_bullets (type:Type, change:int):
	_get_by_type(type).increase(change)

func set_bullets (type:Type, new_count:int):
	_get_by_type(type).amount = new_count
