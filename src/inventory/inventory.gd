extends Resource

class_name Inventory

@export var weapons:Array[Weapon]
@export var ammunition:Ammunition

var current_weapon_index:int = -1

func next_weapon() -> Weapon:
	if weapons.is_empty():
		print("No Weapons in inventory")
		return null
	
	current_weapon_index += 1
	if current_weapon_index >= weapons.size():
		current_weapon_index = 0
	
	return weapons[current_weapon_index]

func previous_weapon() -> Weapon:
	if weapons.is_empty():
		print("No Weapons in inventory")
		return null
	
	current_weapon_index -= 1
	if current_weapon_index < 0:
		current_weapon_index = weapons.size() -1
	
	return weapons[current_weapon_index]

func add_weapon(weapon:Weapon):
	weapons.append(weapon)
