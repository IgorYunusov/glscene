//
// This unit is part of the GLScene Project, http://glscene.org
//
{ : GLGizmo<p>

  Invisible component for helping to Move, Rotate and Scale an Object
  under GLScene (usefull for an Editor).<p>

  <b>History : </b><font size=-1><ul>
  <li>21/06/11 - Yar - Transition to indirect rendering objects
  <li>22/04/10 - Yar - Fixes after GLState revision
  <li>14/07/09 - DaStr - Bugfixed object selection from code (thanks Predator)
  <li>20/01/08 - DaStr - Cleaned up uses section for proper FPC support
  (thanks Lukasz Sokol)
  <li>18/09/07 - DaStr - Initial version (based on GLGizmo.pas by Adirex,
  J.Delauney, Degiovani, Marcus Oblak and a bit myself)
  </ul></font>
}
//
// Original Header:
//
// ------------------------------------------------------------------------------
// Unit : GLGizmo  RC 1.0
// ------------------------------------------------------------------------------
// Original Author : ???????  (glGizmo In an ODEEditor)
// ------------------------------------------------------------------------------
// Modified by     : J.Delauney
// Web Site        : http://KheopsInteractive.cjb.net
// EMail           : wmkheops@free.fr
// Date            : 08/05/2005
//
// Modified by     : Marcus Oblak (8/3/2007)
// - Corrected moving/rotating for children objects
// - Better quantization for mouse operations (MoveCoef,RotationCoef)
// - Added ScaleCoef
// - Added GizmoThickness
//
// If you make some changes, please send your new version. Thanks
// ------------------------------------------------------------------------------
// Description :
// Invisible component for helping to Move, Rotate and Scale an Object
// under GLScene (usefull for an Editor)
// ------------------------------------------------------------------------------
// Features :
// - Interaction When All Gizmo parts are Invisible
// - Add "gpMoveGizmo and  gpRotateGizmo" operations and use Like a "Pivot"
// or use RootGizmo As "Pivot"
// - Add Interactive Camera Movements
// - Adding Extended Controls with Keys
// - Maybe An Undo Function
// - Others Ideas ???
// ------------------------------------------------------------------------------
// Bugs Known :
// - When you change the BoundingBoxColor and LabelInfosColor
// The New Color is not Updated immediately, only after a new Click
// (see in UpdateGizmo, SetBoundingBoxColor
// and SetLabelInfosColor Procedures)
// -  DaStr: Bounding Box is not alway drawn correctly because it does not
// use objects' BarryCenter. For Example, if you select Space Text.
// ------------------------------------------------------------------------------

unit GLScene_Gizmo;

interface

{$I GLScene.inc}

uses
  // Standard
  Classes,
  SysUtils,

  // GLScene_Core
  GLScene_Base_PersistentClasses,
  GLScene_Core,
  GLScene_Base_Color,
  GLScene_Objects,
  GLScene_Base_Vector_Geometry,
  GLScene_Material,
  GLScene_MaterialEx,
  GLScene_Base_Strings,
  GLScene_ObjectsEx,
  GLScene_BitmapFont,
  GLScene_Viewer,
  GLScene_Objects_VectorFile,
  GLScene_Platform,
  GLScene_Base_Coordinates,
  GLScene_Base_Context_Info,
  GLScene_Base_GLStateMachine
{$IFDEF GLS_DELPHI},
  GLScene_Base_Vector_Types{$ENDIF};

