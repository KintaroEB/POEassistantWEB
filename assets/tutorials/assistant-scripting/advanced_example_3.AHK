#NoEnv
#SingleInstance Force
#InstallKeybdHook
#UseHook On
SetBatchLines, -1
SendMode Event
SetKeyDelay, 30, 30

#Include dependencies\includes\_INCLUDES_THREAD

global KeyDelayTimes := {}
global LastPressTime := {}

; =========================
global delayAfterT := 300
global qHoldDelay := 1400
global tTapDelay := 50
global ScriptActive := false
Hotkey, $q, DoDelayedQ
; =========================



THREAD_WAIT(_TICK_UPDATE_WAIT*8)
LoadSettings()

; =========================
; MAIN LOOP
; =========================

Loop {
    ScriptActive := false

    if ( (_POEMEMORY.ERROR == "NONE") AND (InTown() == false) AND (_POEMEMORY.CURHP > 0) ) {
        if ( CheckPoeWindow() == true ) {
            ScriptActive := true
        }
    }

    THREAD_WAIT(_TICK_UPDATE_CRITICAL)
}

; =========================
; HOTKEY LOGIC
; =========================

DoDelayedQ:
    if (!ScriptActive) {
        Send {q}
        return
    }

    KeyWait, q

    SendEvent, {SC014 down}
    Sleep, %tTapDelay%
    SendEvent, {SC014 up}

    Sleep, %delayAfterT%

    SendEvent, {SC010 down}
    Sleep, %qHoldDelay%
    SendEvent, {SC010 up}
return