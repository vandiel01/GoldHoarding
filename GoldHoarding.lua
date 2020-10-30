-- Author	:	Vandiel			(Original Author: Olivier Pelletier)
-- Version	:	2.0				(Original Version: 1.0.6)
-- Date		:	10/25/2020		(Original Last Date: 03/18/2015)
-- Title	:	Gold Hoarding	(Original Title: Every Gold To Banker (EGTB))

local EGTB_GetVers = GetAddOnMetadata("GoldHoarding", "Version") --Grab Version
local EGTB_Vers = "|cffffffff "..EGTB_GetVers.."|r"	-- Version Number
local EGTB_Title = "|c"..RAID_CLASS_COLORS[select(2,UnitClass("player"))].colorStr.."Gold Hoarding|r"  -- EGTB Title
local ShowEGTB = true
Send = "No Name"
Amount = 100
Option = true
Verbose = true
GoldHoarding = {Send,Amount,Option,Verbose}

function EGTB_SetFrame_OnClick()
	if (EGTB_SetFrame:IsVisible()) then
		EGTB_SetFrame:Hide()
	else
		EGTB_SetFrame:Show()
	end
end

local SettingChanges = function(arg)
	if (not type(arg) == "number" or arg == nil) then return else arg = tonumber(arg) end
	--Change Get/Send Settings
	if (arg == 3) or (arg == 4) or (arg == 5) or (arg == 6) then
		CalculateAmountCheck()
	end
	if (arg == 3) or (arg == 4) or (arg == 9) or (arg == 10) then
		EGTB_AmtToSndTBox:SetText(EGTB_SetSndTBox:GetText())
		EGTB_AmtToGoldTBox:SetText(EGTB_SetGoldTBox:GetText())
		GoldHoarding = {EGTB_SetSndTBox:GetText(),EGTB_SetGoldTBox:GetNumber(),EGTB_SetOpenCB:GetChecked(),EGTB_SetVerbCB:GetChecked()}
	end
	--If SendTo is Different from Default, then Reset Icon appears
	if (arg == 5) or (arg == 6) then
		if (EGTB_SetSndTBox:GetText() ~= EGTB_AmtToSndTBox:GetText()) or (EGTB_SetGoldTBox:GetNumber() ~= EGTB_AmtToGoldTBox:GetNumber()) then
			EGTB_AmtToResetBtn:Show()
		else
			EGTB_AmtToResetBtn:Hide()
		end
	end
	if (arg == 7) then --Reset To Default
		EGTB_SetSndTBox:SetText(Send)
		EGTB_SetGoldTBox:SetNumber(Amount)
		EGTB_AmtToSndTBox:SetText(Send)
		EGTB_AmtToGoldTBox:SetNumber(Amount)
		EGTB_SetOpenCB:SetChecked(true)
		EGTB_SetVerbCB:SetChecked(true)
	end
	--EGTB Icon Toggle on MailFrame
	if (arg == 8) then
		if (ShowEGTB) then
			ShowEGTB = false
			EGTB_MainFrame:Show()
		elseif (not ShowEGTB) then
			ShowEGTB = true
			EGTB_MainFrame:Hide()
			EGTB_SetFrame:Hide()
		end
	end
end

local EGTB_Tooltips = function(arg, frame)
	if (not type(arg) == "number" or arg == nil) then return else arg = tonumber(arg) end
	GameTooltip:Hide()
	GameTooltip:ClearLines()
	if arg == 0 then return end
	GameTooltip:SetOwner(frame, "ANCHOR_RIGHT")
	if arg == 1 then msg = "This includes 30c when sending gold to your banker." end
	if arg == 2 then msg = "To make your setting permanent, click here to make changes." end
	if arg == 3 then msg = "Put in a permanent name." end
	if arg == 4 then msg = "Put in a permanent gold amount." end
	if arg == 5 then msg = "To send another person, change here temporarily.\n\nThis variable is not saved!" end
	if arg == 6 then msg = "To send another gold amount, change here temporarily.\n\nThis variable is not saved!" end
	if arg == 7 then msg = "Reset Name/Gold back to default." end
	if arg == 8 then msg = "Toggle "..EGTB_Title end
	if arg == 9 then msg = "Toggle on to open "..EGTB_Title.." at the mailbox" end
	if arg == 10 then msg = "Toggle to display verbose to chat box when sending." end
	GameTooltip:AddLine(msg,1,1,1,1)
	GameTooltip:Show()