type
  TGLGizmoUndoCollection = class;
  TGLGizmo = class;

  TGLGizmoUndoItem = class(TCollectionItem)
  private
    FOldLibMaterialName: string;
    FOldAutoScaling: TGLCoordinates;
    FEffectedObject: TGLCustomSceneObject;
    FOldMatr: TMatrix;
    FOldMatrix: TMatrix;
    procedure SetEffectedObject(const Value: TGLCustomSceneObject);
    procedure SetOldAutoScaling(const Value: TGLCoordinates);
    procedure SetOldMatrix(const Value: TMatrix);
  protected
    procedure DoUndo; virtual;
    function GetParent: TGLGizmoUndoCollection;
    function GetGizmo: TGLGizmo;
  public
    constructor Create(AOwner: TCollection); override;
    destructor Destroy; override;
    procedure Notification(AComponent: TComponent;
      Operation: TOperation); virtual;
    procedure AssignFromObject(const AObject: TGLCustomSceneObject);

    // TODO: create a special type for Matrix.
    property OldMatrix: TMatrix read FOldMatrix write SetOldMatrix;
  published
    property EffectedObject: TGLCustomSceneObject read FEffectedObject
      write SetEffectedObject;
    property OldAutoScaling: TGLCoordinates read FOldAutoScaling
      write SetOldAutoScaling;
    property OldLibMaterialName: string read FOldLibMaterialName
      write FOldLibMaterialName;
  end;

  TGLGizmoUndoCollection = class(TOwnedCollection)
  private
    function GetItems(const Index: Integer): TGLGizmoUndoItem;
    procedure SetItems(const Index: Integer; const Value: TGLGizmoUndoItem);
  protected
    function GetParent: TGLGizmo;
  public
    procedure Notification(AComponent: TComponent; Operation: TOperation);
    procedure RemoveByObject(const AObject: TGLCustomSceneObject);
    function Add: TGLGizmoUndoItem;
    property Items[const Index: Integer]: TGLGizmoUndoItem read GetItems
      write SetItems; default;
  end;

  TGLGizmoElement = (geMove, geRotate, geScale, geAxisLabel, geObjectInfos,
    geBoundingBox);
  TGLGizmoElements = set of TGLGizmoElement;

  TGLGizmoVisibleInfoLabel = (vliName, vliOperation, vliCoords);
  TGLGizmoVisibleInfoLabels = set of TGLGizmoVisibleInfoLabel;

  TGLGizmoAxis = (gaNone, gaX, gaY, gaZ, gaXY, gaXZ, gaYZ);

  TGLGizmoOperation = (gopMove, gopRotate, gopScale, gopNone, gpMoveGizmo,
    gpRotateGizmo);

  TGLGizmoAcceptEvent = procedure(Sender: TObject; var obj: TGLBaseSceneObject;
    var accept: Boolean; var dimensions: TVector) of object;
  TGLGizmoUpdateEvent = procedure(Sender: TObject; obj: TGLBaseSceneObject;
    axis: TGLGizmoAxis; Operation: TGLGizmoOperation; var vector: TVector)
    of object;

  TGLGizmoPickMode = (pmGetPickedObjects, pmRayCast);

  TGLGizmoRayCastHitData = class(TPersistent)
  public
    obj: TGLBaseSceneObject;
    Point: TVector;
  end;

  TGLGizmoPickCube = class(TGLCube)
  end;

  TGLGizmoPickTorus = class(TGLTorus)
  end;

  TGLGizmo = class(TComponent)
  private
    _GZObaseGizmo: TGLBaseSceneObject;

    _GZOBoundingcube: TGLCube;

    _GZOrootHelpers: TGLBaseSceneObject;
    _GZOrootLines: TGLBaseSceneObject;
    _GZOrootTorus: TGLBaseSceneObject;
    _GZOrootCubes: TGLBaseSceneObject;
    _GZORootAxisLabel: TGLBaseSceneObject;
    _GZORootVisibleInfoLabels: TGLBaseSceneObject;

    _GZOlineX, _GZOlineY, _GZOlineZ, _GZOplaneXY, _GZOplaneXZ,
      _GZOplaneYZ: TGLLines; // For Move
    _GZOTorusX, _GZOTorusY, _GZOTorusZ: TGLGizmoPickTorus; // For Rotate
    _GZOCubeX, _GZOCubeY, _GZOCubeZ: TGLGizmoPickCube; // For Scale

    _GZOAxisLabelX, _GZOAxisLabelY, _GZOAxisLabelZ: TGLFlatText;
    _GZOVisibleInfoLabels: TGLFlatText;

    FPickingMaterial: TGLLibMaterialEx;

    FRootGizmo: TGLBaseSceneObject;
    FSelectedObj: TGLBaseSceneObject;
    // FLastOperation,
    FOperation: TGLGizmoOperation;
    FSelAxis: TGLGizmoAxis;

    FBoundingBoxColor: TGLColor;
    FSelectedColor: TGLColor;
    FVisibleInfoLabelsColor: TGLColor;

    FBoundingBoxColorChanged: Boolean;
    FVisibleInfoLabelsColorChanged: Boolean;

    FForceOperation: Boolean;
    FForceAxis: Boolean;
    FForceUniformScale: Boolean;
    FAutoZoom: Boolean;
    FExcludeObjects: Boolean;
    FNoZWrite: Boolean;
    FEnabled: Boolean;

    FAutoZoomFactor: Single;
    FZoomFactor: Single;
    FMoveCoef: Single;
    FRotationCoef: Single;

    FViewer: TGLSceneViewer;

    FGizmoElements: TGLGizmoElements;
    FVisibleVisibleInfoLabels: TGLGizmoVisibleInfoLabels;

    FExcludeObjectsList: TStrings;

    FMoving: Boolean;
    mx, my: Integer;
    rx, ry: Integer;

    lastMousePos: TVector;
    objDimensions: TVector;

    FOnBeforeSelect: TGLGizmoAcceptEvent;
    FOnBeforeUpdate: TGLGizmoUpdateEvent;
    FOnSelectionLost: TNotifyEvent;
    FScaleCoef: Single;
    FGizmoThickness: Single;
    FPickMode: TGLGizmoPickMode;
    FInternalRaycastHitData: TList;

    FUndoHistory: TGLGizmoUndoCollection;
    FLabelFont: TGLCustomBitmapFont;

    procedure SetRootGizmo(const AValue: TGLBaseSceneObject);

    procedure SetGizmoElements(const AValue: TGLGizmoElements);
    procedure SeTGLGizmoVisibleInfoLabels(const AValue
      : TGLGizmoVisibleInfoLabels);
    procedure SetBoundingBoxColor(const AValue: TGLColor);
    procedure SetSelectedColor(const AValue: TGLColor);
    procedure SetVisibleInfoLabelsColor(const AValue: TGLColor);

    procedure SetExcludeObjectsList(const AValue: TStrings);

    function MouseWorldPos(const X, Y: Integer): TVector;
    function CheckObjectInExcludeList(const obj: TGLBaseSceneObject): Boolean;
    procedure UpdateVisibleInfoLabels;
    procedure SetGLGizmoThickness(const Value: Single);

    function InternalGetPickedObjects(const x1, y1, x2, y2: Integer;
      const guessCount: Integer = 8): TPersistentObjectList;
    procedure ClearInternalRaycastHitData;
    procedure SetViewer(const Value: TGLSceneViewer);
    procedure SetLabelFont(const Value: TGLCustomBitmapFont);
    procedure SetSelectedObj(const Value: TGLBaseSceneObject);
    procedure SetNoZWrite(const Value: Boolean);
  public
    PickableObjectsWithRayCast: TList;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Loaded; override;
    procedure Notification(AComponent: TComponent;
      Operation: TOperation); override;

    procedure ViewerMouseMove(const X, Y: Integer);
    procedure ViewerMouseDown(const X, Y: Integer);
    procedure ViewerMouseUp(const X, Y: Integer);

    procedure UpdateGizmo; overload;
    procedure UpdateGizmo(const newDimensions: TVector); overload;
    procedure SetVisible(const AValue: Boolean);
    function GetPickedObjectPoint(const obj: TGLBaseSceneObject): TVector;

    procedure LooseSelection; virtual;

    procedure UndoAdd(const AObject: TGLCustomSceneObject);
    property RootGizmo: TGLBaseSceneObject read FRootGizmo write SetRootGizmo;

    // --------------------------------------------------------------------
  published

    property Viewer: TGLSceneViewer read FViewer write SetViewer;

    property GizmoElements: TGLGizmoElements read FGizmoElements
      write SetGizmoElements;

    property BoundingBoxColor: TGLColor read FBoundingBoxColor
      write SetBoundingBoxColor;
    property SelectedColor: TGLColor read FSelectedColor write SetSelectedColor;

    property SelAxis: TGLGizmoAxis read FSelAxis write FSelAxis;
    property ForceAxis: Boolean read FForceAxis write FForceAxis;

    property SelectedObj: TGLBaseSceneObject read FSelectedObj
      write SetSelectedObj;

    property Operation: TGLGizmoOperation read FOperation write FOperation;
    property ForceOperation: Boolean read FForceOperation write FForceOperation;
    property ForceUniformScale: Boolean read FForceUniformScale
      write FForceUniformScale;

    property ExcludeObjects: Boolean read FExcludeObjects write FExcludeObjects;
    property ExcludeObjectsList: TStrings read FExcludeObjectsList
      write SetExcludeObjectsList;

    property VisibleInfoLabels: TGLGizmoVisibleInfoLabels
      read FVisibleVisibleInfoLabels write SeTGLGizmoVisibleInfoLabels;
    property VisibleInfoLabelsColor: TGLColor read FVisibleInfoLabelsColor
      write SetVisibleInfoLabelsColor;

    property AutoZoom: Boolean read FAutoZoom write FAutoZoom;
    property AutoZoomFactor: Single read FAutoZoomFactor write FAutoZoomFactor;
    property ZoomFactor: Single read FZoomFactor write FZoomFactor;

    property MoveCoef: Single read FMoveCoef write FMoveCoef;
    property RotationCoef: Single read FRotationCoef write FRotationCoef;
    property ScaleCoef: Single read FScaleCoef write FScaleCoef;
    property NoZWrite: Boolean read FNoZWrite write SetNoZWrite;

    property GizmoThickness: Single read FGizmoThickness
      write SetGLGizmoThickness;

    { : Indicates whether the gizmo is enabled or not.
      WARNING: When loading/editing (possibly whenever a structureChanged
      call is made) a model, sometimes the gizmo will trigger a
      bug if the mouse is inside the glscene Viewer. To prevent that,
      remember to disable the gizmo before loading, then process windows
      messages (i.e. application.processMessage) and then enable the gizmo
      again. }

    { : Warning Enable is ReadOnly property if you set to False, Gizmo is not Hidden
      use Visible instead if you want to Hide, if you want to Hide but keep enabled
      see the VisibleGizmo property }
    property Enabled: Boolean read FEnabled write FEnabled default False;

    property LabelFont: TGLCustomBitmapFont read FLabelFont write SetLabelFont
      default nil;

    property OnBeforeSelect: TGLGizmoAcceptEvent read FOnBeforeSelect
      write FOnBeforeSelect;
    property OnSelectionLost: TNotifyEvent read FOnSelectionLost
      write FOnSelectionLost;

    { : Called before an Update is applied. The "vector" parameter is the difference
      that will be applied to the object, according to the axis and
      operation selected. }
    property OnBeforeUpdate: TGLGizmoUpdateEvent read FOnBeforeUpdate
      write FOnBeforeUpdate;
    property PickMode: TGLGizmoPickMode read FPickMode write FPickMode
      default pmGetPickedObjects;
  end;

implementation

uses
  GLScene_Base_Log;

type
  TFriendlyLines = class(TGLLines);

procedure RotateAroundArbitraryAxis(const anObject: TGLBaseSceneObject;
  const axis, Origin: TAffineVector; const angle: Single);
var
  M, M1, M2, M3: TMatrix;
begin
  M1 := CreateTranslationMatrix(VectorNegate(Origin));
  M2 := CreateRotationMatrix(axis, angle * PI / 180);
  M3 := CreateTranslationMatrix(Origin);
  M := MatrixMultiply(M1, M2);
  M := MatrixMultiply(M, M3);
  anObject.Matrix := MatrixMultiply(anObject.Matrix, M);

  // Just a workarround to Update angles...
  anObject.Roll(0);
  anObject.Pitch(0);
  anObject.Turn(0);
end;

// ------------------------------------------------------------------------------

procedure TGLGizmo.ClearInternalRaycastHitData;
var
  t: Integer;
begin
  for t := FInternalRaycastHitData.Count - 1 downto 0 do
  begin
    TGLGizmoRayCastHitData(FInternalRaycastHitData[t]).Free;
  end;
  FInternalRaycastHitData.Clear;
end;

constructor TGLGizmo.Create(AOwner: TComponent);
var
  cub: TGLCube;
