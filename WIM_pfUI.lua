WIM_pfUI = {
  initialized = false,
  defaultInset = nil,
}

local function WIM_pfUI_IsEnabled()
  if not (pfUI and pfUI_config and pfUI_config.thirdparty and pfUI_config.thirdparty.wim) then
    return false
  end
  local flag = pfUI_config.thirdparty.wim.enable
  return flag == "1" or flag == 1 or flag == true
end

function WIM_pfUI_IsIntegrationEnabled()
  return WIM_pfUI_IsEnabled()
end

function WIM_pfUI_CanUsePlayerDBLookup()
  if not WIM_pfUI_IsEnabled() then
    return false
  end
  return type(pfUI_playerDB) == "table"
end

local function WIM_pfUI_FindPlayerDBEntry(name)
  if not (name and pfUI_playerDB) then
    return nil
  end

  local entry = pfUI_playerDB[name]
  if entry then
    return entry
  end

  local lname = string.lower(name)
  for key, data in pfUI_playerDB do
    if key and string.lower(key) == lname then
      return data
    end
  end
  return nil
end

local function WIM_pfUI_LocalizeClass(className)
  if not className or className == "" then
    return ""
  end

  local token = string.upper(className)
  local localized = _G["WIM_LOCALIZED_" .. token]
  return localized or className
end

function WIM_pfUI_EnsurePlayerCache(name)
  if not (name and WIM_PlayerCache) then
    return nil
  end
  if WIM_PlayerCache[name] then
    return WIM_PlayerCache[name]
  end
  if not (WIM_Data and WIM_Data.pfuiPlayerDBLookup ~= false) then
    return nil
  end
  if not WIM_pfUI_CanUsePlayerDBLookup() then
    return nil
  end

  local entry = WIM_pfUI_FindPlayerDBEntry(name)
  if not entry then
    return nil
  end

  local class = WIM_pfUI_LocalizeClass(entry.class)
  local level = entry.level or ""
  local guild = entry.guild or ""
  local race = entry.race or ""
  if class == "" and guild == "" and race == "" and level == "" then
    return nil
  end

  WIM_PlayerCache[name] = {
    class = class,
    level = level,
    race = race,
    guild = guild,
    cached = true,
    source = "pfui",
    stamp = time(),
  }

  return WIM_PlayerCache[name]
end

local function WIM_pfUI_GetColorFromString(colorstr, fr, fg, fb, fa)
  if pfUI and pfUI.api and pfUI.api.GetStringColor and colorstr then
    local r, g, b, a = pfUI.api.GetStringColor(colorstr)
    if r and g and b then
      return r, g, b, a or fa or 1
    end
  end
  return fr or 0, fg or 0, fb or 0, fa or 1
end

local function WIM_pfUI_ApplyClassColors()
  if not (WIM_ClassColors and RAID_CLASS_COLORS) then
    return
  end

  for class, color in pairs(RAID_CLASS_COLORS) do
    local localized = _G["WIM_LOCALIZED_" .. class]
    if localized and color then
      WIM_ClassColors[localized] = WIM_RGBtoHex(color.r, color.g, color.b)
    end
  end
end

local function WIM_pfUI_ApplyFontFace(theWin)
  if not (theWin and pfUI and pfUI.font_default) then
    return
  end

  local name = theWin:GetName()
  if not name then
    return
  end

  local msgFrame = _G[name .. "ScrollingMessageFrame"]
  if msgFrame and msgFrame.GetFont and msgFrame.SetFont then
    local _, size, flags = msgFrame:GetFont()
    msgFrame:SetFont(pfUI.font_default, size or WIM_Data.fontSize, flags)
  end

  local msgBox = _G[name .. "MsgBox"]
  if msgBox and msgBox.GetFont and msgBox.SetFont then
    local _, size, flags = msgBox:GetFont()
    msgBox:SetFont(pfUI.font_default, size or 14, flags)
  end
end