end

function CalculateAmountCheck() --Auto Calculate on Info Frame
	EGTB_SndBtn:Hide()
	EGTB_InfoFrame.Msg:SetText("")
	amountToKeep = EGTB_AmtToGoldTBox:GetNumber()*10000
	amountToSend = GetMoney()-amountToKeep-GetSendMailPrice()
	
	if (EGTB_AmtToSndTBox:GetText() == nil) or (EGTB_AmtToSndTBox:GetText() == "") or (EGTB_AmtToSndTBox:GetText() == "No Name") then
		EGTB_InfoFrame.Msg:SetText("Name cannot be blank or 'No Name'")
		return
	end
	if (amountToKeep == GetMoney()) then
		EGTB_InfoFrame.Msg:SetText("Quit trolling your banker!")
		return
	end
	if (amountToSend < 0) then
		EGTB_InfoFrame.Msg:SetText("Keep dreaming to send that much!")
		return
	end
	if (EGTB_AmtToGoldTBox:GetNumber() == 0) then
		EGTB_InfoFrame.Msg:SetText("|cff00ccffSending "..EGTB_AmtToSndTBox:GetText().." ALL: |r"..GetCoinTextureString(amountToSend,10))
		EGTB_SndBtn:Show()
		return
	end
	if (amountToSend > 0) then
		EGTB_InfoFrame.Msg:SetText("|cff00ccffSending "..EGTB_AmtToSndTBox:GetText()..": |r"..GetCoinTextureString(amountToSend,10))
		EGTB_SndBtn:Show()
		return
	end
end

function EGTB_SndBtn_OnClick()
	amountToKeep = EGTB_AmtToGoldTBox:GetNumber()*10000
	amountToSend = GetMoney()-amountToKeep-GetSendMailPrice()
	SendTo = EGTB_AmtToSndTBox:GetText()
	MailFrameTab2:Click() --???
	SetSendMailMoney(amountToSend)
	SendMail(SendTo,"Auto - Gold Hoarding","")
	if EGTB_SetVerbCB:GetChecked() == true then
		DEFAULT_CHAT_FRAME:AddMessage("|cff00ccffSent\: "..EGTB_AmtToSndTBox:GetText().." |r"..GetCoinTextureString(amountToSend))
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
local EGTB_ToggleIcon = CreateFrame("Button", "EGTB_ToggleIcon", MailFrame)
	EGTB_ToggleIcon:SetSize(16,16)
	EGTB_ToggleIcon:SetNormalTexture("Interface\\MoneyFrame\\UI-GoldIcon")
	EGTB_ToggleIcon:SetPoint("TOPRIGHT", MailFrame, -50, -3)
	EGTB_ToggleIcon:SetScript("OnClick", function() SettingChanges(8) end)
	EGTB_ToggleIcon:SetScript("OnEnter", function() EGTB_Tooltips(8,EGTB_ToggleIcon) end)
	EGTB_ToggleIcon:SetScript("OnLeave", function() EGTB_Tooltips(0) end)

--Main Frame
local EGTB_MainFrame = CreateFrame("Frame", "EGTB_MainFrame", MailFrame, BackdropTemplateMixin and "BackdropTemplate")
	EGTB_MainFrame:SetBackdrop(DefaultBackdrop)
	EGTB_MainFrame:SetSize(300,0)
	EGTB_MainFrame:ClearAllPoints()
	EGTB_MainFrame:SetPoint("TOPRIGHT", MailFrame, EGTB_MainFrame:GetWidth() or 0, 0)
	EGTB_MainFrame:SetClampedToScreen(true)

--Title Frame
local EGTB_TitleMFrame = CreateFrame("Frame", "EGTB_TitleMFrame", EGTB_MainFrame, BackdropTemplateMixin and "BackdropTemplate")
	EGTB_TitleMFrame:SetBackdrop(DefaultBackdrop)
	EGTB_TitleMFrame:SetSize(295,30)
	EGTB_TitleMFrame:ClearAllPoints()
	EGTB_TitleMFrame:SetPoint("TOP", EGTB_MainFrame, 0, -2)
		EGTB_TitleMFrame.MTitle = EGTB_TitleMFrame:CreateFontString("MTitle")
		EGTB_TitleMFrame.MTitle:SetFont("Fonts\\FRIZQT__.TTF", 14)
		EGTB_TitleMFrame.MTitle:SetPoint("TOP", EGTB_TitleMFrame, 0, -8)
		EGTB_TitleMFrame.MTitle:SetText(EGTB_Title)

