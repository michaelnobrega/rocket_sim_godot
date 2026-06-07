# orbit.gd — orbital elements derived from state vector
class_name Orbit

var mu:		float  # Gravitational parameter (m³/s²)
var energy: float  # specific orbital energy (J/kg)
var h:      float  # specific angular momentum (m²/s)
var e:      float  # eccentricity (dimensionless)
var a:      float  # semi-major axis (m)
var omega:  float  # argument of periapsis (rad)
var nu:		float  # true anomaly
var ex:     float  # eccentricity vector x component
var ey:     float  # eccentricity vector y component
var body_x: float  # x position of orbiting body 
var body_y: float  # y position of orbiting body 
var type:   String # "ellipse", "parabola", "hyperbola"


static func from_state(x: float, y: float, vx: float, vy: float) -> Orbit:
	var r_vec = [x, y]
	var v_vec = [vx, vy]
	var orbit = Orbit.new()
	var r     = max(Math.array_abs(r_vec), 1)
	var v     = Math.array_abs(v_vec)
	orbit.body_x = x
	orbit.body_y = y

	orbit.mu    = Config.G * Config.M

	orbit.energy = (v * v) / 2.0 - orbit.mu / r
	orbit.h      = Math.cross_product2(r_vec, v_vec)

	orbit.ex = (vy * orbit.h / orbit.mu) - (x / r)
	orbit.ey = -(vx * orbit.h / orbit.mu) - (y / r)
	var e_vec = [orbit.ex, orbit.ey]
	orbit.e  = Math.array_abs(e_vec)

	orbit.nu = Math.wrap360((sign(Math.cross_product2(e_vec, r_vec)) * rad_to_deg(Math.angle_between_vectors(e_vec, r_vec))))

	orbit.omega = atan2(orbit.ey, orbit.ex)

	if abs(orbit.energy) < 1e-10:
		orbit.type = "parabola"
		orbit.a    = INF
	else:
		orbit.a = -orbit.mu / (2.0 * orbit.energy)
		if orbit.energy < 0.0:
			orbit.type = "ellipse"
		else:
			orbit.type = "hyperbola"

	return orbit


func apoapsis() -> float:
	return a * (1.0 + e) - Config.EARTH_RADIUS_M

func periapsis() -> float:
	return a * (1.0 - e) - Config.EARTH_RADIUS_M

func is_closed() -> bool:
	return type == "ellipse"

func orbital_period() -> float:
	if not is_closed():
		return INF
	return TAU * sqrt(pow(a, 3) / mu)