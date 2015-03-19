-- This config based on config http://github.com/vicfryzel/xmonad-config from Vic Fryzel

import System.IO
import System.Exit
import XMonad
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.ManageHelpers
import XMonad.Hooks.SetWMName
import XMonad.Util.Run(spawnPipe)
import qualified XMonad.StackSet as W
import qualified Data.Map        as M

import XMonad.Layout.ResizableTile
import XMonad.Layout.Fullscreen
import XMonad.Layout.Tabbed
import XMonad.Layout.NoBorders

import XMonad.Layout.WindowNavigation
import XMonad.Layout.IndependentScreens

import XMonad.Actions.DynamicWorkspaces
import XMonad.Util.EZConfig(mkKeymap)
import XMonad.Actions.CycleWS

import XMonad.Prompt (defaultXPConfig)

------------------------------------------------------------------------
-- Terminal
myTerminal = "/usr/bin/xterm"

------------------------------------------------------------------------
-- Workspaces
myWorkspaces = withScreens 2 ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"]

------------------------------------------------------------------------
-- Window rules
--
-- myManageHook = composeAll
--    [ className =? "Chromium"       --> doShift "2"
--    , className =? "Google-chrome"  --> doShift "2"
--    , resource  =? "desktop_window" --> doIgnore
--    , className =? "stalonetray"    --> doIgnore
--    , isFullscreen --> (doF W.focusDown <+> doFullFloat)]


------------------------------------------------------------------------
-- Layouts
-- You can specify and transform your layouts by modifying these values.
-- If you change layout bindings be sure to use 'mod-shift-space' after
-- restarting (with 'mod-q') to reset your layout state to the new
-- defaults, as xmonad preserves your old layout settings by default.
--
-- The available layouts.  Note that each layout is separated by |||,
-- which denotes layout choice.
--
myLayout = avoidStruts (
	smartBorders (ResizableTall 2 (3/100) (1/2) [] ||| layoutHook defaultConfig) |||
	tabbed shrinkText tabConfig |||
	Full)|||
	noBorders (fullscreenFull Full)

------------------------------------------------------------------------
-- Colors and borders
-- Currently based on the ir_black theme.
--
myNormalBorderColor  = "#7c7c7c"
myFocusedBorderColor = "#ffb6b0"

-- Colors for text and backgrounds of each tab when in "Tabbed" layout.
tabConfig = defaultTheme {
    activeBorderColor = "#7C7C7C",
    activeTextColor = "#CEFFAC",
    activeColor = "#000000",
    inactiveBorderColor = "#7C7C7C",
    inactiveTextColor = "#EEEEEE",
    inactiveColor = "#000000"
}

-- Color of current window title in xmobar.
xmobarTitleColor = "#FFB6B0"

-- Color of current workspace in xmobar.
xmobarCurrentWorkspaceColor = "#CEFFAC"

-- Width of the window border in pixels.
myBorderWidth = 1

------------------------------------------------------------------------
-- Key bindings
myModMask = mod4Mask