local function WIM_pfUI_ApplyTabBarTheme()
  if not WIM_TabBar then
    return
  end

  local br, bg, bb, ba = WIM_pfUI_GetColorFromString(
    pfUI_config.appearance and pfUI_config.appearance.border and pfUI_config.appearance.border.background,
    0.08, 0.08, 0.1, 1
  )
  local er, eg, eb, ea = WIM_pfUI_GetColorFromString(
    pfUI_config.appearance and pfUI_config.appearance.border and pfUI_config.appearance.border.color,
    0.55, 0.55, 0.55, 1
  )

  WIM_TabBarBackdropColor[1] = br
  WIM_TabBarBackdropColor[2] = bg
  WIM_TabBarBackdropColor[3] = bb
  WIM_TabBarBackdropColor[4] = ba or 1

  WIM_TabBarBorderColor[1] = er
  WIM_TabBarBorderColor[2] = eg
  WIM_TabBarBorderColor[3] = eb
  WIM_TabBarBorderColor[4] = ea or 1

  WIM_TabBarActiveBackdropColor[1] = math.min(br + 0.05, 1)
  WIM_TabBarActiveBackdropColor[2] = math.min(bg + 0.05, 1)
  WIM_TabBarActiveBackdropColor[3] = math.min(bb + 0.05, 1)
  WIM_TabBarActiveBackdropColor[4] = ba or 1

  WIM_TabBarActiveBorderColor[1] = math.min(er + 0.2, 1)
  WIM_TabBarActiveBorderColor[2] = math.min(eg + 0.2, 1)
  WIM_TabBarActiveBorderColor[3] = math.min(eb + 0.2, 1)
  WIM_TabBarActiveBorderColor[4] = ea or 1

  -- Keep the tab bar frame itself transparent/unstyled.
  if WIM_TabBar.backdrop then
    WIM_TabBar.backdrop:Hide()
  end
end

