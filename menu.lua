
local composer = require( "composer" )
local widget = require( "widget" )

local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------

local function gotoGame( event )
    if ( "ended" == event.phase ) then
		composer.gotoScene( "game", { time=500, effect="slideLeft" } )
    end
end

local function gotoHighScores( event )
    if ( "ended" == event.phase ) then
		composer.gotoScene( "highscores", { time=500, effect="slideLeft" } )
    end
end

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )

	local sceneGroup = self.view
	-- Code here runs when the scene is first created but has not yet appeared on screen

	local background = display.newImageRect( sceneGroup, "background.png", display.contentWidth, display.contentHeight )
	background.x = display.contentCenterX
	background.y = display.contentCenterY

	local title = display.newImageRect( sceneGroup, "title.png", display.contentWidth-40, 200 )
	title.x = display.contentCenterX
	title.y = 350

	-- local playButton = display.newText( sceneGroup, "Play", display.contentCenterX, display.contentCenterY*1.5, native.systemFont, 64 )
	-- playButton:setFillColor( 0.82, 0.86, 1 )
	local playButton = widget.newButton(
			{
				x = display.contentCenterX,
				y = display.contentCenterY*1.5-64,
				width = display.contentCenterX,
				height = 120,
				defaultFile = "img/button_free.png",
				overFile = "img/button_touch.png",
				id = "playButton",
				label = "Играть",
				font = native.systemFontBold,
				fontSize = 64,
				labelColor = { default = { 0.0, 0.0, 0.0}, over = { 1, 0, 0 } },
				onEvent = gotoGame
			}
		)
		
	local highScoresButton = widget.newButton(
			{
				x = display.contentCenterX,
				y = display.contentCenterY*1.5+128,
				width = display.contentCenterX,
				height = 120,
				defaultFile = "img/button_free.png",
				overFile = "img/button_touch.png",
				id = "highScoresButton",
				label = "Таблица рекордов",
				font = native.systemFontBold,
				fontSize = 40,
				labelColor = { default = { 0.0, 0.0, 0.0}, over = { 1, 0, 0 } },
				onEvent = gotoHighScores
			}
		)
	sceneGroup:insert( playButton )
	sceneGroup:insert( highScoresButton )

	-- playButton:addEventListener( "tap", gotoGame )
	-- highScoresButton:addEventListener( "tap", gotoHighScores )
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

	if ( phase == "will" ) then
		-- Code here runs when the scene is on screen (but is about to go off screen)

	elseif ( phase == "did" ) then
		-- Code here runs immediately after the scene goes entirely off screen

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
