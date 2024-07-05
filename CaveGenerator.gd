extends CSGPolygon3D

# Called when the node enters the scene tree for the first time.
func _ready():
	var outline = [PackedVector3Array(), PackedVector3Array()]
	var normals = PackedVector2Array()

	for i in range(0, len(self.polygon)):
		var v = self.polygon[i]
		var prev = self.polygon[len(self.polygon) - 1] if i == 0 else self.polygon[i - 1]

		var d = (v - prev).normalized()
		var nrm = Vector2(-d.y, d.x)
		normals.append(nrm)

		outline[0].append(Vector3(v.x, v.y, 0))
		var v2 = v + nrm * (0.3 + 0.3 * randf())
		outline[1].append(Vector3(v2.x, v2.y, 1.1 + randf() * 0.2))
		#var v3 = v - nrm * (0.3 + 0.3 * randf())
		#outline[2].append(Vector3(v3.x, v3.y, 1.6 + randf() * 0.2))
		#var v4 = v2 - nrm * (0.5 + 0.2 * randf())
		#outline[2].append(Vector3(v4.x, v4.y, 1.9))

	for i in range(0, len(outline) - 1):
		var walls = MeshInstance3D.new()
		walls.mesh = ArrayMesh.new()
		var vertices = PackedVector3Array()
		for j in range(0, len(outline[i])):
			vertices.append(outline[i][j])
			vertices.append(outline[i + 1][j])
		vertices.append(vertices[0])
		vertices.append(vertices[1])
		
		var arrays = []
		arrays.resize(Mesh.ARRAY_MAX)
		arrays[Mesh.ARRAY_VERTEX] = vertices

		walls.mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLE_STRIP, arrays)
		walls.mesh.surface_set_material(0, self.material_override)
		add_child(walls)

	var roof = MeshInstance3D.new()
	roof.mesh = ArrayMesh.new()
	var vertices = PackedVector3Array()
	for i in range(0, len(outline[len(outline) - 1])):
		var v = outline[len(outline) - 1][i]
		vertices.append(v)
		vertices.append(get_roof_vert(v - Vector3(normals[i].x, normals[i].y, 0)))
	vertices.append(vertices[0])
	vertices.append(vertices[1])
	
	var arrays = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices

	roof.mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLE_STRIP, arrays)
	roof.mesh.surface_set_material(0, self.material_override)
	add_child(roof)

func get_roof_vert(v):
	var closest = v
	var closest_d = INF
	for curve in get_children():
		if curve is Path3D:
			var lv = curve.to_local(to_global(v))
			for i in range(0, curve.curve.point_count):
				var c = curve.curve.get_point_position(i)
				var d = c.distance_squared_to(lv)
				if d < closest_d:
					closest_d = d
					closest = to_local(curve.to_global(c))
	return closest
