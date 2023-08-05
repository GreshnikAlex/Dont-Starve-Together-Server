mods = GLOBAL.rawget(GLOBAL, "mods")
if not mods then
	mods = {}
	GLOBAL.rawset(GLOBAL, "mods", mods)
end
mods.RussianLanguagePack = {}
local t = mods.RussianLanguagePack
t.modinfo = modinfo
--Путь, по которому будут сохраняться рабочие версии po файла и лога обновлений.
--Он нужен потому, что сейчас при синхронизации стим затирает все файлы в папке мода на версии из стима.
t.StorePath = MODROOT--"scripts/languages/"
t.UpdateLogFileName = "updatelog.txt"
t.MainPOfilename = "DST.po"
t.UpdatePeriod = {"OncePerLaunch", "OncePerDay", "OncePerWeek", "OncePerMonth", "Never"}
t.TranslationTypes = {Full = "Full", InterfaceChat = "InterfaceChat", ChatOnly = "ChatOnly"}
t.CurrentTranslationType = nil
t.SteamURL = "http://steamcommunity.com/sharedfiles/filedetails/?id=354836336"
t.SelectedLanguage = "ru"
--Склонения
t.AdjectiveCaseTags = {	nominative = "nom", --Именительный	Кто/что
						accusative = "acc", --Винительный	Кого/что
						dative = "dat",		--Дательный		Кому/чему
						ablative = "abl",	--Творительный	Кем/чем
						genitive = "gen",	--Родительный	Кого/чего
						vocative = "voc",	--Звательный
						locative = "loc",	--Предложный	О ком/о чём
						instrumental = "ins"}--unused
t.DefaultActionCase = "accusative"

io = GLOBAL.io
STRINGS = GLOBAL.STRINGS
tonumber = GLOBAL.tonumber
tostring = GLOBAL.tostring
assert = GLOBAL.assert
rawget = GLOBAL.rawget
require = GLOBAL.require
dumptable = GLOBAL.dumptable
GetPlayer = rawget(GLOBAL, "ThePlayer") and (function() return ThePlayer end) or GLOBAL.GetPlayer
TheSim = GLOBAL.TheSim







									
									

local FontNames = {
	DEFAULTFONT = GLOBAL.DEFAULTFONT,
	DIALOGFONT = GLOBAL.DIALOGFONT,
	TITLEFONT = GLOBAL.TITLEFONT,
	UIFONT = GLOBAL.UIFONT,
	BUTTONFONT = GLOBAL.BUTTONFONT,
	NUMBERFONT = GLOBAL.NUMBERFONT,
	TALKINGFONT = GLOBAL.TALKINGFONT,
	SMALLNUMBERFONT = GLOBAL.SMALLNUMBERFONT,
	BODYTEXTFONT = GLOBAL.BODYTEXTFONT,
	NEWFONT = rawget(GLOBAL,"NEWFONT"),
	NEWFONT_SMALL = rawget(GLOBAL,"NEWFONT_SMALL"),
	NEWFONT_OUTLINE = rawget(GLOBAL,"NEWFONT_OUTLINE"),
	NEWFONT_OUTLINE_SMALL = rawget(GLOBAL,"NEWFONT_OUTLINE_SMALL")}

--В этой функции происходит загрузка, подключение и применение русских шрифтов
function ApplyLocalizedFonts()
	--Имена шрифтов, которые нужно загрузить.
	local LocalizedFontList = {["talkingfont"] = true,
							   ["stint-ucr50"] = true,
							   ["stint-ucr20"] = true,
							   ["opensans50"] = true,
							   ["belisaplumilla50"] = true,
							   ["belisaplumilla100"] = true,
							   ["buttonfont"] = true,
							   ["spirequal"] = rawget(GLOBAL,"NEWFONT") and true or nil,
							   ["spirequal_small"] = rawget(GLOBAL,"NEWFONT_SMALL") and true or nil,
							   ["spirequal_outline"] = rawget(GLOBAL,"NEWFONT_OUTLINE") and true or nil,
							   ["spirequal_outline_small"] = rawget(GLOBAL,"NEWFONT_OUTLINE_SMALL") and true or nil}

	--ЭТАП ВЫГРУЗКИ: Вначале выгружаем шрифты, если они были загружены
	--Восстанавливаем оригинальные переменные шрифтов
	GLOBAL.DEFAULTFONT = FontNames.DEFAULTFONT
	GLOBAL.DIALOGFONT = FontNames.DIALOGFONT
	GLOBAL.TITLEFONT = FontNames.TITLEFONT
	GLOBAL.UIFONT = FontNames.UIFONT
	GLOBAL.BUTTONFONT = FontNames.BUTTONFONT
	GLOBAL.NUMBERFONT = FontNames.NUMBERFONT
	GLOBAL.TALKINGFONT = FontNames.TALKINGFONT
	GLOBAL.SMALLNUMBERFONT = FontNames.SMALLNUMBERFONT
	GLOBAL.BODYTEXTFONT = FontNames.BODYTEXTFONT
	if rawget(GLOBAL,"NEWFONT") then
		GLOBAL.NEWFONT = FontNames.NEWFONT
	end
	if rawget(GLOBAL,"NEWFONT_SMALL") then
		GLOBAL.NEWFONT_SMALL = FontNames.NEWFONT_SMALL
	end
	if rawget(GLOBAL,"NEWFONT_OUTLINE") then
		GLOBAL.NEWFONT_OUTLINE = FontNames.NEWFONT_OUTLINE
	end
	if rawget(GLOBAL,"NEWFONT_OUTLINE_SMALL") then
		GLOBAL.NEWFONT_OUTLINE_SMALL = FontNames.NEWFONT_OUTLINE_SMALL
	end

	--Выгружаем локализированные шрифты, если они были до этого загружены
	for FontName in pairs(LocalizedFontList) do
		TheSim:UnloadFont(t.SelectedLanguage.."_"..FontName)
	end
	TheSim:UnloadPrefabs({t.SelectedLanguage.."_fonts_"..modname}) --выгружаем общий префаб локализированных шрифтов


	--ЭТАП ЗАГРУЗКИ: Загружаем шрифты по новой

	--Формируем список ассетов
	local LocalizedFontAssets = {}
	for FontName in pairs(LocalizedFontList) do 
		table.insert(LocalizedFontAssets, GLOBAL.Asset("FONT", MODROOT.."fonts/"..FontName.."__"..t.SelectedLanguage..".zip"))
	end

	--Создаём префаб, регистрируем его и загружаем
	local LocalizedFontsPrefab = GLOBAL.Prefab("common/"..t.SelectedLanguage.."_fonts_"..modname, nil, LocalizedFontAssets)
	GLOBAL.RegisterPrefabs(LocalizedFontsPrefab)
	TheSim:LoadPrefabs({t.SelectedLanguage.."_fonts_"..modname})

	--Формируем список связанных с файлами алиасов
	for FontName in pairs(LocalizedFontList) do
		TheSim:LoadFont(MODROOT.."fonts/"..FontName.."__"..t.SelectedLanguage..".zip", t.SelectedLanguage.."_"..FontName)
	end

	--Строим таблицу фоллбэков для последующей связи шрифтов с доп-шрифтами
	local fallbacks = {}
	for _, v in pairs(GLOBAL.FONTS) do
		local FontName = v.filename:sub(7, -5)
		if LocalizedFontList[FontName] then
			fallbacks[FontName] = {v.alias, GLOBAL.unpack(type(v.fallback) == "table" and v.fallback or {})}
		end
	end
	--Привязываем к новым английским шрифтам локализированные символы
	for FontName in pairs(LocalizedFontList) do
		TheSim:SetupFontFallbacks(t.SelectedLanguage.."_"..FontName, fallbacks[FontName])
	end

	--Вписываем в глобальные переменные шрифтов наши алиасы
	GLOBAL.DEFAULTFONT = t.SelectedLanguage.."_opensans50"
	GLOBAL.DIALOGFONT = t.SelectedLanguage.."_opensans50"
	GLOBAL.TITLEFONT = t.SelectedLanguage.."_belisaplumilla100"
	GLOBAL.UIFONT = t.SelectedLanguage.."_belisaplumilla50"
	GLOBAL.BUTTONFONT = t.SelectedLanguage.."_buttonfont"
	GLOBAL.NUMBERFONT = t.SelectedLanguage.."_stint-ucr50"
	GLOBAL.TALKINGFONT = t.SelectedLanguage.."_talkingfont"
	GLOBAL.SMALLNUMBERFONT = t.SelectedLanguage.."_stint-ucr20"
	GLOBAL.BODYTEXTFONT = t.SelectedLanguage.."_stint-ucr50"
	if rawget(GLOBAL,"NEWFONT") then
		GLOBAL.NEWFONT = t.SelectedLanguage.."_spirequal"
	end
	if rawget(GLOBAL,"NEWFONT_SMALL") then
		GLOBAL.NEWFONT_SMALL = t.SelectedLanguage.."_spirequal_small"
	end
	if rawget(GLOBAL,"NEWFONT_OUTLINE") then
		GLOBAL.NEWFONT_OUTLINE = t.SelectedLanguage.."_spirequal_outline"
	end
	if rawget(GLOBAL,"NEWFONT_OUTLINE_SMALL") then
		GLOBAL.NEWFONT_OUTLINE_SMALL = t.SelectedLanguage.."_spirequal_outline_small"
	end
end





