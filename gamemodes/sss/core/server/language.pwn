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


#define DIRECTORY_LANGUAGES			DIRECTORY_MAIN"languages/"
#define MAX_LANGUAGE				(6)
#define MAX_LANGUAGE_ENTRIES		(500)
#define MAX_LANGUAGE_KEY_LEN		(32)
#define MAX_LANGUAGE_ENTRY_LENGTH	(256)
#define MAX_LANGUAGE_NAME			(32)

#define DELIMITER_CHAR				'='
#define ALPHABET_SIZE				(26)


enum e_LANGUAGE_ENTRY_DATA
{
	lang_key[MAX_LANGUAGE_KEY_LEN],
	lang_val[MAX_LANGUAGE_ENTRY_LENGTH]
}

static
	lang_Entries[MAX_LANGUAGE][MAX_LANGUAGE_ENTRIES][e_LANGUAGE_ENTRY_DATA],
	lang_TotalEntries[MAX_LANGUAGE],
	lang_AlphabetMap[MAX_LANGUAGE][ALPHABET_SIZE],

	lang_Name[MAX_LANGUAGE][MAX_LANGUAGE_NAME],
	lang_Total;


hook OnGameModeInit()
{
	print("\n[OnGameModeInit] Initialising 'language'...");

	DirectoryCheck(DIRECTORY_SCRIPTFILES DIRECTORY_LANGUAGES);

	LoadAllLanguages();
}

stock LoadAllLanguages()
{
	new
		dir:dirhandle,
		directory_with_root[256] = DIRECTORY_SCRIPTFILES,
		item[64],
		type,
		next_path[256],
		count;

	strcat(directory_with_root, DIRECTORY_LANGUAGES);

	dirhandle = dir_open(directory_with_root);

	if(!dirhandle)
	{
		printf("[LoadAllLanguages] ERROR: Reading directory '%s'.", directory_with_root);
		return 0;
	}

	while(dir_list(dirhandle, item, type))
	{
		if(type == FM_FILE)
		{
			next_path[0] = EOS;
			format(next_path, sizeof(next_path), "%s%s", DIRECTORY_LANGUAGES, item);
			count += LoadLanguage(next_path, item);
		}
	}

	dir_close(dirhandle);

	printf("Loaded %d languages", count);

	return 1;
}

stock LoadLanguage(filename[], langname[])
{
	printf("Loading language '%s'...", filename);
	new
		File:f = fopen(filename, io_read),
		line[256],
		length,
		delimiter,
		key[MAX_LANGUAGE_KEY_LEN],
		index;

	while(fread(f, line))
	{
		length = strlen(line);

		if(length < 4)
			continue;

		delimiter = 0;

		while(line[delimiter] != DELIMITER_CHAR)
		{
			key[delimiter] = line[delimiter];
			delimiter++;
		}

		if(delimiter >= length - 1 || delimiter < 4)
		{
			printf("[LoadLanguage] ERROR: Malformed line in '%s' delimiter character (%c) is absent or in first 4 cells.", filename, DELIMITER_CHAR);
			continue;
		}

		if(!(32 <= key[0] < 127))
		{
			printf("[LoadLanguage] ERROR: First character is abnormal character (%d/%c).", key[0], key[0]);
			continue;
		}

		key[delimiter] = EOS;
		index = lang_TotalEntries[lang_Total]++;

		strmid(lang_Entries[lang_Total][index][lang_key], line, 0, delimiter, MAX_LANGUAGE_ENTRY_LENGTH);
		strmid(lang_Entries[lang_Total][index][lang_val], line, delimiter + 1, length - 1, MAX_LANGUAGE_ENTRY_LENGTH);
	}

	fclose(f);

	if(lang_TotalEntries[lang_Total] == 0)
	{
		printf("[LoadLanguage] ERROR: No entries loaded from language file '%s'", filename);
		return 0;
	}

	strcat(lang_Name[lang_Total], langname, MAX_LANGUAGE_NAME);

	_qs(lang_Entries[lang_Total], 0, lang_TotalEntries[lang_Total] - 1);

	// alphabetmap
	new
		this_letter,
		letter_idx;

	for(new i; i < lang_TotalEntries[lang_Total]; i++)
	{
		this_letter = toupper(lang_Entries[lang_Total][i][lang_key][0]) - 65;

		if(this_letter == letter_idx-1)
			continue;

		while(letter_idx < this_letter)
		{
			lang_AlphabetMap[lang_Total][letter_idx] = -1;
			letter_idx++;
		}

		lang_AlphabetMap[lang_Total][letter_idx] = i;
		letter_idx++;
	}

	// fill in the empty ones
	while(letter_idx < 26)
		lang_AlphabetMap[lang_Total][letter_idx++] = -1;

	lang_Total++;

	return 1;
}

