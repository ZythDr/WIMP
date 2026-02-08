WIM_VERSION = "1.3.2";

WIM_Windows = {};
WIM_EditBoxInFocus = nil;
WIM_NewMessageFlag = false;
WIM_NewMessageCount = 0;
WIM_Icon_TheMenu = nil;
WIM_Icon_UpdateInterval = .5;
WIM_CascadeStep = 0;
WIM_MaxMenuCount = 20;
WIM_SingleWindow = true;
WIM_WindowCount = 0;
WIM_WindowOrder = 0;
WIM_SharedFrameName = "WIM_msgFrameShared";
WIM_SessionMessages = {};
WIM_SessionHistoryLoaded = {};
WIM_ClassIcons = {};
WIM_ClassColors = {};
WIM_PlayerCache = {}
WIM_PlayerCacheQueue = {}
WIM_WhisperedTo = {}
WIM_LastWhoSent = nil
WIM_IsGM = false
WIM_Debug = false
WIM_InputCache = {}
WIM_UnfocusBlocker = nil
WIM_CacheDimFactor = 0.6
WIM_SessionWinSize = {}
WIM_ResizeHandle = {}

-- GM Check on load: Check for "Teleport to GM Island" spell in spellbook
local WIM_GMCheckFrame = CreateFrame("Frame")
WIM_GMCheckFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
WIM_GMCheckFrame:SetScript("OnEvent", function()
	local i = 1
	while true do
		local spellName = GetSpellName(i, BOOKTYPE_SPELL)
		if not spellName then break end
		if spellName == "Teleport to GM Island" then
			WIM_IsGM = true
			break
		end
		i = i + 1
	end
end)

-- Debug helper with timestamp
function WIM_DebugMsg(msg)
	if WIM_Debug then
		local timestamp = date("%H:%M:%S")
		DEFAULT_CHAT_FRAME:AddMessage("|cff888888[" .. timestamp .. "]|r " .. msg)
	end
end

-- Debug slash command
SLASH_WIMDEBUG1 = "/wimdebug"
SlashCmdList["WIMDEBUG"] = function()
	WIM_Debug = not WIM_Debug
	local timestamp = date("%H:%M:%S")
	if WIM_Debug then
		DEFAULT_CHAT_FRAME:AddMessage("|cff888888[" .. timestamp .. "]|r |cff00ff00[WIM]|r Debug mode ON")
		DEFAULT_CHAT_FRAME:AddMessage("|cff888888[" .. timestamp .. "]|r |cff00ff00[WIM]|r Queue: " .. WIM_TableCount(WIM_PlayerCacheQueue) .. " players")
		DEFAULT_CHAT_FRAME:AddMessage("|cff888888[" .. timestamp .. "]|r |cff00ff00[WIM]|r Cache: " .. WIM_TableCount(WIM_PlayerCache) .. " players")
		DEFAULT_CHAT_FRAME:AddMessage("|cff888888[" .. timestamp .. "]|r |cff00ff00[WIM]|r LastWhoSent: " .. (WIM_LastWhoSent and string.format("%.1fs ago", GetTime() - WIM_LastWhoSent) or "never"))
		DEFAULT_CHAT_FRAME:AddMessage("|cff888888[" .. timestamp .. "]|r |cff00ff00[WIM]|r IsGM: " .. tostring(WIM_IsGM))
		-- Show queue contents
		for name, info in WIM_PlayerCacheQueue do
			DEFAULT_CHAT_FRAME:AddMessage("|cff888888[" .. timestamp .. "]|r |cff00ff00[WIM]|r   Queue: " .. name .. " (attempts=" .. info.attempts .. ")")
		end
	else
		DEFAULT_CHAT_FRAME:AddMessage("|cff888888[" .. timestamp .. "]|r |cffff0000[WIM]|r Debug mode OFF")
	end
end

function WIM_TableCount(t)
	local count = 0
	for _ in t do count = count + 1 end
	return count
end

WIM_AlreadyCheckedGuildRoster = false;

