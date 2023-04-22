extends Node2D

class_name Crosshair

@onready var top   = $Cross/Top
@onready var left  = $Cross/Left
@onready var down  = $Cross/Down
@onready var right = $Cross/Right

const SPREAD_FACTOR = 0.2
const CROSS_MIN_OFFSET = 2

func _ready():
	global_position = get_viewport_rect().size / 2
	
func setSpread(spread:float):
	top.position   = Vector2.UP    * (SPREAD_FACTOR * spread + CROSS_MIN_OFFSET)
	right.position = Vector2.RIGHT * (SPREAD_FACTOR * spread + CROSS_MIN_OFFSET)
	down.position  = Vector2.DOWN  * (SPREAD_FACTOR * spread + CROSS_MIN_OFFSET)
	left.position  = Vector2.LEFT  * (SPREAD_FACTOR * spread + CROSS_MIN_OFFSET) 

