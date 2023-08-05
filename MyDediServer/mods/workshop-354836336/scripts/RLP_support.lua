local t = mods.RussianLanguagePack

--������������ � ��������� ������� ���� ���������� russian ��� �������� ����������� (��� ������� ������ ����).
local ModIndex = KnownModIndex
if ModIndex and ModIndex.InitializeModInfoEnv then
    --���� PeterA ������� ������, �� ��������� �������������.
    local old_InitializeModInfoEnv = ModIndex.InitializeModInfoEnv
    ModIndex.InitializeModInfoEnv = function(self,...)
        local env = old_InitializeModInfoEnv(self,...)
		env.language = t.SelectedLanguage
		env.russian = true -- !!! ���������� ������. ����� ��������� ����� ����� ������� !!!
        return env
    end
else --����� �����������, ��� ������.
    local temp_mark = false --��������� �����, ����������, ��� � ��������� ����� RunInEnvironment ���� �������� russian=true
   
    --������������� "kleiloadlua", ����� ���������� ��������� ����� � ������ �������� "modinfo.lua"
    local old_kleiloadlua = kleiloadlua
    kleiloadlua = function(path,...)
        local fn = old_kleiloadlua(path,...)
        if fn and type(fn) ~= "string" and path:sub(-12) == "/modinfo.lua" then
			temp_mark = true
        end
        return fn
    end
   
    --������������� RunInEnvironment, ����� ������������ �� ����� (������ �������� ��)
    local old_RunInEnvironment = RunInEnvironment
    RunInEnvironment = function(fn, env, ...)
		if env and temp_mark then
			env.language = t.SelectedLanguage
			env.russian = true -- !!! ���������� ������. ����� ��������� ����� ����� ������� !!!
			temp_mark = false
		end
		return old_RunInEnvironment(fn, env, ...)
    end
end



--������� ���� �� ����������������, ���� ����������� �� � ������ ������� �������, �.�. ���� �� ����� ���������� �������� � ��������
if t.CurrentTranslationType==t.TranslationTypes.Full then


	local genders_reg={"he","he2","she","it","plural","plural2", --numbers
		he="he",he2="he2",she="she",it="it",plural="plural",plural2="plural2"};
	--[[������� ������������ ����� ��� �������� �� ����� �������, ������������ ��� ��� ����������� ���������.

		key - ���� �������. ��������, MYITEM (�� STRINGS.NAMES.MYITEM).
		val - ������� ������� �������� �������.
		gender - ��� �������. ��������: he, he2, she, it, plural, plural2. ��� ����� ��� ��������� ��������� ���� � ���������.
			 "he" � "he2" - ��� ������� ���, �� �� ���� � �� ��, ��������: ������� ������� ������ ��������� (he),
			 �� ������� �������� ����� (he2). plural2 � ����������� �� ������������� ����� (���� �����, ��������, "�����",
			 �� ���� ����� ������ ���������� �������� �������� �� ������������� �����).
		walkto - ��������� ��� ����������� �� ����� "���� �" (����? ����?). ��������� ����� � ������� �����.
		defaultaction - ������������� �� ���� ��������� � ����, ��� ������� �� ������ ������ ���������. �������� "���������" (����? ���?).
		capitalized - ����� �� ������ ��� � ������� �����. ��������� ����� � �������� �� ������ �������.
				  �� ���� �� ������� true, �� ������� ������ ��������� � ������, ��� ���� ����� �����. ��������: "��������� ��������".
		killaction - ������������ ������ � DST �� ���� ���������, ������� �������� ����� ���������. � ���� ��� ����� ���������� � ����������
			 ���� "��� ���� (���? ���?)", �� ���� ��� ������������ �����.
		������ ��������� �������� ���� ����� ������������ �� ������: 1) he, 2) he2, 3) she, 4) it, 5) plural, 6) plural2.
		������ walkto, defaultaction � killaction ����� ������������ 0 ��� 1.
		0 �������� ������� ���������. �� ��, ��� �� ������� �������� �����. �������� �� ����������������. ������������ �������� �� testname.
		1 �������� "�� ��, ��� � ������� �����", �.�. val. ����� �� ����������� ���� � �� �� ������ (val) ����� ������ ������� ��������.
		
		��������: 
		RegisterRussianName("RESEARCHLAB2","������������ ���������",1,"������������� ���������",1)
		������ ���� ������� 1, ��� �������� "he".
		������ defaultaction ������� 1, ��� �������� ���������� val, �.�. "������������ ���������".
	]]


	function t.RegisterRussianName(key,val,gender,walkto,defaultaction,capitalized,killaction)
		local oldval = STRINGS.NAMES[string.upper(key)]
		STRINGS.NAMES[string.upper(key)]=val
		LanguageTranslator.languages[t.SelectedLanguage]["STRINGS.NAMES."..string.upper(key)] = val
		if gender and gender~=0 then 
			if (genders_reg[gender]) then
				t.NamesGender[genders_reg[gender]][string.lower(key)]=true
			--else
			--	print error............
			end
		end
		if walkto or defaultaction or killaction then
			if (walkto==1) then walkto=val end
			if (defaultaction==1) then defaultaction=val end
			if (killaction==1) then killaction=val end
			t.RussianNames[val]={}
			if walkto and walkto~=0 then t.RussianNames[val]["WALKTO"]=walkto end
			if defaultaction and defaultaction~=0 then t.RussianNames[val]["DEFAULTACTION"]=defaultaction end
			if killaction and killaction~=0 then t.RussianNames[val]["KILL"]=killaction end
		end
		if capitalized then t.ShouldBeCapped[string.lower(key)]=true end
		if t.SpeechHashTbl.NAMES and oldval then
			t.SpeechHashTbl.NAMES.Eng2Key[oldval]=string.upper(key)
			t.SpeechHashTbl.NAMES.Rus2Eng[val]=oldval
		end
	end

	-- !!! ���������� ������. ����� ��������� ����� ����� ������� !!!
	RegisterRussianName = t.RegisterRussianName --�������� ��������� ��� �������� ������������� �� ������� Star

	---���������������� �������� �� �������� (id)
	function t.RenameAction(act, new_name)
		if rawget(GLOBAL,"ACTIONS") and ACTIONS[act] then
			ACTIONS[act].str = new_name
			if STRINGS.ACTIONS then
				STRINGS.ACTIONS[act] = new_name
			end
		end
	end

end