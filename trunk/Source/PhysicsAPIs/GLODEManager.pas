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
  01/03/03 - SG - Creation.
  The whole history is logged in previous version of the unit

}

unit GLODEManager;

interface

{$I GLScene.inc}

uses
  OpenGLTokens,
  System.Classes,
  System.SysUtils,
  System.Math,
  System.Types,
  GLScene,
  GLContext,
  GLVectorGeometry,
  GLTexture,
  GLObjects,
  GLXCollection,
  GLPersistentClasses,
  GLVectorLists,
  GLColor,
  GLCoordinates,
  GLRenderContextInfo,
  GLManager,
  GLState,
  GLVectorTypes,
  ODEGL,
  ODEImport,
  GLPipelineTransformation;

type
  TGLODECustomCollisionEvent = procedure(Geom1, Geom2: PdxGeom) of object;
  TGLODECollisionEvent = procedure(Sender: TObject; Object1, Object2: TObject;
    var Contact: TdContact; var HandleCollision: Boolean) of object;
  TGLODEObjectCollisionEvent = procedure(Sender: TObject; Object2: TObject;
    var Contact: TdContact; var HandleCollision: Boolean) of object;
  TGLODECollisionSurfaceMode = (csmMu2, csmFDir1, csmBounce, csmSoftERP,
    csmSoftCFM, csmMotion1, csmMotion2, csmSlip1, csmSlip2);
  TGLODESurfaceModes = set of TGLODECollisionSurfaceMode;
  TGLODESolverMethod = (osmDefault, osmStepFast, osmQuickStep);

  TGLODEElements = class;
  TGLODEBehaviour = class;
  TGLODEElementBase = class;
  TGLODEJointBase = class;

  TGLODEManager = class(TComponent)
  private
    FWorld: PdxWorld;
    FSpace: PdxSpace;
    FContactGroup: TdJointGroupID;
    FGravity: TGLCoordinates;
    FOnCollision: TGLODECollisionEvent;
    FOnCustomCollision: TGLODECustomCollisionEvent;
    FNumContactJoints, FMaxContacts: Integer;
    FODEBehaviours: TPersistentObjectList;
    FRFContactList: TList;
    FIterations: Integer;
    FSolver: TGLODESolverMethod;
    FContacts: array of TdContact;
    FContactGeoms: array of TdContactGeom;
    FRenderPoint: TGLRenderPoint;
    FVisible, FVisibleAtRunTime: Boolean;
    FGeomColorDynD, FGeomColorDynE, FGeomColorStat: TGLColor;
  protected
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
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Step(deltaTime: double);
    procedure NotifyChange(Sender: TObject);
    property World: PdxWorld read FWorld;
    property Space: PdxSpace read FSpace;
    property ContactGroup: TdJointGroupID read FContactGroup;
    property NumContactJoints: Integer read FNumContactJoints;
  published
    property Gravity: TGLCoordinates read FGravity write SetGravity;
    property OnCollision: TGLODECollisionEvent read FOnCollision
      write FOnCollision;
    property OnCustomCollision: TGLODECustomCollisionEvent read FOnCustomCollision
      write FOnCustomCollision;
    property Solver: TGLODESolverMethod read FSolver write FSolver;
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

  TGLODECollisionSurface = class(TPersistent)
  private
    FOwner: TPersistent;
    FSurfaceParams: TdSurfaceParameters;
    FRFCoeff: Single;
    FRFEnabled: Boolean;
  protected
    procedure WriteToFiler(writer: TWriter);
    procedure ReadFromFiler(reader: TReader);
    function GetSurfaceMode: TGLODESurfaceModes;
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

    procedure SetSurfaceMode(Value: TGLODESurfaceModes);
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
    constructor Create(AOwner: TPersistent);
    function GetOwner: TPersistent; override;
    procedure Assign(Source: TPersistent); override;
  published
    property RollingFrictionCoeff: Single read FRFCoeff write FRFCoeff;
    property RollingFrictionEnabled: Boolean read FRFEnabled write FRFEnabled;
    property SurfaceMode: TGLODESurfaceModes read GetSurfaceMode
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

  { Basis structures for GLScene behaviour style implementations. }
  TGLODEBehaviour = class(TGLBehaviour)
  private
    { Private Declartions }
    FManager: TGLODEManager;
    FManagerName: String;
    FSurface: TGLODECollisionSurface;
    FOnCollision: TGLODEObjectCollisionEvent;
    FInitialized: Boolean;
    FOwnerBaseSceneObject: TGLBaseSceneObject;
  protected
    procedure Initialize; virtual;
    procedure Finalize; virtual;

    procedure WriteToFiler(writer: TWriter); override;
    procedure ReadFromFiler(reader: TReader); override;
    procedure Loaded; override;

    procedure SetManager(Value: TGLODEManager);
    procedure SetSurface(Value: TGLODECollisionSurface);
    function GetAbsoluteMatrix: TMatrix;
  public
    constructor Create(AOwner: TGLXCollection); override;
    destructor Destroy; override;
    procedure NotifyChange(Sender: TObject);
    procedure Render(var rci: TGLRenderContextInfo); virtual;
    procedure Reinitialize;
    property Initialized: Boolean read FInitialized;
    property AbsoluteMatrix: TMatrix read GetAbsoluteMatrix;
  published
    property Manager: TGLODEManager read FManager write SetManager;
    property Surface: TGLODECollisionSurface read FSurface write SetSurface;
    property OnCollision: TGLODEObjectCollisionEvent read FOnCollision
      write FOnCollision;
  end;

  TGLODEDynamic = class(TGLODEBehaviour)
  private
    FBody: PdxBody;
    FMass: TdMass;
    FElements: TGLODEElements;
    FEnabled: Boolean;
    FJointRegister: TList;
  protected
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
    property Elements: TGLODEElements read FElements;
    property Enabled: Boolean read GetEnabled write SetEnabled;
  end;

  TGLODEStatic = class(TGLODEBehaviour)
  private
    FElements: TGLODEElements;
  protected
    procedure Initialize; override;
    procedure Finalize; override;
    procedure WriteToFiler(writer: TWriter); override;
    procedure ReadFromFiler(reader: TReader); override;
    procedure AlignElements;
  public
    constructor Create(AOwner: TGLXCollection); override;
    destructor Destroy; override;
    procedure Render(var rci: TGLRenderContextInfo); override;
    class function FriendlyName: String; override;
    class function UniqueItem: Boolean; override;
    function AddNewElement(AChild: TGLODEElementClass): TGLODEElementBase; dynamic;
  published
    property Elements: TGLODEElements read FElements;
  end;

  TGLODEElements = class(TGLXCollection)
  private
    function GetElement(index: Integer): TGLODEElementBase;
  public
    destructor Destroy; override;
    class function ItemsClass: TGLXCollectionItemClass; override;
    procedure Initialize;
    procedure Finalize;
    procedure NotifyChange(Sender: TObject);
    procedure Render(var rci: TGLRenderContextInfo);
    property Element[index: Integer]: TGLODEElementBase read GetElement;
  end;

  TGLODEElementBase = class(TGLXCollectionItem)
  private
    FMass: TdMass;
    FDensity: TdReal;
    FGeomTransform, FGeomElement: PdxGeom;
    FPosition, FDirection, FUp: TGLCoordinates;
    FLocalMatrix: TMatrix;
    FRealignODE, FInitialized, FDynamic, FIsCalculating: Boolean;
  protected
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
    property Density: TdReal read FDensity write SetDensity;
    property Position: TGLCoordinates read FPosition write SetPosition;
    property Direction: TGLCoordinates read FDirection write SetDirection;
    property Up: TGLCoordinates read FUp write SetUp;
  end;

  { ODE box implementation. }
  TODEElementBox = class(TGLODEElementBase)
  private
    FBoxWidth, FBoxHeight, FBoxDepth: TdReal;
  protected
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

  { ODE sphere implementation. }
  TODEElementSphere = class(TGLODEElementBase)
  private
    FRadius: TdReal;
  protected
    procedure Initialize; override;
    function CalculateMass: TdMass; override;
    procedure ODERebuild; override;
    procedure WriteToFiler(writer: TWriter); override;
    procedure ReadFromFiler(reader: TReader); override;
    function GetRadius: TdReal;
    procedure SetRadius(const Value: TdReal);
  public
    constructor Create(AOwner: TGLXCollection); override;
    procedure Render(var rci: TGLRenderContextInfo); override;
    class function FriendlyName: String; override;
    class function FriendlyDescription: String; override;
    class function ItemCategory: String; override;
  published
    property Radius: TdReal read GetRadius write SetRadius;
  end;

  { ODE capped cylinder implementation. }
  TODEElementCapsule = class(TGLODEElementBase)
  private
    FRadius, FLength: TdReal;
  protected
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
    constructor Create(AOwner: TGLXCollection); override;
    procedure Render(var rci: TGLRenderContextInfo); override;
    class function FriendlyName: String; override;
    class function FriendlyDescription: String; override;
    class function ItemCategory: String; override;
  published
    property Radius: TdReal read GetRadius write SetRadius;
    property Length: TdReal read GetLength write SetLength;
  end;

  { ODE cylinder implementation. }
  TODEElementCylinder = class(TGLODEElementBase)
  private
    FRadius, FLength: TdReal;
  protected
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
    constructor Create(AOwner: TGLXCollection); override;
    procedure Render(var rci: TGLRenderContextInfo); override;
    class function FriendlyName: String; override;
    class function FriendlyDescription: String; override;
    class function ItemCategory: String; override;
  published
    property Radius: TdReal read GetRadius write SetRadius;
    property Length: TdReal read GetLength write SetLength;
  end;

  { ODE tri-mesh implementation. }
  TGLODEElementTriMesh = class(TGLODEElementBase)
  private
    FTriMeshData: PdxTriMeshData;
    FVertices: TAffineVectorList;
    FIndices: TIntegerList;
  protected
    procedure Initialize; override;
    procedure Finalize; override;
    function CalculateMass: TdMass; override;
    procedure WriteToFiler(writer: TWriter); override;
    procedure ReadFromFiler(reader: TReader); override;
    procedure SetVertices(const Value: TAffineVectorList);
    procedure SetIndices(const Value: TIntegerList);
  public
    constructor Create(AOwner: TGLXCollection); override;
    destructor Destroy; override;
    class function FriendlyName: String; override;
    class function FriendlyDescription: String; override;
    class function ItemCategory: String; override;
    procedure RefreshTriMeshData;
    property Vertices: TAffineVectorList read FVertices write SetVertices;
    property Indices: TIntegerList read FIndices write SetIndices;
  end;

  { ODE plane implementation. }
  TODEElementPlane = class(TGLODEElementBase)
  protected
    procedure Initialize; override;
    procedure WriteToFiler(writer: TWriter); override;
    procedure ReadFromFiler(reader: TReader); override;
    procedure AlignGeomElementToMatrix(Mat: TMatrix); override;
  public
    class function FriendlyName: String; override;
    class function FriendlyDescription: String; override;
    class function ItemCategory: String; override;
    class function CanAddTo(collection: TGLXCollection): Boolean; override;
  end;

  { An XCollection decendant for ODE Joints. }
  TGLODEJoints = class(TGLXCollection)
  protected
    function GetJoint(index: Integer): TGLODEJointBase;
  public
    class function ItemsClass: TGLXCollectionItemClass; override;
    procedure Initialize;
    procedure Finalize;
    property Joint[index: Integer]: TGLODEJointBase read GetJoint; default;
  end;

  { Component front-end for storing ODE Joints. }
  TGLODEJointList = class(TComponent)
  private
    FJoints: TGLODEJoints;
  protected
    procedure WriteJoints(stream: TStream);
    procedure ReadJoints(stream: TStream);
    procedure DefineProperties(Filer: TFiler); override;
    procedure Loaded; override;
    procedure Notification(AComponent: TComponent;
      Operation: TOperation); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    property Joints: TGLODEJoints read FJoints;
  end;

  TJointOption = (joBothObjectsMustBeAssigned);
  TJointOptions = set of TJointOption;

  { Base structures for ODE Joints. }
  TGLODEJointBase = class(TGLXCollectionItem)
  private
    FJointID: TdJointID;
    FObject1, FObject2: TGLBaseSceneObject;
    FManager: TGLODEManager;
    FObject1Name, FObject2Name, FManagerName: String;
    FInitialized, FEnabled: Boolean;
    FJointOptions: TJointOptions;
  protected
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
    property JointOptions: TJointOptions read FJointOptions write SetJointOptions;
  public
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
    property Manager: TGLODEManager read FManager write SetManager;
    property Object1: TGLBaseSceneObject read FObject1 write SetObject1;
    property Object2: TGLBaseSceneObject read FObject2 write SetObject2;
    property Enabled: Boolean read FEnabled write SetEnabled;
  end;

  TGLODESetParamCallback = function(Param: Integer; const Value: TdReal)
    : Boolean of object;
  TGLODEGetParamCallback = function(Param: Integer; var Value: TdReal)
    : Boolean of object;

  TGLODEJointParams = class(TPersistent)
  private
    FOwner: TPersistent;
    FSetCallback: TGLODESetParamCallback;
    FGetCallback: TGLODEGetParamCallback;
    FLoStop, FHiStop, FVel, FFMax, FFudgeFactor, FBounce, FCFM, FStopERP,
      FStopCFM, FSuspensionERP, FSuspensionCFM: TdReal;
    FFlagLoStop, FFlagHiStop, FFlagVel, FFlagFMax, FFlagFudgeFactor,
      FFlagBounce, FFlagCFM, FFlagStopERP, FFlagStopCFM, FFlagSuspensionERP,
      FFlagSuspensionCFM: Boolean;
  protected
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
    constructor Create(AOwner: TPersistent);
    function GetOwner: TPersistent; override;
    procedure Assign(Source: TPersistent); override;
    procedure ApplyFlagged;
    property SetCallback: TGLODESetParamCallback read FSetCallback
      write FSetCallback;
    property GetCallback: TGLODEGetParamCallback read FGetCallback
      write FGetCallback;
  published
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

  { ODE hinge joint implementation. }
  TGLODEJointHinge = class(TGLODEJointBase)
  private
    FAnchor, FAxis: TGLCoordinates;
    FAxisParams: TGLODEJointParams;
  protected
    procedure WriteToFiler(writer: TWriter); override;
    procedure ReadFromFiler(reader: TReader); override;
    procedure SetAnchor(const Value: TGLCoordinates);
    procedure SetAxis(const Value: TGLCoordinates);
    procedure AnchorChange(Sender: TObject);
    procedure AxisChange(Sender: TObject);
    procedure SetAxisParams(const Value: TGLODEJointParams);
    function SetAxisParam(Param: Integer; const Value: TdReal): Boolean;
    function GetAxisParam(Param: Integer; var Value: TdReal): Boolean;
  public
    constructor Create(AOwner: TGLXCollection); override;
    destructor Destroy; override;
    procedure StructureChanged; override;
    procedure Initialize; override;
    class function FriendlyName: String; override;
    class function FriendlyDescription: String; override;
  published
    property Anchor: TGLCoordinates read FAnchor write SetAnchor;
    property Axis: TGLCoordinates read FAxis write SetAxis;
    property AxisParams: TGLODEJointParams read FAxisParams write SetAxisParams;
  end;

  { ODE ball joint implementation. }
  TGLODEJointBall = class(TGLODEJointBase)
  private
    FAnchor: TGLCoordinates;
  protected
    procedure WriteToFiler(writer: TWriter); override;
    procedure ReadFromFiler(reader: TReader); override;
    procedure SetAnchor(const Value: TGLCoordinates);
    procedure AnchorChange(Sender: TObject);
  public
    constructor Create(AOwner: TGLXCollection); override;
    destructor Destroy; override;
    procedure StructureChanged; override;
    procedure Initialize; override;
    class function FriendlyName: String; override;
    class function FriendlyDescription: String; override;
  published
    property Anchor: TGLCoordinates read FAnchor write SetAnchor;
  end;

  { ODE slider joint implementation. }
  TGLODEJointSlider = class(TGLODEJointBase)
  private
    FAxis: TGLCoordinates;
    FAxisParams: TGLODEJointParams;
  protected
    procedure WriteToFiler(writer: TWriter); override;
    procedure ReadFromFiler(reader: TReader); override;
    procedure SetAxis(const Value: TGLCoordinates);
    procedure AxisChange(Sender: TObject);
    procedure SetAxisParams(const Value: TGLODEJointParams);
    function SetAxisParam(Param: Integer; const Value: TdReal): Boolean;
    function GetAxisParam(Param: Integer; var Value: TdReal): Boolean;
  public
    constructor Create(AOwner: TGLXCollection); override;
    destructor Destroy; override;
    procedure StructureChanged; override;
    procedure Initialize; override;
    class function FriendlyName: String; override;
    class function FriendlyDescription: String; override;
  published
    property Axis: TGLCoordinates read FAxis write SetAxis;
    property AxisParams: TGLODEJointParams read FAxisParams write SetAxisParams;
  end;

  { ODE fixed joint implementation. }
  TGLODEJointFixed = class(TGLODEJointBase)
  protected
    procedure WriteToFiler(writer: TWriter); override;
    procedure ReadFromFiler(reader: TReader); override;
  public
    class function FriendlyName: String; override;
    class function FriendlyDescription: String; override;
    procedure Initialize; override;
  end;

  { ODE hinge2 joint implementation. }
  TGLODEJointHinge2 = class(TGLODEJointBase)
  private
    FAnchor, FAxis1, FAxis2: TGLCoordinates;
    FAxis1Params, FAxis2Params: TGLODEJointParams;
  protected
    procedure WriteToFiler(writer: TWriter); override;
    procedure ReadFromFiler(reader: TReader); override;
    procedure SetAnchor(const Value: TGLCoordinates);
    procedure SetAxis1(const Value: TGLCoordinates);
    procedure SetAxis2(const Value: TGLCoordinates);
    procedure AnchorChange(Sender: TObject);
    procedure Axis1Change(Sender: TObject);
    procedure Axis2Change(Sender: TObject);
    procedure SetAxis1Params(const Value: TGLODEJointParams);
    procedure SetAxis2Params(const Value: TGLODEJointParams);
    function SetAxis1Param(Param: Integer; const Value: TdReal): Boolean;
    function SetAxis2Param(Param: Integer; const Value: TdReal): Boolean;
    function GetAxis1Param(Param: Integer; var Value: TdReal): Boolean;
    function GetAxis2Param(Param: Integer; var Value: TdReal): Boolean;
  public
    constructor Create(AOwner: TGLXCollection); override;
    destructor Destroy; override;
    procedure StructureChanged; override;
    procedure Initialize; override;
    class function FriendlyName: String; override;
    class function FriendlyDescription: String; override;
  published
    property Anchor: TGLCoordinates read FAnchor write SetAnchor;
    property Axis1: TGLCoordinates read FAxis1 write SetAxis1;
    property Axis2: TGLCoordinates read FAxis2 write SetAxis2;
    property Axis1Params: TGLODEJointParams read FAxis1Params write SetAxis1Params;
    property Axis2Params: TGLODEJointParams read FAxis2Params write SetAxis2Params;
  end;

  { ODE universal joint implementation. }
  TGLODEJointUniversal = class(TGLODEJointBase)
  private
    FAnchor, FAxis1, FAxis2: TGLCoordinates;
    FAxis1Params, FAxis2Params: TGLODEJointParams;
  protected
    procedure WriteToFiler(writer: TWriter); override;
    procedure ReadFromFiler(reader: TReader); override;
    procedure SetAnchor(const Value: TGLCoordinates);
    procedure SetAxis1(const Value: TGLCoordinates);
    procedure SetAxis2(const Value: TGLCoordinates);
    procedure AnchorChange(Sender: TObject);
    procedure Axis1Change(Sender: TObject);
    procedure Axis2Change(Sender: TObject);
    procedure SetAxis1Params(const Value: TGLODEJointParams);
    procedure SetAxis2Params(const Value: TGLODEJointParams);
    function SetAxis1Param(Param: Integer; const Value: TdReal): Boolean;
    function SetAxis2Param(Param: Integer; const Value: TdReal): Boolean;
    function GetAxis1Param(Param: Integer; var Value: TdReal): Boolean;
    function GetAxis2Param(Param: Integer; var Value: TdReal): Boolean;
  public
    constructor Create(AOwner: TGLXCollection); override;
    destructor Destroy; override;
    procedure Initialize; override;
    procedure StructureChanged; override;
    class function FriendlyName: String; override;
    class function FriendlyDescription: String; override;
  published
    property Anchor: TGLCoordinates read FAnchor write SetAnchor;
    property Axis1: TGLCoordinates read FAxis1 write SetAxis1;
    property Axis2: TGLCoordinates read FAxis2 write SetAxis2;
    property Axis1Params: TGLODEJointParams read FAxis1Params
      write SetAxis1Params;
    property Axis2Params: TGLODEJointParams read FAxis2Params
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

