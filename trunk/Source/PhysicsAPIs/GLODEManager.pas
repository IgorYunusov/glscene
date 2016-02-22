//
// This unit is part of the GLScene Project, http://glscene.org
//
{
  An ODE Manager for GLScene.

  Where can I find ... ?
  GLScene              (http://glscene.org)
  Open Dynamics Engine (http://opende.sourceforge.org)
  DelphiODE            (http://www.cambrianlabs.com/Mattias/DelphiODE)


  Notes:
  This code is still being developed so any part of it may change at anytime.
  To install use the GLS_ODE?.dpk in the GLScene/Delphi? folder.

  History :
  10/11/12 - PW - Added CPP compatibility: changed vector arrays to records
  21/01/01 - DanB - Added "inherited" call to TODEElementPlane.WriteToFiler
  23/08/10 - Yar - Added OpenGLTokens to uses, replaced OpenGL1x functions to OpenGLAdapter
  14/06/10 - YP  - Sub-element translation code in CalibrateCenterOfMass removed
  22/04/10 - Yar - Fixes after GLState revision
  05/03/10 - DanB - More state added to TGLStateCache
  17/11/09 - DaStr - Improved Unix compatibility(thanks Predator) (BugtrackerID = 2893580)
  08/12/08 - PR - dBodySetMass no longer accepts zero mass. check added joint parms now
             have a 1 appended to them for first parm example dParamLoStop is now dParamLoStop1
  17/10/08 - DanB - changed some NotifyChange(Sender) calls to NotifyChange(Self)
  12/04/08 - DaStr - Cleaned up uses section(thanks Sandor Domokos) (BugtrackerID = 1808373)
  10/04/08 - DaStr - Removed compiler hints from TGLODEDynamic.AddNewElement()
  19/03/08 - Mrqzzz - by DAlex : Added different geom colors;
             Don't create contact between static objects;
             In Destroying procedures placed to last line the "Inherited"
  28/02/08 - Mrqzzz - Changed Axis2 to XHMGVector on universal joint
             creation in TODEJointUniversal.Create
  06/02/08 - Mrqzzz - Upgrade to ODE 0.9 (upgrade by by Paul Robello;
             fixes for runtime creation)
  25/12/07 - DaStr  - Fixed access violation in TGLODEManager.Destroy()
             (thanks Sandor Domokos) (BugtrackerID = 1808371)
  30/11/07 - Mrqzzz - Changed parameters in OnCollision event (TODEObjectCollisionEvent)
  10/10/07 - Mrqzzz - Fixed in TGLODEDynamic.AlignObject the explocit
             reference to ODEGL.ODERToGLSceneMatrix(m,R^,pos^) to avoid ambiguous overloading
  08/09/07 - Mrqzzz - small changes in unit references (last reference is to odeimport) in order to
             make GLODEManager compatible with non-GLODEManager based ODE worlds
             Added public property "ContactGroup"
  24/08/07 - Mrqzzz - Updated GetSurfaceFromObject to support correctly Trimesh collision
  07/06/07 - DaStr - Added GLColor to uses (BugtrackerID = 1732211) Added $I GLScene.inc
  28/03/07 - DaStr - Renamed parameters in some methods (thanks Burkhard Carstens) (Bugtracker ID = 1678658)
  01/03/05 - Mrqzzz - Moved in TGLODEJointBase protected code from Loaded to public DoLoaded.
  20/12/04 - SG - TGLODEStatic objects now realign geoms on step, Fix for Hinge2 and Universal joints,
             Fix for TGLODEDynamic.Enabled property persistence.
  10/12/04 - SG - Added TODEElementPlane, Fixed TODEElementCone.Render function.
  09/12/04 - Mathx - Added getX and getOrCreateX functions.
  19/11/04 - SG - Major structural changes/improvements, Dropped TGLBaseSceneObject style object in favour of
             TGLBehaviour style ones,
             TGLODEBaseBehaviour is now TGLODEBehaviour,
             TGLODEDynamicBehaviour is now TGLODEDynamic,
             TGLODEStaticBehaviour is now TGLODEStatic,
             Added TODEJointParams to handle joint axis parameters,
             Added RenderPoint to GLODEManager to handle rendering.
  17/11/04 - SG - Changed Deinitialize to Finalize, Changed TGLODEDummy to TGLODEDynamicDummy.
  09/11/04 - SG - Fixed problems with contact geom generation (k00m).
  03/05/04 - SG - Tri-mesh and various fixes/enhancements.
  23/04/04 - SG - Fixes for object registration, Exception raised now if ODE fails to initialize at run-time.
  21/04/04 - SG - Changed to dynamic linking DelphiODE, Design-time no longer makes any DelphiODE calls.
  15/04/04 - SG - Added OnCustomCollision event to TGLODEManager.
  14/04/04 - SG - Minor DelphiODE compatibility changes.
  30/03/04 - SG - Joint objects are now fully persistent.
  05/03/04 - SG - SetSurfaceMode fix (Alex)
  25/02/04 - SG - Added the GLODEStaticBehaviour.
  24/02/04 - SG - Added the static GLODETerrain collider.
  23/02/04 - SG - Fix for design to real time gravity persistence. Added cone, cylinder and tri-mesh elements.
             Other various fixes/enhancements.
  28/01/04 - SG - Added TGLODEStaticDummy. Fixed Element alignment code. Other minor fixes/changes.
  13/11/03 - SG - Fixed bug with destroying geoms, manager now forces registered objects to Deinitialize.
             Fixed up some comments.
  12/11/03 - SG - Fixed bug with TGLODEManager.Collision
  01/09/03 - SG - Changed all relevant floating point types to TdReal, Changed Read/Write Single/Double to Read/Write Float.
  19/08/03 - SG - Added GetBodyFromGLSceneObject (Dan Bartlett), Added StepFast and FastIterations to GLODEManager.
  11/08/03 - SG - Added some force/torque methods to dynamic objects.
  30/07/03 - SG - Split terrain collider into GLODECustomColliders unit.
  25/07/03 - SG - Fixed Manager property persistence, other minor changes.
  24/07/03 - SG - ReadFromFiler and WriteToFiler routines added, improved object and joint initialization system.
             Manager properties not persitent in joints and behaviours.
  26/06/03 - EG - Replaced TObjectList with TPersistentObjectList, dropped Contnrs dependency (D5 compatibility)
  23/06/03 - SG - Added GLODETerrainCollider, an implementation from DelphiODE terrain demo (buggy caused assertion error in GLHeightData.pas).
  13/06/03 - SG - Added more joints.
  11/06/03 - SG - Base joint classes implemented and added hinge joint.
  09/06/03 - SG - Added OnCollision event for ODE Objects and Behaviours.
  08/06/03 - SG - Added rolling friction (experimental).
  06/06/03 - SG - Added cylinder element (experimental).
  04/06/03 - SG - Changes to structures, added TGLODEDynamicBehaviour.
  30/05/03 - SG - Added capsule element and plane object, Fixed problems with Collision callback method.
  29/05/03 - SG - Better GetCollisionSurface code (thanks to Mattias Fagerlund).
  28/05/03 - SG - Some fixes to ODE Elements (thanks to Mattias Fagerlund). Added TGLODEDummy.CalibrateCenterOfMass
  01/03/03 - SG - Creation.

}

unit GLODEManager;

interface

{$I GLScene.inc}

uses
  System.Classes, System.SysUtils, System.Math, System.Types,
  // GLS
  ODEGL, ODEImport, GLScene, GLVectorGeometry, GLTexture, OpenGLTokens,
  XOpenGL, GLObjects, GLXCollection, GLPersistentClasses, GLVectorLists,
  GLColor, GLCoordinates, GLRenderContextInfo, GLManager, GLState,
  GLVectorTypes;

type

  TODECustomCollisionEvent = procedure(Geom1, Geom2: PdxGeom) of object;

  TODECollisionEvent = procedure(Sender: TObject; Object1, Object2: TObject;
    var Contact: TdContact; var HandleCollision: Boolean) of object;

  TODEObjectCollisionEvent = procedure(Sender: TObject; Object2: TObject;
    var Contact: TdContact; var HandleCollision: Boolean) of object;

  TODECollisionSurfaceMode = (csmMu2, csmFDir1, csmBounce, csmSoftERP,
    csmSoftCFM, csmMotion1, csmMotion2, csmSlip1, csmSlip2);
  TSurfaceModes = set of TODECollisionSurfaceMode;

  TODESolverMethod = (osmDefault, osmStepFast, osmQuickStep);

  TGLODEElements = class;
  TGLODEBehaviour = class;
  TGLODEElementBase = class;
  TGLODEJointBase = class;

  // TGLODEManager
  //
  TGLODEManager = class(TComponent)
  private
    { Private Declarations }
    FWorld: PdxWorld;
    FSpace: PdxSpace;
    FContactGroup: TdJointGroupID;
    FGravity: TGLCoordinates;
    FOnCollision: TODECollisionEvent;
    FOnCustomCollision: TODECustomCollisionEvent;
    FNumContactJoints, FMaxContacts: Integer;
    FODEBehaviours: TPersistentObjectList;
    FRFContactList: TList;
    FIterations: Integer;
    FSolver: TODESolverMethod;
    FContacts: array of TdContact;
    FContactGeoms: array of TdContactGeom;
    FRenderPoint: TGLRenderPoint;
    FVisible, FVisibleAtRunTime: Boolean;
    FGeomColorDynD, FGeomColorDynE, FGeomColorStat: TGLColor;

  protected
    { Protected Declarations }
    procedure Loaded; override;

    procedure CalcContact(Object1, Object2: TObject; var Contact: TdContact);
    procedure Collision(g1, g2: PdxGeom);

    procedure GravityChange(Sender: TObject);

    procedure SetMaxContacts(const Value: Integer);
    procedure SetGravity(Value: TGLCoordinates);
    procedure SetIterations(const val: Integer);

    function GetODEBehaviour(index: Integer): TGLODEBehaviour;
    procedure RegisterODEBehaviour(ODEBehaviour: TGLODEBehaviour);
    procedure UnregisterODEBehaviour(ODEBehaviour: TGLODEBehaviour);

    procedure SetRenderPoint(const Value: TGLRenderPoint);
    procedure RenderEvent(Sender: TObject; var rci: TGLRenderContextInfo);
    procedure RenderPointFreed(Sender: TObject);

    procedure SetVisible(const Value: Boolean);
    procedure SetVisibleAtRunTime(const Value: Boolean);
    procedure SetGeomColorDynE(const Value: TGLColor);
    procedure GeomColorChangeDynE(Sender: TObject);
    procedure SetGeomColorDynD(const Value: TGLColor);
    procedure GeomColorChangeDynD(Sender: TObject);
    procedure SetGeomColorStat(const Value: TGLColor);
    procedure GeomColorChangeStat(Sender: TObject);

    property ODEBehaviours[index: Integer]: TGLODEBehaviour
      read GetODEBehaviour;

  public
    { Public Declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Step(deltaTime: double);

    procedure NotifyChange(Sender: TObject);

    property World: PdxWorld read FWorld;
    property Space: PdxSpace read FSpace;
    property ContactGroup: TdJointGroupID read FContactGroup;
    property NumContactJoints: Integer read FNumContactJoints;

  published
    { Published Declarations }
    property Gravity: TGLCoordinates read FGravity write SetGravity;
    property OnCollision: TODECollisionEvent read FOnCollision
      write FOnCollision;
    property OnCustomCollision: TODECustomCollisionEvent read FOnCustomCollision
      write FOnCustomCollision;
    property Solver: TODESolverMethod read FSolver write FSolver;
    property Iterations: Integer read FIterations write SetIterations;
    property MaxContacts: Integer read FMaxContacts write SetMaxContacts;
    property RenderPoint: TGLRenderPoint read FRenderPoint write SetRenderPoint;
    property Visible: Boolean read FVisible write SetVisible;
    property VisibleAtRunTime: Boolean read FVisibleAtRunTime
      write SetVisibleAtRunTime;
    property GeomColorDynD: TGLColor read FGeomColorDynD write SetGeomColorDynD;
    property GeomColorDynE: TGLColor read FGeomColorDynE write SetGeomColorDynE;
    property GeomColorStat: TGLColor read FGeomColorStat write SetGeomColorStat;

  end;

  // TGLODECollisionSurface
  //
  TGLODECollisionSurface = class(TPersistent)
  private
    { Private Declarations }
    FOwner: TPersistent;
    FSurfaceParams: TdSurfaceParameters;
    FRFCoeff: Single;
    FRFEnabled: Boolean;

  protected
    { Protected Declarations }
    procedure WriteToFiler(writer: TWriter);
    procedure ReadFromFiler(reader: TReader);

    function GetSurfaceMode: TSurfaceModes;
    function GetMu: TdReal;
    function GetMu2: TdReal;
    function GetBounce: TdReal;
    function GetBounce_Vel: TdReal;
    function GetSoftERP: TdReal;
    function GetSoftCFM: TdReal;
    function GetMotion1: TdReal;
    function GetMotion2: TdReal;
    function GetSlip1: TdReal;
    function GetSlip2: TdReal;

    procedure SetSurfaceMode(Value: TSurfaceModes);
    procedure SetMu(Value: TdReal);
    procedure SetMu2(Value: TdReal);
    procedure SetBounce(Value: TdReal);
    procedure SetBounce_Vel(Value: TdReal);
    procedure SetSoftERP(Value: TdReal);
    procedure SetSoftCFM(Value: TdReal);
    procedure SetMotion1(Value: TdReal);
    procedure SetMotion2(Value: TdReal);
    procedure SetSlip1(Value: TdReal);
    procedure SetSlip2(Value: TdReal);

  public
    { Public Declarations }
    constructor Create(AOwner: TPersistent);
    function GetOwner: TPersistent; override;
    procedure Assign(Source: TPersistent); override;

  published
    { Published Declarations }
    property RollingFrictionCoeff: Single read FRFCoeff write FRFCoeff;
    property RollingFrictionEnabled: Boolean read FRFEnabled write FRFEnabled;
    property SurfaceMode: TSurfaceModes read GetSurfaceMode
      write SetSurfaceMode;
    property Mu: TdReal read GetMu write SetMu;
    property Mu2: TdReal read GetMu2 write SetMu2;
    property Bounce: TdReal read GetBounce write SetBounce;
    property Bounce_Vel: TdReal read GetBounce_Vel write SetBounce_Vel;
    property SoftERP: TdReal read GetSoftERP write SetSoftERP;
    property SoftCFM: TdReal read GetSoftCFM write SetSoftCFM;
    property Motion1: TdReal read GetMotion1 write SetMotion1;
    property Motion2: TdReal read GetMotion2 write SetMotion2;
    property Slip1: TdReal read GetSlip1 write SetSlip1;
    property Slip2: TdReal read GetSlip2 write SetSlip2;

  end;

  TGLODEElementClass = class of TGLODEElementBase;

  // TGLODEBehaviour
  //
  { Basis structures for GLScene behaviour style implementations. }
  TGLODEBehaviour = class(TGLBehaviour)
  private
    { Private Declartions }
    FManager: TGLODEManager;
    FManagerName: String;
    FSurface: TGLODECollisionSurface;
    FOnCollision: TODEObjectCollisionEvent;
    FInitialized: Boolean;
    FOwnerBaseSceneObject: TGLBaseSceneObject;
  protected
    { Protected Declarations }
    procedure Initialize; virtual;
    procedure Finalize; virtual;

    procedure WriteToFiler(writer: TWriter); override;
    procedure ReadFromFiler(reader: TReader); override;
    procedure Loaded; override;

    procedure SetManager(Value: TGLODEManager);
    procedure SetSurface(Value: TGLODECollisionSurface);
    function GetAbsoluteMatrix: TMatrix;

  public
    { Public Declarations }
    constructor Create(AOwner: TGLXCollection); override;
    destructor Destroy; override;

    procedure NotifyChange(Sender: TObject);
    procedure Render(var rci: TGLRenderContextInfo); virtual;

    procedure Reinitialize;
    property Initialized: Boolean read FInitialized;
    property AbsoluteMatrix: TMatrix read GetAbsoluteMatrix;

  published
    { Published Declarations }
    property Manager: TGLODEManager read FManager write SetManager;
    property Surface: TGLODECollisionSurface read FSurface write SetSurface;
    property OnCollision: TODEObjectCollisionEvent read FOnCollision
      write FOnCollision;

  end;

  // TGLODEDynamic
  //
  TGLODEDynamic = class(TGLODEBehaviour)
  private
    { Private Declarations }
    FBody: PdxBody;
    FMass: TdMass;
    FElements: TGLODEElements;
    FEnabled: Boolean;
    FJointRegister: TList;

  protected
    { Protected Declarations }
    procedure Initialize; override;
    procedure Finalize; override;
    procedure WriteToFiler(writer: TWriter); override;
    procedure ReadFromFiler(reader: TReader); override;

    procedure SetMass(const Value: TdMass);
    function GetMass: TdMass;
    procedure AlignBodyToMatrix(Mat: TMatrix);
    procedure SetEnabled(const Value: Boolean);
    function GetEnabled: Boolean;

    procedure RegisterJoint(Joint: TGLODEJointBase);
    procedure UnregisterJoint(Joint: TGLODEJointBase);

  public
    { Public Declarations }
    constructor Create(AOwner: TGLXCollection); override;
    destructor Destroy; override;

    procedure Render(var rci: TGLRenderContextInfo); override;

    class function FriendlyName: String; override;
    class function UniqueItem: Boolean; override;

    function AddNewElement(AChild: TGLODEElementClass): TGLODEElementBase; dynamic;
    procedure AlignObject;
    function CalculateMass: TdMass;
    procedure CalibrateCenterOfMass;

    procedure AddForce(Force: TAffineVector);
    procedure AddForceAtPos(Force, Pos: TAffineVector);
    procedure AddForceAtRelPos(Force, Pos: TAffineVector);
    procedure AddRelForce(Force: TAffineVector);
    procedure AddRelForceAtPos(Force, Pos: TAffineVector);
    procedure AddRelForceAtRelPos(Force, Pos: TAffineVector);
    procedure AddTorque(Torque: TAffineVector);
    procedure AddRelTorque(Torque: TAffineVector);

    property Body: PdxBody read FBody;
    property Mass: TdMass read GetMass write SetMass;

  published
    { Published Declarations }
    property Elements: TGLODEElements read FElements;
    property Enabled: Boolean read GetEnabled write SetEnabled;

  end;

  // TGLODEStatic
  //
  TGLODEStatic = class(TGLODEBehaviour)
  private
    { Private Declarations }
    FElements: TGLODEElements;

  protected
    { Protected Declarations }
    procedure Initialize; override;
    procedure Finalize; override;
    procedure WriteToFiler(writer: TWriter); override;
    procedure ReadFromFiler(reader: TReader); override;
    procedure AlignElements;

  public
    { Public Declarations }
    constructor Create(AOwner: TGLXCollection); override;
    destructor Destroy; override;

    procedure Render(var rci: TGLRenderContextInfo); override;

    class function FriendlyName: String; override;
    class function UniqueItem: Boolean; override;
    function AddNewElement(AChild: TGLODEElementClass): TGLODEElementBase; dynamic;

  published
    { Published Declarations }
    property Elements: TGLODEElements read FElements;

  end;

  // TGLODEElements
  //
  TGLODEElements = class(TGLXCollection)
  private
    { Private Declarations }
    function GetElement(index: Integer): TGLODEElementBase;

  public
    { Public Declarations }
    destructor Destroy; override;
    class function ItemsClass: TGLXCollectionItemClass; override;
    procedure Initialize;
    procedure Finalize;

    procedure NotifyChange(Sender: TObject);

    procedure Render(var rci: TGLRenderContextInfo);

    property Element[index: Integer]: TGLODEElementBase read GetElement;

  end;

  // TGLODEElementBase
  //
  TGLODEElementBase = class(TGLXCollectionItem)
  private
    { Private Declarations }
    FMass: TdMass;
    FDensity: TdReal;
    FGeomTransform, FGeomElement: PdxGeom;
    FPosition, FDirection, FUp: TGLCoordinates;
    FLocalMatrix: TMatrix;
    FRealignODE, FInitialized, FDynamic, FIsCalculating: Boolean;

  protected
    { Protected Declarations }
    procedure Initialize; virtual;
    procedure Finalize; virtual;
    function CalculateMass: TdMass; virtual;
    procedure ODERebuild; virtual;

    procedure NotifyChange(Sender: TObject);
    procedure CoordinateChanged(Sender: TObject);

    procedure WriteToFiler(writer: TWriter); override;
    procedure ReadFromFiler(reader: TReader); override;

    function IsODEInitialized: Boolean;
    procedure AlignGeomElementToMatrix(Mat: TMatrix); virtual;
    procedure SetGeomElement(aGeom: PdxGeom);

    procedure RebuildMatrix;
    procedure RebuildVectors;

    procedure SetDensity(const Value: TdReal);
    procedure SetMatrix(const Value: TMatrix);
    function GetMatrix: TMatrix;

    procedure SetPosition(const Value: TGLCoordinates);
    procedure SetDirection(const Value: TGLCoordinates);
    procedure SetUp(const Value: TGLCoordinates);

  public
    { Public Declarations }
    constructor Create(AOwner: TGLXCollection); override;
    destructor Destroy; override;

    procedure Render(var rci: TGLRenderContextInfo); virtual;

    function AbsoluteMatrix: TMatrix;
    function AbsolutePosition: TAffineVector;

    property Matrix: TMatrix read GetMatrix write SetMatrix;
    property GeomTransform: PdxGeom read FGeomTransform;
    property Geom: PdxGeom read FGeomElement;
    property Initialized: Boolean read FInitialized;

  published
    { Published Declarations }
    property Density: TdReal read FDensity write SetDensity;
    property Position: TGLCoordinates read FPosition write SetPosition;
    property Direction: TGLCoordinates read FDirection write SetDirection;
    property Up: TGLCoordinates read FUp write SetUp;

  end;

  // TODEElementBox
  //
  { ODE box implementation. }
  TODEElementBox = class(TGLODEElementBase)
  private
    { Private Declarations }
    FBoxWidth, FBoxHeight, FBoxDepth: TdReal;

  protected
    { Protected Declarations }
    procedure Initialize; override;
    function CalculateMass: TdMass; override;
    procedure ODERebuild; override;
    procedure WriteToFiler(writer: TWriter); override;
    procedure ReadFromFiler(reader: TReader); override;

    function GetBoxWidth: TdReal;
    function GetBoxHeight: TdReal;
    function GetBoxDepth: TdReal;
    procedure SetBoxWidth(const Value: TdReal);
    procedure SetBoxHeight(const Value: TdReal);
    procedure SetBoxDepth(const Value: TdReal);

  public
    { Public Declarations }
    constructor Create(AOwner: TGLXCollection); override;

    procedure Render(var rci: TGLRenderContextInfo); override;

    class function FriendlyName: String; override;
    class function FriendlyDescription: String; override;
    class function ItemCategory: String; override;

  published
    property BoxWidth: TdReal read GetBoxWidth write SetBoxWidth;
    property BoxHeight: TdReal read GetBoxHeight write SetBoxHeight;
    property BoxDepth: TdReal read GetBoxDepth write SetBoxDepth;
  end;

  // TODEElementSphere
  //
  { ODE sphere implementation. }
  TODEElementSphere = class(TGLODEElementBase)
  private
    { Private Declarations }
    FRadius: TdReal;

  protected
    { Protected Declarations }
    procedure Initialize; override;
    function CalculateMass: TdMass; override;
    procedure ODERebuild; override;

    procedure WriteToFiler(writer: TWriter); override;
    procedure ReadFromFiler(reader: TReader); override;

    function GetRadius: TdReal;
    procedure SetRadius(const Value: TdReal);

  public
    { Public Declarations }
    constructor Create(AOwner: TGLXCollection); override;

    procedure Render(var rci: TGLRenderContextInfo); override;

    class function FriendlyName: String; override;
    class function FriendlyDescription: String; override;
    class function ItemCategory: String; override;

  published
    { Published Declarations }
    property Radius: TdReal read GetRadius write SetRadius;

  end;

  // TODEElementCapsule
  //
  { ODE capped cylinder implementation. }
  TODEElementCapsule = class(TGLODEElementBase)
  private
    { Private Declarations }
    FRadius, FLength: TdReal;

  protected
    { Protected Declarations }
    procedure Initialize; override;
    function CalculateMass: TdMass; override;
    procedure ODERebuild; override;

    procedure WriteToFiler(writer: TWriter); override;
    procedure ReadFromFiler(reader: TReader); override;

    function GetRadius: TdReal;
    function GetLength: TdReal;
    procedure SetRadius(const Value: TdReal);
    procedure SetLength(const Value: TdReal);

  public
    { Public Declarations }
    constructor Create(AOwner: TGLXCollection); override;

    procedure Render(var rci: TGLRenderContextInfo); override;

    class function FriendlyName: String; override;
    class function FriendlyDescription: String; override;
    class function ItemCategory: String; override;

  published
    { Published Declarations }
    property Radius: TdReal read GetRadius write SetRadius;
    property Length: TdReal read GetLength write SetLength;

  end;

  // TODEElementCylinder
  //
  { ODE cylinder implementation. }
  TODEElementCylinder = class(TGLODEElementBase)
  private
    { Private Declarations }
    FRadius, FLength: TdReal;

  protected
    { Protected Declarations }
    procedure Initialize; override;
    function CalculateMass: TdMass; override;
    procedure ODERebuild; override;

    procedure WriteToFiler(writer: TWriter); override;
    procedure ReadFromFiler(reader: TReader); override;

    function GetRadius: TdReal;
    function GetLength: TdReal;
    procedure SetRadius(const Value: TdReal);
    procedure SetLength(const Value: TdReal);

  public
    { Public Declarations }
    constructor Create(AOwner: TGLXCollection); override;

    procedure Render(var rci: TGLRenderContextInfo); override;

    class function FriendlyName: String; override;
    class function FriendlyDescription: String; override;
    class function ItemCategory: String; override;

  published
    { Published Declarations }
    property Radius: TdReal read GetRadius write SetRadius;
    property Length: TdReal read GetLength write SetLength;

  end;

  // TODEElementTriMesh
  //
  { ODE tri-mesh implementation. }
  TODEElementTriMesh = class(TGLODEElementBase)
  private
    { Private Declarations }
    FTriMeshData: PdxTriMeshData;
    FVertices: TAffineVectorList;
    FIndices: TIntegerList;

  protected
    { Protected Declarations }
    procedure Initialize; override;
    procedure Finalize; override;
    function CalculateMass: TdMass; override;

    procedure WriteToFiler(writer: TWriter); override;
    procedure ReadFromFiler(reader: TReader); override;

    procedure SetVertices(const Value: TAffineVectorList);
    procedure SetIndices(const Value: TIntegerList);

  public
    { Public Declarations }
    constructor Create(AOwner: TGLXCollection); override;
    destructor Destroy; override;

    class function FriendlyName: String; override;
    class function FriendlyDescription: String; override;
    class function ItemCategory: String; override;

    procedure RefreshTriMeshData;

    property Vertices: TAffineVectorList read FVertices write SetVertices;
    property Indices: TIntegerList read FIndices write SetIndices;

  end;

  // TODEElementPlane
  //
  { ODE plane implementation. }
  TODEElementPlane = class(TGLODEElementBase)
  protected
    { Protected Declarations }
    procedure Initialize; override;

    procedure WriteToFiler(writer: TWriter); override;
    procedure ReadFromFiler(reader: TReader); override;

    procedure AlignGeomElementToMatrix(Mat: TMatrix); override;

  public
    { Public Declarations }
    class function FriendlyName: String; override;
    class function FriendlyDescription: String; override;
    class function ItemCategory: String; override;
    class function CanAddTo(collection: TGLXCollection): Boolean; override;

  end;

  // TGLODEJoints
  //
  { An XCollection decendant for ODE Joints. }
  TGLODEJoints = class(TGLXCollection)
  protected
    { Protected Declarations }
    function GetJoint(index: Integer): TGLODEJointBase;

  public
    { Public Declarations }
    class function ItemsClass: TGLXCollectionItemClass; override;

    procedure Initialize;
    procedure Finalize;

    property Joint[index: Integer]: TGLODEJointBase read GetJoint; default;

  end;

  // TGLODEJointList
  //
  { Component front-end for storing ODE Joints. }
  TGLODEJointList = class(TComponent)
  private
    { Private Declarations }
    FJoints: TGLODEJoints;

  protected
    { Protected Declarations }
    procedure WriteJoints(stream: TStream);
    procedure ReadJoints(stream: TStream);
    procedure DefineProperties(Filer: TFiler); override;

    procedure Loaded; override;
    procedure Notification(AComponent: TComponent;
      Operation: TOperation); override;

  public
    { Public Declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

  published
    { Published Declarations }
    property Joints: TGLODEJoints read FJoints;

  end;

  TJointOption = (joBothObjectsMustBeAssigned);
  TJointOptions = set of TJointOption;

  // TGLODEJointBase
  //
  { Base structures for ODE Joints. }
  TGLODEJointBase = class(TGLXCollectionItem)
  private
    { Private Declarations }
    FJointID: TdJointID;
    FObject1, FObject2: TGLBaseSceneObject;
    FManager: TGLODEManager;
    FObject1Name, FObject2Name, FManagerName: String;
    FInitialized, FEnabled: Boolean;
    FJointOptions: TJointOptions;

  protected
    { Protected Declarations }

    procedure WriteToFiler(writer: TWriter); override;
    procedure ReadFromFiler(reader: TReader); override;

    procedure Loaded; override;

    function IsODEInitialized: Boolean;
    procedure RegisterJointWithObject(Obj: TGLBaseSceneObject);
    procedure UnregisterJointWithObject(Obj: TGLBaseSceneObject);
    procedure Attach;

    procedure SetManager(const Value: TGLODEManager);
    procedure SetObject1(const Value: TGLBaseSceneObject);
    procedure SetObject2(const Value: TGLBaseSceneObject);
    procedure SetEnabled(const Value: Boolean);

    procedure SetJointOptions(const Value: TJointOptions);

    property JointOptions: TJointOptions read FJointOptions
      write SetJointOptions;

  public
    { Public Declarations }
    constructor Create(AOwner: TGLXCollection); override;
    destructor Destroy; override;
    procedure StructureChanged; virtual;

    procedure Initialize; virtual;
    procedure Finalize; virtual;
    function IsAttached: Boolean;

    procedure DoLoaded;

    property JointID: TdJointID read FJointID;
    property Initialized: Boolean read FInitialized;

  published
    { Published Declarations }
    property Manager: TGLODEManager read FManager write SetManager;
    property Object1: TGLBaseSceneObject read FObject1 write SetObject1;
    property Object2: TGLBaseSceneObject read FObject2 write SetObject2;
    property Enabled: Boolean read FEnabled write SetEnabled;

  end;

  TODESetParamCallback = function(Param: Integer; const Value: TdReal)
    : Boolean of object;
  TODEGetParamCallback = function(Param: Integer; var Value: TdReal)
    : Boolean of object;

  TODEJointParams = class(TPersistent)
  private
    { Private Declarations }
    FOwner: TPersistent;
    FSetCallback: TODESetParamCallback;
    FGetCallback: TODEGetParamCallback;

    FLoStop, FHiStop, FVel, FFMax, FFudgeFactor, FBounce, FCFM, FStopERP,
      FStopCFM, FSuspensionERP, FSuspensionCFM: TdReal;

    FFlagLoStop, FFlagHiStop, FFlagVel, FFlagFMax, FFlagFudgeFactor,
      FFlagBounce, FFlagCFM, FFlagStopERP, FFlagStopCFM, FFlagSuspensionERP,
      FFlagSuspensionCFM: Boolean;

  protected
    { Protected Declarations }
    function GetLoStop: TdReal;
    function GetHiStop: TdReal;
    function GetVel: TdReal;
    function GetFMax: TdReal;
    function GetFudgeFactor: TdReal;
    function GetBounce: TdReal;
    function GetCFM: TdReal;
    function GetStopERP: TdReal;
    function GetStopCFM: TdReal;
    function GetSuspensionERP: TdReal;
    function GetSuspensionCFM: TdReal;

    procedure SetLoStop(const Value: TdReal);
    procedure SetHiStop(const Value: TdReal);
    procedure SetVel(const Value: TdReal);
    procedure SetFMax(const Value: TdReal);
    procedure SetFudgeFactor(const Value: TdReal);
    procedure SetBounce(const Value: TdReal);
    procedure SetCFM(const Value: TdReal);
    procedure SetStopERP(const Value: TdReal);
    procedure SetStopCFM(const Value: TdReal);
    procedure SetSuspensionERP(const Value: TdReal);
    procedure SetSuspensionCFM(const Value: TdReal);

    procedure WriteToFiler(writer: TWriter);
    procedure ReadFromFiler(reader: TReader);

  public
    { Public Declarations }
    constructor Create(AOwner: TPersistent);
    function GetOwner: TPersistent; override;
    procedure Assign(Source: TPersistent); override;

    procedure ApplyFlagged;

    property SetCallback: TODESetParamCallback read FSetCallback
      write FSetCallback;
    property GetCallback: TODEGetParamCallback read FGetCallback
      write FGetCallback;

  published
    { Published Declarations }
    property LoStop: TdReal read GetLoStop write SetLoStop;
    property HiStop: TdReal read GetHiStop write SetHiStop;
    property Vel: TdReal read GetVel write SetVel;
    property FMax: TdReal read GetFMax write SetFMax;
    property FudgeFactor: TdReal read GetFudgeFactor write SetFudgeFactor;
    property Bounce: TdReal read GetBounce write SetBounce;
    property CFM: TdReal read GetCFM write SetCFM;
    property StopERP: TdReal read GetStopERP write SetStopERP;
    property StopCFM: TdReal read GetStopCFM write SetStopCFM;
    property SuspensionERP: TdReal read GetSuspensionERP write SetSuspensionERP;
    property SuspensionCFM: TdReal read GetSuspensionCFM write SetSuspensionCFM;

  end;

  // TODEJointHinge
  //
  { ODE hinge joint implementation. }
  TODEJointHinge = class(TGLODEJointBase)
  private
    { Private Declarations }
    FAnchor, FAxis: TGLCoordinates;
    FAxisParams: TODEJointParams;

  protected
    { Protected Declarations }

    procedure WriteToFiler(writer: TWriter); override;
    procedure ReadFromFiler(reader: TReader); override;

    procedure SetAnchor(const Value: TGLCoordinates);
    procedure SetAxis(const Value: TGLCoordinates);
    procedure AnchorChange(Sender: TObject);
    procedure AxisChange(Sender: TObject);

    procedure SetAxisParams(const Value: TODEJointParams);
    function SetAxisParam(Param: Integer; const Value: TdReal): Boolean;
    function GetAxisParam(Param: Integer; var Value: TdReal): Boolean;

  public
    { Public Declarations }
    constructor Create(AOwner: TGLXCollection); override;
    destructor Destroy; override;
    procedure StructureChanged; override;

    procedure Initialize; override;
    class function FriendlyName: String; override;
    class function FriendlyDescription: String; override;

  published
    { Published Declarations }
    property Anchor: TGLCoordinates read FAnchor write SetAnchor;
    property Axis: TGLCoordinates read FAxis write SetAxis;
    property AxisParams: TODEJointParams read FAxisParams write SetAxisParams;

  end;

  // TODEJointBall
  //
  { ODE ball joint implementation. }
  TODEJointBall = class(TGLODEJointBase)
  private
    { Private Declarations }
    FAnchor: TGLCoordinates;

  protected
    { Protected Declarations }

    procedure WriteToFiler(writer: TWriter); override;
    procedure ReadFromFiler(reader: TReader); override;

    procedure SetAnchor(const Value: TGLCoordinates);
    procedure AnchorChange(Sender: TObject);

  public
    { Public Declarations }
    constructor Create(AOwner: TGLXCollection); override;
    destructor Destroy; override;

    procedure StructureChanged; override;
    procedure Initialize; override;

    class function FriendlyName: String; override;
    class function FriendlyDescription: String; override;

  published
    { Published Declarations }
    property Anchor: TGLCoordinates read FAnchor write SetAnchor;

  end;

  // TODEJointSlider
  //
  { ODE slider joint implementation. }
  TODEJointSlider = class(TGLODEJointBase)
  private
    { Private Declarations }
    FAxis: TGLCoordinates;
    FAxisParams: TODEJointParams;

  protected
    { Protected Declarations }

    procedure WriteToFiler(writer: TWriter); override;
    procedure ReadFromFiler(reader: TReader); override;

    procedure SetAxis(const Value: TGLCoordinates);
    procedure AxisChange(Sender: TObject);

    procedure SetAxisParams(const Value: TODEJointParams);
    function SetAxisParam(Param: Integer; const Value: TdReal): Boolean;
    function GetAxisParam(Param: Integer; var Value: TdReal): Boolean;

  public
    { Public Declarations }
    constructor Create(AOwner: TGLXCollection); override;
    destructor Destroy; override;

    procedure StructureChanged; override;
    procedure Initialize; override;

    class function FriendlyName: String; override;
    class function FriendlyDescription: String; override;

  published
    { Published Declarations }
    property Axis: TGLCoordinates read FAxis write SetAxis;
    property AxisParams: TODEJointParams read FAxisParams write SetAxisParams;

  end;

  // TODEJointFixed
  //
  { ODE fixed joint implementation. }
  TODEJointFixed = class(TGLODEJointBase)
  protected
    { Protected Declarations }

    procedure WriteToFiler(writer: TWriter); override;
    procedure ReadFromFiler(reader: TReader); override;

  public
    { Public Declarations }
    class function FriendlyName: String; override;
    class function FriendlyDescription: String; override;
    procedure Initialize; override;

  end;

  // TODEJointHinge2
  //
  { ODE hinge2 joint implementation. }
  TODEJointHinge2 = class(TGLODEJointBase)
  private
    { Private Declarations }
    FAnchor, FAxis1, FAxis2: TGLCoordinates;
    FAxis1Params, FAxis2Params: TODEJointParams;

  protected
    { Protected Declarations }

    procedure WriteToFiler(writer: TWriter); override;
    procedure ReadFromFiler(reader: TReader); override;

    procedure SetAnchor(const Value: TGLCoordinates);
    procedure SetAxis1(const Value: TGLCoordinates);
    procedure SetAxis2(const Value: TGLCoordinates);
    procedure AnchorChange(Sender: TObject);
    procedure Axis1Change(Sender: TObject);
    procedure Axis2Change(Sender: TObject);

    procedure SetAxis1Params(const Value: TODEJointParams);
    procedure SetAxis2Params(const Value: TODEJointParams);
    function SetAxis1Param(Param: Integer; const Value: TdReal): Boolean;
    function SetAxis2Param(Param: Integer; const Value: TdReal): Boolean;
    function GetAxis1Param(Param: Integer; var Value: TdReal): Boolean;
    function GetAxis2Param(Param: Integer; var Value: TdReal): Boolean;

  public
    { Public Declarations }
    constructor Create(AOwner: TGLXCollection); override;
    destructor Destroy; override;

    procedure StructureChanged; override;
    procedure Initialize; override;

    class function FriendlyName: String; override;
    class function FriendlyDescription: String; override;

  published
    { Published Declarations }
    property Anchor: TGLCoordinates read FAnchor write SetAnchor;
    property Axis1: TGLCoordinates read FAxis1 write SetAxis1;
    property Axis2: TGLCoordinates read FAxis2 write SetAxis2;
    property Axis1Params: TODEJointParams read FAxis1Params
      write SetAxis1Params;
    property Axis2Params: TODEJointParams read FAxis2Params
      write SetAxis2Params;

  end;

  // TODEJointUniversal
  //
  { ODE universal joint implementation. }
  TODEJointUniversal = class(TGLODEJointBase)
  private
    { Private Declarations }
    FAnchor, FAxis1, FAxis2: TGLCoordinates;
    FAxis1Params, FAxis2Params: TODEJointParams;

  protected
    { Protected Declarations }

    procedure WriteToFiler(writer: TWriter); override;
    procedure ReadFromFiler(reader: TReader); override;

    procedure SetAnchor(const Value: TGLCoordinates);
    procedure SetAxis1(const Value: TGLCoordinates);
    procedure SetAxis2(const Value: TGLCoordinates);
    procedure AnchorChange(Sender: TObject);
    procedure Axis1Change(Sender: TObject);
    procedure Axis2Change(Sender: TObject);

    procedure SetAxis1Params(const Value: TODEJointParams);
    procedure SetAxis2Params(const Value: TODEJointParams);
    function SetAxis1Param(Param: Integer; const Value: TdReal): Boolean;
    function SetAxis2Param(Param: Integer; const Value: TdReal): Boolean;
    function GetAxis1Param(Param: Integer; var Value: TdReal): Boolean;
    function GetAxis2Param(Param: Integer; var Value: TdReal): Boolean;

  public
    { Public Declarations }
    constructor Create(AOwner: TGLXCollection); override;
    destructor Destroy; override;

    procedure Initialize; override;
    procedure StructureChanged; override;

    class function FriendlyName: String; override;
    class function FriendlyDescription: String; override;

  published
    { Published Declarations }
    property Anchor: TGLCoordinates read FAnchor write SetAnchor;
    property Axis1: TGLCoordinates read FAxis1 write SetAxis1;
    property Axis2: TGLCoordinates read FAxis2 write SetAxis2;
    property Axis1Params: TODEJointParams read FAxis1Params
      write SetAxis1Params;
    property Axis2Params: TODEJointParams read FAxis2Params
      write SetAxis2Params;

  end;

  { ODE nearCallBack, throws near callback to the collision procedure
    of the ODE manager linked by the Data pointer. }
procedure nearCallBack(Data: Pointer; o1, o2: PdxGeom); cdecl;
{ Helper functions for extracting data from objects with different
  inheritance. }
function GetBodyFromObject(anObject: TObject): PdxBody;
function GetBodyFromGLSceneObject(anObject: TGLBaseSceneObject): PdxBody;
function GetSurfaceFromObject(anObject: TObject): TGLODECollisionSurface;

// GLODEObject register methods (used for joint object persistence)
procedure RegisterGLSceneObject(anObject: TGLBaseSceneObject);
procedure UnregisterGLSceneObject(anObject: TGLBaseSceneObject);
function GetGLSceneObject(anObjectName: String): TGLBaseSceneObject;

// Get and GetOrCreate functions for ode behaviours
function GetOdeStatic(Obj: TGLBaseSceneObject): TGLODEStatic;
function GetOrCreateOdeStatic(Obj: TGLBaseSceneObject): TGLODEStatic;
function GetOdeDynamic(Obj: TGLBaseSceneObject): TGLODEDynamic;
function GetOrCreateOdeDynamic(Obj: TGLBaseSceneObject): TGLODEDynamic;

var
  vGLODEObjectRegister: TList;

  // ------------------------------------------------------------------
  // ------------------------------------------------------------------
  // ------------------------------------------------------------------
implementation

// ------------------------------------------------------------------
// ------------------------------------------------------------------
// ------------------------------------------------------------------
uses
  GLContext;

// nearCallBack
//
procedure nearCallBack(Data: Pointer; o1, o2: PdxGeom); cdecl;
begin
  TGLODEManager(Data).Collision(o1, o2);
end;

// GetBodyFromObject
//
function GetBodyFromObject(anObject: TObject): PdxBody;
begin
  Result := nil;
  if Assigned(anObject) then
    if anObject is TGLODEDynamic then
      Result := TGLODEDynamic(anObject).Body;
end;

// GetBodyFromGLSceneObject
//
function GetBodyFromGLSceneObject(anObject: TGLBaseSceneObject): PdxBody;
var
  temp: TGLODEDynamic;
begin
  Result := nil;
  if Assigned(anObject) then
  begin
    temp := TGLODEDynamic(anObject.Behaviours.GetByClass(TGLODEDynamic));
    if temp <> nil then
      Result := temp.Body;
  end;
end;

// GetSurfaceFromObject
//
function GetSurfaceFromObject(anObject: TObject): TGLODECollisionSurface;
var
  ODEBehaviour: TGLODEBehaviour;
begin
  Result := nil;
  if Assigned(anObject) then
    if anObject is TGLODEBehaviour then
      Result := TGLODEBehaviour(anObject).Surface
    else
    begin
      if (anObject is TGLBaseSceneObject) then
      begin
        ODEBehaviour := TGLODEBehaviour(TGLBaseSceneObject(anObject)
          .Behaviours.GetByClass(TGLODEBehaviour));
        if Assigned(ODEBehaviour) then
          Result := ODEBehaviour.Surface
      end;
    end;
end;

// IsGLODEObject
//
function IsGLODEObject(Obj: TGLBaseSceneObject): Boolean;
var
  temp: TGLODEDynamic;
begin
  Result := False;
  if Assigned(Obj) then
  begin
    temp := TGLODEDynamic(Obj.Behaviours.GetByClass(TGLODEDynamic));
    Result := Assigned(temp);
  end;
end;

// RegisterGLSceneObject
//
procedure RegisterGLSceneObject(anObject: TGLBaseSceneObject);
begin
  if vGLODEObjectRegister.IndexOf(anObject) = -1 then
    vGLODEObjectRegister.Add(anObject);
end;

// UnregisterGLSceneObject
//
procedure UnregisterGLSceneObject(anObject: TGLBaseSceneObject);
begin
  vGLODEObjectRegister.Remove(anObject);
end;

// GetGLSceneObject
//
function GetGLSceneObject(anObjectName: String): TGLBaseSceneObject;
var
  i: Integer;
begin
  Result := nil;
  for i := 0 to vGLODEObjectRegister.Count - 1 do
    if TGLBaseSceneObject(vGLODEObjectRegister[i]).GetNamePath = anObjectName
    then
    begin
      Result := vGLODEObjectRegister[i];
      Exit;
    end;
end;

// GetOdeStatic
//
function GetOdeStatic(Obj: TGLBaseSceneObject): TGLODEStatic;
begin
  Result := TGLODEStatic(Obj.Behaviours.GetByClass(TGLODEStatic));
end;

// GetOrCreateOdeStatic
//
function GetOrCreateOdeStatic(Obj: TGLBaseSceneObject): TGLODEStatic;
begin
  Result := TGLODEStatic(Obj.GetOrCreateBehaviour(TGLODEStatic));
end;

// GetOdeDynamic
//
function GetOdeDynamic(Obj: TGLBaseSceneObject): TGLODEDynamic;
begin
  Result := TGLODEDynamic(Obj.Behaviours.GetByClass(TGLODEDynamic));
end;

// GetOrCreateOdeDynamic
//
function GetOrCreateOdeDynamic(Obj: TGLBaseSceneObject): TGLODEDynamic;
begin
  Result := TGLODEDynamic(Obj.GetOrCreateBehaviour(TGLODEDynamic));
end;

// ---------------
// --------------- TGLODEManager ---------------
// ---------------

// Create
//
constructor TGLODEManager.Create(AOwner: TComponent);
begin
  FWorld := nil;
  if not InitODE('') then
    raise Exception.Create('ODE failed to initialize.');

  inherited;

  FODEBehaviours := TPersistentObjectList.Create;
  FRFContactList := TList.Create;

  FGravity := TGLCoordinates.CreateInitialized(Self, NullHmgPoint, csVector);
  FGravity.OnNotifyChange := GravityChange;

  FSolver := osmDefault;
  FIterations := 3;
  MaxContacts := 8;

  if not(csDesigning in ComponentState) then
  begin
    FWorld := dWorldCreate;
    FSpace := dHashSpaceCreate(nil);
    dWorldSetCFM(FWorld, 1E-5);
    dWorldSetQuickStepNumIterations(FWorld, FIterations);
    FContactGroup := dJointGroupCreate(100);
  end;

  FGeomColorDynD := TGLColor.CreateInitialized(Self, clrRed,
    GeomColorChangeDynD);
  FGeomColorDynE := TGLColor.CreateInitialized(Self, clrLime,
    GeomColorChangeDynE);
  FGeomColorStat := TGLColor.CreateInitialized(Self, clrBlue,
    GeomColorChangeStat);

  RegisterManager(Self);
end;

// Destroy
//
destructor TGLODEManager.Destroy;
begin
  RenderPoint := nil;

  // Unregister everything
  while FODEBehaviours.Count > 0 do
    ODEBehaviours[0].Manager := nil;

  // Clean up everything
  FODEBehaviours.Free;
  FGravity.Free;
  FRFContactList.Free;

  if Assigned(FWorld) then
  begin
    dJointGroupEmpty(FContactGroup);
    dJointGroupDestroy(FContactGroup);
    dSpaceDestroy(FSpace);
    dWorldDestroy(FWorld);
  end;

  FGeomColorDynD.Free;
  FGeomColorDynE.Free;
  FGeomColorStat.Free;

  DeregisterManager(Self);
  inherited Destroy;
end;

// RegisterObject
//
procedure TGLODEManager.RegisterODEBehaviour(ODEBehaviour: TGLODEBehaviour);
begin
  FODEBehaviours.Add(ODEBehaviour);
end;

// UnregisterObject
//
procedure TGLODEManager.UnregisterODEBehaviour(ODEBehaviour: TGLODEBehaviour);
begin
  FODEBehaviours.Remove(ODEBehaviour);
end;

// Loaded
//
procedure TGLODEManager.Loaded;
begin
  GravityChange(Self);
end;

// SetGravity
//
procedure TGLODEManager.SetGravity(Value: TGLCoordinates);
begin
  FGravity.SetPoint(Value.DirectX, Value.DirectY, Value.DirectZ);
end;

// GravityChange
//
procedure TGLODEManager.GravityChange(Sender: TObject);
begin
  if Assigned(FWorld) then
    dWorldSetGravity(FWorld, FGravity.X, FGravity.Y, FGravity.Z);
end;

// CalculateContact
//
procedure TGLODEManager.CalcContact(Object1, Object2: TObject;
  var Contact: TdContact);
var
  Surface1, Surface2: TGLODECollisionSurface;
  Body1, Body2: PdxBody;
begin
  Surface1 := GetSurfaceFromObject(Object1);
  Surface2 := GetSurfaceFromObject(Object2);
  if not(Assigned(Surface1) and Assigned(Surface2)) then
    Exit;

  with Contact.Surface do
  begin
    // Average the involved contact information and assign it to the contact.
    // Better methods for contact calculation will be looked into in the future.
    mode := Surface1.FSurfaceParams.mode or Surface2.FSurfaceParams.mode;
    Mu := (Surface1.Mu + Surface2.Mu) * 0.5;
    Mu2 := (Surface1.Mu2 + Surface2.Mu2) * 0.5;
    Bounce := (Surface1.Bounce + Surface2.Bounce) * 0.5;
    Bounce_Vel := (Surface1.Bounce_Vel + Surface2.Bounce_Vel) * 0.5;
    soft_erp := (Surface1.SoftERP + Surface2.SoftERP) * 0.5;
    soft_cfm := (Surface1.SoftCFM + Surface2.SoftCFM) * 0.5;
    Motion1 := (Surface1.Motion1 + Surface2.Motion1) * 0.5;
    Motion2 := (Surface1.Motion2 + Surface2.Motion2) * 0.5;
    Slip1 := (Surface1.Slip1 + Surface2.Slip1) * 0.5;
    Slip2 := (Surface1.Slip2 + Surface2.Slip2) * 0.5;
  end;

  // Rolling friction
  Body1 := GetBodyFromObject(Object1);
  Body2 := GetBodyFromObject(Object2);
  if (Surface1.RollingFrictionEnabled) and Assigned(Body1) then
    FRFContactList.Add(Object1);
  if (Surface2.RollingFrictionEnabled) and Assigned(Body2) then
    FRFContactList.Add(Object2);
end;

// Collision
//
procedure TGLODEManager.Collision(g1, g2: PdxGeom);
var
  i, flags, num_contacts: Integer;
  Obj1, Obj2: Pointer;
  b1, b2: PdxBody;
  Joint: TdJointID;
  HandleCollision: Boolean;
begin
  // Check for custom collision handling event
  if Assigned(FOnCustomCollision) then
  begin
    FOnCustomCollision(g1, g2);
    Exit;
  end;

  Obj1 := dGeomGetData(g1);
  Obj2 := dGeomGetData(g2);
  b1 := dGeomGetBody(g1);
  b2 := dGeomGetBody(g2);

  // don't create contact between static objects
  if not Assigned(b1) and not Assigned(b2) then
    Exit;

  if Assigned(b1) and Assigned(b2) then
    if dAreConnected(b1, b2) = 1 then
      Exit;

  // Get the collisions
  flags := $0000FFFF and FMaxContacts;
  num_contacts := dCollide(g1, g2, flags, FContactGeoms[0],
    SizeOf(TdContactGeom));

  // Set up the initial contact info
  for i := 0 to num_contacts - 1 do
  begin
    FContacts[i].Geom := FContactGeoms[i];
  end;

  for i := 0 to num_contacts - 1 do
  begin
    HandleCollision := True;

    if Assigned(Obj1) and Assigned(Obj2) then
    begin
      // Calculate the contact based on Obj1 and Obj2 surface info
      CalcContact(Obj1, Obj2, FContacts[i]);
      if Assigned(FOnCollision) then
      begin
        // Fire the Scene level OnCollision event for last minute
        // customization to the contact before the contact joint
        // is created
        FOnCollision(Self, Obj1, Obj2, FContacts[i], HandleCollision);
      end;
      // Fire the OnCollision event for each object
      if TObject(Obj1) is TGLODEBehaviour then
        if Assigned(TGLODEBehaviour(Obj1).FOnCollision) then
          TGLODEBehaviour(Obj1).FOnCollision(Self, Obj2, FContacts[i],
            HandleCollision);
      if TObject(Obj2) is TGLODEBehaviour then
        if Assigned(TGLODEBehaviour(Obj2).FOnCollision) then
          TGLODEBehaviour(Obj2).FOnCollision(Self, Obj1, FContacts[i],
            HandleCollision);
    end
    else
    begin
      // Default surface values
      FContacts[i].Surface.Mu := 1000;
    end;
    if HandleCollision then
    begin
      // Create and assign the contact joint
      Joint := dJointCreateContact(FWorld, FContactGroup, @FContacts[i]);
      dJointAttach(Joint, b1, b2);
      // Increment the number of contact joints this step
      Inc(FNumContactJoints);
    end;
  end;
end;

// Step
//
procedure TGLODEManager.Step(deltaTime: double);
var
  i: Integer;
  vec: PdVector3;
  Body: PdxBody;
  Coeff: Single;
begin
  if not Assigned(World) then
    Exit;

  // Reset the contact joint counter
  FNumContactJoints := 0;

  // Align static elements to their GLScene parent objects
  for i := 0 to FODEBehaviours.Count - 1 do
    if ODEBehaviours[i] is TGLODEStatic then
      if ODEBehaviours[i].Initialized then
        TGLODEStatic(ODEBehaviours[i]).AlignElements;

  // Run ODE collisions and step the scene
  dSpaceCollide(FSpace, Self, nearCallBack);
  case FSolver of
    osmDefault:
      dWorldStep(FWorld, deltaTime);
    osmStepFast:
      dWorldStepFast1(FWorld, deltaTime, FIterations);
    osmQuickStep:
      dWorldQuickStep(FWorld, deltaTime);
  end;
  dJointGroupEmpty(FContactGroup);

  // Align dynamic objects to their ODE bodies
  for i := 0 to FODEBehaviours.Count - 1 do
    if ODEBehaviours[i] is TGLODEDynamic then
      if ODEBehaviours[i].Initialized then
        TGLODEDynamic(ODEBehaviours[i]).AlignObject;

  // Process rolling friction
  Coeff := 0;
  Body := nil;
  while FRFContactList.Count > 0 do
  begin
    if TObject(FRFContactList[0]) is TGLODEDynamic then
    begin
      Body := TGLODEDynamic(FRFContactList[0]).Body;
      Coeff := 1 - (TGLODEDynamic(FRFContactList[0])
        .Surface.RollingFrictionCoeff / TGLODEDynamic(FRFContactList[0])
        .Mass.Mass);
    end;
    vec := dBodyGetAngularVel(Body);
    dBodySetAngularVel(Body, vec[0] * Coeff, vec[1] * Coeff, vec[2] * Coeff);
    FRFContactList.Delete(0);
  end;
end;

// NotifyChange
//
procedure TGLODEManager.NotifyChange(Sender: TObject);
begin
  if Assigned(RenderPoint) then
    RenderPoint.StructureChanged;
end;

// SetInterations
//
procedure TGLODEManager.SetIterations(const val: Integer);
begin
  FIterations := val;
  if Assigned(FWorld) then
    dWorldSetQuickStepNumIterations(FWorld, FIterations);
end;

// SetMaxContacts
//
procedure TGLODEManager.SetMaxContacts(const Value: Integer);
begin
  if Value <> FMaxContacts then
  begin
    FMaxContacts := Value;
    SetLength(FContacts, FMaxContacts);
    SetLength(FContactGeoms, FMaxContacts);
  end;
end;

// GetODEBahaviour
//
function TGLODEManager.GetODEBehaviour(index: Integer): TGLODEBehaviour;
begin
  Result := TGLODEBehaviour(FODEBehaviours[index]);
end;

// SetRenderPoint
//
procedure TGLODEManager.SetRenderPoint(const Value: TGLRenderPoint);
begin
  if FRenderPoint <> Value then
  begin
    if Assigned(FRenderPoint) then
      FRenderPoint.UnRegisterCallBack(RenderEvent);
    FRenderPoint := Value;
    if Assigned(FRenderPoint) then
      FRenderPoint.RegisterCallBack(RenderEvent, RenderPointFreed);
  end;
end;

// RenderEvent
//
procedure TGLODEManager.RenderEvent(Sender: TObject;
  var rci: TGLRenderContextInfo);
var
  i: Integer;
begin
  if not Visible then
    Exit;
  if not(csDesigning in ComponentState) then
    if not VisibleAtRunTime then
      Exit;

  rci.GLStates.Disable(stLighting);
  rci.GLStates.Enable(stPolygonOffsetLine);
  rci.GLStates.SetPolygonOffset(1, 2);

  for i := 0 to FODEBehaviours.Count - 1 do
  begin
    if ODEBehaviours[i] is TGLODEDynamic then
      if TGLODEDynamic(ODEBehaviours[i]).GetEnabled then
        GL.Color4fv(GeomColorDynE.AsAddress)
      else
        GL.Color4fv(GeomColorDynD.AsAddress)
    else
      GL.Color4fv(GeomColorStat.AsAddress);

    ODEBehaviours[i].Render(rci);
  end;
end;

// RenderPointFreed
//
procedure TGLODEManager.RenderPointFreed(Sender: TObject);
begin
  FRenderPoint := nil;
end;

// SetVisible
//
procedure TGLODEManager.SetVisible(const Value: Boolean);
begin
  if Value <> FVisible then
  begin
    FVisible := Value;
    NotifyChange(Self);
  end;
end;

// SetVisibleAtRunTime
//
procedure TGLODEManager.SetVisibleAtRunTime(const Value: Boolean);
begin
  if Value <> FVisibleAtRunTime then
  begin
    FVisibleAtRunTime := Value;
    NotifyChange(Self);
  end;
end;

// SetGeomColorDynD
//

procedure TGLODEManager.SetGeomColorDynD(const Value: TGLColor);
begin
  FGeomColorDynD.Assign(Value);
  NotifyChange(Self);
end;

// GeomColorChangeDynD
//

procedure TGLODEManager.GeomColorChangeDynD(Sender: TObject);
begin
  NotifyChange(Self);
end;

// SetGeomColorDynE
//

procedure TGLODEManager.SetGeomColorDynE(const Value: TGLColor);
begin
  FGeomColorDynE.Assign(Value);
  NotifyChange(Self);
end;

// GeomColorChangeDynE
//

procedure TGLODEManager.GeomColorChangeDynE(Sender: TObject);
begin
  NotifyChange(Self);
end;

// SetGeomColorStat
//

procedure TGLODEManager.SetGeomColorStat(const Value: TGLColor);
begin
  FGeomColorStat.Assign(Value);
  NotifyChange(Self);
end;

// GeomColorChangeStat
//

procedure TGLODEManager.GeomColorChangeStat(Sender: TObject);
begin
  NotifyChange(Self);
end;

// ---------------
// --------------- TGLODECollisionSurface ---------------
// ---------------

// Create
//
constructor TGLODECollisionSurface.Create(AOwner: TPersistent);
begin
  inherited Create;
  FOwner := AOwner;
  Mu := 1000;
  RollingFrictionEnabled := False;
  RollingFrictionCoeff := 0.001; // Larger Coeff = more friction
end;

// GetOwner
//
function TGLODECollisionSurface.GetOwner: TPersistent;
begin
  Result := FOwner;
end;

// Assign
//
procedure TGLODECollisionSurface.Assign(Source: TPersistent);
begin
  inherited;
  if not Assigned(Source) then
    Exit;
  if Source is TGLODECollisionSurface then
  begin
    RollingFrictionCoeff := TGLODECollisionSurface(Source).RollingFrictionCoeff;
    RollingFrictionEnabled := TGLODECollisionSurface(Source)
      .RollingFrictionEnabled;
    SurfaceMode := TGLODECollisionSurface(Source).SurfaceMode;
    Mu := TGLODECollisionSurface(Source).Mu;
    Mu2 := TGLODECollisionSurface(Source).Mu2;
    Bounce := TGLODECollisionSurface(Source).Bounce;
    Bounce_Vel := TGLODECollisionSurface(Source).Bounce_Vel;
    SoftERP := TGLODECollisionSurface(Source).SoftERP;
    SoftCFM := TGLODECollisionSurface(Source).SoftCFM;
    Motion1 := TGLODECollisionSurface(Source).Motion1;
    Motion2 := TGLODECollisionSurface(Source).Motion2;
    Slip1 := TGLODECollisionSurface(Source).Slip1;
    Slip2 := TGLODECollisionSurface(Source).Slip2;
  end;
end;

// WriteToFiler
//
procedure TGLODECollisionSurface.WriteToFiler(writer: TWriter);
var
  mode: TSurfaceModes;
begin
  with writer do
  begin
    WriteInteger(0);
    WriteFloat(RollingFrictionCoeff);
    WriteBoolean(RollingFrictionEnabled);
    mode := SurfaceMode;
    Write(mode, SizeOf(TSurfaceModes));
    WriteFloat(Mu);
    WriteFloat(Mu2);
    WriteFloat(Bounce);
    WriteFloat(Bounce_Vel);
    WriteFloat(SoftERP);
    WriteFloat(SoftCFM);
    WriteFloat(Motion1);
    WriteFloat(Motion2);
    WriteFloat(Slip1);
    WriteFloat(Slip2);
  end;
end;

// ReadFromFiler
//
procedure TGLODECollisionSurface.ReadFromFiler(reader: TReader);
var
  archiveVersion: Integer;
  mode: TSurfaceModes;
begin
  with reader do
  begin
    archiveVersion := ReadInteger;
    Assert(archiveVersion = 0);
    RollingFrictionCoeff := ReadFloat;
    RollingFrictionEnabled := ReadBoolean;
    Read(mode, SizeOf(TSurfaceModes));
    SurfaceMode := mode;
    Mu := ReadFloat;
    Mu2 := ReadFloat;
    Bounce := ReadFloat;
    Bounce_Vel := ReadFloat;
    SoftERP := ReadFloat;
    SoftCFM := ReadFloat;
    Motion1 := ReadFloat;
    Motion2 := ReadFloat;
    Slip1 := ReadFloat;
    Slip2 := ReadFloat;
  end;
end;

// GetSurfaceMode
//
function TGLODECollisionSurface.GetSurfaceMode: TSurfaceModes;
var
  ASurfaceModes: TSurfaceModes;
begin
  ASurfaceModes := [];
  if (FSurfaceParams.mode and dContactSlip2) <> 0 then
    ASurfaceModes := ASurfaceModes + [csmSlip2];
  if (FSurfaceParams.mode and dContactSlip1) <> 0 then
    ASurfaceModes := ASurfaceModes + [csmSlip1];
  if (FSurfaceParams.mode and dContactMotion2) <> 0 then
    ASurfaceModes := ASurfaceModes + [csmMotion2];
  if (FSurfaceParams.mode and dContactMotion1) <> 0 then
    ASurfaceModes := ASurfaceModes + [csmMotion1];
  if (FSurfaceParams.mode and dContactSoftCFM) <> 0 then
    ASurfaceModes := ASurfaceModes + [csmSoftCFM];
  if (FSurfaceParams.mode and dContactSoftERP) <> 0 then
    ASurfaceModes := ASurfaceModes + [csmSoftERP];
  if (FSurfaceParams.mode and dContactBounce) <> 0 then
    ASurfaceModes := ASurfaceModes + [csmBounce];
  if (FSurfaceParams.mode and dContactFDir1) <> 0 then
    ASurfaceModes := ASurfaceModes + [csmFDir1];
  if (FSurfaceParams.mode and dContactMu2) <> 0 then
    ASurfaceModes := ASurfaceModes + [csmMu2];
  Result := ASurfaceModes;
end;

// SetSurfaceMode
//
procedure TGLODECollisionSurface.SetSurfaceMode(Value: TSurfaceModes);
var
  AMode: Integer;
begin
  AMode := 0;
  if csmSlip2 in Value then
    AMode := AMode or dContactSlip2;
  if csmSlip1 in Value then
    AMode := AMode or dContactSlip1;
  if csmMotion2 in Value then
    AMode := AMode or dContactMotion2;
  if csmMotion1 in Value then
    AMode := AMode or dContactMotion1;
  if csmSoftCFM in Value then
    AMode := AMode or dContactSoftCFM;
  if csmSoftERP in Value then
    AMode := AMode or dContactSoftERP;
  if csmBounce in Value then
    AMode := AMode or dContactBounce;
  if csmFDir1 in Value then
    AMode := AMode or dContactFDir1;
  if csmMu2 in Value then
    AMode := AMode or dContactMu2;
  FSurfaceParams.mode := AMode;
end;

// CollisionSurface Property methods
//
function TGLODECollisionSurface.GetMu: TdReal;
begin
  Result := FSurfaceParams.Mu;
end;

function TGLODECollisionSurface.GetMu2: TdReal;
begin
  Result := FSurfaceParams.Mu2;
end;

function TGLODECollisionSurface.GetBounce: TdReal;
begin
  Result := FSurfaceParams.Bounce;
end;

function TGLODECollisionSurface.GetBounce_Vel: TdReal;
begin
  Result := FSurfaceParams.Bounce_Vel;
end;

function TGLODECollisionSurface.GetSoftERP: TdReal;
begin
  Result := FSurfaceParams.soft_erp;
end;

function TGLODECollisionSurface.GetSoftCFM: TdReal;
begin
  Result := FSurfaceParams.soft_cfm;
end;

function TGLODECollisionSurface.GetMotion1: TdReal;
begin
  Result := FSurfaceParams.Motion1;
end;

function TGLODECollisionSurface.GetMotion2: TdReal;
begin
  Result := FSurfaceParams.Motion2;
end;

function TGLODECollisionSurface.GetSlip1: TdReal;
begin
  Result := FSurfaceParams.Slip1;
end;

function TGLODECollisionSurface.GetSlip2: TdReal;
begin
  Result := FSurfaceParams.Slip2;
end;

procedure TGLODECollisionSurface.SetMu(Value: TdReal);
begin
  FSurfaceParams.Mu := Value;
end;

procedure TGLODECollisionSurface.SetMu2(Value: TdReal);
begin
  FSurfaceParams.Mu2 := Value;
end;

procedure TGLODECollisionSurface.SetBounce(Value: TdReal);
begin
  FSurfaceParams.Bounce := Value;
end;

procedure TGLODECollisionSurface.SetBounce_Vel(Value: TdReal);
begin
  FSurfaceParams.Bounce_Vel := Value;
end;

procedure TGLODECollisionSurface.SetSoftERP(Value: TdReal);
begin
  FSurfaceParams.soft_erp := Value;
end;

procedure TGLODECollisionSurface.SetSoftCFM(Value: TdReal);
begin
  FSurfaceParams.soft_cfm := Value;
end;

procedure TGLODECollisionSurface.SetMotion1(Value: TdReal);
begin
  FSurfaceParams.Motion1 := Value;
end;

procedure TGLODECollisionSurface.SetMotion2(Value: TdReal);
begin
  FSurfaceParams.Motion2 := Value;
end;

procedure TGLODECollisionSurface.SetSlip1(Value: TdReal);
begin
  FSurfaceParams.Slip1 := Value;
end;

procedure TGLODECollisionSurface.SetSlip2(Value: TdReal);
begin
  FSurfaceParams.Slip2 := Value;
end;


// ---------------
// --------------- TODEBehaviour --------------
// ---------------

// Create
//
constructor TGLODEBehaviour.Create(AOwner: TGLXCollection);
begin
  inherited;
  FSurface := TGLODECollisionSurface.Create(Self);
  FInitialized := False;
  FOwnerBaseSceneObject := OwnerBaseSceneObject;
  if Assigned(FOwnerBaseSceneObject) then
    RegisterGLSceneObject(OwnerBaseSceneObject);
end;

// Destroy
//
destructor TGLODEBehaviour.Destroy;
begin
  if Assigned(Manager) then
    Manager := nil;
  if Assigned(FOwnerBaseSceneObject) then
    UnregisterGLSceneObject(FOwnerBaseSceneObject);
  FSurface.Free;
  inherited;
end;

// Initialize
//
procedure TGLODEBehaviour.Initialize;
begin
  FInitialized := True;
end;

// Finalize
//
procedure TGLODEBehaviour.Finalize;
begin
  FInitialized := False;
end;

// Reinitialize
//
procedure TGLODEBehaviour.Reinitialize;
begin
  if Initialized then
    Finalize;
  Initialize;
end;

// WriteToFiler
//
procedure TGLODEBehaviour.WriteToFiler(writer: TWriter);
begin
  inherited;
  with writer do
  begin
    WriteInteger(0); // Archive version
    if Assigned(FManager) then
      WriteString(FManager.GetNamePath)
    else
      WriteString('');
    Surface.WriteToFiler(writer);
  end;
end;

// ReadFromFiler
//
procedure TGLODEBehaviour.ReadFromFiler(reader: TReader);
begin
  inherited;
  with reader do
  begin
    Assert(ReadInteger = 0); // Archive version
    FManagerName := ReadString;
    Surface.ReadFromFiler(reader);
  end;
end;

// Loaded
//
procedure TGLODEBehaviour.Loaded;
var
  mng: TComponent;
begin
  inherited;
  if FManagerName <> '' then
  begin
    mng := FindManager(TGLODEManager, FManagerName);
    if Assigned(mng) then
      Manager := TGLODEManager(mng);
    FManagerName := '';
  end
end;

// Render
//
procedure TGLODEBehaviour.Render(var rci: TGLRenderContextInfo);
begin
  // virtual
end;

// NotifyChange
//
procedure TGLODEBehaviour.NotifyChange(Sender: TObject);
begin
  if Assigned(Manager) then
    Manager.NotifyChange(Self);
end;

// SetManager
//
procedure TGLODEBehaviour.SetManager(Value: TGLODEManager);
begin
  if FManager <> Value then
  begin
    if Assigned(FManager) then
    begin
      if Initialized then
        Finalize;
      FManager.UnregisterODEBehaviour(Self);
    end;
    FManager := Value;
    if Assigned(FManager) then
    begin
      if not(csDesigning in TComponent(Owner.Owner).ComponentState) then
      // mrqzzz moved here
        Initialize;
      FManager.RegisterODEBehaviour(Self);
    end;
  end;
end;

// SetSurface
//
procedure TGLODEBehaviour.SetSurface(Value: TGLODECollisionSurface);
begin
  FSurface.Assign(Value);
end;

// GetAbsoluteMatrix
//
function TGLODEBehaviour.GetAbsoluteMatrix: TMatrix;
begin
  Result := IdentityHMGMatrix;
  if Assigned(Owner.Owner) then
    if Owner.Owner is TGLBaseSceneObject then
      Result := TGLBaseSceneObject(Owner.Owner).AbsoluteMatrix;
end;


// ---------------
// --------------- TGLODEDynamic ---------------
// ---------------

// Create
//
constructor TGLODEDynamic.Create(AOwner: TGLXCollection);
begin
  inherited;
  FElements := TGLODEElements.Create(Self);
  FJointRegister := TList.Create;
  FEnabled := True;
end;

// Destroy
//
destructor TGLODEDynamic.Destroy;
begin
  FElements.Free;
  FJointRegister.Free;
  inherited;
end;

// Render
//
procedure TGLODEDynamic.Render(var rci: TGLRenderContextInfo);
var
  Mat: TMatrix;
begin
  if Assigned(Owner.Owner) then
  begin
    rci.PipelineTransformation.Push;
    Mat := TGLBaseSceneObject(Owner.Owner).AbsoluteMatrix;
    rci.PipelineTransformation.ModelMatrix := Mat;
  end;

  Elements.Render(rci);

  if Assigned(Owner.Owner) then
    rci.PipelineTransformation.Pop;
end;

// FriendlyName
//
class function TGLODEDynamic.FriendlyName: String;
begin
  Result := 'ODE Dynamic';
end;

// Initialize
//
procedure TGLODEDynamic.Initialize;
var
  i: Integer;
begin
  if (not Assigned(Manager)) or Assigned(FBody) or (FInitialized) then
    Exit;
  if not Assigned(Manager.World) then
    Exit;

  FBody := dBodyCreate(Manager.World);
  AlignBodyToMatrix(OwnerBaseSceneObject.AbsoluteMatrix);
  dMassSetZero(FMass);
  FElements.Initialize;
  CalculateMass;
  CalibrateCenterOfMass;
  if (FMass.Mass > 0) and (FBody <> nil) then // mrqzzz
    dBodySetMass(FBody, @FMass);
  Enabled := FEnabled;

  for i := 0 to FJointRegister.Count - 1 do
    TGLODEJointBase(FJointRegister[i]).Attach;

  inherited;
end;

// Finalize
//
procedure TGLODEDynamic.Finalize;
var
  i: Integer;
begin
  if not FInitialized then
    Exit;
  FElements.Finalize;
  if Assigned(FBody) then
  begin
    dBodyDestroy(FBody);
    FBody := nil;
  end;
  dMassSetZero(FMass);
  for i := 0 to FJointRegister.Count - 1 do
    TGLODEJointBase(FJointRegister[i]).Attach;
  inherited;
end;

// WriteToFiler
//
procedure TGLODEDynamic.WriteToFiler(writer: TWriter);
begin
  inherited;
  with writer do
  begin
    WriteInteger(1); // Archive version
    FElements.WriteToFiler(writer);
    writer.WriteBoolean(FEnabled);
  end;
end;

// ReadFromFiler
//
procedure TGLODEDynamic.ReadFromFiler(reader: TReader);
var
  archiveVersion: Integer;
begin
  inherited;
  with reader do
  begin
    archiveVersion := ReadInteger;
    Assert((archiveVersion >= 0) and (archiveVersion <= 1)); // Archive version

    // version 0
    FElements.ReadFromFiler(reader);

    // version 1
    if archiveVersion >= 1 then
    begin
      FEnabled := ReadBoolean;
    end;
  end;
end;

// RegisterJoint
//
procedure TGLODEDynamic.RegisterJoint(Joint: TGLODEJointBase);
begin
  if FJointRegister.IndexOf(Joint) = -1 then
    FJointRegister.Add(Joint);
end;

// UnregisterJoint
//
procedure TGLODEDynamic.UnregisterJoint(Joint: TGLODEJointBase);
begin
  if FJointRegister.IndexOf(Joint) > -1 then
    FJointRegister.Remove(Joint);
end;

// AddNewElement
//
function TGLODEDynamic.AddNewElement(AChild: TGLODEElementClass): TGLODEElementBase;
var
  calcmass: TdMass;
begin
  Result := AChild.Create(FElements);
  // FElements.Add(Result);
  Result.Initialize;
  calcmass := CalculateMass;
  if (calcmass.Mass > 0) and (FBody <> nil) then // mrqzzz
    dBodySetMass(FBody, @calcmass);
end;

// AlignObject
//
procedure TGLODEDynamic.AlignObject;
var
  Pos: PdVector3;
  R: PdMatrix3;
  m: TMatrix;
begin
  Pos := dBodyGetPosition(Body);
  R := dBodyGetRotation(Body);
  ODEGL.ODERToGLSceneMatrix(m, R^, Pos^);
  if OwnerBaseSceneObject.Parent is TGLBaseSceneObject then
    m := MatrixMultiply(m, OwnerBaseSceneObject.Parent.InvAbsoluteMatrix);
  OwnerBaseSceneObject.Matrix := m;
end;

// AlignBodyToMatrix
//
procedure TGLODEDynamic.AlignBodyToMatrix(Mat: TMatrix);
var
  R: TdMatrix3;
begin
  if not Assigned(FBody) then
    Exit;
  R[0] := Mat.V[0].V[0];
  R[1] := Mat.V[1].V[0];
  R[2] := Mat.V[2].V[0];
  R[3] := 0;
  R[4] := Mat.V[0].V[1];
  R[5] := Mat.V[1].V[1];
  R[6] := Mat.V[2].V[1];
  R[7] := 0;
  R[8] := Mat.V[0].V[2];
  R[9] := Mat.V[1].V[2];
  R[10] := Mat.V[2].V[2];
  R[11] := 0;
  dBodySetRotation(FBody, R);
  dBodySetPosition(FBody, Mat.V[3].V[0], Mat.V[3].V[1], Mat.V[3].V[2]);
end;

// CalculateMass
//
function TGLODEDynamic.CalculateMass: TdMass;
var
  i: Integer;
  m: TdMass;
begin
  dMassSetZero(FMass);
  for i := 0 to Elements.Count - 1 do
  begin
    m := TGLODEElementBase(Elements[i]).CalculateMass;
    dMassAdd(FMass, m);
  end;
  Result := FMass;
end;

// CalibrateCenterOfMass
//
procedure TGLODEDynamic.CalibrateCenterOfMass;
var
  Pos: TAffineVector;
begin
  SetAffineVector(Pos, FMass.c[0], FMass.c[1], FMass.c[2]);
  NegateVector(Pos);
  dMassTranslate(FMass, Pos.V[0], Pos.V[1], Pos.V[2]);
end;

// GetMass
//
function TGLODEDynamic.GetMass: TdMass;
begin
  dBodyGetMass(FBody, FMass);
  Result := FMass;
end;

// SetMass
//
procedure TGLODEDynamic.SetMass(const Value: TdMass);
begin
  FMass := Value;
  if FMass.Mass > 0 then
    dBodySetMass(FBody, @FMass);
end;

// UniqueItem
//
class function TGLODEDynamic.UniqueItem: Boolean;
begin
  Result := True;
end;

// SetEnabled
//
procedure TGLODEDynamic.SetEnabled(const Value: Boolean);
begin
  FEnabled := Value;
  if Assigned(FBody) then
  begin
    if FEnabled then
      dBodyEnable(FBody)
    else
      dBodyDisable(FBody);
  end;
end;

// GetEnabled
//
function TGLODEDynamic.GetEnabled: Boolean;
begin
  if Assigned(FBody) then
    FEnabled := (dBodyIsEnabled(FBody) = 1);
  Result := FEnabled;
end;

// AddForce
//
procedure TGLODEDynamic.AddForce(Force: TAffineVector);
begin
  if Assigned(FBody) then
    dBodyAddForce(FBody, Force.V[0], Force.V[1], Force.V[2]);
end;

// AddlForceAtPos
//
procedure TGLODEDynamic.AddForceAtPos(Force, Pos: TAffineVector);
begin
  if Assigned(FBody) then
    dBodyAddForceAtPos(FBody, Force.V[0], Force.V[1], Force.V[2], Pos.V[0],
      Pos.V[1], Pos.V[2]);
end;

// AddForceAtRelPos
//
procedure TGLODEDynamic.AddForceAtRelPos(Force, Pos: TAffineVector);
begin
  if Assigned(FBody) then
    dBodyAddForceAtRelPos(FBody, Force.V[0], Force.V[1], Force.V[2], Pos.V[0],
      Pos.V[1], Pos.V[2]);
end;

// AddRelForce
//
procedure TGLODEDynamic.AddRelForce(Force: TAffineVector);
begin
  if Assigned(FBody) then
    dBodyAddRelForce(FBody, Force.V[0], Force.V[1], Force.V[2]);
end;

// AddRelForceAtPos
//
procedure TGLODEDynamic.AddRelForceAtPos(Force, Pos: TAffineVector);
begin
  if Assigned(FBody) then
    dBodyAddForceAtPos(FBody, Force.V[0], Force.V[1], Force.V[2], Pos.V[0],
      Pos.V[1], Pos.V[2]);
end;

// AddRelForceAtRelPos
//
procedure TGLODEDynamic.AddRelForceAtRelPos(Force, Pos: TAffineVector);
begin
  if Assigned(FBody) then
    dBodyAddRelForceAtRelPos(FBody, Force.V[0], Force.V[1], Force.V[2],
      Pos.V[0], Pos.V[1], Pos.V[2]);
end;

// AddTorque
//
procedure TGLODEDynamic.AddTorque(Torque: TAffineVector);
begin
  if Assigned(FBody) then
    dBodyAddTorque(FBody, Torque.V[0], Torque.V[1], Torque.V[2]);
end;

// AddRelTorque
//
procedure TGLODEDynamic.AddRelTorque(Torque: TAffineVector);
begin
  if Assigned(FBody) then
    dBodyAddRelTorque(FBody, Torque.V[0], Torque.V[1], Torque.V[2]);
end;


// ---------------
// --------------- TGLODEStatic ---------------
// ---------------

// Create
//
constructor TGLODEStatic.Create(AOwner: TGLXCollection);
begin
  inherited;
  FElements := TGLODEElements.Create(Self);
end;

// Destroy
//
destructor TGLODEStatic.Destroy;
begin
  FElements.Free;
  inherited;
end;

// Render
//
procedure TGLODEStatic.Render(var rci: TGLRenderContextInfo);
var
  Mat: TMatrix;
begin
  if Assigned(Owner.Owner) then
  begin
    rci.PipelineTransformation.Push;
    Mat := TGLBaseSceneObject(Owner.Owner).AbsoluteMatrix;
    rci.PipelineTransformation.ModelMatrix := Mat;
  end;

  Elements.Render(rci);

  if Assigned(Owner.Owner) then
    rci.PipelineTransformation.Pop;
end;

// FriendlyName
//
class function TGLODEStatic.FriendlyName: String;
begin
  Result := 'ODE Static';
end;

// UniqueItem
//
class function TGLODEStatic.UniqueItem: Boolean;
begin
  Result := True;
end;

// Initialize
//
procedure TGLODEStatic.Initialize;
begin
  if (not Assigned(Manager)) or (FInitialized) then
    Exit;
  if not Assigned(Manager.Space) then
    Exit;

  FElements.Initialize;

  inherited;
end;

// Finalize
//
procedure TGLODEStatic.Finalize;
begin
  if not FInitialized then
    Exit;
  FElements.Finalize;

  inherited;
end;

// WriteToFiler
//
procedure TGLODEStatic.WriteToFiler(writer: TWriter);
begin
  inherited;
  with writer do
  begin
    WriteInteger(0); // Archive version
    FElements.WriteToFiler(writer);
  end;
end;

// ReadFromFiler
//
procedure TGLODEStatic.ReadFromFiler(reader: TReader);
begin
  inherited;
  with reader do
  begin
    Assert(ReadInteger = 0); // Archive version
    FElements.ReadFromFiler(reader);
  end;
end;

// AddNewElement
//
function TGLODEStatic.AddNewElement(AChild: TGLODEElementClass): TGLODEElementBase;
begin
  Result := nil;
  if not Assigned(Manager) then
    Exit;
  Result := AChild.Create(FElements);
  FElements.Add(Result);
  Result.Initialize;
end;

// AlignElements
//
procedure TGLODEStatic.AlignElements;
var
  i: Integer;
begin
  if not FInitialized then
    Exit;

  for i := 0 to FElements.Count - 1 do
    TGLODEElementBase(FElements[i]).AlignGeomElementToMatrix
      (TGLODEElementBase(FElements[i]).AbsoluteMatrix);
end;


// ---------------
// --------------- TODEElements ---------------
// ---------------

// Destroy
//
destructor TGLODEElements.Destroy;
begin
  Finalize;
  inherited;
end;

// GetElement
//
function TGLODEElements.GetElement(index: Integer): TGLODEElementBase;
begin
  Result := TGLODEElementBase(Items[index]);
end;

// ItemsClass
//
class function TGLODEElements.ItemsClass: TGLXCollectionItemClass;
begin
  Result := TGLODEElementBase;
end;

// Initialize
//
procedure TGLODEElements.Initialize;
var
  i: Integer;
begin
  for i := 0 to Count - 1 do
    TGLODEElementBase(Items[i]).Initialize;
end;

// Deintialize
//
procedure TGLODEElements.Finalize;
var
  i: Integer;
begin
  for i := 0 to Count - 1 do
    TGLODEElementBase(Items[i]).Finalize;
end;

// Render
//
procedure TGLODEElements.Render(var rci: TGLRenderContextInfo);
var
  i: Integer;
begin
  for i := 0 to Count - 1 do
    TGLODEElementBase(Items[i]).Render(rci);
end;

// NotifyChange
//
procedure TGLODEElements.NotifyChange(Sender: TObject);
begin
  if Assigned(Owner) then
    if Owner is TGLODEBehaviour then
      TGLODEBehaviour(Owner).NotifyChange(Self);
end;


// ---------------
// --------------- TODEElementBase ---------------
// ---------------

// Create
//
constructor TGLODEElementBase.Create(AOwner: TGLXCollection);
begin
  inherited;
  FPosition := TGLCoordinates.CreateInitialized(Self, NullHmgPoint, csPoint);
  FPosition.OnNotifyChange := NotifyChange;
  FDirection := TGLCoordinates.CreateInitialized(Self, ZHmgVector, csVector);
  FDirection.OnNotifyChange := CoordinateChanged;
  FUp := TGLCoordinates.CreateInitialized(Self, YHmgVector, csVector);
  FUp.OnNotifyChange := CoordinateChanged;
  FDensity := 1;
  FInitialized := False;
  FDynamic := (Owner.Owner is TGLODEDynamic);
  FLocalMatrix := IdentityHMGMatrix;
  FIsCalculating := False;
end;

// Destroy
//
destructor TGLODEElementBase.Destroy;
begin
  if FInitialized then
    Finalize;
  FPosition.Free;
  FDirection.Free;
  FUp.Free;
  inherited;
end;

// Render
//
procedure TGLODEElementBase.Render(var rci: TGLRenderContextInfo);
begin
  // Override this procedure with element drawing OpenGL code
end;

// Initialize
//
procedure TGLODEElementBase.Initialize;
var
  Manager: TGLODEManager;
  Body: PdxBody;
begin
  Manager := nil;
  Body := nil;

  if Owner.Owner is TGLODEBehaviour then
    Manager := TGLODEBehaviour(Owner.Owner).Manager;
  if not Assigned(Manager) then
    Exit;

  if FDynamic then
  begin
    if Owner.Owner is TGLODEDynamic then
      Body := TGLODEDynamic(Owner.Owner).Body;
    if not Assigned(Body) then
      Exit;
  end;

  if not Assigned(Manager.World) then
    Exit;

  if FDynamic then
  begin
    FGeomTransform := dCreateGeomTransform(Manager.Space);
    dGeomSetBody(FGeomTransform, Body);
    dGeomTransformSetCleanup(FGeomTransform, 0);
    dGeomTransformSetGeom(FGeomTransform, FGeomElement);
    dGeomSetData(FGeomTransform, Owner.Owner);
    AlignGeomElementToMatrix(FLocalMatrix);
  end
  else
  begin
    dSpaceAdd(Manager.Space, FGeomElement);
    dGeomSetData(FGeomElement, Owner.Owner);
    AlignGeomElementToMatrix(AbsoluteMatrix);
  end;

  FInitialized := True;
end;

// Finalize
//
procedure TGLODEElementBase.Finalize;
begin
  if not FInitialized then
    Exit;
  if Assigned(FGeomTransform) then
  begin
    dGeomDestroy(FGeomTransform);
    FGeomTransform := nil;
  end;
  if Assigned(FGeomElement) then
  begin
    dGeomDestroy(FGeomElement);
    FGeomElement := nil;
  end;
  FInitialized := False;
end;

// WriteToFiler
//
procedure TGLODEElementBase.WriteToFiler(writer: TWriter);
begin
  inherited;
  with writer do
  begin
    WriteInteger(0); // Archive version
    FPosition.WriteToFiler(writer);
    FDirection.WriteToFiler(writer);
    FUp.WriteToFiler(writer);
    WriteFloat(Density);
  end;
end;

// ReadFromFiler
//
procedure TGLODEElementBase.ReadFromFiler(reader: TReader);
begin
  inherited;
  with reader do
  begin
    Assert(ReadInteger = 0); // Archive version
    FPosition.ReadFromFiler(reader);
    FDirection.ReadFromFiler(reader);
    FUp.ReadFromFiler(reader);
    Density := ReadFloat;
  end;
  NotifyChange(Self);
end;

// AbsoluteMatrix
//
function TGLODEElementBase.AbsoluteMatrix: TMatrix;
var
  Mat: TMatrix;
begin
  Mat := IdentityHMGMatrix;
  if Owner.Owner is TGLODEBehaviour then
    Mat := TGLODEBehaviour(Owner.Owner).AbsoluteMatrix;
  Result := MatrixMultiply(Mat, FLocalMatrix);
end;

// AbsolutePosition
//
function TGLODEElementBase.AbsolutePosition: TAffineVector;
begin
  Result := AffineVectorMake(AbsoluteMatrix.V[3]);
end;

// AlignGeomElementToMatrix
//
procedure TGLODEElementBase.AlignGeomElementToMatrix(Mat: TMatrix);
var
  R: TdMatrix3;
begin
  if not Assigned(FGeomElement) then
    Exit;
  dGeomSetPosition(FGeomElement, Mat.V[3].V[0], Mat.V[3].V[1], Mat.V[3].V[2]);
  R[0] := Mat.V[0].V[0];
  R[1] := Mat.V[1].V[0];
  R[2] := Mat.V[2].V[0];
  R[3] := 0;
  R[4] := Mat.V[0].V[1];
  R[5] := Mat.V[1].V[1];
  R[6] := Mat.V[2].V[1];
  R[7] := 0;
  R[8] := Mat.V[0].V[2];
  R[9] := Mat.V[1].V[2];
  R[10] := Mat.V[2].V[2];
  R[11] := 0;
  dGeomSetRotation(FGeomElement, R);
  FRealignODE := False;
end;

// SetGeomElement
//
procedure TGLODEElementBase.SetGeomElement(aGeom: PdxGeom);
begin
  FGeomElement := aGeom;
end;

// IsODEInitialized
//
function TGLODEElementBase.IsODEInitialized: Boolean;
var
  Manager: TGLODEManager;
begin
  Result := False;
  Manager := nil;
  if Owner.Owner is TGLODEBehaviour then
    Manager := TGLODEBehaviour(Owner.Owner).Manager;
  if not Assigned(Manager) then
    Exit;
  Result := Assigned(Manager.Space);
end;

// CalculateMass
//
function TGLODEElementBase.CalculateMass: TdMass;
var
  R: TdMatrix3;
begin
  R[0] := FLocalMatrix.V[0].V[0];
  R[1] := FLocalMatrix.V[1].V[0];
  R[2] := FLocalMatrix.V[2].V[0];
  R[3] := 0;
  R[4] := FLocalMatrix.V[0].V[1];
  R[5] := FLocalMatrix.V[1].V[1];
  R[6] := FLocalMatrix.V[2].V[1];
  R[7] := 0;
  R[8] := FLocalMatrix.V[0].V[2];
  R[9] := FLocalMatrix.V[1].V[2];
  R[10] := FLocalMatrix.V[2].V[2];
  R[11] := 0;
  dMassRotate(FMass, R);
  dMassTranslate(FMass, FLocalMatrix.V[3].V[0], FLocalMatrix.V[3].V[1],
    FLocalMatrix.V[3].V[2]);
  Result := FMass;
end;

// CoordinateChanged
//
procedure TGLODEElementBase.CoordinateChanged(Sender: TObject);
var
  rightVector: TVector;
begin
  if FIsCalculating then
    Exit;
  FIsCalculating := True;
  try
    if Sender = FDirection then
    begin
      if FDirection.VectorLength = 0 then
        FDirection.DirectVector := ZHmgVector;
      FDirection.Normalize;
      rightVector := VectorCrossProduct(FDirection.AsVector, FUp.AsVector);
      if VectorLength(rightVector) < 1E-5 then
      begin
        rightVector := VectorCrossProduct(ZHmgVector, FUp.AsVector);
        if VectorLength(rightVector) < 1E-5 then
          rightVector := VectorCrossProduct(XHmgVector, FUp.AsVector);
      end;
      FUp.DirectVector := VectorCrossProduct(rightVector, FDirection.AsVector);
      FUp.Normalize;

    end
    else if Sender = FUp then
    begin
      if FUp.VectorLength = 0 then
        FUp.DirectVector := YHmgVector;
      FUp.Normalize;
      rightVector := VectorCrossProduct(FDirection.AsVector, FUp.AsVector);
      if VectorLength(rightVector) < 1E-5 then
      begin
        rightVector := VectorCrossProduct(ZHmgVector, FUp.AsVector);
        if VectorLength(rightVector) < 1E-5 then
          rightVector := VectorCrossProduct(XHmgVector, FUp.AsVector);
      end;
      FDirection.DirectVector := VectorCrossProduct(FUp.AsVector, rightVector);
      FDirection.Normalize;
    end;
    NotifyChange(Self);
  finally
    FIsCalculating := False;
  end;
end;

// NotifyChange
//
procedure TGLODEElementBase.NotifyChange(Sender: TObject);
begin
  RebuildMatrix;
  ODERebuild;
end;

// GetMatrix
//
function TGLODEElementBase.GetMatrix: TMatrix;
begin
  Result := FLocalMatrix;
end;

// RebuildMatrix
//
procedure TGLODEElementBase.RebuildMatrix;
begin
  VectorCrossProduct(FUp.AsVector, FDirection.AsVector, FLocalMatrix.V[0]);
  SetVector(FLocalMatrix.V[1], FUp.AsVector);
  SetVector(FLocalMatrix.V[2], FDirection.AsVector);
  SetVector(FLocalMatrix.V[3], FPosition.AsVector);
end;

// RebuildVectors
//
procedure TGLODEElementBase.RebuildVectors;
begin
  FUp.SetVector(FLocalMatrix.V[1].V[0], FLocalMatrix.V[1].V[1],
    FLocalMatrix.V[1].V[2]);
  FDirection.SetVector(FLocalMatrix.V[2].V[0], FLocalMatrix.V[2].V[1],
    FLocalMatrix.V[2].V[2]);
  FPosition.SetPoint(FLocalMatrix.V[3].V[0], FLocalMatrix.V[3].V[1],
    FLocalMatrix.V[3].V[2]);
end;

// SetDensity
//
procedure TGLODEElementBase.SetDensity(const Value: TdReal);
begin
  FDensity := Value;
end;

// SetMatrix
//
procedure TGLODEElementBase.SetMatrix(const Value: TMatrix);
begin
  FLocalMatrix := Value;
  RebuildVectors;
  ODERebuild;
end;

// ODERebuild
//
procedure TGLODEElementBase.ODERebuild;
begin
  if Initialized then
  begin
    if FDynamic then
    begin
      CalculateMass;
      AlignGeomElementToMatrix(FLocalMatrix);
    end
    else
      AlignGeomElementToMatrix(AbsoluteMatrix);
  end;
  if Assigned(Owner) then
    TGLODEElements(Owner).NotifyChange(Self);
end;

// SetPosition
//
procedure TGLODEElementBase.SetPosition(const Value: TGLCoordinates);
begin
  FPosition.Assign(Value);
end;

// SetDirection
//
procedure TGLODEElementBase.SetDirection(const Value: TGLCoordinates);
begin
  FDirection.Assign(Value);
end;

// SetUp
//
procedure TGLODEElementBase.SetUp(const Value: TGLCoordinates);
begin
  FUp.Assign(Value);
end;


// ---------------
// --------------- TODEElementBox ---------------
// ---------------

// BuildList
//
procedure TODEElementBox.Render(var rci: TGLRenderContextInfo);
begin
  GL.PushMatrix;

  GL.MultMatrixf(@FLocalMatrix);

  GL.Begin_(GL_LINE_LOOP);
  GL.Vertex3f(-FBoxWidth / 2, -FBoxHeight / 2, -FBoxDepth / 2);
  GL.Vertex3f(-FBoxWidth / 2, FBoxHeight / 2, -FBoxDepth / 2);
  GL.Vertex3f(-FBoxWidth / 2, FBoxHeight / 2, FBoxDepth / 2);
  GL.Vertex3f(-FBoxWidth / 2, -FBoxHeight / 2, FBoxDepth / 2);
  GL.End_;

  GL.Begin_(GL_LINE_LOOP);
  GL.Vertex3f(FBoxWidth / 2, FBoxHeight / 2, FBoxDepth / 2);
  GL.Vertex3f(FBoxWidth / 2, -FBoxHeight / 2, FBoxDepth / 2);
  GL.Vertex3f(FBoxWidth / 2, -FBoxHeight / 2, -FBoxDepth / 2);
  GL.Vertex3f(FBoxWidth / 2, FBoxHeight / 2, -FBoxDepth / 2);
  GL.End_;

  GL.Begin_(GL_LINES);
  GL.Vertex3f(-FBoxWidth / 2, FBoxHeight / 2, -FBoxDepth / 2);
  GL.Vertex3f(FBoxWidth / 2, FBoxHeight / 2, -FBoxDepth / 2);
  GL.Vertex3f(-FBoxWidth / 2, -FBoxHeight / 2, FBoxDepth / 2);
  GL.Vertex3f(FBoxWidth / 2, -FBoxHeight / 2, FBoxDepth / 2);
  GL.Vertex3f(-FBoxWidth / 2, -FBoxHeight / 2, -FBoxDepth / 2);
  GL.Vertex3f(FBoxWidth / 2, -FBoxHeight / 2, -FBoxDepth / 2);
  GL.Vertex3f(-FBoxWidth / 2, FBoxHeight / 2, FBoxDepth / 2);
  GL.Vertex3f(FBoxWidth / 2, FBoxHeight / 2, FBoxDepth / 2);
  GL.End_;

  GL.PopMatrix;
end;

// Create
//
constructor TODEElementBox.Create(AOwner: TGLXCollection);
begin
  inherited;
  BoxWidth := 1;
  BoxHeight := 1;
  BoxDepth := 1;
end;

// Initialize
//
procedure TODEElementBox.Initialize;
begin
  if FInitialized then
    Exit;
  if not IsODEInitialized then
    Exit;

  FGeomElement := dCreateBox(nil, FBoxWidth, FBoxHeight, FBoxDepth);
  inherited;
end;

// WriteToFiler
//
procedure TODEElementBox.WriteToFiler(writer: TWriter);
begin
  inherited;
  with writer do
  begin
    WriteInteger(0); // Archive version
    WriteFloat(BoxWidth);
    WriteFloat(BoxHeight);
    WriteFloat(BoxDepth);
  end;
end;

// ReadFromFiler
//
procedure TODEElementBox.ReadFromFiler(reader: TReader);
begin
  inherited;
  with reader do
  begin
    Assert(ReadInteger = 0); // Archive version
    BoxWidth := ReadFloat;
    BoxHeight := ReadFloat;
    BoxDepth := ReadFloat;
  end;
end;

// FriendlyName
//
class function TODEElementBox.FriendlyName: String;
begin
  Result := 'Box';
end;

// FriendlyDescription
//
class function TODEElementBox.FriendlyDescription: String;
begin
  Result := 'The ODE box element implementation';
end;

// ItemCategory
//
class function TODEElementBox.ItemCategory: String;
begin
  Result := 'Primitives';
end;

// CalculateMass
//
function TODEElementBox.CalculateMass: TdMass;
begin
  dMassSetBox(FMass, FDensity, BoxWidth, BoxHeight, BoxDepth);
  Result := inherited CalculateMass;
end;

// GetBoxWidth
//
function TODEElementBox.GetBoxWidth: TdReal;
var
  vec: TdVector3;
begin
  if Assigned(FGeomTransform) then
  begin
    dGeomBoxGetLengths(Geom, vec);
    FBoxWidth := vec[0];
  end;
  Result := FBoxWidth;
end;

// GetBoxHeight
//
function TODEElementBox.GetBoxHeight: TdReal;
var
  vec: TdVector3;
begin
  if Assigned(FGeomTransform) then
  begin
    dGeomBoxGetLengths(Geom, vec);
    FBoxHeight := vec[1];
  end;
  Result := FBoxHeight;
end;

// GetBoxDepth
//
function TODEElementBox.GetBoxDepth: TdReal;
var
  vec: TdVector3;
begin
  if Assigned(FGeomTransform) then
  begin
    dGeomBoxGetLengths(Geom, vec);
    FBoxDepth := vec[2];
  end;
  Result := FBoxDepth;
end;

// ODERebuild
//
procedure TODEElementBox.ODERebuild;
begin
  if Assigned(Geom) then
    dGeomBoxSetLengths(Geom, FBoxWidth, FBoxHeight, FBoxDepth);
  inherited;
end;

// SetBoxWidth
//
procedure TODEElementBox.SetBoxWidth(const Value: TdReal);
begin
  FBoxWidth := Value;
  ODERebuild;
end;

// SetBoxHeight
//
procedure TODEElementBox.SetBoxHeight(const Value: TdReal);
begin
  FBoxHeight := Value;
  ODERebuild;
end;

// SetBoxDepth
//
procedure TODEElementBox.SetBoxDepth(const Value: TdReal);
begin
  FBoxDepth := Value;
  ODERebuild;
end;


// ---------------
// --------------- TODEElementSphere ---------------
// ---------------

// Render
//
procedure TODEElementSphere.Render(var rci: TGLRenderContextInfo);
var
  AngTop, AngBottom, AngStart, AngStop, StepV, StepH: double;
  SinP, CosP, SinP2, CosP2, SinT, CosT, Phi, Phi2, Theta: double;
  FTop, FBottom, FStart, FStop: Single;
  i, J, FSlices, FStacks: Integer;
begin
  GL.PushMatrix;

  GL.MultMatrixf(@FLocalMatrix);
  GL.Scalef(Radius, Radius, Radius);

  FTop := 90;
  FBottom := -90;
  FStart := 0;
  FStop := 360;
  FSlices := 16;
  FStacks := 16;

  AngTop := DegToRad(FTop);
  AngBottom := DegToRad(FBottom);
  AngStart := DegToRad(FStart);
  AngStop := DegToRad(FStop);
  StepH := (AngStop - AngStart) / FSlices;
  StepV := (AngTop - AngBottom) / FStacks;

  Phi := AngTop;
  Phi2 := Phi - StepV;
  for J := 0 to FStacks - 1 do
  begin
    Theta := AngStart;
    SinCos(Phi, SinP, CosP);
    SinCos(Phi2, SinP2, CosP2);

    GL.Begin_(GL_LINE_LOOP);
    for i := 0 to FSlices do
    begin
      SinCos(Theta, SinT, CosT);
      GL.Vertex3f(CosP * SinT, SinP, CosP * CosT);
      Theta := Theta + StepH;
    end;
    GL.End_;
    Phi := Phi2;
    Phi2 := Phi2 - StepV;
  end;

  Phi := AngTop;
  Phi2 := Phi - StepV;
  for J := 0 to FStacks - 1 do
  begin
    Theta := AngStart;
    SinCos(Phi, SinP, CosP);
    SinCos(Phi2, SinP2, CosP2);

    GL.Begin_(GL_LINE_LOOP);
    for i := 0 to FSlices do
    begin
      SinCos(Theta, SinT, CosT);
      GL.Vertex3f(SinP, CosP * SinT, CosP * CosT);
      Theta := Theta + StepH;
    end;
    GL.End_;
    Phi := Phi2;
    Phi2 := Phi2 - StepV;
  end;

  GL.PopMatrix;
end;

// Create
//
constructor TODEElementSphere.Create(AOwner: TGLXCollection);
begin
  inherited;
  FRadius := 0.5;
end;

// Initialize
//
procedure TODEElementSphere.Initialize;
begin
  if FInitialized then
    Exit;
  if not IsODEInitialized then
    Exit;

  FGeomElement := dCreateSphere(nil, FRadius);
  inherited;
end;

// WriteToFiler
//
procedure TODEElementSphere.WriteToFiler(writer: TWriter);
begin
  inherited;
  with writer do
  begin
    WriteInteger(0); // Archive version
    WriteFloat(Radius);
  end;
end;

// ReadFromFiler
//
procedure TODEElementSphere.ReadFromFiler(reader: TReader);
begin
  inherited;
  with reader do
  begin
    Assert(ReadInteger = 0); // Archive version
    Radius := ReadFloat;
  end;
end;

// FriendlyName
//
class function TODEElementSphere.FriendlyName: String;
begin
  Result := 'Sphere';
end;

// FriendlyDescription
//
class function TODEElementSphere.FriendlyDescription: String;
begin
  Result := 'The ODE sphere element implementation';
end;

// ItemCategory
//
class function TODEElementSphere.ItemCategory: String;
begin
  Result := 'Primitives';
end;

// CalculateMass
//
function TODEElementSphere.CalculateMass: TdMass;
begin
  dMassSetSphere(FMass, FDensity, Radius);
  Result := inherited CalculateMass;
end;

// GetRadius
//
function TODEElementSphere.GetRadius: TdReal;
begin
  if Assigned(FGeomElement) then
    FRadius := dGeomSphereGetRadius(FGeomElement);
  Result := FRadius;
end;

// ODERebuild
//
procedure TODEElementSphere.ODERebuild;
begin
  if Assigned(Geom) then
  begin
    dGeomSphereSetRadius(Geom, FRadius);
  end;
  inherited;
end;

// SetRadius
//
procedure TODEElementSphere.SetRadius(const Value: TdReal);
begin
  FRadius := Value;
  ODERebuild;
end;


// ---------------
// --------------- TODEElementCapsule ---------------
// ---------------

// Render
//
procedure TODEElementCapsule.Render(var rci: TGLRenderContextInfo);
var
  i, J, Stacks, Slices: Integer;
begin
  GL.PushMatrix;

  GL.MultMatrixf(@FLocalMatrix);

  Stacks := 8;
  Slices := 16;

  // Middle horizontal circles
  for J := 0 to Stacks - 1 do
  begin
    GL.Begin_(GL_LINE_LOOP);
    for i := 0 to Slices - 1 do
      GL.Vertex3f(FRadius * sin(2 * i * PI / Slices),
        FRadius * cos(2 * i * PI / Slices), -FLength / 2 + FLength * J /
        (Stacks - 1));
    GL.End_;
  end;

  // Middle vertical lines
  GL.Begin_(GL_LINES);
  for i := 0 to (Slices div 2) - 1 do
  begin
    GL.Vertex3f(FRadius * sin(2 * i * PI / Slices),
      FRadius * cos(2 * i * PI / Slices), -FLength / 2);
    GL.Vertex3f(FRadius * sin(2 * i * PI / Slices),
      FRadius * cos(2 * i * PI / Slices), FLength / 2);
    GL.Vertex3f(-FRadius * sin(2 * i * PI / Slices),
      -FRadius * cos(2 * i * PI / Slices), -FLength / 2);
    GL.Vertex3f(-FRadius * sin(2 * i * PI / Slices),
      -FRadius * cos(2 * i * PI / Slices), FLength / 2);
  end;
  GL.End_;

  // Cap XZ half-circles
  GL.PushMatrix;
  for J := 0 to (Slices div 2) - 1 do
  begin
    // Top
    GL.Begin_(GL_LINE_STRIP);
    for i := 0 to Slices do
      GL.Vertex3f(FRadius * cos(i * PI / Slices), 0,
        FRadius * sin(i * PI / Slices) + FLength / 2);
    GL.End_;

    // Bottom
    GL.Begin_(GL_LINE_STRIP);
    for i := 0 to Slices do
      GL.Vertex3f(FRadius * cos(i * PI / Slices), 0,
        -(FRadius * sin(i * PI / Slices) + FLength / 2));
    GL.End_;
    GL.Rotatef(360 / Slices, 0, 0, 1);
  end;
  GL.PopMatrix;
  GL.PopMatrix;
end;

// Create
//
constructor TODEElementCapsule.Create(AOwner: TGLXCollection);
begin
  inherited;
  FRadius := 0.5;
  FLength := 1;
end;

// Initialize
//
procedure TODEElementCapsule.Initialize;
begin
  if FInitialized then
    Exit;
  if not IsODEInitialized then
    Exit;

  FGeomElement := dCreateCapsule(nil, FRadius, FLength);
  inherited;
end;

// WriteToFiler
//
procedure TODEElementCapsule.WriteToFiler(writer: TWriter);
begin
  inherited;
  with writer do
  begin
    WriteInteger(0); // Archive version
    WriteFloat(Radius);
    WriteFloat(Length);
  end;
end;

// ReadFromFiler
//
procedure TODEElementCapsule.ReadFromFiler(reader: TReader);
begin
  inherited;
  with reader do
  begin
    Assert(ReadInteger = 0); // Archive version
    Radius := ReadFloat;
    Length := ReadFloat;
  end;
end;

// FriendlyName
//
class function TODEElementCapsule.FriendlyName: String;
begin
  Result := 'Capsule';
end;

// FriendlyDescription
//
class function TODEElementCapsule.FriendlyDescription: String;
begin
  Result := 'The ODE capped cylinder element implementation';
end;

// ItemCategory
//
class function TODEElementCapsule.ItemCategory: String;
begin
  Result := 'Primitives';
end;

// CalculateMass
//
function TODEElementCapsule.CalculateMass: TdMass;
begin
  dMassSetCapsule(FMass, FDensity, 3, FRadius, FLength);
  Result := inherited CalculateMass;
end;

// GetRadius
//
function TODEElementCapsule.GetRadius: TdReal;
var
  rad, len: TdReal;
begin
  if Assigned(FGeomElement) then
  begin
    dGeomCapsuleGetParams(Geom, rad, len);
    FRadius := rad;
  end;
  Result := FRadius;
end;

// GetLength
//
function TODEElementCapsule.GetLength: TdReal;
var
  rad, len: TdReal;
begin
  if Assigned(FGeomElement) then
  begin
    dGeomCapsuleGetParams(Geom, rad, len);
    FLength := len;
  end;
  Result := FLength;
end;

// ODERebuild
//
procedure TODEElementCapsule.ODERebuild;
begin
  if Assigned(Geom) then
    dGeomCapsuleSetParams(Geom, FRadius, FLength);
  inherited;
end;

// SetRadius
//
procedure TODEElementCapsule.SetRadius(const Value: TdReal);
begin
  FRadius := Value;
  ODERebuild;
end;

// SetLength
//
procedure TODEElementCapsule.SetLength(const Value: TdReal);
begin
  FLength := Value;
  ODERebuild;
end;


// ---------------
// --------------- TODEElementCylinder ---------------
// ---------------

// Render
//
procedure TODEElementCylinder.Render(var rci: TGLRenderContextInfo);
var
  i, J, Stacks, Slices: Integer;
begin
  GL.PushMatrix;

  GL.MultMatrixf(@FLocalMatrix);

  Stacks := 8;
  Slices := 16;

  // Middle horizontal circles
  for J := 0 to Stacks - 1 do
  begin
    GL.Begin_(GL_LINE_LOOP);
    for i := 0 to Slices - 1 do
      GL.Vertex3f(FRadius * sin(2 * i * PI / Slices), -FLength / 2 + FLength * J
        / (Stacks - 1), FRadius * cos(2 * i * PI / Slices));
    GL.End_;
  end;

  // Middle vertical lines
  GL.Begin_(GL_LINES);
  for i := 0 to (Slices div 2) - 1 do
  begin
    GL.Vertex3f(FRadius * sin(2 * i * PI / Slices), -FLength / 2,
      FRadius * cos(2 * i * PI / Slices));
    GL.Vertex3f(FRadius * sin(2 * i * PI / Slices), FLength / 2,
      FRadius * cos(2 * i * PI / Slices));
    GL.Vertex3f(-FRadius * sin(2 * i * PI / Slices), -FLength / 2,
      -FRadius * cos(2 * i * PI / Slices));
    GL.Vertex3f(-FRadius * sin(2 * i * PI / Slices), FLength / 2,
      -FRadius * cos(2 * i * PI / Slices));
  end;
  GL.End_;

  // Caps
  GL.PushMatrix;
  for J := 0 to (Slices div 2) - 1 do
  begin
    GL.Begin_(GL_LINES);
    GL.Vertex3f(-FRadius, FLength / 2, 0);
    GL.Vertex3f(FRadius, FLength / 2, 0);
    GL.Vertex3f(-FRadius, -FLength / 2, 0);
    GL.Vertex3f(FRadius, -FLength / 2, 0);
    GL.End_;
    GL.Rotatef(360 / Slices, 0, 1, 0);
  end;
  GL.PopMatrix;

  GL.PopMatrix;
end;

// Create
//
constructor TODEElementCylinder.Create(AOwner: TGLXCollection);
begin
  inherited;
  FRadius := 0.5;
  FLength := 1;
end;

// Initialize
//
procedure TODEElementCylinder.Initialize;
begin
  if FInitialized then
    Exit;
  if not IsODEInitialized then
    Exit;

  FGeomElement := dCreateCylinder(nil, FRadius, FLength);
  inherited;
end;

// WriteToFiler
//
procedure TODEElementCylinder.WriteToFiler(writer: TWriter);
begin
  inherited;
  with writer do
  begin
    WriteInteger(0); // Archive version
    WriteFloat(Radius);
    WriteFloat(Length);
  end;
end;

// ReadFromFiler
//
procedure TODEElementCylinder.ReadFromFiler(reader: TReader);
begin
  inherited;
  with reader do
  begin
    Assert(ReadInteger = 0); // Archive version
    Radius := ReadFloat;
    Length := ReadFloat;
  end;
end;

// FriendlyName
//
class function TODEElementCylinder.FriendlyName: String;
begin
  Result := 'Cylinder';
end;

// FriendlyDescription
//
class function TODEElementCylinder.FriendlyDescription: String;
begin
  Result := 'The ODE cylinder element implementation';
end;

// ItemCategory
//
class function TODEElementCylinder.ItemCategory: String;
begin
  Result := 'Primitives';
end;

// CalculateMass
//
function TODEElementCylinder.CalculateMass: TdMass;
begin
  dMassSetCylinder(FMass, FDensity, 3, FRadius, FLength);
  Result := inherited CalculateMass;
end;

// GetRadius
//
function TODEElementCylinder.GetRadius: TdReal;
var
  rad, len: TdReal;
begin
  if Assigned(FGeomElement) then
  begin
    dGeomCylinderGetParams(Geom, rad, len);
    FRadius := rad;
  end;
  Result := FRadius;
end;

// GetLength
//
function TODEElementCylinder.GetLength: TdReal;
var
  rad, len: TdReal;
begin
  if Assigned(FGeomElement) then
  begin
    dGeomCylinderGetParams(Geom, rad, len);
    FLength := len;
  end;
  Result := FLength;
end;

// ODERebuild
//
procedure TODEElementCylinder.ODERebuild;
begin
  if Assigned(Geom) then
    dGeomCylinderSetParams(Geom, FRadius, FLength);
  inherited;
end;

// SetRadius
//
procedure TODEElementCylinder.SetRadius(const Value: TdReal);
begin
  FRadius := Value;
  ODERebuild;
end;

// SetLength
//
procedure TODEElementCylinder.SetLength(const Value: TdReal);
begin
  FLength := Value;
  ODERebuild;
end;



// ---------------
// --------------- TODEElementTriMesh ---------------
// ---------------

// Create
//
constructor TODEElementTriMesh.Create(AOwner: TGLXCollection);
begin
  inherited;
  FVertices := TAffineVectorList.Create;
  FIndices := TIntegerList.Create;
end;

// Destroy
//
destructor TODEElementTriMesh.Destroy;
begin
  FVertices.Free;
  FIndices.Free;
  inherited;
end;

// Initialize
//
procedure TODEElementTriMesh.Initialize;
begin
  if not IsODEInitialized then
    Exit;
  if FInitialized or not((FVertices.Count > 0) and (FIndices.Count > 0)) then
    Exit;

  FTriMeshData := dGeomTriMeshDataCreate;
  dGeomTriMeshDataBuildSingle(FTriMeshData, @FVertices.List[0],
    3 * SizeOf(Single), FVertices.Count, @FIndices.List[0], FIndices.Count,
    3 * SizeOf(Integer));
  FGeomElement := dCreateTriMesh(nil, FTriMeshData, nil, nil, nil);

  inherited;
end;

// Finalize
//
procedure TODEElementTriMesh.Finalize;
begin
  if not FInitialized then
    Exit;
  if Assigned(FTriMeshData) then
    dGeomTriMeshDataDestroy(FTriMeshData);
  inherited;
end;

// WriteToFiler
//
procedure TODEElementTriMesh.WriteToFiler(writer: TWriter);
begin
  inherited;
  with writer do
  begin
    WriteInteger(0); // Archive version
  end;
end;

// ReadFromFiler
//
procedure TODEElementTriMesh.ReadFromFiler(reader: TReader);
begin
  inherited;
  with reader do
  begin
    Assert(ReadInteger = 0); // Archive version
  end;
end;

// FriendlyName
//
class function TODEElementTriMesh.FriendlyName: String;
begin
  Result := 'Tri-Mesh';
end;

// FriendlyDescription
//
class function TODEElementTriMesh.FriendlyDescription: String;
begin
  Result := 'The ODE tri-mesh element implementation';
end;

// ItemCategory
//
class function TODEElementTriMesh.ItemCategory: String;
begin
  Result := 'Meshes';
end;

// CalculateMass
//
function TODEElementTriMesh.CalculateMass: TdMass;
var
  R: Single;
  min, max: TAffineVector;
begin
  if Vertices.Count > 0 then
  begin
    Vertices.GetExtents(min, max);
    R := MaxFloat(VectorLength(min), VectorLength(max));
  end
  else
    R := 1;
  dMassSetSphere(FMass, FDensity, R);
  Result := inherited CalculateMass;
end;

// SetVertices
//
procedure TODEElementTriMesh.SetVertices(const Value: TAffineVectorList);
begin
  FVertices.Assign(Value);
  RefreshTriMeshData;
end;

// SetIndices
//
procedure TODEElementTriMesh.SetIndices(const Value: TIntegerList);
begin
  FIndices.Assign(Value);
  RefreshTriMeshData;
end;

// RefreshTriMeshData
//
procedure TODEElementTriMesh.RefreshTriMeshData;
begin
  if FInitialized then
    Finalize;
  Initialize;
end;


// ---------------
// --------------- TODEElementPlane ---------------
// ---------------

// Initialize
//
procedure TODEElementPlane.Initialize;
begin
  if FInitialized then
    Exit;
  if not IsODEInitialized then
    Exit;

  FGeomElement := dCreatePlane(nil, 0, 0, 1, 0);
  inherited;
end;

// WriteToFiler
//
procedure TODEElementPlane.WriteToFiler(writer: TWriter);
begin
  // ArchiveVersion 1, added inherited call
  writer.WriteInteger(1);
  inherited;
end;

// ReadFromFiler
//
procedure TODEElementPlane.ReadFromFiler(reader: TReader);
var
  archiveVersion: Integer;
begin
  archiveVersion := reader.ReadInteger;
  Assert(archiveVersion in [0 .. 1]);
  if archiveVersion >= 1 then
    inherited;
end;

// FriendlyName
//
class function TODEElementPlane.FriendlyName: String;
begin
  Result := 'Plane';
end;

// FriendlyDescription
//
class function TODEElementPlane.FriendlyDescription: String;
begin
  Result := 'The ODE plane element implementation';
end;

// ItemCategory
//
class function TODEElementPlane.ItemCategory: String;
begin
  Result := 'Primitives';
end;

// CanAddTo
//
class function TODEElementPlane.CanAddTo(collection: TGLXCollection): Boolean;
begin
  Result := False;
  if Assigned(TGLODEElements(collection).Owner) then
    if TGLODEElements(collection).Owner is TGLODEStatic then
      Result := True;
end;

// AlignGeomElementToMatrix
//
procedure TODEElementPlane.AlignGeomElementToMatrix(Mat: TMatrix);
var
  d: Single;
begin
  if not Assigned(FGeomElement) then
    Exit;
  d := VectorDotProduct(Mat.V[2], Mat.V[3]);
  dGeomPlaneSetParams(FGeomElement, Mat.V[2].V[0], Mat.V[2].V[1],
    Mat.V[2].V[2], d);
end;


// ---------------
// --------------- TODEJoints ---------------
// ---------------

// ItemsClass
//
class function TGLODEJoints.ItemsClass: TGLXCollectionItemClass;
begin
  Result := TGLODEJointBase;
end;

// Initialize
//
procedure TGLODEJoints.Initialize;
var
  i: Integer;
begin
  for i := 0 to Count - 1 do
    Joint[i].Initialize;
end;

// Finalize
//
procedure TGLODEJoints.Finalize;
var
  i: Integer;
begin
  for i := 0 to Count - 1 do
    Joint[i].Finalize;
end;

// GetJoint
//
function TGLODEJoints.GetJoint(index: Integer): TGLODEJointBase;
begin
  Result := TGLODEJointBase(Items[index]);
end;


// ---------------
// --------------- TGLODEJointList ---------------
// ---------------

// Create
//
constructor TGLODEJointList.Create(AOwner: TComponent);
begin
  inherited;
  FJoints := TGLODEJoints.Create(Self);
end;

// Destroy
//
destructor TGLODEJointList.Destroy;
begin
  FJoints.Free;
  inherited;
end;

// DefineProperties
//
procedure TGLODEJointList.DefineProperties(Filer: TFiler);
begin
  inherited;
  Filer.DefineBinaryProperty('ODEJointsData', ReadJoints, WriteJoints,
    (Assigned(FJoints) and (FJoints.Count > 0)));
end;

// WriteJoints
//
procedure TGLODEJointList.WriteJoints(stream: TStream);
var
  writer: TWriter;
begin
  writer := TWriter.Create(stream, 16384);
  try
    Joints.WriteToFiler(writer);
  finally
    writer.Free;
  end;
end;

// ReadJoints
//
procedure TGLODEJointList.ReadJoints(stream: TStream);
var
  reader: TReader;
begin
  reader := TReader.Create(stream, 16384);
  try
    Joints.ReadFromFiler(reader);
  finally
    reader.Free;
  end;
end;

// Loaded
//
procedure TGLODEJointList.Loaded;
var
  i: Integer;
begin
  inherited;
  for i := 0 to FJoints.Count - 1 do
    FJoints[i].Loaded;
end;

// Notification
//
procedure TGLODEJointList.Notification(AComponent: TComponent;
  Operation: TOperation);
var
  i: Integer;
begin
  inherited;
  if (Operation = opRemove) and (AComponent is TGLBaseSceneObject) then
    for i := 0 to Joints.Count - 1 do
    begin
      if TGLBaseSceneObject(AComponent) = Joints[i].Object1 then
        Joints[i].Object1 := nil;
      if TGLBaseSceneObject(AComponent) = Joints[i].Object2 then
        Joints[i].Object2 := nil;
    end;
end;


// ---------------
// --------------- TGLODEJointBase ---------------
// ---------------

// Create
//
constructor TGLODEJointBase.Create(AOwner: TGLXCollection);
begin
  inherited;
  FJointID := nil;
  FEnabled := True;
  FInitialized := False;
end;

// Destroy
destructor TGLODEJointBase.Destroy;
begin
  Finalize;
  inherited;
end;

// Initialize
//
procedure TGLODEJointBase.Initialize;
begin
  if not IsODEInitialized then
    Exit;

  if Assigned(FObject1) then
    RegisterJointWithObject(FObject1);
  if Assigned(FObject2) then
    RegisterJointWithObject(FObject2);
  Attach;

  FInitialized := True;
end;

// Finalize
//
procedure TGLODEJointBase.Finalize;
begin
  if not Initialized then
    Exit;

  if Assigned(FObject1) then
    UnregisterJointWithObject(FObject1);
  if Assigned(FObject2) then
    UnregisterJointWithObject(FObject2);
  if FJointID <> nil then
    dJointDestroy(FJointID);

  FInitialized := False;
end;

// WriteToFiler
//
procedure TGLODEJointBase.WriteToFiler(writer: TWriter);
begin
  inherited;
  with writer do
  begin
    WriteInteger(0); // Archive version
    if Assigned(FManager) then
      WriteString(FManager.GetNamePath)
    else
      WriteString('');
    if Assigned(FObject1) then
      WriteString(FObject1.GetNamePath)
    else
      WriteString('');
    if Assigned(FObject2) then
      WriteString(FObject2.GetNamePath)
    else
      WriteString('');
    WriteBoolean(FEnabled);
  end;
end;

// ReadFromFiler
//
procedure TGLODEJointBase.ReadFromFiler(reader: TReader);
begin
  inherited;
  with reader do
  begin
    Assert(ReadInteger = 0); // Archive version
    FManagerName := ReadString;
    FObject1Name := ReadString;
    FObject2Name := ReadString;
    FEnabled := ReadBoolean;
  end;
end;

// Loaded
//
procedure TGLODEJointBase.Loaded;
begin
  DoLoaded;
end;

// RegisterJointWithObject
//
procedure TGLODEJointBase.RegisterJointWithObject(Obj: TGLBaseSceneObject);
var
  temp: TGLODEDynamic;
begin
  if Assigned(Obj) then
  begin
    temp := TGLODEDynamic(Obj.Behaviours.GetByClass(TGLODEDynamic));
    if Assigned(temp) then
      temp.RegisterJoint(Self);
  end;
end;

// UnregisterJointWithObject
//
procedure TGLODEJointBase.UnregisterJointWithObject(Obj: TGLBaseSceneObject);
var
  temp: TGLODEDynamic;
begin
  if Assigned(Obj) then
  begin
    temp := TGLODEDynamic(Obj.Behaviours.GetByClass(TGLODEDynamic));
    if Assigned(temp) then
      temp.UnregisterJoint(Self);
  end;
end;

// IsODEInitialized
//
function TGLODEJointBase.IsODEInitialized: Boolean;
begin
  Result := False;
  if not Assigned(Manager) then
    Exit;
  Result := Assigned(Manager.World);
end;

// Attach
//
procedure TGLODEJointBase.Attach;
var
  Body1, Body2: PdxBody;
begin
  if (FJointID = nil) or not FInitialized then
    Exit;

  if Enabled then
  begin
    Body1 := GetBodyFromGLSceneObject(FObject1);
    Body2 := GetBodyFromGLSceneObject(FObject2);
  end
  else
  begin
    Body1 := nil;
    Body2 := nil;
  end;

  if (joBothObjectsMustBeAssigned in JointOptions) then
    if not(Assigned(Body1) and Assigned(Body2)) then
      Exit;

  dJointAttach(FJointID, Body1, Body2);
  if Assigned(Body1) or Assigned(Body2) then
    StructureChanged;
end;

// SetManager
//
procedure TGLODEJointBase.SetManager(const Value: TGLODEManager);
begin
  if FManager <> Value then
  begin
    if Assigned(FManager) then
      if not(csDesigning in FManager.ComponentState) then
        Finalize;
    FManager := Value;
    if Assigned(FManager) then
      if not(csDesigning in FManager.ComponentState) then
        Initialize;
  end;
end;

// SetObject1
//
procedure TGLODEJointBase.SetObject1(const Value: TGLBaseSceneObject);
begin
  if FObject1 <> Value then
  begin
    if Assigned(FObject1) then
      UnregisterJointWithObject(FObject1);
    FObject1 := Value;
    if Assigned(FObject1) then
      if IsGLODEObject(FObject1) then
        RegisterJointWithObject(FObject1)
      else
        FObject1 := nil;
    Attach;
  end;
end;

// SetObject2
//
procedure TGLODEJointBase.SetObject2(const Value: TGLBaseSceneObject);
begin
  if FObject2 <> Value then
  begin
    if Assigned(FObject2) then
      UnregisterJointWithObject(FObject2);
    FObject2 := Value;
    if Assigned(FObject2) then
      if IsGLODEObject(FObject2) then
        RegisterJointWithObject(FObject2)
      else
        FObject2 := nil;
    Attach;
  end;
end;

// SetEnabled
//
procedure TGLODEJointBase.SetEnabled(const Value: Boolean);
begin
  if FEnabled <> Value then
  begin
    FEnabled := Value;
    if IsODEInitialized then
      Attach;
  end;
end;

// StructureChanged
//
procedure TGLODEJointBase.StructureChanged;
begin
  // nothing yet
end;

// DoLoaded (public proc for Loaded)
//
procedure TGLODEJointBase.DoLoaded;
var
  mng: TComponent;
  Obj: TGLBaseSceneObject;
begin
  inherited;
  if FManagerName <> '' then
  begin
    mng := FindManager(TGLODEManager, FManagerName);
    if Assigned(mng) then
      Manager := TGLODEManager(mng);
    FManagerName := '';
  end;
  if FObject1Name <> '' then
  begin
    Obj := GetGLSceneObject(FObject1Name);
    if Assigned(Obj) then
      Object1 := Obj;
    FObject1Name := '';
  end;
  if FObject2Name <> '' then
  begin
    Obj := GetGLSceneObject(FObject2Name);
    if Assigned(Obj) then
      Object2 := Obj;
    FObject2Name := '';
  end;
  Attach;
end;

// IsAttached
//
function TGLODEJointBase.IsAttached: Boolean;
var
  Body1, Body2: PdxBody;
begin
  Result := False;
  if JointID <> nil then
  begin
    Body1 := dJointGetBody(JointID, 0);
    Body2 := dJointGetBody(JointID, 1);
    if joBothObjectsMustBeAssigned in JointOptions then
      Result := Assigned(Body1) and Assigned(Body2)
    else
      Result := Assigned(Body1) or Assigned(Body2);
  end;
end;

// SetJointOptions
//
procedure TGLODEJointBase.SetJointOptions(const Value: TJointOptions);
begin
  if Value <> FJointOptions then
  begin
    FJointOptions := Value;
    Attach;
  end;
end;


// ---------------
// --------------- TODEJointParams ---------------
// ---------------

// Create
//
constructor TODEJointParams.Create(AOwner: TPersistent);
begin
  inherited Create;
  FOwner := AOwner;
end;

// GetOwner
//
function TODEJointParams.GetOwner: TPersistent;
begin
  Result := FOwner;
end;

// Assign
//
procedure TODEJointParams.Assign(Source: TPersistent);
begin
  inherited;
  if not Assigned(Source) then
    Exit;
  if Source is TODEJointParams then
  begin
    LoStop := TODEJointParams(Source).LoStop;
    HiStop := TODEJointParams(Source).HiStop;
    Vel := TODEJointParams(Source).Vel;
    FMax := TODEJointParams(Source).FMax;
    FudgeFactor := TODEJointParams(Source).FudgeFactor;
    Bounce := TODEJointParams(Source).Bounce;
    CFM := TODEJointParams(Source).CFM;
    StopERP := TODEJointParams(Source).StopERP;
    StopCFM := TODEJointParams(Source).StopCFM;
    SuspensionERP := TODEJointParams(Source).SuspensionERP;
    SuspensionCFM := TODEJointParams(Source).SuspensionCFM;
  end;
end;

// WriteToFiler
//
procedure TODEJointParams.WriteToFiler(writer: TWriter);
begin
  with writer do
  begin
    WriteInteger(0); // Archive version
    WriteFloat(LoStop);
    WriteFloat(HiStop);
    WriteFloat(Vel);
    WriteFloat(FMax);
    WriteFloat(FudgeFactor);
    WriteFloat(Bounce);
    WriteFloat(CFM);
    WriteFloat(StopERP);
    WriteFloat(StopCFM);
    WriteFloat(SuspensionERP);
    WriteFloat(SuspensionCFM);
  end;
end;

// ReadFromFiler
//
procedure TODEJointParams.ReadFromFiler(reader: TReader);
var
  archiveVersion: Integer;
begin
  with reader do
  begin
    archiveVersion := ReadInteger;
    Assert(archiveVersion = 0);

    LoStop := ReadFloat;
    HiStop := ReadFloat;
    Vel := ReadFloat;
    FMax := ReadFloat;
    FudgeFactor := ReadFloat;
    Bounce := ReadFloat;
    CFM := ReadFloat;
    StopERP := ReadFloat;
    StopCFM := ReadFloat;
    SuspensionERP := ReadFloat;
    SuspensionCFM := ReadFloat;
  end;
end;

// GetLoStop
//
function TODEJointParams.GetLoStop: TdReal;
begin
  if Assigned(GetCallback) then
    GetCallback(dParamLoStop1, FLoStop);
  Result := FLoStop;
end;

// GetHiStop
//
function TODEJointParams.GetHiStop: TdReal;
begin
  if Assigned(GetCallback) then
    GetCallback(dParamHiStop1, FHiStop);
  Result := FHiStop;
end;

// GetVel
//
function TODEJointParams.GetVel: TdReal;
begin
  if Assigned(GetCallback) then
    GetCallback(dParamVel1, FVel);
  Result := FVel;
end;

// GetFMax
//
function TODEJointParams.GetFMax: TdReal;
begin
  if Assigned(GetCallback) then
    GetCallback(dParamFMax1, FFMax);
  Result := FFMax;
end;

// GetFudgeFactor
//
function TODEJointParams.GetFudgeFactor: TdReal;
begin
  if Assigned(GetCallback) then
    GetCallback(dParamFudgeFactor1, FFudgeFactor);
  Result := FFudgeFactor;
end;

// GetBounce
//
function TODEJointParams.GetBounce: TdReal;
begin
  if Assigned(GetCallback) then
    GetCallback(dParamBounce1, FBounce);
  Result := FBounce;
end;

// GetCFM
//
function TODEJointParams.GetCFM: TdReal;
begin
  if Assigned(GetCallback) then
    GetCallback(dParamCFM1, FCFM);
  Result := FCFM;
end;

// GetStopERP
//
function TODEJointParams.GetStopERP: TdReal;
begin
  if Assigned(GetCallback) then
    GetCallback(dParamStopERP1, FStopERP);
  Result := FStopERP;
end;

// GetStopCFM
//
function TODEJointParams.GetStopCFM: TdReal;
begin
  if Assigned(GetCallback) then
    GetCallback(dParamStopCFM1, FStopCFM);
  Result := FStopCFM;
end;

// GetSuspensionERP
//
function TODEJointParams.GetSuspensionERP: TdReal;
begin
  if Assigned(GetCallback) then
    GetCallback(dParamSuspensionERP, FSuspensionERP);
  Result := FSuspensionERP;
end;

// GetSuspensionCFM
//
function TODEJointParams.GetSuspensionCFM: TdReal;
begin
  if Assigned(GetCallback) then
    GetCallback(dParamSuspensionCFM, FSuspensionCFM);
  Result := FSuspensionCFM;
end;

// SetLoStop
//
procedure TODEJointParams.SetLoStop(const Value: TdReal);
begin
  if Value <> FLoStop then
  begin
    FLoStop := Value;
    if Assigned(SetCallback) then
      FFlagLoStop := not SetCallback(dParamLoStop1, FLoStop)
    else
      FFlagLoStop := True;
  end;
end;

// SetHiStop
//
procedure TODEJointParams.SetHiStop(const Value: TdReal);
begin
  if Value <> FHiStop then
  begin
    FHiStop := Value;
    if Assigned(SetCallback) then
      FFlagHiStop := not SetCallback(dParamHiStop1, FHiStop)
    else
      FFlagHiStop := True;
  end;
end;

// SetVel
//
procedure TODEJointParams.SetVel(const Value: TdReal);
begin
  if Value <> FVel then
  begin
    FVel := Value;
    if Assigned(SetCallback) then
      FFlagVel := not SetCallback(dParamVel1, FVel)
    else
      FFlagVel := True;
  end;
end;

// SetFMax
//
procedure TODEJointParams.SetFMax(const Value: TdReal);
begin
  if Value <> FFMax then
  begin
    FFMax := Value;
    if Assigned(SetCallback) then
      FFlagFMax := not SetCallback(dParamFMax1, FFMax)
    else
      FFlagFMax := True;
  end;
end;

// SetFudgeFactor
//
procedure TODEJointParams.SetFudgeFactor(const Value: TdReal);
begin
  if Value <> FFudgeFactor then
  begin
    FFudgeFactor := Value;
    if Assigned(SetCallback) then
      FFlagFudgeFactor := not SetCallback(dParamFudgeFactor1, FFudgeFactor)
    else
      FFlagFudgeFactor := True;
  end;
end;

// SetBounce
//
procedure TODEJointParams.SetBounce(const Value: TdReal);
begin
  if Value <> FBounce then
  begin
    FBounce := Value;
    if Assigned(SetCallback) then
      FFlagBounce := not SetCallback(dParamBounce1, FBounce)
    else
      FFlagBounce := True;
  end;
end;

// SetCFM
//
procedure TODEJointParams.SetCFM(const Value: TdReal);
begin
  if Value <> FCFM then
  begin
    FCFM := Value;
    if Assigned(SetCallback) then
      FFlagCFM := not SetCallback(dParamCFM1, FCFM)
    else
      FFlagCFM := True;
  end;
end;

// SetStopERP
//
procedure TODEJointParams.SetStopERP(const Value: TdReal);
begin
  if Value <> FStopERP then
  begin
    FStopERP := Value;
    if Assigned(SetCallback) then
      FFlagStopERP := not SetCallback(dParamStopERP1, FStopERP)
    else
      FFlagStopERP := True;
  end;
end;

// SetStopCFM
//
procedure TODEJointParams.SetStopCFM(const Value: TdReal);
begin
  if Value <> FStopCFM then
  begin
    FStopCFM := Value;
    if Assigned(SetCallback) then
      FFlagStopCFM := not SetCallback(dParamStopCFM1, FStopCFM)
    else
      FFlagStopCFM := True;
  end;
end;

// SetSuspensionERP
//
procedure TODEJointParams.SetSuspensionERP(const Value: TdReal);
begin
  if Value <> FSuspensionERP then
  begin
    FSuspensionERP := Value;
    if Assigned(SetCallback) then
      FFlagSuspensionERP := not SetCallback(dParamSuspensionERP, FSuspensionERP)
    else
      FFlagSuspensionERP := True;
  end;
end;

// SetSuspensionCFM
//
procedure TODEJointParams.SetSuspensionCFM(const Value: TdReal);
begin
  if Value <> FSuspensionCFM then
  begin
    FSuspensionCFM := Value;
    if Assigned(SetCallback) then
      FFlagSuspensionCFM := not SetCallback(dParamSuspensionCFM, FSuspensionCFM)
    else
      FFlagSuspensionCFM := True;
  end;
end;

// ApplyFlagged
//
procedure TODEJointParams.ApplyFlagged;
begin
  if not Assigned(SetCallback) then
    Exit;
  if FFlagLoStop then
    SetCallback(dParamLoStop1, FLoStop);
  if FFlagHiStop then
    SetCallback(dParamHiStop1, FHiStop);
  if FFlagVel then
    SetCallback(dParamVel1, FVel);
  if FFlagFMax then
    SetCallback(dParamFMax1, FFMax);
  if FFlagFudgeFactor then
    SetCallback(dParamFudgeFactor1, FFudgeFactor);
  if FFlagBounce then
    SetCallback(dParamBounce1, FBounce);
  if FFlagCFM then
    SetCallback(dParamCFM1, FCFM);
  if FFlagStopERP then
    SetCallback(dParamStopERP1, FStopERP);
  if FFlagStopCFM then
    SetCallback(dParamStopCFM1, FStopCFM);
  if FFlagSuspensionERP then
    SetCallback(dParamSuspensionERP, FSuspensionERP);
  if FFlagSuspensionCFM then
    SetCallback(dParamSuspensionCFM, FSuspensionCFM);
end;


// ---------------
// --------------- TODEJointHinge ---------------
// ---------------

// Create
//
constructor TODEJointHinge.Create(AOwner: TGLXCollection);
begin
  inherited;
  FAnchor := TGLCoordinates.CreateInitialized(Self, NullHmgPoint, csPoint);
  FAnchor.OnNotifyChange := AnchorChange;
  FAxis := TGLCoordinates.CreateInitialized(Self, ZHmgVector, csVector);
  FAxis.OnNotifyChange := AxisChange;
  FAxisParams := TODEJointParams.Create(Self);
  FAxisParams.SetCallback := SetAxisParam;
  FAxisParams.GetCallback := GetAxisParam;

end;

// Destroy
destructor TODEJointHinge.Destroy;
begin
  FAnchor.Free;
  FAxis.Free;
  FAxisParams.Free;
  inherited;
end;

// Initialize
//
procedure TODEJointHinge.Initialize;
begin
  if (not IsODEInitialized) or (FInitialized) then
    Exit;
  FJointID := dJointCreateHinge(FManager.World, nil);
  inherited;
end;

// WriteToFiler
//
procedure TODEJointHinge.WriteToFiler(writer: TWriter);
begin
  inherited;
  with writer do
  begin
    WriteInteger(0); // Archive version
    FAnchor.WriteToFiler(writer);
    FAxis.WriteToFiler(writer);
    FAxisParams.WriteToFiler(writer);
  end;
end;

// ReadFromFiler
//
procedure TODEJointHinge.ReadFromFiler(reader: TReader);
begin
  inherited;
  with reader do
  begin
    Assert(ReadInteger = 0); // Archive version
    FAnchor.ReadFromFiler(reader);
    FAxis.ReadFromFiler(reader);
    FAxisParams.ReadFromFiler(reader);
  end;
end;

// StructureChanged
//
procedure TODEJointHinge.StructureChanged;
begin
  AnchorChange(nil);
  AxisChange(nil);
  FAxisParams.ApplyFlagged;
end;

// AnchorChange
//
procedure TODEJointHinge.AnchorChange(Sender: TObject);
begin
  if IsAttached then
    dJointSetHingeAnchor(FJointID, FAnchor.X, FAnchor.Y, FAnchor.Z);
end;

// AxisChange
//
procedure TODEJointHinge.AxisChange(Sender: TObject);
var
  vec: TVector;
begin
  vec := FAxis.DirectVector;
  NormalizeVector(vec);
  FAxis.DirectVector := vec;
  if IsAttached then
    dJointSetHingeAxis(FJointID, FAxis.X, FAxis.Y, FAxis.Z);
end;

// FriendlyName
//
class function TODEJointHinge.FriendlyName: String;
begin
  Result := 'Hinge';
end;

// FriendlyDescription
//
class function TODEJointHinge.FriendlyDescription: String;
begin
  Result := 'ODE Hinge joint';
end;

// SetAnchor
//
procedure TODEJointHinge.SetAnchor(const Value: TGLCoordinates);
begin
  FAnchor.Assign(Value);
end;

// SetAxis
//
procedure TODEJointHinge.SetAxis(const Value: TGLCoordinates);
begin
  FAxis.Assign(Value);
end;

// SetAxisParams
//
procedure TODEJointHinge.SetAxisParams(const Value: TODEJointParams);
begin
  AxisParams.Assign(Value);
end;

// SetAxisParam
//
function TODEJointHinge.SetAxisParam(Param: Integer;
  const Value: TdReal): Boolean;
begin
  if IsAttached then
  begin
    dJointSetHingeParam(JointID, Param, Value);
    Result := True;
  end
  else
    Result := False;
end;

// GetAxisParam
//
function TODEJointHinge.GetAxisParam(Param: Integer; var Value: TdReal)
  : Boolean;
begin
  if IsAttached then
  begin
    Value := dJointGetHingeParam(JointID, Param);
    Result := True;
  end
  else
    Result := False;
end;


// ---------------
// --------------- TODEJointBall ---------------
// ---------------

// Create
//
constructor TODEJointBall.Create(AOwner: TGLXCollection);
begin
  inherited;
  FAnchor := TGLCoordinates.CreateInitialized(Self, NullHmgPoint, csPoint);
  FAnchor.OnNotifyChange := AnchorChange;
end;

// Destroy
destructor TODEJointBall.Destroy;
begin
  FAnchor.Free;
  inherited;
end;

// Initialize
//
procedure TODEJointBall.Initialize;
begin
  if (not IsODEInitialized) or (FInitialized) then
    Exit;
  FJointID := dJointCreateBall(FManager.World, nil);
  inherited;
end;

// WriteToFiler
//
procedure TODEJointBall.WriteToFiler(writer: TWriter);
begin
  inherited;
  with writer do
  begin
    WriteInteger(0); // Archive version
    FAnchor.WriteToFiler(writer);
  end;
end;

// ReadFromFiler
//
procedure TODEJointBall.ReadFromFiler(reader: TReader);
begin
  inherited;
  with reader do
  begin
    Assert(ReadInteger = 0); // Archive version
    FAnchor.ReadFromFiler(reader);
  end;
end;

// StructureChanged
//
procedure TODEJointBall.StructureChanged;
begin
  AnchorChange(nil);
end;

// AnchorChange
//
procedure TODEJointBall.AnchorChange(Sender: TObject);
begin
  if IsAttached then
    dJointSetBallAnchor(FJointID, FAnchor.X, FAnchor.Y, FAnchor.Z);
end;

// FriendlyName
//
class function TODEJointBall.FriendlyName: String;
begin
  Result := 'Ball';
end;

// FriendlyDescription
//
class function TODEJointBall.FriendlyDescription: String;
begin
  Result := 'ODE Ball joint implementation';
end;

// SetAnchor
//
procedure TODEJointBall.SetAnchor(const Value: TGLCoordinates);
begin
  FAnchor.Assign(Value);
end;


// ---------------
// --------------- TODEJointSlider ---------------
// ---------------

// Create
//
constructor TODEJointSlider.Create(AOwner: TGLXCollection);
begin
  inherited;
  FAxis := TGLCoordinates.CreateInitialized(Self, ZHmgVector, csVector);
  FAxis.OnNotifyChange := AxisChange;
  FAxisParams := TODEJointParams.Create(Self);
  FAxisParams.SetCallback := SetAxisParam;
  FAxisParams.GetCallback := GetAxisParam;
end;

// Destroy
destructor TODEJointSlider.Destroy;
begin
  FAxis.Free;
  FAxisParams.Free;
  inherited;
end;

// Initialize
//
procedure TODEJointSlider.Initialize;
begin
  if (not IsODEInitialized) or (FInitialized) then
    Exit;
  FJointID := dJointCreateSlider(FManager.World, nil);
  inherited;
end;

// WriteToFiler
//
procedure TODEJointSlider.WriteToFiler(writer: TWriter);
begin
  inherited;
  with writer do
  begin
    WriteInteger(0); // Archive version
    FAxis.WriteToFiler(writer);
    FAxisParams.WriteToFiler(writer);
  end;
end;

// ReadFromFiler
//
procedure TODEJointSlider.ReadFromFiler(reader: TReader);
begin
  inherited;
  with reader do
  begin
    Assert(ReadInteger = 0); // Archive version
    FAxis.ReadFromFiler(reader);
    FAxisParams.ReadFromFiler(reader);
  end;
end;

// StructureChanged
//
procedure TODEJointSlider.StructureChanged;
begin
  AxisChange(nil);
  AxisParams.ApplyFlagged;
end;

// AxisChange
//
procedure TODEJointSlider.AxisChange(Sender: TObject);
var
  vec: TVector;
begin
  vec := FAxis.DirectVector;
  NormalizeVector(vec);
  FAxis.DirectVector := vec;
  if IsAttached then
    dJointSetSliderAxis(FJointID, FAxis.X, FAxis.Y, FAxis.Z);
end;

// FriendlyName
//
class function TODEJointSlider.FriendlyName: String;
begin
  Result := 'Slider';
end;

// FriendlyDescription
//
class function TODEJointSlider.FriendlyDescription: String;
begin
  Result := 'ODE Slider joint implementation';
end;

// SetAxis
//
procedure TODEJointSlider.SetAxis(const Value: TGLCoordinates);
begin
  FAxis.Assign(Value);
end;

// SetAxisParams
//
procedure TODEJointSlider.SetAxisParams(const Value: TODEJointParams);
begin
  AxisParams.Assign(Value);
end;

// SetAxisParam
//
function TODEJointSlider.SetAxisParam(Param: Integer;
  const Value: TdReal): Boolean;
begin
  if IsAttached then
  begin
    dJointSetSliderParam(JointID, Param, Value);
    Result := True;
  end
  else
    Result := False;
end;

// GetAxisParam
//
function TODEJointSlider.GetAxisParam(Param: Integer;
  var Value: TdReal): Boolean;
begin
  if IsAttached then
  begin
    Value := dJointGetSliderParam(JointID, Param);
    Result := True;
  end
  else
    Result := False;
end;


// ---------------
// --------------- TODEJointFixed ---------------
// ---------------

// Initialize
//
procedure TODEJointFixed.Initialize;
begin
  if (not IsODEInitialized) or (FInitialized) then
    Exit;
  FJointID := dJointCreateFixed(FManager.World, nil);
  inherited;
end;

// WriteToFiler
//
procedure TODEJointFixed.WriteToFiler(writer: TWriter);
begin
  inherited;
  with writer do
  begin
    WriteInteger(0); // Archive version
  end;
end;

// ReadFromFiler
//
procedure TODEJointFixed.ReadFromFiler(reader: TReader);
begin
  inherited;
  with reader do
  begin
    Assert(ReadInteger = 0); // Archive version
  end;
end;

// FriendlyName
//
class function TODEJointFixed.FriendlyName: String;
begin
  Result := 'Fixed';
end;

// FriendlyDescription
//
class function TODEJointFixed.FriendlyDescription: String;
begin
  Result := 'ODE Fixed joint implementation';
end;


// ---------------
// --------------- TODEJointHinge2 ---------------
// ---------------

// Create
//
constructor TODEJointHinge2.Create(AOwner: TGLXCollection);
begin
  inherited;
  FAnchor := TGLCoordinates.CreateInitialized(Self, NullHmgPoint, csPoint);
  FAnchor.OnNotifyChange := AnchorChange;
  FAxis1 := TGLCoordinates.CreateInitialized(Self, ZHmgVector, csVector);
  FAxis1.OnNotifyChange := Axis1Change;
  FAxis2 := TGLCoordinates.CreateInitialized(Self, ZHmgVector, csVector);
  FAxis2.OnNotifyChange := Axis2Change;
  FAxis1Params := TODEJointParams.Create(Self);
  FAxis1Params.SetCallback := SetAxis1Param;
  FAxis1Params.GetCallback := GetAxis1Param;
  FAxis2Params := TODEJointParams.Create(Self);
  FAxis2Params.SetCallback := SetAxis2Param;
  FAxis2Params.GetCallback := GetAxis2Param;

  JointOptions := [joBothObjectsMustBeAssigned];
end;

// Destroy
destructor TODEJointHinge2.Destroy;
begin
  FAnchor.Free;
  FAxis1.Free;
  FAxis2.Free;
  FAxis1Params.Free;
  FAxis2Params.Free;
  inherited;
end;

// Initialize
//
procedure TODEJointHinge2.Initialize;
begin
  if (not IsODEInitialized) or (FInitialized) then
    Exit;
  FJointID := dJointCreateHinge2(FManager.World, nil);
  inherited;
end;

// WriteToFiler
//
procedure TODEJointHinge2.WriteToFiler(writer: TWriter);
begin
  inherited;
  with writer do
  begin
    WriteInteger(0); // Archive version
    FAnchor.WriteToFiler(writer);
    FAxis1.WriteToFiler(writer);
    FAxis2.WriteToFiler(writer);
    FAxis1Params.WriteToFiler(writer);
    FAxis2Params.WriteToFiler(writer);
  end;
end;

// ReadFromFiler
//
procedure TODEJointHinge2.ReadFromFiler(reader: TReader);
begin
  inherited;
  with reader do
  begin
    Assert(ReadInteger = 0); // Archive version
    FAnchor.ReadFromFiler(reader);
    FAxis1.ReadFromFiler(reader);
    FAxis2.ReadFromFiler(reader);
    FAxis1Params.ReadFromFiler(reader);
    FAxis2Params.ReadFromFiler(reader);
  end;
end;

// StructureChanged
//
procedure TODEJointHinge2.StructureChanged;
begin
  AnchorChange(nil);
  Axis1Change(nil);
  Axis2Change(nil);
  Axis1Params.ApplyFlagged;
  Axis2Params.ApplyFlagged;
end;

// AnchorChange
//
procedure TODEJointHinge2.AnchorChange(Sender: TObject);
begin
  if IsAttached then
    dJointSetHinge2Anchor(FJointID, FAnchor.X, FAnchor.Y, FAnchor.Z);
end;

// Axis1Change
//
procedure TODEJointHinge2.Axis1Change(Sender: TObject);
var
  vec: TVector;
begin
  vec := FAxis1.DirectVector;
  NormalizeVector(vec);
  FAxis1.DirectVector := vec;
  if IsAttached then
    dJointSetHinge2Axis1(FJointID, FAxis1.X, FAxis1.Y, FAxis1.Z);
end;

// Axis2Change
//
procedure TODEJointHinge2.Axis2Change(Sender: TObject);
var
  vec: TVector;
begin
  vec := FAxis2.DirectVector;
  NormalizeVector(vec);
  FAxis2.DirectVector := vec;
  if IsAttached then
    dJointSetHinge2Axis2(FJointID, FAxis2.X, FAxis2.Y, FAxis2.Z);
end;

// FriendlyName
//
class function TODEJointHinge2.FriendlyName: String;
begin
  Result := 'Hinge2';
end;

// FriendlyDescription
//
class function TODEJointHinge2.FriendlyDescription: String;
begin
  Result := 'ODE Double Axis Hinge joint implementation';
end;

// SetAnchor
//
procedure TODEJointHinge2.SetAnchor(const Value: TGLCoordinates);
begin
  FAnchor.Assign(Value);
end;

// SetAxis1
//
procedure TODEJointHinge2.SetAxis1(const Value: TGLCoordinates);
begin
  FAxis1.Assign(Value);
end;

// SetAxis2
//
procedure TODEJointHinge2.SetAxis2(const Value: TGLCoordinates);
begin
  FAxis2.Assign(Value);
end;

// SetAxis1Params
//
procedure TODEJointHinge2.SetAxis1Params(const Value: TODEJointParams);
begin
  Axis1Params.Assign(Value);
end;

// SetAxis2Params
//
procedure TODEJointHinge2.SetAxis2Params(const Value: TODEJointParams);
begin
  Axis2Params.Assign(Value);
end;

// SetAxis1Param
//
function TODEJointHinge2.SetAxis1Param(Param: Integer;
  const Value: TdReal): Boolean;
begin
  if IsAttached then
  begin
    dJointSetHinge2Param(JointID, Param, Value);
    Result := True;
  end
  else
    Result := False;
end;

// SetAxis2Param
//
function TODEJointHinge2.SetAxis2Param(Param: Integer;
  const Value: TdReal): Boolean;
begin
  if IsAttached then
  begin
    dJointSetHinge2Param(JointID, dParamLoStop2 + Param, Value);
    Result := True;
  end
  else
    Result := False;
end;

// GetAxis1Param
//
function TODEJointHinge2.GetAxis1Param(Param: Integer;
  var Value: TdReal): Boolean;
begin
  if IsAttached then
  begin
    Value := dJointGetHinge2Param(JointID, Param);
    Result := True;
  end
  else
    Result := False;
end;

// GetAxis2Param
//
function TODEJointHinge2.GetAxis2Param(Param: Integer;
  var Value: TdReal): Boolean;
begin
  if IsAttached then
  begin
    Value := dJointGetHinge2Param(JointID, dParamLoStop2 + Param);
    Result := True;
  end
  else
    Result := False;
end;


// ---------------
// --------------- TODEJointUniversal ---------------
// ---------------

// Create
//
constructor TODEJointUniversal.Create(AOwner: TGLXCollection);
begin
  inherited;
  FAnchor := TGLCoordinates.CreateInitialized(Self, NullHmgPoint, csPoint);
  FAnchor.OnNotifyChange := AnchorChange;
  FAxis1 := TGLCoordinates.CreateInitialized(Self, ZHmgVector, csVector);
  FAxis1.OnNotifyChange := Axis1Change;
  FAxis2 := TGLCoordinates.CreateInitialized(Self, XHmgVector, csVector);
  FAxis2.OnNotifyChange := Axis2Change;
  FAxis1Params := TODEJointParams.Create(Self);
  FAxis1Params.SetCallback := SetAxis1Param;
  FAxis1Params.GetCallback := GetAxis1Param;
  FAxis2Params := TODEJointParams.Create(Self);
  FAxis2Params.SetCallback := SetAxis2Param;
  FAxis2Params.GetCallback := GetAxis2Param;

  JointOptions := [joBothObjectsMustBeAssigned];
end;

// Destroy
destructor TODEJointUniversal.Destroy;
begin
  FAnchor.Free;
  FAxis1.Free;
  FAxis2.Free;
  FAxis1Params.Free;
  FAxis2Params.Free;
  inherited;
end;

// Initialize
//
procedure TODEJointUniversal.Initialize;
begin
  if (not IsODEInitialized) or (FInitialized) then
    Exit;
  FJointID := dJointCreateUniversal(FManager.World, nil);
  inherited;
end;

// WriteToFiler
//
procedure TODEJointUniversal.WriteToFiler(writer: TWriter);
begin
  inherited;
  with writer do
  begin
    WriteInteger(0); // Archive version
    FAnchor.WriteToFiler(writer);
    FAxis1.WriteToFiler(writer);
    FAxis2.WriteToFiler(writer);
    FAxis1Params.WriteToFiler(writer);
    FAxis2Params.WriteToFiler(writer);
  end;
end;

// ReadFromFiler
//
procedure TODEJointUniversal.ReadFromFiler(reader: TReader);
begin
  inherited;
  with reader do
  begin
    Assert(ReadInteger = 0); // Archive version
    FAnchor.ReadFromFiler(reader);
    FAxis1.ReadFromFiler(reader);
    FAxis2.ReadFromFiler(reader);
    FAxis1Params.ReadFromFiler(reader);
    FAxis2Params.ReadFromFiler(reader);
  end;
end;

// StructureChanged
//
procedure TODEJointUniversal.StructureChanged;
begin
  AnchorChange(nil);
  Axis1Change(nil);
  Axis2Change(nil);
  Axis1Params.ApplyFlagged;
  Axis2Params.ApplyFlagged;
end;

// AnchorChange
//
procedure TODEJointUniversal.AnchorChange(Sender: TObject);
begin
  if IsAttached then
    dJointSetUniversalAnchor(FJointID, FAnchor.X, FAnchor.Y, FAnchor.Z);
end;

// Axis1Change
//
procedure TODEJointUniversal.Axis1Change(Sender: TObject);
var
  vec: TVector;
begin
  vec := FAxis1.DirectVector;
  NormalizeVector(vec);
  FAxis1.DirectVector := vec;
  if IsAttached then
    dJointSetUniversalAxis1(FJointID, FAxis1.X, FAxis1.Y, FAxis1.Z);
end;

// Axis2Change
//
procedure TODEJointUniversal.Axis2Change(Sender: TObject);
var
  vec: TVector;
begin
  vec := FAxis2.DirectVector;
  NormalizeVector(vec);
  FAxis2.DirectVector := vec;
  if IsAttached then
    dJointSetUniversalAxis2(FJointID, FAxis2.X, FAxis2.Y, FAxis2.Z);
end;

// FriendlyName
//
class function TODEJointUniversal.FriendlyName: String;
begin
  Result := 'Universal';
end;

// FriendlyDescription
//
class function TODEJointUniversal.FriendlyDescription: String;
begin
  Result := 'ODE Universal joint implementation';
end;

// SetAnchor
//
procedure TODEJointUniversal.SetAnchor(const Value: TGLCoordinates);
begin
  FAnchor.Assign(Value);
end;

// SetAxis1
//
procedure TODEJointUniversal.SetAxis1(const Value: TGLCoordinates);
begin
  FAxis1.Assign(Value);
end;

// SetAxis2
//
procedure TODEJointUniversal.SetAxis2(const Value: TGLCoordinates);
begin
  FAxis2.Assign(Value);
end;

// SetAxis1Params
//
procedure TODEJointUniversal.SetAxis1Params(const Value: TODEJointParams);
begin
  Axis1Params.Assign(Value);
end;

// SetAxis2Params
//
procedure TODEJointUniversal.SetAxis2Params(const Value: TODEJointParams);
begin
  Axis2Params.Assign(Value);
end;

// SetAxis1Param
//
function TODEJointUniversal.SetAxis1Param(Param: Integer;
  const Value: TdReal): Boolean;
begin
  if IsAttached then
  begin
    dJointSetUniversalParam(JointID, Param, Value);
    Result := True;
  end
  else
    Result := False;
end;

// SetAxis2Param
//
function TODEJointUniversal.SetAxis2Param(Param: Integer;
  const Value: TdReal): Boolean;
begin
  if IsAttached then
  begin
    dJointSetUniversalParam(JointID, dParamLoStop2 + Param, Value);
    Result := True;
  end
  else
    Result := False;
end;

// GetAxis1Param
//
function TODEJointUniversal.GetAxis1Param(Param: Integer;
  var Value: TdReal): Boolean;
begin
  if IsAttached then
  begin
    Value := dJointGetUniversalParam(JointID, Param);
    Result := True;
  end
  else
    Result := False;
end;

// GetAxis2Param
//
function TODEJointUniversal.GetAxis2Param(Param: Integer;
  var Value: TdReal): Boolean;
begin
  if IsAttached then
  begin
    Value := dJointGetUniversalParam(JointID, dParamLoStop2 + Param);
    Result := True;
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

vGLODEObjectRegister := TList.Create;

RegisterXCollectionItemClass(TGLODEDynamic);
RegisterXCollectionItemClass(TGLODEStatic);

RegisterXCollectionItemClass(TODEElementBox);
RegisterXCollectionItemClass(TODEElementSphere);
RegisterXCollectionItemClass(TODEElementCapsule);
RegisterXCollectionItemClass(TODEElementCylinder);
RegisterXCollectionItemClass(TODEElementTriMesh);
RegisterXCollectionItemClass(TODEElementPlane);

RegisterXCollectionItemClass(TODEJointHinge);
RegisterXCollectionItemClass(TODEJointBall);
RegisterXCollectionItemClass(TODEJointSlider);
RegisterXCollectionItemClass(TODEJointFixed);
RegisterXCollectionItemClass(TODEJointHinge2);
RegisterXCollectionItemClass(TODEJointUniversal);

// ------------------------------------------------------------------
// ------------------------------------------------------------------
// ------------------------------------------------------------------
finalization

// ------------------------------------------------------------------
// ------------------------------------------------------------------
// ------------------------------------------------------------------

vGLODEObjectRegister.Free;

UnregisterXCollectionItemClass(TGLODEDynamic);
UnregisterXCollectionItemClass(TGLODEStatic);

UnregisterXCollectionItemClass(TODEElementBox);
UnregisterXCollectionItemClass(TODEElementSphere);
UnregisterXCollectionItemClass(TODEElementCapsule);
UnregisterXCollectionItemClass(TODEElementCylinder);
UnregisterXCollectionItemClass(TODEElementTriMesh);
UnregisterXCollectionItemClass(TODEElementPlane);

UnregisterXCollectionItemClass(TODEJointHinge);
UnregisterXCollectionItemClass(TODEJointBall);
UnregisterXCollectionItemClass(TODEJointSlider);
UnregisterXCollectionItemClass(TODEJointFixed);
UnregisterXCollectionItemClass(TODEJointHinge2);
UnregisterXCollectionItemClass(TODEJointUniversal);

// CloseODE;

end.