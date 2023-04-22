extends Node

@export var max_number_of_bullet_holes:int = 16

var buffer = []
var index = 0

func _ready():
	var DecalBulletHole = preload("res://decal_bullet_hole.tscn")
	for i in range(max_number_of_bullet_holes):
		var d = DecalBulletHole.instantiate()
		d.set_visible(false)
		add_child(d)
		buffer.append(d)
	print("Buffer filled with Bullet Holes")
		
func addBulletHole(tf:Transform3D):
	print("create bullet hole")
	buffer[index].global_transform = tf.rotated_local(Vector3.RIGHT, 0.5*PI)
	buffer[index].set_visible(true)
	index += 1
	if index >= max_number_of_bullet_holes:
		index = 0
