extends Label3D

var ascend_vel = Vector3(0,5,0)

func _physics_process(delta: float) -> void:
	translation += ascend_vel * delta
	ascend_vel /= 1.1
	
	if ascend_vel.length() < 0.002:
		queue_free()
