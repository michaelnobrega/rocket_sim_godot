# rocket.gd — Rocket class
class_name Rocket
extends PhysicsBody


# --- Geometry (vehicle design) ---
var length              = 50.0
var diameter            = 8.0
var nose_length         = 10.0
var sprite_height_px    = 165.0
var sprite_import_scale = 8.0

# --- Mass ---
var mass_dry  = 20_000.0
var mass_fuel = 80_000.0

# --- Aerodynamics ---
var lift_coeff    = 0.0
var drag_coeff    = 0.5
var cross_section = PI * pow(diameter / 2.0, 2)

# --- Center positions (from base, along rocket axis) ---
var cp_position     = 15.0
var cg_dry_position = 25.0
var ct_position     = 0.0

# --- Propulsion ---
var thrust_force          = 1_500_000.0
var fuel_consumption      = 500.0
var max_attitude_rate     = 3.0
var max_nozzle_angle_rate = 10.0

# --- State ---
var nozzle_angle = 0.0
var engine_on    = false
var landed       = true
var crashed      = false

# --- Contact ---
var restitution = 0.1
var friction = 0.5
var in_contact: bool = false


func _init() -> void:
	y     = Config.EARTH_RADIUS_M
	theta = 90.0  # degrees — pointing up


func reset() -> void:
	x            = 0.0
	y            = Config.EARTH_RADIUS_M
	vx           = 0.0
	vy           = 0.0
	theta		 = 90.0
	omega		 = 0.0
	nozzle_angle = 0.0
	engine_on    = false
	landed       = true
	crashed      = false
	mass_fuel    = 80_000.0


func stationary() -> void:
	vx           = 0.0
	vy           = 0.0
	theta 		 = longitude()
	omega		 = 0.0
	engine_on 	 = false
	landed 		 = true


func total_mass() -> float:
	return mass_dry + mass_fuel


func burn_fuel(dt: float) -> void:
	mass_fuel = max(0.0, mass_fuel - fuel_consumption * dt)
	if mass_fuel == 0.0:
		engine_on = false


func max_acceleration() -> float:
	return thrust_force / total_mass()


func moment_of_inertia() -> float:
	# Solid cylinder: I = m*(r²/2 + l²/12)
	var r = diameter / 2.0
	return total_mass() * (r*r / 2.0 + length*length / 12.0)


func deflect_nozzle(dt: float, direction: String = "C", rate_factor: float = 1.0) -> void:
	rate_factor = clamp(rate_factor, 0.0, 1.0)
	if direction == "R":
		nozzle_angle += rate_factor * max_nozzle_angle_rate * dt
	elif direction == "L":
		nozzle_angle -= rate_factor * max_nozzle_angle_rate * dt
	else:
		if abs(nozzle_angle) > 0.1:
			nozzle_angle += -sign(nozzle_angle) * rate_factor * max_nozzle_angle_rate * dt
		else:
			nozzle_angle = 0
	nozzle_angle = clamp(nozzle_angle, -3, 3)