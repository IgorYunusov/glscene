{: Clothify demo.<p>

   Caution: this demo mixes several experimental thingies, and will probably be
            cleaned-up/split to be easier to follow, ad interim, you enter
            the jungle below at your own risks :)
}
unit fClothify;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  GLObjects, GLScene, GLVectorFileObjects, GLWin32Viewer, GLMisc,
  GLFileMS3D, VerletClasses, VectorTypes, VectorLists, Geometry, GLTexture,
  OpenGL12, StdCtrls, GLFileSMD, GLCadencer, ExtCtrls, GLShadowPlane,
  GLVerletClothify, ComCtrls, jpeg, GLFile3DS, ODEImport, ODEGL,
  GeometryBB, SpatialPartitioning;

type
  TfrmClothify = class(TForm)
    GLScene1: TGLScene;
    GLSceneViewer1: TGLSceneViewer;
    GLCamera1: TGLCamera;
    GLActor1: TGLActor;
    GLDummyCube1: TGLDummyCube;
    GLLightSource1: TGLLightSource;
    GLMaterialLibrary1: TGLMaterialLibrary;
    GLCadencer1: TGLCadencer;
    Label1: TLabel;
    Timer1: TTimer;
    GLSphere1: TGLSphere;
    GLCylinder1: TGLCylinder;
    GLShadowPlane1: TGLShadowPlane;
    GLCube1: TGLCube;
    GLCube_Stair1: TGLCube;
    GLDummyCube_Stairs: TGLDummyCube;
    GLCube_Stair2: TGLCube;
    GLCube_Stair3: TGLCube;
    GLCube_Stair4: TGLCube;
    GLDummyCube2: TGLDummyCube;
    GL_Capsule: TGLCylinder;
    GLSphere2: TGLSphere;
    GLSphere3: TGLSphere;
    GLDummyCube_Light: TGLDummyCube;
    GLActor2: TGLActor;
    GLDirectOpenGL1: TGLDirectOpenGL;
    GroupBox_LoadForm: TGroupBox;
    Label2: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    ComboBox_MeshName: TComboBox;
    ComboBox_ConstraintType: TComboBox;
    ComboBox_Collider: TComboBox;
    Button_LoadMesh: TButton;
    CheckBox_UseOctree: TCheckBox;
    CheckBox_SolidEdges: TCheckBox;
    CheckBox_Weld: TCheckBox;
    Button_OpenLoadForm: TButton;
    Button_CancelLoad: TButton;
    Label3: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    TrackBar_Slack: TTrackBar;
    TrackBar_Iterations: TTrackBar;
    TrackBar_Friction: TTrackBar;
    CheckBox_ShowOctree: TCheckBox;
    procedure GLSceneViewer1MouseMove(Sender: TObject; Shift: TShiftState;
      X, Y: Integer);
    procedure GLCadencer1Progress(Sender: TObject; const deltaTime,
      newTime: Double);
    procedure Timer1Timer(Sender: TObject);
    procedure Button_LoadMeshClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure TrackBar_SlackChange(Sender: TObject);
    function GetSlack : single;
    procedure TrackBar_IterationsChange(Sender: TObject);
    procedure FormMouseWheel(Sender: TObject; Shift: TShiftState;
      WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
    procedure TrackBar_FrictionChange(Sender: TObject);
    procedure GLDirectOpenGL1Render(var rci: TRenderContextInfo);
    procedure Button_OpenLoadFormClick(Sender: TObject);
    procedure Button_CancelLoadClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    mx, my : integer;

    VerletWorld : TVerletWorld;
    EdgeDetector : TEdgeDetector;

    world : PdxWorld;
    space : PdxSpace;
    ODESphere: PdxGeom;
    body : PdxBody;
    contactgroup : TdJointGroupID;

    VCSphere : TVCSphere;

  end;

  procedure RecalcMeshNormals(BaseMesh : TGLBaseMesh);
  procedure PrepareMeshForNormalsRecalc(BaseMesh : TGLBaseMesh);

var
  frmClothify: TfrmClothify;

implementation

{$R *.dfm}

procedure TfrmClothify.Button_LoadMeshClick(Sender: TObject);
var
  Floor : TVCFloor;
  Capsule : TVCCapsule;
  Sides : TAffineVector;
  Cube : TVCCube;
  ColliderGravy : single;
  s : string;
  f : single;
  p : Integer;
  i : integer;

  procedure CreateCubeFromGLCube(GLCube : TGLCube);
  begin
    Cube := TVCCube.Create(VerletWorld);
    Cube.Location := AffineVectorMake(GLCube.AbsolutePosition);
    Cube.FrictionRatio := 0.1;
    Sides[0] := GLCube.CubeWidth * 1.1;
    Sides[1] := GLCube.CubeHeight * 1.1;
    Sides[2] := GLCube.CubeDepth * 1.1;
    Cube.Sides := Sides;//}
  end;

  procedure CreateODEWorld;
  var
    m : TdMass;

  begin
    GLSphere1.Visible := true;
    world := dWorldCreate;
    dWorldSetGravity (world,0,-9.81,0);

    contactgroup := dJointGroupCreate (0);
    space := dHashSpaceCreate(nil);
    body := dBodyCreate(world);
    dMassSetSphere (m,0.1,GLSphere1.Radius);
    dCreatePlane (space,0,1,0,GLShadowPlane1.Position.Y);


    ODESphere := dCreateSphere (space, GLSphere1.Radius);

    dGeomSetBody (ODESphere, body);
    dBodySetMass (body,m);

    ODESphere.data := GLSphere1;

    PositionSceneObjectForGeom(ODESphere);
  end;
  
begin
  randomize;

  if world<>nil then
  begin
    dWorldDestroy(world);
    world := nil;
    GLSphere1.Position.AsAffineVector := NullVector;
  end;

  FreeAndNil(VerletWorld);
  FreeAndNil(EdgeDetector);

  s := ComboBox_MeshName.Text;

  DecimalSeparator := '.';

  p:=Pos(',', s);
  if p>0 then begin
      f := StrToFloatDef(Trim(Copy(s, p+1, MaxInt)), 1);
      GLActor1.Scale.AsVector := VectorMake(f,f,f,0)
  end else GLActor1.Scale.AsVector := XYZHmgVector;

  GLActor1.AutoCentering := [macUseBarycenter];
  GLActor1.LoadFromFile(Trim(Copy(s, 1, p-1)));
  PrepareMeshForNormalsRecalc(GLActor1);
  GLActor1.Reference := aarNone;

  GLActor1.Roll(random*360);
  GLActor1.Turn(random*360);//}

  GLSphere1.Visible := false;
  GLCylinder1.Visible := false;
  GLCube1.Visible := false;
  GLDummyCube_Stairs.Visible := False;
  GL_Capsule.Visible := False;

  case ComboBox_Collider.ItemIndex of
    0,-1 : GLSphere1.Visible := true;
    1 : GLCylinder1.Visible := true;
    2 : GLCube1.Visible := true;
    3 : GLDummyCube_Stairs.Visible := true;
    4 : GL_Capsule.Visible := true;
    5 : CreateODEWorld;
  end;

  EdgeDetector := TEdgeDetector.Create(GLActor1);

  if not CheckBox_Weld.Checked then
    EdgeDetector.WeldDistance := -1;

  EdgeDetector.ProcessMesh;

  VerletWorld := TVerletWorld.Create;

  if CheckBox_UseOctree.Checked then
    VerletWorld.CreateOctree(
      AffineVectorMake( -20, -5.5, -20),
      AffineVectorMake(  20,  20,  20), 25, 5);//}

  if ComboBox_ConstraintType.ItemIndex=0 then
    EdgeDetector.AddEdgesAsSticks(VerletWorld, GetSlack)
  else
    EdgeDetector.AddEdgesAsSprings(VerletWorld, 1000,100, GetSlack);//}

  if CheckBox_SolidEdges.Checked then
  begin
    ColliderGravy := 1;
    EdgeDetector.AddEdgesAsSolidEdges(VerletWorld);
  end else
    ColliderGravy := 1.1;

  // VerletWorld.Nodes[0].NailedDown := true;

  TVFGravity.Create(VerletWorld);

  Floor := TVCFloor.Create(VerletWorld);
  Floor.Location := VectorAdd(GLShadowPlane1.Position.AsAffineVector, AffineVectorMake(0,0.1,0));
  Floor.Normal := GLShadowPlane1.Direction.AsAffineVector;

  Floor.FrictionRatio := 0.6;//}

  if GLSphere1.Visible then begin
     VCSphere := TVCSphere.Create(VerletWorld);
     VCSphere.Radius := GLSphere1.Radius * ColliderGravy;
     VCSphere.Location := AffineVectorMake(GLSphere1.AbsolutePosition);
  end;

  if GLCube1.Visible then begin
    CreateCubeFromGLCube(GLCube1);
  end;

  if GLCylinder1.Visible then begin
     Capsule := TVCCapsule.Create(VerletWorld);
     Capsule.Radius := GLCylinder1.TopRadius * ColliderGravy;
     Capsule.Location := AffineVectorMake(GLCylinder1.AbsolutePosition);
     Capsule.Axis := AffineVectorMake(GLCylinder1.AbsoluteUp);//}
     Capsule.Length := 20;
     Capsule.FrictionRatio := 0.6;
  end;

  if GL_Capsule.Visible then begin
     Capsule := TVCCapsule.Create(VerletWorld);
     Capsule.Radius := GL_Capsule.TopRadius * ColliderGravy;
     Capsule.Location := AffineVectorMake(GL_Capsule.AbsolutePosition);
     Capsule.Axis := AffineVectorMake(GL_Capsule.AbsoluteUp);//}
     Capsule.Length := GL_Capsule.Height * ColliderGravy;
     Capsule.FrictionRatio := 0.6;
  end;

  if GLDummyCube_Stairs.Visible then begin
    CreateCubeFromGLCube(GLCube_Stair1);
    CreateCubeFromGLCube(GLCube_Stair2);
    CreateCubeFromGLCube(GLCube_Stair3);
    CreateCubeFromGLCube(GLCube_Stair4);
  end;

  VerletWorld.SimTime := GLCadencer1.GetCurrentTime;
  VerletWorld.MaxDeltaTime := 0.01;
  VerletWorld.Iterations := TrackBar_Iterations.Position;

  TrackBar_FrictionChange(nil);

  GroupBox_LoadForm.Hide;
end;

procedure TfrmClothify.GLSceneViewer1MouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
  if ssLeft in Shift then
    GLCamera1.MoveAroundTarget(my-y, mx-x);

  mx := x;
  my := y
end;

procedure nearCallback (data : pointer; o1, o2 : PdxGeom); cdecl;
const
  cCOL_MAX = 3;
var
  i : integer;
  b1, b2 : PdxBody;
  numc : integer;
  contact : array[0..cCOL_MAX-1] of TdContact;
  c : TdJointID;
begin
  // exit without doing anything if the two bodies are connected by a joint
  b1 := dGeomGetBody(o1);
  b2 := dGeomGetBody(o2);
  if (assigned(b1) and assigned(b2) and (dAreConnected (b1,b2)<>0)) then
    exit;//}

  for i :=0 to cCOL_MAX-1 do
  begin
    contact[i].surface.mode := dContactBounce;

    // This determines friction, play around with it!
    contact[i].surface.mu := 10e9; //dInfinity; SHOULD BE INFINITY!
    contact[i].surface.mu2 := 0;
    contact[i].surface.bounce := 0.5;//0.5;
    contact[i].surface.bounce_vel := 0.1;
  end;

  numc := dCollide (o1,o2,cCOL_MAX,contact[0].geom,sizeof(TdContact));
  if (numc>0) then
  begin
    // dMatrix3 RI;
    // dRSetIdentity (RI);
    // const dReal ss[3] = {0.02,0.02,0.02};
    for i := 0 to numc-1 do
    begin
      c := dJointCreateContact (frmClothify.world,frmClothify.contactgroup,contact[i]);
      dJointAttach (c,b1,b2);
      // dsDrawBox (contact[i].geom.pos,RI,ss);
    end;
  end;
end;

procedure TfrmClothify.GLCadencer1Progress(Sender: TObject;
  const deltaTime, newTime: Double);
begin
   {if CheckBox_Pause.Checked then
      VerletWorld.SimTime := newTime
   else//}
   begin
      if world <> nil then begin
         PositionSceneObjectForGeom(ODESphere);
         VCSphere.Location := GLSphere1.Position.AsAffineVector;

         dBodyAddForce(dGeomGetBody(ODESphere),
                       VCSphere.KickbackForce[0],
                       VCSphere.KickbackForce[1],
                       VCSphere.KickbackForce[2]);

         dSpaceCollide (space,nil,nearCallback);
         dWorldStep(World, VerletWorld.MaxDeltaTime);
         dJointGroupEmpty (contactgroup);
      end;

      VerletWorld.Progress(VerletWorld.MaxDeltaTime, newTime);


      RecalcMeshNormals(GLActor1);
   end;
end;

procedure PrepareMeshForNormalsRecalc(BaseMesh: TGLBaseMesh);
var
   i, j, k : Integer;
   mo : TMeshObject;
   fg : TFGVertexNormalTexIndexList;
   n : TAffineVector;
begin
  // update normals
  // (not very efficient, could use some work...)
  for i:=0 to BaseMesh.MeshObjects.Count-1 do begin
     mo:=BaseMesh.MeshObjects[i];

     for j:=0 to mo.FaceGroups.Count-1 do begin
        if mo.FaceGroups[j] is TFGVertexNormalTexIndexList then begin
           fg:=TFGVertexNormalTexIndexList(mo.FaceGroups[j]);
           for k := 0 to fg.VertexIndices.Count-1 do begin
              fg.NormalIndices.List[k] := fg.VertexIndices.List[k];
           end;
        end;
     end;
  end;
end;

procedure RecalcMeshNormals(BaseMesh: TGLBaseMesh);
var
   i, j, k : Integer;
   mo : TMeshObject;
   fg : TFGVertexIndexList;
   n : TAffineVector;
begin
  // update normals
  // (not very efficient, could use some work...)
  for i:=0 to BaseMesh.MeshObjects.Count-1 do begin
     mo:=BaseMesh.MeshObjects[i];

     FillChar(mo.Normals.List[0], SizeOf(TAffineVector)*mo.Normals.Count, 0);

     for j:=0 to mo.FaceGroups.Count-1 do begin
        if mo.FaceGroups[j] is TFGVertexIndexList then begin
           fg:=TFGVertexIndexList(mo.FaceGroups[j]);
           k:=0; while k<=fg.VertexIndices.Count-3 do begin
              n:=CalcPlaneNormal(mo.Vertices.List[fg.VertexIndices.List[k]],
                                 mo.Vertices.List[fg.VertexIndices.List[k+1]],
                                 mo.Vertices.List[fg.VertexIndices.List[k+2]]);
              mo.Normals.TranslateItem(fg.VertexIndices.List[k], n);
              mo.Normals.TranslateItem(fg.VertexIndices.List[k+1], n);
              mo.Normals.TranslateItem(fg.VertexIndices.List[k+2], n);//}

              Inc(k, 3);
           end;
        end;
     end;
     mo.Normals.Normalize;
  end;

  BaseMesh.StructureChanged;
end;

procedure TfrmClothify.Timer1Timer(Sender: TObject);
begin
  Label1.Caption := Format('%2.1f FPS',[GLSceneViewer1.FramesPerSecond]);
  GLSceneViewer1.ResetPerformanceMonitor;
end;

procedure TfrmClothify.FormCreate(Sender: TObject);
begin
  SetCurrentDir('..\..\Media\');

  Button_LoadMesh.Click;
  TrackBar_IterationsChange(nil);
end;

procedure TfrmClothify.TrackBar_SlackChange(Sender: TObject);
var
  i : integer;
begin
  for i := 0 to VerletWorld.Constraints.Count-1 do
  begin
    if VerletWorld.Constraints[i] is TVCStick then
      TVCStick(VerletWorld.Constraints[i]).Slack := GetSlack;
  end;
end;

function TfrmClothify.GetSlack: single;
begin
  result := TrackBar_Slack.Position/500;
end;

procedure TfrmClothify.TrackBar_IterationsChange(Sender: TObject);
begin
  VerletWorld.Iterations := TrackBar_Iterations.Position;

  Label6.Caption := Format('Iterations %d',[TrackBar_Iterations.Position]);
end;

procedure TfrmClothify.FormMouseWheel(Sender: TObject; Shift: TShiftState;
  WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
begin
	GLCamera1.AdjustDistanceToTarget(Power(1.1, WheelDelta/120));
end;

procedure TfrmClothify.TrackBar_FrictionChange(Sender: TObject);
var
  i : integer;
begin
  for i := 0 to VerletWorld.Constraints.Count-1 do
    if VerletWorld.Constraints[i] is TVerletGlobalFrictionConstraint then
      TVerletGlobalFrictionConstraint(VerletWorld.Constraints[i]).FrictionRatio := TrackBar_Friction.Position / 100;
end;

procedure TfrmClothify.GLDirectOpenGL1Render(var rci: TRenderContextInfo);
  procedure RenderAABB(AABB : TAABB; w, r,g,b : single);
  begin
    glColor3f(r,g,b);
    glLineWidth(w);

    glBegin(GL_LINE_STRIP);
      glVertex3f(AABB.min[0],AABB.min[1], AABB.min[2]);
      glVertex3f(AABB.min[0],AABB.max[1], AABB.min[2]);
      glVertex3f(AABB.max[0],AABB.max[1], AABB.min[2]);
      glVertex3f(AABB.max[0],AABB.min[1], AABB.min[2]);
      glVertex3f(AABB.min[0],AABB.min[1], AABB.min[2]);

      glVertex3f(AABB.min[0],AABB.min[1], AABB.max[2]);
      glVertex3f(AABB.min[0],AABB.max[1], AABB.max[2]);
      glVertex3f(AABB.max[0],AABB.max[1], AABB.max[2]);
      glVertex3f(AABB.max[0],AABB.min[1], AABB.max[2]);
      glVertex3f(AABB.min[0],AABB.min[1], AABB.max[2]);
    glEnd;

    glBegin(GL_LINES);
      glVertex3f(AABB.min[0],AABB.max[1], AABB.min[2]);
      glVertex3f(AABB.min[0],AABB.max[1], AABB.max[2]);

      glVertex3f(AABB.max[0],AABB.max[1], AABB.min[2]);
      glVertex3f(AABB.max[0],AABB.max[1], AABB.max[2]);

      glVertex3f(AABB.max[0],AABB.min[1], AABB.min[2]);
      glVertex3f(AABB.max[0],AABB.min[1], AABB.max[2]);
    glEnd;
  end;

  procedure RenderOctreeNode(Node : TSectorNode);
  var
    i : integer;
    AABB : TAABB;
  begin
    if Node.NoChildren then
    begin
      AABB := Node.AABB;

      if Node.RecursiveLeafCount > 0 then
        RenderAABB(AABB, 1, 0, 0, 0)
      else
        RenderAABB(AABB, 1, 0.8, 0.8, 0.8)//}

    end else
    begin
      for i := 0 to Node.ChildCount-1 do
        RenderOctreeNode(Node.Children[i]);
    end;
  end;
begin
  if CheckBox_ShowOctree.Checked and (VerletWorld.SpacePartition is TOctreeSpacePartition) then
  begin
    glPushAttrib(GL_ENABLE_BIT or GL_CURRENT_BIT or GL_LINE_BIT or GL_COLOR_BUFFER_BIT);
    glDisable(GL_LIGHTING);

    RenderOctreeNode(TOctreeSpacePartition(VerletWorld.SpacePartition).RootNode);
    glPopAttrib;
  end;
end;

procedure TfrmClothify.Button_OpenLoadFormClick(Sender: TObject);
begin
  GroupBox_LoadForm.Visible := true;
  GroupBox_LoadForm.SetFocus;
end;

procedure TfrmClothify.Button_CancelLoadClick(Sender: TObject);
begin
  GroupBox_LoadForm.Hide;
end;
end.
