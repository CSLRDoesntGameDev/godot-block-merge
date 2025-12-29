class_name Block extends RigidBody2D

const BLOCK_PHYSICS_MATERIAL = preload("uid://dw40odb5wc13r")
const FONT = preload("res://resource/Kenney Future.ttf")

var render_size = Vector2(64, 64)
var po2: int = 1
var collision := CollisionShape2D.new()

var active: bool

func _ready() -> void:
	self.physics_material_override = BLOCK_PHYSICS_MATERIAL
	add_child(collision)
	
	collision.shape = RectangleShape2D.new()
	collision.shape.size = render_size
	collision.position = render_size/2
	
	contact_monitor = true
	max_contacts_reported = 10
	
	CurrentGame.clear.connect(delete)

func delete() -> void:
	modulate.g = .5
	modulate.b = .5
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 0.0, .5)
	await tween.finished
	queue_free()

func _physics_process(delta: float) -> void:
	freeze = not active
	
	if get_contact_count() > 0:
		check_for_blocks()
	
	queue_redraw()

func _draw() -> void:
	draw_rect(Rect2(Vector2.ONE, render_size), Color.from_hsv(float(po2)/32.0,1.0,1.0))
	
	var text: String = str(CurrentGame.get_po2_value(po2))
	draw_string(FONT, Vector2(2, render_size.y/2), text,
		HORIZONTAL_ALIGNMENT_CENTER, render_size.x, 16, Color.BLACK)

func check_for_blocks() -> void:
	var colliding_bodies: Array[Node2D] = get_colliding_bodies()
	for body: Node2D in colliding_bodies:
		if body is Block:
			if body.po2 == self.po2 and body.active and self.active:
				var direction: Vector2 = self.global_position.direction_to(body.global_position)
				
				apply_impulse(direction * 200.0)
				
				body.queue_free()
				self.po2 += 1
				
				CurrentGame.total_score += CurrentGame.get_po2_value(self.po2)
				
				if self.po2 > CurrentGame.highest_po2:
					CurrentGame.highest_po2 = self.po2
