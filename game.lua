
local composer = require( "composer" )

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

-- Initialize variables
local score = 0
local lose = false

local scoreText

local function updateText()
    livesText.text = "Lives: " .. lives
    scoreText.text = "Score: " .. score
end

local filePath = system.pathForFile ("films.xml", system.DocumentsDirectory)

local function LoadEasyQuestion()

	-- local file, errorString = io.open( filePath, "r+" )
	local contents_all = {}
	local contents = {}
	local count = {} -- кол-во фильмов в файле
	local str -- выбранная строка для работы
	local i
	local variant1_tmp, variant2_tmp, variant3_tmp
	-- if file then
		for line in io.lines(filePath) do
			contents_all[#contents_all+ 1] = line
		end
		
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
	 
		-- for k,v in pairs( contents_all ) do
			-- print( "KEY: "..k.." | ".."VALUE: "..v )
		-- end
		
		-- Выбираем один из доступных вариантов задания и отмечаем его показанным
		-- В будущем можно усложнить шаблон, чтобы с приоритетом показывались фильмы, которых ещё не было видно
		if contents ~= nil then
			i = math.random(1,#contents)
			str = contents[i]
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
		
		-- записываем в файл информацию о выбранном варианте
		TableSave(contents_all,filePath )
		
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
		
		if str ~= nil then
			nameFilmTrue = string.match(str, "name_rus='(.-)'")
			pictureFilmTrue = string.match(str, "img_easy='(.-)'")
			if string.match (str, "showed='easy1'") or string.match (str, "showed='easy1_and_hard1'") or string.match (str, "showed='easy1_and_hard2'") then
				pictureFilmTrue = string.match(pictureFilmTrue, ",(.+)")
			else		
				pictureFilmTrue = string.match(pictureFilmTrue, "(.-),")
			end
			pictureFilmTrue = "img/"..pictureFilmTrue
			
			if nameFilmTrue ~= nil and pictureFilmTrue ~= nil then
				print("Название правильного фильма: "..nameFilmTrue)
				print("Путь картинки правильного фильма: "..pictureFilmTrue)
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
	-- else
		-- print("Что-то пошло не так тут: "..errorString)
	-- end
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

local function endGame()
	print( "Неправильно!")
	composer.setVariable( "finalScore", score )
	composer.removeScene( "game" )
	composer.gotoScene( "highscores", { time=800, effect="crossFade" } )
end

local function continueGame()
	composer.setVariable( "finalScore", score )
	print( "Правильно!")
	composer.removeScene( "game", true )
	composer.gotoScene( "game", { time=800, effect="crossFade" } )
end

-- Обработка нажатия на вариант ответа
local function onObjectTouch( self, event )
    if ( event.phase == "began" ) then
		self:setFillColor( 0.8, 0.1, 0.1 )
	elseif ( event.phase == "moved" ) then
		self:setFillColor( 0.2, 0.8, 0.1 )
	elseif ( event.phase == "ended" or event.phase == "cancelled" ) then
        print( "Touch event ended on: " .. self.id )
		self:setFillColor( 0.2, 0.8, 0.1 )
		if self.text == nameFilmTrue and nameFilmTrue ~= nil then
			score = score+1
			continueGame()
		else
			endGame()
		end
    end
    return true
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
	
	LoadEasyQuestion()
	-- Code here runs when the scene is first created but has not yet appeared on screen
	local background = display.newImageRect( sceneGroup, "background.png", display.contentWidth, display.contentHeight )
	background.x = display.contentCenterX
	background.y = display.contentCenterY

	local title = display.newImageRect( sceneGroup, pictureFilmTrue, display.contentWidth, display.contentCenterY-50 )
	title.x = display.contentCenterX
	title.y = display.contentCenterY/2+50

	scoreText = display.newText( sceneGroup, "Score: " .. score, 100, 0, native.systemFont, 36 )
	if variant1 ~= nil and variant2 ~= nil and variant3 ~= nil and variant4 ~= nil then
		local variant1Button = display.newText( sceneGroup, variant1, display.contentCenterX/2, display.contentCenterY*1.5, native.systemFont, 40 )
		variant1Button:setFillColor( 0.2, 0.8, 0.1 )
		
		local variant2Button = display.newText( sceneGroup, variant2, display.contentCenterX*1.5, display.contentCenterY*1.5, native.systemFont, 40 )
		variant2Button:setFillColor( 0.2, 0.8, 0.1 )

		local variant3Button = display.newText( sceneGroup, variant3, display.contentCenterX/2, (display.contentCenterY*1.5+128), native.systemFont, 40 )
		variant3Button:setFillColor( 0.2, 0.8, 0.1 )
		
		local variant4Button = display.newText( sceneGroup, variant4, display.contentCenterX*1.5, (display.contentCenterY*1.5+128), native.systemFont, 40 )
		variant4Button:setFillColor( 0.2, 0.8, 0.1 )
		print("Вариант 1: "..variant1)
		print("Вариант 2: "..variant2)
		print("Вариант 3: "..variant3)
		print("Вариант 4: "..variant4)
		variant1Button.touch = onObjectTouch
		variant1Button.id = "Вариант 1: "..variant1
		variant2Button.touch = onObjectTouch
		variant2Button.id = "Вариант 2: "..variant1
		variant3Button.touch = onObjectTouch
		variant3Button.id = "Вариант 3: "..variant1
		variant4Button.touch = onObjectTouch
		variant4Button.id = "Вариант 4: "..variant1
		variant1Button:addEventListener( "touch", variant1Button )
		variant2Button:addEventListener( "touch", variant2Button )
		variant3Button:addEventListener( "touch", variant3Button )
		variant4Button:addEventListener( "touch", variant4Button )
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
