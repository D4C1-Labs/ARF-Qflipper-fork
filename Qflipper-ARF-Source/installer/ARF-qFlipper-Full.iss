; Offline / full bundle: packs dist\ARF-qFlipper (run build_installer.bat first).

#define MyAppName "ARF qFlipper"
#define MyAppNameShort "ARFqFlipper"
#define MyAppExeName "qFlipper.exe"
#define MyAppPublisher "ARF Firmware / Amau_Zero"
#define MyAppURL "https://amauzero.info"
#define DistDir "..\\dist\\ARF-qFlipper"

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
InfoBeforeFile=installer_info_full_en.txt
LicenseFile=..\LICENSE
OutputDir=..\dist
OutputBaseFilename=ARF-qFlipper-Full-Setup
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
WizardStyle=modern
WizardImageFile=arf_wizard_large.bmp
WizardImageStretch=no
WizardSmallImageFile=arf_wizard_small.bmp
WizardImageBackColor=$060610
ShowLanguageDialog=yes
LanguageDetectionMethod=none
UsePreviousAppDir=yes

[Languages]
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
Source: "{#DistDir}\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{group}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; WorkingDir: "{app}"; IconFilename: "{app}\qFlipper.ico"
Name: "{group}\{cm:UninstallProgram,{#MyAppName}}"; Filename: "{uninstallexe}"
Name: "{commondesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon; WorkingDir: "{app}"; IconFilename: "{app}\qFlipper.ico"

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "{cm:LaunchProgram,{#MyAppName}}"; Flags: nowait postinstall skipifsilent

[Code]
function IsOriginalQFlipperName(const DisplayName: String): Boolean;
var
  NameLower: String;
begin
  NameLower := Lowercase(DisplayName);
  Result := (Pos('qflipper', NameLower) > 0) and (Pos('arf', NameLower) = 0);
end;

function TryReadUninstallCmd(const RootKey: Integer; const SubKey: String; var UninstallCmd: String): Boolean;
begin
  Result := False;
  if RegQueryStringValue(RootKey, SubKey, 'QuietUninstallString', UninstallCmd) and (Trim(UninstallCmd) <> '') then
  begin
    Result := True;
    Exit;
  end;

  if RegQueryStringValue(RootKey, SubKey, 'UninstallString', UninstallCmd) and (Trim(UninstallCmd) <> '') then
    Result := True;
end;

function FindOriginalQFlipperUninstaller(var UninstallCmd: String): Boolean;
var
  Keys: TArrayOfString;
  I: Integer;
  BaseKey, DisplayName: String;
begin
  Result := False;
  BaseKey := 'Software\Microsoft\Windows\CurrentVersion\Uninstall';

  if RegGetSubkeyNames(HKLM64, BaseKey, Keys) then
    for I := 0 to GetArrayLength(Keys) - 1 do
      if RegQueryStringValue(HKLM64, BaseKey + '\' + Keys[I], 'DisplayName', DisplayName) and IsOriginalQFlipperName(DisplayName) and
         TryReadUninstallCmd(HKLM64, BaseKey + '\' + Keys[I], UninstallCmd) then begin Result := True; Exit; end;

  if RegGetSubkeyNames(HKLM32, BaseKey, Keys) then
    for I := 0 to GetArrayLength(Keys) - 1 do
      if RegQueryStringValue(HKLM32, BaseKey + '\' + Keys[I], 'DisplayName', DisplayName) and IsOriginalQFlipperName(DisplayName) and
         TryReadUninstallCmd(HKLM32, BaseKey + '\' + Keys[I], UninstallCmd) then begin Result := True; Exit; end;

  if RegGetSubkeyNames(HKCU64, BaseKey, Keys) then
    for I := 0 to GetArrayLength(Keys) - 1 do
      if RegQueryStringValue(HKCU64, BaseKey + '\' + Keys[I], 'DisplayName', DisplayName) and IsOriginalQFlipperName(DisplayName) and
         TryReadUninstallCmd(HKCU64, BaseKey + '\' + Keys[I], UninstallCmd) then begin Result := True; Exit; end;

  if RegGetSubkeyNames(HKCU32, BaseKey, Keys) then
    for I := 0 to GetArrayLength(Keys) - 1 do
      if RegQueryStringValue(HKCU32, BaseKey + '\' + Keys[I], 'DisplayName', DisplayName) and IsOriginalQFlipperName(DisplayName) and
         TryReadUninstallCmd(HKCU32, BaseKey + '\' + Keys[I], UninstallCmd) then begin Result := True; Exit; end;
end;

function RunOriginalQFlipperUninstall(const UninstallCmd: String): Boolean;
var
  ResultCode: Integer;
  CmdLine: String;
begin
  CmdLine := '/C ' + AddQuotes(UninstallCmd + ' /VERYSILENT /SUPPRESSMSGBOXES /NORESTART');
  Result := Exec('cmd.exe', CmdLine, '', SW_HIDE, ewWaitUntilTerminated, ResultCode) and (ResultCode = 0);
end;

function PrepareToInstall(var NeedsRestart: Boolean): String;
var
  UninstallCmd: String;
begin
  Result := '';
  if FindOriginalQFlipperUninstaller(UninstallCmd) then
    if not RunOriginalQFlipperUninstall(UninstallCmd) then
      Result := 'Unable to uninstall original qFlipper automatically. Please uninstall qFlipper and retry.';
end;
