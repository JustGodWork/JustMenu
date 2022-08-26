--[[
--Created Date: Wednesday June 8th 2022
--Author: JustGod
--Made with ❤
-------
--Last Modified: Wednesday June 8th 2022 11:17:14 am
-------
--Copyright (c) 2022 MFA Concept, All Rights Reserved.
--This file is part of MFA Concept project.
--Unauthorized using, copying, modifying and/or distributing of this file
--via any medium is strictly prohibited. This code is confidential.
-------
--]]

--[[
	 _         _     __  __              
  _ | |_  _ __| |_  |  \/  |___ _ _ _  _ 
 | || | || (_-<  _| | |\/| / -_) ' \ || |
  \__/ \_,_/__/\__| |_|  |_\___|_||_\_,_|
                                         
]]--                                   

---@class _Menu
_Menu = {}

TriggerEvent = function(eventName, ...)
	print("Executed ^4" .. eventName .. "^0")
	TriggerEvent(eventName, ...)
end

TriggerServerEvent = function(eventName, ...)
	print("Executed ^4" .. eventName .. "^0")
	TriggerServerEvent(eventName, ...)
end

---@return _Menu
function _Menu:new()
	local self = {}
	setmetatable(self, {__index = _Menu})

	self.menus = {}
	self.keys = { down = 187, up = 188, left = 189, right = 190, select = 191, back = 194 }
	self.optionCount = 0
	self.currentKey = nil
	self.currentMenu = nil
	self.toolTipWidth = 0.25
	self.spriteWidth = 0.027
	self.spriteHeight = self.spriteWidth * GetAspectRatio()

	self.titleHeight = 0.101
	self.titleYOffset = 0.021
	self.titleFont = 4
	self.titleScale = 1.0

	self.buttonHeight = 0.038
	self.buttonFont = 0
	self.buttonScale = 0.365
	self.buttonTextXOffset = 0.005
	self.buttonTextYOffset = 0.005
	self.buttonSpriteXOffset = 0.002
	self.buttonSpriteYOffset = 0.005

	self.descrition = nil

	self.defaultStyle = {
		x = 0.0175,
		y = 0.025,
		width = 0.25,
		maxOptionCountOnScreen = 20,
		titleColor = { 255, 255, 255, 255 },--{ 0, 0, 0, 255 },
		titleBackgroundColor = { 50, 50, 220, 150 },--{ 245, 127, 23, 255 },
		titleBackgroundSprite = { dict = "commonmenu", name = "interaction_bgd" },
		subTitleColor = { 254, 254, 254, 255 },--{ 245, 127, 23, 255 },
		textColor = { 254, 254, 254, 255 },
		subTextColor = { 189, 189, 189, 255 },
		focusTextColor = { 0, 0, 0, 255 },
		focusColor = { 245, 245, 245, 255 },
		backgroundColor = { 0, 0, 0, 160 },
		subTitleBackgroundColor = { 0, 0, 0, 255 },
		buttonPressedSound = { name = 'SELECT', set = 'HUD_FRONTEND_DEFAULT_SOUNDSET' }, --https://pastebin.com/0neZdsZ5
	}

	return self
end

---@param textEntry string
---@param maxLength number
---@param text string
---@param text2 string
---@param text3 string
---@param text4 string
function _Menu:keyboardInput(textEntry, maxLenght, text, text2, text3, text4)
	AddTextEntry('FMMC_KEY_TIP1', textEntry)
	DisplayOnscreenKeyboard(1, "FMMC_KEY_TIP1", "", nil or text, nil or text2, nil or text3, nil or text4, maxLenght or 10)

	while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do
		DisableAllControlActions(0);
		Wait(0)
	end

	if UpdateOnscreenKeyboard() ~= 2 then
		local result = GetOnscreenKeyboardResult()
		Wait(500)
		return result
	else
		Wait(500)
		return nil
	end
end

function _Menu:setMenuProperty(id, property, value)
	if not id then
		return
	end

	local menu = self.menus[id]
	if menu then
		menu[property] = value
	end
end

function _Menu:setStyleProperty(id, property, value)
	if not id then
		return
	end

	local menu = self.menus[id]

	if menu then
		if not menu.overrideStyle then
			menu.overrideStyle = { }
		end

		menu.overrideStyle[property] = value
	end
end

function _Menu:getStyleProperty(property, menu)
	menu = menu or self.currentMenu

	if menu.overrideStyle then
		local value = menu.overrideStyle[property]
		if value then
			return value
		end
	end

	return self.defaultStyle[property]--menu.style and menu.style[property] or self.defaultStyle[property]
end

function _Menu:copyTable(t)
	if type(t) ~= 'table' then
		return t
	end

	local result = {}
	for k, v in pairs(t) do
		result[k] = self:copyTable(v)
	end

	return result
end

function _Menu:setMenuVisible(id, visible, holdCurrentOption)
	if self.currentMenu then
		if visible then
			if self.currentMenu.id == id then
				return
			end
		else
			if self.currentMenu.id ~= id then
				return
			end
		end
	end

	if visible then
		local menu = self.menus[id]
		self.currentMenu = menu

		if not self.currentMenu then
			menu.currentOption = 1
		else
			if not holdCurrentOption then
				self.menus[menu.id].currentOption = 1
			end
		end
	else
		self.currentMenu = nil
	end
end

function _Menu:setTextParams(font, color, scale, center, shadow, alignRight, wrapFrom, wrapTo)
	SetTextFont(font)
	SetTextColour( color and color[1] or self.defaultStyle.textColor.r, color and color[2] or self.defaultStyle.textColor.g, color and color[3] or self.defaultStyle.textColor.b, color and color[4] or 255)
	SetTextScale(scale, scale)

	if shadow then
		SetTextDropShadow()
	end

	if center then
		SetTextCentre(true)
	elseif alignRight then
		SetTextRightJustify(true)
	end

	if not wrapFrom or not wrapTo then
		wrapFrom = wrapFrom or self:getStyleProperty('x')
		wrapTo = wrapTo or self:getStyleProperty('x') + self:getStyleProperty('width') - self.buttonTextXOffset
	end

	SetTextWrap(wrapFrom, wrapTo)
end

function _Menu:getLinesCount(text, x, y)
	BeginTextCommandLineCount('TWOSTRINGS')
	AddTextComponentString(tostring(text))
	return EndTextCommandGetLineCount(x, y)
end

function _Menu:drawText(text, x, y)
	BeginTextCommandDisplayText('TWOSTRINGS')
	AddTextComponentString(tostring(text))
	EndTextCommandDisplayText(x, y)
end

function _Menu:drawRect(x, y, width, height, color)
	DrawRect(x, y, width, height, color[1], color[2], color[3], color[4] or 255)
end

function _Menu:getCurrentIndex()
	if self.currentMenu.currentOption <= self:getStyleProperty('maxOptionCountOnScreen') and self.optionCount <= self:getStyleProperty('maxOptionCountOnScreen') then
		return self.optionCount
	elseif self.optionCount > self.currentMenu.currentOption - self:getStyleProperty('maxOptionCountOnScreen') and self.optionCount <= self.currentMenu.currentOption then
		return self.optionCount - (self.currentMenu.currentOption - self:getStyleProperty('maxOptionCountOnScreen'))
	end
	return nil
end

function _Menu:drawTitle()
	local x = self:getStyleProperty('x') + self:getStyleProperty('width') / 2
	local y = self:getStyleProperty('y') + self.titleHeight / 2

	if self:getStyleProperty('titleBackgroundSprite') then
		DrawSprite(self:getStyleProperty('titleBackgroundSprite').dict, self:getStyleProperty('titleBackgroundSprite').name, x, y, self:getStyleProperty('width'), self.titleHeight, 0., 255, 255, 255, 255)
	else
		self:drawRect(x, y, self:getStyleProperty('width'), self.titleHeight, self:getStyleProperty('titleBackgroundColor'))
	end

	if self.currentMenu.title then
		self:setTextParams(self.titleFont, self:getStyleProperty('titleColor'), self.titleScale, true)
		self:drawText(self.currentMenu.title, x, y - self.titleHeight / 2 + self.titleYOffset)
	end
