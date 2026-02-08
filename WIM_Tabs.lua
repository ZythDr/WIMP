WIM_TabBar = nil;
WIM_TabBarTabs = {};
WIM_TabBar_ActiveUser = nil;
WIM_TabBarTargetWidth = 100;
WIM_TabBarScrollIndex = 1;
WIM_TabBarScrollLeft = nil;
WIM_TabBarScrollRight = nil;
WIM_TabBarScrollButtonSize = 18;
WIM_TabBarScrollButtonPad = 2;
WIM_TabBarTabSpacing = 2;
WIM_TabBarHeight = 24;
WIM_TabBarLeftInset = 7;
WIM_TabBarBackdropColor = { 21 / 255, 21 / 255, 24 / 255, 1 };
WIM_TabBarActiveBackdropColor = { 0.16, 0.16, 0.18, 1 };
WIM_TabBarBorderColor = { 139 / 255, 140 / 255, 135 / 255, 1 };
WIM_TabBarActiveBorderColor = { 1, 1, 1, 1 };
WIM_TabBarFontDelta = 1;
WIM_TabBarFlashGrayColor = { 0.45, 0.45, 0.45, 1 };
WIM_TabBarFlashDimFactor = 0.4;
WIM_TabBarFlashInterval = 1;
WIM_TabBarFlashOn = false;
WIM_TabBarFlashFrame = nil;
WIM_TabBarUnreadLeft = false;
WIM_TabBarUnreadRight = false;

function WIM_TabBar_IsEnabled()
	return WIM_Data and WIM_Data.mergeWindows;
end

function WIM_TabBar_GetClassColor(theUser)
	if not (WIM_PlayerCache and WIM_ClassColors and WIM_PlayerCache[theUser]) then
		return nil
	end
	local class = WIM_PlayerCache[theUser].class
	local hex = class and WIM_ClassColors[class]
	if not hex then
		return nil
	end
	local r = tonumber(string.sub(hex, 1, 2), 16) / 255
	local g = tonumber(string.sub(hex, 3, 4), 16) / 255
	local b = tonumber(string.sub(hex, 5, 6), 16) / 255
	return r, g, b
end

function WIM_TabBar_ApplyTabWidth(btn, width)
	btn:SetWidth(width)
	local fs = btn:GetFontString()
	if fs then
		fs:SetWidth(width - 16)
	end

	local name = btn:GetName()
	local function adjust(leftName, midName, rightName)
		local left = getglobal(name..leftName)
		local mid = getglobal(name..midName)
		local right = getglobal(name..rightName)
		if left and mid and right then
			local midWidth = width - left:GetWidth() - right:GetWidth()
			if midWidth < 1 then
				midWidth = 1
			end
			mid:SetWidth(midWidth)
		end
	end

	adjust("Left", "Middle", "Right")
	adjust("LeftHighlight", "MiddleHighlight", "RightHighlight")
	adjust("LeftDisabled", "MiddleDisabled", "RightDisabled")
	adjust("LeftDown", "MiddleDown", "RightDown")
end

function WIM_TabBar_ApplyTooltipBackdrop(btn, borderR, borderG, borderB, backR, backG, backB)
	if btn._wimTooltipBackdrop then
		btn._wimTooltipBackdrop:SetBackdropBorderColor(borderR, borderG, borderB, 1)
		if backR then
			btn._wimTooltipBackdrop:SetBackdropColor(backR, backG, backB, 1)
		else
			btn._wimTooltipBackdrop:SetBackdropColor(WIM_TabBarBackdropColor[1], WIM_TabBarBackdropColor[2], WIM_TabBarBackdropColor[3], WIM_TabBarBackdropColor[4])
		end
		return
	end
	btn._wimTooltipBackdrop = CreateFrame("Frame", nil, btn)
	btn._wimTooltipBackdrop:SetAllPoints(btn)
	btn._wimTooltipBackdrop:SetFrameLevel(btn:GetFrameLevel() - 1)
	btn._wimTooltipBackdrop:SetBackdrop({
		bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
		tile = true,
		tileSize = 16,
		edgeSize = 12,
		insets = { left = 2, right = 2, top = 2, bottom = 2 }
	})
	if backR then
		btn._wimTooltipBackdrop:SetBackdropColor(backR, backG, backB, 1)
	else
		btn._wimTooltipBackdrop:SetBackdropColor(WIM_TabBarBackdropColor[1], WIM_TabBarBackdropColor[2], WIM_TabBarBackdropColor[3], WIM_TabBarBackdropColor[4])
	end
	btn._wimTooltipBackdrop:SetBackdropBorderColor(borderR, borderG, borderB, 1)

	local name = btn:GetName()
	local texNames = {
		"Left", "Middle", "Right",
		"LeftHighlight", "MiddleHighlight", "RightHighlight",
		"LeftDisabled", "MiddleDisabled", "RightDisabled",
		"LeftDown", "MiddleDown", "RightDown",
	}
	for i=1,table.getn(texNames) do
		local tex = getglobal(name..texNames[i])
		if tex then
			tex:SetAlpha(0)
		end
	end
	local highlight = btn:GetHighlightTexture()
	if highlight then
		highlight:SetAlpha(0)
	end
