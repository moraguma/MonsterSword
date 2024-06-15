extends Sprite2D
class_name Entity

enum TEAM {ALLY, ENEMY}
enum AIM_TYPES {ATTACK}

@export var life: int
@export var max_life: int
@export var attack: int
var effects: Array[Effect]

var team: TEAM
var attack_aim: Entity
var selected = false

@onready var battle: Battle = get_parent().get_parent()


@onready var indicator: Sprite2D = $Indicator
@onready var stats_holder: Node2D = $StatsHolder
@onready var life_display: Label = $StatsHolder/HP
@onready var attack_display: Label = $StatsHolder/ATK


func _ready():
	stats_holder.position[1] = texture.get_height() / 2
	life_display.text = str(life) + "/" + str(max_life)
	attack_display.text = str(attack)


func choose_attack_aim():
	var adversaries = battle.get_attackable_adversaries(self)
	if len(adversaries) == 0:
		attack_aim = null
		return
	
	attack_aim = adversaries[randi() % len(adversaries)]
	display_aim(attack_aim, AIM_TYPES.ATTACK)


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
func display_aim(aim: Entity, type: AIM_TYPES):
	pass


func pressed():
	if not selected:
		selected = true
		indicator.show()
		battle.select_entity(self)
	else:
		selected = false
		indicator.hide()
		battle.desselect_entity(self)
