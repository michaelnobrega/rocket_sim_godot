class_name Math


# --- Vector arithmetic helpers (replaces numpy array operations) ---

static func wrap360(theta: float) -> float:
	return wrap(theta, 0, 360)


static func wrap2pi(theta: float) -> float:
	return wrap(theta, 0, 2*PI)


static func array_add(u: Array, v: Array) -> Array:
	
	var w = u.duplicate()

	for i in range(u.size()):
		w[i] = u[i] + v[i]

	return w


static func array_scale(u: Array, k: float) -> Array:

	var w = u.duplicate()

	for i in range(u.size()):
		w[i] = k * u[i]

	return w


static func array_abs(u: Array) -> float:

	var result: float = 0.0

	for i in range(u.size()):
		result += u[i] * u[i]

	result = sqrt(result)

	return result



static func inner_product(a: Array, b: Array) -> float:
	# Input verification

	# assert(a.size() > 0 and b.size() > 0, "Vectors can't be empty.")
	# assert(a.size() == b.size(), "Vectors must have the same dimension.")
	
	# for i in range(a.size()):
	#     assert(typeof(a[i]) in [TYPE_INT, TYPE_FLOAT], "All elements of 'a' must be numeric.")
	#     assert(typeof(b[i]) in [TYPE_INT, TYPE_FLOAT], "All elements of 'b' must be numeric.")
	
	var result: float = 0.0
	for i in range(a.size()):
		result += a[i] * b[i]

	return result


static func cross_product2(u: Array, v: Array) -> float:

	return u[0] * v[1] - v[0] * u[1]


static func angle_between_vectors(u: Array, v: Array) -> float:

	return acos(inner_product(u, v) / (array_abs(u) * array_abs(v)))


# --- RK4 integrator ---

static func rk4(state: Array, f: Callable, dt: float) -> Array:
	var k1 = f.call(state)
	var k2 = f.call(array_add(state, array_scale(k1, dt / 2.0)))
	var k3 = f.call(array_add(state, array_scale(k2, dt / 2.0)))
	var k4 = f.call(array_add(state, array_scale(k3, dt)))
	var weighted = array_add(
		array_add(k1, array_scale(k2, 2.0)),
		array_add(array_scale(k3, 2.0), k4)
	)
	return array_add(state, array_scale(weighted, dt / 6.0))
