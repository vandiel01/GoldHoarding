local vGH_GetVers = GetAddOnMetadata("GoldHoarding", "Version") --Grab Version
local vGH_Vers = "|cffffffff "..vGH_GetVers.."|r"	-- Version Number
local vGH_Title = "|c"..RAID_CLASS_COLORS[select(2,UnitClass("player"))].colorStr.."Gold Hoarding|r"  -- EGTB Title
local ShowEGTB = true
Send = "No Name"
Amount = 100
Option = true
Verbose = true
GoldHoarding = {Send,Amount,Option,Verbose}

function vGH_SetFrame_OnClick()
	if (vGH_SetFrame:IsVisible()) then
		vGH_SetFrame:Hide()
	else
		vGH_SetFrame:Show()
	end
end

local SettingChanges = function(arg)
	if (not type(arg) == "number" or arg == nil) then return else arg = tonumber(arg) end
	--Change Get/Send Settings
	if (arg == 3) or (arg == 4) or (arg == 5) or (arg == 6) then
		CalculateAmountCheck()
	end
	if (arg == 3) or (arg == 4) or (arg == 9) or (arg == 10) then
		vGH_AmtToSndTBox:SetText(vGH_SetSndTBox:GetText())
		vGH_AmtToGoldTBox:SetText(vGH_SetGoldTBox:GetText())
		GoldHoarding = {vGH_SetSndTBox:GetText(),vGH_SetGoldTBox:GetNumber(),vGH_SetOpenCB:GetChecked(),vGH_SetVerbCB:GetChecked()}
	end
	--If SendTo is Different from Default, then Reset Icon appears
	if (arg == 5) or (arg == 6) then
		if (vGH_SetSndTBox:GetText() ~= vGH_AmtToSndTBox:GetText()) or (vGH_SetGoldTBox:GetNumber() ~= vGH_AmtToGoldTBox:GetNumber()) then
			vGH_AmtToResetBtn:Show()
		else
			vGH_AmtToResetBtn:Hide()
		end
	end
	if (arg == 7) then --Reset To Default
		vGH_SetSndTBox:SetText(Send)
		vGH_SetGoldTBox:SetNumber(Amount)
		vGH_AmtToSndTBox:SetText(Send)
		vGH_AmtToGoldTBox:SetNumber(Amount)
		vGH_SetOpenCB:SetChecked(true)
		vGH_SetVerbCB:SetChecked(true)
	end
	--EGTB Icon Toggle on MailFrame
	if (arg == 8) then
		if (ShowEGTB) then
			ShowEGTB = false
			vGH_MainFrame:Show()
		elseif (not ShowEGTB) then
			ShowEGTB = true
			vGH_MainFrame:Hide()
			vGH_SetFrame:Hide()
		end
	end
end

local vGH_Tooltips = function(arg, frame)
	if (not type(arg) == "number" or arg == nil) then return else arg = tonumber(arg) end
	GameTooltip:Hide()
	GameTooltip:ClearLines()
	if arg == 0 then return end
	GameTooltip:SetOwner(frame, "ANCHOR_RIGHT")
	if arg == 1 then msg = "This includes 30c when sending gold to your banker." end
	if arg == 2 then msg = "To make your setting permanent, click here to make changes." end
	if arg == 3 then msg = "Put in a permanent name.\n\n(Can include server name if connected)" end
	if arg == 4 then msg = "Put in a permanent gold amount." end
	if arg == 5 then msg = "To send another person, change here temporarily.\n\n\(Can include server name if connected\)\n\nThis variable is not saved!" end
	if arg == 6 then msg = "To send another gold amount, change here temporarily.\n\nThis variable is not saved!" end
	if arg == 7 then msg = "Reset Name/Gold back to default." end
	if arg == 8 then msg = "Toggle "..vGH_Title end
	if arg == 9 then msg = "Toggle on to open "..vGH_Title.." at the mailbox" end
	if arg == 10 then msg = "Toggle to display verbose to chat box when sending." end
	GameTooltip:AddLine(msg,1,1,1,1)
	GameTooltip:Show()
end

