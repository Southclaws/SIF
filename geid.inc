/*==============================================================================

# Southclaw's Interactivity Framework (SIF)

## Overview

SIF is a collection of high-level include scripts to make the
development of interactive features easy for the developer while
maintaining quality front-end gameplay for players.

## Description

A GEID helper library, GEID = Global entity ID. Used for generating unique ID
numbers for SIF entities so their state may be identified and stored elsewhere.

## Dependencies

-

## Hooks

- 

## Credits

- SA:MP Team: Amazing mod!
- SA:MP Community: Inspiration and support
- Incognito: Very useful streamer plugin
- Y_Less: YSI framework

==============================================================================*/


#if defined _SIF_GEID_INCLUDED
	#endinput
#endif

#if !defined _SIF_DEBUG_INCLUDED
	#include "debug.inc"
#endif

#define _SIF_GEID_INCLUDED


/*==============================================================================

	Constant Definitions, Function Declarations and Documentation

==============================================================================*/


// Maximum amount of items that can be created.
#if !defined GEID_LEN
	#define GEID_LEN (16)
#endif


// Functions


forward mkgeid(id, result[]);
/*
# Description
Generates a GEID from a given entity ID
*/

forward b64_encode(data[], data_len, result[], &result_len);
/*
# Description
Encodes the given string using base64url standard.
*/


/*==============================================================================

	Setup

==============================================================================*/


static b64[65] = {"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_"};


/*==============================================================================

	Core Functions

==============================================================================*/


stock mkgeid(id, result[])
{
	new
		data[11],
		rlen;

	id = (1103515245 * id + GetTickCount());
	id = id < 0 ? -id : id;

	format(data, sizeof(data), "%010d", id);

	for(new i; data[i] != 0; ++i)
		data[i] = (data[i] + 1 + random(74));

	b64_encode(data, strlen(data), result, rlen);

	return rlen;
}

stock b64_encode(data[], data_len, result[], &result_len)
{
	new
		rc = 0,
		b,
		mlen,
		pad,
		byte0,
		byte1,
		byte2;

	mlen = data_len % 3;
	pad = ((mlen & 1) << 1) + ((mlen & 2) >> 1);
	result_len = 4 * (data_len + pad) / 3;

	for(b = 0; b+3 <= data_len; b += 3)
	{
		byte0 = data[b];
		byte1 = data[b + 1];
		byte2 = data[b + 2];

		result[rc++] = b64[byte0 >> 2];
		result[rc++] = b64[((0x3 & byte0) << 4) + (byte1 >> 4)];
		result[rc++] = b64[((0x0f & byte1) << 2) + (byte2 >> 6)];
		result[rc++] = b64[0x3f & byte2];
	}

	if(pad == 2)
	{
		result[rc++] = b64[data[b] >> 2];
		result[rc++] = b64[(0x3 & data[b]) << 4];
		result_len -= 2;
	}
	else if(pad == 1)
	{
		result[rc++] = b64[data[b] >> 2];
		result[rc++] = b64[((0x3 & data[b]) << 4) + (data[b + 1] >> 4)];
		result[rc++] = b64[(0x0f & data[b + 1]) << 2];
		result_len -= 1;
	}
}