local function WIM_pfUI_ApplyTabElementSkin()
  if not (WIM_TabBar and pfUI and pfUI.api and pfUI.api.CreateBackdrop) then
    return
  end

  local unreadLeft = WIM_TabBarUnreadLeft or false
  local unreadRight = WIM_TabBarUnreadRight or false

  local function StripLegacyButtonArt(btn)
    if not btn then
      return
    end

    if btn._wimBackdrop then
      btn._wimBackdrop:Hide()
    end

    if btn._wimTooltipBackdrop then
      btn._wimTooltipBackdrop:Hide()
    end

    btn:SetNormalTexture(nil)
    btn:SetPushedTexture(nil)
    btn:SetHighlightTexture(nil)
    btn:SetDisabledTexture(nil)
  end

  local function SkinTabButton(btn)
    if not btn then
      return
    end

    if btn._wimTooltipBackdrop then
      btn._wimTooltipBackdrop:Hide()
    end

    if not btn._wimPfUISkinned then
      local name = btn:GetName()
      local texNames = {
        "Left", "Middle", "Right",
        "LeftHighlight", "MiddleHighlight", "RightHighlight",
        "LeftDisabled", "MiddleDisabled", "RightDisabled",
        "LeftDown", "MiddleDown", "RightDown",
      }

      for i = 1, table.getn(texNames) do
        local tex = name and _G[name .. texNames[i]]
        if tex then tex:SetAlpha(0) end
      end

      local hl = btn:GetHighlightTexture()
      if hl then hl:SetAlpha(0) end

      pfUI.api.CreateBackdrop(btn, nil, nil, tonumber(pfUI_config.chat and pfUI_config.chat.global and pfUI_config.chat.global.alpha) or .8)
      btn._wimPfUISkinned = true
    end
  end

  local function ApplyTabStateVisual(btn)
    if not (btn and btn.theUser and WIM_TabBar_GetTabColors) then
      return
    end

    local isActive = WIM_TabBar_ActiveUser and string.upper(WIM_TabBar_ActiveUser) == string.upper(btn.theUser)
    local isUnread = WIM_Windows and WIM_Windows[btn.theUser] and WIM_Windows[btn.theUser].newMSG and not WIM_Windows[btn.theUser].is_visible
    local tr, tg, tb, br, bg, bb = WIM_TabBar_GetTabColors(btn.theUser, isActive, isUnread)

    local fs = btn:GetFontString()
    if fs then
      -- Keep pfUI tabs in sync with WIM tab class-color logic.
      fs:SetTextColor(tr, tg, tb)
    end

    if btn.backdrop then
      if isActive then
        btn.backdrop:SetBackdropColor(
          WIM_TabBarActiveBackdropColor[1],
          WIM_TabBarActiveBackdropColor[2],
          WIM_TabBarActiveBackdropColor[3],
          WIM_TabBarActiveBackdropColor[4] or 1
        )
      else
        btn.backdrop:SetBackdropColor(
          WIM_TabBarBackdropColor[1],
          WIM_TabBarBackdropColor[2],
          WIM_TabBarBackdropColor[3],
          WIM_TabBarBackdropColor[4] or 1
        )
      end

      btn.backdrop:SetBackdropBorderColor(br, bg, bb, WIM_TabBarBorderColor[4] or 1)
    end
  end

  local function GetArrowBackdropTarget(btn)
    if not btn then
      return nil
    end
    if btn.backdrop and btn.backdrop.SetBackdropColor and btn.backdrop.SetBackdropBorderColor then
      return btn.backdrop
    end
    if btn.SetBackdropColor and btn.SetBackdropBorderColor then
      return btn
    end
    return nil
  end

  local function ApplyArrowFlashStyle(btn, unread)
    if not btn then
      return
    end

    local target = GetArrowBackdropTarget(btn)
    if target then
      target:SetBackdropColor(
        WIM_TabBarBackdropColor[1],
        WIM_TabBarBackdropColor[2],
        WIM_TabBarBackdropColor[3],
        WIM_TabBarBackdropColor[4] or 1
      )
    end

    if unread then
      if WIM_TabBarFlashOn then
        if target then
          target:SetBackdropBorderColor(
            WIM_TabBarBorderColor[1],
            WIM_TabBarBorderColor[2],
            WIM_TabBarBorderColor[3],
            WIM_TabBarBorderColor[4] or 1
          )
        end
        btn:SetAlpha(0.75)
        if btn.icon then btn.icon:SetAlpha(0.45) end
      else
        if target then
          target:SetBackdropBorderColor(0.90, 0.90, 0.90, WIM_TabBarActiveBorderColor[4] or 1)
        end
        btn:SetAlpha(1)
        if btn.icon then btn.icon:SetAlpha(0.95) end
      end
    else
      if target then
        target:SetBackdropBorderColor(
          WIM_TabBarBorderColor[1],
          WIM_TabBarBorderColor[2],
          WIM_TabBarBorderColor[3],
          WIM_TabBarBorderColor[4] or 1
        )
      end
      if btn:IsEnabled() then
        btn:SetAlpha(1)
        if btn.icon then btn.icon:SetAlpha(0.8) end
      else
        btn:SetAlpha(0.4)
        if btn.icon then btn.icon:SetAlpha(0.35) end
      end
    end
  end

  if pfUI.api.SkinArrowButton then
    if WIM_TabBarScrollLeft then
      StripLegacyButtonArt(WIM_TabBarScrollLeft)
      if not WIM_TabBarScrollLeft._wimPfUIArrowSkinned then
        pfUI.api.SkinArrowButton(WIM_TabBarScrollLeft, "left")
        WIM_TabBarScrollLeft._wimPfUIArrowSkinned = true
      end
      if WIM_TabBarScrollLeft._wimFlashOverlay then
        WIM_TabBarScrollLeft._wimFlashOverlay:SetAlpha(0)
      end
      ApplyArrowFlashStyle(WIM_TabBarScrollLeft, unreadLeft)
      WIM_TabBarScrollLeft:SetWidth(WIM_TabBarScrollButtonSize or 18)
      WIM_TabBarScrollLeft:SetHeight(WIM_TabBarHeight or 24)
    end

    if WIM_TabBarScrollRight then
      StripLegacyButtonArt(WIM_TabBarScrollRight)
      if not WIM_TabBarScrollRight._wimPfUIArrowSkinned then
        pfUI.api.SkinArrowButton(WIM_TabBarScrollRight, "right")
        WIM_TabBarScrollRight._wimPfUIArrowSkinned = true
      end
      if WIM_TabBarScrollRight._wimFlashOverlay then
        WIM_TabBarScrollRight._wimFlashOverlay:SetAlpha(0)
      end
      ApplyArrowFlashStyle(WIM_TabBarScrollRight, unreadRight)
      WIM_TabBarScrollRight:SetWidth(WIM_TabBarScrollButtonSize or 18)
      WIM_TabBarScrollRight:SetHeight(WIM_TabBarHeight or 24)
    end
  end

  if WIM_TabBarTabs then
    for i = 1, table.getn(WIM_TabBarTabs) do
      local btn = WIM_TabBarTabs[i]
      SkinTabButton(btn)
      ApplyTabStateVisual(btn)
    end
  end
end