function CalculateAmountCheck() --Auto Calculate on Info Frame
	vGH_SndBtn:Hide()
	vGH_InfoFrame.Msg:SetText("")
	amountToKeep = vGH_AmtToGoldTBox:GetNumber()*10000
	amountToSend = GetMoney()-amountToKeep-GetSendMailPrice()

	if strfind(vGH_AmtToSndTBox:GetText(),"-") == nil then
		if (UnitName("player") == vGH_AmtToSndTBox:GetText()) then
			vGH_InfoFrame.Msg:SetText("Greed Much? Can`t send to yourself!")
			return
		end
	else
		TwoName = UnitName("player").."-"..GetRealmName()
		if (TwoName == vGH_AmtToSndTBox:GetText()) then
			vGH_InfoFrame.Msg:SetText("Greed Much? Can`t send to yourself!")
			return
		end
	end
	if (vGH_AmtToSndTBox:GetText() == nil) or (vGH_AmtToSndTBox:GetText() == "") or (vGH_AmtToSndTBox:GetText() == "No Name") then
		vGH_InfoFrame.Msg:SetText("Name cannot be blank or `No Name`")
		return
	end
	if (amountToKeep == GetMoney()) then
		vGH_InfoFrame.Msg:SetText("Quit trolling your banker!")
		return
	end
	if (amountToSend < 0) then
		vGH_InfoFrame.Msg:SetText("Keep dreaming to send that much!")
		return
	end
	if (vGH_AmtToGoldTBox:GetNumber() == 0) then
		vGH_InfoFrame.Msg:SetText("|cff00ccffSend "..vGH_AmtToSndTBox:GetText().." ALL: |r"..GetCoinTextureString(amountToSend,10))
		vGH_SndBtn:Show()
		return
	end
	if (amountToSend > 0) then
		vGH_InfoFrame.Msg:SetText("|cff00ccffSend "..vGH_AmtToSndTBox:GetText()..": |r"..GetCoinTextureString(amountToSend,10))
		vGH_SndBtn:Show()
		return
	end
end

function vGH_SndBtn_OnClick()
	amountToKeep = vGH_AmtToGoldTBox:GetNumber()*10000
	amountToSend = GetMoney()-amountToKeep-GetSendMailPrice()
	SendTo = vGH_AmtToSndTBox:GetText()
	MailFrameTab2:Click() --???
	SetSendMailMoney(amountToSend)
	SendMail(SendTo,"Auto - Gold Hoarding","")
	if vGH_SetVerbCB:GetChecked() == true then
		DEFAULT_CHAT_FRAME:AddMessage("|cff00ccffSent - "..vGH_AmtToSndTBox:GetText().." |r"..GetCoinTextureString(amountToSend))
	end
end

-------------------------------------------------------
-- EGTB Main Frame and Movers
-------------------------------------------------------
local DefaultBackdrop = {
	edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
	tile = false,
	tileEdge = true,
	tileSize = 16,
	edgeSize = 16,
	insets = { left = 4, right = 4, top = 4, bottom = 4 }
}
--EGTB Toggle Icon
local vGH_ToggleIcon = CreateFrame("Button", "vGH_ToggleIcon", MailFrame)
	vGH_ToggleIcon:SetSize(16,16)
	vGH_ToggleIcon:SetNormalTexture("Interface\\MoneyFrame\\UI-GoldIcon")
	vGH_ToggleIcon:SetPoint("TOPRIGHT", MailFrame, -50, -3)
	vGH_ToggleIcon:SetScript("OnClick", function() SettingChanges(8) end)
	vGH_ToggleIcon:SetScript("OnEnter", function() vGH_Tooltips(8,vGH_ToggleIcon) end)
	vGH_ToggleIcon:SetScript("OnLeave", function() vGH_Tooltips(0) end)

--Main Frame
local vGH_MainFrame = CreateFrame("Frame", "vGH_MainFrame", MailFrame, BackdropTemplateMixin and "BackdropTemplate")
	vGH_MainFrame:SetBackdrop(DefaultBackdrop)
	vGH_MainFrame:SetSize(300,0)
	vGH_MainFrame:ClearAllPoints()
	vGH_MainFrame:SetPoint("TOPRIGHT", MailFrame, vGH_MainFrame:GetWidth() or 0, 0)
	vGH_MainFrame:SetClampedToScreen(true)