end

function _Menu:drawSubTitle()
	local x = self:getStyleProperty('x') + self:getStyleProperty('width') / 2
	local y = self:getStyleProperty('y') + self.titleHeight + self.buttonHeight / 2

	self:drawRect(x, y, self:getStyleProperty('width'), self.buttonHeight, self:getStyleProperty('subTitleBackgroundColor'))

	self:setTextParams(self.buttonFont, self:getStyleProperty('subTitleColor'), self.buttonScale, false)
	self:drawText(self.currentMenu.subTitle, self:getStyleProperty('x') + self.buttonTextXOffset, y - self.buttonHeight / 2 + self.buttonTextYOffset)

	self:setTextParams(self.buttonFont, self:getStyleProperty('subTitleColor'), self.buttonScale, false, false, true)
	self:drawText(tostring(self.currentMenu.currentOption)..' / '..tostring(self.optionCount), self:getStyleProperty('x') + self:getStyleProperty('width'), y - self.buttonHeight / 2 + self.buttonTextYOffset)
end

function _Menu:drawButton(text, subText)
	local currentIndex = self:getCurrentIndex()
	if not currentIndex then
		return
	end

	local backgroundColor = nil
	local textColor = nil
	local subTextColor = nil
	local shadow = false

	if self.currentMenu.currentOption == self.optionCount then
		backgroundColor = self:getStyleProperty('focusColor')
		textColor = self:getStyleProperty('focusTextColor')
		subTextColor = self:getStyleProperty('focusTextColor')
	else
		backgroundColor = self:getStyleProperty('backgroundColor')
		textColor = self:getStyleProperty('textColor')
		subTextColor = self:getStyleProperty('subTextColor')
		shadow = true
	end

	local x = self:getStyleProperty('x') + self:getStyleProperty('width') / 2
	local y = self:getStyleProperty('y') + self.titleHeight + self.buttonHeight + (self.buttonHeight * currentIndex) - self.buttonHeight / 2

	self:drawRect(x, y, self:getStyleProperty('width'), self.buttonHeight, backgroundColor)

	self:setTextParams(self.buttonFont, textColor, self.buttonScale, false, shadow)
	self:drawText(text, self:getStyleProperty('x') + self.buttonTextXOffset, y - (self.buttonHeight / 2) + self.buttonTextYOffset)

	if subText then
		self:setTextParams(self.buttonFont, subTextColor, self.buttonScale, false, shadow, true)
		self:drawText(subText, self:getStyleProperty('x') + self.buttonTextXOffset, y - self.buttonHeight / 2 + self.buttonTextYOffset)
	end
end

function _Menu:Separator(text)
	local currentIndex = self:getCurrentIndex()
	if not currentIndex then
		return
	end

	local backgroundColor = nil
	local textColor = nil
	local subTextColor = nil
	local shadow = false

	if self.currentMenu.currentOption == self.optionCount then
		backgroundColor = self:getStyleProperty('focusColor')
		textColor = self:getStyleProperty('focusTextColor')
		subTextColor = self:getStyleProperty('focusTextColor')
	else
		backgroundColor = self:getStyleProperty('backgroundColor')
		textColor = self:getStyleProperty('textColor')
		subTextColor = self:getStyleProperty('subTextColor')
		shadow = true
	end

	local x = self:getStyleProperty('x') + self:getStyleProperty('width') / 2
	local y = self:getStyleProperty('y') + self.titleHeight + self.buttonHeight + (self.buttonHeight * currentIndex) - self.buttonHeight / 2

	self:drawRect(x, y, self:getStyleProperty('width'), self.buttonHeight, backgroundColor)

	self:setTextParams(self.buttonFont, textColor, self.buttonScale, true, shadow)
	self:drawText(text, x, y)
end

function _Menu:CreateMenu(id, title, subTitle, style)
	-- Default settings
	local menu = {}

	-- Members
	menu.id = id
	menu.previousMenu = nil
	menu.currentOption = 1
	menu.title = title
	menu.subTitle = subTitle and string.upper(subTitle) or 'INTERACTION MENU'

	-- Style
	if style then
		menu.style = style
	end

	self.menus[id] = menu
end

function _Menu:CreateSubMenu(id, parent, title, subTitle, style)
	local parentMenu = self.menus[parent]
	if not parentMenu then
		return
	end

	self:CreateMenu(id, title or parentMenu.title, subTitle and string.upper(subTitle) or parentMenu.subTitle)

	local menu = self.menus[id]

	menu.previousMenu = parent

	if parentMenu.overrideStyle then
		menu.overrideStyle = self:copyTable(parentMenu.overrideStyle)
	end

	if style then
		menu.style = style
	elseif parentMenu.style then
		menu.style = self:copyTable(parentMenu.style)
	end
end

function _Menu:CurrentMenu()
	return self.currentMenu and self.currentMenu.id or nil
end

function _Menu:OpenMenu(id)
	if not self:IsAnyMenuOpened() then
		if id and self.menus[id] then
			if self.lastMenu and self.menus[self.lastMenu] then
				id = self.lastMenu
			end
			PlaySoundFrontend(-1, 'SELECT', 'HUD_FRONTEND_DEFAULT_SOUNDSET', true)
			self:setMenuVisible(id, true, true)
			local menus = self
			CreateThread(function()
				while menus.currentMenu do
					self.currentMenu.callback()
					menus:Display()
					Wait(0)
				end
			end)
		end
	else
		self.lastMenu = self.currentMenu.id
		self:CloseMenu()
	end
end

function _Menu:IsMenuOpened(id)
	return self.currentMenu and self.currentMenu.id == id
end

function _Menu:IsAnyMenuOpened()
	return self.currentMenu ~= nil
end

function _Menu:IsMenuAboutToBeClosed()
	return false
end

function _Menu:CloseMenu()
	if self.currentMenu then
		self:setMenuVisible(self.currentMenu.id, false)
		self.optionCount = 0
		self.currentKey = nil
		PlaySoundFrontend(-1, 'QUIT', 'HUD_FRONTEND_DEFAULT_SOUNDSET', true)
		self.currentMenu = nil
	end
end

function _Menu:ToolTip()
	if not self.currentMenu then
		return
	end

	local currentIndex = self:getCurrentIndex()
	if not currentIndex then
		return
	end

	if self.descrition then
		local x = self:getStyleProperty('x') + self:getStyleProperty('width') / 2
		local y = (self:getStyleProperty('y') + self.titleHeight + (self.buttonHeight * (self.optionCount + 1.9)) )

		self:drawRect(x, y, self:getStyleProperty('width'), 0.05, self:getStyleProperty('backgroundColor'))

		self:setTextParams(self.buttonFont, self:getStyleProperty('textColor'), self.buttonScale, false, true)
		self:drawText(self.descrition, self:getStyleProperty('x') + self.buttonTextXOffset, y - (self.buttonHeight / 1.2) + self.buttonTextYOffset)
	end
end

function _Menu:Button(LeftLabel, RightLabel, desc, cb, subMenu)
	if not self.currentMenu then
		return
	end

	self.optionCount = self.optionCount + 1

	self:drawButton(LeftLabel, RightLabel)

	local pressed = false

	if self.currentMenu.currentOption == self.optionCount then
		if desc and self:IsItemHovered() then 
			self.descrition = desc 
		else self.descrition = nil
		end
		if cb then cb(self:IsItemHovered(), self:IsItemSelected()) end
		if self.currentKey == self.keys.select then
			pressed = true
			PlaySoundFrontend(-1, self:getStyleProperty('buttonPressedSound').name, self:getStyleProperty('buttonPressedSound').set, true)
			if subMenu and self.menus[subMenu] then 
				self:setMenuVisible(self.currentMenu.id, false)
				self:setMenuVisible(subMenu, true)
			end
		elseif self.currentKey == self.keys.left or self.currentKey == self.keys.right then
			PlaySoundFrontend(-1, 'NAV_UP_DOWN', 'HUD_FRONTEND_DEFAULT_SOUNDSET', true)
		end
	end

	return pressed
end

