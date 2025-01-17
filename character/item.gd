extends Resource
class_name Item


@export var name : String = "ITEM_NAME"
@export var description : String = ""
@export var is_weapon : bool = true
@export var is_key : bool = false
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
## What type of weapon model is used to represent this item during combat
@export var model : WeaponDisplay.WeaponModel = WeaponDisplay.WeaponModel.NONE

@export_group("Consumable")
## How much health is restored if this item is consumed
@export var health_restore : int = 0
## How much mana is restored if this item is consumed
@export var mana_restore : int = 0