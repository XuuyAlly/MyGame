local NULL = "NULL"

export type ObjectPoolData = {
	object: Instance,
	amount: number,
	onCreate: (object: Instance) -> ()?,
	onGet: (object: Instance) -> ()?,
	onFree: (object: Instance) -> ()?,
}

return {
	currency = 0,
	hotbar = {
		["Slot1"] = NULL,
		["Slot2"] = NULL,
		["Slot3"] = NULL,
		["Slot4"] = NULL,
		["Slot5"] = NULL,
		["Slot6"] = NULL,
		["Slot7"] = NULL,
		["Slot8"] = NULL,
		["Slot9"] = NULL,
	},
}