begin
  inherited Create(AOwner);
  FUndoHistory := TGLGizmoUndoCollection.Create(Self, TGLGizmoUndoItem);
  FPickMode := pmGetPickedObjects;
  PickableObjectsWithRayCast := TList.Create;
  FRotationCoef := 1;
  FMoveCoef := 0.1;
  FScaleCoef := 0.1;
  FGizmoThickness := 1;

  FInternalRaycastHitData := TList.Create;
  FBoundingBoxColor := TGLColor.Create(Self);
  FBoundingBoxColor.Color := clrWhite;
  FBoundingBoxColorChanged := False;
  FSelectedColor := TGLColor.Create(Self);
  FSelectedColor.Color := clrYellow;
  FVisibleInfoLabelsColor := TGLColor.Create(Self);
  FVisibleInfoLabelsColor.Color := clrYellow;
  FVisibleInfoLabelsColorChanged := False;

  _GZObaseGizmo := TGLDummyCube.Create(Self);
  _GZOrootHelpers := TGLDummyCube(_GZObaseGizmo.AddNewChild(TGLDummyCube));
  _GZOBoundingcube := TGLCube(_GZOrootHelpers.AddNewChild(TGLCube));

  _GZOrootLines := _GZOrootHelpers.AddNewChild(TGLDummyCube);
  _GZOrootTorus := _GZOrootHelpers.AddNewChild(TGLDummyCube);
  _GZOrootCubes := _GZOrootHelpers.AddNewChild(TGLDummyCube);
  _GZORootAxisLabel := _GZOrootHelpers.AddNewChild(TGLDummyCube);
  _GZORootVisibleInfoLabels := _GZOrootHelpers.AddNewChild(TGLDummyCube);

  FPickingMaterial := GetInternalMaterialLibrary.Materials.Add;
  with FPickingMaterial do
  begin
    Name := 'GLScene_Gizmo_Picking_Material';
    FixedFunction.MaterialOptions := [moIgnoreFog, moNoLighting];
    FixedFunction.LineProperties.Enabled := True;
    FixedFunction.LineProperties.Width := 3;
    with FixedFunction.DepthProperties do
    begin
      DepthTest := False;
      DepthWrite := True;
      DepthClamp := True;
      ZFar := 0.0;
    end;
  end;

  _GZOBoundingcube.Pickable := False;
  with _GZOBoundingcube.material do
  begin
    FaceCulling := fcNoCull;
    PolygonMode := pmLines;
    with FrontProperties do
    begin
      Diffuse.Color := FBoundingBoxColor.Color;
      Ambient.Color := FBoundingBoxColor.Color;
      Emission.Color := FBoundingBoxColor.Color;
    end;
    with BackProperties do
    begin
      Diffuse.Color := FBoundingBoxColor.Color;
      Ambient.Color := FBoundingBoxColor.Color;
      Emission.Color := FBoundingBoxColor.Color;
    end;
    with DepthProperties do
    begin
      DepthTest := False;
      DepthWrite := True;
      DepthClamp := True;
      ZFar := 0.0;
    end;
  end;

  _GZOlineX := TGLLines(_GZOrootLines.AddNewChild(TGLLines));
  with TFriendlyLines(_GZOlineX) do
  begin
    ObjectStyle := ObjectStyle + [osStreamDraw];
    with FMaterialEx.FixedFunction.DepthProperties do
    begin
      DepthTest := False;
      DepthWrite := True;
      DepthClamp := True;
      ZFar := 0.0;
    end;
    MaterialLibrary := GetInternalMaterialLibrary;
    CustomPickingMaterial := FPickingMaterial.Name;
    LineColor.Color := clrRed;
    LineWidth := 3;
    NodesAspect := lnaInvisible;
    AddNode(0, 0, 0);
    AddNode(1, 0, 0);
    AddNode(0.9, 0, -0.1);
    AddNode(1, 0, 0);
    AddNode(0.9, 0, 0.1);
    // Raycast pickable object
    cub := TGLGizmoPickCube(AddNewChild(TGLGizmoPickCube));
    cub.Up.SetVector(1, 0, 0);
    cub.CubeWidth := 0.1;
    cub.CubeHeight := 1;
    cub.CubeDepth := 0.1;
    cub.position.SetPoint(0.5, 0, 0);
    cub.Visible := False; cub.Tag := 777;
  end;

  _GZOlineY := TGLLines(_GZOrootLines.AddNewChild(TGLLines));
  with TFriendlyLines(_GZOlineY) do
  begin
    ObjectStyle := ObjectStyle + [osStreamDraw];
    with FMaterialEx.FixedFunction.DepthProperties do
    begin
      DepthTest := False;
      DepthWrite := True;
      DepthClamp := True;
      ZFar := 0.0;
    end;
    MaterialLibrary := GetInternalMaterialLibrary;
    CustomPickingMaterial := FPickingMaterial.Name;
    LineColor.Color := clrLime;
    LineWidth := 3;
    NodesAspect := lnaInvisible;
    AddNode(0, 0, 0);
    AddNode(0, 1, 0);
    AddNode(0.1, 0.9, 0);
    AddNode(0, 1, 0);
    AddNode(-0.1, 0.9, 0);
    // Raycast pickable object
    cub := TGLGizmoPickCube(AddNewChild(TGLGizmoPickCube));
    cub.Up.SetVector(0, 1, 0);
    cub.CubeWidth := 0.1;
    cub.CubeHeight := 1;
    cub.CubeDepth := 0.1;
    cub.position.SetPoint(0, 0.5, 0);
    cub.Visible := False; cub.Tag := 777;
  end;

  _GZOlineZ := TGLLines(_GZOrootLines.AddNewChild(TGLLines));
  with TFriendlyLines(_GZOlineZ) do
  begin
    ObjectStyle := ObjectStyle + [osStreamDraw];
    with FMaterialEx.FixedFunction.DepthProperties do
    begin
      DepthTest := False;
      DepthWrite := True;
      DepthClamp := True;
      ZFar := 0.0;
    end;
    MaterialLibrary := GetInternalMaterialLibrary;
    CustomPickingMaterial := FPickingMaterial.Name;
    LineColor.Color := clrBlue;
    LineWidth := 3;
    NodesAspect := lnaInvisible;
    AddNode(0, 0, 0);
    AddNode(0, 0, 1);
    AddNode(0.1, 0, 0.9);
    AddNode(0, 0, 1);
    AddNode(-0.1, 0, 0.9);
    // Raycast pickable object
    cub := TGLGizmoPickCube(AddNewChild(TGLGizmoPickCube));
    cub.Up.SetVector(0, 0, 1);
    cub.CubeWidth := 0.1;
    cub.CubeHeight := 1;
    cub.CubeDepth := 0.1;
    cub.position.SetPoint(0, 0, 0.5);
    cub.Visible := False; cub.Tag := 777;
  end;

  _GZOplaneXY := TGLLines(_GZOrootLines.AddNewChild(TGLLines));
  with TFriendlyLines(_GZOplaneXY) do
  begin
    ObjectStyle := ObjectStyle + [osStreamDraw];
    with FMaterialEx.FixedFunction.DepthProperties do
    begin
      DepthTest := False;
      DepthWrite := True;
      DepthClamp := True;
      ZFar := 0.0;
    end;
    MaterialLibrary := GetInternalMaterialLibrary;
    CustomPickingMaterial := FPickingMaterial.Name;
    LineWidth := 3;
    Options := [loUseNodeColorForLines];
    NodesAspect := lnaInvisible;
    SplineMode := lsmSegments;
    AddNode(0.8, 1, 0);
    TGLLinesNode(Nodes[0]).Color.Color := clrRed;
    AddNode(1, 1, 0);
    TGLLinesNode(Nodes[1]).Color.Color := clrRed;
    AddNode(1, 1, 0);
    TGLLinesNode(Nodes[2]).Color.Color := clrLime;
    AddNode(1, 0.8, 0);
    TGLLinesNode(Nodes[3]).Color.Color := clrLime;
    // Raycast pickable object
    cub := TGLGizmoPickCube(AddNewChild(TGLGizmoPickCube));
    cub.Up.SetVector(1, 0, 0);
    cub.CubeWidth := 0.2;
    cub.CubeHeight := 0.2;
    cub.CubeDepth := 0.1;
    cub.position.SetPoint(0.9, 0.9, 0);
    cub.Visible := False; cub.Tag := 777;
  end;

  _GZOplaneXZ := TGLLines(_GZOrootLines.AddNewChild(TGLLines));
  with TFriendlyLines(_GZOplaneXZ) do
  begin
    ObjectStyle := ObjectStyle + [osStreamDraw];
    with FMaterialEx.FixedFunction.DepthProperties do
    begin
      DepthTest := False;
      DepthWrite := True;
      DepthClamp := True;
      ZFar := 0.0;
    end;
    MaterialLibrary := GetInternalMaterialLibrary;
    CustomPickingMaterial := FPickingMaterial.Name;
    LineWidth := 3;
    Options := [loUseNodeColorForLines];
    NodesAspect := lnaInvisible;
    SplineMode := lsmSegments;
    AddNode(1, 0, 0.8);
    TGLLinesNode(Nodes[0]).Color.Color := clrBlue;
    AddNode(1, 0, 1);
    TGLLinesNode(Nodes[1]).Color.Color := clrBlue;
    AddNode(1, 0, 1);
    TGLLinesNode(Nodes[2]).Color.Color := clrRed;
    AddNode(0.8, 0, 1);
    TGLLinesNode(Nodes[3]).Color.Color := clrRed;
    // Raycast pickable object
    cub := TGLGizmoPickCube(AddNewChild(TGLGizmoPickCube));
    cub.Up.SetVector(1, 0, 0);
    cub.CubeWidth := 0.1;
    cub.CubeHeight := 0.2;
    cub.CubeDepth := 0.2;
    cub.position.SetPoint(0.9, 0, 0.9);
    cub.Visible := False; cub.Tag := 777;
  end;

  _GZOplaneYZ := TGLLines(_GZOrootLines.AddNewChild(TGLLines));
  with TFriendlyLines(_GZOplaneYZ) do
  begin
    ObjectStyle := ObjectStyle + [osStreamDraw];
    with FMaterialEx.FixedFunction.DepthProperties do
    begin
      DepthTest := False;
      DepthWrite := True;
      DepthClamp := True;
      ZFar := 0.0;
    end;
    MaterialLibrary := GetInternalMaterialLibrary;
    CustomPickingMaterial := FPickingMaterial.Name;
    LineWidth := 3;
    Options := [loUseNodeColorForLines];
    NodesAspect := lnaInvisible;
    SplineMode := lsmSegments;
    AddNode(0, 0.8, 1);
    TGLLinesNode(Nodes[0]).Color.Color := clrLime;
    AddNode(0, 1, 1);
    TGLLinesNode(Nodes[1]).Color.Color := clrLime;
    AddNode(0, 1, 1);
    TGLLinesNode(Nodes[2]).Color.Color := clrBlue;
    AddNode(0, 1, 0.8);
    TGLLinesNode(Nodes[3]).Color.Color := clrBlue;
    // Raycast pickable object
    cub := TGLGizmoPickCube(AddNewChild(TGLGizmoPickCube));
    cub.Up.SetVector(0, 0, 1);
    cub.CubeWidth := 0.2;
    cub.CubeHeight := 0.2;
    cub.CubeDepth := 0.1;
    cub.position.SetPoint(0, 0.9, 0.9);
    cub.Visible := False; cub.Tag := 777;
  end;

  _GZOTorusX := TGLGizmoPickTorus(_GZOrootTorus.AddNewChild(TGLGizmoPickTorus));
  with _GZOTorusX do
  begin
    Rings := 16;
    Sides := 4;
    MajorRadius := 0.6;
    MinorRadius := 0.03;
    PitchAngle := 90;
    TurnAngle := 90;
    with material do
    begin
      PolygonMode := pmFill;
      FrontProperties.Emission.Color := clrBlue;
      with DepthProperties do
      begin
        DepthTest := False;
        DepthWrite := True;
        DepthClamp := True;
        ZFar := 0.0;
      end;
    end;
    MaterialLibrary := GetInternalMaterialLibrary;
    CustomPickingMaterial := FPickingMaterial.Name;
  end;

  _GZOTorusY := TGLGizmoPickTorus(_GZOrootTorus.AddNewChild(TGLGizmoPickTorus));
  with _GZOTorusY do
  begin
    Rings := 16;
    Sides := 4;
    MajorRadius := 0.6;
    MinorRadius := 0.03;
    PitchAngle := 90;
    with material do
    begin
      PolygonMode := pmFill;
      FrontProperties.Emission.Color := clrRed;
      with DepthProperties do
      begin
        DepthTest := False;
        DepthWrite := True;
        DepthClamp := True;
        ZFar := 0.0;
      end;
    end;
    MaterialLibrary := GetInternalMaterialLibrary;
    CustomPickingMaterial := FPickingMaterial.Name;
  end;

  _GZOTorusZ := TGLGizmoPickTorus(_GZOrootTorus.AddNewChild(TGLGizmoPickTorus));
  with _GZOTorusZ do
  begin
    Rings := 16;
    Sides := 4;
    MajorRadius := 0.6;
    MinorRadius := 0.03;
    with material do
    begin
      PolygonMode := pmFill;
      FrontProperties.Emission.Color := clrLime;
      with DepthProperties do
      begin
        DepthTest := False;
        DepthWrite := True;
        DepthClamp := True;
        ZFar := 0.0;
      end;
    end;
    MaterialLibrary := GetInternalMaterialLibrary;
    CustomPickingMaterial := FPickingMaterial.Name;
  end;

  _GZOCubeX := TGLGizmoPickCube(_GZOrootCubes.AddNewChild(TGLGizmoPickCube));
  with _GZOCubeX do
  begin
    CubeDepth := 0.1;
    CubeHeight := 0.1;
    CubeWidth := 0.1;
    position.X := 1.15;
    with material do
    begin
      FaceCulling := fcNoCull;
      PolygonMode := pmFill;
      FrontProperties.Emission.Color := clrRed;
      with DepthProperties do
      begin
        DepthTest := False;
        DepthWrite := True;
        DepthClamp := True;
        ZFar := 0.0;
      end;
    end;
    MaterialLibrary := GetInternalMaterialLibrary;
    CustomPickingMaterial := FPickingMaterial.Name;
  end;

  _GZOCubeY := TGLGizmoPickCube(_GZOrootCubes.AddNewChild(TGLGizmoPickCube));
  with _GZOCubeY do
  begin
    CubeDepth := 0.1;
    CubeHeight := 0.1;
    CubeWidth := 0.1;
    position.Y := 1.15;
    with material do
    begin
      FaceCulling := fcNoCull;
      PolygonMode := pmFill;
      FrontProperties.Emission.Color := clrLime;
      with DepthProperties do
      begin
        DepthTest := False;
        DepthWrite := True;
        DepthClamp := True;
        ZFar := 0.0;
      end;
    end;
    MaterialLibrary := GetInternalMaterialLibrary;
    CustomPickingMaterial := FPickingMaterial.Name;
  end;

  _GZOCubeZ := TGLGizmoPickCube(_GZOrootCubes.AddNewChild(TGLGizmoPickCube));
  with _GZOCubeZ do
  begin
    CubeDepth := 0.1;
    CubeHeight := 0.1;
    CubeWidth := 0.1;
    position.Z := 1.15;
    with material do
    begin
      FaceCulling := fcNoCull;
      PolygonMode := pmFill;
      FrontProperties.Emission.Color := clrBlue;
      with DepthProperties do
      begin
        DepthTest := False;
        DepthWrite := True;
        DepthClamp := True;
        ZFar := 0.0;
      end;
    end;
    MaterialLibrary := GetInternalMaterialLibrary;
    CustomPickingMaterial := FPickingMaterial.Name;
  end;

  _GZOAxisLabelX := TGLFlatText(_GZORootAxisLabel.AddNewChild(TGLFlatText));
  with _GZOAxisLabelX do
  begin
    ObjectStyle := ObjectStyle + [osStreamDraw];
    ModulateColor.Color := clrRed;
    Alignment := taCenter;
    Layout := tlCenter;
    Options := Options + [ftoTwoSided];
    position.X := 1.5;
    Scale.X := 0.02;
    Scale.Y := 0.02;
    Text := 'X';
  end;

  _GZOAxisLabelY := TGLFlatText(_GZORootAxisLabel.AddNewChild(TGLFlatText));
  with _GZOAxisLabelY do
  begin
    ObjectStyle := ObjectStyle + [osStreamDraw];
    ModulateColor.Color := clrLime;
    Alignment := taCenter;
    Layout := tlCenter;
    Options := Options + [ftoTwoSided];
    position.Y := 1.5;
    Scale.X := 0.02;
    Scale.Y := 0.02;
    Text := 'Y';
  end;

  _GZOAxisLabelZ := TGLFlatText(_GZORootAxisLabel.AddNewChild(TGLFlatText));
  with _GZOAxisLabelZ do
  begin
    ObjectStyle := ObjectStyle + [osStreamDraw];
    ModulateColor.Color := clrBlue;
    Alignment := taCenter;
    Layout := tlCenter;
    Options := Options + [ftoTwoSided];
    position.Z := 1.5;
    Scale.X := 0.02;
    Scale.Y := 0.02;
    Text := 'Z';
  end;

  _GZOVisibleInfoLabels :=
    TGLFlatText(_GZORootVisibleInfoLabels.AddNewChild(TGLFlatText));
  with _GZOVisibleInfoLabels do
  begin
    ObjectStyle := ObjectStyle + [osStreamDraw];
    ModulateColor.Color := clrYellow;
    Alignment := taCenter;
    Layout := tlCenter;
    Options := Options + [ftoTwoSided];
    position.Y := 1.8;
    position.X := 0;
    Scale.X := 0.01;
    Scale.Y := 0.01;
    Text := '';
  end;

  _GZObaseGizmo.Visible := False;
  FGizmoElements := FGizmoElements + [geMove, geRotate, geScale, geAxisLabel,
    geObjectInfos, geBoundingBox];
  FVisibleVisibleInfoLabels := FVisibleVisibleInfoLabels +
    [vliName, vliOperation, vliCoords];
  AutoZoom := True;
  AutoZoomFactor := 5.0;
  ZoomFactor := 0.35;
  ForceOperation := False;
  ForceAxis := False;
  ForceUniformScale := False;
  Enabled := True;
  FNoZWrite := True;
  FExcludeObjectsList := TStringList.Create;
