/*

ROOT_LIQUID_BITMASK

liquid_Water			= DefineLiquidType("Water", ROOT_LIQUID_BITMASK)
liquid_Milk				= DefineLiquidType("Milk", ROOT_LIQUID_BITMASK)
liquid_Orange			= DefineLiquidType("Orange", ROOT_LIQUID_BITMASK)
liquid_Whiskey			= DefineLiquidType("Whiskey", ROOT_LIQUID_BITMASK)
liquid_Ethanol			= DefineLiquidType("Ethanol", ROOT_LIQUID_BITMASK)
liquid_Turpentine		= DefineLiquidType("Turpentine", ROOT_LIQUID_BITMASK)
liquid_HydroAcid		= DefineLiquidType("Hydrochloric Acid", ROOT_LIQUID_BITMASK)

liquid_StrongWhiskey	= DefineLiquidType("Acid Whiskey", liquid_Whiskey | liquid_Ethanol)
liquid_Fun				= DefineLiquidType("Fun", liquid_Ethanol | liquid_Turpentine | liquid_HydroAcid)

*/

#define MAX_LIQUID_TYPES (31) // technical limit
#define MAX_LIQUID_NAME (32)


enum E_LIQUID_DATA
{
	liq_name[MAX_LIQUID_NAME],
	liq_mask,
	liq_recipe
}


new const ROOT_LIQUID_BITMASK = 0xFFFFFFFF;

static
	liq_Data[MAX_LIQUID_TYPES][E_LIQUID_DATA],
	liq_Total,
	liq_NextMask = 1;


stock DefineLiquidType(name[], recipe)
{
	if(liq_Total == MAX_LIQUID_TYPES)
		return -1;

	strcat(liq_Data[liq_Total][liq_name], name, MAX_LIQUID_NAME);
	liq_Data[liq_Total][liq_mask] = liq_NextMask;
	liq_Data[liq_Total][liq_recipe] = recipe;
	printf("mask = %b name: '%s' recipe: '%b'", liq_NextMask, name, recipe);

	liq_Total++;
	liq_NextMask = liq_NextMask << 1;
	return liq_NextMask;
}