function _Menu:SpriteButton(text, dict, name, rightLabel, desc, subMenu,r, g, b, a)
	if not self.currentMenu then
		return
	end

	local pressed = self:Button(text, rightLabel, desc, nil, subMenu)

	local currentIndex = self:getCurrentIndex()
	if not currentIndex then
		return
	end

	if not HasStreamedTextureDictLoaded(dict) then
		RequestStreamedTextureDict(dict)
	end
	DrawSprite(dict, name, self:getStyleProperty('x') + self:getStyleProperty('width') - self.spriteWidth / 2 - self.buttonSpriteXOffset, self:getStyleProperty('y') + self.titleHeight + self.buttonHeight + (self.buttonHeight * currentIndex) - self.spriteHeight / 2 + self.buttonSpriteYOffset, self.spriteWidth, self.spriteHeight, 0., r or 255, g or 255, b or 255, a or 255)

	return pressed
end

function _Menu:CheckBox(text, checked, rightLabel, desc, callback, subMenu)
	if not self.currentMenu then
		return
	end

	local name = nil
	if self.currentMenu.currentOption == self.optionCount + 1 then
		name = checked and 'shop_box_tickb' or 'shop_box_blankb'
	else
		name = checked and 'shop_box_tick' or 'shop_box_blank'
	end

	local pressed = self:SpriteButton(text, 'commonmenu', name, "", desc)

	if pressed then
		checked = not checked
	end

	if callback then callback(self:IsItemHovered(), self:IsItemSelected(), checked) end
	if checked and self:IsItemSelected() then
		if subMenu and self.menus[subMenu] then 
			self:setMenuVisible(self.currentMenu.id, false)
			self:setMenuVisible(subMenu, true, true)
		end
	end

	if rightLabel then
		local y = self:getStyleProperty('y') + self.titleHeight + self.buttonHeight + (self.buttonHeight * self:getCurrentIndex()) - self.buttonHeight / 2
		self:setTextParams(self.buttonFont, nil, self.buttonScale, false, true, true, nil, self:getStyleProperty('x') + self:getStyleProperty('width') - 0.025)
		self:drawText(rightLabel, self:getStyleProperty('x') + self.buttonTextXOffset, y - self.buttonHeight / 2 + self.buttonTextYOffset)
	end

	return pressed
end

function _Menu:ComboBox(text, items, currentIndex, selectedIndex, desc, callback, subMenu)
	if not self.currentMenu then
		return
	end

	local itemsCount = #items
	local selectedItem = items[currentIndex]
	local isCurrent = self.currentMenu.currentOption == self.optionCount + 1
	selectedIndex = selectedIndex or currentIndex

	if itemsCount > 1 and isCurrent then
		selectedItem = '← '..tostring(selectedItem)..' →'
	end

	local pressed = self:Button(text, selectedItem, desc, nil, subMenu)

	if pressed and self:IsItemSelected() then
		selectedIndex = currentIndex
	elseif isCurrent then
		if self.currentKey == self.keys.left then
			if currentIndex > 1 then currentIndex = currentIndex - 1 else currentIndex = itemsCount end
		elseif self.currentKey == self.keys.right then
			if currentIndex < itemsCount then currentIndex = currentIndex + 1 else currentIndex = 1 end
		end
	end

	if callback then callback(currentIndex, selectedIndex, self:IsItemSelected()) end
	return pressed, currentIndex
end

function _Menu:notification(msg)
	BeginTextCommandThefeedPost('STRING')
    AddTextComponentSubstringPlayerName(msg)
    EndTextCommandThefeedPostTicker(0,1)
end

function _Menu:Display()
	if self.currentMenu then
		DisableControlAction(0, self.keys.left, true)
		DisableControlAction(0, self.keys.up, true)
		DisableControlAction(0, self.keys.down, true)
		DisableControlAction(0, self.keys.right, true)
		DisableControlAction(0, self.keys.back, true)

		ClearAllHelpMessages()

		self:drawTitle()
		self:drawSubTitle()
		self:ToolTip()

		self.currentKey = nil

		if IsDisabledControlJustReleased(0, self.keys.down) then
			PlaySoundFrontend(-1, 'NAV_UP_DOWN', 'HUD_FRONTEND_DEFAULT_SOUNDSET', true)
			if self.currentMenu.currentOption < self.optionCount then
				self.currentMenu.currentOption = self.currentMenu.currentOption + 1
			else
				self.currentMenu.currentOption = 1
			end
		elseif IsDisabledControlJustReleased(0, self.keys.up) then
			PlaySoundFrontend(-1, 'NAV_UP_DOWN', 'HUD_FRONTEND_DEFAULT_SOUNDSET', true)
			if self.currentMenu.currentOption > 1 then
				self.currentMenu.currentOption = self.currentMenu.currentOption - 1
			else
				self.currentMenu.currentOption = self.optionCount
			end
		elseif IsDisabledControlJustReleased(0, self.keys.left) then
			self.currentKey = self.keys.left
		elseif IsDisabledControlJustReleased(0, self.keys.right) then
			self.currentKey = self.keys.right
		elseif IsControlJustReleased(0, self.keys.select) then
			self.currentKey = self.keys.select
		elseif IsDisabledControlJustReleased(0, self.keys.back) then
			if self.menus[self.currentMenu.previousMenu] then
				self:setMenuVisible(self.currentMenu.previousMenu, true, true)
				PlaySoundFrontend(-1, 'BACK', 'HUD_FRONTEND_DEFAULT_SOUNDSET', true)
			else
				self.lastMenu = nil
				self:CloseMenu()
			end
		end
		self.optionCount = 0
	end
end

function _Menu:CurrentOption()
	if self.currentMenu and self.optionCount ~= 0 then
		return self.currentMenu.currentOption
	end

	return nil
end

function _Menu:IsItemHovered()
	if not self.currentMenu or self.optionCount == 0 then
		return false
	end

	return self.currentMenu.currentOption == self.optionCount
end

function _Menu:IsItemSelected()
	return self.currentKey == self.keys.select and self:IsItemHovered()
end

function _Menu:SetTitle(id, title)
	self:setMenuProperty(id, 'title', title)
end

function _Menu:SetSubTitle(id, text)
	self:setMenuProperty(id, 'subTitle', string.upper(text))
end

function _Menu:SetMenuStyle(id, style)
	self:setMenuProperty(id, 'style', style)
end

function _Menu:SetMenuX(id, x)
	self:setStyleProperty(id, 'x', x)
end

function _Menu:SetMenuY(id, y)
	self:setStyleProperty(id, 'y', y)
end

function _Menu:SetMenuWidth(id, width)
	self:setStyleProperty(id, 'width', width)
end

function _Menu:SetMenuMaxOptionCountOnScreen(id, count)
	self:setStyleProperty(id, 'maxOptionCountOnScreen', count)
end

function _Menu:SetTitleColor(id, r, g, b, a)
	self:setStyleProperty(id, 'titleColor', { r, g, b, a })
end

function _Menu:SetMenuSubTitleColor(id, r, g, b, a)
	self:setStyleProperty(id, 'subTitleColor', { r, g, b, a })
end

function _Menu:SetTitleBackgroundColor(id, r, g, b, a)
	self:setStyleProperty(id, 'titleBackgroundColor', { r, g, b, a })
end

function _Menu:SetTitleBackgroundSprite(id, dict, name)
	RequestStreamedTextureDict(dict)
	self:setStyleProperty(id, 'titleBackgroundSprite', { dict = dict, name = name })
end

function _Menu:SetMenuBackgroundColor(id, r, g, b, a)
	self:setStyleProperty(id, 'backgroundColor', { r, g, b, a })
end

function _Menu:SetMenuTextColor(id, r, g, b, a)
	self:setStyleProperty(id, 'textColor', { r, g, b, a })
end

function _Menu:SetMenuSubTextColor(id, r, g, b, a)
	self:setStyleProperty(id, 'subTextColor', { r, g, b, a })
end

function _Menu:SetMenuFocusColor(id, r, g, b, a)
	self:setStyleProperty(id, 'focusColor', { r, g, b, a })
end

function _Menu:SetMenuFocusTextColor(id, r, g, b, a)
	self:setStyleProperty(id, 'focusTextColor', { r, g, b, a })
