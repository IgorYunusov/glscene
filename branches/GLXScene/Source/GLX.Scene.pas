//
// VKScene Component Library, based on GLScene http://glscene.sourceforge.net
//
{
   Base classes and structures for VKScene.
}

unit GLX.Scene;

interface

{$I VKScene.inc}

uses
  Winapi.Windows,
  Winapi.OpenGL,
  Winapi.OpenGLext,
  System.Classes,
  System.SysUtils,
  System.UITypes,
  FMX.Graphics,
  FMX.Controls,
  FMX.Types,
  FMX.Dialogs,
  
  GLX.OpenGLAdapter,
  GLX.Context,
  GLX.VectorGeometry,
  GLX.XCollection,
  GLX.Silhouette,
  GLX.PersistentClasses,
  GLX.State,
  GLX.Graphics,
  GLX.GeometryBB,
  GLX.CrossPlatform,
  GLX.VectorLists,
  GLX.Texture,
  GLX.Color,
  GLX.BaseClasses,
  GLX.Coordinates,
  GLX.RenderContextInfo,
  GLX.Material,
  GLX.TextureFormat,
  GLX.Selection,
  GLX.Strings,
  GLX.XOpenGL,
  GLX.VectorTypes,
  GLX.ApplicationFileIO,
  GLX.Utils;


type
  // TGLProxyObjectOption
  //
  { Defines which features are taken from the master object. }
  TGLProxyObjectOption = (pooEffects, pooObjects, pooTransformation);
  TGLProxyObjectOptions = set of TGLProxyObjectOption;

  // TGLCameraInvarianceMode
  //
  TGLCameraInvarianceMode = (cimNone, cimPosition, cimOrientation);

  TGLSceneViewerMode = (svmDisabled, svmDefault, svmNavigation, svmGizmo);

const
  cDefaultProxyOptions = [pooEffects, pooObjects, pooTransformation];
  GLSCENE_REVISION = '$Revision: 6850$';
  GLSCENE_VERSION = '1.5.0.%s';