myKeys = \conf -> mkKeymap conf $
    [ ("M-<Return>", spawn "xterm")
    , ("M1-C-<Delete>", spawn "xscreensaver-command -lock")
    , ("M-p", spawn "dmenu-with-yeganesh")
    , ("M-a", sendMessage MirrorShrink)
    , ("M-z", sendMessage MirrorShrink)
    , ("C-<KP_Add>", spawn "~/mpd/volumeup")
    , ("C-<KP_Subtract>", spawn "~/mpd/volumedown")
    , ("C-<KP_Multiply>", spawn "~/mpd/next")
    , ("C-<KP_Divide>", spawn "~/mpd/prev")
    , ("C-<Space>", spawn "~/mpd/startstop")

-- "Standard" xmonad key bindings
    , ("M-S-c", kill)                                       -- Kill selected window
    , ("M-<Space>", sendMessage NextLayout)                 -- Switch layout
    , ("M-S-<Space>", setLayout $ XMonad.layoutHook conf)   -- Reset to default layout
    , ("M-n", refresh)                                      -- Resize viewed windows to the correct size
--    , ("M l", windows W.focusRight)                         -- Focus windows navigation
    , ("M-k", windows W.focusUp)
    , ("M-j", windows W.focusDown)
--    , ("M k", windows W.focusLeft)
    , ("M-S-h", sendMessage (IncMasterN 1))                   -- Move window left/right
    , ("M-S-l", sendMessage (IncMasterN (-1)))
    , ("M-q", restart "xmonad" True)                        -- Restart xmonad
--    , ("M-S-t", addWorkspacePrompt defaultXPConfig)
--    , ("M-t", selectWorkspace defaultXPConfig)
-- Quit xmonad.
--  , ((modMask .|. shiftMask, xK_q),
--     io (exitWith ExitSuccess))
    ]
    ++

 -- mod-[1..9], Switch to workspace N
    [("M-" ++ m ++ [k], windows $ onCurrentScreen f i)
        | (i, k) <- zip (workspaces' conf) (['1' .. '9'] ++ ['0', '-'])
        , (f, m) <- [(W.greedyView, ""), (W.shift, "S-")]
    ]
    ++

 -- mod-[1..9], Switch to workspace N
--    [("M" ++ m ++ [k], windows $ f i)
--        | (i, k) <- zip (XMonad.workspaces conf) (['1' .. '9'] ++ ['0', '-'])
--        , (f, m) <- [(W.greedyView, ""), (W.shift, "S-")]]
--    ++

    -- mod-{w,e,r}, Switch to physical/Xinerama screens 1, 2, or 3
    -- mod-shift-{w,e,r}, Move client to screen 1, 2, or 3
    [("M-" ++ m ++ k, screenWorkspace sc >>= flip whenJust (windows . f))
        | (k, sc) <- zip ["w", "e", "r"] [0..]
        , (f, m) <- [(W.view, ""), (W.shift, "S-")]]

------------------------------------------------------------------------
-- Mouse bindings
--
-- Focus rules
-- True if your focus should follow your mouse cursor.
myFocusFollowsMouse :: Bool
myFocusFollowsMouse = True

{-|
myMouseBindings (XConfig {XMonad.modMask = modMask}) = M.fromList $
  [
    -- mod-button1, Set the window to floating mode and move by dragging
    ((modMask, button1),
     (\w -> focus w >> mouseMoveWindow w))

    -- mod-button2, Raise the window to the top of the stack
    , ((modMask, button2),
       (\w -> focus w >> windows W.swapMaster))

    -- mod-button3, Set the window to floating mode and resize by dragging
    , ((modMask, button3),
       (\w -> focus w >> mouseResizeWindow w))

    -- you may also bind events to the mouse scroll wheel (button4 and button5)
  ]
-}

------------------------------------------------------------------------
-- Status bars and logging
-- Perform an arbitrary action on each internal state change or X event.
-- See the 'DynamicLog' extension for examples.
--
-- To emulate dwm's status bar
--
-- > logHook = dynamicLogDzen
--


------------------------------------------------------------------------
-- Startup hook
-- Perform an arbitrary action each time xmonad starts or is restarted
-- with mod-q.  Used by, e.g., XMonad.Layout.PerWorkspace to initialize
-- per-workspace layout choices.
--
-- By default, do nothing.
-- myStartupHook = return ()

------------------------------------------------------------------------
-- Run xmonad with all the defaults we set up.
--
main = do
  xmproc <- spawnPipe "xmobar ~/.xmonad/xmobar.hs"
  xmonad $ defaults
    {
      logHook = dynamicLogWithPP $ xmobarPP {
            ppOutput = hPutStrLn xmproc
          , ppTitle = xmobarColor xmobarTitleColor "" . shorten 100
          , ppCurrent = xmobarColor xmobarCurrentWorkspaceColor ""
          , ppSep = "   "
      }
--      , manageHook = manageDocks <+> myManageHook
    , startupHook = setWMName "LG3D"
    }

defaults = defaultConfig {
    -- simple stuff
    terminal           = myTerminal,
    focusFollowsMouse  = myFocusFollowsMouse,
    borderWidth        = myBorderWidth,
    modMask            = myModMask,
    workspaces         = myWorkspaces,
    normalBorderColor  = myNormalBorderColor,
    focusedBorderColor = myFocusedBorderColor,

    -- key bindings
    keys               = myKeys,
--    mouseBindings      = myMouseBindings,

    -- hooks, layouts
    layoutHook         = smartBorders $ myLayout
--    manageHook         = myManageHook,
--    startupHook        = myStartupHook
}