--Amount Frame
local EGTB_AmtToFrame = CreateFrame("Frame", "EGTB_AmtToFrame", EGTB_MainFrame, BackdropTemplateMixin and "BackdropTemplate")
	EGTB_AmtToFrame:SetBackdrop(DefaultBackdrop)
	EGTB_AmtToFrame:SetSize(295,120)
	EGTB_AmtToFrame:ClearAllPoints()
	EGTB_AmtToFrame:SetPoint("TOP", EGTB_TitleMFrame, 0, 0-EGTB_TitleMFrame:GetHeight()+4)
	
	local EGTB_AmtToGoldHdr = EGTB_AmtToFrame:CreateFontString("EGTB_AmtToGoldHdr")
		EGTB_AmtToGoldHdr:SetFont("Fonts\\FRIZQT__.TTF", 12)
		EGTB_AmtToGoldHdr:SetPoint("TOP", EGTB_AmtToFrame, 0, -10)
		EGTB_AmtToGoldHdr:SetText("Amount of gold to keep on: |c"..RAID_CLASS_COLORS[select(2,UnitClass("player"))].colorStr..UnitName("player").."|r")
	local EGTB_AmtToGoldTBox = CreateFrame("EditBox", "EGTB_AmtToGoldTBox", EGTB_AmtToFrame, "InputBoxTemplate")
		EGTB_AmtToGoldTBox:SetNumber(0)
		EGTB_AmtToGoldTBox:SetPoint("TOP", EGTB_AmtToFrame, 0, -30)
		EGTB_AmtToGoldTBox:SetSize(80,20)
		EGTB_AmtToGoldTBox:SetMaxLetters(100)
		EGTB_AmtToGoldTBox:SetAutoFocus(false)
		EGTB_AmtToGoldTBox:SetMultiLine(false)
		EGTB_AmtToGoldTBox:SetNumeric(true)
		EGTB_AmtToGoldTBox:SetScript("OnEnter", function() EGTB_Tooltips(6,EGTB_AmtToGoldTBox) end)
		EGTB_AmtToGoldTBox:SetScript("OnLeave", function() EGTB_Tooltips(0) end)
		EGTB_AmtToGoldTBox:SetScript("OnTextChanged", function() SettingChanges(6) end)
	local EGTB_AmtToGoldIcon = EGTB_AmtToFrame:CreateTexture(nil, "ARTWORK")
		EGTB_AmtToGoldIcon:SetSize(16,16)
		EGTB_AmtToGoldIcon:SetPoint("TOP", EGTB_AmtToFrame, 50, -31)
		EGTB_AmtToGoldIcon:SetTexture("Interface\\MoneyFrame\\UI-GoldIcon")
		
	local EGTB_AmtToOnHand = EGTB_AmtToFrame:CreateFontString("EGTB_AmtToOnHand")
		EGTB_AmtToOnHand:SetFont("Fonts\\FRIZQT__.TTF", 12)
		EGTB_AmtToOnHand:SetPoint("TOP", EGTB_AmtToFrame, 0, -60)
		EGTB_AmtToOnHand:SetText("You have: "..GetCoinTextureString(GetMoney()))	
		
	local EGTB_AmtToSndHdr = EGTB_AmtToFrame:CreateFontString("EGTB_AmtToSndHdr")
		EGTB_AmtToSndHdr:SetFont("Fonts\\FRIZQT__.TTF", 12)
		EGTB_AmtToSndHdr:SetPoint("TOP", EGTB_AmtToFrame, -55, -87)
		EGTB_AmtToSndHdr:SetText("Name Sending To:")
	local EGTB_AmtToSndTBox = CreateFrame("EditBox", "EGTB_AmtToSndTBox", EGTB_AmtToFrame, "InputBoxTemplate")
		EGTB_AmtToSndTBox:SetText("")
		EGTB_AmtToSndTBox:SetPoint("TOP", EGTB_AmtToFrame, 55, -83)
		EGTB_AmtToSndTBox:SetSize(80,20)
		EGTB_AmtToSndTBox:SetMaxLetters(100)
		EGTB_AmtToSndTBox:SetAutoFocus(false)
		EGTB_AmtToSndTBox:SetMultiLine(false)
		EGTB_AmtToSndTBox:SetNumeric(false)
		EGTB_AmtToSndTBox:SetScript("OnEnter", function() EGTB_Tooltips(5,EGTB_AmtToSndTBox) end)
		EGTB_AmtToSndTBox:SetScript("OnLeave", function() EGTB_Tooltips(0) end)
		EGTB_AmtToSndTBox:SetScript("OnTextChanged", function() SettingChanges(5) end)
		
	local EGTB_AmtToResetBtn = CreateFrame("Button", "EGTB_AmtToResetBtn", EGTB_AmtToFrame)
		EGTB_AmtToResetBtn:SetSize(16,16)
		EGTB_AmtToResetBtn:SetNormalTexture("Interface\\Buttons\\UI-RefreshButton")
		EGTB_AmtToResetBtn:SetPoint("BOTTOMRIGHT", EGTB_AmtToFrame, -5, 5)
		EGTB_AmtToResetBtn:SetScript("OnClick", function() SettingChanges(7) end)
		EGTB_AmtToResetBtn:SetScript("OnEnter", function() EGTB_Tooltips(7,EGTB_AmtToResetBtn) end)
		EGTB_AmtToResetBtn:SetScript("OnLeave", function() EGTB_Tooltips(0) end)
		
