extends Decal

class_name RandomDecal

@export var textures:Array[Texture]

func _ready():
	set_random_texture()

func set_random_texture():
	var idx = randi_range(0, textures.size()-1)
	texture_albedo = textures[idx] 

