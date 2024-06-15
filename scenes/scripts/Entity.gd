extends Node2D
class_name Entity

enum TEAM {ALLY, ENEMY}

@export var life: int
@export var max_life: int
@export var attack: int
@export var effects: Array[Callable]

var team: TEAM
var attack_aim: Entity

@onready var battle: Battle = get_parent().get_parent()


@onready var life_display: Label = $HP
@onready var attack_display: Label = $ATK


func _ready():
	life_display.text = str(life) + "/" + str(max_life)
	attack_display.text = str(attack)


func choose_attack_aim():
	var adversaries = battle.get_attackable_adversaries(self)
	if len(adversaries) == 0:
		attack_aim = null
		return
	
	attack_aim = adversaries[randi() % len(adversaries)]


func perform_attack():
	if attack_aim == null:
		return
	
	attack_aim.get_attacked(self, attack)


func get_attacked(entity: Entity, damage: int):
	life -= damage
	if life <= 0:
		battle.kill_entity(self)


func die():
	queue_free() # TODO: Implement dying animation


## Displays aim circle on top of character that displays type of interaction and
## aimed entity
func display_aim(aim: Entity, type: int):
	pass
