WIM_ButtonsHooked = false;
WIM_TradeSkillIsHooked = false;
WIM_CraftSkillIsHooked = false;
WIM_InspectIsHooked = false;

local function WIM_GetReplyBindingKey()
	if type(GetBindingKey) ~= "function" then
		return nil
	end

	local candidates = {
		"REPLY",
		"REPLY_TELL",
		"REPLY_WHISPER",
		"REPLYWHISPER",
		"REPLYLASTWHISPER",
	}

	for i = 1, table.getn(candidates) do
		local key1 = GetBindingKey(candidates[i])
		if key1 and key1 ~= "" then
			return key1
		end
	end

	return nil
end

local function WIM_ShouldApplyReplyHotkeyFix()
	local key = WIM_GetReplyBindingKey()
	if not key or key == "" then
		return false
	end

	local mainKey = string.gsub(key, "^.+-", "")
	local printableNamedKeys = {
		MINUS = true,
		EQUALS = true,
		BACKSLASH = true,
		LEFTBRACKET = true,
		RIGHTBRACKET = true,
		SEMICOLON = true,
		APOSTROPHE = true,
		COMMA = true,
		PERIOD = true,
		SLASH = true,
		GRAVE = true,
		SPACE = true,
		NUMPADDECIMAL = true,
		NUMPADDIVIDE = true,
		NUMPADMULTIPLY = true,
		NUMPADMINUS = true,
		NUMPADPLUS = true,
	}
	if string.len(mainKey) == 1 then
		return true
	end

	if printableNamedKeys[mainKey] then
		return true
	end

	return false
end



function WIM_FriendsFrame_SendMessage()
	local name = GetFriendInfo(FriendsFrame.selectedFriend);
	WIM_PostMessage(name, "", 5, "", "");
end

function WIM_ChatEdit_ParseText(editBox, send)

	local target
	local msgText = ''

	local _, _, command, rest = strfind(editBox:GetText(), '^(/%S+)%s*(.*)')
	if command then
		command = strupper(command)
		rest = rest or ''
		local i = 1
		while true do
			if getglobal('SLASH_WHISPER'..i) and command == strupper(TEXT(getglobal('SLASH_WHISPER'..i))) and rest ~= '' then
				local _, _, namepart, textpart = strfind(rest, '^(%S+)%s*(.*)')
				if namepart then
					target = gsub(strlower(namepart), '^%l', strupper)
					msgText = textpart or ''
				end
				break
			elseif getglobal('SLASH_REPLY'..i) and command == strupper(TEXT(getglobal('SLASH_REPLY'..i))) and ChatEdit_GetLastTellTarget(editBox) ~= '' then
				target = ChatEdit_GetLastTellTarget(editBox)
				msgText = rest or ''
				break
			elseif not getglobal('SLASH_WHISPER'..i) and not getglobal('SLASH_REPLY'..i) then
				break
			end
			i = i + 1
		end
	end

	if target then
		WIM_PostMessage(target, '', 5, '', '')
		if msgText ~= '' then
			-- Message text present (e.g. /w Name text or macro):
			-- let WoW's original handler do the actual sending
			return WIM_ChatEdit_ParseText_orig(editBox, send)
		else
			-- No message text (just /w Name): open WIM window only
			editBox:SetText('')
			editBox:Hide()
		end
	else
		return WIM_ChatEdit_ParseText_orig(editBox, send)
	end
end

function WIM_ChatFrame_ReplyTell(chatFrame)
	chatFrame = chatFrame or DEFAULT_CHAT_FRAME
	local editBox = chatFrame and chatFrame.editBox or ChatFrameEditBox
	local target = editBox and ChatEdit_GetLastTellTarget(editBox) or ""
	if target ~= '' then
		local useHotkeyFix = WIM_ShouldApplyReplyHotkeyFix()
		if useHotkeyFix then
			WIM_PostMessage(target, '', 5, '', '', true)
		else
			WIM_PostMessage(target, '', 5, '', '')
		end
	elseif WIM_ChatFrame_ReplyTell_orig then
		return WIM_ChatFrame_ReplyTell_orig(chatFrame)
	end
