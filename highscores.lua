
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


local function loadScores()

	local file = io.open( filePath, "r" )

	if file then
		local contents = file:read( "*a" )
		io.close( file )
		scoresTable = json.decode( contents )
	end

	if ( scoresTable == nil or #scoresTable == 0 ) then
		scoresTable = { 50, 40, 35, 30, 25, 20, 15, 10, 5, 1 }
	end
end


local function saveScores()

	for i = #scoresTable, 11, -1 do
		table.remove( scoresTable, i )
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

    -- Load the previous scores
    loadScores()

    -- Insert the saved score from the last game into the table, then reset it
	if finalScore and finalScore ~= 0 then
		for i=1,#scoresTable,1 do
			if finalScore >= scoresTable[i] then
				table.insert( scoresTable, i, finalScore )
				j = i
				break
			end
		end
	end
	composer.setVariable( "finalScore", 0 )

    -- Sort the table entries from highest to lowest
    -- local function compare( a, b )
        -- return a > b
    -- end
    -- table.sort( scoresTable, compare )

    -- Save the scores
    saveScores()

	local background = display.newImageRect( sceneGroup, "background.png", display.contentWidth+50, display.contentHeight+50 )
    background.x = display.contentCenterX
    background.y = display.contentCenterY

    local highScoresHeader = display.newText( sceneGroup, "Таблица рекордов", display.contentCenterX, 100, native.systemFont, 64 )
	highScoresHeader:setFillColor( 0, 0, 0 )

    for i = 1, 10 do
        if ( scoresTable[i] ) then
            local yPos = 150 + ( i * 76 )

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

	local menuButton = widget.newButton(
			{
				x = display.contentCenterX,
				y = display.contentCenterY*1.5+128,
				width = display.contentCenterX,
				height = 120,
				defaultFile = "img/button_free.png",
				overFile = "img/button_touch.png",
				id = "highScoresButton",
				label = "Меню",
				font = native.systemFontBold,
				fontSize = 64,
				labelColor = { default = { 0.0, 0.0, 0.0}, over = { 1, 0, 0 } },
				onEvent = gotoMenu
			}
		)
	sceneGroup:insert( menuButton )
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
