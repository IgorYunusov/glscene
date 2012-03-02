//
// This unit is part of the GLScene Project, http://glscene.org
//
{ : PlugInManager<p>

  An old PlugIn Manager unit. Don't know if if ever wa used...<p>

  <b>Historique : </b><font size=-1><ul>
  <li>31/03/07 - DaStr - Added $I GLScene.inc
  <li>28/07/01 -  EG   - Initial version
  </ul></font>
}
unit GLScene_PlugIn_Manager;

interface

{$I GLScene.inc}
{$ifndef GLS_OPENGL_ES}

uses {$IFDEF MSWINDOWS} Windows,{$ENDIF}
     {$IFDEF UNIX}
     Types, LCLType, dynlibs,
     {$ENDIF}
     Classes, GLScene_PlugIn_Types, SysUtils ;

type
  PPlugInEntry = ^TPlugInEntry;

  TPlugInEntry = record
    Path: TFileName;
    Handle: HINST;
    FileSize: Integer;
    FileDate: TDateTime;
    EnumResourcenames: TEnumResourceNames;
    GetServices: TGetServices;
    GetVendor: TGetVendor;
    GetDescription: TGetDescription;
    GetVersion: TGetVersion;
  end;

  TPlugInManager = class;

  TResourceManager = class(TComponent)
  public
    procedure Notify(Sender: TPlugInManager; Operation: TOperation;
      Service: TPIServiceType; PlugIn: Integer); virtual; abstract;
  end;

  TPlugInList = class(TStringList)
  private
    FOwner: TPlugInManager;
    function GetPlugInEntry(Index: Integer): PPlugInEntry;
    procedure SetPlugInEntry(Index: Integer; AEntry: PPlugInEntry);
  protected
    procedure DefineProperties(Filer: TFiler); override;
    procedure ReadPlugIns(Reader: TReader);
    procedure WritePlugIns(Writer: TWriter);
  public
    constructor Create(AOwner: TPlugInManager); virtual;
    procedure ClearList;
    property Objects[Index: Integer]: PPlugInEntry read GetPlugInEntry
      write SetPlugInEntry; default;
    property Owner: TPlugInManager read FOwner;
  end;

  PResManagerEntry = ^TResManagerEntry;

  TResManagerEntry = record
    Manager: TResourceManager;
    Services: TPIServices;
  end;

  TPlugInManager = class(TComponent)
  private
    FLibraryList: TPlugInList;
    FResManagerList: TList;
  protected
    procedure DoNotify(Operation: TOperation; Service: TPIServiceType;
      PlugIn: Integer);
    function FindResManager(AManager: TResourceManager): PResManagerEntry;
    function GetIndexFromFilename(FileName: String): Integer;
    function GetPlugInFromFilename(FileName: String): PPlugInEntry;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function AddPlugIn(Path: TFileName): Integer;
    procedure EditPlugInList;
    procedure RegisterResourceManager(AManager: TResourceManager;
      Services: TPIServices);
    procedure RemovePlugIn(Index: Integer);
    procedure UnRegisterRessourceManager(AManager: TResourceManager;
      Services: TPIServices);
  published
    property PlugIns: TPlugInList read FLibraryList write FLibraryList;
  end;

  // ------------------------------------------------------------------------------

  {$endif}

implementation

{$ifndef GLS_OPENGL_ES}

uses Dialogs, Forms, GLScene_PropertyEditor_PlugIn;

// ----------------- TPlugInList ------------------------------------------------

constructor TPlugInList.Create(AOwner: TPlugInManager);

begin
  inherited Create;
  FOwner := AOwner;
  Sorted := False;
  Duplicates := DupAccept;
end;

// ------------------------------------------------------------------------------

procedure TPlugInList.ClearList;

begin
  while Count > 0 do
    FOwner.RemovePlugIn(0);
end;

// ------------------------------------------------------------------------------

function TPlugInList.GetPlugInEntry(Index: Integer): PPlugInEntry;

begin
  Result := PPlugInEntry( inherited Objects[Index]);
end;

// ------------------------------------------------------------------------------