_qs(array[][], left, right)
{
	new
		tempLeft = left,
		tempRight = right,
		pivot = array[(left + right) / 2][0];

	while(tempLeft <= tempRight)
	{
		while(array[tempLeft][0] < pivot)
			tempLeft++;

		while(array[tempRight][0] > pivot)
			tempRight--;
		
		if(tempLeft <= tempRight)
		{
			_swap(array[tempLeft][lang_key], array[tempRight][lang_key]);
			_swap(array[tempLeft][lang_val], array[tempRight][lang_val]);

			tempLeft++;
			tempRight--;
		}
	}

	if(left < tempRight)
		_qs(array, left, tempRight);

	if(tempLeft < right)
		_qs(array, tempLeft, right);
}

_swap(str1[], str2[])
{
	new tmp;

	for(new i; str1[i] != '\0' || str2[i] != '\0'; i++)
	{
		tmp = str1[i];
		str1[i] = str2[i];
		str2[i] = tmp;
	}
}

stock GetLanguageString(languageid, key[])
{
	new
		result[MAX_LANGUAGE_ENTRY_LENGTH],
		ret;

	ret = _GetLanguageString(languageid, key, result);

	switch(ret)
	{
		case 1:
			printf("[GetLanguageString] ERROR: Malformed key '%s' must be alphabetical.", key);

		case 2:
			printf("[GetLanguageString] ERROR: Key not found: '%s'", key);
	}

	return result;
}

static stock _GetLanguageString(languageid, key[], result[])
{
	if(!('A' <= key[0] <= 'Z'))
		return 1;

	new
		index,
		start,
		end,
		abindex;

	abindex = toupper(key[0] - 65);

	start = lang_AlphabetMap[languageid][abindex];

	if(start == -1)
		return 2;

	do
	{
		abindex++;

		if(abindex == ALPHABET_SIZE)
			break;
	}
	while(lang_AlphabetMap[languageid][abindex] == -1);

	if(abindex < ALPHABET_SIZE)
		end = lang_AlphabetMap[languageid][abindex];

	else
		end = lang_TotalEntries[languageid];

	// start..end is now the search space

	// dumb search for now, will probably replace with bisect
	for(index = start; index < end; index++)
	{
		if(!strcmp(lang_Entries[languageid][index][lang_key], key))
			break;
	}

	if(index == end)
		return 2;

	strcat(result, lang_Entries[languageid][index][lang_val], MAX_LANGUAGE_ENTRY_LENGTH);

	return 0;
}

stock GetLanguageList(list[][])
{
	for(new i; i < lang_Total; i++)
	{
		list[i][0] = EOS;
		strcat(list[i], lang_Name[i], MAX_LANGUAGE_NAME);
	}

	return lang_Total;
}

stock GetLanguageName(languageid, name[])
{
	if(!(0 <= languageid < lang_Total))
		return 0;

	name[0] = EOS;
	strcat(name, lang_Name[languageid]);

	return 1;
}

stock GetLanguageID(name[])
{
	for(new i; i < lang_Total; i++)
	{
		if(!strcmp(name, lang_Name[i]))
			return i;
	}
	return -1;
}
