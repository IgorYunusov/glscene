//
// VKScene Component Library, based on GLScene http://glscene.sourceforge.net 
//
{
  3ds-specific scene objects.
}
unit VKS.File3DSSceneObjects;

interface

{$I VKScene.inc}

uses
  System.Classes,
  System.SysUtils,
  System.Math,
  
  VKS.VectorGeometry, Winapi.OpenGL, Winapi.OpenGLext,  OpenGLAdapter, VKS.Context, VKS.Scene,
  VKS.VectorFileObjects, VKS.VectorTypes, VKS.PersistentClasses,
  VKS.CrossPlatform, VKS.Coordinates, VKS.RenderContextInfo, VKS.State;

type
  TVKFile3DSLight = class(TVKLightSource)
  private
    FTargetPos: TVKCoordinates;
    FHotSpot: Single;
    FMultipler: Single;
  public
    constructor Create(AOwner: TComponent); override;
    procedure DoRender(var rci: TVKRenderContextInfo; renderSelf, renderChildren: Boolean); override;
    procedure CoordinateChanged(Sender: TVKCustomCoordinates); override;
    destructor Destroy; override;
  published
    property SpotTargetPos: TVKCoordinates read FTargetPos;
    property HotSpot: Single read FHotSpot write FHotSpot;
    property Multipler: Single read FMultipler write FMultipler;
  end;

  TVKFile3DSCamera = class(TVKCamera)
  private
    FTargetPos: TVKCoordinates;
    FQuadCyl: array[0..1] of PGLUquadric;
    FQuadDisk: array[0..1] of PGLUquadric;
  public
    constructor Create(AOwner: TComponent); override;
    procedure DoRender(var rci: TVKRenderContextInfo; renderSelf, renderChildren: Boolean); override;
    procedure CoordinateChanged(Sender: TVKCustomCoordinates); override;
    destructor Destroy; override;
  published
    property CameraTargetPos: TVKCoordinates read FTargetPos;
    property RollAngle;
  end;

  TVKFile3DSActor = class(TVKActor)
  private
    procedure ReadMesh(Stream: TStream);
    procedure WriteMesh(Stream: TStream);
  protected
    procedure DefineProperties(Filer: TFiler); override;
  end;

  TVKFile3DSFreeForm = class(TVKFreeForm)
  private
    FTransfMat, FScaleMat, ParentMatrix: TMatrix;

    FS_Rot3DS: TVKCoordinates4;
    FRot3DS: TVKCoordinates4;
    FScale3DS: TVKCoordinates4;
    procedure ReadMesh(Stream: TStream);
    procedure WriteMesh(Stream: TStream);
  protected
    procedure DefineProperties(Filer: TFiler); override;
  public
    FRefMat: TMatrix;
    constructor Create(AOWner: TComponent); override;
    destructor Destroy; override;
    procedure BuildList(var rci: TVKRenderContextInfo); override;
    procedure CoordinateChanged(Sender: TVKCustomCoordinates); override;
    function AxisAlignedDimensionsUnscaled: TVector; override;
    function BarycenterAbsolutePosition: TVector; override;
  published
    property S_Rot3DS: TVKCoordinates4 read FS_Rot3DS;
    property Rot3DS: TVKCoordinates4 read FRot3DS;
    property Scale3DS: TVKCoordinates4 read FScale3DS;
  end;

var
  vGLFile3DSSceneObjects_RenderCameraAndLights: Boolean = False;

implementation

function MakeRotationQuaternion(const axis: TAffineVector; angle: Single): TQuaternion;
var
  v: Tvector;
  halfAngle, invAxisLengthMult: Single;
begin
  halfAngle := (angle) / 2;
  invAxisLengthMult := 1 / VectorLength(axis) * sin(halfAngle);

  v.X := axis.X * invAxisLengthMult;
  v.Y := axis.Y * invAxisLengthMult;
  v.Z := axis.Z * invAxisLengthMult;
  v.W := cos(halfAngle);

  Result.ImagPart := AffineVectorMake(v);
  Result.RealPart := v.W;
end;

function QuaternionToRotateMatrix(const Quaternion: TQuaternion): TMatrix;
var
  wx, wy, wz, xx, yy, yz, xy, xz, zz, x2, y2, z2: Single;
  quat: TVector;
  m: TMatrix;
