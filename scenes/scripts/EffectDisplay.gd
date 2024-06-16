extends Sprite2D


var value = 0


@onready var label = $Label


func initialize(effect_tex: Texture, value: int):
	texture = effect_tex
	update_value(value)


func update_value(value):
	self.value += value
	label.text = "" if self.value == 0 else str(self.value)