--Title Frame
local vGH_TitleMFrame = CreateFrame("Frame", "vGH_TitleMFrame", vGH_MainFrame, BackdropTemplateMixin and "BackdropTemplate")
	vGH_TitleMFrame:SetBackdrop(DefaultBackdrop)
	vGH_TitleMFrame:SetSize(295,30)
	vGH_TitleMFrame:ClearAllPoints()
	vGH_TitleMFrame:SetPoint("TOP", vGH_MainFrame, 0, -2)
		vGH_TitleMFrame.MTitle = vGH_TitleMFrame:CreateFontString("MTitle")
		vGH_TitleMFrame.MTitle:SetFont("Fonts\\FRIZQT__.TTF", 14)
		vGH_TitleMFrame.MTitle:SetPoint("TOP", vGH_TitleMFrame, 0, -8)
		vGH_TitleMFrame.MTitle:SetText(vGH_Title)

--Amount Frame
local vGH_AmtToFrame = CreateFrame("Frame", "vGH_AmtToFrame", vGH_MainFrame, BackdropTemplateMixin and "BackdropTemplate")
	vGH_AmtToFrame:SetBackdrop(DefaultBackdrop)
	vGH_AmtToFrame:SetSize(295,120)
	vGH_AmtToFrame:ClearAllPoints()
	vGH_AmtToFrame:SetPoint("TOP", vGH_TitleMFrame, 0, 0-vGH_TitleMFrame:GetHeight()+4)
	local vGH_AmtToGoldHdr = vGH_AmtToFrame:CreateFontString("vGH_AmtToGoldHdr")
		vGH_AmtToGoldHdr:SetFont("Fonts\\FRIZQT__.TTF", 12)
		vGH_AmtToGoldHdr:SetPoint("TOP", vGH_AmtToFrame, 0, -10)
		vGH_AmtToGoldHdr:SetText("Amount of gold to keep on: |c"..RAID_CLASS_COLORS[select(2,UnitClass("player"))].colorStr..UnitName("player").."|r")
	local vGH_AmtToGoldTBox = CreateFrame("EditBox", "vGH_AmtToGoldTBox", vGH_AmtToFrame, "InputBoxTemplate")
		vGH_AmtToGoldTBox:SetNumber(0)
		vGH_AmtToGoldTBox:SetPoint("TOP", vGH_AmtToFrame, 0, -30)
		vGH_AmtToGoldTBox:SetSize(80,20)
		vGH_AmtToGoldTBox:SetMaxLetters(100)
		vGH_AmtToGoldTBox:SetAutoFocus(false)
		vGH_AmtToGoldTBox:SetMultiLine(false)
		vGH_AmtToGoldTBox:SetNumeric(true)
		vGH_AmtToGoldTBox:SetScript("OnEnter", function() vGH_Tooltips(6,vGH_AmtToGoldTBox) end)
		vGH_AmtToGoldTBox:SetScript("OnLeave", function() vGH_Tooltips(0) end)
		vGH_AmtToGoldTBox:SetScript("OnTextChanged", function() SettingChanges(6) end)
	local vGH_AmtToGoldIcon = vGH_AmtToFrame:CreateTexture(nil, "ARTWORK")
		vGH_AmtToGoldIcon:SetSize(16,16)
		vGH_AmtToGoldIcon:SetPoint("TOP", vGH_AmtToFrame, 50, -31)
		vGH_AmtToGoldIcon:SetTexture("Interface\\MoneyFrame\\UI-GoldIcon")
		
	local vGH_AmtToOnHand = vGH_AmtToFrame:CreateFontString("vGH_AmtToOnHand")
		vGH_AmtToOnHand:SetFont("Fonts\\FRIZQT__.TTF", 12)
		vGH_AmtToOnHand:SetPoint("TOP", vGH_AmtToFrame, 0, -60)
		vGH_AmtToOnHand:SetText("You have: "..GetCoinTextureString(GetMoney()))	
		
	local vGH_AmtToSndHdr = vGH_AmtToFrame:CreateFontString("vGH_AmtToSndHdr")
		vGH_AmtToSndHdr:SetFont("Fonts\\FRIZQT__.TTF", 12)
		vGH_AmtToSndHdr:SetPoint("TOP", vGH_AmtToFrame, -45, -87)
		vGH_AmtToSndHdr:SetText("Send To:")
	local vGH_AmtToSndTBox = CreateFrame("EditBox", "vGH_AmtToSndTBox", vGH_AmtToFrame, "InputBoxTemplate")
		vGH_AmtToSndTBox:SetText("")
		vGH_AmtToSndTBox:SetPoint("TOP", vGH_AmtToFrame, 60, -83)
		vGH_AmtToSndTBox:SetSize(140,20)
		vGH_AmtToSndTBox:SetMaxLetters(100)
		vGH_AmtToSndTBox:SetAutoFocus(false)
		vGH_AmtToSndTBox:SetMultiLine(false)
		vGH_AmtToSndTBox:SetNumeric(false)
		vGH_AmtToSndTBox:SetScript("OnEnter", function() vGH_Tooltips(5,vGH_AmtToSndTBox) end)
		vGH_AmtToSndTBox:SetScript("OnLeave", function() vGH_Tooltips(0) end)
		vGH_AmtToSndTBox:SetScript("OnTextChanged", function() SettingChanges(5) end)
		
	local vGH_AmtToResetBtn = CreateFrame("Button", "vGH_AmtToResetBtn", vGH_AmtToFrame)
		vGH_AmtToResetBtn:SetSize(16,16)
		vGH_AmtToResetBtn:SetNormalTexture("Interface\\Buttons\\UI-RefreshButton")
		vGH_AmtToResetBtn:SetPoint("BOTTOMRIGHT", vGH_AmtToFrame, -5, 5)
		vGH_AmtToResetBtn:SetScript("OnClick", function() SettingChanges(7) end)
		vGH_AmtToResetBtn:SetScript("OnEnter", function() vGH_Tooltips(7,vGH_AmtToResetBtn) end)
		vGH_AmtToResetBtn:SetScript("OnLeave", function() vGH_Tooltips(0) end)
		
