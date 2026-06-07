# hud_node.gd — telemetry display
extends Control

@onready var label = $TelemetryLabel

var rocket_data: Rocket


func setup(data: Rocket) -> void:
	rocket_data = data


func _ready() -> void:
	anchor_right  = 1.0
	anchor_bottom = 1.0

func _process(_delta: float) -> void:
	if rocket_data == null:
		return

	var alt_km     = rocket_data.radial_distance() / 1000.0 - Config.EARTH_RADIUS_M / 1000.0
	var speed_ms   = rocket_data.speed()
	var vert_speed = rocket_data.vertical_speed()
	var hor_speed  = rocket_data.horizontal_speed()
	var fuel_t     = rocket_data.mass_fuel / 1000.0
	var mass_t     = rocket_data.total_mass() / 1000.0
	var g          = abs(Gravity.calculate_gravity(rocket_data.radial_distance()))
	var isa        = Atmosphere.calculate_isa(rocket_data.radial_distance() - Config.EARTH_RADIUS_M)
	var mach       = speed_ms / isa["soundspeed"]
	var engine_str = "ON 🔥" if rocket_data.engine_on else "off"
	
	label.text = "ROCKET SIM\n"
	label.text += "\nAltitude:   %8.2f km"     % [alt_km]
	label.text += "\nSpeed:      %8.1f m/s"    % [speed_ms]
	label.text += "\nMach:       %8.2f"        % [mach]
	label.text += "\nVert. vel:  %+8.1f m/s"  % [vert_speed]
	label.text += "\nHor. vel:   %+8.1f m/s"  % [hor_speed]
	label.text += "\nFPA:   	 %3.1f deg"    % [rocket_data.flight_path_angle()]
	label.text += "\nAttitude:   %3.1f deg"    % [rocket_data.theta]
	label.text += "\nOmega:      %3.1f deg"   % [rocket_data.omega]
	label.text += "\nGravity:    %8.4f m/s²"  % [g]
	label.text += "\nEngine:     %s"           % [engine_str]
	label.text += "\nFuel:       %7.1f t"      % [fuel_t]
	label.text += "\nMass:       %7.1f t"      % [mass_t]
	label.text += "\nNozzle:     %2.1f deg"    % [rocket_data.nozzle_angle]
	
	if rocket_data.orbit:
		label.text += "\nOrbit:      %s"        % [rocket_data.orbit.type]
		label.text += "\nApoapsis:   %8.2f km"  % [rocket_data.orbit.apoapsis() / 1000.0]
		label.text += "\nPeriapsis:  %8.2f km"  % [rocket_data.orbit.periapsis() / 1000.0]

	if rocket_data.crashed:
		label.text += "\n\n*** CRASH! Press R ***"
	elif rocket_data.landed:
		label.text += "\n\nLanded. [SPACE] to launch"