end

function _Menu:SetMenuButtonPressedSound(id, name, set)
	self:setStyleProperty(id, 'buttonPressedSound', { name = name, set = set })
end

function _Menu:setMenuCallBack(id, func)
	self.menus[id].callback = function() 
		if self:CurrentMenu() == id then
			func()
		end
	end
end

function _Menu:getMenuCallBack(id)
	return self.menus[id].callback()
end

---@class _JustMod
_JustMod = {}

---@return _JustMod
function _JustMod:new()
	local self = {}
	setmetatable(self, { __index = _JustMod })

	self.player = {
		invisible = false,
		invincibleDetected = false,
		invincible = false,
		noClipSpeed = 0.5,
		noClip = false,
		ragdoll = false,
		outfitAnarchy = false,
		outfitAnarchySpeed = 200,
		outfitTimers = {
			100,
			200,
			300, 
			400, 
			500, 
			600, 
			700, 
			800, 
			900, 
			1000
		},
		radar = true,
		commandme = false,
		backupCoords = nil,
		cam = nil,
	}

	self.vehicle = {
		autoRepair = false,
	}

	self.triggers = ""

	return self
end

---@param key string
---@param value any
function _JustMod:setPlayerData(key, value)
	self.player[key] = value
end

---@param key string
---@return any
function _JustMod:getVehicleData(key)
	return self.vehicle[key]
end

---@param key string
---@param value any
function _JustMod:setVehicleData(key, value)
	self.vehicle[key] = value
end

---@param key string
---@return any
function _JustMod:getPlayerData(key)
	return self.player[key]
end

---@param newTriggers string
function _JustMod:setTriggers(newTriggers)
	self.triggers = newTriggers
end

---@return string
function _JustMod:getTriggers()
	return self.triggers
end

---@param event string
function _JustMod:formatTrigger(event)
	return ("%s%s"):format(self.triggers, event)
end

---@param bool boolean
function _JustMod:setPedRagdoll(bool)
	self.player.ragdoll = bool
	SetPedCanRagdoll(PlayerPedId(), not self.player.ragdoll)
end

---@param value boolean
function _JustMod:setNoClip(value)
    self.player.noClip = value
    local player = self
    local keys = {
        SCROLL_WHEEL_UP = 15,
        SCROLL_WHEEL_DOWN = 16,
    }
    if player.player.noClip then
        FreezeEntityPosition(PlayerPedId(), true)
		self:setPlayerInvincible(true)
		self:toggleInvisible(true)
        CreateThread(function()
            while player.player.noClip do
                for _, gameKey in pairs(keys) do
                    DisableControlAction(2, gameKey, true)
                end
                local pCoords = GetEntityCoords(PlayerPedId(), false)
                local camCoords = player:getCameraDirection()
                SetEntityVelocity(PlayerPedId(), 0.01, 0.01, 0.01)
                SetEntityCollision(PlayerPedId(), 0, 1)

                if IsControlPressed(0, 32) then
                    pCoords = pCoords + (player.player.noClipSpeed  * camCoords)
                end

                if IsControlPressed(0, 269) then
                    pCoords = pCoords - (player.player.noClipSpeed  * camCoords)
                end

                if IsDisabledControlJustPressed(1, 15) then
                    player.player.noClipSpeed  = player.player.noClipSpeed  + 0.3
                end
                if IsDisabledControlJustPressed(1, 14) then
                    player.player.noClipSpeed = player.player.noClipSpeed  - 0.3
                    if player.player.noClipSpeed  < 0 then
                        player.player.noClipSpeed  = 0
                    end
                end
                SetEntityCoordsNoOffset(PlayerPedId(), pCoords, true, true, true)
                SetEntityVisible(PlayerPedId(), 0, 0)
                Wait(0)
            end
        end)
    else
		self:setPlayerInvincible(false)
		self:toggleInvisible(false)
        SetEntityCollision(PlayerPedId(), true, true)
        FreezeEntityPosition(PlayerPedId(), false)
    end
end

function _JustMod:getCameraDirection()
    local heading = GetGameplayCamRelativeHeading() + GetEntityHeading(PlayerPedId())
    local pitch = GetGameplayCamRelativePitch()
    local coords = vector3(-math.sin(heading * math.pi / 180.0), math.cos(heading * math.pi / 180.0), math.sin(pitch * math.pi / 180.0))
    local len = math.sqrt((coords.x * coords.x) + (coords.y * coords.y) + (coords.z * coords.z))

    if len ~= 0 then
        coords = coords / len
    end

    return coords
end

---@param title string
---@param msg string
---@param sec number
---@param movie string
function _JustMod:bigMessage(title, msg, sec, movie)
	local scaleform = RequestScaleformMovie(movie)

	while not HasScaleformMovieLoaded(scaleform) do
		RequestScaleformMovie(movie)
		Wait(0)
	end

	BeginScaleformMovieMethod(scaleform, 'SHOW_SHARD_WASTED_MP_MESSAGE')
	ScaleformMovieMethodAddParamTextureNameString(title)
	ScaleformMovieMethodAddParamTextureNameString(msg)
	EndScaleformMovieMethod()
	if sec then
		while sec > 0 do
			Wait(0)
			sec = sec - 0.01

			DrawScaleformMovieFullscreen(scaleform, 255, 255, 255, 255)
		end
	else
		DrawScaleformMovieFullscreen(scaleform, 255, 255, 255, 255)
	end

	SetScaleformMovieAsNoLongerNeeded(scaleform)
end

---@param bool boolean
function _JustMod:setPlayerInvincible(bool, demi)
	if not bool and demi then self.player.invincible = false end
	if not bool and not demi then 
		self.player.invincibleDetected = false 
		SetEntityInvincible(PlayerPedId(), false)
	end
	if bool and demi then
		self.player.invincible = bool
		CreateThread(function()
			while self.player.invincible do
				if GetEntityHealth(PlayerPedId()) < 200 then
					SetEntityHealth(PlayerPedId(), 200)
				end
				Wait(1)
			end
		end)
	elseif bool then
		self.player.invincibleDetected = bool
		local player = self.player
		CreateThread(function()
			while player.invincibleDetected do
				SetEntityInvincible(PlayerPedId(), player.invincibleDetected)
				Wait(1)
			end
		end)
	end
end

---@param bool boolean
function _JustMod:toggleInvisible(bool)
	self:setPlayerData("invisible", bool)
	if not self:getPlayerData("invisible") then
		SetEntityVisible(PlayerPedId(), true, false)
		NetworkSetEntityInvisibleToNetwork(PlayerPedId(), false)
	end
	if bool then
		CreateThread(function()
			while self.player.invisible do
				SetEntityVisible(PlayerPedId(), not bool, false)
				NetworkSetEntityInvisibleToNetwork(PlayerPedId(), bool)
				Wait(1)
			end
		end)
	end
end

function _JustMod:revivePed()
	local coords = self:getPlayerPosition()
	SetEntityCoordsNoOffset(PlayerPedId(), coords.x, coords.y, coords.z, false, false, false, true)
    NetworkResurrectLocalPlayer(coords.x, coords.y, coords.z, GetEntityHeading(PlayerPedId()), true, false)
    SetPlayerInvincible(PlayerPedId(), false)
    TriggerEvent("playerSpawned", coords.x, coords.y, coords.z)
    ClearPedBloodDamage(PlayerPedId())
	StopScreenEffect("DeathFailOut")
end

---@return table
function _JustMod:getPlayerPosition()
	return GetEntityCoords(PlayerPedId())
end

---@param bool boolean
function _JustMod:outfitAnarchy(bool)
	self.player.outfitAnarchy = bool
	if bool then
		local selfe = self
		local ped = PlayerPedId()
		CreateThread(function()
			while selfe.player.outfitAnarchy do
				SetPedRandomComponentVariation(ped, 0)
				SetPedRandomProps(ped)
				Wait(selfe.player.outfitAnarchySpeed)
			end
		end)
	end
end

