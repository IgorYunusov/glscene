//
// VXScene Component Library, based on GLScene http://glscene.sourceforge.net 
//
{
   Custom ODE collider implementations. 

   Credits :  
      Heightfield collider code originally adapted from Mattias Fagerlund's
      DelphiODE terrain collision demo.
      Website: http://www.cambrianlabs.com/Mattias/DelphiODE
   
}
unit VXS.ODECustomColliders;

interface

{$I VXScene.inc}

uses
  System.Classes,
  System.SysUtils,

  ODEImport,
  VXS.ODEGL,
  VXS.ODEManager,
  VXS.VectorGeometry,
  VXS.VectorLists,
  VXS.Scene,
  VXS.TerrainRenderer,
  VXS.Graph,
  VXS.XCollection,
  Winapi.OpenGL, Winapi.OpenGLext, 
  VXS.Context,
  VXS.Texture,
  VXS.Color,
  VXS.RenderContextInfo,
  VXS.State;

type
  TContactPoint = class
  public
    Position,
      Normal: TAffineVector;
    Depth: Single;
  end;

  // TVXODECustomCollider
  //
  { The custom collider is designed for generic contact handling. There is a
     contact point generator for sphere, box, capped cylinder, cylinder and
     cone geoms. 

     Once the contact points for a collision are generated the abstract Collide
     function is called to generate the depth and the contact position and
     normal. These points are then sorted and the deepest are applied to ODE. }
  TVXODECustomCollider = class(TVXODEBehaviour)
  private
    
    FGeom: PdxGeom;
    FContactList,
      FContactCache: TList;
    FTransform: TMatrix;
    FContactResolution: Single;

    FRenderContacts: Boolean;
    FContactRenderPoints: TAffineVectorList;
    FPointSize: Single;
    FContactColor: TVXColor;

  protected
    
    procedure Initialize; override;
    procedure Finalize; override;

    procedure WriteToFiler(writer: TWriter); override;
    procedure ReadFromFiler(reader: TReader); override;

    // Test a position for a collision and fill out the contact information.
    function Collide(aPos: TAffineVector; var Depth: Single;
      var cPos, cNorm: TAffineVector): Boolean; virtual; abstract;

    // Clears the contact list so it's ready for another collision.
    procedure ClearContacts;

    // Add a contact point to the list for ApplyContacts to processes.
    procedure AddContact(x, y, z: TdReal); overload;
    procedure AddContact(pos: TAffineVector); overload;

    // Sort the current contact list and apply the deepest to ODE.
    function ApplyContacts(o1, o2: PdxGeom; flags: Integer;
      contact: PdContactGeom; skip: Integer): Integer;

    { Set the transform used that transforms contact points generated with
       AddContact. }
    procedure SetTransform(ATransform: TMatrix);

    procedure SetContactResolution(const Value: Single);
    procedure SetRenderContacts(const Value: Boolean);
    procedure SetPointSize(const Value: Single);
    procedure SetContactColor(const Value: TVXColor);

  public
    
    constructor Create(AOwner: TVXXCollection); override;
    destructor Destroy; override;

    procedure Render(var rci: TVXRenderContextInfo); override;

    property Geom: PdxGeom read FGeom;

  published
    { Defines the resolution of the contact points created for the colliding
       Geom. The number of contact points generated change base don the size
       of the object and the ContactResolution. Lower values generate higher
       resolution contact boundaries, and thus smoother but slower collisions. }
    property ContactResolution: Single read FContactResolution write SetContactResolution;
    { Toggle contact point rendering on and off. (Rendered through the assigned
       Manager.RenderPoint. }
    property RenderContacts: Boolean read FRenderContacts write SetRenderContacts;
    // Contact point rendering size (in pixels).
    property PointSize: Single read FPointSize write SetPointSize;
    // Contact point rendering color.
    property ContactColor: TVXColor read FContactColor write SetContactColor;

  end;

  // TVXODEHeightField
  //
  { Add this behaviour to a TVXHeightField or TVXTerrainRenderer to enable
     height based collisions for spheres, boxes, capped cylinders, cylinders
     and cones. }
  TVXODEHeightField = class(TVXODECustomCollider)
  protected
    
    procedure WriteToFiler(writer: TWriter); override;
    procedure ReadFromFiler(reader: TReader); override;

    function Collide(aPos: TAffineVector; var Depth: Single;
      var cPos, cNorm: TAffineVector): Boolean; override;

  public
    
    constructor Create(AOwner: TVXXCollection); override;

    class function FriendlyName: string; override;
    class function FriendlyDescription: string; override;
    class function UniqueItem: Boolean; override;
    class function CanAddTo(collection: TVXXCollection): Boolean; override;

  end;

function GetODEHeightField(obj: TVXBaseSceneObject): TVXODEHeightField;
function GetOrCreateODEHeightField(obj: TVXBaseSceneObject): TVXODEHeightField;

implementation

var
  vCustomColliderClass: TdGeomClass;
  vCustomColliderClassNum: Integer;

  // GetODEHeightField
  //

function GetODEHeightField(obj: TVXBaseSceneObject): TVXODEHeightField;
begin
  result := TVXODEHeightField(obj.Behaviours.GetByClass(TVXODEHeightField));
end;

// GetOrCreateODEHeightField
//

function GetOrCreateODEHeightField(obj: TVXBaseSceneObject): TVXODEHeightField;
begin
  result := TVXODEHeightField(obj.GetOrCreateBehaviour(TVXODEHeightField));
end;

// GetColliderFromGeom
//

function GetColliderFromGeom(aGeom: PdxGeom): TVXODECustomCollider;
var
  temp: TObject;
begin
  Result := nil;
  temp := dGeomGetData(aGeom);
  if Assigned(temp) then
    if temp is TVXODECustomCollider then
      Result := TVXODECustomCollider(temp);
end;

// ContactSort
//

function ContactSort(Item1, Item2: Pointer): Integer;
var
  c1, c2: TContactPoint;
begin
  c1 := TContactPoint(Item1);
  c2 := TContactPoint(Item2);
  if c1.Depth > c2.Depth then
    result := -1
  else if c1.Depth = c2.Depth then
    result := 0
  else
    result := 1;
end;

// CollideSphere
//

function CollideSphere(o1, o2: PdxGeom; flags: Integer;
  contact: PdContactGeom; skip: Integer): Integer; cdecl;
var
  Collider: TVXODECustomCollider;
  i, j, res: Integer;
  pos: PdVector3;
  R: PdMatrix3;
  rmat, mat: TMatrix;
  rad, dx, dy, dz: TdReal;
begin
  Result := 0;
  Collider := GetColliderFromGeom(o1);
  if not Assigned(Collider) then
    exit;

  pos := dGeomGetPosition(o2);
  R := dGeomGetRotation(o2);
  ODERToVXSceneMatrix(mat, R^, pos^);
  Collider.SetTransform(mat);

  rad := dGeomSphereGetRadius(o2);

  res := Round(10 * rad / Collider.ContactResolution);
  if res < 8 then
    res := 8;

  Collider.AddContact(0, 0, -rad);
  Collider.AddContact(0, 0, rad);
  rmat := CreateRotationMatrixZ(2 * Pi / res);
  for i := 0 to res - 1 do
  begin
    mat := MatrixMultiply(rmat, mat);
    Collider.SetTransform(mat);
    for j := -(res div 2) + 1 to (res div 2) - 1 do
    begin
      dx := rad * cos(j * Pi / res);
      dy := 0;
      dz := rad * sin(j * Pi / res);
      Collider.AddContact(dx, dy, dz);
    end;
  end;

  Result := Collider.ApplyContacts(o1, o2, flags, contact, skip);
  Collider.SetTransform(IdentityHMGMatrix);
end;

// CollideBox
//

function CollideBox(o1, o2: PdxGeom; flags: Integer;
  contact: PdContactGeom; skip: Integer): Integer; cdecl;
var
  Collider: TVXODECustomCollider;
  i, j, res: Integer;
  rcpres, len1, len2: Single;
  s: TdVector3;
  pos: PdVector3;
  R: PdMatrix3;
  mat: TMatrix;
begin
  Result := 0;
  Collider := GetColliderFromGeom(o1);
  if not Assigned(Collider) then
    exit;

  pos := dGeomGetPosition(o2);
  R := dGeomGetRotation(o2);
  ODERToVXSceneMatrix(mat, R^, pos^);
  Collider.SetTransform(mat);

  dGeomBoxGetLengths(o2, s);

  res := Round(Sqrt(MaxFloat([s[0], s[1], s[2]])) / Collider.ContactResolution);
  if res < 1 then
    res := 1;
  rcpres := 1 / res;

  s[0] := 0.5 * s[0];
  s[1] := 0.5 * s[1];
  s[2] := 0.5 * s[2];

  with Collider do
  begin
    // Corners
    AddContact(s[0], s[1], s[2]);
    AddContact(s[0], s[1], -s[2]);
    AddContact(s[0], -s[1], s[2]);
    AddContact(s[0], -s[1], -s[2]);
    AddContact(-s[0], s[1], s[2]);
    AddContact(-s[0], s[1], -s[2]);
    AddContact(-s[0], -s[1], s[2]);
    AddContact(-s[0], -s[1], -s[2]);

    // Edges
    for i := -(res - 1) to (res - 1) do
    begin
      len1 := i * rcpres * s[0];
      AddContact(len1, s[1], s[2]);
      AddContact(len1, s[1], -s[2]);
      AddContact(len1, -s[1], s[2]);
      AddContact(len1, -s[1], -s[2]);
      len1 := i * rcpres * s[1];
      AddContact(s[0], len1, s[2]);
      AddContact(s[0], len1, -s[2]);
      AddContact(-s[0], len1, s[2]);
      AddContact(-s[0], len1, -s[2]);
      len1 := i * rcpres * s[2];
      AddContact(s[0], s[1], len1);
      AddContact(s[0], -s[1], len1);
      AddContact(-s[0], s[1], len1);
      AddContact(-s[0], -s[1], len1);
    end;

    // Faces
    for i := -(res - 1) to (res - 1) do
      for j := -(res - 1) to (res - 1) do
      begin
        len1 := i * rcpres * s[0];
        len2 := j * rcpres * s[1];
        AddContact(len1, len2, s[2]);
        AddContact(len1, len2, -s[2]);
        len2 := j * rcpres * s[2];
        AddContact(len1, s[1], len2);
        AddContact(len1, -s[1], len2);
        len1 := i * rcpres * s[1];
        AddContact(s[0], len1, len2);
        AddContact(-s[0], len1, len2);
      end;
  end;

  Result := Collider.ApplyContacts(o1, o2, flags, contact, skip);
  Collider.SetTransform(IdentityHMGMatrix);
end;

// CollideCapsule
//

function CollideCapsule(o1, o2: PdxGeom; flags: Integer;
  contact: PdContactGeom; skip: Integer): Integer; cdecl;
var
  Collider: TVXODECustomCollider;
  i, j, res: Integer;
  pos: PdVector3;
  R: PdMatrix3;
  mat, rmat: TMatrix;
  rad, len, dx, dy, dz: TdReal;
begin
  Result := 0;

  Collider := GetColliderFromGeom(o1);
  if not Assigned(Collider) then
    exit;

  pos := dGeomGetPosition(o2);
  R := dGeomGetRotation(o2);
  ODERToVXSceneMatrix(mat, R^, pos^);
  Collider.SetTransform(mat);

  dGeomCapsuleGetParams(o2, rad, len);

  res := Round(5 * MaxFloat(4 * rad, len) / Collider.ContactResolution);
  if res < 8 then
    res := 8;

  rmat := CreateRotationMatrixZ(2 * Pi / res);
  with Collider do
  begin
    AddContact(0, 0, -rad - 0.5 * len);
    AddContact(0, 0, rad + 0.5 * len);
    for i := 0 to res - 1 do
    begin
      mat := MatrixMultiply(rmat, mat);
      SetTransform(mat);

      for j := 0 to res do
        AddContact(rad, 0, len * (j / res - 0.5));

      for j := 1 to (res div 2) - 1 do
      begin
        dx := rad * cos(j * Pi / res);
        dy := 0;
        dz := rad * sin(j * Pi / res);
        Collider.AddContact(dx, dy, -dz - 0.5 * len);
        Collider.AddContact(dx, dy, dz + 0.5 * len);
      end;
    end;
  end;

  Result := Collider.ApplyContacts(o1, o2, flags, contact, skip);
  Collider.SetTransform(IdentityHMGMatrix);
end;

// CollideCylinder
//

function CollideCylinder(o1, o2: PdxGeom; flags: Integer;
  contact: PdContactGeom; skip: Integer): Integer; cdecl;
var
  Collider: TVXODECustomCollider;
  i, j, res: Integer;
  pos: PdVector3;
  R: PdMatrix3;
  mat: TMatrix;
  rad, len, dx, dy: TdReal;
begin
  Result := 0;

  Collider := GetColliderFromGeom(o1);
  if not Assigned(Collider) then
    exit;

  pos := dGeomGetPosition(o2);
  R := dGeomGetRotation(o2);
  ODERToVXSceneMatrix(mat, R^, pos^);
  Collider.SetTransform(mat);

  dGeomCylinderGetParams(o2, rad, len);

  res := Round(5 * MaxFloat(4 * rad, len) / Collider.ContactResolution);
  if res < 8 then
    res := 8;

  with Collider do
  begin
    AddContact(0, -0.5 * len, 0);
    AddContact(0, 0.5 * len, 0);
    for i := 0 to res - 1 do
    begin
      SinCosine(2 * Pi * i / res, rad, dy, dx);
      AddContact(dx, -0.5 * len, dy);
      AddContact(dx, 0, dy);
      AddContact(dx, 0.5 * len, dy);

      for j := 0 to res do
        AddContact(dx, len * (j / res - 0.5), dy);

      for j := 1 to (res div 2) - 1 do
      begin
        SinCosine(2 * Pi * i / res, rad * j / (res div 2), dy, dx);
        AddContact(dx, -0.5 * len, dy);
        AddContact(dx, 0.5 * len, dy);
      end;
    end;
  end;

  Result := Collider.ApplyContacts(o1, o2, flags, contact, skip);
  Collider.SetTransform(IdentityHMGMatrix);
end;

// GetCustomColliderFn
//

function GetCustomColliderFn(num: Integer): TdColliderFn; cdecl;
begin
  if num = dSphereClass then
    Result := CollideSphere
  else if num = dBoxClass then
    Result := CollideBox
  else if num = dCapsuleClass then
    Result := CollideCapsule
  else if num = dCylinderClass then
    Result := CollideCylinder
  else
    Result := nil;
end;

// ---------------
// --------------- TVXODECustomCollider --------------
// ---------------

// Create
//

constructor TVXODECustomCollider.Create(AOwner: TVXXCollection);
begin
  inherited;

  FContactList := TList.Create;
  FContactCache := TList.Create;

  FContactResolution := 1;

  FRenderContacts := False;
  FContactRenderPoints := TAffineVectorList.Create;
  FContactColor := TVXColor.CreateInitialized(Self, clrRed, NotifyChange);
  FPointSize := 3;
end;

// Destroy
//

destructor TVXODECustomCollider.Destroy;
var
  i: integer;
begin
  FContactList.Free;
  for i := 0 to FContactCache.Count - 1 do
    TContactPoint(FContactCache[i]).Free;
  FContactCache.Free;
  FContactRenderPoints.Free;
  FContactColor.Free;
  inherited;
end;

// Initialize
//

procedure TVXODECustomCollider.Initialize;
begin
  if not Assigned(Manager) then
    exit;
  if not Assigned(Manager.Space) then
    exit;
  if vCustomColliderClassNum = 0 then
  begin
    with vCustomColliderClass do
    begin
      bytes := 0;
      collider := GetCustomColliderFn;
      aabb := dInfiniteAABB;
      aabb_test := nil;
      dtor := nil;
    end;
    vCustomColliderClassNum := dCreateGeomClass(vCustomColliderClass);
  end;
  FGeom := dCreateGeom(vCustomColliderClassNum);
  dGeomSetData(FGeom, Self);
  dSpaceAdd(Manager.Space, FGeom);
  inherited;
end;

// Finalize
//

procedure TVXODECustomCollider.Finalize;
begin
  if not Initialized then
    exit;
  if Assigned(FGeom) then
  begin
    dGeomDestroy(FGeom);
    FGeom := nil;
  end;
  inherited;
end;

// WriteToFiler
//

procedure TVXODECustomCollider.WriteToFiler(writer: TWriter);
begin
  inherited;
  with writer do
  begin
    WriteInteger(0); // Archive version
    WriteFloat(FContactResolution);
    WriteBoolean(FRenderContacts);
    WriteFloat(FPointSize);
    Write(PByte(FContactColor.AsAddress)^, 4);
  end;
end;

// ReadFromFiler
//

procedure TVXODECustomCollider.ReadFromFiler(reader: TReader);
var
  archiveVersion: Integer;
begin
  inherited;
  with reader do
  begin
    archiveVersion := ReadInteger;
    Assert(archiveVersion = 0); // Archive version
    FContactResolution := ReadFloat;
    FRenderContacts := ReadBoolean;
    FPointSize := ReadFloat;
    Read(PByte(FContactColor.AsAddress)^, 4);
  end;
end;

// ClearContacts
//

procedure TVXODECustomCollider.ClearContacts;
begin
  FContactList.Clear;
end;

// AddContact (x,y,z)
//

procedure TVXODECustomCollider.AddContact(x, y, z: TdReal);
begin
  AddContact(AffineVectorMake(x, y, z));
end;

// AddContact (pos)
//

procedure TVXODECustomCollider.AddContact(pos: TAffineVector);
var
  absPos, colPos, colNorm: TAffineVector;
  depth: Single;
  ContactPoint: TContactPoint;
begin
  absPos := AffineVectorMake(VectorTransform(PointMake(pos), FTransform));
  if Collide(absPos, depth, colPos, colNorm) then
  begin
    if FContactList.Count < FContactCache.Count then
      ContactPoint := FContactCache[FContactList.Count]
    else
    begin
      ContactPoint := TContactPoint.Create;
      FContactCache.Add(ContactPoint);
    end;
    ContactPoint.Position := colPos;
    ContactPoint.Normal := colNorm;
    ContactPoint.Depth := depth;
    FContactList.Add(ContactPoint);
  end;
  if FRenderContacts and Manager.Visible and Manager.VisibleAtRunTime then
    FContactRenderPoints.Add(absPos);
end;

// ApplyContacts
//

function TVXODECustomCollider.ApplyContacts(o1, o2: PdxGeom;
  flags: Integer; contact: PdContactGeom; skip: Integer): Integer;
var
  i, maxContacts: integer;
begin
  FContactList.Sort(ContactSort);
  Result := 0;
  maxContacts := flags and $FFFF;
  try
    for i := 0 to FContactList.Count - 1 do
    begin
      if Result >= maxContacts then
        Exit;
      with TContactPoint(FContactList[i]) do
      begin
        contact.depth := Depth;
        contact.pos[0] := Position.X;
        contact.pos[1] := Position.Y;
        contact.pos[2] := Position.Z;
        contact.pos[3] := 1;
        contact.normal[0] := -Normal.X;
        contact.normal[1] := -Normal.Y;
        contact.normal[2] := -Normal.Z;
        contact.normal[3] := 0;
      end;
      contact.g1 := o1;
      contact.g2 := o2;
      contact := PdContactGeom(Integer(contact) + skip);
      Inc(Result);
    end;
  finally
    ClearContacts;
  end;
end;

// SetTransform
//

procedure TVXODECustomCollider.SetTransform(ATransform: TMatrix);
begin
  FTransform := ATransform;
end;

// SetContactResolution
//

procedure TVXODECustomCollider.SetContactResolution(const Value: Single);
begin
  FContactResolution := Value;
  if FContactResolution <= 0 then
    FContactResolution := 0.01;
end;

// Render
//

procedure TVXODECustomCollider.Render(var rci: TVXRenderContextInfo);
var
  i: Integer;
begin
  if FRenderContacts and (FContactRenderPoints.Count > 0) then
  begin
    glColor3fv(FContactColor.AsAddress);
    rci.VXStates.PointSize := FPointSize;
    glBegin(GL_POINTS);
    for i := 0 to FContactRenderPoints.Count - 1 do
      glVertex3fv(@FContactRenderPoints.List[i]);
    glEnd;
  end;
  FContactRenderPoints.Clear;
end;

// SetRenderContacts
//

procedure TVXODECustomCollider.SetRenderContacts(const Value: Boolean);
begin
  if Value <> FRenderContacts then
  begin
    FRenderContacts := Value;
    NotifyChange(Self);
  end;
end;

// SetContactColor
//

procedure TVXODECustomCollider.SetContactColor(const Value: TVXColor);
begin
  FContactColor.Assign(Value);
end;

// SetPointSize
//

procedure TVXODECustomCollider.SetPointSize(const Value: Single);
begin
  if Value <> FPointSize then
  begin
    FPointSize := Value;
    NotifyChange(Self);
  end;
end;

// ---------------
// --------------- TVXODEHeightField --------------
// ---------------

// Create
//

constructor TVXODEHeightField.Create(AOwner: TVXXCollection);
var
  Allow: Boolean;
begin
  Allow := False;
  if Assigned(AOwner) then
  begin
    if Assigned(AOwner.Owner) then
    begin
      if ((AOwner.Owner) is TVXTerrainRenderer)
        or ((AOwner.Owner) is TVXHeightField) then
        Allow := True;
    end;
  end;

  if not Allow then
    raise Exception.Create('This element must be a behaviour of a TVXTerrainRenderer or TVXHeightField');

  inherited Create(AOwner);
end;

// WriteToFiler
//

procedure TVXODEHeightField.WriteToFiler(writer: TWriter);
begin
  inherited;
  with writer do
  begin
    WriteInteger(0); // Archive version
  end;
end;

// ReadFromFiler
//

procedure TVXODEHeightField.ReadFromFiler(reader: TReader);
var
  archiveVersion: Integer;
begin
  inherited;
  with reader do
  begin
    archiveVersion := ReadInteger;
    Assert(archiveVersion = 0); // Archive version
  end;
end;

// FriendlyName
//

class function TVXODEHeightField.FriendlyName: string;
begin
  Result := 'ODE HeightField Collider';
end;

// FriendlyDescription
//

class function TVXODEHeightField.FriendlyDescription: string;
begin
  Result := 'A custom ODE collider powered by it''s parent TVXTerrainRenderer or TVXHeightField';
end;

// UniqueItem
//

class function TVXODEHeightField.UniqueItem: Boolean;
begin
  Result := True;
end;

// CanAddTo
//

class function TVXODEHeightField.CanAddTo(collection: TVXXCollection): Boolean;
begin
  Result := False;
  if collection is TVXBehaviours then
    if Assigned(TVXBehaviours(collection).Owner) then
      if (TVXBehaviours(collection).Owner is TVXHeightField)
        or (TVXBehaviours(collection).Owner is TVXTerrainRenderer) then
        Result := True;
end;

// Collide
//

function TVXODEHeightField.Collide(aPos: TAffineVector;
  var Depth: Single; var cPos, cNorm: TAffineVector): Boolean;

  function AbsoluteToLocal(vec: TVector): TVector;
  var
    mat: TMatrix;
  begin
    if Owner.Owner is TVXHeightField then
      Result := TVXHeightField(Owner.Owner).AbsoluteToLocal(vec)
    else if Owner.Owner is TVXTerrainRenderer then
    begin
      mat := TVXTerrainRenderer(Owner.Owner).AbsoluteMatrix;
      NormalizeMatrix(mat);
      InvertMatrix(mat);
      Result := VectorTransform(vec, mat);
    end
    else
      Assert(False);
  end;

  function LocalToAbsolute(vec: TVector): TVector;
  var
    mat: TMatrix;
  begin
    if Owner.Owner is TVXHeightField then
      Result := TVXHeightField(Owner.Owner).LocalToAbsolute(vec)
    else if Owner.Owner is TVXTerrainRenderer then
    begin
      mat := TVXTerrainRenderer(Owner.Owner).AbsoluteMatrix;
      NormalizeMatrix(mat);
      Result := VectorTransform(vec, mat);
    end
    else
      Assert(False);
  end;

  function GetHeight(pos: TVector; var height: Single): Boolean;
  var
    dummy1: TVector;
    dummy2: TTexPoint;
  begin
    Result := False;
    if Owner.Owner is TVXTerrainRenderer then
    begin
      height := TVXTerrainRenderer(Owner.Owner).InterpolatedHeight(LocalToAbsolute(pos));
      Result := True;
    end
    else if Owner.Owner is TVXHeightField then
    begin
      if Assigned(TVXHeightField(Owner.Owner).OnGetHeight) then
      begin
        TVXHeightField(Owner.Owner).OnGetHeight(pos.X, pos.Y, height, dummy1, dummy2);
        Result := True;
      end;
    end;
  end;

const
  cDelta = 0.1;
var
  localPos: TVector;
  height: Single;
  temp1, temp2: TAffineVector;
begin
  localPos := AbsoluteToLocal(PointMake(aPos));
  if GetHeight(localPos, height) then
  begin
    Depth := height - localPos.Z;
    Result := (Depth > 0);
    if Result then
    begin
      localPos.Z := height;
      cPos := AffineVectorMake(LocalToAbsolute(localPos));
      temp1.X := localPos.X + cDelta;
      temp1.Y := localPos.Y;
      temp1.Z := localPos.Z;
      GetHeight(PointMake(temp1), temp1.Z);
      temp2.X := localPos.X;
      temp2.Y := localPos.Y + cDelta;
      temp2.Z := localPos.Z;
      GetHeight(PointMake(temp2), temp2.Z);
      cNorm := CalcPlaneNormal(AffineVectorMake(localPos), temp1, temp2);
      cNorm := AffineVectorMake(LocalToAbsolute(VectorMake(cNorm)));
    end;
  end
  else
    Result := False;
end;

// ------------------------------------------------------------------
// ------------------------------------------------------------------
// ------------------------------------------------------------------
initialization
  // ------------------------------------------------------------------
  // ------------------------------------------------------------------
  // ------------------------------------------------------------------

  RegisterXCollectionItemClass(TVXODEHeightField);

  // ------------------------------------------------------------------
  // ------------------------------------------------------------------
  // ------------------------------------------------------------------
finalization
  // ------------------------------------------------------------------
  // ------------------------------------------------------------------
  // ------------------------------------------------------------------

  UnregisterXCollectionItemClass(TVXODEHeightField);

end.