--Info Frame
local vGH_InfoFrame = CreateFrame("Frame", "vGH_InfoFrame", vGH_MainFrame, BackdropTemplateMixin and "BackdropTemplate")
	vGH_InfoFrame:SetBackdrop(DefaultBackdrop)
	vGH_InfoFrame:SetSize(295,30)
	vGH_InfoFrame:ClearAllPoints()
	vGH_InfoFrame:SetPoint("TOP", vGH_AmtToFrame, 0, 0-vGH_AmtToFrame:GetHeight()+4)
	vGH_InfoFrame:SetScript("OnEnter", function() vGH_Tooltips(1,vGH_InfoFrame) end)
	vGH_InfoFrame:SetScript("OnLeave", function() vGH_Tooltips(0) end)
		vGH_InfoFrame.Msg = vGH_InfoFrame:CreateFontString("Msg")
		vGH_InfoFrame.Msg:SetFont("Fonts\\FRIZQT__.TTF", 11)
		vGH_InfoFrame.Msg:SetPoint("CENTER", vGH_InfoFrame, 0, 0)
		vGH_InfoFrame.Msg:SetText("")

--Send Frame
local vGH_SendFrame = CreateFrame("Frame", "vGH_SendFrame", vGH_MainFrame, BackdropTemplateMixin and "BackdropTemplate")
	vGH_SendFrame:SetBackdrop(DefaultBackdrop)
	vGH_SendFrame:SetSize(295,40)
	vGH_SendFrame:ClearAllPoints()
	vGH_SendFrame:SetPoint("TOP", vGH_InfoFrame, 0, 0-vGH_InfoFrame:GetHeight()+3)
	local vGH_SndBtn = CreateFrame("Button", "vGH_SndBtn", vGH_SendFrame, "UIPanelButtonTemplate")
		vGH_SndBtn:SetSize(80,25)
		vGH_SndBtn:SetPoint("CENTER", vGH_SendFrame, 0, 0)
		vGH_SndBtn:SetText("Send")
		vGH_SndBtn:SetScript("OnClick", vGH_SndBtn_OnClick)
	
	local vGH_OpenSetBtn = CreateFrame("Button", "vGH_OpenSetBtn", vGH_SendFrame)
		vGH_OpenSetBtn:SetSize(16,16)
		vGH_OpenSetBtn:SetNormalTexture("Interface\\Buttons\\UI-OptionsButton")
		vGH_OpenSetBtn:SetPoint("CENTER", vGH_SendFrame, "RIGHT", -15, 0)
		vGH_OpenSetBtn:SetScript("OnClick", vGH_SetFrame_OnClick)
		vGH_OpenSetBtn:SetScript("OnEnter", function() vGH_Tooltips(2,vGH_OpenSetBtn) end)
		vGH_OpenSetBtn:SetScript("OnLeave", function() vGH_Tooltips(0) end)		
	
	--Resize/Fix Main Frame and Background
	vGH_MainFrame:SetSize(300,(vGH_TitleMFrame:GetHeight()+vGH_AmtToFrame:GetHeight()+vGH_InfoFrame:GetHeight()+vGH_SendFrame:GetHeight()-7))
		vGH_MainFrame.Body = vGH_MainFrame:CreateTexture(nil, "BACKGROUND")
		vGH_MainFrame.Body:SetSize(vGH_MainFrame:GetWidth()-10,vGH_MainFrame:GetHeight()-10)
		vGH_MainFrame.Body:SetPoint("TOPLEFT", vGH_MainFrame, 5, -5)
		vGH_MainFrame.Body:SetTexture("Interface\\TabardFrame\\TabardFrameBackground")

