class_name Attack

var attack_damage: float
var knockback_force: float
var attack_position: float
var stun_time: float

func _on_hitbox_area_entered(area):
	if area.has_method("damage"):
		var attack = Attack.new()
		attack.attack_damage = attack_damage
		attack.knockback_force = knockback_force
		attack.attack_position = attack_position
		attack.stun_time = stun_time
		area.damage(attack)
		print(attack.attack_damage)