end

function WIM_HookInspect()
	if(WIM_InspectIsHooked) then
		return;
	end
	
	if(InspectPaperDollFrame) then
		WIM_InspectPaperDollItemSlotButton_OnClick_orig = InspectPaperDollItemSlotButton_OnClick;
		InspectPaperDollItemSlotButton_OnClick = WIM_InspectPaperDollItemSlotButton_OnClick;
		WIM_InspectIsHooked = true;
	elseif(SuperInspectFrame) then
		WIM_SuperInspect_InspectPaperDollItemSlotButton_OnClick_orig = SuperInspect_InspectPaperDollItemSlotButton_OnClick;
		SuperInspect_InspectPaperDollItemSlotButton_OnClick = WIM_SuperInspect_InspectPaperDollItemSlotButton_OnClick;
		WIM_InspectIsHooked = true;
	end
	
	DEFAULT_CHAT_FRAME:AddMessage("Hooking Complete.");
end

function WIM_AtlasLootItem_OnClick(arg1)
	if ( IsShiftKeyDown() ) then
		local nameText = getglobal("AtlasLootItem_"..this:GetID().."_Name"):GetText()
		if nameText then
			local _, _, color = strfind(nameText, "(|cff%x%x%x%x%x%x)")
			color = color or NORMAL_FONT_COLOR_CODE
			local name = gsub(nameText, "|cff%x%x%x%x%x%x", "")
			name = gsub(name, "|r", "")
			local link = nil
			local idPrefix = string.sub(this.itemID, 1, 1)
			if idPrefix == "e" then
				local spellID = tonumber(string.sub(this.itemID, 2))
				if spellID then
					link = NORMAL_FONT_COLOR_CODE.."|Henchant:"..spellID.."|h["..name.."]|h|r"
				end
			elseif idPrefix == "s" then
				local spellID = tonumber(string.sub(this.itemID, 2))
				local craftItem = GetSpellInfoAtlasLootDB and GetSpellInfoAtlasLootDB["craftspells"] and GetSpellInfoAtlasLootDB["craftspells"][spellID] and GetSpellInfoAtlasLootDB["craftspells"][spellID]["craftItem"]
				if craftItem and craftItem ~= 0 and AtlasLoot_GetChatLink then
					link = AtlasLoot_GetChatLink(craftItem)
				elseif spellID then
					link = NORMAL_FONT_COLOR_CODE.."|Henchant:"..spellID.."|h["..name.."]|h|r"
				end
			else
				link = color.."|Hitem:"..this.itemID..":0:0:0|h["..name.."]|h|r"
			end
			if link then
				if WIM_EditBoxInFocus then
					WIM_EditBoxInFocus:Insert(link)
				else
					if ChatFrameEditBox and not ChatFrameEditBox:IsVisible() and ChatEdit_ActivateChat then
						ChatEdit_ActivateChat(ChatFrameEditBox)
					end
					if ChatFrameEditBox then
						ChatFrameEditBox:Insert(link)
					end
				end
			end
		end
		return
	end
	WIM_AtlasLootItem_OnClick_orig(arg1);
end

function WIM_InspectPaperDollItemSlotButton_OnClick(arg1)
	if ( IsShiftKeyDown() ) then
		if ( WIM_EditBoxInFocus ) then
			WIM_EditBoxInFocus:Insert(GetInventoryItemLink(InspectFrame.unit, this:GetID()));
		end
	end
	WIM_InspectPaperDollItemSlotButton_OnClick_orig(arg1);
end

function WIM_AllInOneInventoryFrameItemButton_OnClick(button, ignShift)
	if ( IsShiftKeyDown() ) then
		if ( WIM_EditBoxInFocus ) then
			local bag, slot = AllInOneInventory_GetIdAsBagSlot(this:GetID());
			WIM_EditBoxInFocus:Insert(GetContainerItemLink(bag, slot));
		end
	end
	WIM_AllInOneInventoryFrameItemButton_OnClick_orig(button, ignShift);
