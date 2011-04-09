#include "luabot.h"

lua_State *L = NULL;

extern "C" int AI_init(Funct* _functions, std::vector< std::vector<std::string> > _commandLineOptions)
{
  // Prepare the Lua state
  L = luaL_newstate();
  luaL_openlibs(L);
  lbot_openlibs(L, _functions, _commandLineOptions);

  // Place commonly used strings on the stack for quick usage
  lua_settop(L, 0);
  for(int i = 0; lbot_enum_names[i]; ++i)
  {
    if((i % 16) == 0)
      lua_checkstack(L, 20);
    lua_pushstring(L, lbot_enum_names[i]);
  }
  lua_checkstack(L, 20);
  lbot_pusherrorhandler(L);
  lua_replace(L, 3);

  // Load the AI script, taking the filename from the luabot command line option, or AI\luabot\main.lua otherwise
  lua_getglobal(L, "GetCommandLineArguments");
  lua_pushliteral(L, "luabot");
  lua_call(L, 1, 1);
  lbot_loadfile(L, luaL_optstring(L, -1, "AI\\luabot\\main.lua"));
  lbot_pcall(L, 0, 0, "loading script");
  lua_pop(L, 1);

  // Run the initialisation function, OnInit
  lua_getglobal(L, "OnInit");
  lbot_pcall(L, 0, 0, "initialisation");

	return INTERFACE_VERSION;
}

extern "C" bool AI_run()
{
  lua_pushvalue(L, FUNCTION_NAMES + 0); // "OnTick"
  lua_gettable(L, LUA_GLOBALSINDEX);
  lbot_pcall(L, 0, 0, "tick");
	return true;
}

extern "C" void AI_addevent(int _eventType, int _causeObjectId, int _targetObjectId, 
							int _unitType,  float _longitude, float _latitude)
{
  lua_pushvalue(L, FUNCTION_NAMES + 1); // "OnEvent"
  lua_gettable(L, LUA_GLOBALSINDEX);
  lua_pushvalue(L, EVENT_ENUM_NAMES + _eventType);
  lbot_pushint(L, _causeObjectId);
  if(_targetObjectId == -1)
    lua_pushnil(L);
  else
    lbot_pushint(L, _targetObjectId);
  if(_unitType < 0)
    _unitType = 0;
  lua_pushvalue(L, TYPE_ENUM_NAMES + _unitType);
  lbot_pushnumber(L, _longitude);
  lbot_pushnumber(L, _latitude);
  lbot_pcall(L, 6, 0, "event");
}

extern "C" bool AI_shutdown()
{
  lua_getglobal(L, "OnShutdown");
  lbot_pcall(L, 0, 0, "shutdown");
  lua_close(L);
  L = NULL;
	return true;
}
