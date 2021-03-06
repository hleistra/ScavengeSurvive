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
		fix_TargetVehicle[MAX_PLAYERS],
Float:	fix_Progress[MAX_PLAYERS];


hook OnPlayerConnect(playerid)
{
	fix_TargetVehicle[playerid] = INVALID_VEHICLE_ID;
}

public OnPlayerInteractVehicle(playerid, vehicleid, Float:angle)
{
	if(angle < 25.0 || angle > 335.0)
	{
		new
			Float:vehiclehealth,
			ItemType:itemtype;

		GetVehicleHealth(vehicleid, vehiclehealth);
		itemtype = GetItemType(GetPlayerItem(playerid));

		if(itemtype == item_Wrench)
		{
			if(vehiclehealth <= VEHICLE_HEALTH_CHUNK_2 || VEHICLE_HEALTH_CHUNK_4 - 2.0 <= vehiclehealth <= VEHICLE_HEALTH_MAX)
			{
				CancelPlayerMovement(playerid);
				StartRepairingVehicle(playerid, vehicleid);
				return 1;
			}
			else
			{
				ShowActionText(playerid, "You need another tool", 3000, 100);
			}
		}	
		else if(itemtype == item_Screwdriver)
		{
			if(VEHICLE_HEALTH_CHUNK_2 - 2.0 <= vehiclehealth <= VEHICLE_HEALTH_CHUNK_3)
			{
				CancelPlayerMovement(playerid);
				StartRepairingVehicle(playerid, vehicleid);
				return 1;
			}
			else
			{
				ShowActionText(playerid, "You need another tool", 3000, 100);
			}
		}	
		else if(itemtype == item_Hammer)
		{
			if(VEHICLE_HEALTH_CHUNK_3 - 2.0 <= vehiclehealth <= VEHICLE_HEALTH_CHUNK_4)
			{
				CancelPlayerMovement(playerid);
				StartRepairingVehicle(playerid, vehicleid);
				return 1;
			}
			else
			{
				ShowActionText(playerid, "You need another tool", 3000, 100);
			}
		}
		else if(itemtype == item_Wheel)
		{
			CancelPlayerMovement(playerid);
			ShowActionText(playerid, "Interact with a wheel to repair it", 5000);
		}
		else if(itemtype == item_GasCan)
		{
			CancelPlayerMovement(playerid);
			StartRefuellingVehicle(playerid, vehicleid);
		}
		else if(itemtype == item_Headlight)
		{
			CancelPlayerMovement(playerid);
			ShowLightList(playerid, vehicleid);
		}
		else
		{
			ShowActionText(playerid, "You don't have the right tool", 3000, 100);
		}
	}

	return CallLocalFunction("rep_OnPlayerInteractVehicle", "ddf", playerid, vehicleid, Float:angle);
}
#if defined _ALS_OnPlayerInteractVehicle
	#undef OnPlayerInteractVehicle
#else
	#define _ALS_OnPlayerInteractVehicle
#endif
#define OnPlayerInteractVehicle rep_OnPlayerInteractVehicle
forward rep_OnPlayerInteractVehicle(playerid, vehicleid, Float:angle);

hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(oldkeys & 16)
	{
		StopRepairingVehicle(playerid);
		StopRefuellingVehicle(playerid);
	}
}

StartRepairingVehicle(playerid, vehicleid)
{
	GetVehicleHealth(vehicleid, fix_Progress[playerid]);

	if(fix_Progress[playerid] >= 990.0)
	{
		return 0;
	}

	ApplyAnimation(playerid, "INT_SHOP", "SHOP_CASHIER", 4.0, 1, 0, 0, 0, 0, 1);
	VehicleBonnetState(fix_TargetVehicle[playerid], 1);
	StartHoldAction(playerid, 50000, floatround(fix_Progress[playerid] * 50));

	fix_TargetVehicle[playerid] = vehicleid;

	return 1;
}

StopRepairingVehicle(playerid)
{
	if(fix_TargetVehicle[playerid] == INVALID_VEHICLE_ID)
		return 0;

	if(fix_Progress[playerid] > 990.0)
	{
		SetVehicleHealth(fix_TargetVehicle[playerid], 990.0);
	}

	VehicleBonnetState(fix_TargetVehicle[playerid], 0);
	StopHoldAction(playerid);
	ClearAnimations(playerid);

	fix_TargetVehicle[playerid] = INVALID_VEHICLE_ID;

	return 1;
}

public OnHoldActionUpdate(playerid, progress)
{
	if(fix_TargetVehicle[playerid] != INVALID_VEHICLE_ID)
	{
		new ItemType:itemtype = GetItemType(GetPlayerItem(playerid));

		if(!IsValidItemType(itemtype))
		{
			StopRepairingVehicle(playerid);
			return 1;
		}

		if(!IsPlayerInVehicleArea(playerid, fix_TargetVehicle[playerid]) || !IsValidVehicle(fix_TargetVehicle[playerid]))
		{
			StopRepairingVehicle(playerid);
			return 1;
		}

		if(CompToolHealth(itemtype, fix_Progress[playerid]))
		{
			fix_Progress[playerid] += 2.0;
			SetVehicleHealth(fix_TargetVehicle[playerid], fix_Progress[playerid]);
			SetPlayerToFaceVehicle(playerid, fix_TargetVehicle[playerid]);	
		}
		else
		{
			StopRepairingVehicle(playerid);
		}
	}

	#if defined rep_OnHoldActionUpdate
		return rep_OnHoldActionUpdate(playerid, progress);
	#else
		return 0;
	#endif
}

#if defined _ALS_OnHoldActionUpdate
	#undef OnHoldActionUpdate
#else
	#define _ALS_OnHoldActionUpdate
#endif
#define OnHoldActionUpdate rep_OnHoldActionUpdate
#if defined rep_OnHoldActionUpdate
	forward rep_OnHoldActionUpdate(playerid, progress);
#endif


CompToolHealth(ItemType:itemtype, Float:health)
{
	if(health <= VEHICLE_HEALTH_CHUNK_2 - 2.0)
	{
		if(itemtype == item_Wrench)
			return 1;
	}
	else if(VEHICLE_HEALTH_CHUNK_2 - 2.0 <= health <= VEHICLE_HEALTH_CHUNK_3 - 2.0)
	{
		if(itemtype == item_Screwdriver)
			return 1;
	}
	else if(VEHICLE_HEALTH_CHUNK_3 - 2.0 <= health <= VEHICLE_HEALTH_CHUNK_4 - 2.0)
	{
		if(itemtype == item_Hammer)
			return 1;
	}
	else if(VEHICLE_HEALTH_CHUNK_4 - 2.0 <= health <= VEHICLE_HEALTH_MAX - 2.0)
	{
		if(itemtype == item_Wrench)
			return 1;
	}

	return 0;
}