local function WIM_pfUI_ApplyBarOffset()
  if not WIM_TabBar then
    return
  end

  local parent = WIM_TabBar:GetParent()
  if not parent then
    return
  end

  local inset = WIM_TabBarLeftInset or 0
  -- pfUI mode: raise the bar a bit to keep a clear gap from the window.
  local y = 2

  WIM_TabBar:ClearAllPoints()
  if WIM_Data and WIM_Data.tabBarBelow then
    WIM_TabBar:SetPoint("TOPLEFT", parent, "BOTTOMLEFT", inset, -y)
    WIM_TabBar:SetPoint("TOPRIGHT", parent, "BOTTOMRIGHT", 0, -y)
  else
    WIM_TabBar:SetPoint("BOTTOMLEFT", parent, "TOPLEFT", inset, y)
    WIM_TabBar:SetPoint("BOTTOMRIGHT", parent, "TOPRIGHT", 0, y)
  end
end

local function WIM_pfUI_SetInset(enabled)
  if WIM_pfUI.defaultInset == nil and WIM_TabBarLeftInset ~= nil then
    WIM_pfUI.defaultInset = WIM_TabBarLeftInset
  end

  if WIM_TabBarLeftInset == nil then
    return
  end

  if enabled then
    WIM_TabBarLeftInset = 0
  elseif WIM_pfUI.defaultInset ~= nil then
    WIM_TabBarLeftInset = WIM_pfUI.defaultInset
  end
end

local function WIM_pfUI_ReattachTabBar()
  if not WIM_TabBar_AttachToWindow then
    return
  end

  if WIM_IsMergeEnabled and WIM_IsMergeEnabled() then
    local f = WIM_SharedFrameName and _G[WIM_SharedFrameName]
    if f then WIM_TabBar_AttachToWindow(f) end
  elseif WIM_TabBar_ActiveUser and WIM_Windows and WIM_Windows[WIM_TabBar_ActiveUser] then
    local frameName = WIM_Windows[WIM_TabBar_ActiveUser].frame
    local f = frameName and _G[frameName]
    if f then WIM_TabBar_AttachToWindow(f) end
  end
end

local function WIM_pfUI_Refresh()
  local enabled = WIM_pfUI_IsEnabled()
  WIM_pfUI_SetInset(enabled)

  if not enabled then
    WIM_pfUI_ReattachTabBar()
    return
  end

  WIM_pfUI_ApplyClassColors()

  if WIM_TabBar_Ensure then
    WIM_TabBar_Ensure()
  end
  WIM_pfUI_ReattachTabBar()
  WIM_pfUI_ApplyBarOffset()
  WIM_pfUI_ApplyTabBarTheme()
  WIM_pfUI_ApplyTabElementSkin()

  if WIM_IsMergeEnabled and WIM_IsMergeEnabled() and WIM_GetSharedFrame then
    local f = WIM_GetSharedFrame()
    if f then
      WIM_pfUI_ApplyFontFace(f)
    end
  end
end

local function WIM_pfUI_Init()
  if WIM_pfUI.initialized then
    return
  end
  WIM_pfUI.initialized = true

  hooksecurefunc("WIM_InitClassProps", function()
    if WIM_pfUI_IsEnabled() then
      WIM_pfUI_ApplyClassColors()
    end
  end)

  hooksecurefunc("WIM_SetWindowProps", function(theWin)
    if WIM_pfUI_IsEnabled() then
      WIM_pfUI_ApplyFontFace(theWin)
    end
  end)

  if WIM_TabBar_Ensure then
    hooksecurefunc("WIM_TabBar_Ensure", function()
      if WIM_pfUI_IsEnabled() then
        WIM_pfUI_ApplyTabBarTheme()
      end
    end)
  end

  if WIM_TabBar_Update then
    hooksecurefunc("WIM_TabBar_Update", function()
      if WIM_pfUI_IsEnabled() then
        WIM_pfUI_ApplyTabBarTheme()
        WIM_pfUI_ApplyTabElementSkin()
      end
    end)
  end

  if WIM_TabBar_AttachToWindow then
    hooksecurefunc("WIM_TabBar_AttachToWindow", function()
      if WIM_pfUI_IsEnabled() then
        WIM_pfUI_ApplyBarOffset()
        WIM_pfUI_ApplyTabElementSkin()
      end
    end)
  end

  WIM_pfUI_Refresh()
end

local f = CreateFrame("Frame")
f:RegisterEvent("ADDON_LOADED")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:SetScript("OnEvent", function()
  if event == "ADDON_LOADED" then
    if arg1 == "pfUI" or arg1 == "WIM" then
      WIM_pfUI_Init()
      WIM_pfUI_Refresh()
    end
  elseif event == "PLAYER_ENTERING_WORLD" then
    WIM_pfUI_Init()
    WIM_pfUI_Refresh()
  end
end)
