
-- Custom reconfigs. Stolen from: https://github.com/sdegutis/dotfiles/blob/osx/home/.hydra/init.lua
dofile(package.searchpath("grid", package.path))

hydra.alert "Hydra, at your service."

pathwatcher.new(os.getenv("HOME") .. "/.hydra/", hydra.reload):start()
autolaunch.set(true)

menu.show(function()
	return {
		{title = "About Hydra", fn = hydra.showabout},
		{title = "-"},
		{title = "Quit", fn = os.exit},
	}
end)

local mash = {"cmd", "alt", "ctrl"}
local mashshift = {"cmd", "alt", "shift"}

local function opendictionary()
	hydra.alert("Lexicon, at your service.", 0.75)
	application.launchorfocus("Dictionary")
end

hotkey.bind(mash, 'D', opendictionary)

hotkey.bind(mash, 'M', ext.grid.maximize_window)

hotkey.bind(mash, ';', function() ext.grid.snap(window.focusedwindow()) end)
hotkey.bind(mash, "'", function() fnutils.map(window.visiblewindows(), ext.grid.snap) end)

hotkey.bind(mash, '=', function() ext.grid.adjustwidth( 1) end)
hotkey.bind(mash, '-', function() ext.grid.adjustwidth(-1) end)

hotkey.bind(mashshift, 'H', function() window.focusedwindow():focuswindow_west() end)
hotkey.bind(mashshift, 'L', function() window.focusedwindow():focuswindow_east() end)
hotkey.bind(mashshift, 'K', function() window.focusedwindow():focuswindow_north() end)
hotkey.bind(mashshift, 'J', function() window.focusedwindow():focuswindow_south() end)

hotkey.bind(mash, 'N', ext.grid.pushwindow_nextscreen)
hotkey.bind(mash, 'P', ext.grid.pushwindow_prevscreen)

hotkey.bind(mash, 'J', ext.grid.pushwindow_down)
hotkey.bind(mash, 'K', ext.grid.pushwindow_up)
hotkey.bind(mash, 'H', ext.grid.pushwindow_left)
hotkey.bind(mash, 'L', ext.grid.pushwindow_right)

hotkey.bind(mash, 'U', ext.grid.resizewindow_taller)
hotkey.bind(mash, 'O', ext.grid.resizewindow_wider)
hotkey.bind(mash, 'I', ext.grid.resizewindow_thinner)

hotkey.bind(mash, 'X', logger.show)
hotkey.bind(mash, "R", repl.open)
-- open a repl
-- the repl is a Lua prompt; type "print('hello world')"
-- when you're in the repl, type "help" to get started
-- almost all readline functionality works in the repl
hotkey.bind({"cmd", "ctrl", "alt"}, "R", repl.open)

-- save the time when updates are checked
function checkforupdates()
    updates.check()
    settings.set('lastcheckedupdates', os.time())
end

-- show a helpful menu
menu.show(function()
    local updatetitles = {[true] = "Install Update", [false] = "Check for Update..."}
    local updatefns = {[true] = updates.install, [false] = checkforupdates}
    local hasupdate = (updates.newversion ~= nil)

    return {
          {title = "Reload Config", fn = hydra.reload},
	  {title = "Open REPL", fn = repl.open},
	  {title = "-"},
	  {title = "About", fn = hydra.showabout},
	  {title = updatetitles[hasupdate], fn = updatefns[hasupdate]},
	  {title = "Quit Hydra", fn = os.exit},
	   }
end)

-- move the window to the right half of the screen
function movewindow_righthalf()
    local win = window.focusedwindow()
    local newframe = win:screen():frame_without_dock_or_menu()
    newframe.w = newframe.w / 2
    newframe.x = newframe.w -- comment this line to push it to left half of screen
    win:setframe(newframe)
end


hotkey.new({"cmd", "ctrl", "alt"}, "L", movewindow_righthalf):enable()

-- show available updates
local function showupdate()
    os.execute('open https://github.com/sdegutis/Hydra/releases')
end


-- what to do when an update is checked
function updates.available(available)
    if available then
        notify.show("Hydra update available", "", "Click here to see the changelog and maybe even install it", "showupdate")
    else
        hydra.alert("No update available.")
    end
end

autolaunch.set(true)

-- check for updates every week
timer.new(timer.weeks(1), checkforupdates):start()
notify.register("showupdate", showupdate)

-- if this is your first time running Hydra, you're launching it more than a week later, check now
local lastcheckedupdates = settings.get('lastcheckedupdates')
if lastcheckedupdates == nil or lastcheckedupdates <= os.time() - timer.days(7) then
    checkforupdates()
end
