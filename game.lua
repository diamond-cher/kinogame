
local composer = require( "composer" )
local widget = require( "widget" )
local appodeal = require( "plugin.appodeal" )

local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------

local nameFilmTrue -- название загаданного фильма
local pictureFilmTrue = "img/Shoushenko1.png" -- кадр из загаданного фильма (работает)
local variant1 = "Вариант 1"
local variant2 = "Вариант 2"
local variant3 = "Вариант 3"
local variant4 = "Вариант 4"

-- переменны для отлова повторов
local replay
local replay_table = {}
local replay_tablePath = system.pathForFile( "replay_table.xml", system.DocumentsDirectory )

-- Initialize variables
local score = 0
local lose = false

local scoreText

local function updateText()
    scoreText.text = "Score: " .. score
end

local filePath = system.pathForFile ("films.xml", system.ResourceDirectory)
local filePathLocal = system.pathForFile ("films.xml", system.DocumentsDirectory)

-- переменные для рекламы
local appKey = "59a8e580539962fd5a9029b680675ec623d09dea560418f4" -- ключ, который надо будет получить на апподиле после публикации приложения
local add_count = 0

local function LoadQuestion()

	local contents_all = {}
	local contents = {}
	local count = {} -- кол-во фильмов в файле
	local str -- выбранная строка для работы
	local i
	local variant1_tmp, variant2_tmp, variant3_tmp
	local complexity
	
	-- Проверяем, есть ли локальный файл. Если да, то работаем дальше с ним
	local file, errorString = io.open( filePathLocal, "rb" )
	if file then
		filePath = filePathLocal
		file:close()
	end
	
	for line in io.lines(filePath) do
		contents_all[#contents_all+ 1] = line
	end
	
	LoadReplayFile()
	
	-- определяем сложность скриншота
	if math.random(1,2) == 1 then
		complexity = "easy"
		print("Выбранная сложность - "..complexity)
	else
		complexity = "hard"
		print("Выбранная сложность - "..complexity)
	end
	
	if complexity == "hard" then
		for s, line in pairs( contents_all ) do
			if (not line:match ("showed='hard2'")) and (not line:match ("showed='easy1_and_hard2'")) and (not line:match ("showed='easy2_and_hard2'")) then
				contents[#contents+ 1] = line
				count[#count+ 1] = s
			else
				-- тут надо придумать, что делаем когда все фильмы закончились. Сейчас просто показываем всё по второму кругу
				contents[#contents+ 1] = line
				count[#count+ 1] = s
			end
		end
	elseif complexity == "easy" then
		for s, line in pairs( contents_all ) do
			if (not line:match ("showed='easy2'")) and (not line:match ("showed='easy2_and_hard1'")) and (not line:match ("showed='easy2_and_hard2'")) then
				contents[#contents+ 1] = line
				count[#count+ 1] = s
			else
				-- тут надо придумать, что делаем когда все фильмы закончились. Сейчас просто показываем всё по второму кругу
				contents[#contents+ 1] = line
				count[#count+ 1] = s
			end
		end
	end
	
	-- Выбираем один из доступных вариантов задания, проверяем, не показывали ли мы его недавно, и вносим его в таблицу повторов
	replay = true
	while replay == true do
		i = math.random(1,#contents)
		str = contents[i]
		nameFilmTrue = string.match(str, "name_rus='(.-)'")			
		if replay_table ~= {} and #replay_table>0 then
			for j=1,#replay_table do
				if nameFilmTrue == replay_table[j] then
					replay = true
					break
				else
					replay = false
				end
			end
		else
			replay = false
		end
		if replay == false then
			table.insert( replay_table, 1, nameFilmTrue )
		end
	end
	
	-- Отмечаем, что показали выбранный фильм в очередной раз
	if complexity == "hard" then
		print("Выбранная строка: "..str)
		print("Номер строки в файле: "..count[i])
		if str:match ("showed=''") then
			contents_all[count[i]] = contents_all[count[i]]:gsub("showed=''", "showed='hard1'");
		elseif str:match ("showed='easy1'") then
			contents_all[count[i]] = contents_all[count[i]]:gsub("showed='easy1'", "showed='easy1_and_hard1'");
		elseif str:match ("showed='hard1'") then
			contents_all[count[i]] = contents_all[count[i]]:gsub("showed='hard1'", "showed='hard2'");
		elseif str:match ("showed='easy2'") then
			contents_all[count[i]] = contents_all[count[i]]:gsub("showed='easy2'", "showed='easy2_and_hard1'");
		elseif str:match ("showed='easy1_and_hard1'") then
			contents_all[count[i]] = contents_all[count[i]]:gsub("showed='easy1_and_hard1'", "showed='easy1_and_hard2'");
		elseif str:match ("showed='easy2_and_hard1'") then
			contents_all[count[i]] = contents_all[count[i]]:gsub("showed='easy1_and_hard2'", "showed='easy2_and_hard2'");
		end
	elseif complexity == "easy" then
		print("Выбранная строка: "..str)
		print("Номер строки в файле: "..count[i])
		if str:match ("showed=''") then
			contents_all[count[i]] = contents_all[count[i]]:gsub("showed=''", "showed='easy1'");
		elseif str:match ("showed='easy1'") then
			contents_all[count[i]] = contents_all[count[i]]:gsub("showed='easy1'", "showed='easy2'");
		elseif str:match ("showed='hard1'") then
			contents_all[count[i]] = contents_all[count[i]]:gsub("showed='hard1'", "showed='easy1_and_hard1'");
		elseif str:match ("showed='hard2'") then
			contents_all[count[i]] = contents_all[count[i]]:gsub("showed='hard2'", "showed='easy1_and_hard2'");
		elseif str:match ("showed='easy1_and_hard1'") then
			contents_all[count[i]] = contents_all[count[i]]:gsub("showed='easy1_and_hard1'", "showed='easy2_and_hard1'");
		elseif str:match ("showed='easy1_and_hard2'") then
			contents_all[count[i]] = contents_all[count[i]]:gsub("showed='easy1_and_hard2'", "showed='easy2_and_hard2'");
		end
	end
	
	-- for k,v in pairs( replay_table ) do
		-- print( "KEY: "..k.." | ".."VALUE: "..v )
	-- end	
	
	-- записываем в файл информацию о выбранном варианте
	TableSave(contents_all,filePathLocal )
	
	-- записываем таблицу повторов для последних 5 фильмов
	if #replay_table > 5 then
		for j = #replay_table,6,-1 do
			table.remove(replay_table,j)
		end
		TableSave(replay_table,replay_tablePath )
	else
		TableSave(replay_table,replay_tablePath )
	end
	
	--Выбираем 3 других неправильных варианта
	--В будущем усложить и добавить корреляцию по жанрам, году
	if contents_all ~= nil then
		local v1,v2,v3 = math.random(1, #contents_all), math.random(1, #contents_all), math.random(1, #contents_all)
		
		-- Убедимся, что все варианты разные. Тут пиздец какой-то. Если будут лаги, то может быть из-за этого, я хз
		while v1 == v2 or v1 == v3 or v2 == v3 or v1 == count[i] or v2 == count[i] or v3 == count[i] do
			v1,v2,v3 = math.random(1, #contents_all), math.random(1, #contents_all), math.random(1, #contents_all)
		end
		variant1_tmp = string.match(contents_all[v1], "name_rus='(.-)'")
		variant2_tmp = string.match(contents_all[v2], "name_rus='(.-)'")
		variant3_tmp = string.match(contents_all[v3], "name_rus='(.-)'")
		-- print("Вариант 1_tmp: "..variant1_tmp)
		-- print("Вариант 2_tmp: "..variant2_tmp)
		-- print("Вариант 3_tmp: "..variant3_tmp)
	end
	
	-- Определяем, какой кадр будет показан для фильма
	if str ~= nil then
		if complexity == "hard" then
			pictureFilmTrue = string.match(str, "img_hard='(.-)'")
			if string.match (str, "showed='hard1'") or string.match (str, "showed='easy1_and_hard1'") or string.match (str, "showed='easy2_and_hard1'") then
				pictureFilmTrue = string.match(pictureFilmTrue, ",(.+)")
			elseif string.match (str, "showed='hard2'") or string.match (str, "showed='easy1_and_hard2'") or string.match (str, "showed='easy2_and_hard2'") then
				if math.random(1,2) == 1 then
					pictureFilmTrue = string.match(pictureFilmTrue, ",(.+)")
				else
					pictureFilmTrue = string.match(pictureFilmTrue, "(.-),")
				end
			else		
				pictureFilmTrue = string.match(pictureFilmTrue, "(.-),")
			end
		elseif complexity == "easy" then
			pictureFilmTrue = string.match(str, "img_easy='(.-)'")
			if string.match (str, "showed='easy1'") or string.match (str, "showed='easy1_and_hard1'") or string.match (str, "showed='easy1_and_hard2'") then
				pictureFilmTrue = string.match(pictureFilmTrue, ",(.+)")
			elseif string.match (str, "showed='easy2'") or string.match (str, "showed='easy2_and_hard1'") or string.match (str, "showed='easy2_and_hard2'") then
				if math.random(1,2) == 1 then
					pictureFilmTrue = string.match(pictureFilmTrue, ",(.+)")
				else
					pictureFilmTrue = string.match(pictureFilmTrue, "(.-),")
				end
			else		
				pictureFilmTrue = string.match(pictureFilmTrue, "(.-),")
			end
		end
		pictureFilmTrue = "img/"..pictureFilmTrue
		
		if nameFilmTrue ~= nil and pictureFilmTrue ~= nil then
			print("Название правильного фильма: "..nameFilmTrue)
			print("Путь картинки: "..pictureFilmTrue)
		else
			print("Название правильного фильма: Что-то пошло не так")
		end
	end	
	
	if math.random(1,4) == 1 then
		variant1 = nameFilmTrue
		variant2 = variant2_tmp
		variant3 = variant3_tmp
		variant4 = variant1_tmp
	elseif math.random(1,3) == 1 then
		variant1 = variant1_tmp
		variant2 = nameFilmTrue
		variant3 = variant3_tmp
		variant4 = variant2_tmp
	elseif math.random(1,2) == 1 then
		variant1 = variant1_tmp
		variant2 = variant2_tmp
		variant3 = nameFilmTrue
		variant4 = variant3_tmp
	else
		variant1 = variant1_tmp
		variant2 = variant2_tmp
		variant3 = variant3_tmp
		variant4 = nameFilmTrue
	end
end


-- Загружаем файл с повторами в таблицу
function LoadReplayFile()
	-- Проверяем, есть ли локальный файл.
	local file, errorString = io.open( replay_tablePath, "rb" )
	if file then
		file:close()
	else
		return
	end
	
	for line in io.lines(replay_tablePath) do
		replay_table[#replay_table+ 1] = line
	end
end

local function exportstring( s )
  return string.format("%s", s)
end

--// The Save Function
function TableSave(  tbl,filename )
  local charS,charE = "","\n"
  local file,err = io.open( filename, "wb" )
  if err then return err end

  -- initiate variables for save procedure
  local tables,lookup = { tbl },{ [tbl] = 1 }
  -- file:write( "return {"..charE )

  for idx,t in ipairs( tables ) do
	 -- file:write( "-- Table: {"..idx.."}"..charE )
	 -- file:write( "{"..charE )
	 local thandled = {}

	 for i,v in ipairs( t ) do
		thandled[i] = true
		local stype = type( v )
		-- only handle value
		if stype == "table" then
		   if not lookup[v] then
			  table.insert( tables, v )
			  lookup[v] = #tables
		   end
		   file:write( charS..lookup[v]..charE )
		elseif stype == "string" then
		   file:write(  charS..exportstring( v )..charE )
		elseif stype == "number" then
		   file:write(  charS..tostring( v )..charE )
		end
	 end

	 for i,v in pairs( t ) do
		-- escape handled values
		if (not thandled[i]) then
		
		   local str = ""
		   local stype = type( i )
		   -- handle index
		   if stype == "table" then
			  if not lookup[i] then
				 table.insert( tables,i )
				 lookup[i] = #tables
			  end
			  str = charS..lookup[i].."}]="
		   elseif stype == "string" then
			  str = charS..exportstring( i ).."]="
		   elseif stype == "number" then
			  str = charS.."["..tostring( i ).."]="
		   end
		
		   if str ~= "" then
			  print("Хуйпоймичтотакое: "..str)
			  stype = type( v )
			  -- handle value
			  if stype == "table" then
				 if not lookup[v] then
					table.insert( tables,v )
					lookup[v] = #tables
				 end
				 file:write( str.."{"..lookup[v].."},"..charE )
			  elseif stype == "string" then
				 file:write( str..exportstring( v )..","..charE )
			  elseif stype == "number" then
				 file:write( str..tostring( v )..","..charE )
			  end
		   end
		end
	 end
	 -- file:write( "},"..charE )
  end
  file:close()
end


-- Если название длинное, то делим по словам примерно в центре и переносим вторую часть на вторую строку (не работает)
local function SplitLongString(stringName)
	local stringNameMod = stringName
	local t={} ; i=1
	if string.len(stringName) > 5 then
		for str in string.gmatch(stringName, "%s+") do
				t[i] = str
				i = i + 1
				print( "Разделённая строка: " ..str )
		end
	end
	-- if t[1] ~= nil then
		-- print( "Разделённая строка: " ..t[1] )
	-- end
	return stringNameMod
end

-- Пока что меняем размер текста в кнопке в зависимости от длины
local function ChooseSize(stringName)
	local size = 40
	if string.len(stringName) > 52 then
		size = 16
	elseif string.len(stringName) > 44 then
		size = 20
	elseif string.len(stringName) > 40 then
		size = 23
	elseif string.len(stringName) > 30 then
		size = 28
	elseif string.len(stringName) > 20 then
		size = 33
	elseif string.len(stringName) > 10 then
		size = 38
	else
		size = 40
	end	
	print( 'Размер текста "'..stringName..'" - '..size )
	return size
end

local function endGame()
	print( "Неправильно!")
	appodeal.hide( "banner" )
	composer.setVariable( "finalScore", score )
	appodeal.show( "interstitial")
	composer.removeScene( "game" )
	composer.gotoScene( "highscores", { time=800, effect="crossFade" } )
end

local function continueGame()
	composer.setVariable( "finalScore", score )
	add_count = add_count+1
	print( "Правильно! Кол-во очков без рекламы: "..add_count)
	if add_count >= math.random(5,8) then
		add_count = 0
		appodeal.show( "interstitial")
	end
	composer.removeScene( "game", true )
	composer.gotoScene( "game", { time=800, effect="crossFade" } )
end

local function handleButtonEvent1( event )
    if ( "ended" == event.phase ) then
        print( "Button was pressed and released " )
		if variant1 == nameFilmTrue and nameFilmTrue ~= nil then
			score = score+1
			continueGame()
		else
			endGame()
		end
    end
end
local function handleButtonEvent2( event )
    if ( "ended" == event.phase ) then
        print( "Button was pressed and released " )
		if variant2 == nameFilmTrue and nameFilmTrue ~= nil then
			score = score+1
			continueGame()
		else
			endGame()
		end
    end
end
local function handleButtonEvent3( event )
    if ( "ended" == event.phase ) then
        print( "Button was pressed and released " )
		if variant3 == nameFilmTrue and nameFilmTrue ~= nil then
			score = score+1
			continueGame()
		else
			endGame()
		end
    end
end
local function handleButtonEvent4( event )
    if ( "ended" == event.phase ) then
        print( "Button was pressed and released " )
		if variant4 == nameFilmTrue and nameFilmTrue ~= nil then
			score = score+1
			continueGame()
		else
			endGame()
		end
    end
end

local function cheatButton( event )
    score = score+1
end

-- функция для рекламы
local function adListener( event )

    if ( event.phase == "init" ) then  -- Successful initialization
		-- appodeal.show( "banner", {yAlign="bottom"} )
		appodeal.load( "interstitial" )
		
    elseif ( event.phase == "failed" ) then  -- The ad failed to load
        print( event.type )
        print( event.isError )
        print( event.response )
    end
end
-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )

	local sceneGroup = self.view
	if composer.getVariable( "finalScore" ) ~= nil then
		score = composer.getVariable( "finalScore" )
	end
	
	
	LoadQuestion()
	
	-- Code here runs when the scene is first created but has not yet appeared on screen
	local background = display.newImageRect( sceneGroup, "background.png", display.contentWidth, display.contentHeight )
	background.x = display.contentCenterX
	background.y = display.contentCenterY
	
	local pictureFilm
	-- Проверяем, чтобы картинка у фильма была, иначе ищем другой фильм
	repeat
		pictureFilm = display.newImageRect( sceneGroup, pictureFilmTrue, display.contentWidth, display.contentCenterY-50 )
		if not pictureFilm then
			LoadQuestion()
		end
	until pictureFilm
	pictureFilm.x = display.contentCenterX
	pictureFilm.y = display.contentCenterY/2+130

	scoreText = display.newText( sceneGroup, "Score: " .. score, 140, 100, native.systemFont, 48 )
	scoreText:setFillColor( 0, 0, 0 )
	if variant1 ~= nil and variant2 ~= nil and variant3 ~= nil and variant4 ~= nil then
		local variant1Button = widget.newButton(
			{
				left = 20,
				top = display.contentCenterY*1.35,
				width = display.contentCenterX-30,
				height = 120,
				defaultFile = "img/button_free.png",
				overFile = "img/button_touch.png",
				id = "variant1Button",
				label = variant1,
				font = native.systemFontBold,
				fontSize = ChooseSize(variant1),
				labelColor = { default = { 0.1, 0.0, 0.9}, over = { 1, 0, 0 } },
				onEvent = handleButtonEvent1
			}
		)
		local variant2Button = widget.newButton(
			{
				left = display.contentCenterX+10,
				top = display.contentCenterY*1.35,
				width = display.contentCenterX-30,
				height = 120,
				defaultFile = "img/button_free.png",
				overFile = "img/button_touch.png",
				id = "variant2Button",
				label = variant2,
				font = native.systemFontBold,
				fontSize = ChooseSize(variant2),
				labelColor = { default = { 0.1, 0.0, 0.9}, over = { 1, 0, 0 } },
				onEvent = handleButtonEvent2
			}
		)
		local variant3Button = widget.newButton(
			{
				left = 20,
				top = display.contentCenterY*1.35+140,
				width = display.contentCenterX-30,
				height = 120,
				defaultFile = "img/button_free.png",
				overFile = "img/button_touch.png",
				id = "variant3Button",
				label = variant3,
				font = native.systemFontBold,
				fontSize = ChooseSize(variant3),
				labelColor = { default = { 0.1, 0.0, 0.9}, over = { 1, 0, 0 } },
				onEvent = handleButtonEvent3
			}
		)
		local variant4Button = widget.newButton(
			{
				left = display.contentCenterX+10,
				top = display.contentCenterY*1.35+140,
				width = display.contentCenterX-30,
				height = 120,
				defaultFile = "img/button_free.png",
				overFile = "img/button_touch.png",
				id = "variant4Button",
				label = variant4,
				font = native.systemFontBold,
				fontSize = ChooseSize(variant4),
				labelColor = { default = { 0.1, 0.0, 0.9}, over = { 1, 0, 0 } },
				onEvent = handleButtonEvent4
			}
		)
		-- привязываем кнопку к сцене
		sceneGroup:insert( variant1Button )
		sceneGroup:insert( variant2Button )
		sceneGroup:insert( variant3Button )
		sceneGroup:insert( variant4Button )
		print("Вариант 1: "..variant1)
		print("Вариант 2: "..variant2)
		print("Вариант 3: "..variant3)
		print("Вариант 4: "..variant4)
		
		-- scoreText:addEventListener( "tap", cheatButton )
		
		appodeal.init( adListener, { appKey=appKey } )
		appodeal.show( "banner", {yAlign="bottom"} )
	end
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