procedure TPlugInList.SetPlugInEntry(Index: Integer; AEntry: PPlugInEntry);

begin
  inherited Objects[Index] := Pointer(AEntry);
end;

// ------------------------------------------------------------------------------

procedure TPlugInList.WritePlugIns(Writer: TWriter);

var
  I: Integer;

begin
  Writer.WriteListBegin;
  for I := 0 to Count - 1 do
    Writer.WriteString(Objects[I].Path);
  Writer.WriteListEnd;
end;

// ------------------------------------------------------------------------------

procedure TPlugInList.ReadPlugIns(Reader: TReader);

begin
  ClearList;
  Reader.ReadListBegin;
  while not Reader.EndOfList do
    FOwner.AddPlugIn(Reader.ReadString);
  Reader.ReadListEnd;
end;

// ------------------------------------------------------------------------------

procedure TPlugInList.DefineProperties(Filer: TFiler);

begin
  Filer.DefineProperty('Paths', ReadPlugIns, WritePlugIns, Count > 0);
end;

// ----------------- TPlugInManager ---------------------------------------------

constructor TPlugInManager.Create(AOwner: TComponent);

begin
  inherited Create(AOwner);
  FLibraryList := TPlugInList.Create(Self);
  FResManagerList := TList.Create;
end;

// ------------------------------------------------------------------------------

destructor TPlugInManager.Destroy;
var
  I: Integer;
begin
  FLibraryList.ClearList;
  FLibraryList.Free;
  for I := 0 to FResManagerList.Count - 1 do
    FreeMem(PResManagerEntry(FResManagerList[I]), SizeOf(TResManagerEntry));
  FResManagerList.Free;
  inherited Destroy;
end;

// ------------------------------------------------------------------------------

function TPlugInManager.AddPlugIn(Path: TFileName): Integer;

// open the given DLL and read its properties, to identify
// whether it's a valid plug-in or not

var
  NewPlugIn: PPlugInEntry;
  OldError: Integer;
  NewHandle: HINST;
  ServiceFunc: TGetServices;
  SearchRec: TSearchRec;
  Service: TPIServiceType;
  Services: TPIServices;

begin

  Result := -1;
  {$IFDEF MSWINDOWS}
  OldError := SetErrorMode(SEM_NOOPENFILEERRORBOX);    //On UNIX No TESTED
  {$ENDIF }
  if Length(Path) > 0 then
    try
      Result := GetIndexFromFilename(Path);
      // plug-in already registered?
      if Result > -1 then
        Exit;
      // first step is loading the file into client memory
      NewHandle := LoadLibrary(PChar(Path));
      // loading failed -> exit
      if NewHandle = 0 then
        Abort;
      // get the service function address to identify the plug-in
      ServiceFunc := GetProcAddress(NewHandle, 'GetServices');
      if not assigned(ServiceFunc) then
      begin
        // if address not found then the given library is not valid
        // release it from client memory
        FreeLibrary(NewHandle);
        Abort;
      end;
      // all went fine so far, we just loaded a valid plug-in
      // allocate a new entry for the plug-in list and fill it
      New(NewPlugIn);
      NewPlugIn.Path := Path;
      with NewPlugIn^ do
      begin
        Handle := NewHandle;
        FindFirst(Path, faAnyFile, SearchRec);
        FileSize := SearchRec.Size;
        FileDate :=
{$IFDEF GLS_DELPHI_XE_UP}
      SearchRec.TimeStamp;
{$ELSE}
      FileDateToDateTime(SearchRec.Time);
{$ENDIF}
        FindClose(SearchRec);
        GetServices := ServiceFunc;
        EnumResourcenames := GetProcAddress(Handle, 'EnumResourceNames');
        GetVendor := GetProcAddress(Handle, 'GetVendor');
        GetVersion := GetProcAddress(Handle, 'GetVersion');
        GetDescription := GetProcAddress(Handle, 'GetDescription');
      end;
      Result := FLibraryList.Add(string(NewPlugIn.GetVendor));
      FLibraryList.Objects[Result] := NewPlugIn;
      // now notify (for all provided services) all registered resource managers
      // for which these services are relevant
      Services := NewPlugIn.GetServices;
      for Service := Low(TPIServiceType) to High(TPIServiceType) do
        if Service in Services then
          DoNotify(opInsert, Service, Result);
    finally
        {$IFDEF MSWINDOWS}
      SetErrorMode(OldError);
          {$ENDIF }
    end;
