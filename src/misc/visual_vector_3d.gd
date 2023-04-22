extends Node3D
class_name VisualVector3D

@export var material:Material
@export var from_point_material:Material
@export var to_point_material:Material
@export var thickness:float = 0.05
@export var tip_length:float = 0.1
@export var primary_axis:Vector3 = Vector3.UP
@export var show_points:bool = false

var tf:Transform3D

var shaft:MeshInstance3D
var tip:MeshInstance3D

var from_ball:MeshInstance3D
var to_ball:MeshInstance3D

func _ready():

	shaft = MeshInstance3D.new()
	shaft.mesh = CylinderMesh.new()
	shaft.mesh.material = material
	shaft.mesh.top_radius = thickness
	shaft.mesh.bottom_radius = thickness
	add_child(shaft)
	shaft.hide()
	
	tip = MeshInstance3D.new()
	tip.mesh = CylinderMesh.new()
	tip.mesh.height = tip_length
	tip.mesh.top_radius = 0.0
	tip.mesh.bottom_radius = 2*thickness
	tip.mesh.material = material
	add_child(tip)
	tip.hide()
	
	from_ball = MeshInstance3D.new()
	from_ball.mesh = SphereMesh.new()
	from_ball.mesh.radius = 2*thickness
	from_ball.mesh.height = 4*thickness
	from_ball.mesh.material = from_point_material
	add_child(from_ball)
	from_ball.hide()
	
	to_ball = MeshInstance3D.new()
	to_ball.mesh = SphereMesh.new()
	to_ball.mesh.radius = 2*thickness
	to_ball.mesh.height = 4*thickness
	to_ball.mesh.material = to_point_material
	add_child(to_ball)
	to_ball.hide()

		

func draw(from:Vector3, to:Vector3):
	shaft.set_rotation(Vector3(0, 0, 0)) # reset
	tip.set_rotation(Vector3(0, 0, 0)) # reset
	
	var total_length = from.distance_to(to)
	var direction = from.direction_to(to)
	
	var updated_tip_length = min(total_length, tip_length)	
	var shaft_length = total_length - updated_tip_length
	var mid_point_shaft = from + 0.5 * shaft_length * direction
	var mid_point_tip = to - 0.5 * updated_tip_length * direction
	
	var rot_axis = primary_axis.cross(direction).normalized()
	var rot_angle = primary_axis.angle_to(direction)
	
	shaft.mesh.height = shaft_length
	shaft.set_global_position(mid_point_shaft)
	
	tip.set_global_position(mid_point_tip)
		
	if rot_axis:
		shaft.rotate(rot_axis, rot_angle)
		tip.rotate(rot_axis, rot_angle)
	elif primary_axis.dot(direction) == -1:
		var helper = Vector3.LEFT
		if helper == primary_axis or helper == - primary_axis:
			helper = Vector3.UP
		shaft.rotate(primary_axis.cross(helper), PI)
		tip.rotate(primary_axis.cross(helper), PI)
		
	shaft.show()
	tip.show()
	
	to_ball.set_global_position(to)
	from_ball.set_global_position(from)
	
	if show_points:
		to_ball.show()
		from_ball.show()
	
