-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

rateUsCounter = 0

-- Your code here
local composer = require( "composer" )
gameanalytics = require ("plugin.gameanalytics_v2")

-- Start Analytics
gameanalytics.setEnabledInfoLog(true)
gameanalytics.setEnabledVerboseLog(true)

-- Configure available virtual currencies and item types
gameanalytics.configureAvailableCustomDimensions01({"level", "easy", "hard"})
gameanalytics.configureAvailableResourceItemTypes({"hints", "lives"})

gameanalytics.configureBuild( "1.1.1" )
gameanalytics.initialize {
    gameKey = "3114d263a0d6eb91b8210c818d089290",
    gameSecret = "0e6039492bd2a69fd70147fc3e2c2dc84d107916"
}

-- Hide status bar
display.setStatusBar( display.HiddenStatusBar )
 
-- Seed the random number generator
math.randomseed( os.time() )
 
-- Go to the menu screen
composer.gotoScene( "menu" )