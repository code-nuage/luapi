package = "luapi"
version = "0.0-1"
source = {
   url = "git+https://github.com/code-nuage/luapi.git"
}
description = {
   summary = "A simple file reader",
   homepage = "https://github.com/code-nuage/luapi",
   license = "MIT"
}
dependencies = {
   "lua >= 5.1",
   "lua-cjson >= 0.7.2-1",
   "luafilesystem >= 1.8.0-1",
   "luasec >= 1.3.2-1"
}
build = {
   type = "builtin",
   modules = {
      luapi = "src/main.lua",
      colors = "src/colors.lua",
      config = "src/config.lua",
      menu = "src/menu.lua",
      menus = "src/menus.lua",
      save = "src/save.lua",
      http = "src/http.lua"
   },
   install = {
      bin = {
         ["luapi"] = "bin/luapi.lua"
      }
   }
}