procedure nearCallBack(Data: Pointer; o1, o2: PdxGeom); cdecl;
begin
  TGLODEManager(Data).Collision(o1, o2);
end;

function GetBodyFromObject(anObject: TObject): PdxBody;
begin
  Result := nil;
  if Assigned(anObject) then
    if anObject is TGLODEDynamic then
      Result := TGLODEDynamic(anObject).Body;
end;

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

procedure RegisterGLSceneObject(anObject: TGLBaseSceneObject);
begin
  if vGLODEObjectRegister.IndexOf(anObject) = -1 then
    vGLODEObjectRegister.Add(anObject);
end;

procedure UnregisterGLSceneObject(anObject: TGLBaseSceneObject);
begin
  vGLODEObjectRegister.Remove(anObject);
end;

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

function GetOdeStatic(Obj: TGLBaseSceneObject): TGLODEStatic;
begin
  Result := TGLODEStatic(Obj.Behaviours.GetByClass(TGLODEStatic));
end;

function GetOrCreateOdeStatic(Obj: TGLBaseSceneObject): TGLODEStatic;
begin
  Result := TGLODEStatic(Obj.GetOrCreateBehaviour(TGLODEStatic));
end;

function GetOdeDynamic(Obj: TGLBaseSceneObject): TGLODEDynamic;
begin
  Result := TGLODEDynamic(Obj.Behaviours.GetByClass(TGLODEDynamic));
