import 'dart:ffi';

import 'package:dart_luajit_ffi/dart_luajit_ffi.dart';
import 'package:dart_luajit_ffi/macros.dart';
import 'package:ffi/ffi.dart';

const dartPrintPrefix = "dartLog: ";
final NULLP = Pointer.fromAddress(0);
void main() {
  final luaFFI = createLua("assets/libluajit.so");
  final lp = luaFFI.luaL_newstate();
  luaFFI.luaL_openlibs(lp);

  luaFFI.luaL_loadfilex(
    lp,
    "assets/hw.lua".toNativeUtf8().cast<Char>(),
    NULLP.cast(),
  );
  luaFFI.lua_pushnumber(lp, 1.2);
  luaFFI.lua_setglobal(lp, "dartvar".toNativeUtf8().cast());
  luaFFI.lua_pcall(lp, 0, -1, 0);
  luaFFI.lua_settop(lp, 0);
  luaFFI.lua_getglobal(lp, "helloworldCall".toNativeUtf8().cast());
  luaFFI.lua_pcall(lp, 0, 1, 0);
  {
    final runFunctionResult = luaFFI.lua_tonumberx(lp, 0, NULLP.cast());
    print(
      "$dartPrintPrefix run function return result value  ${runFunctionResult}",
    );
  }
  // LuaPrintPrefix definition in  [assets/hw.lua]  file
  luaFFI.luaL_loadstring(
    lp,
    "print(LuaPrintPrefix..\"from dart print \")".toNativeUtf8().cast(),
  );
  luaFFI.lua_pcall(lp, 0, -1, 0);
  {
    final fromStringLoadCodeResult = luaFFI.luaL_loadstring(
      lp,
      "print(\"my from dart code load print \")".toNativeUtf8().cast(),
    );
    print(
      "$dartPrintPrefix load error return number value : ${fromStringLoadCodeResult}",
    );
  }
  luaFFI.lua_close(lp);
}