begin
  quat := VectorMake(Quaternion.ImagPart);
  quat.W := Quaternion.RealPart;

  x2 := quat.X + quat.X;
  y2 := quat.Y + quat.Y;
  z2 := quat.Z + quat.Z;
  xx := quat.X * x2;
  xy := quat.X * y2;
  xz := quat.X * z2;
  yy := quat.Y * y2;
  yz := quat.Y * z2;
  zz := quat.Z * z2;
  wx := quat.W * x2;
  wy := quat.W * y2;
  wz := quat.W * z2;

  m.X.X := 1.0 - (yy + zz);
  m.X.Y := xy - wz;
  m.X.Z := xz + wy;
  m.Y.X := xy + wz;
  m.Y.Y := 1.0 - (xx + zz);
  m.Y.Z := yz - wx;
  m.Z.X := xz - wy;
  m.Z.Y := yz + wx;
  m.Z.Z := 1.0 - (xx + yy);

  m.X.W := 0;
  m.Y.W := 0;
  m.Z.W := 0;
  m.W.X := 0;
  m.W.Y := 0;
  m.W.Z := 0;
  m.W.W := 1;

  Result := m;
end;

constructor TVKFile3DSLight.Create(AOwner: TComponent);
begin
  inherited;

  FTargetPos := TVKCoordinates.CreateInitialized(self, VectorMake(NullVector), csPoint);
  FHotSpot := 1;
  FMultipler := 1;
end;

procedure TVKFile3DSLight.DoRender(var rci: TVKRenderContextInfo; renderSelf, renderChildren: Boolean);

  procedure BuildFace;
  begin
    glBegin(GL_TRIANGLES);
    glVertex3f(0.03, 0, 0);
    glVertex3f(0, 0.03, 0);
    glVertex3f(0, 0, 0.07);
    glEnd;
  end;

var
  dv: Single;

begin
  inherited;
  if not vGLFile3DSSceneObjects_RenderCameraAndLights then
    Exit;

  rci.VKStates.PolygonMode := pmLines;
  glPushMatrix;

  dv := VectorDistance(Position.AsVector, rci.cameraPosition);
  glScalef(dv, dv, dv);

  // Up.
  BuildFace;
  glRotatef(90, 0, 0, 1);
  BuildFace;
  glRotatef(180, 0, 0, 1);
  BuildFace;
  glRotatef(270, 0, 0, 1);
  BuildFace;

  // Down.
  glRotatef(180, 0, 1, 0);
  BuildFace;
  glRotatef(90, 0, 0, 1);
  BuildFace;
  glRotatef(180, 0, 0, 1);
  BuildFace;
  glRotatef(270, 0, 0, 1);
  BuildFace;

  glPopMatrix;
end;

procedure TVKFile3DSLight.CoordinateChanged(Sender: TVKCustomCoordinates);
begin
  inherited;

  if (Sender = FTargetPos) or (Sender = Position) then
    SpotDirection.SetVector(VectorNormalize(VectorSubtract(FTargetPos.AsAffineVector, Position.AsAffineVector)));
end;

destructor TVKFile3DSLight.Destroy;
begin
  FTargetPos.Free;
  inherited;
end;

constructor TVKFile3DSCamera.Create(AOwner: TComponent);
var
  I: Integer;
begin
  inherited;

  FTargetPos := TVKCoordinates.CreateInitialized(self, VectorMake(NullVector), csPoint);

  for I := 0 to 1 do
  begin
    //    FQuadCyl[I] := gluNewQuadric;
    //    FQuadDisk[I] := gluNewQuadric;
    //    gluQuadricNormals(FQuadCyl[I], GLU_SMOOTH);
    //    gluQuadricNormals(FQuadDisk[I], GLU_SMOOTH);
  end;
end;

