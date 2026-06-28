#Include dependencies\includes\_INCLUDES_THREAD

global KeyDelayTimes := {}
global LastPressTime := {}
THREAD_WAIT(_TICK_UPDATE_WAIT*8)
LoadSettings()

; OVERLAY RELATED ___________________________________________________
	PrevVal1 := ""
	PrevVal2 := ""
	PrevVal3 := ""

	; Panel colors (1=blue, 2=green, 3=red)
	BG1Color := "0x1E4C7A"
	BG2Color := "0x1E7A4C"
	BG3Color := "0x7A1E1E"

	TextColor    := "White"
	CustomSize   := 16
	CustomFont   := "Segoe UI Bold"
	Transparency := 255

	; EDIT POSITION AND SIZE HERE
    OverlayX := 400
    OverlayY := 800
    OverlayW := 120
    OverlayH := 40
; ___________________________________________________________________

; UI_________________________________________________________________
	Gui +E0x20 -Caption +LastFound +ToolWindow +AlwaysOnTop
	Gui, Margin, 0, 0
	Gui, Font, s%CustomSize% Q4, %CustomFont%

	; Background panels
	Gui, Add, Progress, vBG1 x0 y0 w%OverlayW% h%OverlayH% c%BG1Color% Range0-100, 100
	Gui, Add, Progress, vBG2 x0 y0 w%OverlayW% h%OverlayH% c%BG2Color% Range0-100, 100
	Gui, Add, Progress, vBG3 x0 y0 w%OverlayW% h%OverlayH% c%BG3Color% Range0-100, 100

	; Text overlays (initially invisible until placed)
	Gui, Add, Text, vOverlayText1 c%TextColor% BackgroundTrans Center +0x200 x0 y0 w%OverlayW% h%OverlayH%
	Gui, Add, Text, vOverlayText2 c%TextColor% BackgroundTrans Center +0x200 x0 y0 w%OverlayW% h%OverlayH%
	Gui, Add, Text, vOverlayText3 c%TextColor% BackgroundTrans Center +0x200 x0 y0 w%OverlayW% h%OverlayH%

	WinSet, Transparent, %Transparency%
	Gui, Hide
	OverlayVisible := false
; ___________________________________________________________________

; _____MAIN LOOP
Loop {
	if ( (_POEMEMORY.ERROR == "NONE") AND (InTown() == false) AND (_POEMEMORY.CURHP > 0) ) {
		if ( CheckPoeWindow() == true ) {

			DisplayValue1 := ClampCharge(_POEMEMORY.BUFFLIST["power_charge"].CHARGES)
			DisplayValue2 := ClampCharge(_POEMEMORY.BUFFLIST["frenzy_charge"].CHARGES)
			DisplayValue3 := ClampCharge(_POEMEMORY.BUFFLIST["endurance_charge"].CHARGES)

			visCount := (DisplayValue1 ? 1 : 0) + (DisplayValue2 ? 1 : 0) + (DisplayValue3 ? 1 : 0)

			if (visCount > 0) {
			    availW := OverlayW
			    SlotW  := Floor(availW / visCount)
			    curX   := 0
			    placed := 0

			    if (DisplayValue1) {
			        placed++
			        w := (placed = visCount) ? (availW - SlotW*(visCount-1)) : SlotW
			        GuiControl, Move, BG1, x%curX% y0 w%w% h%OverlayH%
			        GuiControl, Move, OverlayText1, x%curX% y0 w%w% h%OverlayH%
			        GuiControl, Show, BG1
			        GuiControl, Show, OverlayText1
			        if (DisplayValue1 != PrevVal1) {
			            GuiControl,, OverlayText1, %DisplayValue1%
			            PrevVal1 := DisplayValue1
			        }
			        curX += w
			    } else {
			        GuiControl, Hide, BG1
			        GuiControl, Hide, OverlayText1
			        PrevVal1 := ""
			    }

			    if (DisplayValue2) {
			        placed++
			        w := (placed = visCount) ? (availW - SlotW*(visCount-1)) : SlotW
			        GuiControl, Move, BG2, x%curX% y0 w%w% h%OverlayH%
			        GuiControl, Move, OverlayText2, x%curX% y0 w%w% h%OverlayH%
			        GuiControl, Show, BG2
			        GuiControl, Show, OverlayText2
			        if (DisplayValue2 != PrevVal2) {
			            GuiControl,, OverlayText2, %DisplayValue2%
			            PrevVal2 := DisplayValue2
			        }
			        curX += w
			    } else {
			        GuiControl, Hide, BG2
			        GuiControl, Hide, OverlayText2
			        PrevVal2 := ""
			    }

			    if (DisplayValue3) {
			        placed++
			        w := (placed = visCount) ? (availW - SlotW*(visCount-1)) : SlotW
			        GuiControl, Move, BG3, x%curX% y0 w%w% h%OverlayH%
			        GuiControl, Move, OverlayText3, x%curX% y0 w%w% h%OverlayH%
			        GuiControl, Show, BG3
			        GuiControl, Show, OverlayText3
			        if (DisplayValue3 != PrevVal3) {
			            GuiControl,, OverlayText3, %DisplayValue3%
			            PrevVal3 := DisplayValue3
			        }
			        curX += w
			    } else {
			        GuiControl, Hide, BG3
			        GuiControl, Hide, OverlayText3
			        PrevVal3 := ""
			    }

			    if (!OverlayVisible) {
			        Gui, Show, NoActivate x%OverlayX% y%OverlayY% w%OverlayW% h%OverlayH%, NVC
			        OverlayVisible := true
			    }
			} else {
			    if (OverlayVisible) {
			        Gui, Hide
			        OverlayVisible := false
			    }
			    PrevVal1 := ""
			    PrevVal2 := ""
			    PrevVal3 := ""
			}
		}
		else {
		    if (OverlayVisible) {
		        Gui, Hide
		        OverlayVisible := false
		    }
		}
	}
	THREAD_WAIT(_TICK_UPDATE_CRITICAL)
}


; HELPER FUNCTIONS___________________________________________________
ClampCharge(val) {
    return (val >= 1 && val <= 20) ? val : 0
}
