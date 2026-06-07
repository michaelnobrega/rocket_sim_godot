# physics.gd — physics simulation
class_name Physics


# --- Physics update ---

static func update_physics(rocket: Rocket, dt: float) -> void:

	if rocket.crashed:
		return

	# Liftoff
	if rocket.landed and rocket.engine_on:
		rocket.landed = false

	var f = func(state: Array) -> Array:
		if rocket.landed:
			return [0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
		# var x 	= state[0]
		# var y   = state[1]
		var vx  = state[2]
		var vy  = state[3]
		var omega = state[5]
		var omega_dot = 0

		# Gravity
		var r = rocket.radial_distance()
		var g = Gravity.calculate_gravity(r)
		var lambda = deg_to_rad(rocket.longitude())
		var ax = g*cos(lambda)
		var ay = g*sin(lambda)
		
		# Aerodynamics
		var isa  = Atmosphere.calculate_isa(r)
		var aero = Aerodynamics.calculate_aerodynamic_forces(rocket, isa["density"])

		var gamma = deg_to_rad(rocket.flight_path_angle())
		var mass = rocket.total_mass()
		ax += -cos(gamma) * aero["drag"] / mass
		ay += -sin(gamma) * aero["drag"] / mass

		# Thrust
		if rocket.engine_on and not rocket.landed:
			var thrust_acc = rocket.max_acceleration()
			ax += thrust_acc * cos(deg_to_rad(rocket.theta))
			ay += thrust_acc * sin(deg_to_rad(rocket.theta))

			var torque = rocket.thrust_force * sin(deg_to_rad(rocket.nozzle_angle)) * (rocket.ct_position - rocket.cg_dry_position)
			omega_dot = rad_to_deg(torque / rocket.moment_of_inertia())
			
		return [vx, vy, ax, ay, omega, omega_dot]

	var new_state = Math.rk4(rocket.get_state(), f, dt)
	rocket.set_state(new_state)
	rocket.update_orbit()

	# Burn fuel
	if rocket.engine_on and not rocket.landed:
		rocket.burn_fuel(dt)

	# Contact detection
	if rocket.landed:
		return

	var contact = detect_contact(rocket)
	if not contact["contact"]:
		return

	var impact_speed = rocket.speed()
	if impact_speed > 50.0:
		rocket.crashed = true
		rocket.engine_on = false
		rocket.vx = 0.0
		rocket.vy = 0.0
		return
	
	Physics.handle_contact(rocket, contact["nx"], contact["ny"], contact["cx"], contact["cy"], contact["depth"])
	# Only land if speed is still low after impulse
	if rocket.speed() <= 2 and abs(rocket.omega) <= 2 and abs(rocket.theta - rocket.longitude()) <= 2 and not rocket.engine_on:
		rocket.stationary()
		print("Stationary.")


static func detect_contact(rocket: Rocket) -> Dictionary:
	var theta_rad = deg_to_rad(rocket.theta)
	var dir_x = sin(theta_rad) * rocket.diameter / 2.0
	var dir_y = sin(theta_rad) * rocket.length
	

	var points = [
		# Base (half length below center left)
		[rocket.x - dir_x, rocket.y],
		# Base (half length below center right)
		[rocket.x + dir_x, rocket.y],
		# Nose (half length above center left)
		[rocket.x - dir_x, rocket.y + dir_y],
		# Nose (half length above center right)
		[rocket.x + dir_x, rocket.y + dir_y],
		# # Center
		# [rocket.x, rocket.y],
	]

	for p in points:
		var px = p[0]
		var py = p[1]
		var r  = sqrt(px*px + py*py)
		if r <= Config.EARTH_RADIUS_M:
			var nx = px / r
			var ny = py / r
			var depth = Config.EARTH_RADIUS_M - r
			return {"contact": true, "nx": nx, "ny": ny, "cx": px, "cy": py, "depth": depth}

	return {"contact": false}


static func handle_contact(rocket: Rocket, normal_x: float, normal_y: float, contact_x: float, contact_y: float, penetration_depth: float) -> void:
	var nx = normal_x
	var ny = normal_y

	var cg_x = rocket.x + cos(deg_to_rad(rocket.theta)) * rocket.cg_dry_position
	var cg_y = rocket.y + sin(deg_to_rad(rocket.theta)) * rocket.cg_dry_position
	var rx = contact_x - cg_x
	var ry = contact_y - cg_y

	var omega_rad = deg_to_rad(rocket.omega)
	var vcx = rocket.vx - omega_rad * ry
	var vcy = rocket.vy + omega_rad * rx

	var vn = vcx * nx + vcy * ny

	if vn >= 0:
		return

	rocket.restore_contact([normal_x, normal_y], penetration_depth)

	var I = rocket.moment_of_inertia()
	var m = rocket.total_mass()
	var r_cross_n = rx * ny - ry * nx
	var j = -(1.0 + rocket.restitution) * vn / (1.0/m + r_cross_n*r_cross_n/I)

	rocket.vx += j * nx / m
	rocket.vy += j * ny / m
	rocket.omega += rad_to_deg(r_cross_n * j / I)
