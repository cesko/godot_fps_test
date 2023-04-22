extends Node

var blood_effects

func _ready():
	blood_effects = BloodEffectsPool.new()
	add_child(blood_effects)