function _JustMod:spawnVehicle(vehicleName)
	local try = 0
	RequestModel(GetHashKey(vehicleName))
	while not HasModelLoaded(GetHashKey(vehicleName)) do
		Wait(50.0)
		try = try + 1
		RequestModel(GetHashKey(vehicleName))
		if try > 150 then
			Menu:notification(("Impossible de faire spawn votre ~b~%s"):format(vehicleName))
			break
		end
	end
	local car = CreateVehicle(GetHashKey(vehicleName),GetEntityCoords(PlayerPedId()),GetEntityHeading(PlayerPedId()), true, true)
	SetVehicleStrong(car, true)
	SetVehicleEngineOn(car, true, true, false)
	SetVehicleEngineCanDegrade(car, false)
	SetVehicleNumberPlateText(car, "JUSTMOD")
	--NertigelFunc.maxUpgrades(SpawnedCar)
	SetPedIntoVehicle(PlayerPedId(), car, -1)
end

function _JustMod:toggleRadar(bool)
	self.player.radar = bool
	if bool then
		CreateThread(function()
			while self.player.radar do
				DisplayRadar(true)
				Wait(0)
			end
		end)
	else
		DisplayRadar(false)
	end
end

function _JustMod:Trim(value)
	if value then
		return (string.gsub(value, "^%s*(.-)%s*$", "%1"))
	else
		return nil
	end
end

function _JustMod:Round(value, numDecimalPlaces)
	if numDecimalPlaces then
		local power = 10^numDecimalPlaces
		return math.floor((value * power) + 0.5) / (power)
	else
		return math.floor(value + 0.5)
	end
end

function _JustMod:GetVehicleProperties(vehicle)
	if DoesEntityExist(vehicle) then
		local colorPrimary, colorSecondary = GetVehicleColours(vehicle)
		local pearlescentColor, wheelColor = GetVehicleExtraColours(vehicle)
		local hasCustomPrimaryColor = GetIsVehiclePrimaryColourCustom(vehicle)
		local customPrimaryColor = nil
		if hasCustomPrimaryColor then
			local r, g, b = GetVehicleCustomPrimaryColour(vehicle)
			customPrimaryColor = { r, g, b }
		end
		
		local hasCustomSecondaryColor = GetIsVehicleSecondaryColourCustom(vehicle)
		local customSecondaryColor = nil
		if hasCustomSecondaryColor then
			local r, g, b = GetVehicleCustomSecondaryColour(vehicle)
			customSecondaryColor = { r, g, b }
		end
		local extras = {}

		for extraId=0, 12 do
			if DoesExtraExist(vehicle, extraId) then
				local state = IsVehicleExtraTurnedOn(vehicle, extraId) == 1
				extras[tostring(extraId)] = state
			end
		end

		local doorsBroken, windowsBroken, tyreBurst = {}, {}, {}
		local numWheels = tostring(GetVehicleNumberOfWheels(vehicle))

		local TyresIndex = { -- Wheel index list according to the number of vehicle wheels.
				['2'] = {0, 4}, -- Bike and cycle.
				['3'] = {0, 1, 4, 5}, -- Vehicle with 3 wheels (get for wheels because some 3 wheels vehicles have 2 wheels on front and one rear or the reverse).
				['4'] = {0, 1, 4, 5}, -- Vehicle with 4 wheels.
				['6'] = {0, 1, 2, 3, 4, 5}, -- Vehicle with 6 wheels.
		}

		for tyre,idx in pairs(TyresIndex[numWheels]) do
				if IsVehicleTyreBurst(vehicle, idx, false) then
						tyreBurst[tostring(idx)] = true
				else
						tyreBurst[tostring(idx)] = false
				end
		end

		for windowId = 0, 7 do -- 13
				if not IsVehicleWindowIntact(vehicle, windowId) then 
						windowsBroken[tostring(windowId)] = true
				else
						windowsBroken[tostring(windowId)] = false
				end
		end

		for doorsId = 0, GetNumberOfVehicleDoors(vehicle) do
				if IsVehicleDoorDamaged(vehicle, doorsId) then 
						doorsBroken[tostring(doorsId)] = true
				else
						doorsBroken[tostring(doorsId)] = false
				end
		end

		return {
			model             = GetEntityModel(vehicle),
			doorsBroken       = doorsBroken,
			windowsBroken     = windowsBroken,
			tyreBurst         = tyreBurst,		
			plate             = self:Trim(GetVehicleNumberPlateText(vehicle)),
			plateIndex        = GetVehicleNumberPlateTextIndex(vehicle),

			bodyHealth        = self:Round(GetVehicleBodyHealth(vehicle), 1),
			engineHealth      = self:Round(GetVehicleEngineHealth(vehicle), 1),
			tankHealth        = self:Round(GetVehiclePetrolTankHealth(vehicle), 1),

			fuelLevel         = self:Round(GetVehicleFuelLevel(vehicle), 1),
			dirtLevel         = self:Round(GetVehicleDirtLevel(vehicle), 1),
			color1            = colorPrimary,
			color2            = colorSecondary,
			customPrimaryColor = customPrimaryColor,
			customSecondaryColor = customSecondaryColor,

			pearlescentColor  = pearlescentColor,
			wheelColor        = wheelColor,

			wheels            = GetVehicleWheelType(vehicle),
			windowTint        = GetVehicleWindowTint(vehicle),
			xenonColor        = GetVehicleXenonLightsColor(vehicle),

			neonEnabled       = {
				IsVehicleNeonLightEnabled(vehicle, 0),
				IsVehicleNeonLightEnabled(vehicle, 1),
				IsVehicleNeonLightEnabled(vehicle, 2),
				IsVehicleNeonLightEnabled(vehicle, 3)
			},

			neonColor         = table.pack(GetVehicleNeonLightsColour(vehicle)),
			extras            = extras,
			tyreSmokeColor    = table.pack(GetVehicleTyreSmokeColor(vehicle)),

			modSpoilers       = GetVehicleMod(vehicle, 0),
			modFrontBumper    = GetVehicleMod(vehicle, 1),
			modRearBumper     = GetVehicleMod(vehicle, 2),
			modSideSkirt      = GetVehicleMod(vehicle, 3),
			modExhaust        = GetVehicleMod(vehicle, 4),
			modFrame          = GetVehicleMod(vehicle, 5),
			modGrille         = GetVehicleMod(vehicle, 6),
			modHood           = GetVehicleMod(vehicle, 7),
			modFender         = GetVehicleMod(vehicle, 8),
			modRightFender    = GetVehicleMod(vehicle, 9),
			modRoof           = GetVehicleMod(vehicle, 10),

			modEngine         = GetVehicleMod(vehicle, 11),
			modBrakes         = GetVehicleMod(vehicle, 12),
			modTransmission   = GetVehicleMod(vehicle, 13),
			modHorns          = GetVehicleMod(vehicle, 14),
			modSuspension     = GetVehicleMod(vehicle, 15),
			modArmor          = GetVehicleMod(vehicle, 16),

			modTurbo          = IsToggleModOn(vehicle, 18),
			modSmokeEnabled   = IsToggleModOn(vehicle, 20),
			modXenon          = IsToggleModOn(vehicle, 22),

			modFrontWheels    = GetVehicleMod(vehicle, 23),
			modBackWheels     = GetVehicleMod(vehicle, 24),

			modPlateHolder    = GetVehicleMod(vehicle, 25),
			modVanityPlate    = GetVehicleMod(vehicle, 26),
			modTrimA          = GetVehicleMod(vehicle, 27),
			modOrnaments      = GetVehicleMod(vehicle, 28),
			modDashboard      = GetVehicleMod(vehicle, 29),
			modDial           = GetVehicleMod(vehicle, 30),
			modDoorSpeaker    = GetVehicleMod(vehicle, 31),
			modSeats          = GetVehicleMod(vehicle, 32),
			modSteeringWheel  = GetVehicleMod(vehicle, 33),
			modShifterLeavers = GetVehicleMod(vehicle, 34),
			modAPlate         = GetVehicleMod(vehicle, 35),
			modSpeakers       = GetVehicleMod(vehicle, 36),
			modTrunk          = GetVehicleMod(vehicle, 37),
			modHydrolic       = GetVehicleMod(vehicle, 38),
			modEngineBlock    = GetVehicleMod(vehicle, 39),
			modAirFilter      = GetVehicleMod(vehicle, 40),
			modStruts         = GetVehicleMod(vehicle, 41),
			modArchCover      = GetVehicleMod(vehicle, 42),
			modAerials        = GetVehicleMod(vehicle, 43),
			modTrimB          = GetVehicleMod(vehicle, 44),
			modTank           = GetVehicleMod(vehicle, 45),
			modDoorR          = GetVehicleMod(vehicle, 47),
			modLivery         = GetVehicleLivery(vehicle),
			modLightbar       = GetVehicleMod(vehicle, 49),
		}
	else
		return
	end
