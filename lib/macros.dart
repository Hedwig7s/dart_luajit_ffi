// ignore_for_file: non_constant_identifier_names

import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'package:dart_luajit_ffi/generated_bindings.dart';

extension LuaJITMacros on LuaFFIBind {
  // From lua.h - Stack manipulation macros

  void lua_pop(Pointer<lua_State> L, int n) => lua_settop(L, -n - 1);

  void lua_newtable(Pointer<lua_State> L) => lua_createtable(L, 0, 0);

  void lua_register(Pointer<lua_State> L, Pointer<Char> n, lua_CFunction f) {
    lua_pushcfunction(L, f);
    lua_setfield(L, LUA_GLOBALSINDEX, n.cast());
  }

  void lua_pushcfunction(Pointer<lua_State> L, lua_CFunction f) =>
      lua_pushcclosure(L, f, 0);

  Pointer<Char> lua_pushliteral(Pointer<lua_State> L, String s) {
    final nativeStr = s.toNativeUtf8();
    lua_pushlstring(L, nativeStr.cast(), s.length);
    return nativeStr.cast();
  }

  void lua_setglobal(Pointer<lua_State> L, Pointer<Char> s) =>
      lua_setfield(L, LUA_GLOBALSINDEX, s.cast());

  void lua_getglobal(Pointer<lua_State> L, Pointer<Char> s) =>
      lua_getfield(L, LUA_GLOBALSINDEX, s.cast());

  Pointer<Char> lua_tostring(Pointer<lua_State> L, int i) =>
      lua_tolstring(L, i, nullptr).cast();

  int lua_strlen(Pointer<lua_State> L, int i) => lua_objlen(L, i);

  // Type checking macros

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

  void lua_insert(Pointer<lua_State> L, int idx) {
    lua_pushvalue(L, idx);
    lua_remove(L, idx);
  }

  void lua_replace(Pointer<lua_State> L, int idx) {
    lua_settop(L, idx);
  }

  double lua_tonumber(Pointer<lua_State> L, int idx) =>
      lua_tonumberx(L, idx, nullptr);

  int lua_tointeger(Pointer<lua_State> L, int idx) =>
      lua_tointegerx(L, idx, nullptr);

  void lua_getregistry(Pointer<lua_State> L) =>
      lua_pushvalue(L, LUA_REGISTRYINDEX);

  int lua_getgccount(Pointer<lua_State> L) => lua_gc(L, LUA_GCCOUNT, 0);

  // From lauxlib.h - Auxiliary library macros

  void luaL_argcheck(
    Pointer<lua_State> L,
    bool cond,
    int numarg,
    String extramsg,
  ) {
    if (!cond) {
      final msg = extramsg.toNativeUtf8();
      luaL_argerror(L, numarg, msg.cast());
      malloc.free(msg);
    }
  }

  Pointer<Char> luaL_checkstring(Pointer<lua_State> L, int n) =>
      luaL_checklstring(L, n, nullptr).cast();

  Pointer<Char> luaL_optstring(Pointer<lua_State> L, int n, Pointer<Char> d) =>
      luaL_optlstring(L, n, d.cast(), nullptr).cast();

  int luaL_checkint(Pointer<lua_State> L, int n) => luaL_checkinteger(L, n);

  int luaL_optint(Pointer<lua_State> L, int n, int d) =>
      luaL_optinteger(L, n, d);

  int luaL_checklong(Pointer<lua_State> L, int n) => luaL_checkinteger(L, n);

  int luaL_optlong(Pointer<lua_State> L, int n, int d) =>
      luaL_optinteger(L, n, d);

  Pointer<Char> luaL_typename(Pointer<lua_State> L, int i) =>
      lua_typename(L, lua_type(L, i)).cast();

  int luaL_dofile(Pointer<lua_State> L, Pointer<Char> fn) {
    final loadResult = luaL_loadfile(L, fn);
    if (loadResult != 0) return 1;
    return lua_pcall(L, 0, LUA_MULTRET, 0) != 0 ? 1 : 0;
  }

  int luaL_dostring(Pointer<lua_State> L, Pointer<Char> s) {
    final loadResult = luaL_loadstring(L, s);
    if (loadResult != 0) return 1;
    return lua_pcall(L, 0, LUA_MULTRET, 0) != 0 ? 1 : 0;
  }

  void luaL_getmetatable(Pointer<lua_State> L, Pointer<Char> n) =>
      lua_getfield(L, LUA_REGISTRYINDEX, n.cast());

  int luaL_opt(
    Pointer<lua_State> L,
    int Function(Pointer<lua_State>, int) f,
    int n,
    int d,
  ) => lua_isnoneornil(L, n) ? d : f(L, n);

  void luaL_newlibtable(
    Pointer<lua_State> L,
    Pointer<luaL_Reg> l,
    int structSize,
  ) => lua_createtable(L, 0, structSize ~/ sizeOf<luaL_Reg>() - 1);

  void luaL_newlib(Pointer<lua_State> L, Pointer<luaL_Reg> l, int structSize) {
    luaL_newlibtable(L, l, structSize);
    luaL_setfuncs(L, l, 0);
  }

  int luaL_loadbuffer(
    Pointer<lua_State> L,
    Pointer<Char> buff,
    int sz,
    Pointer<Char> name,
  ) => luaL_loadbufferx(L, buff.cast(), sz, name.cast(), nullptr);
}