end;

destructor TGLGizmo.Destroy;
begin
  if Assigned(FRootGizmo) then
    FRootGizmo.DeleteChildren
  else
  begin
    _GZObaseGizmo.DeleteChildren;
    _GZObaseGizmo.Free;
  end;

  FBoundingBoxColor.Free;
  FSelectedColor.Free;
  FVisibleInfoLabelsColor.Free;
  PickableObjectsWithRayCast.Free;
  FExcludeObjectsList.Free;
  ClearInternalRaycastHitData;
  FInternalRaycastHitData.Free;

  // FUndoHistory has to be nil before Notification() is called.
  FreeAndNil(FUndoHistory);
  inherited Destroy;
end;

procedure TGLGizmo.SetVisible(const AValue: Boolean);
begin
  _GZObaseGizmo.Visible := AValue;
end;

procedure TGLGizmo.SetGizmoElements(const AValue: TGLGizmoElements);
begin
  if AValue <> FGizmoElements then
  begin
    FGizmoElements := AValue;
    _GZOrootLines.Visible := geMove in FGizmoElements;
    _GZOrootTorus.Visible := geRotate in FGizmoElements;
    _GZOrootCubes.Visible := geScale in FGizmoElements;
    _GZORootAxisLabel.Visible := geAxisLabel in FGizmoElements;
    _GZORootVisibleInfoLabels.Visible := geObjectInfos in FGizmoElements;
    _GZOBoundingcube.Visible := geBoundingBox in FGizmoElements;
  end;
