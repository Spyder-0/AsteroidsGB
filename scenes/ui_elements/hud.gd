extends CanvasLayer

@onready var warning_sprite_parent: Node2D = $WraningSpriteInstances
@onready var life_progress_bar: ProgressBar = $BottomColorRect/LifeHBoxContainer/LifeProgressBar
@onready var score_count_label: Label = $BottomColorRect/ScoreHBoxContainer/ScoreCountLabel
@onready var ready_indicator: Node = $MiddleColorRect
@onready var power_up_label: Label = $PowerUpLabel
@onready var exit_label: Label = $ExitLabel
@onready var meteor_warn_sound_effect: AudioStreamPlayer = $MeteorWarnSFX
@onready var level_up_sound_effect: AudioStreamPlayer = $LevelUpSFX
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var secondary_animation_player: AnimationPlayer = $SecondaryAnimationPlayer

var warning_sprite_scene: PackedScene = preload("res://scenes/ui_elements/warning_sprite.tscn")


func _ready():
	exit_label.visible = false
	update_hud_stats() # Stats also need to be updated in this function because wrong variables may appear (only) on the first frame once the scene is loaded. This is purely to fix asthetics.

func _process(_delta: float):
	update_hud_stats()

func update_hud_stats():
	life_progress_bar.value = Globals.player_health
	score_count_label.text = str(Globals.player_score)

func remove_ready_indicator():
	animation_player.play("remove_ready_indicator")

func display_power_up_notification(collected_power_up_type: PowerUp.PowerUpType):
	match collected_power_up_type:
		PowerUp.PowerUpType.HEAL:
			power_up_label.text = "+HEALTH"
		PowerUp.PowerUpType.RAPID:
			power_up_label.text = "+RAPID"
		PowerUp.PowerUpType.ACCELERATION:
			power_up_label.text = "+ACCEL"
		PowerUp.PowerUpType.BUSTERJAM:
			power_up_label.text = "!BUSTER-JAM"
		PowerUp.PowerUpType.METEORSHOWER:
			power_up_label.text = "!METEOR-SHOWER"
	
	animation_player.play("power_up_notification")

func display_meteor_warning(meteor_position: Vector2):
	var warning_sprite_instance: Sprite2D = warning_sprite_scene.instantiate()
	warning_sprite_instance.global_position.x = meteor_position.x
	
	warning_sprite_parent.call_deferred("add_child", warning_sprite_instance)
	meteor_warn_sound_effect.play()

func display_level_up_notification():
	secondary_animation_player.play("level_up")
	level_up_sound_effect.play()

func display_exit_notification():
	exit_label.visible = true
	await get_tree().create_timer(2.0, false, false, false).timeout
	exit_label.visible = false
