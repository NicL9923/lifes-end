extends Spatial

onready var mesh_inst = $MeshInstance
onready var planet_radius = mesh_inst.mesh.radius

func get_coords_from_lat_long(lat, long):
	var x = planet_radius * cos(lat) * cos(long)
	var y = planet_radius * cos(lat) * sin(long)
	var z = planet_radius * sin(lat)
	
	return Vector3(x, y, z)
