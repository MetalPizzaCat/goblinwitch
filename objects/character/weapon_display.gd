extends BoneAttachment3D
class_name WeaponDisplay

enum WeaponModel {
	NONE,
	AXE,
	SWORD,
	STICK,
	BOW,
	TEXT
}

@export var model: WeaponModel:
	get:
		return _model
	set(value):
		if _model != WeaponModel.NONE:
			get_model(_model).visible = false
		_model = value
		if _model != WeaponModel.NONE:
			get_model(_model).visible = true
		

@export var axe_model : Node3D
@export var sword_model : Node3D
@export var stick_model : Node3D
@export var bow_model : Node3D
@export var text_model : Node3D

func get_model(type : WeaponModel) -> Node3D:
	match type:
		WeaponModel.AXE:
			return axe_model
		WeaponModel.SWORD:
			return sword_model
		WeaponModel.STICK:
			return stick_model
		WeaponModel.BOW:
			return bow_model
	return null

var _model: WeaponModel = WeaponModel.NONE