end;

function GetOrCreateOdeDynamic(Obj: TGLBaseSceneObject): TGLODEDynamic;
begin
  Result := TGLODEDynamic(Obj.GetOrCreateBehaviour(TGLODEDynamic));
end;

// ---------------
// --------------- TGLODEManager ---------------
// ---------------
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

procedure TGLODEManager.RegisterODEBehaviour(ODEBehaviour: TGLODEBehaviour);
begin
  FODEBehaviours.Add(ODEBehaviour);
end;

procedure TGLODEManager.UnregisterODEBehaviour(ODEBehaviour: TGLODEBehaviour);
begin
  FODEBehaviours.Remove(ODEBehaviour);
end;

procedure TGLODEManager.Loaded;
begin
  GravityChange(Self);
end;

procedure TGLODEManager.SetGravity(Value: TGLCoordinates);
begin
  FGravity.SetPoint(Value.DirectX, Value.DirectY, Value.DirectZ);
end;

procedure TGLODEManager.GravityChange(Sender: TObject);
begin
  if Assigned(FWorld) then
    dWorldSetGravity(FWorld, FGravity.X, FGravity.Y, FGravity.Z);
end;

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
      // Creates and assign the contact joint
      Joint := dJointCreateContact(FWorld, FContactGroup, @FContacts[i]);
      dJointAttach(Joint, b1, b2);
      // Increment the number of contact joints this step
      Inc(FNumContactJoints);
    end;
  end;
end;

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

procedure TGLODEManager.NotifyChange(Sender: TObject);
begin
  if Assigned(RenderPoint) then
    RenderPoint.StructureChanged;
end;

procedure TGLODEManager.SetIterations(const val: Integer);
begin
  FIterations := val;
  if Assigned(FWorld) then
    dWorldSetQuickStepNumIterations(FWorld, FIterations);
end;

procedure TGLODEManager.SetMaxContacts(const Value: Integer);
begin
  if Value <> FMaxContacts then
  begin
    FMaxContacts := Value;
    SetLength(FContacts, FMaxContacts);
    SetLength(FContactGeoms, FMaxContacts);
  end;
end;

function TGLODEManager.GetODEBehaviour(index: Integer): TGLODEBehaviour;
begin
  Result := TGLODEBehaviour(FODEBehaviours[index]);
end;

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

procedure TGLODEManager.RenderPointFreed(Sender: TObject);
begin
  FRenderPoint := nil;
end;

procedure TGLODEManager.SetVisible(const Value: Boolean);
begin
  if Value <> FVisible then
  begin
    FVisible := Value;
    NotifyChange(Self);
  end;
end;

procedure TGLODEManager.SetVisibleAtRunTime(const Value: Boolean);
begin
  if Value <> FVisibleAtRunTime then
  begin
    FVisibleAtRunTime := Value;
    NotifyChange(Self);
  end;
end;

procedure TGLODEManager.SetGeomColorDynD(const Value: TGLColor);
begin
  FGeomColorDynD.Assign(Value);
  NotifyChange(Self);
end;

procedure TGLODEManager.GeomColorChangeDynD(Sender: TObject);
begin
  NotifyChange(Self);
end;

procedure TGLODEManager.SetGeomColorDynE(const Value: TGLColor);
begin
  FGeomColorDynE.Assign(Value);
  NotifyChange(Self);
end;

procedure TGLODEManager.GeomColorChangeDynE(Sender: TObject);
begin
  NotifyChange(Self);
end;

procedure TGLODEManager.SetGeomColorStat(const Value: TGLColor);
begin
  FGeomColorStat.Assign(Value);
  NotifyChange(Self);
end;

procedure TGLODEManager.GeomColorChangeStat(Sender: TObject);
begin
  NotifyChange(Self);
end;

// ---------------
// --------------- TGLODECollisionSurface ---------------
// ---------------

constructor TGLODECollisionSurface.Create(AOwner: TPersistent);
begin
  inherited Create;
  FOwner := AOwner;
  Mu := 1000;
  RollingFrictionEnabled := False;
  RollingFrictionCoeff := 0.001; // Larger Coeff = more friction
end;

function TGLODECollisionSurface.GetOwner: TPersistent;
begin
  Result := FOwner;
end;

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

procedure TGLODECollisionSurface.WriteToFiler(writer: TWriter);
var
  mode: TGLODESurfaceModes;
begin
  with writer do
  begin
    WriteInteger(0);
    WriteFloat(RollingFrictionCoeff);
    WriteBoolean(RollingFrictionEnabled);
    mode := SurfaceMode;
    Write(mode, SizeOf(TGLODESurfaceModes));
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

procedure TGLODECollisionSurface.ReadFromFiler(reader: TReader);
var
  archiveVersion: Integer;
  mode: TGLODESurfaceModes;
begin
  with reader do
  begin
    archiveVersion := ReadInteger;
    Assert(archiveVersion = 0);
    RollingFrictionCoeff := ReadFloat;
    RollingFrictionEnabled := ReadBoolean;
    Read(mode, SizeOf(TGLODESurfaceModes));
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

function TGLODECollisionSurface.GetSurfaceMode: TGLODESurfaceModes;
var
  ASurfaceModes: TGLODESurfaceModes;
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

procedure TGLODECollisionSurface.SetSurfaceMode(Value: TGLODESurfaceModes);
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
// --------------- TGLODEBehaviour --------------
// ---------------

constructor TGLODEBehaviour.Create(AOwner: TGLXCollection);
begin
  inherited;
  FSurface := TGLODECollisionSurface.Create(Self);
  FInitialized := False;
  FOwnerBaseSceneObject := OwnerBaseSceneObject;
  if Assigned(FOwnerBaseSceneObject) then
    RegisterGLSceneObject(OwnerBaseSceneObject);
end;

destructor TGLODEBehaviour.Destroy;
begin
  if Assigned(Manager) then
    Manager := nil;
  if Assigned(FOwnerBaseSceneObject) then
    UnregisterGLSceneObject(FOwnerBaseSceneObject);
  FSurface.Free;
  inherited;
end;

procedure TGLODEBehaviour.Initialize;
begin
  FInitialized := True;
end;

procedure TGLODEBehaviour.Finalize;
begin
  FInitialized := False;
end;

procedure TGLODEBehaviour.Reinitialize;
begin
  if Initialized then
    Finalize;
  Initialize;
end;

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

