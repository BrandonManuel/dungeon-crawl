@tool
extends CPUParticles2D

@export var capture_to: ParticlePreset
@export var do_capture: bool = true:
	set(v):
		if v and capture_to:
			for prop in capture_to.get_property_list():
				if prop.usage & PROPERTY_USAGE_SCRIPT_VARIABLE:
					capture_to.set(prop.name, get(prop.name))
			ResourceSaver.save(capture_to, capture_to.resource_path)
		do_capture = true
