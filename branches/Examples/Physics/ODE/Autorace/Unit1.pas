unit Unit1;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.ExtCtrls,
  Vcl.StdCtrls,
  Vcl.Imaging.jpeg,
   
  GLCadencer,
  GLWin32Viewer,
  GLScene,
  GLObjects,
  GLVectorLists,
  GLVectorFileObjects,
  GLFile3DS,
  ODEImport,
  ODEGL,
  GLGeomObjects,
  GLKeyboard,
  GLVectorTypes,
  GLVectorGeometry,
  GLSkydome,
  GLFileMD3,
  Q3MD3,
  GLTexture,
  GLBitmapFont,
  GLWindowsFont,
  GLHUDObjects,
  GLMaterial,
  GLCoordinates,
  GLCrossPlatform,
  GLBaseClasses;

Const
  FRICTION = 0.8; // ������ � ���������
  ContactNum = 7; // ���� ��������� ������ ������ ������ 20, � �������� ������

//Ode Physic world
type
  TOde = class(TObject)
    world: PdxWorld;
    space: PdxSpace;
    GlobalFriction: Single;
    contactgroup: TdJointGroupID; // ������ �������� - ������������ ��� �������� �������� �������� ���������
    phystime: double;
    maps: PdxGeom; // ��������� ������
    contact: array of TdContact; // ������ ���������
    constructor create;
    destructor destroy; override;
    procedure update;
    procedure Loadmap(Name:string);
  end;

//Car Constante
const
  cZOOM            = 1;
  cZOOM_CUBED      = cZOOM  * cZOOM * cZOOM;
  cLENGTH          = 2.8    * cZOOM;
  cWIDTH           = 0.95   * cZOOM;
  cHEIGHT          = 0.70   * cZOOM;
  cRADIUS          = 0.30   * cZOOM;
  cSTARTZ          = 0.0    * cZOOM;
  cCMASS           = 6.0    * cZOOM;
  cWMASS           = 0.5   * cZOOM;
  cWHEEL_OFFSET    = 0.0001 * cZOOM;
  cSUSPENSION_ERP  = 0.2;
  cSUSPENSION_CFM  = 0.3;
  cWHEEL_WOBBLE    = 0.0;
  cACCEL           = 0.010/5;
  cTURN_SPEED      = 0.5/10;

//Ode Car
type
  TCars = class
    body: array[0..4] of PdxBody;
    joint: array[0..3] of TdJointID;
    Geoms: array[0..4] of PdxGeom; // ���� ������ ��������� ������ ���� ��� ����
    BodySpace: PdxSpace; // ��������� ������������ ��� ������ (� ����� �����������)
    CarAct: TGLActor;
    roueact: TGLActor;
    Steer: Single;
    speed: single;
    Cube: TGLDummyCube;
    dummyCube: TGLDummyCube;
    MotorRunning: boolean;
    constructor create;
    destructor destroy; override;
    procedure update;
  end;

