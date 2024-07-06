extends CSGPolygon3D

# Called when the node enters the scene tree for the first time.
func _ready():
	var outline = [PackedVector3Array(), PackedVector3Array()]
	var normals2d = PackedVector2Array()
	
	seed(420691337)

	for i in range(0, len(self.polygon)):
		var v = self.polygon[i]
		var prev = self.polygon[len(self.polygon) - 1] if i == 0 else self.polygon[i - 1]

		var d = (v - prev).normalized()
		var nrm = Vector2(-d.y, d.x)
		normals2d.append(nrm)

		outline[0].append(Vector3(v.x, v.y, 0))
		var v2 = v + nrm * (0.3 + 0.3 * randf())
		outline[1].append(Vector3(v2.x, v2.y, 1.1 + randf() * 0.2))
		#var v3 = v - nrm * (0.3 + 0.3 * randf())
		#outline[2].append(Vector3(v3.x, v3.y, 1.6 + randf() * 0.2))
		#var v4 = v2 - nrm * (0.5 + 0.2 * randf())
		#outline[2].append(Vector3(v4.x, v4.y, 1.9))

	var walls = MeshInstance3D.new()
	walls.mesh = ArrayMesh.new()

	var vertices_unindexed = PackedVector3Array()
	var vertices = PackedVector3Array()
	var normals = PackedVector3Array()
	var uvs = PackedVector2Array()
	var indices = PackedInt32Array()
	
	var num_outlines = len(outline)
	for i in range(0, num_outlines - 1):
		var num_verts = len(outline[i])
		for j in range(0, num_verts + 1):
			var a = outline[i][0] if j == num_verts else outline[i][j]
			var b = outline[i + 1][0] if j == num_verts else outline[i + 1][j]
			var c = outline[i][num_verts - 1] if j == 0 else outline[i][j - 1]
			var d = outline[i + 1][num_verts - 1] if j == 0 else outline[i + 1][j - 1]
			
			var u = a - b
			var v = a - c

			var nrm = Vector3(
				u.y * v.z - u.z * v.y,
				u.z * v.x - u.x * v.z,
				u.x * v.y - u.y * v.x,
			).normalized()

			var idx = len(vertices)
			vertices.append_array([a, b, c, d])
			normals.append_array([nrm, nrm, nrm, nrm])
			uvs.append(Vector2(j / float(num_verts), i / float(num_outlines)))
			uvs.append(Vector2(j / float(num_verts), (i + 1) / float(num_outlines)))
			uvs.append(Vector2((j + 1) / float(num_verts), i / float(num_outlines)))
			uvs.append(Vector2((j + 1) / float(num_verts), (i + 1) / float(num_outlines)))
			
			indices.append_array([
				idx + 2, idx + 1, idx,
				idx + 2, idx + 3, idx + 1
			])
			vertices_unindexed.append_array([
				c, b, a,
				c, d, b
			])

	var top = outline[len(outline) - 1]
	var num_verts = len(top)
	for i in range(0, num_verts + 1):
		var a = top[0] if i == num_verts else top[i]
		var an = normals2d[0 if i == num_verts else i]
		var b = get_roof_vert(a - Vector3(an.x, an.y, 0) * 4)
		var c = top[num_verts - 1] if i == 0 else top[i - 1]
		var cn = normals2d[num_verts - 1 if i == 0 else i - 1]
		var d = get_roof_vert(c - Vector3(cn.x, cn.y, 0) * 4)
		
		var u = a - b
		var v = a - c

		var nrm = Vector3(
			u.y * v.z - u.z * v.y,
			u.z * v.x - u.x * v.z,
			u.x * v.y - u.y * v.x,
		).normalized()

		var idx = len(vertices)
		vertices.append_array([a, b, c, d])
		normals.append_array([nrm, nrm, nrm, nrm])
		uvs.append(Vector2(i / float(num_verts), 0.5))
		uvs.append(Vector2(i / float(num_verts), 1.0))
		uvs.append(Vector2((i + 1) / float(num_verts), 0.5))
		uvs.append(Vector2((i + 1) / float(num_verts), 1.0))
		
		indices.append_array([
			idx + 2, idx + 1, idx,
			idx + 2, idx + 3, idx + 1
		])
		vertices_unindexed.append_array([
			c, b, a,
			c, d, b
		])
	
	var arrays = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_NORMAL] = normals
	arrays[Mesh.ARRAY_TEX_UV] = uvs
	arrays[Mesh.ARRAY_INDEX] = indices

	walls.mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	walls.mesh.surface_set_material(0, self.material_override)
	add_child(walls)

	var collider = StaticBody3D.new()
	var collision_mesh = CollisionShape3D.new()
	var collision_shape = ConcavePolygonShape3D.new()
	collision_shape.set_faces(vertices_unindexed)
	collision_mesh.shape = collision_shape
	collider.add_child(collision_mesh)
	add_child(collider)

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
