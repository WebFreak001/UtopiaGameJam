extends Area3D

var hand: XRController3D
var grabbed: RigidBody3D
var grab_offset: Vector3

func _ready():
	hand = get_parent()
	body_entered.connect(highlight_body)
	body_exited.connect(unhighlight_body)
	
	hand.input_float_changed.connect(on_input)

func on_input(name: String, value: float):
	if name == "grip":
		if value > 0.5 and grabbed == null:
			grab()
		elif value < 0.5 and grabbed != null:
			ungrab()

func highlight_body(body: Node3D):
	pass

func unhighlight_body(body: Node3D):
	pass

func grab():
	for body in self.get_overlapping_areas():
		if body is GrabbableArea:
			grabbed = body.get_parent() as RigidBody3D
			grabbed.gravity_scale = 0
			grab_offset = body.position
			return

func ungrab():
	grabbed.gravity_scale = 1
	grabbed = null

func _physics_process(delta):
	if grabbed != null:
		grabbed.move_and_collide((global_position - grabbed.global_position + grab_offset * grabbed.quaternion) * 10 * delta)
		grabbed.apply_central_force(Vector3(0, 100, 0) * delta)