end

function WIM_LootFrameItem_OnClick(arg1)
	if ( IsShiftKeyDown() ) then
		if ( WIM_EditBoxInFocus ) then
			WIM_EditBoxInFocus:Insert(GetLootSlotLink(this.slot));
		end
	end
	WIM_LootFrameItem_OnClick_orig(arg1);
end

function WIM_SuperInspect_InspectPaperDollItemSlotButton_OnClick(button, ignoreModifiers)
	local itemLink = this.link;
	if ( IsShiftKeyDown() ) then
		if ( WIM_EditBoxInFocus ) then
			local link = "|c"..this.c.."|H"..itemLink.."|h["..GetItemInfo(itemLink).."]|h|r";
			WIM_EditBoxInFocus:Insert(link);
		end
	end
	WIM_SuperInspect_InspectPaperDollItemSlotButton_OnClick_orig(button, ignoreModifiers);
end

function WIM_HookTradeSkill()
	if(WIM_TradeSkillIsHooked == true and WIM_CraftSkillIsHooked == true) then
		return;
	end
	
	if(WIM_TradeSkillIsHooked == false and TradeSkillFrame ~= nil) then
		WIM_TradeSkillSkillIcon_OnClick_orig = TradeSkillSkillIcon:GetScript("OnClick");
		TradeSkillSkillIcon:SetScript("OnClick", function() WIM_TradeSkillSkillIcon_OnClick_orig(); WIM_TradeSkillSkillIcon_OnClick(); end);
		
		for i=1, 8 do 
			WIM_TradeSkillReagent_OnClick_orig = getglobal("TradeSkillReagent"..i):GetScript("OnClick");
			getglobal("TradeSkillReagent"..i):SetScript("OnClick", function() WIM_TradeSkillReagent_OnClick_orig(); WIM_TradeSkillReagent_OnClick(); end);
		end
		WIM_TradeSkillIsHooked = true;
	end
	
	if(WIM_CraftSkillIsHooked == false and CraftFrame ~= nil) then
		WIM_CraftIcon_OnClick_orig = CraftIcon:GetScript("OnClick");
		CraftIcon:SetScript("OnClick", function() WIM_CraftIcon_OnClick_orig(); WIM_CraftIcon_OnClick(); end);
		
		for i=1, 8 do 
			WIM_CraftReagent_OnClick_orig = getglobal("CraftReagent"..i):GetScript("OnClick");
			getglobal("CraftReagent"..i):SetScript("OnClick", function() WIM_CraftReagent_OnClick_orig(); WIM_CraftReagent_OnClick(); end);
		end
		
		WIM_CraftSkillIsHooked = true;
	end
end

function WIM_CraftIcon_OnClick(arg1)
	if ( IsShiftKeyDown() ) then
		if ( WIM_EditBoxInFocus ) then
			WIM_EditBoxInFocus:Insert(GetCraftItemLink(GetCraftSelectionIndex()));
		end
	end
end

function WIM_CraftReagent_OnClick(arg1)
	if ( IsShiftKeyDown() ) then
		if ( WIM_EditBoxInFocus ) then
			WIM_EditBoxInFocus:Insert(GetCraftReagentItemLink(GetCraftSelectionIndex(), this:GetID()));
		end
	end
end


function WIM_TradeSkillSkillIcon_OnClick(agr1)
	if ( IsShiftKeyDown() ) then
		if ( WIM_EditBoxInFocus ) then
			WIM_EditBoxInFocus:Insert(GetTradeSkillItemLink(TradeSkillFrame.selectedSkill));
		end
	end
end

function WIM_TradeSkillReagent_OnClick(arg1)
	if ( IsShiftKeyDown() ) then
		if ( WIM_EditBoxInFocus ) then
			WIM_EditBoxInFocus:Insert(GetTradeSkillReagentItemLink(TradeSkillFrame.selectedSkill, this:GetID()));
		end
	end
end


