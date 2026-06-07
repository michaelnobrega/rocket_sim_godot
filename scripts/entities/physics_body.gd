# physics_body.gd — base class for any object with 2D physics
class_name PhysicsBody


# --- State ---
var x  		= 0.0
var y  		= 0.0
var vx 		= 0.0
var vy 		= 0.0
var theta 	= 0.0
var omega	= 0.0

# --- Orbit ---
var orbit: Orbit = null


func get_state() -> Array:
	return [x, y, vx, vy, theta, omega]


func set_state(state: Array) -> void:
	x  		= state[0]
	y  		= state[1]
	vx 		= state[2]
	vy 		= state[3]
	theta 	= state[4]
	omega 	= state[5]


func speed() -> float:
	return Math.array_abs([vx, vy])


func longitude() -> float:
	return rad_to_deg(atan2(y, x))


func velocity_angle() -> float:
	return rad_to_deg(atan2(vy, vx))


func horizontal_angle() -> float:
	return longitude() - 90


func horizontal_speed() -> float:
	return speed()*cos(deg_to_rad(velocity_angle() - horizontal_angle()))


func vertical_speed() -> float:
	return speed()*sin(deg_to_rad(velocity_angle() - horizontal_angle()))


func flight_path_angle() -> float:
	return velocity_angle() - horizontal_angle()


func radial_distance() -> float:
	return sqrt(x * x + y * y)


func update_orbit() -> void:
	orbit = Orbit.from_state(x, y, vx, vy)

	
func restore_contact(normal2D, penetration_depth):
	x += normal2D[0] * penetration_depth
	y += normal2D[1] * penetration_depth
