//
// This unit is part of the GLScene Project, http://glscene.org
//
{
  ThorFX  for GLScene
  History :  
   10/11/12 - PW - Added CPP compatibility: changed vector arrays to records in Render
   21/01/11 - DanB - Added "inherited" call to TGLBThorFX.WriteToFiler
   23/08/10 - Yar - Added OpenGLTokens to uses, replaced OpenGL1x functions to OpenGLAdapter
   14/06/10 - Yar - Bugfixed in TGLBThorFX.ReadFromFiler when assertion off (thanks olkondr)
   22/04/10 - Yar - Fixes after GLState revision
   05/03/10 - DanB - More state added to TGLStateCache
   06/06/07 - DaStr - Added GLColor to uses (BugtrackerID = 1732211)
   30/03/07 - DaStr - Added $I GLScene.inc
   16/03/07 - DaStr - Added explicit pointer dereferencing
  (thanks Burkhard Carstens) (Bugtracker ID = 1678644)
   13/02/07 - aidave - Updated Target.Style to csPoint
   23/12/04 - PhP - GLScenestyled Header
   02/08/04 - LR, YHC - BCB corrections: use record instead array
   06/04/04 - PhP - Removed property Paused use of property Disabled instead
   04/15/03 - Added initialization to CalcThor, to fix an error
  Thanks to Martin Kirsch for this solution
   12/08/01 - EG - Dropped unused Handle allocation (leftover from FirexFX)
  Fixed leaks (colors)
   09/03/01 - Ren� Lindsay - unit created
   
}
unit GLThorFX;

interface

{$I GLScene.inc}

uses
  System.Classes, System.SysUtils, System.Types, System.Math,

  GLScene, GLXCollection, GLVectorGeometry,
  OpenGLTokens, GLContext, GLVectorLists, GLVectorTypes,
  GLCadencer, GLColor, GLBaseClasses, GLCoordinates, GLRenderContextInfo,
  GLManager, GLState, GLTextureFormat;

