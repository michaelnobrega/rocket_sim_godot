# aerodynamics.gd — aerodynamic forces
class_name Aerodynamics


static func calculate_angle_of_attack(vessel) -> float:
	var theta = deg_to_rad(vessel.attitude_deg)
	var gamma = vessel.flight_path_angle()
	return theta - gamma


static func calculate_aerodynamic_forces(vessel, air_density: float) -> Dictionary:
	var reference_area = vessel.cross_section
	var lift_coeff     = vessel.lift_coeff
	var drag_coeff     = vessel.drag_coeff
	var airspeed       = vessel.speed()
	var dyn_press      = 0.5 * air_density * airspeed * airspeed
	var lift           = lift_coeff * dyn_press * reference_area
	var drag           = drag_coeff * dyn_press * reference_area
	return {"lift": lift, "drag": drag}