procedure TGLODEBehaviour.Render(var rci: TGLRenderContextInfo);
begin
  // virtual
end;

procedure TGLODEBehaviour.NotifyChange(Sender: TObject);
begin
  if Assigned(Manager) then
    Manager.NotifyChange(Self);
end;

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

procedure TGLODEBehaviour.SetSurface(Value: TGLODECollisionSurface);
begin
  FSurface.Assign(Value);
end;

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

constructor TGLODEDynamic.Create(AOwner: TGLXCollection);
begin
  inherited;
  FElements := TGLODEElements.Create(Self);
  FJointRegister := TList.Create;
  FEnabled := True;
end;

destructor TGLODEDynamic.Destroy;
begin
  FElements.Free;
  FJointRegister.Free;
  inherited;
end;

procedure TGLODEDynamic.Render(var rci: TGLRenderContextInfo);
var
  Mat: TMatrix;
begin
  if Assigned(Owner.Owner) then
  begin
    rci.PipelineTransformation.Push;
    Mat := TGLBaseSceneObject(Owner.Owner).AbsoluteMatrix;
    rci.PipelineTransformation.ModelMatrix^ := Mat;
  end;

  Elements.Render(rci);

  if Assigned(Owner.Owner) then
    rci.PipelineTransformation.Pop;
end;

class function TGLODEDynamic.FriendlyName: String;
begin
  Result := 'ODE Dynamic';
end;

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

procedure TGLODEDynamic.RegisterJoint(Joint: TGLODEJointBase);
begin
  if FJointRegister.IndexOf(Joint) = -1 then
    FJointRegister.Add(Joint);
end;

procedure TGLODEDynamic.UnregisterJoint(Joint: TGLODEJointBase);
begin
  if FJointRegister.IndexOf(Joint) > -1 then
    FJointRegister.Remove(Joint);
end;

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

procedure TGLODEDynamic.AlignBodyToMatrix(Mat: TMatrix);
var
  R: TdMatrix3;
begin
  if not Assigned(FBody) then
    Exit;
  R[0] := Mat.X.X;
  R[1] := Mat.Y.X;
  R[2] := Mat.Z.X;
  R[3] := 0;
  R[4] := Mat.X.Y;
  R[5] := Mat.Y.Y;
  R[6] := Mat.Z.Y;
  R[7] := 0;
  R[8] := Mat.X.Z;
  R[9] := Mat.Y.Z;
  R[10] := Mat.Z.Z;
  R[11] := 0;
  dBodySetRotation(FBody, R);
  dBodySetPosition(FBody, Mat.W.X, Mat.W.Y, Mat.W.Z);
end;

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

procedure TGLODEDynamic.CalibrateCenterOfMass;
var
  Pos: TAffineVector;
begin
  SetAffineVector(Pos, FMass.c[0], FMass.c[1], FMass.c[2]);
  NegateVector(Pos);
  dMassTranslate(FMass, Pos.X, Pos.Y, Pos.Z);
end;

function TGLODEDynamic.GetMass: TdMass;
begin
  dBodyGetMass(FBody, FMass);
  Result := FMass;
end;

procedure TGLODEDynamic.SetMass(const Value: TdMass);
begin
  FMass := Value;
  if FMass.Mass > 0 then
    dBodySetMass(FBody, @FMass);
end;

class function TGLODEDynamic.UniqueItem: Boolean;
begin
  Result := True;
end;

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

function TGLODEDynamic.GetEnabled: Boolean;
begin
  if Assigned(FBody) then
    FEnabled := (dBodyIsEnabled(FBody) = 1);
  Result := FEnabled;
end;

procedure TGLODEDynamic.AddForce(Force: TAffineVector);
begin
  if Assigned(FBody) then
    dBodyAddForce(FBody, Force.X, Force.Y, Force.Z);
end;

procedure TGLODEDynamic.AddForceAtPos(Force, Pos: TAffineVector);
begin
  if Assigned(FBody) then
    dBodyAddForceAtPos(FBody, Force.X, Force.Y, Force.Z, Pos.X,
      Pos.Y, Pos.Z);
end;

procedure TGLODEDynamic.AddForceAtRelPos(Force, Pos: TAffineVector);
begin
  if Assigned(FBody) then
    dBodyAddForceAtRelPos(FBody, Force.X, Force.Y, Force.Z, Pos.X,
      Pos.Y, Pos.Z);
end;

procedure TGLODEDynamic.AddRelForce(Force: TAffineVector);
begin
  if Assigned(FBody) then
    dBodyAddRelForce(FBody, Force.X, Force.Y, Force.Z);
end;

procedure TGLODEDynamic.AddRelForceAtPos(Force, Pos: TAffineVector);
begin
  if Assigned(FBody) then
    dBodyAddForceAtPos(FBody, Force.X, Force.Y, Force.Z, Pos.X,
      Pos.Y, Pos.Z);
end;

procedure TGLODEDynamic.AddRelForceAtRelPos(Force, Pos: TAffineVector);
begin
  if Assigned(FBody) then
    dBodyAddRelForceAtRelPos(FBody, Force.X, Force.Y, Force.Z,
      Pos.X, Pos.Y, Pos.Z);
end;

procedure TGLODEDynamic.AddTorque(Torque: TAffineVector);
begin
  if Assigned(FBody) then
    dBodyAddTorque(FBody, Torque.X, Torque.Y, Torque.Z);
end;

procedure TGLODEDynamic.AddRelTorque(Torque: TAffineVector);
begin
  if Assigned(FBody) then
    dBodyAddRelTorque(FBody, Torque.X, Torque.Y, Torque.Z);
end;


// ---------------
// --------------- TGLODEStatic ---------------
// ---------------

constructor TGLODEStatic.Create(AOwner: TGLXCollection);
begin
  inherited;
  FElements := TGLODEElements.Create(Self);
end;

destructor TGLODEStatic.Destroy;
begin
  FElements.Free;
  inherited;
end;

procedure TGLODEStatic.Render(var rci: TGLRenderContextInfo);
var
  Mat: TMatrix;
begin
  if Assigned(Owner.Owner) then
  begin
    rci.PipelineTransformation.Push;
    Mat := TGLBaseSceneObject(Owner.Owner).AbsoluteMatrix;
    rci.PipelineTransformation.ModelMatrix^ := Mat;
  end;

  Elements.Render(rci);

  if Assigned(Owner.Owner) then
    rci.PipelineTransformation.Pop;
end;

class function TGLODEStatic.FriendlyName: String;
begin
  Result := 'ODE Static';
end;

class function TGLODEStatic.UniqueItem: Boolean;
begin
  Result := True;
end;

procedure TGLODEStatic.Initialize;
begin
  if (not Assigned(Manager)) or (FInitialized) then
    Exit;
  if not Assigned(Manager.Space) then
    Exit;

  FElements.Initialize;

  inherited;
end;

procedure TGLODEStatic.Finalize;
begin
  if not FInitialized then
    Exit;
  FElements.Finalize;

  inherited;
end;

procedure TGLODEStatic.WriteToFiler(writer: TWriter);
begin
  inherited;
  with writer do
  begin
    WriteInteger(0); // Archive version
    FElements.WriteToFiler(writer);
  end;
end;

procedure TGLODEStatic.ReadFromFiler(reader: TReader);
begin
  inherited;
  with reader do
  begin
    Assert(ReadInteger = 0); // Archive version
    FElements.ReadFromFiler(reader);
  end;
end;

function TGLODEStatic.AddNewElement(AChild: TGLODEElementClass): TGLODEElementBase;
begin
  Result := nil;
  if not Assigned(Manager) then
    Exit;
  Result := AChild.Create(FElements);
  FElements.Add(Result);
  Result.Initialize;
end;

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
// --------------- TGLODEElements ---------------
// ---------------
destructor TGLODEElements.Destroy;
begin
  Finalize;
  inherited;
end;

function TGLODEElements.GetElement(index: Integer): TGLODEElementBase;
begin
  Result := TGLODEElementBase(Items[index]);
end;

class function TGLODEElements.ItemsClass: TGLXCollectionItemClass;
begin
  Result := TGLODEElementBase;
end;

procedure TGLODEElements.Initialize;
var
  i: Integer;
begin
  for i := 0 to Count - 1 do
    TGLODEElementBase(Items[i]).Initialize;
end;

procedure TGLODEElements.Finalize;
var
  i: Integer;
begin
  for i := 0 to Count - 1 do
    TGLODEElementBase(Items[i]).Finalize;
end;

procedure TGLODEElements.Render(var rci: TGLRenderContextInfo);
var
  i: Integer;
begin
  for i := 0 to Count - 1 do
    TGLODEElementBase(Items[i]).Render(rci);
end;

procedure TGLODEElements.NotifyChange(Sender: TObject);
begin
  if Assigned(Owner) then
    if Owner is TGLODEBehaviour then
      TGLODEBehaviour(Owner).NotifyChange(Self);
end;


// ---------------
// --------------- TGLODEElementBase ---------------
// ---------------

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

destructor TGLODEElementBase.Destroy;
begin
  if FInitialized then
    Finalize;
  FPosition.Free;
  FDirection.Free;
  FUp.Free;
  inherited;
end;

procedure TGLODEElementBase.Render(var rci: TGLRenderContextInfo);
begin
  // Override this procedure with element drawing OpenGL code
end;

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

function TGLODEElementBase.AbsoluteMatrix: TMatrix;
var
  Mat: TMatrix;
begin
  Mat := IdentityHMGMatrix;
  if Owner.Owner is TGLODEBehaviour then
    Mat := TGLODEBehaviour(Owner.Owner).AbsoluteMatrix;
  Result := MatrixMultiply(Mat, FLocalMatrix);
