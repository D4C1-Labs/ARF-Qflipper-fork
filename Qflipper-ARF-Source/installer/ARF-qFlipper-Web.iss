; Web installer: downloads the portable bundle ZIP from your site, then extracts to {app}.
; 1) Edit #define DownloadURL below to your deployed URL (same host as public/downloads/... in amau-zero-hub).
; 2) Run build_installer.bat — it builds arf-qflipper-win64.zip and can copy it to the site public folder.

#define MyAppName "ARF qFlipper"
#define MyAppNameShort "ARFqFlipper"
#define MyAppExeName "qFlipper.exe"
#define MyAppPublisher "ARF Firmware / Amau_Zero"
; Production site (HTTPS). ZIP must exist at this URL after deploy (public/downloads).
#define MyAppURL "https://amauzero.info"
#define DownloadURL "https://amauzero.info/downloads/arf-qflipper-win64.zip"

[Setup]
AppId={{C4A91F3E-8B2D-4E61-9F0A-1D2E3F4A5B6C}
AppName={#MyAppName}
AppVersion=1.0.0
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
DefaultDirName={autopf}\{#MyAppNameShort}
DefaultGroupName={#MyAppName}
AllowNoIcons=yes
InfoBeforeFile=installer_info_web_en.txt
LicenseFile=..\LICENSE
OutputDir=..\dist
OutputBaseFilename=ARF-qFlipper-Setup
SetupIconFile=..\application\assets\icons\qFlipper.ico
Compression=lzma2/max
SolidCompression=yes
PrivilegesRequired=admin
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64
UninstallDisplayIcon={app}\qFlipper.ico
DisableProgramGroupPage=yes
DisableWelcomePage=no
SetupLogging=yes
; Inno 6.7+ ignores BackColor on modern wizard — dark look comes from BMPs + system theme.
WizardStyle=modern
WizardImageFile=arf_wizard_large.bmp
WizardImageStretch=no
WizardSmallImageFile=arf_wizard_small.bmp
WizardImageBackColor=$060610
ShowLanguageDialog=yes
LanguageDetectionMethod=none
UsePreviousAppDir=yes
UsePreviousLanguage=yes
UsePreviousTasks=yes

[Languages]
; First language = default installer language.
Name: "english"; MessagesFile: "compiler:Default.isl"
Name: "french"; MessagesFile: "compiler:Languages\French.isl"
Name: "german"; MessagesFile: "compiler:Languages\German.isl"
Name: "spanish"; MessagesFile: "compiler:Languages\Spanish.isl"
Name: "italian"; MessagesFile: "compiler:Languages\Italian.isl"
Name: "portuguese"; MessagesFile: "compiler:Languages\Portuguese.isl"
Name: "brazilianportuguese"; MessagesFile: "compiler:Languages\BrazilianPortuguese.isl"
Name: "polish"; MessagesFile: "compiler:Languages\Polish.isl"
Name: "russian"; MessagesFile: "compiler:Languages\Russian.isl"
Name: "ukrainian"; MessagesFile: "compiler:Languages\Ukrainian.isl"
Name: "czech"; MessagesFile: "compiler:Languages\Czech.isl"
Name: "dutch"; MessagesFile: "compiler:Languages\Dutch.isl"
Name: "swedish"; MessagesFile: "compiler:Languages\Swedish.isl"
Name: "finnish"; MessagesFile: "compiler:Languages\Finnish.isl"
Name: "norwegian"; MessagesFile: "compiler:Languages\Norwegian.isl"
Name: "danish"; MessagesFile: "compiler:Languages\Danish.isl"
Name: "hungarian"; MessagesFile: "compiler:Languages\Hungarian.isl"
Name: "turkish"; MessagesFile: "compiler:Languages\Turkish.isl"
Name: "japanese"; MessagesFile: "compiler:Languages\Japanese.isl"
Name: "korean"; MessagesFile: "compiler:Languages\Korean.isl"
Name: "arabic"; MessagesFile: "compiler:Languages\Arabic.isl"
Name: "hebrew"; MessagesFile: "compiler:Languages\Hebrew.isl"
Name: "catalan"; MessagesFile: "compiler:Languages\Catalan.isl"
Name: "armenian"; MessagesFile: "compiler:Languages\Armenian.isl"
Name: "bulgarian"; MessagesFile: "compiler:Languages\Bulgarian.isl"
Name: "slovak"; MessagesFile: "compiler:Languages\Slovak.isl"
Name: "slovenian"; MessagesFile: "compiler:Languages\Slovenian.isl"
Name: "thai"; MessagesFile: "compiler:Languages\Thai.isl"
Name: "tamil"; MessagesFile: "compiler:Languages\Tamil.isl"
Name: "corsican"; MessagesFile: "compiler:Languages\Corsican.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
Source: "arf_web_download.ps1"; Flags: dontcopy
; Same .ico as in the ZIP — also installed after download so shortcuts never bind to the wrong PE icon index.
Source: "..\application\assets\icons\qFlipper.ico"; DestDir: "{app}"; DestName: "qFlipper.ico"; Flags: ignoreversion

[Icons]
Name: "{group}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; WorkingDir: "{app}"; IconFilename: "{app}\qFlipper.ico"
Name: "{group}\{cm:UninstallProgram,{#MyAppName}}"; Filename: "{uninstallexe}"
Name: "{commondesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon; WorkingDir: "{app}"; IconFilename: "{app}\qFlipper.ico"

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "{cm:LaunchProgram,{#MyAppName}}"; Flags: nowait postinstall skipifsilent

[UninstallDelete]
Type: filesandordirs; Name: "{app}"

[Code]
function PrepareToInstall(var NeedsRestart: Boolean): String;
var
  ResultCode: Integer;
  ScriptPath: String;
  AppDir: String;
begin
  Result := '';
  AppDir := ExpandConstant('{app}');
  ExtractTemporaryFile('arf_web_download.ps1');
  ScriptPath := ExpandConstant('{tmp}\arf_web_download.ps1');
  if Exec('powershell.exe', '-NoProfile -ExecutionPolicy Bypass -File "' + ScriptPath + '" -Url "' + '{#DownloadURL}' + '" -DestDir "' + AppDir + '"', '', SW_HIDE, ewWaitUntilTerminated, ResultCode) then
  begin
    if ResultCode <> 0 then
      Result := 'Download or extraction failed (exit code ' + IntToStr(ResultCode) + '). Check the URL and your network connection.';
  end
  else
    Result := 'Could not start PowerShell.';
end;
