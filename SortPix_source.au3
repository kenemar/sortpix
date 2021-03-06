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
#pragma compile (FileDescription, 'Script for sorting pictures to correct job folder as they are taken.')
#pragma compile (ProductName, 'SortPix')
#pragma compile(FileVersion, 2021.4.1)

;initialize from settings file in Local App Data
readSettings ()

;main GUI
Opt("GUIOnEventMode", 1) ; Change to OnEvent mode
;start GUI at the right of the desktop or not
If $GUIPosInit = 1 Then
   Local $hMainGUI = GUICreate("SortPix", 400, 450,@DesktopWidth - 420)
Else
   Local $hMainGUI = GUICreate("SortPix", 400, 450)
Endif
GUISetOnEvent($GUI_EVENT_CLOSE, "CLOSEButton")
GUISetState(@SW_SHOW, $hMainGUI)

;source
GUICtrlCreateLabel("Path to source directory (Camera Roll)", 20, 10)
Local $srcDir = GUICtrlCreateLabel($sourceFolderInit, 20, 30, 250 , 20, $SS_LEFTNOWORDWRAP)
GUICtrlSetFont($srcDir, 8.5, $FW_BOLD, $GUI_FONTUNDER)
Local $browseSourceButton = GUICtrlCreateButton("Browse", 295, 27, 70, 27)
GUICtrlSetOnEvent($browseSourceButton, "browseSource")

;destination
GUICtrlCreateLabel("Path to destination parent directory (folder that contains the job folders)", 20, 60)
Local $destDir = GUICtrlCreateLabel($destFolderInit, 20, 80, 250, 20)
GUICtrlSetFont($destDir, 8.5, $FW_BOLD, $GUI_FONTUNDER)
Local $browseDestButton = GUICtrlCreateButton("Browse", 295, 78, 70, 27)
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
Local $jobNum = GUICtrlCreateInput($jobNumInit, 60, 245, 100, 32)
GUICtrlSetFont($jobNum, 14, $FW_SEMIBOLD)
$jobNumLabel = GUICtrlCreateLabel("Job Number", 65, 220, 90)
GUICtrlSetFont($jobNumLabel, 11, $FW_BOLD)

;job number edit buttons
Local $NumBtn1 = GUICtrlCreateButton("1", 210, 225, 36, 32)
Local $NumBtn2 = GUICtrlCreateButton("2", 250, 225, 36, 32)
Local $NumBtn3 = GUICtrlCreateButton("3", 290, 225, 36, 32)
Local $NumBtn4 = GUICtrlCreateButton("4", 330, 225, 36, 32)
Local $NumBtn5 = GUICtrlCreateButton("5", 210, 265, 36, 32)
Local $NumBtn6 = GUICtrlCreateButton("6", 250, 265, 36, 32)
Local $NumBtn7 = GUICtrlCreateButton("7", 290, 265, 36, 32)
Local $NumBtn8 = GUICtrlCreateButton("8", 330, 265, 36, 32)
Local $NumBtn9 = GUICtrlCreateButton("9", 210, 305, 36, 32)
Local $NumBtn0 = GUICtrlCreateButton("0", 250, 305, 36, 32)
Local $NumBtnBack = GUICtrlCreateButton("<", 290, 305, 76, 32)
GUICtrlSetOnEvent ($NumBtn1,"NumBtn1")
GUICtrlSetOnEvent ($NumBtn2,"NumBtn2")
GUICtrlSetOnEvent ($NumBtn3,"NumBtn3")
GUICtrlSetOnEvent ($NumBtn4,"NumBtn4")
GUICtrlSetOnEvent ($NumBtn5,"NumBtn5")
GUICtrlSetOnEvent ($NumBtn6,"NumBtn6")
GUICtrlSetOnEvent ($NumBtn7,"NumBtn7")
GUICtrlSetOnEvent ($NumBtn8,"NumBtn8")
GUICtrlSetOnEvent ($NumBtn9,"NumBtn9")
GUICtrlSetOnEvent ($NumBtn0,"NumBtn0")
GUICtrlSetOnEvent ($NumBtnBack,"NumBtnBack")

