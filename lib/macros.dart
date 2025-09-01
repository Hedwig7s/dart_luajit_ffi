// ignore_for_file: non_constant_identifier_names

import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'package:dart_lua_ffi/generated_bindings.dart';

extension LuaMacros on LuaFFIBind {
  // From lauxlib.h
  void luaL_checkversion(Pointer<lua_State> L) =>
      luaL_checkversion_(L, LUA_VERSION_NUM.toDouble(), LUAL_NUMSIZES);

  void luaL_newlibtable(Pointer<lua_State> L, Pointer<luaL_Reg> l, int structSize) =>
      lua_createtable(L, 0, structSize ~/ sizeOf<luaL_Reg>() - 1);

  void luaL_newlib(Pointer<lua_State> L, Pointer<luaL_Reg> l, int structSize) {
    luaL_checkversion(L);
    luaL_newlibtable(L, l, structSize);
    luaL_setfuncs(L, l, 0);
  }

  void luaL_argcheck(
      Pointer<lua_State> L, bool cond, int arg, String extramsg) {
    if (!cond) luaL_argerror(L, arg, extramsg.toNativeUtf8().cast());
  }

  void luaL_argexpected(
      Pointer<lua_State> L, bool cond, int arg, String tname) {
    if (!cond) luaL_typeerror(L, arg, tname.toNativeUtf8().cast());
  }

  Pointer<Char> luaL_checkstring(Pointer<lua_State> L, int n) =>
      luaL_checklstring(L, n, nullptr).cast();

  Pointer<Char> luaL_optstring(Pointer<lua_State> L, int n, Pointer<Char> d) =>
      luaL_optlstring(L, n, d.cast(), nullptr).cast();

  Pointer<Char> luaL_typename(Pointer<lua_State> L, int i) =>
      lua_typename(L, lua_type(L, i)).cast();

  int luaL_loadfile(Pointer<lua_State> L, Pointer<Char> fn) =>
      luaL_loadfilex(L, fn, nullptr);

  int luaL_dofile(Pointer<lua_State> L, Pointer<Char> fn) =>
      luaL_loadfile(L, fn) != 0 || lua_pcall(L, 0, LUA_MULTRET, 0) != 0 ? 1 : 0;

  int luaL_dostring(Pointer<lua_State> L, Pointer<Char> s) =>
      luaL_loadstring(L, s) != 0 || lua_pcall(L, 0, LUA_MULTRET, 0) != 0
          ? 1
          : 0;

  int luaL_getmetatable(Pointer<lua_State> L, Pointer<Char> n) =>
      lua_getfield(L, LUA_REGISTRYINDEX, n.cast());

  int luaL_opt(Pointer<lua_State> L, Function f, int n, int d) =>
      lua_isnoneornil(L, n) ? d : f(L, n);

  int luaL_loadbuffer(
          Pointer<lua_State> L, Pointer<Char> s, int sz, Pointer<Char> n) =>
      luaL_loadbufferx(L, s.cast(), sz, n.cast(), nullptr);

  void luaL_pushfail(Pointer<lua_State> L) => lua_pushnil(L);

  // From lua.h
  void lua_call(Pointer<lua_State> L, int nargs, int nresults) =>
      lua_callk(L, nargs, nresults, 0, nullptr);

  int lua_pcall(Pointer<lua_State> L, int nargs, int nresults, int errfunc) =>
      lua_pcallk(L, nargs, nresults, errfunc, 0, nullptr);

  int lua_yield(Pointer<lua_State> L, int nresults) =>
      lua_yieldk(L, nresults, 0, nullptr);

  Pointer<Void> lua_getextraspace(Pointer<lua_State> L) =>
      L.cast<Char>().elementAt(-LUA_EXTRASPACE).cast();

  double lua_tonumber(Pointer<lua_State> L, int i) =>
      lua_tonumberx(L, i, nullptr);

  int lua_tointeger(Pointer<lua_State> L, int i) =>
      lua_tointegerx(L, i, nullptr);

  void lua_pop(Pointer<lua_State> L, int n) => lua_settop(L, -n - 1);

  void lua_newtable(Pointer<lua_State> L) => lua_createtable(L, 0, 0);

  void lua_register(Pointer<lua_State> L, Pointer<Char> n,
      lua_CFunction f) {
    lua_pushcfunction(L, f);
    lua_setglobal(L, n.cast());
  }

  void lua_pushcfunction(
          Pointer<lua_State> L, lua_CFunction f) =>
      lua_pushcclosure(L, f, 0);

  bool lua_isfunction(Pointer<lua_State> L, int n) =>
      lua_type(L, n) == LUA_TFUNCTION;
  bool lua_istable(Pointer<lua_State> L, int n) => lua_type(L, n) == LUA_TTABLE;
  bool lua_islightuserdata(Pointer<lua_State> L, int n) =>
      lua_type(L, n) == LUA_TLIGHTUSERDATA;
  bool lua_isnil(Pointer<lua_State> L, int n) => lua_type(L, n) == LUA_TNIL;
  bool lua_isboolean(Pointer<lua_State> L, int n) =>
      lua_type(L, n) == LUA_TBOOLEAN;
  bool lua_isthread(Pointer<lua_State> L, int n) =>
      lua_type(L, n) == LUA_TTHREAD;
  bool lua_isnone(Pointer<lua_State> L, int n) => lua_type(L, n) == LUA_TNONE;
  bool lua_isnoneornil(Pointer<lua_State> L, int n) => lua_type(L, n) <= 0;

  Pointer<Char> lua_pushliteral(Pointer<lua_State> L, String s) =>
      lua_pushstring(L, s.toNativeUtf8().cast());

  void lua_pushglobaltable(Pointer<lua_State> L) =>
      lua_rawgeti(L, LUA_REGISTRYINDEX, LUA_RIDX_GLOBALS);

  Pointer<Char> lua_tostring(Pointer<lua_State> L, int i) =>
      lua_tolstring(L, i, nullptr).cast();

  void lua_insert(Pointer<lua_State> L, int idx) => lua_rotate(L, idx, 1);

  void lua_remove(Pointer<lua_State> L, int idx) {
    lua_rotate(L, idx, -1);
    lua_pop(L, 1);
  }

  void lua_replace(Pointer<lua_State> L, int idx) {
    lua_copy(L, -1, idx);
    lua_pop(L, 1);
  }
}
