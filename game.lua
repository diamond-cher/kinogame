
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
local numbersFilmFalse = {}	-- таблица неправильных вариантов

-- переменны для отлова повторов
local replay
local replay_table = {}
local replay_tablePath = system.pathForFile( "replay_table.xml", system.DocumentsDirectory )

-- Initialize variables
local score = 0
local coins
local used50 = false
local lives = 3

local scoreText
local coinsText

-- файлы
local filePath = system.pathForFile ("films.xml", system.ResourceDirectory)
local filePath1 = system.pathForFile ("films1.xml", system.ResourceDirectory)
local filePathLocal = system.pathForFile ("films.xml", system.DocumentsDirectory)
local filePathUpdates = system.pathForFile ("updates1.xml", system.DocumentsDirectory)
local filePathCoins = system.pathForFile ("coins.xml", system.DocumentsDirectory)
local filePathRateUs = system.pathForFile ("rateUs.xml", system.DocumentsDirectory)

-- переменные для рекламы
local appKey = "59a8e580539962fd5a9029b680675ec623d09dea560418f4" -- ключ, который надо будет получить на апподиле после публикации приложения
local adCounter = 0
local user_id = system.getInfo( "deviceID" )

-- переменные для текста 
local goodAlertTitle_Ru = "Поздравляем!"
local goodAlertBody_Ru = "За просмотр видео вы получили 2 монеты!"
local goodAlertButton_Ru = "Превосходно!"

