extends Sprite2D
class_name Intent


var type_tex


func initialize(target: Entity, type: Texture):
	texture = target.icon
	type_tex = type


func _ready():
	$Type.texture = type_tex
