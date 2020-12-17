extends Node2D


func _process(_delta):
	get_node("ground").position.x = get_node("aicraft").position.x # infinite ground