local badAlertTitle_Ru = "Ошибка!"
local badAlertBody_Ru = "Возможно, отсутствует интернет. Попробуйте запросить рекламу позже"
local badAlertButton_Ru = "Хорошо"
-- Выбор кадра из фильма и вариантов ответа
local function LoadQuestion()

	local contents_all = {}
	local contents = {}
	local count = {} -- кол-во фильмов в файле
	local str -- выбранная строка для работы
	local i
	local variant1_tmp, variant2_tmp, variant3_tmp
	local complexity
	used50 = false
	
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
	
	-- Добавляем в таблицу новые фильмы
	local file_updates, errorString = io.open( filePathUpdates, "rb" )
	if file_updates then
		file_updates:close()
	else
		for line in io.lines(filePath1) do
			contents_all[#contents_all+ 1] = line
		end
		file_updates, errorString = io.open( filePathUpdates, "w" )
		file_updates:close()
	end
	
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
	
	-- записываем таблицу повторов для последних 100 фильмов
	if #replay_table > 100 then
		for j = #replay_table,101,-1 do
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
	
	-- определяем, в каком месте будет правильный вариант писаться
	if math.random(1,4) == 1 then
		variant1 = nameFilmTrue
		variant2 = variant2_tmp
		variant3 = variant3_tmp
		variant4 = variant1_tmp
		numbersFilmFalse = {"variant2", "variant3", "variant4"}
	elseif math.random(1,3) == 1 then
		variant1 = variant1_tmp
		variant2 = nameFilmTrue
		variant3 = variant3_tmp
		variant4 = variant2_tmp
		numbersFilmFalse = {"variant1", "variant3", "variant4"}
	elseif math.random(1,2) == 1 then
		variant1 = variant1_tmp
		variant2 = variant2_tmp
		variant3 = nameFilmTrue
		variant4 = variant3_tmp
		numbersFilmFalse = {"variant1", "variant2", "variant4"}
	else
		variant1 = variant1_tmp
		variant2 = variant2_tmp
		variant3 = variant3_tmp
		variant4 = nameFilmTrue
		numbersFilmFalse = {"variant1", "variant2", "variant3"}
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

-- Загружаем монеты
function LoadCoins()
	-- Проверяем, есть ли локальный файл.
	local file, errorString = io.open( filePathCoins, "rb" )
	if file then
		coins = file:read( "*n" )
		file:close()
	else
		local file, errorString = io.open( filePathCoins, "wb" )
		file:write( "2" )
		file:close()
		coins = 2
	end
	if coins == 0 then
		coins = 1
	end
	return coins
end

-- Сохраняем монеты в файле
function SaveCoins()
	local file, errorString = io.open( filePathCoins, "wb" )
	file:write( coins )
	file:close()
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

--Обновляем бар сверху
local function UpdateBar()

	local scoreText = display.newText( sceneGroup, "Счёт: " .. score, 40, 100, native.systemFont, 48 )
	scoreText:setFillColor( 0, 0, 0 )
	scoreText.anchorX = 0
	
	local hearsBar1 = display.newImageRect( sceneGroup, "heart_bar.png", 96, 96 )
	hearsBar1.x = display.contentCenterX-120
	hearsBar1.y = 100
	local hearsBar2 = display.newImageRect( sceneGroup, "heart_bar.png", 96, 96 )
	hearsBar2.x = display.contentCenterX-20
	hearsBar2.y = 100
	local hearsBar3 = display.newImageRect( sceneGroup, "heart_bar.png", 96, 96 )
	hearsBar3.x = display.contentCenterX+80
	hearsBar3.y = 100
	if lives == 2 then
		display.remove( hearsBar3 )
	elseif lives == 1 then
		display.remove( hearsBar3 )
		display.remove( hearsBar2 )
	elseif lives == 0 then
		display.remove( hearsBar3 )
		display.remove( hearsBar2 )
		display.remove( hearsBar1 )
	end
	
	local coinsBar = display.newImageRect( sceneGroup, "coins_bar.png", 96, 96 )
	coinsBar.x = display.contentCenterX+180
	coinsBar.y = 100
	display.remove( coinsText )
	coinsText = display.newText( sceneGroup, coins, display.contentCenterX+230, 100, native.systemFont, 48 )
	coinsText:setFillColor( 0, 0, 0 )
	coinsText.anchorX = 0
	
	-- coinsBar:addEventListener( "tap", function () native.showAlert( "Как получить монеты", "Монеты выдаются при угадывании фильмов. Ещё их можно получить посмотрев рекламу.", { "Понятно" } ) end )
end

-- Если название длинное, то переносим вторую часть на другую строку
local function SplitLongString(stringName)
	local i=1
	local count = string.len(stringName)
	local number_s = stringName:find("%s")
	-- если длина строки больше 12 символов, то делаем перенос
	if count > 24 and number_s then
		-- если первое слово больше 11 или 7 символов, то первый же пробел будет заменён на перенос, иначе - пробел примерно после центра фразы
		if number_s > 22 and count < 60 then
			stringName = stringName:gsub("%s+", "\n", 1)
			print( "Перенос здесь: " ..number_s )
		-- elseif number_s > 14 and count < 60 then
			-- stringName = stringName:gsub("%s+", "\n", 1)
			-- print( "Перенос здесь: " ..number_s )
		else
			-- ищем середину фразы
			i = math.floor(count/2)
			-- ищем ближайший к середине пробел
			local number_s = stringName:find("%s", i)
			local revers_number_s = string.find(string.reverse( stringName ), "%s", i)
			if revers_number_s then
				print ("revers_number_s: "..revers_number_s)
				if number_s then
					if number_s-i > revers_number_s-i then
						i = i - revers_number_s-i - 1
					end
				else
					i = i - revers_number_s-i - 1
				end
			end
			-- for j=0,i do
				-- local j_i = i-j
				-- if stringName:match ("%s", j_i) then
					-- i = j_i
					-- break
				-- end
			-- end
			print( "Перенос после этого символа: " ..i )
			local stringName1 = stringName:sub(1,i-1)
			local stringName2 = stringName:sub(i)
			
			
			-- условие, чтобы верхняя часть не вылезала за рамки из-за своего размера
			if string.len(stringName1) < 40 then
				stringName2 = stringName2:gsub("%s+", "\n", 1)
				stringName = stringName1..stringName2
			else
			-- если первая часть охуенно большая, то делим её ещё пополам и ищем пробел уже там
				i = math.floor(i/2)
				local stringName1 = stringName1:sub(1,i-1)
				local stringName12 = stringName1:sub(i)
				stringName12 = stringName12:gsub("%s+", "\n", 1)
				stringName = stringName1..stringName12..stringName2
			end
		end
		
		-- чтобы перенесённая и оставшаяся фраза были примерно по центру, добавляем в начало наименьшей части пробелы
		local number_n = stringName:find("\n")
		if number_n then
			print( "Нашлась n здесь: "..number_n )
			local stringName1 = stringName:sub(1,number_n-1)
			local stringName2 = stringName:sub(number_n+1)
			local symbol_s = " "
			if string.len(stringName1) > string.len(stringName2) then
				local difference = string.len(stringName1) - string.len(stringName2)
				local quantity = math.floor(difference/2)
				stringName2 = "\n"..string.rep(symbol_s, quantity)..stringName2
			elseif string.len(stringName1) < string.len(stringName2) then
				local difference = string.len(stringName2) - string.len(stringName1)
				local quantity = math.floor(difference/2)
				stringName1 = string.rep(symbol_s, quantity)..stringName1.."\n"
			elseif string.len(stringName1) == string.len(stringName2) then
				stringName1 = stringName1.."\n"
			end
			stringName = stringName1..stringName2
		end
	end
	return stringName
end

-- Меняем размер текста в кнопке в зависимости от длины
local function ChooseSize(stringName)
	local size = 40
	if string.len(stringName) > 75 then
		size = 23
	elseif string.len(stringName) > 70 then
		size = 27
	elseif string.len(stringName) > 60 then
		size = 31 -- 74 и больше надо оставить такой размер
	elseif string.len(stringName) > 20 then
		size = 35
	elseif string.len(stringName) > 10 then
		size = 38
	else
		size = 40
	end	
	print( 'Размер текста "'..stringName..'" - '..size )
	return size
end

-- проверяем, хватает ли жизней для дальнейшей игры
local function checkLives()
	if lives <= 0 then
		composer.removeScene( "game" )
		composer.gotoScene( "highscores", { time=500, effect="slideRight" } )
	else
		composer.removeScene( "game", true )
		composer.gotoScene( "game" )
	end
end
-- Запускается при выборе неправильного ответа
local function endGame()
	print( "Неправильно!")
	appodeal.hide( "banner" )
	composer.setVariable( "finalScore", score )
	if adCounter >= 5 then
		appodeal.show( "interstitial")
		timer.performWithDelay( 1000, checkLives, 1 )
	else
		checkLives()
	end
end

-- Запускается при выборе правильного ответа
local function continueGame()
	composer.setVariable( "finalScore", score )
	adCounter = adCounter+1
	rateUsCounter = rateUsCounter+1
	if rateUsCounter == 2 then
		-- Проверяем, ставил ли игрок оценку/отзыв
		local file_rateUs, errorString = io.open( filePathRateUs, "rb" )
		if file_rateUs then
			file_rateUs:close()
			print( "Правильно!")
			composer.removeScene( "game", true )
			composer.gotoScene( "game" )
		else
			composer.showOverlay( "rate_us" )
			print( "rate_us!")
		end
	else
		print( "Правильно!")
		composer.removeScene( "game", true )
		composer.gotoScene( "game" )
	end
end

-- при правильном ответе создаём зелёную кнопку поверх обычной
local function GenerateGreenButton( self )
	local left_position
	local top_position
	if self == variant1 then
		left_position = 20
		top_position = display.contentCenterY*1.35
	elseif self == variant2 then
		left_position = display.contentCenterX+10
		top_position = display.contentCenterY*1.35
	elseif self == variant3 then
		left_position = 20
		top_position = display.contentCenterY*1.35+140
	else
		left_position = display.contentCenterX+10
		top_position = display.contentCenterY*1.35+140
	end
    greenButton = widget.newButton(
			{
				left = left_position,
				top = top_position,
				width = display.contentCenterX-30,
				height = 120,
				defaultFile = "img/button_green.png",
				overFile = "img/button_green.png",
				id = "greenButton",
				label = SplitLongString(self),
				font = native.systemFontBold,
				fontSize = ChooseSize(self),
				labelColor = { default = { 0.0, 0.0, 0.0}, over = { 1, 0, 0 } },
				labelAlign = "center",
				isEnabled  = false
			}
		)
	sceneGroup:insert( greenButton )
end

-- при неправильном ответе создаём красную кнопку поверх обычной
local function GenerateRedButton( self )
	local left_position
	local top_position
	if self == variant1 then
		left_position = 20
		top_position = display.contentCenterY*1.35
	elseif self == variant2 then
		left_position = display.contentCenterX+10
		top_position = display.contentCenterY*1.35
	elseif self == variant3 then
		left_position = 20
		top_position = display.contentCenterY*1.35+140
	else
		left_position = display.contentCenterX+10
		top_position = display.contentCenterY*1.35+140
	end
    redButton = widget.newButton(
			{
				left = left_position,
				top = top_position,
				width = display.contentCenterX-30,
				height = 120,
				defaultFile = "img/button_red.png",
				overFile = "img/button_red.png",
				id = "redButton",
				label = SplitLongString(self),
				font = native.systemFontBold,
				fontSize = ChooseSize(self),
				labelColor = { default = { 0.0, 0.0, 0.0}, over = { 1, 0, 0 } },
				labelAlign = "center",
				isEnabled  = false
			}
		)
	sceneGroup:insert( redButton )
end

-- обрабатываем нажатие на кнопку ответа
local function handleButtonEvent( event )
	local buttonId = event.target.id
	local buttonLabel
    if ( "ended" == event.phase ) then
        print( "Button was pressed and released "..buttonId )
		if buttonId == "variant1ButtonId" then
			buttonLabel = variant1
		elseif buttonId == "variant2ButtonId" then
			buttonLabel = variant2
		elseif buttonId == "variant3ButtonId" then
			buttonLabel = variant3
		else
			buttonLabel = variant4
		end
		
		if buttonLabel == nameFilmTrue then
			score = score+1
			GenerateGreenButton( buttonLabel )
			variant1Button:setEnabled(false)
			variant2Button:setEnabled(false)
			variant3Button:setEnabled(false)
			variant4Button:setEnabled(false)
			hint50Button:setEnabled(false)
			timer.performWithDelay( 1000, continueGame, 1 )
		else
			lives = lives-1
			UpdateBar()
			GenerateRedButton( buttonLabel )
			variant1Button:setEnabled(false)
			variant2Button:setEnabled(false)
			variant3Button:setEnabled(false)
			variant4Button:setEnabled(false)
			hint50Button:setEnabled(false)
			timer.performWithDelay( 1000, endGame, 1 )
		end
    end
end

-- логика работы подсказки 50:50
local function hint50ButtonEvent( event )
	local buttonId = event.target.id
	local deleteButtonl
	local deleteButton2
    if ( "ended" == event.phase ) then
		coins = coins-1
		SaveCoins()
		UpdateBar()
		while deleteButtonl == deleteButton2 do
			deleteButtonl, deleteButton2 = numbersFilmFalse[math.random(1, #numbersFilmFalse)], numbersFilmFalse[math.random(1, #numbersFilmFalse)]
		end
		if deleteButtonl == "variant1" then
			display.remove(variant1Button)
		elseif deleteButtonl == "variant2" then
			display.remove(variant2Button)
		elseif deleteButtonl == "variant3" then
			display.remove(variant3Button)
		else
			display.remove(variant4Button)
		end
		if deleteButton2 == "variant1" then
			display.remove(variant1Button)
		elseif deleteButton2 == "variant2" then
			display.remove(variant2Button)
		elseif deleteButton2 == "variant3" then
			display.remove(variant3Button)
		else
			display.remove(variant4Button)
		end
		used50 = true
		UpdateHints()
    end
end


-- Получение монет из серой подсказки
local function grayHints50ButtonEvent( event )
    if ( "ended" == event.phase ) then
		if appodeal.isLoaded( "rewardedVideo" ) then
			appodeal.show( "rewardedVideo" )
			timer.performWithDelay( 1000, function()
			local alert = native.showAlert( goodAlertTitle_Ru, goodAlertBody_Ru, { goodAlertButton_Ru } )			
			coins = coins+2
			SaveCoins()
			UpdateBar()
			hint50Button = widget.newButton(
				{
					x = display.contentCenterX,
					y = display.contentCenterY*1.25,
					width = 192,
					height = 86,
					defaultFile = "img/buttonCircle_free.png",
					overFile = "img/buttonCircle_touch.png",
					id = "hint50Button",
					label = "50:50",
					font = native.systemFontBold,
					fontSize = 46,
					labelColor = { default = { 0.1, 0.0, 0.9}, over = { 1, 0, 0 } },
					labelAlign = "center",
					onEvent = hint50ButtonEvent
				}
			)			
			sceneGroup:insert( hint50Button ) end, 1 )
		else
			local alert = native.showAlert( badAlertTitle_Ru, badAlertBody_Ru, { badAlertButton_Ru } )
		end
		
    end
end

-- вывод подсказок на экран (пока что только 50:50)
function UpdateHints()
	if coins > 0 and used50 == false then
	-- активная подсказка
		hint50Button = widget.newButton(
			{
				x = display.contentCenterX,
				y = display.contentCenterY*1.25,
				width = 192,
				height = 86,
				defaultFile = "img/buttonCircle_free.png",
				overFile = "img/buttonCircle_touch.png",
				id = "hint50Button",
				label = "50:50",
				font = native.systemFontBold,
				fontSize = 46,
				labelColor = { default = { 0.1, 0.0, 0.9}, over = { 1, 0, 0 } },
				labelAlign = "center",
				onEvent = hint50ButtonEvent
			}
		)
	elseif coins <= 0 and used50 == false then
	-- серая подсказка (нет монет)
		hint50Button = widget.newButton(
			{
				x = display.contentCenterX,
				y = display.contentCenterY*1.25,
				width = 192,
				height = 86,
				defaultFile = "img/buttonCircle_gray.png",
				overFile = "img/buttonCircle_gray.png",
				id = "hint50Button",
				label = "50:50",
				font = native.systemFontBold,
				fontSize = 46,
				labelColor = { default = { 0.6, 0.6, 0.6}, over = { 0.6, 0.6, 0.6 } },
				labelAlign = "center",
				onEvent = grayHints50ButtonEvent
			}
		)
	else
	-- серая подсказка (уже нажимали)
		hint50Button = widget.newButton(
			{
				x = display.contentCenterX,
				y = display.contentCenterY*1.25,
				width = 192,
				height = 86,
				defaultFile = "img/buttonCircle_gray.png",
				overFile = "img/buttonCircle_gray.png",
				id = "hint50Button",
				label = "50:50",
				font = native.systemFontBold,
				fontSize = 46,
				labelColor = { default = { 0.6, 0.6, 0.6}, over = { 0.6, 0.6, 0.6 } },
				labelAlign = "center",
			}
		)
	end
	sceneGroup:insert( hint50Button )
end

-- получение монет через просмотр видео
local function plusCoinsButtonEvent( event )
    if ( "ended" == event.phase ) then
		print("plusCoinsButtonEvent")
		if appodeal.isLoaded( "rewardedVideo" ) then
			appodeal.show( "rewardedVideo" )
			timer.performWithDelay( 1000, function()
			local alert = native.showAlert( goodAlertTitle_Ru, goodAlertBody_Ru, { goodAlertButton_Ru } )
			coins = coins+2
			SaveCoins()
			UpdateBar()
			UpdateHints() end, 1 )		
		else
			local alert = native.showAlert( badAlertTitle_Ru, badAlertBody_Ru, { badAlertButton_Ru } )
		end
		
    end
end

-- накручиваем очки по тапу по ним (читерская функция)
local function cheatButton( event )
    -- score = score+1
    -- scoreText.text = "Score: " .. score
	continueGame()
end

-- функция для рекламы
local function adListener( event )

    if ( event.phase == "init" ) then  -- Successful initialization
		-- appodeal.show( "banner", {yAlign="bottom"} )
		appodeal.setUserDetails( { userId = user_id } )
		appodeal.load( "interstitial" )
		appodeal.load( "rewardedVideo" )
		
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

	sceneGroup = self.view
	if composer.getVariable( "finalScore" ) ~= nil then
		score = composer.getVariable( "finalScore" )
	end
	
	
	LoadQuestion()
	if coins == nil then
		LoadCoins()
	end
	
	-- Code here runs when the scene is first created but has not yet appeared on screen
	local background = display.newImageRect( sceneGroup, "background.png", display.contentWidth+220, display.contentHeight+220 )
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
	
	UpdateBar()
	
	if variant1 ~= nil and variant2 ~= nil and variant3 ~= nil and variant4 ~= nil then
		variant1Button = widget.newButton(
			{
				left = 20,
				top = display.contentCenterY*1.35,
				width = display.contentCenterX-30,
				height = 120,
				defaultFile = "img/button_free.png",
				overFile = "img/button_touch.png",
				id = "variant1ButtonId",
				label = SplitLongString(variant1),
				font = native.systemFontBold,
				fontSize = ChooseSize(variant1),
				labelColor = { default = { 0.0, 0.0, 0.0}, over = { 1, 0, 0 } },
				labelAlign = "center",
				onEvent = handleButtonEvent
			}
		)
		variant2Button = widget.newButton(
			{
				left = display.contentCenterX+10,
				top = display.contentCenterY*1.35,
				width = display.contentCenterX-30,
				height = 120,
				defaultFile = "img/button_free.png",
				overFile = "img/button_touch.png",
				id = "variant2ButtonId",
				label = SplitLongString(variant2),
				font = native.systemFontBold,
				fontSize = ChooseSize(variant2),
				labelColor = { default = { 0.0, 0.0, 0.0}, over = { 1, 0, 0 } },
				labelAlign = "center",
				onEvent = handleButtonEvent
			}
		)
		variant3Button = widget.newButton(
			{
				left = 20,
				top = display.contentCenterY*1.35+140,
				width = display.contentCenterX-30,
				height = 120,
				defaultFile = "img/button_free.png",
				overFile = "img/button_touch.png",
				id = "variant3ButtonId",
				label = SplitLongString(variant3),
				font = native.systemFontBold,
				fontSize = ChooseSize(variant3),
				labelColor = { default = { 0.0, 0.0, 0.0}, over = { 1, 0, 0 } },
				labelAlign = "center",
				onEvent = handleButtonEvent
			}
		)
		variant4Button = widget.newButton(
			{
				left = display.contentCenterX+10,
				top = display.contentCenterY*1.35+140,
				width = display.contentCenterX-30,
				height = 120,
				defaultFile = "img/button_free.png",
				overFile = "img/button_touch.png",
				id = "variant4ButtonId",
				label = SplitLongString(variant4),
				font = native.systemFontBold,
				fontSize = ChooseSize(variant4),
				labelColor = { default = { 0.0, 0.0, 0.0}, over = { 1, 0, 0 } },
				labelAlign = "center",
				onEvent = handleButtonEvent
			}
		)
		
		UpdateHints()
		plusCoinsButton = widget.newButton(
				{
					x = display.contentCenterX*2-60,
					y = 100,
					width = 100,
					height = 80,
					defaultFile = "img/button_free.png",
					overFile = "img/button_touch.png",
					id = "plusCoinsButton",
					font = native.systemFontBold,
					label = "free",
					fontSize = 40,
					labelColor = { default = { 0, 0, 0}, over = { 1, 0, 0 } },
					labelAlign = "center",
					onEvent = plusCoinsButtonEvent
				}
			)
		-- привязываем кнопки к сцене
		sceneGroup:insert( variant1Button )
		sceneGroup:insert( variant2Button )
		sceneGroup:insert( variant3Button )
		sceneGroup:insert( variant4Button )
		sceneGroup:insert( plusCoinsButton )
		print("Вариант 1: "..variant1)
		print("Вариант 2: "..variant2)
		print("Вариант 3: "..variant3)
		print("Вариант 4: "..variant4)
		-- scoreText:addEventListener( "tap", cheatButton )
	end
	appodeal.init( adListener, { appKey=appKey } )
	appodeal.show( "banner", {yAlign="bottom"} )
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

-- resume()
function scene:resumeGame()
    --code to resume game
	rateUsCounter = rateUsCounter+1
	continueGame()	
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
