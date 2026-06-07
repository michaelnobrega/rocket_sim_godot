# gravity.gd — gravitational model
class_name Gravity


static func calculate_gravity(r: float) -> float:
	return -(Config.G * Config.M) / pow(r, 2)