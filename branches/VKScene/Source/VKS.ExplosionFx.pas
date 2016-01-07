//
// VKScene project based on GLScene library, http://glscene.sourceforge.net 
//
{
  TVKBExplosionFX Effect 

  Description: this effect explodes a mesh object into triangles
  that fly over. You can define a default direction, in wich case
  the pieces of the mesh will follow that direction, only rotating,
  or if you define a null vector as the direction, a vector will be
  calculated for each triangle, based on the normal vector of that
  triangle, with a little random addition so things look better.
  Pretty neat :) 

  Note: the owner of this behaviour should be any class that derives
  from TVKBaseMesh class or any other class derived from TVKBaseMesh.
  Also, the structure of the mesh is lost after the caching of information,
  so if you'll need the mesh after exploding it, you'll have to save the
  MeshObjects property of the mesh, OR load it again.
}
unit VKS.ExplosionFx;

interface

{$i VKScene.inc}

uses
  VKS.OpenGLTokens, VKS.VectorGeometry, VKS.Scene, VKS.VectorFileObjects,
  VKS.VectorTypes, VKS.VectorLists, VKS.XCollection, VKS.Coordinates,
  VKS.RenderContextInfo, VKS.Context, VKS.State;

type
  TVKBExplosionFX = class(TVKObjectPreEffect)
  private
    FTriList: TAffineVectorList;
    FRotList: TAffineVectorList;
    FDirList: TAffineVectorList;
    FPosList: TAffineVectorList;
    FEnabled: boolean;
    FFaceCount: integer;
    FSpeed: single;
    FDirection: TVKCoordinates;
    FMaxSteps: integer;
    FStep: integer;
    procedure SetTriList(Value: TAffineVectorList);
    procedure SetRotList(Value: TAffineVectorList);
    procedure SetDirList(Value: TAffineVectorList);
    procedure SetPosList(Value: TAffineVectorList);
    procedure SetDirection(value: TVKCoordinates);
    procedure SetEnabled(value: boolean);
  protected
    property TriList: TAffineVectorList read FTriList write SetTriList;
    property RotList: TAffineVectorList read FRotList write SetRotList;
    property DirList: TAffineVectorList read FDirList write SetDirList;
    property PosList: TAffineVectorList read FPosList write SetPosList;
    property FaceCount: integer read FFAceCount write FFaceCount;
    procedure CacheInfo;
  public
    property Enabled: boolean read FEnabled write SetEnabled;
    property Step: integer read FStep;
    constructor Create(aOwner : TXCollection); override;
    destructor Destroy; override;
    procedure Render(var rci : TRenderContextInfo); override;
    { resets the behaviour, so the information can be re-cached and
      the mesh can be exploded again }
    procedure Reset;
    class function FriendlyName : String; override;
    class function FriendlyDescription : String; override;
  published
    property MaxSteps: integer read FMaxSteps write FMaxSteps;
    property Speed: single read FSpeed write FSpeed;
    property Direction: TVKCoordinates read FDirection write SetDirection;
  end;

implementation

{ TVKBExplosionFx }

// Create
//
constructor TVKBExplosionFx.Create(aOwner: TXCollection);
begin
  inherited Create(AOwner);
  FTriList := TAffineVectorList.Create;
  FRotList := TAffineVectorList.Create;
  FDirList := TAffineVectorList.Create;
  FPosList := TAffineVectorList.Create;
  FDirection := TVKCoordinates.CreateInitialized(Self, NullHmgVector, csPoint);
end;

// Destroy
//
destructor TVKBExplosionFX.Destroy;
begin
  FEnabled := False;
  FTriList.Free;
  FRotList.Free;
  FDirList.Free;
  FPosList.Free;
  FDirection.Free;
  inherited Destroy;
end;

// FriendlyName
//
class function TVKBExplosionFX.FriendlyName: string;
begin
  Result := 'ExplosionFx';
end;

// FriendlyDescription
//
class function TVKBExplosionFX.FriendlyDescription: string;
begin
  Result := 'Explosion FX';
end;

// SetTriList
//
procedure TVKBExplosionFx.SetTriList(Value: TAffineVectorList);
begin
  FTriList.Assign(Value);
end;

// SetRotList
//
procedure TVKBExplosionFx.SetRotList(Value: TAffineVectorList);
begin
  FRotList.Assign(Value);
end;

// SetDirList
//
procedure TVKBExplosionFx.SetDirList(Value: TAffineVectorList);
begin
  FDirList.Assign(Value);
end;

// SetPosList
//
procedure TVKBExplosionFx.SetPosList(Value: TAffineVectorList);
begin
  FPosList.Assign(Value);
end;

// SetDirection
//
procedure TVKBExplosionFx.SetDirection(Value: TVKCoordinates);
begin
  Value.Normalize;
  FDirection.Assign(Value);
end;

// SetEnabled
//
procedure TVKBExplosionFx.SetEnabled(Value: boolean);
begin
  FEnabled := Value;
end;

// Reset
//
procedure TVKBExplosionFx.Reset;
begin
  FEnabled := False;
  FStep := 0;
  FTriList.Clear;
  FRotList.Clear;
  FDirList.Clear;
  FPosList.Clear;
  FFaceCount := 0;
end;

// CacheInfo
//
procedure TVKBExplosionFx.CacheInfo;
var
  Face: integer;
  p1, p2, p3, v1, v2, posi: TAffineVector;
  Normal: TVector;