end;

procedure TGLGizmo.SetBoundingBoxColor(const AValue: TGLColor);
begin
  // Bug Here New Color is not Updated
  if AValue <> FBoundingBoxColor then
  begin
    FBoundingBoxColor.Color := AValue.Color;
    with _GZOBoundingcube.material do
    begin
      with FrontProperties do
      begin
        Diffuse.Color := FBoundingBoxColor.Color;
        Ambient.Color := FBoundingBoxColor.Color;
        Emission.Color := FBoundingBoxColor.Color;
      end;
      with BackProperties do
      begin
        Diffuse.Color := FBoundingBoxColor.Color;
        Ambient.Color := FBoundingBoxColor.Color;
        Emission.Color := FBoundingBoxColor.Color;
      end;
    end;
    FBoundingBoxColorChanged := True;
  end;
end;

procedure TGLGizmo.SetSelectedColor(const AValue: TGLColor);
begin
  if AValue <> FSelectedColor then
  begin
    FSelectedColor.Color := AValue.Color;
  end;
end;

procedure TGLGizmo.SetVisibleInfoLabelsColor(const AValue: TGLColor);
begin
  // Bug Here New Color is not Updated
  if AValue <> FSelectedColor then
  begin
    FVisibleInfoLabelsColor.Color := AValue.Color;
    _GZOVisibleInfoLabels.ModulateColor.Color := AValue.Color;
    FVisibleInfoLabelsColorChanged := True;
  end;
end;

procedure TGLGizmo.SeTGLGizmoVisibleInfoLabels(const AValue
  : TGLGizmoVisibleInfoLabels);
begin
  if AValue <> FVisibleVisibleInfoLabels then
  begin
    FVisibleVisibleInfoLabels := AValue;
    if not(csDesigning in ComponentState) then
      UpdateGizmo;
  end;
end;

procedure TGLGizmo.UndoAdd(const AObject: TGLCustomSceneObject);
begin
  if AObject <> nil then
  begin
    FUndoHistory.Add.AssignFromObject(AObject)
  end;
end;

procedure TGLGizmo.SetRootGizmo(const AValue: TGLBaseSceneObject);
begin
  if FRootGizmo <> AValue then
  begin
    if FRootGizmo <> nil then
      FRootGizmo.RemoveFreeNotification(Self);
    FRootGizmo := AValue;
    if FRootGizmo <> nil then
      FRootGizmo.FreeNotification(Self);
    _GZObaseGizmo.MoveTo(AValue);
  end;
end;

procedure TGLGizmo.SetExcludeObjectsList(const AValue: TStrings);
begin
  FExcludeObjectsList.Clear;
  FExcludeObjectsList.AddStrings(AValue);
end;

procedure TGLGizmo.SetGLGizmoThickness(const Value: Single);
var
  thk: Single;
begin
  if FGizmoThickness <> Value then
  begin
    thk := MaxInteger(1, Round(3 * Value));
    _GZOlineX.LineWidth := thk;
    _GZOlineY.LineWidth := thk;
    _GZOlineZ.LineWidth := thk;
    _GZOplaneXY.LineWidth := thk;
    _GZOplaneXZ.LineWidth := thk;
    _GZOplaneYZ.LineWidth := thk;

    _GZOTorusX.MinorRadius := 0.03 * Value;
    _GZOTorusY.MinorRadius := 0.03 * Value;
    _GZOTorusZ.MinorRadius := 0.03 * Value;

    with _GZOCubeX do
    begin
      CubeDepth := 0.1 * Value;
      CubeHeight := 0.1 * Value;
      CubeWidth := 0.1 * Value;
    end;
    with _GZOCubeY do
    begin
      CubeDepth := 0.1 * Value;
      CubeHeight := 0.1 * Value;
      CubeWidth := 0.1 * Value;
    end;
    with _GZOCubeZ do
    begin
      CubeDepth := 0.1 * Value;
      CubeHeight := 0.1 * Value;
      CubeWidth := 0.1 * Value;
    end;

    FGizmoThickness := Value;
  end;
end;

// ------------------------------------------------------------------------------

procedure TGLGizmo.SetLabelFont(const Value: TGLCustomBitmapFont);
begin
  if FLabelFont <> Value then
  begin
    if FLabelFont <> nil then
      FLabelFont.RemoveFreeNotification(Self);
    FLabelFont := Value;
    if FLabelFont <> nil then
      FLabelFont.FreeNotification(Self);

    _GZOAxisLabelX.BitmapFont := Value;
    _GZOAxisLabelY.BitmapFont := Value;
    _GZOAxisLabelZ.BitmapFont := Value;
    _GZOVisibleInfoLabels.BitmapFont := Value;
  end;
end;

procedure TGLGizmo.SetNoZWrite(const Value: Boolean);
var
  LDProp: TGLDepthProperties;
begin
  if FNoZWrite <> Value then
  begin
    FNoZWrite := Value;
    LDProp := _GZOBoundingcube.material.DepthProperties;

    if FNoZWrite then
    begin
      with LDProp do
      begin
        DepthTest := False;
        DepthClamp := True;
        ZFar := 0.0;
      end;
    end
    else
    begin

      with LDProp do
      begin
        DepthTest := True;
        DepthClamp := False;
        ZFar := 1.0;
      end;
    end;

    TFriendlyLines(_GZOlineX).FMaterialEx.FixedFunction.DepthProperties.
      Assign(LDProp);
    TFriendlyLines(_GZOlineY).FMaterialEx.FixedFunction.DepthProperties.
      Assign(LDProp);
    TFriendlyLines(_GZOlineZ).FMaterialEx.FixedFunction.DepthProperties.
      Assign(LDProp);
    TFriendlyLines(_GZOplaneXY).FMaterialEx.FixedFunction.DepthProperties.
      Assign(LDProp);
    TFriendlyLines(_GZOplaneXZ).FMaterialEx.FixedFunction.DepthProperties.
      Assign(LDProp);
    TFriendlyLines(_GZOplaneYZ).FMaterialEx.FixedFunction.DepthProperties.
      Assign(LDProp);
    _GZOTorusX.material.DepthProperties.Assign(LDProp);
    _GZOTorusY.material.DepthProperties.Assign(LDProp);
    _GZOTorusZ.material.DepthProperties.Assign(LDProp);
    _GZOCubeX.material.DepthProperties.Assign(LDProp);
    _GZOCubeY.material.DepthProperties.Assign(LDProp);
    _GZOCubeZ.material.DepthProperties.Assign(LDProp);
    FPickingMaterial.FixedFunction.DepthProperties.Assign(LDProp);
  end;
end;

function TGLGizmo.GetPickedObjectPoint(const obj: TGLBaseSceneObject): TVector;
var
  t: Integer;
  r: TGLGizmoRayCastHitData;
begin
  for t := 0 to FInternalRaycastHitData.Count - 1 do
  begin
    r := TGLGizmoRayCastHitData(FInternalRaycastHitData[t]);
    if r.obj = obj then
    begin
      Result := r.Point;
      Break;
    end;
  end;
end;

function TGLGizmo.InternalGetPickedObjects(const x1, y1, x2, y2: Integer;
  const guessCount: Integer): TPersistentObjectList;
var
  t: Integer;
  rayStart, rayVector, iPoint, iNormal: TVector;
  o: TGLBaseSceneObject;
  HitData: TGLGizmoRayCastHitData;

  procedure AddGizmosToPicklListRecurse(const root: TGLBaseSceneObject);
  var
    u: Integer;
  begin
    for u := 0 to root.Count - 1 do
    begin
      if ((root[u] is TGLGizmoPickTorus) or (root[u] is TGLGizmoPickCube))
        and (PickableObjectsWithRayCast.IndexOf(root[u]) < 0) then
        PickableObjectsWithRayCast.Add(root[u]);
      AddGizmosToPicklListRecurse(root[u]);
    end;
  end;

begin
  case FPickMode of
    pmGetPickedObjects:
      begin
        Result := Viewer.Buffer.GetPickedObjects(rect(x1, y1, x2, y2), guessCount);
      end;

    pmRayCast:
      begin
        Result := TPersistentObjectList.Create;
        ClearInternalRaycastHitData;
        SetVector(rayStart, Viewer.Camera.AbsolutePosition);
        SetVector(rayVector, Viewer.Buffer.ScreenToVector
          (AffineVectorMake((x1 + x2) * 0.5,
          Viewer.Height - ((y1 + y2) * 0.5), 0)));
        NormalizeVector(rayVector);
        // Add gizmos
        if (RootGizmo <> nil) and (SelectedObj <> nil) then
          AddGizmosToPicklListRecurse(RootGizmo);
        // pick
        for t := 0 to PickableObjectsWithRayCast.Count - 1 do
        begin
          o := TGLBaseSceneObject(PickableObjectsWithRayCast[t]);
          if (o.RayCastIntersect(rayStart, rayVector, @iPoint, @iNormal)) and
            (VectorDotProduct(rayVector, iNormal) < 0) then
          begin
            try
              HitData := TGLGizmoRayCastHitData.Create;
              if o.Tag = 777 then
                o := o.Parent;
              Result.Add(o);
              HitData.obj := o;
              MakeVector(HitData.Point, iPoint);
              FInternalRaycastHitData.Add(HitData);
            except
              //
            end;
          end;
        end;
      end;

  else
    begin
      Result := nil;
      Assert(False, glsErrorEx + glsUnknownType);
    end;

  end;