type

  TNormalDirection = (ndInside, ndOutside);

  // TObjectChanges
  //
  // used to decribe only the changes in an object,
  // which have to be reflected in the scene
  TObjectChange = (ocTransformation, ocAbsoluteMatrix, ocInvAbsoluteMatrix,
    ocStructure);
  TObjectChanges = set of TObjectChange;

  TObjectBBChange = (oBBcChild, oBBcStructure);
  TObjectBBChanges = set of TObjectBBChange;

  // flags for design notification
  TSceneOperation = (soAdd, soRemove, soMove, soRename, soSelect, soBeginUpdate,
    soEndUpdate);

  // TContextOption
  //
  { Options for the rendering context. 
     roSoftwareMode: force software rendering.
     roDoubleBuffer: enables double-buffering.
     roRenderToWindows: ignored (legacy). 
     roTwoSideLighting: enables two-side lighting model. 
     roStereo: enables stereo support in the driver (dunno if it works,
         I don't have a stereo device to test...) 
     roDestinationAlpha: request an Alpha channel for the rendered output 
     roNoColorBuffer: don't request a color buffer (color depth setting ignored)
     roNoColorBufferClear: do not clear the color buffer automatically, if the
         whole viewer is fully repainted each frame, this can improve framerate 
     roNoSwapBuffers: don't perform RenderingContext.SwapBuffers after rendering
     roNoDepthBufferClear: do not clear the depth buffer automatically. Useful for
         early-z culling. 
     roForwardContext: force Vulkan forward context }
  TContextOption = (roSoftwareMode, roDoubleBuffer, roStencilBuffer,
    roRenderToWindow, roTwoSideLighting, roStereo,
    roDestinationAlpha, roNoColorBuffer, roNoColorBufferClear,
    roNoSwapBuffers, roNoDepthBufferClear, roDebugContext,
    roForwardContext, roVulkan_ES2_Context);
  TContextOptions = set of TContextOption;

  // IDs for limit determination
  TLimitType = (limClipPlanes, limEvalOrder, limLights, limListNesting,
    limModelViewStack, limNameStack, limPixelMapTable, limProjectionStack,
    limTextureSize, limTextureStack, limViewportDims, limAccumAlphaBits,
    limAccumBlueBits, limAccumGreenBits, limAccumRedBits, limAlphaBits,
    limAuxBuffers, limBlueBits, limGreenBits, limRedBits, limIndexBits,
    limStereo, limDoubleBuffer, limSubpixelBits, limDepthBits, limStencilBits,
    limNbTextureUnits);

  TGLBaseSceneObject = class;
  TGLSceneObjectClass = class of TGLBaseSceneObject;
  TGLCustomSceneObject = class;
  TGLScene = class;
  TGLBehaviour = class;
  TGLBehaviourClass = class of TGLBehaviour;
  TGLBehaviours = class;
  TGLObjectEffect = class;
  TGLObjectEffectClass = class of TGLObjectEffect;
  TGLObjectEffects = class;
  TGLSceneBuffer = class;

  // TGLObjectStyle
  //
  { Possible styles/options for a GLScene object. 
     Allowed styles are: 
      osDirectDraw : object shall not make use of compiled call lists, but issue
        direct calls each time a render should be performed.
      osIgnoreDepthBuffer : object is rendered with depth test disabled,
        this is true for its children too.
      osNoVisibilityCulling : whatever the VisibilityCulling setting,
        it will be ignored and the object rendered
       }
  TGLObjectStyle = (
    osDirectDraw,
    osIgnoreDepthBuffer,
    osNoVisibilityCulling);
  TGLObjectStyles = set of TGLObjectStyle;

  // IGLInitializable
  //
  { Interface to objects that need initialization  }
  IGLInitializable = interface
    ['{EA40AE8E-79B3-42F5-ADF1-7A901B665E12}']
    procedure InitializeObject(ASender: TObject; const ARci:
      TGLRenderContextInfo);
  end;

  // TGLInitializableObjectList
  //
  { Just a list of objects that support IGLInitializable.  }
  TGLInitializableObjectList = class(TList)
  private
    function GetItems(const Index: Integer): IGLInitializable;
    procedure PutItems(const Index: Integer; const Value: IGLInitializable);
  public
    function Add(const Item: IGLInitializable): Integer;
    property Items[const Index: Integer]: IGLInitializable read GetItems write
    PutItems; default;
  end;

  // TGLBaseSceneObject
  //
  { Base class for all scene objects. 
     A scene object is part of scene hierarchy (each scene object can have
     multiple children), this hierarchy primarily defines transformations
     (each child coordinates are relative to its parent), but is also used
     for depth-sorting, bounding and visibility culling purposes. 
     Subclasses implement either visual scene objects (that are made to be
     visible at runtime, like a Cube) or structural objects (that influence
     rendering or are used for varied structural manipulations,
     like the ProxyObject). 
     To add children at runtime, use the AddNewChild method of TGLBaseSceneObject;
     other children manipulations methods and properties are provided (to browse,
     move and delete them). Using the regular TComponent methods is not
     encouraged. }

  TGLBaseSceneObject = class(TGLCoordinatesUpdateAbleComponent)
  private
    
    FAbsoluteMatrix, FInvAbsoluteMatrix: PMatrix;
    FLocalMatrix: PMatrix;
    FObjectStyle: TGLObjectStyles;
    FListHandle: TGLListHandle; // created on 1st use
    FPosition: TGLCoordinates;
    FDirection, FUp: TGLCoordinates;
    FScaling: TGLCoordinates;
    FChanges: TObjectChanges;
    FParent: TGLBaseSceneObject;
    FScene: TGLScene;

    FBBChanges: TObjectBBChanges;
    FBoundingBoxPersonalUnscaled: THmgBoundingBox;
    FBoundingBoxOfChildren: THmgBoundingBox;
    FBoundingBoxIncludingChildren: THmgBoundingBox;

    FChildren: TPersistentObjectList; // created on 1st use
    FVisible: Boolean;
    FUpdateCount: Integer;
    FShowAxes: Boolean;
    FRotation: TGLCoordinates; // current rotation angles
    FIsCalculating: Boolean;
    FObjectsSorting: TGLObjectsSorting;
    FVisibilityCulling: TGLVisibilityCulling;
    FOnProgress: TGLProgressEvent;
    FOnAddedToParent: TNotifyEvent;
    FGLBehaviours: TGLBehaviours;
    FGLObjectEffects: TGLObjectEffects;
    FPickable: Boolean;
    FOnPicked: TNotifyEvent;

    FTagObject: TObject;
    FTagFloat: Single;

    //  FOriginalFiler: TFiler;   //used to allow persistent events in behaviours & effects
    {If somebody could look at DefineProperties, ReadBehaviours, ReadEffects and verify code
    is safe to use then it could be uncommented}

    function Get(Index: Integer): TGLBaseSceneObject;
    function GetCount: Integer;
    function GetIndex: Integer;
    procedure SetParent(const val: TGLBaseSceneObject);
    procedure SetIndex(aValue: Integer);
    procedure SetDirection(AVector: TGLCoordinates);
    procedure SetUp(AVector: TGLCoordinates);
    function GetMatrix: TMatrix;
    procedure SetMatrix(const aValue: TMatrix);
    procedure SetPosition(APosition: TGLCoordinates);

    procedure SetPitchAngle(AValue: Single);
    procedure SetRollAngle(AValue: Single);
    procedure SetTurnAngle(AValue: Single);
    procedure SetRotation(aRotation: TGLCoordinates);
    function GetPitchAngle: Single;
    function GetTurnAngle: Single;
    function GetRollAngle: Single;

    procedure SetShowAxes(AValue: Boolean);
    procedure SetScaling(AValue: TGLCoordinates);
    procedure SetObjectsSorting(const val: TGLObjectsSorting);
    procedure SetVisibilityCulling(const val: TGLVisibilityCulling);
    procedure SetBehaviours(const val: TGLBehaviours);
    function GetBehaviours: TGLBehaviours;
    procedure SetEffects(const val: TGLObjectEffects);
    function GetEffects: TGLObjectEffects;

    function GetAbsoluteAffineScale: TAffineVector;
    function GetAbsoluteScale: TVector;
    procedure SetAbsoluteAffineScale(const Value: TAffineVector);
    procedure SetAbsoluteScale(const Value: TVector);

    function GetAbsoluteMatrix: TMatrix;
    procedure SetAbsoluteMatrix(const Value: TMatrix);
    procedure SetBBChanges(const Value: TObjectBBChanges);
  protected
    
    procedure Loaded; override;
    procedure SetScene(const Value: TGLScene); virtual;

    procedure DefineProperties(Filer: TFiler); override;
    procedure WriteBehaviours(stream: TStream);
    procedure ReadBehaviours(stream: TStream);
    procedure WriteEffects(stream: TStream);
    procedure ReadEffects(stream: TStream);
    procedure WriteRotations(stream: TStream);
    procedure ReadRotations(stream: TStream);

    function GetVisible: Boolean; virtual;
    function GetPickable: Boolean; virtual;
    procedure SetVisible(aValue: Boolean); virtual;
    procedure SetPickable(aValue: Boolean); virtual;

    procedure SetAbsolutePosition(const v: TVector);
    function GetAbsolutePosition: TVector;
    procedure SetAbsoluteUp(const v: TVector);
    function GetAbsoluteUp: TVector;
    procedure SetAbsoluteDirection(const v: TVector);
    function GetAbsoluteDirection: TVector;

    function GetAbsoluteAffinePosition: TAffineVector;
    procedure SetAbsoluteAffinePosition(const Value: TAffineVector);
    procedure SetAbsoluteAffineUp(const v: TAffineVector);
    function GetAbsoluteAffineUp: TAffineVector;
    procedure SetAbsoluteAffineDirection(const v: TAffineVector);
    function GetAbsoluteAffineDirection: TAffineVector;

    procedure RecTransformationChanged;

    procedure DrawAxes(var rci: TGLRenderContextInfo; pattern: Word);
    procedure GetChildren(AProc: TGetChildProc; Root: TComponent); override;
    // Should the object be considered as blended for sorting purposes?
    function Blended: Boolean; virtual;
    procedure RebuildMatrix;
    procedure SetName(const NewName: TComponentName); override;
    procedure SetParentComponent(Value: TComponent); override;
    procedure DestroyHandle; dynamic;
    procedure DestroyHandles;
    procedure DeleteChildCameras;
    procedure DoOnAddedToParent; virtual;

    { Used to re-calculate BoundingBoxes every time we need it.
       GetLocalUnscaleBB() must return the local BB, not the axis-aligned one.

       By default it is calculated from AxisAlignedBoundingBoxUnscaled and
       BarycenterAbsolutePosition, but for most objects there is a more
       efficient method, that's why it is virtual. }
    procedure CalculateBoundingBoxPersonalUnscaled(var ANewBoundingBox:
      THmgBoundingBox); virtual;
  public
    
    constructor Create(AOwner: TComponent); override;
    constructor CreateAsChild(aParentOwner: TGLBaseSceneObject);
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;

    { Controls and adjusts internal optimizations based on object's style. 
       Advanced user only. }
    property ObjectStyle: TGLObjectStyles read FObjectStyle write FObjectStyle;

    { Returns the handle to the object's build list. 
       Use with caution! Some objects don't support buildlists! }
    function GetHandle(var rci: TGLRenderContextInfo): Cardinal; virtual;
    function ListHandleAllocated: Boolean;

    { The local transformation (relative to parent). 
       If you're *sure* the local matrix is up-to-date, you may use LocalMatrix
       for quicker access. }
    property Matrix: TMatrix read GetMatrix write SetMatrix;
    { See Matrix. }
    function MatrixAsAddress: PMatrix;
    { Holds the local transformation (relative to parent). 
       If you're not *sure* the local matrix is up-to-date, use Matrix property. }
    property LocalMatrix: PMatrix read FLocalMatrix;
    { Forces the local matrix to the specified value. 
       AbsoluteMatrix, InverseMatrix, etc. will honour that change, but
       may become invalid if the specified matrix isn't orthonormal (can
       be used for specific rendering or projection effects). 
       The local matrix will be reset by the next TransformationChanged,
       position or attitude change. }
    procedure ForceLocalMatrix(const aMatrix: TMatrix);

    { See AbsoluteMatrix. }
    function AbsoluteMatrixAsAddress: PMatrix;
    { Holds the absolute transformation matrix. 
       If you're not *sure* the absolute matrix is up-to-date,
       use the AbsoluteMatrix property, this one may be nil... }
    property DirectAbsoluteMatrix: PMatrix read FAbsoluteMatrix;

    { Calculates the object's absolute inverse matrix. 
       Multiplying an absolute coordinate with this matrix gives a local coordinate. 
       The current implem uses transposition(AbsoluteMatrix), which is true
       unless you're using some scaling... }
    function InvAbsoluteMatrix: TMatrix;
    { See InvAbsoluteMatrix. }
    function InvAbsoluteMatrixAsAddress: PMatrix;

    { The object's absolute matrix by composing all local matrices.
       Multiplying a local coordinate with this matrix gives an absolute coordinate. }
    property AbsoluteMatrix: TMatrix read GetAbsoluteMatrix write
      SetAbsoluteMatrix;

    { Direction vector in absolute coordinates. }
    property AbsoluteDirection: TVector read GetAbsoluteDirection write
      SetAbsoluteDirection;
    property AbsoluteAffineDirection: TAffineVector read
      GetAbsoluteAffineDirection write SetAbsoluteAffineDirection;

    { Scale vector in absolute coordinates.
       Warning: SetAbsoluteScale() does not work correctly at the moment. }
    property AbsoluteScale: TVector read GetAbsoluteScale write
      SetAbsoluteScale;
    property AbsoluteAffineScale: TAffineVector read GetAbsoluteAffineScale write
      SetAbsoluteAffineScale;

    { Up vector in absolute coordinates. }
    property AbsoluteUp: TVector read GetAbsoluteUp write SetAbsoluteUp;
    property AbsoluteAffineUp: TAffineVector read GetAbsoluteAffineUp write
      SetAbsoluteAffineUp;

    { Calculate the right vector in absolute coordinates. }
    function AbsoluteRight: TVector;

    { Calculate the left vector in absolute coordinates. }
    function AbsoluteLeft: TVector;

    { Computes and allows to set the object's absolute coordinates.  }
    property AbsolutePosition: TVector read GetAbsolutePosition write
      SetAbsolutePosition;
    property AbsoluteAffinePosition: TAffineVector read GetAbsoluteAffinePosition
      write SetAbsoluteAffinePosition;
    function AbsolutePositionAsAddress: PVector;

    { Returns the Absolute X Vector expressed in local coordinates. }
    function AbsoluteXVector: TVector;
    { Returns the Absolute Y Vector expressed in local coordinates. }
    function AbsoluteYVector: TVector;
    { Returns the Absolute Z Vector expressed in local coordinates. }
    function AbsoluteZVector: TVector;

    { Converts a vector/point from absolute coordinates to local coordinates.  }
    function AbsoluteToLocal(const v: TVector): TVector; overload;
    { Converts a vector from absolute coordinates to local coordinates.  }
    function AbsoluteToLocal(const v: TAffineVector): TAffineVector; overload;
    { Converts a vector/point from local coordinates to absolute coordinates.  }
    function LocalToAbsolute(const v: TVector): TVector; overload;
    { Converts a vector from local coordinates to absolute coordinates.  }
    function LocalToAbsolute(const v: TAffineVector): TAffineVector; overload;

    { Returns the Right vector (based on Up and Direction) }
    function Right: TVector;
    { Returns the Left vector (based on Up and Direction) }
    function LeftVector: TVector;

    { Returns the Right vector (based on Up and Direction) }
    function AffineRight: TAffineVector;
    { Returns the Left vector (based on Up and Direction) }
    function AffineLeftVector: TAffineVector;

    { Calculates the object's square distance to a point/object. 
       pt is assumed to be in absolute coordinates,
       AbsolutePosition is considered as being the object position. }
    function SqrDistanceTo(anObject: TGLBaseSceneObject): Single; overload;
    function SqrDistanceTo(const pt: TVector): Single; overload;
    function SqrDistanceTo(const pt: TAffineVector): Single; overload;

    { Computes the object's distance to a point/object. 
       Only objects AbsolutePositions are considered. }
    function DistanceTo(anObject: TGLBaseSceneObject): Single; overload;
    function DistanceTo(const pt: TAffineVector): Single; overload;
    function DistanceTo(const pt: TVector): Single; overload;

    { Calculates the object's barycenter in absolute coordinates.
       Default behaviour is to consider Barycenter=AbsolutePosition
       (whatever the number of children). 
       SubClasses where AbsolutePosition is not the barycenter should
       override this method as it is used for distance calculation, during
       rendering for instance, and may lead to visual inconsistencies. }
    function BarycenterAbsolutePosition: TVector; virtual;
    { Calculates the object's barycenter distance to a point.  }
    function BarycenterSqrDistanceTo(const pt: TVector): Single;

    { Shall returns the object's axis aligned extensions. 
       The dimensions are measured from object center and are expressed
       <i>with</i> scale accounted for, in the object's coordinates
       (not in absolute coordinates). 
       Default value is half the object's Scale.  }
    function AxisAlignedDimensions: TVector; virtual;
    function AxisAlignedDimensionsUnscaled: TVector; virtual;

    { Calculates and return the AABB for the object. 
       The AABB is currently calculated from the BB.
       There is  no  caching scheme for them. }
    function AxisAlignedBoundingBox(const AIncludeChilden: Boolean = True):
      TAABB;
    function AxisAlignedBoundingBoxUnscaled(const AIncludeChilden: Boolean =
      True): TAABB;
    function AxisAlignedBoundingBoxAbsolute(const AIncludeChilden: Boolean =
      True; const AUseBaryCenter: Boolean = False): TAABB;

    { Advanced AABB functions that use a caching scheme.
       Also they include children and use BaryCenter. }
    function AxisAlignedBoundingBoxEx: TAABB;
    function AxisAlignedBoundingBoxAbsoluteEx: TAABB;

    { Calculates and return the Bounding Box for the object. 
       The BB is calculated  each  time this method is invoked,
       based on the AxisAlignedDimensions of the object and that of its
       children.
       There is  no  caching scheme for them. }
    function BoundingBox(const AIncludeChilden: Boolean = True; const
      AUseBaryCenter: Boolean = False): THmgBoundingBox;
    function BoundingBoxUnscaled(const AIncludeChilden: Boolean = True; const
      AUseBaryCenter: Boolean = False): THmgBoundingBox;
    function BoundingBoxAbsolute(const AIncludeChilden: Boolean = True; const
      AUseBaryCenter: Boolean = False): THmgBoundingBox;

    { Advanced BB functions that use a caching scheme.
       Also they include children and use BaryCenter. }
    function BoundingBoxPersonalUnscaledEx: THmgBoundingBox;
    function BoundingBoxOfChildrenEx: THmgBoundingBox;
    function BoundingBoxIncludingChildrenEx: THmgBoundingBox;

    { Max distance of corners of the BoundingBox. }
    function BoundingSphereRadius: Single;
    function BoundingSphereRadiusUnscaled: Single;

    { Indicates if a point is within an object. 
       Given coordinate is an absolute coordinate. 
       Linear or surfacic objects shall always return False. 
       Default value is based on AxisAlignedDimension and a cube bounding. }
    function PointInObject(const point: TVector): Boolean; virtual;
    { Request to determine an intersection with a casted ray. 
       Given coordinates & vector are in absolute coordinates, rayVector
       must be normalized. 
       rayStart may be a point inside the object, allowing retrieval of
       the multiple intersects of the ray. 
       When intersectXXX parameters are nil (default) implementation should
       take advantage of this to optimize calculus, if not, and an intersect
       is found, non nil parameters should be defined. 
       The intersectNormal needs NOT be normalized by the implementations. 
       Default value is based on bounding sphere. }
    function RayCastIntersect(const rayStart, rayVector: TVector;
      intersectPoint: PVector = nil;
      intersectNormal: PVector = nil): Boolean; virtual;

    { Request to generate silhouette outlines. 
       Default implementation assumes the objects is a sphere of
       AxisAlignedDimensionUnscaled size. Subclasses may choose to return
       nil instead, which will be understood as an empty silhouette. }
    function GenerateSilhouette(const silhouetteParameters:
      TGLSilhouetteParameters): TGLSilhouette; virtual;

    property Children[Index: Integer]: TGLBaseSceneObject read Get; default;
    property Count: Integer read GetCount;
    property Index: Integer read GetIndex write SetIndex;
    // Create a new scene object and add it to this object as new child
    function AddNewChild(AChild: TGLSceneObjectClass): TGLBaseSceneObject;
      dynamic;
    // Create a new scene object and add it to this object as first child
    function AddNewChildFirst(AChild: TGLSceneObjectClass): TGLBaseSceneObject;
      dynamic;
    procedure AddChild(AChild: TGLBaseSceneObject); dynamic;

    function GetOrCreateBehaviour(aBehaviour: TGLBehaviourClass): TGLBehaviour;
    function AddNewBehaviour(aBehaviour: TGLBehaviourClass): TGLBehaviour;

    function GetOrCreateEffect(anEffect: TGLObjectEffectClass): TGLObjectEffect;
    function AddNewEffect(anEffect: TGLObjectEffectClass): TGLObjectEffect;

    function HasSubChildren: Boolean;
    procedure DeleteChildren; dynamic;
    procedure Insert(AIndex: Integer; AChild: TGLBaseSceneObject); dynamic;
    { Takes a scene object out of the child list, but doesn't destroy it. 
       If 'KeepChildren' is true its children will be kept as new children
       in this scene object. }
    procedure Remove(aChild: TGLBaseSceneObject; keepChildren: Boolean);
      dynamic;
    function IndexOfChild(aChild: TGLBaseSceneObject): Integer;
    function FindChild(const aName: string; ownChildrenOnly: Boolean):
      TGLBaseSceneObject;
    { The "safe" version of this procedure checks if indexes are inside
       the list. If not, no exception if raised. }
    procedure ExchangeChildrenSafe(anIndex1, anIndex2: Integer);
    { The "regular" version of this procedure does not perform any checks
       and calls FChildren.Exchange directly. User should/can perform range
       checks manualy. }
    procedure ExchangeChildren(anIndex1, anIndex2: Integer);
    { These procedures are safe. }
    procedure MoveChildUp(anIndex: Integer);
    procedure MoveChildDown(anIndex: Integer);
    procedure MoveChildFirst(anIndex: Integer);
    procedure MoveChildLast(anIndex: Integer);

    procedure DoProgress(const progressTime: TProgressTimes); override;
    procedure MoveTo(newParent: TGLBaseSceneObject); dynamic;
    procedure MoveUp;
    procedure MoveDown;
    procedure MoveFirst;
    procedure MoveLast;
    procedure BeginUpdate; virtual;
    procedure EndUpdate; virtual;
    { Make object-specific geometry description here. 
       Subclasses should MAINTAIN Vulkan states (restore the states if
       they were altered). }
    procedure BuildList(var rci: TGLRenderContextInfo); virtual;
    function GetParentComponent: TComponent; override;
    function HasParent: Boolean; override;
    function IsUpdating: Boolean;
    // Moves the object along the Up vector (move up/down)
    procedure Lift(ADistance: Single);
    // Moves the object along the direction vector
    procedure Move(ADistance: Single);
    // Translates the object
    procedure Translate(tx, ty, tz: Single);
    procedure MoveObjectAround(anObject: TGLBaseSceneObject;
      pitchDelta, turnDelta: Single);
    procedure MoveObjectAllAround(anObject: TGLBaseSceneObject;
      pitchDelta, turnDelta: Single);
    procedure Pitch(angle: Single);
    procedure Roll(angle: Single);
    procedure Turn(angle: Single);

    { Sets all rotations to zero and restores default Direction/Up. 
       Using this function then applying roll/pitch/turn in the order that
       suits you, you can give an "absolute" meaning to rotation angles
       (they are still applied locally though). 
       Scale and Position are not affected. }
    procedure ResetRotations;
    { Reset rotations and applies them back in the specified order. }
    procedure ResetAndPitchTurnRoll(const degX, degY, degZ: Single);

    { Applies rotations around absolute X, Y and Z axis.  }
    procedure RotateAbsolute(const rx, ry, rz: Single); overload;
    { Applies rotations around the absolute given vector (angle in degrees).  }
    procedure RotateAbsolute(const axis: TAffineVector; angle: Single);
      overload;
    // Moves camera along the right vector (move left and right)
    procedure Slide(ADistance: Single);
    // Orients the object toward a target object
    procedure PointTo(const ATargetObject: TGLBaseSceneObject; const AUpVector:
      TVector); overload;
    // Orients the object toward a target absolute position
    procedure PointTo(const AAbsolutePosition, AUpVector: TVector); overload;

    procedure Render(var ARci: TGLRenderContextInfo);
    procedure DoRender(var ARci: TGLRenderContextInfo;
      ARenderSelf, ARenderChildren: Boolean); virtual;
    procedure RenderChildren(firstChildIndex, lastChildIndex: Integer;
      var rci: TGLRenderContextInfo); virtual;

    procedure StructureChanged; dynamic;
    procedure ClearStructureChanged;

    // Recalculate an orthonormal system
    procedure CoordinateChanged(Sender: TGLCustomCoordinates); override;
    procedure TransformationChanged;
    procedure NotifyChange(Sender: TObject); override;

    property Rotation: TGLCoordinates read FRotation write SetRotation;
    property PitchAngle: Single read GetPitchAngle write SetPitchAngle;
    property RollAngle: Single read GetRollAngle write SetRollAngle;
    property TurnAngle: Single read GetTurnAngle write SetTurnAngle;

    property ShowAxes: Boolean read FShowAxes write SetShowAxes default False;

    property Changes: TObjectChanges read FChanges;
    property BBChanges: TObjectBBChanges read fBBChanges write SetBBChanges;

    property Parent: TGLBaseSceneObject read FParent write SetParent;
    property Position: TGLCoordinates read FPosition write SetPosition;
    property Direction: TGLCoordinates read FDirection write SetDirection;
    property Up: TGLCoordinates read FUp write SetUp;
    property Scale: TGLCoordinates read FScaling write SetScaling;
    property Scene: TGLScene read FScene;
    property Visible: Boolean read FVisible write SetVisible default True;
    property Pickable: Boolean read FPickable write SetPickable default True;
    property ObjectsSorting: TGLObjectsSorting read FObjectsSorting write
      SetObjectsSorting default osInherited;
    property VisibilityCulling: TGLVisibilityCulling read FVisibilityCulling
      write SetVisibilityCulling default vcInherited;
    property OnProgress: TGLProgressEvent read FOnProgress write FOnProgress;
    property OnPicked: TNotifyEvent read FOnPicked write FOnPicked;
    property OnAddedToParent: TNotifyEvent read FOnAddedToParent write
      FOnAddedToParent;

    property Behaviours: TGLBehaviours read GetBehaviours write SetBehaviours
      stored False;
    property Effects: TGLObjectEffects read GetEffects write SetEffects stored
      False;

    property TagObject: TObject read FTagObject write FTagObject;
  published
    
    property TagFloat: Single read FTagFloat write FTagFloat;

  end;

  // TGLBaseBehaviour
  //
  { Base class for implementing behaviours in TGLScene. 
     Behaviours are regrouped in a collection attached to a TGLBaseSceneObject,
     and are part of the "Progress" chain of events. Behaviours allows clean
     application of time-based alterations to objects (movements, shape or
     texture changes...). 
     Since behaviours are implemented as classes, there are basicly two kinds
     of strategies for subclasses : 
      stand-alone : the subclass does it all, and holds all necessary data
        (covers animation, inertia etc.)
      proxy : the subclass is an interface to and external, shared operator
        (like gravity, force-field effects etc.)
       
     Some behaviours may be cooperative (like force-fields affects inertia)
     or unique (e.g. only one inertia behaviour per object). 
     NOTES : 
      Don't forget to override the ReadFromFiler/WriteToFiler persistence
        methods if you add data in a subclass !
      Subclasses must be registered using the RegisterXCollectionItemClass
        function
       }
  TGLBaseBehaviour = class(TGLXCollectionItem)
  protected
    
    procedure SetName(const val: string); override;

    { Override this function to write subclass data. }
    procedure WriteToFiler(writer: TWriter); override;
    { Override this function to read subclass data. }
    procedure ReadFromFiler(reader: TReader); override;

    { Returns the TGLBaseSceneObject on which the behaviour should be applied. 
       Does NOT check for nil owners. }
    function OwnerBaseSceneObject: TGLBaseSceneObject;

  public
    
    constructor Create(aOwner: TGLXCollection); override;
    destructor Destroy; override;

    procedure DoProgress(const progressTime: TProgressTimes); virtual;
  end;

  // TGLBehaviour
  //
  { Ancestor for non-rendering behaviours. 
     This class shall never receive any properties, it's just here to differentiate
     rendereing and non-rendering behaviours. Rendereing behaviours are named
     "TGLObjectEffect", non-rendering effects (like inertia) are simply named
     "TGLBehaviour". }

  TGLBehaviour = class(TGLBaseBehaviour)
  end;

  // TGLBehaviours
  //
  { Holds a list of TGLBehaviour objects. 
     This object expects itself to be owned by a TGLBaseSceneObject. 
     As a TGLXCollection (and contrary to a TCollection), this list can contain
     objects of varying class, the only constraint being that they should all
     be TGLBehaviour subclasses. }
  TGLBehaviours = class(TGLXCollection)
  protected
    
    function GetBehaviour(index: Integer): TGLBehaviour;

  public
    
    constructor Create(aOwner: TPersistent); override;

    function GetNamePath: string; override;

    class function ItemsClass: TGLXCollectionItemClass; override;

    property Behaviour[index: Integer]: TGLBehaviour read GetBehaviour; default;

    function CanAdd(aClass: TGLXCollectionItemClass): Boolean; override;

    procedure DoProgress(const progressTimes: TProgressTimes);
  end;

  // TGLObjectEffect
  //
  { A rendering effect that can be applied to SceneObjects. 
     ObjectEffect is a subclass of behaviour that gets a chance to Render
     an object-related special effect. 
     TGLObjectEffect should not be used as base class for custom effects,
     instead you should use the following base classes : 
      TGLObjectPreEffect is rendered before owner object render
      TGLObjectPostEffect is rendered after the owner object render
      TGLObjectAfterEffect is rendered at the end of the scene rendering
       NOTES : 
      Don't forget to override the ReadFromFiler/WriteToFiler persistence
        methods if you add data in a subclass !
      Subclasses must be registered using the RegisterXCollectionItemClass
        function
       }
//   TGLObjectEffectClass = class of TGLObjectEffect;

  TGLObjectEffect = class(TGLBaseBehaviour)
  protected
    
    { Override this function to write subclass data. }
    procedure WriteToFiler(writer: TWriter); override;
    { Override this function to read subclass data. }
    procedure ReadFromFiler(reader: TReader); override;

  public
    
    procedure Render(var rci: TGLRenderContextInfo); virtual;
  end;

  // TGLObjectPreEffect
  //
  { An object effect that gets rendered before owner object's render. 
     The current Vulkan matrices and material are that of the owner object. }
  TGLObjectPreEffect = class(TGLObjectEffect)
  end;

  // TGLObjectPostEffect
  //
  { An object effect that gets rendered after owner object's render. 
     The current Vulkan matrices and material are that of the owner object. }
  TGLObjectPostEffect = class(TGLObjectEffect)
  end;

  // TGLObjectAfterEffect
  //
  { An object effect that gets rendered at scene's end. 
     No particular Vulkan matrices or material should be assumed. }
  TGLObjectAfterEffect = class(TGLObjectEffect)
  end;

  // TGLObjectEffects
  //
  { Holds a list of object effects. 
     This object expects itself to be owned by a TGLBaseSceneObject.  }
  TGLObjectEffects = class(TGLXCollection)
  protected
    
    function GetEffect(index: Integer): TGLObjectEffect;

  public
    
    constructor Create(aOwner: TPersistent); override;

    function GetNamePath: string; override;

    class function ItemsClass: TGLXCollectionItemClass; override;

    property ObjectEffect[index: Integer]: TGLObjectEffect read GetEffect;
    default;

    function CanAdd(aClass: TGLXCollectionItemClass): Boolean; override;

    procedure DoProgress(const progressTime: TProgressTimes);
    procedure RenderPreEffects(var rci: TGLRenderContextInfo);
    { Also take care of registering after effects with the GLSceneViewer. }
    procedure RenderPostEffects(var rci: TGLRenderContextInfo);
  end;

  // TGLCustomSceneObject
  //
  { Extended base scene object class with a material property. 
     The material allows defining a color and texture for the object,
     see TGLMaterial. }
  TGLCustomSceneObject = class(TGLBaseSceneObject)
  private
    
    FMaterial: TGLMaterial;
    FHint: string;

  protected
    
    function Blended: Boolean; override;

    procedure SetVKMaterial(AValue: TGLMaterial);
    procedure DestroyHandle; override;
    procedure Loaded; override;

  public
    
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure Assign(Source: TPersistent); override;
    procedure DoRender(var ARci: TGLRenderContextInfo;
      ARenderSelf, ARenderChildren: Boolean); override;

    property Material: TGLMaterial read FMaterial write SetVKMaterial;
    property Hint: string read FHint write FHint;
  end;

  // TGLSceneRootObject
  //
  { This class shall be used only as a hierarchy root. 
     It exists only as a container and shall never be rotated/scaled etc. as
     the class type is used in parenting optimizations. 
     Shall never implement or add any functionality, the "Create" override
     only take cares of disabling the build list. }
  TGLSceneRootObject = class(TGLBaseSceneObject)
  public
    
    constructor Create(AOwner: TComponent); override;
  end;

  // TGLImmaterialSceneObject
  //
  { Base class for objects that do not have a published "material". 
     Note that the material is available in public properties, but isn't
     applied automatically before invoking BuildList. 
     Subclassing should be reserved to structural objects and objects that
     have no material of their own. }
  TGLImmaterialSceneObject = class(TGLCustomSceneObject)
  public
    
    procedure DoRender(var ARci: TGLRenderContextInfo;
      ARenderSelf, ARenderChildren: Boolean); override;

  published
    
    property ObjectsSorting;
    property VisibilityCulling;
    property Direction;
    property PitchAngle;
    property Position;
    property RollAngle;
    property Scale;
    property ShowAxes;
    property TurnAngle;
    property Up;
    property Visible;
    property Pickable;
    property OnProgress;
    property OnPicked;
    property Behaviours;
    property Effects;
    property Hint;
  end;

  // TGLCameraInvariantObject
  //
  { Base class for camera invariant objects. 
     Camera invariant objects bypass camera settings, such as camera
     position (object is always centered on camera) or camera orientation
     (object always has same orientation as camera). }
  TGLCameraInvariantObject = class(TGLImmaterialSceneObject)
  private
    
    FCamInvarianceMode: TGLCameraInvarianceMode;

  protected
    
    procedure SetCamInvarianceMode(const val: TGLCameraInvarianceMode);

    property CamInvarianceMode: TGLCameraInvarianceMode read FCamInvarianceMode
      write SetCamInvarianceMode;

  public
    
    constructor Create(AOwner: TComponent); override;

    procedure Assign(Source: TPersistent); override;
    procedure DoRender(var ARci: TGLRenderContextInfo;
      ARenderSelf, ARenderChildren: Boolean); override;
  end;

  // TGLSceneObject
  //
  { Base class for standard scene objects. 
     Publishes the Material property. }
  TGLSceneObject = class(TGLCustomSceneObject)
  published
    
    property Material;
    property ObjectsSorting;
    property VisibilityCulling;
    property Direction;
    property PitchAngle;
    property Position;
    property RollAngle;
    property Scale;
    property ShowAxes;
    property TurnAngle;
    property Up;
    property Visible;
    property Pickable;
    property OnProgress;
    property OnPicked;
    property Behaviours;
    property Effects;
    property Hint;
  end;

  // TDirectRenderEvent
  //
  { Event for user-specific rendering in a TGLDirectVulkan object. }
  TDirectRenderEvent = procedure(Sender: TObject; var rci: TGLRenderContextInfo)
    of object;

  // TGLDirectVulkan
  //
  { Provides a way to issue direct Vulkan calls during the rendering. 
     You can use this object to do your specific rendering task in its OnRender
     event. The Vulkan calls shall restore the Vulkan states they found when
     entering, or exclusively use the GLMisc utility functions to alter the
     states.  }
  TGLDirectVulkan = class(TGLImmaterialSceneObject)
  private
    
    FUseBuildList: Boolean;
    FOnRender: TDirectRenderEvent;
    FBlend: Boolean;

  protected
    
    procedure SetUseBuildList(const val: Boolean);
    function Blended: Boolean; override;
    procedure SetBlend(const val: Boolean);
  public
    
    constructor Create(AOwner: TComponent); override;

    procedure Assign(Source: TPersistent); override;
    procedure BuildList(var rci: TGLRenderContextInfo); override;

    function AxisAlignedDimensionsUnscaled: TVector; override;
  published
    
    { Specifies if a build list be made. 
       If True, GLScene will generate a build list (Vulkan-side cache),
       ie. OnRender will only be invoked once for the first render, or after
       a StructureChanged call. This is suitable for "static" geometry and
       will usually speed up rendering of things that don't change. 
       If false, OnRender will be invoked for each render. This is suitable
       for dynamic geometry (things that change often or constantly). }
    property UseBuildList: Boolean read FUseBuildList write SetUseBuildList;
    { Place your specific Vulkan code here. 
       The Vulkan calls shall restore the Vulkan states they found when
       entering, or exclusively use the GLMisc utility functions to alter
       the states.  }
    property OnRender: TDirectRenderEvent read FOnRender write FOnRender;
    { Defines if the object uses blending. 
       This property will allow direct Vulkan objects to be flagged as
       blended for object sorting purposes.  }
    property Blend: Boolean read FBlend write SetBlend;
  end;

  // TGLRenderPoint
  //
  { Scene object that allows other objects to issue rendering at some point. 
     This object is used to specify a render point for which other components
     have (rendering) tasks to perform. It doesn't render anything itself
     and is invisible, but other components can register and be notified
     when the point is reached in the rendering phase. 
     Callbacks must be explicitly unregistered. }
  TGLRenderPoint = class(TGLImmaterialSceneObject)
  private
    
    FCallBacks: array of TDirectRenderEvent;
    FFreeCallBacks: array of TNotifyEvent;

  protected
    

  public
    
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure BuildList(var rci: TGLRenderContextInfo); override;

    procedure RegisterCallBack(renderEvent: TDirectRenderEvent;
      renderPointFreed: TNotifyEvent);
    procedure UnRegisterCallBack(renderEvent: TDirectRenderEvent);
    procedure Clear;

  published
    
  end;

  // TGLProxyObject
  //
  { A full proxy object. 
     This object literally uses another object's Render method to do its own
     rendering, however, it has a coordinate system and a life of its own. 
     Use it for duplicates of an object. }
  TGLProxyObject = class(TGLBaseSceneObject)
  private
    
    FMasterObject: TGLBaseSceneObject;
    FProxyOptions: TGLProxyObjectOptions;

  protected
    
    FRendering: Boolean;

    procedure Notification(AComponent: TComponent; Operation: TOperation);
      override;
    procedure SetMasterObject(const val: TGLBaseSceneObject); virtual;
    procedure SetProxyOptions(const val: TGLProxyObjectOptions);

  public
    
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure Assign(Source: TPersistent); override;
    procedure DoRender(var ARci: TGLRenderContextInfo;
      ARenderSelf, ARenderChildren: Boolean); override;

    function BarycenterAbsolutePosition: TVector; override;
    function AxisAlignedDimensions: TVector; override;
    function AxisAlignedDimensionsUnscaled: TVector; override;
    function RayCastIntersect(const rayStart, rayVector: TVector;
      intersectPoint: PVector = nil;
      intersectNormal: PVector = nil): Boolean; override;
    function GenerateSilhouette(const silhouetteParameters:
      TGLSilhouetteParameters): TGLSilhouette; override;

  published
    
    { Specifies the Master object which will be proxy'ed. }
    property MasterObject: TGLBaseSceneObject read FMasterObject write
      SetMasterObject;
    { Specifies how and what is proxy'ed. }
    property ProxyOptions: TGLProxyObjectOptions read FProxyOptions write
      SetProxyOptions default cDefaultProxyOptions;

    property ObjectsSorting;
    property Direction;
    property PitchAngle;
    property Position;
    property RollAngle;
    property Scale;
    property ShowAxes;
    property TurnAngle;
    property Up;
    property Visible;
    property Pickable;
    property OnProgress;
    property OnPicked;
    property Behaviours;
  end;

  TGLProxyObjectClass = class of TGLProxyObject;

  // TLightStyle
  //
  { Defines the various styles for lightsources.
      
      lsSpot : a spot light, oriented and with a cutoff zone (note that if
        cutoff is 180, the spot is rendered as an omni source)
      lsOmni : an omnidirectionnal source, punctual and sending light in
        all directions uniformously
      lsParallel : a parallel light, oriented as the light source is (this
        type of light can help speed up rendering)
        }
  TLightStyle = (lsSpot, lsOmni, lsParallel, lsParallelSpot);

  // TGLLightSource
  //
  { Standard light source. 
     The standard GLScene light source covers spotlights, omnidirectionnal and
     parallel sources (see TLightStyle). 
     Lights are colored, have distance attenuation parameters and are turned
     on/off through their Shining property. 
     Lightsources are managed in a specific object by the TGLScene for rendering
     purposes. The maximum number of light source in a scene is limited by the
     Vulkan implementation (8 lights are supported under most ICDs), though the
     more light you use, the slower rendering may get. If you want to render
     many more light/lightsource, you may have to resort to other techniques
     like lightmapping. }
  TGLLightSource = class(TGLBaseSceneObject)
  private
    
    FLightID: Cardinal;
    FSpotDirection: TGLCoordinates;
    FSpotExponent, FSpotCutOff: Single;
    FConstAttenuation, FLinearAttenuation, FQuadraticAttenuation: Single;
    FShining: Boolean;
    FAmbient, FDiffuse, FSpecular: TGLColor;
    FLightStyle: TLightStyle;

  protected
    
    procedure SetAmbient(AValue: TGLColor);
    procedure SetDiffuse(AValue: TGLColor);
    procedure SetSpecular(AValue: TGLColor);
    procedure SetConstAttenuation(AValue: Single);
    procedure SetLinearAttenuation(AValue: Single);
    procedure SetQuadraticAttenuation(AValue: Single);
    procedure SetShining(AValue: Boolean);
    procedure SetSpotDirection(AVector: TGLCoordinates);
    procedure SetSpotExponent(AValue: Single);
    procedure SetSpotCutOff(const val: Single);
    procedure SetLightStyle(const val: TLightStyle);

  public
    
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure DoRender(var ARci: TGLRenderContextInfo;
      ARenderSelf, ARenderChildren: Boolean); override;
    // light sources have different handle types than normal scene objects
    function GetHandle(var rci: TGLRenderContextInfo): Cardinal; override;
    function RayCastIntersect(const rayStart, rayVector: TVector;
      intersectPoint: PVector = nil;
      intersectNormal: PVector = nil): Boolean; override;
    procedure CoordinateChanged(Sender: TGLCustomCoordinates); override;
    function GenerateSilhouette(const silhouetteParameters:
      TGLSilhouetteParameters): TGLSilhouette; override;

    property LightID: Cardinal read FLightID;

    function Attenuated: Boolean;

  published
    
    property Ambient: TGLColor read FAmbient write SetAmbient;
    property ConstAttenuation: Single read FConstAttenuation write
      SetConstAttenuation;
    property Diffuse: TGLColor read FDiffuse write SetDiffuse;
    property LinearAttenuation: Single read FLinearAttenuation write
      SetLinearAttenuation;
    property QuadraticAttenuation: Single read FQuadraticAttenuation write
      SetQuadraticAttenuation;
    property Position;
    property LightStyle: TLightStyle read FLightStyle write SetLightStyle default
      lsSpot;
    property Shining: Boolean read FShining write SetShining default True;
    property Specular: TGLColor read FSpecular write SetSpecular;
    property SpotCutOff: Single read FSpotCutOff write SetSpotCutOff;
    property SpotDirection: TGLCoordinates read FSpotDirection write
      SetSpotDirection;
    property SpotExponent: Single read FSpotExponent write SetSpotExponent;
    property OnProgress;
  end;

  // TGLCameraStyle
  //
  TGLCameraStyle = (csPerspective, csOrthogonal, csOrtho2D, csCustom,
    csInfinitePerspective, csPerspectiveKeepFOV);

  TGLCameraKeepFOVMode = (ckmHorizontalFOV, ckmVerticalFOV);

  // TOnCustomPerspective
  //
  TOnCustomPerspective = procedure(const viewport: TRectangle;
    width, height: Integer; DPI: Integer;
    var viewPortRadius: Single) of object;

  // TGLCamera
  //
  { Camera object. 
     This object is commonly referred by TGLSceneViewer and defines a position,
     direction, focal length, depth of view... all the properties needed for
     defining a point of view and optical characteristics. }
  TGLCamera = class(TGLBaseSceneObject)
  private
    
    FFocalLength: Single;
    FDepthOfView: Single;
    FNearPlane: Single; // nearest distance to the camera
    FNearPlaneBias: Single; // scaling bias applied to near plane
    FViewPortRadius: Single; // viewport bounding radius per distance unit
    FTargetObject: TGLBaseSceneObject;
    FLastDirection: TVector; // Not persistent
    FCameraStyle: TGLCameraStyle;
    FKeepFOVMode: TGLCameraKeepFOVMode;
    FSceneScale: Single;
    FDeferredApply: TNotifyEvent;
    FOnCustomPerspective: TOnCustomPerspective;
    FDesign: Boolean;
    FFOVY, FFOVX: Double;

  protected
    
    procedure Notification(AComponent: TComponent; Operation: TOperation);
      override;
    procedure SetTargetObject(const val: TGLBaseSceneObject);
    procedure SetDepthOfView(AValue: Single);
    procedure SetFocalLength(AValue: Single);
    procedure SetCameraStyle(const val: TGLCameraStyle);
    procedure SetKeepFOVMode(const val: TGLCameraKeepFOVMode);
    procedure SetSceneScale(value: Single);
    function StoreSceneScale: Boolean;
    procedure SetNearPlaneBias(value: Single);
    function StoreNearPlaneBias: Boolean;

  public
    
    constructor Create(aOwner: TComponent); override;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;

    { Nearest clipping plane for the frustum. 
       This value depends on the FocalLength and DepthOfView fields and
       is calculated to minimize Z-Buffer crawling as suggested by the
       Vulkan documentation. }
    property NearPlane: Single read FNearPlane;

    // Apply camera transformation
    procedure Apply;
    procedure DoRender(var ARci: TGLRenderContextInfo;
      ARenderSelf, ARenderChildren: Boolean); override;
    function RayCastIntersect(const rayStart, rayVector: TVector;
      intersectPoint: PVector = nil;
      intersectNormal: PVector = nil): Boolean; override;

    procedure ApplyPerspective(const AViewport: TRectangle;
      AWidth, AHeight: Integer; ADPI: Integer);
    procedure AutoLeveling(Factor: Single);
    procedure Reset(aSceneBuffer: TGLSceneBuffer);
    // Position the camera so that the whole scene can be seen
    procedure ZoomAll(aSceneBuffer: TGLSceneBuffer);

    procedure RotateObject(obj: TGLBaseSceneObject; pitchDelta, turnDelta:
      Single;
      rollDelta: Single = 0);
    procedure RotateTarget(pitchDelta, turnDelta: Single; rollDelta: Single =
      0);

    { Change camera's position to make it move around its target. 
       If TargetObject is nil, nothing happens. This method helps in quickly
       implementing camera controls. Camera's Up and Direction properties
       are unchanged. 
       Angle deltas are in degrees, camera parent's coordinates should be identity. 
       Tip : make the camera a child of a "target" dummycube and make
       it a target the dummycube. Now, to pan across the scene, just move
       the dummycube, to change viewing angle, use this method. }
    procedure MoveAroundTarget(pitchDelta, turnDelta: Single);
    { Change camera's position to make it move all around its target. 
       If TargetObject is nil, nothing happens. This method helps in quickly
       implementing camera controls. Camera's Up and Direction properties
       are changed. 
       Angle deltas are in degrees. }
    procedure MoveAllAroundTarget(pitchDelta, turnDelta :Single);
    { Moves the camera in eye space coordinates. }
    procedure MoveInEyeSpace(forwardDistance, rightDistance, upDistance:
      Single);
    { Moves the target in eye space coordinates. }
    procedure MoveTargetInEyeSpace(forwardDistance, rightDistance, upDistance:
      Single);
    { Computes the absolute vector corresponding to the eye-space translations. }
    function AbsoluteEyeSpaceVector(forwardDistance, rightDistance, upDistance:
      Single): TVector;
    { Adjusts distance from camera to target by applying a ratio. 
       If TargetObject is nil, nothing happens. This method helps in quickly
       implementing camera controls. Only the camera's position is changed. }
    procedure AdjustDistanceToTarget(distanceRatio: Single);
    { Returns the distance from camera to target. 
       If TargetObject is nil, returns 1. }
    function DistanceToTarget: Single;
    { Computes the absolute normalized vector to the camera target. 
       If no target is defined, AbsoluteDirection is returned. }
    function AbsoluteVectorToTarget: TVector;
    { Computes the absolute normalized right vector to the camera target. 
       If no target is defined, AbsoluteRight is returned. }
    function AbsoluteRightVectorToTarget: TVector;
    { Computes the absolute normalized up vector to the camera target. 
       If no target is defined, AbsoluteUpt is returned. }
    function AbsoluteUpVectorToTarget: TVector;
    { Calculate an absolute translation vector from a screen vector. 
       Ratio is applied to both screen delta, planeNormal should be the
       translation plane's normal. }
    function ScreenDeltaToVector(deltaX, deltaY: Integer; ratio: Single;
      const planeNormal: TVector): TVector;
    { Same as ScreenDeltaToVector but optimized for XY plane. }
    function ScreenDeltaToVectorXY(deltaX, deltaY: Integer; ratio: Single):
      TVector;
    { Same as ScreenDeltaToVector but optimized for XZ plane. }
    function ScreenDeltaToVectorXZ(deltaX, deltaY: Integer; ratio: Single):
      TVector;
    { Same as ScreenDeltaToVector but optimized for YZ plane. }
    function ScreenDeltaToVectorYZ(deltaX, deltaY: Integer; ratio: Single):
      TVector;
    { Returns true if a point is in front of the camera. }
    function PointInFront(const point: TVector): boolean; overload;
    { Calculates the field of view in degrees, given a viewport dimension
    (width or height). F.i. you may wish to use the minimum of the two. }
    function GetFieldOfView(const AViewportDimension: single): single;
    { Sets the FocalLength in degrees, given a field of view and a viewport
    dimension (width or height). }
    procedure SetFieldOfView(const AFieldOfView, AViewportDimension: single);
  published
    
    { Depth of field/view. 
       Adjusts the maximum distance, beyond which objects will be clipped
       (ie. not visisble). 
       You must adjust this value if you are experiencing disappearing
       objects (increase the value) of Z-Buffer crawling (decrease the
       value). Z-Buffer crawling happens when depth of view is too large
       and the Z-Buffer precision cannot account for all that depth
       accurately : objects farther overlap closer objects and vice-versa. 
       Note that this value is ignored in cSOrtho2D mode. }
    property DepthOfView: Single read FDepthOfView write SetDepthOfView;
    { Focal Length of the camera. 
       Adjusting this value allows for lens zooming effects (use SceneScale
       for linear zooming). This property affects near/far planes clipping. }
    property FocalLength: Single read FFocalLength write SetFocalLength;
    { Scene scaling for camera point. 
       This is a linear 2D scaling of the camera's output, allows for
       linear zooming (use FocalLength for lens zooming). }
    property SceneScale: Single read FSceneScale write SetSceneScale stored
      StoreSceneScale;
    { Scaling bias applied to near-plane calculation. 
       Values inferior to one will move the nearplane nearer, and also
       reduce medium/long range Z-Buffer precision, values superior
       to one will move the nearplane farther, and also improve medium/long
       range Z-Buffer precision. }
    property NearPlaneBias: Single read FNearPlaneBias write SetNearPlaneBias
      stored StoreNearPlaneBias;
    { If set, camera will point to this object. 
       When camera is pointing an object, the Direction vector is ignored
       and the Up vector is used as an absolute vector to the up. }
    property TargetObject: TGLBaseSceneObject read FTargetObject write
      SetTargetObject;
    { Adjust the camera style. 
       Three styles are available : 
        csPerspective, the default value for perspective projection
        csOrthogonal, for orthogonal (or isometric) projection.
        csOrtho2D, setups orthogonal 2D projection in which 1 unit
          (in x or y) represents 1 pixel.
        csInfinitePerspective, for perspective view without depth limit.
        csKeepCamAnglePerspective, for perspective view with keeping aspect on view resize.
        csCustom, setup is deferred to the OnCustomPerspective event.
         }
    property CameraStyle: TGLCameraStyle read FCameraStyle write SetCameraStyle
      default csPerspective;

    { Keep camera angle mode.  
       When CameraStyle is csKeepCamAnglePerspective, select which camera angle you want to keep.
        kaHeight, for Keep Height oriented camera angle
        kaWidth,  for Keep Width oriented camera angle
       }
    property KeepFOVMode: TGLCameraKeepFOVMode read FKeepFOVMode
      write SetKeepFOVMode default ckmHorizontalFOV;

    { Custom perspective event. 
       This event allows you to specify your custom perpective, either
       with a glFrustrum, a glOrtho or whatever method suits you. 
       You must compute viewPortRadius for culling to work. 
       This event is only called if CameraStyle is csCustom. }
    property OnCustomPerspective: TOnCustomPerspective read FOnCustomPerspective
      write FOnCustomPerspective;

    property Position;
    property Direction;
    property Up;
    property OnProgress;
  end;

  // TGLScene
  //
  { Scene object. 
     The scene contains the scene description (lights, geometry...), which is
     basicly a hierarchical scene graph made of TGLBaseSceneObject. It will
     usually contain one or more TGLCamera object, which can be referred by
     a Viewer component for rendering purposes. 
     The scene's objects can be accessed directly from Delphi code (as regular
     components), but those are edited with a specific editor (double-click
     on the TGLScene component at design-time to invoke it). To add objects
     at runtime, use the AddNewChild method of TGLBaseSceneObject. }
  TGLScene = class(TGLUpdateAbleComponent)
  private
    
    FUpdateCount: Integer;
    FObjects: TGLSceneRootObject;
    FBaseContext: TGLContext; //reference, not owned!
    FLights, FBuffers: TPersistentObjectList;
    FCurrentCamera: TGLCamera;
    FCurrentBuffer: TGLSceneBuffer;
    FObjectsSorting: TGLObjectsSorting;
    FVisibilityCulling: TGLVisibilityCulling;
    FOnBeforeProgress: TGLProgressEvent;
    FOnProgress: TGLProgressEvent;
    FCurrentDeltaTime: Double;
    FInitializableObjects: TGLInitializableObjectList;

  protected
    
    procedure AddLight(aLight: TGLLightSource);
    procedure RemoveLight(aLight: TGLLightSource);
    // Adds all lights in the subtree (anObj included)
    procedure AddLights(anObj: TGLBaseSceneObject);
    // Removes all lights in the subtree (anObj included)
    procedure RemoveLights(anObj: TGLBaseSceneObject);

    procedure GetChildren(AProc: TGetChildProc; Root: TComponent); override;
    procedure SetChildOrder(AChild: TComponent; Order: Integer); override;
    procedure SetObjectsSorting(const val: TGLObjectsSorting);
    procedure SetVisibilityCulling(const val: TGLVisibilityCulling);

    procedure ReadState(Reader: TReader); override;
  public
    
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure BeginUpdate;
    procedure EndUpdate;
    function IsUpdating: Boolean;

    procedure AddBuffer(aBuffer: TGLSceneBuffer);
    procedure RemoveBuffer(aBuffer: TGLSceneBuffer);
    procedure SetupLights(maxLights: Integer);
    procedure NotifyChange(Sender: TObject); override;
    procedure Progress(const deltaTime, newTime: Double);

    function FindSceneObject(const AName: string): TGLBaseSceneObject;
    { Calculates, finds and returns the first object intercepted by the ray. 
       Returns nil if no intersection was found. This function will be
       accurate only for objects that overrided their RayCastIntersect
       method with accurate code, otherwise, bounding sphere intersections
       will be returned. }
    function RayCastIntersect(const rayStart, rayVector: TVector;
      intersectPoint: PVector = nil;
      intersectNormal: PVector = nil): TGLBaseSceneObject; virtual;

    procedure ShutdownAllLights;

    { Saves the scene to a file (recommended extension : .GLS) }
    procedure SaveToFile(const fileName: string);
    { Load the scene from a file.
       Existing objects/lights/cameras are freed, then the file is loaded. 
       Delphi's IDE is not handling this behaviour properly yet, ie. if
       you load a scene in the IDE, objects will be properly loaded, but
       no declare will be placed in the code. }
    procedure LoadFromFile(const fileName: string);

    procedure SaveToStream(aStream: TStream);
    procedure LoadFromStream(aStream: TStream);

    { Saves the scene to a text file }
    procedure SaveToTextFile(const fileName: string);
    { Load the scene from a text files. 
       See LoadFromFile for details. }
    procedure LoadFromTextFile(const fileName: string);

    property CurrentCamera: TGLCamera read FCurrentCamera;
    property Lights: TPersistentObjectList read FLights;
    property Objects: TGLSceneRootObject read FObjects;
    property CurrentBuffer: TGLSceneBuffer read FCurrentBuffer;

    { List of objects that request to be initialized when rendering context is active. 
      They are removed automaticly from this list once initialized. }
    property InitializableObjects: TGLInitializableObjectList read
      FInitializableObjects;
    property CurrentDeltaTime: Double read FCurrentDeltaTime;
  published
    
    { Defines default ObjectSorting option for scene objects. }
    property ObjectsSorting: TGLObjectsSorting read FObjectsSorting write
      SetObjectsSorting default osRenderBlendedLast;
    { Defines default VisibilityCulling option for scene objects. }
    property VisibilityCulling: TGLVisibilityCulling read FVisibilityCulling
      write SetVisibilityCulling default vcNone;
    property OnBeforeProgress: TGLProgressEvent read FOnBeforeProgress write FOnBeforeProgress;
    property OnProgress: TGLProgressEvent read FOnProgress write FOnProgress;
  end;

  // TFogMode
  //
  TFogMode = (fmLinear, fmExp, fmExp2);

  // TFogDistance
  //
  { Fog distance calculation mode. 
      
      fdDefault: let Vulkan use its default formula
      fdEyeRadial: uses radial "true" distance (best quality)
      fdEyePlane: uses the distance to the projection plane
                 (same as Z-Buffer, faster)
      Requires support of GL_NV_fog_distance extension, otherwise,
     it is ignored. }
  TFogDistance = (fdDefault, fdEyeRadial, fdEyePlane);

  // TGLFogEnvironment
  //
  { Parameters for fog environment in a scene. 
     The fog descibed by this object is a distance-based fog, ie. the "intensity"
     of the fog is given by a formula depending solely on the distance, this
     intensity is used for blending to a fixed color. }
  TGLFogEnvironment = class(TGLUpdateAbleObject)
  private
    
    FSceneBuffer: TGLSceneBuffer;
    FFogColor: TGLColor; // alpha value means the fog density
    FFogStart, FFogEnd: Single;
    FFogMode: TFogMode;
    FFogDistance: TFogDistance;

  protected
    
    procedure SetFogColor(Value: TGLColor);
    procedure SetFogStart(Value: Single);
    procedure SetFogEnd(Value: Single);
    procedure SetFogMode(Value: TFogMode);
    procedure SetFogDistance(const val: TFogDistance);

  public
    
    constructor Create(AOwner: TPersistent); override;
    destructor Destroy; override;

    procedure ApplyFog;
    procedure Assign(Source: TPersistent); override;

    function IsAtDefaultValues: Boolean;

  published
    
    { Color of the fog when it is at 100% intensity. }
    property FogColor: TGLColor read FFogColor write SetFogColor;
    { Minimum distance for fog, what is closer is not affected. }
    property FogStart: Single read FFogStart write SetFogStart;
    { Maximum distance for fog, what is farther is at 100% fog intensity. }
    property FogEnd: Single read FFogEnd write SetFogEnd;
    { The formula used for converting distance to fog intensity. }
    property FogMode: TFogMode read FFogMode write SetFogMode default fmLinear;
    { Adjusts the formula used for calculating fog distances. 
       This option is honoured if and only if the Vulkan ICD supports the
       GL_NV_fog_distance extension, otherwise, it is ignored. 
           fdDefault: let Vulkan use its default formula
           fdEyeRadial: uses radial "true" distance (best quality)
           fdEyePlane: uses the distance to the projection plane
             (same as Z-Buffer, faster)
         }
    property FogDistance: TFogDistance read FFogDistance write SetFogDistance
      default fdDefault;
  end;

  // TGLDepthPrecision
  //
  TGLDepthPrecision = (dpDefault, dp16bits, dp24bits, dp32bits);

  // TGLColorDepth
  //
  TGLColorDepth = (cdDefault, cd8bits, cd16bits, cd24bits, cdFloat64bits,
    cdFloat128bits); // float_type

  // TGLShadeModel
  //
  TGLShadeModel = (smDefault, smSmooth, smFlat);

  // TGLSceneBuffer
  //
  { Encapsulates an Vulkan frame/rendering buffer.  }
  TGLSceneBuffer = class(TGLUpdateAbleObject)
  private
    
    // Internal state
    FRendering: Boolean;
    FRenderingContext: TGLContext;
    FAfterRenderEffects: TPersistentObjectList;
    FViewMatrixStack: array of TMatrix;
    FProjectionMatrixStack: array of TMatrix;
    FBaseProjectionMatrix: TMatrix;
    FCameraAbsolutePosition: TVector;
    FViewPort: TRectangle;
    FSelector: TGLBaseSelectTechnique;

    // Options & User Properties
    FFaceCulling, FFogEnable, FLighting: Boolean;
    FDepthTest: Boolean;
    FBackgroundColor: TColor;
    FBackgroundAlpha: Single;
    FAmbientColor: TGLColor;
    FAntiAliasing: TGLAntiAliasing;
    FDepthPrecision: TGLDepthPrecision;
    FColorDepth: TGLColorDepth;
    FContextOptions: TContextOptions;
    FShadeModel: TGLShadeModel;
    FRenderDPI: Integer;
    FFogEnvironment: TGLFogEnvironment;
    FAccumBufferBits: Integer;
    FLayer: TGLContextLayer;

    // Cameras
    FCamera: TGLCamera;

    // Freezing
    FFreezeBuffer: Pointer;
    FFreezed: Boolean;
    FFreezedViewPort: TRectangle;

    // Monitoring
    FFrameCount: Longint;
    FFramesPerSecond: Single;
    FFirstPerfCounter: Int64;
    FLastFrameTime: Single;

    // Events
    FOnChange: TNotifyEvent;
    FOnStructuralChange: TNotifyEvent;
    FOnPrepareGLContext: TNotifyEvent;

    FBeforeRender: TNotifyEvent;
    FViewerBeforeRender: TNotifyEvent;
    FPostRender: TNotifyEvent;
    FAfterRender: TNotifyEvent;
    FInitiateRendering: TDirectRenderEvent;
    FWrapUpRendering: TDirectRenderEvent;
    procedure SetLayer(const Value: TGLContextLayer);

  protected
    
    procedure SetBackgroundColor(AColor: TColor);
    procedure SetBackgroundAlpha(alpha: Single);
    procedure SetAmbientColor(AColor: TGLColor);
    function GetLimit(Which: TLimitType): Integer;
    procedure SetCamera(ACamera: TGLCamera);
    procedure SetContextOptions(Options: TContextOptions);
    procedure SetDepthTest(AValue: Boolean);
    procedure SetFaceCulling(AValue: Boolean);
    procedure SetLighting(AValue: Boolean);
    procedure SetAntiAliasing(const val: TGLAntiAliasing);
    procedure SetDepthPrecision(const val: TGLDepthPrecision);
    procedure SetColorDepth(const val: TGLColorDepth);
    procedure SetShadeModel(const val: TGLShadeModel);
    procedure SetFogEnable(AValue: Boolean);
    procedure SetFogEnvironment(AValue: TGLFogEnvironment);
    function StoreFog: Boolean;
    procedure SetAccumBufferBits(const val: Integer);

    procedure PrepareRenderingMatrices(const aViewPort: TRectangle;
      resolution: Integer; pickingRect: PGLRect = nil);
    procedure DoBaseRender(const aViewPort: TRectangle; resolution: Integer;
      drawState: TDrawState; baseObject: TGLBaseSceneObject);

    procedure SetupRenderingContext(context: TGLContext);
    procedure SetupRCOptions(context: TGLContext);
    procedure PrepareGLContext;

    procedure DoChange;
    procedure DoStructuralChange;

    // DPI for current/last render
    property RenderDPI: Integer read FRenderDPI;

    property OnPrepareGLContext: TNotifyEvent read FOnPrepareGLContext write
      FOnPrepareGLContext;

  public
    
    constructor Create(AOwner: TPersistent); override;
    destructor Destroy; override;

    procedure NotifyChange(Sender: TObject); override;

    procedure CreateRC(AWindowHandle: THandle; memoryContext: Boolean;//in VCL -> HWND
      BufferCount: integer = 1); overload;
    procedure ClearBuffers;
    procedure DestroyRC;
    function RCInstantiated: Boolean;
    procedure Resize(newLeft, newTop, newWidth, newHeight: Integer);
    // Indicates hardware acceleration support
    function Acceleration: TGLContextAcceleration;

    // ViewPort for current/last render
    property ViewPort: TRectangle read FViewPort;

    // Fills the PickList with objects in Rect area
    procedure PickObjects(const rect: TGLRect; pickList: TGLPickList;
      objectCountGuess: Integer);
    { Returns a PickList with objects in Rect area. 
       Returned list should be freed by caller. 
       Objects are sorted by depth (nearest objects first). }
    function GetPickedObjects(const rect: TGLRect; objectCountGuess: Integer =
      64): TGLPickList;
    // Returns the nearest object at x, y coordinates or nil if there is none
    function GetPickedObject(x, y: Integer): TGLBaseSceneObject;

    // Returns the color of the pixel at x, y in the frame buffer
    function GetPixelColor(x, y: Integer): TColor;
    { Returns the raw depth (Z buffer) of the pixel at x, y in the frame buffer. 
       This value does not map to the actual eye-object distance, but to
       a depth buffer value in the [0; 1] range. }
    function GetPixelDepth(x, y: Integer): Single;
    { Converts a raw depth (Z buffer value) to frustrum distance.
       This calculation is only accurate for the pixel at the centre of the viewer,
       because it does not take into account that the corners of the frustrum
       are further from the eye than its centre. }
    function PixelDepthToDistance(aDepth: Single): Single;
    { Converts a raw depth (Z buffer value) to world distance.
       It also compensates for the fact that the corners of the frustrum
       are further from the eye, than its centre.}
    function PixelToDistance(x, y: integer): Single;
    { Design time notification }
    procedure NotifyMouseMove(Shift: TShiftState; X, Y: Single);

    { Renders the scene on the viewer. 
       You do not need to call this method, unless you explicitly want a
       render at a specific time. If you just want the control to get
       refreshed, use Invalidate instead. }
    procedure Render(baseObject: TGLBaseSceneObject); overload;
    procedure Render; overload;
    procedure RenderScene(aScene: TGLScene;
      const viewPortSizeX, viewPortSizeY: Integer;
      drawState: TDrawState;
      baseObject: TGLBaseSceneObject);
    { Render the scene to a bitmap at given DPI. 
      DPI = "dots per inch". 
      The "magic" DPI of the screen is 96 under Windows. }
    procedure RenderToBitmap(ABitmap: TBitmap; DPI: Integer = 0);
    { Render the scene to a bitmap at given DPI and saves it to a file. 
       DPI = "dots per inch". 
       The "magic" DPI of the screen is 96 under Windows. }
    procedure RenderToFile(const AFile: string; DPI: Integer = 0); overload;
    { Renders to bitmap of given size, then saves it to a file. 
       DPI is adjusted to make the bitmap similar to the viewer. }
    procedure RenderToFile(const AFile: string; bmpWidth, bmpHeight: Integer);
      overload;
    { Creates a TGLBitmap32 that is a snapshot of current Vulkan content. 
       When possible, use this function instead of RenderToBitmap, it won't
       request a redraw and will be significantly faster. 
       The returned TGLBitmap32 should be freed by calling code. }
    function CreateSnapShot: TGLImage;
    { Creates a FMX bitmap that is a snapshot of current Vulkan content.  }
    function CreateSnapShotBitmap: TBitmap;
    procedure CopyToTexture(aTexture: TGLTexture); overload;
    procedure CopyToTexture(aTexture: TGLTexture; xSrc, ySrc, AWidth, AHeight:
      Integer;
      xDest, yDest: Integer; glCubeFace: GLEnum = 0); overload;
    { Save as raw float data to a file }
    procedure SaveAsFloatToFile(const aFilename: string);
    { Event reserved for viewer-specific uses.  }
    property ViewerBeforeRender: TNotifyEvent read FViewerBeforeRender write
      FViewerBeforeRender stored False;
    procedure SetViewPort(X, Y, W, H: Integer);
    function Width: Integer;
    function Height: Integer;

    { Indicates if the Viewer is "frozen". }
    property Freezed: Boolean read FFreezed;
    { Freezes rendering leaving the last rendered scene on the buffer. This
       is usefull in windowed applications for temporarily stopping rendering
       (when moving the window, for example). }
    procedure Freeze;
    { Restarts rendering after it was freezed. }
    procedure Melt;

    { Displays a window with info on current Vulkan ICD and context. }
    procedure ShowInfo(Modal: boolean = false);

    { Currently Rendering? }
    property Rendering: Boolean read FRendering;

    { Adjusts background alpha channel. }
    property BackgroundAlpha: Single read FBackgroundAlpha write
      SetBackgroundAlpha;
    { Returns the projection matrix in use or used for the last rendering. }
    function ProjectionMatrix: TMatrix; deprecated;
    { Returns the view matrix in use or used for the last rendering. }
    function ViewMatrix: TMatrix; deprecated;
    function ModelMatrix: TMatrix; deprecated;

    { Returns the base projection matrix in use or used for the last rendering. 
       The "base" projection is (as of now) either identity or the pick
       matrix, ie. it is the matrix on which the perspective or orthogonal
       matrix gets applied. }
    property BaseProjectionMatrix: TMatrix read FBaseProjectionMatrix;

    { Back up current View matrix and replace it with newMatrix. 
       This method has no effect on theVulkan matrix, only on the Buffer's
       matrix, and is intended for special effects rendering. }
    procedure PushViewMatrix(const newMatrix: TMatrix); deprecated;
    { Restore a View matrix previously pushed. }
    procedure PopViewMatrix; deprecated;

    procedure PushProjectionMatrix(const newMatrix: TMatrix); deprecated;
    procedure PopProjectionMatrix;  deprecated;

    { Converts a screen pixel coordinate into 3D coordinates for orthogonal projection.
       This function accepts standard canvas coordinates, with (0,0) being
       the top left corner, and returns, when the camera is in orthogonal
       mode, the corresponding 3D world point that is in the camera's plane. }
    function OrthoScreenToWorld(screenX, screenY: Integer): TAffineVector;
      overload;
    { Converts a screen coordinate into world (3D) coordinates. 
       This methods wraps a call to gluUnProject. 
       Note that screen coord (0,0) is the lower left corner. }
    function ScreenToWorld(const aPoint: TAffineVector): TAffineVector;
      overload;
    function ScreenToWorld(const aPoint: TVector): TVector; overload;
    { Converts a screen pixel coordinate into 3D world coordinates. 
       This function accepts standard canvas coordinates, with (0,0) being
       the top left corner. }
    function ScreenToWorld(screenX, screenY: Integer): TAffineVector; overload;
    { Converts an absolute world coordinate into screen coordinate. 
       This methods wraps a call to gluProject. 
       Note that screen coord (0,0) is the lower left corner. }
    function WorldToScreen(const aPoint: TAffineVector): TAffineVector;
      overload;
    function WorldToScreen(const aPoint: TVector): TVector; overload;
    { Converts a set of point absolute world coordinates into screen coordinates.  }
    procedure WorldToScreen(points: PVector; nbPoints: Integer); overload;
    { Calculates the 3D vector corresponding to a 2D screen coordinate. 
       The vector originates from the camera's absolute position and is
       expressed in absolute coordinates. 
       Note that screen coord (0,0) is the lower left corner. }
    function ScreenToVector(const aPoint: TAffineVector): TAffineVector;
      overload;
    function ScreenToVector(const aPoint: TVector): TVector; overload;
    function ScreenToVector(const x, y: Integer): TVector; overload;
    { Calculates the 2D screen coordinate of a vector from the camera's
       absolute position and is expressed in absolute coordinates. 
       Note that screen coord (0,0) is the lower left corner. }
    function VectorToScreen(const VectToCam: TAffineVector): TAffineVector;
    { Calculates intersection between a plane and screen vector. 
       If an intersection is found, returns True and places result in
       intersectPoint. }
    function ScreenVectorIntersectWithPlane(
      const aScreenPoint: TVector;
      const planePoint, planeNormal: TVector;
      var intersectPoint: TVector): Boolean;
    { Calculates intersection between plane XY and screen vector. 
       If an intersection is found, returns True and places result in
       intersectPoint. }
    function ScreenVectorIntersectWithPlaneXY(
      const aScreenPoint: TVector; const z: Single;
      var intersectPoint: TVector): Boolean;
    { Calculates intersection between plane YZ and screen vector. 
       If an intersection is found, returns True and places result in
       intersectPoint. }
    function ScreenVectorIntersectWithPlaneYZ(
      const aScreenPoint: TVector; const x: Single;
      var intersectPoint: TVector): Boolean;
    { Calculates intersection between plane XZ and screen vector. 
       If an intersection is found, returns True and places result in
       intersectPoint. }
    function ScreenVectorIntersectWithPlaneXZ(
      const aScreenPoint: TVector; const y: Single;
      var intersectPoint: TVector): Boolean;
    { Calculates a 3D coordinate from screen position and ZBuffer. 
       This function returns a world absolute coordinate from a 2D point
       in the viewer, the depth being extracted from the ZBuffer data
       (DepthTesting and ZBuffer must be enabled for this function to work). 
       Note that ZBuffer precision is not linear and can be quite low on
       some boards (either from compression or resolution approximations). }
    function PixelRayToWorld(x, y: Integer): TAffineVector;
    { Time (in second) spent to issue rendering order for the last frame. 
       Be aware that since execution by the hardware isn't synchronous,
       this value may not be an accurate measurement of the time it took
       to render the last frame, it's a measurement of only the time it
       took to issue rendering orders. }
    property LastFrameTime: Single read FLastFrameTime;
    { Current FramesPerSecond rendering speed. 
       You must keep the renderer busy to get accurate figures from this
       property. 
       This is an average value, to reset the counter, call
       ResetPerfomanceMonitor. }
    property FramesPerSecond: Single read FFramesPerSecond;
    { Resets the perfomance monitor and begin a new statistics set. 
       See FramesPerSecond. }
    procedure ResetPerformanceMonitor;

    { Retrieve one of the Vulkan limits for the current viewer. 
       Limits include max texture size, Vulkan stack depth, etc. }
    property LimitOf[Which: TLimitType]: Integer read GetLimit;
    { Current rendering context. 
       The context is a wrapper around platform-specific contexts
       (see TGLContext) and takes care of context activation and handle
       management. }
    property RenderingContext: TGLContext read FRenderingContext;
    { The camera from which the scene is rendered. 
       A camera is an object you can add and define in a TGLScene component. }
    property Camera: TGLCamera read FCamera write SetCamera;
    { Specifies the layer plane that the rendering context is bound to. }
    property Layer: TGLContextLayer read FLayer write SetLayer
      default clMainPlane;
  published
    
    { Fog environment options.
       See TGLFogEnvironment. }
    property FogEnvironment: TGLFogEnvironment read FFogEnvironment write
      SetFogEnvironment stored StoreFog;
    { Color used for filling the background prior to any rendering. }
    property BackgroundColor: TColor read FBackgroundColor write
      SetBackgroundColor default TColors.SysBtnFace;
    { Scene ambient color vector. 
       This ambient color is defined independantly from all lightsources,
       which can have their own ambient components. }
    property AmbientColor: TGLColor read FAmbientColor write SetAmbientColor;

    { Context options allows to setup specifics of the rendering context. 
       Not all contexts support all options. }
    property ContextOptions: TContextOptions read FContextOptions write
      SetContextOptions default [roDoubleBuffer, roRenderToWindow, roDebugContext];
    { Number of precision bits for the accumulation buffer. }
    property AccumBufferBits: Integer read FAccumBufferBits write
      SetAccumBufferBits default 0;
    { DepthTest enabling. 
       When DepthTest is enabled, objects closer to the camera will hide
       farther ones (via use of Z-Buffering). 
       When DepthTest is disabled, the latest objects drawn/rendered overlap
       all previous objects, whatever their distance to the camera. 
       Even when DepthTest is enabled, objects may chose to ignore depth
       testing through the osIgnoreDepthBuffer of their ObjectStyle property. }
    property DepthTest: Boolean read FDepthTest write SetDepthTest default True;
    { Enable or disable face culling in the renderer. 
       Face culling is used in hidden faces removal algorithms : each face
       is given a normal or 'outside' direction. When face culling is enabled,
       only faces whose normal points towards the observer are rendered. }
    property FaceCulling: Boolean read FFaceCulling write SetFaceCulling default
      True;
    { Toggle to enable or disable the fog settings. }
    property FogEnable: Boolean read FFogEnable write SetFogEnable default
      False;
    { Toggle to enable or disable lighting calculations. 
       When lighting is enabled, objects will be lit according to lightsources,
       when lighting is disabled, objects are rendered in their own colors,
       without any shading. 
       Lighting does NOT generate shadows in Vulkan. }
    property Lighting: Boolean read FLighting write SetLighting default True;
    { AntiAliasing option. 
       Ignored if not hardware supported, currently based on ARB_multisample. }
    property AntiAliasing: TGLAntiAliasing read FAntiAliasing write
      SetAntiAliasing default aaDefault;
    { Depth buffer precision. 
       Default is highest available (below and including 24 bits) }
    property DepthPrecision: TGLDepthPrecision read FDepthPrecision write
      SetDepthPrecision default dpDefault;
    { Color buffer depth.
       Default depth buffer is highest available (below and including 24 bits) }
    property ColorDepth: TGLColorDepth read FColorDepth write SetColorDepth
      default cdDefault;
    { Shade model. 
       Default is "Smooth".  }
    property ShadeModel: TGLShadeModel read FShadeModel write SetShadeModel
      default smDefault;

    { Indicates a change in the scene or buffer options. 
       A simple re-render is enough to take into account the changes. }
    property OnChange: TNotifyEvent read FOnChange write FOnChange stored False;
    { Indicates a structural change in the scene or buffer options. 
       A reconstruction of the RC is necessary to take into account the
       changes (this may lead to a driver switch or lengthy operations). }
    property OnStructuralChange: TNotifyEvent read FOnStructuralChange write
      FOnStructuralChange stored False;

    { Triggered before the scene's objects get rendered. 
       You may use this event to execute your own Vulkan rendering
       (usually background stuff). }
    property BeforeRender: TNotifyEvent read FBeforeRender write FBeforeRender
      stored False;
    { Triggered after BeforeRender, before rendering objects. 
       This one is fired after the rci has been initialized and can be used
       to alter it or perform early renderings that require an rci,
       the Sender is the buffer. }
    property InitiateRendering: TDirectRenderEvent read FInitiateRendering write
      FInitiateRendering stored False;
    { Triggered after rendering all scene objects, before PostRender. 
       This is the last point after which the rci becomes unavailable,
       the Sender is the buffer. }
    property WrapUpRendering: TDirectRenderEvent read FWrapUpRendering write
      FWrapUpRendering stored False;
    { Triggered just after all the scene's objects have been rendered. 
       The Vulkan context is still active in this event, and you may use it
       to execute your own Vulkan rendering (usually for HUD, 2D overlays
       or after effects).  }
    property PostRender: TNotifyEvent read FPostRender write FPostRender stored
      False;
    { Called after rendering. 
       You cannot issue Vulkan calls in this event, if you want to do your own
       Vulkan stuff, use the PostRender event. }
    property AfterRender: TNotifyEvent read FAfterRender write FAfterRender
      stored False;
  end;

  // TGLNonVisualViewer
  //
  { Base class for non-visual viewer. 
     Non-visual viewer may actually render visuals, but they are non-visual
     (ie. non interactive) at design time. Such viewers include memory
     or full-screen viewers. }
  TGLNonVisualViewer = class(TComponent)
  private
    
    FBuffer: TGLSceneBuffer;
    FWidth, FHeight: Integer;
    FCubeMapRotIdx: Integer;
    FCubeMapZNear, FCubeMapZFar: Single;
    FCubeMapTranslation: TAffineVector;
    //FCreateTexture : Boolean;

  protected
    
    procedure SetBeforeRender(const val: TNotifyEvent);
    function GetBeforeRender: TNotifyEvent;
    procedure SetPostRender(const val: TNotifyEvent);
    function GetPostRender: TNotifyEvent;
    procedure SetAfterRender(const val: TNotifyEvent);
    function GetAfterRender: TNotifyEvent;
    procedure SetCamera(const val: TGLCamera);
    function GetCamera: TGLCamera;
    procedure SetBuffer(const val: TGLSceneBuffer);
    procedure SetWidth(const val: Integer);
    procedure SetHeight(const val: Integer);

    procedure SetupCubeMapCamera(Sender: TObject);
    procedure DoOnPrepareGLContext(Sender: TObject);
    procedure PrepareGLContext; dynamic;
    procedure DoBufferChange(Sender: TObject); virtual;
    procedure DoBufferStructuralChange(Sender: TObject); virtual;

  public
    
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure Notification(AComponent: TComponent; Operation: TOperation);
      override;

    procedure Render(baseObject: TGLBaseSceneObject = nil); virtual; abstract;
    procedure CopyToTexture(aTexture: TGLTexture); overload; virtual;
    procedure CopyToTexture(aTexture: TGLTexture; xSrc, ySrc, width, height:
      Integer;
      xDest, yDest: Integer); overload;
    { CopyToTexture for Multiple-Render-Target }
    procedure CopyToTextureMRT(aTexture: TGLTexture; BufferIndex: integer);
      overload; virtual;
    procedure CopyToTextureMRT(aTexture: TGLTexture; xSrc, ySrc, width, height:
      Integer;
      xDest, yDest: Integer; BufferIndex: integer); overload;
    { Renders the 6 texture maps from a scene. 
       The viewer is used to render the 6 images, one for each face
       of the cube, from the absolute position of the camera. 
       This does NOT alter the content of the Pictures in the image,
       and will only change or define the content of textures as
       registered by Vulkan. }
    procedure RenderCubeMapTextures(cubeMapTexture: TGLTexture;
      zNear: Single = 0;
      zFar: Single = 0);
  published
    
    { Camera from which the scene is rendered. }
    property Camera: TGLCamera read GetCamera write SetCamera;

    property Width: Integer read FWidth write SetWidth default 256;
    property Height: Integer read FHeight write SetHeight default 256;

    { Triggered before the scene's objects get rendered. 
       You may use this event to execute your own Vulkan rendering. }
    property BeforeRender: TNotifyEvent read GetBeforeRender write
      SetBeforeRender;
    { Triggered just after all the scene's objects have been rendered. 
       The Vulkan context is still active in this event, and you may use it
       to execute your own Vulkan rendering.  }
    property PostRender: TNotifyEvent read GetPostRender write SetPostRender;
    { Called after rendering. 
       You cannot issue Vulkan calls in this event, if you want to do your own
       Vulkan stuff, use the PostRender event. }
    property AfterRender: TNotifyEvent read GetAfterRender write SetAfterRender;

    { Access to buffer properties. }
    property Buffer: TGLSceneBuffer read FBuffer write SetBuffer;
  end;

  // TGLMemoryViewer
  //
  { Component to render a scene to memory only. 
     This component curently requires that the Vulkan ICD supports the
     WGL_ARB_pbuffer extension (indirectly). }
  TGLMemoryViewer = class(TGLNonVisualViewer)
  private
    
    FBufferCount: integer;
    procedure SetBufferCount(const Value: integer);

  protected
    

  public
    
    constructor Create(AOwner: TComponent); override;

    procedure InstantiateRenderingContext;

    procedure Render(baseObject: TGLBaseSceneObject = nil); override;

  published
    
    { Set BufferCount > 1 for multiple render targets.  
       Users should check if the corresponding extension (GL_ATI_draw_buffers)
       is supported. Current hardware limit is BufferCount = 4. }
    property BufferCount: integer read FBufferCount write SetBufferCount default
      1;
  end;

  TInvokeInfoForm = procedure(aSceneBuffer: TGLSceneBuffer; Modal: boolean);

  { Register an event handler triggered by any TGLBaseSceneObject Name change. 
     *INCOMPLETE*, currently allows for only 1 (one) event, and is used by
     GLSceneEdit in the IDE. }
procedure RegisterGLBaseSceneObjectNameChangeEvent(notifyEvent: TNotifyEvent);
{ Deregister an event handler triggered by any TGLBaseSceneObject Name change. 
   See RegisterGLBaseSceneObjectNameChangeEvent. }
procedure DeRegisterGLBaseSceneObjectNameChangeEvent(notifyEvent: TNotifyEvent);
{ Register an event handler triggered by any TGLBehaviour Name change. 
   *INCOMPLETE*, currently allows for only 1 (one) event, and is used by
   FBehavioursEditor in the IDE. }
procedure RegisterGLBehaviourNameChangeEvent(notifyEvent: TNotifyEvent);
{ Deregister an event handler triggered by any TGLBaseSceneObject Name change. 
   See RegisterGLBaseSceneObjectNameChangeEvent. }
procedure DeRegisterGLBehaviourNameChangeEvent(notifyEvent: TNotifyEvent);

{ Issues Vulkan calls for drawing X, Y, Z axes in a standard style. }
procedure AxesBuildList(var rci: TGLRenderContextInfo; pattern: Word; AxisLen:
  Single);

{ Registers the procedure call used to invoke the info form. }
procedure RegisterInfoForm(infoForm: TInvokeInfoForm);
procedure InvokeInfoForm(aSceneBuffer: TGLSceneBuffer; Modal: boolean);

function GetCurrentRenderingObject: TGLBaseSceneObject;

  //------------------------------------------------------------------------------
  //------------------------------------------------------------------------------
  //------------------------------------------------------------------------------
implementation
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------

var
  vCounterFrequency: Int64;
{$IFNDEF VKS_MULTITHREAD}
var
{$ELSE}
threadvar
{$ENDIF}
  vCurrentRenderingObject: TGLBaseSceneObject;

function GetCurrentRenderingObject: TGLBaseSceneObject;
begin
  Result := vCurrentRenderingObject;
end;

  // AxesBuildList
  //

procedure AxesBuildList(var rci: TGLRenderContextInfo; pattern: Word; axisLen:
  Single);
begin
{$IFDEF VKS_OPENGL_DEBUG}
  if GL.GREMEDY_string_marker then
    GL.StringMarkerGREMEDY(13, 'AxesBuildList');
{$ENDIF}
  with rci.VKStates do
  begin
    Disable(stLighting);
    if not rci.ignoreBlendingRequests then
    begin
      Enable(stBlend);
      SetBlendFunc(bfSrcAlpha, bfOneMinusSrcAlpha);
    end;
    LineWidth := 1;
    Enable(stLineStipple);
    LineStippleFactor := 1;
    LineStipplePattern := Pattern;
    DepthWriteMask := 1;
    DepthFunc := cfLEqual;
    if rci.bufferDepthTest then
      Enable(stDepthTest);
  end;
  glBegin(GL_LINES);
  glColor3f(0.5, 0.0, 0.0);
  glVertex3f(0, 0, 0);
  glVertex3f(-AxisLen, 0, 0);
  glColor3f(1.0, 0.0, 0.0);
  glVertex3f(0, 0, 0);
  glVertex3f(AxisLen, 0, 0);
  glColor3f(0.0, 0.5, 0.0);
  glVertex3f(0, 0, 0);
  glVertex3f(0, -AxisLen, 0);
  glColor3f(0.0, 1.0, 0.0);
  glVertex3f(0, 0, 0);
  glVertex3f(0, AxisLen, 0);
  glColor3f(0.0, 0.0, 0.5);
  glVertex3f(0, 0, 0);
  glVertex3f(0, 0, -AxisLen);
  glColor3f(0.0, 0.0, 1.0);
  glVertex3f(0, 0, 0);
  glVertex3f(0, 0, AxisLen);
  glEnd;
end;

// RegisterInfoForm
//
var
  vInfoForm: TInvokeInfoForm = nil;

procedure RegisterInfoForm(infoForm: TInvokeInfoForm);
begin
  vInfoForm := infoForm;
end;

// InvokeInfoForm
//

procedure InvokeInfoForm(aSceneBuffer: TGLSceneBuffer; Modal: boolean);
begin
  if Assigned(vInfoForm) then
    vInfoForm(aSceneBuffer, Modal)
  else
    InformationDlg('InfoForm not available.');
end;

//------------------ internal global routines ----------------------------------

var
  vGLBaseSceneObjectNameChangeEvent: TNotifyEvent;
  vGLBehaviourNameChangeEvent: TNotifyEvent;

  // RegisterGLBaseSceneObjectNameChangeEvent
  //

procedure RegisterGLBaseSceneObjectNameChangeEvent(notifyEvent: TNotifyEvent);
begin
  vGLBaseSceneObjectNameChangeEvent := notifyEvent;
end;

// DeRegisterGLBaseSceneObjectNameChangeEvent
//

procedure DeRegisterGLBaseSceneObjectNameChangeEvent(notifyEvent: TNotifyEvent);
begin
  vGLBaseSceneObjectNameChangeEvent := nil;
end;

// RegisterGLBehaviourNameChangeEvent
//

procedure RegisterGLBehaviourNameChangeEvent(notifyEvent: TNotifyEvent);
begin
  vGLBehaviourNameChangeEvent := notifyEvent;
end;

// DeRegisterGLBehaviourNameChangeEvent
//

procedure DeRegisterGLBehaviourNameChangeEvent(notifyEvent: TNotifyEvent);
begin
  vGLBehaviourNameChangeEvent := nil;
end;

// ------------------
// ------------------ TGLBaseSceneObject ------------------
// ------------------

// Create
//

constructor TGLBaseSceneObject.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FObjectStyle := [];
  FChanges := [ocTransformation, ocStructure,
    ocAbsoluteMatrix, ocInvAbsoluteMatrix];
  FPosition := TGLCoordinates.CreateInitialized(Self, NullHmgPoint, csPoint);
  FRotation := TGLCoordinates.CreateInitialized(Self, NullHmgVector, csVector);
  FDirection := TGLCoordinates.CreateInitialized(Self, ZHmgVector, csVector);
  FUp := TGLCoordinates.CreateInitialized(Self, YHmgVector, csVector);
  FScaling := TGLCoordinates.CreateInitialized(Self, XYZHmgVector, csVector);
  GetMem(FLocalMatrix, SizeOf(TMatrix));
  FLocalMatrix^ := IdentityHmgMatrix;
  FVisible := True;
  FPickable := True;
  FObjectsSorting := osInherited;
  FVisibilityCulling := vcInherited;

  fBBChanges := [oBBcChild, oBBcStructure];
  FBoundingBoxPersonalUnscaled := NullBoundingBox;
  FBoundingBoxOfChildren := NullBoundingBox;
  FBoundingBoxIncludingChildren := NullBoundingBox;
end;

// CreateAsChild
//

constructor TGLBaseSceneObject.CreateAsChild(aParentOwner: TGLBaseSceneObject);
begin
  Create(aParentOwner);
  aParentOwner.AddChild(Self);
end;

// Destroy
//

destructor TGLBaseSceneObject.Destroy;
begin
  DeleteChildCameras;
  if assigned(FLocalMatrix) then
    FreeMem(FLocalMatrix, SizeOf(TMatrix));
  if assigned(FAbsoluteMatrix) then
    // This bug have coming surely from a bad commit file.
    FreeMem(FAbsoluteMatrix, SizeOf(TMatrix) * 2);
  // k00m memory fix and remove some leak of the old version.
  FGLObjectEffects.Free;
  FGLBehaviours.Free;
  FListHandle.Free;
  FPosition.Free;
  FRotation.Free;
  FDirection.Free;
  FUp.Free;
  FScaling.Free;
  if Assigned(FParent) then
    FParent.Remove(Self, False);
  if Assigned(FChildren) then
  begin
    DeleteChildren;
    FChildren.Free;
  end;
  inherited Destroy;
end;

// GetHandle
//

function TGLBaseSceneObject.GetHandle(var rci: TGLRenderContextInfo): Cardinal;
begin
  if not Assigned(FListHandle) then
    FListHandle := TGLListHandle.Create;
  Result := FListHandle.Handle;
  if Result = 0 then
    Result := FListHandle.AllocateHandle;

  if ocStructure in FChanges then
  begin
    ClearStructureChanged;
    FListHandle.NotifyChangesOfData;
  end;

  if FListHandle.IsDataNeedUpdate then
  begin
    rci.VKStates.NewList(Result, GL_COMPILE);
    try
      BuildList(rci);
    finally
      rci.VKStates.EndList;
    end;
    FListHandle.NotifyDataUpdated;
  end;
end;

// ListHandleAllocated
//

function TGLBaseSceneObject.ListHandleAllocated: Boolean;
begin
  Result := Assigned(FListHandle)
    and (FListHandle.Handle <> 0)
    and not (ocStructure in FChanges);
end;

// DestroyHandle
//

procedure TGLBaseSceneObject.DestroyHandle;
begin
  if Assigned(FListHandle) then
    FListHandle.DestroyHandle;
end;

// DestroyHandles
//

procedure TGLBaseSceneObject.DestroyHandles;
var
  i: Integer;
begin
  for i := 0 to Count - 1 do
    Children[i].DestroyHandles;
  DestroyHandle;
end;

// SetBBChanges
//

procedure TGLBaseSceneObject.SetBBChanges(const Value: TObjectBBChanges);
begin
  if value <> fBBChanges then
  begin
    fBBChanges := Value;
    if Assigned(FParent) then
      FParent.BBChanges := FParent.BBChanges + [oBBcChild];
  end;
end;

// Blended
//

function TGLBaseSceneObject.Blended: Boolean;
begin
  Result := False;
end;

// BeginUpdate
//

procedure TGLBaseSceneObject.BeginUpdate;
begin
  Inc(FUpdateCount);
end;

// EndUpdate
//

procedure TGLBaseSceneObject.EndUpdate;
begin
  if FUpdateCount > 0 then
  begin
    Dec(FUpdateCount);
    if FUpdateCount = 0 then
      NotifyChange(Self);
  end
  else
    Assert(False, strUnBalancedBeginEndUpdate);
end;

// BuildList
//

procedure TGLBaseSceneObject.BuildList(var rci: TGLRenderContextInfo);
begin
  // nothing
end;

// DeleteChildCameras
//

procedure TGLBaseSceneObject.DeleteChildCameras;
var
  i: Integer;
  child: TGLBaseSceneObject;
begin
  i := 0;
  if Assigned(FChildren) then
    while i < FChildren.Count do
    begin
      child := TGLBaseSceneObject(FChildren.List^[i]);
      child.DeleteChildCameras;
      if child is TGLCamera then
      begin
        Remove(child, True);
        child.Free;
      end
      else
        Inc(i);
    end;
end;

// DeleteChildren
//

procedure TGLBaseSceneObject.DeleteChildren;
var
  child: TGLBaseSceneObject;
begin
  DeleteChildCameras;
  if Assigned(FScene) then
    FScene.RemoveLights(Self);
  if Assigned(FChildren) then
    while FChildren.Count > 0 do
    begin
      child := TGLBaseSceneObject(FChildren.Pop);
      child.FParent := nil;
      child.Free;
    end;
  BBChanges := BBChanges + [oBBcChild];
end;

// Loaded
//

procedure TGLBaseSceneObject.Loaded;
begin
  inherited;
  FPosition.W := 1;
  if Assigned(FGLBehaviours) then
    FGLBehaviours.Loaded;
  if Assigned(FGLObjectEffects) then
    FGLObjectEffects.Loaded;
end;

// DefineProperties
//

procedure TGLBaseSceneObject.DefineProperties(Filer: TFiler);
begin
  inherited;
  {FOriginalFiler := Filer;}

  Filer.DefineBinaryProperty('BehavioursData',
    ReadBehaviours, WriteBehaviours,
    (Assigned(FGLBehaviours) and (FGLBehaviours.Count > 0)));
  Filer.DefineBinaryProperty('EffectsData',
    ReadEffects, WriteEffects,
    (Assigned(FGLObjectEffects) and (FGLObjectEffects.Count > 0)));
  {FOriginalFiler:=nil;}
end;

// WriteBehaviours
//

procedure TGLBaseSceneObject.WriteBehaviours(stream: TStream);
var
  writer: TWriter;
begin
  writer := TWriter.Create(stream, 16384);
  try
    Behaviours.WriteToFiler(writer);
  finally
    writer.Free;
  end;
end;

// ReadBehaviours
//

procedure TGLBaseSceneObject.ReadBehaviours(stream: TStream);
var
  reader: TReader;
begin
  reader := TReader.Create(stream, 16384);
  { with TReader(FOriginalFiler) do  }
  try
    {  reader.Root                 := Root;
      reader.OnError              := OnError;
      reader.OnFindMethod         := OnFindMethod;
      reader.OnSetName            := OnSetName;
      reader.OnReferenceName      := OnReferenceName;
      reader.OnAncestorNotFound   := OnAncestorNotFound;
      reader.OnCreateComponent    := OnCreateComponent;
      reader.OnFindComponentClass := OnFindComponentClass;}
    Behaviours.ReadFromFiler(reader);
  finally
    reader.Free;
  end;
end;

// WriteEffects
//

procedure TGLBaseSceneObject.WriteEffects(stream: TStream);
var
  writer: TWriter;
begin
  writer := TWriter.Create(stream, 16384);
  try
    Effects.WriteToFiler(writer);
  finally
    writer.Free;
  end;
end;

// ReadEffects
//

procedure TGLBaseSceneObject.ReadEffects(stream: TStream);
var
  reader: TReader;
begin
  reader := TReader.Create(stream, 16384);
  {with TReader(FOriginalFiler) do }
  try
    { reader.Root                 := Root;
     reader.OnError              := OnError;
     reader.OnFindMethod         := OnFindMethod;
     reader.OnSetName            := OnSetName;
     reader.OnReferenceName      := OnReferenceName;
     reader.OnAncestorNotFound   := OnAncestorNotFound;
     reader.OnCreateComponent    := OnCreateComponent;
     reader.OnFindComponentClass := OnFindComponentClass;   }
    Effects.ReadFromFiler(reader);
  finally
    reader.Free;
  end;
end;

// WriteRotations
//

procedure TGLBaseSceneObject.WriteRotations(stream: TStream);
begin
  stream.Write(FRotation.AsAddress^, 3 * SizeOf(GLfloat));
end;

// ReadRotations
//

procedure TGLBaseSceneObject.ReadRotations(stream: TStream);
begin
  stream.Read(FRotation.AsAddress^, 3 * SizeOf(GLfloat));
end;

// DrawAxes
//

procedure TGLBaseSceneObject.DrawAxes(var rci: TGLRenderContextInfo; pattern:
  Word);
begin
  AxesBuildList(rci, Pattern, rci.rcci.farClippingDistance -
    rci.rcci.nearClippingDistance);
end;

// GetChildren
//

procedure TGLBaseSceneObject.GetChildren(AProc: TGetChildProc; Root: TComponent);
var
  i: Integer;
begin
  if Assigned(FChildren) then
    for i := 0 to FChildren.Count - 1 do
      if not IsSubComponent(TComponent(FChildren.List^[i])) then
        AProc(TComponent(FChildren.List^[i]));
end;

// Get
//

function TGLBaseSceneObject.Get(Index: Integer): TGLBaseSceneObject;
begin
  if Assigned(FChildren) then
    Result := TGLBaseSceneObject(FChildren[Index])
  else
    Result := nil;
end;

// GetCount
//

function TGLBaseSceneObject.GetCount: Integer;
begin
  if Assigned(FChildren) then
    Result := FChildren.Count
  else
    Result := 0;
end;

// HasSubChildren
//

function TGLBaseSceneObject.HasSubChildren: Boolean;
var
  I: Integer;
begin
  Result := False;
  if Count <> 0 then
    for I := 0 to Count - 1 do
      if IsSubComponent(Children[i]) then
      begin
        Result := True;
        Exit;
      end;
end;

// AddChild
//

procedure TGLBaseSceneObject.AddChild(aChild: TGLBaseSceneObject);
begin
  if Assigned(FScene) then
    FScene.AddLights(aChild);
  if not Assigned(FChildren) then
    FChildren := TPersistentObjectList.Create;
  FChildren.Add(aChild);
  aChild.FParent := Self;
  aChild.SetScene(FScene);
  TransformationChanged;
  aChild.TransformationChanged;
  aChild.DoOnAddedToParent;
  BBChanges := BBChanges + [oBBcChild];
end;

// AddNewChild
//

function TGLBaseSceneObject.AddNewChild(aChild: TGLSceneObjectClass):
  TGLBaseSceneObject;
begin
  Result := aChild.Create(Owner);
  AddChild(Result);
end;

// AddNewChildFirst
//

function TGLBaseSceneObject.AddNewChildFirst(aChild: TGLSceneObjectClass):
  TGLBaseSceneObject;
begin
  Result := aChild.Create(Owner);
  Insert(0, Result);
end;

// GetOrCreateBehaviour
//

function TGLBaseSceneObject.GetOrCreateBehaviour(aBehaviour: TGLBehaviourClass):
  TGLBehaviour;
begin
  Result := TGLBehaviour(Behaviours.GetOrCreate(aBehaviour));
end;

// AddNewBehaviour
//

function TGLBaseSceneObject.AddNewBehaviour(aBehaviour: TGLBehaviourClass):
  TGLBehaviour;
begin
  Assert(Behaviours.CanAdd(aBehaviour));
  result := aBehaviour.Create(Behaviours)
end;

// GetOrCreateEffect
//

function TGLBaseSceneObject.GetOrCreateEffect(anEffect: TGLObjectEffectClass):
  TGLObjectEffect;
begin
  Result := TGLObjectEffect(Effects.GetOrCreate(anEffect));
end;

// AddNewEffect
//

function TGLBaseSceneObject.AddNewEffect(anEffect: TGLObjectEffectClass):
  TGLObjectEffect;
begin
  Assert(Effects.CanAdd(anEffect));
  result := anEffect.Create(Effects)
end;

// RebuildMatrix
//

procedure TGLBaseSceneObject.RebuildMatrix;
begin
  if ocTransformation in Changes then
  begin
    VectorScale(LeftVector, Scale.X, FLocalMatrix^.X);
    VectorScale(FUp.AsVector, Scale.Y, FLocalMatrix^.Y);
    VectorScale(FDirection.AsVector, Scale.Z, FLocalMatrix^.Z);
    SetVector(FLocalMatrix^.W, FPosition.AsVector);
    Exclude(FChanges, ocTransformation);
    Include(FChanges, ocAbsoluteMatrix);
    Include(FChanges, ocInvAbsoluteMatrix);
  end;
end;

// ForceLocalMatrix
//

procedure TGLBaseSceneObject.ForceLocalMatrix(const aMatrix: TMatrix);
begin
  FLocalMatrix^ := aMatrix;
  Exclude(FChanges, ocTransformation);
  Include(FChanges, ocAbsoluteMatrix);
  Include(FChanges, ocInvAbsoluteMatrix);
end;

// AbsoluteMatrixAsAddress
//

function TGLBaseSceneObject.AbsoluteMatrixAsAddress: PMatrix;
begin
  if ocAbsoluteMatrix in FChanges then
  begin
    RebuildMatrix;
    if not Assigned(FAbsoluteMatrix) then
    begin
      GetMem(FAbsoluteMatrix, SizeOf(TMatrix) * 2);
      FInvAbsoluteMatrix := PMatrix(PtrUInt(FAbsoluteMatrix) + SizeOf(TMatrix));
    end;
    if Assigned(Parent) and (not (Parent is TGLSceneRootObject)) then
    begin
      MatrixMultiply(FLocalMatrix^,
        TGLBaseSceneObject(Parent).AbsoluteMatrixAsAddress^,
        FAbsoluteMatrix^);
    end
    else
      FAbsoluteMatrix^ := FLocalMatrix^;
    Exclude(FChanges, ocAbsoluteMatrix);
    Include(FChanges, ocInvAbsoluteMatrix);
  end;
  Result := FAbsoluteMatrix;
end;

// InvAbsoluteMatrix
//

function TGLBaseSceneObject.InvAbsoluteMatrix: TMatrix;
begin
  Result := InvAbsoluteMatrixAsAddress^;
end;

// InvAbsoluteMatrix
//

function TGLBaseSceneObject.InvAbsoluteMatrixAsAddress: PMatrix;
begin
  if ocInvAbsoluteMatrix in FChanges then
  begin
    if VectorEquals(Scale.DirectVector, XYZHmgVector) then
    begin
      if not Assigned(FAbsoluteMatrix) then
      begin
        GetMem(FAbsoluteMatrix, SizeOf(TMatrix) * 2);
        FInvAbsoluteMatrix := PMatrix(PtrUInt(FAbsoluteMatrix) +
          SizeOf(TMatrix));
      end;
      RebuildMatrix;
      if Parent <> nil then
        FInvAbsoluteMatrix^ :=
          MatrixMultiply(Parent.InvAbsoluteMatrixAsAddress^,
          AnglePreservingMatrixInvert(FLocalMatrix^))
      else
        FInvAbsoluteMatrix^ := AnglePreservingMatrixInvert(FLocalMatrix^);
    end
    else
    begin
      FInvAbsoluteMatrix^ := AbsoluteMatrixAsAddress^;
      InvertMatrix(FInvAbsoluteMatrix^);
    end;
    Exclude(FChanges, ocInvAbsoluteMatrix);
  end;
  Result := FInvAbsoluteMatrix;
end;

// GetAbsoluteMatrix
//

function TGLBaseSceneObject.GetAbsoluteMatrix: TMatrix;
begin
  Result := AbsoluteMatrixAsAddress^;
end;

// SetAbsoluteMatrix
//

procedure TGLBaseSceneObject.SetAbsoluteMatrix(const Value: TMatrix);
begin
  if not MatrixEquals(Value, FAbsoluteMatrix^) then
  begin
    FAbsoluteMatrix^ := Value;
    if Parent <> nil then
      SetMatrix(MatrixMultiply(FAbsoluteMatrix^,
        Parent.InvAbsoluteMatrixAsAddress^))
    else
      SetMatrix(Value);
  end;
end;

// GetAbsoluteDirection
//

function TGLBaseSceneObject.GetAbsoluteDirection: TVector;
begin
  Result := VectorNormalize(AbsoluteMatrixAsAddress^.Z);
end;

// SetAbsoluteDirection
//

procedure TGLBaseSceneObject.SetAbsoluteDirection(const v: TVector);
begin
  if Parent <> nil then
    Direction.AsVector := Parent.AbsoluteToLocal(v)
  else
    Direction.AsVector := v;
end;

// GetAbsoluteScale
//

function TGLBaseSceneObject.GetAbsoluteScale: TVector;
begin
  Result.X := AbsoluteMatrixAsAddress^.X.X;
  Result.Y := AbsoluteMatrixAsAddress^.Y.Y;
  Result.Z := AbsoluteMatrixAsAddress^.Z.Z;

  Result.W := 0;
end;

// SetAbsoluteScale
//

procedure TGLBaseSceneObject.SetAbsoluteScale(const Value: TVector);
begin
  if Parent <> nil then
    Scale.AsVector := Parent.AbsoluteToLocal(Value)
  else
    Scale.AsVector := Value;
end;

// GetAbsoluteUp
//

function TGLBaseSceneObject.GetAbsoluteUp: TVector;
begin
  Result := VectorNormalize(AbsoluteMatrixAsAddress^.Y);
end;

// SetAbsoluteUp
//

procedure TGLBaseSceneObject.SetAbsoluteUp(const v: TVector);
begin
  if Parent <> nil then
    Up.AsVector := Parent.AbsoluteToLocal(v)
  else
    Up.AsVector := v;
end;

// AbsoluteRight
//

function TGLBaseSceneObject.AbsoluteRight: TVector;
begin
  Result := VectorNormalize(AbsoluteMatrixAsAddress^.X);
end;

// AbsoluteLeft
//

function TGLBaseSceneObject.AbsoluteLeft: TVector;
begin
  Result := VectorNegate(AbsoluteRight);
end;

// GetAbsolutePosition
//

function TGLBaseSceneObject.GetAbsolutePosition: TVector;
begin
  Result := AbsoluteMatrixAsAddress^.W;
end;

// SetAbsolutePosition
//

procedure TGLBaseSceneObject.SetAbsolutePosition(const v: TVector);
begin
  if Assigned(Parent) then
    Position.AsVector := Parent.AbsoluteToLocal(v)
  else
    Position.AsVector := v;
end;

// AbsolutePositionAsAddress
//

function TGLBaseSceneObject.AbsolutePositionAsAddress: PVector;
begin
  Result := @AbsoluteMatrixAsAddress^.W;
end;

// AbsoluteXVector
//

function TGLBaseSceneObject.AbsoluteXVector: TVector;
begin
  AbsoluteMatrixAsAddress;
  SetVector(Result, PAffineVector(@FAbsoluteMatrix.X)^);
end;

// AbsoluteYVector
//

function TGLBaseSceneObject.AbsoluteYVector: TVector;
begin
  AbsoluteMatrixAsAddress;
  SetVector(Result, PAffineVector(@FAbsoluteMatrix.Y)^);
end;

// AbsoluteZVector
//

function TGLBaseSceneObject.AbsoluteZVector: TVector;
begin
  AbsoluteMatrixAsAddress;
  SetVector(Result, PAffineVector(@FAbsoluteMatrix.Z)^);
end;

// AbsoluteToLocal (hmg)
//

function TGLBaseSceneObject.AbsoluteToLocal(const v: TVector): TVector;
begin
  Result := VectorTransform(v, InvAbsoluteMatrixAsAddress^);
end;

// AbsoluteToLocal (affine)
//

function TGLBaseSceneObject.AbsoluteToLocal(const v: TAffineVector):
  TAffineVector;
begin
  Result := VectorTransform(v, InvAbsoluteMatrixAsAddress^);
end;

// LocalToAbsolute (hmg)
//

function TGLBaseSceneObject.LocalToAbsolute(const v: TVector): TVector;
begin
  Result := VectorTransform(v, AbsoluteMatrixAsAddress^);
end;

// LocalToAbsolute (affine)
//

function TGLBaseSceneObject.LocalToAbsolute(const v: TAffineVector):
  TAffineVector;
begin
  Result := VectorTransform(v, AbsoluteMatrixAsAddress^);
end;

// Right
//

function TGLBaseSceneObject.Right: TVector;
begin
  Result := VectorCrossProduct(FDirection.AsVector, FUp.AsVector);
end;

// LeftVector
//

function TGLBaseSceneObject.LeftVector: TVector;
begin
  Result := VectorCrossProduct(FUp.AsVector, FDirection.AsVector);
end;

// BarycenterAbsolutePosition
//

function TGLBaseSceneObject.BarycenterAbsolutePosition: TVector;
begin
  Result := AbsolutePosition;
end;

// SqrDistanceTo (obj)
//

function TGLBaseSceneObject.SqrDistanceTo(anObject: TGLBaseSceneObject): Single;
begin
  if Assigned(anObject) then
    Result := VectorDistance2(AbsolutePosition, anObject.AbsolutePosition)
  else
    Result := 0;
end;

// SqrDistanceTo (vec4)
//

function TGLBaseSceneObject.SqrDistanceTo(const pt: TVector): Single;
begin
  Result := VectorDistance2(pt, AbsolutePosition);
end;

// DistanceTo (obj)
//

function TGLBaseSceneObject.DistanceTo(anObject: TGLBaseSceneObject): Single;
begin
  if Assigned(anObject) then
    Result := VectorDistance(AbsolutePosition, anObject.AbsolutePosition)
  else
    Result := 0;
end;

// DistanceTo (vec4)
//

function TGLBaseSceneObject.DistanceTo(const pt: TVector): Single;
begin
  Result := VectorDistance(AbsolutePosition, pt);
end;

// BarycenterSqrDistanceTo
//

function TGLBaseSceneObject.BarycenterSqrDistanceTo(const pt: TVector): Single;
var
  d: TVector;
begin
  d := BarycenterAbsolutePosition;
  Result := VectorDistance2(d, pt);
end;

// AxisAlignedDimensions
//

function TGLBaseSceneObject.AxisAlignedDimensions: TVector;
begin
  Result := AxisAlignedDimensionsUnscaled();
  ScaleVector(Result, Scale.AsVector);
end;

// AxisAlignedDimensionsUnscaled
//

function TGLBaseSceneObject.AxisAlignedDimensionsUnscaled: TVector;
begin
  Result.X := 0.5;
  Result.Y := 0.5;
  Result.Z := 0.5;
  Result.W := 0;
end;

// AxisAlignedBoundingBox
//

function TGLBaseSceneObject.AxisAlignedBoundingBox(
  const AIncludeChilden: Boolean): TAABB;
var
  i: Integer;
  aabb: TAABB;
  child: TGLBaseSceneObject;
begin
  SetAABB(Result, AxisAlignedDimensionsUnscaled);
  // not tested for child objects
  if AIncludeChilden and Assigned(FChildren) then
  begin
    for i := 0 to FChildren.Count - 1 do
    begin
      child := TGLBaseSceneObject(FChildren.List^[i]);
      aabb := child.AxisAlignedBoundingBoxUnscaled(AIncludeChilden);
      AABBTransform(aabb, child.Matrix);
      AddAABB(Result, aabb);
    end;
  end;
  AABBScale(Result, Scale.AsAffineVector);
end;

// AxisAlignedBoundingBoxUnscaled
//

function TGLBaseSceneObject.AxisAlignedBoundingBoxUnscaled(
  const AIncludeChilden: Boolean): TAABB;
var
  i: Integer;
  aabb: TAABB;
begin
  SetAABB(Result, AxisAlignedDimensionsUnscaled);
  //not tested for child objects
  if AIncludeChilden and Assigned(FChildren) then
  begin
    for i := 0 to FChildren.Count - 1 do
    begin
      aabb :=
        TGLBaseSceneObject(FChildren.List^[i]).AxisAlignedBoundingBoxUnscaled(AIncludeChilden);
      AABBTransform(aabb, TGLBaseSceneObject(FChildren.List^[i]).Matrix);
      AddAABB(Result, aabb);
    end;
  end;
end;

// AxisAlignedBoundingBoxAbsolute
//

function TGLBaseSceneObject.AxisAlignedBoundingBoxAbsolute(
  const AIncludeChilden: Boolean; const AUseBaryCenter: Boolean): TAABB;
begin
  Result := BBToAABB(BoundingBoxAbsolute(AIncludeChilden, AUseBaryCenter));
end;

// BoundingBox
//

function TGLBaseSceneObject.BoundingBox(const AIncludeChilden: Boolean;
  const AUseBaryCenter: Boolean): THmgBoundingBox;
var
  CurrentBaryOffset: TVector;
begin
  Result := AABBToBB(AxisAlignedBoundingBox(AIncludeChilden));

  // DaStr: code not tested...
  if AUseBaryCenter then
  begin
    CurrentBaryOffset :=
      VectorSubtract(AbsoluteToLocal(BarycenterAbsolutePosition),
      Position.AsVector);
    OffsetBBPoint(Result, CurrentBaryOffset);
  end;
end;

// BoundingBoxUnscaled
//

function TGLBaseSceneObject.BoundingBoxUnscaled(
  const AIncludeChilden: Boolean;
  const AUseBaryCenter: Boolean): THmgBoundingBox;
var
  CurrentBaryOffset: TVector;
begin
  Result := AABBToBB(AxisAlignedBoundingBoxUnscaled(AIncludeChilden));

  // DaStr: code not tested...
  if AUseBaryCenter then
  begin
    CurrentBaryOffset :=
      VectorSubtract(AbsoluteToLocal(BarycenterAbsolutePosition),
      Position.AsVector);
    OffsetBBPoint(Result, CurrentBaryOffset);
  end;
end;

// BoundingBoxAbsolute
//

function TGLBaseSceneObject.BoundingBoxAbsolute(
  const AIncludeChilden: Boolean;
  const AUseBaryCenter: Boolean): THmgBoundingBox;
var
  I: Integer;
  CurrentBaryOffset: TVector;
begin
  Result := BoundingBoxUnscaled(AIncludeChilden, False);
  for I := 0 to 7 do
    Result.BBox[I] := LocalToAbsolute(Result.BBox[I]);

  if AUseBaryCenter then
  begin
    CurrentBaryOffset := VectorSubtract(BarycenterAbsolutePosition,
      AbsolutePosition);
    OffsetBBPoint(Result, CurrentBaryOffset);
  end;
end;

// BoundingSphereRadius
//

function TGLBaseSceneObject.BoundingSphereRadius: Single;
begin
  Result := VectorLength(AxisAlignedDimensions);
end;

// BoundingSphereRadiusUnscaled
//

function TGLBaseSceneObject.BoundingSphereRadiusUnscaled: Single;
begin
  Result := VectorLength(AxisAlignedDimensionsUnscaled);
end;

// PointInObject
//

function TGLBaseSceneObject.PointInObject(const point: TVector): Boolean;
var
  localPt, dim: TVector;
begin
  dim := AxisAlignedDimensions;
  localPt := VectorTransform(point, InvAbsoluteMatrix);
  Result := (Abs(localPt.X * Scale.X) <= dim.X) and
            (Abs(localPt.Y * Scale.Y) <= dim.Y) and
            (Abs(localPt.Z * Scale.Z) <= dim.Z);
end;

// CalculateBoundingBoxPersonalUnscaled
//

procedure TGLBaseSceneObject.CalculateBoundingBoxPersonalUnscaled(var
  ANewBoundingBox: THmgBoundingBox);
begin
  // Using the standard method to get the local BB.
  ANewBoundingBox := AABBToBB(AxisAlignedBoundingBoxUnscaled(False));
  OffsetBBPoint(ANewBoundingBox, AbsoluteToLocal(BarycenterAbsolutePosition));
end;

// BoundingBoxPersonalUnscaledEx
//

function TGLBaseSceneObject.BoundingBoxPersonalUnscaledEx: THmgBoundingBox;
begin
  if oBBcStructure in FBBChanges then
  begin
    CalculateBoundingBoxPersonalUnscaled(FBoundingBoxPersonalUnscaled);
    Exclude(FBBChanges, oBBcStructure);
  end;
  Result := FBoundingBoxPersonalUnscaled;
end;

// AxisAlignedBoundingBoxAbsoluteEx
//

function TGLBaseSceneObject.AxisAlignedBoundingBoxAbsoluteEx: TAABB;
var
  pBB: THmgBoundingBox;
begin
  pBB := BoundingBoxIncludingChildrenEx;
  BBTransform(pBB, AbsoluteMatrix);
  Result := BBtoAABB(pBB);
end;

// AxisAlignedBoundingBoxEx
//

function TGLBaseSceneObject.AxisAlignedBoundingBoxEx: TAABB;
begin
  Result := BBtoAABB(BoundingBoxIncludingChildrenEx);
  AABBScale(Result, Scale.AsAffineVector);
end;

// BoundingBoxOfChildrenEx
//

function TGLBaseSceneObject.BoundingBoxOfChildrenEx: THmgBoundingBox;
var
  i: Integer;
  pBB: THmgBoundingBox;
begin
  if oBBcChild in FBBChanges then
  begin
    // Computing
    FBoundingBoxOfChildren := NullBoundingBox;
    if assigned(FChildren) then
    begin
      for i := 0 to FChildren.count - 1 do
      begin
        pBB :=
          TGLBaseSceneObject(FChildren.List^[i]).BoundingBoxIncludingChildrenEx;
        if not BoundingBoxesAreEqual(@pBB, @NullBoundingBox) then
        begin
          // transformation with local matrix
          BBTransform(pbb, TGLBaseSceneObject(FChildren.List^[i]).Matrix);
          if BoundingBoxesAreEqual(@FBoundingBoxOfChildren, @NullBoundingBox) then
            FBoundingBoxOfChildren := pBB
          else
            AddBB(FBoundingBoxOfChildren, pBB);
        end;
      end;
    end;
    exclude(FBBChanges, oBBcChild);
  end;
  result := FBoundingBoxOfChildren;
end;

// BoundingBoxIncludingChildrenEx
//

function TGLBaseSceneObject.BoundingBoxIncludingChildrenEx: THmgBoundingBox;
var
  pBB: THmgBoundingBox;
begin
  if (oBBcStructure in FBBChanges) or
    (oBBcChild in FBBChanges) then
  begin
    pBB := BoundingBoxPersonalUnscaledEx;
    if BoundingBoxesAreEqual(@pBB, @NullBoundingBox) then
      FBoundingBoxIncludingChildren := BoundingBoxOfChildrenEx
    else
    begin
      FBoundingBoxIncludingChildren := pBB;
      pBB := BoundingBoxOfChildrenEx;
      if not BoundingBoxesAreEqual(@pBB, @NullBoundingBox) then
        AddBB(FBoundingBoxIncludingChildren, pBB);
    end;
  end;
  Result := FBoundingBoxIncludingChildren;
end;

// RayCastIntersect
//

function TGLBaseSceneObject.RayCastIntersect(const rayStart, rayVector: TVector;
  intersectPoint: PVector = nil;
  intersectNormal: PVector = nil): Boolean;
var
  i1, i2, absPos: TVector;
begin
  SetVector(absPos, AbsolutePosition);
  if RayCastSphereIntersect(rayStart, rayVector, absPos, BoundingSphereRadius,
    i1, i2) > 0 then
  begin
    Result := True;
    if Assigned(intersectPoint) then
      SetVector(intersectPoint^, i1);
    if Assigned(intersectNormal) then
    begin
      SubtractVector(i1, absPos);
      NormalizeVector(i1);
      SetVector(intersectNormal^, i1);
    end;
  end
  else
    Result := False;
end;

// GenerateSilhouette
//

function TGLBaseSceneObject.GenerateSilhouette(const silhouetteParameters:
  TGLSilhouetteParameters): TGLSilhouette;
const
  cNbSegments = 21;
var
  i, j: Integer;
  d, r, vr, s, c, angleFactor: Single;
  sVec, tVec: TAffineVector;
begin
  r := BoundingSphereRadiusUnscaled;
  d := VectorLength(silhouetteParameters.SeenFrom);
  // determine visible radius
  case silhouetteParameters.Style of
    ssOmni: vr := SphereVisibleRadius(d, r);
    ssParallel: vr := r;
  else
    Assert(False);
    vr := r;
  end;
  // determine a local orthonormal matrix, viewer-oriented
  sVec := VectorCrossProduct(silhouetteParameters.SeenFrom, XVector);
  if VectorLength(sVec) < 1e-3 then
    sVec := VectorCrossProduct(silhouetteParameters.SeenFrom, YVector);
  tVec := VectorCrossProduct(silhouetteParameters.SeenFrom, sVec);
  NormalizeVector(sVec);
  NormalizeVector(tVec);
  // generate the silhouette (outline and capping)
  Result := TGLSilhouette.Create;
  angleFactor := (2 * PI) / cNbSegments;
  vr := vr * 0.98;
  for i := 0 to cNbSegments - 1 do
  begin
    SinCosine(i * angleFactor, vr, s, c);
    Result.Vertices.AddPoint(VectorCombine(sVec, tVec, s, c));
    j := (i + 1) mod cNbSegments;
    Result.Indices.Add(i, j);
    if silhouetteParameters.CappingRequired then
      Result.CapIndices.Add(cNbSegments, i, j)
  end;
  if silhouetteParameters.CappingRequired then
    Result.Vertices.Add(NullHmgPoint);
end;

// Assign
//

procedure TGLBaseSceneObject.Assign(Source: TPersistent);
var
  i: Integer;
  child, newChild: TGLBaseSceneObject;
begin
  if Assigned(Source) and (Source is TGLBaseSceneObject) then
  begin
    DestroyHandles;
    FVisible := TGLBaseSceneObject(Source).FVisible;
    TGLBaseSceneObject(Source).RebuildMatrix;
    SetMatrix(TGLBaseSceneObject(Source).FLocalMatrix^);
    FShowAxes := TGLBaseSceneObject(Source).FShowAxes;
    FObjectsSorting := TGLBaseSceneObject(Source).FObjectsSorting;
    FVisibilityCulling := TGLBaseSceneObject(Source).FVisibilityCulling;
    FRotation.Assign(TGLBaseSceneObject(Source).FRotation);
    DeleteChildren;
    if Assigned(Scene) then
      Scene.BeginUpdate;
    if Assigned(TGLBaseSceneObject(Source).FChildren) then
    begin
      for i := 0 to TGLBaseSceneObject(Source).FChildren.Count - 1 do
      begin
        child := TGLBaseSceneObject(TGLBaseSceneObject(Source).FChildren[i]);
        newChild := AddNewChild(TGLSceneObjectClass(child.ClassType));
        newChild.Assign(child);
      end;
    end;
    if Assigned(Scene) then
      Scene.EndUpdate;
    OnProgress := TGLBaseSceneObject(Source).OnProgress;
    if Assigned(TGLBaseSceneObject(Source).FGLBehaviours) then
      Behaviours.Assign(TGLBaseSceneObject(Source).Behaviours)
    else
      FreeAndNil(FGLBehaviours);
    if Assigned(TGLBaseSceneObject(Source).FGLObjectEffects) then
      Effects.Assign(TGLBaseSceneObject(Source).Effects)
    else
      FreeAndNil(FGLObjectEffects);
    Tag := TGLBaseSceneObject(Source).Tag;
    FTagFloat := TGLBaseSceneObject(Source).FTagFloat;
  end
  else
    inherited Assign(Source);
end;

// IsUpdating
//

function TGLBaseSceneObject.IsUpdating: Boolean;
begin
  Result := (FUpdateCount <> 0) or (csReading in ComponentState);
end;

// GetParentComponent
//

function TGLBaseSceneObject.GetParentComponent: TComponent;
begin
  if FParent is TGLSceneRootObject then
    Result := FScene
  else
    Result := FParent;
end;

// HasParent
//

function TGLBaseSceneObject.HasParent: Boolean;
begin
  Result := assigned(FParent);
end;

// Lift
//

procedure TGLBaseSceneObject.Lift(aDistance: Single);
begin
  FPosition.AddScaledVector(aDistance, FUp.AsVector);
  TransformationChanged;
end;

// Move
//

procedure TGLBaseSceneObject.Move(ADistance: Single);
begin
  FPosition.AddScaledVector(ADistance, FDirection.AsVector);
  TransformationChanged;
end;

// Slide
//

procedure TGLBaseSceneObject.Slide(ADistance: Single);
begin
  FPosition.AddScaledVector(ADistance, Right);
  TransformationChanged;
end;

// ResetRotations
//

procedure TGLBaseSceneObject.ResetRotations;
begin
  FillChar(FLocalMatrix^, SizeOf(TMatrix), 0);
  FLocalMatrix^.X.X := Scale.DirectX;
  FLocalMatrix^.Y.Y := Scale.DirectY;
  FLocalMatrix^.Z.Z := Scale.DirectZ;
  SetVector(FLocalMatrix^.W, Position.DirectVector);
  FRotation.DirectVector := NullHmgPoint;
  FDirection.DirectVector := ZHmgVector;
  FUp.DirectVector := YHmgVector;
  TransformationChanged;
  Exclude(FChanges, ocTransformation);
end;

// ResetAndPitchTurnRoll
//

procedure TGLBaseSceneObject.ResetAndPitchTurnRoll(const degX, degY, degZ:
  Single);
var
  rotMatrix: TMatrix;
  V: TVector;
begin
  ResetRotations;
  // set DegX (Pitch)
  rotMatrix := CreateRotationMatrix(Right, degX * cPIdiv180);
  V := VectorTransform(FUp.AsVector, rotMatrix);
  NormalizeVector(V);
  FUp.DirectVector := V;
  V := VectorTransform(FDirection.AsVector, rotMatrix);
  NormalizeVector(V);
  FDirection.DirectVector := V;
  FRotation.DirectX := NormalizeDegAngle(DegX);
  // set DegY (Turn)
  rotMatrix := CreateRotationMatrix(FUp.AsVector, degY * cPIdiv180);
  V := VectorTransform(FUp.AsVector, rotMatrix);
  NormalizeVector(V);
  FUp.DirectVector := V;
  V := VectorTransform(FDirection.AsVector, rotMatrix);
  NormalizeVector(V);
  FDirection.DirectVector := V;
  FRotation.DirectY := NormalizeDegAngle(DegY);
  // set DegZ (Roll)
  rotMatrix := CreateRotationMatrix(Direction.AsVector, degZ * cPIdiv180);
  V := VectorTransform(FUp.AsVector, rotMatrix);
  NormalizeVector(V);
  FUp.DirectVector := V;
  V := VectorTransform(FDirection.AsVector, rotMatrix);
  NormalizeVector(V);
  FDirection.DirectVector := V;
  FRotation.DirectZ := NormalizeDegAngle(DegZ);
  TransformationChanged;
  NotifyChange(self);
end;

// RotateAbsolute
//

procedure TGLBaseSceneObject.RotateAbsolute(const rx, ry, rz: Single);
var
  resMat: TMatrix;
  v: TAffineVector;
begin
  resMat := Matrix;
  // No we build rotation matrices and use them to rotate the obj
  if rx <> 0 then
  begin
    SetVector(v, AbsoluteToLocal(XVector));
    resMat := MatrixMultiply(CreateRotationMatrix(v, -DegToRadian(rx)), resMat);
  end;
  if ry <> 0 then
  begin
    SetVector(v, AbsoluteToLocal(YVector));
    resMat := MatrixMultiply(CreateRotationMatrix(v, -DegToRadian(ry)), resMat);
  end;
  if rz <> 0 then
  begin
    SetVector(v, AbsoluteToLocal(ZVector));
    resMat := MatrixMultiply(CreateRotationMatrix(v, -DegToRadian(rz)), resMat);
  end;
  Matrix := resMat;
end;

// RotateAbsolute
//

procedure TGLBaseSceneObject.RotateAbsolute(const axis: TAffineVector; angle:
  Single);
var
  v: TAffineVector;
begin
  if angle <> 0 then
  begin
    SetVector(v, AbsoluteToLocal(axis));
    Matrix := MatrixMultiply(CreateRotationMatrix(v, DegToRadian(angle)), Matrix);
  end;
end;

// Pitch
//

procedure TGLBaseSceneObject.Pitch(angle: Single);
var
  r: Single;
  rightVector: TVector;
begin
  FIsCalculating := True;
  try
    angle := -DegToRadian(angle);
    rightVector := Right;
    FUp.Rotate(rightVector, angle);
    FUp.Normalize;
    FDirection.Rotate(rightVector, angle);
    FDirection.Normalize;
    r := -RadianToDeg(ArcTangent2(FDirection.Y, VectorLength(FDirection.X,
      FDirection.Z)));
    if FDirection.X < 0 then
      if FDirection.Y < 0 then
        r := 180 - r
      else
        r := -180 - r;
    FRotation.X := r;
  finally
    FIsCalculating := False;
  end;
  TransformationChanged;
end;

// SetPitchAngle
//

procedure TGLBaseSceneObject.SetPitchAngle(AValue: Single);
var
  diff: Single;
  rotMatrix: TMatrix;
begin
  if AValue <> FRotation.X then
  begin
    if not (csLoading in ComponentState) then
    begin
      FIsCalculating := True;
      try
        diff := DegToRadian(FRotation.X - AValue);
        rotMatrix := CreateRotationMatrix(Right, diff);
        FUp.DirectVector := VectorTransform(FUp.AsVector, rotMatrix);
        FUp.Normalize;
        FDirection.DirectVector := VectorTransform(FDirection.AsVector,
          rotMatrix);
        FDirection.Normalize;
        TransformationChanged;
      finally
        FIsCalculating := False;
      end;
    end;
    FRotation.DirectX := NormalizeDegAngle(AValue);
  end;
end;

// Roll
//

procedure TGLBaseSceneObject.Roll(angle: Single);
var
  r: Single;
  rightVector, directionVector: TVector;
begin
  FIsCalculating := True;
  try
    angle := DegToRadian(angle);
    directionVector := Direction.AsVector;
    FUp.Rotate(directionVector, angle);
    FUp.Normalize;
    FDirection.Rotate(directionVector, angle);
    FDirection.Normalize;

    // calculate new rotation angle from vectors
    rightVector := Right;
    r := -RadianToDeg(ArcTangent2(rightVector.Y,
              VectorLength(rightVector.X,
                           rightVector.Z)));
    if rightVector.X < 0 then
      if rightVector.Y < 0 then
        r := 180 - r
      else
        r := -180 - r;
    FRotation.Z := r;
  finally
    FIsCalculating := False;
  end;
  TransformationChanged;
end;

// SetRollAngle
//

procedure TGLBaseSceneObject.SetRollAngle(AValue: Single);
var
  diff: Single;
  rotMatrix: TMatrix;
begin
  if AValue <> FRotation.Z then
  begin
    if not (csLoading in ComponentState) then
    begin
      FIsCalculating := True;
      try
        diff := DegToRadian(FRotation.Z - AValue);
        rotMatrix := CreateRotationMatrix(Direction.AsVector, diff);
        FUp.DirectVector := VectorTransform(FUp.AsVector, rotMatrix);
        FUp.Normalize;
        FDirection.DirectVector := VectorTransform(FDirection.AsVector,
          rotMatrix);
        FDirection.Normalize;
        TransformationChanged;
      finally
        FIsCalculating := False;
      end;
    end;
    FRotation.DirectZ := NormalizeDegAngle(AValue);
  end;
end;

// Turn
//

procedure TGLBaseSceneObject.Turn(angle: Single);
var
  r: Single;
  upVector: TVector;
begin
  FIsCalculating := True;
  try
    angle := DegToRadian(angle);
    upVector := Up.AsVector;
    FUp.Rotate(upVector, angle);
    FUp.Normalize;
    FDirection.Rotate(upVector, angle);
    FDirection.Normalize;
    r := -RadianToDeg(ArcTangent2(FDirection.X, VectorLength(FDirection.Y,
      FDirection.Z)));
    if FDirection.X < 0 then
      if FDirection.Y < 0 then
        r := 180 - r
      else
        r := -180 - r;
    FRotation.Y := r;
  finally
    FIsCalculating := False;
  end;
  TransformationChanged;
end;

// SetTurnAngle
//

procedure TGLBaseSceneObject.SetTurnAngle(AValue: Single);
var
  diff: Single;
  rotMatrix: TMatrix;
begin
  if AValue <> FRotation.Y then
  begin
    if not (csLoading in ComponentState) then
    begin
      FIsCalculating := True;
      try
        diff := DegToRadian(FRotation.Y - AValue);
        rotMatrix := CreateRotationMatrix(Up.AsVector, diff);
        FUp.DirectVector := VectorTransform(FUp.AsVector, rotMatrix);
        FUp.Normalize;
        FDirection.DirectVector := VectorTransform(FDirection.AsVector,
          rotMatrix);
        FDirection.Normalize;
        TransformationChanged;
      finally
        FIsCalculating := False;
      end;
    end;
    FRotation.DirectY := NormalizeDegAngle(AValue);
  end;
end;

// SetRotation
//

procedure TGLBaseSceneObject.SetRotation(aRotation: TGLCoordinates);
begin
  FRotation.Assign(aRotation);
  TransformationChanged;
end;

// GetPitchAngle
//

function TGLBaseSceneObject.GetPitchAngle: Single;
begin
  Result := FRotation.X;
end;

// GetTurnAngle
//

function TGLBaseSceneObject.GetTurnAngle: Single;
begin
  Result := FRotation.Y;
end;

// GetRollAngle
//

function TGLBaseSceneObject.GetRollAngle: Single;
begin
  Result := FRotation.Z;
end;

// PointTo
//

procedure TGLBaseSceneObject.PointTo(const ATargetObject: TGLBaseSceneObject;
  const AUpVector: TVector);
begin
  PointTo(ATargetObject.AbsolutePosition, AUpVector);
end;

// PointTo
//

procedure TGLBaseSceneObject.PointTo(const AAbsolutePosition, AUpVector:
  TVector);
var
  absDir, absRight, absUp: TVector;
begin
  // first compute absolute attitude for pointing
  absDir := VectorSubtract(AAbsolutePosition, Self.AbsolutePosition);
  NormalizeVector(absDir);
  absRight := VectorCrossProduct(absDir, AUpVector);
  NormalizeVector(absRight);
  absUp := VectorCrossProduct(absRight, absDir);
  // convert absolute to local and adjust object
  if Parent <> nil then
  begin
    FDirection.AsVector := Parent.AbsoluteToLocal(absDir);
    FUp.AsVector := Parent.AbsoluteToLocal(absUp);
  end
  else
  begin
    FDirection.AsVector := absDir;
    FUp.AsVector := absUp;
  end;
  TransformationChanged
end;

// SetShowAxes
//

procedure TGLBaseSceneObject.SetShowAxes(AValue: Boolean);
begin
  if FShowAxes <> AValue then
  begin
    FShowAxes := AValue;
    NotifyChange(Self);
  end;
end;

// SetScaling
//

procedure TGLBaseSceneObject.SetScaling(AValue: TGLCoordinates);
begin
  FScaling.Assign(AValue);
  TransformationChanged;
end;

// SetName
//

procedure TGLBaseSceneObject.SetName(const NewName: TComponentName);
begin
  if Name <> NewName then
  begin
    inherited SetName(NewName);
    if Assigned(vGLBaseSceneObjectNameChangeEvent) then
      vGLBaseSceneObjectNameChangeEvent(Self);
  end;
end;

// SetParent
//

procedure TGLBaseSceneObject.SetParent(const val: TGLBaseSceneObject);
begin
  MoveTo(val);
end;

// GetIndex
//

function TGLBaseSceneObject.GetIndex: Integer;
begin
  if Assigned(FParent) then
    Result := FParent.FChildren.IndexOf(Self)
  else
    Result := -1;
end;

// SetIndex
//

procedure TGLBaseSceneObject.SetIndex(aValue: Integer);
var
  LCount: Integer;
  parentBackup: TGLBaseSceneObject;
begin
  if Assigned(FParent) then
  begin
    if aValue < 0 then
      aValue := 0;
    LCount := FParent.Count;
    if aValue >= LCount then
      aValue := LCount - 1;
    if aValue <> Index then
    begin
      if Assigned(FScene) then
        FScene.BeginUpdate;
      parentBackup := FParent;
      parentBackup.Remove(Self, False);
      parentBackup.Insert(AValue, Self);
      if Assigned(FScene) then
        FScene.EndUpdate;
    end;
  end;
end;

// SetParentComponent
//

procedure TGLBaseSceneObject.SetParentComponent(Value: TComponent);
begin
  inherited;
  if Value = FParent then
    Exit;

  if Value is TGLScene then
    SetParent(TGLScene(Value).Objects)
  else if Value is TGLBaseSceneObject then
    SetParent(TGLBaseSceneObject(Value))
  else
    SetParent(nil);
end;

// StructureChanged
//

procedure TGLBaseSceneObject.StructureChanged;
begin
  if not (ocStructure in FChanges) then
  begin
    Include(FChanges, ocStructure);
    NotifyChange(Self);
  end
  else if osDirectDraw in ObjectStyle then
    NotifyChange(Self);
end;

// ClearStructureChanged
//

procedure TGLBaseSceneObject.ClearStructureChanged;
begin
  Exclude(FChanges, ocStructure);
  SetBBChanges(BBChanges + [oBBcStructure]);
end;

// RecTransformationChanged
//

procedure TGLBaseSceneObject.RecTransformationChanged;
var
  i: Integer;
  list: PPointerObjectList;
  matSet: TObjectChanges;
begin
  matSet := [ocAbsoluteMatrix, ocInvAbsoluteMatrix];
  if matSet * FChanges <> matSet then
  begin
    FChanges := FChanges + matSet;
    if Assigned(FChildren) then
    begin
      list := FChildren.List;
      for i := 0 to FChildren.Count - 1 do
        TGLBaseSceneObject(list^[i]).RecTransformationChanged;
    end;
  end;
end;

// TransformationChanged
//

procedure TGLBaseSceneObject.TransformationChanged;
begin
  if not (ocTransformation in FChanges) then
  begin
    Include(FChanges, ocTransformation);
    RecTransformationChanged;
    if not (csLoading in ComponentState) then
      NotifyChange(Self);
  end;
end;

// MoveTo
//

procedure TGLBaseSceneObject.MoveTo(newParent: TGLBaseSceneObject);
begin
  if newParent = FParent then
    Exit;
  if Assigned(FParent) then
  begin
    FParent.Remove(Self, False);
    FParent := nil;
  end;
  if Assigned(newParent) then
    newParent.AddChild(Self)
  else
    SetScene(nil);
end;

// MoveUp
//

procedure TGLBaseSceneObject.MoveUp;
begin
  if Assigned(parent) then
    parent.MoveChildUp(parent.IndexOfChild(Self));
end;

// MoveDown
//

procedure TGLBaseSceneObject.MoveDown;
begin
  if Assigned(parent) then
    parent.MoveChildDown(parent.IndexOfChild(Self));
end;

// MoveFirst
//

procedure TGLBaseSceneObject.MoveFirst;
begin
  if Assigned(parent) then
    parent.MoveChildFirst(parent.IndexOfChild(Self));
end;

// MoveLast
//

procedure TGLBaseSceneObject.MoveLast;
begin
  if Assigned(parent) then
    parent.MoveChildLast(parent.IndexOfChild(Self));
end;

// MoveObjectAroundTarget
//

procedure TGLBaseSceneObject.MoveObjectAround(anObject: TGLBaseSceneObject;
  pitchDelta, turnDelta: Single);
var
  originalT2C, normalT2C, normalCameraRight, newPos: TVector;
  pitchNow, dist: Single;
begin
  if Assigned(anObject) then
  begin
    // normalT2C points away from the direction the camera is looking
    originalT2C := VectorSubtract(AbsolutePosition,
      anObject.AbsolutePosition);
    SetVector(normalT2C, originalT2C);
    dist := VectorLength(normalT2C);
    NormalizeVector(normalT2C);
    // normalRight points to the camera's right
    // the camera is pitching around this axis.
    normalCameraRight := VectorCrossProduct(AbsoluteUp, normalT2C);
    if VectorLength(normalCameraRight) < 0.001 then
      SetVector(normalCameraRight, XVector) // arbitrary vector
    else
      NormalizeVector(normalCameraRight);
    // calculate the current pitch.
    // 0 is looking down and PI is looking up
    pitchNow := ArcCosine(VectorDotProduct(AbsoluteUp, normalT2C));
    pitchNow := ClampValue(pitchNow + DegToRadian(pitchDelta), 0 + 0.025, PI -
      0.025);
    // create a new vector pointing up and then rotate it down
    // into the new position
    SetVector(normalT2C, AbsoluteUp);
    RotateVector(normalT2C, normalCameraRight, -pitchNow);
    RotateVector(normalT2C, AbsoluteUp, -DegToRadian(turnDelta));
    ScaleVector(normalT2C, dist);
    newPos := VectorAdd(AbsolutePosition, VectorSubtract(normalT2C,
      originalT2C));
    if Assigned(Parent) then
      newPos := Parent.AbsoluteToLocal(newPos);
    Position.AsVector := newPos;
  end;
end;

// MoveObjectAllAround
//

procedure TGLBaseSceneObject.MoveObjectAllAround(anObject: TGLBaseSceneObject;
  pitchDelta, turnDelta: Single);
var
  upvector: TVector;
  lookat : TVector;
  rightvector : TVector;
  tempvector: TVector;
  T2C: TVector;

begin

  // if camera has got a target
  if Assigned(anObject) then
  begin
    //vector camera to target
    lookat := VectorNormalize(VectorSubtract(anObject.AbsolutePosition, AbsolutePosition));
    //camera up vector
    upvector := VectorNormalize(AbsoluteUp);

    // if upvector and lookat vector are colinear, it is necessary to compute new up vector
    if Abs(VectorDotProduct(lookat,upvector))>0.99 then
    begin
      //X or Y vector use to generate upvector
      SetVector(tempvector,1,0,0);
      //if lookat is colinear to X vector use Y vector to generate upvector
      if Abs(VectorDotProduct(tempvector,lookat))>0.99 then
      begin
        SetVector(tempvector,0,1,0);
      end;
      upvector:= VectorCrossProduct(tempvector,lookat);
      rightvector := VectorCrossProduct(lookat,upvector);
    end
    else
    begin
      rightvector := VectorCrossProduct(lookat,upvector);
      upvector:= VectorCrossProduct(rightvector,lookat);
    end;
    //now the up right and lookat vector are orthogonal

    // vector Target to camera
    T2C:= VectorSubtract(AbsolutePosition,anObject.AbsolutePosition);
    RotateVector(T2C,rightvector,DegToRadian(-PitchDelta));
    RotateVector(T2C,upvector,DegToRadian(-TurnDelta));
    AbsolutePosition := VectorAdd(anObject.AbsolutePosition, T2C);

    //now update new up vector
    RotateVector(upvector,rightvector,DegToRadian(-PitchDelta));
    AbsoluteUp := upvector;
    AbsoluteDirection := VectorSubtract(anObject.AbsolutePosition,AbsolutePosition);

  end;
end;

// CoordinateChanged
//

procedure TGLBaseSceneObject.CoordinateChanged(Sender: TGLCustomCoordinates);
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
      // adjust up vector
      rightVector := VectorCrossProduct(FDirection.AsVector, FUp.AsVector);
      // Rightvector is zero if direction changed exactly by 90 degrees,
      // in this case assume a default vector
      if VectorLength(rightVector) < 1e-5 then
      begin
        rightVector := VectorCrossProduct(ZHmgVector, FUp.AsVector);
        if VectorLength(rightVector) < 1e-5 then
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
      // adjust up vector
      rightVector := VectorCrossProduct(FDirection.AsVector, FUp.AsVector);
      // Rightvector is zero if direction changed exactly by 90 degrees,
      // in this case assume a default vector
      if VectorLength(rightVector) < 1e-5 then
      begin
        rightVector := VectorCrossProduct(ZHmgVector, FUp.AsVector);
        if VectorLength(rightVector) < 1e-5 then
          rightVector := VectorCrossProduct(XHmgVector, FUp.AsVector);
      end;
      FDirection.DirectVector := VectorCrossProduct(FUp.AsVector, RightVector);
      FDirection.Normalize;
    end;
    TransformationChanged;
  finally
    FIsCalculating := False;
  end;
end;

// DoProgress
//

procedure TGLBaseSceneObject.DoProgress(const progressTime: TProgressTimes);
var
  i: Integer;
begin
  if Assigned(FChildren) then
    for i := FChildren.Count - 1 downto 0 do
      TGLBaseSceneObject(FChildren.List^[i]).DoProgress(progressTime);
  if Assigned(FGLBehaviours) then
    FGLBehaviours.DoProgress(progressTime);
  if Assigned(FGLObjectEffects) then
    FGLObjectEffects.DoProgress(progressTime);
  if Assigned(FOnProgress) then
    with progressTime do
      FOnProgress(Self, deltaTime, newTime);
end;

// Insert
//

procedure TGLBaseSceneObject.Insert(aIndex: Integer; aChild:
  TGLBaseSceneObject);
begin
  if not Assigned(FChildren) then
    FChildren := TPersistentObjectList.Create;
  with FChildren do
  begin
    if Assigned(aChild.FParent) then
      aChild.FParent.Remove(aChild, False);
    Insert(aIndex, aChild);
  end;
  aChild.FParent := Self;
  if AChild.FScene <> FScene then
    AChild.DestroyHandles;
  AChild.SetScene(FScene);
  if Assigned(FScene) then
    FScene.AddLights(aChild);
  AChild.TransformationChanged;

  aChild.DoOnAddedToParent;
end;

// Remove
//

procedure TGLBaseSceneObject.Remove(aChild: TGLBaseSceneObject; keepChildren:
  Boolean);
var
  I: Integer;
begin
  if not Assigned(FChildren) then
    Exit;
  if aChild.Parent = Self then
  begin
    if Assigned(FScene) then
      FScene.RemoveLights(aChild);
    if aChild.Owner = Self then
      RemoveComponent(aChild);
    FChildren.Remove(aChild);
    aChild.FParent := nil;
    if keepChildren then
    begin
      BeginUpdate;
      if aChild.Count <> 0 then
        for I := aChild.Count - 1 downto 0 do
          if not IsSubComponent(aChild.Children[I]) then
            aChild.Children[I].MoveTo(Self);
      EndUpdate;
    end
    else
      NotifyChange(Self);
  end;
end;

// IndexOfChild
//

function TGLBaseSceneObject.IndexOfChild(aChild: TGLBaseSceneObject): Integer;
begin
  if Assigned(FChildren) then
    Result := FChildren.IndexOf(aChild)
  else
    Result := -1;
end;

// FindChild
//

function TGLBaseSceneObject.FindChild(const aName: string;
  ownChildrenOnly: Boolean): TGLBaseSceneObject;
var
  i: integer;
  res: TGLBaseSceneObject;
begin
  res := nil;
  Result := nil;
  if not Assigned(FChildren) then
    Exit;
  for i := 0 to FChildren.Count - 1 do
  begin
    if CompareText(TGLBaseSceneObject(FChildren[i]).Name, aName) = 0 then
    begin
      res := TGLBaseSceneObject(FChildren[i]);
      Break;
    end;
  end;
  if not ownChildrenOnly then
  begin
    for i := 0 to FChildren.Count - 1 do
      with TGLBaseSceneObject(FChildren[i]) do
      begin
        Result := FindChild(aName, ownChildrenOnly);
        if Assigned(Result) then
          Break;
      end;
  end;
  if not Assigned(Result) then
    Result := res;
end;

// ExchangeChildren
//

procedure TGLBaseSceneObject.ExchangeChildren(anIndex1, anIndex2: Integer);
begin
  Assert(Assigned(FChildren), 'No children found!');
  FChildren.Exchange(anIndex1, anIndex2);
  NotifyChange(Self);
end;

// ExchangeChildrenSafe
//

procedure TGLBaseSceneObject.ExchangeChildrenSafe(anIndex1, anIndex2: Integer);
begin
  Assert(Assigned(FChildren), 'No children found!');
  if (anIndex1 < FChildren.Count) and (anIndex2 < FChildren.Count) and
    (anIndex1 > -1) and (anIndex2 > -1) and (anIndex1 <> anIndex2) then
  begin
    FChildren.Exchange(anIndex1, anIndex2);
    NotifyChange(Self);
  end;
end;

// MoveChildUp
//

procedure TGLBaseSceneObject.MoveChildUp(anIndex: Integer);
begin
  Assert(Assigned(FChildren), 'No children found!');
  if anIndex > 0 then
  begin
    FChildren.Exchange(anIndex, anIndex - 1);
    NotifyChange(Self);
  end;
end;

// MoveChildDown
//

procedure TGLBaseSceneObject.MoveChildDown(anIndex: Integer);
begin
  Assert(Assigned(FChildren), 'No children found!');
  if anIndex < FChildren.Count - 1 then
  begin
    FChildren.Exchange(anIndex, anIndex + 1);
    NotifyChange(Self);
  end;
end;

// MoveChildFirst
//

procedure TGLBaseSceneObject.MoveChildFirst(anIndex: Integer);
begin
  Assert(Assigned(FChildren), 'No children found!');
  if anIndex <> 0 then
  begin
    FChildren.Move(anIndex, 0);
    NotifyChange(Self);
  end;
end;

// MoveChildLast
//

procedure TGLBaseSceneObject.MoveChildLast(anIndex: Integer);
begin
  Assert(Assigned(FChildren), 'No children found!');
  if anIndex <> FChildren.Count - 1 then
  begin
    FChildren.Move(anIndex, FChildren.Count - 1);
    NotifyChange(Self);
  end;
end;

// Render
//

procedure TGLBaseSceneObject.Render(var ARci: TGLRenderContextInfo);
var
  shouldRenderSelf, shouldRenderChildren: Boolean;
  aabb: TAABB;
  master: TObject;
begin
{$IFDEF VKS_OPENGL_DEBUG}
  if GL.GREMEDY_string_marker then
    GL.StringMarkerGREMEDY(
      Length(Name) + Length('.Render'), PGLChar(String(Name + '.Render')));
{$ENDIF}
  if (ARci.drawState = dsPicking) and not FPickable then
    exit;
  // visibility culling determination
  if ARci.visibilityCulling in [vcObjectBased, vcHierarchical] then
  begin
    if ARci.visibilityCulling = vcObjectBased then
    begin
      shouldRenderSelf := (osNoVisibilityCulling in ObjectStyle)
        or (not IsVolumeClipped(BarycenterAbsolutePosition,
        BoundingSphereRadius,
        ARci.rcci.frustum));
      shouldRenderChildren := Assigned(FChildren);
    end
    else
    begin // vcHierarchical
      aabb := AxisAlignedBoundingBox;
      shouldRenderSelf := (osNoVisibilityCulling in ObjectStyle)
        or (not IsVolumeClipped(aabb.min, aabb.max, ARci.rcci.frustum));
      shouldRenderChildren := shouldRenderSelf and Assigned(FChildren);
    end;
    if not (shouldRenderSelf or shouldRenderChildren) then
      Exit;
  end
  else
  begin
    Assert(ARci.visibilityCulling in [vcNone, vcInherited],
      'Unknown visibility culling option');
    shouldRenderSelf := True;
    shouldRenderChildren := Assigned(FChildren);
  end;

  // Prepare Matrix and PickList stuff
  ARci.PipelineTransformation.Push;
  if ocTransformation in FChanges then
    RebuildMatrix;

  if ARci.proxySubObject then
    ARci.PipelineTransformation.ModelMatrix :=
      MatrixMultiply(LocalMatrix^, ARci.PipelineTransformation.ModelMatrix)
  else
    ARci.PipelineTransformation.ModelMatrix := AbsoluteMatrix;

  master := nil;
  if ARci.drawState = dsPicking then
  begin
    if ARci.proxySubObject then
      master := TGLSceneBuffer(ARci.buffer).FSelector.CurrentObject;
    TGLSceneBuffer(ARci.buffer).FSelector.CurrentObject := Self;
  end;

  // Start rendering
  if shouldRenderSelf then
  begin
    vCurrentRenderingObject := Self;
{$IFNDEF VKS_OPTIMIZATIONS}
    if FShowAxes then
      DrawAxes(ARci, $CCCC);
{$ENDIF}
    if Assigned(FGLObjectEffects) and (FGLObjectEffects.Count > 0) then
    begin
      ARci.PipelineTransformation.Push;
      FGLObjectEffects.RenderPreEffects(ARci);
      ARci.PipelineTransformation.Pop;

      ARci.PipelineTransformation.Push;
      if osIgnoreDepthBuffer in ObjectStyle then
      begin
        ARci.VKStates.Disable(stDepthTest);
        DoRender(ARci, True, shouldRenderChildren);
        ARci.VKStates.Enable(stDepthTest);
      end
      else
        DoRender(ARci, True, shouldRenderChildren);

      FGLObjectEffects.RenderPostEffects(ARci);
      ARci.PipelineTransformation.Pop;
    end
    else
    begin
      if osIgnoreDepthBuffer in ObjectStyle then
      begin
        ARci.VKStates.Disable(stDepthTest);
        DoRender(ARci, True, shouldRenderChildren);
        ARci.VKStates.Enable(stDepthTest);
      end
      else
        DoRender(ARci, True, shouldRenderChildren);

    end;
    vCurrentRenderingObject := nil;
  end
  else
  begin
    if (osIgnoreDepthBuffer in ObjectStyle) and
      TGLSceneBuffer(ARCi.buffer).DepthTest then
    begin
      ARci.VKStates.Disable(stDepthTest);
      DoRender(ARci, False, shouldRenderChildren);
      ARci.VKStates.Enable(stDepthTest);
    end
    else
      DoRender(ARci, False, shouldRenderChildren);
  end;
  // Pop Name & Matrix
  if Assigned(master) then
    TGLSceneBuffer(ARci.buffer).FSelector.CurrentObject := master;
  ARci.PipelineTransformation.Pop;
end;

// DoRender
//

procedure TGLBaseSceneObject.DoRender(var ARci: TGLRenderContextInfo;
  ARenderSelf, ARenderChildren: Boolean);
begin
  // start rendering self
  if ARenderSelf then
  begin
    if (osDirectDraw in ObjectStyle) or ARci.amalgamating then
      BuildList(ARci)
    else
      ARci.VKStates.CallList(GetHandle(ARci));
  end;
  // start rendering children (if any)
  if ARenderChildren then
    Self.RenderChildren(0, Count - 1, ARci);
end;

// RenderChildren
//

procedure TGLBaseSceneObject.RenderChildren(firstChildIndex, lastChildIndex:
  Integer;
  var rci: TGLRenderContextInfo);
var
  i: Integer;
  objList: TPersistentObjectList;
  distList: TSingleList;
  plist: PPointerObjectList;
  obj: TGLBaseSceneObject;
  oldSorting: TGLObjectsSorting;
  oldCulling: TGLVisibilityCulling;
begin
  if not Assigned(FChildren) then
    Exit;
  oldCulling := rci.visibilityCulling;
  if Self.VisibilityCulling <> vcInherited then
    rci.visibilityCulling := Self.VisibilityCulling;
  if lastChildIndex = firstChildIndex then
  begin
    obj := TGLBaseSceneObject(FChildren.List^[firstChildIndex]);
    if obj.Visible then
      obj.Render(rci)
  end
  else if lastChildIndex > firstChildIndex then
  begin
    oldSorting := rci.objectsSorting;
    if Self.ObjectsSorting <> osInherited then
      rci.objectsSorting := Self.ObjectsSorting;
    case rci.objectsSorting of
      osNone:
        begin
          plist := FChildren.List;
          for i := firstChildIndex to lastChildIndex do
          begin
            obj := TGLBaseSceneObject(plist^[i]);
            if obj.Visible then
              obj.Render(rci);
          end;
        end;
      osRenderFarthestFirst, osRenderBlendedLast, osRenderNearestFirst:
        begin
          distList := TSingleList.Create;
          objList := TPersistentObjectList.Create;
          distList.GrowthDelta := lastChildIndex + 1; // no reallocations
          objList.GrowthDelta := distList.GrowthDelta;
          try
            case rci.objectsSorting of
              osRenderBlendedLast:
                // render opaque stuff
                for i := firstChildIndex to lastChildIndex do
                begin
                  obj := TGLBaseSceneObject(FChildren.List^[i]);
                  if obj.Visible then
                  begin
                    if not obj.Blended then
                      obj.Render(rci)
                    else
                    begin
                      objList.Add(obj);
                      distList.Add(1 +
                        obj.BarycenterSqrDistanceTo(rci.cameraPosition));
                    end;
                  end;
                end;
              osRenderFarthestFirst:
                for i := firstChildIndex to lastChildIndex do
                begin
                  obj := TGLBaseSceneObject(FChildren.List^[i]);
                  if obj.Visible then
                  begin
                    objList.Add(obj);
                    distList.Add(1 +
                      obj.BarycenterSqrDistanceTo(rci.cameraPosition));
                  end;
                end;
              osRenderNearestFirst:
                for i := firstChildIndex to lastChildIndex do
                begin
                  obj := TGLBaseSceneObject(FChildren.List^[i]);
                  if obj.Visible then
                  begin
                    objList.Add(obj);
                    distList.Add(-1 -
                      obj.BarycenterSqrDistanceTo(rci.cameraPosition));
                  end;
                end;
            else
              Assert(False);
            end;
            if distList.Count > 0 then
            begin
              if distList.Count > 1 then
                FastQuickSortLists(0, distList.Count - 1, distList, objList);
              plist := objList.List;
              for i := objList.Count - 1 downto 0 do
                TGLBaseSceneObject(plist^[i]).Render(rci);
            end;
          finally
            objList.Free;
            distList.Free;
          end;
        end;
    else
      Assert(False);
    end;
    rci.objectsSorting := oldSorting;
  end;
  rci.visibilityCulling := oldCulling;
end;

// NotifyChange
//

procedure TGLBaseSceneObject.NotifyChange(Sender: TObject);
begin
  if Assigned(FScene) and (not IsUpdating) then
    FScene.NotifyChange(Self);
end;

// GetMatrix
//

function TGLBaseSceneObject.GetMatrix: TMatrix;
begin
  RebuildMatrix;
  Result := FLocalMatrix^;
end;

// MatrixAsAddress
//

function TGLBaseSceneObject.MatrixAsAddress: PMatrix;
begin
  RebuildMatrix;
  Result := FLocalMatrix;
end;

// SetMatrix
//

procedure TGLBaseSceneObject.SetMatrix(const aValue: TMatrix);
begin
  FLocalMatrix^ := aValue;
  FDirection.DirectVector := VectorNormalize(FLocalMatrix^.Z);
  FUp.DirectVector := VectorNormalize(FLocalMatrix^.Y);
  Scale.SetVector(VectorLength(FLocalMatrix^.X),
    VectorLength(FLocalMatrix^.Y),
    VectorLength(FLocalMatrix^.Z), 0);
  FPosition.DirectVector := FLocalMatrix^.W;
  TransformationChanged;
end;

procedure TGLBaseSceneObject.SetPosition(APosition: TGLCoordinates);
begin
  FPosition.SetPoint(APosition.DirectX, APosition.DirectY, APosition.DirectZ);
end;

procedure TGLBaseSceneObject.SetDirection(AVector: TGLCoordinates);
begin
  if not VectorIsNull(AVector.DirectVector) then
    FDirection.SetVector(AVector.DirectX, AVector.DirectY, AVector.DirectZ);
end;

procedure TGLBaseSceneObject.SetUp(AVector: TGLCoordinates);
begin
  if not VectorIsNull(AVector.DirectVector) then
    FUp.SetVector(AVector.DirectX, AVector.DirectY, AVector.DirectZ);
end;

function TGLBaseSceneObject.GetVisible: Boolean;
begin
  Result := FVisible;
end;

function TGLBaseSceneObject.GetPickable: Boolean;
begin
  Result := FPickable;
end;

// SetVisible
//

procedure TGLBaseSceneObject.SetVisible(aValue: Boolean);
begin
  if FVisible <> aValue then
  begin
    FVisible := AValue;
    NotifyChange(Self);
  end;
end;

// SetPickable
//

procedure TGLBaseSceneObject.SetPickable(aValue: Boolean);
begin
  if FPickable <> aValue then
  begin
    FPickable := AValue;
    NotifyChange(Self);
  end;
end;

// SetObjectsSorting
//

procedure TGLBaseSceneObject.SetObjectsSorting(const val: TGLObjectsSorting);
begin
  if FObjectsSorting <> val then
  begin
    FObjectsSorting := val;
    NotifyChange(Self);
  end;
end;

// SetVisibilityCulling
//

procedure TGLBaseSceneObject.SetVisibilityCulling(const val:
  TGLVisibilityCulling);
begin
  if FVisibilityCulling <> val then
  begin
    FVisibilityCulling := val;
    NotifyChange(Self);
  end;
end;

// SetBehaviours
//

procedure TGLBaseSceneObject.SetBehaviours(const val: TGLBehaviours);
begin
  Behaviours.Assign(val);
end;

// GetBehaviours
//

function TGLBaseSceneObject.GetBehaviours: TGLBehaviours;
begin
  if not Assigned(FGLBehaviours) then
    FGLBehaviours := TGLBehaviours.Create(Self);
  Result := FGLBehaviours;
end;

// SetEffects
//

procedure TGLBaseSceneObject.SetEffects(const val: TGLObjectEffects);
begin
  Effects.Assign(val);
end;

// GetEffects
//

function TGLBaseSceneObject.GetEffects: TGLObjectEffects;
begin
  if not Assigned(FGLObjectEffects) then
    FGLObjectEffects := TGLObjectEffects.Create(Self);
  Result := FGLObjectEffects;
end;

// SetScene
//

procedure TGLBaseSceneObject.SetScene(const value: TGLScene);
var
  i: Integer;
begin
  if value <> FScene then
  begin
    // must be freed, the new scene may be using a non-compatible RC
    if FScene <> nil then
      DestroyHandles;
    FScene := value;
    // propagate for childs
    if Assigned(FChildren) then
      for i := 0 to FChildren.Count - 1 do
        Children[I].SetScene(FScene);
  end;
end;

// Translate
//

procedure TGLBaseSceneObject.Translate(tx, ty, tz: Single);
begin
  FPosition.Translate(AffineVectorMake(tx, ty, tz));
end;

// GetAbsoluteAffinePosition
//

function TGLBaseSceneObject.GetAbsoluteAffinePosition: TAffineVector;
var
  temp: TVector;
begin
  temp := GetAbsolutePosition;
  Result := AffineVectorMake(temp.X, temp.Y, temp.Z);
end;

// GetAbsoluteAffineDirection
//

function TGLBaseSceneObject.GetAbsoluteAffineDirection: TAffineVector;
var
  temp: TVector;
begin
  temp := GetAbsoluteDirection;
  Result := AffineVectorMake(temp.X, temp.Y, temp.Z);
end;

// GetAbsoluteAffineUp
//

function TGLBaseSceneObject.GetAbsoluteAffineUp: TAffineVector;
var
  temp: TVector;
begin
  temp := GetAbsoluteUp;
  Result := AffineVectorMake(temp.X, temp.Y, temp.Z);
end;

// SetAbsoluteAffinePosition
//

procedure TGLBaseSceneObject.SetAbsoluteAffinePosition(const Value:
  TAffineVector);
begin
  SetAbsolutePosition(VectorMake(Value, 1));
end;

// SetAbsoluteAffineUp
//

procedure TGLBaseSceneObject.SetAbsoluteAffineUp(const v: TAffineVector);
begin
  SetAbsoluteUp(VectorMake(v, 1));
end;

// SetAbsoluteAffineDirection
//

procedure TGLBaseSceneObject.SetAbsoluteAffineDirection(const v: TAffineVector);
begin
  SetAbsoluteDirection(VectorMake(v, 1));
end;

// AffineLeftVector
//

function TGLBaseSceneObject.AffineLeftVector: TAffineVector;
begin
  Result := AffineVectorMake(LeftVector);
end;

// AffineRight
//

function TGLBaseSceneObject.AffineRight: TAffineVector;
begin
  Result := AffineVectorMake(Right);
end;

// DistanceTo
//

function TGLBaseSceneObject.DistanceTo(const pt: TAffineVector): Single;
begin
  Result := VectorDistance(AbsoluteAffinePosition, pt);
end;

// SqrDistanceTo
//

function TGLBaseSceneObject.SqrDistanceTo(const pt: TAffineVector): Single;
begin
  Result := VectorDistance2(AbsoluteAffinePosition, pt);
end;

// DoOnAddedToParent
//

procedure TGLBaseSceneObject.DoOnAddedToParent;
begin
  if Assigned(FOnAddedToParent) then
    FOnAddedToParent(self);
end;

// GetAbsoluteAffineScale
//

function TGLBaseSceneObject.GetAbsoluteAffineScale: TAffineVector;
begin
  Result := AffineVectorMake(GetAbsoluteScale);
end;

// SetAbsoluteAffineScale
//

procedure TGLBaseSceneObject.SetAbsoluteAffineScale(
  const Value: TAffineVector);
begin
  SetAbsoluteScale(VectorMake(Value, GetAbsoluteScale.W));
end;

// ------------------
// ------------------ TGLBaseBehaviour ------------------
// ------------------

// Create
//

constructor TGLBaseBehaviour.Create(aOwner: TGLXCollection);
begin
  inherited Create(aOwner);
  // nothing more, yet
end;

// Destroy
//

destructor TGLBaseBehaviour.Destroy;
begin
  // nothing more, yet
  inherited Destroy;
end;

// SetName
//

procedure TGLBaseBehaviour.SetName(const val: string);
begin
  inherited SetName(val);
  if Assigned(vGLBehaviourNameChangeEvent) then
    vGLBehaviourNameChangeEvent(Self);
end;

// WriteToFiler
//

procedure TGLBaseBehaviour.WriteToFiler(writer: TWriter);
begin
  inherited;

  with writer do
  begin
    WriteInteger(0); // Archive Version 0
    // nothing more, yet
  end;
end;

// ReadFromFiler
//

procedure TGLBaseBehaviour.ReadFromFiler(reader: TReader);
begin
  if Owner.ArchiveVersion > 0 then
    inherited;

  with reader do
  begin
    if ReadInteger <> 0 then
      Assert(False);
    // nothing more, yet
  end;
end;

// OwnerBaseSceneObject
//

function TGLBaseBehaviour.OwnerBaseSceneObject: TGLBaseSceneObject;
begin
  Result := TGLBaseSceneObject(Owner.Owner);
end;

// DoProgress
//

procedure TGLBaseBehaviour.DoProgress(const progressTime: TProgressTimes);
begin
  // does nothing
end;

// ------------------
// ------------------ TGLBehaviours ------------------
// ------------------

// Create
//

constructor TGLBehaviours.Create(aOwner: TPersistent);
begin
  Assert(aOwner is TGLBaseSceneObject);
  inherited Create(aOwner);
end;

// GetNamePath
//

function TGLBehaviours.GetNamePath: string;
var
  s: string;
begin
  Result := ClassName;
  if GetOwner = nil then
    Exit;
  s := GetOwner.GetNamePath;
  if s = '' then
    Exit;
  Result := s + '.Behaviours';
end;

// ItemsClass
//

class function TGLBehaviours.ItemsClass: TGLXCollectionItemClass;
begin
  Result := TGLBehaviour;
end;

// GetBehaviour
//

function TGLBehaviours.GetBehaviour(index: Integer): TGLBehaviour;
begin
  Result := TGLBehaviour(Items[index]);
end;

// CanAdd
//

function TGLBehaviours.CanAdd(aClass: TGLXCollectionItemClass): Boolean;
begin
  Result := (not aClass.InheritsFrom(TGLObjectEffect)) and (inherited
    CanAdd(aClass));
end;

// DoProgress
//

procedure TGLBehaviours.DoProgress(const progressTimes: TProgressTimes);
var
  i: Integer;
begin
  for i := 0 to Count - 1 do
    TGLBehaviour(Items[i]).DoProgress(progressTimes);
end;

// ------------------
// ------------------ TGLObjectEffect ------------------
// ------------------

// WriteToFiler
//

procedure TGLObjectEffect.WriteToFiler(writer: TWriter);
begin
  inherited;
  with writer do
  begin
    WriteInteger(0); // Archive Version 0
    // nothing more, yet
  end;
end;

// ReadFromFiler
//

procedure TGLObjectEffect.ReadFromFiler(reader: TReader);
begin
  if Owner.ArchiveVersion > 0 then
    inherited;

  with reader do
  begin
    if ReadInteger <> 0 then
      Assert(False);
    // nothing more, yet
  end;
end;

// Render
//

procedure TGLObjectEffect.Render(var rci: TGLRenderContextInfo);
begin
  // nothing here, this implem is just to avoid "abstract error"
end;

// ------------------
// ------------------ TGLObjectEffects ------------------
// ------------------

// Create
//

constructor TGLObjectEffects.Create(aOwner: TPersistent);
begin
  Assert(aOwner is TGLBaseSceneObject);
  inherited Create(aOwner);
end;

// GetNamePath
//

function TGLObjectEffects.GetNamePath: string;
var
  s: string;
begin
  Result := ClassName;
  if GetOwner = nil then
    Exit;
  s := GetOwner.GetNamePath;
  if s = '' then
    Exit;
  Result := s + '.Effects';
end;

// ItemsClass
//

class function TGLObjectEffects.ItemsClass: TGLXCollectionItemClass;
begin
  Result := TGLObjectEffect;
end;

// GetEffect
//

function TGLObjectEffects.GetEffect(index: Integer): TGLObjectEffect;
begin
  Result := TGLObjectEffect(Items[index]);
end;

// CanAdd
//

function TGLObjectEffects.CanAdd(aClass: TGLXCollectionItemClass): Boolean;
begin
  Result := (aClass.InheritsFrom(TGLObjectEffect)) and (inherited
    CanAdd(aClass));
end;

// DoProgress
//

procedure TGLObjectEffects.DoProgress(const progressTime: TProgressTimes);
var
  i: Integer;
begin
  for i := 0 to Count - 1 do
    TGLObjectEffect(Items[i]).DoProgress(progressTime);
end;

// RenderPreEffects
//

procedure TGLObjectEffects.RenderPreEffects(var rci: TGLRenderContextInfo);
var
  i: Integer;
  effect: TGLObjectEffect;
begin
  for i := 0 to Count - 1 do
  begin
    effect := TGLObjectEffect(Items[i]);
    if effect is TGLObjectPreEffect then
      effect.Render(rci);
  end;
end;

// RenderPostEffects
//

procedure TGLObjectEffects.RenderPostEffects(var rci: TGLRenderContextInfo);
var
  i: Integer;
  effect: TGLObjectEffect;
begin
  for i := 0 to Count - 1 do
  begin
    effect := TGLObjectEffect(Items[i]);
    if effect is TGLObjectPostEffect then
      effect.Render(rci)
    else if Assigned(rci.afterRenderEffects) and (effect is TGLObjectAfterEffect) then
      rci.afterRenderEffects.Add(effect);
  end;
end;

// ------------------
// ------------------ TGLCustomSceneObject ------------------
// ------------------

// Create
//

constructor TGLCustomSceneObject.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FMaterial := TGLMaterial.Create(Self);
end;

// Destroy
//

destructor TGLCustomSceneObject.Destroy;
begin
  inherited Destroy;
  FMaterial.Free;
end;

// Assign
//

procedure TGLCustomSceneObject.Assign(Source: TPersistent);
begin
  if Source is TGLCustomSceneObject then
  begin
    FMaterial.Assign(TGLCustomSceneObject(Source).FMaterial);
    FHint := TGLCustomSceneObject(Source).FHint;
  end;
  inherited Assign(Source);
end;

// Blended
//

function TGLCustomSceneObject.Blended: Boolean;
begin
  Result := Material.Blended;
end;

// Loaded
//

procedure TGLCustomSceneObject.Loaded;
begin
  inherited;
  FMaterial.Loaded;
end;

// SetGLMaterial
//

procedure TGLCustomSceneObject.SetVKMaterial(AValue: TGLMaterial);
begin
  FMaterial.Assign(AValue);
  NotifyChange(Self);
end;

// DestroyHandle
//

procedure TGLCustomSceneObject.DestroyHandle;
begin
  inherited;
  FMaterial.DestroyHandles;
end;

// DoRender
//

procedure TGLCustomSceneObject.DoRender(var ARci: TGLRenderContextInfo;
  ARenderSelf, ARenderChildren: Boolean);
begin
  // start rendering self
  if ARenderSelf then
    if ARci.ignoreMaterials then
      if (osDirectDraw in ObjectStyle) or ARci.amalgamating then
        BuildList(ARci)
      else
        ARci.VKStates.CallList(GetHandle(ARci))
    else
    begin
      FMaterial.Apply(ARci);
      repeat
        if (osDirectDraw in ObjectStyle) or ARci.amalgamating then
          BuildList(ARci)
        else
          ARci.VKStates.CallList(GetHandle(ARci));
      until not FMaterial.UnApply(ARci);
    end;
  // start rendering children (if any)
  if ARenderChildren then
    Self.RenderChildren(0, Count - 1, ARci);
end;

// ------------------
// ------------------ TGLSceneRootObject ------------------
// ------------------

// Create
//

constructor TGLSceneRootObject.Create(AOwner: TComponent);
begin
  Assert(AOwner is TGLScene);
  inherited Create(AOwner);
  ObjectStyle := ObjectStyle + [osDirectDraw];
  FScene := TGLScene(AOwner);
end;

// ------------------
// ------------------ TGLCamera ------------------
// ------------------

// Create
//

constructor TGLCamera.Create(aOwner: TComponent);
begin
  inherited Create(aOwner);
  FFocalLength := 50;
  FDepthOfView := 100;
  FNearPlaneBias := 1;
  FDirection.Initialize(VectorMake(0, 0, -1, 0));
  FCameraStyle := csPerspective;
  FSceneScale := 1;
  FDesign := False;
  FFOVY := -1;
  FKeepFOVMode := ckmHorizontalFOV;
end;

// destroy
//

destructor TGLCamera.Destroy;
begin
  TargetObject := nil;
  inherited;
end;

procedure TGLCamera.Assign(Source: TPersistent);
var
  cam: TGLCamera;
  dir: TVector;
begin
  if Assigned(Source) then
  begin
    inherited Assign(Source);

    if Source is TGLCamera then
    begin
      cam := TGLCamera(Source);
      SetDepthOfView(cam.DepthOfView);
      SetFocalLength(cam.FocalLength);
      SetCameraStyle(cam.CameraStyle);
      SetSceneScale(cam.SceneScale);
      SetNearPlaneBias(cam.NearPlaneBias);
      SetScene(cam.Scene);
      SetKeepFOVMode(cam.FKeepFOVMode);

      if Parent <> nil then
      begin
        SetTargetObject(cam.TargetObject);
      end
      else // Design camera
      begin
        Position.AsVector := cam.AbsolutePosition;
        if Assigned(cam.TargetObject) then
        begin
          VectorSubtract(cam.TargetObject.AbsolutePosition, AbsolutePosition, dir);
          NormalizeVector(dir);
          Direction.AsVector := dir;
        end;
      end;
    end;
  end;
end;

// AbsoluteVectorToTarget
//

function TGLCamera.AbsoluteVectorToTarget: TVector;
begin
  if TargetObject <> nil then
  begin
    VectorSubtract(TargetObject.AbsolutePosition, AbsolutePosition, Result);
    NormalizeVector(Result);
  end
  else
    Result := AbsoluteDirection;
end;

// AbsoluteRightVectorToTarget
//

function TGLCamera.AbsoluteRightVectorToTarget: TVector;
begin
  if TargetObject <> nil then
  begin
    VectorSubtract(TargetObject.AbsolutePosition, AbsolutePosition, Result);
    Result := VectorCrossProduct(Result, AbsoluteUp);
    NormalizeVector(Result);
  end
  else
    Result := AbsoluteRight;
end;

// AbsoluteUpVectorToTarget
//

function TGLCamera.AbsoluteUpVectorToTarget: TVector;
begin
  if TargetObject <> nil then
    Result := VectorCrossProduct(AbsoluteRightVectorToTarget,
      AbsoluteVectorToTarget)
  else
    Result := AbsoluteUp;
end;

// Apply
//

procedure TGLCamera.Apply;
var
  v, d, v2: TVector;
  absPos: TVector;
  LM, mat: TMatrix;
begin
  if Assigned(FDeferredApply) then
    FDeferredApply(Self)
  else
  begin
    if Assigned(FTargetObject) then
    begin
      v := TargetObject.AbsolutePosition;
      absPos := AbsolutePosition;
      VectorSubtract(v, absPos, d);
      NormalizeVector(d);
      FLastDirection := d;
      LM := CreateLookAtMatrix(absPos, v, Up.AsVector);
    end
    else
    begin
      if Assigned(Parent) then
        mat := Parent.AbsoluteMatrix
      else
        mat := IdentityHmgMatrix;
      absPos := AbsolutePosition;
      v := VectorTransform(Direction.AsVector, mat);
      FLastDirection := v;
      d := VectorTransform(Up.AsVector, mat);
      v2 := VectorAdd(absPos, v);
      LM := CreateLookAtMatrix(absPos, v2, d);
    end;
    with CurrentVKContext.PipelineTransformation do
      ViewMatrix := MatrixMultiply(LM, ViewMatrix);
    ClearStructureChanged;
  end;
end;

// ApplyPerspective
//

procedure TGLCamera.ApplyPerspective(const AViewport: TRectangle;
  AWidth, AHeight: Integer; ADPI: Integer);
var
  vLeft, vRight, vBottom, vTop, vFar: Single;
  MaxDim, Ratio, f: Double;
  xmax, ymax: Double;
  mat: TMatrix;
const
  cEpsilon: Single = 1e-4;

  function IsPerspective(CamStyle: TGLCameraStyle): Boolean;
  begin
    Result := CamStyle in [csPerspective, csInfinitePerspective, csPerspectiveKeepFOV];
  end;

begin
  if (AWidth <= 0) or (AHeight <= 0) then
    Exit;

  if CameraStyle = csOrtho2D then
  begin
    vLeft := 0;
    vRight := AWidth;
    vBottom := 0;
    vTop := AHeight;
    FNearPlane := -1;
    vFar := 1;
    mat := CreateOrthoMatrix(vLeft, vRight, vBottom, vTop, FNearPlane, vFar);
    with CurrentVKContext.PipelineTransformation do
      ProjectionMatrix := MatrixMultiply(mat, ProjectionMatrix);
    FViewPortRadius := VectorLength(AWidth, AHeight) / 2;
  end
  else if CameraStyle = csCustom then
  begin
    FViewPortRadius := VectorLength(AWidth, AHeight) / 2;
    if Assigned(FOnCustomPerspective) then
      FOnCustomPerspective(AViewport, AWidth, AHeight, ADPI, FViewPortRadius);
  end
  else
  begin
    // determine biggest dimension and resolution (height or width)
    MaxDim := AWidth;
    if AHeight > MaxDim then
      MaxDim := AHeight;

    // calculate near plane distance and extensions;
    // Scene ratio is determined by the window ratio. The viewport is just a
    // specific part of the entire window and has therefore no influence on the
    // scene ratio. What we need to know, though, is the ratio between the window
    // borders (left, top, right and bottom) and the viewport borders.
    // Note: viewport.top is actually bottom, because the window (and viewport) origin
    // in OGL is the lower left corner

    if IsPerspective(CameraStyle) then
      f := FNearPlaneBias / (AWidth * FSceneScale)
    else
      f := 100 * FNearPlaneBias / (focalLength * AWidth * FSceneScale);

    // calculate window/viewport ratio for right extent
    Ratio := (2 * AViewport.Width + 2 * AViewport.Left - AWidth) * f;
    // calculate aspect ratio correct right value of the view frustum and take
    // the window/viewport ratio also into account
    vRight := Ratio * AWidth / (2 * MaxDim);

    // the same goes here for the other three extents
    // left extent:
    Ratio := (AWidth - 2 * AViewport.Left) * f;
    vLeft := -Ratio * AWidth / (2 * MaxDim);

    if IsPerspective(CameraStyle) then
      f := FNearPlaneBias / (AHeight * FSceneScale)
    else
      f := 100 * FNearPlaneBias / (focalLength * AHeight * FSceneScale);

    // top extent (keep in mind the origin is left lower corner):
    Ratio := (2 * AViewport.Height + 2 * AViewport.Top - AHeight) * f;
    vTop := Ratio * AHeight / (2 * MaxDim);

    // bottom extent:
    Ratio := (AHeight - 2 * AViewport.Top) * f;
    vBottom := -Ratio * AHeight / (2 * MaxDim);

    FNearPlane := FFocalLength * 2 * ADPI / (25.4 * MaxDim) * FNearPlaneBias;
    vFar := FNearPlane + FDepthOfView;

    // finally create view frustum (perspective or orthogonal)
    case CameraStyle of
      csPerspective:
        begin
          mat := CreateMatrixFromFrustum(vLeft, vRight, vBottom, vTop, FNearPlane, vFar);
        end;
      csPerspectiveKeepFOV:
        begin
          if FFOVY < 0 then // Need Update FOV
          begin
            FFOVY := ArcTangent2(vTop - vBottom, 2 * FNearPlane) * 2;
            FFOVX := ArcTangent2(vRight - vLeft, 2 * FNearPlane) * 2;
          end;

          case FKeepFOVMode of
            ckmVerticalFOV:
            begin
              ymax := FNearPlane * Tangent(FFOVY / 2);
              xmax := ymax * AWidth / AHeight;
            end;
            ckmHorizontalFOV:
            begin
              xmax := FNearPlane * Tangent(FFOVX / 2);
              ymax := xmax * AHeight / AWidth;
            end;
            else
            begin
              xmax := 0;
              ymax := 0;
              Assert(False, 'Unknown keep camera angle mode');
            end;
          end;
          mat := CreateMatrixFromFrustum(-xmax, xmax, -ymax, ymax, FNearPlane, vFar);
        end;
      csInfinitePerspective:
        begin
          mat := IdentityHmgMatrix;
          mat.X.X := 2 * FNearPlane / (vRight - vLeft);
          mat.Y.Y := 2 * FNearPlane / (vTop - vBottom);
          mat.Z.X := (vRight + vLeft) / (vRight - vLeft);
          mat.Z.Y := (vTop + vBottom) / (vTop - vBottom);
          mat.Z.Z := cEpsilon - 1;
          mat.Z.W := -1;
          mat.W.Z := FNearPlane * (cEpsilon - 2);
          mat.W.W := 0;
        end;
      csOrthogonal:
        begin
          mat := CreateOrthoMatrix(vLeft, vRight, vBottom, vTop, FNearPlane, vFar);
        end;
    else
      Assert(False);
    end;

    with CurrentVKContext.PipelineTransformation do
      ProjectionMatrix := MatrixMultiply(mat, ProjectionMatrix);

    FViewPortRadius := VectorLength(vRight, vTop) / FNearPlane;
  end;
end;

//------------------------------------------------------------------------------

procedure TGLCamera.AutoLeveling(Factor: Single);
var
  rightVector, rotAxis: TVector;
  angle: Single;
begin
  angle := RadianToDeg(ArcCosine(VectorDotProduct(FUp.AsVector, YVector)));
  rotAxis := VectorCrossProduct(YHmgVector, FUp.AsVector);
  if (angle > 1) and (VectorLength(rotAxis) > 0) then
  begin
    rightVector := VectorCrossProduct(FDirection.AsVector, FUp.AsVector);
    FUp.Rotate(AffineVectorMake(rotAxis), Angle / (10 * Factor));
    FUp.Normalize;
    // adjust local coordinates
    FDirection.DirectVector := VectorCrossProduct(FUp.AsVector, rightVector);
    FRotation.Z := -RadianToDeg(ArcTangent2(RightVector.Y,
      VectorLength(RightVector.X, RightVector.Z)));
  end;
end;

// Notification
//

procedure TGLCamera.Notification(AComponent: TComponent; Operation: TOperation);
begin
  if (Operation = opRemove) and (AComponent = FTargetObject) then
    TargetObject := nil;
  inherited;
end;

// SetTargetObject
//

procedure TGLCamera.SetTargetObject(const val: TGLBaseSceneObject);
begin
  if (FTargetObject <> val) then
  begin
    if Assigned(FTargetObject) then
      FTargetObject.RemoveFreeNotification(Self);
    FTargetObject := val;
    if Assigned(FTargetObject) then
      FTargetObject.FreeNotification(Self);
    if not (csLoading in ComponentState) then
      TransformationChanged;
  end;
end;

// Reset
//

procedure TGLCamera.Reset(aSceneBuffer: TGLSceneBuffer);
var
  Extent: Single;
begin
  FRotation.Z := 0;
  FFocalLength := 50;
  with aSceneBuffer do
  begin
    ApplyPerspective(FViewport, FViewport.Width, FViewport.Height, FRenderDPI);
    FUp.DirectVector := YHmgVector;
    if FViewport.Height < FViewport.Width then
      Extent := FViewport.Height * 0.25
    else
      Extent := FViewport.Width * 0.25;
  end;
  FPosition.SetPoint(0, 0, FNearPlane * Extent);
  FDirection.SetVector(0, 0, -1, 0);
  TransformationChanged;
end;

// ZoomAll
//

procedure TGLCamera.ZoomAll(aSceneBuffer: TGLSceneBuffer);
var
  extent: Single;
begin
  with aSceneBuffer do
  begin
    if FViewport.Height < FViewport.Width then
      Extent := FViewport.Height * 0.25
    else
      Extent := FViewport.Width * 0.25;
    FPosition.DirectVector := NullHmgPoint;
    Move(-FNearPlane * Extent);
    // let the camera look at the scene center
    FDirection.SetVector(-FPosition.X, -FPosition.Y, -FPosition.Z, 0);
  end;
end;

// RotateObject
//

procedure TGLCamera.RotateObject(obj: TGLBaseSceneObject; pitchDelta, turnDelta:
  Single;
  rollDelta: Single = 0);
var
  resMat: TMatrix;
  vDir, vUp, vRight: TVector;
  v: TAffineVector;
  position1: TVEctor;
  Scale1: TVector;
begin
  // First we need to compute the actual camera's vectors, which may not be
  // directly available if we're in "targeting" mode
  vUp := AbsoluteUp;
  if TargetObject <> nil then
  begin
    vDir := AbsoluteVectorToTarget;
    vRight := VectorCrossProduct(vDir, vUp);
    vUp := VectorCrossProduct(vRight, vDir);
  end
  else
  begin
    vDir := AbsoluteDirection;
    vRight := VectorCrossProduct(vDir, vUp);
  end;

  //save scale & position info
  Scale1 := obj.Scale.AsVector;
  position1 := obj.Position.asVector;
  resMat := obj.Matrix;
  //get rid of scaling & location info
  NormalizeMatrix(resMat);
  // Now we build rotation matrices and use them to rotate the obj
  if rollDelta <> 0 then
  begin
    SetVector(v, obj.AbsoluteToLocal(vDir));
    resMat := MatrixMultiply(CreateRotationMatrix(v, DegToRadian(rollDelta)),
      resMat);
  end;
  if turnDelta <> 0 then
  begin
    SetVector(v, obj.AbsoluteToLocal(vUp));
    resMat := MatrixMultiply(CreateRotationMatrix(v, DegToRadian(turnDelta)),
      resMat);
  end;
  if pitchDelta <> 0 then
  begin
    SetVector(v, obj.AbsoluteToLocal(vRight));
    resMat := MatrixMultiply(CreateRotationMatrix(v, DegToRadian(pitchDelta)),
      resMat);
  end;
  obj.Matrix := resMat;
  //restore scaling & rotation info
  obj.Scale.AsVector := Scale1;
  obj.Position.AsVector := Position1;
end;

// RotateTarget
//

procedure TGLCamera.RotateTarget(pitchDelta, turnDelta: Single; rollDelta: Single
  = 0);
begin
  if Assigned(FTargetObject) then
    RotateObject(FTargetObject, pitchDelta, turnDelta, rollDelta)
end;

// MoveAroundTarget
//

procedure TGLCamera.MoveAroundTarget(pitchDelta, turnDelta: Single);
begin
  MoveObjectAround(FTargetObject, pitchDelta, turnDelta);
end;

// MoveAllAroundTarget
//

procedure TGLCamera.MoveAllAroundTarget(pitchDelta, turnDelta :Single);
begin
  MoveObjectAllAround(FTargetObject, pitchDelta, turnDelta);
end;

// MoveInEyeSpace
//

procedure TGLCamera.MoveInEyeSpace(forwardDistance, rightDistance, upDistance:
  Single);
var
  trVector: TVector;
begin
  trVector := AbsoluteEyeSpaceVector(forwardDistance, rightDistance,
    upDistance);
  if Assigned(Parent) then
    Position.Translate(Parent.AbsoluteToLocal(trVector))
  else
    Position.Translate(trVector);
end;

// MoveTargetInEyeSpace
//

procedure TGLCamera.MoveTargetInEyeSpace(forwardDistance, rightDistance,
  upDistance: Single);
var
  trVector: TVector;
begin
  if TargetObject <> nil then
  begin
    trVector := AbsoluteEyeSpaceVector(forwardDistance, rightDistance,
      upDistance);
    TargetObject.Position.Translate(TargetObject.Parent.AbsoluteToLocal(trVector));
  end;
end;

// AbsoluteEyeSpaceVector
//

function TGLCamera.AbsoluteEyeSpaceVector(forwardDistance, rightDistance,
  upDistance: Single): TVector;
begin
  Result := NullHmgVector;
  if forwardDistance <> 0 then
    CombineVector(Result, AbsoluteVectorToTarget, forwardDistance);
  if rightDistance <> 0 then
    CombineVector(Result, AbsoluteRightVectorToTarget, rightDistance);
  if upDistance <> 0 then
    CombineVector(Result, AbsoluteUpVectorToTarget, upDistance);
end;

// AdjustDistanceToTarget
//

procedure TGLCamera.AdjustDistanceToTarget(distanceRatio: Single);
var
  vect: TVector;
begin
  if Assigned(FTargetObject) then
  begin
    // calculate vector from target to camera in absolute coordinates
    vect := VectorSubtract(AbsolutePosition, TargetObject.AbsolutePosition);
    // ratio -> translation vector
    ScaleVector(vect, -(1 - distanceRatio));
    AddVector(vect, AbsolutePosition);
    if Assigned(Parent) then
      vect := Parent.AbsoluteToLocal(vect);
    Position.AsVector := vect;
  end;
end;

// DistanceToTarget
//

function TGLCamera.DistanceToTarget: Single;
var
  vect: TVector;
begin
  if Assigned(FTargetObject) then
  begin
    vect := VectorSubtract(AbsolutePosition, TargetObject.AbsolutePosition);
    Result := VectorLength(vect);
  end
  else
    Result := 1;
end;

// ScreenDeltaToVector
//

function TGLCamera.ScreenDeltaToVector(deltaX, deltaY: Integer; ratio: Single;
  const planeNormal: TVector): TVector;
var
  screenY, screenX: TVector;
  screenYoutOfPlaneComponent: Single;
begin
  // calculate projection of direction vector on the plane
  if Assigned(FTargetObject) then
    screenY := VectorSubtract(TargetObject.AbsolutePosition, AbsolutePosition)
  else
    screenY := Direction.AsVector;
  screenYoutOfPlaneComponent := VectorDotProduct(screenY, planeNormal);
  screenY := VectorCombine(screenY, planeNormal, 1,
    -screenYoutOfPlaneComponent);
  NormalizeVector(screenY);
  // calc the screenX vector
  screenX := VectorCrossProduct(screenY, planeNormal);
  // and here, we're done
  Result := VectorCombine(screenX, screenY, deltaX * ratio, deltaY * ratio);
end;

// ScreenDeltaToVectorXY
//

function TGLCamera.ScreenDeltaToVectorXY(deltaX, deltaY: Integer; ratio:
  Single): TVector;
var
  screenY: TVector;
  dxr, dyr, d: Single;
begin
  // calculate projection of direction vector on the plane
  if Assigned(FTargetObject) then
    screenY := VectorSubtract(TargetObject.AbsolutePosition, AbsolutePosition)
  else
    screenY := Direction.AsVector;
  d := VectorLength(screenY.X, screenY.Y);
  if d <= 1e-10 then
    d := ratio
  else
    d := ratio / d;
  // and here, we're done
  dxr := deltaX * d;
  dyr := deltaY * d;
  Result.X := screenY.Y * dxr + screenY.X * dyr;
  Result.Y := screenY.Y * dyr - screenY.X * dxr;
  Result.Z := 0;
  Result.W := 0;
end;

// ScreenDeltaToVectorXZ
//

function TGLCamera.ScreenDeltaToVectorXZ(deltaX, deltaY: Integer; ratio:
  Single): TVector;
var
  screenY: TVector;
  d, dxr, dzr: Single;
begin
  // calculate the projection of direction vector on the plane
  if Assigned(fTargetObject) then
    screenY := VectorSubtract(TargetObject.AbsolutePosition, AbsolutePosition)
  else
    screenY := Direction.AsVector;
  d := VectorLength(screenY.X, screenY.Z);
  if d <= 1e-10 then
    d := ratio
  else
    d := ratio / d;
  dxr := deltaX * d;
  dzr := deltaY * d;
  Result.X := -screenY.Z * dxr + screenY.X * dzr;
  Result.Y := 0;
  Result.Z := screenY.Z * dzr + screenY.X * dxr;
  Result.W := 0;
end;

// ScreenDeltaToVectorYZ
//

function TGLCamera.ScreenDeltaToVectorYZ(deltaX, deltaY: Integer; ratio:
  Single): TVector;
var
  screenY: TVector;
  d, dyr, dzr: single;
begin
  // calculate the projection of direction vector on the plane
  if Assigned(fTargetObject) then
    screenY := VectorSubtract(TargetObject.AbsolutePosition, AbsolutePosition)
  else
    screenY := Direction.AsVector;
  d := VectorLength(screenY.Y, screenY.Z);
  if d <= 1e-10 then
    d := ratio
  else
    d := ratio / d;
  dyr := deltaX * d;
  dzr := deltaY * d;
  Result.X := 0;
  Result.Y := screenY.Z * dyr + screenY.Y * dzr;
  Result.Z := screenY.Z * dzr - screenY.Y * dyr;
  Result.W := 0;
end;

// PointInFront
//

function TGLCamera.PointInFront(const point: TVector): boolean;
begin
  result := PointIsInHalfSpace(point, AbsolutePosition, AbsoluteDirection);
end;

// SetDepthOfView
//

procedure TGLCamera.SetDepthOfView(AValue: Single);
begin
  if FDepthOfView <> AValue then
  begin
    FDepthOfView := AValue;
    FFOVY := - 1;
    if not (csLoading in ComponentState) then
      TransformationChanged;
  end;
end;

// SetFocalLength
//

procedure TGLCamera.SetFocalLength(AValue: Single);
begin
  if AValue <= 0 then
    AValue := 1;
  if FFocalLength <> AValue then
  begin
    FFocalLength := AValue;
    FFOVY := - 1;
    if not (csLoading in ComponentState) then
      TransformationChanged;
  end;
end;

// GetFieldOfView
//

function TGLCamera.GetFieldOfView(const AViewportDimension: single): single;
begin
  if FFocalLength = 0 then
    result := 0
  else
    result := RadianToDeg(2 * ArcTangent2(AViewportDimension * 0.5, FFocalLength));
end;

// SetFieldOfView
//

procedure TGLCamera.SetFieldOfView(const AFieldOfView,
  AViewportDimension: single);
begin
  FocalLength := AViewportDimension / (2 * Tangent(DegToRadian(AFieldOfView / 2)));
end;

// SetCameraStyle
//

procedure TGLCamera.SetCameraStyle(const val: TGLCameraStyle);
begin
  if FCameraStyle <> val then
  begin
    FCameraStyle := val;
    FFOVY := -1;
    NotifyChange(Self);
  end;
end;

// SetKeepCamAngleMode
//

procedure TGLCamera.SetKeepFOVMode(const val: TGLCameraKeepFOVMode);
begin
  if FKeepFOVMode <> val then
  begin
    FKeepFOVMode := val;
    FFOVY := -1;
    if FCameraStyle = csPerspectiveKeepFOV then
      NotifyChange(Self);
  end;
end;

// SetSceneScale
//

procedure TGLCamera.SetSceneScale(value: Single);
begin
  if value = 0 then
    value := 1;
  if FSceneScale <> value then
  begin
    FSceneScale := value;
    FFOVY := -1;
    NotifyChange(Self);
  end;
end;

// StoreSceneScale
//

function TGLCamera.StoreSceneScale: Boolean;
begin
  Result := (FSceneScale <> 1);
end;

// SetNearPlaneBias
//

procedure TGLCamera.SetNearPlaneBias(value: Single);
begin
  if value <= 0 then
    value := 1;
  if FNearPlaneBias <> value then
  begin
    FNearPlaneBias := value;
    FFOVY := -1;
    NotifyChange(Self);
  end;
end;

// StoreNearPlaneBias
//

function TGLCamera.StoreNearPlaneBias: Boolean;
begin
  Result := (FNearPlaneBias <> 1);
end;

// DoRender
//

procedure TGLCamera.DoRender(var ARci: TGLRenderContextInfo;
  ARenderSelf, ARenderChildren: Boolean);
begin
  if ARenderChildren and (Count > 0) then
    Self.RenderChildren(0, Count - 1, ARci);
end;

// RayCastIntersect
//

function TGLCamera.RayCastIntersect(const rayStart, rayVector: TVector;
  intersectPoint: PVector = nil;
  intersectNormal: PVector = nil): Boolean;
begin
  Result := False;
end;

// ------------------
// ------------------ TGLImmaterialSceneObject ------------------
// ------------------

// DoRender
//

procedure TGLImmaterialSceneObject.DoRender(var ARci: TGLRenderContextInfo;
  ARenderSelf, ARenderChildren: Boolean);
begin
  // start rendering self
  if ARenderSelf then
  begin
    if (osDirectDraw in ObjectStyle) or ARci.amalgamating then
      BuildList(ARci)
    else
      ARci.VKStates.CallList(GetHandle(ARci));
  end;
  // start rendering children (if any)
  if ARenderChildren then
    Self.RenderChildren(0, Count - 1, ARci);
end;

// ------------------
// ------------------ TGLCameraInvariantObject ------------------
// ------------------

// Create
//

constructor TGLCameraInvariantObject.Create(AOwner: TComponent);
begin
  inherited;
  FCamInvarianceMode := cimNone;
end;

// Assign
//

procedure TGLCameraInvariantObject.Assign(Source: TPersistent);
begin
  if Source is TGLCameraInvariantObject then
  begin
    FCamInvarianceMode := TGLCameraInvariantObject(Source).FCamInvarianceMode;
  end;
  inherited Assign(Source);
end;

// DoRender
//

procedure TGLCameraInvariantObject.DoRender(var ARci: TGLRenderContextInfo;
  ARenderSelf, ARenderChildren: Boolean);
begin
  if CamInvarianceMode <> cimNone then
    with ARci.PipelineTransformation do
    begin
      Push;
      try
        // prepare
        case CamInvarianceMode of
          cimPosition:
            begin
              ViewMatrix := MatrixMultiply(
                CreateTranslationMatrix(ARci.cameraPosition),
                ARci.PipelineTransformation.ViewMatrix);
            end;
          cimOrientation:
            begin
              // makes the coordinates system more 'intuitive' (Z+ forward)
              ViewMatrix := CreateScaleMatrix(Vector3fMake(1, -1, -1))
            end;
        else
          Assert(False);
        end;
        // Apply local transform
        ModelMatrix := LocalMatrix^;

        if ARenderSelf then
        begin
          if (osDirectDraw in ObjectStyle) or ARci.amalgamating then
            BuildList(ARci)
          else
            ARci.VKStates.CallList(GetHandle(ARci));
        end;
        if ARenderChildren then
          Self.RenderChildren(0, Count - 1, ARci);
      finally
        Pop;
      end;
    end
  else
    inherited;
end;

// SetCamInvarianceMode
//

procedure TGLCameraInvariantObject.SetCamInvarianceMode(const val:
  TGLCameraInvarianceMode);
begin
  if FCamInvarianceMode <> val then
  begin
    FCamInvarianceMode := val;
    NotifyChange(Self);
  end;
end;

// ------------------
// ------------------ TGLDirectVulkan ------------------
// ------------------

// Create
//

constructor TGLDirectVulkan.Create(AOwner: TComponent);
begin
  inherited;
  ObjectStyle := ObjectStyle + [osDirectDraw];
  FBlend := False;
end;

// Assign
//

procedure TGLDirectVulkan.Assign(Source: TPersistent);
begin
  if Source is TGLDirectVulkan then
  begin
    UseBuildList := TGLDirectVulkan(Source).UseBuildList;
    FOnRender := TGLDirectVulkan(Source).FOnRender;
    FBlend := TGLDirectVulkan(Source).Blend;
  end;
  inherited Assign(Source);
end;

// BuildList
//

procedure TGLDirectVulkan.BuildList(var rci: TGLRenderContextInfo);
begin
  if Assigned(FOnRender) then
  begin
    xgl.MapTexCoordToMain; // single texturing by default
    OnRender(Self, rci);
  end;
end;

// AxisAlignedDimensionsUnscaled
//

function TGLDirectVulkan.AxisAlignedDimensionsUnscaled: TVector;
begin
  Result := NullHmgPoint;
end;

// SetUseBuildList
//

procedure TGLDirectVulkan.SetUseBuildList(const val: Boolean);
begin
  if val <> FUseBuildList then
  begin
    FUseBuildList := val;
    if val then
      ObjectStyle := ObjectStyle - [osDirectDraw]
    else
      ObjectStyle := ObjectStyle + [osDirectDraw];
  end;
end;

// Blended
//

function TGLDirectVulkan.Blended: Boolean;
begin
  Result := FBlend;
end;

// SetBlend
//

procedure TGLDirectVulkan.SetBlend(const val: Boolean);
begin
  if val <> FBlend then
  begin
    FBlend := val;
    StructureChanged;
  end;
end;

// ------------------
// ------------------ TGLRenderPoint ------------------
// ------------------

// Create
//

constructor TGLRenderPoint.Create(AOwner: TComponent);
begin
  inherited;
  ObjectStyle := ObjectStyle + [osDirectDraw];
end;

// Destroy
//

destructor TGLRenderPoint.Destroy;
begin
  Clear;
  inherited;
end;

// BuildList
//

procedure TGLRenderPoint.BuildList(var rci: TGLRenderContextInfo);
var
  i: Integer;
begin
  for i := 0 to High(FCallBacks) do
    FCallBacks[i](Self, rci);
end;

// RegisterCallBack
//

procedure TGLRenderPoint.RegisterCallBack(renderEvent: TDirectRenderEvent;
  renderPointFreed: TNotifyEvent);
var
  n: Integer;
begin
  n := Length(FCallBacks);
  SetLength(FCallBacks, n + 1);
  SetLength(FFreeCallBacks, n + 1);
  FCallBacks[n] := renderEvent;
  FFreeCallBacks[n] := renderPointFreed;
end;

// UnRegisterCallBack
//

procedure TGLRenderPoint.UnRegisterCallBack(renderEvent: TDirectRenderEvent);
type
  TEventContainer = record
    event: TDirectRenderEvent;
  end;
var
  i, j, n: Integer;
  refContainer, listContainer: TEventContainer;
begin
  refContainer.event := renderEvent;
  n := Length(FCallBacks);
  for i := 0 to n - 1 do
  begin
    listContainer.event := FCallBacks[i];
    if CompareMem(@listContainer, @refContainer, SizeOf(TEventContainer)) then
    begin
      for j := i + 1 to n - 1 do
      begin
        FCallBacks[j - 1] := FCallBacks[j];
        FFreeCallBacks[j - 1] := FFreeCallBacks[j];
      end;
      SetLength(FCallBacks, n - 1);
      SetLength(FFreeCallBacks, n - 1);
      Break;
    end;
  end;
end;

// BuildList
//

procedure TGLRenderPoint.Clear;
begin
  while Length(FCallBacks) > 0 do
  begin
    FFreeCallBacks[High(FCallBacks)](Self);
    SetLength(FCallBacks, Length(FCallBacks) - 1);
  end;
end;

// ------------------
// ------------------ TGLProxyObject ------------------
// ------------------

// Create
//

constructor TGLProxyObject.Create(AOwner: TComponent);
begin
  inherited;
  FProxyOptions := cDefaultProxyOptions;
end;

// Destroy
//

destructor TGLProxyObject.Destroy;
begin
  SetMasterObject(nil);
  inherited;
end;

// Assign
//

procedure TGLProxyObject.Assign(Source: TPersistent);
begin
  if Source is TGLProxyObject then
  begin
    SetMasterObject(TGLProxyObject(Source).MasterObject);
  end;
  inherited Assign(Source);
end;

// Render
//

procedure TGLProxyObject.DoRender(var ARci: TGLRenderContextInfo;
  ARenderSelf, ARenderChildren: Boolean);
var
  gotMaster, masterGotEffects, oldProxySubObject: Boolean;
begin
  if FRendering then
    Exit;
  FRendering := True;
  try
    gotMaster := Assigned(FMasterObject);
    masterGotEffects := gotMaster and (pooEffects in FProxyOptions)
      and (FMasterObject.Effects.Count > 0);
    if gotMaster then
    begin
      if pooObjects in FProxyOptions then
      begin
        oldProxySubObject := ARci.proxySubObject;
        ARci.proxySubObject := True;
        if pooTransformation in FProxyOptions then
          with ARci.PipelineTransformation do
            ModelMatrix := MatrixMultiply(FMasterObject.Matrix, ModelMatrix);
        FMasterObject.DoRender(ARci, ARenderSelf, (FMasterObject.Count > 0));
        ARci.proxySubObject := oldProxySubObject;
      end;
    end;
    // now render self stuff (our children, our effects, etc.)
    if ARenderChildren and (Count > 0) then
      Self.RenderChildren(0, Count - 1, ARci);
    if masterGotEffects then
      FMasterObject.Effects.RenderPostEffects(ARci);
  finally
    FRendering := False;
  end;
  ClearStructureChanged;
end;

// AxisAlignedDimensions
//

function TGLProxyObject.AxisAlignedDimensions: TVector;
begin
  If Assigned(FMasterObject) then
  begin
    Result := FMasterObject.AxisAlignedDimensionsUnscaled;
    If (pooTransformation in ProxyOptions) then
      ScaleVector(Result,FMasterObject.Scale.AsVector)
    else
      ScaleVector(Result, Scale.AsVector);
  end
  else
    Result := inherited AxisAlignedDimensions;
end;

function TGLProxyObject.AxisAlignedDimensionsUnscaled: TVector;
begin
  if Assigned(FMasterObject) then
  begin
    Result := FMasterObject.AxisAlignedDimensionsUnscaled;
  end
  else
    Result := inherited AxisAlignedDimensionsUnscaled;
end;

// BarycenterAbsolutePosition
//

function TGLProxyObject.BarycenterAbsolutePosition: TVector;
var
  lAdjustVector: TVector;
begin
  if Assigned(FMasterObject) then
  begin
    // Not entirely correct, but better than nothing...
    lAdjustVector := VectorSubtract(FMasterObject.BarycenterAbsolutePosition,
      FMasterObject.AbsolutePosition);
    Position.AsVector := VectorAdd(Position.AsVector, lAdjustVector);
    Result := AbsolutePosition;
    Position.AsVector := VectorSubtract(Position.AsVector, lAdjustVector);
  end
  else
    Result := inherited BarycenterAbsolutePosition;
end;

// Notification
//

procedure TGLProxyObject.Notification(AComponent: TComponent; Operation:
  TOperation);
begin
  if (Operation = opRemove) and (AComponent = FMasterObject) then
    MasterObject := nil;
  inherited;
end;

// SetMasterObject
//

procedure TGLProxyObject.SetMasterObject(const val: TGLBaseSceneObject);
begin
  if FMasterObject <> val then
  begin
    if Assigned(FMasterObject) then
      FMasterObject.RemoveFreeNotification(Self);
    FMasterObject := val;
    if Assigned(FMasterObject) then
      FMasterObject.FreeNotification(Self);
    StructureChanged;
  end;
end;

// SetProxyOptions
//

procedure TGLProxyObject.SetProxyOptions(const val: TGLProxyObjectOptions);
begin
  if FProxyOptions <> val then
  begin
    FProxyOptions := val;
    StructureChanged;
  end;
end;

// RayCastIntersect
//

function TGLProxyObject.RayCastIntersect(const rayStart, rayVector: TVector;
  intersectPoint: PVector = nil;
  intersectNormal: PVector = nil): Boolean;
var
  localRayStart, localRayVector: TVector;
begin
  if Assigned(MasterObject) then
  begin
    SetVector(localRayStart, AbsoluteToLocal(rayStart));
    SetVector(localRayStart, MasterObject.LocalToAbsolute(localRayStart));
    SetVector(localRayVector, AbsoluteToLocal(rayVector));
    SetVector(localRayVector, MasterObject.LocalToAbsolute(localRayVector));
    NormalizeVector(localRayVector);

    Result := MasterObject.RayCastIntersect(localRayStart, localRayVector,
      intersectPoint, intersectNormal);
    if Result then
    begin
      if Assigned(intersectPoint) then
      begin
        SetVector(intersectPoint^,
          MasterObject.AbsoluteToLocal(intersectPoint^));
        SetVector(intersectPoint^, LocalToAbsolute(intersectPoint^));
      end;
      if Assigned(intersectNormal) then
      begin
        SetVector(intersectNormal^,
          MasterObject.AbsoluteToLocal(intersectNormal^));
        SetVector(intersectNormal^, LocalToAbsolute(intersectNormal^));
      end;
    end;
  end
  else
    Result := False;
end;

// GenerateSilhouette
//

function TGLProxyObject.GenerateSilhouette(const silhouetteParameters:
  TGLSilhouetteParameters): TGLSilhouette;
begin
  if Assigned(MasterObject) then
    Result := MasterObject.GenerateSilhouette(silhouetteParameters)
  else
    Result := nil;
end;

// ------------------
// ------------------ TGLLightSource ------------------
// ------------------

// Create
//

constructor TGLLightSource.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FShining := True;
  FSpotDirection := TGLCoordinates.CreateInitialized(Self, VectorMake(0, 0, -1,
    0),
    csVector);
  FConstAttenuation := 1;
  FLinearAttenuation := 0;
  FQuadraticAttenuation := 0;
  FSpotCutOff := 180;
  FSpotExponent := 0;
  FLightStyle := lsSpot;
  FAmbient := TGLColor.Create(Self);
  FDiffuse := TGLColor.Create(Self);
  FDiffuse.Initialize(clrWhite);
  FSpecular := TGLColor.Create(Self);
end;

// Destroy
//

destructor TGLLightSource.Destroy;
begin
  FSpotDirection.Free;
  FAmbient.Free;
  FDiffuse.Free;
  FSpecular.Free;
  inherited Destroy;
end;

// DoRender
//

procedure TGLLightSource.DoRender(var ARci: TGLRenderContextInfo;
  ARenderSelf, ARenderChildren: Boolean);
begin
  if ARenderChildren and Assigned(FChildren) then
    Self.RenderChildren(0, Count - 1, ARci);
end;

// RayCastIntersect
//

function TGLLightSource.RayCastIntersect(const rayStart, rayVector: TVector;
  intersectPoint: PVector = nil;
  intersectNormal: PVector = nil): Boolean;
begin
  Result := False;
end;

// CoordinateChanged
//

procedure TGLLightSource.CoordinateChanged(Sender: TGLCustomCoordinates);
begin
  inherited;
  if Sender = FSpotDirection then
    TransformationChanged;
end;

// GenerateSilhouette
//

function TGLLightSource.GenerateSilhouette(const silhouetteParameters:
  TGLSilhouetteParameters): TGLSilhouette;
begin
  Result := nil;
end;

// GetHandle
//

function TGLLightSource.GetHandle(var rci: TGLRenderContextInfo): Cardinal;
begin
  Result := 0;
end;

// SetShining
//

procedure TGLLightSource.SetShining(AValue: Boolean);
begin
  if AValue <> FShining then
  begin
    FShining := AValue;
    NotifyChange(Self);
  end;
end;

// SetSpotDirection
//

procedure TGLLightSource.SetSpotDirection(AVector: TGLCoordinates);
begin
  FSpotDirection.DirectVector := AVector.AsVector;
  FSpotDirection.W := 0;
  NotifyChange(Self);
end;

// SetSpotExponent
//

procedure TGLLightSource.SetSpotExponent(AValue: Single);
begin
  if FSpotExponent <> AValue then
  begin
    FSpotExponent := AValue;
    NotifyChange(Self);
  end;
end;

// SetSpotCutOff
//

procedure TGLLightSource.SetSpotCutOff(const val: Single);
begin
  if FSpotCutOff <> val then
  begin
    if ((val >= 0) and (val <= 90)) or (val = 180) then
    begin
      FSpotCutOff := val;
      NotifyChange(Self);
    end;
  end;
end;

// SetLightStyle
//

procedure TGLLightSource.SetLightStyle(const val: TLightStyle);
begin
  if FLightStyle <> val then
  begin
    FLightStyle := val;
    NotifyChange(Self);
  end;
end;

// SetAmbient
//

procedure TGLLightSource.SetAmbient(AValue: TGLColor);
begin
  FAmbient.Color := AValue.Color;
  NotifyChange(Self);
end;

// SetDiffuse
//

procedure TGLLightSource.SetDiffuse(AValue: TGLColor);
begin
  FDiffuse.Color := AValue.Color;
  NotifyChange(Self);
end;

// SetSpecular
//

procedure TGLLightSource.SetSpecular(AValue: TGLColor);
begin
  FSpecular.Color := AValue.Color;
  NotifyChange(Self);
end;

// SetConstAttenuation
//

procedure TGLLightSource.SetConstAttenuation(AValue: Single);
begin
  if FConstAttenuation <> AValue then
  begin
    FConstAttenuation := AValue;
    NotifyChange(Self);
  end;
end;

// SetLinearAttenuation
//

procedure TGLLightSource.SetLinearAttenuation(AValue: Single);
begin
  if FLinearAttenuation <> AValue then
  begin
    FLinearAttenuation := AValue;
    NotifyChange(Self);
  end;
end;

// SetQuadraticAttenuation
//

procedure TGLLightSource.SetQuadraticAttenuation(AValue: Single);
begin
  if FQuadraticAttenuation <> AValue then
  begin
    FQuadraticAttenuation := AValue;
    NotifyChange(Self);
  end;
end;

// Attenuated
//

function TGLLightSource.Attenuated: Boolean;
begin
  Result := (LightStyle <> lsParallel)
    and ((ConstAttenuation <> 1) or (LinearAttenuation <> 0) or
    (QuadraticAttenuation <> 0));
end;

// ------------------
// ------------------ TGLScene ------------------
// ------------------

// Create
//

constructor TGLScene.Create(AOwner: TComponent);
begin
  inherited;
  // root creation
  FCurrentBuffer := nil;
  FObjects := TGLSceneRootObject.Create(Self);
  FObjects.Name := 'ObjectRoot';
  FLights := TPersistentObjectList.Create;
  FObjectsSorting := osRenderBlendedLast;
  FVisibilityCulling := vcNone;
  // actual maximum number of lights is stored in TGLSceneViewer
  FLights.Count := 8;
  FInitializableObjects := TGLInitializableObjectList.Create;
end;

// Destroy
//

destructor TGLScene.Destroy;
begin
  InitializableObjects.Free;
  FObjects.DestroyHandles;
  FLights.Free;
  FObjects.Free;
  if Assigned(FBuffers) then FreeAndNil(FBuffers);
  inherited Destroy;
end;

// AddLight
//

procedure TGLScene.AddLight(ALight: TGLLightSource);
var
  i: Integer;
begin
  for i := 0 to FLights.Count - 1 do
    if FLights.List^[i] = nil then
    begin
      FLights.List^[i] := ALight;
      ALight.FLightID := i;
      Break;
    end;
end;

// RemoveLight
//

procedure TGLScene.RemoveLight(ALight: TGLLightSource);
var
  idx: Integer;
begin
  idx := FLights.IndexOf(ALight);
  if idx >= 0 then
    FLights[idx] := nil;
end;

// AddLights
//

procedure TGLScene.AddLights(anObj: TGLBaseSceneObject);
var
  i: Integer;
begin
  if anObj is TGLLightSource then
    AddLight(TGLLightSource(anObj));
  for i := 0 to anObj.Count - 1 do
    AddLights(anObj.Children[i]);
end;

// RemoveLights
//

procedure TGLScene.RemoveLights(anObj: TGLBaseSceneObject);
var
  i: Integer;
begin
  if anObj is TGLLightSource then
    RemoveLight(TGLLightSource(anObj));
  for i := 0 to anObj.Count - 1 do
    RemoveLights(anObj.Children[i]);
end;

// ShutdownAllLights
//

procedure TGLScene.ShutdownAllLights;

  procedure DoShutdownLight(Obj: TGLBaseSceneObject);
  var
    i: integer;
  begin
    if Obj is TGLLightSource then
      TGLLightSource(Obj).Shining := False;
    for i := 0 to Obj.Count - 1 do
      DoShutDownLight(Obj[i]);
  end;

begin
  DoShutdownLight(FObjects);
end;

// AddBuffer
//

procedure TGLScene.AddBuffer(aBuffer: TGLSceneBuffer);
begin
  if not Assigned(FBuffers) then
    FBuffers := TPersistentObjectList.Create;
  if FBuffers.IndexOf(aBuffer) < 0 then
  begin
    FBuffers.Add(aBuffer);
    if FBaseContext = nil then
      FBaseContext := TGLSceneBuffer(FBuffers[0]).RenderingContext;
    if (FBuffers.Count > 1) and Assigned(FBaseContext) then
      aBuffer.RenderingContext.ShareLists(FBaseContext);
  end;
end;

// RemoveBuffer
//

procedure TGLScene.RemoveBuffer(aBuffer: TGLSceneBuffer);
var
  i: Integer;
begin
  if Assigned(FBuffers) then
  begin
    i := FBuffers.IndexOf(aBuffer);
    if i >= 0 then
    begin
      if FBuffers.Count = 1 then
      begin
        FreeAndNil(FBuffers);
        FBaseContext := nil;
      end
      else
      begin
        FBuffers.Delete(i);
        FBaseContext := TGLSceneBuffer(FBuffers[0]).RenderingContext;
      end;
    end;
  end;
end;

// GetChildren
//

procedure TGLScene.GetChildren(AProc: TGetChildProc; Root: TComponent);
begin
  FObjects.GetChildren(AProc, Root);
end;

// SetChildOrder
//

procedure TGLScene.SetChildOrder(AChild: TComponent; Order: Integer);
begin
  (AChild as TGLBaseSceneObject).Index := Order;
end;

// IsUpdating
//

function TGLScene.IsUpdating: Boolean;
begin
  Result := (FUpdateCount <> 0) or (csLoading in ComponentState) or (csDestroying
    in ComponentState);
end;

// BeginUpdate
//

procedure TGLScene.BeginUpdate;
begin
  Inc(FUpdateCount);
end;

// EndUpdate
//

procedure TGLScene.EndUpdate;
begin
  Assert(FUpdateCount > 0);
  Dec(FUpdateCount);
  if FUpdateCount = 0 then
    NotifyChange(Self);
end;

// SetObjectsSorting
//

procedure TGLScene.SetObjectsSorting(const val: TGLObjectsSorting);
begin
  if FObjectsSorting <> val then
  begin
    if val = osInherited then
      FObjectsSorting := osRenderBlendedLast
    else
      FObjectsSorting := val;
    NotifyChange(Self);
  end;
end;

// SetVisibilityCulling
//

procedure TGLScene.SetVisibilityCulling(const val: TGLVisibilityCulling);
begin
  if FVisibilityCulling <> val then
  begin
    if val = vcInherited then
      FVisibilityCulling := vcNone
    else
      FVisibilityCulling := val;
    NotifyChange(Self);
  end;
end;

// ReadState
//

procedure TGLScene.ReadState(Reader: TReader);
var
  SaveRoot: TComponent;
begin
  SaveRoot := Reader.Root;
  try
    if Owner <> nil then
      Reader.Root := Owner;
    inherited;
  finally
    Reader.Root := SaveRoot;
  end;
end;

// Progress
//

procedure TGLScene.Progress(const deltaTime, newTime: Double);
var
  pt: TProgressTimes;
begin
  pt.deltaTime := deltaTime;
  pt.newTime := newTime;
  FCurrentDeltaTime := deltaTime;
  if Assigned(FOnBeforeProgress) then
   FOnBeforeProgress(Self, deltaTime, newTime);
  FObjects.DoProgress(pt);
  if Assigned(FOnProgress) then
   FOnProgress(Self, deltaTime, newTime);
end;

// SaveToFile
//

procedure TGLScene.SaveToFile(const fileName: string);
var
  stream: TStream;
begin
  stream := CreateFileStream(fileName, fmCreate);
  try
    SaveToStream(stream);
  finally
    stream.Free;
  end;
end;

// LoadFromFile
//

procedure TGLScene.LoadFromFile(const fileName: string);

  procedure CheckResFileStream(Stream: TStream);
  var
    N: Integer;
    B: Byte;
  begin
    N := Stream.Position;
    Stream.Read(B, Sizeof(B));
    Stream.Position := N;
    if B = $FF then
      Stream.ReadResHeader;
  end;

var
  stream: TStream;
begin
  stream := CreateFileStream(fileName, fmOpenRead);
  try
    CheckResFileStream(stream);
    LoadFromStream(stream);
  finally
    stream.Free;
  end;
end;

// SaveToTextFile
//

procedure TGLScene.SaveToTextFile(const fileName: string);
var
  mem: TMemoryStream;
  fil: TStream;
begin
  mem := TMemoryStream.Create;
  fil := CreateFileStream(fileName, fmCreate);
  try
    SaveToStream(mem);
    mem.Position := 0;
    ObjectBinaryToText(mem, fil);
  finally
    fil.Free;
    mem.Free;
  end;
end;

// LoadFromTextFile
//

procedure TGLScene.LoadFromTextFile(const fileName: string);
var
  Mem: TMemoryStream;
  Fil: TStream;
begin
  Mem := TMemoryStream.Create;
  Fil := CreateFileStream(fileName, fmOpenRead);
  try
    ObjectTextToBinary(Fil, Mem);
    Mem.Position := 0;
    LoadFromStream(Mem);
  finally
    Fil.Free;
    Mem.Free;
  end;
end;

// LoadFromStream
//

procedure TGLScene.LoadFromStream(aStream: TStream);
var
  fixups: TStringList;
  i: Integer;
  obj: TGLBaseSceneObject;
begin
  Fixups := TStringList.Create;
  try
    if Assigned(FBuffers) then
    begin
      for i := 0 to FBuffers.Count - 1 do
        Fixups.AddObject(TGLSceneBuffer(FBuffers[i]).Camera.Name, FBuffers[i]);
    end;
    ShutdownAllLights;
    // will remove Viewer from FBuffers
    Objects.DeleteChildren;
    aStream.ReadComponent(Self);
    for i := 0 to Fixups.Count - 1 do
    begin
      obj := FindSceneObject(fixups[I]);
      if obj is TGLCamera then
        TGLSceneBuffer(Fixups.Objects[i]).Camera := TGLCamera(obj)
      else { can assign default camera (if existing, of course) instead }
        ;
    end;
  finally
    Fixups.Free;
  end;
end;

// SaveToStream
//

procedure TGLScene.SaveToStream(aStream: TStream);
begin
  aStream.WriteComponent(Self);
end;

// FindSceneObject
//

function TGLScene.FindSceneObject(const AName: string): TGLBaseSceneObject;
begin
  Result := FObjects.FindChild(AName, False);
end;

// RayCastIntersect
//

function TGLScene.RayCastIntersect(const rayStart, rayVector: TVector;
  intersectPoint: PVector = nil;
  intersectNormal: PVector = nil): TGLBaseSceneObject;
var
  bestDist2: Single;
  bestHit: TGLBaseSceneObject;
  iPoint, iNormal: TVector;
  pINormal: PVector;

  function RecursiveDive(baseObject: TGLBaseSceneObject): TGLBaseSceneObject;
  var
    i: Integer;
    curObj: TGLBaseSceneObject;
    dist2: Single;
    fNear, fFar: single;
  begin
    Result := nil;
    for i := 0 to baseObject.Count - 1 do
    begin
      curObj := baseObject.Children[i];
      if curObj.Visible then
      begin
        if RayCastAABBIntersect(rayStart, rayVector,
          curObj.AxisAlignedBoundingBoxAbsoluteEx, fNear, fFar) then
        begin
          if fnear * fnear > bestDist2 then
          begin
            if not PointInAABB(rayStart, curObj.AxisAlignedBoundingBoxAbsoluteEx) then
              continue;
          end;
          if curObj.RayCastIntersect(rayStart, rayVector, @iPoint, pINormal) then
          begin
            dist2 := VectorDistance2(rayStart, iPoint);
            if dist2 < bestDist2 then
            begin
              bestHit := curObj;
              bestDist2 := dist2;
              if Assigned(intersectPoint) then
                intersectPoint^ := iPoint;
              if Assigned(intersectNormal) then
                intersectNormal^ := iNormal;
            end;
          end;
          RecursiveDive(curObj);
        end;
      end;
    end;
  end;

begin
  bestDist2 := 1e20;
  bestHit := nil;
  if Assigned(intersectNormal) then
    pINormal := @iNormal
  else
    pINormal := nil;
  RecursiveDive(Objects);
  Result := bestHit;
end;

// NotifyChange
//

procedure TGLScene.NotifyChange(Sender: TObject);
var
  i: Integer;
begin
  if (not IsUpdating) and Assigned(FBuffers) then
    for i := 0 to FBuffers.Count - 1 do
      TGLSceneBuffer(FBuffers[i]).NotifyChange(Self);
end;

// SetupLights
//

procedure TGLScene.SetupLights(maxLights: Integer);
var
  i: Integer;
  lightSource: TGLLightSource;
  nbLights: Integer;
  lPos: TVector;
begin
  nbLights := FLights.Count;
  if nbLights > maxLights then
    nbLights := maxLights;
  // setup all light sources
  with CurrentVKContext.VKStates, CurrentVKContext.PipelineTransformation do
  begin
    for i := 0 to nbLights - 1 do
    begin
      lightSource := TGLLightSource(FLights[i]);
      if Assigned(lightSource) then
        with lightSource do
        begin
          LightEnabling[FLightID] := Shining;
          if Shining then
          begin
            if FixedFunctionPipeLight then
            begin
              RebuildMatrix;
              if LightStyle in [lsParallel, lsParallelSpot] then
              begin
                ModelMatrix := AbsoluteMatrix;
                glLightfv(GL_LIGHT0 + FLightID, GL_POSITION, SpotDirection.AsAddress);
              end
              else
              begin
                ModelMatrix := Parent.AbsoluteMatrix;
                glLightfv(GL_LIGHT0 + FLightID, GL_POSITION, Position.AsAddress);
              end;
              if LightStyle in [lsSpot, lsParallelSpot] then
              begin
                if FSpotCutOff <> 180 then
                  glLightfv(GL_LIGHT0 + FLightID, GL_SPOT_DIRECTION, FSpotDirection.AsAddress);
              end;
            end;

            lPos := lightSource.AbsolutePosition;
            if LightStyle in [lsParallel, lsParallelSpot] then
              lPos.W := 0.0
            else
              lPos.W := 1.0;
            LightPosition[FLightID] := lPos;
            LightSpotDirection[FLightID] := lightSource.SpotDirection.AsAffineVector;

            LightAmbient[FLightID] := FAmbient.Color;
            LightDiffuse[FLightID] := FDiffuse.Color;
            LightSpecular[FLightID] := FSpecular.Color;

            LightConstantAtten[FLightID] := FConstAttenuation;
            LightLinearAtten[FLightID] := FLinearAttenuation;
            LightQuadraticAtten[FLightID] := FQuadraticAttenuation;

            LightSpotExponent[FLightID] := FSpotExponent;
            LightSpotCutoff[FLightID] := FSpotCutOff;
          end;
        end
      else
        LightEnabling[i] := False;
    end;
    // turn off other lights
    for i := nbLights to maxLights - 1 do
      LightEnabling[i] := False;
    ModelMatrix := IdentityHmgMatrix;
  end;
end;

// ------------------
// ------------------ TGLFogEnvironment ------------------
// ------------------

// Note: The fog implementation is not conformal with the rest of the scene management
//       because it is viewer bound not scene bound.

// Create
//

constructor TGLFogEnvironment.Create(AOwner: TPersistent);
begin
  inherited;
  FSceneBuffer := (AOwner as TGLSceneBuffer);
  FFogColor := TGLColor.CreateInitialized(Self, clrBlack);
  FFogMode := fmLinear;
  FFogStart := 10;
  FFogEnd := 1000;
  FFogDistance := fdDefault;
end;

// Destroy
//

destructor TGLFogEnvironment.Destroy;
begin
  FFogColor.Free;
  inherited Destroy;
end;

// SetFogColor
//

procedure TGLFogEnvironment.SetFogColor(Value: TGLColor);
begin
  if Assigned(Value) then
  begin
    FFogColor.Assign(Value);
    NotifyChange(Self);
  end;
end;

// SetFogStart
//

procedure TGLFogEnvironment.SetFogStart(Value: Single);
begin
  if Value <> FFogStart then
  begin
    FFogStart := Value;
    NotifyChange(Self);
  end;
end;

// SetFogEnd
//

procedure TGLFogEnvironment.SetFogEnd(Value: Single);
begin
  if Value <> FFogEnd then
  begin
    FFogEnd := Value;
    NotifyChange(Self);
  end;
end;

// Assign
//

procedure TGLFogEnvironment.Assign(Source: TPersistent);
begin
  if Source is TGLFogEnvironment then
  begin
    FFogColor.Assign(TGLFogEnvironment(Source).FFogColor);
    FFogStart := TGLFogEnvironment(Source).FFogStart;
    FFogEnd := TGLFogEnvironment(Source).FFogEnd;
    FFogMode := TGLFogEnvironment(Source).FFogMode;
    FFogDistance := TGLFogEnvironment(Source).FFogDistance;
    NotifyChange(Self);
  end;
  inherited;
end;

// IsAtDefaultValues
//

function TGLFogEnvironment.IsAtDefaultValues: Boolean;
begin
  Result := VectorEquals(FogColor.Color, FogColor.DefaultColor)
    and (FogStart = 10)
    and (FogEnd = 1000)
    and (FogMode = fmLinear)
    and (FogDistance = fdDefault);
end;

// SetFogMode
//

procedure TGLFogEnvironment.SetFogMode(Value: TFogMode);
begin
  if Value <> FFogMode then
  begin
    FFogMode := Value;
    NotifyChange(Self);
  end;
end;

// SetFogDistance
//

procedure TGLFogEnvironment.SetFogDistance(const val: TFogDistance);
begin
  if val <> FFogDistance then
  begin
    FFogDistance := val;
    NotifyChange(Self);
  end;
end;

// ApplyFog
//
var
  vImplemDependantFogDistanceDefault: Integer = -1;

procedure TGLFogEnvironment.ApplyFog;
var
  tempActivation: Boolean;
begin
  with FSceneBuffer do
  begin
    if not Assigned(FRenderingContext) then
      Exit;
    tempActivation := not FRenderingContext.Active;
    if tempActivation then
      FRenderingContext.Activate;
  end;

  case FFogMode of
    fmLinear: glFogi(GL_FOG_MODE, GL_LINEAR);
    fmExp:
      begin
        glFogi(GL_FOG_MODE, GL_EXP);
        glFogf(GL_FOG_DENSITY, FFogColor.Alpha);
      end;
    fmExp2:
      begin
        glFogi(GL_FOG_MODE, GL_EXP2);
        glFogf(GL_FOG_DENSITY, FFogColor.Alpha);
      end;
  end;
  glFogfv(GL_FOG_COLOR, FFogColor.AsAddress);
  glFogf(GL_FOG_START, FFogStart);
  glFogf(GL_FOG_END, FFogEnd);
  if GL_NV_fog_distance then
  begin
    case FogDistance of
      fdDefault:
        begin
          if vImplemDependantFogDistanceDefault = -1 then
            glGetIntegerv(Cardinal(GL_NV_fog_distance), //GL_FOG_DISTANCE_MODE_NV,
              @vImplemDependantFogDistanceDefault)
          else
            glFogi(Cardinal(GL_NV_fog_distance), vImplemDependantFogDistanceDefault);
        end;
      fdEyePlane:
        glFogi(Cardinal(GL_NV_fog_distance), GL_EYE_PLANE_ABSOLUTE_NV);
      fdEyeRadial:
        glFogi(GL_FOG_DISTANCE_MODE_NV, GL_EYE_RADIAL_NV);
    else
      Assert(False);
    end;
  end;

  if tempActivation then
    FSceneBuffer.RenderingContext.Deactivate;
end;

// ------------------
// ------------------ TGLSceneBuffer ------------------
// ------------------

// Create
//

constructor TGLSceneBuffer.Create(AOwner: TPersistent);
begin
  inherited Create(AOwner);

  // initialize private state variables
  FFogEnvironment := TGLFogEnvironment.Create(Self);
  FBackgroundColor := TColors.SysBtnFace;
  FBackgroundAlpha := 1;
  FAmbientColor := TGLColor.CreateInitialized(Self, clrGray20);
  FDepthTest := True;
  FFaceCulling := True;
  FLighting := True;
  FAntiAliasing := aaDefault;
  FDepthPrecision := dpDefault;
  FColorDepth := cdDefault;
  FShadeModel := smDefault;
  FFogEnable := False;
  FLayer := clMainPlane;
  FAfterRenderEffects := TPersistentObjectList.Create;

  FContextOptions := [roDoubleBuffer, roRenderToWindow, roDebugContext];

  ResetPerformanceMonitor;
end;

// Destroy
//

destructor TGLSceneBuffer.Destroy;
begin
  Melt;
  DestroyRC;
  FAmbientColor.Free;
  FAfterRenderEffects.Free;
  FFogEnvironment.Free;
  inherited Destroy;
end;

// PrepareGLContext
//

procedure TGLSceneBuffer.PrepareGLContext;
begin
  if Assigned(FOnPrepareGLContext) then
    FOnPrepareGLContext(Self);
end;

// SetupRCOptions
//

procedure TGLSceneBuffer.SetupRCOptions(context: TGLContext);
const
  cColorDepthToColorBits: array[cdDefault..cdFloat128bits] of Integer =
    (24, 8, 16, 24, 64, 128); // float_type
  cDepthPrecisionToDepthBits: array[dpDefault..dp32bits] of Integer =
    (24, 16, 24, 32);
var
  locOptions: TGLRCOptions;
  locStencilBits, locAlphaBits, locColorBits: Integer;
begin
  locOptions := [];

  if roDoubleBuffer in ContextOptions then
    locOptions := locOptions + [rcoDoubleBuffered];
  if roStereo in ContextOptions then
    locOptions := locOptions + [rcoStereo];
  if roDebugContext in ContextOptions then
    locOptions := locOptions + [rcoDebug];
  if roVulkan_ES2_Context in ContextOptions then
    locOptions := locOptions + [rcoOGL_ES];
  if roNoColorBuffer in ContextOptions then
    locColorBits := 0
  else
    locColorBits := cColorDepthToColorBits[ColorDepth];
  if roStencilBuffer in ContextOptions then
    locStencilBits := 8
  else
    locStencilBits := 0;
  if roDestinationAlpha in ContextOptions then
    locAlphaBits := 8
  else
    locAlphaBits := 0;
  with context do
  begin
    if roSoftwareMode in ContextOptions then
      Acceleration := chaSoftware
    else
      Acceleration := chaHardware;
    Options := locOptions;
    ColorBits := locColorBits;
    DepthBits := cDepthPrecisionToDepthBits[DepthPrecision];
    StencilBits := locStencilBits;
    AlphaBits := locAlphaBits;
    AccumBits := AccumBufferBits;
    AuxBuffers := 0;
    AntiAliasing := Self.AntiAliasing;
    Layer := Self.Layer;
    VKStates.ForwardContext := roForwardContext in ContextOptions;
    PrepareGLContext;
  end;
end;

procedure TGLSceneBuffer.CreateRC(AWindowHandle: THandle; memoryContext:
  Boolean; BufferCount: Integer);
begin
  DestroyRC;
  FRendering := True;

  try
    // will be freed in DestroyWindowHandle
    FRenderingContext := VKContextManager.CreateContext;
    if not Assigned(FRenderingContext) then
      raise Exception.Create('Failed to create RenderingContext.');
    SetupRCOptions(FRenderingContext);

    if Assigned(FCamera) and Assigned(FCamera.FScene) then
      FCamera.FScene.AddBuffer(Self);

    with FRenderingContext do
    begin
      try
        if memoryContext then
          CreateMemoryContext(AWindowHandle, FViewPort.Width, FViewPort.Height,
            BufferCount)
        else
          CreateContext(AWindowHandle);
      except
        FreeAndNil(FRenderingContext);
        raise;
      end;
    end;
    FRenderingContext.Activate;
    try
      // this one should NOT be replaced with an assert
      if (GL_VERSION < 1.1) then
      begin
        ShowMessage(strWrongVersion);
        Abort;
      end;
      // define viewport, this is necessary because the first WM_SIZE message
      // is posted before the rendering context has been created
      FRenderingContext.VKStates.ViewPort :=
        Vector4iMake(FViewPort.Left, FViewPort.Top, FViewPort.Width, FViewPort.Height);
      // set up initial context states
      SetupRenderingContext(FRenderingContext);
      FRenderingContext.VKStates.ColorClearValue :=
        ConvertWinColor(FBackgroundColor);
    finally
      FRenderingContext.Deactivate;
    end;
  finally
    FRendering := False;
  end;
end;

// DestroyRC
//

procedure TGLSceneBuffer.DestroyRC;
begin
  if Assigned(FRenderingContext) then
  begin
    Melt;
    // for some obscure reason, Mesa3D doesn't like this call... any help welcome
    FreeAndNil(FSelector);
    FreeAndNil(FRenderingContext);
    if Assigned(FCamera) and Assigned(FCamera.FScene) then
      FCamera.FScene.RemoveBuffer(Self);
  end;
end;

// RCInstantiated
//

function TGLSceneBuffer.RCInstantiated: Boolean;
begin
  Result := Assigned(FRenderingContext);
end;

// Resize
//

procedure TGLSceneBuffer.Resize(newLeft, newTop, newWidth, newHeight: Integer);
begin
  if newWidth < 1 then
    newWidth := 1;
  if newHeight < 1 then
    newHeight := 1;
  FViewPort.Left := newLeft;
  FViewPort.Top := newTop;
  FViewPort.Width := newWidth;
  FViewPort.Height := newHeight;
  if Assigned(FRenderingContext) then
  begin
    FRenderingContext.Activate;
    try
      // Part of workaround for MS OpenGL "black borders" bug
      FRenderingContext.VKStates.ViewPort :=
        Vector4iMake(FViewPort.Left, FViewPort.Top, FViewPort.Width, FViewPort.Height);
    finally
      FRenderingContext.Deactivate;
    end;
  end;
end;

// Acceleration
//

function TGLSceneBuffer.Acceleration: TGLContextAcceleration;
begin
  if Assigned(FRenderingContext) then
    Result := FRenderingContext.Acceleration
  else
    Result := chaUnknown;
end;

// SetupRenderingContext
//

procedure TGLSceneBuffer.SetupRenderingContext(context: TGLContext);

  procedure SetState(bool: Boolean; csState: TGLState);
  begin
    case bool of
      true: context.VKStates.PerformEnable(csState);
      false: context.VKStates.PerformDisable(csState);
    end;
  end;

var
  LColorDepth: Cardinal;
begin
  if not Assigned(context) then
    Exit;

  if not (roForwardContext in ContextOptions) then
  begin
    glLightModelfv(GL_LIGHT_MODEL_AMBIENT, FAmbientColor.AsAddress);
    if roTwoSideLighting in FContextOptions then
      glLightModeli(GL_LIGHT_MODEL_TWO_SIDE, GL_TRUE)
    else
      glLightModeli(GL_LIGHT_MODEL_TWO_SIDE, GL_FALSE);
    glHint(GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST);
    case ShadeModel of
      smDefault, smSmooth: glShadeModel(GL_SMOOTH);
      smFlat: glShadeModel(GL_FLAT);
    else
      Assert(False, strErrorEx + strUnknownType);
    end;
  end;

  with context.VKStates do
  begin
    Enable(stNormalize);
    SetState(DepthTest, stDepthTest);
    SetState(FaceCulling, stCullFace);
    SetState(Lighting, stLighting);
    SetState(FogEnable, stFog);
    if GL_ARB_depth_clamp then
      Disable(stDepthClamp);
    if not (roForwardContext in ContextOptions) then
    begin
      glGetIntegerv(GL_BLUE_BITS, @LColorDepth); // could've used red or green too
      SetState((LColorDepth < 8), stDither);
    end;
    ResetAllTextureMatrix;
  end;
end;

// GetLimit
//

function TGLSceneBuffer.GetLimit(Which: TLimitType): Integer;
var
  VP: array[0..1] of Double;
begin
  case Which of
    limClipPlanes:
      glGetIntegerv(GL_MAX_CLIP_PLANES, @Result);
    limEvalOrder:
      glGetIntegerv(GL_MAX_EVAL_ORDER, @Result);
    limLights:
      glGetIntegerv(GL_MAX_LIGHTS, @Result);
    limListNesting:
      glGetIntegerv(GL_MAX_LIST_NESTING, @Result);
    limModelViewStack:
      glGetIntegerv(GL_MAX_MODELVIEW_STACK_DEPTH, @Result);
    limNameStack:
      glGetIntegerv(GL_MAX_NAME_STACK_DEPTH, @Result);
    limPixelMapTable:
      glGetIntegerv(GL_MAX_PIXEL_MAP_TABLE, @Result);
    limProjectionStack:
      glGetIntegerv(GL_MAX_PROJECTION_STACK_DEPTH, @Result);
    limTextureSize:
      glGetIntegerv(GL_MAX_TEXTURE_SIZE, @Result);
    limTextureStack:
      glGetIntegerv(GL_MAX_TEXTURE_STACK_DEPTH, @Result);
    limViewportDims:
      begin
        glGetDoublev(GL_MAX_VIEWPORT_DIMS, @VP);
        if VP[0] > VP[1] then
          Result := Round(VP[0])
        else
          Result := Round(VP[1]);
      end;
    limAccumAlphaBits:
      glGetIntegerv(GL_ACCUM_ALPHA_BITS, @Result);
    limAccumBlueBits:
      glGetIntegerv(GL_ACCUM_BLUE_BITS, @Result);
    limAccumGreenBits:
      glGetIntegerv(GL_ACCUM_GREEN_BITS, @Result);
    limAccumRedBits:
      glGetIntegerv(GL_ACCUM_RED_BITS, @Result);
    limAlphaBits:
      glGetIntegerv(GL_ALPHA_BITS, @Result);
    limAuxBuffers:
      glGetIntegerv(GL_AUX_BUFFERS, @Result);
    limDepthBits:
      glGetIntegerv(GL_DEPTH_BITS, @Result);
    limStencilBits:
      glGetIntegerv(GL_STENCIL_BITS, @Result);
    limBlueBits:
      glGetIntegerv(GL_BLUE_BITS, @Result);
    limGreenBits:
      glGetIntegerv(GL_GREEN_BITS, @Result);
    limRedBits:
      glGetIntegerv(GL_RED_BITS, @Result);
    limIndexBits:
      glGetIntegerv(GL_INDEX_BITS, @Result);
    limStereo:
      glGetIntegerv(GL_STEREO, @Result);
    limDoubleBuffer:
      glGetIntegerv(GL_DOUBLEBUFFER, @Result);
    limSubpixelBits:
      glGetIntegerv(GL_SUBPIXEL_BITS, @Result);
    limNbTextureUnits:
      if GL_ARB_multitexture then
        glGetIntegerv(GL_MAX_TEXTURE_UNITS_ARB, @Result)
      else
        Result := 1;
  else
    Result := 0;
  end;
end;

// RenderToFile
//

procedure TGLSceneBuffer.RenderToFile(const aFile: string; DPI: Integer);
var
  aBitmap: TBitmap;
  saveAllowed: Boolean;
  fileName: string;
begin
  Assert((not FRendering), strAlreadyRendering);
  aBitmap := TBitmap.Create;
  try
    aBitmap.Width := FViewPort.Width;
    aBitmap.Height := FViewPort.Height;
    { TODO -oPW : E2129 Cannot assign to a read-only property }
    (*aBitmap.PixelFormat := glpf24Bit;*)
    RenderToBitmap(ABitmap, DPI);
    fileName := aFile;
    if fileName = '' then
      saveAllowed := SavePictureDialog(fileName)
    else
      saveAllowed := True;
    if saveAllowed then
    begin
      if FileExists(fileName) then
        saveAllowed := QuestionDlg(Format('Overwrite file %s?', [fileName]));
      if saveAllowed then
        aBitmap.SaveToFile(fileName);
    end;
  finally
    aBitmap.Free;
  end;
end;

// RenderToFile
//

procedure TGLSceneBuffer.RenderToFile(const AFile: string; bmpWidth, bmpHeight:
  Integer);
var
  aBitmap: TBitmap;
  saveAllowed: Boolean;
  fileName: string;
begin
  Assert((not FRendering), strAlreadyRendering);
  aBitmap := TBitmap.Create;
  try
    aBitmap.Width := bmpWidth;
    aBitmap.Height := bmpHeight;
    { TODO -oPW : E2129 Cannot assign to a read-only property }
    (*aBitmap.PixelFormat := glpf24Bit;*)
    RenderToBitmap(aBitmap,
      (GetDeviceLogicalPixelsX(ABitmap.Handle) * bmpWidth) div
      FViewPort.Width);
    fileName := AFile;
    if fileName = '' then
      saveAllowed := SavePictureDialog(fileName)
    else
      saveAllowed := True;
    if saveAllowed then
    begin
      if FileExists(fileName) then
        saveAllowed := QuestionDlg(Format('Overwrite file %s?', [fileName]));
      if SaveAllowed then
        aBitmap.SaveToFile(fileName);
    end;
  finally
    aBitmap.Free;
  end;
end;

// TGLBitmap32
//

function TGLSceneBuffer.CreateSnapShot: TGLBitmap32;
begin
  Result := TGLBitmap32.Create;
  Result.Width := FViewPort.Width;
  Result.Height := FViewPort.Height;
  if Assigned(Camera) and Assigned(Camera.Scene) then
  begin
    FRenderingContext.Activate;
    try
      Result.ReadPixels(Rect(0, 0, FViewPort.Width, FViewPort.Height));
    finally
      FRenderingContext.DeActivate;
    end;
  end;
end;

// CreateSnapShotBitmap
//

function TGLSceneBuffer.CreateSnapShotBitmap: TBitmap;
var
  bmp32: TGLBitmap32;
begin
  bmp32 := CreateSnapShot;
  try
    Result := bmp32.Create32BitsBitmap;
  finally
    bmp32.Free;
  end;
end;

// CopyToTexture
//

procedure TGLSceneBuffer.CopyToTexture(aTexture: TGLTexture);
begin
  CopyToTexture(aTexture, 0, 0, Width, Height, 0, 0);
end;

// CopyToTexture
//

procedure TGLSceneBuffer.CopyToTexture(aTexture: TGLTexture;
  xSrc, ySrc, AWidth, AHeight: Integer;
  xDest, yDest: Integer;
  glCubeFace: GLEnum = 0);
var
  bindTarget: TGLTextureTarget;
begin
  if RenderingContext <> nil then
  begin
    RenderingContext.Activate;
    try
      if not (aTexture.Image is TGLBlankImage) then
        aTexture.ImageClassName := TGLBlankImage.ClassName;
      if aTexture.Image.Width <> AWidth then
        TGLBlankImage(aTexture.Image).Width := AWidth;
      if aTexture.Image.Height <> AHeight then
        TGLBlankImage(aTexture.Image).Height := AHeight;
      if aTexture.Image.Depth <> 0 then
        TGLBlankImage(aTexture.Image).Depth := 0;
      if TGLBlankImage(aTexture.Image).CubeMap <> (glCubeFace > 0) then
        TGLBlankImage(aTexture.Image).CubeMap := (glCubeFace > 0);

      bindTarget := aTexture.Image.NativeTextureTarget;
      RenderingContext.VKStates.TextureBinding[0, bindTarget] := aTexture.Handle;
      if glCubeFace > 0 then
        glCopyTexSubImage2D(glCubeFace,
          0, xDest, yDest, xSrc, ySrc, AWidth, AHeight)
      else
        glCopyTexSubImage2D(DecodeTextureTarget(bindTarget),
          0, xDest, yDest, xSrc, ySrc, AWidth, AHeight)
    finally
      RenderingContext.Deactivate;
    end;
  end;
end;

procedure TGLSceneBuffer.SaveAsFloatToFile(const aFilename: string);
var
  Data: pointer;
  DataSize: integer;
  Stream: TMemoryStream;
const
  FloatSize = 4;
begin
  if Assigned(Camera) and Assigned(Camera.Scene) then
  begin
    DataSize := Width * Height * FloatSize * FloatSize;
    GetMem(Data, DataSize);
    FRenderingContext.Activate;
    try
      glReadPixels(0, 0, Width, Height, GL_RGBA, GL_FLOAT, Data);
      glGetError;

      Stream := TMemoryStream.Create;
      try
        Stream.Write(Data^, DataSize);
        Stream.SaveToFile(aFilename);
      finally
        Stream.Free;
      end;
    finally
      FRenderingContext.DeActivate;
      FreeMem(Data);
    end;
  end;
end;

// SetViewPort
//

procedure TGLSceneBuffer.SetViewPort(X, Y, W, H: Integer);
begin
  with FViewPort do
  begin
    Left := X;
    Top := Y;
    Width := W;
    Height := H;
  end;
  NotifyChange(Self);
end;

// Width
//

function TGLSceneBuffer.Width: Integer;
begin
  Result := FViewPort.Width;
end;

// Height
//

function TGLSceneBuffer.Height: Integer;
begin
  Result := FViewPort.Height;
end;

// Freeze
//

procedure TGLSceneBuffer.Freeze;
begin
  if Freezed then
    Exit;
  if RenderingContext = nil then
    Exit;
  Render;
  FFreezed := True;
  RenderingContext.Activate;
  try
    FFreezeBuffer := AllocMem(FViewPort.Width * FViewPort.Height * 4);
    glReadPixels(0, 0, FViewport.Width, FViewPort.Height,
      GL_RGBA, GL_UNSIGNED_BYTE, FFreezeBuffer);
    FFreezedViewPort := FViewPort;
  finally
    RenderingContext.Deactivate;
  end;
end;

// Melt
//

procedure TGLSceneBuffer.Melt;
begin
  if not Freezed then
    Exit;
  FreeMem(FFreezeBuffer);
  FFreezeBuffer := nil;
  FFreezed := False;
end;

// RenderToBitmap
//

procedure TGLSceneBuffer.RenderToBitmap(ABitmap: TBitmap; DPI: Integer);
var
  nativeContext: TGLContext;
  aColorBits: Integer;
begin
  Assert((not FRendering), strAlreadyRendering);
  FRendering := True;
  nativeContext := RenderingContext;
  try
    aColorBits := PixelFormatToColorBits(ABitmap.PixelFormat);
    if aColorBits < 8 then
      aColorBits := 8;
    FRenderingContext := VKContextManager.CreateContext;
    SetupRCOptions(FRenderingContext);
    with FRenderingContext do
    begin
      Options := []; // no such things for bitmap rendering
      ColorBits := aColorBits; // honour Bitmap's pixel depth
      AntiAliasing := aaNone; // no AA for bitmap rendering
      CreateContext(ABitmap.Handle);
    end;
    try
      FRenderingContext.Activate;
      try
        SetupRenderingContext(FRenderingContext);
        FRenderingContext.VKStates.ColorClearValue := ConvertWinColor(FBackgroundColor);
        // set the desired viewport and limit output to this rectangle
        with FViewport do
        begin
          Left := 0;
          Top := 0;
          Width := ABitmap.Width;
          Height := ABitmap.Height;
          FRenderingContext.VKStates.ViewPort :=
            Vector4iMake(Left, Top, Width, Height);
        end;
        ClearBuffers;
        FRenderDPI := DPI;
        if FRenderDPI = 0 then
          FRenderDPI := GetDeviceLogicalPixelsX(ABitmap.Handle);
        // render
        DoBaseRender(FViewport, FRenderDPI, dsPrinting, nil);
        if nativeContext <> nil then
          FViewport := TRectangle(nativeContext.VKStates.ViewPort);
        glFinish;
      finally
        FRenderingContext.Deactivate;
      end;
    finally
      FRenderingContext.Free;
    end;
  finally
    FRenderingContext := nativeContext;
    FRendering := False;
  end;
  if Assigned(FAfterRender) then
    if Owner is TComponent then
      if not (csDesigning in TComponent(Owner).ComponentState) then
        FAfterRender(Self);
end;

// ShowInfo
//

procedure TGLSceneBuffer.ShowInfo(Modal: boolean);
begin
  if not Assigned(FRenderingContext) then
    Exit;
  // most info is available with active context only
  FRenderingContext.Activate;
  try
    InvokeInfoForm(Self, Modal);
  finally
    FRenderingContext.Deactivate;
  end;
end;

// ResetPerformanceMonitor
//

procedure TGLSceneBuffer.ResetPerformanceMonitor;
begin
  FFramesPerSecond := 0;
  FFrameCount := 0;
  FFirstPerfCounter := 0;
end;

// PushViewMatrix
//

procedure TGLSceneBuffer.PushViewMatrix(const newMatrix: TMatrix);
var
  n: Integer;
begin
  n := Length(FViewMatrixStack);
  SetLength(FViewMatrixStack, n + 1);
  FViewMatrixStack[n] := RenderingContext.PipelineTransformation.ViewMatrix;
  RenderingContext.PipelineTransformation.ViewMatrix := newMatrix;
end;

// PopModelViewMatrix
//

procedure TGLSceneBuffer.PopViewMatrix;
var
  n: Integer;
begin
  n := High(FViewMatrixStack);
  Assert(n >= 0, 'Unbalanced PopViewMatrix');
  RenderingContext.PipelineTransformation.ViewMatrix := FViewMatrixStack[n];
  SetLength(FViewMatrixStack, n);
end;

// PushProjectionMatrix
//

procedure TGLSceneBuffer.PushProjectionMatrix(const newMatrix: TMatrix);
var
  n: Integer;
begin
  n := Length(FProjectionMatrixStack);
  SetLength(FProjectionMatrixStack, n + 1);
  FProjectionMatrixStack[n] := RenderingContext.PipelineTransformation.ProjectionMatrix;
  RenderingContext.PipelineTransformation.ProjectionMatrix := newMatrix;
end;

// PopProjectionMatrix
//

procedure TGLSceneBuffer.PopProjectionMatrix;
var
  n: Integer;
begin
  n := High(FProjectionMatrixStack);
  Assert(n >= 0, 'Unbalanced PopProjectionMatrix');
  RenderingContext.PipelineTransformation.ProjectionMatrix := FProjectionMatrixStack[n];
  SetLength(FProjectionMatrixStack, n);
end;

function TGLSceneBuffer.ProjectionMatrix;
begin
  Result := RenderingContext.PipelineTransformation.ProjectionMatrix;
end;

function TGLSceneBuffer.ViewMatrix: TMatrix;
begin
  Result := RenderingContext.PipelineTransformation.ViewMatrix;
end;

function TGLSceneBuffer.ModelMatrix: TMatrix;
begin
  Result := RenderingContext.PipelineTransformation.ModelMatrix;
end;

// OrthoScreenToWorld
//

function TGLSceneBuffer.OrthoScreenToWorld(screenX, screenY: Integer):
  TAffineVector;
var
  camPos, camUp, camRight: TAffineVector;
  f: Single;
begin
  if Assigned(FCamera) then
  begin
    SetVector(camPos, FCameraAbsolutePosition);
    if Camera.TargetObject <> nil then
    begin
      SetVector(camUp, FCamera.AbsoluteUpVectorToTarget);
      SetVector(camRight, FCamera.AbsoluteRightVectorToTarget);
    end
    else
    begin
      SetVector(camUp, Camera.AbsoluteUp);
      SetVector(camRight, Camera.AbsoluteRight);
    end;
    f := 100 * FCamera.NearPlaneBias / (FCamera.FocalLength *
      FCamera.SceneScale);
    if FViewPort.Width > FViewPort.Height then
      f := f / FViewPort.Width
    else
      f := f / FViewPort.Height;
    SetVector(Result,
      VectorCombine3(camPos, camUp, camRight, 1,
      (screenY - (FViewPort.Height div 2)) * f,
      (screenX - (FViewPort.Width div 2)) * f));
  end
  else
    Result := NullVector;
end;

// ScreenToWorld (affine)
//

function TGLSceneBuffer.ScreenToWorld(const aPoint: TAffineVector):
  TAffineVector;
var
  rslt: TVector;
begin
  if Assigned(FCamera)
    and UnProject(
    VectorMake(aPoint),
    RenderingContext.PipelineTransformation.ViewProjectionMatrix,
    PHomogeneousIntVector(@FViewPort)^,
    rslt) then
    Result := Vector3fMake(rslt)
  else
    Result := aPoint;
end;

// ScreenToWorld (hmg)
//

function TGLSceneBuffer.ScreenToWorld(const aPoint: TVector): TVector;
begin
  MakePoint(Result, ScreenToWorld(AffineVectorMake(aPoint)));
end;

// ScreenToWorld (x, y)
//

function TGLSceneBuffer.ScreenToWorld(screenX, screenY: Integer): TAffineVector;
begin
  Result := ScreenToWorld(AffineVectorMake(screenX, FViewPort.Height - screenY,
    0));
end;

// WorldToScreen
//

function TGLSceneBuffer.WorldToScreen(const aPoint: TAffineVector):
  TAffineVector;
var
  rslt: TVector;
begin
  RenderingContext.Activate;
  try
    PrepareRenderingMatrices(FViewPort, FRenderDPI);
    if Assigned(FCamera)
      and Project(
      VectorMake(aPoint),
      RenderingContext.PipelineTransformation.ViewProjectionMatrix,
      TVector4i(FViewPort),
      rslt) then
      Result := Vector3fMake(rslt)
    else
      Result := aPoint;
  finally
    RenderingContext.Deactivate;
  end;
end;

// WorldToScreen
//

function TGLSceneBuffer.WorldToScreen(const aPoint: TVector): TVector;
begin
  SetVector(Result, WorldToScreen(AffineVectorMake(aPoint)));
end;

// WorldToScreen
//

procedure TGLSceneBuffer.WorldToScreen(points: PVector; nbPoints: Integer);
var
  i: Integer;
begin
  if Assigned(FCamera) then
  begin
    for i := nbPoints - 1 downto 0 do
    begin
      Project(points^, RenderingContext.PipelineTransformation.ViewProjectionMatrix, PHomogeneousIntVector(@FViewPort)^, points^);
      Inc(points);
    end;
  end;
end;

// ScreenToVector (affine)
//

function TGLSceneBuffer.ScreenToVector(const aPoint: TAffineVector):
  TAffineVector;
begin
  Result := VectorSubtract(ScreenToWorld(aPoint),
    PAffineVector(@FCameraAbsolutePosition)^);
end;

// ScreenToVector (hmg)
//

function TGLSceneBuffer.ScreenToVector(const aPoint: TVector): TVector;
begin
  SetVector(Result, VectorSubtract(ScreenToWorld(aPoint),
    FCameraAbsolutePosition));
  Result.W := 0;
end;

// ScreenToVector
//

function TGLSceneBuffer.ScreenToVector(const x, y: Integer): TVector;
var
  av: TAffineVector;
begin
  av.X := x;
  av.Y := y;
  av.Z := 0;
  SetVector(Result, ScreenToVector(av));
end;

// VectorToScreen
//

function TGLSceneBuffer.VectorToScreen(const VectToCam: TAffineVector):
  TAffineVector;
begin
  Result := WorldToScreen(VectorAdd(VectToCam,
    PAffineVector(@FCameraAbsolutePosition)^));
end;

// ScreenVectorIntersectWithPlane
//

function TGLSceneBuffer.ScreenVectorIntersectWithPlane(
  const aScreenPoint: TVector;
  const planePoint, planeNormal: TVector;
  var intersectPoint: TVector): Boolean;
var
  v: TVector;
begin
  if Assigned(FCamera) then
  begin
    SetVector(v, ScreenToVector(aScreenPoint));
    Result := RayCastPlaneIntersect(FCameraAbsolutePosition,
      v, planePoint, planeNormal, @intersectPoint);
    intersectPoint.W := 1;
  end
  else
    Result := False;
end;

// ScreenVectorIntersectWithPlaneXY
//

function TGLSceneBuffer.ScreenVectorIntersectWithPlaneXY(
  const aScreenPoint: TVector; const z: Single;
  var intersectPoint: TVector): Boolean;
begin
  Result := ScreenVectorIntersectWithPlane(aScreenPoint, VectorMake(0, 0, z),
    ZHmgVector, intersectPoint);
  intersectPoint.W := 0;
end;

// ScreenVectorIntersectWithPlaneYZ
//

function TGLSceneBuffer.ScreenVectorIntersectWithPlaneYZ(
  const aScreenPoint: TVector; const x: Single;
  var intersectPoint: TVector): Boolean;
begin
  Result := ScreenVectorIntersectWithPlane(aScreenPoint, VectorMake(x, 0, 0),
    XHmgVector, intersectPoint);
  intersectPoint.W := 0;
end;

// ScreenVectorIntersectWithPlaneXZ
//

function TGLSceneBuffer.ScreenVectorIntersectWithPlaneXZ(
  const aScreenPoint: TVector; const y: Single;
  var intersectPoint: TVector): Boolean;
begin
  Result := ScreenVectorIntersectWithPlane(aScreenPoint, VectorMake(0, y, 0),
    YHmgVector, intersectPoint);
  intersectPoint.W := 0;
end;

// PixelRayToWorld
//

function TGLSceneBuffer.PixelRayToWorld(x, y: Integer): TAffineVector;
var
  dov, np, fp, z, dst, wrpdst: Single;
  vec, cam, targ, rayhit, pix: TAffineVector;
  camAng: real;
begin
  if Camera.CameraStyle = csOrtho2D then
    dov := 2
  else
    dov := Camera.DepthOfView;
  np := Camera.NearPlane;
  fp := Camera.NearPlane + dov;
  z := GetPixelDepth(x, y);
  dst := (fp * np) / (fp - z * dov); //calc from z-buffer value to world depth
  //------------------------
  //z:=1-(fp/d-1)/(fp/np-1);  //calc from world depth to z-buffer value
  //------------------------
  vec.X := x;
  vec.Y := FViewPort.Height - y;
  vec.Z := 0;
  vec := ScreenToVector(vec);
  NormalizeVector(vec);
  SetVector(cam, Camera.AbsolutePosition);
  //targ:=Camera.TargetObject.Position.AsAffineVector;
  //SubtractVector(targ,cam);
  pix.X := FViewPort.Width * 0.5;
  pix.Y := FViewPort.Height * 0.5;
  pix.Z := 0;
  targ := self.ScreenToVector(pix);

  camAng := VectorAngleCosine(targ, vec);
  wrpdst := dst / camAng;
  rayhit := cam;
  CombineVector(rayhit, vec, wrpdst);
  result := rayhit;
end;

// ClearBuffers
//

procedure TGLSceneBuffer.ClearBuffers;
var
  bufferBits: GLbitfield;
begin
  if roNoDepthBufferClear in ContextOptions then
    bufferBits := 0
  else
  begin
    bufferBits := GL_DEPTH_BUFFER_BIT;
    CurrentVKContext.VKStates.DepthWriteMask := Byte(True);
  end;
  if ContextOptions * [roNoColorBuffer, roNoColorBufferClear] = [] then
  begin
    bufferBits := bufferBits or GL_COLOR_BUFFER_BIT;
    CurrentVKContext.VKStates.SetColorMask(cAllColorComponents);
  end;
  if roStencilBuffer in ContextOptions then
  begin
    bufferBits := bufferBits or GL_STENCIL_BUFFER_BIT;
  end;
  glClear(BufferBits);
end;

// NotifyChange
//

procedure TGLSceneBuffer.NotifyChange(Sender: TObject);
begin
  DoChange;
end;

// PickObjects
//

procedure TGLSceneBuffer.PickObjects(const rect: TGLRect; pickList: TGLPickList;
  objectCountGuess: Integer);
var
  I: Integer;
  obj: TGLBaseSceneObject;
begin
  if not Assigned(FCamera) then
    Exit;
  Assert((not FRendering), strAlreadyRendering);
  Assert(Assigned(PickList));
  FRenderingContext.Activate;
  FRendering := True;
  try
    // Create best selector which techniques is hardware can do
    if not Assigned(FSelector) then
      FSelector := GetBestSelectorClass.Create;

    xgl.MapTexCoordToNull; // turn off
    PrepareRenderingMatrices(FViewPort, RenderDPI, @Rect);
    FSelector.Hits := -1;
    if objectCountGuess > 0 then
      FSelector.ObjectCountGuess := objectCountGuess;
    repeat
      FSelector.Start;
      // render the scene (in select mode, nothing is drawn)
      FRenderDPI := 96;
      if Assigned(FCamera) and Assigned(FCamera.FScene) then
        RenderScene(FCamera.FScene, FViewPort.Width, FViewPort.Height,
          dsPicking, nil);
    until FSelector.Stop;
    FSelector.FillPickingList(PickList);
    for I := 0 to PickList.Count-1 do
    begin
      obj := TGLBaseSceneObject(PickList[I]);
      if Assigned(obj.FOnPicked) then
        obj.FOnPicked(obj);
    end;
  finally
    FRendering := False;
    FRenderingContext.Deactivate;
  end;
end;

// GetPickedObjects
//

function TGLSceneBuffer.GetPickedObjects(const rect: TGLRect; objectCountGuess:
  Integer = 64): TGLPickList;
begin
  Result := TGLPickList.Create(psMinDepth);
  PickObjects(Rect, Result, objectCountGuess);
end;

// GetPickedObject
//

function TGLSceneBuffer.GetPickedObject(x, y: Integer): TGLBaseSceneObject;
var
  pkList: TGLPickList;
begin
  pkList := GetPickedObjects(Rect(x - 1, y - 1, x + 1, y + 1));
  try
    if pkList.Count > 0 then
      Result := TGLBaseSceneObject(pkList.Hit[0])
    else
      Result := nil;
  finally
    pkList.Free;
  end;
end;

// GetPixelColor
//

function TGLSceneBuffer.GetPixelColor(x, y: Integer): TColor;
var
  buf: array[0..2] of Byte;
begin
  if not Assigned(FCamera) then
  begin
    Result := 0;
    Exit;
  end;
  FRenderingContext.Activate;
  try
    glReadPixels(x, FViewPort.Height - y, 1, 1, GL_RGB, GL_UNSIGNED_BYTE,
      @buf[0]);
  finally
    FRenderingContext.Deactivate;
  end;
  Result := RGB(buf[0], buf[1], buf[2]);
end;

// GetPixelDepth
//

function TGLSceneBuffer.GetPixelDepth(x, y: Integer): Single;
begin
  if not Assigned(FCamera) then
  begin
    Result := 0;
    Exit;
  end;
  FRenderingContext.Activate;
  try
    glReadPixels(x, FViewPort.Height - y, 1, 1, GL_DEPTH_COMPONENT, GL_FLOAT,
      @Result);
  finally
    FRenderingContext.Deactivate;
  end;
end;

// PixelDepthToDistance
//

function TGLSceneBuffer.PixelDepthToDistance(aDepth: Single): Single;
var
  dov, np, fp: Single;
begin
  if Camera.CameraStyle = csOrtho2D then
    dov := 2
  else
    dov := Camera.DepthOfView; // Depth of View (from np to fp)
  np := Camera.NearPlane; // Near plane distance
  fp := np + dov; // Far plane distance
  Result := (fp * np) / (fp - aDepth * dov);
  // calculate world distance from z-buffer value
end;

// PixelToDistance
//

function TGLSceneBuffer.PixelToDistance(x, y: integer): Single;
var
  z, dov, np, fp, dst, camAng: Single;
  norm, coord, vec: TAffineVector;
begin
  z := GetPixelDepth(x, y);
  if Camera.CameraStyle = csOrtho2D then
    dov := 2
  else
    dov := Camera.DepthOfView; // Depth of View (from np to fp)
  np := Camera.NearPlane; // Near plane distance
  fp := np + dov; // Far plane distance
  dst := (np * fp) / (fp - z * dov);
  //calculate from z-buffer value to frustrum depth
  coord.X := x;
  coord.Y := y;
  vec := self.ScreenToVector(coord); //get the pixel vector
  coord.X := FViewPort.Width div 2;
  coord.Y := FViewPort.Height div 2;
  norm := self.ScreenToVector(coord); //get the absolute camera direction
  camAng := VectorAngleCosine(norm, vec);
  Result := dst / camAng; //compensate for flat frustrum face
end;

// NotifyMouseMove
//

procedure TGLSceneBuffer.NotifyMouseMove(Shift: TShiftState; X, Y: Single);
begin
  // Nothing
end;

// PrepareRenderingMatrices
//

procedure TGLSceneBuffer.PrepareRenderingMatrices(const aViewPort: TRectangle;
  resolution: Integer; pickingRect: PGLRect = nil);
begin
  RenderingContext.PipelineTransformation.IdentityAll;
  // setup projection matrix
  if Assigned(pickingRect) then
  begin
    CurrentVKContext.PipelineTransformation.ProjectionMatrix := CreatePickMatrix(
      (pickingRect^.Left + pickingRect^.Right) div 2,
      FViewPort.Height - ((pickingRect^.Top + pickingRect^.Bottom) div 2),
      Abs(pickingRect^.Right - pickingRect^.Left),
      Abs(pickingRect^.Bottom - pickingRect^.Top),
      TVector4i(FViewport));
  end;
  FBaseProjectionMatrix := CurrentVKContext.PipelineTransformation.ProjectionMatrix;

  if Assigned(FCamera) then
  begin
    FCamera.Scene.FCurrentCamera := FCamera;
    // apply camera perpective
    FCamera.ApplyPerspective(
      aViewport,
      FViewPort.Width,
      FViewPort.Height,
      resolution);
    // setup model view matrix
    // apply camera transformation (viewpoint)
    FCamera.Apply;
    FCameraAbsolutePosition := FCamera.AbsolutePosition;
  end;
end;

// DoBaseRender
//

procedure TGLSceneBuffer.DoBaseRender(const aViewPort: TRectangle; resolution:
  Integer;
  drawState: TDrawState; baseObject: TGLBaseSceneObject);
begin
  with RenderingContext.VKStates do
  begin
    PrepareRenderingMatrices(aViewPort, resolution);
    if not ForwardContext then
    begin
      xgl.MapTexCoordToNull; // force XGL rebind
      xgl.MapTexCoordToMain;
    end;

    if Assigned(FViewerBeforeRender) and (drawState <> dsPrinting) then
      FViewerBeforeRender(Self);
    if Assigned(FBeforeRender) then
      if Owner is TComponent then
        if not (csDesigning in TComponent(Owner).ComponentState) then
          FBeforeRender(Self);

    if Assigned(FCamera) and Assigned(FCamera.FScene) then
    begin
      with FCamera.FScene do
      begin
        SetupLights(MaxLights);
        if not ForwardContext then
        begin
          if FogEnable then
          begin
            Enable(stFog);
            FogEnvironment.ApplyFog;
          end
          else
            Disable(stFog);
        end;

        RenderScene(FCamera.FScene, aViewPort.Width, aViewPort.Height,
          drawState,
          baseObject);
      end;
    end;
    if Assigned(FPostRender) then
      if Owner is TComponent then
        if not (csDesigning in TComponent(Owner).ComponentState) then
          FPostRender(Self);
  end;
  Assert(Length(FViewMatrixStack) = 0,
    'Unbalance Push/PopViewMatrix.');
  Assert(Length(FProjectionMatrixStack) = 0,
    'Unbalance Push/PopProjectionMatrix.');
end;

// Render
//

procedure TGLSceneBuffer.Render;
begin
  Render(nil);
end;

// Render
//

procedure TGLSceneBuffer.Render(baseObject: TGLBaseSceneObject);
var
  perfCounter, framePerf: Int64;

begin
  if FRendering then
    Exit;
  if not Assigned(FRenderingContext) then
    Exit;

  if Freezed and (FFreezeBuffer <> nil) then
  begin
    RenderingContext.Activate;
    try
      RenderingContext.VKStates.ColorClearValue :=
        ConvertWinColor(FBackgroundColor, FBackgroundAlpha);
      ClearBuffers;
      glMatrixMode(GL_PROJECTION);
      glLoadIdentity;
      glMatrixMode(GL_MODELVIEW);
      glLoadIdentity;
      glRasterPos2f(-1, -1);
      glDrawPixels(FFreezedViewPort.Width, FFreezedViewPort.Height,
        GL_RGBA, GL_UNSIGNED_BYTE, FFreezeBuffer);
      if not (roNoSwapBuffers in ContextOptions) then
        RenderingContext.SwapBuffers;
    finally
      RenderingContext.Deactivate;
    end;
    Exit;
  end;

  QueryPerformanceCounter(framePerf);

  if Assigned(FCamera) and Assigned(FCamera.FScene) then
  begin
    FCamera.AbsoluteMatrixAsAddress;
    FCamera.FScene.AddBuffer(Self);
  end;

  FRendering := True;
  try
    FRenderingContext.Activate;
    try
      if FFrameCount = 0 then
        QueryPerformanceCounter(FFirstPerfCounter);

      FRenderDPI := 96; // default value for screen
      ClearOpenGLError;
      SetupRenderingContext(FRenderingContext);
      // clear the buffers
      FRenderingContext.VKStates.ColorClearValue :=
        ConvertWinColor(FBackgroundColor, FBackgroundAlpha);
      ClearBuffers;
      // render
      DoBaseRender(FViewport, RenderDPI, dsRendering, baseObject);

      if not (roNoSwapBuffers in ContextOptions) then
        RenderingContext.SwapBuffers;

      // yes, calculate average frames per second...
      Inc(FFrameCount);
      QueryPerformanceCounter(perfCounter);
      FLastFrameTime := (perfCounter - framePerf) / vCounterFrequency;
      Dec(perfCounter, FFirstPerfCounter);
      if perfCounter > 0 then
        FFramesPerSecond := (FFrameCount * vCounterFrequency) / perfCounter;
      CheckOpenGLError;
    finally
      FRenderingContext.Deactivate;
    end;
    if Assigned(FAfterRender) and (Owner is TComponent) then
      if not (csDesigning in TComponent(Owner).ComponentState) then
        FAfterRender(Self);
  finally
    FRendering := False;
  end;
end;

// RenderScene
//

procedure TGLSceneBuffer.RenderScene(aScene: TGLScene;
  const viewPortSizeX, viewPortSizeY: Integer;
  drawState: TDrawState;
  baseObject: TGLBaseSceneObject);

var
  i: Integer;
  rci: TGLRenderContextInfo;
  rightVector: TVector;
begin
  FAfterRenderEffects.Clear;
  aScene.FCurrentBuffer := Self;
  FillChar(rci, SizeOf(rci), 0);
  rci.scene := aScene;
  rci.buffer := Self;
  rci.afterRenderEffects := FAfterRenderEffects;
  rci.objectsSorting := aScene.ObjectsSorting;
  rci.visibilityCulling := aScene.VisibilityCulling;
  rci.bufferFaceCull := FFaceCulling;
  rci.bufferLighting := FLighting;
  rci.bufferFog := FFogEnable;
  rci.bufferDepthTest := FDepthTest;
  rci.drawState := drawState;
  rci.sceneAmbientColor := FAmbientColor.Color;
  rci.primitiveMask := cAllMeshPrimitive;
  with FCamera do
  begin
    rci.cameraPosition := FCameraAbsolutePosition;
    rci.cameraDirection := FLastDirection;
    NormalizeVector(rci.cameraDirection);
    rci.cameraDirection.W := 0;
    rightVector := VectorCrossProduct(rci.cameraDirection, Up.AsVector);
    rci.cameraUp := VectorCrossProduct(rightVector, rci.cameraDirection);
    NormalizeVector(rci.cameraUp);

    with rci.rcci do
    begin
      origin := rci.cameraPosition;
      clippingDirection := rci.cameraDirection;
      viewPortRadius := FViewPortRadius;
      nearClippingDistance := FNearPlane;
      farClippingDistance := FNearPlane + FDepthOfView;
      frustum := RenderingContext.PipelineTransformation.Frustum;
    end;
  end;
  rci.viewPortSize.cx := viewPortSizeX;
  rci.viewPortSize.cy := viewPortSizeY;
  rci.renderDPI := FRenderDPI;
  rci.VKStates := RenderingContext.VKStates;
  rci.PipelineTransformation := RenderingContext.PipelineTransformation;
  rci.proxySubObject := False;
  rci.ignoreMaterials := (roNoColorBuffer in FContextOptions)
    or (rci.drawState = dsPicking);
  rci.amalgamating := rci.drawState = dsPicking;
  rci.VKStates.SetColorWriting(not rci.ignoreMaterials);
  if Assigned(FInitiateRendering) then
    FInitiateRendering(Self, rci);

  if aScene.InitializableObjects.Count <> 0 then
  begin
    // First initialize all objects and delete them from the list.
    for I := aScene.InitializableObjects.Count - 1 downto 0 do
    begin
      aScene.InitializableObjects.Items[I].InitializeObject({Self?}aScene, rci);
      aScene.InitializableObjects.Delete(I);
    end;
  end;

  if RenderingContext.IsPraparationNeed then
    RenderingContext.PrepareHandlesData;

  if baseObject = nil then
  begin
    aScene.Objects.Render(rci);
  end
  else
    baseObject.Render(rci);
  rci.VKStates.SetColorWriting(True);
  with FAfterRenderEffects do
    if Count > 0 then
      for i := 0 to Count - 1 do
        TGLObjectAfterEffect(Items[i]).Render(rci);
  if Assigned(FWrapUpRendering) then
    FWrapUpRendering(Self, rci);
end;

// SetBackgroundColor
//

procedure TGLSceneBuffer.SetBackgroundColor(AColor: TColor);
begin
  if FBackgroundColor <> AColor then
  begin
    FBackgroundColor := AColor;
    NotifyChange(Self);
  end;
end;

// SetBackgroundAlpha
//

procedure TGLSceneBuffer.SetBackgroundAlpha(alpha: Single);
begin
  if FBackgroundAlpha <> alpha then
  begin
    FBackgroundAlpha := alpha;
    NotifyChange(Self);
  end;
end;

// SetAmbientColor
//

procedure TGLSceneBuffer.SetAmbientColor(AColor: TGLColor);
begin
  FAmbientColor.Assign(AColor);
end;

// SetCamera
//

procedure TGLSceneBuffer.SetCamera(ACamera: TGLCamera);
begin
  if FCamera <> ACamera then
  begin
    if Assigned(FCamera) then
    begin
      if Assigned(FCamera.FScene) then
        FCamera.FScene.RemoveBuffer(Self);
      FCamera := nil;
    end;
    if Assigned(ACamera) and Assigned(ACamera.FScene) then
    begin
      FCamera := ACamera;
      FCamera.TransformationChanged;
    end;
    NotifyChange(Self);
  end;
end;

// SetContextOptions
//

procedure TGLSceneBuffer.SetContextOptions(Options: TContextOptions);
begin
  if FContextOptions <> Options then
  begin
    FContextOptions := Options;
    DoStructuralChange;
  end;
end;

// SetDepthTest
//

procedure TGLSceneBuffer.SetDepthTest(AValue: Boolean);
begin
  if FDepthTest <> AValue then
  begin
    FDepthTest := AValue;
    NotifyChange(Self);
  end;
end;

// SetFaceCulling
//

procedure TGLSceneBuffer.SetFaceCulling(AValue: Boolean);
begin
  if FFaceCulling <> AValue then
  begin
    FFaceCulling := AValue;
    NotifyChange(Self);
  end;
end;

procedure TGLSceneBuffer.SetLayer(const Value: TGLContextLayer);
begin
  if FLayer <> Value then
  begin
    FLayer := Value;
    DoStructuralChange;
  end;
end;

procedure TGLSceneBuffer.SetLighting(aValue: Boolean);
begin
  if FLighting <> aValue then
  begin
    FLighting := aValue;
    NotifyChange(Self);
  end;
end;

// SetAntiAliasing
//

procedure TGLSceneBuffer.SetAntiAliasing(const val: TGLAntiAliasing);
begin
  if FAntiAliasing <> val then
  begin
    FAntiAliasing := val;
    DoStructuralChange;
  end;
end;

// SetDepthPrecision
//

procedure TGLSceneBuffer.SetDepthPrecision(const val: TGLDepthPrecision);
begin
  if FDepthPrecision <> val then
  begin
    FDepthPrecision := val;
    DoStructuralChange;
  end;
end;

// SetColorDepth
//

procedure TGLSceneBuffer.SetColorDepth(const val: TGLColorDepth);
begin
  if FColorDepth <> val then
  begin
    FColorDepth := val;
    DoStructuralChange;
  end;
end;

// SetShadeModel
//

procedure TGLSceneBuffer.SetShadeModel(const val: TGLShadeModel);
begin
  if FShadeModel <> val then
  begin
    FShadeModel := val;
    NotifyChange(Self);
  end;
end;

// SetFogEnable
//

procedure TGLSceneBuffer.SetFogEnable(AValue: Boolean);
begin
  if FFogEnable <> AValue then
  begin
    FFogEnable := AValue;
    NotifyChange(Self);
  end;
end;

// SetFogEnvironment
//

procedure TGLSceneBuffer.SetFogEnvironment(AValue: TGLFogEnvironment);
begin
  FFogEnvironment.Assign(AValue);
  NotifyChange(Self);
end;

// StoreFog
//

function TGLSceneBuffer.StoreFog: Boolean;
begin
  Result := (not FFogEnvironment.IsAtDefaultValues);
end;

// SetAccumBufferBits
//

procedure TGLSceneBuffer.SetAccumBufferBits(const val: Integer);
begin
  if FAccumBufferBits <> val then
  begin
    FAccumBufferBits := val;
    DoStructuralChange;
  end;
end;

// DoChange
//

procedure TGLSceneBuffer.DoChange;
begin
  if (not FRendering) and Assigned(FOnChange) then
    FOnChange(Self);
end;

// DoStructuralChange
//

procedure TGLSceneBuffer.DoStructuralChange;
var
  bCall: Boolean;
begin
  if Assigned(Owner) then
    bCall := not (csLoading in TComponent(GetOwner).ComponentState)
  else
    bCall := True;
  if bCall and Assigned(FOnStructuralChange) then
    FOnStructuralChange(Self);
end;

// ------------------
// ------------------ TGLNonVisualViewer ------------------
// ------------------

// Create
//

constructor TGLNonVisualViewer.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FWidth := 256;
  FHeight := 256;
  FBuffer := TGLSceneBuffer.Create(Self);
  FBuffer.OnChange := DoBufferChange;
  FBuffer.OnStructuralChange := DoBufferStructuralChange;
  FBuffer.OnPrepareGLContext := DoOnPrepareGLContext;
end;

// Destroy
//

destructor TGLNonVisualViewer.Destroy;
begin
  FBuffer.Free;
  inherited Destroy;
end;

// Notification
//

procedure TGLNonVisualViewer.Notification(AComponent: TComponent; Operation:
  TOperation);
begin
  if (Operation = opRemove) and (AComponent = Camera) then
    Camera := nil;
  inherited;
end;

// CopyToTexture
//

procedure TGLNonVisualViewer.CopyToTexture(aTexture: TGLTexture);
begin
  CopyToTexture(aTexture, 0, 0, Width, Height, 0, 0);
end;

// CopyToTexture
//

procedure TGLNonVisualViewer.CopyToTexture(aTexture: TGLTexture;
  xSrc, ySrc, width, height: Integer;
  xDest, yDest: Integer);
begin
  Buffer.CopyToTexture(aTexture, xSrc, ySrc, width, height, xDest, yDest);
end;

// CopyToTextureMRT
//

procedure TGLNonVisualViewer.CopyToTextureMRT(aTexture: TGLTexture;
  BufferIndex: integer);
begin
  CopyToTextureMRT(aTexture, 0, 0, Width, Height, 0, 0, BufferIndex);
end;

// CopyToTextureMRT
//

procedure TGLNonVisualViewer.CopyToTextureMRT(aTexture: TGLTexture; xSrc,
  ySrc, width, height, xDest, yDest, BufferIndex: integer);
var
  target, handle: Integer;
  buf: Pointer;
  createTexture: Boolean;

  procedure CreateNewTexture;
  begin
    GetMem(buf, Width * Height * 4);
    try // float_type
      glReadPixels(0, 0, Width, Height, GL_RGBA, GL_UNSIGNED_BYTE, buf);
      case aTexture.MinFilter of
        miNearest, miLinear:
          glTexImage2d(target, 0, aTexture.VulkanTextureFormat, Width, Height,
            0, GL_RGBA, GL_UNSIGNED_BYTE, buf);
      else
        if GL_SGIS_generate_mipmap and (target = GL_TEXTURE_2D) then
        begin
          // hardware-accelerated when supported
          glTexParameteri(target, GL_GENERATE_MIPMAP_SGIS, GL_TRUE);
          glTexImage2d(target, 0, aTexture.VulkanTextureFormat, Width, Height,
            0, GL_RGBA, GL_UNSIGNED_BYTE, buf);
        end
        else
        begin
          glTexImage2d(target, 0, aTexture.VulkanTextureFormat, Width, Height,
            0, GL_RGBA, GL_UNSIGNED_BYTE, buf);
          glGenerateMipmap(target);
        end;
      end;
    finally
      FreeMem(buf);
    end;
  end;

begin
  if Buffer.RenderingContext <> nil then
  begin
    Buffer.RenderingContext.Activate;
    try
      target := DecodeTextureTarget(aTexture.Image.NativeTextureTarget);

      CreateTexture := true;

      if aTexture.IsFloatType then
      begin // float_type special treatment
        CreateTexture := false;
        handle := aTexture.Handle;
      end
      else if (target <> GL_TEXTURE_CUBE_MAP_ARB) or (FCubeMapRotIdx = 0) then
      begin
        CreateTexture := not aTexture.IsHandleAllocated;
        if CreateTexture then
          handle := aTexture.AllocateHandle
        else
          handle := aTexture.Handle;
      end
      else
        handle := aTexture.Handle;

      // For MRT
      glReadBuffer(MRT_BUFFERS[BufferIndex]);

      Buffer.RenderingContext.VKStates.TextureBinding[0,
        EncodeTextureTarget(target)] := handle;

      if target = GL_TEXTURE_CUBE_MAP_ARB then
        target := GL_TEXTURE_CUBE_MAP_POSITIVE_X_ARB + FCubeMapRotIdx;

      if CreateTexture then
        CreateNewTexture
      else
        glCopyTexSubImage2D(target, 0, xDest, yDest, xSrc, ySrc, Width, Height);

      ClearOpenGLError;
    finally
      Buffer.RenderingContext.Deactivate;
    end;
  end;
end;

// SetupCubeMapCamera
//

procedure TGLNonVisualViewer.SetupCubeMapCamera(Sender: TObject);

const
  cFaceMat: array[0..5] of TMatrix =
  (
    (X: (X:0; Y:0; Z:-1; W:0);
     Y: (X:0; Y:-1; Z:0; W:0);
     Z: (X:-1; Y:0; Z:0; W:0);
     W: (X:0; Y:0; Z:0; W:1)),
    (X:(X:2.4335928828e-08; Y:0; Z:1; W:0);
     Y:(X:0; Y:-1; Z:0; W:0);
     Z:(X:1; Y:0; Z:-2.4335928828e-08; W:0);
     W:(X:0; Y:0; Z:0; W:1)),
    (X:(X:1; Y:1.2167964414e-08; Z:-1.4805936071e-16; W:0);
     Y:(X:0; Y:-1.2167964414e-08; Z:-1; W:0);
     Z:(X:-1.2167964414e-08; Y:1; Z:-1.2167964414e-08; W:0);
     W:(X:0; Y:0; Z:0; W:1)),
    (X:(X:1; Y:-1.2167964414e-08; Z:-1.4805936071e-16; W:0);
     Y:(X:0; Y:-1.2167964414e-08; Z:1; W:0);
     Z:(X:-1.2167964414e-08; Y:-1; Z:-1.2167964414e-08; W:0);
     W:(X:0; Y:0; Z:0; W:1)),
    (X:(X:1; Y:0; Z:-1.2167964414e-08; W:0);
     Y:(X:0; Y:-1; Z:0; W:0);
     Z:(X:-1.2167964414e-08; Y:0; Z:-1; W:0);
     W:(X:0; Y:0; Z:0; W:1)),
    (X:(X:-1; Y:0; Z:-1.2167964414e-08; W:0);
     Y:(X:0; Y:-1; Z:0; W:0);
     Z:(X:-1.2167964414e-08; Y:0; Z:1; W:0);
     W:(X:0; Y:0; Z:0; W:1))
  );

var
  TM: TMatrix;
begin
  // Setup appropriate FOV
  with CurrentVKContext.PipelineTransformation do
  begin
    ProjectionMatrix := CreatePerspectiveMatrix(90, 1, FCubeMapZNear, FCubeMapZFar);
    TM := CreateTranslationMatrix(FCubeMapTranslation);
    ViewMatrix := MatrixMultiply(cFaceMat[FCubeMapRotIdx], TM);
  end;
end;

// RenderTextures
//

procedure TGLNonVisualViewer.RenderCubeMapTextures(cubeMapTexture: TGLTexture;
  zNear: Single = 0;
  zFar: Single = 0);
var
  oldEvent: TNotifyEvent;
begin
  Assert((Width = Height), 'Memory Viewer must render to a square!');
  Assert(Assigned(FBuffer.FCamera), 'Camera not specified');
  Assert(Assigned(cubeMapTexture), 'Texture not specified');

  if zFar <= 0 then
    zFar := FBuffer.FCamera.DepthOfView;
  if zNear <= 0 then
    zNear := zFar * 0.001;

  oldEvent := FBuffer.FCamera.FDeferredApply;
  FBuffer.FCamera.FDeferredApply := SetupCubeMapCamera;
  FCubeMapZNear := zNear;
  FCubeMapZFar := zFar;
  VectorScale(FBuffer.FCamera.AbsolutePosition, -1, FCubeMapTranslation);
  try
    FCubeMapRotIdx := 0;
    while FCubeMapRotIdx < 6 do
    begin
      Render;
      Buffer.CopyToTexture(cubeMapTexture, 0, 0, Width, Height, 0, 0,
        GL_TEXTURE_CUBE_MAP_POSITIVE_X + FCubeMapRotIdx);
      Inc(FCubeMapRotIdx);
    end;
  finally
    FBuffer.FCamera.FDeferredApply := oldEvent;
  end;
end;

// SetBeforeRender
//

procedure TGLNonVisualViewer.SetBeforeRender(const val: TNotifyEvent);
begin
  FBuffer.BeforeRender := val;
end;

// GetBeforeRender
//

function TGLNonVisualViewer.GetBeforeRender: TNotifyEvent;
begin
  Result := FBuffer.BeforeRender;
end;

// SetPostRender
//

procedure TGLNonVisualViewer.SetPostRender(const val: TNotifyEvent);
begin
  FBuffer.PostRender := val;
end;

// GetPostRender
//

function TGLNonVisualViewer.GetPostRender: TNotifyEvent;
begin
  Result := FBuffer.PostRender;
end;

// SetAfterRender
//

procedure TGLNonVisualViewer.SetAfterRender(const val: TNotifyEvent);
begin
  FBuffer.AfterRender := val;
end;

// GetAfterRender
//

function TGLNonVisualViewer.GetAfterRender: TNotifyEvent;
begin
  Result := FBuffer.AfterRender;
end;

// SetCamera
//

procedure TGLNonVisualViewer.SetCamera(const val: TGLCamera);
begin
  FBuffer.Camera := val;
end;

// GetCamera
//

function TGLNonVisualViewer.GetCamera: TGLCamera;
begin
  Result := FBuffer.Camera;
end;

// SetBuffer
//

procedure TGLNonVisualViewer.SetBuffer(const val: TGLSceneBuffer);
begin
  FBuffer.Assign(val);
end;

// DoOnPrepareGLContext
//

procedure TGLNonVisualViewer.DoOnPrepareGLContext(sender: TObject);
begin
  PrepareGLContext;
end;

// PrepareGLContext
//

procedure TGLNonVisualViewer.PrepareGLContext;
begin
  // nothing, reserved for subclasses
end;

// DoBufferChange
//

procedure TGLNonVisualViewer.DoBufferChange(Sender: TObject);
begin
  // nothing, reserved for subclasses
end;

// DoBufferStructuralChange
//

procedure TGLNonVisualViewer.DoBufferStructuralChange(Sender: TObject);
begin
  FBuffer.DestroyRC;
end;

// SetWidth
//

procedure TGLNonVisualViewer.SetWidth(const val: Integer);
begin
  if val <> FWidth then
  begin
    FWidth := val;
    if FWidth < 1 then
      FWidth := 1;
    DoBufferStructuralChange(Self);
  end;
end;

// SetHeight
//

procedure TGLNonVisualViewer.SetHeight(const val: Integer);
begin
  if val <> FHeight then
  begin
    FHeight := val;
    if FHeight < 1 then
      FHeight := 1;
    DoBufferStructuralChange(Self);
  end;
end;

// ------------------
// ------------------ TGLMemoryViewer ------------------
// ------------------

// Create
//

constructor TGLMemoryViewer.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Width := 256;
  Height := 256;
  FBufferCount := 1;
end;

// InstantiateRenderingContext
//

procedure TGLMemoryViewer.InstantiateRenderingContext;
begin
  if FBuffer.RenderingContext = nil then
  begin
    FBuffer.SetViewPort(0, 0, Width, Height);
    FBuffer.CreateRC(HWND(0), True, FBufferCount);
  end;
end;

// Render
//

procedure TGLMemoryViewer.Render(baseObject: TGLBaseSceneObject = nil);
begin
  InstantiateRenderingContext;
  FBuffer.Render(baseObject);
end;

// SetBufferCount
//

procedure TGLMemoryViewer.SetBufferCount(const Value: integer);
//var
//   MaxAxuBufCount : integer;
const
  MaxAxuBufCount = 4; // Current hardware limit = 4
begin
  if FBufferCount = Value then
    exit;
  FBufferCount := Value;

  if FBufferCount < 1 then
    FBufferCount := 1;

  if FBufferCount > MaxAxuBufCount then
    FBufferCount := MaxAxuBufCount;

  // Request a new Instantiation of RC on next render
  FBuffer.DestroyRC;
end;

// ------------------
// ------------------ TGLInitializableObjectList ------------------
// ------------------

// Add
//

function TGLInitializableObjectList.Add(const Item: IGLInitializable): Integer;
begin
  Result := inherited Add(Pointer(Item));
end;

// GetItems
//

function TGLInitializableObjectList.GetItems(
  const Index: Integer): IGLInitializable;
begin
  Result := IGLInitializable(inherited Get(Index));
end;

// PutItems
//

procedure TGLInitializableObjectList.PutItems(const Index: Integer;
  const Value: IGLInitializable);
begin
  inherited Put(Index, Pointer(Value));
end;

//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
initialization
  //------------------------------------------------------------------------------
  //------------------------------------------------------------------------------
  //------------------------------------------------------------------------------

  RegisterClasses([TGLLightSource, TGLCamera, TGLProxyObject,
    TGLScene, TGLDirectVulkan, TGLRenderPoint,
      TGLMemoryViewer]);

  // preparation for high resolution timer
  QueryPerformanceFrequency(vCounterFrequency);

end.
