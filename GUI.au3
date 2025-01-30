#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=C:\Program Files (x86)\AutoIt3\Icons\MyAutoIt3_Blue.ico
#AutoIt3Wrapper_Outfile=.out\PGN Tools.exe
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.16.1
 Author:         Mauer01

 Script Function:
#ce ----------------------------------------------------------------------------
#include <File.au3>
#include <Array.au3>
; Script Start - Add your code below here
#include <ButtonConstants.au3>
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <StaticConstants.au3>
#include <TreeViewConstants.au3>
#include <WindowsConstants.au3>
#Region ### START Koda GUI section ### Form=
$pgnTools = GUICreate("Pgn tools", 577, 324, 768, 252, -1, BitOR($WS_EX_ACCEPTFILES,$WS_EX_WINDOWEDGE))
$Input1 = GUICtrlCreateInput("", 424, 8, 121, 21)
$Input2 = GUICtrlCreateInput("", 424, 48, 121, 21)
$Input3 = GUICtrlCreateInput("", 424, 96, 121, 21)
$i_event = GUICtrlCreateInput("", 424, 128, 121, 21)
$i_game = GUICtrlCreateInput("", 424, 168, 121, 21)
$Label1 = GUICtrlCreateLabel("Date:", 376, 88, 30, 17)
$Label2 = GUICtrlCreateLabel("You", 384, 8, 23, 17)
$Label3 = GUICtrlCreateLabel("Opponent", 360, 48, 51, 17)
$Label4 = GUICtrlCreateLabel("Event:", 376, 128, 35, 17)
$Label5 = GUICtrlCreateLabel("Game:", 376, 168, 35, 17)
$i_folder = GUICtrlCreateInput("", 16, 8, 313, 21)
$btn_folder = GUICtrlCreateButton("Folder", 328, 8, 35, 25)
$tree_folders = GUICtrlCreateTreeView(16, 40, 241, 273, BitOR($GUI_SS_DEFAULT_TREEVIEW,$TVS_CHECKBOXES,$WS_HSCROLL,$WS_VSCROLL))

$btn_pgn = GUICtrlCreateButton("Tag Changer", 272, 40, 75, 25)
$btn_createCSV = GUICtrlCreateButton("Create CSV", 272, 72, 75, 25)
GUISetState(@SW_SHOW)
#EndRegion ### END Koda GUI section ###
local $Filetree
While 1
	$nMsg = GUIGetMsg()
	Switch $nMsg
		Case $GUI_EVENT_CLOSE
			Exit
		Case $btn_folder
			If IsMap($Filetree) Then
				deleteTreeItems($Filetree)
			EndIf
			$dir = FileSelectFolder("Select Folder",@HomePath,0)
			If @error Then ContinueCase
			GUICtrlSetData($i_folder,$dir)
			FileChangeDir($dir)
			$Filetree = setTreeItems($tree_folders,_FileListToArray($dir,"*",0,true))
		Case $btn_pgn
		Case $btn_createCSV
			local $map[]
			For $key in MapKeys($Filetree)
				If isChecked($key) Then
					MapAppend($map, $Filetree[$key])
				EndIf
			Next
			createCSV($map)

		Case Else
			If $nMsg <= 0 Then ContinueCase
			If not FileExists($Filetree[$nMsg]) then ContinueCase
			If StringInStr(FileGetAttrib($Filetree[$nMsg]),"D") > 0 Then
				$folder = $Filetree[$nMsg]
				$folderSize = DirGetSize($folder,1)
				$folderCount = $folderSize[2]+$folderSize[1]
				If isChecked($nMsg) Then
					For $i = 1 To $folderCount
						GUICtrlSetState($nMsg + $i, $GUI_CHECKED)
					Next
				Else
					For $i = 1 To $folderCount
						GUICtrlSetState($nMsg + $i, $GUI_UNCHECKED)
					Next
				EndIf
			ElseIf isTextFile($Filetree[$nMsg]) Then

			EndIf
	EndSwitch
WEnd

