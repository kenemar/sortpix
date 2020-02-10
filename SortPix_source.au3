#include <GUIConstantsEx.au3>
#include <ColorConstants.au3>
#include <FontConstants.au3>
#include <MsgBoxConstants.au3>
#include <WindowsConstants.au3>
#include <WinAPIFiles.au3>
#include <FileConstants.au3>
#include <StaticConstants.au3>
#include <Array.au3>
#include <File.au3>
#include <Date.au3>

#pragma compile (CompanyName, 'Kendall Martin')
#pragma compile (FileDescription, 'Script designed for sorting pictures to correct job folder as they are taken.')
#pragma compile (ProductName, 'SortPix')
#pragma compile(FileVersion, 2020.2.1)

;initialize from settings file in Local App Data
readSettings ()

;main GUI
Opt("GUIOnEventMode", 1) ; Change to OnEvent mode
Local $hMainGUI = GUICreate("SortPix", 420, 350)
GUISetOnEvent($GUI_EVENT_CLOSE, "CLOSEButton")
GUISetState(@SW_SHOW, $hMainGUI)

;source
GUICtrlCreateLabel("Path to source directory (Camera Roll)", 20, 10)
Local $srcDir = GUICtrlCreateLabel($sourceFolderInit, 20, 30, 250 , 20, $SS_LEFTNOWORDWRAP)
GUICtrlSetFont($srcDir, 8.5, $FW_BOLD, $GUI_FONTUNDER)
Local $browseSourceButton = GUICtrlCreateButton("Browse", 280, 27, 70, 24)
GUICtrlSetOnEvent($browseSourceButton, "browseSource")

;destination
GUICtrlCreateLabel("Path to destination parent directory (folder that contains the job folders)", 20, 60)
Local $destDir = GUICtrlCreateLabel($destFolderInit, 20, 80, 250, 20)
GUICtrlSetFont($destDir, 8.5, $FW_BOLD, $GUI_FONTUNDER)
Local $browseDestButton = GUICtrlCreateButton("Browse", 280, 78, 70, 24)
GUICtrlSetOnEvent($browseDestButton, "browseDest")

;job folder name
GUICtrlCreateLabel("Job Folder Name Settings:", 20, 130)
GUICtrlCreateLabel("Prefix", 160, 110)
Local $jobNumPref = GUICtrlCreateInput($jobNumPrefInit, 155, 127, 40, 20)
GUICtrlCreateLabel("<job#>", 200, 130)
GUICtrlCreateLabel("Suffix", 244, 110)
Local $jobNumSuf = GUICtrlCreateInput($jobNumSufInit, 238, 127, 40, 20)

;pictures folder checkbox
Global $picsCheckbox = GUICtrlCreateCheckbox("Move to subfolder 'Pictures' (create if it doesn't exist)", 50, 160, 280, 25)
GUICtrlSetState ( $picsCheckbox, $picsCheckboxInit )

;valid paths
$pathIsValid = GUICtrlCreateLabel("validate paths", 50, 190, 330)

;job number
Local $jobNum = GUICtrlCreateInput($jobNumInit, 160, 245, 100, 32)
GUICtrlSetFont($jobNum, 14, $FW_SEMIBOLD)
$jobNumLabel = GUICtrlCreateLabel("Job Number", 165, 220, 90)
GUICtrlSetFont($jobNumLabel, 11, $FW_BOLD)

;exit button
Local $iCLOSEButton = GUICtrlCreateButton("Exit", 181, 300, 60)
GUICtrlSetOnEvent($iCLOSEButton, "CLOSEButton")

;initalize reference time
;get string representing current date and time without punctuation for use with calculating against creation date
$aRef = StringSplit(_NowCalc(), "/: ")
_ArrayDelete ($aRef, 0)
$ref = _ArrayToString( $aRef, "")


While 1
   If checkPaths() = 1 Then moveFiles() ;only run this loop while paths are valid
   Sleep(100) ; Sleep to reduce CPU usage
