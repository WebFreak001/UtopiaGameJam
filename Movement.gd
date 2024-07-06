extends XROrigin3D

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _process(delta):
	var input_dbg = Input.get_vector("move_left", "move_right", "move_back", "move_fwd")
	var input_both = $RightHand.get_vector2("primary")
	var input_move = $LeftHand.get_vector2("primary")
	
	if $LeftHand.get_is_active() and not $RightHand.get_is_active():
		input_both = $LeftHand.get_vector2("primary")
		input_move = Vector2.ZERO

	input_move.y += input_both.y
	var rot = input_both.x
	
	var input = input_move if $RightHand.get_is_active() or $LeftHand.get_is_active() else input_dbg
	
	var applied: Vector3 = ($XRCamera3D.global_transform.basis * Vector3(input.x, 0, -input.y)).normalized()
	
	if abs(applied.length_squared()) > 0.001 * 0.001:
		self.global_translate(Vector3(applied.x, 0, applied.z) * delta)

	if abs(rot) > 0.001:
		self.rotate_y(rot * -delta)

func _input(event):
	if event is InputEventMouseMotion and not $LeftHand.get_is_active() and not $RightHand.get_is_active():
		self.rotate_y(event.relative.x * -0.001)
	else:
		if event.is_action_pressed("ui_cancel"):
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			if event.is_action_pressed("click"):
				if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
					Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
					get_tree().set_input_as_handled()
