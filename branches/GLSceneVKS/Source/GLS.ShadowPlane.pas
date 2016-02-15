//
// GLScene on Vulkan, http://glscene.sourceforge.net 
//
{
   Implements a basic shadow plane. 

   It is strongly recommended to read and understand the explanations in the
   materials/mirror demo before using this component. 
    
}
unit GLS.ShadowPlane;

interface

{$I GLScene.inc}

uses
  System.Classes,
  GLS.Scene,
  GLS.VectorGeometry,
  GLS.Objects,
  GLS.CrossPlatform,
  GLS.Color,
  GLS.RenderContextInfo,
  GLS.State,
  GLS.TextureFormat;

type

  // TShadowPlaneOptions
  //
  TShadowPlaneOption = (spoUseStencil, spoScissor, spoTransparent, spoIgnoreZ);
  TShadowPlaneOptions = set of TShadowPlaneOption;

const
  cDefaultShadowPlaneOptions = [spoUseStencil, spoScissor];

type

  // TVKShadowPlane
  //
  { A simple shadow plane. 
     This mirror requires a stencil buffer for optimal rendering! 
     The object is a mix between a plane and a proxy object, in that the plane
     defines where the shadows are cast, while the proxy part is used to reference
     the objects that should be shadowing (it is legal to self-shadow, but no
     self-shadow visuals will be rendered). 
     If stenciling isn't used, the shadow will 'paint' the ShadowColor instead
     of blending it transparently. 
     You can have lower quality shadow geometry: add a dummycube, set it to
     invisible (so it won't be rendered in the "regular" pass), and under
     it place another visible dummycube under which you have all your
     low quality objects, use it as shadowing object. Apply the same movements
     to the low-quality objects that you apply to the visible, high-quality ones.
     }
  TVKShadowPlane = class(TVKPlane)
  private
    { Private Declarations }
    FRendering: Boolean;
    FShadowingObject: TVKBaseSceneObject;
    FShadowedLight: TVKLightSource;
    FShadowColor: TVKColor;
    FShadowOptions: TShadowPlaneOptions;
    FOnBeginRenderingShadows, FOnEndRenderingShadows: TNotifyEvent;

  protected
    { Protected Declarations }
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    procedure SetShadowingObject(const val: TVKBaseSceneObject);
    procedure SetShadowedLight(const val: TVKLightSource);
    procedure SetShadowColor(const val: TVKColor);
    procedure SetShadowOptions(const val: TShadowPlaneOptions);

  public
    { Public Declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure DoRender(var ARci: TVKRenderContextInfo;
      ARenderSelf, ARenderChildren: Boolean); override;

    procedure Assign(Source: TPersistent); override;

  published
    { Public Declarations }
          { Selects the object to mirror. 
             If nil, the whole scene is mirrored. }
    property ShadowingObject: TVKBaseSceneObject read FShadowingObject write SetShadowingObject;
    { The light which casts shadows. 
       The light must be enabled otherwise shadows won't be cast. }
    property ShadowedLight: TVKLightSource read FShadowedLight write SetShadowedLight;
    { The shadow's color. 
       This color is transparently blended to make shadowed area darker. }
    property ShadowColor: TVKColor read FShadowColor write SetShadowColor;

    { Controls rendering options. 
        
        spoUseStencil: plane area is stenciled, prevents shadowing
          objects to be visible on the sides of the mirror (stencil buffer
          must be active in the viewer too). It also allows shadows to
          be partial (blended).
        spoScissor: plane area is 'scissored', this should improve
          rendering speed by limiting rendering operations and fill rate,
          may have adverse effects on old hardware in rare cases
        spoTransparent: does not render the plane's material, may help
          improve performance if you're fillrate limited, are using the
          stencil, and your hardware has optimized stencil-only writes
        
    }
    property ShadowOptions: TShadowPlaneOptions read FShadowOptions write SetShadowOptions default cDefaultShadowPlaneOptions;

    { Fired before the shadows are rendered. }
    property OnBeginRenderingShadows: TNotifyEvent read FOnBeginRenderingShadows write FOnBeginRenderingShadows;
    { Fired after the shadows are rendered. }
    property OnEndRenderingShadows: TNotifyEvent read FOnEndRenderingShadows write FOnEndRenderingShadows;
  end;

  //-------------------------------------------------------------
  //-------------------------------------------------------------
  //-------------------------------------------------------------
implementation
//-------------------------------------------------------------
//-------------------------------------------------------------
//-------------------------------------------------------------
uses GLS.OpenGLTokens, GLS.Context;
// ------------------
// ------------------ TVKShadowPlane ------------------
// ------------------

// Create
//

constructor TVKShadowPlane.Create(AOwner: Tcomponent);
const
  cDefaultShadowColor: TColorVector = (X:0; Y:0; Z:0; W:0.5);
begin
  inherited Create(AOwner);
  FShadowOptions := cDefaultShadowPlaneOptions;
  ObjectStyle := ObjectStyle + [osDirectDraw];
  FShadowColor := TVKColor.CreateInitialized(Self, cDefaultShadowColor);
end;

// Destroy
//

destructor TVKShadowPlane.Destroy;
begin
  inherited;
  FShadowColor.Free;
end;

// DoRender
//

procedure TVKShadowPlane.DoRender(var ARci: TVKRenderContextInfo;
  ARenderSelf, ARenderChildren: Boolean);
var
  oldProxySubObject, oldIgnoreMaterials: Boolean;
  shadowMat: TMatrix;
  sr: TVKRect;
  CurrentBuffer: TVKSceneBuffer;
  ModelMat: TMatrix;
begin
  if FRendering then
    Exit;
  FRendering := True;
  try
    with ARci.GLStates do
    begin
      oldProxySubObject := ARci.proxySubObject;
      ARci.proxySubObject := True;
      CurrentBuffer := TVKSceneBuffer(ARci.buffer);

      if ARenderSelf and (VectorDotProduct(VectorSubtract(ARci.cameraPosition, AbsolutePosition), AbsoluteDirection) > 0) then
      begin

        if (spoScissor in ShadowOptions)
          and (PointDistance(ARci.cameraPosition) > BoundingSphereRadius) then
        begin
          sr := ScreenRect(CurrentBuffer);
          InflateGLRect(sr, 1, 1);
          IntersectGLRect(sr, GLRect(0, 0, ARci.viewPortSize.cx, ARci.viewPortSize.cy));
          GL.Scissor(sr.Left, sr.Top, sr.Right - sr.Left, sr.Bottom - sr.Top);
          Enable(stScissorTest);
        end;

        if (spoUseStencil in ShadowOptions) then
        begin
          StencilClearValue := 0;
          glClear(GL_STENCIL_BUFFER_BIT);
          Enable(stStencilTest);
          SetStencilFunc(cfAlways, 1, 1);
          SetStencilOp(soReplace, soReplace, soReplace);
        end;

        // "Render"  plane and stencil mask
        if (spoTransparent in ShadowOptions) then
        begin
          SetGLColorWriting(False);
          DepthWriteMask := False;
          BuildList(ARci);
          SetGLColorWriting(True);
        end
        else
        begin
          Material.Apply(ARci);
          repeat
            BuildList(ARci);
          until not Material.UnApply(ARci);
        end;

        // Setup depth options
        if spoIgnoreZ in ShadowOptions then
          Disable(stDepthTest)
        else
          Enable(stDepthTest);
        DepthFunc := cfLEqual;

        if Assigned(FShadowedLight) then
        begin

          ARci.PipelineTransformation.Push;

          case ShadowedLight.LightStyle of
            lsParallel:
              begin
                shadowMat := MakeShadowMatrix(AbsolutePosition, AbsoluteDirection,
                  VectorScale(ShadowedLight.SpotDirection.AsVector, 1e10));
              end;
          else
            shadowMat := MakeShadowMatrix(AbsolutePosition, AbsoluteDirection,
              ShadowedLight.AbsolutePosition);
          end;

          ARci.PipelineTransformation.ViewMatrix := MatrixMultiply(
            shadowMat,
            ARci.PipelineTransformation.ViewMatrix);
          ARci.PipelineTransformation.ModelMatrix := IdentityHmgMatrix;

          Disable(stCullFace);
          Enable(stNormalize);
          SetPolygonOffset(-1, -1);
          Enable(stPolygonOffsetFill);

          oldIgnoreMaterials := ARci.ignoreMaterials;
          ARci.ignoreMaterials := True;
          ActiveTextureEnabled[ttTexture2D] := False;
          Disable(stLighting);
          Disable(stFog);

          glColor4fv(ShadowColor.AsAddress);

          if (spoUseStencil in ShadowOptions) then
          begin
            Enable(stBlend);
            Disable(stAlphaTest);
            SetBlendFunc(bfSrcAlpha, bfOneMinusSrcAlpha);
            SetStencilFunc(cfEqual, 1, 1);
            SetStencilOp(soKeep, soKeep, soZero);
          end
          else
            Disable(stBlend);

          if Assigned(FOnBeginRenderingShadows) then
            FOnBeginRenderingShadows(Self);
          if Assigned(FShadowingObject) then
          begin
            ModelMat := IdentityHmgMatrix;
            if FShadowingObject.Parent <> nil then
              MatrixMultiply(ModelMat, FShadowingObject.Parent.AbsoluteMatrix, ModelMat);
            MatrixMultiply(ModelMat, FShadowingObject.LocalMatrix^, ModelMat);
            ARci.PipelineTransformation.ModelMatrix := ModelMat;
            FShadowingObject.DoRender(ARci, True, (FShadowingObject.Count > 0));
          end
          else
          begin
            Scene.Objects.DoRender(ARci, True, True);
          end;
          if Assigned(FOnEndRenderingShadows) then
            FOnEndRenderingShadows(Self);

          ARci.ignoreMaterials := oldIgnoreMaterials;

          // Restore to "normal"
          ARci.PipelineTransformation.Pop;

        end;
        Disable(stStencilTest);
        Disable(stScissorTest);
        Disable(stPolygonOffsetFill);
      end;

      ARci.proxySubObject := oldProxySubObject;

      if ARenderChildren and (Count > 0) then
        Self.RenderChildren(0, Count - 1, ARci);
    end;
  finally
    FRendering := False;
  end;
end;

// Notification
//

procedure TVKShadowPlane.Notification(AComponent: TComponent; Operation: TOperation);
begin
  if Operation = opRemove then
  begin
    if AComponent = FShadowingObject then
      ShadowingObject := nil
    else if AComponent = FShadowedLight then
      ShadowedLight := nil;
  end;
  inherited;
end;

// SetShadowingObject
//

procedure TVKShadowPlane.SetShadowingObject(const val: TVKBaseSceneObject);
begin
  if FShadowingObject <> val then
  begin
    if Assigned(FShadowingObject) then
      FShadowingObject.RemoveFreeNotification(Self);
    FShadowingObject := val;
    if Assigned(FShadowingObject) then
      FShadowingObject.FreeNotification(Self);
    NotifyChange(Self);
  end;
end;

// SetShadowedLight
//

procedure TVKShadowPlane.SetShadowedLight(const val: TVKLightSource);
begin
  if FShadowedLight <> val then
  begin
    if Assigned(FShadowedLight) then
      FShadowedLight.RemoveFreeNotification(Self);
    FShadowedLight := val;
    if Assigned(FShadowedLight) then
      FShadowedLight.FreeNotification(Self);
    NotifyChange(Self);
  end;
end;

// SetShadowColor
//

procedure TVKShadowPlane.SetShadowColor(const val: TVKColor);
begin
  FShadowColor.Assign(val);
end;

// Assign
//

procedure TVKShadowPlane.Assign(Source: TPersistent);
begin
  if Assigned(Source) and (Source is TVKShadowPlane) then
  begin
    FShadowOptions := TVKShadowPlane(Source).FShadowOptions;
    ShadowingObject := TVKShadowPlane(Source).ShadowingObject;
    ShadowedLight := TVKShadowPlane(Source).ShadowedLight;
    ShadowColor := TVKShadowPlane(Source).ShadowColor;
  end;
  inherited Assign(Source);
end;

// SetShadowOptions
//

procedure TVKShadowPlane.SetShadowOptions(const val: TShadowPlaneOptions);
begin
  if FShadowOptions <> val then
  begin
    FShadowOptions := val;
    NotifyChange(Self);
  end;
end;

//-------------------------------------------------------------
//-------------------------------------------------------------
//-------------------------------------------------------------
initialization
  //-------------------------------------------------------------
  //-------------------------------------------------------------
  //-------------------------------------------------------------

  RegisterClasses([TVKShadowPlane]);

end.