end;

// ------------------------------------------------------------------------------

procedure TPlugInManager.DoNotify(Operation: TOperation;
  Service: TPIServiceType; PlugIn: Integer);

var
  I: Integer;

begin
  for I := 0 TO FResManagerList.Count - 1 do
    if Service in PResManagerEntry(FResManagerList[I]).Services then
      PResManagerEntry(FResManagerList[I]).Manager.Notify(Self, Operation,
        Service, PlugIn);
end;

// ------------------------------------------------------------------------------

function TPlugInManager.FindResManager(AManager: TResourceManager)
  : PResManagerEntry;

var
  I: Integer;

begin
  Result := nil;
  for I := 0 to FResManagerList.Count - 1 do
    if PResManagerEntry(FResManagerList[I]).Manager = AManager then
    begin
      Result := PResManagerEntry(FResManagerList[I]);
      Exit;
    end;
end;

// ------------------------------------------------------------------------------

function TPlugInManager.GetIndexFromFilename(FileName: String): Integer;

var
  I: Integer;

begin
  Result := -1;
  for I := 0 to FLibraryList.Count - 1 do
    if CompareText(FLibraryList[I].Path, FileName) = 0 then
    begin
      Result := I;
      Exit;
    end;
end;

// ------------------------------------------------------------------------------

function TPlugInManager.GetPlugInFromFilename(FileName: String): PPlugInEntry;

var
  I: Integer;

begin
  I := GetIndexFromFilename(FileName);
  if I > -1 then
    Result := FLibraryList[I]
  else
    Result := nil;
end;

// ------------------------------------------------------------------------------

procedure TPlugInManager.RegisterResourceManager(AManager: TResourceManager;
  Services: TPIServices);

var
  ManagerEntry: PResManagerEntry;

begin
  ManagerEntry := FindResManager(AManager);
  if assigned(ManagerEntry) then
    ManagerEntry.Services := ManagerEntry.Services + Services
  else
  begin
    New(ManagerEntry);
    ManagerEntry.Manager := AManager;
    ManagerEntry.Services := Services;
    FResManagerList.Add(ManagerEntry);
  end;
end;

// ------------------------------------------------------------------------------

procedure TPlugInManager.RemovePlugIn(Index: Integer);

var
  Entry: PPlugInEntry;
  Service: TPIServiceType;
  Services: TPIServices;

begin
  Entry := FLibraryList.Objects[Index];
  Services := Entry.GetServices;
  // notify for all services to be deleted all registered resource managers
  // for which these services are relevant
  for Service := Low(TPIServiceType) to High(TPIServiceType) do
    if Service in Services then
      DoNotify(opRemove, Service, Index);
  FreeLibrary(Entry.Handle);
  Dispose(Entry);
  FLibraryList.Delete(Index);
end;

// ------------------------------------------------------------------------------

procedure TPlugInManager.EditPlugInList;

begin
  TPlugInManagerPropForm.EditPlugIns(Self);
end;

// ------------------------------------------------------------------------------

procedure TPlugInManager.UnRegisterRessourceManager(AManager: TResourceManager;
  Services: TPIServices);

var
  ManagerEntry: PResManagerEntry;
  Index: Integer;

begin
  ManagerEntry := FindResManager(AManager);
  if assigned(ManagerEntry) then
  begin
    ManagerEntry.Services := ManagerEntry.Services - Services;
    if ManagerEntry.Services = [] then
    begin
      Index := FResManagerList.IndexOf(ManagerEntry);
      Dispose(ManagerEntry);
      FResManagerList.Delete(Index);
    end;
  end;
end;

{$endif}
// ------------------------------------------------------------------------------

end.