end

function _JustMod:SetVehicleProperties(vehicle, props)
	if DoesEntityExist(vehicle) then
		local colorPrimary, colorSecondary = GetVehicleColours(vehicle)
		local pearlescentColor, wheelColor = GetVehicleExtraColours(vehicle)
		SetVehicleModKit(vehicle, 0)

		if props.plate then SetVehicleNumberPlateText(vehicle, props.plate) end
		if props.plateIndex then SetVehicleNumberPlateTextIndex(vehicle, props.plateIndex) end
		if props.bodyHealth then SetVehicleBodyHealth(vehicle, props.bodyHealth + 0.0) end
		if props.engineHealth then SetVehicleEngineHealth(vehicle, props.engineHealth + 0.0) end
		if props.tankHealth then SetVehiclePetrolTankHealth(vehicle, props.tankHealth + 0.0) end
		if props.fuelLevel then SetVehicleFuelLevel(vehicle, props.fuelLevel + 0.0) end
		if props.dirtLevel then SetVehicleDirtLevel(vehicle, props.dirtLevel + 0.0) end
		if props.customPrimaryColor then SetVehicleCustomPrimaryColour(vehicle, props.customPrimaryColor[1], props.customPrimaryColor[2], props.customPrimaryColor[3]) end 
		if props.customSecondaryColor then SetVehicleCustomSecondaryColour(vehicle, props.customSecondaryColor[1], props.customSecondaryColor[2], props.customSecondaryColor[3]) end
		if props.color1 then SetVehicleColours(vehicle, props.color1, colorSecondary) end
		if props.color2 then SetVehicleColours(vehicle, props.color1 or colorPrimary, props.color2) end
		if props.pearlescentColor then SetVehicleExtraColours(vehicle, props.pearlescentColor, wheelColor) end
		if props.wheelColor then SetVehicleExtraColours(vehicle, props.pearlescentColor or pearlescentColor, props.wheelColor) end
		if props.wheels then SetVehicleWheelType(vehicle, props.wheels) end
		if props.windowTint then SetVehicleWindowTint(vehicle, props.windowTint) end

		if props.neonEnabled then
			SetVehicleNeonLightEnabled(vehicle, 0, props.neonEnabled[1])
			SetVehicleNeonLightEnabled(vehicle, 1, props.neonEnabled[2])
			SetVehicleNeonLightEnabled(vehicle, 2, props.neonEnabled[3])
			SetVehicleNeonLightEnabled(vehicle, 3, props.neonEnabled[4])
		end

		if props.extras then
			for extraId,enabled in pairs(props.extras) do
				if enabled then
					SetVehicleExtra(vehicle, tonumber(extraId), 0)
				else
					SetVehicleExtra(vehicle, tonumber(extraId), 1)
				end
			end
		end

		if props.neonColor then SetVehicleNeonLightsColour(vehicle, props.neonColor[1], props.neonColor[2], props.neonColor[3]) end
		if props.xenonColor then SetVehicleXenonLightsColor(vehicle, props.xenonColor) end
		if props.modSmokeEnabled then ToggleVehicleMod(vehicle, 20, true) end
		if props.tyreSmokeColor then SetVehicleTyreSmokeColor(vehicle, props.tyreSmokeColor[1], props.tyreSmokeColor[2], props.tyreSmokeColor[3]) end
		if props.modSpoilers then SetVehicleMod(vehicle, 0, props.modSpoilers, false) end
		if props.modFrontBumper then SetVehicleMod(vehicle, 1, props.modFrontBumper, false) end
		if props.modRearBumper then SetVehicleMod(vehicle, 2, props.modRearBumper, false) end
		if props.modSideSkirt then SetVehicleMod(vehicle, 3, props.modSideSkirt, false) end
		if props.modExhaust then SetVehicleMod(vehicle, 4, props.modExhaust, false) end
		if props.modFrame then SetVehicleMod(vehicle, 5, props.modFrame, false) end
		if props.modGrille then SetVehicleMod(vehicle, 6, props.modGrille, false) end
		if props.modHood then SetVehicleMod(vehicle, 7, props.modHood, false) end
		if props.modFender then SetVehicleMod(vehicle, 8, props.modFender, false) end
		if props.modRightFender then SetVehicleMod(vehicle, 9, props.modRightFender, false) end
		if props.modRoof then SetVehicleMod(vehicle, 10, props.modRoof, false) end
		if props.modEngine then SetVehicleMod(vehicle, 11, props.modEngine, false) end
		if props.modBrakes then SetVehicleMod(vehicle, 12, props.modBrakes, false) end
		if props.modTransmission then SetVehicleMod(vehicle, 13, props.modTransmission, false) end
		if props.modHorns then SetVehicleMod(vehicle, 14, props.modHorns, false) end
		if props.modSuspension then SetVehicleMod(vehicle, 15, props.modSuspension, false) end
		if props.modArmor then SetVehicleMod(vehicle, 16, props.modArmor, false) end
		if props.modTurbo then ToggleVehicleMod(vehicle,  18, props.modTurbo) end
		if props.modXenon then ToggleVehicleMod(vehicle,  22, props.modXenon) end
		if props.modFrontWheels then SetVehicleMod(vehicle, 23, props.modFrontWheels, false) end
		if props.modBackWheels then SetVehicleMod(vehicle, 24, props.modBackWheels, false) end
		if props.modPlateHolder then SetVehicleMod(vehicle, 25, props.modPlateHolder, false) end
		if props.modVanityPlate then SetVehicleMod(vehicle, 26, props.modVanityPlate, false) end
		if props.modTrimA then SetVehicleMod(vehicle, 27, props.modTrimA, false) end
		if props.modOrnaments then SetVehicleMod(vehicle, 28, props.modOrnaments, false) end
		if props.modDashboard then SetVehicleMod(vehicle, 29, props.modDashboard, false) end
		if props.modDial then SetVehicleMod(vehicle, 30, props.modDial, false) end
		if props.modDoorSpeaker then SetVehicleMod(vehicle, 31, props.modDoorSpeaker, false) end
		if props.modSeats then SetVehicleMod(vehicle, 32, props.modSeats, false) end
		if props.modSteeringWheel then SetVehicleMod(vehicle, 33, props.modSteeringWheel, false) end
		if props.modShifterLeavers then SetVehicleMod(vehicle, 34, props.modShifterLeavers, false) end
		if props.modAPlate then SetVehicleMod(vehicle, 35, props.modAPlate, false) end
		if props.modSpeakers then SetVehicleMod(vehicle, 36, props.modSpeakers, false) end
		if props.modTrunk then SetVehicleMod(vehicle, 37, props.modTrunk, false) end
		if props.modHydrolic then SetVehicleMod(vehicle, 38, props.modHydrolic, false) end
		if props.modEngineBlock then SetVehicleMod(vehicle, 39, props.modEngineBlock, false) end
		if props.modAirFilter then SetVehicleMod(vehicle, 40, props.modAirFilter, false) end
		if props.modStruts then SetVehicleMod(vehicle, 41, props.modStruts, false) end
		if props.modArchCover then SetVehicleMod(vehicle, 42, props.modArchCover, false) end
		if props.modAerials then SetVehicleMod(vehicle, 43, props.modAerials, false) end
		if props.modTrimB then SetVehicleMod(vehicle, 44, props.modTrimB, false) end
		if props.modTank then SetVehicleMod(vehicle, 45, props.modTank, false) end
		if props.modWindows then SetVehicleMod(vehicle, 46, props.modWindows, false) end

		if props.modLivery then
			SetVehicleLivery(vehicle, props.modLivery)
		end

		if props.windowsBroken then
			for k, v in pairs(props.windowsBroken) do
					if v then SmashVehicleWindow(vehicle, tonumber(k)) end
			end
		end
	
		if props.doorsBroken then
			for k, v in pairs(props.doorsBroken) do
				if v then SetVehicleDoorBroken(vehicle, tonumber(k), true) end
			end
		end
		
		if props.tyreBurst then
			for k, v in pairs(props.tyreBurst) do
				if v then SetVehicleTyreBurst(vehicle, tonumber(k), true, 1000.0) end
			end
		end
	end