--Setting Frame
local vGH_SetFrame = CreateFrame("Frame", "vGH_SetFrame", vGH_MainFrame, BackdropTemplateMixin and "BackdropTemplate")
	vGH_SetFrame:SetBackdrop(DefaultBackdrop)
	vGH_SetFrame:SetSize(300,125)
	vGH_SetFrame:ClearAllPoints()
	vGH_SetFrame:SetPoint("TOP", vGH_MainFrame, 0, 0-vGH_MainFrame:GetHeight()+2)
	vGH_SetFrame:SetClampedToScreen(true)
		vGH_SetFrame.Body = vGH_SetFrame:CreateTexture(nil, "BACKGROUND")
		vGH_SetFrame.Body:SetSize(vGH_SetFrame:GetWidth()-10,vGH_SetFrame:GetHeight()-10)
		vGH_SetFrame.Body:SetPoint("TOPLEFT", vGH_SetFrame, 5, -5)
		vGH_SetFrame.Body:SetTexture("Interface\\TabardFrame\\TabardFrameBackground")
	
--Setting Title Frame
local vGH_TitleSetFrame = CreateFrame("Frame", "vGH_TitleSetFrame", vGH_SetFrame, BackdropTemplateMixin and "BackdropTemplate")
	vGH_TitleSetFrame:SetBackdrop(DefaultBackdrop)
	vGH_TitleSetFrame:SetSize(295,30)
	vGH_TitleSetFrame:ClearAllPoints()
	vGH_TitleSetFrame:SetPoint("TOP", vGH_SetFrame, "TOP", 0, -2)
		vGH_TitleSetFrame.STitle = vGH_TitleSetFrame:CreateFontString("STitle")
		vGH_TitleSetFrame.STitle:SetFont("Fonts\\FRIZQT__.TTF", 14)
		vGH_TitleSetFrame.STitle:SetPoint("TOP", vGH_TitleSetFrame, 0, -8)
		vGH_TitleSetFrame.STitle:SetText("|cffE1E115Setting|r")