procedure TVKFile3DSCamera.DoRender(var rci: TVKRenderContextInfo; renderSelf, renderChildren: Boolean);

  procedure BuildCyl;
  begin
    //    gluCylinder(FQuadCyl[0], 1, 1, 0.5, 6, 1);
    //    glTranslatef(0, 0, 0.5);
    //    gluDisk(FQuadDisk[0], 0, 1, 6, 1);
    glTranslatef(0, 0, -0.5);
    rci.VKStates.InvertFrontFace;
    //    gluDisk(FQuadDisk[0], 0, 1, 6, 1);
    rci.VKStates.InvertFrontFace;
  end;

  procedure BuildFace;
  begin
    glRotatef(-90, 0, 1, 0);
    glRotatef(45, 0, 0, 1);
    glTranslatef(0, -0.5, 1);
    //    gluCylinder(FQuadCyl[0], 0.5, 1.3, 2.4, 4, 1);
    glTranslatef(0, 0, 2.4);
    //    gluDisk(FQuadDisk[0], 0, 1.3, 4, 1);
  end;

var
  dv, ang: Single;
  v, v1: TAffineVector;

begin
  inherited;
  if not vGLFile3DSSceneObjects_RenderCameraAndLights then
    Exit;

  v := VectorNormalize(VectorSubtract(FTargetPos.AsAffineVector, Position.AsAffineVector));

  v1 := AffineVectorMake(v.X, v.Y, 0);
  NormalizeVector(v1);
  ang := ArcCosine(VectorDotProduct(v, v1));

  rci.VKStates.PolygonMode := pmLines;

  glPushMatrix;
  glRotatef(ang * 180 / pi, 0, 0, 1);
  dv := VectorDistance(Position.AsVector, rci.cameraPosition);
  glScalef(dv / 25, dv / 25, dv / 25);

  glRotateF(90, 0, 1, 0);
  glTranslatef(0, 1, 0);
  BuildCyl;
  glTranslatef(1, -1, 0);
  BuildCyl;
  BuildFace;
  glPopMatrix;

  rci.VKStates.PolygonMode := pmFill;
end;

procedure TVKFile3DSCamera.CoordinateChanged(Sender: TVKCustomCoordinates);
begin
  inherited;

  if (Sender = FTargetPos) or (Sender = Position) then
  begin
    //    Up.AsAffineVector := ZVector;
    //    Direction.SetVector(VectorNormalize(VectorSubtract(FTargetPos.AsAffineVector, Position.AsAffineVector)));
  end;
end;

destructor TVKFile3DSCamera.Destroy;
var
  I: Integer;
begin
  inherited;
  FTargetPos.Free;
  for I := 0 to 1 do
  begin
    gluDeleteQuadric(@FQuadCyl[I]);
    gluDeleteQuadric(@FQuadDisk[I]);
  end;
end;

procedure TVKFile3DSActor.ReadMesh(Stream: TStream);
var
  virt: TBinaryReader;
begin
  virt := TBinaryReader.Create(Stream);
  MeshOBjects.ReadFromFiler(virt);
  virt.Free;
end;

procedure TVKFile3DSActor.WriteMesh(Stream: TStream);
var
  virt: TBinaryWriter;
begin
  virt := TBinaryWriter.Create(Stream);
  MeshOBjects.WriteToFiler(virt);
  virt.Free;
end;

procedure TVKFile3DSActor.DefineProperties(Filer: TFiler);
begin
  Filer.DefineBinaryProperty('MeshObjectsData', ReadMesh, WriteMesh, True);
end;

constructor TVKFile3DSFreeForm.Create(AOWner: TComponent);
begin
  inherited;

  FRefMat := IdentityHmgMatrix;
  FTransfMat := IdentityHmgMatrix;
  FScaleMat := IdentityHmgMatrix;
  FS_Rot3DS := TVKCoordinates4.CreateInitialized(self, VectorMake(1, 0, 0), csVector);
  FRot3DS := TVKCoordinates4.CreateInitialized(self, VectorMake(1, 0, 0), csVector);
  FScale3DS := TVKCoordinates4.CreateInitialized(self, VectorMake(1, 1, 1), csVector);

  ObjectStyle := [osDirectDraw];
end;

destructor TVKFile3DSFreeForm.Destroy;
begin
  FS_Rot3DS.Free;
  FRot3DS.Free;
  FScale3DS.Free;

  inherited;
end;

procedure TVKFile3DSFreeForm.ReadMesh(Stream: TStream);
var
  v: TVector;
  virt: TBinaryReader;
begin
  virt := TBinaryReader.Create(Stream);

  virt.read(FRefMat, sizeof(FRefMat));
  virt.read(v, sizeof(v));
  S_Rot3DS.SetVector(v);
  virt.read(v, sizeof(v));
  Rot3DS.SetVector(v);
  virt.read(v, sizeof(v));
  Scale3DS.SetVector(v);

  MeshOBjects.ReadFromFiler(virt);
  virt.Free;