end;

procedure TGLGizmo.Loaded;
begin
  inherited;
  SetGLGizmoThickness(GizmoThickness);
end;

// ------------------------------------------------------------------------------

procedure TGLGizmo.UpdateVisibleInfoLabels;
var
  t: string;
  X, Y, Z: Single;
begin
  t := '';
  if not(Assigned(SelectedObj)) then
    Exit;
  if vliName in FVisibleVisibleInfoLabels then
    t := SelectedObj.Name;

  if vliOperation in FVisibleVisibleInfoLabels then
  begin
    if (Operation <> gopNone) then
    begin
      if Length(t) > 0 then
        t := t + ' - ';
      case Operation of
        gopMove:
          t := t + 'Move';
        gopRotate:
          t := t + 'Rotate';
        gopScale:
          t := t + 'Scale';
      end;
    end;
  end;

  if vliCoords in FVisibleVisibleInfoLabels then
  begin
    if (Operation <> gopNone) then
    begin
      if Length(t) > 0 then
        t := t + ' - ';
      case Operation of
        gopMove:
          begin
            X := SelectedObj.position.X;
            Y := SelectedObj.position.Y;
            Z := SelectedObj.position.Z;
            t := t + 'X : ' + Format('%2.3f', [X]);
            t := t + ' Y : ' + Format('%2.3f', [Y]);
            t := t + ' Z : ' + Format('%2.3f', [Z]);
          end;
        gopRotate:
          begin
            X := SelectedObj.Rotation.X;
            Y := SelectedObj.Rotation.Y;
            Z := SelectedObj.Rotation.Z;
            t := t + 'X : ' + Format('%2.3f', [X]);
            t := t + ' Y : ' + Format('%2.3f', [Y]);
            t := t + ' Z : ' + Format('%2.3f', [Z]);
          end;
        gopScale:
          begin
            X := SelectedObj.Scale.X;
            Y := SelectedObj.Scale.Y;
            Z := SelectedObj.Scale.Z;
            t := t + 'X : ' + Format('%2.3f', [X]);
            t := t + ' Y : ' + Format('%2.3f', [Y]);
            t := t + ' Z : ' + Format('%2.3f', [Z]);
          end;
      end;
    end;
  end;

  _GZOVisibleInfoLabels.Text := t;
  _GZOVisibleInfoLabels.StructureChanged;
end;

// ------------------------------------------------------------------------------

function TGLGizmo.CheckObjectInExcludeList
  (const obj: TGLBaseSceneObject): Boolean;
var
  I: Integer;
begin
  Result := False;
  if FExcludeObjects then
  begin
    for I := 0 to FExcludeObjectsList.Count - 1 do
    begin
      if UpperCase(obj.Name) = UpperCase(FExcludeObjectsList[I]) then
      begin
        Result := True;
        Exit;
      end;
    end;
  end;
end;

function TGLGizmo.MouseWorldPos(const X, Y: Integer): TVector;
var
  v: TVector;
  InvertedY: Integer;
begin
  InvertedY := Viewer.Height - Y;
  if Assigned(SelectedObj) then
  begin
    SetVector(v, X, InvertedY, 0);

    case SelAxis of
      gaX:
        if not Viewer.Buffer.ScreenVectorIntersectWithPlaneXZ(v,
          SelectedObj.AbsolutePosition[1], Result) then
          MakeVector(Result, X / 5, 0, 0);

      gaY:
        if not Viewer.Buffer.ScreenVectorIntersectWithPlaneYZ(v,
          SelectedObj.AbsolutePosition[0], Result) then
          MakeVector(Result, 0, InvertedY / 5, 0);

      gaZ:
        if not Viewer.Buffer.ScreenVectorIntersectWithPlaneYZ(v,
          SelectedObj.AbsolutePosition[0], Result) then
          MakeVector(Result, 0, 0, -InvertedY / 5);

      gaXY:
        begin
          Viewer.Buffer.ScreenVectorIntersectWithPlaneXY(v,
            SelectedObj.AbsolutePosition[2], Result);
        end;
      gaXZ:
        begin
          Viewer.Buffer.ScreenVectorIntersectWithPlaneXZ(v,
            SelectedObj.AbsolutePosition[1], Result);
        end;
      gaYZ:
        begin
          Viewer.Buffer.ScreenVectorIntersectWithPlaneYZ(v,
            SelectedObj.AbsolutePosition[0], Result);
        end;
    end;

  end
  else
    SetVector(Result, NullVector);
end;