--Setting Player Name/Gold To Send		
local vGH_SetSnGoFrame = CreateFrame("Frame", "vGH_SetSnGoFrame", vGH_SetFrame, BackdropTemplateMixin and "BackdropTemplate")
	vGH_SetSnGoFrame:SetBackdrop(DefaultBackdrop)
	vGH_SetSnGoFrame:SetSize(295,94)
	vGH_SetSnGoFrame:ClearAllPoints()
	vGH_SetSnGoFrame:SetPoint("TOP", vGH_SetFrame, 0, -29)
	
	local vGH_SetSndStr = vGH_SetSnGoFrame:CreateFontString("vGH_SetSndStr")
		vGH_SetSndStr:SetFont("Fonts\\FRIZQT__.TTF", 12)
		vGH_SetSndStr:SetPoint("TOP", vGH_SetSnGoFrame, -70, -8)
		vGH_SetSndStr:SetText("Default Send To:")
		local vGH_SetSndTBox = CreateFrame("EditBox", "vGH_SetSndTBox", vGH_SetSnGoFrame, "InputBoxTemplate")
			vGH_SetSndTBox:SetText("")
			vGH_SetSndTBox:SetPoint("TOP", vGH_SetSnGoFrame, 60, -5)
			vGH_SetSndTBox:SetSize(140,20)
			vGH_SetSndTBox:SetMaxLetters(100)
			vGH_SetSndTBox:SetAutoFocus(false)
			vGH_SetSndTBox:SetMultiLine(false)
			vGH_SetSndTBox:SetNumeric(false)
			vGH_SetSndTBox:SetScript("OnEnter", function() vGH_Tooltips(3,vGH_SetSndTBox) end)
			vGH_SetSndTBox:SetScript("OnLeave", function() vGH_Tooltips(0) end)
			vGH_SetSndTBox:SetScript("OnTextChanged", function() SettingChanges(3) end)
			
	local vGH_SetGoldStr = vGH_SetSnGoFrame:CreateFontString("vGH_SetGoldStr")
		vGH_SetGoldStr:SetFont("Fonts\\FRIZQT__.TTF", 12)
		vGH_SetGoldStr:SetPoint("TOP", vGH_SetSnGoFrame, -50, -30)
		vGH_SetGoldStr:SetText("    Default Gold To Keep:")
		local vGH_SetGoldTBox = CreateFrame("EditBox", "vGH_SetGoldTBox", vGH_SetSnGoFrame, "InputBoxTemplate")
			vGH_SetGoldTBox:SetNumber(0)
			vGH_SetGoldTBox:SetPoint("TOP", vGH_SetSnGoFrame, 70, -27)
			vGH_SetGoldTBox:SetSize(80,20)
			vGH_SetGoldTBox:SetMaxLetters(100)
			vGH_SetGoldTBox:SetAutoFocus(false)
			vGH_SetGoldTBox:SetMultiLine(false)
			vGH_SetGoldTBox:SetNumeric(true)
			vGH_SetGoldTBox:SetScript("OnEnter", function() vGH_Tooltips(4,vGH_SetGoldTBox) end)
			vGH_SetGoldTBox:SetScript("OnLeave", function() vGH_Tooltips(0) end)
			vGH_SetGoldTBox:SetScript("OnTextChanged", function() SettingChanges(4) end)
			local vGH_SetGoldIcon = vGH_SetSnGoFrame:CreateTexture(nil, "ARTWORK")
				vGH_SetGoldIcon:SetSize(16,16)
				vGH_SetGoldIcon:SetPoint("RIGHT", vGH_SetSnGoFrame, -20, 10)
				vGH_SetGoldIcon:SetTexture("Interface\\MoneyFrame\\UI-GoldIcon")
				
	local vGH_SetOpenMailS = vGH_SetSnGoFrame:CreateFontString("vGH_SetOpenMailS")
		vGH_SetOpenMailS:SetFont("Fonts\\FRIZQT__.TTF", 12)
		vGH_SetOpenMailS:SetPoint("TOP", vGH_SetSnGoFrame, -50, -52)
		vGH_SetOpenMailS:SetText(" Open this at MailBox?")
		local vGH_SetOpenCB = CreateFrame("CheckButton", "vGH_SetOpenCB", vGH_SetSnGoFrame, "ChatConfigCheckButtonTemplate")
			vGH_SetOpenCB:SetChecked(true)
			vGH_SetOpenCB:SetPoint("TOP", vGH_SetSnGoFrame, 33, -47)
			vGH_SetOpenCB:SetScript("OnClick", function() SettingChanges(9) end)
			vGH_SetOpenCB:SetScript("OnEnter", function() vGH_Tooltips(9,vGH_SetOpenCB) end)
			vGH_SetOpenCB:SetScript("OnLeave", function() vGH_Tooltips(0) end)
			
	local vGH_SetVerbose = vGH_SetSnGoFrame:CreateFontString("vGH_SetVerbose")
		vGH_SetVerbose:SetFont("Fonts\\FRIZQT__.TTF", 12)
		vGH_SetVerbose:SetPoint("TOP", vGH_SetSnGoFrame, -50, -70)
		vGH_SetVerbose:SetText("Verbose Enable To Chat")
		local vGH_SetVerbCB = CreateFrame("CheckButton", "vGH_SetVerbCB", vGH_SetSnGoFrame, "ChatConfigCheckButtonTemplate")
			vGH_SetVerbCB:SetChecked(true)
			vGH_SetVerbCB:SetPoint("TOP", vGH_SetSnGoFrame, 33, -65)
			vGH_SetVerbCB:SetScript("OnClick", function() SettingChanges(10) end)
			vGH_SetVerbCB:SetScript("OnEnter", function() vGH_Tooltips(10,vGH_SetVerbCB) end)
			vGH_SetVerbCB:SetScript("OnLeave", function() vGH_Tooltips(0) end)