type
  PThorpoint = ^TThorpoint;

  TThorpoint = record
    Position: TVector; // Position
    Size: single; // particle size
  end;

  PThorpointArray = ^TThorpointArray;
  TThorpointArray = array [0 .. MAXINT shr 6] of TThorpoint;

  TGLBThorFX = class;

  TCalcPointEvent = procedure(Sender: TObject; PointNo: integer; var x: single;
    var y: single; var z: single) of object;

  // TGLThorFXManager
  //
  {  Thor special effect manager. }
  TGLThorFXManager = class(TGLCadenceAbleComponent)
  private
    { Private Declarations }
    FClients: TList;
    FThorpoints: PThorpointArray;
    FTarget: TGLCoordinates;
    FCadencer: TGLCadencer;
    FMaxpoints: integer;
    FGlowSize: single;
    FVibrate: single;
    FWildness: single;
    NP: integer;
    FInnerColor, FOuterColor, FCoreColor: TGLColor;
    FDisabled, FCore, FGlow: boolean;
    FOnCalcPoint: TCalcPointEvent;
  protected
    { Protected Declarations }
    procedure RegisterClient(aClient: TGLBThorFX);
    procedure DeRegisterClient(aClient: TGLBThorFX);
    procedure DeRegisterAllClients;
    procedure SetTarget(const val: TGLCoordinates);
    procedure SetCadencer(const val: TGLCadencer);
    procedure SetMaxpoints(const val: integer);
    function StoreGlowSize: boolean;
    function StoreVibrate: boolean;
    procedure SetInnerColor(const val: TGLColor);
    procedure SetOuterColor(const val: TGLColor);
    procedure SetCoreColor(const val: TGLColor);
    procedure Notification(AComponent: TComponent;
      Operation: TOperation); override;
    procedure ThorInit;
    procedure CalcThor;
    procedure CalcFrac(left, right: integer; lh, rh: single; xyz: integer);
  public
    { Public Declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure DoProgress(const progressTime: TProgressTimes); override;
  published
    { Published Declarations }
    property Target: TGLCoordinates read FTarget write SetTarget;
    property Cadencer: TGLCadencer read FCadencer write SetCadencer;
    property Maxpoints: integer read FMaxpoints write SetMaxpoints default 256;
    property GlowSize: single read FGlowSize write FGlowSize
      stored StoreGlowSize;
    property Vibrate: single read FVibrate write FVibrate stored StoreVibrate;
    property InnerColor: TGLColor read FInnerColor write SetInnerColor;
    property OuterColor: TGLColor read FOuterColor write SetOuterColor;
    // default clrWhite;
    property CoreColor: TGLColor read FCoreColor write SetCoreColor;
    // default clrWhite;
    property Disabled: boolean read FDisabled write FDisabled;
    property Core: boolean read FCore write FCore;
    property Glow: boolean read FGlow write FGlow;
    property Wildness: single read FWildness write FWildness;
    property OnCalcPoint: TCalcPointEvent read FOnCalcPoint write FOnCalcPoint;
  end;

  // TGLBThorFX
  //
  {  Thor special effect }
  TGLBThorFX = class(TGLObjectPostEffect)
  private
    { Private Declarations }
    FManager: TGLThorFXManager;
    FManagerName: String; // NOT persistent, temporarily used for persistence
    FTarget: TGLCoordinates;
  protected
    { Protected Declarations }
    procedure SetManager(const val: TGLThorFXManager);
    procedure WriteToFiler(writer: TWriter); override;
    procedure ReadFromFiler(reader: TReader); override;
    procedure Loaded; override;
    procedure SetTarget(const val: TGLCoordinates);
  public
    { Public Declarations }
    constructor Create(AOwner: TGLXCollection); override;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    class function FriendlyName: String; override;
    class function FriendlyDescription: String; override;
    procedure Render(var rci: TRenderContextInfo); override;
  published
    { Published Declarations }
    {  Refers the collision manager. }
    property Manager: TGLThorFXManager read FManager write SetManager;
  end;

  {  Returns or creates the TGLBThorFX within the given object's effects.  }
function GetOrCreateThorFX(obj: TGLBaseSceneObject; const name: String = '')
  : TGLBThorFX;

// ------------------------------------------------------------------
// ------------------------------------------------------------------
// ------------------------------------------------------------------
implementation

// ------------------------------------------------------------------
// ------------------------------------------------------------------
// ------------------------------------------------------------------

// ------------------
// ------------------ TGLThorFXManager ------------------
// ------------------

// Create
//
constructor TGLThorFXManager.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FClients := TList.Create;
  RegisterManager(Self);
  FTarget := TGLCoordinates.CreateInitialized(Self, VectorMake(0, 1, 0));
  FTarget.Style := csPoint;
  FMaxpoints := 64;
  FGlowSize := 0.2;
  FVibrate := 0;
  FWildness := 1;
  FInnerColor := TGLColor.Create(Self);
  FInnerColor.Initialize(clrWhite);
  FOuterColor := TGLColor.Create(Self);
  FOuterColor.Initialize(clrBlue);
  FOuterColor.Alpha := 0;
  FCoreColor := TGLColor.Create(Self);
  FCoreColor.Initialize(clrWhite);
  FCore := True;
  FGlow := True;
  ThorInit;
end;

// Destroy
//
destructor TGLThorFXManager.Destroy;
begin
  DeRegisterAllClients;
  DeRegisterManager(Self);
  FreeMem(FThorpoints);
  FreeAndNil(FClients);
  FreeAndNil(FInnerColor);
  FreeAndNil(FOuterColor);
  FreeAndNil(FCoreColor);
  FreeAndNil(FTarget);
  inherited Destroy;
end;

// RegisterClient
//
procedure TGLThorFXManager.RegisterClient(aClient: TGLBThorFX);
begin
  if Assigned(aClient) then
    if FClients.IndexOf(aClient) < 0 then
    begin
      FClients.Add(aClient);
      aClient.FManager := Self;
    end;
end;

// DeRegisterClient
//
procedure TGLThorFXManager.DeRegisterClient(aClient: TGLBThorFX);
begin
  if Assigned(aClient) then
  begin
    aClient.FManager := nil;
    FClients.Remove(aClient);
  end;
end;

// DeRegisterAllClients
//
procedure TGLThorFXManager.DeRegisterAllClients;
var
  i: integer;
begin
  // Fast deregistration
  for i := 0 to FClients.Count - 1 do
    TGLBThorFX(FClients[i]).FManager := nil;
  FClients.Clear;
end;

procedure TGLThorFXManager.SetTarget(const val: TGLCoordinates);
begin
  FTarget.Assign(val);
  ThorInit;
end;

// SetCadencer
//
procedure TGLThorFXManager.SetCadencer(const val: TGLCadencer);
begin
  if FCadencer <> val then
  begin
    if Assigned(FCadencer) then
      FCadencer.UnSubscribe(Self);
    FCadencer := val;
    if Assigned(FCadencer) then
      FCadencer.Subscribe(Self);
  end;
end;

// SetMaxpoints
//
procedure TGLThorFXManager.SetMaxpoints(const val: integer);
begin
  if FMaxpoints <> val then
  begin
    FMaxpoints := val;
    ThorInit;
  end;
end;

// StoreGlowSize
//
function TGLThorFXManager.StoreGlowSize: boolean;
begin
  Result := (FGlowSize <> 1);
end;

// StoreGlowSize
//
function TGLThorFXManager.StoreVibrate: boolean;
begin
  Result := (FVibrate <> 1);
end;

// SetInnerColor
//
procedure TGLThorFXManager.SetInnerColor(const val: TGLColor);
begin
  if FInnerColor <> val then
  begin
    FInnerColor.color := val.color;
    ThorInit;
  end;
end;

// SetOuterColor
//
procedure TGLThorFXManager.SetOuterColor(const val: TGLColor);
begin
  if FOuterColor <> val then
  begin
    FOuterColor.color := val.color;
    ThorInit;
  end;
end;

// SetOuterColor
//
procedure TGLThorFXManager.SetCoreColor(const val: TGLColor);
begin
  if FCoreColor <> val then
  begin
    FCoreColor.color := val.color;
    ThorInit;
  end;
end;

// Notification
//
procedure TGLThorFXManager.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  if (Operation = opRemove) and (AComponent = FCadencer) then
    Cadencer := nil;
  inherited;
end;

// DoProgress
//
procedure TGLThorFXManager.DoProgress(const progressTime: TProgressTimes);
var
  i: integer;

begin
  if not FDisabled then
    CalcThor;
  // Invalidate all clients
  for i := 0 to FClients.Count - 1 do
    TGLBThorFX(FClients[i]).OwnerBaseSceneObject.NotifyChange
      (TGLBThorFX(FClients[i]));
end;

// ThorInit
//
procedure TGLThorFXManager.ThorInit;
begin
  ReallocMem(FThorpoints, FMaxpoints * Sizeof(TThorpoint));
end;

// CalcThor
//
procedure TGLThorFXManager.CalcThor;
var
  N: integer;
  vec, axs, nvec: TVector;
  dist: single;
  a, b: single;
  len: single;
begin
  // initialise all points with valid data
  for N := 0 to Maxpoints - 1 do
    SetVector(FThorpoints^[N].Position, 0, 0, 0);

  // ------------------Calculate fractal (wildness)---------------
  // SetVector(FThorpoints[0].Position,0,0,0);
  SetVector(FThorpoints^[Maxpoints - 1].Position, 0, 0, 0);

  CalcFrac(0, Maxpoints - 1, 0, 0, 0);
  CalcFrac(0, Maxpoints - 1, 0, 0, 1);
  // CalcFrac(0,maxpoints-1,0,FTarget.z,2);

  // ---------------Rotate Vector to target-------------
  SetVector(nvec, FTarget.x, FTarget.y, FTarget.z);
  len := VectorLength(nvec);
  NormalizeVector(nvec);
  a := ArcCos(nvec.V[2]);
  b := ArcTan2(nvec.V[0], nvec.V[1]);

  N := 0;
  While (N < Maxpoints) do
  begin
    dist := N / Maxpoints * len;
    vec := FThorpoints^[N].Position;
    vec.V[2] := dist;

    if Assigned(OnCalcPoint) then
      OnCalcPoint(Self, N, vec.V[0], vec.V[1], vec.V[2]);
    // Let user mess around with point position

    SetVector(axs, 1, 0, 0); // Rotate up
    RotateVector(vec, axs, a);
    SetVector(axs, 0, 0, 1); // Rotate to the sides
    RotateVector(vec, axs, b);
    FThorpoints^[N].Position := vec;
    inc(N);
  end;
  // ----------------------------------------------------
  NP := Maxpoints;
end;

procedure TGLThorFXManager.CalcFrac(left, right: integer; lh, rh: single;
  xyz: integer);
var
  midh: single;
  mid: integer;
  res: integer;
  fracScale: single;
begin
  mid := (left + right) div 2;
  res := (left + right) mod 2;
  fracScale := (right - left) / Maxpoints;
  midh := (lh + rh) / 2 + (fracScale * FWildness * random) -
    (fracScale * FWildness) / 2;
  FThorpoints^[mid].Position.V[xyz] := midh +
    (FVibrate * random - (FVibrate / 2));
  // if res=1 then FThorpoints[right-1].Position[xyz]:=
  // (FThorpoints[right].Position[xyz]+midh)/(right-mid)*(right-mid-1);
  if res = 1 then
    FThorpoints^[right - 1].Position.V[xyz] := FThorpoints^[right].Position.V[xyz];
  if (mid - left) > 1 then
    CalcFrac(left, mid, lh, midh, xyz);
  if (right - mid) > 1 then
    CalcFrac(mid, right, midh, rh, xyz);
end;

// ------------------
// ------------------ TGLBThorFX ------------------
// ------------------

// Create
//
constructor TGLBThorFX.Create(AOwner: TGLXCollection);
begin
  inherited Create(AOwner);
  FTarget := TGLCoordinates.CreateInitialized(Self, VectorMake(0, 1, 0));
  FTarget.Style := csPoint;
end;

// Destroy
//
destructor TGLBThorFX.Destroy;
begin
  Manager := nil;
  FreeAndNil(FTarget);
  inherited Destroy;
end;

// FriendlyName
//
class function TGLBThorFX.FriendlyName: String;
begin
  Result := 'ThorFX';
end;

// FriendlyDescription
//
class function TGLBThorFX.FriendlyDescription: String;
begin
  Result := 'Thor FX';
end;

// WriteToFiler
//
procedure TGLBThorFX.WriteToFiler(writer: TWriter);
begin
  with writer do
  begin
    // ArchiveVersion 1, added inherited call
    WriteInteger(1);
    inherited;
    if Assigned(FManager) then
      WriteString(FManager.GetNamePath)
    else
      WriteString('');
  end;
end;

// ReadFromFiler
//
procedure TGLBThorFX.ReadFromFiler(reader: TReader);
var
  archiveVersion: integer;
begin
  with reader do
  begin
    archiveVersion := ReadInteger;
    Assert(archiveVersion in [0 .. 1]);
    if archiveVersion >= 1 then
      inherited;
    FManagerName := ReadString;
    Manager := nil;
  end;
end;

// Loaded
//
procedure TGLBThorFX.Loaded;
var
  mng: TComponent;

begin
  inherited;
  if FManagerName <> '' then
  begin
    mng := FindManager(TGLThorFXManager, FManagerName);
    if Assigned(mng) then
      Manager := TGLThorFXManager(mng);
    FManagerName := '';
  end;
end;

// Assign
//
procedure TGLBThorFX.Assign(Source: TPersistent);
begin
  if Source is TGLBThorFX then
  begin
    Manager := TGLBThorFX(Source).Manager;
  end;
  inherited Assign(Source);
end;

// SetTarget
//
procedure TGLBThorFX.SetTarget(const val: TGLCoordinates);
begin
  FTarget.Assign(val);
end;

// SetManager
//
procedure TGLBThorFX.SetManager(const val: TGLThorFXManager);
begin
  if val <> FManager then
  begin
    if Assigned(FManager) then
      FManager.DeRegisterClient(Self);
    if Assigned(val) then
      val.RegisterClient(Self);
  end;
end;

// Render
//
procedure TGLBThorFX.Render(var rci: TRenderContextInfo);
var
  N: integer;
  i: integer;
  // absPos :TVector;
  InnerColor: TVector;
  distList: TSingleList;
  objList: TList;
  fp: PThorpoint;
  mat: TMatrix;

  vx, vy: TVector;
  m: integer;
  Icol, Ocol, Ccol: TColorVector;
  Ppos, Ppos2: TAffineVector;
begin
  if Manager = nil then
    Exit;

  rci.PipelineTransformation.Push;
  // we get the object position and apply translation...
  // absPos:=OwnerBaseSceneObject.AbsolutePosition;
  // ...should be removed when absolute coords will be handled directly
  // in the point system (and will also make a better flame effect)

  rci.GLStates.Disable(stCullFace);
  rci.GLStates.ActiveTextureEnabled[ttTexture2D] := False;
  rci.GLStates.Disable(stLighting);
  rci.GLStates.SetBlendFunc(bfSrcAlpha, bfOne);
  rci.GLStates.Enable(stBlend);

  N := Manager.NP;

  if N > 1 then
  begin
    distList := TSingleList.Create;
    objList := TList.Create;
    for i := 0 to N - 1 do
    begin
      fp := @(Manager.FThorpoints[i]);
      distList.Add(VectorDotProduct(rci.cameraDirection, fp^.Position));
      objList.Add(fp);
    end;
    QuickSortLists(0, N - 1, distList, objList);

    mat := rci.PipelineTransformation.ModelViewMatrix;
    for m := 0 to 2 do
    begin
      vx.V[m] := mat.V[m].V[0] * Manager.GlowSize;
      vy.V[m] := mat.V[m].V[1] * Manager.GlowSize;
    end;

    SetVector(InnerColor, Manager.FInnerColor.color);

    // ---------------
    rci.GLStates.SetBlendFunc(bfSrcAlpha, bfOne);
    rci.GLStates.Enable(stBlend);
    rci.GLStates.Enable(stLineSmooth);
    rci.GLStates.Disable(stLighting);
    // Stops particles at same distanceform overwriting each-other
    rci.GLStates.DepthFunc := cfLEqual;
    rci.GLStates.LineWidth := 3;
    Icol := Manager.FInnerColor.color;
    Ocol := Manager.FOuterColor.color;
    Ccol := Manager.FCoreColor.color;

    // ---Core Line---
    if Manager.FCore then
    begin
      rci.GLStates.Disable(stBlend);
      GL.Color4fv(@Ccol);
      GL.Begin_(GL_LINE_STRIP);
      for i := 0 to N - 1 do
      begin
        fp := @(Manager.FThorpoints[i]);
        SetVector(Ppos, fp^.Position);
        GL.Vertex3f(Ppos.V[0], Ppos.V[1], Ppos.V[2]);
      end;
      GL.End_;
    end; // Core;

    // ---Point Glow---
    if Manager.FGlow then
    begin
      rci.GLStates.Enable(stBlend);
      for i := N - 1 downto 0 do
      begin
        fp := PThorpoint(objList[i]);
        SetVector(Ppos, fp^.Position);
        fp := @(Manager.FThorpoints[i]);
        SetVector(Ppos2, fp^.Position);
        GL.Begin_(GL_TRIANGLE_FAN);
        GL.Color4fv(@Icol);
        GL.Vertex3f(Ppos.V[0], Ppos.V[1], Ppos.V[2]); // middle1
        GL.Color4fv(@Ocol);
        GL.Vertex3f(Vx.V[0] + Vy.V[0] + Ppos.V[0],
          Vx.V[1] + Vy.V[1] + Ppos.V[1], Vx.V[2] + Vy.V[2] +
          Ppos.V[2]); // TopRight
        GL.Vertex3f(Vx.V[0] * 1.4 + Ppos.V[0],
          Vx.V[1] * 1.4 + Ppos.V[1], Vx.V[2] * 1.4 + Ppos.V[2]);
        // Right1
        GL.Vertex3f(Vx.V[0] - Vy.V[0] + Ppos.V[0],
          Vx.V[1] - Vy.V[1] + Ppos.V[1], Vx.V[2] - Vy.V[2] +
          Ppos.V[2]); // BottomRight
        GL.Vertex3f(-Vy.V[0] * 1.4 + Ppos.V[0],
          -Vy.V[1] * 1.4 + Ppos.V[1], -Vy.V[2] * 1.4 + Ppos.V[2]
          ); // bottom1
        GL.Vertex3f(-Vx.V[0] - Vy.V[0] + Ppos.V[0],
          -Vx.V[1] - Vy.V[1] + Ppos.V[1], -Vx.V[2] - Vy.V[2]
          + Ppos.V[2]); // BottomLeft
        GL.Vertex3f(-Vx.V[0] * 1.4 + Ppos.V[0],
          -Vx.V[1] * 1.4 + Ppos.V[1], -Vx.V[2] * 1.4 + Ppos.V[2]); // left1
        GL.Vertex3f(-Vx.V[0] + Vy.V[0] + Ppos.V[0],
          -Vx.V[1] + Vy.V[1] + Ppos.V[1], -Vx.V[2] + Vy.V[2]
          + Ppos.V[2]); // TopLeft
        GL.Vertex3f(Vy.V[0] * 1.4 + Ppos.V[0],
          Vy.V[1] * 1.4 + Ppos.V[1], Vy.V[2] * 1.4 + Ppos.V[2]);
        // top1
        GL.Vertex3f(Vx.V[0] + Vy.V[0] + Ppos.V[0],
          Vx.V[1] + Vy.V[1] + Ppos.V[1], Vx.V[2] + Vy.V[2] +
          Ppos.V[2]); // TopRight
        GL.End_;
      end; // Glow
    end;

    objList.Free;
    distList.Free;
  end;
  rci.PipelineTransformation.Pop;
end;

// GetOrCreateThorFX
//
function GetOrCreateThorFX(obj: TGLBaseSceneObject; const name: String = '')
  : TGLBThorFX;
var
  i: integer;
begin
  with obj.Effects do
  begin
    if name = '' then
    begin
      i := IndexOfClass(TGLBThorFX);
      if i >= 0 then
        Result := TGLBThorFX(Items[i])
      else
        Result := TGLBThorFX.Create(obj.Effects);
    end
    else
    begin
      i := IndexOfName(name);
      if i >= 0 then
        Result := (Items[i] as TGLBThorFX)
      else
      begin
        Result := TGLBThorFX.Create(obj.Effects);
        Result.name := name;
      end;
    end;
  end;
end;

// ------------------------------------------------------------------
// ------------------------------------------------------------------
// ------------------------------------------------------------------
initialization

// ------------------------------------------------------------------
// ------------------------------------------------------------------
// ------------------------------------------------------------------

// class registrations
RegisterXCollectionItemClass(TGLBThorFX);

finalization

UnregisterXCollectionItemClass(TGLBThorFX);

end.