;job folder button
Local $iJobFolderButton = GUICtrlCreateButton("Open Job Folder", 60, 305, 100, 32)
GUICtrlSetOnEvent($iJobFolderButton, "JOBFOLDERButton")

;GUI position checkbox
Global $GUIPosCheckbox = GUICtrlCreateCheckbox("Start SortPix at right of screen", 120, 355, 280, 25)
GUICtrlSetState ( $GUIPosCheckbox, $GUIPosInit )

;exit button
Local $iCLOSEButton = GUICtrlCreateButton("Exit", 170, 400, 60, 30)
GUICtrlSetOnEvent($iCLOSEButton, "CLOSEButton")

;initalize reference time
;get string representing current date and time without punctuation for use with calculating against creation date
$aRef = StringSplit(_NowCalc(), "/: ")
_ArrayDelete ($aRef, 0)
$ref = _ArrayToString( $aRef, "")

;initialize destination folder path
Global $destPath = GUICtrlRead($destDir)

;main loop
While 1
   If checkPaths() = 1 Then moveFiles() ;only run this loop while paths are valid
   Sleep(100) ; Sleep to reduce CPU usage
WEnd

Func JOBFOLDERButton()
   ;check if job folder path is valid before attempting to open
   If _WinAPI_PathIsDirectory ($destPath) Then
	  ShellExecute($destPath)
   Else
	  MsgBox($MB_ICONERROR, "Invalid Job Folder", "Set valid Source and Destination and Job Number.")
   EndIf
EndFunc

;functions for job number edit buttons
Func NumBtn1 ()
   GUICtrlSetData ($jobNum,(GUICtrlRead($jobNum)& "1"))
   FocusJobNum()
EndFunc

Func NumBtn2 ()
   GUICtrlSetData ($jobNum,(GUICtrlRead($jobNum)& "2"))
   FocusJobNum()
EndFunc

Func NumBtn3 ()
   GUICtrlSetData ($jobNum,(GUICtrlRead($jobNum)& "3"))
   FocusJobNum()
EndFunc

Func NumBtn4 ()
   GUICtrlSetData ($jobNum,(GUICtrlRead($jobNum)& "4"))
   FocusJobNum()
EndFunc

Func NumBtn5 ()
   GUICtrlSetData ($jobNum,(GUICtrlRead($jobNum)& "5"))
   FocusJobNum()
EndFunc

Func NumBtn6 ()
   GUICtrlSetData ($jobNum,(GUICtrlRead($jobNum)& "6"))
   FocusJobNum()
EndFunc

Func NumBtn7 ()
   GUICtrlSetData ($jobNum,(GUICtrlRead($jobNum)& "7"))
   FocusJobNum()
EndFunc

Func NumBtn8 ()
   GUICtrlSetData ($jobNum,(GUICtrlRead($jobNum)& "8"))
   FocusJobNum()
EndFunc

Func NumBtn9 ()
   GUICtrlSetData ($jobNum,(GUICtrlRead($jobNum)& "9"))
   FocusJobNum()
EndFunc

Func NumBtn0 ()
   GUICtrlSetData ($jobNum,(GUICtrlRead($jobNum)& "0"))
   FocusJobNum()
EndFunc

Func NumBtnBack()
   GUICtrlSetState ($jobNum,$GUI_FOCUS)
   ControlSend($hMainGUI,"", $jobNum, "^{End}");Send Ctrl+End
   ControlSend($hMainGUI,"", $jobNum, "{BACKSPACE}");Send Backspace
EndFunc

Func FocusJobNum()
   GUICtrlSetState ($jobNum,$GUI_FOCUS)
   ControlSend($hMainGUI,"", $jobNum, "^{End}");Send Ctrl+End
