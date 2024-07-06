class_name GrabbableArea
extends Area3D

func _ready():
	var collider = CollisionShape3D.new()
	var sphere = SphereShape3D.new()
	sphere.radius = 0.05
	collider.shape = sphere
	add_child(collider)