function WIM_PaperDollItemSlotButton_OnClick(arg1)
	if(arg1 == "LeftButton" and IsShiftKeyDown()) then
		if(WIM_EditBoxInFocus) then
			WIM_EditBoxInFocus:Insert(GetInventoryItemLink("player", this:GetID()));
			return;
		end
	end
	WIM_PaperDollItemSlotButton_OnClick_orig(arg1);
end

function WIM_LootLinkItemButton_OnClick(arg1)
	if(arg1 == "LeftButton" and IsShiftKeyDown()) then
		if(WIM_EditBoxInFocus) then
			WIM_EditBoxInFocus:Insert(WIM_LootLink_GetLink(this:GetText()));
		end
	end
	WIM_LootLinkItemButton_OnClick_orig(arg1);
end

-- copy of Lootlink's local function - modified
function WIM_LootLink_GetHyperlink(name)
	local itemLink = ItemLinks[name];
	DEFAULT_CHAT_FRAME:AddMessage("LootLink_GetHyperlink: "..name);
	if( itemLink and itemLink.i ) then
		-- Remove instance-specific data that we captured from the link we return
		local item = string.gsub(itemLink.i, "(%d+):(%d+):(%d+):(%d+)", "%1:0:%3:%4");
		return "item:"..item;
	end
	return nil;
end

-- copy of Lootlink's local function - modified
function WIM_LootLink_GetLink(name)
	local itemLink = ItemLinks[name];
	if( itemLink and itemLink.c and itemLink.i ) then
		local link = "|c"..itemLink.c.."|H"..WIM_LootLink_GetHyperlink(name).."|h["..name.."]|h|r";
		return link;
	end
	return nil;
end



function WIM_EngInventory_ItemButton_OnClick()
	if(arg1 == "LeftButton" and IsShiftKeyDown()) then
		if(WIM_EditBoxInFocus) then
			local bar, position, itm, bagnum, slotnum;

			if (EngInventory_buttons[this:GetName()] ~= nil) then
                bar = EngInventory_buttons[this:GetName()]["bar"];
                position = EngInventory_buttons[this:GetName()]["position"];

				bagnum = EngInventory_bar_positions[bar][position]["bagnum"];
				slotnum = EngInventory_bar_positions[bar][position]["slotnum"];

                itm = EngInventory_item_cache[bagnum][slotnum];

				if(itm) then
					WIM_EditBoxInFocus:Insert(GetContainerItemLink(itm["bagnum"], itm["slotnum"]));
				end
			end
		end
	end
	WIM_EngInventory_ItemButton_OnClick_orig(arg1, arg2);
end


function WIM_FriendsFrame_OnEvent()
    if event == 'WHO_LIST_UPDATE' then
    	WIM_LastWhoListUpdate = GetTime()

    	if WIM_WhoScanInProgress then
			local numResults = GetNumWhoResults()
			if WIM_Debug then
				local timestamp = date("%H:%M:%S")
				DEFAULT_CHAT_FRAME:AddMessage("|cff888888[" .. timestamp .. "]|r |cff00ff00[WIM WHO]|r WHO_LIST_UPDATE received, results: " .. numResults)
			end

			-- Check results against our queue
			for i=1,numResults do
				local name, guild, level, race, class, zone = GetWhoInfo(i)

				if WIM_PlayerCacheQueue[name] then
					if WIM_Debug then
						local timestamp = date("%H:%M:%S")
						DEFAULT_CHAT_FRAME:AddMessage("|cff888888[" .. timestamp .. "]|r |cff00ff00[WIM WHO]|r Found: " .. name .. " - " .. tostring(level) .. " " .. tostring(race) .. " " .. tostring(class))
					end
					local callbacks = WIM_PlayerCacheQueue[name].callbacks
					WIM_PlayerCacheQueue[name] = nil

					WIM_PlayerCache[name] = {
						class = class,
						level = level,
						race = race,
						guild = guild,
						cached = false,
						source = nil,
						stamp = time(),
					}
					if WIM_PlayerCacheDB and WIM_Data and WIM_Data.wimPlayerDBLookup ~= false then
						WIM_PlayerCacheDB[name] = {
							class = class,
							level = level,
							race = race,
							guild = guild,
							stamp = WIM_PlayerCache[name].stamp,
						}
					end

					for _, callback in callbacks do
						callback(WIM_PlayerCache[name])
					end
				end
			end

			if WIM_PlayerCacheQueueEmpty() then
				WIM_WhoScanInProgress = false
				SetWhoToUI(0)
				if WIM_Debug then
					local timestamp = date("%H:%M:%S")
					DEFAULT_CHAT_FRAME:AddMessage("|cff888888[" .. timestamp .. "]|r |cff00ff00[WIM WHO]|r Queue empty, scan complete")
				end
			end

			return -- Don't pass to original handler (prevents WHO window from opening)
		end
	end

	return WIM_FriendsFrame_OnEvent_orig(event)
