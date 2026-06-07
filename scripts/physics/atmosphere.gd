# atmosphere.gd — atmospheric model (ISA)
class_name Atmosphere

const EARTH_RADIUS_M = 600_000.0
const AIR_CONSTANT_R     = 287.0
const GAMMA              = 1.4
const SL_TEMPERATURE     = 288.15
const SL_DENSITY         = 1.225
const SL_PRESSURE        = 101325.0

const TROPO_LAMBDA       = -6.5e-3
const TROPO_BOT          = -2000.0
const TROPO_TOP          = 11000.0
const TROPOPAUSE_TOP     = 20000.0

const LOW_STRATO_LAMBDA  =  1.0e-3
const LOW_STRATO_TOP     = 32000.0
const HIGH_STRATO_LAMBDA =  2.8e-3
const HIGH_STRATO_TOP    = 47000.0
const STRATOPAUSE_TOP    = 51000.0

const LOW_MESO_LAMBDA    = -2.8e-3
const LOW_MESO_TOP       = 71000.0
const HIGH_MESO_LAMBDA   = -2.0e-3
const HIGH_MESO_TOP      = 84852.0
const MESOPAUSE_TOP      = 90000.0


static func calculate_isa(r: float) -> Dictionary:
	var altitude: float = max(TROPO_BOT, r-EARTH_RADIUS_M)
	var g = Gravity.calculate_gravity(r)

	# TROPOSPHERE
	var temperature = SL_TEMPERATURE + TROPO_LAMBDA * min(TROPO_TOP, altitude)
	var pressure    = _air_pressure(temperature, TROPO_LAMBDA, SL_TEMPERATURE, SL_PRESSURE, g)
	var density     = _air_density(temperature,  TROPO_LAMBDA, SL_TEMPERATURE, SL_DENSITY,  g)

	# TROPOPAUSE
	if altitude >= TROPO_TOP:
		pressure = _air_pressure_pause(altitude, TROPO_TOP, temperature, pressure, g)
		density  = _air_density_pause(altitude,  TROPO_TOP, temperature, density,  g)

	# LOW STRATOSPHERE
	if altitude >= TROPOPAUSE_TOP:
		temperature += LOW_STRATO_LAMBDA * (min(LOW_STRATO_TOP, altitude) - TROPOPAUSE_TOP)
		pressure = _air_pressure(temperature, LOW_STRATO_LAMBDA, temperature, pressure, g)
		density  = _air_density(temperature,  LOW_STRATO_LAMBDA, temperature, density,  g)

	# HIGH STRATOSPHERE
	if altitude >= LOW_STRATO_TOP:
		temperature += HIGH_STRATO_LAMBDA * (min(HIGH_STRATO_TOP, altitude) - LOW_STRATO_TOP)
		pressure = _air_pressure(temperature, HIGH_STRATO_LAMBDA, temperature, pressure, g)
		density  = _air_density(temperature,  HIGH_STRATO_LAMBDA, temperature, density,  g)

	# STRATOPAUSE
	if altitude >= HIGH_STRATO_TOP:
		pressure = _air_pressure_pause(altitude, HIGH_STRATO_TOP, temperature, pressure, g)
		density  = _air_density_pause(altitude,  HIGH_STRATO_TOP, temperature, density,  g)

	# LOW MESOSPHERE
	if altitude >= STRATOPAUSE_TOP:
		temperature += LOW_MESO_LAMBDA * (min(LOW_MESO_TOP, altitude) - STRATOPAUSE_TOP)
		pressure = _air_pressure(temperature, LOW_MESO_LAMBDA, temperature, pressure, g)
		density  = _air_density(temperature,  LOW_MESO_LAMBDA, temperature, density,  g)

	# HIGH MESOSPHERE
	if altitude >= LOW_MESO_TOP:
		temperature += HIGH_MESO_LAMBDA * (min(HIGH_MESO_TOP, altitude) - LOW_MESO_TOP)
		pressure = _air_pressure(temperature, HIGH_MESO_LAMBDA, temperature, pressure, g)
		density  = _air_density(temperature,  HIGH_MESO_LAMBDA, temperature, density,  g)

	# MESOPAUSE
	if altitude >= HIGH_MESO_TOP:
		pressure = _air_pressure_pause(altitude, HIGH_MESO_TOP, temperature, pressure, g)
		density  = _air_density_pause(altitude,  HIGH_MESO_TOP, temperature, density,  g)

	var soundspeed = sqrt(GAMMA * AIR_CONSTANT_R * temperature)

	return {
		"temperature": temperature,
		"pressure":    pressure,
		"density":     density,
		"soundspeed":  soundspeed,
	}


static func _air_density(temperature, layer_lambda, base_temperature, base_density, g) -> float:
	return base_density * pow(temperature / base_temperature, -1.0 + g / (AIR_CONSTANT_R * layer_lambda))

static func _air_pressure(temperature, layer_lambda, base_temperature, base_pressure, g) -> float:
	return base_pressure * pow(temperature / base_temperature, g / (AIR_CONSTANT_R * layer_lambda))

static func _air_density_pause(altitude, base_altitude, base_temperature, base_density, g) -> float:
	return base_density * exp(g * (altitude - base_altitude) / (AIR_CONSTANT_R * base_temperature))

static func _air_pressure_pause(altitude, base_altitude, base_temperature, base_pressure, g) -> float:
	return base_pressure * exp(g * (altitude - base_altitude) / (AIR_CONSTANT_R * base_temperature))