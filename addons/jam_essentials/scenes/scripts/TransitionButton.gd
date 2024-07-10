extends Button


@export var transition_path: String


func _ready():
	mouse_entered.connect(SoundController.play_sfx.bind("UIHover"))
	pressed.connect(SoundController.play_sfx.bind("UIPlay"))


func _pressed():
	SceneManager.goto_scene(transition_path)
