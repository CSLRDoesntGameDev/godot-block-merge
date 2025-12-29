extends Control
@onready var score_label: Label = %ScoreLabel
@onready var new_po_2_label: Label = %NewPo2Label
@onready var mute: TextureButton = $Mute
@onready var music: AudioStreamPlayer = %Music

func _ready() -> void:
	CurrentGame.game_scene = self
	new_po_2_label.hide()

func _process(delta: float) -> void:
	score_label.text = str(CurrentGame.total_score)
	music.volume_linear = .2 if mute.button_pressed else 0.0

func notify_new_po2(new_po2: int) -> void:
	new_po_2_label.text = str("New Number! %s" % new_po2)
	new_po_2_label.show()
	
	get_tree().create_timer(1.5).timeout.connect(new_po_2_label.hide)
