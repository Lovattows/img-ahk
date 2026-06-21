#Requires AutoHotkey v2.0
#SingleInstance Force

CoordMode "Pixel", "Screen"
CoordMode "Mouse", "Screen"

; ==========================
; VARIÁVEIS
; ==========================
global stashes := Map()
global selectedStashes := []
global selectedHours := []
global ultimaExecucao := ""

; ==========================
; IMAGENS
; ==========================
stashLinks := [
    "https://github.com/Lovattows/img-ahk/blob/main/stash1.png?raw=true",
    "https://github.com/Lovattows/img-ahk/blob/main/stash2.png?raw=true",
    "https://github.com/Lovattows/img-ahk/blob/main/stash3.png?raw=true",
    "https://github.com/Lovattows/img-ahk/blob/main/stash4.png?raw=true",
    "https://github.com/Lovattows/img-ahk/blob/main/stash5.png?raw=true",
    "https://github.com/Lovattows/img-ahk/blob/f45e694b99257b4ddcddf80ed8ec22b8c6285777c/stash6.png?raw=true",
    "https://github.com/Lovattows/img-ahk/blob/f45e694b99257b4ddcddf80ed8ec22b8c6285777c/stash7.png?raw=true"
]

btnImg := A_Temp "\btn.png"

Loop 7
{
    path := A_Temp "\stash" A_Index ".png"
    stashes[A_Index] := path
    Download(stashLinks[A_Index], path)
}

Download(
    "https://raw.githubusercontent.com/Lovattows/img-ahk/f45e694b99257b4ddcddf80ed8ec22b8c6285777c/btn.png",
    btnImg
)

OnExit LimparArquivos

; ==========================
; GUI (ALTURA DINÂMICA)
; ==========================
myGui := Gui("+AlwaysOnTop", "Configuração")
myGui.SetFont("s9", "Segoe UI")

myGui.MarginX := 10
myGui.MarginY := 10

; ==========================
; CONTROLE DE LINHAS
; ==========================
leftY := 10
rightY := 10
lineH := 24

; ==========================
; COLUNA ESQUERDA - BAÚS
; ==========================
myGui.Add("Text", "x10 y" leftY " w190", "BAÚS")
leftY += lineH

stashChecks := []
Loop 7
{
    stashChecks.Push(
        myGui.Add("CheckBox", "x10 y" leftY " w190", "Baú " A_Index)
    )
    leftY += lineH
}

; ==========================
; COLUNA DIREITA - HORÁRIOS
; ==========================
myGui.Add("Text", "x220 y" rightY " w190", "HORÁRIOS")
rightY += lineH

hourList := [
    "01:00","04:00","07:00","10:00","13:00"
]

hourChecks := []
Loop hourList.Length
{
    hourChecks.Push(
        myGui.Add("CheckBox", "x220 y" rightY " w190", hourList[A_Index])
    )
    rightY += lineH
}

; ==========================
; MANUAL
; ==========================
rightY += 8
myGui.Add("Text", "x220 y" rightY " w190", "MANUAL (HH:MM)")
rightY += lineH

manualInput := myGui.Add("Edit", "x220 y" rightY " w100")

; ==========================
; BOTÃO
; ==========================
finalY := Max(leftY, rightY) + 20
myGui.Add("Button", "x10 y" finalY " w400", "Iniciar").OnEvent("Click", StartScript)

; 🔥 ALTURA AUTOMÁTICA (SEM TRAVAR TAMANHO)
myGui.Show("w420 h" finalY + 50)

; ==========================
; START
; ==========================
StartScript(*)
{
    global stashChecks, hourChecks, hourList
    global selectedStashes, selectedHours, manualInput

    selectedStashes := []
    selectedHours := []

    Loop 7
        if stashChecks[A_Index].Value
            selectedStashes.Push(A_Index)

    Loop hourChecks.Length
        if hourChecks[A_Index].Value
            selectedHours.Push(hourList[A_Index])

    manualHour := Trim(manualInput.Value)

    if (manualHour != "")
    {
        if !RegExMatch(manualHour, "^(?:[01]\d|2[0-3]):[0-5]\d$")
        {
            MsgBox "Horário inválido! Use HH:MM (00:00 - 23:59)"
            return
        }
        selectedHours.Push(manualHour)
    }

    if (selectedStashes.Length = 0)
    {
        MsgBox "Selecione pelo menos 1 baú!"
        return
    }

    if (selectedHours.Length = 0)
    {
        MsgBox "Selecione pelo menos 1 horário!"
        return
    }

    myGui.Destroy()
    SetTimer MainLoop, 1000
}

; ==========================
; LOOP
; ==========================
MainLoop()
{
    global selectedHours, ultimaExecucao

    hora := FormatTime(, "HH:mm")
    hoje := FormatTime(, "yyyyMMdd")

    for h in selectedHours
    {
        if (hora = h && ultimaExecucao != hoje hora)
        {
            RotinaCompleta()
            ultimaExecucao := hoje hora
            return
        }
    }
}

; ==========================
; ROTINA
; ==========================
RotinaCompleta()
{
    global selectedStashes, stashes, btnImg

    for stashID in selectedStashes
    {
        img := stashes[stashID]

        if ImageSearch(&x1, &y1, 0, 0, A_ScreenWidth, A_ScreenHeight, "*80 " img)
        {
            MouseMove x1 + 28, y1 + 15, 0
            Sleep 100
            Click "Left"

            Sleep 2000

            if ImageSearch(&x2, &y2, 0, 0, A_ScreenWidth, A_ScreenHeight, "*30 " btnImg)
            {
                MouseMove x2 + 60, y2 + 15, 0
                Sleep 100
                Click "Left"
            }
        }

        Sleep 1000
    }
}

; ==========================
; LIMPEZA
; ==========================
LimparArquivos(*)
{
    global stashes, btnImg

    for _, path in stashes
        try FileDelete(path)

    try FileDelete(btnImg)
}