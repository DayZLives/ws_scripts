// better vehicle behaviour miniscript
// v1 13.04.2013
// By Wolfenswan: wolfenswanarps@gmail.com 
//
// FEATURE
// Vehicle crews will only bail when the vehicle damage is over x (by default 0.8) or the guns are destroyed
//
// USAGE
// [parameter1,parameter2] execVM "ws_bettervehicles.sqf";
//
// PARAMETERS
// 1.side, object or array of objects
// 2. damage until the crew bails (any integer from 0.1 to 1)
//
// USAGE WITH F2:
// Use f_var_vehicles or f_var_vehicles_BLU or f_var_vehicles_RES or f_var_vehicles_OPF as first parameter

if !(isServer) exitWith {};

private ["_debug","_side","_alloweddamage","_vehicles","_handle"];

_debug = false; if !(isNil "ws_debug") then {_debug = ws_debug};   //Debug mode. If ws_debug is globally defined it overrides _debug

_side = _this select 0;
_alloweddamage = _this select 1; //damage allowed before the group bails no matter what
_vehicles = [];

switch (typename _side) do {
	case "SIDE": {
		// All non-static vehicles with a turret on the map
		{if (!(_x isKindOf "StaticWeapon") && side _x == _side && canFire _x && (count crew _x > 0)) then [{
			_vehicles = _vehicles + [_x];},{if _debug then {player sidechat format ["ws_bettervehicles DBG: %1 has no crew or is a static weapon",_x]};}];
		} forEach vehicles;
	};
	case "OBJECT": {
		_vehicles = [_side];
	};
	case "ARRAY": {
		_vehicles = _side;
	};
};


{
_handle = _x getVariable "ws_better_vehicle";
if (isNil "_handle") then {
	if _debug then {player sidechat format ["ws_bettervehicles DBG: Improving: %1",_x]};
	[_x,_alloweddamage,_debug] spawn {
		private ["_unit","_alloweddamage"];
		_unit = _this select 0;
		_unit allowCrewInImmobile true;
		_unit setvariable ["ws_better_vehicle",1];	
		_alloweddamage = _this select 1;
		while {damage _unit < _alloweddamage && canFire _unit} do 
		{
			sleep 2.5;
		};
		_unit allowCrewInImmobile false;
		{_x action ["eject", _unit];} forEach crew _unit;

		if (_this select 2) then {player sidechat format ["ws_bettervehicles DBG: %1 has taken enough damage or can't fire any more. crew bailing",_unit]};	
	   };
   };
} forEach _vehicles;

if _debug then {player sidechat format ["ws_bettervehicles DBG: Exiting. Improved vehicles: %1",_vehicles]};