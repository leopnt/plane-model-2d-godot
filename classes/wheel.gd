extends RigidBody2D

const thickness:float = 2.0


func _process(_delta):
	update()
	
	
func _draw():
	draw_arc(Vector2.ZERO, get_node("wheelCollShape").shape.radius - thickness/2, 0.0, 2*PI, 16, Color(0.07, 0.01, 0.04), thickness, true)
	draw_line(Vector2.ZERO, get_node("wheelCollShape").shape.radius/2 * Vector2.RIGHT, Color.gray, 1.0, true)