-------------------------------------------------------
-- OnEvent
-------------------------------------------------------
local vGH_OnUpdate = CreateFrame("Frame")
	vGH_OnUpdate:RegisterEvent("ADDON_LOADED")
	vGH_OnUpdate:RegisterEvent("PLAYER_LOGIN")
	vGH_OnUpdate:RegisterEvent("MAIL_SHOW")
	vGH_OnUpdate:RegisterEvent("MAIL_CLOSED")
	vGH_OnUpdate:RegisterEvent("MAIL_INBOX_UPDATE")
	vGH_OnUpdate:RegisterEvent("PLAYER_MONEY")

vGH_OnUpdate:SetScript("OnEvent", function(self, event, ...)
	if event == "ADDON_LOADED" then
		--Do Nothing
	end
	if event == "PLAYER_LOGIN" then
		vGH_MainFrame:Hide()
		vGH_SetFrame:Hide()
		DEFAULT_CHAT_FRAME:AddMessage("Loaded: "..vGH_Title..vGH_Vers)
	end
	if event == "PLAYER_MONEY" then
		if (MailFrame:IsShown()) then
			vGH_AmtToOnHand:SetText("You have: "..GetCoinTextureString(GetMoney()))
			CalculateAmountCheck()
		end
	end
	if event == "MAIL_INBOX_UPDATE" then
		if (MailFrame:IsShown()) then
			SettingChanges(6)
		end
	end
	if event == "MAIL_SHOW" then
		if GoldHoarding == nil then
			GoldHoarding = {Send,Amount,Option,Verbose}
		else
			if GoldHoarding[1] == nil or GoldHoarding[1] == "" then --Name
				vGH_SetSndTBox:SetText(Send)
				vGH_AmtToSndTBox:SetText(Send)
			else
				vGH_SetSndTBox:SetText(GoldHoarding[1])
				vGH_AmtToSndTBox:SetText(GoldHoarding[1])
			end
			if GoldHoarding[2] == nil or not tonumber(GoldHoarding[2]) then --Amount
				vGH_SetGoldTBox:SetNumber(Amount)
				vGH_AmtToGoldTBox:SetNumber(Amount)
			else
				vGH_SetGoldTBox:SetNumber(GoldHoarding[2])
				vGH_AmtToGoldTBox:SetNumber(GoldHoarding[2])
			end
			if GoldHoarding[3] == nil or GoldHoarding[3] == true then --Open Default?
				vGH_SetOpenCB:SetChecked(true)
			else
				vGH_SetOpenCB:SetChecked(false)
			end
			if GoldHoarding[4] == nil or GoldHoarding[4] == true then --Do Verbose?
				vGH_SetVerbCB:SetChecked(true)
			else
				vGH_SetVerbCB:SetChecked(false)
			end
		end
		if GoldHoarding[3] == true then
			vGH_MainFrame:Show()
			vGH_SndBtn:Hide()
			vGH_AmtToOnHand:SetText("You have: "..GetCoinTextureString(GetMoney()))
		elseif GoldHoarding[3] == false then
			vGH_MainFrame:Hide()
			vGH_SetFrame:Hide()
		end
		GoldHoarding = {vGH_SetSndTBox:GetText(),vGH_SetGoldTBox:GetNumber(),vGH_SetOpenCB:GetChecked(),vGH_SetVerbCB:GetChecked()}
	end
	if event == "MAIL_CLOSED" then
		GoldHoarding = {vGH_SetSndTBox:GetText(),vGH_SetGoldTBox:GetNumber(),vGH_SetOpenCB:GetChecked(),vGH_SetVerbCB:GetChecked()}
		vGH_MainFrame:Hide()
		vGH_SetFrame:Hide()
	end
end
)