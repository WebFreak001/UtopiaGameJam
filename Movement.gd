extends XROrigin3D

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _process(delta):
	var debug_input = Input.get_vector("debug_move_left", "debug_move_right", "debug_move_fwd", "debug_move_back")
	
	var applied = ($XRCamera3D.global_transform.basis * Vector3(debug_input.x, 0, debug_input.y)).normalized()
	
	self.global_translate(Vector3(applied.x, 0, applied.z) * 0.01)

func _input(event):
	if event is InputEventMouseMotion:
		self.rotate_y(event.relative.x * -0.001)
	else:
		if event.is_action_pressed("ui_cancel"):
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			if event.is_action_pressed("click"):
				if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
					Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
					get_tree().set_input_as_handled()
