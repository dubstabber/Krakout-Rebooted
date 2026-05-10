extends RefCounted
class_name KrakoutGameplayContext

var owner


func _init(session_owner = null) -> void:
	owner = session_owner


func racket_rect() -> Rect2:
	return _call_owner("racket_rect", [], Rect2())


func racket_segment_count() -> int:
	return int(_call_owner("_current_racket_segment_count", [], 0))


func projectile_rect(projectile: Dictionary) -> Rect2:
	return _call_owner("projectile_rect", [projectile], Rect2())


func target_speed_for_ball(ball: Dictionary) -> float:
	return float(_call_owner("_target_speed_for_ball", [ball], 0.0))


func award_score_with_popup(points: int, position: Vector2) -> void:
	_call_owner("_award_score_with_popup", [points, position])


func spawn_impact_effect(position: Vector2, kind: int) -> bool:
	return bool(_call_owner("_spawn_impact_effect", [position, kind], false))


func queue_audio_event(event_name: String) -> void:
	_call_owner("_queue_audio_event", [event_name])


func queue_audio_event_at_x(event_name: String, source_x: float) -> void:
	_call_owner("_queue_audio_event_at_x", [event_name, source_x])


func queue_audio_event_with_pan100(event_name: String, pan100: float) -> void:
	_call_owner("_queue_audio_event_with_pan100", [event_name, pan100])


func to_ports() -> Dictionary:
	return {
		"context": self,
		"racket_rect": Callable(self, "racket_rect"),
		"racket_segment_count": Callable(self, "racket_segment_count"),
		"projectile_rect": Callable(self, "projectile_rect"),
		"target_speed_for_ball": Callable(self, "target_speed_for_ball"),
		"award_score_with_popup": Callable(self, "award_score_with_popup"),
		"spawn_impact_effect": Callable(self, "spawn_impact_effect"),
		"queue_audio_event": Callable(self, "queue_audio_event"),
		"queue_audio_event_at_x": Callable(self, "queue_audio_event_at_x"),
		"queue_audio_event_with_pan100": Callable(self, "queue_audio_event_with_pan100"),
	}


func _call_owner(method_name: String, args: Array = [], default_value = null):
	if owner == null or not owner.has_method(method_name):
		return default_value
	return owner.callv(method_name, args)