end

function WIM_TabBar_ApplyFont(btn)
	if btn._wimFontApplied then
		return
	end
	local fs = btn:GetFontString()
	if not fs then
		return
	end
	local font, size, flags = fs:GetFont()
	if font and size then
		fs:SetFont(font, size + WIM_TabBarFontDelta, flags)
		btn._wimFontApplied = true
	end
end

function WIM_TabBar_Brighten(r, g, b, factor)
	r = r * factor
	g = g * factor
	b = b * factor
	if r > 1 then r = 1 end
	if g > 1 then g = 1 end
	if b > 1 then b = 1 end
	return r, g, b
end

function WIM_TabBar_Dim(r, g, b, factor)
	return r * factor, g * factor, b * factor
end

function WIM_TabBar_GetTabColors(user, isActive, isUnread)
	local cr, cg, cb = WIM_TabBar_GetClassColor(user)
	local textR, textG, textB = 1, 1, 1
	local borderR, borderG, borderB = WIM_TabBarBorderColor[1], WIM_TabBarBorderColor[2], WIM_TabBarBorderColor[3]

	if cr then
		textR, textG, textB = cr, cg, cb
	end

	if isActive then
		if cr then
			borderR, borderG, borderB = cr, cg, cb
		else
			borderR, borderG, borderB = WIM_TabBarActiveBorderColor[1], WIM_TabBarActiveBorderColor[2], WIM_TabBarActiveBorderColor[3]
		end
	end

	if (not isActive) and isUnread then
		if WIM_TabBarFlashOn then
			if cr then
				textR, textG, textB = WIM_TabBar_Dim(cr, cg, cb, WIM_TabBarFlashDimFactor)
				borderR, borderG, borderB = WIM_TabBarBorderColor[1], WIM_TabBarBorderColor[2], WIM_TabBarBorderColor[3]
			else
				textR, textG, textB = WIM_TabBarFlashGrayColor[1], WIM_TabBarFlashGrayColor[2], WIM_TabBarFlashGrayColor[3]
				borderR, borderG, borderB = WIM_TabBarFlashGrayColor[1], WIM_TabBarFlashGrayColor[2], WIM_TabBarFlashGrayColor[3]
			end
		else
			if cr then
				textR, textG, textB = cr, cg, cb
				borderR, borderG, borderB = cr, cg, cb
			end
		end
	end

	return textR, textG, textB, borderR, borderG, borderB
end

function WIM_TabBar_ApplyButtonBackdrop(btn)
	if btn._wimBackdrop then
		return
	end
	btn._wimBackdrop = CreateFrame("Frame", nil, btn)
	btn._wimBackdrop:SetAllPoints(btn)
	btn._wimBackdrop:SetFrameLevel(btn:GetFrameLevel() - 1)
	btn._wimBackdrop:SetBackdrop({
		bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
		tile = true,
		tileSize = 16,
		edgeSize = 12,
		insets = { left = 2, right = 2, top = 2, bottom = 2 }
	})
	btn._wimBackdrop:SetBackdropColor(WIM_TabBarBackdropColor[1], WIM_TabBarBackdropColor[2], WIM_TabBarBackdropColor[3], WIM_TabBarBackdropColor[4])
	btn._wimBackdrop:SetBackdropBorderColor(WIM_TabBarBorderColor[1], WIM_TabBarBorderColor[2], WIM_TabBarBorderColor[3], WIM_TabBarBorderColor[4])
end

