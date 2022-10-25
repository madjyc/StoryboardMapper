extends CPUParticles2D

func _ready():
	# Start the emitter
	one_shot = true # Security
	emitting = true
	
	# Wait for particles' lifetime and die quietly.
	yield(get_tree().create_timer(lifetime), 'timeout')
	queue_free()
