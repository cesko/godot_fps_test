extends Node3D
class_name Arrow

@export var material:Material
@export var thickness:float = 0.05
@export var tip_length:float = 0.1
@export var primary_axis:Vector3 = Vector3.FORWARD

var tf:Transform3D

var shaft:MeshInstance3D
var tip:MeshInstance3D

func _ready():

	shaft = MeshInstance3D.new()
	shaft.mesh = CylinderMesh.new()
	shaft.mesh.material = material
	shaft.mesh.top_radius = thickness
	shaft.mesh.bottom_radius = thickness
	add_child(shaft)
	
	tip = MeshInstance3D.new()
	tip.mesh = CylinderMesh.new()
	tip.mesh.height = tip_length
	tip.mesh.top_radius = 2*thickness
	tip.mesh.bottom_radius = 0.0
	tip.mesh.material = material
	add_child(tip)
	
	shaft.translate(Vector3(0, 0, -.5))	
	shaft.rotate_x(deg_to_rad(90))
	
	tip.translate(Vector3(0, 0, -1))
	tip.rotate_x(deg_to_rad(90))
		

func draw(from:Vector3, to:Vector3):
	var length = from.distance_to(to)
	var direction = from.direction_to(to)
	
	var mid_point = to-from
	
	var rot_axis = primary_axis.cross(direction)
	var rot_angle = primary_axis.angle_to(direction)
	
	
	pass