end;

function TGLODEElementBase.AbsolutePosition: TAffineVector;
begin
  Result := AffineVectorMake(AbsoluteMatrix.W);
end;

procedure TGLODEElementBase.AlignGeomElementToMatrix(Mat: TMatrix);
var
  R: TdMatrix3;
begin
  if not Assigned(FGeomElement) then
    Exit;
  dGeomSetPosition(FGeomElement, Mat.W.X, Mat.W.Y, Mat.W.Z);
  R[0] := Mat.X.X;
  R[1] := Mat.Y.X;
  R[2] := Mat.Z.X;
  R[3] := 0;
  R[4] := Mat.X.Y;
  R[5] := Mat.Y.Y;
  R[6] := Mat.Z.Y;
  R[7] := 0;
  R[8] := Mat.X.Z;
  R[9] := Mat.Y.Z;
  R[10] := Mat.Z.Z;
  R[11] := 0;
  dGeomSetRotation(FGeomElement, R);
  FRealignODE := False;
end;

procedure TGLODEElementBase.SetGeomElement(aGeom: PdxGeom);
begin
  FGeomElement := aGeom;
end;

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

function TGLODEElementBase.CalculateMass: TdMass;
var
  R: TdMatrix3;
begin
  R[0] := FLocalMatrix.X.X;
  R[1] := FLocalMatrix.Y.X;
  R[2] := FLocalMatrix.Z.X;
  R[3] := 0;
  R[4] := FLocalMatrix.X.Y;
  R[5] := FLocalMatrix.Y.Y;
  R[6] := FLocalMatrix.Z.Y;
  R[7] := 0;
  R[8] := FLocalMatrix.X.Z;
  R[9] := FLocalMatrix.Y.Z;
  R[10] := FLocalMatrix.Z.Z;
  R[11] := 0;
  dMassRotate(FMass, R);
  dMassTranslate(FMass, FLocalMatrix.W.X, FLocalMatrix.W.Y,
    FLocalMatrix.W.Z);
  Result := FMass;
end;

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

procedure TGLODEElementBase.NotifyChange(Sender: TObject);
begin
  RebuildMatrix;
  ODERebuild;
end;

function TGLODEElementBase.GetMatrix: TMatrix;
begin
  Result := FLocalMatrix;
end;

procedure TGLODEElementBase.RebuildMatrix;
begin
  VectorCrossProduct(FUp.AsVector, FDirection.AsVector, FLocalMatrix.X);
  SetVector(FLocalMatrix.Y, FUp.AsVector);
  SetVector(FLocalMatrix.Z, FDirection.AsVector);
  SetVector(FLocalMatrix.W, FPosition.AsVector);
end;

procedure TGLODEElementBase.RebuildVectors;
begin
  FUp.SetVector(FLocalMatrix.Y.X, FLocalMatrix.Y.Y,
    FLocalMatrix.Y.Z);
  FDirection.SetVector(FLocalMatrix.Z.X, FLocalMatrix.Z.Y,
    FLocalMatrix.Z.Z);
  FPosition.SetPoint(FLocalMatrix.W.X, FLocalMatrix.W.Y,
    FLocalMatrix.W.Z);
end;

procedure TGLODEElementBase.SetDensity(const Value: TdReal);
begin
  FDensity := Value;
end;

procedure TGLODEElementBase.SetMatrix(const Value: TMatrix);
begin
  FLocalMatrix := Value;
  RebuildVectors;
  ODERebuild;
end;

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

procedure TGLODEElementBase.SetPosition(const Value: TGLCoordinates);
begin
  FPosition.Assign(Value);
end;

procedure TGLODEElementBase.SetDirection(const Value: TGLCoordinates);
begin
  FDirection.Assign(Value);
end;

procedure TGLODEElementBase.SetUp(const Value: TGLCoordinates);
begin
  FUp.Assign(Value);
end;


// ---------------
// --------------- TODEElementBox ---------------
// ---------------

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

constructor TODEElementBox.Create(AOwner: TGLXCollection);
begin
  inherited;
  BoxWidth := 1;
  BoxHeight := 1;
  BoxDepth := 1;
end;

procedure TODEElementBox.Initialize;
begin
  if FInitialized then
    Exit;
  if not IsODEInitialized then
    Exit;

  FGeomElement := dCreateBox(nil, FBoxWidth, FBoxHeight, FBoxDepth);
  inherited;
end;

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

class function TODEElementBox.FriendlyName: String;
begin
  Result := 'Box';
end;

class function TODEElementBox.FriendlyDescription: String;
begin
  Result := 'The ODE box element implementation';
end;

class function TODEElementBox.ItemCategory: String;
begin
  Result := 'Primitives';
end;

function TODEElementBox.CalculateMass: TdMass;
begin
  dMassSetBox(FMass, FDensity, BoxWidth, BoxHeight, BoxDepth);
  Result := inherited CalculateMass;
end;

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

procedure TODEElementBox.ODERebuild;
begin
  if Assigned(Geom) then
    dGeomBoxSetLengths(Geom, FBoxWidth, FBoxHeight, FBoxDepth);
  inherited;
end;

procedure TODEElementBox.SetBoxWidth(const Value: TdReal);
begin
  FBoxWidth := Value;
  ODERebuild;
end;

procedure TODEElementBox.SetBoxHeight(const Value: TdReal);
begin
  FBoxHeight := Value;
  ODERebuild;
end;

procedure TODEElementBox.SetBoxDepth(const Value: TdReal);
begin
  FBoxDepth := Value;
  ODERebuild;
end;


// ---------------
// --------------- TODEElementSphere ---------------
// ---------------

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

constructor TODEElementSphere.Create(AOwner: TGLXCollection);
begin
  inherited;
  FRadius := 0.5;
end;

procedure TODEElementSphere.Initialize;
begin
  if FInitialized then
    Exit;
  if not IsODEInitialized then
    Exit;

  FGeomElement := dCreateSphere(nil, FRadius);
  inherited;
end;

procedure TODEElementSphere.WriteToFiler(writer: TWriter);
begin
  inherited;
  with writer do
  begin
    WriteInteger(0); // Archive version
    WriteFloat(Radius);
  end;
end;

procedure TODEElementSphere.ReadFromFiler(reader: TReader);
begin
  inherited;
  with reader do
  begin
    Assert(ReadInteger = 0); // Archive version
    Radius := ReadFloat;
  end;
end;

class function TODEElementSphere.FriendlyName: String;
begin
  Result := 'Sphere';
end;

class function TODEElementSphere.FriendlyDescription: String;
begin
  Result := 'The ODE sphere element implementation';
end;

class function TODEElementSphere.ItemCategory: String;
begin
  Result := 'Primitives';
end;

function TODEElementSphere.CalculateMass: TdMass;
begin
  dMassSetSphere(FMass, FDensity, Radius);
  Result := inherited CalculateMass;
end;

function TODEElementSphere.GetRadius: TdReal;
begin
  if Assigned(FGeomElement) then
    FRadius := dGeomSphereGetRadius(FGeomElement);
  Result := FRadius;
end;

procedure TODEElementSphere.ODERebuild;
begin
  if Assigned(Geom) then
  begin
    dGeomSphereSetRadius(Geom, FRadius);
  end;
  inherited;
end;

procedure TODEElementSphere.SetRadius(const Value: TdReal);
begin
  FRadius := Value;
  ODERebuild;
end;


// ---------------
// --------------- TODEElementCapsule ---------------
// ---------------

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

 
//
constructor TODEElementCapsule.Create(AOwner: TGLXCollection);
begin
  inherited;
  FRadius := 0.5;
  FLength := 1;
end;

procedure TODEElementCapsule.Initialize;
begin
  if FInitialized then
    Exit;
  if not IsODEInitialized then
    Exit;

  FGeomElement := dCreateCapsule(nil, FRadius, FLength);
  inherited;
end;

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

class function TODEElementCapsule.FriendlyName: String;
begin
  Result := 'Capsule';
end;

class function TODEElementCapsule.FriendlyDescription: String;
begin
  Result := 'The ODE capped cylinder element implementation';
end;

class function TODEElementCapsule.ItemCategory: String;
begin
  Result := 'Primitives';
end;

function TODEElementCapsule.CalculateMass: TdMass;
begin
  dMassSetCapsule(FMass, FDensity, 3, FRadius, FLength);
  Result := inherited CalculateMass;
end;

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

procedure TODEElementCapsule.ODERebuild;
begin
  if Assigned(Geom) then
    dGeomCapsuleSetParams(Geom, FRadius, FLength);
  inherited;
end;

procedure TODEElementCapsule.SetRadius(const Value: TdReal);
begin
  FRadius := Value;
  ODERebuild;
end;

procedure TODEElementCapsule.SetLength(const Value: TdReal);
begin
  FLength := Value;
  ODERebuild;
end;


// ---------------
// --------------- TODEElementCylinder ---------------
// ---------------

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

constructor TODEElementCylinder.Create(AOwner: TGLXCollection);
begin
  inherited;
  FRadius := 0.5;
  FLength := 1;
end;

procedure TODEElementCylinder.Initialize;
begin
  if FInitialized then
    Exit;
  if not IsODEInitialized then
    Exit;

  FGeomElement := dCreateCylinder(nil, FRadius, FLength);
  inherited;
end;

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

class function TODEElementCylinder.FriendlyName: String;
begin
  Result := 'Cylinder';
end;

class function TODEElementCylinder.FriendlyDescription: String;
begin
  Result := 'The ODE cylinder element implementation';
end;

class function TODEElementCylinder.ItemCategory: String;
begin
  Result := 'Primitives';
end;

