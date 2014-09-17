
---
-- Written By: Roman Larionov
-- File Name: init.lua
--
-- Description: This is a config file for Roman Larionov's personal 
-- mjolnir window manager. This has bindings for custom hotkeys, 
-- spotify control, alerts, window grids, etc.
--
-- This file needs to be placed within ~/.mjolnir.
-- This will be auto loaded whenever Mjolnir is run.
---


------------ External Dependencies. 
local application = require "mjolnir.application"
local hotkey = require "mjolnir.hotkey"
local window = require "mjolnir.window"
local grid = require "mjolnir.sd.grid"
--local fnutils = require "mjolnir.fnutils"
local spotify = require "mjolnir.lb.spotify"
local alert = require "mjolnir.alert"

----------- Global Variables
local mash = {"cmd", "alt", "ctrl"}
local mashShift = {"cmd", "alt", "shift"}
----------- Custom Hotkeys

-- Spotify 
hotkey.bind(mash, "space", spotify.displayCurrentTrack)
hotkey.bind(mash, "p", spotify.play) -- Play/Pause
hotkey.bind(mash, "right", spotify.next)
hotkey.bind(mash, "left", spotify.previous)

-- Window Management 
hotkey.bind(mash, "k", grid.pushwindow_left)
hotkey.bind(mash, "l", grid.pushwindow_right)

hotkey.bind(mash, 'M', grid.maximize_window)
hotkey.bind(mash, "n", window.minimize)

-- Mjolnir Specific
hotkey.bind(mash, "r", mjolnir.reload)

-- On StartUp
alert.show("Config Loaded!");





