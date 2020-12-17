extends RigidBody2D
class_name Aircraft

# It's very important to have self body mass a lot higher than
# wheel's mass because the center of mass is considered at (0, 0) by apply_impulse()
#
# To be more accurate, you can calculate the center of mass by taking into
# account wheel's mass, apply_impulse(COM, force) and then calculate the torque
# with Vector2(COM, COP).cross(force)


# loss of energy is applied by default_linear_damp and default_angular_damp
# provided in settings > physics > 2D
# It allows it to reach a maximum falling speed and achieve better stability


const natural_drag_coeff:float = 0.001
const lift_coeff:float = 0.02
const stall_angle:float = PI/4
const stall_factor:float = 2.0 # how much natural_drag will be applied when stalling and how less powerfull elevators will be

const shape_factor:float = 2.0 # have to be > 0

const COP:Vector2 = Vector2(-15, 0) # center of pressure. This is where aero forces apply
const COT:Vector2 = Vector2(18, 0) # center of thrust


var torque:float # elevator force, simplified
const elevatorCoeff:float = 30.0 # max elevator action
var engineForce:Vector2
const thrust:float = 100000.0

onready var bodyCollShape = get_node("bodyCollShape")
onready var cam = get_node("Camera2D")
onready var elevator = get_node("elevator")

var acc:Vector2 # global plane acceleration calculated each frame from linear_velocity
var last_velocity:Vector2 = Vector2.ZERO # to calculate acceleration vector

func _ready():
	Global.playerNode = self


func _draw():
	# draw main shape:
	draw_colored_polygon(bodyCollShape.polygon, MyColors.mainBright, PoolVector2Array(  ), null, null, true)

	# drawings are rotated so need to counteract with .rotated(-rotation)
	# draw vector infos:
#	draw_line(COP, COP + 0.001 * get_lift().rotated(-rotation), Color.green, 2.0,true)
#	draw_line(COP, COP + 0.01 * get_natural_drag().rotated(-rotation), Color.yellow, 2.0, true)
#	draw_line(Vector2.ZERO, 0.1 * linear_velocity.rotated(-rotation), Color.blue, 2.0, true)
	
	# draw aoa info:
#	if get_aoa() < 0:
#		draw_arc(Vector2.ZERO, 200, 0, get_aoa(), 16, Color.red, 2.0, true)
#	else:
#		draw_arc(Vector2.ZERO, 200, 0, get_aoa(), 16, Color.blue, 2.0, true)
#	draw_arc(Vector2.ZERO, 210, -stall_angle, stall_angle, 16, Color(1, 0, 0, 0.5), 2.0, true)
	

	# draw shaft:
	draw_line(Vector2(0, -1), COT + Vector2(1, -1), MyColors.mainBright, 1.2, true)

	# draw propeller:
	draw_arc(
		Vector2(bodyCollShape.polygon[0].x, 0),
		COT.x - bodyCollShape.polygon[0].x - 0.5,
		-0.12*sin((0.04 * linear_velocity.length()) + 0.02 * OS.get_ticks_msec()) - 0.03,
		0.12*sin((0.04 * linear_velocity.length()) + 0.02 * OS.get_ticks_msec()) - 0.03,
		16, Color(0.25, 0.14, 0.22), 1.2, true
		)


func _process(_delta):
	cam.zoom = Vector2(
		lerp(cam.zoom.x, exp(linear_velocity.length() * 0.0002) -0.5, 0.1),
		lerp(cam.zoom.y, exp(linear_velocity.length() * 0.0002) -0.5, 0.1)
		)
	
	elevator.rotation = -deg2rad(torque)
	
	acc = get_acceleration()
	

func _physics_process(delta):
	_apply_controls(delta)
	
	if abs(get_aoa()) < stall_angle:
		# not stalling
		apply_impulse(COP.rotated(rotation), get_lift() * delta)
		apply_impulse(COP.rotated(rotation), get_natural_drag() * delta)
	
	else:
		# stalling. Apply a bigger drag force and no lift
		apply_impulse(COP.rotated(rotation), stall_factor * get_natural_drag() * delta)
	
	update()

	
func get_acceleration()->Vector2:
	# calculate accelaration from previous velocity
	
	var acceleration = last_velocity - linear_velocity
	last_velocity = linear_velocity
	
	return acceleration


func get_vertical_g_force(acceleration:Vector2)->float:
	# returns the vertical component of g force
	# the g vector is projected according to plane axis, then
	# rotated only have it on global Vector2.UP
	# that way, we can have positive and negative values
	# instead of using .length()
	
	var v_g = (acceleration + Vector2(0, +1)).project(Vector2.UP.rotated(rotation)).rotated(-rotation) # add gravity with Vector2(0, +1)
	return v_g.y


func get_lift()->Vector2:
	# it includes induced drag by making it perpendicular to linear_velocity
	
	var aoa = get_aoa()
	
	var mag:float = lift_coeff * shape_factor * aoa * linear_velocity.length_squared()
	var lift = mag * Vector2.UP.rotated(linear_velocity.angle()) # here, induced drag is already included
	
	return lift


func get_aoa()->float:
	# angle of attack
	
	return -linear_velocity.angle_to(Vector2.RIGHT.rotated(rotation))


func get_natural_drag()->Vector2:
	var u = -linear_velocity.normalized() # drag is in opposite direction of velocity
	var drag_factor = natural_drag_coeff * abs(get_aoa()) # drag is always opposite to velocity so abs() is necessary in case aoa is negative
	var v2 = linear_velocity.length_squared()
	
	return drag_factor * v2 * u


func _apply_controls(delta):
	if Input.is_action_pressed("ui_right"):
		engineForce = lerp(engineForce, thrust * Vector2.RIGHT.rotated(rotation), 0.02)
	else:
		engineForce = lerp(engineForce, Vector2.ZERO, 0.06)
	
	# here, elevator action is simulated with torque directly on the plane
	if Input.is_action_pressed("ui_down"):
		torque = lerp(torque, -elevatorCoeff, 0.006 / (pow(get_aoa(), 3) + 1))
	elif Input.is_action_pressed("ui_up"):		
		torque = lerp(torque, elevatorCoeff, 0.006 / (pow(get_aoa(), 3) + 1))
	else:
		torque = lerp(torque, 0, 0.006 / (pow(get_aoa(), 2) + 3)) # reset torque smoothly

	# apply thrust
	apply_impulse(COT.rotated(rotation), engineForce * delta)
	
	
	# apply torque
	# the faster the plane, the bigger the elevator action (squared because of air pushing)
	if abs(get_aoa()) > stall_angle:
		torque = lerp(torque, 0, 0.2) # reset torque smoothly
	apply_torque_impulse(lift_coeff * torque * linear_velocity.length_squared() * delta)
		