end;

procedure TVKFile3DSFreeForm.WriteMesh(Stream: TStream);
var
  virt: TBinaryWriter;
  v: TVector;
begin
  virt := TBinaryWriter.Create(Stream);

  virt.write(FRefMat, sizeof(FRefMat));
  v := S_Rot3DS.AsVector;
  virt.write(v, sizeof(v));
  v := Rot3DS.AsVector;
  virt.write(v, sizeof(v));
  v := Scale3DS.AsVector;
  virt.write(v, sizeof(v));

  MeshOBjects.WriteToFiler(virt);
  virt.Free;
end;

procedure TVKFile3DSFreeForm.DefineProperties(Filer: TFiler);
begin
  Filer.DefineBinaryProperty('MeshObjectsData', ReadMesh, WriteMesh, True);
end;

procedure TVKFile3DSFreeForm.BuildList(var rci: TVKRenderContextInfo);
begin
  glMultMatrixf(@FTransfMat);
  glMultMatrixf(@FScaleMat);

  glPushMatrix;
  glMultMatrixf(@FRefMat);
  inherited;
  glPopMatrix;

  if parent is TVKFile3DSFreeForm then
    ParentMatrix := (parent as TVKFile3DSFreeForm).ParentMatrix
  else
    ParentMatrix := IdentityHmgMatrix;

  ParentMatrix := MatrixMultiply(FScaleMat, ParentMatrix);
  ParentMatrix := MatrixMultiply(FTransfMat, ParentMatrix);
end;

procedure TVKFile3DSFreeForm.CoordinateChanged(Sender: TVKCustomCoordinates);
var
  quat, quat1, quat2: TQuaternion;
begin
  inherited;

  if Sender.ClassType = FRot3DS.ClassType then
  begin
    quat1 := MakeRotationQuaternion(FS_Rot3DS.AsAffineVector, FS_Rot3DS.W);
    quat2 := MakeRotationQuaternion(FRot3DS.AsAffineVector, FRot3DS.W);

    quat := QuaternionMultiply(quat1, quat2);
    NormalizeQuaternion(quat);
    FTransfMat := QuaternionToRotateMatrix(quat);
    NormalizeMatrix(FTransfMat);
  end;
  if Sender.ClassType = FScale3DS.ClassType then
  begin
    FScaleMat := CreateScaleMatrix(FScale3DS.AsAffineVector);
  end;
end;

function TVKFile3DSFreeForm.AxisAlignedDimensionsUnscaled: TVector;
var
  dMin, dMax: TAffineVector;
  mat: TMatrix;
begin
  MeshObjects.GetExtents(dMin, dMax);
  mat := ParentMatrix;
  mat := MatrixMultiply(FRefMat, mat);
  if not IsInfinite(dMin.X) then
    dMin := VectorTransform(dMin, mat);
  if not IsInfinite(dMax.X) then
    dMax := VectorTransform(dMax, mat);

  Result.X := (dMax.X - dMin.X) / 2;
  Result.Y := (dMax.Y - dMin.Y) / 2;
  Result.Z := (dMax.Z - dMin.Z) / 2;
  Result.W := 0;
end;

// BarycenterAbsolutePosition
//

function TVKFile3DSFreeForm.BarycenterAbsolutePosition: TVector;
var
  dMin, dMax: TAffineVector;
  mat: TMatrix;
begin
  MeshObjects.GetExtents(dMin, dMax);
  mat := ParentMatrix;
  mat := MatrixMultiply(FRefMat, mat);
  if not IsInfinite(dMin.X) then
    dMin := VectorTransform(dMin, mat);
  if not IsInfinite(dMax.X) then
    dMax := VectorTransform(dMax, mat);

  Result.X := (dMax.X + dMin.X) / 2;
  Result.Y := (dMax.Y + dMin.Y) / 2;
  Result.Z := (dMax.Z + dMin.Z) / 2;
  Result.W := 1;

  Result := LocalToAbsolute(Result);
end;

initialization
  RegisterClasses([TVKFile3DSLight, TVKFile3DSCamera, TVKFile3DSActor, TVKFile3DSFreeForm]);

end.