function TODEElementCylinder.CalculateMass: TdMass;
begin
  dMassSetCylinder(FMass, FDensity, 3, FRadius, FLength);
  Result := inherited CalculateMass;
end;

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

procedure TODEElementCylinder.ODERebuild;
begin
  if Assigned(Geom) then
    dGeomCylinderSetParams(Geom, FRadius, FLength);
  inherited;
end;

procedure TODEElementCylinder.SetRadius(const Value: TdReal);
begin
  FRadius := Value;
  ODERebuild;
end;

procedure TODEElementCylinder.SetLength(const Value: TdReal);
begin
  FLength := Value;
  ODERebuild;
end;

// ---------------
// --------------- TGLODEElementTriMesh ---------------
// ---------------

constructor TGLODEElementTriMesh.Create(AOwner: TGLXCollection);
begin
  inherited;
  FVertices := TAffineVectorList.Create;
  FIndices := TIntegerList.Create;
end;

destructor TGLODEElementTriMesh.Destroy;
begin
  FVertices.Free;
  FIndices.Free;
  inherited;
end;

procedure TGLODEElementTriMesh.Initialize;
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

procedure TGLODEElementTriMesh.Finalize;
begin
  if not FInitialized then
    Exit;
  if Assigned(FTriMeshData) then
    dGeomTriMeshDataDestroy(FTriMeshData);
  inherited;
end;

procedure TGLODEElementTriMesh.WriteToFiler(writer: TWriter);
begin
  inherited;
  with writer do
  begin
    WriteInteger(0); // Archive version
  end;
end;

procedure TGLODEElementTriMesh.ReadFromFiler(reader: TReader);
begin
  inherited;
  with reader do
  begin
    Assert(ReadInteger = 0); // Archive version
  end;
end;

class function TGLODEElementTriMesh.FriendlyName: String;
begin
  Result := 'Tri-Mesh';
end;

class function TGLODEElementTriMesh.FriendlyDescription: String;
begin
  Result := 'The ODE tri-mesh element implementation';
end;

class function TGLODEElementTriMesh.ItemCategory: String;
begin
  Result := 'Meshes';
end;

function TGLODEElementTriMesh.CalculateMass: TdMass;
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

procedure TGLODEElementTriMesh.SetVertices(const Value: TAffineVectorList);
begin
  FVertices.Assign(Value);
  RefreshTriMeshData;
end;

procedure TGLODEElementTriMesh.SetIndices(const Value: TIntegerList);
begin
  FIndices.Assign(Value);
  RefreshTriMeshData;
end;

procedure TGLODEElementTriMesh.RefreshTriMeshData;
begin
  if FInitialized then
    Finalize;
  Initialize;
end;


// ---------------
// --------------- TODEElementPlane ---------------
// ---------------

procedure TODEElementPlane.Initialize;
begin
  if FInitialized then
    Exit;
  if not IsODEInitialized then
    Exit;

  FGeomElement := dCreatePlane(nil, 0, 0, 1, 0);
  inherited;
end;

procedure TODEElementPlane.WriteToFiler(writer: TWriter);
begin
  // ArchiveVersion 1, added inherited call
  writer.WriteInteger(1);
  inherited;
end;

procedure TODEElementPlane.ReadFromFiler(reader: TReader);
var
  archiveVersion: Integer;
begin
  archiveVersion := reader.ReadInteger;
  Assert(archiveVersion in [0 .. 1]);
  if archiveVersion >= 1 then
    inherited;
end;

class function TODEElementPlane.FriendlyName: String;
begin
  Result := 'Plane';
end;

class function TODEElementPlane.FriendlyDescription: String;
begin
  Result := 'The ODE plane element implementation';
end;

class function TODEElementPlane.ItemCategory: String;
begin
  Result := 'Primitives';
end;

class function TODEElementPlane.CanAddTo(collection: TGLXCollection): Boolean;
begin
  Result := False;
  if Assigned(TGLODEElements(collection).Owner) then
    if TGLODEElements(collection).Owner is TGLODEStatic then
      Result := True;
end;

procedure TODEElementPlane.AlignGeomElementToMatrix(Mat: TMatrix);
var
  d: Single;
begin
  if not Assigned(FGeomElement) then
    Exit;
  d := VectorDotProduct(Mat.Z, Mat.W);
  dGeomPlaneSetParams(FGeomElement, Mat.Z.X, Mat.Z.Y,
    Mat.Z.Z, d);
end;


// ---------------
// --------------- TGLODEJoints ---------------
// ---------------

class function TGLODEJoints.ItemsClass: TGLXCollectionItemClass;
begin
  Result := TGLODEJointBase;
end;

procedure TGLODEJoints.Initialize;
var
  i: Integer;
begin
  for i := 0 to Count - 1 do
    Joint[i].Initialize;
end;

procedure TGLODEJoints.Finalize;
var
  i: Integer;
begin
  for i := 0 to Count - 1 do
    Joint[i].Finalize;
end;

function TGLODEJoints.GetJoint(index: Integer): TGLODEJointBase;
begin
  Result := TGLODEJointBase(Items[index]);
end;


// ---------------
// --------------- TGLODEJointList ---------------
// ---------------

constructor TGLODEJointList.Create(AOwner: TComponent);
begin
  inherited;
  FJoints := TGLODEJoints.Create(Self);
end;

destructor TGLODEJointList.Destroy;
begin
  FJoints.Free;
  inherited;
end;

procedure TGLODEJointList.DefineProperties(Filer: TFiler);
begin
  inherited;
  Filer.DefineBinaryProperty('ODEJointsData', ReadJoints, WriteJoints,
    (Assigned(FJoints) and (FJoints.Count > 0)));
end;

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

procedure TGLODEJointList.Loaded;
var
  i: Integer;
begin
  inherited;
  for i := 0 to FJoints.Count - 1 do
    FJoints[i].Loaded;
end;

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

constructor TGLODEJointBase.Create(AOwner: TGLXCollection);
begin
  inherited;
  FJointID := nil;
  FEnabled := True;
  FInitialized := False;
end;

destructor TGLODEJointBase.Destroy;
begin
  Finalize;
  inherited;
end;

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

procedure TGLODEJointBase.Loaded;
begin
  DoLoaded;
end;

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

function TGLODEJointBase.IsODEInitialized: Boolean;
begin
  Result := False;
  if not Assigned(Manager) then
    Exit;
  Result := Assigned(Manager.World);
end;

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

procedure TGLODEJointBase.SetEnabled(const Value: Boolean);
begin
  if FEnabled <> Value then
  begin
    FEnabled := Value;
    if IsODEInitialized then
      Attach;
  end;
end;

procedure TGLODEJointBase.StructureChanged;
begin
  // nothing yet
end;

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

procedure TGLODEJointBase.SetJointOptions(const Value: TJointOptions);
begin
  if Value <> FJointOptions then
  begin
    FJointOptions := Value;
    Attach;
  end;
end;


// ---------------
// --------------- TGLODEJointParams ---------------
// ---------------

constructor TGLODEJointParams.Create(AOwner: TPersistent);
begin
  inherited Create;
  FOwner := AOwner;
end;

function TGLODEJointParams.GetOwner: TPersistent;
begin
  Result := FOwner;
end;

procedure TGLODEJointParams.Assign(Source: TPersistent);
begin
  inherited;
  if not Assigned(Source) then
    Exit;
  if Source is TGLODEJointParams then
  begin
    LoStop := TGLODEJointParams(Source).LoStop;
    HiStop := TGLODEJointParams(Source).HiStop;
    Vel := TGLODEJointParams(Source).Vel;
    FMax := TGLODEJointParams(Source).FMax;
    FudgeFactor := TGLODEJointParams(Source).FudgeFactor;
    Bounce := TGLODEJointParams(Source).Bounce;
    CFM := TGLODEJointParams(Source).CFM;
    StopERP := TGLODEJointParams(Source).StopERP;
    StopCFM := TGLODEJointParams(Source).StopCFM;
    SuspensionERP := TGLODEJointParams(Source).SuspensionERP;
    SuspensionCFM := TGLODEJointParams(Source).SuspensionCFM;
  end;
end;

procedure TGLODEJointParams.WriteToFiler(writer: TWriter);
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

procedure TGLODEJointParams.ReadFromFiler(reader: TReader);
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

function TGLODEJointParams.GetLoStop: TdReal;
begin
  if Assigned(GetCallback) then
    GetCallback(dParamLoStop1, FLoStop);
  Result := FLoStop;
end;

function TGLODEJointParams.GetHiStop: TdReal;
begin
  if Assigned(GetCallback) then
    GetCallback(dParamHiStop1, FHiStop);
  Result := FHiStop;
end;

function TGLODEJointParams.GetVel: TdReal;
begin
  if Assigned(GetCallback) then
    GetCallback(dParamVel1, FVel);
  Result := FVel;
end;

function TGLODEJointParams.GetFMax: TdReal;
begin
  if Assigned(GetCallback) then
    GetCallback(dParamFMax1, FFMax);
  Result := FFMax;
end;

function TGLODEJointParams.GetFudgeFactor: TdReal;
begin
  if Assigned(GetCallback) then
    GetCallback(dParamFudgeFactor1, FFudgeFactor);
  Result := FFudgeFactor;
end;

function TGLODEJointParams.GetBounce: TdReal;
begin
  if Assigned(GetCallback) then
    GetCallback(dParamBounce1, FBounce);
  Result := FBounce;
end;

function TGLODEJointParams.GetCFM: TdReal;
begin
  if Assigned(GetCallback) then
    GetCallback(dParamCFM1, FCFM);
  Result := FCFM;
end;

