extends Sprite2D
class_name Entity

enum TEAM {ALLY, ENEMY}
enum AIM_TYPES {ATTACK}


const ANIMATION_MOVEMENT = 8
const LERP_WEIGHT = 0.1


@export var life: int
@export var max_life: int
@export var attack: int
var effects: Array[Effect]

var team: TEAM
var attack_aim: Entity
var selected = false
var alive = true

@onready var battle: Battle = get_parent().get_parent()


@onready var indicator: Sprite2D = $Indicator

@onready var stats_holder: Node2D = $StatsHolder
@onready var life_display: Label = $StatsHolder/HP
@onready var attack_display: Label = $StatsHolder/ATK

@onready var intent_holder: Node2D = $IntentHolder
@onready var turn_timer: Label = $IntentHolder/TurnTimer


func _ready():
	intent_holder.position[1] = -texture.get_height() / 2
	stats_holder.position[1] = texture.get_height() / 2
	update_values()


func _process(delta):
	offset = lerp(offset, Vector2(0, 0), LERP_WEIGHT)


func update_values():
	life_display.text = str(life) + "/" + str(max_life)
	attack_display.text = str(attack)


## Called at the start of the player's turn. Returns true if this entity intends
## on doing something and false otherwise
func process_intent():
	var intent_loaded = false
	
	# Process effect intents
	for effect: Effect in effects:
		if effect.load_intent():
			intent_loaded = true
	
	# If no attack
	if attack <= 0:
		attack_aim = null
		return intent_loaded
	
	var adversaries = battle.get_attackable_adversaries(self)
	
	# If no targets
	if len(adversaries) == 0:
		attack_aim = null
		return intent_loaded
	
	attack_aim = adversaries[randi() % len(adversaries)]
	display_intent(attack_aim, AIM_TYPES.ATTACK)
	return true


## Called at the entity's turn
func turn():
	for effect in effects:
		if effect.turn():
			await battle.sleep()
		if not alive:
			return
	
	if attack_aim == null:
		return
	
	attack_aim.get_attacked(self, attack)
	animate()


func get_attacked(entity: Entity, damage: int):
	life -= damage
	update_values()
	
	if life <= 0:
		battle.kill_entity(self)


func die():
	alive = false
	queue_free() # TODO: Implement dying animation


## Displays aim circle on top of character that displays type of interaction and
## aimed entity
func display_intent(aim: Entity, type: AIM_TYPES):
	pass


func pressed():
	if not selected:
		if battle.select_entity(self):
			selected = true
			indicator.show()
	else:
		selected = false
		indicator.hide()
		battle.desselect_entity(self)


func set_order(value: int):
	turn_timer.text = str(value)


func delete_order():
	turn_timer.text = ""


func animate():
	offset += ANIMATION_MOVEMENT * (Vector2(1, 0) if team == TEAM.ENEMY else Vector2(-1, 0)) 
