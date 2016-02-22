//
// GLScene on Vulkan, http://glscene.sourceforge.net 
//

unit ODEGL;

interface

{
  Here are collected random functions and procedures that were found useful when
  integrating ODE into GLScene. If you don't use GLS.Scene, this unit won't be
  very useful to you. The unit is not intended as a sorted toolbox, but more
  as a place to put stuff until we figure out how to organize the integration.
  Mattias Fagerlund, 2002-09-26
}

uses
  System.SysUtils,

  ODEImport,
  Winapi.OpenGL, Winapi.OpenGLext, 
  GLS.Context,
  GLS.VectorGeometry,
  GLS.Scene,
  GLS.VectorTypes,
  GLS.VectorLists,
  GLS.Objects,
  GLS.VerletClothify,
  GLS.VectorFileObjects;

procedure DrawBox(Sides: TdVector3);
procedure setTransform(pos: TdVector3; R: TdMatrix3);
procedure dsDrawBox(pos: PdVector3; R: PdMatrix3; Sides: TdVector3); overload;
procedure dsDrawBox(pos: TdVector3; R: TdMatrix3; Sides: TdVector3); overload;

procedure ODERToGLSceneMatrix(var m: TMatrix; R: TdMatrix3; pos: TdVector3);
overload;
procedure ODERToGLSceneMatrix(var m: TMatrix; R: PdMatrix3; pos: PdVector3);
overload;
procedure ODERToGLSceneMatrix(var m: TMatrix; R: TdMatrix3_As3x4; pos:  TdVector3); overload;
function GLSceneMatrixToODER(m: TMatrix): TdMatrix3;

// Converting between ODE and GLScene formats
function ConvertdVector3ToVector3f(R: TdVector3): TVector3f; overload;
function ConvertdVector3ToVector3f(R: PdVector3): TVector3f; overload;
function ConvertdVector3ToVector4f(R: TdVector3): TVector4f; overload;
function ConvertdVector3ToVector4f(R: PdVector3): TVector4f; overload;

function ConvertdVector3ToAffineVector(R: PdVector3): TAffineVector; overload;
function ConvertdVector3ToAffineVector(R: TdVector3): TAffineVector; overload;

function GetBodyPositionAsAffineVector(Body: PdxBody): TAffineVector;

// Converting between GLScene and ODE formats
function ConvertVector3fTodVector3(R: TVector3f): TdVector3;
function ConvertVector3fToPdVector3(R: TVector3f): PdVector3;
function ConvertVector4fTodVector3(R: TVector4f): TdVector3;
function ConvertVector4fToPdVector3(R: TVector4f): PdVector3;

function dVector3Length(R: TdVector3): single; overload;
function dVector3Length(R: PdVector3): single; overload;

function dBodyToBodyDistance(Body1, Body2: PdxBody): TdReal;

procedure CopyPosFromGeomToGL(Geom: PdxGeom; GLBaseSceneObject:  TVKBaseSceneObject);
procedure PositionSceneObject(GLBaseSceneObject: TVKBaseSceneObject; Geom: PdxGeom);
procedure PositionSceneObjectForGeom(Geom: PdxGeom);

procedure CopyCubeSizeFromBox(Cube: TVKCube; Geom: PdxGeom);
procedure CopyBodyFromCube(Body: PdxBody; var Geom: PdxGeom; Cube: TVKCube;  Space: PdxSpace);

function CreateGeomFromCube(Cube: TVKCube; Space: PdxSpace): PdxGeom;
function CreateBodyFromCube(var Geom: PdxGeom; Cube: TVKCube; World: PdxWorld;  Space: PdxSpace): PdxBody;