--Info Frame
local EGTB_InfoFrame = CreateFrame("Frame", "EGTB_InfoFrame", EGTB_MainFrame, BackdropTemplateMixin and "BackdropTemplate")
	EGTB_InfoFrame:SetBackdrop(DefaultBackdrop)
	EGTB_InfoFrame:SetSize(295,30)
	EGTB_InfoFrame:ClearAllPoints()
	EGTB_InfoFrame:SetPoint("TOP", EGTB_AmtToFrame, 0, 0-EGTB_AmtToFrame:GetHeight()+4)
	EGTB_InfoFrame:SetScript("OnEnter", function() EGTB_Tooltips(1,EGTB_InfoFrame) end)
	EGTB_InfoFrame:SetScript("OnLeave", function() EGTB_Tooltips(0) end)
		EGTB_InfoFrame.Msg = EGTB_InfoFrame:CreateFontString("Msg")
		EGTB_InfoFrame.Msg:SetFont("Fonts\\FRIZQT__.TTF", 11)
		EGTB_InfoFrame.Msg:SetPoint("CENTER", EGTB_InfoFrame, 0, 0)
		EGTB_InfoFrame.Msg:SetText("")

--Send Frame
local EGTB_SendFrame = CreateFrame("Frame", "EGTB_SendFrame", EGTB_MainFrame, BackdropTemplateMixin and "BackdropTemplate")
	EGTB_SendFrame:SetBackdrop(DefaultBackdrop)
	EGTB_SendFrame:SetSize(295,40)
	EGTB_SendFrame:ClearAllPoints()
	EGTB_SendFrame:SetPoint("TOP", EGTB_InfoFrame, 0, 0-EGTB_InfoFrame:GetHeight()+3)
	local EGTB_SndBtn = CreateFrame("Button", "EGTB_SndBtn", EGTB_SendFrame, "UIPanelButtonTemplate")
		EGTB_SndBtn:SetSize(80,25)
		EGTB_SndBtn:SetPoint("CENTER", EGTB_SendFrame, 0, 0)
		EGTB_SndBtn:SetText("Send")
		EGTB_SndBtn:SetScript("OnClick", EGTB_SndBtn_OnClick)
	
	local EGTB_OpenSetBtn = CreateFrame("Button", "EGTB_OpenSetBtn", EGTB_SendFrame)
		EGTB_OpenSetBtn:SetSize(16,16)
		EGTB_OpenSetBtn:SetNormalTexture("Interface\\Buttons\\UI-OptionsButton")
		EGTB_OpenSetBtn:SetPoint("CENTER", EGTB_SendFrame, "RIGHT", -15, 0)
		EGTB_OpenSetBtn:SetScript("OnClick", EGTB_SetFrame_OnClick)
		EGTB_OpenSetBtn:SetScript("OnEnter", function() EGTB_Tooltips(2,EGTB_OpenSetBtn) end)
		EGTB_OpenSetBtn:SetScript("OnLeave", function() EGTB_Tooltips(0) end)		
	
	--Resize/Fix Main Frame and Background
	EGTB_MainFrame:SetSize(300,(EGTB_TitleMFrame:GetHeight()+EGTB_AmtToFrame:GetHeight()+EGTB_InfoFrame:GetHeight()+EGTB_SendFrame:GetHeight()-7))
		EGTB_MainFrame.Body = EGTB_MainFrame:CreateTexture(nil, "BACKGROUND")
		EGTB_MainFrame.Body:SetSize(EGTB_MainFrame:GetWidth()-10,EGTB_MainFrame:GetHeight()-10)
		EGTB_MainFrame.Body:SetPoint("TOPLEFT", EGTB_MainFrame, 5, -5)
		EGTB_MainFrame.Body:SetTexture("Interface\\TabardFrame\\TabardFrameBackground")