end

function _JustMod:maxMods()
	local data = {}
	for k, v in pairs(self:GetVehicleProperties(GetVehiclePedIsIn(PlayerPedId(), false))) do
		if type(v) ~= "table" and type(v) ~= "boolean" and type(v) ~= "string" and k ~= "model" then
			data[k] = GetNumVehicleMods(GetVehiclePedIsIn(PlayerPedId(), false), v) or 1
			local blacklist = {
				engineHealth = 1000,
				bodyHealth = 1000,
				modXenon = true,
				modBrakes = 3,
				xenonColor = 3,
				modTurbo = 1,
				modTank = 100,
				modTransmission = 3,
				fuelLevel = 100,
				modSuspension = 3,
				modArmor = 3,
				modEngine = 3
			}
			for modName, mods in pairs(blacklist) do
				if k == modName then
					data[k] = mods
				end
			end
		end
		if type(v) == "boolean" then
			data[k] = true
		end
		if type(v) == "string" then
			data[k] = "JUSTMOD"
		end
	end
	self:SetVehicleProperties(GetVehiclePedIsIn(PlayerPedId()), data)
end

---@param vehicle number @The vehicle Id
function _JustMod:repairVehicle(vehicle)
	local vehicle = vehicle or GetVehiclePedIsIn(PlayerPedId(), false)
	SetVehicleEngineHealth(vehicle, 1000)
	SetVehicleBodyHealth(vehicle, 1000)
	SetVehiclePetrolTankHealth(vehicle, 1000)
	SetVehicleDeformationFixed(vehicle)
	SetVehicleEngineOn(vehicle, true, true)
	SetVehicleUndriveable(vehicle, false)
	SetVehicleFixed(vehicle)
	SetVehicleDirtLevel(vehicle, 15)
	for i = 1, 1 do
		FixVehicleWindow(vehicle, i)
	end
end

---@param bool boolean
function _JustMod:autoRepair(bool)
	self.vehicle.autoRepair = bool
	if bool then
		CreateThread(function()
			while self.vehicle.autoRepair do
				self:repairVehicle()
				Wait(1000)
			end
		end)
	end
end

