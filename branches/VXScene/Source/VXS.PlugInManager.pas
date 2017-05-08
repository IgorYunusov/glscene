//
// VXScene Component Library, based on GLScene http://glscene.sourceforge.net 
//
{
  An old PlugIn Manager unit. Don't know if if ever wa used... 
  
}
unit VXS.PlugInManager;

interface

{$I VXScene.inc}

uses
  Winapi.Windows, System.Classes, System.SysUtils,
  FMX.Dialogs, FMX.Forms,

  VXS.PlugInIntf;


type
  PPlugInEntry = ^TVXPlugInEntry;

  TVXPlugInEntry = record
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

  TVXPlugInManager = class;

  TVXResourceManager = class(TComponent)
  public
    procedure Notify(Sender: TVXPlugInManager; Operation: TOperation;
      Service: TPIServiceType; PlugIn: Integer); virtual; abstract;
  end;

  TVXPlugInList = class(TStringList)
  private
    FOwner: TVXPlugInManager;
    function GetPlugInEntry(Index: Integer): PPlugInEntry;
    procedure SetPlugInEntry(Index: Integer; AEntry: PPlugInEntry);
  protected
    procedure DefineProperties(Filer: TFiler); override;
    procedure ReadPlugIns(Reader: TReader);
    procedure WritePlugIns(Writer: TWriter);
  public
    constructor Create(AOwner: TVXPlugInManager); virtual;
    procedure ClearList;
    property Objects[Index: Integer]: PPlugInEntry read GetPlugInEntry
      write SetPlugInEntry; default;
    property Owner: TVXPlugInManager read FOwner;
  end;

  PResManagerEntry = ^TResManagerEntry;

  TResManagerEntry = record
    Manager: TVXResourceManager;
    Services: TPIServices;
  end;

  TVXPlugInManager = class(TComponent)
  private
    FLibraryList: TVXPlugInList;
    FResManagerList: TList;
  protected
    procedure DoNotify(Operation: TOperation; Service: TPIServiceType;
      PlugIn: Integer);
    function FindResManager(AManager: TVXResourceManager): PResManagerEntry;
    function GetIndexFromFilename(FileName: String): Integer;
    function GetPlugInFromFilename(FileName: String): PPlugInEntry;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function AddPlugIn(Path: TFileName): Integer;
    procedure EditPlugInList;
    procedure RegisterResourceManager(AManager: TVXResourceManager;
      Services: TPIServices);
    procedure RemovePlugIn(Index: Integer);
    procedure UnRegisterRessourceManager(AManager: TVXResourceManager;
      Services: TPIServices);
  published
    property PlugIns: TVXPlugInList read FLibraryList write FLibraryList;
  end;

  // ------------------------------------------------------------------------------
implementation
// ----------------- TVXPlugInList ------------------------------------------------

constructor TVXPlugInList.Create(AOwner: TVXPlugInManager);

begin
  inherited Create;
  FOwner := AOwner;
  Sorted := False;
  Duplicates := DupAccept;
end;

// ------------------------------------------------------------------------------

procedure TVXPlugInList.ClearList;

begin
  while Count > 0 do
    FOwner.RemovePlugIn(0);
end;

// ------------------------------------------------------------------------------

function TVXPlugInList.GetPlugInEntry(Index: Integer): PPlugInEntry;

begin
  Result := PPlugInEntry( inherited Objects[Index]);
end;

// ------------------------------------------------------------------------------

procedure TVXPlugInList.SetPlugInEntry(Index: Integer; AEntry: PPlugInEntry);

begin
  inherited Objects[Index] := Pointer(AEntry);
end;

// ------------------------------------------------------------------------------

procedure TVXPlugInList.WritePlugIns(Writer: TWriter);

var
  I: Integer;

begin
  Writer.WriteListBegin;
  for I := 0 to Count - 1 do
    Writer.WriteString(Objects[I].Path);
  Writer.WriteListEnd;
end;

// ------------------------------------------------------------------------------

procedure TVXPlugInList.ReadPlugIns(Reader: TReader);

begin
  ClearList;
  Reader.ReadListBegin;
  while not Reader.EndOfList do
    FOwner.AddPlugIn(Reader.ReadString);
  Reader.ReadListEnd;
end;

// ------------------------------------------------------------------------------

procedure TVXPlugInList.DefineProperties(Filer: TFiler);

begin
  Filer.DefineProperty('Paths', ReadPlugIns, WritePlugIns, Count > 0);
end;

// ----------------- TVXPlugInManager ---------------------------------------------

constructor TVXPlugInManager.Create(AOwner: TComponent);

begin
  inherited Create(AOwner);
  FLibraryList := TVXPlugInList.Create(Self);
  FResManagerList := TList.Create;
end;

// ------------------------------------------------------------------------------

destructor TVXPlugInManager.Destroy;
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

function TVXPlugInManager.AddPlugIn(Path: TFileName): Integer;

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
  OldError := SetErrorMode(SEM_NOOPENFILEERRORBOX);
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
        FileDate := SearchRec.TimeStamp;
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
      SetErrorMode(OldError);
    end;
end;

// ------------------------------------------------------------------------------

procedure TVXPlugInManager.DoNotify(Operation: TOperation;
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

function TVXPlugInManager.FindResManager(AManager: TVXResourceManager)
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

function TVXPlugInManager.GetIndexFromFilename(FileName: String): Integer;

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

function TVXPlugInManager.GetPlugInFromFilename(FileName: String): PPlugInEntry;

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

procedure TVXPlugInManager.RegisterResourceManager(AManager: TVXResourceManager;
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

procedure TVXPlugInManager.RemovePlugIn(Index: Integer);

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

procedure TVXPlugInManager.EditPlugInList;

begin
  ///TVXPlugInManagerEditor.EditPlugIns(Self);   //Circular call to edit Listbox items?
end;

// ------------------------------------------------------------------------------

procedure TVXPlugInManager.UnRegisterRessourceManager(AManager: TVXResourceManager;
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

// ------------------------------------------------------------------------------

end.
