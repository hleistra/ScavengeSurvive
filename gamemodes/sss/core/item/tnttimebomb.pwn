/*==============================================================================


	Southclaw's Scavenge and Survive

		Copyright (C) 2016 Barnaby "Southclaw" Keene

		This program is free software: you can redistribute it and/or modify it
		under the terms of the GNU General Public License as published by the
		Free Software Foundation, either version 3 of the License, or (at your
		option) any later version.

		This program is distributed in the hope that it will be useful, but
		WITHOUT ANY WARRANTY; without even the implied warranty of
		MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
		See the GNU General Public License for more details.

		You should have received a copy of the GNU General Public License along
		with this program.  If not, see <http://www.gnu.org/licenses/>.


==============================================================================*/


#include <YSI\y_hooks>


static
	tntt_ArmingItem[MAX_PLAYERS];


hook OnPlayerConnect(playerid)
{
	tntt_ArmingItem[playerid] = INVALID_ITEM_ID;
}

public OnPlayerUseItem(playerid, itemid)
{
	if(GetItemType(itemid) == item_TntTimebomb)
	{
		PlayerDropItem(playerid);
		tntt_ArmingItem[playerid] = itemid;

		StartHoldAction(playerid, 1000);
		ApplyAnimation(playerid, "BOMBER", "BOM_Plant_Loop", 4.0, 1, 0, 0, 0, 0);
		ShowActionText(playerid, "Arming...");
		return 1;
	}
    #if defined tntt_OnPlayerUseItem
		return tntt_OnPlayerUseItem(playerid, itemid);
	#else
		return 0;
	#endif
}
#if defined _ALS_OnPlayerUseItem
    #undef OnPlayerUseItem
#else
    #define _ALS_OnPlayerUseItem
#endif
#define OnPlayerUseItem tntt_OnPlayerUseItem
#if defined tntt_OnPlayerUseItem
	forward tntt_OnPlayerUseItem(playerid, itemid);
#endif

public OnHoldActionFinish(playerid)
{
	if(IsValidItem(tntt_ArmingItem[playerid]))
	{
		defer TimeBombExplode(tntt_ArmingItem[playerid]);
		logf("[EXPLOSIVE] TNT TIMEBOMB placed by %p", playerid);
		ClearAnimations(playerid);
		ShowActionText(playerid, "Armed for 5 seconds", 3000);

		tntt_ArmingItem[playerid] = INVALID_ITEM_ID;
	}

	#if defined tntt_OnHoldActionFinish
		return tntt_OnHoldActionFinish(playerid);
	#else
		return 1;
	#endif
}
#if defined _ALS_OnHoldActionFinish
	#undef OnHoldActionFinish
#else
	#define _ALS_OnHoldActionFinish
#endif
#define OnHoldActionFinish tntt_OnHoldActionFinish
#if defined tntt_OnHoldActionFinish
	forward tntt_OnHoldActionFinish(playerid);
#endif

hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(RELEASED(16) && IsValidItem(tntt_ArmingItem[playerid]))
	{
		StopHoldAction(playerid);
		tntt_ArmingItem[playerid] = INVALID_ITEM_ID;
	}
}

timer TimeBombExplode[5000](itemid)
{
	new
		Float:x,
		Float:y,
		Float:z;

	GetItemPos(itemid, x, y, z);

	logf("[EXPLOSIVE] TNT TIMEBOMB detonated at %f, %f, %f", x, y, z);

	SetItemToExplode(itemid, 10, 12.0, EXPLOSION_PRESET_STRUCTURAL, 2);
}
