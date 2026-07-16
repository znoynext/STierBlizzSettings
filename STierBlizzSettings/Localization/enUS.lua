local _, STBS = ...
STBS.Locale = STBS.Locale or {}
STBS.Locale.enUS = {
  TITLE="S-Tier Blizz Settings", HOME="Home", GRAPHICS="Graphics", INTERFACE="Interface & Gameplay", PROFILES="Profiles", BACKUPS="Backup & Restore", DIAGNOSTICS="Diagnostics",
  APPLY_GRAPHICS="Apply Graphics", APPLY_INTERFACE="Apply Interface & Gameplay", APPLY_ALL="Apply Everything", PREVIEW="Preview Changes", SAVE="Save Current Settings", EXPORT="Export", IMPORT="Import", RESTORE="Restore", COPY="Select All",
  UNIFIED="One Profile Everywhere", SPLIT="Optimized Raid Mode", MODE="Graphics mode", MODE_UNSET="Choose a graphics mode before applying.",
  HOME_TEXT="Optimal built-in WoW settings. One click. No UI pack required.", GRAPHICS_TEXT="Choose consistent graphics everywhere, or keep a lighter Blizzard profile for raids and battlegrounds.", INTERFACE_TEXT="Recommended built-in settings improve combat readability with cooldown numbers, target-of-target, player silhouette, enemy nameplates and a stable camera.",
  CHANGED="Changed", IDENTICAL="Already configured", SKIPPED="Skipped", FAILED="Failed", UNAVAILABLE="Unavailable", PRESERVED="Preserved", REPORT_GRAPHICS="GRAPHICS APPLIED", REPORT_INTERFACE="INTERFACE & GAMEPLAY APPLIED",
  CREATE_BACKUP="Create Manual Backup", RESTORE_ALL="Restore Everything", RESTORE_GRAPHICS="Restore Graphics Only", RESTORE_INTERFACE="Restore Interface & Gameplay Only", BACKUP_CREATED="Backup created.",
  SAVE_GRAPHICS="Save Graphics", SAVE_INTERFACE="Save Interface & Gameplay", SAVE_ALL="Save Everything", RENAME="Rename", DELETE="Delete selected", SELECT="Select", CANCEL_PENDING="Cancel Pending Operation", NO_PENDING="No operation is queued.",
  CONFIRM="Confirm", BACK="Back", IMPORT_GRAPHICS="Graphics only", IMPORT_INTERFACE="Interface & Gameplay only", IMPORT_ALL="Everything", KEEP_MODE="Keep current graphics mode", USE_PROFILE_MODE="Use profile graphics mode",
  PENDING="Pending operation will apply after combat ends.", IMPORT_HELP="Paste an STBS1 profile string. WoW does not support direct clipboard access; use Select All and copy manually.", EXPORT_HELP="Use Select All, then copy this text manually.", INVALID_IMPORT="The profile is invalid or unsupported.",
  PROFILE_NAME="Profile name:", IMPORT_PROMPT="Paste an STBS1 profile string:", SETTINGS_COUNT="settings", IMPORT_CONFIRMATION="Choose an import scope below to confirm. Nothing has been applied yet.", HARDWARE_PRESERVED="Preserved hardware settings: monitor, resolution, refresh rate, V-Sync, FPS limits and latency mode.", PERSONAL_PRESERVED="Preserved personal settings: UI scale, mouse controls, accessibility, sound and keybindings.",
  DIFF_HEADER="Change preview", PROFILE_SUMMARY="Profile summary", BACKUP_HISTORY="Backup history", NO_BACKUPS="No backups yet.", NO_PROFILES="No saved personal profiles yet.", SELECTED="Selected", SIZE="Size", BASE_GRAPHICS="Base graphics", RAID_GRAPHICS="Raid & battleground graphics", CAMERA="Camera", OTHER_INTERFACE="Interface & gameplay", STATUS="Status",
  PERSONAL="Personal profile", UNSUPPORTED="This feature is unavailable in this client.", EDITMODE_UNAVAILABLE="Edit Mode profile management is unavailable in this alpha.", KEYBINDING_UNAVAILABLE="Keybinding profile management is unavailable in this alpha.", TRANSACTION_ROLLED_BACK="The operation was reverted because a setting could not be verified.",
}
STBS.Locale.enUS.WELCOME="To configure S-Tier Blizz Settings, type /stier or click the minimap button."
STBS.Locale.enUS.MINIMAP_TOOLTIP="Left-click to open settings."