function WIM_TabBar_Ensure()
	if not WIM_TabBar_IsEnabled() then
		if WIM_TabBar then
			WIM_TabBar:Hide()
		end
		return
	end
	if not WIM_TabBar then
		WIM_TabBar = CreateFrame("Frame", "WIM_TabBar", UIParent)
		WIM_TabBar:SetHeight(WIM_TabBarHeight)
		WIM_TabBar:SetClampedToScreen(true)
		WIM_TabBar:EnableMouseWheel(true)
		WIM_TabBar:SetScript("OnMouseWheel", WIM_TabBar_OnMouseWheel)
		WIM_TabBar:Hide()
	end

	if not WIM_TabBarFlashFrame then
		WIM_TabBarFlashFrame = CreateFrame("Frame", nil, WIM_TabBar)
		WIM_TabBarFlashFrame:Hide()
		WIM_TabBarFlashFrame.elapsed = 0
		WIM_TabBarFlashFrame:SetScript("OnUpdate", function()
			WIM_TabBarFlashFrame.elapsed = WIM_TabBarFlashFrame.elapsed + arg1
			if WIM_TabBarFlashFrame.elapsed >= WIM_TabBarFlashInterval then
				WIM_TabBarFlashFrame.elapsed = 0
				WIM_TabBarFlashOn = not WIM_TabBarFlashOn
				WIM_TabBar_Update(false)
			end
		end)
	end

	if not WIM_TabBarScrollLeft then
		WIM_TabBarScrollLeft = CreateFrame("Button", "WIM_TabBarScrollLeft", WIM_TabBar)
		WIM_TabBarScrollLeft:SetWidth(WIM_TabBarScrollButtonSize)
		WIM_TabBarScrollLeft:SetHeight(WIM_TabBarHeight)
		WIM_TabBarScrollLeft:SetPoint("BOTTOMLEFT", WIM_TabBar, "BOTTOMLEFT", 0, 0)
		WIM_TabBarScrollLeft:SetNormalTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Up")
		WIM_TabBarScrollLeft:SetPushedTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Down")
		WIM_TabBarScrollLeft:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight")
		WIM_TabBarScrollLeft:RegisterForClicks("LeftButtonUp", "RightButtonUp")
		WIM_TabBarScrollLeft:SetScript("OnClick", WIM_TabBar_ScrollButtonClick)
		WIM_TabBar_ApplyButtonBackdrop(WIM_TabBarScrollLeft)
		WIM_TabBarScrollLeft:Hide()
		WIM_TabBarScrollLeft._wimFlashOverlay = WIM_TabBarScrollLeft:CreateTexture(nil, "OVERLAY")
		WIM_TabBarScrollLeft._wimFlashOverlay:SetAllPoints()
		WIM_TabBarScrollLeft._wimFlashOverlay:SetTexture("Interface\\Buttons\\UI-Common-MouseHilight")
		WIM_TabBarScrollLeft._wimFlashOverlay:SetBlendMode("ADD")
		WIM_TabBarScrollLeft._wimFlashOverlay:SetAlpha(0)
	end

	if not WIM_TabBarScrollRight then
		WIM_TabBarScrollRight = CreateFrame("Button", "WIM_TabBarScrollRight", WIM_TabBar)
		WIM_TabBarScrollRight:SetWidth(WIM_TabBarScrollButtonSize)
		WIM_TabBarScrollRight:SetHeight(WIM_TabBarHeight)
		WIM_TabBarScrollRight:SetPoint("BOTTOMRIGHT", WIM_TabBar, "BOTTOMRIGHT", 0, 0)
		WIM_TabBarScrollRight:SetNormalTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Up")
		WIM_TabBarScrollRight:SetPushedTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Down")
		WIM_TabBarScrollRight:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight")
		WIM_TabBarScrollRight:RegisterForClicks("LeftButtonUp", "RightButtonUp")
		WIM_TabBarScrollRight:SetScript("OnClick", WIM_TabBar_ScrollButtonClick)
		WIM_TabBar_ApplyButtonBackdrop(WIM_TabBarScrollRight)
		WIM_TabBarScrollRight:Hide()
		WIM_TabBarScrollRight._wimFlashOverlay = WIM_TabBarScrollRight:CreateTexture(nil, "OVERLAY")
		WIM_TabBarScrollRight._wimFlashOverlay:SetAllPoints()
		WIM_TabBarScrollRight._wimFlashOverlay:SetTexture("Interface\\Buttons\\UI-Common-MouseHilight")
		WIM_TabBarScrollRight._wimFlashOverlay:SetBlendMode("ADD")
		WIM_TabBarScrollRight._wimFlashOverlay:SetAlpha(0)
	end
