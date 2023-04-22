extends TriggerEvent

class_name TriggerEventSetAttribute

@export var attribute_name:String = ""

enum Operation {SET_TO_VALUE, INREASE_BY_VALUE, INCREASE_IGNORE_LIMITS, SET_MAX}
@export var operation:Operation

@export var value:float = 0