end


function WIM_SetItemRef (link, text, button)
	if (WIM_isLinkURL(link)) then
		WIM_DisplayURL(link);
		return;
	end
	if (strsub(link, 1, 6) ~= "player") and ( IsShiftKeyDown() ) and ( not ChatFrameEditBox:IsVisible() ) then
		local itemName = gsub(text, ".*%[(.*)%].*", "%1");
		if(WIM_EditBoxInFocus) then
			WIM_EditBoxInFocus:Insert(text);
		end
	end
end

function WIM_ItemButton_OnClick(button, ignoreModifiers)
	if ( button == "LeftButton" ) and (not ignoreModifiers) and ( IsShiftKeyDown() ) and ( not ChatFrameEditBox:IsVisible() ) and (GameTooltipTextLeft1:GetText()) then
		if(WIM_EditBoxInFocus) then
			WIM_EditBoxInFocus:Insert(GetContainerItemLink(this:GetParent():GetID(), this:GetID()));
		end
	end
end

function WIM_WhoList_Update()
	if not WIM_WhoScanInProgress then
		return WIM_WhoList_Update_orig()
	end
end

function WIM_SetUpHooks()
	if WIM_ButtonsHooked then
		return
	end

	do
		local supress
		local orig = ChatFrameEditBox:GetScript('OnTextSet')
		ChatFrameEditBox:SetScript('OnTextSet', function()
			if not supress then
				orig()
			else
				supress = false
			end
		end)
		ChatFrameEditBox:SetScript('OnChar', function()
			if IsControlKeyDown() then -- TODO problem is ctrl-v, maybe find a better solution
				return
			end

			local text = this:GetText()
			local _, _, command, name = strfind(text, '^(/%S+)%s*(%a*)')
			if command then
				local i = 1
				while true do
					if getglobal('SLASH_WHISPER'..i) then

						if strupper(command) == strupper(TEXT(getglobal('SLASH_WHISPER'..i))) and name ~= '' then

							local function tryCompleting(candidate)
								if strsub(strupper(candidate), 1, strlen(name)) == strupper(name) then
									supress = true
									this:SetText(text..strsub(candidate, strlen(name) + 1))
									this:HighlightText(strlen(text), -1)
									return
								end
							end

							for i=1,GetNumFriends() do
								tryCompleting(GetFriendInfo(i) or '')
							end

							for i=1,GetNumGuildMembers(true) do
								tryCompleting(GetGuildRosterInfo(i) or '')
							end

							break
						end
					else
						break
					end
					i = i + 1
				end
			end
		end)
	end

	--Hook Friends Frame Send Message Button
	FriendsFrame_SendMessage = WIM_FriendsFrame_SendMessage;
	
	--Hook Chat Frame Whisper Parse
	WIM_ChatEdit_ParseText_orig = ChatEdit_ParseText
	ChatEdit_ParseText = WIM_ChatEdit_ParseText

	--Hook Chat Frame Reply
	WIM_ChatFrame_ReplyTell_orig = ChatFrame_ReplyTell
	ChatFrame_ReplyTell = WIM_ChatFrame_ReplyTell

	--Hook WhoList_Update
	WIM_WhoList_Update_orig = WhoList_Update
	WhoList_Update = WIM_WhoList_Update
		
	--Hook FriendsFrame_OnEvent
	WIM_FriendsFrame_OnEvent_orig = FriendsFrame_OnEvent;
	FriendsFrame_OnEvent = WIM_FriendsFrame_OnEvent;
	
	--Hook ChatFrame_OnEvent
	WIM_ChatFrame_OnEvent_orig = ChatFrame_OnEvent;
	ChatFrame_OnEvent = function(event) if(WIM_ChatFrameSupressor_OnEvent(event)) then WIM_ChatFrame_OnEvent_orig(event); end; end;
	
	--Hook SetItemRef
	WIM_SetItemRef_orig = SetItemRef;
	SetItemRef = function(link, text, button) if(not WIM_isLinkURL(link)) then WIM_SetItemRef_orig(link, text, button); end; WIM_SetItemRef(link, text, button); end;

	--Hook Paper Doll Button
	WIM_PaperDollItemSlotButton_OnClick_orig = PaperDollItemSlotButton_OnClick;
	PaperDollItemSlotButton_OnClick = WIM_PaperDollItemSlotButton_OnClick;
	
	--Hook Loot Frame 
	WIM_LootFrameItem_OnClick_orig = LootFrameItem_OnClick;
	LootFrameItem_OnClick = WIM_LootFrameItem_OnClick;
	
	
	--Hook ContainerFrameItemButton_OnClick
	WIM_ContainerFrameItemButton_OnClick_orig = ContainerFrameItemButton_OnClick;
	ContainerFrameItemButton_OnClick = function(button, ignoreModifiers)

			if ( button == "LeftButton" ) and (not ignoreModifiers) and ( IsShiftKeyDown() ) and ( not ChatFrameEditBox:IsVisible() ) and (GameTooltipTextLeft1:GetText()) then
				if(WIM_EditBoxInFocus) then
					WIM_EditBoxInFocus:Insert(GetContainerItemLink(this:GetParent():GetID(), this:GetID()));
					return
				end
			end

		WIM_ContainerFrameItemButton_OnClick_orig(button, ignoreModifiers); 
		-- WIM_ItemButton_OnClick(button, ignoreModifiers);

	end;

	-- Ensure AtlasLoot hook is applied even if AtlasLoot loaded before WIM
	if IsAddOnLoaded and IsAddOnLoaded("AtlasLoot") then
		if AtlasLootItem_OnClick and AtlasLootItem_OnClick ~= WIM_AtlasLootItem_OnClick then
			WIM_AtlasLootItem_OnClick_orig = AtlasLootItem_OnClick;
			AtlasLootItem_OnClick = WIM_AtlasLootItem_OnClick;
		end
	end
	
	if (AllInOneInventoryFrameItemButton_OnClick) then
		--Hook ContainerFrameItemButton_OnClick
		WIM_AllInOneInventoryFrameItemButton_OnClick_orig = AllInOneInventoryFrameItemButton_OnClick;
		AllInOneInventoryFrameItemButton_OnClick = function(button, ignoreModifiers) WIM_AllInOneInventoryFrameItemButton_OnClick_orig(button, ignoreModifiers); WIM_ItemButton_OnClick(button, ignoreModifiers); end;
	end
	
	if (EngInventory_ItemButton_OnClick) then
		--Hook ContainerFrameItemButton_OnClick
		WIM_EngInventory_ItemButton_OnClick_orig = EngInventory_ItemButton_OnClick;
		EngInventory_ItemButton_OnClick = function(button, ignoreModifiers) WIM_EngInventory_ItemButton_OnClick_orig(button, ignoreModifiers); WIM_ItemButton_OnClick(button, ignoreModifiers); end;
	end
	
	if (BrowseButton) then
		--Hook BrowseButtons
		for i=1, 8 do
			local frame = getglobal("BrowseButton"..i.."Item");
			local oldFunc = frame:GetScript("OnClick");
			frame:SetScript("OnClick", function() oldFunc(); WIM_ItemButton_OnClick(arg1); end);
		end
	end
	-- Universal Link Proxy: Redirect Shift+Click links from any source to WIM
	-- Strategy: When WIM EditBox has focus, show ChatFrameEditBox invisibly
	-- so WoW's internal Shift+Click handlers see it as visible and insert links.
	-- We intercept those links via OnTextChanged and redirect to WIM.
	local wimProxyActive = false;
	local wimProxyOrigOnTextChanged = ChatFrameEditBox:GetScript("OnTextChanged");
	local wimProxyOrigOnShow = ChatFrameEditBox:GetScript("OnShow");

	ChatFrameEditBox:SetScript("OnTextChanged", function()
		if wimProxyActive and WIM_EditBoxInFocus then
			local text = ChatFrameEditBox:GetText();
			if text and text ~= "" then
				if strfind(text, "|H") or strfind(text, "|c") then
					WIM_EditBoxInFocus:Insert(text);
					ChatFrameEditBox:SetText("");
					return;
				end
			end
		end
		if wimProxyOrigOnTextChanged then
			wimProxyOrigOnTextChanged();
		end
	end);

	-- Monitor frame to toggle ChatFrameEditBox proxy visibility
	local wimProxyMonitor = CreateFrame("Frame", "WIM_LinkProxyMonitor", UIParent);
	wimProxyMonitor.elapsed = 0;
	wimProxyMonitor:SetScript("OnUpdate", function()
		local dt = arg1 or 0;
		this.elapsed = this.elapsed + dt;
		if this.elapsed < 0.1 then return; end
		this.elapsed = 0;

		if WIM_EditBoxInFocus and not wimProxyActive then
			-- Activate proxy: make ChatFrameEditBox "visible" but non-interactive
			wimProxyActive = true;
			-- Suppress OnShow focus grab
			ChatFrameEditBox:SetScript("OnShow", function() end);
			ChatFrameEditBox:EnableMouse(false);
			ChatFrameEditBox:EnableKeyboard(false);
			ChatFrameEditBox:SetAlpha(0);
			ChatFrameEditBox:Show();
			ChatFrameEditBox:SetText("");
			-- Restore focus to WIM EditBox (in case Show() stole it)
			WIM_EditBoxInFocus:SetFocus();
		elseif not WIM_EditBoxInFocus and wimProxyActive then
			-- Deactivate proxy: restore ChatFrameEditBox to normal state
			wimProxyActive = false;
			ChatFrameEditBox:SetText("");
			ChatFrameEditBox:Hide();
			ChatFrameEditBox:EnableMouse(true);
			ChatFrameEditBox:EnableKeyboard(true);
			ChatFrameEditBox:SetAlpha(1);
			-- Restore original OnShow handler
			if wimProxyOrigOnShow then
				ChatFrameEditBox:SetScript("OnShow", wimProxyOrigOnShow);
			else
				ChatFrameEditBox:SetScript("OnShow", nil);
			end
		end
	end);

	WIM_ButtonsHooked = true;
end


function WIM_AddonDetectToHook(theAddon)
	if(theAddon == "SuperInspect_UI") then
		WIM_HookInspect();
	elseif(theAddon == "AtlasLoot") then
		WIM_AtlasLootItem_OnClick_orig = AtlasLootItem_OnClick;
		AtlasLootItem_OnClick = WIM_AtlasLootItem_OnClick;
	elseif(theAddon == "AllInOneInventory") then
		WIM_AllInOneInventoryFrameItemButton_OnClick_orig = AllInOneInventoryFrameItemButton_OnClick;
		AllInOneInventoryFrameItemButton_OnClick = WIM_AllInOneInventoryFrameItemButton_OnClick;
	elseif(theAddon == "EngInventory") then
		WIM_EngInventory_ItemButton_OnClick_orig = EngInventory_ItemButton_OnClick;
		EngInventory_ItemButton_OnClick = WIM_EngInventory_ItemButton_OnClick;
	elseif(theAddon == "LootLink") then
		WIM_LootLinkItemButton_OnClick_orig = LootLinkItemButton_OnClick;
		LootLinkItemButton_OnClick = WIM_LootLinkItemButton_OnClick;
	end
end
