extends Node2D

var radius_px: float = 1.0
var camera: Camera2D
var _last_zoom: float = -1.0


@onready var atmosphere = $Atmosphere


func setup(radius_m: float, world_scale: float, cam: Camera2D) -> void:
	radius_px = radius_m * world_scale
	camera = cam
	atmosphere.z_index = -1  # renderiza abaixo do _draw()
	
	# Scale atmosphere sprite to match planet size
	var texture_size = atmosphere.texture.get_size().x
	var target_size = radius_px * 2.35  # 110% of diameter
	var scale_factor = target_size / texture_size
	atmosphere.scale = Vector2(scale_factor, scale_factor)

	queue_redraw()


func _process(_delta: float) -> void:
	if camera and camera.zoom.x != _last_zoom:
		_last_zoom = camera.zoom.x
		queue_redraw()


func _draw() -> void:
	var zoom_level = 1.0
	if camera:
		zoom_level = camera.zoom.x
	var segments = int(clamp(64 * zoom_level, 128, 4096))

	# Build circle polygon manually for smooth edges at any zoom
	var points = PackedVector2Array()
	for i in range(segments):
		var angle = TAU * i / segments
		points.append(Vector2(cos(angle), sin(angle)) * radius_px)
	draw_polygon(points, PackedColorArray([Color(0.1, 0.3, 0.6)]))

	# Longitude markers every 1 degree
	var font = ThemeDB.fallback_font
	var font_size = max(8, int(radius_px * 0.015))
	var marker_w = radius_px * (4.0 / Config.EARTH_RADIUS_M) * 100
	var marker_h = radius_px * (20.0 / Config.EARTH_RADIUS_M) * 100

	for deg in range(0, 360):
		var angle_rad = deg_to_rad(float(deg))
		var mx = cos(angle_rad) * radius_px
		var my = -sin(angle_rad) * radius_px

		# Direction vector (radial outward)
		var dir = Vector2(cos(angle_rad), -sin(angle_rad))
		var perp = Vector2(-dir.y, dir.x)

		# Draw marker rectangle
		var p0 = Vector2(mx, my) - perp * marker_w / 2
		var p1 = Vector2(mx, my) + perp * marker_w / 2
		var p2 = p1 + dir * marker_h
		var p3 = p0 + dir * marker_h
		draw_colored_polygon([p0, p1, p2, p3], Color.WHITE)

		# Draw label every 10 degrees
		if deg % 10 == 0:
			var label_pos = Vector2(mx, my) + dir * (marker_h + font_size)
			draw_string(font, label_pos, str(deg) + "°",
				HORIZONTAL_ALIGNMENT_CENTER, -1, font_size, Color.WHITE)
