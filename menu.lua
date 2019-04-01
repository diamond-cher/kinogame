
local composer = require( "composer" )
local widget = require( "widget" )

local scene = composer.newScene()
local sceneGroupGlobal

local locationPath = system.pathForFile( "location.xml", system.DocumentsDirectory )
location = "eng"

local playButton
local playButtonPress
local title
local languageButton
local languageButtonText = "English"
local sceneCount = 0

local playButton_Eng = "interface/menu/button_Play_free_Eng.png"
local playButtonPress_Eng = "interface/menu/button_Play_press_Eng.png"
local title_Eng = "interface/menu/title_Eng.png"
local playButton_Rus = "interface/menu/button_Play_free_Rus.png"
local playButtonPress_Rus = "interface/menu/button_Play_press_Rus.png"
local title_Rus = "interface/menu/title_Rus.png"

local languageButtonText_Eng = "English"
local languageButtonText_Rus = "Русский"
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

local function CheckLanguage()
	
	local file_location = io.open( locationPath, "rb" )
	if file_location then
		location = file_location:read( "*a" )
		file_location:close()
	else
		file_location = io.open( locationPath, "w" )
		-- если язык ещё не был выбран, то по умолчанию ставим системный
		local systemLanguage = system.getPreference( "ui", "language" )	
		if string.find( systemLanguage, "ru" ) or string.find( systemLanguage, "RU" ) or string.find( systemLanguage, "Ru" ) then
			location = "rus"
			file_location:write ("rus")
		else
			location = "eng"
			file_location:write ("eng")
		end
		file_location:close()
	end
	
end

local function UpdateScene()
	local titleWidth
	local titleImg
	local playButtonImg
	local playButtonPressImg
	
	if location == "eng" then
		playButtonImg = playButton_Eng
		playButtonPressImg = playButtonPress_Eng
		languageButtonText = languageButtonText_Eng
		titleImg = title_Eng
		titleWidth = 619
	else
		playButtonImg = playButton_Rus
		playButtonPressImg = playButtonPress_Rus
		languageButtonText = languageButtonText_Rus
		titleImg = title_Rus
		titleWidth = 471
	end

	display.remove( title )
	display.remove( playButton )
	display.remove( languageButton )
	
	title = display.newImageRect( sceneGroupGlobal, titleImg, titleWidth, 356 )
	title.x = display.contentCenterX
	title.y = 350

	playButton = widget.newButton(
			{
				x = display.contentCenterX+13,
				y = display.contentCenterY+160,
				width = 483,
				height = 211,
				defaultFile = playButtonImg,
				overFile = playButtonPressImg,
				id = "playButton",
				onEvent = gotoGame
			}
		)
	languageButton = widget.newButton(
			{
				x = display.contentCenterX+128,
				y = display.contentCenterY+342,
				width = 248,
				height = 208,
				defaultFile = "interface/menu/button_Language_free.png",
				overFile = "interface/menu/button_Language_press.png",
				id = "languageButton",
				label = languageButtonText,
				font = native.systemFontBold,
				fontSize = 40,
				labelYOffset = -4,
				labelXOffset = -5,
				labelColor = { default = { 1, 1, 1}, over = { 0.9, 0.9, 0.9 } }
			}
		)
	
	sceneGroupGlobal:insert( languageButton )
	sceneGroupGlobal:insert( playButton )
end

local function ChangeLanguage()
	-- читаем, какой был язык
	local file_location = io.open( locationPath, "rb" )
	if file_location then
		location = file_location:read( "*a" )
		file_location:close()
	else
		location = "eng"
	end
	
	-- меняем и записываем в файл новое значение языка
	file_location = io.open( locationPath, "w" )
	if location == "eng" then
		location = "rus"
		file_location:write ("rus")
		print ("поменяли на русский")
	else
		location = "eng"
		file_location:write ("eng")
		print ("поменяли на английский")
	end
	file_location:close()
	
	-- перезагружаем сцену
	composer.removeScene( "menu", true )
	composer.gotoScene( "menu" )
end

-- обработка кнопки "Назад"
function KeyBack(event)

    if ( event.keyName == "back" and event.phase == "up" ) then
		local currScene = composer.getSceneName( "current" )
		if currScene == "game" or currScene == "highscores" then
			composer.removeScene( currScene )
			composer.gotoScene( "menu", { time=500, effect="slideRight" } )
			return true
		else
			native.requestExit()
			return false
		end
    end
end
-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )

	local sceneGroup = self.view
	sceneGroupGlobal = sceneGroup
	-- Code here runs when the scene is first created but has not yet appeared on screen
	CheckLanguage()
	
	local background = display.newImageRect( sceneGroup, "background.png", display.contentWidth+220, display.contentHeight+220 )
	background.x = display.contentCenterX
	background.y = display.contentCenterY
		
	local highScoresButton = widget.newButton(
			{
				x = display.contentCenterX-100,
				y = display.contentCenterY+342,
				width = 259,
				height = 208,
				defaultFile = "interface/menu/button_Scores_free.png",
				overFile = "interface/menu/button_Scores_press.png",
				id = "highScoresButton",
				onEvent = gotoHighScores
			}
		)
		
	UpdateScene(sceneGroup)
	
	sceneGroup:insert( highScoresButton )

	languageButton:addEventListener( "tap", ChangeLanguage )
	Runtime:addEventListener( "key", KeyBack )
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
