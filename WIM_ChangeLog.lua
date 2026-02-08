WIM_CHANGE_LOG = [[
|rVersion 1.0 (WIMP Fork) (02-08-2026)|cffffffff
[+] - Added merged tabbed window mode with a shared conversation frame.
[+] - Added a horizontal scrollable tab bar with unread flashing animation.
[+] - Added option to place tab bar above or below the message window.
[+] - Added class-colored names and borders on tabs.
[+] - Added right-click close for tab conversations.
[+] - Added click-outside unfocus behavior for the message input.
[+] - Added session-only drag-resize handle (resets on /reload).
[+] - Added class-colored names in message lines and history.
[+] - Added player cache fallback placeholders for details before /who resolves.
[+] - Added pfUI tab skin integration when pfUI WIM integration is enabled.
[+] - Added pfUI player DB fallback for class/guild/race/level before /who resolves.
[*] - Fixed AtlasLoot shift-click links no longer sending immediately.
[*] - Fixed character panel shift-click links no longer duplicating.

|rVersion 1.4.0 (TurtleWoW)|cffffffff
[+] - Added new filter type: Exact.
[+] - Added Escape unfocus option while keeping input text.
[+] - Added Alt+Arrow key toggle for cursor movement behavior.
[*] - Fixed in-game links insertion (items/spells/quests) without text gaps.
[*] - Fixed macro/script whispers to send and display correctly in WIM.
[*] - Fixed Lua 5.0 filter iteration by using pairs().
[*] - Reorganized General options and normalized checkbox code formatting.

|rVersion 1.3.5 (TurtleWoW)|cffffffff
[+] - Added 30s WHO cooldown for TurtleWoW limits.
[*] - Messages now display immediately while WHO loads asynchronously.
[-] - Removed Block Low Level option.
[+] - Added debug mode command: /wimdebug

Version 1.3.3 (12-27-2017)|cffffffff
[+] - refactoring by shirsig

Version 1.3.2 (01-05-2017)|cffffffff
[+] - translated into ruRU

Version 1.3.1 (10-17-2006)|cffffffff
[+] - Created new minimap icon menu. No longer using Blizzards Drop Down Menu.
[+] - You can now close conversations from the minimap icon menu.
[*] - Made required code changes for titan plugin and new minimap icon menu.
[*] - Who window no longer pops up when speaking with GM or offline user.
[+] - WIM replaces "Send Message" button in the Friends Frame.
[+] - Now interecepts /w and /whisper commands and opens a message window.
[+] - Added option to enable/disable whisper slash command intercepting.
[+] - Added support for LootLink.
[+] - Added support for EngInventory.
[+] - You can now execute slash commands inside a message window.

|rVersion 1.2.13 (10-03-2006)|cffffffff
[*] - Fixed bug that causes error if titan is not loaded.

|rVersion 1.2.12 (10-03-2006)|cffffffff
[+] - Added support for AtlasLoot.
[+] - Added option to only keep focus while in a major city.
[+] - Added option to not show AFK and DND messages.
[+] - Added option to Enable/Disable use of 'Escape Key' to close windows.
[+] - Added 'Show' and 'Hide All Messages' key bindings.
[+] - Added scroll bar to general options tab. (out of room!).
[*] - Fixed nil error in function WIM_LoadGuildList(). (thanks Misschief).
[+] - You can now link items from the loot window.
[+] - Added support for AllInOneInventory.
[*] - Who window should no longer pop up when finding similar names.
[*] - Titan is now listed as an optional dependency.

|rVersion 1.2.11 (09-29-2006)|cffffffff
[*] - Fixed spelling mistake on Windows tab.
[*] - No longer run /who request on cross-realm users.
[+] - Get information on cross-realm users from raid info.
[*] - Message toggle window only shows unique users as intended.
[+] - Toggling window now brings it to front if behind another window.
[+] - Toggling windows now auto focuses when message selected.
[+] - The TAB key now toggles windows while already focused in another window.
[+] - You can now link items from the inspect screen.
[+] - You can now link items in SuperInspect.
[+] - Added "Did you know?" tab in help.
[+] - Added "Credits" tab in help.
[+] - Added button to option screen to access help.

|rVersion 1.2.10 (09-26-2006)|cffffffff
[*] - Made a minor adjustment to window focusing behavior.
[+] - Modified options window to include aliasing, filtering & History options
[+] - Added Alias Filtering: (1: replace name; 2: show as comment);
[+] - Added Keyword/Phrase Filtering: (1: Ignore (by WIM); 2: Block (all together))
[+] - Added default CT_RABM filter rules.
[+] - Added history engine and options.
[+] - Added history viewer.   ( /wim history )
[*] - Shortcut bar now retains its transparency of 100%.
[+] - Added button to message window to access history if history exists.
[+] - Added options to set default window position.
[+] - Added option to Enable/Disable window cascading.
[+] - Added option to change the direction if window cascading.
[+] - Added key bindings.
[+] - Added a key binding to toggle through recent conversations.
[+] - Added a help screen. ( /wim help )

|rVersion 1.1.15 (09-19-2006)|cffffffff
[+] - Added option to show character info (/who requests).
[+] - Added option to show class icon. (updated default icon).
[*] - Minimap icon no longer shows on top of all other windows unless its in free moving mode.
[+] - You can now link items in your character frame.
[+] - You can now link items from trade skill windows.
[+] - You can now link items from crafting windows (ex: Enchanting)
[+] - Added option to set class color to title bar text.
[+] - Added option to display timestamps.
[+] - Added option to Enable/Disable WIM.
[+] - Added shortcut bar (and appropriate options).
[+] - Added detailed character info. (Guild, level, race, class).

|rVersion 1.1.4 (09-15-2006)|cffffffff
[+] - Added built-in Titan plugin.
[*] - Transparency no longer affects chat text.
[*] - Minimap menu now opens to the left the way intended.
[+] - Created new graphics for message window.
[+] - Recreated message window frame - now sizable!
[+] - Reorganized option window & created tab for window options
[-] - Removed option 'Show minimap tooltip'.
[+] - Added options 'Show tooltips'.
[*] - Reworded option to pop up when receiving replies (worked as intended).
[*] - Windows can no longer positioned outside of the interface.
[+] - Added option to sort conversation list alphabetically (otherwise sort by order received).
[+] - Added options to change height and width of message windows.
[+] - Message windows can now be dragged by the chat frame.
[+] - Clicking chat frame will now set focus to message box.
[+] - Added the ability to close a conversation.
[+] - Added freely movable minimap icon. (Move anywhere on your screen).
[+] - Shift-Click scroll button now pages up & down.
[+] - Shift-ScrollWheel now pages up and down.
[+] - Added option to disable popups when in combat.
[+] - Added class icons to message window.

|rVersion 1.0.19 (09-12-2006) |cffffffff
[*] - Fixed the problem with in game languages (Common/Orcish). This should also resolve problems with other lingual wow interfaces as well. 
[*] - Recoded some function hooks to avoid receiving duplicate messages due to addon conflicts. 

|rVersion 1.0.18 (09-12-2006) |cffffffff
[!] - Initial public release.

]]
