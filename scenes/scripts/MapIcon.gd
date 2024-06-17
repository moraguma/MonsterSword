extends TextureButton
class_name MapIcon


enum MODE {X, ARROW, MARKER}
enum TYPE {BATTLE, HARD_BATTLE, CAMPFIRE, BOSS}


var type: TYPE
var mode: MODE


const TYPE_TO_TEX = {
	TYPE.BATTLE: preload("res://resources/sprites/ui/battle.png"),
	TYPE.HARD_BATTLE: preload("res://resources/sprites/ui/hard_battle.png"),
	TYPE.CAMPFIRE: preload("res://resources/sprites/ui/campfire.png"),
	TYPE.BOSS: preload("res://resources/sprites/ui/boss.png")
}
@onready var mode_to_sprite = {
	MODE.X: $X,
	MODE.ARROW: $Arrow,
	MODE.MARKER: $Marker
}


func _ready():
	mouse_entered.connect(play_sound)


func set_type(new_type: TYPE):
	type = new_type
	
	var tex = TYPE_TO_TEX[new_type]
	texture_normal = tex


func set_mode(mode: MODE):
	self.mode = mode
	for m in mode_to_sprite:
		if m == mode:
			mode_to_sprite[m].show()
		else:
			mode_to_sprite[m].hide()


func play_sound():
	SoundController.play_sfx("UIMapHover")
