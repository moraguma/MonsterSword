extends Sprite2D
class_name Effect


var entity: Entity
var value: int = 0
var val_to_update: int = 0


@onready var label = $Label
@onready var tooltip: Control = $Tooltip



func initialize(value: int):
	val_to_update = value


func _ready():
	update_value(val_to_update)


func update_value(value):
	self.value += value
	label.text = "" if self.value == 0 else str(self.value)


## Called when entity receives effect. Should register to any needed signals
func attach(new_entity: Entity):
	entity = new_entity


## Called at the start of player's turn. Returns true if loaded any intent and
## false otherwise
func process_intent():
	pass


## Called in the attached entity's turn. Returns true if an action was performed
## and false otherwise
func turn():
	pass
