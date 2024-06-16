extends Control


func _make_custom_tooltip(for_text):
	var tip = preload("res://scenes/Tooltip.tscn").instantiate()
	tip.text = for_text
	return tip
