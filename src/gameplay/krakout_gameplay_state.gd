extends RefCounted
class_name KrakoutGameplayState

const RandomScript := preload("res://src/gameplay/krakout_random.gd")
const BallRulesScript := preload("res://src/gameplay/rules/krakout_ball_rules.gd")
const RacketRulesScript := preload("res://src/gameplay/rules/krakout_racket_rules.gd")
const BonusCatalogScript := preload("res://src/gameplay/rules/krakout_bonus_catalog.gd")

const PHASE_READY := "ready"

var board_state
var phase := PHASE_READY
var balls: Array[Dictionary] = []
var ball_tracks_enabled := true
var ball_tracks: Array = []
var racket_y := RacketRulesScript.RACKET_MIN_Y
var racket_segment_count := RacketRulesScript.RACKET_DEFAULT_SEGMENTS
var ball_size := BallRulesScript.BALL_SIZE
var ball_speed_scale := BallRulesScript.BALL_DEFAULT_SPEED_SCALE
var board_changed := false
var score := 0
var displayed_score := 0
var best_score := 0
var lives_remaining := 3
var points_to_next_extra_life := 20000
var display_level_number := 1
var bonus_stock_counts: Array[int] = []
var remaining_bonus_stock := 0
var falling_bonuses: Array[Dictionary] = []
var bonus_stack: Array[Dictionary] = []
var bonus_pointer_frame := 0
var projectiles: Array[Dictionary] = []
var monsters: Array[Dictionary] = []
var bees: Array[Dictionary] = []
var snake_segments: Array[Dictionary] = []
var impact_effects: Array[Dictionary] = []
var score_popups: Array[Dictionary] = []
var back_wall_time_remaining := 0.0
var level_ready_time_remaining := 0.0
var low_block_timer_time_remaining := 0.0
var drunk_paddle_time_remaining := 0.0

var bonus_rng: KrakoutRandom = RandomScript.new()
var ball_animation_rng: KrakoutRandom = RandomScript.new(31415)
var bonus_animation_rng: KrakoutRandom = RandomScript.new(31415)
var monster_rng: KrakoutRandom = RandomScript.new(31415)
var collision_rng: KrakoutRandom = RandomScript.new(31415)
var ball_track_rng: KrakoutRandom = RandomScript.new(31415)

var bonus_drop_cooldown := BonusCatalogScript.BONUS_DROP_GATE_SECONDS
var bonus_pointer_elapsed := 0.0
var shooting_paddle_mode := 0
var racket_visual_mode := RacketRulesScript.RACKET_VISUAL_MODE_NORMAL
var racket_visual_frame := 0
var racket_visual_target_mode := RacketRulesScript.RACKET_VISUAL_MODE_NORMAL
var racket_visual_elapsed := 0.0
var racket_hit_recoil_offset_x := 0.0
var racket_hit_recoil_elapsed := 0.0
var single_shot_projectile_armed := false
var double_paddle_active := false
var double_paddle_x := RacketRulesScript.RACKET_X + RacketRulesScript.DOUBLE_PADDLE_OFFSET_X
var magnet_paddle_active := false
var last_racket_input_y := RacketRulesScript.RACKET_READY_CENTER_Y
var last_racket_input_x := RacketRulesScript.RACKET_X
var has_last_racket_input := false
var has_last_racket_x_input := false
var level_ready_animation_time_remaining := 0.0
var level_ready_roller_offset := 0.0
var level_ready_roller_frame := 0
var level_ready_roller_step_elapsed := 0.0
var level_ready_auto_launch_pending := false
var low_block_timer_started := false
var ball_track_spawn_elapsed: Array[float] = []
var audio_events: Array[Dictionary] = []

var audio_event_queue
var ball_system
var ball_track_pool
var bonus_system
var enemy_hazard_system
var projectile_system
var gameplay_context
var racket_system
var transient_vfx_pool