procedure TGLGizmo.ViewerMouseMove(const X, Y: Integer);
var
  pickList: TPersistentObjectList;
  mousePos: TVector;

  function indexOf(obj: TGLBaseSceneObject): Integer;
  var
    I: Integer;
  begin
    Result := -1;
    for I := 0 to pickList.Count - 1 do
      if pickList[I] = obj then
      begin
        Result := I;
        Break;
      end;
  end;

  function lightLine(const line: TGLLines; const dark: TVector;
    const axis: TGLGizmoAxis; alterStyle: Boolean = False): Boolean;
  var
    PickObj: TGLBaseSceneObject;
  begin
    case FPickMode of
      pmGetPickedObjects:
        PickObj := line;
      pmRayCast:
        PickObj := line;
    else
      begin
        PickObj := nil;
        Assert(False, glsErrorEx + glsUnknownType);
      end;
    end;

    if indexOf(PickObj) > -1 then
    begin
      line.LineColor.Color := FSelectedColor.Color;
      if not(FForceOperation) then
        if Operation <> gopMove then
          Operation := gopMove;
      line.Options := [];
      if not(FForceAxis) then
        SelAxis := axis;
      Result := True;
    end
    else
    begin
      line.LineColor.Color := dark;
      if not(FForceOperation) then
        Operation := gopNone;
      if alterStyle then
        line.Options := [loUseNodeColorForLines];
      if not(FForceAxis) then
        if SelAxis = axis then
          SelAxis := gaNone;
      Result := False;
    end;
  end;

  function lightTorus(const Torus: TGLGizmoPickTorus; const dark: TVector;
    const axis: TGLGizmoAxis; alterStyle: Boolean = False): Boolean;
  begin
    if indexOf(Torus) > -1 then
    begin
      Torus.material.FrontProperties.Emission.Color := FSelectedColor.Color;
      if not(FForceOperation) then
        if Operation <> gopRotate then
          Operation := gopRotate;
      if not(FForceAxis) then
        SelAxis := axis;
      Result := True;
    end
    else
    begin
      Torus.material.FrontProperties.Emission.Color := dark;
      if not(FForceOperation) then
        Operation := gopNone;
      if not(FForceAxis) then
        if SelAxis = axis then
          SelAxis := gaNone;
      Result := False;
    end;
  end;

  function lightCube(const Cube: TGLCube; const dark: TVector;
    const axis: TGLGizmoAxis; alterStyle: Boolean = False): Boolean;
  begin
    if indexOf(Cube) > -1 then
    begin
      Cube.material.FrontProperties.Emission.Color := FSelectedColor.Color;
      if not(FForceOperation) then
        if Operation <> gopScale then
          Operation := gopScale;
      if not(FForceAxis) then
        SelAxis := axis;
      Result := True;
    end
    else
    begin
      Cube.material.FrontProperties.Emission.Color := dark;
      if not(FForceOperation) then
        Operation := gopNone;
      if not(FForceAxis) then
        if SelAxis = axis then
          SelAxis := gaNone;
      Result := False;
    end;
  end;

  procedure OpeMove(mousePos: TVector);
  var
    vec1, vec2: TVector;
    quantizedMousePos, quantizedMousePos2: TVector;
    t: Integer;
  begin
    for t := 0 to 3 do
    begin
      quantizedMousePos[t] := (Round(mousePos[t] / MoveCoef)) * MoveCoef;
      quantizedMousePos2[t] := (Round(lastMousePos[t] / MoveCoef)) * MoveCoef;
    end;
    case SelAxis of
      gaX:
        begin
          MakeVector(vec1, quantizedMousePos[0], 0, 0);
          MakeVector(vec2, quantizedMousePos2[0], 0, 0);
        end;
      gaY:
        begin
          MakeVector(vec1, 0, quantizedMousePos[1], 0);
          MakeVector(vec2, 0, quantizedMousePos2[1], 0);
        end;
      gaZ:
        begin
          MakeVector(vec1, 0, 0, quantizedMousePos[2]);
          MakeVector(vec2, 0, 0, quantizedMousePos2[2]);
        end;
    else
      begin
        vec1 := quantizedMousePos;
        vec2 := quantizedMousePos2;
      end;
    end;
    SubtractVector(vec1, vec2);
    if Assigned(OnBeforeUpdate) then
      OnBeforeUpdate(Self, SelectedObj, SelAxis, Operation, vec1);
    vec1 := SelectedObj.parent.AbsoluteToLocal(vec1);
    if (VectorLength(vec1) > 0) then // prevents NAN problems
    begin
      SelectedObj.position.Translate(vec1);
    end;
  end;

  procedure OpeRotate(const X, Y: Integer);
  var
    vec1: TVector;
    rotV: TAffineVector;
    pmat: TMatrix;

  begin
    vec1[0] := 0;
    vec1[1] := 0;
    if abs(X - rx) >= RotationCoef then
    begin
      if RotationCoef > 1 then
        vec1[0] := RotationCoef * (Round((X - rx) / (RotationCoef)))
      else
        vec1[0] := RotationCoef * (X - rx);
      rx := X;
    end;
    if abs(Y - ry) >= RotationCoef then
    begin
      if RotationCoef > 1 then
        vec1[1] := RotationCoef * (Round((Y - ry) / (RotationCoef)))
      else
        vec1[1] := RotationCoef * (Y - ry);
      ry := Y;
    end;

    vec1[2] := 0;
    vec1[3] := 0;
    if Assigned(OnBeforeUpdate) then
      OnBeforeUpdate(Self, SelectedObj, SelAxis, Operation, vec1);

    pmat := SelectedObj.parent.InvAbsoluteMatrix;
    SetVector(pmat[3], NullHmgPoint);
    case SelAxis of
      gaX:
        begin
          rotV := VectorTransform(XVector, pmat);
          RotateAroundArbitraryAxis(SelectedObj, rotV,
            AffineVectorMake(SelectedObj.position.AsVector), vec1[1]);
        end;
      gaY:
        begin
          rotV := VectorTransform(YVector, pmat);
          RotateAroundArbitraryAxis(SelectedObj, rotV,
            AffineVectorMake(SelectedObj.position.AsVector), vec1[0]);
        end;
      gaZ:
        begin
          rotV := VectorTransform(ZVector, pmat);
          RotateAroundArbitraryAxis(SelectedObj, rotV,
            AffineVectorMake(SelectedObj.position.AsVector), vec1[1]);
        end;
      gaXY:
        begin
          rotV := VectorTransform(XVector, pmat);
          RotateAroundArbitraryAxis(SelectedObj, rotV,
            AffineVectorMake(SelectedObj.position.AsVector), vec1[1]);
          rotV := VectorTransform(YVector, pmat);
          RotateAroundArbitraryAxis(SelectedObj, rotV,
            AffineVectorMake(SelectedObj.position.AsVector), vec1[0]);
        end;
      gaXZ:
        begin
          rotV := VectorTransform(XVector, pmat);
          RotateAroundArbitraryAxis(SelectedObj, rotV,
            AffineVectorMake(SelectedObj.position.AsVector), vec1[1]);
          rotV := VectorTransform(ZVector, pmat);
          RotateAroundArbitraryAxis(SelectedObj, rotV,
            AffineVectorMake(SelectedObj.position.AsVector), vec1[0]);
        end;
      gaYZ:
        begin
          rotV := VectorTransform(YVector, pmat);
          RotateAroundArbitraryAxis(SelectedObj, rotV,
            AffineVectorMake(SelectedObj.position.AsVector), vec1[1]);
          rotV := VectorTransform(ZVector, pmat);
          RotateAroundArbitraryAxis(SelectedObj, rotV,
            AffineVectorMake(SelectedObj.position.AsVector), vec1[0]);
        end;
    end;
  end;

  procedure OpeScale(const mousePos: TVector);
  var
    vec1, vec2: TVector;
    quantizedMousePos, quantizedMousePos2: TVector;
    t: Integer;
  begin
    for t := 0 to 3 do
    begin
      quantizedMousePos[t] := (Round(mousePos[t] / ScaleCoef)) * FScaleCoef;
      quantizedMousePos2[t] := (Round(lastMousePos[t] / FScaleCoef)) *
        FScaleCoef;
    end;
    case SelAxis of
      gaX:
        begin
          if FForceUniformScale then
          begin
            MakeVector(vec1, quantizedMousePos[0], quantizedMousePos[0],
              quantizedMousePos[0]);
            MakeVector(vec2, quantizedMousePos2[0], quantizedMousePos2[0],
              quantizedMousePos2[0]);
          end
          else
          begin
            MakeVector(vec1, quantizedMousePos[0], 0, 0);
            MakeVector(vec2, quantizedMousePos2[0], 0, 0);
          end;

        end;

      gaY:
        begin
          if FForceUniformScale then
          begin
            MakeVector(vec1, quantizedMousePos[1], quantizedMousePos[1],
              quantizedMousePos[1]);
            MakeVector(vec2, quantizedMousePos2[1], quantizedMousePos2[1],
              quantizedMousePos2[1]);
          end
          else
          begin
            MakeVector(vec1, 0, quantizedMousePos[1], 0);
            MakeVector(vec2, 0, quantizedMousePos2[1], 0);
          end;
        end;

      gaZ:
        begin
          if FForceUniformScale then
          begin
            MakeVector(vec1, quantizedMousePos[2], quantizedMousePos[2],
              quantizedMousePos[2]);
            MakeVector(vec2, quantizedMousePos2[2], quantizedMousePos2[2],
              quantizedMousePos2[2]);
          end
          else
          begin
            MakeVector(vec1, 0, 0, quantizedMousePos[2]);
            MakeVector(vec2, 0, 0, quantizedMousePos2[2]);
          end;
        end;
    else
      begin
        vec1 := quantizedMousePos;
        vec2 := quantizedMousePos2;
      end;
    end;
    SubtractVector(vec1, vec2);
    if Assigned(OnBeforeUpdate) then
      OnBeforeUpdate(Self, SelectedObj, SelAxis, Operation, vec1);
    SelectedObj.Scale.Translate(vec1);
    UpdateGizmo;
  end;

begin
  if not Enabled then
    Exit;

  if Assigned(SelectedObj) and (SelAxis <> gaNone) and FMoving then
  begin
    mousePos := MouseWorldPos(X, Y);

    // moving object...
    case Operation of
      gopMove: OpeMove(mousePos);
      gopRotate: OpeRotate(X, Y);
      gopScale: OpeScale(mousePos);
    end;

    UpdateGizmo;
    mx := X;
    my := Y;
    lastMousePos := mousePos;
    Exit;
  end;

  Assert(FViewer <> nil, 'Viewer not Assigned to gizmo');
  pickList := InternalGetPickedObjects(X - 1, Y - 1, X + 1, Y + 1, 8);

  if not lightLine(_GZOlineX, clrRed, gaX)
    and not lightLine(_GZOlineY, clrLime, gaY)
    and not lightLine(_GZOlineZ, clrBlue, gaZ)
    and not lightTorus(_GZOTorusX, clrRed, gaX)
    and not lightTorus(_GZOTorusY, clrLime, gaY)
    and not lightTorus(_GZOTorusZ, clrBlue, gaZ)
    and not lightCube(_GZOCubeX, clrRed, gaX)
    and not lightCube(_GZOCubeY, clrLime, gaY)
    and not lightCube(_GZOCubeZ, clrBlue, gaZ)
    and not lightLine(_GZOplaneXY, clrWhite, gaXY, True)
    and not lightLine(_GZOplaneXZ, clrWhite, gaXZ, True)
    and not lightLine(_GZOplaneYZ, clrWhite, gaYZ, True) then
  begin
    if not(FForceAxis) then
      SelAxis := gaNone;
    if not(FForceOperation) then
      Operation := gopNone;
  end;

  pickList.Free;

  mx := X;
  my := Y;
end;

procedure TGLGizmo.ViewerMouseDown(const X, Y: Integer);
var
  pick: TPersistentObjectList;
  I: Integer;
  accept: Boolean;
  dimensions: TVector;
  gotPick: Boolean;
  pickedObj: TGLBaseSceneObject;
begin
  mx := X;
  my := Y;
  rx := X;
  ry := Y;

  if not Enabled then
    Exit;

  pick := InternalGetPickedObjects(X - 1, Y - 1, X + 1, Y + 1);
  gotPick := False;
  accept := False;

  try

    for I := 0 to pick.Count - 1 do
      if (_GZOrootLines.IndexOfChild(TGLBaseSceneObject(pick[I])) > -1) or
        (_GZOrootTorus.IndexOfChild(TGLBaseSceneObject(pick[I])) > -1) or
        (_GZOrootCubes.IndexOfChild(TGLBaseSceneObject(pick[I])) > -1) then
        gotPick := True;

    if not gotPick then
    begin
      for I := 0 to pick.Count - 1 do

        if (pick[I] <> _GZOBoundingcube) and (pick[I] <> _GZOAxisLabelX) and
          (pick[I] <> _GZOAxisLabelY) and (pick[I] <> _GZOAxisLabelZ) and
          (pick[I] <> _GZOVisibleInfoLabels) and
          not(CheckObjectInExcludeList(TGLBaseSceneObject(pick[I]))) then
        begin
          accept := True;
          pickedObj := TGLBaseSceneObject(pick[I]);
          dimensions := pickedObj.AxisAlignedDimensions;
          if Assigned(OnBeforeSelect) then
            OnBeforeSelect(Self, pickedObj, accept, dimensions);

          Break;
        end;

      if accept then
        SetSelectedObj(pickedObj)
      else
        SetSelectedObj(nil);
    end
    else
      UpdateVisibleInfoLabels();

  finally
    pick.Free;
    FMoving := True;
    lastMousePos := MouseWorldPos(X, Y);
  end;

