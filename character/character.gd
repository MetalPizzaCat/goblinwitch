extends Resource
class_name Character

@export var name: String = "YOUR_MOM"
@export var texture: Texture
@export_group("Stats")
## How much damage can character deal with melee weapons or bows
@export var strength: int = 0
## How likely the character is to dodge the attack
@export var dexterity: int = 0
## How good is the character at using magic
@export var intelligence: int = 0
## How good is the character at hitting the enemy
@export var perception: int = 0
## How durable the character is
@export var endurance: int = 0
## How good is the character at talking
@export var charisma: int = 0

@export_group("Inventory")
## Which items does the character have in their inventory
@export var items: Array[Item] = []
## What item is currently equipped[br]
## Characters can only hold one weapon at a time
@export var weapon: Item

@export_group("Combat")
@export var total_ap: int = 3
@export var total_mana: int = 1
## Spells are additional attacks that use mana
@export var spells: Array[Attack] = []

@export_group("Visuals")
@export var model_prefab: PackedScene

## Get max health this character have based on their endurance
## [br]
## Calculate health based on endurance [br]
## Health can be lower than 2 with negative endurance but it can not go below 1
func get_max_health() -> int:
    # old formula: max(roundi(max(endurance, -1) / 2.0) + 2, 1)
    return max(roundi(max(endurance, -1)) + 10, 1)

func get_melee_damage() -> int:
    var base_damage = weapon.damage if weapon != null else 0
    return base_damage + round(strength / 2.0)


func get_player_save_data() -> Dictionary:
    return {
        "items": items.map(func(p: Item): return p.resource_path),
        "spells": spells.map(func(p: Attack): return p.resource_path),
        "has_weapon" : weapon != null,
        "weapon_id" : items.find(weapon) 
    }

func load_data(data : Dictionary) -> void:
    items.clear()
    print(data['items'])
    for item_path in data['items']:
        var itm = ResourceLoader.load(item_path, "Item")
        if itm != null:
            items.append(itm)
        else:
            printerr("Failed to load %s " % item_path)
    for spell_path in data['spells']:
        var spell = ResourceLoader.load(spell_path, "Attack")
        if spell != null:
            spells.append(spell)
        else:
            printerr("Failed to load %s " % spell_path)
    print(items)
    print(spells)