WEnd

Func CLOSEButton() ;write config to file and close
	writeSettings()
    Exit
 EndFunc

Func browseSource ()
   Global $sourceFolder = FileSelectFolder("Select source folder - (Camera Roll)", GUICtrlRead($srcDir))
   If $sourceFolder = Not "" Then GUICtrlSetData($srcDir, $sourceFolder)
EndFunc

Func browseDest ()
   Global $destFolder = FileSelectFolder("Select destination folder - folder that contains the job folders", GUICtrlRead($destDir))
   If $destFolder = Not "" Then GUICtrlSetData($destDir, $destFolder)
EndFunc

Func readSettings ()
   ;read file to array
   Global $initFile = @LocalAppDataDir & "\sortPix.ini"
   If FileExists($initFile) = 1 Then
	  Local $aSettings
	  _FileReadToArray($initFile, $aSettings)
   Else
	  Local $aSettings = ["","select folder","select folder","0","","",""]
   EndIf

   ;load variables from array: source dir, dest dir, pic checkbox, jobnum pref and suf, job num
   Global $sourceFolderInit = $aSettings[1]
   Global $destFolderInit = $aSettings[2]
   Global $jobNumPrefInit = $aSettings[3]
   Global $jobNumSufInit = $aSettings[4]
   Global $picsCheckboxInit = $aSettings[5]
   Global $jobNumInit = $aSettings[6]

EndFunc

Func writeSettings ()
   Local $aSettingsWrite[] = ["", GUICtrlRead($srcDir), GUICtrlRead($destDir), GUICtrlRead($jobNumPref), GUICtrlRead($jobNumSuf), GUICtrlRead($picsCheckbox), GUICtrlRead($jobNum)]
   _FileWriteFromArray(@LocalAppDataDir & "\sortPix.ini", $aSettingsWrite, 1)
EndFunc

Func moveFiles()
	  Local $aFileList = _FileListToArray($srcPath, "*")
	  If (_WinAPI_PathIsDirectoryEmpty ($srcPath) = False) Then	;check if source folder is empty

		 _ArrayDelete ($aFileList, 0)	;delete first element in array (number of elements)

		 For $fileName in $aFileList
			$created = FileGetTime ($srcPath & "\" & $fileName, $FT_CREATED, $FT_STRING)
			If $created > $ref Then	;check if file was created after script started
			   FileMove ($srcPath & "\" & $filename, $destPath & "\" & $fileName, $FC_CREATEPATH)   ;move file to destination directory
			EndIf
		 Next

	  Endif

EndFunc

Func checkPaths()
   Global $srcPath = GUICtrlRead($srcDir)
   $dPath = GUICtrlRead($destDir) & "\" & GUICtrlRead($jobNumPref) & GUICtrlRead($jobNum) & GUICtrlRead($jobNumSuf)
   If _WinAPI_PathIsDirectory ($srcPath) And _WinAPI_PathIsDirectory ($dPath) Then
	  GUICtrlSetData ($pathIsValid, "Folder paths and job number OK. Ready to sort pictures.")
	  GUICtrlSetColor($pathIsValid, $COLOR_GREEN)
	  If GUICtrlRead($picsCheckbox) = $GUI_CHECKED Then
		 Select
		 Case _WinAPI_PathIsDirectory ($dPath & "\pics")
			Global $destPath = ($dPath & "\pics")
		 Case _WinAPI_PathIsDirectory ($dPath & "\photos")
			Global $destPath = ($dPath & "\photos")
		 Case Else
			Global $destPath = ($dPath & "\Pictures")
		 EndSelect
	  Else
		 Global $destPath = $dPath
	  EndIf
	  Return 1
   Else
	  GUICtrlSetData ($pathIsValid, "Folders are invalid/inaccessible. Check path names and job number.")
	  GUICtrlSetColor($pathIsValid, $COLOR_RED)
	  Return 0
   EndIf
EndFunc
