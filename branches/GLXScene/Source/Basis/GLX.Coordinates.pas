//
// VKScene Component Library, based on GLScene http://glscene.sourceforge.net 
//
{
  Coordinate related classes. 
}

unit GLX.Coordinates;

interface

uses
  Winapi.OpenGL,
  System.Classes, System.SysUtils,
  
  GLX.VectorGeometry, GLX.VectorTypes, GLX.BaseClasses,
  GLX.CrossPlatform;

{$I VKScene.inc}

type

  // TGLCoordinatesStyle
  //
  { Identifie le type de donn�es stock�es au sein d'un TGLCustomCoordinates. 
      csPoint2D : a simple 2D point (Z=0, W=0)
      csPoint : un point (W=1)
     csVector : un vecteur (W=0)
     csUnknown : aucune contrainte
      }
  TGLCoordinatesStyle = (CsPoint2D, CsPoint, CsVector, CsUnknown);

  // TGLCustomCoordinates
  //
  { Stores and homogenous vector. 
    This class is basicly a container for a TVector, allowing proper use of
    delphi property editors and editing in the IDE. Vector/Coordinates
    manipulation methods are only minimal. 
    Handles dynamic default values to save resource file space.  }
  TGLCustomCoordinates = class(TGLUpdateAbleObject)
  private
    
    FCoords: TVector;
    FStyle: TGLCoordinatesStyle; // NOT Persistent
    FPDefaultCoords: PVector;
    procedure SetAsPoint2D(const Value: TVector2f);
    procedure SetAsVector(const Value: TVector);
    procedure SetAsAffineVector(const Value: TAffineVector);
    function GetAsAffineVector: TAffineVector;
    function GetAsPoint2D: TVector2f;
    function GetAsString: String;
    function GetCoordinate(const AIndex: Integer): GLfloat;
    procedure SetCoordinate(const AIndex: Integer; const AValue: GLfloat);
    function GetDirectCoordinate(const Index: Integer): GLfloat;
    procedure SetDirectCoordinate(const Index: Integer; const AValue: GLfloat);

  protected
    
    procedure SetDirectVector(const V: TVector);

    procedure DefineProperties(Filer: TFiler); override;
    procedure ReadData(Stream: TStream);
    procedure WriteData(Stream: TStream);

  public
    
    constructor CreateInitialized(AOwner: TPersistent; const AValue: TVector;
      const AStyle: TGLCoordinatesStyle = CsUnknown);
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    procedure WriteToFiler(Writer: TWriter);
    procedure ReadFromFiler(Reader: TReader);

    procedure Initialize(const Value: TVector);
    procedure NotifyChange(Sender: TObject); override;

    { Identifies the coordinates styles. 
      The property is NOT persistent, csUnknown by default, and should be
      managed by owner object only (internally). 
      It is used by the TGLCustomCoordinates for internal "assertion" checks
      to detect "misuses" or "misunderstandings" of what the homogeneous
      coordinates system implies. }
    property Style: TGLCoordinatesStyle read FStyle write FStyle;

    procedure Translate(const TranslationVector: TVector); overload;
    procedure Translate(const TranslationVector: TAffineVector); overload;
    procedure AddScaledVector(const Factor: Single;
      const TranslationVector: TVector); overload;
    procedure AddScaledVector(const Factor: Single;
      const TranslationVector: TAffineVector); overload;
    procedure Rotate(const AnAxis: TAffineVector; AnAngle: Single); overload;
    procedure Rotate(const AnAxis: TVector; AnAngle: Single); overload;
    procedure Normalize;
    procedure Invert;
    procedure Scale(Factor: Single);
    function VectorLength: GLfloat;
    function VectorNorm: GLfloat;
    function MaxXYZ: Single;
    function Equals(const AVector: TVector): Boolean; reintroduce;

    procedure SetVector(const X, Y: Single; Z: Single = 0); overload;
    procedure SetVector(const X, Y, Z, W: Single); overload;
    procedure SetVector(const V: TAffineVector); overload;
    procedure SetVector(const V: TVector); overload;

    procedure SetPoint(const X, Y, Z: Single); overload;
    procedure SetPoint(const V: TAffineVector); overload;
    procedure SetPoint(const V: TVector); overload;

    procedure SetPoint2D(const X, Y: Single); overload;
    procedure SetPoint2D(const Vector: TAffineVector); overload;
    procedure SetPoint2D(const Vector: TVector); overload;
    procedure SetPoint2D(const Vector: TVector2f); overload;

    procedure SetToZero;
    function AsAddress: PGLFloat;

    { The coordinates viewed as a vector. 
      Assigning a value to this property will trigger notification events,
      if you don't want so, use DirectVector instead. }
    property AsVector: TVector read FCoords write SetAsVector;

    { The coordinates viewed as an affine vector. 
      Assigning a value to this property will trigger notification events,
      if you don't want so, use DirectVector instead. 
      The W component is automatically adjustes depending on style. }
    property AsAffineVector: TAffineVector read GetAsAffineVector
      write SetAsAffineVector;

    { The coordinates viewed as a 2D point. 
      Assigning a value to this property will trigger notification events,
      if you don't want so, use DirectVector instead. }
    property AsPoint2D: TVector2f read GetAsPoint2D write SetAsPoint2D;

    property X: GLfloat index 0 read GetCoordinate write SetCoordinate;
    property Y: GLfloat index 1 read GetCoordinate write SetCoordinate;
    property Z: GLfloat index 2 read GetCoordinate write SetCoordinate;
    property W: GLfloat index 3 read GetCoordinate write SetCoordinate;

    property Coordinate[const AIndex: Integer]: GLfloat read GetCoordinate
      write SetCoordinate; default;

    { The coordinates, in-between brackets, separated by semi-colons. }
    property AsString: String read GetAsString;

    // : Similar to AsVector but does not trigger notification events
    property DirectVector: TVector read FCoords write SetDirectVector;
    property DirectX: GLfloat index 0 read GetDirectCoordinate
      write SetDirectCoordinate;
    property DirectY: GLfloat index 1 read GetDirectCoordinate
      write SetDirectCoordinate;
    property DirectZ: GLfloat index 2 read GetDirectCoordinate
      write SetDirectCoordinate;
    property DirectW: GLfloat index 3 read GetDirectCoordinate
      write SetDirectCoordinate;
  end;

  { A TGLCustomCoordinates that publishes X, Y properties. }
  TGLCoordinates2 = class(TGLCustomCoordinates)
  published
    property X stored False;
    property Y stored False;
  end;

  { A TGLCustomCoordinates that publishes X, Y, Z properties. }
  TGLCoordinates3 = class(TGLCustomCoordinates)
  published
    property X stored False;
    property Y stored False;
    property Z stored False;
  end;

  // TGLCoordinates4
  //
  { A TGLCustomCoordinates that publishes X, Y, Z, W properties. }
  TGLCoordinates4 = class(TGLCustomCoordinates)
  published
    property X stored False;
    property Y stored False;
    property Z stored False;
    property W stored False;
  end;

  // TGLCoordinates
  //
  TGLCoordinates = TGLCoordinates3;

  // Actually Sender should be TGLCustomCoordinates, but that would require
  // changes in a some other GLScene units and some other projects that use
  // TGLCoordinatesUpdateAbleComponent
  IGLCoordinatesUpdateAble = interface(IInterface)
    ['{ACB98D20-8905-43A7-AFA5-225CF5FA6FF5}']
    procedure CoordinateChanged(Sender: TGLCustomCoordinates);
  end;

  // TGLCoordinatesUpdateAbleComponent
  //
  TGLCoordinatesUpdateAbleComponent = class(TGLUpdateAbleComponent,
    IGLCoordinatesUpdateAble)
  public
    
    procedure CoordinateChanged(Sender: TGLCustomCoordinates); virtual;
      abstract;
  end;

var
  // Specifies if TGLCustomCoordinates should allocate memory for
  // their default values (ie. design-time) or not (run-time)
  VUseDefaultCoordinateSets: Boolean = False;

implementation

const
  CsVectorHelp =
    'If you are getting assertions here, consider using the SetPoint procedure';
  CsPointHelp =
    'If you are getting assertions here, consider using the SetVector procedure';
  CsPoint2DHelp =
    'If you are getting assertions here, consider using one of the SetVector or SetPoint procedures';

  // ------------------
  // ------------------ TGLCustomCoordinates ------------------
  // ------------------

  // CreateInitialized
  //
constructor TGLCustomCoordinates.CreateInitialized(AOwner: TPersistent;
  const AValue: TVector; const AStyle: TGLCoordinatesStyle = CsUnknown);
begin
  Create(AOwner);
  Initialize(AValue);
  FStyle := AStyle;
end;

// Destroy
//
destructor TGLCustomCoordinates.Destroy;
begin
  if Assigned(FPDefaultCoords) then
    Dispose(FPDefaultCoords);
  inherited;
end;

// Initialize
//
procedure TGLCustomCoordinates.Initialize(const Value: TVector);
begin
  FCoords := Value;
  if VUseDefaultCoordinateSets then
  begin
    if not Assigned(FPDefaultCoords) then
      New(FPDefaultCoords);
    FPDefaultCoords^ := Value;
  end;
end;

// Assign
//
procedure TGLCustomCoordinates.Assign(Source: TPersistent);
begin
  if Source is TGLCustomCoordinates then
    FCoords := TGLCustomCoordinates(Source).FCoords
  else
    inherited;
end;

// WriteToFiler
//
procedure TGLCustomCoordinates.WriteToFiler(Writer: TWriter);
var
  WriteCoords: Boolean;
begin
  with Writer do
  begin
    WriteInteger(0); // Archive Version 0
    if VUseDefaultCoordinateSets then
      WriteCoords := not VectorEquals(FPDefaultCoords^, FCoords)
    else
      WriteCoords := True;
    WriteBoolean(WriteCoords);
    if WriteCoords then
      Write(FCoords.X, SizeOf(FCoords));
  end;
end;

// ReadFromFiler
//
procedure TGLCustomCoordinates.ReadFromFiler(Reader: TReader);
var
  N: Integer;
begin
  with Reader do
  begin
    ReadInteger; // Ignore ArchiveVersion
    if ReadBoolean then
    begin
      N := SizeOf(FCoords);
      Assert(N = 4 * SizeOf(Single));
      Read(FCoords.X, N);
    end
    else if Assigned(FPDefaultCoords) then
      FCoords := FPDefaultCoords^;
  end;
end;

// DefineProperties
//
procedure TGLCustomCoordinates.DefineProperties(Filer: TFiler);
begin
  inherited;
  Filer.DefineBinaryProperty('Coordinates', ReadData, WriteData,
    not(Assigned(FPDefaultCoords) and VectorEquals(FPDefaultCoords^, FCoords)));
end;

// ReadData
//
procedure TGLCustomCoordinates.ReadData(Stream: TStream);
begin
  Stream.Read(FCoords, SizeOf(FCoords));
end;

// WriteData
//
procedure TGLCustomCoordinates.WriteData(Stream: TStream);
begin
  Stream.Write(FCoords, SizeOf(FCoords));
end;

// NotifyChange
//
procedure TGLCustomCoordinates.NotifyChange(Sender: TObject);
var
  Int: IGLCoordinatesUpdateAble;
begin
  if Supports(Owner, IGLCoordinatesUpdateAble, Int) then
    Int.CoordinateChanged(TGLCoordinates(Self));
  inherited NotifyChange(Sender);
end;

// Translate
//
procedure TGLCustomCoordinates.Translate(const TranslationVector: TVector);
begin
  FCoords.X := FCoords.X + TranslationVector.X;
  FCoords.Y := FCoords.Y + TranslationVector.Y;
  FCoords.Z := FCoords.Z + TranslationVector.Z;
  NotifyChange(Self);
end;

// Translate
//
procedure TGLCustomCoordinates.Translate(const TranslationVector
  : TAffineVector);
begin
  FCoords.X := FCoords.X + TranslationVector.X;
  FCoords.Y := FCoords.Y + TranslationVector.Y;
  FCoords.Z := FCoords.Z + TranslationVector.Z;
  NotifyChange(Self);
end;

// AddScaledVector (hmg)
//
procedure TGLCustomCoordinates.AddScaledVector(const Factor: Single;
  const TranslationVector: TVector);
var
  F: Single;
begin
  F := Factor;
  CombineVector(FCoords, TranslationVector, F);
  NotifyChange(Self);
end;

// AddScaledVector (affine)
//
procedure TGLCustomCoordinates.AddScaledVector(const Factor: Single;
  const TranslationVector: TAffineVector);
var
  F: Single;
begin
  F := Factor;
  CombineVector(FCoords, TranslationVector, F);
  NotifyChange(Self);
end;

// Rotate (affine)
//
procedure TGLCustomCoordinates.Rotate(const AnAxis: TAffineVector;
  AnAngle: Single);
begin
  RotateVector(FCoords, AnAxis, AnAngle);
  NotifyChange(Self);
end;

// Rotate (hmg)
//
procedure TGLCustomCoordinates.Rotate(const AnAxis: TVector; AnAngle: Single);
begin
  RotateVector(FCoords, AnAxis, AnAngle);
  NotifyChange(Self);
end;

// Normalize
//
procedure TGLCustomCoordinates.Normalize;
begin
  NormalizeVector(FCoords);
  NotifyChange(Self);
end;

// Invert
//
procedure TGLCustomCoordinates.Invert;
begin
  NegateVector(FCoords);
  NotifyChange(Self);
end;

// Scale
//
procedure TGLCustomCoordinates.Scale(Factor: Single);
begin
  ScaleVector(PAffineVector(@FCoords)^, Factor);
  NotifyChange(Self);
end;

// VectorLength
//
function TGLCustomCoordinates.VectorLength: GLfloat;
begin
  Result := GLX.VectorGeometry.VectorLength(FCoords);
end;

// VectorNorm
//
function TGLCustomCoordinates.VectorNorm: GLfloat;
begin
  Result := GLX.VectorGeometry.VectorNorm(FCoords);
end;

// MaxXYZ
//
function TGLCustomCoordinates.MaxXYZ: Single;
begin
  Result := GLX.VectorGeometry.MaxXYZComponent(FCoords);
end;

// Equals
//
function TGLCustomCoordinates.Equals(const AVector: TVector): Boolean;
begin
  Result := VectorEquals(FCoords, AVector);
end;

// SetVector (affine)
//
procedure TGLCustomCoordinates.SetVector(const X, Y: Single; Z: Single = 0);
begin
  Assert(FStyle = CsVector, CsVectorHelp);
  GLX.VectorGeometry.SetVector(FCoords, X, Y, Z);
  NotifyChange(Self);
end;

// SetVector (TAffineVector)
//
procedure TGLCustomCoordinates.SetVector(const V: TAffineVector);
begin
  Assert(FStyle = CsVector, CsVectorHelp);
  GLX.VectorGeometry.SetVector(FCoords, V);
  NotifyChange(Self);
end;

// SetVector (TVector)
//
procedure TGLCustomCoordinates.SetVector(const V: TVector);
begin
  Assert(FStyle = CsVector, CsVectorHelp);
  GLX.VectorGeometry.SetVector(FCoords, V);
  NotifyChange(Self);
end;

// SetVector (hmg)
//
procedure TGLCustomCoordinates.SetVector(const X, Y, Z, W: Single);
begin
  Assert(FStyle = CsVector, CsVectorHelp);
  GLX.VectorGeometry.SetVector(FCoords, X, Y, Z, W);
  NotifyChange(Self);
end;

// SetDirectVector
//
procedure TGLCustomCoordinates.SetDirectCoordinate(const Index: Integer;
  const AValue: GLfloat);
begin
  FCoords.V[index] := AValue;
end;

procedure TGLCustomCoordinates.SetDirectVector(const V: TVector);
begin
  FCoords.X := V.X;
  FCoords.Y := V.Y;
  FCoords.Z := V.Z;
  FCoords.W := V.W;
end;

// SetToZero
//
procedure TGLCustomCoordinates.SetToZero;
begin
  FCoords.X := 0;
  FCoords.Y := 0;
  FCoords.Z := 0;
  if FStyle = CsPoint then
    FCoords.W := 1
  else
    FCoords.W := 0;
  NotifyChange(Self);
end;

// SetPoint
//
procedure TGLCustomCoordinates.SetPoint(const X, Y, Z: Single);
begin
  Assert(FStyle = CsPoint, CsPointHelp);
  GLX.VectorGeometry.MakePoint(FCoords, X, Y, Z);
  NotifyChange(Self);
end;

// SetPoint (TAffineVector)
//
procedure TGLCustomCoordinates.SetPoint(const V: TAffineVector);
begin
  Assert(FStyle = CsPoint, CsPointHelp);
  GLX.VectorGeometry.MakePoint(FCoords, V);
  NotifyChange(Self);
end;

// SetPoint (TVector)
//
procedure TGLCustomCoordinates.SetPoint(const V: TVector);
begin
  Assert(FStyle = CsPoint, CsPointHelp);
  GLX.VectorGeometry.MakePoint(FCoords, V);
  NotifyChange(Self);
end;

// SetPoint2D
//
procedure TGLCustomCoordinates.SetPoint2D(const X, Y: Single);
begin
  Assert(FStyle = CsPoint2D, CsPoint2DHelp);
  GLX.VectorGeometry.MakeVector(FCoords, X, Y, 0);
  NotifyChange(Self);
end;

// SetPoint2D (TAffineVector)
//
procedure TGLCustomCoordinates.SetPoint2D(const Vector: TAffineVector);
begin
  Assert(FStyle = CsPoint2D, CsPoint2DHelp);
  GLX.VectorGeometry.MakeVector(FCoords, Vector);
  NotifyChange(Self);
end;

// SetPoint2D (TVector)
//
procedure TGLCustomCoordinates.SetPoint2D(const Vector: TVector);
begin
  Assert(FStyle = CsPoint2D, CsPoint2DHelp);
  GLX.VectorGeometry.MakeVector(FCoords, Vector);
  NotifyChange(Self);
end;

// SetPoint2D (TVector2f)
//
procedure TGLCustomCoordinates.SetPoint2D(const Vector: TVector2f);
begin
  Assert(FStyle = CsPoint2D, CsPoint2DHelp);
  GLX.VectorGeometry.MakeVector(FCoords, Vector.X, Vector.Y, 0);
  NotifyChange(Self);
end;

// AsAddress
//
function TGLCustomCoordinates.AsAddress: PGLFloat;
begin
  Result := @FCoords;
end;

// SetAsVector
//
procedure TGLCustomCoordinates.SetAsVector(const Value: TVector);
begin
  FCoords := Value;
  case FStyle of
    CsPoint2D:
      begin
        FCoords.Z := 0;
        FCoords.W := 0;
      end;
    CsPoint:
      FCoords.W := 1;
    CsVector:
      FCoords.W := 0;
  else
    Assert(False);
  end;
  NotifyChange(Self);
end;

// SetAsAffineVector
//
procedure TGLCustomCoordinates.SetAsAffineVector(const Value: TAffineVector);
begin
  case FStyle of
    CsPoint2D:
      MakeVector(FCoords, Value);
    CsPoint:
      MakePoint(FCoords, Value);
    CsVector:
      MakeVector(FCoords, Value);
  else
    Assert(False);
  end;
  NotifyChange(Self);
end;

// SetAsPoint2D
//
procedure TGLCustomCoordinates.SetAsPoint2D(const Value: TVector2f);
begin
  case FStyle of
    CsPoint2D, CsPoint, CsVector:
      begin
        FCoords.X := Value.X;
        FCoords.Y := Value.Y;
        FCoords.Z := 0;
        FCoords.W := 0;
      end;
  else
    Assert(False);
  end;
  NotifyChange(Self);
end;

// GetAsAffineVector
//
function TGLCustomCoordinates.GetAsAffineVector: TAffineVector;
begin
  GLX.VectorGeometry.SetVector(Result, FCoords);
end;

// GetAsPoint2D
//
function TGLCustomCoordinates.GetAsPoint2D: TVector2f;
begin
  Result.X := FCoords.X;
  Result.Y := FCoords.Y;
end;

// SetCoordinate
//
procedure TGLCustomCoordinates.SetCoordinate(const AIndex: Integer;
  const AValue: GLfloat);
begin
  FCoords.V[AIndex] := AValue;
  NotifyChange(Self);
end;

// GetCoordinate
//
function TGLCustomCoordinates.GetCoordinate(const AIndex: Integer): GLfloat;
begin
  Result := FCoords.V[AIndex];
end;

function TGLCustomCoordinates.GetDirectCoordinate(
  const Index: Integer): GLfloat;
begin
  Result := FCoords.V[index]
end;

// GetAsString
//
function TGLCustomCoordinates.GetAsString: String;
begin
  case Style of
    CsPoint2D:
      Result := Format('(%g; %g)', [FCoords.X, FCoords.Y]);
    CsPoint:
      Result := Format('(%g; %g; %g)', [FCoords.X, FCoords.Y, FCoords.Z]);
    CsVector:
      Result := Format('(%g; %g; %g; %g)', [FCoords.X, FCoords.Y, FCoords.Z,
        FCoords.W]);
  else
    Assert(False);
  end;
end;

initialization

RegisterClasses([TGLCoordinates2, TGLCoordinates3, TGLCoordinates4]);

end.