Func isChecked($control)
	Return BitAND(GUICtrlRead($control),$GUI_CHECKED)

EndFunc

Func setTreeItems($tree,$itemList)
	local $map[]
	If not IsArray($itemList) Then Return
	for $item in $itemList
		$filename = filegetname($item)
		If isNumber($item) Then ContinueLoop
		$isD = FileGetAttrib($item)
		If StringInStr($isD,"D") > 0 Then
			$filelist = _FileListToArray($item,"*",0,true)
			If IsArray($filelist) Then
				$key = GUICtrlCreateTreeViewItem($filename,$tree)
				$map[$key] = $item
				mapCombine($map, setTreeItems($key,$filelist))
			EndIf
		Else
			If isTextFile($item) then
				$map[GuictrlcreateTreeViewItem($filename,$tree)] = $item
			EndIf
		EndIf
	Next
	return $map
EndFunc
Func deleteTreeItems($map)
	For $key in MapKeys($map)
		GUICtrlDelete($key)
	Next
EndFunc
Func isTextFile($file)
	$split = StringSplit($file,".",2)
	if @error then return False
	If $split[1] = "txt" then
		return True
	EndIf
	Return False
EndFunc

Func mapCombine(ByRef $map1, ByRef $map2)
	For $key in MapKeys($map2)
		$map1[$key] = $map2[$key]
	Next
EndFunc
Func filegetname($fullPath)
	$lastSlashPos = StringInStr($fullPath, "\", 0, -1) ; Find last "\" position
	$filename = StringTrimLeft($fullPath, $lastSlashPos) ; Remove everything before last "\"
	return $filename
EndFunc



Func createCSV($filelist)
	$myself = "test"
	$seperator = ","
	local $csvfile[1] = ["Filename,GameNum,WhitePlayer,BlackPlayer,Game,White,Black,Date,Event,"]
	for $file in $filelist
		$filearray = FileReadToArray($file)
		if @error then
			ContinueLoop
		EndIf
		local $moves = '"',$whiteuser = $myself,$blackuser = $myself,$resultarray[2] = [0,0],$date= "01.01.2000",$event=""
		for $line in $filearray
			$switchstring = StringRegExp($line,"[a-zA-Z]+",3)
			if @error then ContinueLoop
			Switch $switchstring[0]
				Case "Result"
					$result = StringRegExp($line,'[01]-[01]',3)
					if @error = 0 Then $resultarray = StringSplit($result[0],"-",2)
				Case "Date"
					$date = StringRegExp($line,'[0-9]+.[0-9]+.[0-9]+',3)[0]
				Case "White"
					$user = StringRegExp($line,'"(.)+"',2)
					if @error = 0 then
						$whiteuser = $user[0]
						$whiteuser = StringTrimRight($whiteuser,1)
						$whiteuser = StringTrimLeft($whiteuser,1)
					EndIf
				Case "Black"
					$user = StringRegExp($line,'"(.)+"',2)
					if @error = 0 Then
						$blackuser = $user[0]
						$blackuser = StringTrimRight($blackuser,1)
						$blackuser = StringTrimLeft($blackuser,1)
					EndIf
				Case "Event"
					$event = StringRegExp($line,'"(.)+"',2)
					$event = StringTrimRight($event,1)
					$event = StringTrimLeft($event,1)
			EndSwitch

			if StringLeft($line,1) <> "[" Then
				$moves &= $line & @CRLf
			EndIf
		Next
		$moves = StringTrimRight($moves,StringLen(@CRLF)) & '"'
		$fullline = $file & $seperator & UBound($csvfile) & $seperator & $whiteuser & $seperator & $blackuser & $seperator & $moves & _
			$seperator & $resultarray[0] & $seperator & $resultarray[1] & $seperator & $date & $seperator & $event
		_ArrayAdd($csvfile,$fullline)
	Next
	$string = _ArrayToString($csvfile,"," & @CRLF)
	FileDelete(@ScriptDir & "\data.csv")
	FileWrite(@ScriptDir & "\data.csv",$string)
EndFunc

