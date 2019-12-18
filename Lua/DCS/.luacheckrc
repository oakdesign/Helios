std = {
    globals = {
        -- modules
        "lfs",
        "log",

        -- helios epxport API
        helios = {
            fields = {
                "splitString",
                "round",
                "ensureString",
                "textureToString",
                "send",
                "parseIndication",
                "selfName",
                "autoLoadDelay"
            }
        },

        -- internal functions needed for mock testing, but not to be used by profile drivers
        helios_impl = {
            fields = {
                "loadProfile",
                "driverName",
                "dispatchCommand",
                "autoLoadDelay",
                "exportInterval"
            }
        },

        -- mutable globals
        "package",

        -- mutable export hooks
        "LuaExportStart",
        "LuaExportBeforeNextFrame",
        "LuaExportAfterNextFrame",
        "LuaExportStop",
        "LuaExportActivityNextEvent"
    },
    read_globals = {
        -- LUA std
        "math",
        "table",
        "string",
        "os",
        "require",
        "dofile",
        "type",
        "pairs",
        "ipairs",
        "tonumber",
        "pcall",

        -- DCS
        "list_indication",
        "GetDevice",
        "LoGetSelfData"
    }
}
ignore = {
    "631" -- line too long
}
-- WARNING: following sections do not work when running within vscode via vscode-lua, so you must
-- either: execute "lua\bin\luacheck Scripts" manually on the command line or configure an
-- absolute path to luacheck in settings.json (workspace path does not get expanded on vscode-lua)
-- For ease of local hacking, consider running "git update-index --skip-worktree .vscode\settings.json"
files["Scripts/Helios"] = {
    std = {
        globals = { },
        read_globals = {
            -- modules
            "log",

            -- helios export API
            helios = {
                fields = {
                    "splitString",
                    "round",
                    "ensureString",
                    "textureToString",
                    "send",
                    "parseIndication",
                    "selfName"
                }
            },

            -- LUA std
            "math",
            "table",
            "string",
            "tonumber",

            -- DCS
            -- nothing for now, let's try to wrap those things that we need in safe alternatives, like parseIndication
        }
    }
 }
 files["Scripts/test"] = {
    std = {
        globals = {
            helios_mock = {
                fields = {
                    "test"
                }
            }
        },
        read_globals = {
            -- modules
            "log",

            -- helios export API
            helios = {
                fields = {
                    "selfName"
                }
            },

            -- helios mock API
            helios_mock = {
                fields = {
                    "setSelf",
                    "loadDriver",
                    "profileName",
                    "receiveLoadProfile",
                    "framesUntilAutoLoad"
                }
            },

            -- LUA std
            "math",
            "table",
            "string",
            "tonumber",
            "assert"
        }
    }
 }