function TGLODEJointParams.GetStopERP: TdReal;
begin
  if Assigned(GetCallback) then
    GetCallback(dParamStopERP1, FStopERP);
  Result := FStopERP;
end;

function TGLODEJointParams.GetStopCFM: TdReal;
begin
  if Assigned(GetCallback) then
    GetCallback(dParamStopCFM1, FStopCFM);
  Result := FStopCFM;
end;

function TGLODEJointParams.GetSuspensionERP: TdReal;
begin
  if Assigned(GetCallback) then
    GetCallback(dParamSuspensionERP, FSuspensionERP);
  Result := FSuspensionERP;
end;

function TGLODEJointParams.GetSuspensionCFM: TdReal;
begin
  if Assigned(GetCallback) then
    GetCallback(dParamSuspensionCFM, FSuspensionCFM);
  Result := FSuspensionCFM;
end;

procedure TGLODEJointParams.SetLoStop(const Value: TdReal);
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

procedure TGLODEJointParams.SetHiStop(const Value: TdReal);
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

procedure TGLODEJointParams.SetVel(const Value: TdReal);
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

procedure TGLODEJointParams.SetFMax(const Value: TdReal);
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

procedure TGLODEJointParams.SetFudgeFactor(const Value: TdReal);
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

procedure TGLODEJointParams.SetBounce(const Value: TdReal);
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

procedure TGLODEJointParams.SetCFM(const Value: TdReal);
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

procedure TGLODEJointParams.SetStopERP(const Value: TdReal);
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

procedure TGLODEJointParams.SetStopCFM(const Value: TdReal);
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

procedure TGLODEJointParams.SetSuspensionERP(const Value: TdReal);
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

procedure TGLODEJointParams.SetSuspensionCFM(const Value: TdReal);
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

procedure TGLODEJointParams.ApplyFlagged;
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
// --------------- TGLODEJointHinge ---------------
// ---------------

constructor TGLODEJointHinge.Create(AOwner: TGLXCollection);
begin
  inherited;
  FAnchor := TGLCoordinates.CreateInitialized(Self, NullHmgPoint, csPoint);
  FAnchor.OnNotifyChange := AnchorChange;
  FAxis := TGLCoordinates.CreateInitialized(Self, ZHmgVector, csVector);
  FAxis.OnNotifyChange := AxisChange;
  FAxisParams := TGLODEJointParams.Create(Self);
  FAxisParams.SetCallback := SetAxisParam;
  FAxisParams.GetCallback := GetAxisParam;

end;

 
destructor TGLODEJointHinge.Destroy;
begin
  FAnchor.Free;
  FAxis.Free;
  FAxisParams.Free;
  inherited;
end;

procedure TGLODEJointHinge.Initialize;
begin
  if (not IsODEInitialized) or (FInitialized) then
    Exit;
  FJointID := dJointCreateHinge(FManager.World, nil);
  inherited;
end;

procedure TGLODEJointHinge.WriteToFiler(writer: TWriter);
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

procedure TGLODEJointHinge.ReadFromFiler(reader: TReader);
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

procedure TGLODEJointHinge.StructureChanged;
begin
  AnchorChange(nil);
  AxisChange(nil);
  FAxisParams.ApplyFlagged;
end;

procedure TGLODEJointHinge.AnchorChange(Sender: TObject);
begin
  if IsAttached then
    dJointSetHingeAnchor(FJointID, FAnchor.X, FAnchor.Y, FAnchor.Z);
end;

procedure TGLODEJointHinge.AxisChange(Sender: TObject);
var
  vec: TVector;
begin
  vec := FAxis.DirectVector;
  NormalizeVector(vec);
  FAxis.DirectVector := vec;
  if IsAttached then
    dJointSetHingeAxis(FJointID, FAxis.X, FAxis.Y, FAxis.Z);
end;

class function TGLODEJointHinge.FriendlyName: String;
begin
  Result := 'Hinge';
end;

class function TGLODEJointHinge.FriendlyDescription: String;
begin
  Result := 'ODE Hinge joint';
end;

procedure TGLODEJointHinge.SetAnchor(const Value: TGLCoordinates);
begin
  FAnchor.Assign(Value);
end;

procedure TGLODEJointHinge.SetAxis(const Value: TGLCoordinates);
begin
  FAxis.Assign(Value);
end;

procedure TGLODEJointHinge.SetAxisParams(const Value: TGLODEJointParams);
begin
  AxisParams.Assign(Value);
end;

