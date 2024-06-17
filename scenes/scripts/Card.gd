extends Sprite2D
class_name Card


const LERP_WEIGHT = 0.1
const SELECT_OFFSET = Vector2(0, -32)
const BASE_OFFSET = Vector2(0, 0)


var upgrade_card = null
var hovered = false
var selected = false


@onready var battle = get_parent().get_parent()


func set_tooltip(text):
	$Button.tooltip_text = text


func update_battle_ref():
	battle = get_parent().get_parent()


func play(entity: Entity):
	pass


func _process(delta):
	offset = lerp(offset, SELECT_OFFSET if (hovered or selected) and battle.can_interact else BASE_OFFSET, LERP_WEIGHT)


func mouse_entered():
	SoundController.play_sfx("Hover")
	hovered = true


func mouse_exited():
	hovered = false


func pressed():
	SoundController.play_sfx("Select")
	if not selected:
		if battle.select_card(self):
			selected = true
	else:
		selected = false
		battle.desselect_card(self)