--Setting Frame
local EGTB_SetFrame = CreateFrame("Frame", "EGTB_SetFrame", EGTB_MainFrame, BackdropTemplateMixin and "BackdropTemplate")
	EGTB_SetFrame:SetBackdrop(DefaultBackdrop)
	EGTB_SetFrame:SetSize(300,125)
	EGTB_SetFrame:ClearAllPoints()
	EGTB_SetFrame:SetPoint("TOP", EGTB_MainFrame, 0, 0-EGTB_MainFrame:GetHeight()+2)
	EGTB_SetFrame:SetClampedToScreen(true)
		EGTB_SetFrame.Body = EGTB_SetFrame:CreateTexture(nil, "BACKGROUND")
		EGTB_SetFrame.Body:SetSize(EGTB_SetFrame:GetWidth()-10,EGTB_SetFrame:GetHeight()-10)
		EGTB_SetFrame.Body:SetPoint("TOPLEFT", EGTB_SetFrame, 5, -5)
		EGTB_SetFrame.Body:SetTexture("Interface\\TabardFrame\\TabardFrameBackground")
	
--Setting Title Frame
local EGTB_TitleSetFrame = CreateFrame("Frame", "EGTB_TitleSetFrame", EGTB_SetFrame, BackdropTemplateMixin and "BackdropTemplate")
	EGTB_TitleSetFrame:SetBackdrop(DefaultBackdrop)
	EGTB_TitleSetFrame:SetSize(295,30)
	EGTB_TitleSetFrame:ClearAllPoints()
	EGTB_TitleSetFrame:SetPoint("TOP", EGTB_SetFrame, "TOP", 0, -2)
		EGTB_TitleSetFrame.STitle = EGTB_TitleSetFrame:CreateFontString("STitle")
		EGTB_TitleSetFrame.STitle:SetFont("Fonts\\FRIZQT__.TTF", 14)
		EGTB_TitleSetFrame.STitle:SetPoint("TOP", EGTB_TitleSetFrame, 0, -8)
		EGTB_TitleSetFrame.STitle:SetText("|cffE1E115Setting|r")