end;

procedure TGLGizmo.ViewerMouseUp(const X, Y: Integer);
begin
  FMoving := False;
end;

// ------------------------------------------------------------------------------

procedure TGLGizmo.UpdateGizmo;
var
  d: Single;
begin
  if SelectedObj = nil then
  begin
    _GZObaseGizmo.Visible := False;
    Exit;
  end;

  _GZObaseGizmo.position.AsVector := SelectedObj.AbsolutePosition;
  if geObjectInfos in FGizmoElements then
    UpdateVisibleInfoLabels;

  _GZOBoundingcube.Matrix := SelectedObj.absoluteMatrix;
  _GZOBoundingcube.position.SetPoint(0, 0, 0);

  // We must Update Color Of the BoundingBox And VisibleInfoLabels Here
  // If not Color is not Updated;

  // if FBoundingBoxColorChanged then
  // Begin
  with _GZOBoundingcube.material do
  begin
    with FrontProperties do
    begin
      Diffuse.Color := FBoundingBoxColor.Color;
      Ambient.Color := FBoundingBoxColor.Color;
      Emission.Color := FBoundingBoxColor.Color;
    end;
    with BackProperties do
    begin
      Diffuse.Color := FBoundingBoxColor.Color;
      Ambient.Color := FBoundingBoxColor.Color;
      Emission.Color := FBoundingBoxColor.Color;
    end;
  end;
  // FBoundingBoxColorChanged:=False;
  // End;
  // If FVisibleInfoLabelsColorChanged then
  // Begin
  _GZOVisibleInfoLabels.ModulateColor.Color := FVisibleInfoLabelsColor.Color;
  // FVisibleInfoLabelsColorChanged:=False;
  // End;

  objDimensions := SelectedObj.AxisAlignedDimensions;
  _GZOBoundingcube.Scale.AsVector := VectorScale(objDimensions, 2);

  Assert(Viewer <> nil, 'Viewer not Assigned to gizmo');

  _GZOAxisLabelX.PointTo(Viewer.Camera.position.AsVector,
    Viewer.Camera.Up.AsVector);
  _GZOAxisLabelX.StructureChanged;
  _GZOAxisLabelY.PointTo(Viewer.Camera.position.AsVector,
    Viewer.Camera.Up.AsVector);
  _GZOAxisLabelY.StructureChanged;
  _GZOAxisLabelZ.PointTo(Viewer.Camera.position.AsVector,
    Viewer.Camera.Up.AsVector);
  _GZOAxisLabelZ.StructureChanged;
  _GZOVisibleInfoLabels.PointTo(Viewer.Camera.position.AsVector,
    Viewer.Camera.Up.AsVector);
  _GZOVisibleInfoLabels.StructureChanged;
  if FAutoZoom then
    d := Viewer.Camera.distanceTo(SelectedObj) / FAutoZoomFactor
  else
    d := FZoomFactor;
  _GZOrootLines.Scale.AsVector := VectorMake(d, d, d);
  _GZOrootTorus.Scale.AsVector := VectorMake(d, d, d);
  _GZOrootCubes.Scale.AsVector := VectorMake(d, d, d);
  _GZORootAxisLabel.Scale.AsVector := VectorMake(d, d, d);
  _GZORootVisibleInfoLabels.Scale.AsVector := VectorMake(d, d, d);
end;

procedure TGLGizmo.UpdateGizmo(const newDimensions: TVector);
begin
  objDimensions := newDimensions;
  UpdateGizmo;
end;

procedure TGLGizmo.LooseSelection;
begin
  SelectedObj := nil;
  UpdateGizmo;
  if Assigned(OnSelectionLost) then
    OnSelectionLost(Self);
end;

procedure TGLGizmo.SetViewer(const Value: TGLSceneViewer);
begin
  if FViewer <> Value then
  begin
    if FViewer <> nil then
      FViewer.RemoveFreeNotification(Self);
    FViewer := Value;
    if FViewer <> nil then
      FViewer.FreeNotification(Self);
  end;
end;

procedure TGLGizmo.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited;
  if Operation = opRemove then
  begin
    if AComponent = FViewer then
      FViewer := nil;
    if AComponent = FRootGizmo then
      FRootGizmo := nil;
  end;

  if FUndoHistory <> nil then
    FUndoHistory.Notification(AComponent, Operation);
end;

procedure TGLGizmoUndoItem.AssignFromObject(const AObject
  : TGLCustomSceneObject);
begin
  SetEffectedObject(AObject);
  SetOldMatrix(AObject.Matrix);
  if AObject is TGLFreeForm then
  begin
    FOldAutoScaling.Assign(TGLFreeForm(AObject).AutoScaling);
  end;
  FOldLibMaterialName := AObject.material.LibMaterialName;
end;

constructor TGLGizmoUndoItem.Create(AOwner: TCollection);
begin
  inherited;
  FOldAutoScaling := TGLCoordinates.CreateInitialized(Self,
    NullHmgVector, csPoint);
end;

destructor TGLGizmoUndoItem.Destroy;
begin
  FOldAutoScaling.Free;
  inherited;
end;

procedure TGLGizmoUndoItem.DoUndo;
begin
  FEffectedObject.Matrix := FOldMatr;
  if FEffectedObject is TGLFreeForm then
    TGLFreeForm(FEffectedObject).AutoScaling.Assign(FOldAutoScaling);
  FEffectedObject.material.LibMaterialName := FOldLibMaterialName;
end;

function TGLGizmoUndoItem.GetGizmo: TGLGizmo;
begin
  if GetParent <> nil then
    Result := GetParent.GetParent
  else
    Result := nil;
end;

function TGLGizmoUndoItem.GetParent: TGLGizmoUndoCollection;
begin
  Result := TGLGizmoUndoCollection(GetOwner);
end;

procedure TGLGizmoUndoItem.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited;
  if Operation = opRemove then
  begin
    if AComponent = FEffectedObject then
      FEffectedObject := nil;
  end;
end;

procedure TGLGizmoUndoItem.SetEffectedObject(const Value: TGLCustomSceneObject);
begin
  if FEffectedObject <> nil then
    FEffectedObject.RemoveFreeNotification(GetGizmo);
  FEffectedObject := Value;
  if FEffectedObject <> nil then
    FEffectedObject.FreeNotification(GetGizmo);
end;

procedure TGLGizmoUndoItem.SetOldAutoScaling(const Value: TGLCoordinates);
begin
  FOldAutoScaling.Assign(Value);
end;

procedure TGLGizmoUndoItem.SetOldMatrix(const Value: TMatrix);
begin
  FOldMatrix := Value;
end;

{ TGLGizmoUndoCollection }

function TGLGizmoUndoCollection.Add: TGLGizmoUndoItem;
begin
  Result := TGLGizmoUndoItem( inherited Add);
end;

function TGLGizmoUndoCollection.GetItems(const Index: Integer)
  : TGLGizmoUndoItem;
begin
  Result := TGLGizmoUndoItem( inherited GetItem(Index));
end;

function TGLGizmoUndoCollection.GetParent: TGLGizmo;
begin
  Result := TGLGizmo(GetOwner);
end;

procedure TGLGizmoUndoCollection.Notification(AComponent: TComponent;
  Operation: TOperation);
var
  I: Integer;
begin
  if Count <> 0 then
    for I := 0 to Count - 1 do
      GetItems(I).Notification(AComponent, Operation);
end;

procedure TGLGizmoUndoCollection.RemoveByObject(const AObject
  : TGLCustomSceneObject);
var
  I: Integer;
begin
  for I := Count - 1 downto 0 do
    if GetItems(I).FEffectedObject = AObject then
      GetItems(I).Free;
end;

procedure TGLGizmoUndoCollection.SetItems(const Index: Integer;
  const Value: TGLGizmoUndoItem);
begin
  GetItems(Index).Assign(Value);
end;

procedure TGLGizmo.SetSelectedObj(const Value: TGLBaseSceneObject);
begin
  if FSelectedObj <> Value then
  begin
    FSelectedObj := Value;

    if Value <> nil then
    begin
      SetVisible(True);
      UpdateVisibleInfoLabels();
      UpdateGizmo();
    end
    else
    begin
      LooseSelection();
      SetVisible(False);
    end;
  end;
end;

end.