end

function WIM_TabBar_AttachToWindow(theWin)
	if not WIM_TabBar_IsEnabled() then
		if WIM_TabBar then
			WIM_TabBar:Hide()
		end
		return
	end
	if not theWin then
		return
	end
	WIM_TabBar_Ensure()
	WIM_TabBar:SetParent(theWin)
	WIM_TabBar:ClearAllPoints()
	if WIM_Data and WIM_Data.tabBarBelow then
		WIM_TabBar:SetPoint("TOPLEFT", theWin, "BOTTOMLEFT", WIM_TabBarLeftInset, 0)
		WIM_TabBar:SetPoint("TOPRIGHT", theWin, "BOTTOMRIGHT", 0, 0)
	else
		WIM_TabBar:SetPoint("BOTTOMLEFT", theWin, "TOPLEFT", WIM_TabBarLeftInset, 0)
		WIM_TabBar:SetPoint("BOTTOMRIGHT", theWin, "TOPRIGHT", 0, 0)
	end
	local w = theWin:GetWidth() - WIM_TabBarLeftInset
	if w < 1 then w = 1 end
	WIM_TabBar:SetWidth(w)
	WIM_TabBar:SetFrameStrata(theWin:GetFrameStrata())
	WIM_TabBar:SetFrameLevel(theWin:GetFrameLevel() + 5)
	WIM_TabBar:Show()
end

function WIM_TabBar_SetActiveUser(theUser)
	if not WIM_TabBar_IsEnabled() then
		if WIM_TabBar then
			WIM_TabBar:Hide()
		end
		return
	end
	if not theUser then
		return
	end
	WIM_TabBar_ActiveUser = theUser
	if WIM_IsMergeEnabled() then
		WIM_TabBar_AttachToWindow(WIM_GetSharedFrame())
	elseif WIM_Windows[theUser] then
		WIM_TabBar_AttachToWindow(getglobal(WIM_Windows[theUser].frame))
	end
	WIM_TabBar_Update(true)
end

function WIM_TabBar_BuildList()
	if not WIM_TabBar_IsEnabled() then
		return {}
	end
	local tList = {}
	local tListActivity = {}

	for key in WIM_IconItems do
		table.insert(tListActivity, key)
	end
	table.sort(tListActivity, WIM_Icon_SortByActivity)
	for i=1,table.getn(tListActivity) do
		if i <= WIM_MaxMenuCount then
			table.insert(tList, tListActivity[i])
		end
	end
	if WIM_Data.sortAlpha then
		table.sort(tList)
	end
	return tList
end

function WIM_TabBar_TabClick()
	if not this or not this.theUser then
		return
	end
	if arg1 == "RightButton" then
		WIM_CloseConvo(this.theUser)
		return
	end
	WIM_Icon_PlayerClick()
end

function WIM_TabBar_ShowConversationMenu(anchor)
	if not WIM_ConversationMenu then
		return
	end
	WIM_Icon_DropDown_Update()
	WIM_ConversationMenu:ClearAllPoints()
	WIM_ConversationMenu:Show()
	if anchor then
		WIM_ConversationMenu:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, -2)
	else
		WIM_ConversationMenu:SetPoint("TOPLEFT", WIM_TabBar, "BOTTOMLEFT", 0, -2)
	end
end

function WIM_TabBar_ScrollButtonClick()
	if arg1 == "RightButton" then
		WIM_TabBar_ShowConversationMenu(this)
		return
	end
	if this == WIM_TabBarScrollLeft then
		WIM_TabBar_SetScrollIndex(WIM_TabBarScrollIndex - 1)
	else
		WIM_TabBar_SetScrollIndex(WIM_TabBarScrollIndex + 1)
	end
end

function WIM_TabBar_OnMouseWheel()
	if not WIM_TabBar_IsEnabled() then
		return
	end
	local delta = arg1 or 0
	WIM_TabBar_SetScrollIndex(WIM_TabBarScrollIndex - delta)
end

function WIM_TabBar_SetScrollIndex(index)
	if not WIM_TabBar then
		return
	end
	if index < 1 then
		index = 1
	end
	WIM_TabBarScrollIndex = index
	WIM_TabBar_Update(false)
end