--Setting Player Name/Gold To Send		
local EGTB_SetSnGoFrame = CreateFrame("Frame", "EGTB_SetSnGoFrame", EGTB_SetFrame, BackdropTemplateMixin and "BackdropTemplate")
	EGTB_SetSnGoFrame:SetBackdrop(DefaultBackdrop)
	EGTB_SetSnGoFrame:SetSize(295,94)
	EGTB_SetSnGoFrame:ClearAllPoints()
	EGTB_SetSnGoFrame:SetPoint("TOP", EGTB_SetFrame, 0, -29)
	
	local EGTB_SetSndStr = EGTB_SetSnGoFrame:CreateFontString("EGTB_SetSndStr")
		EGTB_SetSndStr:SetFont("Fonts\\FRIZQT__.TTF", 12)
		EGTB_SetSndStr:SetPoint("TOP", EGTB_SetSnGoFrame, -50, -8)
		EGTB_SetSndStr:SetText(" Default Sending Name:")
		local EGTB_SetSndTBox = CreateFrame("EditBox", "EGTB_SetSndTBox", EGTB_SetSnGoFrame, "InputBoxTemplate")
			EGTB_SetSndTBox:SetText("")
			EGTB_SetSndTBox:SetPoint("TOP", EGTB_SetSnGoFrame, 70, -5)
			EGTB_SetSndTBox:SetSize(80,20)
			EGTB_SetSndTBox:SetMaxLetters(100)
			EGTB_SetSndTBox:SetAutoFocus(false)
			EGTB_SetSndTBox:SetMultiLine(false)
			EGTB_SetSndTBox:SetNumeric(false)
			EGTB_SetSndTBox:SetScript("OnEnter", function() EGTB_Tooltips(3,EGTB_SetSndTBox) end)
			EGTB_SetSndTBox:SetScript("OnLeave", function() EGTB_Tooltips(0) end)
			EGTB_SetSndTBox:SetScript("OnTextChanged", function() SettingChanges(3) end)
			
	local EGTB_SetGoldStr = EGTB_SetSnGoFrame:CreateFontString("EGTB_SetGoldStr")
		EGTB_SetGoldStr:SetFont("Fonts\\FRIZQT__.TTF", 12)
		EGTB_SetGoldStr:SetPoint("TOP", EGTB_SetSnGoFrame, -50, -30)
		EGTB_SetGoldStr:SetText("    Default Gold To Keep:")
		local EGTB_SetGoldTBox = CreateFrame("EditBox", "EGTB_SetGoldTBox", EGTB_SetSnGoFrame, "InputBoxTemplate")
			EGTB_SetGoldTBox:SetNumber(0)
			EGTB_SetGoldTBox:SetPoint("TOP", EGTB_SetSnGoFrame, 70, -27)
			EGTB_SetGoldTBox:SetSize(80,20)
			EGTB_SetGoldTBox:SetMaxLetters(100)
			EGTB_SetGoldTBox:SetAutoFocus(false)
			EGTB_SetGoldTBox:SetMultiLine(false)
			EGTB_SetGoldTBox:SetNumeric(true)
			EGTB_SetGoldTBox:SetScript("OnEnter", function() EGTB_Tooltips(4,EGTB_SetGoldTBox) end)
			EGTB_SetGoldTBox:SetScript("OnLeave", function() EGTB_Tooltips(0) end)
			EGTB_SetGoldTBox:SetScript("OnTextChanged", function() SettingChanges(4) end)
			local EGTB_SetGoldIcon = EGTB_SetSnGoFrame:CreateTexture(nil, "ARTWORK")
				EGTB_SetGoldIcon:SetSize(16,16)
				EGTB_SetGoldIcon:SetPoint("RIGHT", EGTB_SetSnGoFrame, -20, 2)
				EGTB_SetGoldIcon:SetTexture("Interface\\MoneyFrame\\UI-GoldIcon")
				
	local EGTB_SetOpenMailS = EGTB_SetSnGoFrame:CreateFontString("EGTB_SetOpenMailS")
		EGTB_SetOpenMailS:SetFont("Fonts\\FRIZQT__.TTF", 12)
		EGTB_SetOpenMailS:SetPoint("TOP", EGTB_SetSnGoFrame, -50, -52)
		EGTB_SetOpenMailS:SetText(" Open this at MailBox?")
		local EGTB_SetOpenCB = CreateFrame("CheckButton", "EGTB_SetOpenCB", EGTB_SetSnGoFrame, "ChatConfigCheckButtonTemplate")
			EGTB_SetOpenCB:SetChecked(true)
			EGTB_SetOpenCB:SetPoint("TOP", EGTB_SetSnGoFrame, 33, -47)
			EGTB_SetOpenCB:SetScript("OnClick", function() SettingChanges(9) end)
			EGTB_SetOpenCB:SetScript("OnEnter", function() EGTB_Tooltips(9,EGTB_SetOpenCB) end)
			EGTB_SetOpenCB:SetScript("OnLeave", function() EGTB_Tooltips(0) end)
			
	local EGTB_SetVerbose = EGTB_SetSnGoFrame:CreateFontString("EGTB_SetVerbose")
		EGTB_SetVerbose:SetFont("Fonts\\FRIZQT__.TTF", 12)
		EGTB_SetVerbose:SetPoint("TOP", EGTB_SetSnGoFrame, -50, -70)
		EGTB_SetVerbose:SetText("Verbose Enable To Chat")
		local EGTB_SetVerbCB = CreateFrame("CheckButton", "EGTB_SetVerbCB", EGTB_SetSnGoFrame, "ChatConfigCheckButtonTemplate")
			EGTB_SetVerbCB:SetChecked(true)
			EGTB_SetVerbCB:SetPoint("TOP", EGTB_SetSnGoFrame, 33, -65)
			EGTB_SetVerbCB:SetScript("OnClick", function() SettingChanges(10) end)
			EGTB_SetVerbCB:SetScript("OnEnter", function() EGTB_Tooltips(10,EGTB_SetVerbCB) end)
			EGTB_SetVerbCB:SetScript("OnLeave", function() EGTB_Tooltips(0) end)