{ Note that this method requires you to manually deallocate vertices and
  indices when you're done with the trimesh }
function CreateTriMeshFromBaseMesh(
  GLBaseMesh: TVKBaseMesh;
  Space: PdxSpace;
  var Vertices: PdVector3Array;
  var Indices: PdIntegerArray): PdxGeom;

function GLMatrixFromGeom(Geom: PdxGeom): TMatrix;
function GLDirectionFromGeom(Geom: PdxGeom): TVector;

function CreateODEPlaneFromGLPlane(Plane: TVKPlane; Space: PdxSpace): PdxGeom;

procedure RenderGeomList(GeomList: TGeomList);

function RandomColorVector: TVector;

// { $ EXTERNALSYM GL_ZERO} ?

implementation

procedure ODERToGLSceneMatrix(var m: TMatrix; R: TdMatrix3_As3x4; pos: TdVector3); overload;
begin
  m.X.X := r[0][0];
  m.X.Y := r[0][1];
  m.X.Z := r[0][2];
  m.X.W := 0;
  m.Y.X := r[1][0];
  m.Y.Y := r[1][1];
  m.Y.Z := r[1][2];
  m.Y.W := 0;
  m.Z.X := r[2][0];
  m.Z.Y := r[2][1];
  m.Z.Z := r[2][2];
  m.Z.W := 0;
  m.W := NullHmgPoint;

  TransposeMatrix(m);
  m.W.X := pos[0];
  m.W.Y := pos[1];
  m.W.Z := pos[2];
  m.W.W := 1; //}
end;

procedure ODERToGLSceneMatrix(var m: TMatrix; R: PdMatrix3; pos: PdVector3);
begin
  ODERToGLSceneMatrix(m, TdMatrix3_As3x4(R^), pos^);
end;

procedure ODERToGLSceneMatrix(var m: TMatrix; R: TdMatrix3; pos: TdVector3);
begin
  ODERToGLSceneMatrix(m, TdMatrix3_As3x4(R), pos);
end;

procedure DrawBox(Sides: TdVector3);
var
  lx, ly, lz: single;
begin
  lx := Sides[0] * 0.5;
  ly := Sides[1] * 0.5;
  lz := Sides[2] * 0.5;

  // sides
  glBegin(GL_TRIANGLE_STRIP);
  glNormal3f(-1, 0, 0);
  glVertex3f(-lx, -ly, -lz);
  glVertex3f(-lx, -ly, lz);
  glVertex3f(-lx, ly, -lz);
  glVertex3f(-lx, ly, lz);
  glNormal3f(0, 1, 0);
  glVertex3f(lx, ly, -lz);
  glVertex3f(lx, ly, lz);
  glNormal3f(1, 0, 0);
  glVertex3f(lx, -ly, -lz);
  glVertex3f(lx, -ly, lz);
  glNormal3f(0, -1, 0);
  glVertex3f(-lx, -ly, -lz);
  glVertex3f(-lx, -ly, lz);
  glEnd();

  // top face
  glBegin(GL_TRIANGLE_FAN);
  glNormal3f(0, 0, 1);
  glVertex3f(-lx, -ly, lz);
  glVertex3f(lx, -ly, lz);
  glVertex3f(lx, ly, lz);
  glVertex3f(-lx, ly, lz);
  glEnd();

  // bottom face
  glBegin(GL_TRIANGLE_FAN);
  glNormal3f(0, 0, -1);
  glVertex3f(-lx, -ly, -lz);
  glVertex3f(-lx, ly, -lz);
  glVertex3f(lx, ly, -lz);
  glVertex3f(lx, -ly, -lz);
  glEnd();
end;

function GLSceneMatrixToODER(m: TMatrix): TdMatrix3;
begin
  TransposeMatrix(m);
  Result[0] := m.X.X;
  Result[1] := m.X.Y;
  Result[2] := m.X.Z;
  Result[4] := m.Y.X;
  Result[5] := m.Y.Y;
  Result[6] := m.Y.Z;
  Result[8] := m.Z.X;
  Result[9] := m.Z.Y;
  Result[10] := m.Z.Z;
end;

procedure dsDrawBox(pos: PdVector3; R: PdMatrix3; Sides: TdVector3);
begin
  dsDrawBox(pos^, r^, Sides);
end;

procedure dsDrawBox(pos: TdVector3; R: TdMatrix3; Sides: TdVector3);
begin
  setTransform(pos, R);
  drawBox(sides);
  glPopMatrix();
end;

procedure setTransform(pos: TdVector3; R: TdMatrix3);
var
  matrix: array[0..15] of GLfloat;
begin
  matrix[0] := R[0];
  matrix[1] := R[4];
  matrix[2] := R[8];
  matrix[3] := 0;
  matrix[4] := R[1];
  matrix[5] := R[5];
  matrix[6] := R[9];
  matrix[7] := 0;
  matrix[8] := R[2];
  matrix[9] := R[6];
  matrix[10] := R[10];
  matrix[11] := 0;
  matrix[12] := pos[0];
  matrix[13] := pos[1];
  matrix[14] := pos[2];
  matrix[15] := 1;
  glPushMatrix();
  GL.MultMatrixf(@matrix);
end;

(*$WARNINGS OFF*)

function ConvertdVector3ToVector3f(R: TdVector3): TVector3f;
begin
  result.X := R[0];
  result.Y := R[1];
  result.Z := R[2];
end;

function ConvertdVector3ToVector3f(R: PdVector3): TVector3f;
begin
  result.X := R[0];
  result.Y := R[1];
  result.Z := R[2];
end;

function ConvertdVector3ToVector4f(R: TdVector3): TVector4f; overload;
begin
  result.X := R[0];
  result.Y := R[1];
  result.Z := R[2];
  result.W := 0;
end;

function ConvertdVector3ToVector4f(R: PdVector3): TVector4f; overload;
begin
  result.X := R[0];
  result.Y := R[1];
  result.Z := R[2];
  result.W := 0;
end;

function ConvertdVector3ToAffineVector(R: PdVector3): TAffineVector; overload;
begin
  result.X := R[0];
  result.Y := R[1];
  result.Z := R[2];
end;

function ConvertdVector3ToAffineVector(R: TdVector3): TAffineVector; overload;
begin
  result.X := R[0];
  result.Y := R[1];
  result.Z := R[2];
end;

function ConvertVector3fTodVector3(R: TVector3f): TdVector3;
begin
  result[0] := R.X;
  result[1] := R.Y;
  result[2] := R.Z;
end;

function ConvertVector3fToPdVector3(R: TVector3f): PdVector3;
begin
  result[0] := R.X;
  result[1] := R.Y;
  result[2] := R.Z;
end;

function ConvertVector4fTodVector3(R: TVector4f): TdVector3;
begin
  result[0] := R.X;
  result[1] := R.Y;
  result[2] := R.Z;
  result[3] := 0;
end;

function ConvertVector4fToPdVector3(R: TVector4f): PdVector3;
begin
  result[0] := R.X;
  result[1] := R.Y;
  result[2] := R.Z;
  result[3] := 0;
end;

(*$WARNINGS ON*)

function GetBodyPositionAsAffineVector(Body: PdxBody): TAffineVector;
begin
  result := ConvertdVector3ToVector3f(dBodyGetPosition(Body));
end;

procedure PositionSceneObjectForGeom(Geom: PdxGeom);
begin
  if Assigned(Geom.Data) then
    PositionSceneObject(TVKBaseSceneObject(Geom.Data), Geom);
end;

function GLMatrixFromGeom(Geom: PdxGeom): TMatrix;
var
  pos, Pos2: PdVector3;
  R, R2: PdMatrix3;

  actual_pos: TdVector3;
  actual_R: TdMatrix3;

  TransformedGeom: PdxGeom;
  GeomClass: integer;
begin
  // Retrieve the position and rotation of the geom
  pos := dGeomGetPosition(geom);
  R := dGeomGetRotation(geom);

  // if the geom is a transform geom, it should be treated differently
  GeomClass := dGeomGetClass(Geom);

  if GeomClass = dGeomTransformClass then
  begin
    TransformedGeom := dGeomTransformGetGeom(Geom);

    // No transformed geom!?
    if TransformedGeom = nil then
      exit;

    // Retrieve the position and rotation of the transformed geom
    pos2 := dGeomGetPosition(TransformedGeom);
    R2 := dGeomGetRotation(TransformedGeom);

    dMULTIPLY0_331(actual_pos, R^, pos2^);
    actual_pos := Vector3ADD(actual_pos, pos^);
    dMULTIPLY0_333(actual_R, R^, R2^);

    ODERToGLSceneMatrix(result, actual_R, actual_pos);
  end
  else
  begin
    ODERToGLSceneMatrix(result, R, pos);
  end;
end;

function GLDirectionFromGeom(Geom: PdxGeom): TVector;
var
  m: TMatrix;
begin
  m := GLMatrixFromGeom(Geom);

  result := VectorNormalize(m.Z);
end;

procedure PositionSceneObject(GLBaseSceneObject: TVKBaseSceneObject; Geom: PdxGeom);
var
  Scale: TAffineVector;
begin
  Scale := GLBaseSceneObject.Scale.AsAffineVector;
  GLBaseSceneObject.Matrix := GLMatrixFromGeom(Geom);
  GLBaseSceneObject.Scale.AsAffineVector := Scale;
end;

procedure CopyCubeSizeFromBox(Cube: TVKCube; Geom: PdxGeom);
var
  Sides: TdVector3;
begin
  dGeomBoxGetLengths(Geom, Sides);

  Cube.CubeWidth := Sides[0]; // 0
  Cube.CubeHeight := Sides[1]; // 1
  Cube.CubeDepth := Sides[2]; // 2
end;

procedure CopyPosFromGeomToGL(Geom: PdxGeom; GLBaseSceneObject: TVKBaseSceneObject);
var
  v: TVector;
  m: TMatrix;

  R: PdMatrix3;
  pos: PdVector3;
begin
  v := GLBaseSceneObject.AbsolutePosition;

  dGeomSetPosition(Geom, v.X, v.Y, v.Z);

  R := dGeomGetRotation(Geom);
  pos := dgeomGetPosition(Geom);

  m := GLBaseSceneObject.AbsoluteMatrix;
  R[0] := m.X.X;
  R[4] := m.X.Y;
  R[8] := m.X.Z;
  R[1] := m.Y.X;
  R[5] := m.Y.Y;
  R[9] := m.Y.Z;
  R[2] := m.Z.X;
  R[6] := m.Z.Y;
  R[10] := m.Z.Z;
  pos[0] := m.W.X;
  pos[1] := m.W.Y;
  pos[2] := m.W.Z; //}

  dGeomSetRotation(Geom, R^);
end;

function CreateGeomFromCube(Cube: TVKCube; Space: PdxSpace): PdxGeom;
var
  Geom: PdxGeom;
begin
  Geom := dCreateBox(Space, Cube.CubeWidth, Cube.CubeHeight, Cube.CubeDepth);
  CopyPosFromGeomToGL(Geom, Cube);

  result := Geom;
end;

function CreateBodyFromCube(var Geom: PdxGeom; Cube: TVKCube; World: PdxWorld; Space: PdxSpace): PdxBody;
var
  Body: PdxBody;
begin
  Body := dBodyCreate(World);

  try
    dBodySetLinearVel(Body, 0, 0, 0);

    CopyBodyFromCube(Body, Geom, Cube, Space);
  finally
    result := Body;
  end;
end;

function CreateTriMeshFromBaseMesh(
  GLBaseMesh: TVKBaseMesh;
  Space: PdxSpace;
  var Vertices: PdVector3Array;
  var Indices: PdIntegerArray): PdxGeom;
var
  i, j, p: integer;
  FaceExtractor: TFaceExtractor;
  VertexCount: integer;
  Vertex: TAffineVector;
  OffsetList: TIntegerList;
  Face: TFace;
  iMO: integer;
  TriMeshData: PdxTriMeshData;
begin
  OffsetList := nil;
  FaceExtractor := TFaceExtractor.Create(GLBaseMesh);

  try
    OffsetList := TIntegerList.Create;

    FaceExtractor.ProcessMesh;

    VertexCount := 0;
    for i := 0 to GLBaseMesh.MeshObjects.Count - 1 do
      VertexCount := VertexCount + GLBaseMesh.MeshObjects[i].Vertices.Count;

    Vertices := AllocMem(sizeOf(TdVector3) * VertexCount);
    Indices := AllocMem(sizeOf(integer) * FaceExtractor.FaceList.Count * 3);

    // Copy all vertices
    p := 0;
    for i := 0 to GLBaseMesh.MeshObjects.Count - 1 do
    begin
      OffsetList.Add(p);
      for j := 0 to GLBaseMesh.MeshObjects[i].Vertices.Count - 1 do
      begin
        Vertex :=
          GLBaseMesh.LocalToAbsolute(GLBaseMesh.MeshObjects[i].Vertices[j]);
        Vertices^[p, 0] := Vertex.X;
        Vertices^[p, 1] := Vertex.Y;
        Vertices^[p, 2] := Vertex.Z;
        Vertices^[p, 3] := 0;
        inc(p);
      end;
    end;

    // Copy all triangles
    p := 0;
    for i := 0 to FaceExtractor.FaceList.Count - 1 do
    begin
      Face := FaceExtractor.FaceList[i];
      iMO := GLBaseMesh.MeshObjects.IndexOf(Face.MeshObject);

      Indices^[p] := Face.Vertices[0] + OffsetList[iMO];
      inc(p);
      Indices^[p] := Face.Vertices[1] + OffsetList[iMO];
      inc(p);
      Indices^[p] := Face.Vertices[2] + OffsetList[iMO];
      inc(p);
    end;

    TriMeshData := dGeomTriMeshDataCreate;

    dGeomTriMeshDataBuildSimple(
      TriMeshData,
      Vertices, VertexCount,
      Indices, FaceExtractor.FaceList.Count * 3);

    result := dCreateTriMesh(space, TriMeshData, nil, nil, nil);
  finally
    FaceExtractor.Free;

    if OffsetList <> nil then
      OffsetList.Free;
  end;
end;

procedure CopyBodyFromCube(Body: PdxBody; var Geom: PdxGeom; Cube: TVKCube;
  Space: PdxSpace);
var
  m: TdMass;
begin
  // Stup the body
  dMassSetBox(m, 1, Cube.CubeWidth, Cube.CubeHeight, Cube.CubeDepth);
  if m.mass>0 then dBodySetMass(Body, @m);

  // Setup the geom
  Geom := CreateGeomFromCube(Cube, Space);
  dGeomSetBody(Geom, Body);

  CopyPosFromGeomToGL(Geom, Cube);

  Geom.data := Cube;
end;

function dBodyToBodyDistance(Body1, Body2: PdxBody): TdReal;
begin
  result := dVector3Length(Vector3SUB(Body1.posr.pos, Body2.posr.pos));
end;

function dVector3Length(R: TdVector3): single;
begin
  result := Sqrt(sqr(R[0]) + sqr(R[1]) + sqr(R[2]));
end;

function dVector3Length(R: PdVector3): single;
begin
  result := Sqrt(sqr(R[0]) + sqr(R[1]) + sqr(R[2]));
end;

procedure RenderGeomList(GeomList: TGeomList);
var
  i: integer;
begin
  for i := 0 to GeomList.Count - 1 do
    if Assigned(GeomList[i].data) then
      PositionSceneObject(TVKBaseSceneObject(GeomList[i].data), GeomList[i]);
end;

function CreateODEPlaneFromGLPlane(Plane: TVKPlane; Space: PdxSpace): PdxGeom;
var
  Pos, Direction: TVector;
  d: single;
begin
  Direction := Plane.AbsoluteDirection;
  Pos := Plane.AbsolutePosition;

  d := (Direction.X * Pos.X +
        Direction.Y * Pos.Y +
        Direction.Z * Pos.Z);

  result := dCreatePlane(space, Direction.X, Direction.Y, Direction.Z, d);
end;

function RandomColorVector: TVector;
begin
  result := VectorMake(Random, Random, Random, 1);
end;
end.
