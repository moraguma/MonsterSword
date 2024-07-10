extends Button


@export var aim_pos: Vector2


func _ready():
	mouse_entered.connect(SoundController.play_sfx.bind("UIHover"))
	pressed.connect(SoundController.play_sfx.bind("UIPlay"))


func _pressed():
	GlobalCamera.follow_pos(aim_pos)

