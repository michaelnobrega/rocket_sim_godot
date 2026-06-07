# trajectory_node.gd — draws predicted orbital trajectory
extends Node2D


var rocket_data: Rocket
var camera: Camera2D
var visible_trajectory: bool = false


func setup(data: Rocket, cam: Camera2D) -> void:
	rocket_data = data
	camera = cam


func toggle() -> void:
	visible_trajectory = not visible_trajectory
	queue_redraw()


func _process(_delta: float) -> void:
	if visible_trajectory:
		queue_redraw()


func _draw() -> void:
	if not visible_trajectory or rocket_data == null:
		return
	if rocket_data.landed or rocket_data.crashed:
		return
	if rocket_data.orbit == null:
		return

	var orbit = rocket_data.orbit
	var ws    = Config.WORLD_SCALE

	var line_width = 3.0 / camera.zoom.x
	
	if orbit.type == "ellipse":
		_draw_ellipse(orbit, ws, line_width)
	elif orbit.type == "hyperbola":
		_draw_hyperbola(orbit, ws, line_width)


func _draw_ellipse(orbit: Orbit, ws: float, line_width: float) -> void:
	var e 	  = orbit.e
	var a     = orbit.a
	var b     = a * sqrt(1.0 - e * e)
	var omega = orbit.omega

	# Center of ellipse is offset from focus by a*e in the periapsis direction
	var cx = -a * e * cos(omega)
	var cy = -a * e * sin(omega)

	var points   = PackedVector2Array()
	var angles 	 = Array()
	var angle = 0
	
	# if camera.zoom.x < 1:
	var segments = int(clamp(256 * camera.zoom.x, 128, 512))
	points.resize(segments + 1)
	angles.resize(segments + 1)
	var delta_angle_avg = TAU / segments
	for i in range(segments):
		angle += delta_angle_avg*(1 - cos(4*PI * i / segments))
		
		# Point on ellipse in orbital frame
		var px = a * cos(angle)
		var py = b * sin(angle)
		# Rotate by omega and translate to focus
		var rx = px * cos(omega) - py * sin(omega) + cx
		var ry = px * sin(omega) + py * cos(omega) + cy

		points[i] = Vector2(rx, -ry) * ws
		angles[i] = angle

		
	# var c_vec = [orbit.body_x - cx, orbit.body_y - cy]
	# var e_vec = [orbit.ex, orbit.ey]
	# var center_nu = Math.wrap2pi(sign(Math.cross_product2(e_vec, c_vec)) * Math.angle_between_vectors(c_vec, e_vec))

	# for i in range(1, segments):
	# 	if angles[i-1] < center_nu and center_nu <= angles[i]:
	# 		# Point on ellipse in orbital frame
	# 		var px = a * cos(center_nu)
	# 		var py = b * sin(center_nu)
	# 		# Rotate by omega and translate to focus
	# 		var rx = px * cos(omega) - py * sin(omega) + cx
	# 		var ry = px * sin(omega) + py * cos(omega) + cy

	# 		points[i] = Vector2(rx, -ry) * ws
	# 		angles[i] = angle
	# 		break
	# else:
	# 	var c_vec = [orbit.body_x - cx, orbit.body_y - cy]
	# 	var e_vec = [orbit.ex, orbit.ey]
	# 	var center_nu = Math.wrap2pi(sign(Math.cross_product2(e_vec, c_vec)) * Math.angle_between_vectors(c_vec, e_vec))
	# 	var angle_interval = 200000.0 / camera.zoom.x
	# 	var segments = int(clamp(128 * camera.zoom.x, 128, 256))
	# 	angle_interval = deg_to_rad(clamp(angle_interval, 15, 180))
	# 	points.resize(segments + 1)
	# 	for i in range(segments):
	# 		angle = center_nu + angle_interval * (float(i) - float(segments) / 2) / float(segments)
			
	# 		# Point on ellipse in orbital frame
	# 		var px = a * cos(angle)
	# 		var py = b * sin(angle)
	# 		# Rotate by omega and translate to focus
	# 		var rx = px * cos(omega) - py * sin(omega) + cx
	# 		var ry = px * sin(omega) + py * cos(omega) + cy

	# 		points[i] = Vector2(rx, -ry) * ws

	# Draw full ellipse — split into two colors: future and past
	draw_polyline(points, Color(0.0, 1.0, 0.5, 0.5), line_width, true)


func _draw_hyperbola(orbit: Orbit, ws: float, line_width: float) -> void:
	var a     = abs(orbit.a)
	var omega = orbit.omega

	# Maximum true anomaly before asymptote
	var max_nu = acos(-1.0 / orbit.e) * 0.98

	var points   = PackedVector2Array()
	var segments = int(clamp(256 * camera.zoom.x, 128, 512))

	for i in range(segments + 1):
		var nu = lerp(-max_nu, max_nu, float(i) / segments)
		# Polar equation of hyperbola
		var r_nu = a * (orbit.e * orbit.e - 1.0) / (1.0 + orbit.e * cos(nu))
		if r_nu < 0:
			continue
		var px = r_nu * cos(nu)
		var py = r_nu * sin(nu)
		# Rotate by omega
		var rx = px * cos(omega) - py * sin(omega)
		var ry = px * sin(omega) + py * cos(omega)
		points.append(Vector2(rx, -ry) * ws)

	draw_polyline(points, Color(1.0, 0.5, 0.0, 0.5), line_width, true)
