extends RefCounted
class_name KrakoutBonusCatalog

const BoardStateScript := preload("res://src/gameplay/krakout_board_state.gd")
const BallRulesScript := preload("res://src/gameplay/rules/krakout_ball_rules.gd")

const BONUS_TYPE_COUNT := 22
const BONUS_SELECTOR_COUNT := 23
const MAX_FALLING_BONUSES := 20
const MAX_STACKED_BONUSES := 16
const BONUS_DROP_GATE_SECONDS := 3.0
const BONUS_SIZE := 32.0
const ORIGINAL_BONUS_STEPS_PER_UPDATE := 3.0
const ORIGINAL_BONUS_SUBSTEP_HZ := BallRulesScript.ORIGINAL_UPDATE_HZ * ORIGINAL_BONUS_STEPS_PER_UPDATE
const BONUS_STEP_X := 1.5
const BONUS_WAVE_SCALE := 1.0 / 12.0
const BONUS_ANGLE_STEP := 3
const BONUS_MIN_Y := 10.0
const BONUS_MAX_Y := 438.0
const BONUS_EXPIRE_X := 600.0
const BONUS_ANIMATION_FRAME_COUNT := 10
const BONUS_FALLING_FRAME_SECONDS := 0.1
const BONUS_STACK_FRAME_SECONDS := 0.07
const BONUS_POINTER_FRAME_SECONDS := 0.05
const BACK_WALL_DURATION_SECONDS := 30.0
const BACK_WALL_STATUS_ICON_INDEX := 3
const LEVEL_READY_SEQUENCE_SECONDS := 30.0
const LEVEL_READY_STATUS_ICON_INDEX := 2
const RACKET_STUN_STATUS_ICON_INDEX := 1
const LOW_BLOCK_TIMER_TRIGGER_REQUIRED_BRICKS := 3
const LOW_BLOCK_TIMER_SECONDS := 30.0
const LOW_BLOCK_TIMER_STATUS_ICON_INDEX := 4
const LOW_BLOCK_TIMER_CHAIN_TILE_ID := 43
const LOW_BLOCK_TIMER_CHAIN_DELAY_SECONDS := 100.0 * BoardStateScript.CHAIN_EXPLOSION_DELAY_SECONDS

const BONUS_ADD_STANDARD_BALL := 0
const BONUS_ADD_FIREBALL := 1
const BONUS_NON_STRICKED_BALLS := 2
const BONUS_DECREASE_BALL_SIZE := 3
const BONUS_INCREASE_BALL_SIZE := 4
const BONUS_INCREASE_BALL_SPEED := 5
const BONUS_DECREASE_BALL_SPEED := 6
const BONUS_SHOOTING_PADDLE_TIMED := 7
const BONUS_SHOOTING_PADDLE_CONTINUOUS := 8
const BONUS_SHRINK_PADDLE := 9
const BONUS_EXPAND_PADDLE := 10
const BONUS_DOUBLE_PADDLE := 11
const BONUS_MAGNET_PADDLE := 12
const BONUS_BACK_WALL := 13
const BONUS_EXTRA_LIFE := 14
const BONUS_DESTROY_ONE_BALL := 15
const BONUS_RANDOM_BONUS := 16
const BONUS_ONE_STRIKE_BRICKS := 17
const BONUS_DRUNK_PADDLE := 18
const BONUS_EXPAND_EXPLODING := 19
const BONUS_JUMP_TO_NEXT_LEVEL := 20
const BONUS_EXPLODE_ALL_EXPLODINGS := 21

const BONUS_TYPE_NAMES := [
	"Add standard Ball",
	"Add FireBall",
	"All Balls non stricked (8 sec)",
	"Decrease all Ball size",
	"Increase all Ball size",
	"Increase all Ball speed",
	"Decrease all Ball speed",
	"Shooting Paddle (on time shoot)",
	"Shooting Paddle (continiously)",
	"Shrink Paddle size",
	"Expand Paddle size",
	"Double Paddle",
	"Magnet Paddle",
	"Back Wall (30 sec)",
	"Extra Life",
	"Destroy one Ball",
	"Random Bonus",
	"All Bricks destroy by one strike",
	"Drunk Paddle",
	"Expand Exploding",
	"Jump to Next Level",
	"Explode all Explodings",
]
const SUPPORTED_BONUS_EFFECTS := {
	BONUS_ADD_STANDARD_BALL: true,
	BONUS_ADD_FIREBALL: true,
	BONUS_NON_STRICKED_BALLS: true,
	BONUS_DECREASE_BALL_SIZE: true,
	BONUS_INCREASE_BALL_SIZE: true,
	BONUS_INCREASE_BALL_SPEED: true,
	BONUS_DECREASE_BALL_SPEED: true,
	BONUS_SHOOTING_PADDLE_TIMED: true,
	BONUS_SHOOTING_PADDLE_CONTINUOUS: true,
	BONUS_SHRINK_PADDLE: true,
	BONUS_EXPAND_PADDLE: true,
	BONUS_DOUBLE_PADDLE: true,
	BONUS_MAGNET_PADDLE: true,
	BONUS_BACK_WALL: true,
	BONUS_EXTRA_LIFE: true,
	BONUS_DESTROY_ONE_BALL: true,
	BONUS_RANDOM_BONUS: true,
	BONUS_ONE_STRIKE_BRICKS: true,
	BONUS_DRUNK_PADDLE: true,
	BONUS_EXPAND_EXPLODING: true,
	BONUS_JUMP_TO_NEXT_LEVEL: true,
	BONUS_EXPLODE_ALL_EXPLODINGS: true,
}
const CHAIN_SELECTOR_TILE_IDS := [68, 43]
const BONUS_DISPLAY_INCREMENT_IDS := {
	1: true,
	11: true,
	14: true,
	16: true,
	17: true,
	18: true,
	19: true,
	20: true,
	21: true,
}


static func bonus_type_name(type_id: int) -> String:
	if type_id < 0 or type_id >= BONUS_TYPE_NAMES.size():
		return "Unknown"
	return String(BONUS_TYPE_NAMES[type_id])
