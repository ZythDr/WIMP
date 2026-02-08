# WIMP v1.0 - TurtleWoW
## Patch Notes

### Merged Windows/Tabbed Layout & QoL
- **Merged tabbed window mode**
  - All conversations in one shared frame
  - Horizontal scrollable tab bar with unread flashing animation
  - Tab bar can be placed above or below WIM
  - Class-colored names + borders on tabs
  - Right-click tab to close it's conversation

- **General improvements**
  - Click-outside to unfocus WIM, click WIM to focus WIM and start typing.
  - Drag-resize handle (session-only, resets to size specified in WIM options on `/reload`)
  - Class-colored names in messages and history
  - Adds a `PlayerCacheDB` to store details about previously messaged players. (Placeholder until `/who` query is successful)

- **pfUI compatible (WIM Tabs)**
  - Only activates when pfUI is loaded and pfUI `WIM Integration` is enabled
  - The new Tab Bar skins itself to match pfUI when pfUI is present and `WIM Integration` is enabled in pfUI
  - Use pfUI's DB for faster Class/Guild/Race/Level lookup (until `/who` query is successful)

- **Bug Fixes**
  - AtlasLoot Links no longer instantly send when shift-clicked
  - Linking equipped items from the Character Panel no longer results in double links



## Previous Changes v1.4.0 (by [Kirchlive](https://github.com/Kirchlive/WIM))
### Patch Notes

### New Features
- **New Filter Type: Exact** – Now filters only whispers matching exactly. "inv" only blocks message "inv", still allows message like "raid inv now"
- **Unfocus WIM Window** – Pressing Escape now leaving window focus but keeps insert text. Optional under general with "escape close window" dependency.
- **Alt+Arrow Key Toggle** – Added option to text cursor moving. Alt modifier now can be disabled to work like in normal inputbox.

### Bug Fixes
- **Ingame Links** – All chat links such as items, spells, quests, etc. now insert correctly without gaps.
- **Macro Whispers** – Script- and macro-based whispers now send and display correctly in WIM.
- **Filter Iteration** – Fixed Lua 5.0 table iteration to now properly use `pairs()`, preventing undefined behavior.

### UI Improvements
- Reorganized General options for improved clarity and better accessibility
- Updated code formatting across all checkboxes for consistency

Some more minor quality of life changes. 🐢

## Previous Changes v1.3.5
- Added 30s WHO cooldown (TurtleWoW limit)
- Messages now display immediately (WHO loads async)
- Removed "Block Low Level" option
- Added debug mode: `/wimdebug`