EndFunc

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
   ;this code is to accomodate the old array-based config file and the new standard format .ini file.
   ;if old config file exits, read contents and then delete it
   Global $oldInitFile = @LocalAppDataDir & "\sortPix.ini"
   Global $initFile = @LocalAppDataDir & "\Sortpix\config.ini"
   If FileExists($oldInitFile) = 1 Then
	  ;read file to array
	  Local $aSettings
	  _FileReadToArray($oldInitFile, $aSettings)
	  ;verify array contains expected number of elements, if not, add empty elements
	  While $aSettings[0] < 7
		 _ArrayAdd($aSettings, "")
		 $aSettings[0] = $aSettings[0] + 1
	  WEnd
	  parseInitArray($aSettings)
	  FileDelete($oldInitFile)	;delete old configuration file

   Else
	  ;load configuration from .ini file
	  Global $sourceFolderInit = IniRead($initFile, "folders", "sourceFolderPath", "select folder")
	  Global $destFolderInit = IniRead($initFile, "folders", "destinationFolderPath", "select folder")
	  Global $picsCheckboxInit = IniRead($initFile, "folders", "picsFolderCheckbox", "0")
	  Global $jobNumInit = IniRead($initFile, "jobNumber", "jobNumber", "")
	  Global $jobNumPrefInit = IniRead($initFile, "jobNumber", "jobNumberPrefix", "0")
	  Global $jobNumSufInit = IniRead($initFile, "jobNumber", "jobNumberSuffix", "")
	  Global $GUIPosInit = IniRead($initFile, "GUI", "GUIPositionCheckbox", "1")

   EndIf



EndFunc

Func parseInitArray($aSettings)
   ;only for loading config from old array-based config file
   ;load variables from array: source dir, dest dir, pic checkbox, jobnum pref and suf, job num
   Global $sourceFolderInit = $aSettings[1]
   Global $destFolderInit = $aSettings[2]
   Global $jobNumPrefInit = $aSettings[3]
   Global $jobNumSufInit = $aSettings[4]
   Global $picsCheckboxInit = $aSettings[5]
   Global $jobNumInit = $aSettings[6]
   Global $GUIPosInit = $aSettings[7]

EndFunc

Func writeSettings ()
   ;check for config folder, create if it doesn't exist
   If (_WinAPI_PathIsDirectory (@LocalAppDataDir & "\Sortpix") = False) Then
	  DirCreate(@LocalAppDataDir & "\Sortpix")
   EndIf

   ;write ini File
   IniWrite ($initFile,"folders", "sourceFolderPath", GUICtrlRead($srcDir))
   IniWrite ($initFile,"folders", "destinationFolderPath", GUICtrlRead($destDir))
   IniWrite ($initFile,"folders", "picsFolderCheckbox", GUICtrlRead($picsCheckbox))
   IniWrite ($initFile,"jobNumber", "jobNumber", GUICtrlRead($jobNum))
   IniWrite ($initFile,"jobNumber", "jobNumberPrefix", GUICtrlRead($jobNumPref))
   IniWrite ($initFile,"jobNumber", "jobNumberSuffix", GUICtrlRead($jobNumSuf))
   IniWrite ($initFile,"GUI", "GUIPositionCheckbox", GUICtrlRead($GUIPosCheckbox))

EndFunc

Func moveFiles()
	  Local $aFileList = _FileListToArray($srcPath, "*")
	  If (_WinAPI_PathIsDirectoryEmpty ($srcPath) = False) Then	;check if source folder is empty

		 _ArrayDelete ($aFileList, 0)	;delete first element in array (number of elements)

		 For $fileName in $aFileList
			$created = FileGetTime ($srcPath & "\" & $fileName, $FT_CREATED, $FT_STRING)
			If $created > $ref Then	;check if file was created after script started
			   Sleep(500) ; Sleep to make sure file is fully written
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
