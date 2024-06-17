extends Sprite2D


# Called when the node enters the scene tree for the first time.
func _ready():
	SoundController.play_music("Menu")
	
	await get_tree().create_timer(5.0).timeout
	
	SceneManager.goto_scene("res://scenes/Menu.tscn")
