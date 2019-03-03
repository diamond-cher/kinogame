
local composer = require( "composer" )
local widget = require( "widget" )

local scene = composer.newScene()
-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------

-- Initialize variables

local rateUs_background = "interface/rateUs/rateUs_background.png"
local rateUs_buttonGray = "interface/rateUs/rateUs_buttonGray.png"
local rateUs_buttonGreen = "interface/rateUs/rateUs_buttonGreen.png"
local rateUs_buttonRed = "interface/rateUs/rateUs_buttonRed.png"
local rateUs_buttonGreenPress = "interface/rateUs/rateUs_buttonGreenPress.png"
local rateUs_buttonRedPress = "interface/rateUs/rateUs_buttonRedPress.png"
local filePathRateUs = system.pathForFile ("rateUs.xml", system.DocumentsDirectory)


local function tap_buttonGray( event )
    if ( "ended" == event.phase ) then
		composer.hideOverlay( "fade", 400 )
    end
end

local function tap_buttonGreen( event )
    if ( "ended" == event.phase ) then
		local options =
		{
		   supportedAndroidStores = { "google", "amazon" }
		}
		native.showPopup( "appStore", options )
		print("appStore")
		local file_rateUs = io.open( filePathRateUs, "w" )
		file_rateUs:close()
		composer.hideOverlay( "fade", 400 )
    end
end

local function tap_buttonRed( event )
    if ( "ended" == event.phase ) then
		local options =
		{
		   to = "i.logic.magic@gmail.com",
		   subject = "My Problem",
		   body = "Опишите здесь, что вам не нравится. Мы постараемся это исправить",
		   attachment = { }
		}
		native.showPopup("mail", options)
		print("mail")
		composer.hideOverlay( "fade", 400 )
    end
end

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )

    local sceneGroup = self.view

	local background = display.newImageRect( sceneGroup, rateUs_background, 600, 400 )
    background.x = display.contentCenterX
    background.y = display.contentCenterY
	
	local backgroundText = display.newText( sceneGroup, "Оцените, пожалуйста, игру!", display.contentCenterX, display.contentCenterY-160, native.systemBolt, 40 )
	backgroundText:setFillColor( 0, 0, 0 )

	local rateUs_buttonGray = widget.newButton(
			{
				x = display.contentCenterX,
				y = display.contentCenterY+120,
				width = 346,
				height = 80,
				defaultFile = rateUs_buttonGray,
				overFile = rateUs_buttonGray,
				id = "rateUs_buttonGray",
				label = "Позже",
				font = native.systemFontBold,
				fontSize = 64,
				labelColor = { default = { 0.0, 0.0, 0.0}, over = { 1, 0, 0 } },
				onEvent = tap_buttonGray
			}
		)
	local rateUs_buttonGreen = widget.newButton(
			{
				x = display.contentCenterX+150,
				y = display.contentCenterY-15,
				width = 225,
				height = 165,
				defaultFile = rateUs_buttonGreen,
				overFile = rateUs_buttonGreenPress,
				id = "rateUs_buttonGreen",
				onEvent = tap_buttonGreen
			}
		)
	local rateUs_buttonRed = widget.newButton(
			{
				x = display.contentCenterX-150,
				y = display.contentCenterY-15,
				width = 225,
				height = 165,
				defaultFile = rateUs_buttonRed,
				overFile = rateUs_buttonRedPress,
				id = "rateUs_buttonRed",
				onEvent = tap_buttonRed
			}
		)
	sceneGroup:insert( rateUs_buttonGray )
	sceneGroup:insert( rateUs_buttonGreen )
	sceneGroup:insert( rateUs_buttonRed )
end


-- show()
function scene:show( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is still off screen (but is about to come on screen)

	elseif ( phase == "did" ) then
		-- Code here runs when the scene is entirely on screen

	end
end


-- hide()
function scene:hide( event )

	local sceneGroup = self.view
	local phase = event.phase
	local parent = event.parent

	if ( phase == "will" ) then
		parent:resumeGame()
		-- Code here runs when the scene is on screen (but is about to go off screen)

	elseif ( phase == "did" ) then
		-- Code here runs immediately after the scene goes entirely off screen
		composer.removeScene( "highscores" )
	end
end


-- destroy()
function scene:destroy( event )

	local sceneGroup = self.view
	-- Code here runs prior to the removal of scene's view

end


-- -----------------------------------------------------------------------------------
-- Scene event function listeners
-- -----------------------------------------------------------------------------------
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
-- -----------------------------------------------------------------------------------

return scene
