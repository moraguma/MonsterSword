extends Sprite2D
class_name Intent


var type_tex
var tooltip_text_tobe = ""

@onready var intent: Control = $Intent



func initialize(target: Entity, type: Texture, tooltip_text: String):
	texture = target.icon
	type_tex = type
	tooltip_text_tobe = tooltip_text


func _ready():
	$Type.texture = type_tex
	intent.tooltip_text = tooltip_text_tobe
