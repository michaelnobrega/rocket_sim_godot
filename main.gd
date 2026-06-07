extends Node2D

@onready var camera = $Camera
@onready var ui_layer = $UILayer

const RocketScene = preload("res://scenes/rocket.tscn")
const EarthScene = preload("res://scenes/earth.tscn")
const TrajectoryScene = preload("res://scenes/trajectory.tscn")
const HUDScene = preload("res://scenes/hud.tscn")

var rocket: Rocket
var rocket_node: Node2D
var earth_node: Node2D
var elapsed: float = 0.0
var hud_node: Control
var trajectory_node: Node2D


func _ready() -> void:
	# Earth
	earth_node = EarthScene.instantiate()
	add_child(earth_node)
	earth_node.setup(Config.EARTH_RADIUS_M, Config.WORLD_SCALE, camera)
	earth_node.position = Vector2.ZERO

	# Rocket
	rocket = Rocket.new()
	rocket_node = RocketScene.instantiate()
	rocket_node.setup(rocket)
	add_child(rocket_node)
	rocket_node.position = Vector2(rocket.x, -rocket.y) * Config.WORLD_SCALE
	rocket.engine_on = false

	# Trajectory
	trajectory_node = TrajectoryScene.instantiate()
	add_child(trajectory_node)
	trajectory_node.setup(rocket, camera)

	# Camera starts at rocket position
	camera.zoom = Vector2(Config.ZOOM_INIT, Config.ZOOM_INIT)
	camera.position = rocket_node.position

	# HUD
	hud_node = HUDScene.instantiate()
	ui_layer.add_child(hud_node)
	hud_node.setup(rocket)


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_SPACE:
			if not rocket.crashed:
				rocket.engine_on = not rocket.engine_on
		if event.keycode == KEY_T:
			trajectory_node.toggle()
		if event.keycode == KEY_R:
			rocket.reset()


func _process(delta: float) -> void:
	elapsed += delta

	# Input
	if Input.is_key_pressed(KEY_LEFT):
		rocket.theta += rocket.max_attitude_rate * delta

	if Input.is_key_pressed(KEY_RIGHT):
		rocket.theta -= rocket.max_attitude_rate * delta

	if Input.is_key_pressed(KEY_A):
		rocket.deflect_nozzle(delta, "L", 0.3)
	elif Input.is_key_pressed(KEY_D):
		rocket.deflect_nozzle(delta, "R", 0.3)
	else:
		rocket.deflect_nozzle(delta)

	# Update physics
	Physics.update_physics(rocket, delta)

	# Update visual position and rotation
	rocket_node.position = Vector2(rocket.x, -rocket.y) * Config.WORLD_SCALE
	rocket_node.rotation = deg_to_rad(-(rocket.theta - 90.0))

	# Camera follows rocket
	camera.position = rocket_node.position
	camera.rotation = -deg_to_rad(rocket.horizontal_angle())