function TGLODEJointHinge.SetAxisParam(Param: Integer;
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

function TGLODEJointHinge.GetAxisParam(Param: Integer; var Value: TdReal)
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
// --------------- TGLODEJointBall ---------------
// ---------------

constructor TGLODEJointBall.Create(AOwner: TGLXCollection);
begin
  inherited;
  FAnchor := TGLCoordinates.CreateInitialized(Self, NullHmgPoint, csPoint);
  FAnchor.OnNotifyChange := AnchorChange;
end;

destructor TGLODEJointBall.Destroy;
begin
  FAnchor.Free;
  inherited;
end;

procedure TGLODEJointBall.Initialize;
begin
  if (not IsODEInitialized) or (FInitialized) then
    Exit;
  FJointID := dJointCreateBall(FManager.World, nil);
  inherited;
end;

procedure TGLODEJointBall.WriteToFiler(writer: TWriter);
begin
  inherited;
  with writer do
  begin
    WriteInteger(0); // Archive version
    FAnchor.WriteToFiler(writer);
  end;
end;

procedure TGLODEJointBall.ReadFromFiler(reader: TReader);
begin
  inherited;
  with reader do
  begin
    Assert(ReadInteger = 0); // Archive version
    FAnchor.ReadFromFiler(reader);
  end;
end;

procedure TGLODEJointBall.StructureChanged;
begin
  AnchorChange(nil);
end;

procedure TGLODEJointBall.AnchorChange(Sender: TObject);
begin
  if IsAttached then
    dJointSetBallAnchor(FJointID, FAnchor.X, FAnchor.Y, FAnchor.Z);
end;

class function TGLODEJointBall.FriendlyName: String;
begin
  Result := 'Ball';
end;

class function TGLODEJointBall.FriendlyDescription: String;
begin
  Result := 'ODE Ball joint implementation';
end;

procedure TGLODEJointBall.SetAnchor(const Value: TGLCoordinates);
begin
  FAnchor.Assign(Value);
end;


// ---------------
// --------------- TGLODEJointSlider ---------------
// ---------------

constructor TGLODEJointSlider.Create(AOwner: TGLXCollection);
begin
  inherited;
  FAxis := TGLCoordinates.CreateInitialized(Self, ZHmgVector, csVector);
  FAxis.OnNotifyChange := AxisChange;
  FAxisParams := TGLODEJointParams.Create(Self);
  FAxisParams.SetCallback := SetAxisParam;
  FAxisParams.GetCallback := GetAxisParam;
end;

 
destructor TGLODEJointSlider.Destroy;
begin
  FAxis.Free;
  FAxisParams.Free;
  inherited;
end;

procedure TGLODEJointSlider.Initialize;
begin
  if (not IsODEInitialized) or (FInitialized) then
    Exit;
  FJointID := dJointCreateSlider(FManager.World, nil);
  inherited;
end;

procedure TGLODEJointSlider.WriteToFiler(writer: TWriter);
begin
  inherited;
  with writer do
  begin
    WriteInteger(0); // Archive version
    FAxis.WriteToFiler(writer);
    FAxisParams.WriteToFiler(writer);
  end;
end;

procedure TGLODEJointSlider.ReadFromFiler(reader: TReader);
begin
  inherited;
  with reader do
  begin
    Assert(ReadInteger = 0); // Archive version
    FAxis.ReadFromFiler(reader);
    FAxisParams.ReadFromFiler(reader);
  end;
end;

procedure TGLODEJointSlider.StructureChanged;
begin
  AxisChange(nil);
  AxisParams.ApplyFlagged;
end;

procedure TGLODEJointSlider.AxisChange(Sender: TObject);
var
  vec: TVector;
begin
  vec := FAxis.DirectVector;
  NormalizeVector(vec);
  FAxis.DirectVector := vec;
  if IsAttached then
    dJointSetSliderAxis(FJointID, FAxis.X, FAxis.Y, FAxis.Z);
end;

class function TGLODEJointSlider.FriendlyName: String;
begin
  Result := 'Slider';
end;

class function TGLODEJointSlider.FriendlyDescription: String;
begin
  Result := 'ODE Slider joint implementation';
end;

procedure TGLODEJointSlider.SetAxis(const Value: TGLCoordinates);
begin
  FAxis.Assign(Value);
end;

procedure TGLODEJointSlider.SetAxisParams(const Value: TGLODEJointParams);
begin
  AxisParams.Assign(Value);
end;

function TGLODEJointSlider.SetAxisParam(Param: Integer;
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

function TGLODEJointSlider.GetAxisParam(Param: Integer;
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
// --------------- TGLODEJointFixed ---------------
// ---------------

procedure TGLODEJointFixed.Initialize;
begin
  if (not IsODEInitialized) or (FInitialized) then
    Exit;
  FJointID := dJointCreateFixed(FManager.World, nil);
  inherited;
end;

procedure TGLODEJointFixed.WriteToFiler(writer: TWriter);
begin
  inherited;
  with writer do
  begin
    WriteInteger(0); // Archive version
  end;
end;

procedure TGLODEJointFixed.ReadFromFiler(reader: TReader);
begin
  inherited;
  with reader do
  begin
    Assert(ReadInteger = 0); // Archive version
  end;
end;

class function TGLODEJointFixed.FriendlyName: String;
begin
  Result := 'Fixed';
end;

class function TGLODEJointFixed.FriendlyDescription: String;
begin
  Result := 'ODE Fixed joint implementation';
end;


// ---------------
// --------------- TGLODEJointHinge2 ---------------
// ---------------

constructor TGLODEJointHinge2.Create(AOwner: TGLXCollection);
begin
  inherited;
  FAnchor := TGLCoordinates.CreateInitialized(Self, NullHmgPoint, csPoint);
  FAnchor.OnNotifyChange := AnchorChange;
  FAxis1 := TGLCoordinates.CreateInitialized(Self, ZHmgVector, csVector);
  FAxis1.OnNotifyChange := Axis1Change;
  FAxis2 := TGLCoordinates.CreateInitialized(Self, ZHmgVector, csVector);
  FAxis2.OnNotifyChange := Axis2Change;
  FAxis1Params := TGLODEJointParams.Create(Self);
  FAxis1Params.SetCallback := SetAxis1Param;
  FAxis1Params.GetCallback := GetAxis1Param;
  FAxis2Params := TGLODEJointParams.Create(Self);
  FAxis2Params.SetCallback := SetAxis2Param;
  FAxis2Params.GetCallback := GetAxis2Param;

  JointOptions := [joBothObjectsMustBeAssigned];
end;

destructor TGLODEJointHinge2.Destroy;
begin
  FAnchor.Free;
  FAxis1.Free;
  FAxis2.Free;
  FAxis1Params.Free;
  FAxis2Params.Free;
  inherited;
end;

procedure TGLODEJointHinge2.Initialize;
begin
  if (not IsODEInitialized) or (FInitialized) then
    Exit;
  FJointID := dJointCreateHinge2(FManager.World, nil);
  inherited;
end;

procedure TGLODEJointHinge2.WriteToFiler(writer: TWriter);
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

procedure TGLODEJointHinge2.ReadFromFiler(reader: TReader);
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

procedure TGLODEJointHinge2.StructureChanged;
begin
  AnchorChange(nil);
  Axis1Change(nil);
  Axis2Change(nil);
  Axis1Params.ApplyFlagged;
  Axis2Params.ApplyFlagged;
end;

procedure TGLODEJointHinge2.AnchorChange(Sender: TObject);
begin
  if IsAttached then
    dJointSetHinge2Anchor(FJointID, FAnchor.X, FAnchor.Y, FAnchor.Z);
end;

procedure TGLODEJointHinge2.Axis1Change(Sender: TObject);
var
  vec: TVector;
begin
  vec := FAxis1.DirectVector;
  NormalizeVector(vec);
  FAxis1.DirectVector := vec;
  if IsAttached then
    dJointSetHinge2Axis1(FJointID, FAxis1.X, FAxis1.Y, FAxis1.Z);
end;

procedure TGLODEJointHinge2.Axis2Change(Sender: TObject);
var
  vec: TVector;
begin
  vec := FAxis2.DirectVector;
  NormalizeVector(vec);
  FAxis2.DirectVector := vec;
  if IsAttached then
    dJointSetHinge2Axis2(FJointID, FAxis2.X, FAxis2.Y, FAxis2.Z);
end;

class function TGLODEJointHinge2.FriendlyName: String;
begin
  Result := 'Hinge2';
end;

class function TGLODEJointHinge2.FriendlyDescription: String;
begin
  Result := 'ODE Double Axis Hinge joint implementation';
end;

procedure TGLODEJointHinge2.SetAnchor(const Value: TGLCoordinates);
begin
  FAnchor.Assign(Value);
end;

procedure TGLODEJointHinge2.SetAxis1(const Value: TGLCoordinates);
begin
  FAxis1.Assign(Value);
end;

procedure TGLODEJointHinge2.SetAxis2(const Value: TGLCoordinates);
begin
  FAxis2.Assign(Value);
end;

procedure TGLODEJointHinge2.SetAxis1Params(const Value: TGLODEJointParams);
begin
  Axis1Params.Assign(Value);
end;

procedure TGLODEJointHinge2.SetAxis2Params(const Value: TGLODEJointParams);
begin
  Axis2Params.Assign(Value);
end;

function TGLODEJointHinge2.SetAxis1Param(Param: Integer;
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

function TGLODEJointHinge2.SetAxis2Param(Param: Integer;
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

function TGLODEJointHinge2.GetAxis1Param(Param: Integer;
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

function TGLODEJointHinge2.GetAxis2Param(Param: Integer;
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
// --------------- TGLODEJointUniversal ---------------
// ---------------

constructor TGLODEJointUniversal.Create(AOwner: TGLXCollection);
begin
  inherited;
  FAnchor := TGLCoordinates.CreateInitialized(Self, NullHmgPoint, csPoint);
  FAnchor.OnNotifyChange := AnchorChange;
  FAxis1 := TGLCoordinates.CreateInitialized(Self, ZHmgVector, csVector);
  FAxis1.OnNotifyChange := Axis1Change;
  FAxis2 := TGLCoordinates.CreateInitialized(Self, XHmgVector, csVector);
  FAxis2.OnNotifyChange := Axis2Change;
  FAxis1Params := TGLODEJointParams.Create(Self);
  FAxis1Params.SetCallback := SetAxis1Param;
  FAxis1Params.GetCallback := GetAxis1Param;
  FAxis2Params := TGLODEJointParams.Create(Self);
  FAxis2Params.SetCallback := SetAxis2Param;
  FAxis2Params.GetCallback := GetAxis2Param;

  JointOptions := [joBothObjectsMustBeAssigned];
end;


destructor TGLODEJointUniversal.Destroy;
begin
  FAnchor.Free;
  FAxis1.Free;
  FAxis2.Free;
  FAxis1Params.Free;
  FAxis2Params.Free;
  inherited;
end;

procedure TGLODEJointUniversal.Initialize;
begin
  if (not IsODEInitialized) or (FInitialized) then
    Exit;
  FJointID := dJointCreateUniversal(FManager.World, nil);
  inherited;
end;

procedure TGLODEJointUniversal.WriteToFiler(writer: TWriter);
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

procedure TGLODEJointUniversal.ReadFromFiler(reader: TReader);
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

procedure TGLODEJointUniversal.StructureChanged;
begin
  AnchorChange(nil);
  Axis1Change(nil);
  Axis2Change(nil);
  Axis1Params.ApplyFlagged;
  Axis2Params.ApplyFlagged;
end;

procedure TGLODEJointUniversal.AnchorChange(Sender: TObject);
begin
  if IsAttached then
    dJointSetUniversalAnchor(FJointID, FAnchor.X, FAnchor.Y, FAnchor.Z);
end;

procedure TGLODEJointUniversal.Axis1Change(Sender: TObject);
var
  vec: TVector;
begin
  vec := FAxis1.DirectVector;
  NormalizeVector(vec);
  FAxis1.DirectVector := vec;
  if IsAttached then
    dJointSetUniversalAxis1(FJointID, FAxis1.X, FAxis1.Y, FAxis1.Z);
end;

procedure TGLODEJointUniversal.Axis2Change(Sender: TObject);
var
  vec: TVector;
begin
  vec := FAxis2.DirectVector;
  NormalizeVector(vec);
  FAxis2.DirectVector := vec;
  if IsAttached then
    dJointSetUniversalAxis2(FJointID, FAxis2.X, FAxis2.Y, FAxis2.Z);
end;

class function TGLODEJointUniversal.FriendlyName: String;
begin
  Result := 'Universal';
end;

class function TGLODEJointUniversal.FriendlyDescription: String;
begin
  Result := 'ODE Universal joint implementation';
end;

procedure TGLODEJointUniversal.SetAnchor(const Value: TGLCoordinates);
begin
  FAnchor.Assign(Value);
end;

procedure TGLODEJointUniversal.SetAxis1(const Value: TGLCoordinates);
begin
  FAxis1.Assign(Value);
end;

procedure TGLODEJointUniversal.SetAxis2(const Value: TGLCoordinates);
begin
  FAxis2.Assign(Value);
end;

procedure TGLODEJointUniversal.SetAxis1Params(const Value: TGLODEJointParams);
begin
  Axis1Params.Assign(Value);
end;

procedure TGLODEJointUniversal.SetAxis2Params(const Value: TGLODEJointParams);
begin
  Axis2Params.Assign(Value);
end;

function TGLODEJointUniversal.SetAxis1Param(Param: Integer;
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

function TGLODEJointUniversal.SetAxis2Param(Param: Integer;
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

function TGLODEJointUniversal.GetAxis1Param(Param: Integer;
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

function TGLODEJointUniversal.GetAxis2Param(Param: Integer;
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
RegisterXCollectionItemClass(TGLODEElementTriMesh);
RegisterXCollectionItemClass(TODEElementPlane);

RegisterXCollectionItemClass(TGLODEJointHinge);
RegisterXCollectionItemClass(TGLODEJointBall);
RegisterXCollectionItemClass(TGLODEJointSlider);
RegisterXCollectionItemClass(TGLODEJointFixed);
RegisterXCollectionItemClass(TGLODEJointHinge2);
RegisterXCollectionItemClass(TGLODEJointUniversal);

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
UnregisterXCollectionItemClass(TGLODEElementTriMesh);
UnregisterXCollectionItemClass(TODEElementPlane);

UnregisterXCollectionItemClass(TGLODEJointHinge);
UnregisterXCollectionItemClass(TGLODEJointBall);
UnregisterXCollectionItemClass(TGLODEJointSlider);
UnregisterXCollectionItemClass(TGLODEJointFixed);
UnregisterXCollectionItemClass(TGLODEJointHinge2);
UnregisterXCollectionItemClass(TGLODEJointUniversal);

// CloseODE;

end.
