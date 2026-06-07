# config.gd — global constants and configuration
extends Node

# --- World ---
const EARTH_RADIUS_M = 600_000.0   # m — scaled down (like KSP)
const WORLD_SCALE    = 0.0005      # pixels per meter

# --- Physics ---
const G = 6.674e-11                # m³/kg·s² — gravitational constant
const M = 9.8 * 600_000.0 * 600_000.0 / 6.674e-11  # kg — Earth mass (adjusted for scaled radius)

# --- Camera ---
const ZOOM_MIN  = 0.1
const ZOOM_MAX  = 20000.0
const ZOOM_STEP = 0.1
const ZOOM_INIT = 10000.0