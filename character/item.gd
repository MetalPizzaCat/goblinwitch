extends Resource
class_name Item


@export var name : String = "ITEM_NAME"
@export_group("Weapon")
## How much does this item deal when used as a weapon
@export var damage : int = 1
## How much strength is required to use this weapon well[br]
## Having strength below required will still make the weapon usable but less accurate
@export var min_strength : int = 0
## How accurate user needs to be use this weapon well
@export var accuracy : int = 0
## What attacks can this weapon perform
@export var attacks : Array[Attack] = []