extends Effect


var target = null


func _ready():
	tooltip.tooltip_text = "This entity must be defeated before its allies can be targeted by regular attacks"
	super()


func blocks_attack():
	return true
