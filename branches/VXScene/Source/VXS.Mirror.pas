//
// VXScene Component Library, based on GLScene http://glscene.sourceforge.net 
//
{
   Implements a basic, stencil-based mirror (as in Mark Kilgard's demo). 

   It is strongly recommended to read and understand the explanations in the
   materials/mirror demo before using this component. 
   
}
unit VXS.Mirror;

interface

{$I VXScene.inc}

uses
  Winapi.OpenGL, 
  Winapi.OpenGLext, 
  System.Classes,

  VXS.PersistentClasses,
  VXS.Scene,
  VXS.XCollection,
  VXS.PipelineTransformation,
  VXS.VectorGeometry,
  VXS.Context,
  VXS.Material,
  VXS.Color,
  VXS.RenderContextInfo,
  VXS.State,
  VXS.VectorTypes;


type

  TMirrorOption = (moUseStencil, moOpaque, moMirrorPlaneClip, moClearZBuffer);
  TMirrorOptions = set of TMirrorOption;

const
  cDefaultMirrorOptions = [moUseStencil];

type

  TMirrorShapes = (msRect, msDisk);

  { A simple plane mirror.
     This mirror requires a stencil buffer for optimal rendering!
     The object is a mix between a plane and a proxy object, in that the plane
     defines the mirror's surface, while the proxy part is used to reference
     the objects that should be mirrored (it is legal to self-mirror, but no
     self-mirror visuals will be rendered).
     It is strongly recommended to read and understand the explanations in the
     materials/mirror demo before using this component. }
  TVXMirror = class(TVXSceneObject)
  private
    FRendering: Boolean;
    FMirrorObject: TVXBaseSceneObject;
    FWidth, FHeight: Single;
    FMirrorOptions: TMirrorOptions;
    FOnBeginRenderingMirrors, FOnEndRenderingMirrors: TNotifyEvent;
    FShape: TMirrorShapes; //ORL
    FRadius: Single; //ORL
    FSlices: GLint; //ORL
  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    procedure SetMirrorObject(const val: TVXBaseSceneObject);
    procedure SetMirrorOptions(const val: TMirrorOptions);
    procedure ClearZBufferArea(aBuffer: TVXSceneBuffer);
    procedure SetHeight(AValue: Single);
    procedure SetWidth(AValue: Single);
    procedure SetRadius(const aValue: Single); //ORL
    procedure SetSlices(const aValue: GLint); //ORL
    procedure SetShape(aValue: TMirrorShapes); //ORL
    function GetRadius: Single; //ORL
    function GetSlices: GLint; //ORL
  public
    constructor Create(AOwner: TComponent); override;
    procedure DoRender(var ARci: TVXRenderContextInfo;
      ARenderSelf, ARenderChildren: Boolean); override;
    procedure BuildList(var ARci: TVXRenderContextInfo); override;
    procedure Assign(Source: TPersistent); override;
    function AxisAlignedDimensionsUnscaled: TVector; override;
  published
    { Selects the object to mirror. If nil, the whole scene is mirrored. }
    property MirrorObject: TVXBaseSceneObject read FMirrorObject write
      SetMirrorObject;
    { Controls rendering options. 
        moUseStencil: mirror area is stenciled, prevents reflected
          objects to be visible on the sides of the mirror (stencil buffer
          must be active in the viewer)
        moOpaque: mirror is opaque (ie. painted with background color)
        moMirrorPlaneClip: a ClipPlane is defined to prevent reflections
          from popping out of the mirror (for objects behind or halfway through)
        moClearZBuffer: mirror area's ZBuffer is cleared so that background
          objects don't interfere with reflected objects (reflected objects
          must be rendered AFTER the mirror in the hierarchy). Works only
          along with stenciling. }
    property MirrorOptions: TMirrorOptions read FMirrorOptions write
      SetMirrorOptions default cDefaultMirrorOptions;
    property Height: Single read FHeight write SetHeight;
    property Width: Single read FWidth write SetWidth;
    { Fired before the object's mirror images are rendered. }
    property OnBeginRenderingMirrors: TNotifyEvent read FOnBeginRenderingMirrors
      write FOnBeginRenderingMirrors;
    { Fired after the object's mirror images are rendered. }
    property OnEndRenderingMirrors: TNotifyEvent read FOnEndRenderingMirrors
      write FOnEndRenderingMirrors;
    property Radius: Single read FRadius write SetRadius; //ORL
    property Slices: GLint read FSlices write SetSlices default 16; //ORL
    property Shape: TMirrorShapes read FShape write SetShape default msRect;
    //ORL
  end;

//-------------------------------------------------------------
implementation
//-------------------------------------------------------------

// ------------------
// ------------------ TVXMirror ------------------
// ------------------


constructor TVXMirror.Create(AOwner: Tcomponent);
begin
  inherited Create(AOwner);
  FWidth := 1;
  FHeight := 1;
  FMirrorOptions := cDefaultMirrorOptions;
  ObjectStyle := ObjectStyle + [osDirectDraw];
  Material.FrontProperties.Diffuse.Initialize(VectorMake(1, 1, 1, 0.1));
  Material.BlendingMode := bmTransparency;

  FRadius := 1; //ORL
  FSlices := 16; //ORL
  Shape := msRect; //ORL
end;


procedure TVXMirror.DoRender(var ARci: TVXRenderContextInfo;
  ARenderSelf, ARenderChildren: Boolean);
var
  oldProxySubObject: Boolean;
  refMat, curMat, ModelMat: TMatrix;
  clipPlane: TDoubleHmgPlane;
  bgColor: TColorVector;
  cameraPosBackup, cameraDirectionBackup: TVector;
  CurrentBuffer: TVXSceneBuffer;
begin
  if FRendering then
    Exit;
  FRendering := True;
  try
    oldProxySubObject := ARci.proxySubObject;
    ARci.proxySubObject := True;
    CurrentBuffer := TVXSceneBuffer(ARci.buffer);

    if VectorDotProduct(VectorSubtract(ARci.cameraPosition, AbsolutePosition),
      AbsoluteDirection) > 0 then
      with ARci.VxStates do
      begin

        // "Render" stencil mask
        if MirrorOptions <> [] then
        begin
          if (moUseStencil in MirrorOptions) then
          begin
            Enable(stStencilTest);
            ARci.VXStates.StencilClearValue := 0;
            glClear(GL_STENCIL_BUFFER_BIT);
            SetStencilFunc(cfAlways, 1, 1);
            SetStencilOp(soReplace, soZero, soReplace);
          end;
          if (moOpaque in MirrorOptions) then
          begin
            bgColor := ConvertWinColor(CurrentBuffer.BackgroundColor);
            ARci.VXStates.SetMaterialColors(cmFront, bgColor, clrBlack,
              clrBlack, clrBlack, 0);
          end
          else
            SetColorWriting(False);

          Enable(stDepthTest);
          DepthWriteMask := False;

          BuildList(ARci);

          DepthWriteMask := True;
          if (moUseStencil in MirrorOptions) then
          begin
            SetStencilFunc(cfEqual, 1, 1);
            SetStencilOp(soKeep, soKeep, soKeep);
          end;

          if (moClearZBuffer in MirrorOptions) then
            ClearZBufferArea(CurrentBuffer);

          if not (moOpaque in MirrorOptions) then
            SetColorWriting(True);
        end;

        ARci.PipelineTransformation.Push;
        ARci.PipelineTransformation.SetModelMatrix(IdentityHmgMatrix);

        Disable(stCullFace);
        Enable(stNormalize);

        if moMirrorPlaneClip in MirrorOptions then
        begin
          glEnable(GL_CLIP_PLANE0);
          SetPlane(clipPlane, PlaneMake(AffineVectorMake(AbsolutePosition),
            VectorNegate(AffineVectorMake(AbsoluteDirection))));
          glClipPlane(GL_CLIP_PLANE0, @clipPlane);
        end;

        // Mirror lights
        refMat := MakeReflectionMatrix(
          AffineVectorMake(AbsolutePosition),
          AffineVectorMake(AbsoluteDirection));
        curMat := MatrixMultiply(refMat, ARci.PipelineTransformation.ViewMatrix^);
        ARci.PipelineTransformation.SetViewMatrix(curMat);
        Scene.SetupLights(CurrentBuffer.LimitOf[limLights]);

        // mirror geometry and render master
        cameraPosBackup := ARci.cameraPosition;
        cameraDirectionBackup := ARci.cameraDirection;
        ARci.cameraPosition := VectorTransform(ARci.cameraPosition, refMat);
        ARci.cameraDirection := VectorTransform(ARci.cameraDirection, refMat);

        // temporary fix? (some objects don't respect culling options, or ?)
        CullFaceMode := cmFront;
        if Assigned(FOnBeginRenderingMirrors) then
          FOnBeginRenderingMirrors(Self);
        if Assigned(FMirrorObject) then
        begin
          ModelMat := IdentityHmgMatrix;
          if FMirrorObject.Parent <> nil then
            MatrixMultiply(ModelMat, FMirrorObject.Parent.AbsoluteMatrix, ModelMat);
          MatrixMultiply(ModelMat, FMirrorObject.LocalMatrix^, ModelMat);
          ARci.PipelineTransformation.SetModelMatrix(ModelMat);
          FMirrorObject.DoRender(ARci, ARenderSelf, FMirrorObject.Count > 0);
        end
        else
        begin
          Scene.Objects.DoRender(ARci, ARenderSelf, True);
        end;
        if Assigned(FOnEndRenderingMirrors) then
          FOnEndRenderingMirrors(Self);

        // Restore to "normal"
        ARci.cameraPosition := cameraPosBackup;
        ARci.cameraDirection := cameraDirectionBackup;
        ARci.VXStates.CullFaceMode := cmBack;
        ARci.PipelineTransformation.ReplaceFromStack;
        Scene.SetupLights(CurrentBuffer.LimitOf[limLights]);
        ARci.PipelineTransformation.Pop;
        if moMirrorPlaneClip in MirrorOptions then
          glDisable(GL_CLIP_PLANE0);
        ARci.VXStates.Disable(stStencilTest);

        ARci.proxySubObject := oldProxySubObject;

        // start rendering self
        if ARenderSelf then
        begin
          Material.Apply(ARci);
          repeat
            BuildList(ARci);
          until not Material.UnApply(ARci);
        end;

      end;

    if ARenderChildren then
      Self.RenderChildren(0, Count - 1, ARci);

    if Assigned(FMirrorObject) then
      FMirrorObject.Effects.RenderPostEffects(ARci);
  finally
    FRendering := False;
  end;
end;

procedure TVXMirror.BuildList(var ARci: TVXRenderContextInfo);
var
  hw, hh: Single;
  quadric: GLUquadricObj;
begin
  if msRect = FShape then
  begin
    hw := FWidth * 0.5;
    hh := FHeight * 0.5;
    glNormal3fv(@ZVector);
    glBegin(GL_QUADS);
    glVertex3f(hw, hh, 0);
    glVertex3f(-hw, hh, 0);
    glVertex3f(-hw, -hh, 0);
    glVertex3f(hw, -hh, 0);
    glEnd;
  end
  else
  begin
    quadric := gluNewQuadric;
    gluDisk(Quadric, 0, FRadius, FSlices, 1); //radius. slices, loops
  end;
end;


procedure TVXMirror.ClearZBufferArea(aBuffer: TVXSceneBuffer);
var
  worldMat: TMatrix;
  p: TAffineVector;
begin
  with aBuffer do
  begin
    glPushMatrix;
    worldMat := Self.AbsoluteMatrix;
    glMatrixMode(GL_PROJECTION);
    glPushMatrix;
    glLoadIdentity;
    glOrtho(0, Width, 0, Height, 1, -1);
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity;

    with aBuffer.RenderingContext.VxStates do
    begin
      DepthFunc := cfAlways;
      SetColorWriting(False);
    end;

    glBegin(GL_QUADS);
    p := WorldToScreen(VectorTransform(AffineVectorMake(Self.Width * 0.5,
      Self.Height * 0.5, 0), worldMat));
    glVertex3f(p.X, p.Y, 0.999);
    p := WorldToScreen(VectorTransform(AffineVectorMake(-Self.Width * 0.5,
      Self.Height * 0.5, 0), worldMat));
    glVertex3f(p.X, p.Y, 0.999);
    p := WorldToScreen(VectorTransform(AffineVectorMake(-Self.Width * 0.5,
      -Self.Height * 0.5, 0), worldMat));
    glVertex3f(p.X, p.Y, 0.999);
    p := WorldToScreen(VectorTransform(AffineVectorMake(Self.Width * 0.5,
      -Self.Height * 0.5, 0), worldMat));
    glVertex3f(p.X, p.Y, 0.999);
    glEnd;

    with aBuffer.RenderingContext.VxStates do
    begin
      DepthFunc := cfLess;
      SetColorWriting(True);
    end;

    glMatrixMode(GL_PROJECTION);
    glPopMatrix;
    glMatrixMode(GL_MODELVIEW);
    glPopMatrix;
  end;
end;

procedure TVXMirror.Notification(AComponent: TComponent; Operation: TOperation);
begin
  if (Operation = opRemove) and (AComponent = FMirrorObject) then
    MirrorObject := nil;
  inherited;
end;

procedure TVXMirror.SetMirrorObject(const val: TVXBaseSceneObject);
begin
  if FMirrorObject <> val then
  begin
    if Assigned(FMirrorObject) then
      FMirrorObject.RemoveFreeNotification(Self);
    FMirrorObject := val;
    if Assigned(FMirrorObject) then
      FMirrorObject.FreeNotification(Self);
    NotifyChange(Self);
  end;
end;


procedure TVXMirror.SetWidth(AValue: Single);
begin
  if AValue <> FWidth then
  begin
    FWidth := AValue;
    NotifyChange(Self);
  end;
end;


procedure TVXMirror.SetHeight(AValue: Single);
begin
  if AValue <> FHeight then
  begin
    FHeight := AValue;
    NotifyChange(Self);
  end;
end;


procedure TVXMirror.Assign(Source: TPersistent);
begin
  if Assigned(Source) and (Source is TVXMirror) then
  begin
    FWidth := TVXMirror(Source).FWidth;
    FHeight := TVXMirror(Source).FHeight;
    FMirrorOptions := TVXMirror(Source).FMirrorOptions;
    MirrorObject := TVXMirror(Source).MirrorObject;
  end;
  inherited Assign(Source);
end;


function TVXMirror.AxisAlignedDimensionsUnscaled: TVector;
begin
  Result := VectorMake(0.5 * Abs(FWidth),
    0.5 * Abs(FHeight), 0);
end;


procedure TVXMirror.SetMirrorOptions(const val: TMirrorOptions);
begin
  if FMirrorOptions <> val then
  begin
    FMirrorOptions := val;
    NotifyChange(Self);
  end;
end;

//ORL add-ons


procedure TVXMirror.SetRadius(const aValue: Single);
begin
  if aValue <> FRadius then
  begin
    FRadius := aValue;
    StructureChanged;
  end;
end;


function TVXMirror.GetRadius: single;
begin
  result := FRadius;
end;


procedure TVXMirror.SetSlices(const aValue: GLint);
begin
  if aValue <> FSlices then
  begin
    if aValue > 2 then
      FSlices := aValue;
    StructureChanged;
  end
  else
  begin
  end;
end;


function TVXMirror.GetSlices: GLint;
begin
  result := FSlices;
end;


procedure TVXMirror.SetShape(aValue: TMirrorShapes);
begin
  if aValue <> FShape then
  begin
    FShape := aValue;
    StructureChanged;
  end;
end;

//-------------------------------------------------------------
initialization
//-------------------------------------------------------------

  RegisterClasses([TVXMirror]);

end.