//Form with some var and proc...
type
  TFrm = class(TForm)
    GLScene: TGLScene;
    GLCadencer: TGLCadencer;
    Cam: TGLCamera;
    Scene: TGLDummyCube;
    CamBox: TGLDummyCube;
    Map: TGLDummyCube;
    Light: TGLLightSource;
    FreeForm: TGLFreeForm;
    CarsBox: TGLDummyCube;
    GLSceneViewer: TGLSceneViewer;
    GLSkyDome1: TGLSkyDome;
    GLMaterialLibrary1: TGLMaterialLibrary;
    Timer: TTimer;
    GLHUDText1: TGLHUDText;
    GLWindowsBitmapFont1: TGLWindowsBitmapFont;
    Tkiller: TTimer;
    procedure GLCadencerProgress(Sender: TObject; const deltaTime,newTime: Double);
    procedure TimerTimer(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure TkillerTimer(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
     
  public
    Ode: TOde;
    Car: TCars;
    procedure FreeAll;
    procedure SetResolution(X,Y:integer);

  end;

var
  Frm: TFrm;
  Modelcar: integer=1;

implementation

uses Frm2;

{$R *.dfm}

// this is called by dSpaceCollide when two objects in space are
// potentially colliding.
{ ��������� nearCallBack ���, ��� ��� ������ ���������. ������ k00m'� �������
  ���� �������, �� �� �� �������� ��������� ������������ (���� �� ��
  �����������!). ���� ������� ����������, ����������� � ������������� (��������
  ����� �������� � ����� ODE � ODE user manual).
  ������, � �������� data � ���� ���������� ��������� �� ������, ���
  ����� ������ - ������ ����������� Frm.ode ����� ������������ ����� ������ }
procedure nearCallback(data: pointer; o1, o2: PdxGeom); cdecl;
var
  i, n: integer;
  b1, b2: PdxBody;
  c: TdJointID;
begin
  // ���� ������������ ������������ � ���-����
  if (dGeomIsSpace(o1) <> 0) or (dGeomIsSpace(o2) <> 0) then
  begin
    // ���������� ����� ����� �������� �����������
    dSpaceCollide2 (o1, o2, data, nearCallback);

    { � ������ ��������� ������ ����� ���������, �� � ������ ������ ��� �����
      ������ ������ ������� �.�. ��� �������� ����������� ������, ���������
      ����������� ���� � ������ (�.�. ������ � �������) ���������, � �����������
      ���� �� �� �����������. ���� ������ ������ ������ �� ���������, ������
      ����-���� ������ fps. �� ��� �������������� ������ ��� ���������� }

{    // ������������ ��������� ������ ������������ (�����������).
    if (dGeomIsSpace(o1) <> 0) then dSpaceCollide (PdxSpace(o1), data, nearCallback);
    if (dGeomIsSpace(o2) <> 0) then dSpaceCollide (PdxSpace(o2), data, nearCallback); //}

  end
  else begin
    b1 := dGeomGetBody(o1);
    b2 := dGeomGetBody(o2);
    // � ������, ���� ���� ���������, �� ���������� ��
    if Assigned(b1) and Assigned(b2) then
      if (dAreConnected(b1, b2) <> 0) then
        Exit;
    n := dCollide (o1, o2, ContactNum, TODE(Data).contact[0].geom, sizeof(TdContact));
    for i := 0 to n-1 do
    begin
      with TODE(data).contact[i] do
      begin
        // ��������� ����������� ���� ������������� ������ � �����...
        if (dGeomGetClass(o1) = dSphereClass) or (dGeomGetClass(o2) = dSphereClass) then
        begin
          surface.mode     := ord(dContactBounce) or ord(dContactSoftcfm) or ord(dContactSoftERP);
          surface.mu       := FRICTION;
          surface.soft_erp := 0.5; // �������������� ����
          surface.soft_cfm := 0.001; // �������� (����� - ������������ �������������)
          surface.bounce   := 0.001;
          surface.bounce_vel:= 0.001;
        end;
        // ...� ���� ������������ ����� � �����
        if (dGeomGetClass(o1) = dBoxClass) or (dGeomGetClass(o2) = dBoxClass) then
        begin
          surface.mode     := ord(dContactSoftERP);
          surface.mu       := 0.6;
          surface.soft_erp := 0.5;
        end;
        // ������� � ������������ ���������� ���������� � ��������� �����������
        c := dJointCreateContact (Frm.Ode.world, Frm.Ode.contactgroup, @Frm.ode.contact[i]);
        dJointAttach (c, b1, b2);
       end;
    end; {for i}
  end; {if dGeomIsSpace else}
end;

////////////////////////////////////////////////////////////////////////////////
//My Physic Ode
constructor TOde.create;
begin
  inherited;
  // ��������������� ������������ "������������" ������ ODE (DynODE.pas), �������
  // ���������� �������������
  if not IsODEInitialized then
    InitODE('ode.dll');
    
  physTime:= 0;
  world:= dWorldCreate;
  // ��� �������� ������������ - Hash �.�. ��� ����� ��������� ��������� ������������
  space:= dHashSpaceCreate(nil);
  contactgroup:= dJointGroupCreate(0);
  // ���������� ���������� �� ��� Z ������ ����, ����� ��������� ������ � �����
  dWorldSetGravity(world,0,0,-0.55);
  // ������� ������ ������ ���� ���
  SetLength(contact,contactnum);
end;

procedure TOde.update;
const
  cDeltaTime = 1/50;
begin
  // �������� data ��������� � Self - ������ ��������� � nearCallBack
  dSpaceCollide(space, Self ,nearCallback);
  dWorldQuickStep(world, cDeltaTime);
  physTime:= physTime + cDeltaTime;
  dJointGroupEmpty(contactgroup);
  if Assigned(Frm.Car) then
    Frm.Car.update;
end;

procedure TOde.Loadmap(Name:string);
var
  Vertices: PdVector3Array;
  Indices: PdIntegerArray;
begin
  Frm.FreeForm.LoadFromFile(Name);
  maps:= CreateTriMeshFromBaseMesh(Frm.FreeForm, space, Vertices, Indices);
  dGeomSetData(maps, Frm.FreeForm);
//  maps.data := Frm.FreeForm;
end;

destructor TOde.destroy;
begin
  dJointGroupDestroy(contactgroup);
  dSpaceDestroy(space);
  dWorldDestroy(world);
  dCloseODE;
  inherited;
end;

////////////////////////////////////////////////////////////////////////////////
//My Car Ode
constructor TCars.create;
var
  m: TdMass;
  i: integer;
  q: TdQuaternion;
  a: PdVector3;
begin
  inherited;
  // ������������ ������ ������� � ������� ������������. ��� ������������ - Simple
  // �.�. ��� ����� ��������� ������ ���������, �� �� ������ ������������
  BodySpace := dSimpleSpaceCreate(Frm.Ode.space);
  // Car Body
  Steer := 0.0;
  speed := 0.0;
  // ������� � ����������� ���� ��� ������
  body[0] := dBodyCreate(Frm.Ode.world);
  dBodySetPosition(body[0], 0+10, 0-110, cSTARTZ+10);
  dMassSetBox(m, 1, cLENGTH, cWIDTH, cHEIGHT);
  { �������� �����!
    ����� ������� ������ geometry.data, body.data, mass.mass �.�.�. �.�.
    �������� ��������� � ��������� �������, ��, ��������, ��� ������ �����
    ������ ODE � ������, ���� �� �� ���������� ��������� ��� Delphi, ��� �����
    �������� ������ ������� ���������� (Access violation) ���, ��� ��� ����,
    ����� ������ �� ���������� ������� ������ (!!!) - ������ �������� �����
    ��������� �� ���� ��������. ��� ��������, ���� � ���������� ODE ���������
    �������� ��������� ������������ ������ ������. �� ����������� ���� �� �����
    ���� �� ������ ������������ ������ ������. ������ ����� ������� ������������
    ������������ ��������� ����� dMassAdjust, dBodySetData, dBodyGetData � �.�.
  }
  dMassAdjust(m, cCMASS);
  dBodySetMass(body[0], @m);
  Geoms[4]:= dCreateBox(BodySpace, cLENGTH, cWIDTH, cHEIGHT); // ������� ���� ��� ������
  dGeomSetBody(Geoms[4], body[0]); // ��������� ���� � ���������
  // ������������� �������, no comments
  Cube := TGLDummyCube(Frm.CarsBox.AddNewChild(TGLDummyCube));
  CarAct:= TGLActor(Frm.CarsBox.AddNewChild(TGLActor));
  CarAct.Parent:= Cube;
  CarAct.LoadFromFile(ExtractFilePath(Application.ExeName)+'slingshot\body.md3');
  CarAct.MaterialLibrary:= Frm.GLMaterialLibrary1;
  CarAct.LightmapLibrary:= Frm.GLMaterialLibrary1;
  CarAct.Material.FrontProperties.Specular.AsWinColor:= clwhite;
  LoadQ3Skin(ExtractFilePath(Application.ExeName)+'slingshot\'+IntToStr(Modelcar)+'.skin',CarAct);
  with CarAct.Scale do
  begin
    X:= 0.03;
    Y:= 0.03;
    Z:= 0.03;
  end;
  with CarAct.Direction do
  begin
    X:= 0;
    Y:= 0;
    Z:= 1;
  end;
  dGeomSetData(Geoms[4], Cube);
  // Geoms[4].data:= Cube
  // ������ :)
  //Wheels
  for i:= 1 to 4 do
  begin
    body[i]:= dBodyCreate(Frm.Ode.world);
    dQFromAxisAndAngle(q,1,0,0,PI*0.5);
    dBodySetQuaternion(body[i],q);
    dMassSetSphere(m,1,cRADIUS);
    // �� ������ ����� ������ ������ ���� ���� �����, ����� ������ ����� ������������
    if (i = 1) or (i = 2) then
      dMassAdjust (m,0.55);
    if (i = 3) or (i = 4) then
      dMassAdjust (m,cWMASS);
    dBodySetMass (body[i],@m);
    Geoms[i-1]:= dCreateSphere(BodySpace, cRADIUS);
    dGeomSetBody(Geoms[i-1],body[i]);
    //������� ���������� ������ ������
    DummyCube:= TGLDummyCube(Frm.CarsBox.AddNewChild(TGLDummyCube));
    dGeomSetData(Geoms[i - 1], DummyCube);
//    Geoms[i-1].data:= DummyCube;
    roueact:= TGLActor(Frm.CarsBox.AddNewChild(TGLActor));
    roueact.LoadFromFile(ExtractFilePath(Application.ExeName)+'slingshot\wheel.md3');
    roueact.MaterialLibrary:= Frm.GLMaterialLibrary1;
    roueact.LightmapLibrary:= Frm.GLMaterialLibrary1;
    roueact.Material.FrontProperties.Specular.AsWinColor:= clWhite;
    roueact.Material.BlendingMode:= bmModulate;
    roueact.Parent:= DummyCube;
    with roueact.Scale do
    begin
      X:= 0.03;
      Y:= 0.03;
      Z:= 0.03;
    end;
    with roueact.Direction do
    begin
      X:= 1;
      Y:= 0;
      Z:= 0;
    end;
    if i = 2 then
      roueact.RollAngle:=180;
    if i = 4 then
      roueact.RollAngle:=180;
  LoadQ3Skin(ExtractFilePath(Application.ExeName)+'slingshot\mag'+IntToStr(Modelcar)+'.skin',roueact);
  end;
  dBodySetPosition(body[1],   0.4*cLENGTH-0.1+10,    cWIDTH*0.7-110,    cSTARTZ-cHEIGHT*0.5-cWHEEL_OFFSET+10);
  dBodySetPosition(body[2],   0.4*cLENGTH-0.1+10,   -cWIDTH*0.7-110,    cSTARTZ-cHEIGHT*0.5-cWHEEL_OFFSET+10);
  dBodySetPosition(body[3], -0.4*cLENGTH+0.25+10,    cWIDTH*0.7-110,    cSTARTZ-cHEIGHT*0.5-cWHEEL_OFFSET+10);
  dBodySetPosition(body[4], -0.4*cLENGTH+0.25+10,   -cWIDTH*0.7-110,    cSTARTZ-cHEIGHT*0.5-cWHEEL_OFFSET+10);
  for i := 0 to 3 do
  begin
    // ������� Hinge2-���������� ����� ������ ������� � ��������
    joint[i]:= dJointCreateHinge2(Frm.Ode.world,0);
    dJointAttach(joint[i],body[0],body[i+1]);
    A:=dBodyGetPosition(body[i+1]);
    dJointSetHinge2Anchor(joint[i],a[0],a[1],a[2]);
    dJointSetHinge2Axis1(joint[i],0,0,1);
    dJointSetHinge2Axis2(joint[i],0,1,0);
    // �������������� ���� "�������������"...
    dJointSetHinge2Param(joint[i],dParamSuspensionERP,cSUSPENSION_ERP);
    // ...� �� ��������
    dJointSetHinge2Param(joint[i],dParamSuspensionCFM,cSUSPENSION_CFM);
    // ���� �������� ���� �������������� � ���� ��� ������
    dJointSetHinge2Param(joint[i],dParamLoStop,-cWHEEL_WOBBLE);
    dJointSetHinge2Param(joint[i],dParamHiStop,+cWHEEL_WOBBLE);
  end;

  { ��� ��������� ����� �� ������������ ������ ���, �� ���������� ���������� ��
    ���� ��� }
  // ������������ �������� ������, �������������� �� ���� ���
  dJointSetHinge2Param (joint[0],dParamFMax,0.2 * cZOOM_CUBED);
  // ����. ���� �������� ����
  dJointSetHinge2Param (joint[0],dParamLoStop,-0.75);
  dJointSetHinge2Param (joint[0],dParamHiStop,0.75);
  // �������� ���������� ������ ���������� ��� � ���������
  dJointSetHinge2Param (joint[0],dParamFudgeFactor,0.1);

  dJointSetHinge2Param (joint[1],dParamFMax,0.2 * cZOOM_CUBED);
  dJointSetHinge2Param (joint[1],dParamLoStop,-0.75);
  dJointSetHinge2Param (joint[1],dParamHiStop,0.75);
  dJointSetHinge2Param (joint[1],dParamFudgeFactor,0.1);
end;

//cheat here for my car this is 4x4 engine, it is because the car can get more speed force.
procedure TCars.update;
var i: integer;
    v: TdReal;
begin
  { ����������� ������� �����. ���������� ��� ������� ������ �.�. ��� ��� ��
   �������, ������� � ����� ������ (������, ���� � ������������, ��� �����
   ������ ������ ��������������� � ������ ������� ��� ������� "����������").
   ������ ��� ������� �������� ���� ��������. � ��� �� ���� ������.
   ��� �������� �������� �� ��� ������� }
  if Steer > 0.50 then
    Steer := 0.50;
  if Steer < -0.50 then
    Steer := -0.50;
  v := Steer - dJointGetHinge2Angle1(joint[0]);

  if (v > 0.1) then
    v := 0.1;
  if (v < -0.1) then
    v := -0.1;
  v := v * 5.0;
  dJointSetHinge2Param (joint[0], dParamVel, v); // �� ����� ���� �������� dParamVel
                                                 // ������������� ��������
  v := Steer - dJointGetHinge2Angle1(joint[1]);  // ������� ��� motor joint'�
  if (v > 0.1) then                              // � "����" ��������������
    v := 0.1;                                    // �� ��������, ��������� �
  if (v < -0.1) then                             // ��������� dParamFMax
    v := -0.1;
  v := v * 5.0;
  dJointSetHinge2Param (joint[1], dParamVel, v);




  //  ���� ��� ���������� ����
  if IsKeyDown(VK_RIGHT) then
    steer:= steer + cTURN_SPEED
  else
  if IsKeyDown(VK_LEFT) then
    steer:= steer - cTURN_SPEED
  else
    Steer:= Steer * 0.55;

  // ������ ����������� �������� �������� ��� ������� �������. ��������...
  if Speed > 25 then
    Speed := 25;
  if Speed < -15 then
    Speed := -15;

  if (not IsKeyDown(VK_UP)) and (not IsKeyDown(VK_DOWN)) then
    Speed:=Speed-0.01;

  if Speed < 25 then
    if not IsKeyDown(' ') then
      if IsKeyDown(VK_UP) then
      begin
        MotorRunning := true;
        if Speed>=0 then
          speed:= speed + cACCEL
        else
          Speed:= 25;
      end
      else
      if IsKeyDown(VK_DOWN) then
      begin
        MotorRunning:= True;
        if Speed<=0 then
          speed:= speed - cACCEL
        else
          Speed:= -15;
      end
      else
      begin
        MotorRunning := false;
        if Speed > -25 then
          Speed:= Speed - 15
        else
          Speed := Speed - 0.01;
      end;
  // ��� ���������� ����� ���������� �������� �������� (dParamVel2) � ����
  //Hard Break 4 wheels.
  if IsKeyDown(' ') then
  begin
    dJointSetHinge2Param(joint[2],dParamVel2,0.0);
    dJointSetHinge2Param(joint[2],dParamFMax2,0.2 * cZOOM_CUBED);
    dJointSetHinge2Param(joint[3],dParamVel2,0.0);
    dJointSetHinge2Param(joint[3],dParamFMax2,0.2 * cZOOM_CUBED);
    dJointSetHinge2Param(joint[0],dParamVel2,0.0);
    dJointSetHinge2Param(joint[0],dParamFMax2,0.2 * cZOOM_CUBED);
    dJointSetHinge2Param(joint[1],dParamVel2,0.0);
    dJointSetHinge2Param(joint[1],dParamFMax2,0.2 * cZOOM_CUBED);
  end
  else
  //Break Back wheels.
  if IsKeyDown('b') then
  begin
    dJointSetHinge2Param(joint[2],dParamVel2,0.0);
    dJointSetHinge2Param(joint[2],dParamFMax2,0.2 * cZOOM_CUBED);
    dJointSetHinge2Param(joint[3],dParamVel2,0.0);
    dJointSetHinge2Param(joint[3],dParamFMax2,0.2 * cZOOM_CUBED);
  end
  else
  begin
    dJointSetHinge2Param(joint[0],dParamFMax2,0.0);
    dJointSetHinge2Param(joint[1],dParamFMax2,0.0);
    dJointSetHinge2Param(joint[2],dParamFMax2,0.0);
    dJointSetHinge2Param(joint[3],dParamFMax2,0.0);
  end;
  if (not IsKeyDown(' ')) and (not IsKeyDown('b')) then
    if MotorRunning then
    begin
      // ���� �� �������� � �������� UP-DOWN,
      // ���������� �������� �������� (dParamVel2)
      // (speed ����� � ������� �.�. ������ ���������� � �������� �������)  
      dJointSetHinge2Param(joint[2],dParamVel2,-speed);
      dJointSetHinge2Param(joint[2],dParamFMax2,0.1 * cZOOM_CUBED);
      dJointSetHinge2Param(joint[3],dParamVel2,-speed);
      dJointSetHinge2Param(joint[3],dParamFMax2,0.1 * cZOOM_CUBED);
      if not IsKeyDown(VK_DOWN) then
      begin
        if Speed > 5 then
        begin
          dJointSetHinge2Param(joint[0],dParamVel2,-speed);
          dJointSetHinge2Param(joint[0],dParamFMax2,0.1 * cZOOM_CUBED);
          dJointSetHinge2Param(joint[1],dParamVel2,-speed);
          dJointSetHinge2Param(joint[1],dParamFMax2,0.1 * cZOOM_CUBED);
        end;
      end;
    end;

  { ������� �����������������, ���������� � ������ 0.6. � ���� ��� ������
    ����������, ��, ������, � ������ ������� ���������� ���� ��������������
    ������������� ���� constrain'�� joint'�� }
{  dJointCorrectHinge2(Joint[0]);
  dJointCorrectHinge2(Joint[1]); //}

  // ��������������� ������� - 'Esc' � 'R'
  if IsKeyDown('r') then
  begin
    dBodyAddForce(body[1], 0,0,2.45 * cZOOM);
    dBodyAddForce(body[2], 0,0,2.45 * cZOOM);
  end;
  if IsKeyDown(27) then
    Frm.Close;
  // ����������� ���������� ������� � ������������ � �����������
  for i := 0 to 4 do
  begin
    PositionSceneObject(TGLBaseSceneObject(Geoms[i].data), Geoms[i]);
    Frm.CamBox.PointTo((Cube), ZHmgVector);
    if Frm.CamBox.DistanceTo(Cube) > 3 then
      Frm.CamBox.Move(0.048);
  end;
  if Frm.Tkiller.Enabled <> true then
  begin
    if Cube.Position.Z < -200 then
    begin
      Frm.Tkiller.Enabled:= True;
      Frm.GLCadencer.Enabled:= False;
      Frm.GLHUDText1.Text:='Wait Plz!';
    end;
  end;
end;

destructor TCars.destroy;
begin
  Frm.CarsBox.DeleteChildren;
  inherited;
end;
////////////////////////////////////////////////////////////////////////////////

procedure TFrm.SetResolution(X,Y:integer);
begin
  if (x=0) and (y=0) then
  begin
    Height:= Screen.Height;
    Width:= Screen.Width;
  end else
  if (x<>0) and (y<>0) then
  begin
    Height:= Y;
    Width:= X;
  end;  
end;

procedure TFrm.FreeAll;
begin
  if Assigned(Ode) then
    Ode.Free;
  if Assigned(Car) then
    Car.Free;
end;

procedure TFrm.GLCadencerProgress(Sender: TObject; const deltaTime,
  newTime: Double);
begin
  if Assigned(Ode) then
  begin
    { ���������� ������ - ���� ��� ������� ������������� ���������� ����� ������.
      ������� ��������, �� ����� �������� }
    while Ode.physTime<newtime*8 do
      Ode.update;
  end;  
  GLSceneViewer.Invalidate;
end;

procedure TFrm.FormDestroy(Sender: TObject);
begin
  FreeAll;
end;

procedure TFrm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  GLCadencer.Enabled:= False;
end;

procedure TFrm.TkillerTimer(Sender: TObject);
begin
  FreeAll;
  Ode:= TOde.create;
  Ode.Loadmap('track02.3DS');
  Car:= TCars.create;
  GLCadencer.Enabled:= True;
  Tkiller.Enabled:= False;
end;

procedure TFrm.TimerTimer(Sender: TObject);
begin
  GLHUDText1.Text:= Format('%.2f FPS', [GLSceneViewer.FramesPerSecond]);
	GLSceneViewer.ResetPerformanceMonitor;
end;

procedure TFrm.FormShow(Sender: TObject);
begin
  FrmMenu.ShowModal;
end;

end.
