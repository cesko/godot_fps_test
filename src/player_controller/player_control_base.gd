extends CharacterBody3D

class_name PlayerControlBase

@export var attributes : CharacterAttributes = CharacterAttributes.new()
#@export var inventory : Inventory = Inventory.new()

signal died
var alive = true

var camera 
var audio_stream

var active = true

func _ready():
	camera = _find_child_camera()
	attributes.health.attribute_changed.connect(_on_health_changed)
	
func set_active(a:bool = true):
	active = a
	
	if active:
		if camera:
			camera.make_current()
			
		update_hud()

func apply_camera_transform():
	if active:
		pass
	

func apply_movement():
	if not active:
		velocity = Vector3.ZERO
	
	move_and_slide()
	
func hit(hit_info:HitInfo):
	attributes.health.increase_value(-hit_info.hit_value)
	pass
	
func handle_event(event:TriggerEvent) -> bool:
	print("PlayerBase handle event")
	if event is	TriggerEventSetAttribute:
		var attr = attributes.by_name(event.attribute_name)
		if not attr:
			print("Attribute not found: " + event.attribute_name) 
		elif event.operation == TriggerEventSetAttribute.Operation.INREASE_BY_VALUE:
			attr.increase_value(event.value)
		elif event.operation == TriggerEventSetAttribute.Operation.INCREASE_IGNORE_LIMITS:
			attr.increase_value(event.value, true)
		elif event.operation == TriggerEventSetAttribute.Operation.SET_TO_VALUE:
			attr.set_value(event.value)
		elif event.operation == TriggerEventSetAttribute.Operation.SET_MAX:
			attr.set_max()
		if event.attribute_name == "health":
			if audio_stream:
				audio_stream.play(preload("res://assets/audio/health_pickup.mp3"))
	
	else:
		print("unhandled event: " + str(event.get_class()))
		return false
	
	return true
	
	
func _get_configuration_warnings():
	var warnings = super() 
	if _find_child_camera() == null:
		warnings.append("PlayerControlBase requires a Camera3D instance as child")
		
	return warnings
	
func _find_child_camera() -> Camera3D:
	var cameras = find_children("*", "Camera3D")
	if cameras.is_empty():
		return null
	else:
		return cameras[0]
		
func _on_health_changed(health:float):
	# update UI
	GameManager.hud.update_health(health, attributes.health.maximum)
	
	if health <= 0:
		died.emit()

func update_hud():
	GameManager.hud.update_health(attributes.health.current, attributes.health.maximum)