begin
  // make sure we can explode this object
  if not OwnerBaseSceneObject.InheritsFrom(TVKBaseMesh) then begin
    FEnabled := False;
    Exit;
  end;
  FTriList.Free;
  // get all the triangles of all the meshObjects
  FTriList := TVKBaseMesh(OwnerBaseSceneObject).MeshObjects.ExtractTriangles;
  FaceCount := FTriList.Count div 3;
  // set initial direction, rotation and position
  for Face := 0 to Facecount - 1 do begin
  // get the vertices of the triangle
    SetVector(p1, FTriList.Items[Face * 3]);
    SetVector(p2, FTriList.Items[Face * 3 + 1]);
    SetVector(p3, FTriList.Items[Face * 3 + 2]);
  // if the direction property is a null vector, than the direction is
  // given by the normal of the face
    if VectorEquals(FDirection.AsVector, NullHmgVector) then begin
      v1 := VectorSubtract(p2, p1);
      v2 := VectorSubtract(p2, p3);
      NormalizeVector(v1); // use of procedure is faster: PhP
      NormalizeVector(v2); // use of procedure is faster: PhP
      SetVector(Normal, VectorCrossProduct(v1, v2)); // use of procedure is faster: PhP
  // randomly rotate the normal vector so the faces are somewhat scattered
      case Random(3) of
        0: RotateVector(Normal, XVector, DegToRadian(45.0*Random));
        1: RotateVector(Normal, YVector, DegToRadian(45.0*Random));
        2: RotateVector(Normal, ZVector, DegToRadian(45.0*Random));
      end;
      NormalizeVector(Normal);
      FDirList.Add(Normal);
    end
    else
      FDirList.Add(FDirection.AsVector);
  // calculate the center (position) of the triangle so it rotates around its center
    posi.V[0] := (p1.V[0] + p2.V[0] + p3.V[0]) / 3;
    posi.V[1] := (p1.V[1] + p2.V[1] + p3.V[1]) / 3;
    posi.V[2] := (p1.V[2] + p2.V[2] + p3.V[2]) / 3;
    FPosList.add(posi);
  // random rotation (in degrees)
    FRotList.Add(DegToRadian(3.0*Random), DegToRadian(3.0*Random), DegToRadian(3.0*Random));
  end;
  // Dispose the struture of the mesh
  TVKBaseMesh(OwnerBaseSceneObject).MeshObjects.Clear;
  TVKBaseMesh(OwnerBaseSceneObject).StructureChanged;
end;

// Render
//
procedure TVKBExplosionFX.Render(var rci : TRenderContextInfo);
var
  Face: integer;
  dir, p1, p2, p3: TAffineVector;
  mat: TMatrix;

begin
  if not FEnabled then
    Exit;
  // cache de list of vertices
  if FTriList.Count <= 0 then begin
    CacheInfo;
    if not FEnabled then
      Exit;
  end;
  // render explosion
  rci.GLStates.Disable(stCullFace);
  GL.Begin_(GL_TRIANGLES);
  for Face := 0 to FaceCount - 1 do begin
    SetVector(p1, FTriList.Items[Face * 3]);
    SetVector(p2, FTriList.Items[Face * 3 + 1]);
    SetVector(p3, FTriList.Items[Face * 3 + 2]);
  // rotate the face
    mat := IdentityHmgMatrix;
    mat := MatrixMultiply(mat, CreateRotationMatrixX(FRotList.Items[face].V[0]));
    mat := MatrixMultiply(mat, CreateRotationMatrixY(FRotList.Items[face].V[1]));
    mat := MatrixMultiply(mat, CreateRotationMatrixZ(FRotList.Items[face].V[2]));
    SubtractVector(p1, FPosList.Items[Face]);  // use of procedure is faster: PhP
    SubtractVector(p2, FPosList.Items[Face]);  // -''-
    SubtractVector(p3, FPosList.Items[Face]);  // -''-
    p1 := VectorTransform(p1, mat);
    p2 := VectorTransform(p2, mat);
    p3 := VectorTransform(p3, mat);
    AddVector(p1, FPosList.Items[Face]);  // use of procedure is faster: PhP
    AddVector(p2, FPosList.Items[Face]);  // -''-
    AddVector(p3, FPosList.Items[Face]);  // -''-
  // move the face in the direction it is heading
    SetVector(dir, FDirList.Items[Face]);
    GL.Normal3f(dir.V[0], dir.V[1], dir.V[2]);
    ScaleVector(dir, Speed);
    AddVector(p1, dir);
    AddVector(p2, dir);
    AddVector(p3, dir);
  // also, move the center of the face
    FPosList.Items[Face] := VectorAdd(FPosList.Items[Face], dir);

  // save the changes
    FTrilist.Items[face * 3] := p1;
    FTrilist.Items[face * 3 +1] := p2;
    FTrilist.Items[face * 3 +2] := p3;

    GL.Vertex3f(p1.V[0], p1.V[1], p1.V[2]);
    GL.Vertex3f(p2.V[0], p2.V[1], p2.V[2]);
    GL.Vertex3f(p3.V[0], p3.V[1], p3.V[2]);
  end;
  GL.End_;
  rci.GLStates.Enable(stCullFace);
  if FMaxSteps <> 0 then begin
    Inc(FStep);
    if FStep = FMaxSteps then
      FEnabled := False;
  end;
end;

initialization
	// class registrations
	RegisterXCollectionItemClass(TVKBExplosionFX);

finalization

	UnregisterXCollectionItemClass(TVKBExplosionFX);

end.
