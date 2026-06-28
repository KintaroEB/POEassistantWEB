#Include dependencies\includes\_INCLUDES_THREAD

global KeyDelayTimes := {}
global LastPressTime := {}

global BuffOverlayText
global BuffOverlayTime

; =========================
; BUFF OVERLAY SETTINGS
; =========================
global _TICKRATE := 250

global BUFF_NAME := "bedlam"
global BUFF_OVERLAY_TITLE := "BEDLAM"

; Use "CENTER" to center inside the active PoE window.
; Or set numbers, for example:
; global BUFF_OVERLAY_X := 800
; global BUFF_OVERLAY_Y := 450
global BUFF_OVERLAY_X := "CENTER"
global BUFF_OVERLAY_Y := "CENTER"

global BUFF_OVERLAY_W := 260
global BUFF_OVERLAY_H := 120

; Text edit settings
global BUFF_TITLE_FONT_SIZE := 16
global BUFF_TIME_FONT_SIZE := 12
global BUFF_TEXT_COLOR := "Red"
global BUFF_FONT_NAME := "Arial"

; Text box heights
global BUFF_TITLE_H := 20
global BUFF_TIME_H := 18

global BUFF_OVERLAY_CREATED := false
global BUFF_OVERLAY_VISIBLE := false

THREAD_WAIT(_TICK_UPDATE_WAIT*8)
LoadSettings()



; _____MAIN LOOP
Loop {
	if ( (_POEMEMORY.ERROR == "NONE") AND (InTown() == false) AND (_POEMEMORY.CURHP > 0) ) {
		if ( CheckPoeWindow() == true ) {

			buffName := BUFF_NAME

			if (_POEMEMORY.BUFFLIST.HasKey(buffName) AND _POEMEMORY.BUFFLIST[buffName].DURATION > 0.1 ) {
				ShowBuffOverlay(_POEMEMORY.BUFFLIST[buffName].DURATION)
			}
			else {
				HideBuffOverlay()
			}

		}
		else {
			HideBuffOverlay()
		}
	}
	else {
		HideBuffOverlay()
	}

	THREAD_WAIT(_TICKRATE)
}



; =========================
; BUFF OVERLAY FUNCTIONS
; =========================

CreateBuffOverlay() {
	global BUFF_OVERLAY_CREATED
	global BUFF_OVERLAY_W, BUFF_OVERLAY_H
	global BuffOverlayText, BuffOverlayTime

	global BUFF_TITLE_FONT_SIZE
	global BUFF_TIME_FONT_SIZE
	global BUFF_TEXT_COLOR
	global BUFF_FONT_NAME
	global BUFF_TITLE_H
	global BUFF_TIME_H

	if (BUFF_OVERLAY_CREATED)
		return

	Gui, BuffOverlay:New, +AlwaysOnTop -Caption +ToolWindow +E0x20 +LastFound
	Gui, BuffOverlay:Color, 010101

	Gui, BuffOverlay:Font, % "s" BUFF_TITLE_FONT_SIZE " Bold c" BUFF_TEXT_COLOR, %BUFF_FONT_NAME%
	Gui, BuffOverlay:Add, Text, vBuffOverlayText Center w%BUFF_OVERLAY_W% h%BUFF_TITLE_H% BackgroundTrans, BUFF

	Gui, BuffOverlay:Font, % "s" BUFF_TIME_FONT_SIZE " Bold c" BUFF_TEXT_COLOR, %BUFF_FONT_NAME%
	Gui, BuffOverlay:Add, Text, vBuffOverlayTime Center w%BUFF_OVERLAY_W% h%BUFF_TIME_H% BackgroundTrans, 0.0

	WinSet, TransColor, 010101

	BUFF_OVERLAY_CREATED := true
}

ShowBuffOverlay(duration) {
	global BUFF_OVERLAY_CREATED, BUFF_OVERLAY_VISIBLE
	global BUFF_OVERLAY_TITLE
	global BUFF_OVERLAY_W, BUFF_OVERLAY_H

	CreateBuffOverlay()

	GuiControl, BuffOverlay:, BuffOverlayText, %BUFF_OVERLAY_TITLE%
	GuiControl, BuffOverlay:, BuffOverlayTime, % Format("{:.1f}", duration)

	GetBuffOverlayPosition(x, y)

	if (!BUFF_OVERLAY_VISIBLE) {
		Gui, BuffOverlay:Show, x%x% y%y% w%BUFF_OVERLAY_W% h%BUFF_OVERLAY_H% NoActivate
		BUFF_OVERLAY_VISIBLE := true
	}
	else {
		; Keeps position updated if the PoE window moves.
		Gui, BuffOverlay:Show, x%x% y%y% NoActivate
	}
}

HideBuffOverlay() {
	global BUFF_OVERLAY_CREATED, BUFF_OVERLAY_VISIBLE

	if (!BUFF_OVERLAY_CREATED)
		return

	if (BUFF_OVERLAY_VISIBLE) {
		Gui, BuffOverlay:Hide
		BUFF_OVERLAY_VISIBLE := false
	}
}

GetBuffOverlayPosition(ByRef x, ByRef y) {
	global BUFF_OVERLAY_X, BUFF_OVERLAY_Y
	global BUFF_OVERLAY_W, BUFF_OVERLAY_H

	; Since CheckPoeWindow() is true when this is called,
	; the active window should be the PoE window.
	WinGetPos, wx, wy, ww, wh, A

	if (BUFF_OVERLAY_X == "CENTER")
		x := wx + (ww // 2) - (BUFF_OVERLAY_W // 2)
	else
		x := BUFF_OVERLAY_X

	if (BUFF_OVERLAY_Y == "CENTER")
		y := wy + (wh // 2) - (BUFF_OVERLAY_H // 2)
	else
		y := BUFF_OVERLAY_Y
}