function WIM_TabBar_Update(forceActive)
	if not WIM_TabBar_IsEnabled() then
		if WIM_TabBar then
			WIM_TabBar:Hide()
		end
		if WIM_TabBarFlashFrame then
			WIM_TabBarFlashFrame:Hide()
		end
		return
	end
	if not WIM_TabBar and not next(WIM_IconItems) then
		return
	end
	WIM_TabBar_Ensure()
	local tList = WIM_TabBar_BuildList()
	if table.getn(tList) == 0 then
		WIM_TabBar:Hide()
		return
	end

	local hasUnread = false
	for i=1,table.getn(tList) do
		local user = tList[i]
		local btn = WIM_TabBarTabs[i]
		if not btn then
			btn = CreateFrame("Button", "WIM_TabBarTab"..i, WIM_TabBar, "TabButtonTemplate")
			btn:SetScript("OnClick", WIM_TabBar_TabClick)
			btn:RegisterForClicks("LeftButtonUp", "RightButtonUp")
			btn:EnableMouseWheel(true)
			btn:SetScript("OnMouseWheel", WIM_TabBar_OnMouseWheel)
			btn:SetID(i)
			btn:SetHeight(24)
			WIM_TabBarTabs[i] = btn
		end
		if btn:GetParent() ~= WIM_TabBar then
			btn:SetParent(WIM_TabBar)
		end
		btn.theUser = user
		btn.value = WIM_Windows[user] and WIM_Windows[user].frame or nil
		btn:SetText(WIM_GetAlias(user, true))
		if WIM_Windows[user] and WIM_Windows[user].newMSG and not WIM_Windows[user].is_visible then
			hasUnread = true
		end

		if WIM_TabBar_ActiveUser and string.upper(WIM_TabBar_ActiveUser) == string.upper(user) then
			PanelTemplates_SelectTab(btn)
		else
			PanelTemplates_DeselectTab(btn)
		end
		btn:Enable()
		btn:Show()
	end

	for i=table.getn(tList)+1, table.getn(WIM_TabBarTabs) do
		WIM_TabBarTabs[i]:Hide()
	end

	if hasUnread then
		if not WIM_TabBarFlashFrame:IsShown() then
			WIM_TabBarFlashOn = false
			WIM_TabBarFlashFrame:Show()
		end
	else
		if WIM_TabBarFlashFrame:IsShown() then
			WIM_TabBarFlashFrame:Hide()
		end
		if WIM_TabBarFlashOn then
			WIM_TabBarFlashOn = false
		end
	end

	local barWidth = WIM_TabBar:GetWidth() or 1
	local totalTabs = table.getn(tList)
	local leftPad = WIM_TabBarScrollButtonSize + WIM_TabBarScrollButtonPad
	local rightPad = WIM_TabBarScrollButtonSize + WIM_TabBarScrollButtonPad
	local availableWidth = barWidth - leftPad - rightPad
	if availableWidth < 1 then
		availableWidth = 1
	end
	local maxVisible = math.floor(availableWidth / WIM_TabBarTargetWidth)
	if maxVisible < 1 then
		maxVisible = 1
	end
	local showButtons = totalTabs > maxVisible
	local perWidth = math.floor((availableWidth - (maxVisible - 1) * WIM_TabBarTabSpacing) / maxVisible)
	if perWidth < 1 then
		perWidth = 1
	end

	local maxStart = totalTabs - maxVisible + 1
	if maxStart < 1 then
		maxStart = 1
	end
	if WIM_TabBarScrollIndex > maxStart then
		WIM_TabBarScrollIndex = maxStart
	end

	if showButtons then
		WIM_TabBarScrollLeft:Show()
		WIM_TabBarScrollRight:Show()
		if WIM_TabBarScrollIndex <= 1 then
			WIM_TabBarScrollLeft:Disable()
			WIM_TabBarScrollLeft:SetAlpha(0.4)
		else
			WIM_TabBarScrollLeft:Enable()
			WIM_TabBarScrollLeft:SetAlpha(1)
		end
		if WIM_TabBarScrollIndex >= maxStart then
			WIM_TabBarScrollRight:Disable()
			WIM_TabBarScrollRight:SetAlpha(0.4)
		else
			WIM_TabBarScrollRight:Enable()
			WIM_TabBarScrollRight:SetAlpha(1)
		end
	else
		WIM_TabBarScrollLeft:Hide()
		WIM_TabBarScrollRight:Hide()
	end

	if forceActive and WIM_TabBar_ActiveUser then
		local activeIndex = nil
		for i=1,totalTabs do
			if string.upper(tList[i]) == string.upper(WIM_TabBar_ActiveUser) then
				activeIndex = i
				break
			end
		end
		if activeIndex then
			if activeIndex < WIM_TabBarScrollIndex then
				WIM_TabBarScrollIndex = activeIndex
			elseif activeIndex > (WIM_TabBarScrollIndex + maxVisible - 1) then
				WIM_TabBarScrollIndex = activeIndex - maxVisible + 1
			end
		end
	end

	for i=1,totalTabs do
		if WIM_TabBarTabs[i] then
			WIM_TabBarTabs[i]:Hide()
		end
	end

	local prevBtn = nil
	local unreadLeft = false
	local unreadRight = false
	for i=WIM_TabBarScrollIndex, math.min(totalTabs, WIM_TabBarScrollIndex + maxVisible - 1) do
		local btn = WIM_TabBarTabs[i]
		if btn then
			btn:ClearAllPoints()
			if not prevBtn then
				btn:SetPoint("BOTTOMLEFT", WIM_TabBar, "BOTTOMLEFT", leftPad, 0)
			else
				btn:SetPoint("LEFT", prevBtn, "RIGHT", WIM_TabBarTabSpacing, 0)
			end
			local isActive = WIM_TabBar_ActiveUser and string.upper(WIM_TabBar_ActiveUser) == string.upper(btn.theUser)
			local isUnread = WIM_Windows[btn.theUser] and WIM_Windows[btn.theUser].newMSG and not WIM_Windows[btn.theUser].is_visible
			local tr, tg, tb, br, bg, bb = WIM_TabBar_GetTabColors(btn.theUser, isActive, isUnread)
			WIM_TabBar_ApplyFont(btn)
			if isActive then
				WIM_TabBar_ApplyTooltipBackdrop(btn, br, bg, bb, WIM_TabBarActiveBackdropColor[1], WIM_TabBarActiveBackdropColor[2], WIM_TabBarActiveBackdropColor[3])
			else
				WIM_TabBar_ApplyTooltipBackdrop(btn, br, bg, bb)
			end
			btn:GetFontString():SetTextColor(tr, tg, tb)
			WIM_TabBar_ApplyTabWidth(btn, perWidth)
			btn:Show()
			prevBtn = btn
		end
	end

	if showButtons then
		if WIM_TabBarScrollIndex > 1 then
			for i=1, WIM_TabBarScrollIndex - 1 do
				local user = tList[i]
				if WIM_Windows[user] and WIM_Windows[user].newMSG and not WIM_Windows[user].is_visible then
					unreadLeft = true
					break
				end
			end
		end
		if WIM_TabBarScrollIndex + maxVisible - 1 < totalTabs then
			for i=WIM_TabBarScrollIndex + maxVisible, totalTabs do
				local user = tList[i]
				if WIM_Windows[user] and WIM_Windows[user].newMSG and not WIM_Windows[user].is_visible then
					unreadRight = true
					break
				end
			end
		end
		if WIM_TabBarScrollLeft._wimFlashOverlay then
			if WIM_TabBarScrollLeft._wimPfUIArrowSkinned then
				WIM_TabBarScrollLeft._wimFlashOverlay:SetAlpha(0)
			elseif unreadLeft and not WIM_TabBarFlashOn then
				WIM_TabBarScrollLeft._wimFlashOverlay:SetAlpha(0.8)
			else
				WIM_TabBarScrollLeft._wimFlashOverlay:SetAlpha(0)
			end
		end
		if WIM_TabBarScrollRight._wimFlashOverlay then
			if WIM_TabBarScrollRight._wimPfUIArrowSkinned then
				WIM_TabBarScrollRight._wimFlashOverlay:SetAlpha(0)
			elseif unreadRight and not WIM_TabBarFlashOn then
				WIM_TabBarScrollRight._wimFlashOverlay:SetAlpha(0.8)
			else
				WIM_TabBarScrollRight._wimFlashOverlay:SetAlpha(0)
			end
		end
		WIM_TabBarUnreadLeft = unreadLeft
		WIM_TabBarUnreadRight = unreadRight
	else
		WIM_TabBarUnreadLeft = false
		WIM_TabBarUnreadRight = false
	end
end