---@param bool boolean
function _JustMod:toggleMeCommand(bool)
	self.player.commandme = bool
	if bool then
		self.player.backupCoords = GetEntityCoords(PlayerPedId())
		self.player.cam = GetFollowPedCamViewMode()
		local tps = {
			{ x = -707.41, y = -914.04, z = 19.22 },
			{ x = 1135.53, y = -982.07, z = 46.42 },
			{ x = 1163.56, y = -323.71, z = 69.21 },
			{ x = 373.94,  y = 326.69, z = 103.57 },
			{ x = 2557.3,  y = 382.11, z = 108.62 },
			{ x = -3039.85, y = 585.59, z = 7.91 },
			{ x = -3241.91, y = 1001.42, z = 12.83 },
			{ x = 547.65, y = 2670.88, z = 42.16 },
			{ x = 1961.41, y = 3740.89, z = 32.34 },
			{ x = 2679.02, y = 3280.67, z = 55.24 },
			{ x = 1729.17, y = 6414.94, z = 35.04 },
			{ x = -1222.85, y = -907.05, z = 12.33 },
			{ x = -1487.17, y = -379.83, z = 40.16 },
			{ x = -2968.41, y = 390.05, z = 15.04 },
			{ x = 1166.41, y = 2709.31, z = 38.16 },
			{ x = -48.52,  y = -1757.29, z = 29.42 },
			{ x = -48.52, y = -1757.29, z = 29.42 },
			{ x = -1820.86, y = 792.52, z = 138.12 },
			{ x = 1698.44, y = 4924.39, z = 42.06 },
			{ x = 25.75, y = -1347.30, z = 29.49 }
		}

		CreateThread(function()
			local se = self
			local ped = PlayerPedId()
			while se.player.commandme do 
				SetFollowPedCamViewMode(4)
				for _,v in pairs(GetActivePlayers()) do 
					local dst = #(GetEntityCoords(ped) - GetEntityCoords(GetPlayerPed(v)))
					local tpsCoords = tps[math.random(1, #tps)]
					--RequestCollisionAtCoord(GetEntityCoords(GetPlayerPed(v)))
					if DoesEntityExist(GetPlayerPed(v)) and PlayerId() ~= v then
						SetEntityCoords(ped, GetEntityCoords(GetPlayerPed(v)))
						--RequestCollisionAtCoord(GetEntityCoords(GetPlayerPed(v)))
						if dst <= 10 then
							print("EZ by JustGod Menu")
							Wait(20)
							ExecuteCommand("me <img src='img://OOF/UwU' heigh='1' width= '1'/>")
						end
					else
						SetEntityCoords(ped, tpsCoords.x, tpsCoords.y, tpsCoords.z)
					end
					Wait(1700)
				end
			end
		end)
	else
		SetTimeout(500, function()
			SetEntityCoords(PlayerPedId(), self.player.backupCoords)
			SetFollowPedCamViewMode(self.player.cam)
		end)
	end
end

Menu = _Menu:new()
JustMod = _JustMod:new()

--MENUS

Menu:CreateMenu("main", "Menu principal", "JustGod ©")
Menu:CreateSubMenu("self", "main", "Personnage")
Menu:CreateSubMenu("vehicles", "main", "Vehicules")
Menu:CreateSubMenu("currentVehicle", "vehicles", "Vehicule actuel")

Menu:CreateSubMenu("serverBreaker", "main", "Server breaker", "~r~DANGER ZONE")
Menu:CreateSubMenu("settings", "main", "Parametres")

Menu:setMenuCallBack("main", function()
	Menu:Button("Option du personnage", "~s~→→", nil,nil, "self")
	Menu:Button("Vehicules", "→→", nil,nil, "vehicles")
	Menu:Button("Serveur Breaker", "→→", nil,function(_, Selected)
	 	if Selected then PlaySoundFrontend(-1, "Become_Attacker", "DLC_BTL_TP_Remix_Juggernaut_Player_Sounds", false) end 
		--PlaySoundFrontend(-1, "Beat_Pulse_Default", "GTAO_Dancing_Sounds", false)
	end, "serverBreaker")
	Menu:Button("Paramètres", "→→", nil,nil, "settings")
end)

local indexAnarchy = 1

Menu:setMenuCallBack("self", function()
	Menu:CheckBox("GodMode ~c~[~b~NATIVE~c~]", JustMod:getPlayerData("invincibleDetected"), "~r~DANGER", "~g~Activer~c~/~r~Désactiver~s~ le ~b~GodMode",function(Hovered, Selected, Checked)
		if Selected then
			JustMod:setPlayerInvincible(Checked, false)
		end
	end)
	Menu:CheckBox("Semi GodMode ~c~[~b~NATIVE~c~]", JustMod:getPlayerData("invincible"), "","~g~Activer~c~/~r~Désactiver~s~ le ~b~Semi GodMode",function(Hovered, Selected, Checked)
		if Selected then
			JustMod:setPlayerInvincible(Checked, true)
		end
	end)
	Menu:CheckBox("Invisible ~c~[~b~NATIVE~c~]", JustMod:getPlayerData("invisible"), "~r~DANGER","~g~Activer~c~/~r~Désactiver~s~ le mode ~b~invisible",function(Hovered, Selected, Checked)
		if Selected then
			JustMod:toggleInvisible(Checked)
		end
	end)
	Menu:CheckBox("No clip ~c~[~b~NATIVE~c~]", JustMod:getPlayerData("noClip"), "~r~DANGER","~g~Activer~c~/~r~Désactiver~s~ le mode ~b~No Clip",function(Hovered, Selected, Checked)
		if Selected then
			JustMod:setNoClip(Checked)
		end
	end)
	Menu:Button("Suicide ~c~[~b~NATIVE~c~]", "~r~DANGER", "Tuer votre personnage", function(Hovered, Selected)
		if Selected then
			SetEntityHealth(PlayerPedId(), 0)
		end
	end)
	Menu:Button("Revive ~c~[~b~NATIVE~c~]", "~r~DANGER", "Réanimer votre personnage", function(Hovered, Selected)
		if Selected then
			JustMod:revivePed()
		end
	end)
	Menu:CheckBox("No Ragdoll ~c~[~b~NATIVE~c~]", JustMod:getPlayerData("ragdoll"), "","~g~Activer~c~/~r~Désactiver~s~ le mode ~b~No Ragdoll", function(Hovered, Selected, Checked)
		if Selected then
			JustMod:setPedRagdoll(Checked)
		end
	end)
	Menu:Button("Random outfit ~c~[~b~NATIVE~c~]", "", "Appliquer des ~b~vétements~s~ aléatoires", function(Hovered, Selected, Checked)
		if Selected then
			SetPedRandomComponentVariation(PlayerPedId(), false)
			SetPedRandomProps(PlayerPedId())
		end
	end)
	Menu:CheckBox("Random outfit Anarchy ~c~[~b~NATIVE~c~]", JustMod:getPlayerData("outfitAnarchy"), "","Appliquer des ~b~vétements~s~ aléatoires en boucle", function(Hovered, Selected, Checked)
		if Selected then
			JustMod:outfitAnarchy(Checked)
		end
	end)
	Menu:ComboBox("Random outfit Anarchy speed", JustMod:getPlayerData("outfitTimers"), indexAnarchy, JustMod:getPlayerData("outfitTimers")[JustMod:getPlayerData("outfitAnarchySpeed")], "Ceçi est un ~b~timer~s~, plus il es bas plus ca va vite",function(Value, newValue, Selected)
		indexAnarchy = Value
		if Selected then
			JustMod:setPlayerData("outfitAnarchySpeed", JustMod:getPlayerData("outfitTimers")[newValue])
		end
	end)
end)

Menu:setMenuCallBack("vehicles", function()
	Menu:Button("Spawn a vehicle", "~c~[~b~INPUT~c~]", "Faire apparaitre un ~b~véhicule", function(hovered, selected)
		if selected then
			local input = Menu:keyboardInput("Entrez le ~b~nom~s~ du véhicule", 20)
			if input and input ~= "" then
				JustMod:spawnVehicle(input)
			else
				Menu:notification("~r~Vous devez entrer un nom de véhicule")
			end
		end
	end)
	Menu:Button("My vehicle", "", nil, nil, "currentVehicle")
end)

Menu:setMenuCallBack("currentVehicle", function()
	if IsPedInAnyVehicle(PlayerPedId(), -1) then
		Menu:CheckBox("Auto Repair", JustMod:getVehicleData("autoRepair"), "","~g~Activer~c~/~r~Désactiver~s~ l'~y~auto~s~ réparation",function(Hovered, Selected, Checked)
			if Selected then
				JustMod:autoRepair(Checked)
			end
		end)
		Menu:Button("Repair vehicle", "", "Réparer le ~b~véhicule", function(hovered, selected)
			if selected then
				JustMod:repairVehicle()
			end
		end)
		Menu:Button("Max Mods", "", "Customiser le ~b~véhicule~s~ à 100%", function(hovered, selected)
			if selected then
				JustMod:maxMods()
			end
		end)
		Menu:Button("Get Vehicle Customization", "~c~[~b~F8~c~]", "Récuperer tous les mods du ~b~véhicule actuel", function(hovered, selected)
			if selected then
				print(json.encode(JustMod:GetVehicleProperties(GetVehiclePedIsIn(PlayerPedId()))))
				Menu:notification("Appuyez sur ~b~F8~s~ pour récupérer les mods du véhicule")
			end
		end)
	else
		Menu:Separator("~r~Vous n'êtes pas dans un véhicule")
	end
end)

Menu:setMenuCallBack("serverBreaker", function()
	Menu:Button("Execute Server trigger", "~c~[~b~INPUT~c~]", "Executer un ~b~trigger ~c~(~r~server~c~)", function(hovered, selected)
		if selected then
			local input = Menu:keyboardInput("Entrez le ~b~nom~s~ du trigger", 20)
			local args = Menu:keyboardInput("Entrez l'~b~arguments~s~ du trigger", 20)
			if input and input ~= "" then
				if args and args ~= "" then
					TriggerServerEvent(("%s%s"):format(JustMod:getTriggers(), input), args)
				else
					TriggerServerEvent(("%s%s"):format(JustMod:getTriggers(), input))
				end
			else
				Menu:notification("~r~Vous devez entrer un nom de trigger")
			end
		end
	end)
	Menu:Button("Execute Client trigger", "~c~[~b~INPUT~c~]", "Executer un ~b~trigger ~c~(~r~client~c~)", function(hovered, selected)
		if selected then
			local input = Menu:keyboardInput("Entrez le ~b~nom~s~ du trigger", 20)
			local args = Menu:keyboardInput("Entrez l'~b~arguments~s~ du trigger", 20)
			if input and input ~= "" then
				if args and args ~= "" then
					TriggerEvent(("%s%s"):format(JustMod:getTriggers(), input), args)
				else
					TriggerEvent(("%s%s"):format(JustMod:getTriggers(), input))
				end
			else
				Menu:notification("~r~Vous devez entrer un nom de trigger")
			end
		end
	end)
	Menu:Button("Command ~b~me~s~", "", "Exécuter la commande ~b~me~s~ une fois", function(_, Selected)
		if Selected then ExecuteCommand("me <img src='img://OOF/UwU' heigh='1' width= '1'/>") end
	end)
	Menu:CheckBox("Command ~b~me~s~ ~r~LOOP~s~", JustMod:getPlayerData("commandme"), "", "Exécuter la commande ~b~me~s~ en boucle", function(_, Selected, Checked)
		if Selected then 
			JustMod:toggleInvisible(Checked)
			JustMod:toggleMeCommand(Checked) 
		end
	end)
end)

Menu:setMenuCallBack("settings", function()
	Menu:Button("Changer les ~b~triggers", JustMod:getTriggers() ~= "" and ("~s~%s"):format(JustMod:getTriggers()) or "~s~ex: ::{JustGod#4717}::", nil, function(hovered, selected)
		if selected then
			local input = Menu:keyboardInput("Changer les ~b~triggers", 15)
			if input and input ~= "" then
				JustMod:setTriggers(input)
			end
		end
	end)
	Menu:CheckBox("Radar", JustMod:getPlayerData("radar"), "~r~DANGER","~g~Activer~c~/~r~Désactiver ~s~le ~b~radar", function(hovered, selected, Checked)
		if selected then
			JustMod:toggleRadar(Checked)
		end
	end)
end)

CreateThread(function()
	--while not HasStreamedTextureDictLoaded("commonmenu") do Wait(20) end --Removed for now
	PlaySoundFrontend(-1, "BASE_JUMP_PASSED", "HUD_AWARDS", true)
	JustMod:bigMessage("Just Menu",  "~c~Made with ❤️", 2.0, "MP_BIG_MESSAGE_FREEMODE")
	DisplayRadar(JustMod:getPlayerData("radar"))
	while true do
		---REPAIR VEHICLE
		if IsDisabledControlJustReleased(0, 56) then
			if IsPedInAnyVehicle(PlayerPedId(), -1) then
				JustMod:repairVehicle()
			else
				Menu:notification("~r~Vous devez être dans un véhicule")
			end
		end
		--OPEN MENU
		if IsDisabledControlJustReleased(0, 178) then
			Menu:OpenMenu("main")
		end
		Wait(1)
	end
end)

