
local composer = require( "composer" )
local widget = require( "widget" )

local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------

-- Initialize variables
local json = require( "json" )

local scoresTable = {}

local filePath = system.pathForFile( "scores.json", system.DocumentsDirectory )
local titleBackground = "interface/highscores/title_background.png"
local centerBackground = "interface/highscores/center_background.png"

local emptyTable = false

local noRecordText_Ru = "Нет рекордов"
local titleText_Ru = "ТАБЛИЦА РЕКОРДОВ"
local menuText_Ru = "МЕНЮ"
local noRecordText_En = "No records"
local titleText_En = "TABLE OF HIGH SCORES"
local menuText_En = "MENU"

local function loadScores()

	local file = io.open( filePath, "r" )

	if file then
		local contents = file:read( "*a" )
		io.close( file )
		scoresTable = json.decode( contents )
	end

	if ( scoresTable == nil or #scoresTable == 0 ) then
		emptyTable = true
	end
end


local function saveScores()

	if #scoresTable > 10 then
		for i = #scoresTable, 11, -1 do
			table.remove( scoresTable, i )
		end
	end

	local file = io.open( filePath, "w" )

	if file then
		file:write( json.encode( scoresTable ) )
		io.close( file )
	end
end

local function gotoMenu( event )
    if ( "ended" == event.phase ) then
		composer.gotoScene( "menu", { time=500, effect="slideRight" } )
    end
end

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )

    local sceneGroup = self.view
	local finalScore = composer.getVariable( "finalScore" )
	local j -- место, куда вставили новый рекорд игрока
    -- Code here runs when the scene is first created but has not yet appeared on screen
	local menuText
	local titleText
	local noRecordText

	if location == "eng" then
		menuText = menuText_En
		titleText = titleText_En
		noRecordText = noRecordText_En
		highScoresHeaderSize = 46
	else
		menuText = menuText_Ru
		titleText = titleText_Ru
		noRecordText = noRecordText_Ru
		highScoresHeaderSize = 54
	end
    -- Load the previous scores
    loadScores()

    -- Insert the saved score from the last game into the table, then reset it
	if finalScore and finalScore ~= 0 then
		if ( scoresTable == nil or #scoresTable == 0 ) then
			scoresTable = { finalScore }
		else
			for i=1,#scoresTable,1 do
				if finalScore >= scoresTable[i] then
					table.insert( scoresTable, i, finalScore )
					j = i
					break
				end
			end
		end
		-- Save the scores
		saveScores()
		emptyTable = false
	end


	local background = display.newImageRect( sceneGroup, "background.png", display.contentWidth+220, display.contentHeight+220 )
    background.x = display.contentCenterX
    background.y = display.contentCenterY
	local titleBackground = display.newImageRect( sceneGroup, titleBackground, display.contentCenterX+display.contentCenterX/2, 120 )
    titleBackground.x = display.contentCenterX
    titleBackground.y = 150
	local centerBackground = display.newImageRect( sceneGroup, centerBackground, display.contentCenterX+display.contentCenterX/2, 800 )
    centerBackground.x = display.contentCenterX
    centerBackground.y = display.contentCenterY-55
	local highScoresHeader = display.newText( sceneGroup, titleText, display.contentCenterX, 150, native.systemFont, highScoresHeaderSize )
	highScoresHeader:setFillColor( 0, 0, 0 )

	if emptyTable == true then
		local emptyTableText = display.newText( sceneGroup, noRecordText, display.contentCenterX, display.contentCenterY, native.systemBolt, 54 )
		emptyTableText:setFillColor( 0, 0, 0 )
	else
		for i = 1, #scoresTable do
			if ( scoresTable[i] ) then
				local yPos = 180 + ( i * 76 )

				local rankNum = display.newText( sceneGroup, i .. ")", display.contentCenterX-50, yPos, native.systemBolt, 54 )
				rankNum:setFillColor( 0, 0, 0 )
				rankNum.anchorX = 1

				local thisScore = display.newText( sceneGroup, scoresTable[i], display.contentCenterX-30, yPos, native.systemFont, 54 )
				if i == j then
					thisScore:setFillColor( 1, 0, 0 )
				else
					thisScore:setFillColor( 0, 0, 0 )
				end
				thisScore.anchorX = 0
			end
		end
	end

	local menuButton = widget.newButton(
			{
				x = display.contentCenterX,
				y = display.contentCenterY*1.5+128,
				width = display.contentCenterX,
				height = 185,
				defaultFile = "interface/game/button_free.png",
				overFile = "interface/game/button_touch.png",
				id = "highScoresButton",
				label = menuText,
				font = native.systemFontBold,
				fontSize = 64,
				labelYOffset = -8,
				labelXOffset = -10,
				labelColor = { default = { 0.0, 0.0, 0.0}, over = { 0.3, 0.3, 0.3} },
				labelAlign = "center",
				onEvent = gotoMenu
			}
		)
	sceneGroup:insert( menuButton )
	composer.setVariable( "finalScore", 0 )
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
