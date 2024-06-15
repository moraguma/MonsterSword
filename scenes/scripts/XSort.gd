extends Node2D
class_name XSort


func _process(delta):
	for i in range(1, get_child_count()):
		var key = get_child(i).position[0]
		var j = i - 1
		while j >= 0 and key < get_child(j).position[0]:
			move_child(get_child(j), j + 1)
			j -= 1
