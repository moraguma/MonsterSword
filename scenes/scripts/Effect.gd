extends Object
class_name Effect


var entity: Entity


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
