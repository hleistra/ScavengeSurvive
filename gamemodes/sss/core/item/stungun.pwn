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


public OnPlayerMeleePlayer(playerid, targetid, Float:bleedrate, Float:knockmult)
{
	new itemid = GetPlayerItem(playerid);

	if(GetItemType(itemid) == item_StunGun)
	{
		if(GetItemExtraData(itemid) == 1)
		{
			new
				Float:x,
				Float:y,
				Float:z;

			GetPlayerPos(targetid, x, y, z);

			KnockOutPlayer(targetid, 60000);
			SetItemExtraData(itemid, 0);
			CreateTimedDynamicObject(18724, x, y, z-1.0, 0.0, 0.0, 0.0, 1000);

			return 1;
		}
		else
		{
			ShowActionText(playerid, "Out of charge", 3000);
			return 1;
		}
	}

	#if defined stun_OnPlayerMeleePlayer
		return stun_OnPlayerMeleePlayer(playerid, targetid, bleedrate, knockmult);
	#else
		return 0;
	#endif
}
#if defined _ALS_OnPlayerMeleePlayer
	#undef OnPlayerMeleePlayer
#else
	#define _ALS_OnPlayerMeleePlayer
#endif
 
#define OnPlayerMeleePlayer stun_OnPlayerMeleePlayer
#if defined stun_OnPlayerMeleePlayer
	forward stun_OnPlayerMeleePlayer(playerid, targetid, Float:bleedrate, Float:knockmult);
#endif

public OnPlayerUseItemWithItem(playerid, itemid, withitemid)
{
	if(GetItemType(itemid) == item_StunGun && GetItemType(withitemid) == item_Battery)
	{
		SetItemExtraData(itemid, 1);
		DestroyItem(withitemid);
		ShowActionText(playerid, "Stun Gun Charged", 3000);
	}

	#if defined stun_OnPlayerUseItemWithItem
		return stun_OnPlayerUseItemWithItem(playerid, itemid, withitemid);
	#else
		return 0;
	#endif
}
#if defined _ALS_OnPlayerUseItemWithItem
	#undef OnPlayerUseItemWithItem
#else
	#define _ALS_OnPlayerUseItemWithItem
#endif

#define OnPlayerUseItemWithItem stun_OnPlayerUseItemWithItem
#if defined stun_OnPlayerUseItemWithItem
	forward stun_OnPlayerUseItemWithItem(playerid, itemid, withitemid);
#endif

public OnItemNameRender(itemid, ItemType:itemtype)
{
	if(itemtype == item_StunGun)
	{
		if(GetItemExtraData(itemid) == 1)
			SetItemNameExtra(itemid, "Charged");

		else
			SetItemNameExtra(itemid, "Uncharged");
	}

	#if defined stun_OnItemNameRender
		return stun_OnItemNameRender(itemid, itemtype);
	#else
		return 0;
	#endif
}
#if defined _ALS_OnItemNameRender
	#undef OnItemNameRender
#else
	#define _ALS_OnItemNameRender
#endif
#define OnItemNameRender stun_OnItemNameRender
#if defined stun_OnItemNameRender
	forward stun_OnItemNameRender(itemid, ItemType:itemtype);
#endif