WIM_GuildList = {}; --[Not saved between sessions: Autopopulates from GUILD_ROSTER_UPDATE event
WIM_FriendList = {}; --[Not saved between sessions: Autopopulates from FRIENDLIST_SHOW & FRIENDLIST_UPDATE event

WIM_Alias = {};
WIM_Filters = nil;
	
WIM_ToggleWindow_Timer = 0;
WIM_ToggleWindow_Index = 1;

WIM_RecentList = {}; --[Not saved between sessions: Store's list of recent conversations.
	
WIM_History = {};

WIM_Data_DEFAULTS = {
	versionLastLoaded = "",
	showChangeLogOnNewVersion = true,
	enableWIM = true,
	iconPosition=337,
	showMiniMap=true,
	displayColors = {
		wispIn = {r=0.5607843137254902, g=0.03137254901960784, b=0.7607843137254902},
		wispOut = {r=1, g=0.07843137254901961, b=0.9882352941176471},
		sysMsg = {r=1, g=0.6627450980392157, b=0},
		errorMsg = {r=1, g=0, b=0},
		webAddress = {r=0, g=0, b=1},
	},
	fontSize = 12,
	windowSize = 1,
	windowAlpha = .8,
	supressWisps = true,
	keepFocus = false,
	keepFocusRested = false,
	popNew = true,
	popUpdate = true,
	popOnSend = true,
	popCombat = false,
	autoFocus = false,
	playSoundWisp = true,
	showToolTips = true,
	sortAlpha = false,
	winSize = {
		width = 384,
		height = 256
	},
	winLoc = {
		left =242 ,
		top =775
	},
	winCascade = {
		enabled = true,
		direction = "downright"
	},
	miniFreeMoving = {
		enabled = false;
		left = 0,
		top = 0
	},
	characterInfo = {
		show = true,
		classIcon = true,
		details = true,
		classColor = true
	},
	showTimeStamps = true,
	showShortcutBar = true,
	enableAlias = true,
	enableFilter = true,
	aliasAsComment = true,
	enableHistory = true,
	historySettings = {
		recordEveryone = false,
		recordFriends = true,
		recordGuild = true,
		colorIn = {
				r=0.4705882352941176,
				g=0.4705882352941176,
				b=0.4705882352941176
		},
		colorOut = {
				r=0.7058823529411764,
				g=0.7058823529411764,
				b=0.7058823529411764
		},
		popWin = {
			enabled = true,
			count = 25
		},
		maxMsg = {
			enabled = true,
			count = 200
		},
		autoDelete = {
			enabled = true,
			days = 7
		}
	},
	showAFK = true,
	useEscape = true,
	escapeUnfocus = false,
	hookWispParse = true,
	blockLowLevel = false,
	requireAltForArrows = false,
	mergeWindows = true,
	clickOutsideUnfocus = false,
	tabBarBelow = false,
	classColorMessages = true,
	wimPlayerDBLookup = true,
	pfuiPlayerDBLookup = true,
};
--[initialize defualt values
WIM_Data = WIM_Data_DEFAULTS;

WIM_CascadeDirection = {
	up = {
		left = 0,
		top = 25
	},
	down = {
		left = 0,
		top = -25
	},
	left = {
		left = -50,
		top = 0
	},
	right = {
		left = 50,
		top = 0
	},
	upleft = {
		left = -50,
		top = 25
	},
	upright = {
		left = 50,
		top = 25
	},
	downleft = {
		left = -50,
		top = -25
	},
	downright = {
		left = 50,
		top = -25
	}
};

WIM_IconItems = { };

function WIM_OnLoad()
	SlashCmdList["WIM"] = WIM_SlashCommand;
	SLASH_WIM1 = "/wim";
end

function WIM_IsMergeEnabled()
	return WIM_Data and WIM_Data.mergeWindows;
end

function WIM_ClearSessionSize()
	WIM_SessionWinSize = {}
end

function WIM_GetEffectiveWinSize(theWin)
	local width = WIM_Data.winSize.width
	local height = WIM_Data.winSize.height
	if theWin and WIM_SessionWinSize then
		local key = theWin:GetName()
		local entry = key and WIM_SessionWinSize[key]
		if entry then
			width = entry.width or width
			height = entry.height or height
		end
	end
	if WIM_Data.showShortcutBar then
		if height < 240 then
			height = 240
		end
	end
	return width, height
end

function WIM_ResizeHandle_Init(theWin)
	if not theWin then
		return
	end
	local key = theWin:GetName()
	if not key then
		return
	end
	if WIM_ResizeHandle[key] then
		return
	end
	local h = CreateFrame("Frame", "WIM_ResizeHandle"..key, theWin)
	h:SetWidth(32)
	h:SetHeight(32)
	h:SetPoint("BOTTOMRIGHT", theWin, "BOTTOMRIGHT", 2, -2)
	h:EnableMouse(true)
	h:SetFrameStrata(theWin:GetFrameStrata())
	h:SetFrameLevel(theWin:GetFrameLevel() + 30)
	h.tex = h:CreateTexture(nil, "OVERLAY")
	h.tex:SetWidth(20)
	h.tex:SetHeight(20)
	h.tex:SetPoint("BOTTOMRIGHT", h, "BOTTOMRIGHT", -2, 2)
	h.tex:SetTexture("Interface\\Cursor\\Item")
	h.tex:SetTexCoord(0.45, 0, 0.45, 0)
	h.tex:SetVertexColor(1, 1, 1)
	h.tex:SetAlpha(0.3)
	h._hoverAlpha = 0.3
	h:SetScript("OnEnter", function()
		h._hoverAlpha = 1
		h.tex:SetAlpha(1)
	end)
	h:SetScript("OnLeave", function()
		h._hoverAlpha = 0.30
		h.tex:SetAlpha(0.30)
	end)
	h:SetScript("OnMouseDown", function()
		h._wimResizing = true
		h._startX, h._startY = GetCursorPosition()
		h._startW = theWin:GetWidth()
		h._startH = theWin:GetHeight()
	end)
	h:SetScript("OnMouseUp", function()
		h._wimResizing = false
		if WIM_SessionWinSize and WIM_SessionWinSize[key] then
			WIM_SetWindowProps(theWin)
			if WIM_TabBar then
				WIM_TabBar_Update(true)
			end
		end
	end)
	h:SetScript("OnUpdate", function()
		if not h._wimResizing then
			return
		end
		local x, y = GetCursorPosition()
		local scale = theWin:GetEffectiveScale()
		local dx = (x - h._startX) / scale
		local dy = (h._startY - y) / scale
		local width = h._startW + dx
		local height = h._startH + dy
		local minW, maxW = 250, 800
		local minH, maxH = 130, 600
		if WIM_Data.showShortcutBar and minH < 240 then
			minH = 240
		end
		if width < minW then width = minW end
		if width > maxW then width = maxW end
		if height < minH then height = minH end
		if height > maxH then height = maxH end
		WIM_SessionWinSize[key] = { width = width, height = height }
		theWin:SetWidth(width)
		theWin:SetHeight(height)
	end)
	WIM_ResizeHandle[key] = h
end

function WIM_DimHexColor(hex, factor)
	if not hex or string.len(hex) < 6 then
		return hex
	end
	local r = tonumber(string.sub(hex, 1, 2), 16) / 255
	local g = tonumber(string.sub(hex, 3, 4), 16) / 255
	local b = tonumber(string.sub(hex, 5, 6), 16) / 255
	r = r * factor
	g = g * factor
	b = b * factor
	return WIM_RGBtoHex(r, g, b)
end

function WIM_PlayerCacheDB_Clear(name)
	if WIM_PlayerCacheDB then
		WIM_PlayerCacheDB[name] = nil
	end
end

function WIM_PlayerCacheDB_ClearAll()
	if WIM_PlayerCacheDB then
		WIM_PlayerCacheDB = {}
	end
end

function WIM_FindPlayerCacheDBEntry(name)
	if not (name and WIM_PlayerCacheDB) then
		return nil, nil
	end

	local info = WIM_PlayerCacheDB[name]
	if info then
		return name, info
	end

	local up = string.upper(name)
	for key, data in WIM_PlayerCacheDB do
		if key and string.upper(key) == up then
			return key, data
		end
	end
	return nil, nil
end

function WIM_EnsurePlayerCacheFromDB(name)
	if not (name and WIM_PlayerCache) then
		return nil
	end
	if not (WIM_Data and WIM_Data.wimPlayerDBLookup ~= false) then
		return nil
	end

	local _, info = WIM_FindPlayerCacheDBEntry(name)
	if not info then
		return WIM_PlayerCache[name]
	end

	local existing = WIM_PlayerCache[name]
	if existing and existing.source ~= "pfui" then
		return existing
	end

	WIM_PlayerCache[name] = {
		class = info.class or "",
		level = info.level,
		race = info.race or "",
		guild = info.guild or "",
		isGM = info.isGM,
		cached = true,
		source = "wimdb",
		stamp = info.stamp,
	}
	return WIM_PlayerCache[name]
end

function WIM_ShouldUseWIMPlayerDB()
	return WIM_Data and WIM_Data.wimPlayerDBLookup ~= false
end

function WIM_ShouldUsePfUIPlayerDB()
	return WIM_Data and WIM_Data.pfuiPlayerDBLookup ~= false
end

function WIM_EnsurePlayerCacheFallback(name)
	if not name then
		return nil
	end

	local info = nil
	if WIM_ShouldUseWIMPlayerDB() and WIM_EnsurePlayerCacheFromDB then
		info = WIM_EnsurePlayerCacheFromDB(name)
	end
	if (not info) and WIM_ShouldUsePfUIPlayerDB() and WIM_pfUI_EnsurePlayerCache then
		info = WIM_pfUI_EnsurePlayerCache(name)
	end
	return info
end

function WIM_UnfocusBlocker_Init()
	if WIM_UnfocusBlocker then
		return
	end
	local f = CreateFrame("Frame", "WIM_UnfocusBlocker", UIParent)
	f:SetAllPoints(UIParent)
	f:SetFrameStrata("BACKGROUND")
	f:EnableMouse(true)
	f._mouseEnabled = true
	f:Hide()
	f:SetScript("OnMouseDown", function()
		if not (WIM_Data and WIM_Data.clickOutsideUnfocus) then
			return
		end
		if WIM_EditBoxInFocus then
			WIM_EditBoxInFocus:ClearFocus()
		end
	end)
	f:SetScript("OnUpdate", function()
		local allow = not (IsShiftKeyDown() or IsAltKeyDown() or IsControlKeyDown())
		if allow ~= f._mouseEnabled then
			f._mouseEnabled = allow
			f:EnableMouse(allow)
		end
	end)
	WIM_UnfocusBlocker = f
end

function WIM_UnfocusBlocker_Show()
	if not (WIM_Data and WIM_Data.clickOutsideUnfocus) then
		return
	end
	WIM_UnfocusBlocker_Init()
	WIM_UnfocusBlocker:Show()
end

function WIM_UnfocusBlocker_Hide()
	if WIM_UnfocusBlocker then
		WIM_UnfocusBlocker:Hide()
	end
end

function WIM_FindMostRecentUser()
	local bestUser = nil
	local bestTime = -1
	local bestVisible = false
	for user in WIM_Windows do
		local info = WIM_Windows[user]
		local frame = info and info.frame and getglobal(info.frame)
		local visible = frame and frame:IsVisible()
		local t = (info and info.last_msg) or 0
		if visible then
			if not bestVisible or t > bestTime then
				bestUser = user
				bestTime = t
				bestVisible = true
			end
		elseif not bestVisible and t > bestTime then
			bestUser = user
			bestTime = t
		end
	end
	return bestUser
end

function WIM_SwitchMergeMode(enable)
	local want = enable and true or false
	if WIM_IsMergeEnabled() == want then
		return
	end

	if want then
		for user in WIM_Windows do
			local info = WIM_Windows[user]
			local frame = info and info.frame and getglobal(info.frame)
			info.was_visible = frame and frame:IsVisible() or false
			if frame and info.frame ~= WIM_SharedFrameName then
				frame:Hide()
			end
			if info then
				info.is_visible = false
			end
		end
		WIM_Data.mergeWindows = true
		local active = WIM_TabBar_ActiveUser
		if not (active and WIM_Windows[active]) then
			active = WIM_FindMostRecentUser()
		end
		if active then
			WIM_SelectUser(active)
			WIM_GetSharedFrame():Show()
		else
			local shared = getglobal(WIM_SharedFrameName)
			if shared then
				shared:Hide()
			end
		end
	else
		local active = WIM_TabBar_ActiveUser
		local shared = getglobal(WIM_SharedFrameName)
		if shared then
			shared:Hide()
		end
		WIM_Data.mergeWindows = false
		local users = {}
		for user in WIM_Windows do
			table.insert(users, user)
		end
		table.sort(users, WIM_Icon_SortByCreation)
		local step = 0
		for i=1,table.getn(users) do
			local user = users[i]
			local info = WIM_Windows[user]
			local f = WIM_GetOrCreateWindow(user)
			if f and info then
				info.frame = f:GetName()
				f.theUser = user
				if not f._wimSessionLoaded then
					WIM_LoadConversation(user, f)
					f._wimSessionLoaded = true
				end
				WIM_SetWhoInfo(user)
				WIM_CascadeStep = step
				WIM_SetWindowLocation(f)
				step = step + 1
				if step > 10 then
					step = 0
				end
				f:Show()
				info.is_visible = true
			end
		end
		WIM_CascadeStep = step
	end

	WIM_TabBar_Update(false)
	WIM_Icon_DropDown_Update()
end

function WIM_GetSharedFrame()
	local f = getglobal(WIM_SharedFrameName)
	if not f then
		f = CreateFrame('Frame', WIM_SharedFrameName, UIParent, 'WIM_msgFrameTemplate')
		WIM_SetWindowProps(f)
		WIM_SetWindowLocation(f)
		f._wimSharedInit = true
	end
	return f
end

function WIM_GetOrCreateWindow(theUser)
	if WIM_Windows[theUser] and WIM_Windows[theUser].frame then
		local frameName = WIM_Windows[theUser].frame
		local existing = getglobal(frameName)
		if existing then
			if frameName ~= WIM_SharedFrameName or WIM_IsMergeEnabled() then
				return existing
			end
		end
	end
	WIM_WindowCount = WIM_WindowCount + 1
	local frameName = "WIM_msgFrame"..WIM_WindowCount
	local f = CreateFrame('Frame', frameName, UIParent, 'WIM_msgFrameTemplate')
	f.theUser = theUser
	f._wimSessionLoaded = false
	WIM_SetWindowProps(f)
	WIM_SetWindowLocation(f)
	local from = getglobal(frameName.."From")
	if from then
		from:SetText(WIM_GetAlias(theUser))
	end
	local details = getglobal(frameName.."CharacterDetails")
	if details then
		details:SetText("")
	end
	local icon = getglobal(frameName.."ClassIcon")
	if icon then
		icon:SetTexture("Interface\\AddOns\\WIM\\Images\\classBLANK")
	end
	return f
end

function WIM_GetSharedChatBox()
	local f = WIM_GetSharedFrame()
	return getglobal(f:GetName().."ScrollingMessageFrame")
end

function WIM_EnsureSession(user)
	if not WIM_SessionMessages[user] then
		WIM_SessionMessages[user] = {}
	end
end

function WIM_RecordMessage(user, msg, r, g, b, noEcho)
	WIM_EnsureSession(user)
	local entry = { msg = msg, r = r, g = g, b = b }
	table.insert(WIM_SessionMessages[user], entry)
	local maxLines = 128
	local chatBox = nil
	if WIM_IsMergeEnabled() then
		chatBox = WIM_GetSharedChatBox()
		maxLines = chatBox:GetMaxLines() or 128
	end
	while table.getn(WIM_SessionMessages[user]) > maxLines do
		table.remove(WIM_SessionMessages[user], 1)
	end
	if WIM_IsMergeEnabled() then
		if not noEcho and WIM_TabBar_ActiveUser and string.upper(WIM_TabBar_ActiveUser) == string.upper(user) then
			chatBox:AddMessage(msg, r, g, b)
		end
	elseif not noEcho then
		local win = WIM_GetOrCreateWindow(user)
		local winChat = win and getglobal(win:GetName().."ScrollingMessageFrame")
		if winChat then
			winChat:AddMessage(msg, r, g, b)
		end
	end
end

function WIM_LoadHistoryIntoSession(theUser)
	if WIM_SessionHistoryLoaded[theUser] then
		return
	end
	WIM_SessionHistoryLoaded[theUser] = true
	if not (WIM_History[theUser] and WIM_Data.enableHistory and WIM_Data.historySettings.popWin.enabled) then
		return
	end
	table.sort(WIM_History[theUser], WIM_SortHistory)
	for i=table.getn(WIM_History[theUser])-WIM_Data.historySettings.popWin.count-1, table.getn(WIM_History[theUser]) do
		if(WIM_History[theUser][i]) then
			local fromName = WIM_History[theUser][i].from
			local nameLink = WIM_FormatPlayerLink(fromName, WIM_GetAlias(fromName, true), WIM_History[theUser][i].isGM, true, true)
			local msg = nameLink..": "..WIM_History[theUser][i].msg
			if(WIM_Data.showTimeStamps) then
				msg = WIM_History[theUser][i].time.." "..msg
			end
			if(WIM_History[theUser][i].type == 1) then
				WIM_RecordMessage(theUser, msg, WIM_Data.historySettings.colorIn.r, WIM_Data.historySettings.colorIn.g, WIM_Data.historySettings.colorIn.b, true)
			elseif(WIM_History[theUser][i].type == 2) then
				WIM_RecordMessage(theUser, msg, WIM_Data.historySettings.colorOut.r, WIM_Data.historySettings.colorOut.g, WIM_Data.historySettings.colorOut.b, true)
			end
		end
	end
end

function WIM_LoadConversation(theUser, frame)
	local f = frame or WIM_GetSharedFrame()
	local chatBox = getglobal(f:GetName().."ScrollingMessageFrame")
	chatBox:Clear()
	WIM_EnsureSession(theUser)
	WIM_LoadHistoryIntoSession(theUser)
	for i=1,table.getn(WIM_SessionMessages[theUser]) do
		local entry = WIM_SessionMessages[theUser][i]
		chatBox:AddMessage(entry.msg, entry.r, entry.g, entry.b)
	end
	if WIM_Data.enableHistory and WIM_History[theUser] then
		getglobal(f:GetName().."HistoryButton"):Show()
	else
		getglobal(f:GetName().."HistoryButton"):Hide()
	end
	WIM_UpdateScrollBars(chatBox)
end

function WIM_SelectUser(theUser)
	if not theUser or not WIM_Windows[theUser] then
		return
	end
	if not WIM_IsMergeEnabled() then
		local f = WIM_GetOrCreateWindow(theUser)
		if not f then
			return
		end
		f.theUser = theUser
		WIM_Windows[theUser].newMSG = false
		getglobal(f:GetName().."From"):SetText(WIM_GetAlias(theUser))
		WIM_LoadConversation(theUser, f)
		WIM_SetWhoInfo(theUser)
		f:Show()
		f:Raise()
		return
	end
	local f = WIM_GetSharedFrame()
	local edit = getglobal(f:GetName().."MsgBox")
	local prevUser = WIM_TabBar_ActiveUser
	local wasFocused = false
	if edit then
		if edit.HasFocus then
			wasFocused = edit:HasFocus()
		elseif edit.IsFocused then
			wasFocused = edit:IsFocused()
		end
	end
	if prevUser and edit then
		WIM_InputCache[prevUser] = edit:GetText()
	end
	f.theUser = theUser
	WIM_TabBar_SetActiveUser(theUser)
	for key in WIM_Windows do
		WIM_Windows[key].is_visible = (string.upper(key) == string.upper(theUser))
	end
	WIM_Windows[theUser].newMSG = false
	getglobal(f:GetName().."From"):SetText(WIM_GetAlias(theUser))
	WIM_LoadConversation(theUser)
	WIM_SetWhoInfo(theUser)
	if edit then
		local text = WIM_InputCache[theUser] or ""
		edit:SetText(text)
		if edit.SetCursorPosition then
			edit:SetCursorPosition(string.len(text))
		end
		if wasFocused then
			edit:SetFocus()
		end
	end
end


function WIM_Incoming(event)
	--[Events
	if(event == "VARIABLES_LOADED") then
		if(WIM_Data.enableWIM == nil) then WIM_Data.enableWIM = WIM_Data_DEFAULTS.enableWIM; end;
		if(WIM_Data.versionLastLoaded == nil) then WIM_Data.versionLastLoaded = ""; end;
		if(WIM_Data.showChangeLogOnNewVersion == nil) then WIM_Data.showChangeLogOnNewVersion = WIM_Data_DEFAULTS.showChangeLogOnNewVersion; end;
		if(WIM_Data.displayColors == nil) then WIM_Data.displayColors = WIM_Data_DEFAULTS.displayColors; end;
		if(WIM_Data.displayColors.sysMsg == nil) then WIM_Data.displayColors.sysMsg = WIM_Data_DEFAULTS.displayColors.sysMsg; end;
		if(WIM_Data.displayColors.errorMsg == nil) then WIM_Data.displayColors.errorMsg = WIM_Data_DEFAULTS.displayColors.errorMsg; end;
		if(WIM_Data.fontSize == nil) then WIM_Data.fontSize = WIM_Data_DEFAULTS.fontSize; end;
		if(WIM_Data.windowSize == nil) then WIM_Data.windowSize = WIM_Data_DEFAULTS.windowSize; end;
		if(WIM_Data.windowAlpha == nil) then WIM_Data.windowAlpha = WIM_Data_DEFAULTS.windowAlpha; end;
		if(WIM_Data.supressWisps == nil) then WIM_Data.supressWisps = WIM_Data_DEFAULTS.supressWisps; end;
		if(WIM_Data.keepFocus == nil) then WIM_Data.keepFocus = WIM_Data_DEFAULTS.keepFocus; end;
		if(WIM_Data.keepFocusRested == nil) then WIM_Data.keepFocusRested = WIM_Data_DEFAULTS.keepFocusRested; end;
		if(WIM_Data.popNew == nil) then WIM_Data.popNew = WIM_Data_DEFAULTS.popNew; end;
		if(WIM_Data.popUpdate == nil) then WIM_Data.popNew = WIM_Data_DEFAULTS.popUpdate; end;
		if(WIM_Data.autoFocus == nil) then WIM_Data.autoFocus = WIM_Data_DEFAULTS.autoFocus; end;
		if(WIM_Data.playSoundWisp == nil) then WIM_Data.playSoundWisp = WIM_Data_DEFAULTS.playSoundWisp; end;
		if(WIM_Data.showToolTips == nil) then WIM_Data.showToolTips = WIM_Data_DEFAULTS.showToolTips; end;
		if(WIM_Data.sortAlpha == nil) then WIM_Data.sortAlpha = WIM_Data_DEFAULTS.sortAlpha; end;
		if(WIM_Data.winSize == nil) then WIM_Data.winSize = WIM_Data_DEFAULTS.winSize; end;
		if(WIM_Data.miniFreeMoving == nil) then WIM_Data.miniFreeMoving = WIM_Data_DEFAULTS.miniFreeMoving; end;
		if(WIM_Data.popCombat == nil) then WIM_Data.popCombat = WIM_Data_DEFAULTS.popCombat; end;
		if(WIM_Data.characterInfo == nil) then WIM_Data.characterInfo = WIM_Data_DEFAULTS.characterInfo; end;
		if(WIM_Data.showTimeStamps == nil) then WIM_Data.showTimeStamps = WIM_Data_DEFAULTS.showTimeStamps; end;
		if(WIM_Data.showShortcutBar == nil) then WIM_Data.showShortcutBar = WIM_Data_DEFAULTS.showShortcutBar; end;
		if(WIM_Data.enableAlias == nil) then WIM_Data.enableAlias = WIM_Data_DEFAULTS.enableAlias; end;
		if(WIM_Data.enableFilter == nil) then WIM_Data.enableFilter = WIM_Data_DEFAULTS.enableFilter; end;
		if(WIM_Data.aliasAsComment == nil) then WIM_Data.aliasAsComment = WIM_Data_DEFAULTS.aliasAsComment; end;
		if(WIM_Data.enableHistory == nil) then WIM_Data.enableHistory = WIM_Data_DEFAULTS.enableHistory; end;
		if(WIM_Data.historySettings == nil) then WIM_Data.historySettings = WIM_Data_DEFAULTS.historySettings; end;
		if(WIM_Data.winLoc == nil) then WIM_Data.winLoc = WIM_Data_DEFAULTS.winLoc; end;
		if(WIM_Data.winCascade == nil) then WIM_Data.winCascade = WIM_Data_DEFAULTS.winCascade; end;
		if(WIM_Data.popOnSend == nil) then WIM_Data.popOnSend = WIM_Data_DEFAULTS.popOnSend; end;
		if(WIM_Data.versionLastLoaded == nil) then WIM_Data.versionLastLoaded = WIM_Data_DEFAULTS.versionLastLoaded; end;
		if(WIM_Data.showAFK == nil) then WIM_Data.showAFK = WIM_Data_DEFAULTS.showAFK; end;
		if(WIM_Data.useEscape == nil) then WIM_Data.useEscape = WIM_Data_DEFAULTS.useEscape; end;
		if(WIM_Data.escapeUnfocus == nil) then WIM_Data.escapeUnfocus = WIM_Data_DEFAULTS.escapeUnfocus; end;
		if(WIM_Data.hookWispParse == nil) then WIM_Data.hookWispParse = WIM_Data_DEFAULTS.hookWispParse; end;
		if(WIM_Data.requireAltForArrows == nil) then WIM_Data.requireAltForArrows = WIM_Data_DEFAULTS.requireAltForArrows; end;
		if(WIM_Data.mergeWindows == nil) then WIM_Data.mergeWindows = WIM_Data_DEFAULTS.mergeWindows; end;
		if(WIM_Data.clickOutsideUnfocus == nil) then WIM_Data.clickOutsideUnfocus = WIM_Data_DEFAULTS.clickOutsideUnfocus; end;
		if(WIM_Data.tabBarBelow == nil) then WIM_Data.tabBarBelow = WIM_Data_DEFAULTS.tabBarBelow; end;
		if(WIM_Data.classColorMessages == nil) then WIM_Data.classColorMessages = WIM_Data_DEFAULTS.classColorMessages; end;
		if(WIM_Data.wimPlayerDBLookup == nil) then WIM_Data.wimPlayerDBLookup = WIM_Data_DEFAULTS.wimPlayerDBLookup; end;
		if(WIM_Data.pfuiPlayerDBLookup == nil) then WIM_Data.pfuiPlayerDBLookup = WIM_Data_DEFAULTS.pfuiPlayerDBLookup; end;

		if(WIM_PlayerCacheDB == nil) then WIM_PlayerCacheDB = {}; end;
		if WIM_Data.wimPlayerDBLookup ~= false then
			for name, info in WIM_PlayerCacheDB do
				if not WIM_PlayerCache[name] then
					WIM_PlayerCache[name] = {
						class = info.class or "",
						level = info.level,
						race = info.race or "",
						guild = info.guild or "",
						isGM = info.isGM,
						cached = true,
						source = "wimdb",
						stamp = info.stamp,
					};
				end
			end
		end

		if(WIM_Filters == nil) then
			WIM_LoadDefaultFilters();
		end
		
		ShowFriends(); --[update friend list
		if(IsInGuild()) then GuildRoster(); end; --[update guild roster
		
		ItemRefTooltip:SetFrameStrata("TOOLTIP");
		
		WIM_HistoryPurge();
		
		WIM_InitClassProps();
		
		WIM_SetWIM_Enabled(WIM_Data.enableWIM);
		
		if(WIM_VERSION ~= WIM_Data.versionLastLoaded) then
			WIM_Help:Show();
		end
		WIM_Data.versionLastLoaded = WIM_VERSION;
		
		if(WIM_Data.miniFreeMoving.enabled) then
			if(WIM_Data.showMiniMap == false) then
				WIM_IconFrame:Hide();
			else
				WIM_IconFrame:Show();
				WIM_IconFrame:SetFrameStrata("LOW");
				WIM_IconFrame:SetPoint("TOPLEFT", "UIParent", "BOTTOMLEFT",WIM_Data.miniFreeMoving.left,WIM_Data.miniFreeMoving.top);
			end
		else
			WIM_Icon_UpdatePosition();
		end
		
	elseif(event == "TRADE_SKILL_SHOW" or event == "CRAFT_SHOW") then
		--[hook tradeskill window functions
		WIM_HookTradeSkill();
	elseif(event == "GUILD_ROSTER_UPDATE") then
		WIM_LoadGuildList();
		WIM_AlreadyCheckedGuildRoster = true;
	elseif(event == "FRIENDLIST_SHOW" or event == "FRIENDLIST_UPDATE") then
		WIM_LoadFriendList();
	elseif(event == "ADDON_LOADED") then
		WIM_AddonDetectToHook(arg1);
	else
		if(WIM_AlreadyCheckedGuildRoster == false) then
			if(IsInGuild()) then GuildRoster(); end; --[update guild roster
		end
		WIM_ChatFrame_OnEvent(event);
	end
end

function WIM_PlayerCacheQueueEmpty()
	for _, info in WIM_PlayerCacheQueue do
		if info.attempts <= 5 then
			return false
		end
	end
	return true
end

function WIM_Update()
	-- Turtle WoW: 30 second WHO cooldown (global) - GMs skip cooldown but wait for response
	if not WIM_IsGM then
		local WHO_COOLDOWN = 30
		if WIM_LastWhoSent and GetTime() - WIM_LastWhoSent < WHO_COOLDOWN then
			return
		end
		
		-- Don't send multiple WHOs if we're still waiting for results (non-GM only)
		if WIM_WhoScanInProgress then
			local timeout = 10
			if WIM_LastWhoSent and GetTime() - WIM_LastWhoSent < timeout then
				return
			end
			-- Timeout reached, allow retry
			WIM_DebugMsg("|cffffff00[WIM WHO]|r Timeout reached, allowing retry")
			WIM_WhoScanInProgress = false
		end
	else
		-- GM: Still need to wait for WHO response before sending next one
		if WIM_WhoScanInProgress then
			local timeout = 2 -- Short timeout for GMs
			if WIM_LastWhoSent and GetTime() - WIM_LastWhoSent < timeout then
				return
			end
			-- Timeout reached, allow retry
			WIM_DebugMsg("|cffffff00[WIM WHO]|r GM timeout reached, allowing retry")
			WIM_WhoScanInProgress = false
		end
	end
	
	-- Find next player to query (round-robin by lowest attempts)
	local nextPlayer = nil
	local lowestAttempts = 999
	local toRemove = {}
	
	for name, info in WIM_PlayerCacheQueue do
		-- Mark for removal after 5 failed attempts
		if info.attempts >= 5 then
			tinsert(toRemove, name)
		elseif info.attempts < lowestAttempts then
			lowestAttempts = info.attempts
			nextPlayer = name
		end
	end
	
	-- Remove failed players outside of loop
	for _, name in toRemove do
		WIM_DebugMsg("|cffff0000[WIM WHO]|r Removing " .. name .. " from queue (5 failed attempts)")
		WIM_PlayerCacheQueue[name] = nil
	end
	
	if nextPlayer then
		local info = WIM_PlayerCacheQueue[nextPlayer]
		WIM_DebugMsg("|cff00ffff[WIM WHO]|r Sending WHO for: " .. nextPlayer .. " (attempt " .. (info.attempts + 1) .. ")" .. (WIM_IsGM and " [GM]" or ""))
		WIM_WhoScanInProgress = true
		-- Only call SetWhoToUI for non-GMs
		if not WIM_IsGM then
			SetWhoToUI(1)
		end
		SendWho('n-"'..nextPlayer..'"')
		info.attempts = info.attempts + 1
		WIM_LastWhoSent = GetTime()
	end
end

function WIM_WhoInfo(name, callback)
	if WIM_PlayerCache[name] and not WIM_PlayerCache[name].cached then
		WIM_DebugMsg("|cff00ff00[WIM WHO]|r " .. name .. " already in cache, skipping WHO")
		callback(WIM_PlayerCache[name])
		return
	end
	if WIM_PlayerCache[name] and WIM_PlayerCache[name].cached then
		WIM_DebugMsg("|cffffff00[WIM WHO]|r Using cached data for " .. name .. ", queueing WHO")
		callback(WIM_PlayerCache[name])
		if WIM_PlayerCacheQueue[name] then
			return
		end
	end
	WIM_DebugMsg("|cffffff00[WIM WHO]|r Adding " .. name .. " to queue")
	WIM_WhoScanInProgress = true
	SetWhoToUI(1)
	WIM_PlayerCacheQueue[name] = WIM_PlayerCacheQueue[name] or { callbacks = {} }
	WIM_PlayerCacheQueue[name].attempts = 0
	tinsert(WIM_PlayerCacheQueue[name].callbacks, callback)
end

local function playerCheck(player, k)
	-- Always show messages immediately - WHO info will load async
	-- Queue WHO request for player info (class/race/level) if not cached
	WIM_DebugMsg("|cff00ffff[WIM]|r playerCheck: " .. player)

	if WIM_EnsurePlayerCacheFallback then
		WIM_EnsurePlayerCacheFallback(player)
	end
	
	-- Skip WHO check if player is a GM (we already have GM info)
	if WIM_PlayerCache[player] and WIM_PlayerCache[player].isGM then
		WIM_DebugMsg("|cff00ffff[WIM]|r Skipping WHO for GM: " .. player)
		return k()
	end
	
	if (not WIM_PlayerCache[player] or WIM_PlayerCache[player].cached) and not WIM_PlayerCacheQueue[player] then
		WIM_WhoInfo(player, function(info)
			-- Info loaded - update window if exists (but not for GMs)
			if WIM_Windows[player] and not (WIM_PlayerCache[player] and WIM_PlayerCache[player].isGM) then
				WIM_SetWhoInfo(player)
			end
		end)
	end
	return k()
end

function WIM_ChatFrame_OnEvent(event)
	if( WIM_Data.enableWIM == false) then
		return;
	end
	local msg = "";
	if((event == "CHAT_MSG_AFK" or event == "CHAT_MSG_DND") and WIM_Data.showAFK) then
		local afkType;
		if( event == "CHAT_MSG_AFK" ) then
			afkType = "AFK";
		else
			afkType = "DND";
		end
		local nameLink = WIM_FormatPlayerLink(arg2, WIM_GetAlias(arg2, true), false, false)
		msg = "<"..afkType.."> "..nameLink..": "..arg1;
		WIM_PostMessage(arg2, msg, 3);
		ChatEdit_SetLastTellTarget(ChatFrameEditBox,arg2);
	elseif event == 'CHAT_MSG_WHISPER' then
		local content, sender = arg1, arg2
		local isGMSender = arg6 == "GM" -- arg6 contains chat flags like "GM", "DEV", etc.
		
		-- Store GM status BEFORE playerCheck (so it's set when WIM_SetWhoInfo is called)
		if isGMSender then
			WIM_PlayerCache[sender] = WIM_PlayerCache[sender] or {}
			WIM_PlayerCache[sender].isGM = true
			WIM_PlayerCache[sender].cached = false
			WIM_PlayerCache[sender].source = nil
			WIM_PlayerCache[sender].stamp = time()
			if WIM_PlayerCacheDB and WIM_Data and WIM_Data.wimPlayerDBLookup ~= false then
				WIM_PlayerCacheDB[sender] = {
					class = WIM_PlayerCache[sender].class,
					level = WIM_PlayerCache[sender].level,
					race = WIM_PlayerCache[sender].race,
					guild = WIM_PlayerCache[sender].guild,
					isGM = true,
					stamp = WIM_PlayerCache[sender].stamp,
				}
			end
			-- Remove from WHO queue if present
			if WIM_PlayerCacheQueue[sender] then
				WIM_DebugMsg("|cffff00ff[WIM GM]|r Removing GM from WHO queue: " .. sender)
				WIM_PlayerCacheQueue[sender] = nil
			end
		end
		
		playerCheck(sender, function()
			-- Update window if GM and window exists
			if isGMSender and WIM_Windows[sender] then
				WIM_SetWhoInfo(sender)
			end
			if WIM_FilterResult(content) ~= 1 and WIM_FilterResult(content) ~= 2 then
				local nameLink = WIM_FormatPlayerLink(sender, WIM_GetAlias(sender, true), isGMSender, true)
				msg = nameLink..": "..content
				WIM_PostMessage(sender, msg, 1, sender, content)
			end
			ChatEdit_SetLastTellTarget(ChatFrameEditBox, sender)
		end)
	elseif event == 'CHAT_MSG_WHISPER_INFORM' then
		local content, receiver = arg1, arg2
		local isGMReceiver = arg6 == "GM" -- Check if receiver is GM
		
		WIM_DebugMsg("|cffff00ff[WIM GM]|r WHISPER_INFORM to: " .. receiver .. " | arg6: " .. tostring(arg6) .. " | isGM: " .. tostring(isGMReceiver))
		
		-- Store GM status BEFORE WIM_PostMessage
		if isGMReceiver then
			WIM_PlayerCache[receiver] = WIM_PlayerCache[receiver] or {}
			WIM_PlayerCache[receiver].isGM = true
			WIM_PlayerCache[receiver].cached = false
			WIM_PlayerCache[receiver].source = nil
			WIM_PlayerCache[receiver].stamp = time()
			if WIM_PlayerCacheDB and WIM_Data and WIM_Data.wimPlayerDBLookup ~= false then
				WIM_PlayerCacheDB[receiver] = {
					class = WIM_PlayerCache[receiver].class,
					level = WIM_PlayerCache[receiver].level,
					race = WIM_PlayerCache[receiver].race,
					guild = WIM_PlayerCache[receiver].guild,
					isGM = true,
					stamp = WIM_PlayerCache[receiver].stamp,
				}
			end
			WIM_DebugMsg("|cffff00ff[WIM GM]|r Set isGM=true for: " .. receiver)
			-- Remove from WHO queue if present
			if WIM_PlayerCacheQueue[receiver] then
				WIM_DebugMsg("|cffff00ff[WIM GM]|r Removing GM from WHO queue: " .. receiver)
				WIM_PlayerCacheQueue[receiver] = nil
			end
			-- Update window if it already exists
			if WIM_Windows[receiver] then
				WIM_DebugMsg("|cffff00ff[WIM GM]|r Updating existing window for GM: " .. receiver)
				WIM_SetWhoInfo(receiver)
			end
		end
		
		WIM_WhisperedTo[receiver] = true
		if WIM_FilterResult(content) ~= 1 and WIM_FilterResult(content) ~= 2 then
			local selfName = UnitName("player")
			local nameLink = WIM_FormatPlayerLink(selfName, WIM_GetAlias(selfName, true), false, true)
			msg = nameLink..": "..content
			WIM_PostMessage(receiver, msg, 2, UnitName("player"), content)
		end
	elseif(event == "CHAT_MSG_SYSTEM") then
		local tstart,tfinish = string.find(arg1, "\'(%a+)\'");
		if(tstart ~= nil and tfinish ~= nil) then
			user = string.sub(arg1, tstart+1, tfinish-1);
			user = string.gsub(user, "^%l", string.upper)
			tstart, tfinish = string.find(arg1, "playing");
			if(tstart ~= nil and WIM_Windows[user] ~= nil) then
				-- player not playing, can't whisper
				local nameLink = WIM_FormatPlayerLink(user, WIM_GetAlias(user, true), false, false)
				msg = nameLink.." is not currently playing!";
				WIM_PostMessage(user, msg, 4);
			end
		end
	end
end

function WIM_ChatFrameSupressor_OnEvent(event)
	if(WIM_Data.enableWIM == false) then
		return true;
	end
	local msg = "";
	if((event == "CHAT_MSG_AFK" or event == "CHAT_MSG_DND") and WIM_Data.showAFK) then
		if(WIM_Data.supressWisps) then
			return false; --[ false to supress from chatframe
		else
			return true;
		end	
	elseif(event == "CHAT_MSG_WHISPER") then
		if(WIM_Data.supressWisps) then
			if(WIM_FilterResult(arg1) == 1) then
				return true;
			else
				return false; --[ false to supress from chatframe
			end
		else
			if(WIM_FilterResult(arg1) == 2) then
				return false;
			else
				return true;
			end
		end
	elseif(event == "CHAT_MSG_WHISPER_INFORM") then
		if(WIM_Data.supressWisps) then
			if(WIM_FilterResult(arg1) == 1) then
				return true;
			else
				return false; --[ false to supress from chatframe
			end
		else
			if(WIM_FilterResult(arg1) == 2) then
				return false;
			else
				return true;
			end
		end
	elseif(event == "CHAT_MSG_SYSTEM") then
		local tstart,tfinish = string.find(arg1, "\'(%a+)\'");
		if(tstart ~= nil and tfinish ~= nil) then
			user = string.sub(arg1, tstart+1, tfinish-1);
			user = string.gsub(user, "^%l", string.upper)
			tstart, tfinish = string.find(arg1, "playing");
			if(tstart ~= nil and WIM_Windows[user] ~= nil) then
				-- player not playing, can't whisper
				if(WIM_Data.supressWisps) then
					return false; --[ false to supress from chatframe
				else
					return true;
				end
			end
		end
		return true;
	end
	return true;
end


function WIM_PostMessage(user, msg, ttype, from, raw_msg, hotkeyFix)
	--[[
		ttype:
			1 - Wisper from someone
			2 - Wisper sent
			3 - System Message
			4 - Error Message
			5 - Show window... Do nothing else...
	]]--
	
	local f,chatBox
	local isNew = false
	if WIM_EnsurePlayerCacheFallback then
		WIM_EnsurePlayerCacheFallback(user)
	end
	if not WIM_Windows[user] then
		if WIM_IsMergeEnabled() then
			f = WIM_GetSharedFrame()
		else
			f = WIM_GetOrCreateWindow(user)
		end
		WIM_WindowOrder = WIM_WindowOrder + 1
		WIM_Windows[user] = {
			frame = f:GetName(),
			order = WIM_WindowOrder,
			newMSG = true, 
			is_visible = false, 
			last_msg = time(),
		}
		WIM_EnsureSession(user)
		WIM_Icon_AddUser(user)
		isNew = true
		if WIM_Data.characterInfo.show then
			if table.getn(WIM_Split(user, '-')) == 2 then
				-- WIM_GetBattleWhoInfo(user)
			elseif WIM_PlayerCache[user] and WIM_PlayerCache[user].isGM then
				-- Skip WHO for GMs, just set GM info
				WIM_DebugMsg("|cffff00ff[WIM GM]|r PostMessage: Skipping WHO for GM: " .. user)
				WIM_SetWhoInfo(user)
			else
				WIM_DebugMsg("|cffff00ff[WIM GM]|r PostMessage: Sending WHO for: " .. user .. " | isGM: " .. tostring(WIM_PlayerCache[user] and WIM_PlayerCache[user].isGM))
				WIM_WhoInfo(user, function()
					-- Don't update if player became GM in the meantime
					if not (WIM_PlayerCache[user] and WIM_PlayerCache[user].isGM) then
						WIM_SetWhoInfo(user)
					end
				end) 
			end
		end
		WIM_UpdateCascadeStep()
		WIM_DisplayHistory(user)
	end

	if WIM_IsMergeEnabled() then
		f = WIM_GetSharedFrame()
	else
		f = WIM_GetOrCreateWindow(user)
		if f then
			WIM_Windows[user].frame = f:GetName()
			if not f._wimSessionLoaded then
				WIM_LoadConversation(user, f)
				f._wimSessionLoaded = true
			end
		end
	end
	chatBox = getglobal(f:GetName()..'ScrollingMessageFrame')
	msg = WIM_ConvertURLtoLinks(msg)
	WIM_Windows[user].newMSG = true
	WIM_Windows[user].last_msg = time()
	if ttype == 1 then
		WIM_PlaySoundWisp()
		WIM_AddToHistory(user, from, raw_msg, false)
		WIM_RecentListAdd(user)
		WIM_RecordMessage(user, WIM_getTimeStamp()..msg, WIM_Data.displayColors.wispIn.r, WIM_Data.displayColors.wispIn.g, WIM_Data.displayColors.wispIn.b)
	elseif ttype == 2 then
		WIM_AddToHistory(user, from, raw_msg, true)
		WIM_RecentListAdd(user)
		WIM_RecordMessage(user, WIM_getTimeStamp()..msg, WIM_Data.displayColors.wispOut.r, WIM_Data.displayColors.wispOut.g, WIM_Data.displayColors.wispOut.b)
	elseif ttype == 3 then
		WIM_RecordMessage(user, msg, WIM_Data.displayColors.sysMsg.r, WIM_Data.displayColors.sysMsg.g, WIM_Data.displayColors.sysMsg.b)
	elseif ttype == 4 then
		WIM_RecordMessage(user, msg, WIM_Data.displayColors.errorMsg.r, WIM_Data.displayColors.errorMsg.g, WIM_Data.displayColors.errorMsg.b)
	end
	local doPop = WIM_PopOrNot(isNew) or ttype == 2 or ttype == 5
	local isMerge = WIM_IsMergeEnabled()
	local isIncoming = (ttype == 1)
	local isActive = isMerge and WIM_TabBar_ActiveUser and string.upper(WIM_TabBar_ActiveUser) == string.upper(user)
	local wasHidden = isMerge and f and not f:IsVisible()
	local shouldSelect = true
	if isMerge and isIncoming and WIM_TabBar_ActiveUser and not isActive and not wasHidden then
		shouldSelect = false
	end
	if doPop then
		if ttype == 2 and WIM_Data.popOnSend == false then
			--[ do nothing, user prefers not to pop on send
		else
			if isMerge then
				if shouldSelect then
					WIM_SelectUser(user)
					WIM_Windows[user].newMSG = false
				end
				f:Show()
				if ttype ==5 then
					f:Raise()
					getglobal(f:GetName()..'MsgBox'):SetFocus()
				end
			else
				WIM_Windows[user].newMSG = false
				f:Show()
				if ttype ==5 then
					f:Raise()
					getglobal(f:GetName()..'MsgBox'):SetFocus()
				end
			end
		end
	end
	if isMerge and isActive then
		WIM_Windows[user].newMSG = false
	end
	if WIM_IsMergeEnabled() and WIM_TabBar_ActiveUser and string.upper(WIM_TabBar_ActiveUser) == string.upper(user) then
		WIM_UpdateScrollBars(chatBox)
	end
	WIM_Icon_DropDown_Update()
	if WIM_HistoryFrame:IsVisible() then
		WIM_HistoryViewNameScrollBar_Update()
		WIM_HistoryViewFiltersScrollBar_Update()
	end

	if hotkeyFix then
		local orig = getglobal(f:GetName()..'MsgBox'):GetScript('OnChar')
		getglobal(f:GetName()..'MsgBox'):SetScript('OnChar', function()
			getglobal(f:GetName()..'MsgBox'):SetText('')
			getglobal(f:GetName()..'MsgBox'):SetScript('OnChar', orig)
		end)
	end
end

function WIM_SetWindowLocation(theWin)
	local CascadeOffset_Left = 0;
	local CascadeOffset_Top = 0;

	if(WIM_Data.winCascade.enabled) then
		CascadeOffset_Left = WIM_CascadeDirection[WIM_Data.winCascade.direction].left;
		CascadeOffset_Top = WIM_CascadeDirection[WIM_Data.winCascade.direction].top;
	end
	
	theWin:SetPoint(
		"TOPLEFT",
		"UIParent",
		"BOTTOMLEFT",
		(WIM_Data.winLoc.left + WIM_CascadeStep*CascadeOffset_Left), 
		(WIM_Data.winLoc.top + WIM_CascadeStep*CascadeOffset_Top)
	);
end

function WIM_PopOrNot(isNew)
	if(isNew == true and WIM_Data.popNew == true) then
		if(WIM_Data.popCombat and UnitAffectingCombat("player")) then
			return false;
		else
			return true;
		end
	elseif(WIM_Data.popNew == true and WIM_Data.popUpdate == true) then
		if(WIM_Data.popCombat and UnitAffectingCombat("player")) then
			return false;
		else
			return true;
		end
	else
		return false;
	end
end


function WIM_UpdateScrollBars(smf)
	local parentName = smf:GetParent():GetName();
	if(smf:AtTop()) then
		getglobal(parentName.."ScrollUp"):Disable();
	else
		getglobal(parentName.."ScrollUp"):Enable();
	end
	if(smf:AtBottom()) then
		getglobal(parentName.."ScrollDown"):Disable();
	else
		getglobal(parentName.."ScrollDown"):Enable();
	end
end

function WIM_isLinkURL(link)
	if (strsub(link, 1, 3) == "url") then
		return true;
	else
		return false;
	end
end

function WIM_DisplayURL(link)
	local theLink = "";
	if (string.len(link) > 4) and (string.sub(link,1,4) == "url:") then
		theLink = string.sub(link,5, string.len(link));
	end
	--show UI to show url so it can be copied
	if(theLink) then
		WIM_urlCopyUrlBox:SetText(theLink);
		WIM_urlCopy:Show();
		WIM_urlCopyUrlBox:HighlightText(0);
	end
end

function WIM_ConvertURLtoLinks(text)
	local preLink, midLink, postLink;
	preLink = "|Hurl:";
	midLink = "|h|cff"..WIM_RGBtoHex(WIM_Data.displayColors.webAddress.r, WIM_Data.displayColors.webAddress.g, WIM_Data.displayColors.webAddress.b);
	postLink = "|h|r";
	text = string.gsub(text, "(%a+://[%w_/%.%?%%=~&-]+)", preLink.."%1"..midLink.."%1"..postLink);
	return text;
end

function WIM_SlashCommand(msg)
	if(msg == "" or msg == nil) then
		WIM_Options:Show();
	elseif(msg == "reset") then
		WIM_Data = WIM_Data_DEFAULTS;
	elseif(msg == "clear history") then
		WIM_History = {};
		WIM_PlayerCacheDB_ClearAll();
	elseif(msg == "reset filters") then
		WIM_LoadDefaultFilters();
	elseif(msg == "history") then
		WIM_HistoryFrame:Show();
	elseif(msg == "help") then
		WIM_Help:Show();
	end
end


function WIM_Icon_Move(toDegree)
	WIM_Data.iconPosition = toDegree;
	WIM_Icon_UpdatePosition();
end

function WIM_Icon_UpdatePosition()
	if(WIM_Data.showMiniMap == false) then
		WIM_IconFrame:Hide();
	else
		if(WIM_Data.miniFreeMoving.enabled == false) then
			WIM_IconFrame:SetPoint(
				"TOPLEFT",
				"Minimap",
				"TOPLEFT",
				54 - (78 * cos(WIM_Data.iconPosition)),
				(78 * sin(WIM_Data.iconPosition)) - 55
			);
		end
		WIM_IconFrame:Show();
	end
end


function WIM_SetWindowProps(theWin)
	local width, height = WIM_GetEffectiveWinSize(theWin)
	if(WIM_Data.showShortcutBar) then
		getglobal(theWin:GetName().."ShortcutFrame"):Show();
	else
		getglobal(theWin:GetName().."ShortcutFrame"):Hide();
	end
	theWin:SetHeight(height);
	theWin:SetWidth(width);
	theWin:SetScale(WIM_Data.windowSize);
	theWin:SetAlpha(WIM_Data.windowAlpha);
	getglobal(theWin:GetName().."ScrollingMessageFrame"):SetFont("Fonts\\ARIALN.TTF",WIM_Data.fontSize);
	getglobal(theWin:GetName().."ScrollingMessageFrame"):SetAlpha(1);
	getglobal(theWin:GetName().."MsgBox"):SetAlpha(1);
	getglobal(theWin:GetName().."MsgBox"):SetAltArrowKeyMode(WIM_Data.requireAltForArrows);
	getglobal(theWin:GetName().."ShortcutFrame"):SetAlpha(1);
	if(WIM_Data.useEscape) then
		WIM_AddEscapeWindow(theWin);
	else
		WIM_RemoveEscapeWindow(theWin);
	end
	--WIM_SetTabFrameProps();
	if WIM_IsMergeEnabled() then
		if theWin:GetName() == WIM_SharedFrameName then
			WIM_TabBar_AttachToWindow(theWin)
			WIM_TabBar_Update()
		end
	end
	if WIM_IsMergeEnabled() then
		if theWin:GetName() == WIM_SharedFrameName then
			WIM_ResizeHandle_Init(theWin)
			if WIM_ResizeHandle[theWin:GetName()] then
				WIM_ResizeHandle[theWin:GetName()]:Show()
			end
		elseif WIM_ResizeHandle[theWin:GetName()] then
			WIM_ResizeHandle[theWin:GetName()]:Hide()
		end
	else
		WIM_ResizeHandle_Init(theWin)
		if WIM_ResizeHandle[theWin:GetName()] then
			WIM_ResizeHandle[theWin:GetName()]:Show()
		end
	end
end


function WIM_AddEscapeWindow(theWin)
	for i=1, table.getn(UISpecialFrames) do 
		if(UISpecialFrames[i] == theWin:GetName()) then
			return;
		end
	end
	tinsert(UISpecialFrames,theWin:GetName());
end

function WIM_RemoveEscapeWindow(theWin)
	for i=1, table.getn(UISpecialFrames) do 
		if(UISpecialFrames[i] == theWin:GetName()) then
			table.remove(UISpecialFrames, i);
			return;
		end
	end
end

function WIM_SetAllWindowProps()
	if WIM_IsMergeEnabled() then
		local f = getglobal(WIM_SharedFrameName)
		if f then
			WIM_SetWindowProps(f)
		end
		return
	end
	for key in WIM_Windows do
		WIM_SetWindowProps(getglobal(WIM_Windows[key].frame));
	end
end


function WIM_Icon_ToggleDropDown()
	if(WIM_ConversationMenu:IsVisible()) then
		WIM_ConversationMenu:Hide();
	else
		WIM_ConversationMenu:ClearAllPoints();
		WIM_ConversationMenu:Show();
		WIM_ConversationMenu:SetPoint("TOPRIGHT", WIM_IconFrame, "BOTTOMLEFT", 5, 5);
	end
end

function WIM_Icon_DropDown_Update()
	
	local tList = {}
	local tListActivity = {}
	local tCount = 0
	for key in WIM_IconItems do
		table.insert(tListActivity, key)
		tCount = tCount + 1
	end
	
	--[first get a sorted list of users by most recent activity
	table.sort(tListActivity, WIM_Icon_SortByActivity)
	--[account for only the allowable amount of active users
	for i=1,table.getn(tListActivity) do
		if i <= WIM_MaxMenuCount then
			table.insert(tList, tListActivity[i])
		end
	end
	
	--Initialize Menu
	for i=1,20 do 
		getglobal("WIM_ConversationMenuTellButton"..i.."Close"):Show()
		getglobal("WIM_ConversationMenuTellButton"..i):Enable()
		getglobal("WIM_ConversationMenuTellButton"..i):Hide()
	end
	
	
	WIM_NewMessageCount = 0;
	
	if tCount == 0 then
		info = {}
		info.justifyH = "LEFT"
		info.text = "WIM_L_NONE"
		info.notClickable = 1
		info.notCheckable = 1
		getglobal("WIM_ConversationMenuTellButton1Close"):Hide()
		getglobal("WIM_ConversationMenuTellButton1"):Disable()
		getglobal("WIM_ConversationMenuTellButton1"):SetText(WIM_L_NONEC)
		getglobal("WIM_ConversationMenuTellButton1"):Show()
	else
		if WIM_Data.sortAlpha then
			table.sort(tList)
		end
		WIM_NewMessageFlag = false
		for i=1,table.getn(tList) do
			if WIM_Windows[tList[i]].newMSG and WIM_Windows[tList[i]].is_visible == false then
				WIM_IconItems[tList[i]].color = "|cff"..WIM_RGBtoHex(77/255, 135/233, 224/255)
				WIM_NewMessageFlag = true
				WIM_NewMessageCount = WIM_NewMessageCount + 1
			else
				WIM_IconItems[tList[i]].color = "|cffffffff"
			end
			getglobal("WIM_ConversationMenuTellButton"..i):SetText(WIM_IconItems[tList[i]].color..WIM_GetAlias(WIM_IconItems[tList[i]].text, true))
			getglobal("WIM_ConversationMenuTellButton"..i).theUser = WIM_IconItems[tList[i]].text
			getglobal("WIM_ConversationMenuTellButton"..i).value = WIM_IconItems[tList[i]].value
			getglobal("WIM_ConversationMenuTellButton"..i):Show()
		end
	end
	
	--Set Height of Conversation Menu depending on message count
	local ConvoMenuHeight = 60
	local CMH_Delta = 16 * (table.getn(tList)-1)
	if CMH_Delta < 0 then CMH_Delta = 0 end
	ConvoMenuHeight = ConvoMenuHeight + CMH_Delta
	WIM_ConversationMenu:SetHeight(ConvoMenuHeight)
	
	--Minimap icon
	if WIM_Data.enableWIM == true then
		if WIM_NewMessageFlag == true then
			WIM_IconFrameButton:SetNormalTexture("Interface\\AddOns\\WIM\\Images\\miniEnabled")
		else
			WIM_IconFrameButton:SetNormalTexture("Interface\\AddOns\\WIM\\Images\\miniDisabled")
		end
	else
		--show wim disabled icon
		WIM_IconFrameButton:SetNormalTexture("Interface\\AddOns\\WIM\\Images\\miniOff")
	end

	WIM_TabBar_Update()
end


function WIM_ConversationMenu_OnUpdate(elapsed)
	if this.isCounting then
		this.timeElapsed = this.timeElapsed + elapsed
		if this.timeElapsed > 1 then
			this:Hide()
			this.timeElapsed = 0
			this.isCounting = false
		end
	end
end

function WIM_Icon_AddUser(theUser)
	UIDROPDOWNMENU_INIT_MENU = "WIM_Options_DropDown"
	UIDROPDOWNMENU_OPEN_MENU = UIDROPDOWNMENU_INIT_MENU
	local info = {}
	info.text = theUser;
	info.justifyH = "LEFT"
	info.isTitle = nil
	info.notCheckable = 1
	info.value = WIM_Windows[theUser].frame
	info.func = WIM_Icon_PlayerClick
	WIM_IconItems[theUser] = info
	table.sort(WIM_IconItems)
	WIM_Icon_DropDown_Update()
end

function WIM_Icon_PlayerClick()
	local user = this.theUser
	if not user and this.value then
		local frame = getglobal(this.value)
		if frame then
			user = frame.theUser
		end
	end
	if not user then
		return
	end
	if WIM_IsMergeEnabled() then
		WIM_SelectUser(user)
		local f = WIM_GetSharedFrame()
		f:Show()
	else
		local f = WIM_GetOrCreateWindow(user)
		if f then
			f:Show()
			f:Raise()
		end
	end
	WIM_Icon_DropDown_Update()
end

function WIM_Icon_OnUpdate(elapsedTime)
	if WIM_NewMessageFlag == false then
		this.TimeSinceLastUpdate = 0
		if WIM_Icon_NewMessageFlash:IsVisible() then
			WIM_Icon_NewMessageFlash:Hide()
		end
		return
	end

	this.TimeSinceLastUpdate = this.TimeSinceLastUpdate + elapsedTime 	

	while this.TimeSinceLastUpdate > WIM_Icon_UpdateInterval do
		if WIM_Icon_NewMessageFlash:IsVisible() then
			WIM_Icon_NewMessageFlash:Hide()
		else
			WIM_Icon_NewMessageFlash:Show()
		end
		this.TimeSinceLastUpdate = this.TimeSinceLastUpdate - WIM_Icon_UpdateInterval
	end
end

function WIM_UpdateCascadeStep()
		WIM_CascadeStep = WIM_CascadeStep + 1
		if WIM_CascadeStep > 10 then
			WIM_CascadeStep = 0
		end
end

function WIM_PlaySoundWisp()
	if WIM_Data.playSoundWisp == true then
		PlaySoundFile("Interface\\AddOns\\WIM\\Sounds\\wisp.wav")
	end
end

function WIM_Icon_SortByActivity(user1, user2)
	return WIM_Windows[user1].last_msg > WIM_Windows[user2].last_msg
end

function WIM_Icon_SortByCreation(user1, user2)
	local a = WIM_Windows[user1] and WIM_Windows[user1].order or 0
	local b = WIM_Windows[user2] and WIM_Windows[user2].order or 0
	return a < b
end

function WIM_RGBtoHex(r,g,b)
	return string.format ("%.2x%.2x%.2x",r*255,g*255,b*255)
end

function WIM_Icon_OnEnter()
	GameTooltip:SetOwner(this, "ANCHOR_LEFT");
	GameTooltip:SetText("WIM v"..WIM_VERSION.."              ");
	GameTooltip:AddDoubleLine("Conversation Menu", "Left-Click", 1,1,1,1,1,1);
	GameTooltip:AddDoubleLine("Show New Messages", "Right-Click", 1,1,1,1,1,1);
	GameTooltip:AddDoubleLine("WIM Options", "/wim", 1,1,1,1,1,1);
end

function WIM_ShowNewMessages()
	for key in WIM_Windows do
		if(WIM_Windows[key].newMSG == true) then
			getglobal(WIM_Windows[key].frame):Show();
			WIM_Windows[key].newMSG = false;
		end
	end
	WIM_Icon_DropDown_Update();
end

function WIM_ShowAll()
	for key in WIM_Windows do
		getglobal(WIM_Windows[key].frame):Show();
	end
end

function WIM_HideAll()
	for key in WIM_Windows do
		getglobal(WIM_Windows[key].frame):Hide();
	end
end

function WIM_CloseAllConvos()
	for key in WIM_Windows do
		WIM_CloseConvo(key);
	end
end

function WIM_CloseConvo(theUser)
	if(WIM_Windows[theUser] == nil) then return; end; --[ fail silently
	local wasActive = WIM_IsMergeEnabled() and (WIM_TabBar_ActiveUser and string.upper(WIM_TabBar_ActiveUser) == string.upper(theUser))
	if WIM_IsMergeEnabled() then
		if wasActive then
			local f = WIM_GetSharedFrame()
			f:Hide()
			getglobal(f:GetName().."ScrollingMessageFrame"):Clear();
			getglobal(f:GetName().."ClassIcon"):SetTexture("Interface\\AddOns\\WIM\\Images\\classBLANK");
			getglobal(f:GetName().."CharacterDetails"):SetText("");
		end
	else
		local f = getglobal(WIM_Windows[theUser].frame)
		if f then
			f:Hide()
		end
	end
	WIM_Windows[theUser] = nil;
	WIM_IconItems[theUser] = nil;
	WIM_InputCache[theUser] = nil;

	if wasActive then
		WIM_TabBar_ActiveUser = nil
		local tList = WIM_TabBar_BuildList()
		if table.getn(tList) > 0 then
			WIM_SelectUser(tList[1])
			WIM_GetSharedFrame():Show()
		end
	end

	WIM_SessionMessages[theUser] = nil
	WIM_SessionHistoryLoaded[theUser] = nil

	WIM_Icon_DropDown_Update();
end

function WIM_InitClassProps()
	WIM_ClassIcons[WIM_LOCALIZED_DRUID] 	= "Interface\\AddOns\\WIM\\Images\\classDRUID";
	WIM_ClassIcons[WIM_LOCALIZED_HUNTER] 	= "Interface\\AddOns\\WIM\\Images\\classHUNTER";
	WIM_ClassIcons[WIM_LOCALIZED_MAGE]	 	= "Interface\\AddOns\\WIM\\Images\\classMAGE";
	WIM_ClassIcons[WIM_LOCALIZED_PALADIN] 	= "Interface\\AddOns\\WIM\\Images\\classPALADIN";
	WIM_ClassIcons[WIM_LOCALIZED_PRIEST] 	= "Interface\\AddOns\\WIM\\Images\\classPRIEST";
	WIM_ClassIcons[WIM_LOCALIZED_ROGUE] 	= "Interface\\AddOns\\WIM\\Images\\classROGUE";
	WIM_ClassIcons[WIM_LOCALIZED_SHAMAN] 	= "Interface\\AddOns\\WIM\\Images\\classSHAMAN";
	WIM_ClassIcons[WIM_LOCALIZED_WARLOCK] 	= "Interface\\AddOns\\WIM\\Images\\classWARLOCK";
	WIM_ClassIcons[WIM_LOCALIZED_WARRIOR] 	= "Interface\\AddOns\\WIM\\Images\\classWARRIOR";
	
	WIM_ClassColors[WIM_LOCALIZED_DRUID]	= "ff7d0a";
	WIM_ClassColors[WIM_LOCALIZED_HUNTER]	= "abd473";
	WIM_ClassColors[WIM_LOCALIZED_MAGE]		= "69ccf0";
	WIM_ClassColors[WIM_LOCALIZED_PALADIN]	= "f58cba";
	WIM_ClassColors[WIM_LOCALIZED_PRIEST]	= "ffffff";
	WIM_ClassColors[WIM_LOCALIZED_ROGUE]	= "fff569";
	WIM_ClassColors[WIM_LOCALIZED_SHAMAN]	= "0070de";
	WIM_ClassColors[WIM_LOCALIZED_WARLOCK]	= "9482ca";
	WIM_ClassColors[WIM_LOCALIZED_WARRIOR]	= "c79c6e";
end

function WIM_UserWithClassColor(theUser)
	if(WIM_PlayerCache[theUser].class == "") then
		return theUser;
	else
		if(WIM_ClassColors[WIM_PlayerCache[theUser].class]) then
			local hex = WIM_ClassColors[WIM_PlayerCache[theUser].class]
			return "|cff"..hex..WIM_GetAlias(theUser);
		else
			return WIM_GetAlias(theUser);
		end
	end
end

function WIM_GetClassColorHexRaw(name)
	local entry = WIM_PlayerCache[name]
	if not entry then
		local up = string.upper(name)
		for key in WIM_PlayerCache do
			if string.upper(key) == up then
				entry = WIM_PlayerCache[key]
				break
			end
		end
	end
	if entry and entry.class and WIM_ClassColors[entry.class] then
		return WIM_ClassColors[entry.class], entry.cached
	end
	if WIM_Data and WIM_Data.wimPlayerDBLookup ~= false then
		local _, dbEntry = WIM_FindPlayerCacheDBEntry(name)
		if dbEntry and dbEntry.class and WIM_ClassColors[dbEntry.class] then
			return WIM_ClassColors[dbEntry.class], true
		end
	end
	if string.upper(name) == string.upper(UnitName("player")) then
		local localized, class = UnitClass("player")
		if localized and WIM_ClassColors[localized] then
			return WIM_ClassColors[localized], false
		end
		if class and WIM_ClassColors[class] then
			return WIM_ClassColors[class], false
		end
	end
	return nil
end

function WIM_GetClassColorHexForName(name)
	local hex, cached = WIM_GetClassColorHexRaw(name)
	if hex and cached then
		hex = WIM_DimHexColor(hex, WIM_CacheDimFactor)
	end
	return hex
end

function WIM_FormatPlayerLink(name, displayName, isGM, bracketed, forceDim)
	local label = displayName or WIM_GetAlias(name, true)
	if isGM then
		label = "|cff00ccff<GM>|r "..WIM_GetAlias(name, true)
		if bracketed == false then
			return "|Hplayer:"..name.."|h"..label.."|h"
		end
		return "|Hplayer:"..name.."|h["..label.."]|h"
	end
	local allowColor = not (WIM_Data and WIM_Data.classColorMessages == false)
	local hex, cached = nil, nil
	if allowColor then
		hex, cached = WIM_GetClassColorHexRaw(name)
		if hex then
			if forceDim then
				hex = WIM_DimHexColor(hex, WIM_CacheDimFactor)
			end
		end
	end
	if hex then
		label = "|cff"..hex..label.."|r"
	end
	if bracketed == false then
		return "|Hplayer:"..name.."|h"..label.."|h"
	end
	return "|Hplayer:"..name.."|h["..label.."]|h"
end

function WIM_SetWhoInfo(theUser)
	if WIM_IsMergeEnabled() and WIM_TabBar_ActiveUser and string.upper(WIM_TabBar_ActiveUser) ~= string.upper(theUser) then
		WIM_TabBar_Update(false)
		return
	end
	if not WIM_Windows[theUser] then
		return
	end
	local frameName = WIM_IsMergeEnabled() and WIM_SharedFrameName or WIM_Windows[theUser].frame
	if not frameName then
		return
	end
	local classIcon = getglobal(frameName.."ClassIcon");
	if not classIcon then
		return
	end
	if WIM_EnsurePlayerCacheFallback then
		WIM_EnsurePlayerCacheFallback(theUser)
	end
	if not WIM_PlayerCache[theUser] then
		classIcon:SetTexture("Interface\\AddOns\\WIM\\Images\\classBLANK");
		local details = getglobal(frameName.."CharacterDetails")
		if details then
			details:SetText("")
		end
		if WIM_Data.characterInfo.classColor then
			getglobal(frameName.."From"):SetText(WIM_GetAlias(theUser));
		end
		if WIM_IsMergeEnabled() then
			WIM_TabBar_Update(false)
		end
		return
	end
	
	-- Check if user is a GM - show GM icon instead of class icon
	if WIM_PlayerCache[theUser] and WIM_PlayerCache[theUser].isGM then
		classIcon:SetTexture("Interface\\AddOns\\WIM\\Images\\Blizzard");
		-- Update name with GM tag if not already present
		local currentName = getglobal(frameName.."From"):GetText()
		if currentName and not string.find(currentName, "<GM>") then
			getglobal(frameName.."From"):SetText("|cff00ccff<GM>|r "..WIM_GetAlias(theUser));
		end
		-- Show GM in details instead of class info
		getglobal(frameName.."CharacterDetails"):SetText("|cff00ccffGame Master|r");
		return; -- Don't show class info for GMs
	elseif(WIM_Data.characterInfo.classIcon and WIM_PlayerCache[theUser] and WIM_ClassIcons[WIM_PlayerCache[theUser].class]) then
		classIcon:SetTexture(WIM_ClassIcons[WIM_PlayerCache[theUser].class]);
		if(WIM_Data.characterInfo.classColor) then	
			getglobal(frameName.."From"):SetText(WIM_UserWithClassColor(theUser));
		end
		if(WIM_Data.characterInfo.details) then	
			local tGuild = "";
			if(WIM_PlayerCache[theUser].guild ~= "") then
				tGuild = "<"..WIM_PlayerCache[theUser].guild.."> ";
			end
			local detailColor = "ffffff"
			if WIM_PlayerCache[theUser].cached then
				detailColor = WIM_DimHexColor(detailColor, WIM_CacheDimFactor)
			end
			getglobal(frameName.."CharacterDetails"):SetText("|cff"..detailColor..tGuild..WIM_PlayerCache[theUser].level.." "..WIM_PlayerCache[theUser].race.." "..WIM_PlayerCache[theUser].class.."|r");
		end
	else
		classIcon:SetTexture("Interface\\AddOns\\WIM\\Images\\classBLANK");
		if(WIM_Data.characterInfo.classColor and WIM_PlayerCache[theUser]) then	
			getglobal(frameName.."From"):SetText(WIM_UserWithClassColor(theUser));
		end
		if(WIM_Data.characterInfo.details and WIM_PlayerCache[theUser]) then	
			local tGuild = "";
			if(WIM_PlayerCache[theUser].guild ~= "") then
				tGuild = "<"..WIM_PlayerCache[theUser].guild.."> ";
			end
			local detailColor = "ffffff"
			if WIM_PlayerCache[theUser].cached then
				detailColor = WIM_DimHexColor(detailColor, WIM_CacheDimFactor)
			end
			getglobal(frameName.."CharacterDetails"):SetText("|cff"..detailColor..tGuild..WIM_PlayerCache[theUser].level.." "..WIM_PlayerCache[theUser].race.." "..WIM_PlayerCache[theUser].class.."|r");
		end
	end
	if WIM_IsMergeEnabled() then
		WIM_TabBar_Update(false)
	end
end

function WIM_getTimeStamp()
	if(WIM_Data.showTimeStamps) then
		return "|cff"..WIM_RGBtoHex(WIM_Data.displayColors.sysMsg.r, WIM_Data.displayColors.sysMsg.g, WIM_Data.displayColors.sysMsg.b)..date("%H:%M").."|r ";
	else
		return "";
	end
end

function WIM_Bindings_EnableWIM()
	WIM_SetWIM_Enabled(not WIM_Data.enableWIM);
end

function WIM_SetWIM_Enabled(YesOrNo)
	WIM_Data.enableWIM = YesOrNo
	WIM_Icon_DropDown_Update();
end

function WIM_LoadShortcutFrame()
	local tButtons = {
		{
			icon = "Interface\\Icons\\Ability_Hunter_AimedShot",
			cmd		= "target",
			tooltip = WIM_L_TARGET
		},
		{
			icon = "Interface\\Icons\\Spell_Holy_BlessingOfStrength",
			cmd		= "invite",
			tooltip = WIM_L_INVITE
		},
		{
			icon = "Interface\\Icons\\INV_Misc_Bag_10_Blue",
			cmd		= "trade",
			tooltip = WIM_L_TRADE
		},
		{
			icon = "Interface\\Icons\\INV_Helmet_44",
			cmd		= "inspect",
			tooltip = WIM_L_INSPECT
		},
		{
			icon = "Interface\\Icons\\Ability_Physical_Taunt",
			cmd		= "ignore",
			tooltip = WIM_L_IGNORE
		},
	};
	for i=1,5 do
		getglobal(this:GetName().."ShortcutFrameButton"..i.."Icon"):SetTexture(tButtons[i].icon);
		getglobal(this:GetName().."ShortcutFrameButton"..i).cmd = tButtons[i].cmd;
		getglobal(this:GetName().."ShortcutFrameButton"..i).tooltip = tButtons[i].tooltip;
	end
	getglobal(this:GetName().."ShortcutFrame"):SetScale(.75);
end

function WIM_ShorcutButton_Clicked()
	local cmd = this.cmd;
	local theUser = this:GetParent():GetParent().theUser;
	if(cmd == "target") then
		TargetByName(theUser, true)
	elseif(cmd == "invite") then
		InviteByName(theUser)
	elseif(cmd == "trade") then
		TargetByName(theUser, true)
		InitiateTrade("target")
	elseif(cmd == "inspect") then
		TargetByName(theUser, true)
		InspectUnit("target")
	elseif(cmd == "ignore") then
		getglobal(this:GetParent():GetParent():GetName().."IgnoreConfirm"):Show();
	end
end

function WIM_GetAlias(theUser, nameOnly)
	if(WIM_Data.enableAlias and WIM_Alias[theUser] ~= nil) then
		if(WIM_Data.aliasAsComment) then
			if(nameOnly) then
				return theUser;
			else
				return theUser.." |cffffffff- "..WIM_Alias[theUser].."|r";
			end
		else
			return WIM_Alias[theUser];
		end
	else
		return theUser;
	end
end


function WIM_FilterResult(theMSG)
	if(WIM_Data.enableFilter) then
		local key;
		for key in pairs(WIM_Filters) do
			local action = WIM_Filters[key];
			-- backward compat: table format from earlier version
			if(type(action) == "table") then
				action = action.action or "Block";
			end
			local matched = false;
			if(action == "Exact") then
				matched = (strlower(theMSG) == strlower(key));
			else
				matched = (strfind(strlower(theMSG), strlower(key)) ~= nil);
			end
			if(matched) then
				if(action == "Ignore") then
					return 1;
				elseif(action == "Block" or action == "Exact") then
					return 2;
				end
			end
		end
		return 0;
	else
		return 0;
	end
end

function WIM_CanRecordUser(theUser)
	if(WIM_Data.historySettings.recordEveryone) then
		return true;
	else
		if(WIM_Data.historySettings.recordFriends and WIM_FriendList[theUser]) then
			return true;
		elseif(WIM_Data.historySettings.recordGuild and WIM_GuildList[theUser]) then
			return true;
		end
	end
	return false;
end

function WIM_AddToHistory(theUser, userFrom, theMessage, isMsgIn)
	local tmpEntry = {};
	if(WIM_Data.enableHistory) then --[if history is enabled
		if(WIM_CanRecordUser(theUser)) then --[if record user
			if WIM_TabBar_ActiveUser and string.upper(WIM_TabBar_ActiveUser) == string.upper(theUser) then
				getglobal(WIM_SharedFrameName.."HistoryButton"):Show();
			end
			tmpEntry["stamp"] = time();
			tmpEntry["date"] = date("%m/%d/%y");
			tmpEntry["time"] = date("%H:%M");
			tmpEntry["msg"] = WIM_ConvertURLtoLinks(theMessage);
			tmpEntry["from"] = userFrom;
			-- Save GM status in history
			if WIM_PlayerCache[userFrom] and WIM_PlayerCache[userFrom].isGM then
				tmpEntry["isGM"] = true;
			end
			if(isMsgIn) then
				tmpEntry["type"] = 2;
			else
				tmpEntry["type"] = 1;
			end
			if(WIM_History[theUser] == nil) then
				WIM_History[theUser] = {};
			end
			table.insert(WIM_History[theUser], tmpEntry);
			
			if(WIM_Data.historySettings.maxMsg.enabled) then
				local tOver = table.getn(WIM_History[theUser]) - WIM_Data.historySettings.maxMsg.count;
				if(tOver > 0) then
					for i = 1, tOver do 
						table.remove(WIM_History[theUser], 1);
					end
				end
			end
			if(WIM_Options:IsVisible()) then
				WIM_HistoryScrollBar_Update();
			end
		end
	end
end

function WIM_SortHistory(a, b)
	if(a.stamp < b.stamp) then
		return true;
	else
		return false;
	end
end

function WIM_DisplayHistory(theUser)
	WIM_LoadHistoryIntoSession(theUser)
end

function WIM_LoadDefaultFilters()
	WIM_Filters = {};
	WIM_Filters["^LVBM"] 					= "Ignore";
	WIM_Filters["^YOU ARE BEING WATCHED!"] 	= "Ignore";
	WIM_Filters["^YOU ARE MARKED!"] 		= "Ignore";
	WIM_Filters["^YOU ARE CURSED!"] 		= "Ignore";
	WIM_Filters["^YOU HAVE THE PLAGUE!"] 	= "Ignore";
	WIM_Filters["^YOU ARE BURNING!"] 		= "Ignore";
	WIM_Filters["^YOU ARE THE BOMB!"] 		= "Ignore";
	WIM_Filters["VOLATILE INFECTION"] 		= "Ignore";
	WIM_Filters["^<GA"]						= "Block";
	WIM_Filters["USD"]						= "Block";
	WIM_Filters["W@W"]						= "Block";
	WIM_Filters["C@M"]						= "Block";
	WIM_Filters["G4"]						= "Block";
	WIM_Filters["G="]						= "Block";
	WIM_Filters[">>"]						= "Ignore";
	WIM_Filters[">>>"]						= "Ignore";
	WIM_Filters["OKO"]						= "Block";
	WIM_Filters["GAMES"]					= "Block";
	WIM_Filters["NOST"]						= "Ignore";
	WIM_Filters["DOLLARS"]					= "Block";
	WIM_Filters["CQM"]						= "Block";
	WIM_Filters["SERVICE"]					= "Ignore";
	WIM_Filters["CHEAP"]					= "Block";
	WIM_Filters["WWW"]						= "Block";
	WIM_Filters["1-60"]						= "Block";
--	WIM_Filters[""]						= "Ignore";
	
	WIM_FilteringScrollBar_Update();
end

function WIM_LoadGuildList()
	WIM_GuildList = {};
	if(IsInGuild()) then
		for i=1, GetNumGuildMembers(true) do 
			local name, junk = GetGuildRosterInfo(i);
			if(name) then
				WIM_GuildList[name] = "1"; --[set place holder for quick lookup
			end
		end
	end
end

function WIM_LoadFriendList()
	WIM_FriendList = {};
	for i=1, GetNumFriends() do 
		local name, junk = GetFriendInfo(i);
		if(name) then
			WIM_FriendList[name] = "1"; --[set place holder for quick lookup
		end
	end
end

function WIM_HistoryPurge()
	if(WIM_Data.historySettings.autoDelete.enabled) then
		local delCount = 0;
		local eldestTime = time() - (60 * 60 * 24 * WIM_Data.historySettings.autoDelete.days);
		for key in WIM_History do
			if(WIM_History[key][1]) then
				while(WIM_History[key][1].stamp < eldestTime) do
					table.remove(WIM_History[key], 1);
					delCount = delCount + 1;
					if(table.getn(WIM_History[key]) == 0) then
						WIM_History[key] = nil;
						WIM_PlayerCacheDB_Clear(key);
						break;
					end
				end
			end
		end
		if(delCount > 0) then
			DEFAULT_CHAT_FRAME:AddMessage("[WIM]: Purged "..delCount.." out-dated messages from history.");
		end
	end
end

function WIM_ToggleWindow_OnUpdate(elapsedTime)

	WIM_ToggleWindow_Timer = WIM_ToggleWindow_Timer + elapsedTime; 	

	while (WIM_ToggleWindow_Timer > 1) do
		WIM_ToggleWindow:Hide();
		WIM_ToggleWindow_Timer = 0;
	end
end

function WIM_RecentListAdd(theUser)
	for i=1, table.getn(WIM_RecentList) do 
		if(string.upper(WIM_RecentList[i]) == string.upper(theUser)) then
			table.remove(WIM_RecentList, i);
			break;
		end
	end
	table.insert(WIM_RecentList, 1, theUser);
end

function WIM_ToggleWindow_Toggle()
	if(table.getn(WIM_RecentList) == 0) then
		return;
	end
	
	if(WIM_RecentList[WIM_ToggleWindow_Index] == nil) then
		WIM_ToggleWindow_Index = 1;
	end
	
	WIM_ToggleWindowUser:SetText(WIM_GetAlias(WIM_RecentList[WIM_ToggleWindow_Index], true));
	WIM_ToggleWindow.theUser = WIM_RecentList[WIM_ToggleWindow_Index];
	WIM_ToggleWindowCount:SetText("Recent Conversation "..WIM_ToggleWindow_Index.." of "..table.getn(WIM_RecentList));
	if(WIM_Windows[WIM_RecentList[WIM_ToggleWindow_Index]]) then
		if(WIM_Windows[WIM_RecentList[WIM_ToggleWindow_Index]].newMSG) then
			WIM_ToggleWindowStatus:SetText("New message!");
			WIM_ToggleWindowIconNew:Show();
			WIM_ToggleWindowIconRead:Hide();
		else
			WIM_ToggleWindowStatus:SetText("No new messages.");
			WIM_ToggleWindowIconRead:Show();
			WIM_ToggleWindowIconNew:Hide();
		end
	else
		WIM_ToggleWindowStatus:SetText("Conversation closed.");
		WIM_ToggleWindowIconRead:Show();
		WIM_ToggleWindowIconNew:Hide();
	end
	WIM_ToggleWindow_Timer = 0;
	WIM_ToggleWindow:Show();
	WIM_ToggleWindow_Index = WIM_ToggleWindow_Index + 1;
end

function WIM_Split(theString, thePattern)
	local t = {n = 0}
	local fpat = "(.-)"..thePattern
	local last_end = 1
	local s,e,cap = string.find(theString, fpat, 1)
	while s ~= nil do
		if s~=1 or cap~="" then
		table.insert(t,cap)
		end
		last_end = e+1
		s,e,cap = string.find(theString, fpat, last_end)
	end
	if last_end<=string.len(theString) then
		cap = string.sub(theString,last_end)
		table.insert(t,cap)
	end
	return t
end

function WIM_SetTabFrameProps()
	WIM_TabFrame:SetScale(WIM_Data.windowSize * 1);
	WIM_TabFrame:SetAlpha(WIM_Data.windowAlpha);
end

function WIM_UpdateTabs()
	local tabs = {};
	local offset = 0;
	
	for key in WIM_IconItems do
		table.insert(tabs, key);
	end
	
	for i=1,10 do 
		local tab = getglobal("WIM_TabFrameTab"..i);
		tab:Hide();
		if(tabs[i+offset]) then
			tab:SetText(WIM_GetAlias(tabs[i+offset], true));
			tab:Show();
			tab.theUser=tabs[i+offset];
		else
			tab:Hide();
			tab.theUser="";
		end
	end
	
end

function WIM_WindowOnShow()
	if WIM_IsMergeEnabled() and this and this.theUser then
		WIM_TabBar_SetActiveUser(this.theUser)
	end
end

function WIM_GetTabByUser(theUser)
	for i=1,10 do 
		local tab = getglobal("WIM_TabFrameTab"..i);
		if(string.upper(theUser) == string.upper(tab.theUser)) then
			return tab;
		end
	end
	return nil;
end

function WIM_TabSetSelected(theUser)
	for i=1,10 do 
		local tab = getglobal("WIM_TabFrameTab"..i);
		if(string.upper(theUser) == string.upper(tab.theUser)) then
			PanelTemplates_SelectTab(tab);
		else
			PanelTemplates_DeselectTab(tab);
		end
	end
end
