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


#define MAX_HACKTRAP	(64)


new
			hak_ItemID[MAX_HACKTRAP],
Iterator:	hak_Index<MAX_HACKTRAP>;


stock CreateHackerTrap(Float:x, Float:y, Float:z, lootindex)
{
	new id = Iter_Free(hak_Index);

	hak_ItemID[id] = CreateLootItem(lootindex, x, y, z, 0, 0, 0.7);

	Iter_Add(hak_Index, id);

	return id;
}


public OnPlayerPickUpItem(playerid, itemid)
{
	foreach(new i : hak_Index)
	{
		if(itemid == hak_ItemID[i])
		{
			TheTrapHasSprung(playerid);
			return 1;
		}
	}

	#if defined hak_OnPlayerPickUpItem
		return hak_OnPlayerPickUpItem(playerid, itemid);
	#else
		return 0;
	#endif
}
#if defined _ALS_OnPlayerPickUpItem
	#undef OnPlayerPickUpItem
#else
	#define _ALS_OnPlayerPickUpItem
#endif
#define OnPlayerPickUpItem hak_OnPlayerPickUpItem
#if defined hak_OnPlayerPickUpItem
	forward hak_OnPlayerPickUpItem(playerid, itemid);
#endif


TheTrapHasSprung(playerid)
{
	new
		name[MAX_PLAYER_NAME],
		Float:x,
		Float:y,
		Float:z;

	GetPlayerName(playerid, name, MAX_PLAYER_NAME);
	GetPlayerPos(playerid, x, y, z);

	ReportPlayer(name, "Picked up a hack-trap", -1, REPORT_TYPE_HACKTRAP, x, y, z, GetPlayerVirtualWorld(playerid), GetPlayerInterior(playerid), "");
	BanPlayer(playerid, "Sprung the hacker trap by picking up an unreachable item!", -1, 0);
}