function t.escapeR(str) --Удаляет \r из конца строки. Нужна для строк, загружаемых в юниксе.
	if string.sub(str, #str)=="\r" then return string.sub(str, 1, #str-1) else return str end
end


GLOBAL.getmetatable(TheSim).__index.UnregisterAllPrefabs = (function()
	local oldUnregisterAllPrefabs = GLOBAL.getmetatable(TheSim).__index.UnregisterAllPrefabs
	return function(self, ...)
		oldUnregisterAllPrefabs(self, ...)
		ApplyLocalizedFonts()
	end
end)()


--Вставляем функцию, подключающую русские шрифты
local OldRegisterPrefabs = GLOBAL.ModManager.RegisterPrefabs --Подменяем функцию,в которой нужно подгрузить шрифты и исправить глобальные шрифтовые константы
local function NewRegisterPrefabs(self)
	OldRegisterPrefabs(self)
	ApplyLocalizedFonts()
	GLOBAL.TheFrontEnd.consoletext:SetFont(GLOBAL.BODYTEXTFONT) --Нужно, чтобы шрифт в консоли не слетал
	GLOBAL.TheFrontEnd.consoletext:SetRegionSize(900, 404) --Чуть-чуть увеличил по вертикали, чтобы не обрезало буквы в нижней строке
end
GLOBAL.ModManager.RegisterPrefabs=NewRegisterPrefabs





--Узнаём тип локализации, и меняем содержимое таблицы с переводом PO, если нужно
--	t.CurrentTranslationType=GLOBAL.Profile:GetLocalizaitonValue("translation_type")
t.CurrentTranslationType = TheSim:GetSetting("translation", "translation_type")

if not t.CurrentTranslationType then --Если нет записи о типе, то делаем по умолчанию полный перевод
	t.CurrentTranslationType = t.TranslationTypes.Full
--		GLOBAL.Profile:SetLocalizaitonValue("translation_type",t.CurrentTranslationType)
	TheSim:SetSetting("translation", "translation_type", t.CurrentTranslationType)
end

require("RLP_support")


--Переопределяем функцию AddClassPostConstruct, чтобы она проверяла наличие файла и не падала при его отсутствии
local OldAddClassPostConstruct = AddClassPostConstruct
local function AddClassPostConstruct(path, ...)
	if not GLOBAL.kleifileexists("scripts/"..path..".lua") then
		print("RLP ERROR AddClassPostConstruct: file \""..path..".lua\" is not found. Skipping.")
		return
	end
	local res = OldAddClassPostConstruct(path, ...)
	return res
end


--!!! Временное исправление нерабочего русского языка в чате на выделенных серверах
AddClassPostConstruct("screens/chatinputscreen", function(self)
	if self.chat_edit then
		self.chat_edit:SetCharacterFilter(nil)
	end

end)

--[[--Увеличим область для текста в чате, чтобы не пропадали длинные русские буквы
AddClassPostConstruct("widgets/chatqueue", function(self)
	if self.messages and type(self.messages)=="table" and #self.messages>0 then
		for i,v in pairs(self.messages) do
			local w,h=v:GetRegionSize()
			v:SetRegionSize(w,h+2)
		end
	end
end)]]

--Для тех, кто пользуется ps4 или NACL должна быть возможность сохранять не в ини файле, а в облаке.
--Для этого дорабатываем функционал стандартного класса PlayerProfile
local function SetLocalizaitonValue(self,name,value) --Метод, сохраняющий опцию с именем name и значением value
    local USE_SETTINGS_FILE = GLOBAL.PLATFORM ~= "PS4" and GLOBAL.PLATFORM ~= "NACL"
 	if USE_SETTINGS_FILE then
		TheSim:SetSetting("translation", tostring(name), tostring(value))
	else
		self:SetValue(tostring(name), tostring(value))
		self.dirty = true
		self:Save() --Сохраняем сразу, поскольку у нас нет кнопки "применить"
	end
end
local function GetLocalizaitonValue(self,name) --Метод, возвращающий значение опции name
        local USE_SETTINGS_FILE = GLOBAL.PLATFORM ~= "PS4" and GLOBAL.PLATFORM ~= "NACL"
 	if USE_SETTINGS_FILE then
		return TheSim:GetSetting("translation", tostring(name))
	else
		return self:GetValue(tostring(name))
	end
end

--Расширяем функционал PlayerProfile дополнительной инициализацией двух методов и заданием дефолтных значений опций нашего перевода.
AddGlobalClassPostConstruct("playerprofile", "PlayerProfile", function(self)
	local USE_SETTINGS_FILE = GLOBAL.PLATFORM ~= "PS4" and GLOBAL.PLATFORM ~= "NACL"
 	if not USE_SETTINGS_FILE then
	        self.persistdata.update_is_allowed = true --Разрешено запускать обновление по умолчанию
	        self.persistdata.update_frequency = t.UpdatePeriod[3] --Раз в неделю по умолчанию
		local date=GLOBAL.os.date("*t")
		self.persistdata.last_update_date = tostring(date.day.."."..date.month.."."..date.year) --Текущая дата по умолчанию
	end
	self["SetLocalizaitonValue"]=SetLocalizaitonValue --метод задачи значения опции
	self["GetLocalizaitonValue"]=GetLocalizaitonValue --метод получения значения опции
end)





  
--Добавление кнопки настроек меню модов при наведении на русский мод
local OldHasModConfigurationOptions = GLOBAL.KnownModIndex and GLOBAL.KnownModIndex.HasModConfigurationOptions
if OldHasModConfigurationOptions then
	function GLOBAL.KnownModIndex:HasModConfigurationOptions(modname, ...)
		local res = OldHasModConfigurationOptions(self,modname)
		if self:GetModInfo(modname).name==modinfo.name then return true end
		return res
	end
end

--Переопределяем действие кнопки
AddGlobalClassPostConstruct("screens/modsscreen", "ModsScreen", function(self)

	if self.detailwarning and self.CreateDetailPanel then
		self.detailwarning:SetSize(25)
		local OldCreateDetailPanel=self.CreateDetailPanel
		function self:CreateDetailPanel(...)
			OldCreateDetailPanel(self,...)
			self.detailwarning:SetSize(25)
		end
	end
	if not self.ConfigureSelectedMod then return end
	self.OldConfigureSelectedMod=self.ConfigureSelectedMod
	local function NewConfigureSelectedMod(self)
		if GLOBAL.KnownModIndex:GetModInfo(self.currentmodname).name==modinfo.name then
			local LanguageOptions = require "screens/LanguageOptions"
			GLOBAL.TheFrontEnd:PushScreen(LanguageOptions())
		else
			self:OldConfigureSelectedMod()
		end
	end
	self.ConfigureSelectedMod=NewConfigureSelectedMod
end)

--Исправление бага с шрифтом в спиннерах
AddClassPostConstruct("widgets/spinner", function(self, options, width, height, textinfo, ...) --Выполняем подмену шрифта в спиннере из-за глупой ошибки разрабов в этом виджете
	if textinfo then return end
	self.text:SetFont(GLOBAL.BUTTONFONT)
end)



local function GetPoFileVersion(file) --Возвращает версию po файла
	local f = assert(io.open(file,"r"))
	local ver=nil
	for line in f:lines() do
		ver = string.match(t.escapeR(line),"#%s+Версия%s+(.+)%s*$")
		if ver then break end
	end
	f:close()
	if not ver then ver = "не задана" end
	return ver
end

--Проверяем версию по файла, и если она не соответствует текущей версии, то отключаем перевод
local poversion = GetPoFileVersion(t.StorePath..t.MainPOfilename)
if poversion~=modinfo.version then
	local OldStart = GLOBAL.Start --Переопределяем функцию, после выполнения которой можно будет вывести попап.
	function GLOBAL.Start() 
		ApplyLocalizedFonts()
		OldStart()
		local a,b="/","\\"
		if GLOBAL.PLATFORM == "NACL" or GLOBAL.PLATFORM == "PS4" or GLOBAL.PLATFORM == "LINUX_STEAM" or GLOBAL.PLATFORM == "OSX_STEAM" then
			a,b=b,a
		end
		local text="Версия игры: "..modinfo.version..", версия PO файла: "..poversion.."\nПуть: "..string.gsub(GLOBAL.CWD..t.StorePath,a,b)..t.MainPOfilename.."\nПеревод работает в режиме «Только чат»."
		local PopupDialogScreen = require "screens/popupdialog"
	        GLOBAL.TheFrontEnd:PushScreen(PopupDialogScreen("Неверная версия PO файла", text,
			{{text="Понятно", cb = function() GLOBAL.TheFrontEnd:PopScreen() end}}))
	end
	return
end


--Функция проверяет файл language.lua на наличие подключения po файла и старых версий русификации
function language_lua_has_rusification(filename)
	if not GLOBAL.kleifileexists(filename) then return false end --Нет файла? Нет проблем


	local f = assert(io.open(filename,"r")) --Читаем весь файл в буфер
	local content =""
	for line in f:lines() do
		content=content..line
	end
	f:close()

	content=string.gsub(content,"\r","")--Удаляем все возвраты каретки, на случай, если это юникс
	content=string.gsub(content,"%-%-%[%[.-%]%]","")--Удаляем многострочные комментарии
	if string.sub(content,#content)~="\n" then content=content.."\n" end --добавляем перенос строки в самом конце, если нужно
	local tocomment={}
	for str in string.gmatch(content,"([^\n]*)\n") do --Обходим все строки
		if not str then str="" end
		str=string.gsub(str,"%-%-.*$","")--Удаляем все однострочные комментарии
		--Запоминаем строки, которые нужно отключить
		if string.find(str,"LanguageTranslator:LoadPOFile(",1,true) then table.insert(tocomment,str) end --загрузка po
		if string.find(str,"russian_fix",1,true) then table.insert(tocomment,str) end --загрузка моей ранней версии русификации
	end
	if #tocomment==0 then return false end --Если не нашлось строк, которые нужно закомментировать, то выходим

	content={}
	local f=assert(io.open(filename,"r"))
	for line in f:lines() do --Снова считываем все строки, параллельно проверяя
		for _,str in ipairs(tocomment) do --обходим все строки, которые нужно закомментировать
			local a,b=string.find(line,str,1,true)
			if a then --если есть совпадение то...
				line=string.sub(line,1,a-1).."--"..str..string.sub(line,b+1)
				break --комментируем и прерываем цикл
			end
		end
		table.insert(content,line)
	end
	f:close()
	f = assert(io.open(filename,"w")) --Формируем новый language.lua с отключёнными строками
	for _,str in ipairs(content) do
		f:write(str.."\n")
	end
	f:close()
	return true
end


local languageluapath ="scripts/languages/language.lua"

if language_lua_has_rusification(languageluapath) then --Если в language.lua подключается русификация
	local OldStart=GLOBAL.Start --Переопределяем функцию, после выполнения которой можно будет вывести попап и перезагрузиться
	function GLOBAL.Start() 
		ApplyLocalizedFonts()
		OldStart()
		local a,b="/","\\"
		if GLOBAL.PLATFORM == "NACL" or GLOBAL.PLATFORM == "PS4" or GLOBAL.PLATFORM == "LINUX_STEAM" or GLOBAL.PLATFORM == "OSX_STEAM" then
			a,b=b,a
		end
		local text="В файле "..string.gsub("data/"..languageluapath,a,b).."\nнайдено подключение другой локализации.\nЭто подключение было деактивировано."
		local PopupDialogScreen = require "screens/popupdialog"
	        GLOBAL.TheFrontEnd:PushScreen(PopupDialogScreen("Обнаружена посторонняя локализация", text,
			{{text="Понятно", cb = function() GLOBAL.TheFrontEnd:PopScreen() GLOBAL.SimReset() end}}))
	end
end



local OldStart = GLOBAL.Start --
function GLOBAL.Start() 
	ApplyLocalizedFonts()
	OldStart()
end






if t.CurrentTranslationType==t.TranslationTypes.ChatOnly then
	Assets = {
	Asset("ATLAS",MODROOT.."images/eyebutton.xml"),
	Asset("ATLAS",MODROOT.."images/gradient.xml")}
	return
end












--!!!!!!!! ТУТ ПРЕРЫВАЕТСЯ ВЫПОЛНЕНИЕ МОДА, ЕСЛИ ТЕКУЩИЙ РЕЖИМ РУСИФИКАЦИИ - ТОЛЬКО ЧАТ!!!!!!!!!!!!!














Assets = {
	Asset("ATLAS",MODROOT.."images/eyebutton.xml"), --Кнопка с глазом
	Asset("ATLAS",MODROOT.."images/gradient.xml"), --Градиент на слишком длинных строках лога в настройках перевода
	Asset("ATLAS",MODROOT.."images/rus_mapgen.xml"), --Русифицированные пиктограммы в окне генерирования нового мира
	--Персонажи
	Asset("ATLAS",MODROOT.."images/rus_locked.xml"), 
	Asset("ATLAS",MODROOT.."images/rus_wickerbottom.xml"), 
	Asset("ATLAS",MODROOT.."images/rus_waxwell.xml"), 
	Asset("ATLAS",MODROOT.."images/rus_willow.xml"), 
	Asset("ATLAS",MODROOT.."images/rus_wilson.xml"), 
	Asset("ATLAS",MODROOT.."images/rus_woodie.xml"), 
	Asset("ATLAS",MODROOT.."images/rus_wes.xml"), 
	Asset("ATLAS",MODROOT.."images/rus_wolfgang.xml"), 
	Asset("ATLAS",MODROOT.."images/rus_wendy.xml"),
	Asset("ATLAS",MODROOT.."images/rus_wathgrithr.xml"),
	Asset("ATLAS",MODROOT.."images/rus_webber.xml"),
	Asset("ATLAS",MODROOT.."images/rus_random.xml"),

	Asset("ATLAS",MODROOT.."images/rus_names_wickerbottom.xml"), 
	Asset("ATLAS",MODROOT.."images/rus_names_willow.xml"), 
	Asset("ATLAS",MODROOT.."images/rus_names_wilson.xml"), 
	Asset("ATLAS",MODROOT.."images/rus_names_woodie.xml"), 
	Asset("ATLAS",MODROOT.."images/rus_names_wes.xml"), 
	Asset("ATLAS",MODROOT.."images/rus_names_wolfgang.xml"), 
	Asset("ATLAS",MODROOT.."images/rus_names_wendy.xml"),
	Asset("ATLAS",MODROOT.."images/rus_names_wathgrithr.xml"),
	Asset("ATLAS",MODROOT.."images/rus_names_webber.xml"),
	Asset("ATLAS",MODROOT.."images/rus_names_waxwell.xml"),
	Asset("ATLAS",MODROOT.."images/rus_names_random.xml"),
	}




--Возвращает корректную форму слова день (или другого, переданного вторым параметром)
local function StringTime(n,s)
	local pl_type=n%10==1 and n%100~=11 and 1 or(n%10>=2 and n%10<=4
       		and(n%100<10 or n%100>=20)and 2 or 3)
	s=s or {"день","дня","дней"}
	return s[pl_type]
end 



--Пытается сформировать правильные окончания в словах названия предмета str1 в соответствии действию action
--objectname - название префаба предмета
function rebuildname(str1,action,objectname)
	local function repsubstr(str,pos,substr)--вставить подстроку substr в строку str в позиции pos
		pos=pos-1
		return str:utf8sub(1,pos)..substr..str:utf8sub(pos+substr:utf8len()+1,str:utf8len())
	end
	if not str1 then
		return nil
	end
	local 	sogl=  {['б']=1,['в']=1,['г']=1,['д']=1,['ж']=1,['з']=1,['к']=1,['л']=1,['м']=1,['н']=1,['п']=1,
			['р']=1,['с']=1,['т']=1,['ф']=1,['х']=1,['ц']=1,['ч']=1,['ш']=1,['щ']=1}

	local sogl2 = {['г']=1,['ж']=1,['к']=1,['х']=1,['ц']=1,['ч']=1,['ш']=1,['щ']=1}
	local sogl3 = {["р"]=1,["л"]=1,["к"]=1,["Р"]=1,["Л"]=1,["К"]=1}

	local resstr=""
	local delimetr
	local wasnoun=false
	local wordcount=#(str1:gsub("[%s-]","~"):split("~"))
	local counter=0
	local FoundNoun
	local str=""
	str1=str1.." "
	local str1len=str1:utf8len()
	for i=1,str1len do
		delimetr=str1:utf8sub(i,i)
		if delimetr~=" " and delimetr~="-" then
			str=str..delimetr
		elseif #str>0 and (delimetr==" " or delimetr=="-") then
			counter=counter+1
			if action=="KILL" and objectname and str:utf8len()>2 then -- был убит (кем? чем?) Творительный
				--Особый случай, в objectname передаём имя префаба для более точного анализа его пола
				--Действие "KILL" не генерируется игрой, а используется только в этом моде для формирования сообщений о смерти в DST
				local function testnoun()
					if t.NamesGender["she"][string.lower(objectname)] then --женский род
						if str:utf8sub(str:utf8len()-1)=="ца" or str:utf8sub(str:utf8len()-1)=="ча" or str:utf8sub(str:utf8len()-1)=="ша" then
							str=repsubstr(str,str:utf8len(),"ей") FoundNoun=delimetr~="-"
						elseif str:utf8sub(str:utf8len())=="а" then
							str=repsubstr(str,str:utf8len(),"ой") FoundNoun=delimetr~="-"
						elseif str:utf8sub(-4)=="роня" then
							str=repsubstr(str,str:utf8len(),"ёй") FoundNoun=delimetr~="-"
						elseif str:utf8sub(-3)=="мля" then
							str=repsubstr(str,str:utf8len(),"ёй") FoundNoun=delimetr~="-"
						elseif str:utf8sub(str:utf8len())=="я" and str:utf8len()>3 then
							str=repsubstr(str,str:utf8len(),"ей") FoundNoun=delimetr~="-"
						elseif str:utf8sub(str:utf8len())=="ь" then
							str=str.."ю" FoundNoun=delimetr~="-"
						end
					elseif t.NamesGender["it"][string.lower(objectname)] then --средний род
						if str:utf8sub(-1)~="и" then
							str=str.."м" FoundNoun=delimetr~="-"
						end
					elseif t.NamesGender["plural"][string.lower(objectname)] or 
						   t.NamesGender["plural2"][string.lower(objectname)] then --множественное число
						if str:utf8sub(str:utf8len())=="а" or str:utf8sub(str:utf8len())=="ы" then
							str=repsubstr(str,str:utf8len(),"ами") FoundNoun=delimetr~="-"
						elseif str:utf8sub(str:utf8len())=="я" then
							str=repsubstr(str,str:utf8len(),"ями") FoundNoun=delimetr~="-"
						elseif str:utf8sub(str:utf8len())=="и" then
							if sogl2[str:utf8sub(str:utf8len()-1,str:utf8len()-1)] then
								str=repsubstr(str,str:utf8len(),"ами") FoundNoun=delimetr~="-"
							else 
								str=repsubstr(str,str:utf8len(),"ями") FoundNoun=delimetr~="-"
							end
						end
					else --мужской род
						if str:utf8sub(-3,-3)=="о" and str:utf8sub(str:utf8len())=="ь" and not sogl3[str:utf8sub(-4,-4) or "р"] then
							str=str:utf8sub(1,-4)..str:utf8sub(-2,-2).."ём" FoundNoun=delimetr~="-" 
						elseif str:utf8sub(str:utf8len()-1)=="ок" then
							str=repsubstr(str,str:utf8len()-1,"ком") FoundNoun=delimetr~="-"
						elseif str:utf8sub(str:utf8len()-2)=="чек" then
							str=repsubstr(str,str:utf8len()-1,"ком") FoundNoun=delimetr~="-"
						elseif str:utf8sub(str:utf8len()-1)=="ец" then
							str=repsubstr(str,str:utf8len()-1,"цем") FoundNoun=delimetr~="-"
						elseif str:utf8sub(str:utf8len()-2)=="ень" then
							str=repsubstr(str,str:utf8len()-2,"нем") FoundNoun=delimetr~="-"
						elseif str:utf8sub(str:utf8len()-1)=="дь" then
							str=repsubstr(str,str:utf8len(),"ем") FoundNoun=delimetr~="-"
						elseif str:utf8sub(str:utf8len()-2)=="арь" then
							str=repsubstr(str,str:utf8len(),"ём") FoundNoun=delimetr~="-"
						elseif str:utf8sub(str:utf8len()-1)=="рь" then
							str=repsubstr(str,str:utf8len(),"ем") FoundNoun=delimetr~="-"
						elseif str:utf8sub(str:utf8len()-1)=="ёр" then
							str=repsubstr(str,str:utf8len()-1,"ром") FoundNoun=delimetr~="-"
						elseif str:utf8sub(str:utf8len()-1)=="уй" then
							str=repsubstr(str,str:utf8len(),"ем") FoundNoun=delimetr~="-"
						elseif str:utf8sub(str:utf8len()-1)=="ай" then
							str=repsubstr(str,str:utf8len(),"ем") FoundNoun=delimetr~="-"
						elseif str:utf8sub(str:utf8len()-2)=="лей" then --улей
							str=repsubstr(str,str:utf8len()-1,"ьем") FoundNoun=delimetr~="-"
						elseif str:utf8sub(str:utf8len()-2)=="йль" then
							str=repsubstr(str,str:utf8len(),"ем") FoundNoun=delimetr~="-"
						elseif str:utf8sub(str:utf8len()-2)=="ель" then
							str=repsubstr(str,str:utf8len(),"ем") FoundNoun=delimetr~="-"
						elseif str:utf8sub(str:utf8len()-2)=="ень" then
							str=repsubstr(str,str:utf8len(),"ем") FoundNoun=delimetr~="-"
						elseif str:utf8sub(str:utf8len())=="ь" then
							str=repsubstr(str,str:utf8len(),"ём") FoundNoun=delimetr~="-"
						elseif sogl[str:utf8sub(-1)] then
							str=str.."ом" FoundNoun=delimetr~="-"
						end
					end
				end
				if counter~=wordcount and str:utf8len()>3 then --Если это не последнее слово, то это может быть прилагательное
					if t.NamesGender["she"][string.lower(objectname)] then --женский род
						if str:utf8sub(str:utf8len()-1)=="ая" then
							str=repsubstr(str,str:utf8len()-1,"ой")
						elseif str:utf8sub(str:utf8len()-1)=="яя" then
							str=repsubstr(str,str:utf8len()-1,"ей")
						elseif str:utf8sub(str:utf8len()-1)=="ья" then
							str=repsubstr(str,str:utf8len(),"ей")
						elseif str:utf8sub(-4)=="аяся" then
							str=repsubstr(str,str:utf8len()-3,"ейся")
						elseif not  FoundNoun then testnoun() end
					elseif t.NamesGender["it"][string.lower(objectname)] then --средний род
						if str:utf8sub(str:utf8len()-2)=="кое" then
							str=repsubstr(str,str:utf8len()-1,"им")
						elseif str:utf8sub(str:utf8len()-1)=="ое" then
							str=repsubstr(str,str:utf8len()-1,"ым")
						elseif str:utf8sub(str:utf8len()-1)=="ее" then
							str=repsubstr(str,str:utf8len()-1,"им")
						elseif not  FoundNoun then testnoun() end
					elseif t.NamesGender["plural"][string.lower(objectname)] or 
						   t.NamesGender["plural2"][string.lower(objectname)] then --множественное число
						if str:utf8sub(str:utf8len()-1)=="ые" then
							str=repsubstr(str,str:utf8len()-1,"ыми")
						elseif str:utf8sub(str:utf8len()-1)=="ие" then
							str=repsubstr(str,str:utf8len()-1,"ими")
						elseif str:utf8sub(str:utf8len()-1)=="ьи" then
							str=repsubstr(str,str:utf8len()-1,"ими")
						elseif not  FoundNoun then testnoun() end
					else --мужской род
						if str:utf8sub(str:utf8len()-1)=="ый" then
							str=repsubstr(str,str:utf8len()-1,"ым")
						elseif str:utf8sub(str:utf8len()-1)=="ий" then
							str=repsubstr(str,str:utf8len()-1,"им")
						elseif str:utf8sub(str:utf8len()-1)=="ой" then
							str=repsubstr(str,str:utf8len()-1,"ым")
						elseif not  FoundNoun then testnoun() end
					end
				else
					if not  FoundNoun then testnoun() end
				end			
			elseif action=="WALKTO" then --идти к (кому? чему?) Дательный
				if str:utf8sub(str:utf8len()-1)=="ая" and resstr=="" then
					str=repsubstr(str,str:utf8len()-1,"ой")
				elseif str:utf8sub(str:utf8len()-1)=="ая" then
					str=repsubstr(str,str:utf8len()-1,"ей")
				elseif str:utf8sub(str:utf8len()-1)=="яя" then
					str=repsubstr(str,str:utf8len()-1,"ей")
				elseif str:utf8sub(str:utf8len()-1)=="ец" then
					str=repsubstr(str,str:utf8len()-1,"цу")
				elseif str:utf8sub(str:utf8len()-1)=="ый" then
					str=repsubstr(str,str:utf8len()-1,"ому")
				elseif str:utf8sub(str:utf8len()-1)=="ий" then
					str=repsubstr(str,str:utf8len()-1,"ему")
				elseif str:utf8sub(str:utf8len()-1)=="ое" then
					str=repsubstr(str,str:utf8len()-1,"ому")
				elseif str:utf8sub(str:utf8len()-1)=="ее" then
					str=repsubstr(str,str:utf8len()-1,"ему")
				elseif str:utf8sub(str:utf8len()-1)=="ые" then
					str=repsubstr(str,str:utf8len()-1,"ым")
				elseif str:utf8sub(str:utf8len()-1)=="ой" and resstr=="" then
					str=repsubstr(str,str:utf8len()-1,"ому")
				elseif str:utf8sub(str:utf8len()-1)=="ья" and resstr=="" then
					str=repsubstr(str,str:utf8len()-1,"ьей")
				elseif str:utf8sub(str:utf8len()-2)=="орь" then
					str=str:utf8sub(1,str:utf8len()-3).."рю"
				elseif str:utf8sub(str:utf8len()-1)=="ек" then
					str=str:utf8sub(1,str:utf8len()-2).."ку"
					wasnoun=true
				elseif str:utf8sub(str:utf8len()-2)=="ень" then
					str=str:utf8sub(1,str:utf8len()-3).."ню"
				elseif str:utf8sub(str:utf8len()-1)=="ок" then
					str=repsubstr(str,str:utf8len()-1,"ку")
					wasnoun=true
				elseif str:utf8sub(str:utf8len()-1)=="ть" then
					str=repsubstr(str,str:utf8len(),"и")
					wasnoun=true
				elseif str:utf8sub(str:utf8len()-1)=="вь" then
					str=repsubstr(str,str:utf8len(),"и")
					wasnoun=true
				elseif str:utf8sub(str:utf8len()-1)=="ль" then
					str=repsubstr(str,str:utf8len(),"и")
					wasnoun=true
				elseif str:utf8sub(str:utf8len()-1)=="зь" then
					str=repsubstr(str,str:utf8len(),"и")
					wasnoun=true
				elseif str:utf8sub(str:utf8len()-1)=="нь" then
					str=repsubstr(str,str:utf8len(),"ю")
					wasnoun=true
				elseif str:utf8sub(str:utf8len()-1)=="рь" then
					str=repsubstr(str,str:utf8len(),"ю")
					wasnoun=true
				elseif str:utf8sub(str:utf8len()-1)=="ьи" then
					str=str.."м"
				elseif str:utf8sub(str:utf8len()-1)=="ки" and not wasnoun then
					str=repsubstr(str,str:utf8len(),"ам")
					wasnoun=true
				elseif str:utf8sub(str:utf8len())=="ы" and not wasnoun then
					str=repsubstr(str,str:utf8len(),"ам")
					wasnoun=true
				elseif str:utf8sub(str:utf8len())=="ы" and not wasnoun then
					str=repsubstr(str,str:utf8len(),"ам")
					wasnoun=true
				elseif str:utf8sub(str:utf8len())=="а" and not wasnoun then
					str=repsubstr(str,str:utf8len(),"е")
					wasnoun=true
				elseif str:utf8sub(str:utf8len())=="я" and not wasnoun then
					str=repsubstr(str,str:utf8len(),"е")
					wasnoun=true
				elseif str:utf8sub(str:utf8len())=="о" and not wasnoun then
					str=repsubstr(str,str:utf8len(),"у")
					wasnoun=true
				elseif str:utf8sub(str:utf8len()-1)=="це" and not wasnoun then
					str=repsubstr(str,str:utf8len()-1,"цу")
					wasnoun=true
				elseif str:utf8sub(str:utf8len())=="е" and not wasnoun then
					str=repsubstr(str,str:utf8len(),"ю")
					wasnoun=true
				elseif sogl[str:utf8sub(str:utf8len())] and not wasnoun then
					str=str.."у"
					wasnoun=true
				end
			--Изучить (Кого? Что?) Винительный
			--применительно к имени свиньи или кролика
			elseif action and objectname and (objectname=="pigman" or objectname=="pigguard" or objectname=="bunnyman") then 
				if str:utf8sub(str:utf8len()-2)=="нок" then
					str=str:utf8sub(1,str:utf8len()-2).."ка"
				elseif str:utf8sub(str:utf8len()-2)=="лец" then
					str=str:utf8sub(1,str:utf8len()-2).."ьца"
				elseif str:utf8sub(str:utf8len()-2)=="ный" then
					str=str:utf8sub(1,str:utf8len()-2).."ого"
				elseif str:utf8sub(str:utf8len()-1)=="ец" then
					str=str:utf8sub(1,str:utf8len()-2).."ца"
				elseif str:utf8sub(str:utf8len())=="а" then
					str=str:utf8sub(1,str:utf8len()-1).."у"
				elseif str:utf8sub(str:utf8len())=="я" then
					str=str:utf8sub(1,str:utf8len()-1).."ю"
				elseif str:utf8sub(str:utf8len())=="ь" then
					str=str:utf8sub(1,str:utf8len()-1).."я"
				elseif str:utf8sub(str:utf8len())=="й" then
					str=str:utf8sub(1,str:utf8len()-1).."я"
				elseif sogl[str:utf8sub(str:utf8len())] then
					str=str.."а"
				end
			elseif action then --Изучить (Кого? Что?) Винительный
				if str:utf8sub(str:utf8len()-1)=="ая" then
					str=repsubstr(str,str:utf8len()-1,"ую")
				elseif str:utf8sub(str:utf8len()-1)=="яя" then
					str=repsubstr(str,str:utf8len()-1,"юю")
				elseif str:utf8sub(str:utf8len())=="а" then
					str=repsubstr(str,str:utf8len(),"у")
				elseif str:utf8sub(str:utf8len())=="я" then
					str=repsubstr(str,str:utf8len(),"ю")
				end
			end
			resstr=resstr..str..delimetr
			str=""		
		end
	end
	resstr=resstr:utf8sub(1,resstr:utf8len()-1)
	return resstr
end
t.rebuildname = rebuildname


GLOBAL.testname=function(name,key)
	if name and (not key) and type(name)=="string" and rawget(STRINGS.NAMES,name:upper()) then key=name:upper() name=STRINGS.NAMES[key] end
	print("Идти к "..rebuildname(name,"WALKTO", key))
	print("Осмотреть "..rebuildname(name,"DEFAULTACTION", key))
	if key then
		print("Был убит "..rebuildname(name,"KILL",key))
	end
end


--Сохраняет в файле fn все имена с действием, указанным в параметре action)
local function printnames(fn,action,openfn)
	local filename = MODROOT..fn..".txt"
	local str1,str2
	local names={}
	local f=assert(io.open(MODROOT..(openfn or "names_new.txt"),"r"))
	for line in f:lines() do
		str1=string.match(line,"[.\t]([^.\t]*)$")
		str2=STRINGS.NAMES[str1]
		if not (t.RussianNames[str2] and t.RussianNames[str2]["KILL"]) then
			local s1
			if action=="DEFAULTACTION" then
				s1="Изучить "
			elseif action=="WALKTO" then
				s1="Идти к "
			elseif action=="KILL" then
				s1="Он был убит "
			end
			s1=s1..rebuildname(str2,action,str1:lower())
			local name=s1
			local len=s1:utf8len()
			while len<48 do
				name=name.."\t"
				len=len+8
			end
			s1=str2
			name=name..s1
			len=s1:utf8len()
			while len<48 do
				name=name.."\t"
				len=len+8
			end
			name=name..str1.."\n"
			table.insert(names,name)
		end
	end
	f:close()
	local file = io.open(filename, "w")
	for i,v in ipairs(names) do
		file:write(v)
	end
	file:close()
end



t.RussianNames = {} --Таблица с особыми формами названий предметов в различных падежах
t.ShouldBeCapped = {} --Таблица, в которой находится список названий, первое слово которых пишется с большой буквы

t.NamesGender={} --Таблица со списками имён, отсортированными по полам
t.NamesGender["he"]={}
t.NamesGender["he2"]={}
t.NamesGender["she"]={}
t.NamesGender["it"]={}
t.NamesGender["plural"]={}
t.NamesGender["plural2"]={}



--Объявляем таблицу особых тегов, присущих персонажам.
--Порядковый номер тега определяет его приоритет.
t.CharacterInherentTags={}
for char in pairs(GLOBAL.GetActiveCharacterList()) do
	t.CharacterInherentTags[char]={}
end

--делит строку на части по символу-разделителю. Возвращает и пустые вхождения:
--split("|a|","|") вернёт таблицу из "", "а" и ""
--split("а","|") вернёт таблицу из "а"
--split("","|") вернёт таблицу из ""
--split("|","|") вернёт таблицу из "" и ""
--По идее разделителем может служить сразу несколько символов (не тестировалось)
local function split(str,sep)
       	local fields, first = {}, 1
	str=str..sep
	for i=1,#str do
		if string.sub(str,i,i+#sep-1)==sep then
			fields[#fields+1]=(i<=first) and "" or string.sub(str,first,i-1)
			first=i+#sep
		end
	end
        return fields
end


local LetterCasesHash={u2l={["А"]="а",["Б"]="б",["В"]="в",["Г"]="г",["Д"]="д",["Е"]="е",["Ё"]="ё",["Ж"]="ж",["З"]="з",
							["И"]="и",["Й"]="й",["К"]="к",["Л"]="л",["М"]="м",["Н"]="н",["О"]="о",["П"]="п",["Р"]="р",
							["С"]="с",["Т"]="т",["У"]="у",["Ф"]="ф",["Х"]="х",["Ц"]="ц",["Ч"]="ч",["Ш"]="ш",["Щ"]="щ",
							["Ъ"]="ъ",["Ы"]="ы",["Ь"]="ь",["Э"]="э",["Ю"]="ю",["Я"]="я"},
					   l2u={["а"]="А",["б"]="Б",["в"]="В",["г"]="Г",["д"]="Д",["е"]="Е",["ё"]="Ё",["ж"]="Ж",["з"]="З",
							["и"]="И",["й"]="Й",["к"]="К",["л"]="Л",["м"]="М",["н"]="Н",["о"]="О",["п"]="П",["р"]="Р",
							["с"]="С",["т"]="Т",["у"]="У",["ф"]="Ф",["х"]="Х",["ц"]="Ц",["ч"]="Ч",["ш"]="Ш",["щ"]="Щ",
							["ъ"]="Ъ",["ы"]="Ы",["ь"]="Ь",["э"]="Э",["ю"]="Ю",["я"]="Я"}}
--первый символ в нижний регистр
local function firsttolower(tmp)
	if not tmp then return end
	local firstletter=tmp:utf8sub(1,1)
	firstletter = LetterCasesHash.u2l[firstletter] or firstletter
	return firstletter:lower()..tmp:utf8sub(2)
end

--первый символ в верхний регистр
local function firsttoupper(tmp)
	if not tmp then return end
	local firstletter=tmp:utf8sub(1,1)
	firstletter = LetterCasesHash.l2u[firstletter] or firstletter
	return firstletter:upper()..tmp:utf8sub(2)
end

function isupper(letter)
	if not letter or type(letter)~="string" then return end
	return LetterCasesHash.u2l[letter] or (#letter==1 and letter>="A" and letter<="Z")
end

function islower(letter)
	if not letter or type(letter)~="string" then return end
	return LetterCasesHash.l2u[letter] or (#letter==1 and letter>="a" and letter<="z")
end

local function russianupper(tmp)
	if not tmp then return end
	local res=""
	local letter
	for i=1,tmp:utf8len() do
		letter = tmp:utf8sub(i,i)
		letter = LetterCasesHash.l2u[letter] or letter
		res = res..letter:upper()
	end
	return res
end

local function russianlower(tmp)
	if not tmp then return end
	local res=""
	local letter
	for i=1,tmp:utf8len() do
		letter = tmp:utf8sub(i,i)
		letter = LetterCasesHash.u2l[letter] or letter
		res = res..letter:lower()
	end
	return res
end

--Функция ищет в реплике спец-тэги, оформленные в [] и выбирает нужный, соответствующий персонажу char
--Варианты с разным переводом для разного пола оформляются в [] и разделяются символом |.
--В общем случае оформляется так: [мужчина|женщина|оно|множественное число|имя префаба персонажа=его вариант]
--При этом каждый вариант без указания имени префаба определяет свою принадлежность в такой последовательности:
--первый — мужской вариант, второй — женский, третий — средний род, четвёртый — мн. число.
--Имя префаба можно указывать в любом из вариантов (например первом). Тогда оно не берётся в расчёт при анализе
--пустых (без указания имени префаба) вариантов: [wes=он молчун|это мужчина|wolfgang=силач|это женщина|это оно]
--Если в вариантах не указан нужный для char, то берётся вариант мужского пола (кроме webber'а, которому сперва
--попытается подставить вариант множественного числа, и Wx-78, который на русском считается мужским полом),
--если нет и этого, то ничего не подставится.
--Варианты полов можно задавать явно, указывая ключевые слова "he", "she", "it" или "plural"/"they"/"pl".
--Варианты с указанными префабами (и ключевыми словами) можно объединять в группы через запятую:
--[he=мужской|willow,wendy=женский без Уиккерботтом]
--Пример: "Скажи[plural=те], [приятель|милочка|создание|приятели|wickerbottom=дамочка], почему так[ой|ая|ое|ие] грустн[ый|ая|ое|ые]?"
--Необязательный параметр talker сообщает название префаба говорящего. Сейчас нужен для корректной обработки ситуации с Веббером
function t.ParseTranslationTags(message, char, talker, optionaltags)
	if not (message and string.find(message,"[",1,true)) then return message end

	local gender="neutral"
	local function parse(str)
		local vars=split(str,"|")
		local tags={}
		local function SelectByCustomTags(CustomTags)
			if not CustomTags then return false end
			if type(CustomTags)=="string" then return tags[CustomTags] end
			for _,tag in ipairs(CustomTags) do
				if tags[tag] then return tags[tag] end
			end
			return false
		end
		local counter=0
		for i,v in pairs(vars) do
			local vars2=split(v,"=")
			if #vars2==1 then counter=counter+1 end
			local path=(#vars2==2) and vars2[1] or 
			        (((counter==1) and "he")
				or ((counter==2) and "she")
				or ((counter==3) and "it")
				or ((counter==4) and "plural")
				or ((counter==5) and "neutral")
				or ((counter>5) and nil))
			if path then
				local vars3=split(path,",")
				for _,vv in ipairs(vars3) do
					local c=vv and vv:match("^%s*(.*%S)")
					c=c and c:lower()
					if c=="they" or c=="pl" then c="plural"
					elseif c=="nog" or c=="nogender" then c="neutral"
					elseif c=="def" then c="default" end
					if c then tags[c]=(#vars2==2) and vars2[2] or v end
				end
			end
		end
		str=tags and (tags[char] --сначала ищем по имени
			or SelectByCustomTags(t.CharacterInherentTags[char]) --потом по особым тегам персонажа
			or tags[gender] --потом пытаемся выбрать по полу персонажа
			or SelectByCustomTags(optionaltags) --потом ищем, есть ли в вариантах дополнительные теги
			or tags["default"] --или берём дефолтный тег
			or tags["neutral"] --если ничего не нашли, пытаемся выбрать нейтральный вариант
			or tags["he"] --если и его нет, то мужской пол (это уже неправильно, но лучше, чем ничего)
			or "") or "" --ладно, ничего, значит ничего
		return str
	end
	local function search(part)
		part=string.sub(part,2,-2)
		if not string.find(part,"[",1,true) then
			part=parse(part)
		else
			part=parse(part:gsub("%b[]",search))
		end
		return part
	end

	--Экранируем тег заглавной буквы
	local CaseAdoptationNeeded
	message, CaseAdoptationNeeded = message:gsub("%[adoptcase]","<adoptcase>")
	--Ищем теги-маркеры, которые нужно добавить в список optionaltags
	message=message:gsub("%[marker=(.-)]",function(marker)
		if not optionaltags then optionaltags={}
		elseif type(optionaltags)=="string" then optionaltags={optionaltags} end
		table.insert(optionaltags,marker)
		return ""
	end)
	
--[[	message=message:gsub("$(.-)%((.-)%)[adoptadjective%.(.-)%.(.-)=(.-)]",function(gender, case, adjective)
		adjective = FixPrefix(adjective, case:lower(), gender:lower())
		return adjective
	end)]]
	message=message:gsub("%[adoptadjective%.(.-)%.(.-)=(.-)]",function(gender, case, adjective)
		adjective = FixPrefix(adjective, case:lower(), gender:lower())
		return adjective
	end)

	if char then
		char=char:lower()
		if char=="generic" then char="wilson" end

		if rawget(GLOBAL,"CHARACTER_GENDERS") then
			if GLOBAL.CHARACTER_GENDERS.MALE and table.contains(GLOBAL.CHARACTER_GENDERS.MALE, char) then gender="he"
			elseif GLOBAL.CHARACTER_GENDERS.FEMALE and table.contains(GLOBAL.CHARACTER_GENDERS.FEMALE, char) then gender="she"
			elseif GLOBAL.CHARACTER_GENDERS.ROBOT and table.contains(GLOBAL.CHARACTER_GENDERS.ROBOT, char) then gender="he"
			elseif GLOBAL.CHARACTER_GENDERS.IT and table.contains(GLOBAL.CHARACTER_GENDERS.IT, char) then gender="it"
			elseif GLOBAL.CHARACTER_GENDERS.NEUTRAL and table.contains(GLOBAL.CHARACTER_GENDERS.IT, char) then gender="neutral"
			elseif GLOBAL.CHARACTER_GENDERS.PLURAL and table.contains(GLOBAL.CHARACTER_GENDERS.PLURAL, char) then gender="plural" end
		end
		--Если это Веббер и он говорит сам о себе, то это множественное число
		if char=="webber" and (not talker or talker:lower()==char) then gender="plural" end
	end
	message=search("["..message.."]") or message
	if CaseAdoptationNeeded then
		message=message:gsub("([^.!? ]?)(%s*)<adoptcase>(.)",function(before, space, symbol)
			if not before or before=="" then symbol=firsttoupper(symbol) else symbol=firsttolower(symbol) end
			return((before or "")..(space or "")..(symbol or ""))
		end)
	end
	return message
end






















--Делаем бекап названия версии игры
local UPDATENAME=GLOBAL.STRINGS.UI.MAINSCREEN.UPDATENAME

--Загружаем русификацию
LoadPOFile(t.StorePath..t.MainPOfilename, t.SelectedLanguage)

t.PO = GLOBAL.LanguageTranslator.languages[t.SelectedLanguage]

--Восстанавливаем название версии игры из бекапа
t.PO["STRINGS.UI.MAINSCREEN.UPDATENAME"] = UPDATENAME


function ExtractMeta(str, key)
	if not str:find("{",1, true) then return str end --Для увеличения скорости
	local gentbl = {male = "he", maleanimated = "he2", female = "she", femaleanimated = "she2",
					neutral = "it", plural = "plural", pluralanimated = "plural2"}
	local actions = {}
	local res = str:gsub("{([^}]+)}", function(meta)
		if meta=="forcecase" then
			t.ShouldBeCapped[key:lower()] = true
			return ""
		else
			local parts = meta:split("=")
			if #parts==2 then
				if parts[1]=="gender" then
					local gen = gentbl[parts[2]:lower()]
					if gen then
						t.NamesGender[gen][key:lower()] = true
					end
					return ""
				elseif parts[1]:sub(1,5)=="case." or parts[1]:sub(1,5)=="form." then --формы по падежам и действиям
					local act = parts[1]:sub(6):upper()
					if act=="DEF" or act=="DEFAULT" or act==t.AdjectiveCaseTags[t.DefaultActionCase]:upper() then
						act = "DEFAULTACTION"
					end
					actions[act] = parts[2]
					return ""
				end
			end
		end
	end)
	for act, rus in pairs(actions) do
		if not t.RussianNames[res] then
			t.RussianNames[res] = {}
			t.RussianNames[res]["DEFAULT"] = res --TODO: Это лишнее, нужно удалить
			t.RussianNames[res].path = key --добавляем путь
			if act~="DEFAULTACTION" then
				t.RussianNames[res]["DEFAULTACTION"] = rebuildname(res, "DEFAULTACTION")
			end
			if act~="WALKTO" then
				t.RussianNames[res]["WALKTO"] = rebuildname(res, "WALKTO")
			end
		end
		t.RussianNames[res][act] = rus
	end
	return res
end




























--Сохраняем строки анонсов на русском
local announcerus={}
local ru=t.PO
announcerus.LEFTGAME=ru["STRINGS.UI.NOTIFICATION.LEFTGAME"] or ""
announcerus.JOINEDGAME=ru["STRINGS.UI.NOTIFICATION.JOINEDGAME"] or ""
announcerus.KICKEDFROMGAME=ru["STRINGS.UI.NOTIFICATION.KICKEDFROMGAME"] or ""
announcerus.BANNEDFROMGAME=ru["STRINGS.UI.NOTIFICATION.BANNEDFROMGAME"] or ""
--announcerus.NEW_SKIN_ANNOUNCEMENT=ru["STRINGS.UI.NOTIFICATION.NEW_SKIN_ANNOUNCEMENT"] or ""


announcerus.DEATH_ANNOUNCEMENT_1=ru["STRINGS.UI.HUD.DEATH_ANNOUNCEMENT_1"] or ""
announcerus.DEATH_ANNOUNCEMENT_2_MALE=ru["STRINGS.UI.HUD.DEATH_ANNOUNCEMENT_2_MALE"] or ""
announcerus.DEATH_ANNOUNCEMENT_2_FEMALE=ru["STRINGS.UI.HUD.DEATH_ANNOUNCEMENT_2_FEMALE"] or ""
announcerus.DEATH_ANNOUNCEMENT_2_ROBOT=ru["STRINGS.UI.HUD.DEATH_ANNOUNCEMENT_2_ROBOT"] or ""
announcerus.DEATH_ANNOUNCEMENT_2_DEFAULT=ru["STRINGS.UI.HUD.DEATH_ANNOUNCEMENT_2_DEFAULT"] or ""
announcerus.GHOST_DEATH_ANNOUNCEMENT_MALE=ru["STRINGS.UI.HUD.GHOST_DEATH_ANNOUNCEMENT_MALE"] or ""
announcerus.GHOST_DEATH_ANNOUNCEMENT_FEMALE=ru["STRINGS.UI.HUD.GHOST_DEATH_ANNOUNCEMENT_FEMALE"] or ""
announcerus.GHOST_DEATH_ANNOUNCEMENT_ROBOT=ru["STRINGS.UI.HUD.GHOST_DEATH_ANNOUNCEMENT_ROBOT"] or ""
announcerus.GHOST_DEATH_ANNOUNCEMENT_DEFAULT=ru["STRINGS.UI.HUD.GHOST_DEATH_ANNOUNCEMENT_DEFAULT"] or ""
announcerus.REZ_ANNOUNCEMENT=ru["STRINGS.UI.HUD.REZ_ANNOUNCEMENT"] or ""
announcerus.START_AFK=ru["STRINGS.UI.HUD.START_AFK"] or ""
announcerus.STOP_AFK=ru["STRINGS.UI.HUD.STOP_AFK"] or ""
--	announcerus.VOTINGKICKSTART=ru["STRINGS.VOTING.KICK.START"] or ""
--	announcerus.VOTINGKICKSUCCESS=ru["STRINGS.VOTING.KICK.SUCCESS"] or ""
--	announcerus.VOTINGKICKFAILURE=ru["STRINGS.VOTING.KICK.FAILURE"] or ""


--Обнуляем их, чтобы они не перевелись, и сервер всегда писал на английском
ru["STRINGS.UI.NOTIFICATION.LEFTGAME"]=nil
ru["STRINGS.UI.NOTIFICATION.JOINEDGAME"]=nil
ru["STRINGS.UI.NOTIFICATION.KICKEDFROMGAME"]=nil
ru["STRINGS.UI.NOTIFICATION.BANNEDFROMGAME"]=nil
--ru["STRINGS.UI.NOTIFICATION.NEW_SKIN_ANNOUNCEMENT"]=nil
ru["STRINGS.UI.HUD.DEATH_ANNOUNCEMENT_1"]=nil
ru["STRINGS.UI.HUD.DEATH_ANNOUNCEMENT_2_MALE"]=nil
ru["STRINGS.UI.HUD.DEATH_ANNOUNCEMENT_2_FEMALE"]=nil
ru["STRINGS.UI.HUD.DEATH_ANNOUNCEMENT_2_ROBOT"]=nil
ru["STRINGS.UI.HUD.DEATH_ANNOUNCEMENT_2_DEFAULT"]=nil
ru["STRINGS.UI.HUD.GHOST_DEATH_ANNOUNCEMENT_MALE"]=nil
ru["STRINGS.UI.HUD.GHOST_DEATH_ANNOUNCEMENT_FEMALE"]=nil
ru["STRINGS.UI.HUD.GHOST_DEATH_ANNOUNCEMENT_ROBOT"]=nil
ru["STRINGS.UI.HUD.GHOST_DEATH_ANNOUNCEMENT_DEFAULT"]=nil
ru["STRINGS.UI.HUD.REZ_ANNOUNCEMENT"]=nil
ru["STRINGS.UI.HUD.START_AFK"]=nil
ru["STRINGS.UI.HUD.STOP_AFK"]=nil
--	ru["STRINGS.VOTING.KICK.START"]=nil
--	ru["STRINGS.VOTING.KICK.SUCCESS"]=nil
--	ru["STRINGS.VOTING.KICK.FAILURE"]=nil

--Строим хеш-таблицы
t.SpeechHashTbl={}

--Строит хеш-таблицу по имени персонажа. Английские реплики персонажа должны быть в STRINGS.CHARACTERS
--russource - таблица, в которой находятся все русские реплики персонажа в виде ["ключ из STRINGS"]="русский перевод"
--Если она не указана, то используется стандартная таблица, в которую загружаются реплики из PO файлов LanguageTranslator.languages[t.SelectedLanguage]
function t.BuildCharacterHash(charname,russource)
	local source=russource or t.PO
	local function CreateRussianHashTable(hashtbl,tbl,str)
		for i,v in pairs(tbl) do
			if type(v)=="table" then
				CreateRussianHashTable(hashtbl,tbl[i],str.."."..i)
			else
				local val=source[str.."."..i] or v
				--составляем спец-список всех сообщений, в которых есть отсылки на вставляемое имя (или на что-то другое)
				if v and string.find(v,"%s",1,true) then
					hashtbl["mentioned_class"]=hashtbl["mentioned_class"] or {}
					hashtbl["mentioned_class"][v]=val
				end
				if not hashtbl[v] then
					hashtbl[v]=val
				elseif type(hashtbl[v])=="string" and val~=hashtbl[v] then
					local temp=hashtbl[v] --преобразуем в список
					hashtbl[v]={}
					table.insert(hashtbl[v],temp)
					table.insert(hashtbl[v],val) --добавляем текущее
				elseif type(hashtbl[v])=="table" then
					local found=false
					for _,vv in ipairs(hashtbl[v]) do
						if vv==val then
							found=true
							break
						end
					end
					if not found then table.insert(hashtbl[v],val) end
				end
			end
		end
	end
	charname=charname:upper()
	if character=="WILSON" then character="GENERIC" end
	if character=="MAXWELL" then character="WAXWELL" end
	if character=="WIGFRID" then character="WATHGRITHR" end
	t.SpeechHashTbl[charname]={}
	CreateRussianHashTable(t.SpeechHashTbl[charname],STRINGS.CHARACTERS[charname],"STRINGS.CHARACTERS."..charname)
end


--Генерируем хеши для всех персонажей, перечисленных в STRINGS.CHARACTERS
for charname,v in pairs(STRINGS.CHARACTERS) do
	t.BuildCharacterHash(charname)
end

--Генерируем хеш-таблицы для названий предметов в обе стороны
--А так же извлекаем мета-данные о поле предмета, его особых формах и необходимости писать с большой буквы
t.SpeechHashTbl.NAMES = {Eng2Key = {}, Rus2Eng = {}}
for key, val in pairs(STRINGS.NAMES) do
	local fullkey = "STRINGS.NAMES."..key
	if t.PO[fullkey] then
		t.PO[fullkey] = ExtractMeta(t.PO[fullkey], key)
	end
	t.SpeechHashTbl.NAMES.Eng2Key[val] = key
	t.SpeechHashTbl.NAMES.Rus2Eng[t.PO[fullkey] or val] = val
end

--Извлекаем мета-данные из названий скинов
for key, val in pairs(STRINGS.SKIN_NAMES) do
	local fullkey = "STRINGS.SKIN_NAMES."..key
	if t.PO[fullkey] then
		t.PO[fullkey] = ExtractMeta(t.PO[fullkey], key)
	end
end


--Генерируем хеш-таблицы для имён свиней и кроликов
t.SpeechHashTbl.PIGNAMES={Eng2Rus={}}
for i,v in pairs(STRINGS.PIGNAMES) do
	t.SpeechHashTbl.PIGNAMES.Eng2Rus[v]=t.PO["STRINGS.PIGNAMES."..i] or v
	t.PO["STRINGS.PIGNAMES."..i]=nil
end
t.SpeechHashTbl.BUNNYMANNAMES={Eng2Rus={}}
for i,v in pairs(STRINGS.BUNNYMANNAMES) do
	t.SpeechHashTbl.BUNNYMANNAMES.Eng2Rus[v]=t.PO["STRINGS.BUNNYMANNAMES."..i] or v
	t.PO["STRINGS.BUNNYMANNAMES."..i]=nil
end



--t.SpeechHashTbl.PIGTALKS={}
--t.SpeechHashTbl.BUNNYMANTALKS={}
t.SpeechHashTbl.EPITAPHS={}

local function GetDataByPath(path)
	if type(path)~="table" then return path end
	local dat=GLOBAL
	for _,v in ipairs(path) do
		dat=dat[tonumber(v) or v]
		if not dat then break end
	end
	return dat
end

--Удаляем из таблицы с переводом PO некоторые реплики.
--Далее игра будет пользоваться хеш-таблицами для вывода русских реплик		
for i,v in pairs(t.PO) do
	local path=string.split(i,".")
	local data=nil
	if path and type(path)=="table" and path[2] then
		if path[2]=="CHARACTERS" then --Удаляем все реплики персонажей
			t.PO[i]=nil
--[[		elseif string.sub(path[2],1,9)=="PIG_TALK_" --Удаляем реплики свинов и свинов стражей
		   or string.sub(path[2],1,14)=="PIG_GUARD_TALK" then
			data=GetDataByPath(path)
			if data then t.SpeechHashTbl.PIGTALKS[data]=t.PO[i] end
			t.PO[i]=nil
		elseif string.sub(path[2],1,7)=="RABBIT_" then --Удаляем реплики зайцев
			data=GetDataByPath(path)
			if data then t.SpeechHashTbl.BUNNYMANTALKS[data]=t.PO[i] end
			t.PO[i]=nil]]
		elseif path[2]=="EPITAPHS" then--Удаляем эпитафии
			data=GetDataByPath(path)
			if data then
				t.SpeechHashTbl.EPITAPHS[data] = t.PO[i]
				t.SpeechHashTbl.EPITAPHS[data:upper()] = russianupper(t.PO[i])
			end
			t.PO[i]=nil
		end
	end
end




if t.CurrentTranslationType==t.TranslationTypes.Full then --Полный перевод. Ничего не делаем.
elseif t.CurrentTranslationType==t.TranslationTypes.InterfaceChat or t.CurrentTranslationType==t.TranslationTypes.ChatOnly then --Интерфейс и чат. Тоже ничего не делаем. Блокировка произойдёт позже.
	for charname,v in pairs(STRINGS.CHARACTERS) do
		t.SpeechHashTbl[charname]={}
	end
--	t.SpeechHashTbl.PIGTALKS={}
--	t.SpeechHashTbl.BUNNYMANTALKS={}
	t.SpeechHashTbl.EPITAPHS={}
	t.SpeechHashTbl.NAMES={Eng2Key={},Rus2Eng={}}
	t.SpeechHashTbl.PIGNAMES={Eng2Rus={}}
	t.SpeechHashTbl.BUNNYMANNAMES={Eng2Rus={}}

	if t.CurrentTranslationType==t.TranslationTypes.ChatOnly then --Только чат. Убираем перевод всего.
		local a1=t.PO["STRINGS.LMB"]
		local a2=t.PO["STRINGS.RMB"]
		t.PO={} --Да, вот так. Убираем весь перевод.
		t.PO["STRINGS.LMB"]=a1
		t.PO["STRINGS.RMB"]=a2
		Assets={Assets[1],Assets[2]} --Часть графики тоже отключаем
	else
		for i,v in pairs(t.PO) do
			if string.sub(i,8+1,8+3)~="UI." then t.PO[i]=nil end
		end
	end
end





--Подменяем названия режимов игры
if rawget(GLOBAL,"GAME_MODES") and STRINGS.UI.GAMEMODES then
	for i,v in pairs(GLOBAL.GAME_MODES) do
		for ii,vv in pairs(STRINGS.UI.GAMEMODES) do
			if v.text==vv then
				GLOBAL.GAME_MODES[i].text = t.PO["STRINGS.UI.GAMEMODES."..ii] or GLOBAL.GAME_MODES[i].text
			end
			if v.description==vv then
				GLOBAL.GAME_MODES[i].description = t.PO["STRINGS.UI.GAMEMODES."..ii] or GLOBAL.GAME_MODES[i].description
			end
		end
	end
end

--Подменяем шрифт, потому что тут уже инициализировался английский
AddClassPostConstruct("widgets/loadingwidget", function(self)
	local OldKeepAlive = self.KeepAlive
	function self:KeepAlive(...)
		local res = OldKeepAlive(self, ...)
		if self.loading_widget then
			self.loading_widget:SetFont(GLOBAL.UIFONT)
		end
		return res
	end
end)


local _utf8=require("1251")
local _1251=require("utf-8")

local function converttoutf8(str)
		return str:gsub('.',_1251)
end

local function convertfromutf8(str)
	return str
--[[		if not str or type(str)~="string" then return str end
	local str2=""
	for uchar in string.gfind(str, "([%z\1-\127\194-\244][\128-\191]*)") do
       		if #uchar==1 then
			str2=str2..uchar
		elseif #uchar==2 then
			local res=(uchar:byte(1)-0xC0)*0x40+uchar:byte(2)-0x80
			if _utf8[res] then str2=str2..string.char(_utf8[res]) end
		end
	end
	return str2]]
end


local AllPlayersList={} --Список всех игроков в игре, бывших за сессию. Нужен для случаев, когда игрока уже нет, а сообщение пришло

--Исправляем русские имена персонажей, которые приходят к нам в другой кодировке, и обновляем AllPlayersList
if GLOBAL.TheNet.GetClientTable then
	GLOBAL.getmetatable(GLOBAL.TheNet).__index.GetClientTable = (function()
		local oldGetClientTable = GLOBAL.getmetatable(GLOBAL.TheNet).__index.GetClientTable
		return function(self, ... )
			local res = oldGetClientTable(self, ...)
			if res and type(res)=="table" then for i,v in pairs(res) do
				if v.name and v.prefab then
					if t.CurrentTranslationType~=t.TranslationTypes.ChatOnly and v.name=="[Host]" then
						v.name="[Хост]"
					end
					AllPlayersList[v.name]=v.prefab or nil
				end
			end end
			return res
		end
	end)()
end


--Сообщения о событиях в игре
AddClassPostConstruct("widgets/eventannouncer", function(self)
	--Переопределяем глобальную функцию, формирующую анонс-сообщение о смерти
	--Делаем это тут, потому что она объявлена в классе eventannouncer, и не видна до обращения к этому классу.
	--Тут нам нужно позаботиться об выводе имени убийцы на английском языке.
	local oldGetNewDeathAnnouncementString=GLOBAL.GetNewDeathAnnouncementString
	function newGetNewDeathAnnouncementString(theDead, source, pkname)
		local str=oldGetNewDeathAnnouncementString(theDead, source, pkname)
		if GLOBAL.TheWorld and not GLOBAL.TheWorld.ismastersim then return str end
		if string.find(str,STRINGS.UI.HUD.DEATH_ANNOUNCEMENT_1,1,true) then
			--если игрок был убит
			local capturestring=nil
			if string.find(str,STRINGS.UI.HUD.DEATH_ANNOUNCEMENT_2_MALE,1,true) then
				capturestring="( "..STRINGS.UI.HUD.DEATH_ANNOUNCEMENT_1.." )(.*)("..STRINGS.UI.HUD.DEATH_ANNOUNCEMENT_2_MALE..")"
			elseif string.find(str,STRINGS.UI.HUD.DEATH_ANNOUNCEMENT_2_FEMALE,1,true) then
				capturestring="( "..STRINGS.UI.HUD.DEATH_ANNOUNCEMENT_1.." )(.*)("..STRINGS.UI.HUD.DEATH_ANNOUNCEMENT_2_FEMALE..")"
			elseif string.find(str,STRINGS.UI.HUD.DEATH_ANNOUNCEMENT_2_ROBOT,1,true) then
				capturestring="( "..STRINGS.UI.HUD.DEATH_ANNOUNCEMENT_1.." )(.*)("..STRINGS.UI.HUD.DEATH_ANNOUNCEMENT_2_ROBOT..")"
			elseif string.find(str,STRINGS.UI.HUD.DEATH_ANNOUNCEMENT_2_DEFAULT,1,true) then
				capturestring="( "..STRINGS.UI.HUD.DEATH_ANNOUNCEMENT_1.." )(.*)("..STRINGS.UI.HUD.DEATH_ANNOUNCEMENT_2_DEFAULT..")"
			else 
				capturestring="( "..STRINGS.UI.HUD.DEATH_ANNOUNCEMENT_1.." )(.*)(%.)$"
			end
			if capturestring then -- выяснилось, что кто-то убит
				local a, killername, b=str:match(capturestring)
				if killername then
					killername=t.SpeechHashTbl.NAMES.Rus2Eng[killername] or killername--Переводим на английский
					str=str:gsub(capturestring,"%1"..killername.."%3")
				end
			end
		end	
		return str
	end
	GLOBAL.GetNewDeathAnnouncementString=newGetNewDeathAnnouncementString
	
	--Сообщение о том, что кто-то был оживлён. Тут нужно подменить на английский источник оживления
	local oldGetNewRezAnnouncementString=GLOBAL.GetNewRezAnnouncementString
	function NewGetNewRezAnnouncementString(theRezzed, source, ...)
		source=source and (t.SpeechHashTbl.NAMES.Rus2Eng[source] or source) --Переводим имя на английский
		return oldGetNewRezAnnouncementString(theRezzed, source, ...)
	end
	GLOBAL.GetNewRezAnnouncementString=NewGetNewRezAnnouncementString

	--Вывод любых анонсов на экран. Тут подменяем все нестандартные фразы, и не только
	local OldShowNewAnnouncement = self.ShowNewAnnouncement
	if OldShowNewAnnouncement then function self:ShowNewAnnouncement(announcement, ...)
		--Ничего не делаем, если переводится только чат или только чат и интерфейс
		if t.CurrentTranslationType==t.TranslationTypes.ChatOnly or t.CurrentTranslationType==t.TranslationTypes.InterfaceChat then
			return OldShowNewAnnouncement(self, announcement, ...)
		end

		local gender, player, RussianMessage, name, name2, killerkey

		local function test(adder1,msg1,rusmsg1,adder2,msg2,rusmsg2,ending)
			if name or name2 then return end
			msg1=msg1 and msg1:gsub("([.%-?])","%%%1"):gsub("%%s","(.*)") or ""
			msg2=msg2 and msg2:gsub("([.%-?])","%%%1"):gsub("%%s","(.*)") or ""
			name, name2=announcement:match((adder1 or "")..msg1..(adder2 or "")..msg2)
			if name then RussianMessage=rusmsg1 end
			if adder2 and name and name2 and rusmsg2 then RussianMessage=RussianMessage..rusmsg2 end
			if ending and RussianMessage then RussianMessage=RussianMessage..ending end
		end
		--Проверяем голосования
--			test(nil,STRINGS.VOTING.KICK.START, announcerus.VOTINGKICKSTART)
--			test(nil,STRINGS.VOTING.KICK.SUCCESS, announcerus.VOTINGKICKSUCCESS)
--			test(nil,STRINGS.VOTING.KICK.FAILURE, announcerus.VOTINGKICKFAILURE)
		--Присоединение/Отсоединение
--		--C 176665 в этих двух изначально есть %s
--		test("(.*) ",STRINGS.UI.NOTIFICATION.JOINEDGAME, announcerus.JOINEDGAME)
--		test("(.*) ",STRINGS.UI.NOTIFICATION.LEFTGAME, announcerus.LEFTGAME)
		test(nil,STRINGS.UI.NOTIFICATION.JOINEDGAME, announcerus.JOINEDGAME)
		test(nil,STRINGS.UI.NOTIFICATION.LEFTGAME, announcerus.LEFTGAME)
		--Кик/Бан
		test(nil,STRINGS.UI.NOTIFICATION.KICKEDFROMGAME, announcerus.KICKEDFROMGAME)
		test(nil,STRINGS.UI.NOTIFICATION.BANNEDFROMGAME, announcerus.BANNEDFROMGAME)
		--Новый скин
--		test(nil,STRINGS.UI.NOTIFICATION.NEW_SKIN_ANNOUNCEMENT, announcerus.NEW_SKIN_ANNOUNCEMENT)
		if not name2 then
			--Реплики о смерти
			test("(.*) ",STRINGS.UI.HUD.DEATH_ANNOUNCEMENT_1, announcerus.DEATH_ANNOUNCEMENT_1,
			     " (.*)",STRINGS.UI.HUD.DEATH_ANNOUNCEMENT_2_MALE, announcerus.DEATH_ANNOUNCEMENT_2_MALE)
			test("(.*) ",STRINGS.UI.HUD.DEATH_ANNOUNCEMENT_1, announcerus.DEATH_ANNOUNCEMENT_1,
			     " (.*)",STRINGS.UI.HUD.DEATH_ANNOUNCEMENT_2_FEMALE, announcerus.DEATH_ANNOUNCEMENT_2_FEMALE)
			test("(.*) ",STRINGS.UI.HUD.DEATH_ANNOUNCEMENT_1, announcerus.DEATH_ANNOUNCEMENT_1,
			     " (.*)",STRINGS.UI.HUD.DEATH_ANNOUNCEMENT_2_ROBOT, announcerus.DEATH_ANNOUNCEMENT_2_ROBOT)
			test("(.*) ",STRINGS.UI.HUD.DEATH_ANNOUNCEMENT_1, announcerus.DEATH_ANNOUNCEMENT_1,
			     " (.*)",STRINGS.UI.HUD.DEATH_ANNOUNCEMENT_2_DEFAULT, announcerus.DEATH_ANNOUNCEMENT_2_DEFAULT)
			test("(.*) ",STRINGS.UI.HUD.DEATH_ANNOUNCEMENT_1, announcerus.DEATH_ANNOUNCEMENT_1, " (.*)%.$", nil, nil, ".")
			test("(.*) ",STRINGS.UI.HUD.GHOST_DEATH_ANNOUNCEMENT_MALE, announcerus.GHOST_DEATH_ANNOUNCEMENT_MALE)
			test("(.*) ",STRINGS.UI.HUD.GHOST_DEATH_ANNOUNCEMENT_FEMALE, announcerus.GHOST_DEATH_ANNOUNCEMENT_FEMALE)
			test("(.*) ",STRINGS.UI.HUD.GHOST_DEATH_ANNOUNCEMENT_ROBOT, announcerus.GHOST_DEATH_ANNOUNCEMENT_ROBOT)
			test("(.*) ",STRINGS.UI.HUD.GHOST_DEATH_ANNOUNCEMENT_DEFAULT, announcerus.GHOST_DEATH_ANNOUNCEMENT_DEFAULT)
			--Реплика об оживлении
			test("(.*) ",STRINGS.UI.HUD.REZ_ANNOUNCEMENT, announcerus.REZ_ANNOUNCEMENT, " (.*)%.$", nil, nil, ".")
			if name2 then --Было обнаружено второе имя, и это сообщение о смерти/оживлении
				--Переводим имя на русский, если получится
				killerkey=t.SpeechHashTbl.NAMES.Eng2Key[name2] --Получаем ключ имени
				if killerkey then
					name2=STRINGS.NAMES[killerkey] or STRINGS.NAMES["SHENANIGANS"] --Тут переводим имя на русский
					name2=t.RussianNames[name2] and t.RussianNames[name2]["KILL"] or rebuildname(name2,"KILL",killerkey) or name2
					if not t.ShouldBeCapped[killerkey:lower()] and not table.contains(GLOBAL.GetActiveCharacterList(), killerkey:lower()) then
						name2=firsttolower(name2)
					end
					killerkey=killerkey:lower()
					if table.contains(GLOBAL.GetActiveCharacterList(), killerkey) then killerkey=nil end
				end
			end
		end
		if name and RussianMessage then
			if GLOBAL.TheNet.GetClientTable then GLOBAL.TheNet:GetClientTable()	end --обновляем список игроков
			announcement = string.format((t.ParseTranslationTags(RussianMessage, AllPlayersList[name], "announce", killerkey)), name or "", name2 or "", "" ,"") or announcement
		end
        OldShowNewAnnouncement(self, announcement, ...)
	end end
end) -- для AddClassPostConstruct "widgets/eventannouncer"



--Подбирает сообщение из хеш-таблиц по указанному персонажу и сообщению на английском.
--Если персонаж не указан, используется уилсон.
--Возвращает переведённое сообщение и вторым параметром таблицу всех замен %s, если таковые были.
function t.GetFromSpeechesHash(message, char)
	local function GetMentioned(message,char)
		if not (message and t.SpeechHashTbl[char] and t.SpeechHashTbl[char]["mentioned_class"] and type(t.SpeechHashTbl[char]["mentioned_class"])=="table") then return nil end
		for i,v in pairs(t.SpeechHashTbl[char]["mentioned_class"]) do
			local mentions={string.match(message,"^"..(string.gsub(i,"%%s","(.*)")).."$")}
			if mentions and #mentions>0 then
				return v, mentions --возвращаем перевод (с незаменёнными %s) и список отсылок
			end
		end
		return nil
	end
	local mentions
	if not char then char = "GENERIC" end
	if message and t.SpeechHashTbl[char] then
		local umlautified = false
		if char=="WATHGRITHR" then
			local tmp = message:gsub("[\246ö]","o"):gsub("[\214Ö]","O") or message --подменяем и 1251 и UTF-8 версии
			umlautified = tmp~=message
			message = tmp
		end
		--переводим из хеш-таблицы родного персонажа или Уилсона (если не найден родной)
		local msg = t.SpeechHashTbl[char][message] or t.SpeechHashTbl["GENERIC"][message]
		if not msg and char=="WX78" then --Тут хеш-таблица не работает, приходится делать перебор
			for i, v in pairs(t.SpeechHashTbl["GENERIC"]) do
				if message==i:upper() then msg = v break end
			end
		end
		--в mentions попадает таблица всех найденных замен %s, если они есть
		if not msg then msg, mentions = GetMentioned(message,char) end
		if not msg then msg, mentions = GetMentioned(message,"GENERIC") end
		message = msg or message
		--если есть разные варианты переводов, то выбираем один из них случайным образом
		message = (type(message)=="table") and GLOBAL.GetRandomItem(message) or message
		if umlautified then
			if rawget(GLOBAL, "GetSpecialCharacterPostProcess") then
				--подменяем русские на английские, чтобы работала Umlautify
				local tmp = message:gsub("о","o"):gsub("О","O") or message
				message = GLOBAL.GetSpecialCharacterPostProcess("wathgrithr", tmp) or message
			else
				message = message:gsub("о","ö"):gsub("О","Ö") or message
			end
		end
	end
	return message, mentions
end


--Переводит сообщение на русский, пользуясь хеш-таблицами
--message - сообщение на английском
--entity - ссылка на говорящего это сообщение персонажа
function t.TranslateToRussian(message, entity)
--	print("t.TranslateToRussian", message, entity)
	if not (entity and entity.prefab and entity.components.talker and type(message)=="string") then return message end
	if entity:HasTag("playerghost") then --Если это реплика игрока-привидения
		message=string.gsub(message,"h","у")
		return message
--	elseif entity.prefab=="pigman" then --Если это реплика свина
--		return t.SpeechHashTbl.PIGTALKS[message] or message
--	elseif entity.prefab=="pigguard" then --Если это реплика свина-стража
--		print("pig talk detected")
--		return t.SpeechHashTbl.PIGTALKS[message] or message
--	elseif entity.prefab=="bunnyman" then --Если это реплика зайца
--		return t.SpeechHashTbl.BUNNYMANTALKS[message] or message
	end
	if t.SpeechHashTbl.EPITAPHS[message] then --если это описание эпитафии
		return t.SpeechHashTbl.EPITAPHS[message]
	end
	local ent=entity
	entity=entity.prefab:upper()
	if entity=="WILSON" then entity="GENERIC" end
	if entity=="MAXWELL" then entity="WAXWELL" end
	if entity=="WIGFRID" then entity="WATHGRITHR" end

	--Обработка сообщения
	local function TranslateMessage(message)
		--Получаем перевод реплики и список отсылок %s, если они есть в реплике
		if not message then return end
		local NotTranslated=message
		local msg, mentions=t.GetFromSpeechesHash(message,entity)
		message=msg or message
		
		if NotTranslated==message then return message end

		local killerkey
		if mentions then
			if #mentions>1 then
				killerkey=t.SpeechHashTbl.NAMES.Eng2Key[mentions[2]] --Получаем ключ имени убийцы
				if not killerkey and entity=="WX78" then --тут только полный перебор, т.к. он говорит всё в верхнем регистре
					for eng, key in pairs(t.SpeechHashTbl.NAMES.Eng2Key) do
						if eng:upper()==mentions[2] then killerkey = key break end
					end
				end
				mentions[2]=killerkey and STRINGS.NAMES[killerkey] or mentions[2]
				if killerkey then
					mentions[2]=t.RussianNames[mentions[2]] and t.RussianNames[mentions[2]]["KILL"] or rebuildname(mentions[2],"KILL",killerkey) or mentions[2]
					if not t.ShouldBeCapped[killerkey:lower()] and not table.contains(GLOBAL.GetActiveCharacterList(), killerkey:lower()) then
						mentions[2]=firsttolower(mentions[2])
					end
					killerkey=killerkey:lower()
					if table.contains(GLOBAL.GetActiveCharacterList(), killerkey) then killerkey=nil end
				end
			end
		end
		--Подстраиваем сообщение под пол персонажа
		message=(t.ParseTranslationTags(message, ent.prefab, nil, killerkey)) or message
		--Подставляем имена, если они есть
		message=string.format(message, GLOBAL.unpack(mentions or {"","","",""}))
		if entity=="WX78" then
			message=russianupper(message) or message
		end
		return message
	end

	--Делим реплику на куски из строк по переносу строки
	--Это нужно для совместимости с модами, которые что-то добавляют в реплику через \n
	local messages=split(message,"\n") or {message}
	message=""
	local i=1
	--Пытаемся перевести по отдельности и парами, потому что есть реплики из двух строк
	while i<=#messages do
		local trans
		trans=TranslateMessage(messages[i])
		if trans~=messages[i] then --Получили перевод реплики
			message=message..(i>1 and "\n" or "")..trans
			if i<#messages then --Если реплика не последняя
				--Переводим, если получится, следующую строку
				message=message..TranslateMessage("\n"..messages[i+1])
				--Собираем оставшиеся строки
				for k=i+2,#messages do message=message.."\n"..messages[k] end
			end
			break --выходим из цикла
		elseif i<#messages then --не получили, пытаемся объединить со следующей и перевести
			trans=TranslateMessage(messages[i].."\n"..messages[i+1])
			if trans~=messages[i].."\n"..messages[i+1] then --Получилось перевести обе
				--Добавляем перевод
				message=message..(i>1 and "\n" or "")..trans
				--Собираем оставшиеся строки
				for k=i+2,#messages do message=message.."\n"..messages[k] end
				break --выходим из цикла
			else--Обе не перевелись
				message=message..(i>1 and "\n" or "")..messages[i]
				i=i+1 --переходим к следующей реплике (она отдельно ещё не проверялась)
			end
		else --это была последняя, и она не перевелась
			message=message..(i>1 and "\n" or "")..messages[i]
			break
		end
	end
	return message
end



--Перевод сообщения на русский на стороне клиента
if rawget(GLOBAL,"Networking_Talk") then
	local OldNetworking_Talk=GLOBAL.Networking_Talk

	function Networking_Talk(guid, message, ...)
--		print("Networking_Talk", guid, message, ...)
		local entity = GLOBAL.Ents[guid]
		message=t.TranslateToRussian(message,entity) or message --Переводим на русский
		if OldNetworking_Talk then OldNetworking_Talk(guid, message, ...) end
	end
	GLOBAL.Networking_Talk=Networking_Talk
end


--Перевод на русский произносимого на сервере
if GLOBAL.TheNet.Talker then
    GLOBAL.getmetatable(GLOBAL.TheNet).__index.Talker = (function()
        local oldTalker = GLOBAL.getmetatable(GLOBAL.TheNet).__index.Talker
        return function(self, message, entity, ... )
            oldTalker(self, message, entity, ...)
 
            local inst=entity and entity:GetGUID() or nil
            inst=inst and GLOBAL.Ents[inst] or nil --определяем инстанс персонажа по entity
            if inst and inst.components.talker.widget then --если он может говорить
                if message and type(message)=="string" then
                    --Делаем одноразовую подмену для последующего задания текста, в котором осуществляем перевод.
                    local OldSetString = inst.components.talker.widget.text.SetString
                    function inst.components.talker.widget.text:SetString(str, ...)
                        str = t.TranslateToRussian(str, inst) or str --переводим
                        OldSetString(self, str, ...)
                        self.SetString = OldSetString
                    end
                end
            end
        end
    end)()
end
--Перевод на русский произносимого на сервере
--[[if GLOBAL.TheNet.Talker then
	GLOBAL.getmetatable(GLOBAL.TheNet).__index.Talker = (function()
		local oldTalker = GLOBAL.getmetatable(GLOBAL.TheNet).__index.Talker
		return function(self, message, entity, ... )
			oldTalker(self, message, entity, ...)

			local inst=entity and entity:GetGUID() or nil 
			inst=inst and GLOBAL.Ents[inst] or nil --определяем инстанс персонажа по entity
			if inst and inst.components.talker.widget then --если он может говорить
				message=t.TranslateToRussian(message,inst) or message --переводим
				print("translating to rusian:", message)
				if message and type(message)=="string" then
					inst.components.talker.widget.text:SetString(message) --меняем текст
					print("inst.components.talker.widget.text",inst.components.talker.widget.text)
				end
			end
		end
	end)()
end--]]

--Тут мы должны переделать описание скелета, чтобы в него не попал русский
AddPrefabPostInit("skeleton_player", function(inst)
	local function reassignfn(inst) --функция переопределяет функцию. Туповато, но менять лень
		inst.components.inspectable.Oldgetspecialdescription=inst.components.inspectable.getspecialdescription
		function inst.components.inspectable.getspecialdescription(inst, viewer, ...)
			local message=inst.components.inspectable.Oldgetspecialdescription(inst, viewer, ...)
			
			if not message then return message end

			local player=rawget(GLOBAL,"ThePlayer") or GLOBAL.GetPlayer()
			local key=player and player.prefab:upper() or "GENERIC"
--				local key=inst.char:upper()
			local deadgender=GLOBAL.GetGenderStrings(inst.char)
			local m=STRINGS.CHARACTERS[key] and STRINGS.CHARACTERS[key].DESCRIBE and STRINGS.CHARACTERS[key].DESCRIBE.SKELETON_PLAYER and STRINGS.CHARACTERS[key].DESCRIBE.SKELETON_PLAYER[deadgender] or STRINGS.CHARACTERS.GENERIC.DESCRIBE.SKELETON_PLAYER[deadgender]
			if not m then return message end
			local dead,killer=string.match(message,(string.gsub(m,"%%s","(.*)"))) --вытаскиваем имена из сообщения
			if not (m and dead and killer) then return message end

			dead=inst.playername or t.SpeechHashTbl.NAMES.Rus2Eng[dead] or dead --переводим на английский имя убитого
			killer=t.SpeechHashTbl.NAMES.Rus2Eng[killer] or killer --Переводим на английский имя убийцы

			message=string.format(m,dead,killer)
			return message
		end
	end
	if inst.SetSkeletonDescription and not inst.OldSetSkeletonDescription then
		inst.OldSetSkeletonDescription=inst.SetSkeletonDescription
		function inst.SetSkeletonDescription(inst, ...)
			inst.OldSetSkeletonDescription(inst, ...)
			reassignfn(inst)
		end
	end
	if inst.OnLoad and not inst.OldOnLoad then
		inst.OldOnLoad=inst.OnLoad
		function inst.OnLoad(inst, ...)
			inst.OldOnLoad(inst, ...)
			reassignfn(inst)
		end
	end
end)


--Тут мы должны перехватывать название предмета у blueprint и переводить на английский
AddPrefabPostInit("blueprint", function(inst)
	local function reassignfn(inst)
		if inst.recipetouse then
			local name = STRINGS.NAMES[string.upper(inst.recipetouse)] or STRINGS.NAMES[inst.recipetouse]
			if name then
				name = t.SpeechHashTbl.NAMES.Rus2Eng[name] or name
				inst.components.named:SetName(name.." Blueprint")
			end
		end
	end
	if inst.OnLoad and not inst.OldOnLoad then
		inst.OldOnLoad=inst.OnLoad
		function inst.OnLoad(inst, data)
			if data and data.recipetouse and not STRINGS.NAMES[string.upper(data.recipetouse)] then
				STRINGS.NAMES[string.upper(data.recipetouse)]="Предмет из отключённого мода"
				inst.OldOnLoad(inst, data)
				STRINGS.NAMES[string.upper(data.recipetouse)]=nil
			else
				inst.OldOnLoad(inst, data)
			end
			reassignfn(inst)
		end
	end
	reassignfn(inst)
end)



--Вешает хук на любой метод класса указанного объекта.
--Функция fn получает в качестве параметров ссылку на объект и все параметры перехватываемого метода.
--DoAfter определяет, выполняется ли хук до, или после метода.
--Если функция fn выполняется до метода и возвращает результат, то этот результат считается таблицей и распаковывается в качестве параметров оригинального метода.
--ExecuteNow пригодится, если нужно выполнить действие сразу в момент установки хука.
local function SetHookFunction(obj, method, fn, DoAfter, ExecuteNow, ...)
	if obj and method and type(method)=="string" and fn and type(fn)=="function" then
		if ExecuteNow then fn(obj, ...) end
		if obj[method] then
			local Old=obj[method]
			obj[method]=function(obj, ...)
				local params={...}
				if not DoAfter then local a={fn(obj, ...)} if #a>0 then params=a end end
				Old(obj, GLOBAL.unpack(params))
				if DoAfter then fn(obj, ...) end
			end
		end
	end
end










--Остальное не выполняется, если перевод в режиме только чата
if t.CurrentTranslationType~=mods.RussianLanguagePack.TranslationTypes.ChatOnly then

	local function HookUpImage(img, DefaultAtlasPath, NewAtlasPath, ListToChange)
		if not img then return end
		local OldSetTexture = img.SetTexture
		function img.SetTexture(self, atlas, tex, default_tex, ...)
--			print("img.SetTexture")
			if atlas and tex then
				if atlas:sub(1,#DefaultAtlasPath)==DefaultAtlasPath then
					local name1 = atlas:sub(#DefaultAtlasPath+1,-5)
					local name2 = tex:sub(1,-5)
					if ListToChange[name1] and ListToChange[name1]==name2 then
--						print("atlas",atlas)
--						print("tex",tex)
--						print("name1",name1)
--						print("name2",name2)
						atlas = NewAtlasPath..name1..".xml"
						tex = "rus_"..tex
						default_tex = default_tex and tex --Не совсем корректно, зато точно не упадёт
					end
				end
			end
			local res = OldSetTexture(self, atlas, tex, default_tex, ...)
			return res
		end
		if img.atlas and img.texture then img:SetTexture(img.atlas, img.texture) end
	end

	--Подменяем портреты
	AddClassPostConstruct("widgets/characterselect", function(self)
		local charlist = {wickerbottom=1,waxwell=1,willow=1,wilson=1,woodie=1,wes=1,wolfgang=1,wendy=1,wathgrithr=1,webber=1}
		local texnames = {locked="locked",random="random"}
		for name in pairs(charlist) do texnames[name] = name.."_none" end
		if self.heroportrait then HookUpImage(self.heroportrait, "bigportraits/", "images/rus_", texnames) end
		if self.leftsmallportrait then HookUpImage(self.leftsmallportrait.image, "bigportraits/", "images/rus_", texnames) end
		if self.leftportrait then HookUpImage(self.leftportrait.image, "bigportraits/", "images/rus_", texnames) end
		if self.rightportrait then HookUpImage(self.rightportrait.image, "bigportraits/", "images/rus_", texnames) end
		if self.rightsmallportrait then HookUpImage(self.rightsmallportrait.image, "bigportraits/", "images/rus_", texnames) end
	end)

	--Подменяем русские имена в лобби и правим другие мелочи
	AddClassPostConstruct("screens/lobbyscreen", function(self)
		local charlist = {wickerbottom=1,willow=1,wilson=1,woodie=1,wes=1,wolfgang=1,wendy=1,wathgrithr=1,webber=1,random=1}
		local texnames = {}
		for name in pairs(charlist) do texnames["names_"..name] = name end
		if self.heroname then HookUpImage(self.heroname, "images/", "images/rus_", texnames) end
		if 	self.disconnectbutton then
			self.disconnectbutton.text:Nudge({x=25,y=0,z=0})
			self.disconnectbutton.text_shadow:Nudge({x=25,y=0,z=0})
			self.disconnectbutton.text:SetSize( self.disconnectbutton.text.size-6 )
			self.disconnectbutton.text_shadow:SetSize( self.disconnectbutton.text_shadow.size-6 )
		end
		if self.loadout_title then
			self.loadout_title:SetString(STRINGS.UI.LOBBYSCREEN.LOADOUT_TITLE..self.loadout_title:GetString():sub(1,-#STRINGS.UI.LOBBYSCREEN.LOADOUT_TITLE-1))
		end
	end)
	
	--Подменяем русские имена в виджете внешнего вида персонажа
	AddClassPostConstruct("widgets/playeravatarpopup", function(self)
		local charlist = {wickerbottom=1,willow=1,wilson=1,woodie=1,wes=1,wolfgang=1,wendy=1,wathgrithr=1,webber=1,random=1}
		local texnames = {}
		for name in pairs(charlist) do texnames["names_"..name] = name end
		if self.character_name then HookUpImage(self.character_name, "images/", "images/rus_", texnames) end
	end)
	
	AddClassPostConstruct("screens/skinsscreen", function(self)
		if self.title and self.title:GetString():sub(-#STRINGS.UI.SKINSSCREEN.TITLE)==STRINGS.UI.SKINSSCREEN.TITLE then
			self.title:SetString(STRINGS.UI.SKINSSCREEN.TITLE..self.title:GetString():sub(1,-#STRINGS.UI.SKINSSCREEN.TITLE-1))
		end
	end)

	AddClassPostConstruct("screens/playerstatusscreen", function(self)
		if self.OnBecomeActive then
			local OldOnBecomeActive = self.OnBecomeActive
			function self:OnBecomeActive(...)
				local res = OldOnBecomeActive(self, ...)
					if self.player_widgets then
						for _, v in pairs(self.player_widgets) do
							if v.age and v.age.SetString then
								local OldSetString = v.age.SetString
								function v.age:SetString(str, ...)
									if str then
										str = str:gsub("(%d+)(.+)", function (days, word)
											if word~=STRINGS.UI.PLAYERSTATUSSCREEN.AGE_DAY and word~=STRINGS.UI.PLAYERSTATUSSCREEN.AGE_DAYS then return end
											return days.." "..StringTime(days)
										end)
									end
									local res = OldSetString(self, str, ...)
									return res
								end
								v.age:SetString(v.age:GetString())
							end
						end
					end
				return res
			end
		end
	end)
	
	AddClassPostConstruct("widgets/uiclock", function(self)
		if self._text and self._text.SetString then
			local OldSetString = self._text.SetString
			function self._text:SetString(str, ...)
				if str then
					str = str:gsub(STRINGS.UI.HUD.CLOCKSURVIVED.."(.+)(%d+)(%s+)(.+)", function (sep1, days, sep2, word)
						if word~=STRINGS.UI.HUD.CLOCKDAY and word~=STRINGS.UI.HUD.CLOCKDAYS then return end
						return StringTime(days, {"Прожит", "Прожито", "Прожиты"})..sep1..days..sep2..StringTime(days)
					end)
				end
				local res = OldSetString(self, str, ...)
				return res
			end
		end
	end)
	
	AddClassPostConstruct("widgets/playeravatarpopup", function(self)
		if self.age then
			local OldSetString = self.age.SetString
			function self.age:SetString(str, ...)
				if str then
					str = str:gsub(STRINGS.UI.PLAYER_AVATAR.AGE_SURVIVED.."(.+)(%d+)(%s+)(.+)", function (sep1, days, sep2, word)
						if word~=STRINGS.UI.PLAYER_AVATAR.AGE_DAY and word~=STRINGS.UI.PLAYER_AVATAR.AGE_DAYS then return end
						return StringTime(days, {"Прожит", "Прожито", "Прожиты"})..sep1..days..sep2..StringTime(days)
					end)
				end
				local res = OldSetString(self, str, ...)
				return res
			end
			self.age:SetString(self.age:GetString())
		end
	end)

	--Переводим названия дней недели
	if GLOBAL.TheNet.ListSnapshots then
		GLOBAL.getmetatable(GLOBAL.TheNet).__index.ListSnapshots = (function()
			local oldListSnapshots = GLOBAL.getmetatable(GLOBAL.TheNet).__index.ListSnapshots
			return function(self, ...)
				local list=oldListSnapshots(self, ...)
				if list and #list>0 and list[1].timestamp then
					local daysofweek={"Monday","Tuesday","Wednesday","Thursday","Friday","Saturday","Sunday"}
					local rusdaysofweek={"Понедельник","Вторник","Среда","Четверг","Пятница","Суббота","Воскресенье"}
					local rusdaysofweek3={"Пнд","Втр","Срд","Чтв","Птн","Сбт","Вск"}
					for _,v in ipairs(list) do
						for ii,vv in ipairs(daysofweek) do
							if string.sub(v.timestamp,1,#vv):lower()==vv:lower() then
								v.timestamp=rusdaysofweek[ii]..string.sub(v.timestamp,#vv+1)
								break
							elseif string.sub(v.timestamp,1,3):lower()==string.sub(vv,1,3):lower() then
								v.timestamp=rusdaysofweek3[ii]..string.sub(v.timestamp,4)
								break
							elseif string.sub(v.timestamp,1,2):lower()==string.sub(vv,1,2):lower() then
								v.timestamp=string.sub(rusdaysofweek3[ii],1,2)..string.sub(v.timestamp,3)
								break
							end

						end
					end
				end
				return list
			end
		end)()
	end




	--Окно просмотра серверов, двигаем контролсы, исправляем надписи
	AddClassPostConstruct("screens/serverlistingscreen", function(self)
		if self.nav_bar and self.nav_bar.title then
			local w, h = self.nav_bar.title:GetRegionSize()
			self.nav_bar.title:SetRegionSize(w+50, h)
		end
		if self.join_button then
			self.join_button.text:SetSize(33)
		end
		if self.NAME and self.NAME.text and self.NAME.arrow then
			self.NAME.text:Nudge({x=20,y=0,z=0})
			self.NAME.arrow:Nudge({x=20,y=0,z=0})
		end
		if self.DETAILS and self.DETAILS.arrow and self.DETAILS.text then
				self.DETAILS.text:Nudge({x=15,y=0,z=0})
				self.DETAILS.arrow:Nudge({x=13,y=0,z=0})
		end
		if self.PLAYERS and self.PLAYERS.text then
				self.PLAYERS.text:Nudge({x=2,y=0,z=0})
		end
		if self.PING and self.PING.text then
				self.PING.text:Nudge({x=3,y=0,z=0})
		end
		if self.title then
			local checkstr = STRINGS.UI.SERVERLISTINGSCREEN.SERVER_LIST_TITLE_INTENT:gsub("%%s", "(.+)")
			local intentions = {}
			for key, str in pairs(STRINGS.UI.INTENTION) do intentions[str] = key end
			local OldSetString = self.title.SetString
			function self.title:SetString(str, ...)
				if str then
					local int = str:match(checkstr)
					if int and intentions[int] then
						if intentions[int]=="SOCIAL" then
							str = "Дружеские сервера"
						elseif intentions[int]=="COOPERATIVE" then
							str = "Командные сервера"
						elseif intentions[int]=="COMPETITIVE" then
							str = "Соревновательные сервера"
						elseif intentions[int]=="MADNESS" then
							str = "Сервера типа «Безумие»"
						elseif intentions[int]=="ANY" then
							str = "Сервера всех стилей"
						end
					end
				end
				local res = OldSetString(self, str, ...)
				return res
			end
			self.title:SetString(self.title:GetString())
		end
		if self.server_count then
			local OldSetString = self.server_count.SetString
			if OldSetString then
				function self.server_count:SetString(str, ...)
					if str and str:sub(-#STRINGS.UI.SERVERLISTINGSCREEN.SHOWING-1)==STRINGS.UI.SERVERLISTINGSCREEN.SHOWING..")" then
						str = "("..STRINGS.UI.SERVERLISTINGSCREEN.SHOWING.." "..str:sub(2, -#STRINGS.UI.SERVERLISTINGSCREEN.SHOWING-3)..")"
						str = str:gsub(STRINGS.UI.SERVERLISTINGSCREEN.SHOWING.." (%d-) ",function(n)
							n = tonumber(n)
							if not n then return end
							local function StringTime2(n,s)
								local pl_type = n%10==1 and n%100~=11 and 1 or (n%10==2 and (n%100<10 or n%100>=20) and 2 or 3)
								s = s or {"Показан","Показано","Показаны"}
								return s[pl_type]
							end 
							return StringTime2(n).." "..tostring(n).." "
							
						end)
					end
					local res = OldSetString(self, str, ...)
					return res
				end
			end
		end
	end)



	--Сохраняем непереведённый текст настроек приватности серверов в свойствах мира (см. ниже)
	local privacy_options = {}
	for i,v in pairs(STRINGS.UI.SERVERCREATIONSCREEN.PRIVACY) do
		privacy_options[v] = i
	end

	--Баг разработчиков, не переводятся радиобаттоны в настройках при создании сервера
	AddClassPostConstruct("widgets/serversettingstab", function(self)
		if self.privacy_type and self.privacy_type.buttons and self.privacy_type.buttons.buttonwidgets then
			for _,option in pairs(self.privacy_type.buttons.options) do
				if privacy_options[option.text] then
					option.text = STRINGS.UI.SERVERCREATIONSCREEN.PRIVACY[ privacy_options[option.text] ]
				end
				
			end
			for i,v in ipairs(self.privacy_type.buttons.buttonwidgets) do
				v.button.text:SetFont(GLOBAL.NEWFONT)
				v.button:SetTextSize(self.privacy_type.buttons.buttonsettings.font_size-2)
			end   
		end
		if self.server_intention then
			self.server_intention.button.text:SetSize(23)
			self.server_intention.button.text:Nudge({x=-3,y=0,z=0})
		end
	end)

	--Сохраняем непереведённый текст настроек в свойствах мира (см. ниже)
	local SandboxMenuData = {}
	for i,v in pairs(STRINGS.UI.SANDBOXMENU) do
		SandboxMenuData[v] = i
	end


	--Виджет выбора свойств мира. Исправляем надписи, согласовываем слова
	AddClassPostConstruct("widgets/customizationlist", function(self)
		if self.optionwidgets then
			for i,v in pairs(self.optionwidgets) do
				for ii,vv in pairs(v:GetChildren()) do
					if vv.name and vv.name:upper()=="TEXT" then --Заголовки групп настроек
						local words = vv:GetString():split(" ")
						local res
						if #words==2 then
							local second = SandboxMenuData[ words[2] ]
							words[2] = STRINGS.UI.SANDBOXMENU[second] or words[2]
							if second and words[1]==STRINGS.UI.SANDBOXMENU.LOCATION.FOREST then
								if second=="CHOICEAMTDAY" then
									res = words[2].." в лесу"
								elseif second=="CHOICEMONSTERS" or second=="CHOICEANIMALS" or second=="CHOICERESOURCES" then
									res = words[2].." леса"
								elseif second=="CHOICEFOOD" or second=="CHOICECOOKED"then
									res = words[2]..", доступная в лесу"
								elseif second=="CHOICEMISC" then
									res = "Лесной "..firsttolower(words[2])
								end
							elseif second and words[1]==STRINGS.UI.SANDBOXMENU.LOCATION.CAVE then
								if second=="CHOICEAMTDAY" then
									res = words[2].." в пещерах"
								elseif second=="CHOICEMONSTERS" or second=="CHOICEANIMALS" or second=="CHOICERESOURCES" then
									res = words[2].." пещер"
								elseif second=="CHOICEFOOD" or second=="CHOICECOOKED"then
									res = words[2]..", доступная в пещерах"
								elseif second=="CHOICEMISC" then
									res = "Пещерный "..firsttolower(words[2])
								end
							elseif second and words[1]==STRINGS.UI.SANDBOXMENU.LOCATION.UNKNOWN then
								if second=="CHOICEAMTDAY" then
									res = words[2].." в каком-то мире"
								elseif second=="CHOICEMONSTERS" or second=="CHOICEANIMALS" or second=="CHOICERESOURCES" then
									res = words[2].." какого-то мира"
								elseif second=="CHOICEFOOD" or second=="CHOICECOOKED"then
									res = words[2]..", доступная в каком-то мире"
								elseif second=="CHOICEMISC" then
									res = words[1].." "..firsttolower(words[2])
								end
							end
						end
						if res then vv:SetString(res) end
					elseif vv.name and vv.name:upper()=="OPTION" then --Спиннеры, нужно перевести в них текст
						for iii,vvv in pairs(vv:GetChildren()) do
							if vvv.name and vvv.name:upper()=="SPINNER" then
								for _,opt in ipairs(vvv.options) do
									if SandboxMenuData[opt.text] then
										opt.text = STRINGS.UI.SANDBOXMENU[ SandboxMenuData[opt.text] ]
									elseif opt.text then
										local words = opt.text:split(" ")
										for idx, txt in ipairs(words) do
											local p = SandboxMenuData[txt]
											words[idx] = p and STRINGS.UI.SANDBOXMENU[p] or words[idx]
										end
										if words[2]==STRINGS.UI.SANDBOXMENU.DAY then
											if words[1]==STRINGS.UI.SANDBOXMENU.EXCLUDE then words= {"Без","дня"}
											elseif words[1]==STRINGS.UI.SANDBOXMENU.SLIDELONG then words[1]="Долгий" end
										elseif words[2]==STRINGS.UI.SANDBOXMENU.DUSK then
											if words[1]==STRINGS.UI.SANDBOXMENU.EXCLUDE then words= {"Без","вечера"}
											elseif words[1]==STRINGS.UI.SANDBOXMENU.SLIDELONG then words[1]="Долгий" end
										elseif words[2]==STRINGS.UI.SANDBOXMENU.NIGHT then
											if words[1]==STRINGS.UI.SANDBOXMENU.EXCLUDE then words= {"Без","ночи"}
											elseif words[1]==STRINGS.UI.SANDBOXMENU.SLIDELONG then words[1]="Долгая" end
										end
										opt.text = words[1] or opt.text
										for idx=2,#words do opt.text = opt.text.." "..firsttolower(words[idx]) end
									end
								end
								vvv:UpdateState()
							elseif vvv.name and vvv.name:upper()=="IMAGEPARENT" then
								local list={["day.tex"]=1,
											["season.tex"]=1,
											["season_start.tex"]=1,
											["world_size.tex"]=1,
											["world_branching.tex"]=1,
											["world_loop.tex"]=1,
											["world_map.tex"]=1,
											["world_start.tex"]=1,
											["winter.tex"]=1,
											["summer.tex"]=1,
											["autumn.tex"]=1,
											["spring.tex"]=1}
								for iiii,vvvv in pairs(vvv:GetChildren()) do
									if vvvv.name and vvvv.name:upper()=="IMAGE" then
										if list[vvvv.texture] then
											vvvv:SetTexture(MODROOT.."images/rus_mapgen.xml", "rus_"..vvvv.texture)
										end
									end
								end
							end
						end
					end
				end
			end
		end
	end)


	--Сохраняем непереведённый текст пресетов настроек в свойствах мира (см. ниже)
	local PresetLevels = {}
	for i,v in pairs(STRINGS.UI.CUSTOMIZATIONSCREEN.PRESETLEVELS) do
		PresetLevels[v] = i
	end
	for i,v in pairs(STRINGS.UI.CUSTOMIZATIONSCREEN.PRESETLEVELDESC) do
		PresetLevels[v] = i
	end

	--Баг разработчиков: Не переведённые пресеты
	AddClassPostConstruct("widgets/customizationtab", function(self)
		if self.presets then
			for _,v in ipairs(self.presets) do
				v.text = PresetLevels[v.text] and STRINGS.UI.CUSTOMIZATIONSCREEN.PRESETLEVELS[ PresetLevels[v.text] ] or v.text
				v.desc = PresetLevels[v.desc] and STRINGS.UI.CUSTOMIZATIONSCREEN.PRESETLEVELDESC[ PresetLevels[v.desc] ] or v.desc
			end
		end
		if self.addmultileveltext then
			self.addmultileveltext:SetString("Многоуровневый")
		end
	end)


	--согласовываем слово "дней" с количеством дней
	AddClassPostConstruct("widgets/worldresettimer", function(self)
		if self.countdown_message then self.countdown_message:SetSize(27) end
		SetHookFunction(self.countdown_message, "SetString", function(self, str)
			local val=tonumber((str or ""):match(" ([^ ]*)$"))
			return str..(val and " "..StringTime(val,{"секунду","секунды","секунд"}) or "")
		end, false, true, self.countdown_message and self.countdown_message:GetString())

		if self.survived_message then self.survived_message:SetSize(27) end
		SetHookFunction(self.survived_message, "SetString", function(self, str)
			local val=tonumber((str or ""):match(" ([^ ]*)$"))
			return str..(val and " "..StringTime(val) or "")
		end, false, true, self.survived_message and self.survived_message:GetString())
	end)

end-- для if t.CurrentTranslationType~=t.TranslationTypes.ChatOnly


--Меняем размер текста на кнопочках
--[[	AddClassPostConstruct("screens/serveradminscreen", function(self)
	SetHookFunction(self.clear_button, "Disable", function(self) self:SetTextSize(35) end, true, self.clear_button and not self.clear_button:IsEnabled())
	SetHookFunction(self.undo_button, "Disable", function(self) self:SetTextSize(35) end, true, self.clear_button and not self.undo_button:IsEnabled())
end)]]






--Проверяем наличие пустых строк, которые специальным образом маркируются на Notabenoid
for i,v in pairs(t.PO) do
	if v=="<пусто>" then t.PO[i]="" end
end











--------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------



--Перегоняем перевод в STRINGS
GLOBAL.TranslateStringTable(GLOBAL.STRINGS)



local function fixupper()
	print("fixupper begin")
	local f = io.open(MODROOT.."russian_new_.po")
	local content = f:read("*all")
	f:close()
	local c = GLOBAL.deepcopy(t.ShouldBeCapped)
	content = content:gsub('"STRINGS%.NAMES%.([^"]+)"(.-)msgstr "([^"]+)"', function(key, data, rus)
		local found = false
		local endadder = ""
		if t.RussianNames[rus] then
			for act, list in pairs(t.ActionsToSave) do
				for _,rec in ipairs(list) do
					if rec.pth==key then
						if rebuildname(rus, act, key:lower())~=rec.trans then
							local a = act=="DEFAULTACTION" and "case."..t.AdjectiveCaseTags[t.DefaultActionCase]:upper() or "form."..act:upper()
							endadder = endadder..(endadder~="" and '"\n"' or "").."{"..a.."="..rec.trans.."}"
							found = true
						else
							print('Found redundant normal form "'..rec.trans..'" for '..act:upper()..' action of '..rus..' ('..key..'). Skipping.')
						end
						break
					end
				end
			end
		end
		local adder2 = ""
		if c[key:lower()] then
			c[key:lower()] = nil
			adder2 = "{forcecase}"
			found = true
		end
		for gender, tbl in pairs(t.NamesGender) do
			local gen = gender
			if gen=="he" then gen = "male" end
			if gen=="he2" then gen = "maleanimated" end
			if gen=="she" then gen = "female" end
			if gen=="it" then gen = "neutral" end
			if gen=="plural2" then gen = "pluralanimated" end
			if tbl[key:lower()] then
				adder2 = adder2.."{gender="..gen.."}"
				found = true
			end
		end
		if adder2~="" then adder2 = '"\n"'..adder2 end
		if endadder~="" then endadder = '"\n"'..endadder end
		if found then
			return '"STRINGS.NAMES.'..key..'"'..data..'msgstr "'..((adder2~="" or endadder~="")and '"\n"' or '')..rus..adder2..endadder..'"'
		end
	end)
	print("NOT FOUND in uppercase:")
	dumptable(c)
	local f = io.open(MODROOT.."russian_new2.po", "w")
	f:write(content)
	f:close()
	print("fixupper end")
end

--fixupper()









--Функция меняет окончания прилагательного prefix в зависимости от падежа, пола и числа предмета
function FixPrefix(prefix, act, item)
	if not t.NamesGender then return prefix end
--	prefix=prefix.." "
	local soft23={["г"]=1,["к"]=1,["х"]=1}
	
	local soft45={["г"]=1,["ж"]=1,["к"]=1,["ч"]=1,["х"]=1,["ш"]=1,["щ"]=1}
	local endings={}
	--Таблица окончаний в зависимости от действия и пола
	--case2 и case3, а так же case4 и case5 — твёрдый и мягкий пары
				-- влажный      синий  скользкий    простой    большой
	--Именительный Кто? Что?
	endings["nom"]={
		he=		{case1="ый",case2="ий",case3="ий",case4="ой",case5="ой"},
		he2=	{case1="ый",case2="ий",case3="ий",case4="ой",case5="ой"},
		she=	{case1="ая",case2="ая",case3="ая",case4="ая",case5="ая"},
		it=		{case1="ое",case2="ее",case3="ое",case4="ое",case5="ое"},
		plural=	{case1="ые",case2="ие",case3="ие",case4="ые",case5="ие"},
		plural2={case1="ые",case2="ие",case3="ие",case4="ые",case5="ие"}}
	--Винительный Кого? Что?
	endings["acc"]={
		he=		{case1="ый",case2="ий",case3="ий",case4="ой",case5="ой"},
		he2=	{case1="ого",case2="его",case3="ого",case4="ого",case5="ого"},
		she=	{case1="ую",case2="ую",case3="ую",case4="ую",case5="ую"},
		it=		{case1="ое",case2="ее",case3="ое",case4="ое",case5="ое"},
		plural=	{case1="ые",case2="ие",case3="ие",case4="ые",case5="ие"},
		plural2={case1="ых",case2="их",case3="их",case4="ых",case5="их"}}
	--Дательный Кому? Чему?
	endings["dat"]={
		he=		{case1="ому",case2="ему",case3="ому",case4="ому",case5="ому"},
		he2=	{case1="ому",case2="ему",case3="ому",case4="ому",case5="ому"},
		she=	{case1="ой",case2="ей",case3="ой",case4="ой",case5="ой"},                          
		it=		{case1="ому",case2="ему",case3="ому",case4="ому",case5="ому"},
		plural=	{case1="ым",case2="им",case3="им",case4="ым",case5="им"},
		plural2={case1="ым",case2="им",case3="им",case4="ым",case5="им"}}
	--Творительный Кем? Чем?
	endings["abl"]={
		he=		{case1="ым",case2="им",case3="им",case4="ым",case5="им"},
		he2=	{case1="ым",case2="им",case3="им",case4="ым",case5="им"},
		she=	{case1="ой",case2="ей",case3="ой",case4="ой",case5="ой"},
		it=		{case1="ым",case2="им",case3="им",case4="ым",case5="им"},
		plural=	{case1="ыми",case2="ими",case3="ими",case4="ыми",case5="ими"},
		plural2=	{case1="ыми",case2="ими",case3="ими",case4="ыми",case5="ими"}}
	--Родительный Кого? Чего?
	endings["gen"]={
		he=		{case1="ого",case2="его",case3="ого",case4="ого",case5="ого"},
		he2=	{case1="ого",case2="его",case3="ого",case4="ого",case5="ого"},
		she=	{case1="ой",case2="ей",case3="ой",case4="ой",case5="ой"},
		it=		{case1="ого",case2="его",case3="ого",case4="ого",case5="ого"},
		plural=	{case1="ых",case2="их",case3="их",case4="ых",case5="их"},
		plural2={case1="ых",case2="их",case3="их",case4="ых",case5="их"}}
	--Предложный О ком? О чём?
	endings["loc"]={
		he=		{case1="ом",case2="ем",case3="ом",case4="ом",case5="ом"},
		he2=	{case1="ом",case2="ем",case3="ом",case4="ом",case5="ом"},
		she=	{case1="ой",case2="ей",case3="ой",case4="ой",case5="ой"},
		it=		{case1="ом",case2="ем",case3="ом",case4="ом",case5="ом"},
		plural=	{case1="ых",case2="их",case3="их",case4="ых",case5="их"},
		plural2={case1="ых",case2="их",case3="их",case4="ых",case5="их"}}
		
	--дополнительные поля под различные действия в игре
	endings["NOACTION"] = endings["nom"]
	endings["DEFAULTACTION"] = endings["acc"]
	endings["WALKTO"] = endings["dat"]
	endings["SLEEPIN"] = endings["loc"]
	
	--Определим пол
	local gender="he"
	if endings["nom"][item] then --Если item содержит непосредственно пол
		gender = item
	else
		if t.NamesGender["he2"][item] then gender="he2"
		elseif t.NamesGender["she"][item] then gender="she"
		elseif t.NamesGender["it"][item] then gender="it"
		elseif t.NamesGender["plural"][item] then gender="plural"
		elseif t.NamesGender["plural2"][item] then gender="plural2" end
	end

	--Особый случай. Для действия "Собрать" у меня есть три записи с заменённым текстом. Там получается множественное число.
	if act=="PICK" and item and t.RussianNames[STRINGS.NAMES[string.upper(item)]] and t.RussianNames[STRINGS.NAMES[string.upper(item)]][act] then gender="plural" end
	--Ищем переданное действие в таблице выше

	act = endings[act] and act or (item and "DEFAULTACTION" or "nom")
	
	local words=string.split(prefix," ") --разбиваем на слова
	prefix=""
	for _,word in ipairs(words) do
		if --[[isupper(word:utf8sub(1,1)) and ]]word:utf8len()>3 then
			--Заменяем по всем возможным сценариям
			if word:utf8sub(-2)=="ый" then
				word=word:utf8sub(1,word:utf8len()-2)..endings[act][gender]["case1"]
			elseif word:utf8sub(-2)=="ий" then
				if soft23[word:utf8sub(-3,-3)] then
					word=word:utf8sub(1,word:utf8len()-2)..endings[act][gender]["case3"]
				else
					word=word:utf8sub(1,word:utf8len()-2)..endings[act][gender]["case2"]
				end
			elseif word:utf8sub(-2)=="ой" then
				if soft45[word:utf8sub(-3,-3)] then
					word=word:utf8sub(1,word:utf8len()-2)..endings[act][gender]["case5"]
				else
					word=word:utf8sub(1,word:utf8len()-2)..endings[act][gender]["case4"]
				end
			end
		end
		prefix=prefix..word.." "
	end
	prefix=prefix:utf8sub(1,1)..russianlower(prefix:utf8sub(2,-2))
	return prefix
end


if t.CurrentTranslationType~=t.TranslationTypes.ChatOnly then --Выполняем, если не только чат

	if t.CurrentTranslationType~=t.TranslationTypes.InterfaceChat then
		--Ниже идут функции непосредственного склонения предметов и формирования названий
		-- выполняем если не "только чат" и не "интерфейс/чат" (т.е. если перевод полный)


		--Подменяем имена персонажей, создаваемых с консоли в игре.
		local OldSetPrefabName = GLOBAL.EntityScript.SetPrefabName
		function GLOBAL.EntityScript:SetPrefabName(name,...)
			OldSetPrefabName(self,name,...)
			if not self.entity:HasTag("player") then return end
			self.name=t.SpeechHashTbl.NAMES.Rus2Eng[self.name] or self.name
		end



		local GetAdjectiveOld = GLOBAL.EntityScript["GetAdjective"]
		--Новая версия функции, выдающей качество предмета
		function GetAdjectiveNew(self)
			local str=GetAdjectiveOld(self)
			if str and self.prefab then
				local player=rawget(GLOBAL,"ThePlayer") or GLOBAL.GetPlayer()
				local act=player.components.playercontroller:GetLeftMouseAction() --Получаем текущее действие
				if act then act=act.action.id or "NOACTION" else act="NOACTION" end
				str=FixPrefix(str,act,self.prefab) --склоняем окончание префикса
				if act~="NOACTION" then --если есть действие, то нужно сделать с маленькой буквы
					str=firsttolower(str)
				end
			end
			return str
		end
		GLOBAL.EntityScript["GetAdjective"]=GetAdjectiveNew --подменяем функцию, выводящую качества продуктов



		--Фикс для hoverer, передающий в GetDisplayName действие, если оно есть
		AddClassPostConstruct("widgets/hoverer", function(self)
			if not self.OnUpdate then return end
			local OldOnUpdate=self.OnUpdate
			function self:OnUpdate(...)
				local changed = false
				local OldlmbtargetGetDisplayName
				local lmb = self.owner and self.owner.components and self.owner.components.playercontroller and self.owner.components.playercontroller:GetLeftMouseAction()
				if lmb and lmb.target and lmb.target.GetDisplayName then
					changed = true
					OldlmbtargetGetDisplayName = lmb.target.GetDisplayName
					lmb.target.GetDisplayName = function(self)
						return OldlmbtargetGetDisplayName(self, lmb)
					end
				end
				OldOnUpdate(self, ...)
				if changed then
					lmb.target.GetDisplayName = OldlmbtargetGetDisplayName
				end
			end
		end)



		local GetDisplayNameOld=GLOBAL.EntityScript["GetDisplayName"] --сохраняем старую функцию, выводящую название предмета
		function GetDisplayNameNew(self, act) --Подмена функции, выводящей название предмета. В ней реализовано склонение в зависимости от действия (переменная аct)

			local name = GetDisplayNameOld(self)
			local player = rawget(GLOBAL,"ThePlayer") or GLOBAL.GetPlayer()
			
		--	if not player then return name end --Если не удалось получить instance игрока, то возвращаем имя на англ. и выходим
			
		--	local act=player.components.playercontroller:GetLeftMouseAction() --Получаем текущее действие

			if self:HasTag("player") then
				if STRINGS.NAMES[self.prefab:upper()] then
					--Пытаемся перевести имя на русский, если это кукла, а не игрок
					if not(self.userid and (type(self.userid)=="string") and #self.userid>0)
						and name==t.SpeechHashTbl.NAMES.Rus2Eng[STRINGS.NAMES[self.prefab:upper()] ] then
						name=STRINGS.NAMES[t.SpeechHashTbl.NAMES.Eng2Key[name] ]
						act=act and act.action.id or "DEFAULT"
						name=(t.RussianNames[name] and (t.RussianNames[name][act] or t.RussianNames[name]["DEFAULTACTION"] or t.RussianNames[name]["DEFAULT"])) or rebuildname(name,act,self.prefab) or name
					end
				end
				return name
			end

			local itisblueprint=false
			if name:sub(-10)==" Blueprint" then --Особое исключительное написание для чертежей
				name=name:sub(1,-11)
				name=t.SpeechHashTbl.NAMES.Eng2Key[name] and STRINGS.NAMES[t.SpeechHashTbl.NAMES.Eng2Key[name]] or name
				itisblueprint=true
			end
			--Проверим, есть ли префикс мокрости, засушенности или дымления
			local Prefix=nil
			if STRINGS.WET_PREFIX then
				for i,v in pairs(STRINGS.WET_PREFIX) do
					if type(v)=="string" and v~="" and string.sub(name,1,#v)==v then Prefix=v break end
				end 
				if string.sub(name,1,#STRINGS.WITHEREDITEM)==STRINGS.WITHEREDITEM then Prefix=STRINGS.WITHEREDITEM 
				elseif string.sub(name,1,#STRINGS.SMOLDERINGITEM)==STRINGS.SMOLDERINGITEM then Prefix=STRINGS.SMOLDERINGITEM end
				if Prefix then --Нашли префикс. Меняем его и удаляем из имени для его дальнейшей корректной обработки
					name=string.sub(name,#Prefix+2)--Убираем префикс из имени
					if act then
						Prefix=FixPrefix(Prefix,act.action and act.action.id or "NOACTION",self.prefab)
						--Если есть действие, значит нужно сделать с маленькой буквы
						Prefix=firsttolower(Prefix)
					else 
						Prefix=FixPrefix(Prefix,"NOACTION",self.prefab)
						if self:GetAdjective() then
							Prefix=firsttolower(Prefix)
						end				
					end
				end
			end
			if name and self.prefab then --Для ДСТ нужно перевести имя свина или кролика на русский
				if self.prefab=="pigman" then 
					name=t.SpeechHashTbl.PIGNAMES.Eng2Rus[name] or name
				elseif self.prefab=="pigguard" then 
					name=t.SpeechHashTbl.PIGNAMES.Eng2Rus[name] or name
				elseif self.prefab=="bunnyman" then 
					name=t.SpeechHashTbl.BUNNYMANNAMES.Eng2Rus[name] or name
				end
			end
			if act then --Если есть действие
				act=act.action.id

				if not itisblueprint then
					if t.RussianNames[name] then
						name=t.RussianNames[name][act] or t.RussianNames[name]["DEFAULTACTION"] or t.RussianNames[name]["DEFAULT"] or rebuildname(name,act,self.prefab) or "NAME"
					else
						name=rebuildname(name,act,self.prefab)
					end
					if (not self.prefab or self.prefab~="pigman" and self.prefab~="pigguard" and self.prefab~="bunnyman")
					 and not t.ShouldBeCapped[self.prefab] and name and type(name)=="string" and #name>0 then
						--меняем первый символ названия предмета в нижний регистр
						name=firsttolower(name)
					end
				else name="чертёж предмета \""..name.."\"" end

			else	--Если нет действия
					if itisblueprint then name="Чертёж предмета \""..name.."\"" end
				if not t.ShouldBeCapped[self.prefab] and (self:GetAdjective() or Prefix) then
					name=firsttolower(name)
				end
			end
			if Prefix then
				name=Prefix.." "..name
			end
			if act and act=="SLEEPIN" and name then name="в "..name end --Особый случай для "спать в палатке" и "спать в навесе для сиесты"
			return name
		end
		GLOBAL.EntityScript["GetDisplayName"]=GetDisplayNameNew --подменяем на новую


		AddClassPostConstruct("components/playercontroller", function(self)
			--Переопределяем функцию, выводящую "Создать ...", когда устанавливается на землю крафт-предмет типа палатки.
			--В старой функции у Klei ошибка. Нужно заменить self.player_recipe на self.placer_recipe
			local OldGetHoverTextOverride = self.GetHoverTextOverride
			if OldGetHoverTextOverride then
				function self:GetHoverTextOverride(...)
					if self.placer_recipe then
						local name = STRINGS.NAMES[string.upper(self.placer_recipe.name)]
						local act = "BUILD"
						if name then
							if t.RussianNames[name] then
								name = t.RussianNames[name][act] or t.RussianNames[name]["DEFAULTACTION"] or t.RussianNames[name]["DEFAULT"] or rebuildname(name,act) or STRINGS.UI.HUD.HERE
							else
								name = rebuildname(name,act) or STRINGS.UI.HUD.HERE
							end
						else
							name = STRINGS.UI.HUD.HERE
						end
						if not t.ShouldBeCapped[self.placer_recipe.name] and name and type(name)=="string" and #name>0 then
							--меняем первый символ названия предмета в нижний регистр
							name = firsttolower(name)
						end
						return STRINGS.UI.HUD.BUILD.. " " .. name
		--				local res = OldGetHoverTextOverride(self, ...) 	
		--				return res
					end
				end
			end
		end)


	end --t.CurrentTranslationType~=t.TranslationTypes.InterfaceChat then







	--Дальше идут функции, отлкючённые только в режиме ChatOnly


	--Дядька, продающий скины должен склонять слова под названия вещей
	AddClassPostConstruct("widgets/skincollector", function(self)
		if not self.Say then return end
		if self.text then
			self.text:SetSize(self.text.size-5)
		end
		local OldSay = self.Say
		function self:Say(text, rarity, name, number, ...)
--			text = STRINGS.UI.TRADESCREEN.SKIN_COLLECTOR_SPEECH.RESULT[3]
--			name = GLOBAL.GetRandomItem(STRINGS.SKIN_NAMES)
--			text = STRINGS.UI.TRADESCREEN.SKIN_COLLECTOR_SPEECH.ADDMORE[4]
--			rarity = GLOBAL.GetRandomItem(STRINGS.UI.RARITY)
			if type(text) == "table" then 
				text = GLOBAL.GetRandomItem(text)
			end
			if text then
				local gender = "he"
				if name then --если есть название предмета, ищем его пол
					local key = table.reverselookup(STRINGS.SKIN_NAMES, name)
					if key then
						for gen, tbl in pairs(t.NamesGender) do
							if tbl[key:lower()] then gender = gen break end
						end
						name = russianlower(name)
					end
	--				text = string.gsub(text, "<item>", name)
				end
				if rarity then
					rarity = russianlower(rarity)
					text = string.gsub(text, "<rarity>", rarity) --заменим, чтобы парсились склонения (ниже)
				end
				--парсим теги
				if name or rarity then
					text = t.ParseTranslationTags(text, nil, nil, gender)
				end
			end
			return OldSay(self, text, rarity, name, number, ...)
		end
	end)


	--Увеличиваем область заголовка, чтобы не съедало буквы
	AddClassPostConstruct("widgets/intentionpicker", function(self)
		if self.headertext then
			local w,h = self.headertext:GetRegionSize()
			self.headertext:SetRegionSize(w,h+10)
		end
	end)


	--Исправляем жёстко зашитые надписи на кнопках в казане и телепорте.
	AddClassPostConstruct("widgets/containerwidget", function(self)
		self.oldOpen=self.Open
		local function newOpen(self, container, doer)
			self:oldOpen(container, doer)
			if self.button then
				if self.button:GetText()=="Cook" then self.button:SetText("Готовить") end
				if self.button:GetText()=="Activate" then self.button:SetText("Запустить") end
			end
		end
		self.Open=newOpen
	end)


	AddClassPostConstruct("widgets/recipepopup", function(self) --Уменьшаем шрифт описания рецепта в попапе рецептов
		if self.name and self.Refresh then --Перехватываем вывод названия, проверяем, вмещается ли оно, и если нужно, меняем его размер
			if not self.OldRefresh then
				self.OldRefresh=self.Refresh
				function self.Refresh(self,...)
					self:OldRefresh(...)
					if not self.name then return end
					local Text = require "widgets/text"
					local tmp = self.contents:AddChild(Text(GLOBAL.UIFONT, 42))
					
					tmp:SetPosition(320, 182, 0)
					tmp:SetHAlign(GLOBAL.ANCHOR_MIDDLE)
					tmp:Hide()
					tmp:SetString(self.name:GetString())
					local desiredw = self.name:GetRegionSize()
					local w = tmp:GetRegionSize()
					tmp:Kill()
					if w>desiredw then
						self.name:SetSize(42*desiredw/w)
					else
						self.name:SetSize(42)
					end
				end
			end
		end
		if self.desc then
			self.desc:SetSize(28)
			self.desc:SetRegionSize(64*3+30,130)
		end
	end)


	AddClassPostConstruct("widgets/writeablewidget", function(self)
		if self.menu and self.menu.items then
			local translations={["Cancel"]="Отмена",["Random"]="Случайно",["Write it!"]="Написать!"}
			for i,v in pairs(self.menu.items) do
				if v.text and translations[v.text:GetString()] then
					v.text:SetString(translations[v.text:GetString()])
				end
			end
		end
	end)


	--сочетаем слово "День" с количеством дней
	AddClassPostConstruct("screens/morguescreen", function(self) 
		if self.encounter_widgets then for _,v in ipairs(self.encounter_widgets) do
			if v.PLAYER_AGE and not v.PLAYER_AGE.RLPFixed then
				local x, y = v.PLAYER_AGE:GetRegionSize()
				v.PLAYER_AGE:SetRegionSize(x+20, y)
				local OldSetString = v.PLAYER_AGE.SetString
				if OldSetString then
					function v.PLAYER_AGE:SetString(s, ...)
						s = s:gsub("(%d-) (.*)",function(n,word)
							n = tonumber(n) or nil
							if not n then return end
							return tostring(n).." "..StringTime(n)
						end) or s
						local res = OldSetString(self, s, ...)
						return res
					end
					v.PLAYER_AGE.RLPFixed = true
					v.PLAYER_AGE:SetString(v.PLAYER_AGE:GetString())
				end
			end
			if v.SEEN_DATE and not v.SEEN_DATE.RLPFixed then
				local OldSetString = v.SEEN_DATE.SetString
				if OldSetString then
					local months = {Jan="Янв.",Feb="Февр.",Mar="Март",Apr="Апр.",May="Мая",Jun="Июня",Jul="Июля",Aug="Авг.",Sept="Сент.",Oct="Окт.",Nov="Нояб.",Dec="Дек."}
					function v.SEEN_DATE:SetString(s, ...)
						s = s:gsub("(.-) (%d-), (%d-)",function(m, d, y)
							if not months[m] then return end
							return d.." "..months[m].." "..y
						end) or s
						local res = OldSetString(self, s, ...)
						return res
					end
					v.SEEN_DATE.RLPFixed = true
					v.SEEN_DATE:SetString(v.SEEN_DATE:GetString())
				end
			end
		end end
	end)

	--Исправляем последовательность слов в заголовке окна настройки модов
	AddClassPostConstruct("screens/modconfigurationscreen", function(self)
		for title,val in pairs(self.root.children) do
			if title.name and string.lower(title.name)=="text" then 
				local tmp=title:GetString()
				tmp=string.sub(tmp,1,#tmp-#STRINGS.UI.MODSSCREEN.CONFIGSCREENTITLESUFFIX-1)
				title:SetString(STRINGS.UI.MODSSCREEN.CONFIGSCREENTITLESUFFIX.." \""..tmp.."\"")
			end
		end
	end)



	AddClassPostConstruct("screens/networkloginpopup", function(self)
		if self.menu and self.menu.items then
			for i,v in pairs(self.menu.items) do
				if v.text and v.text:GetString()==STRINGS.UI.MAINSCREEN.PLAYOFFLINE then 
					local sx, sy, sz = v.image.inst.UITransform:GetScale()
					v.image:SetScale(sx*1.15,sy)
					v:Nudge({x=10,y=0,z=0})
				end
			end
		end
	end)

	--Подвигаем всё красивенько в окне подписки
	AddClassPostConstruct("screens/emailsignupscreen", function(self)
		self.bg:Nudge({x=-5,y=0,z=0})
		self.bg.fill:Nudge({x=-5,y=0,z=0})
		if self.bday_message then
			self.bday_message:SetSize(21)
		end
		if self.bday_label then
			self.bday_label:SetSize(26)
			self.bday_label:Nudge({x=7,y=0,z=0})
		end
		if self.spinners then
			self.spinners:Nudge({x=10,y=0,z=0})
		end
	end)


	--Комплекс из двух подмен для того, чобы названия серверов слева в окне создания сервера были поменьше
	--Грязный хак, подменяем то, что, как нам кажется, будет только в ServerCreationScreen:MakeSaveSlotButton
	--Это нужно, чтобы строка оканчивалась тремя точками попозже, ведь шрифт будет поменьше
	if GLOBAL.FrontEnd and GLOBAL.FrontEnd.GetTruncatedString then
		local OldGetTruncatedString = GLOBAL.FrontEnd.GetTruncatedString
		function GLOBAL.FrontEnd:GetTruncatedString(str, font, size, maxwidth, maxchars, suffix, ...)
			if font==GLOBAL.NEWFONT and size==35 and maxwidth==140 and not maxchars and suffix then
				size = 28 --Надеюсь, это произойдёт только в ServerCreationScreen:MakeSaveSlotButton
			end
			local res = OldGetTruncatedString(self, str, font, size, maxwidth, maxchars, suffix, ...)
			return res
		end
	end
	--Уменьшаем шрифт в окне создания сервера
	AddClassPostConstruct("screens/servercreationscreen", function(self)
		if self.save_slots then --Уменьшаем шрифт в слотах слева
			for _, slot in ipairs(self.save_slots) do
				if slot.SetTextSize then slot:SetTextSize(28) end
			end
		end
		if self.create_button then --Уменьшаем текст на кнопке "создать"
			self.create_button.text:SetSize(self.create_button.text.size-7)
		end
	end)


end --t.CurrentTranslationType~=t.TranslationTypes.ChatOnly