-------------------------------------------------------
-- OnEvent
-------------------------------------------------------
local EGTB_OnUpdate = CreateFrame("Frame")
	EGTB_OnUpdate:RegisterEvent("ADDON_LOADED")
	EGTB_OnUpdate:RegisterEvent("PLAYER_LOGIN")
	EGTB_OnUpdate:RegisterEvent("MAIL_SHOW")
	EGTB_OnUpdate:RegisterEvent("MAIL_CLOSED")
	EGTB_OnUpdate:RegisterEvent("MAIL_INBOX_UPDATE")
	EGTB_OnUpdate:RegisterEvent("PLAYER_MONEY")

EGTB_OnUpdate:SetScript("OnEvent", function(self, event, ...)
	if event == "ADDON_LOADED" then
		--Do Nothing
	end
	if event == "PLAYER_LOGIN" then
		EGTB_MainFrame:Hide()
		EGTB_SetFrame:Hide()
		DEFAULT_CHAT_FRAME:AddMessage("Loaded: "..EGTB_Title..EGTB_Vers)
	end
	if event == "PLAYER_MONEY" then
		if (MailFrame:IsShown()) then
			EGTB_AmtToOnHand:SetText("You have: "..GetCoinTextureString(GetMoney()))
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
				EGTB_SetSndTBox:SetText(Send)
				EGTB_AmtToSndTBox:SetText(Send)
			else
				EGTB_SetSndTBox:SetText(GoldHoarding[1])
				EGTB_AmtToSndTBox:SetText(GoldHoarding[1])
			end
			if GoldHoarding[2] == nil or not tonumber(GoldHoarding[2]) then --Amount
				EGTB_SetGoldTBox:SetNumber(Amount)
				EGTB_AmtToGoldTBox:SetNumber(Amount)
			else
				EGTB_SetGoldTBox:SetNumber(GoldHoarding[2])
				EGTB_AmtToGoldTBox:SetNumber(GoldHoarding[2])
			end
			if GoldHoarding[3] == nil or GoldHoarding[3] == true then --Open Default?
				EGTB_SetOpenCB:SetChecked(true)
			else
				EGTB_SetOpenCB:SetChecked(false)
			end
			if GoldHoarding[4] == nil or GoldHoarding[4] == true then --Do Verbose?
				EGTB_SetVerbCB:SetChecked(true)
			else
				EGTB_SetVerbCB:SetChecked(false)
			end
		end
		if GoldHoarding[3] == true then
			EGTB_MainFrame:Show()
			--EGTB_SetFrame:Show() -- Temporary
			EGTB_SndBtn:Hide()
			EGTB_AmtToOnHand:SetText("You have: "..GetCoinTextureString(GetMoney()))
		elseif GoldHoarding[3] == false then
			EGTB_MainFrame:Hide()
			EGTB_SetFrame:Hide()
		end
		GoldHoarding = {EGTB_SetSndTBox:GetText(),EGTB_SetGoldTBox:GetNumber(),EGTB_SetOpenCB:GetChecked(),EGTB_SetVerbCB:GetChecked()}
	end
	if event == "MAIL_CLOSED" then
		GoldHoarding = {EGTB_SetSndTBox:GetText(),EGTB_SetGoldTBox:GetNumber(),EGTB_SetOpenCB:GetChecked(),EGTB_SetVerbCB:GetChecked()}
		EGTB_MainFrame:Hide()
		EGTB_SetFrame:Hide()
	end
end
)