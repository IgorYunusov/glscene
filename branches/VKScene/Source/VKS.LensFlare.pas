//
// VKScene project based on GLScene library, http://glscene.sourceforge.net 
//
{
   Lens flare object. 
 
}
unit VKS.LensFlare;

interface

{$I VKScene.inc}

uses
  System.Classes, System.SysUtils,

  VKS.Scene, VKS.VectorGeometry, VKS.Objects, VKS.OpenGLTokens,
  VKS.Context, VKS.Color, VKS.BaseClasses, VKS.RenderContextInfo, 
  VKS.State, VKS.VectorTypes, VKS.Utils, VKS.TextureFormat;

type

  // TFlareElement
  //
  TFlareElement = (feGlow, feRing, feStreaks, feRays, feSecondaries);
  TFlareElements = set of TFlareElement;

  { The actual gradients between two colors are, of course, calculated by OpenGL. 
     The start and end colors of a gradient are stored to represent the color of
     lens flare elements. }
  TVKFlareGradient = class(TVKUpdateAbleObject)
  private
    { Private Declarations }
    FFromColor: TVKColor;
    FToColor: TVKColor;

  protected
    { Protected Declarations }
    procedure SetFromColor(const val: TVKColor);
    procedure SetToColor(const val: TVKColor);

  public
    { Public Declarations }
    constructor Create(AOwner: TPersistent); override;
    constructor CreateInitialized(AOwner: TPersistent;
      const fromColor, toColor: TColorVector);
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;

  published
    { Public Declarations }
    property FromColor: TVKColor read FFromColor write SetFromColor;
    property ToColor: TVKColor read FToColor write SetToColor;
  end;

const
  cDefaultFlareElements = [feGlow, feRing, feStreaks, feRays, feSecondaries];

type

  // TVKLensFlare
  //
  TVKLensFlare = class(TVKBaseSceneObject)
  private
    { Private Declarations }
    FSize: Integer;
    FDeltaTime: Single;
    FCurrSize: Single;
    FSeed: Integer;
    FSqueeze: Single;
    FNumStreaks: Integer;
    FStreakWidth, FStreakAngle: Single;
    FNumSecs: Integer;
    FResolution: Integer;
    FAutoZTest: Boolean;
    FElements: TFlareElements;
    FSin20Res, FCos20Res: array of Single;
    FSinRes, FCosRes: array of Single;
    FTexRays: TVKTextureHandle;
    FFlareIsNotOccluded: Boolean;
    FOcclusionQuery: TVKOcclusionQueryHandle;
    FGlowGradient: TVKFlareGradient;
    FRingGradient: TVKFlareGradient;
    FStreaksGradient: TVKFlareGradient;
    FRaysGradient: TVKFlareGradient;
    FSecondariesGradient: TVKFlareGradient;
    FDynamic: Boolean;
    FPreRenderPoint: TVKRenderPoint;

  protected
    { Protected Declarations }
    procedure SetGlowGradient(const val: TVKFlareGradient);
    procedure SetRingGradient(const val: TVKFlareGradient);
    procedure SetStreaksGradient(const val: TVKFlareGradient);
    procedure SetRaysGradient(const val: TVKFlareGradient);
    procedure SetSecondariesGradient(const val: TVKFlareGradient);
    procedure SetSize(aValue: Integer);
    procedure SetSeed(aValue: Integer);
    procedure SetSqueeze(aValue: Single);
    function StoreSqueeze: Boolean;
    procedure SetNumStreaks(aValue: Integer);
    procedure SetStreakWidth(aValue: Single);
    function StoreStreakWidth: Boolean;
    procedure SetStreakAngle(aValue: Single);
    procedure SetNumSecs(aValue: Integer);
    procedure SetResolution(aValue: Integer);
    procedure SetAutoZTest(aValue: Boolean);
    procedure SetElements(aValue: TFlareElements);
    procedure SetDynamic(aValue: Boolean);
    procedure SetPreRenderPoint(const val: TVKRenderPoint);
    procedure PreRenderEvent(Sender: TObject; var rci: TRenderContextInfo);
    procedure PreRenderPointFreed(Sender: TObject);

    // These are quite unusual in that they don't use an RCI, since
    // PreRender is done before proper rendering starts, but we do know
    // which RC is being used, so we can use this state cache
    procedure SetupRenderingOptions(StateCache: TVKStateCache);

    procedure RenderRays(StateCache: TVKStateCache; const size: Single);
    procedure RenderStreaks(StateCache: TVKStateCache);
    procedure RenderRing;
    procedure RenderSecondaries(const posVector: TAffineVector);

  public
    { Public Declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Notification(AComponent: TComponent; Operation: TOperation);
      override;

    procedure BuildList(var rci: TRenderContextInfo); override;
    procedure DoProgress(const progressTime: TProgressTimes); override;

    { Prepares pre-rendered texture to speed up actual rendering. 
       Will use the currently active context as scratch space, and will
       automatically do nothing if things have already been prepared,
       thus you can invoke it systematically in a Viewer.BeforeRender
       event f.i. }
    procedure PreRender(activeBuffer: TVKSceneBuffer);
    { Access to the Flare's current size. 
       Flares decay or grow back over several frames, depending on their
       occlusion status, and this property allows to track or manually
       alter this instantaneous size. }
    property FlareInstantaneousSize: Single read FCurrSize write FCurrSize;

  published
    { Public Declarations }
    property GlowGradient: TVKFlareGradient read FGlowGradient write
      SetGlowGradient;
    property RingGradient: TVKFlareGradient read FRingGradient;
    property StreaksGradient: TVKFlareGradient read FStreaksGradient;
    property RaysGradient: TVKFlareGradient read FRaysGradient;
    property SecondariesGradient: TVKFlareGradient read FSecondariesGradient;

    //: MaxRadius of the flare.
    property Size: Integer read FSize write SetSize default 50;
    //: Random seed
    property Seed: Integer read FSeed write SetSeed;
    //: To create elliptic flares.
    property Squeeze: Single read FSqueeze write SetSqueeze stored StoreSqueeze;
    //: Number of streaks.
    property NumStreaks: Integer read FNumStreaks write SetNumStreaks default 4;
    //: Width of the streaks.
    property StreakWidth: Single read FStreakWidth write SetStreakWidth stored
      StoreStreakWidth;
    //: Angle of the streaks (in degrees)
    property StreakAngle: Single read FStreakAngle write SetStreakAngle;
    //: Number of secondary flares.
    property NumSecs: Integer read FNumSecs write SetNumSecs default 8;
    //: Number of segments used when rendering circles.
    property Resolution: Integer read FResolution write SetResolution default
      64;
    { Automatically computes FlareIsNotOccluded depending on ZBuffer test. 
       Not that the automated test may use test result from the previous
       frame into the next (to avoid a rendering stall). }
    property AutoZTest: Boolean read FAutoZTest write SetAutoZTest default True;
    { Is the LensFlare not occluded?. 
       If false the flare will fade away, if true, it will fade in and stay.
       This value is automatically updated if AutoZTest is set. }
    property FlareIsNotOccluded: Boolean read FFlareIsNotOccluded write
      FFlareIsNotOccluded;
    //: Which elements should be rendered?
    property Elements: TFlareElements read FElements write SetElements default
      cDefaultFlareElements;
    { Is the flare size adjusted dynamically? 
       If true, the flare size will be grown and reduced over a few frames
       when it switches between occluded and non-occluded states. This
       requires animation to be active, but results in a smoother appearance. 
       When false, flare will either be at full size or hidden. 
       The flare is always considered non-dynamic at design-time. }
    property Dynamic: Boolean read FDynamic write FDynamic default True;

    { PreRender point for pre-rendered flare textures. 
       See PreRender method for more details. }
    property PreRenderPoint: TVKRenderPoint read FPreRenderPoint write
      SetPreRenderPoint;

    property ObjectsSorting;
    property Position;
    property Visible;
    property OnProgress;
    property Behaviours;
    property Effects;
  end;

  // ------------------------------------------------------------------
  // ------------------------------------------------------------------
  // ------------------------------------------------------------------
implementation
// ------------------
// ------------------ TVKFlareGradient ------------------
// ------------------

// Create
//

constructor TVKFlareGradient.Create(AOwner: TPersistent);
begin
  inherited;
  FFromColor := TVKColor.Create(Self);
  FToColor := TVKColor.Create(Self);
end;

// CreateInitialized
//

constructor TVKFlareGradient.CreateInitialized(AOwner: TPersistent;
  const fromColor, toColor: TColorVector);
begin
  Create(AOwner);
  FFromColor.Initialize(fromColor);
  FToColor.Initialize(toColor);
end;

// Destroy
//

destructor TVKFlareGradient.Destroy;
begin
  FToColor.Free;
  FFromColor.Free;
  inherited;
end;

// Assign
//

procedure TVKFlareGradient.Assign(Source: TPersistent);
begin
  if Source is TVKFlareGradient then
  begin
    FromColor := TVKFlareGradient(Source).FromColor;
    ToColor := TVKFlareGradient(Source).ToColor;
  end;
  inherited;
end;

// SetFromColor
//

procedure TVKFlareGradient.SetFromColor(const val: TVKColor);
begin
  FFromColor.Assign(val);
end;

// SetToColor
//

procedure TVKFlareGradient.SetToColor(const val: TVKColor);
begin
  FToColor.Assign(val);
end;

// ------------------
// ------------------ TVKLensFlare ------------------
// ------------------

// Create
//

constructor TVKLensFlare.Create(AOwner: TComponent);
begin
  inherited;
  // Set default parameters:
  ObjectStyle := ObjectStyle + [osDirectDraw, osNoVisibilityCulling];
  FSize := 50;
  FSeed := 1465;
  FSqueeze := 1;
  FNumStreaks := 4;
  FStreakWidth := 2;
  FNumSecs := 8;
  FAutoZTest := True;
  FlareIsNotOccluded := True;
  FDynamic := True;

  SetResolution(64);

  // Render all elements by default.
  FElements := [feGlow, feRing, feStreaks, feRays, feSecondaries];
  // Setup default gradients:
  FGlowGradient := TVKFlareGradient.CreateInitialized(Self,
    VectorMake(1, 1, 0.8, 0.3), VectorMake(1, 0.2, 0, 0));
  FRingGradient := TVKFlareGradient.CreateInitialized(Self,
    VectorMake(0.5, 0.2, 0, 0.1), VectorMake(0.5, 0.4, 0, 0.1));
  FStreaksGradient := TVKFlareGradient.CreateInitialized(Self,
    VectorMake(1, 1, 1, 0.2), VectorMake(0.2, 0, 1, 0));
  FRaysGradient := TVKFlareGradient.CreateInitialized(Self,
    VectorMake(1, 0.8, 0.5, 0.05), VectorMake(0.5, 0.2, 0, 0));
  FSecondariesGradient := TVKFlareGradient.CreateInitialized(Self,
    VectorMake(0, 0.2, 1, 0), VectorMake(0, 0.8, 0.2, 0.15));

  FTexRays := TVKTextureHandle.Create;
end;

// Destroy
//

destructor TVKLensFlare.Destroy;
begin
  PreRenderPoint := nil;
  FGlowGradient.Free;
  FRingGradient.Free;
  FStreaksGradient.Free;
  FRaysGradient.Free;
  FSecondariesGradient.Free;
  FOcclusionQuery.Free;
  FTexRays.Free;
  inherited;
end;

// Notification
//

procedure TVKLensFlare.Notification(AComponent: TComponent; Operation:
  TOperation);
begin
  if (Operation = opRemove) and (AComponent = FPreRenderPoint) then
    PreRenderPoint := nil;
  inherited;
end;

// SetupRenderingOptions
//

procedure TVKLensFlare.SetupRenderingOptions(StateCache: TVKStateCache);
begin
  with StateCache do
  begin
    Disable(stLighting);
    Disable(stDepthTest);
    Disable(stFog);
    Disable(stColorMaterial);
    Disable(stCullFace);
    DepthWriteMask := False;
    Enable(stBlend);
    SetBlendFunc(bfSrcAlpha, bfOne);
    Disable(stAlphaTest);
    PolygonMode := pmFill;
  end;
end;

// RenderRays
//

procedure TVKLensFlare.RenderRays(StateCache: TVKStateCache; const size:
  Single);
var
  i: Integer;
  rnd: Single;
begin
{$IFDEF VKS_OPENGL_DEBUG}
  if GL.GREMEDY_string_marker then
    GL.StringMarkerGREMEDY(14, 'LensFlare.Rays');
{$ENDIF}

  with StateCache do
  begin
    LineWidth := 1;
    Disable(stLineSmooth);
    Disable(stLineStipple);
  end;

  GL.Begin_(GL_LINES);
  for i := 0 to Resolution * 20 - 1 do
  begin
    if (i and 1) <> 0 then
      rnd := 1.5 * Random * size
    else
      rnd := Random * size;
    GL.Color4fv(RaysGradient.FromColor.AsAddress);
    GL.Vertex2f(0, 0);
    GL.Color4fv(RaysGradient.ToColor.AsAddress);
    GL.Vertex2f(rnd * FCos20Res[i], rnd * FSin20Res[i] * Squeeze);
  end;
  GL.End_;
end;

// RenderStreak
//

procedure TVKLensFlare.RenderStreaks(StateCache: TVKStateCache);
var
  i: Integer;
  a, f, s, c: Single;
begin
{$IFDEF VKS_OPENGL_DEBUG}
  if GL.GREMEDY_string_marker then
    GL.StringMarkerGREMEDY(17, 'LensFlare.Streaks');
{$ENDIF}
  StateCache.Enable(stLineSmooth);
  StateCache.LineWidth := StreakWidth;
  a := c2PI / NumStreaks;
  f := 1.5 * FCurrSize;
  GL.Begin_(GL_LINES);
  for i := 0 to NumStreaks - 1 do
  begin
    SinCosine(StreakAngle * cPIdiv180 + a * i, f, s, c);
    GL.Color4fv(StreaksGradient.FromColor.AsAddress);
    GL.Vertex3fv(@NullVector);
    GL.Color4fv(StreaksGradient.ToColor.AsAddress);
    GL.Vertex2f(c, Squeeze * s);
  end;
  GL.End_;
  StateCache.Disable(stLineSmooth);
end;

// RenderRing
//

procedure TVKLensFlare.RenderRing;
var
  i: Integer;
  rW, s0, c0, s, c: Single;
begin
{$IFDEF VKS_OPENGL_DEBUG}
  if GL.GREMEDY_string_marker then
    GL.StringMarkerGREMEDY(14, 'LensFlare.Ring');
{$ENDIF}
  rW := FCurrSize * (1 / 15); // Ring width
  GL.Begin_(GL_QUADS);
  s0 := 0;
  c0 := 0.6;
  for i := 0 to Resolution - 1 do
  begin
    s := s0;
    c := c0;
    s0 := FSinRes[i] * 0.6 * Squeeze;
    c0 := FCosRes[i] * 0.6;

    GL.Color4fv(GlowGradient.ToColor.AsAddress);
    GL.Vertex2f((FCurrSize - rW) * c, (FCurrSize - rW) * s);
    GL.Color4fv(RingGradient.FromColor.AsAddress);
    GL.Vertex2f(FCurrSize * c, Squeeze * FCurrSize * s);

    GL.Vertex2f(FCurrSize * c0, FCurrSize * s0);
    GL.Color4fv(GlowGradient.ToColor.AsAddress);
    GL.Vertex2f((FCurrSize - rW) * c0, (FCurrSize - rW) * s0);

    GL.Color4fv(RingGradient.FromColor.AsAddress);
    GL.Vertex2f(FCurrSize * c, FCurrSize * s);
    GL.Vertex2f(FCurrSize * c0, FCurrSize * s0);

    GL.Color4fv(GlowGradient.ToColor.AsAddress);
    GL.Vertex2f((FCurrSize + rW) * c0, (FCurrSize + rW) * s0);
    GL.Vertex2f((FCurrSize + rW) * c, (FCurrSize + rW) * s);
  end;
  GL.End_;
end;

// RenderSecondaries
//

procedure TVKLensFlare.RenderSecondaries(const posVector: TAffineVector);
var
  i, j: Integer;
  rnd: Single;
  v: TAffineVector;
  grad: TVKFlareGradient;
begin
{$IFDEF VKS_OPENGL_DEBUG}
  if GL.GREMEDY_string_marker then
    GL.StringMarkerGREMEDY(21, 'LensFlare.Secondaries');
{$ENDIF}
  // Other secondaries (plain gradiented circles, like the glow):
  for j := 1 to NumSecs do
  begin
    rnd := 2 * Random - 1;
    // If rnd < 0 then the secondary glow will end up on the other side
    // of the origin. In this case, we can push it really far away from
    // the flare. If  the secondary is on the flare's side, we pull it
    // slightly towards the origin to avoid it winding up in the middle
    // of the flare.
    if rnd < 0 then
      v := VectorScale(posVector, rnd)
    else
      v := VectorScale(posVector, 0.8 * rnd);
    if j mod 3 = 0 then
      grad := GlowGradient
    else
      grad := SecondariesGradient;
    rnd := (Random + 0.1) * FCurrSize * 0.25;

    GL.Begin_(GL_TRIANGLE_FAN);
    GL.Color4fv(grad.FromColor.AsAddress);
    GL.Vertex2f(v.V[0], v.V[1]);
    GL.Color4fv(grad.ToColor.AsAddress);
    for i := 0 to Resolution - 1 do
      GL.Vertex2f(FCosRes[i] * rnd + v.V[0], FSinRes[i] * rnd + v.V[1]);
    GL.End_;
  end;
end;

// BuildList
//

procedure TVKLensFlare.BuildList(var rci: TRenderContextInfo);
var
  i: Integer;
  depth, dist: Single;
  posVector, v, rv: TAffineVector;
  screenPos: TAffineVector;
  flareInViewPort, dynamicSize: Boolean;
  oldSeed: LongInt;
  projMatrix: TMatrix;
  CurrentBuffer: TVKSceneBuffer;
begin
  if (rci.drawState = dsPicking) then
  begin
    if Count <> 0 then
      Self.RenderChildren(0, Count - 1, rci);
    Exit;
  end;
  CurrentBuffer := TVKSceneBuffer(rci.buffer);

  SetVector(v, AbsolutePosition);
  // are we looking towards the flare?
  rv := VectorSubtract(v, PAffineVector(@rci.cameraPosition)^);
  if VectorDotProduct(rci.cameraDirection, rv) > 0 then
  begin
    // find out where it is on the screen.
    screenPos := CurrentBuffer.WorldToScreen(v);
    flareInViewPort := (screenPos.V[0] < rci.viewPortSize.cx)
    and (screenPos.V[0] >= 0)
    and (screenPos.V[1] < rci.viewPortSize.cy)
    and (screenPos.V[1] >= 0);
  end
  else
    flareInViewPort := False;

  dynamicSize := FDynamic and not (csDesigning in ComponentState);
  if dynamicSize then
  begin
    // make the glow appear/disappear progressively
    if flareInViewPort and FlareIsNotOccluded then
    begin
      FCurrSize := FCurrSize + FDeltaTime * 10 * Size;
      if FCurrSize > Size then
        FCurrSize := Size;
    end
    else
    begin
      FCurrSize := FCurrSize - FDeltaTime * 10 * Size;
      if FCurrSize < 0 then
        FCurrSize := 0;
    end;
  end
  else
  begin
    if flareInViewPort and FlareIsNotOccluded then
      FCurrSize := Size
    else
      FCurrSize := 0;
  end;

  // Prepare matrices
  GL.PushMatrix;
  GL.LoadMatrixf(@CurrentBuffer.BaseProjectionMatrix);

  GL.MatrixMode(GL_PROJECTION);
  GL.PushMatrix;
  projMatrix := IdentityHmgMatrix;
  projMatrix.V[0].V[0] := 2 / rci.viewPortSize.cx;
  projMatrix.V[1].V[1] := 2 / rci.viewPortSize.cy;
  GL.LoadMatrixf(@projMatrix);

  MakeVector(posVector,
    screenPos.V[0] - rci.viewPortSize.cx * 0.5,
    screenPos.V[1] - rci.viewPortSize.cy * 0.5,
    0);

  if AutoZTest then
  begin
    if dynamicSize and (GL.HP_occlusion_test or
      TVKOcclusionQueryHandle.IsSupported) then
    begin
      // hardware-based occlusion test is possible
      FlareIsNotOccluded := True;

      rci.GLStates.SetColorMask([]);
      rci.GLStates.Disable(stAlphaTest);
      rci.GLStates.DepthWriteMask := False;
      rci.GLStates.Enable(stDepthTest);
      rci.GLStates.DepthFunc := cfLEqual;

      if TVKOcclusionQueryHandle.IsSupported then
      begin
        // preferred method, doesn't stall rendering too badly
        if not Assigned(FOcclusionQuery) then
          FOcclusionQuery := TVKOcclusionQueryHandle.Create;
        FOcclusionQuery.AllocateHandle;
        if FOcclusionQuery.IsDataNeedUpdate then
          FOcclusionQuery.NotifyDataUpdated
        else
          FlareIsNotOccluded := (FOcclusionQuery.PixelCount <> 0);
        FOcclusionQuery.BeginQuery;
      end
      else
      begin
        // occlusion_test, stalls rendering a bit
        GL.Enable(GL_OCCLUSION_TEST_HP);
      end;

      GL.Begin_(GL_QUADS);
      GL.Vertex3f(posVector.V[0] + 2, posVector.V[1], 1);
      GL.Vertex3f(posVector.V[0], posVector.V[1] + 2, 1);
      GL.Vertex3f(posVector.V[0] - 2, posVector.V[1], 1);
      GL.Vertex3f(posVector.V[0], posVector.V[1] - 2, 1);
      GL.End_;

      if TVKOcclusionQueryHandle.IsSupported then
        FOcclusionQuery.EndQuery
      else
      begin
        GL.Disable(GL_OCCLUSION_TEST_HP);
        GL.GetBooleanv(GL_OCCLUSION_TEST_RESULT_HP, @FFlareIsNotOccluded)
      end;

      rci.GLStates.DepthFunc := cfLEqual;
      rci.GLStates.SetColorMask(cAllColorComponents);
    end
    else
    begin
      //Compares the distance to the lensflare, to the z-buffer depth.
      //This prevents the flare from being occluded by objects BEHIND the light.
      depth := CurrentBuffer.PixelToDistance(Round(ScreenPos.V[0]),
        Round(rci.viewPortSize.cy - ScreenPos.V[1]));
      dist := VectorDistance(rci.cameraPosition, self.AbsolutePosition);
      FlareIsNotOccluded := ((dist - depth) < 1);
    end;
  end;

  if FCurrSize >= 0 then
  begin

    // Random seed must be backed up, could be used for other purposes
    // (otherwise we essentially reset the random generator at each frame)
    oldSeed := RandSeed;
    RandSeed := Seed;

    SetupRenderingOptions(rci.GLStates);

    if [feGlow, feStreaks, feRays, feRing] * Elements <> [] then
    begin
      GL.Translatef(posVector.V[0], posVector.V[1], posVector.V[2]);

      // Glow (a circle with transparent edges):
      if feGlow in Elements then
      begin
        GL.Begin_(GL_TRIANGLE_FAN);
        GL.Color4fv(GlowGradient.FromColor.AsAddress);
        GL.Vertex2f(0, 0);
        GL.Color4fv(GlowGradient.ToColor.AsAddress);
        for i := 0 to Resolution - 1 do
          GL.Vertex2f(FCurrSize * FCosRes[i],
            Squeeze * FCurrSize * FSinRes[i]);
        GL.End_;
      end;

      if feStreaks in Elements then
        RenderStreaks(rci.GLStates);

      // Rays (random-length lines from the origin):
      if feRays in Elements then
      begin
        if FTexRays.Handle <> 0 then
        begin
        {$IFDEF VKS_OPENGL_DEBUG}
          if GL.GREMEDY_string_marker then
            GL.StringMarkerGREMEDY(19, 'LensFlare.RaysQuad');
        {$ENDIF}
          rci.GLStates.TextureBinding[0, ttTexture2D] := FTexRays.Handle;
          rci.GLStates.ActiveTextureEnabled[ttTexture2D] := True;
          GL.TexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_REPLACE);

          GL.Begin_(GL_QUADS);
          GL.TexCoord2f(0, 0);
          GL.Vertex2f(-FCurrSize, -FCurrSize);
          GL.TexCoord2f(1, 0);
          GL.Vertex2f(FCurrSize, -FCurrSize);
          GL.TexCoord2f(1, 1);
          GL.Vertex2f(FCurrSize, FCurrSize);
          GL.TexCoord2f(0, 1);
          GL.Vertex2f(-FCurrSize, FCurrSize);
          GL.End_;

          rci.GLStates.ActiveTextureEnabled[ttTexture2D] := False;
        end
        else
          RenderRays(rci.GLStates, FCurrSize);
      end;

      if feRing in Elements then
        RenderRing;

      GL.LoadMatrixf(@projMatrix);
    end;

    if feSecondaries in Elements then
      RenderSecondaries(posVector);

    RandSeed := oldSeed;
  end;

  GL.PopMatrix;
  GL.MatrixMode(GL_MODELVIEW);
  GL.PopMatrix;

  if Count > 0 then
    Self.RenderChildren(0, Count - 1, rci);
end;

// DoProgress
//

procedure TVKLensFlare.DoProgress(const progressTime: TProgressTimes);
begin
  inherited;
  FDeltaTime := progressTime.deltaTime;
end;

// PreRender
//

procedure TVKLensFlare.PreRender(activeBuffer: TVKSceneBuffer);
var
  i, texSize, maxSize: Integer;
  stateCache: TVKStateCache;
begin
  if FTexRays.Handle <> 0 then
    Exit;
  with activeBuffer.RenderingContext do
  begin
    stateCache := GLStates;
    PipelineTransformation.Push;
    PipelineTransformation.ProjectionMatrix := CreateOrthoMatrix(0, activeBuffer.Width, 0, activeBuffer.Height, -1, 1);
    PipelineTransformation.ViewMatrix := IdentityHmgMatrix;
  end;
  SetupRenderingOptions(stateCache);

  texSize := RoundUpToPowerOf2(Size);
  if texSize < Size * 1.5 then
    texSize := texSize * 2;
  GL.GetIntegerv(GL_MAX_TEXTURE_SIZE, @maxSize);
  if texSize > maxSize then
    texSize := maxSize;

  stateCache.Disable(stBlend);
  GL.Color4f(0, 0, 0, 0);
  GL.Begin_(GL_QUADS);
  GL.Vertex2f(0, 0);
  GL.Vertex2f(texSize + 4, 0);
  GL.Vertex2f(texSize + 4, texSize + 4);
  GL.Vertex2f(0, texSize + 4);
  GL.End_;
  stateCache.Enable(stBlend);

  GL.Translatef(texSize * 0.5 + 2, texSize * 0.5 + 2, 0);
  RenderRays(stateCache, texSize * 0.5);

  FTexRays.AllocateHandle;
  stateCache.TextureBinding[0, ttTexture2D] := FTexRays.Handle;
  if GL.EXT_texture_edge_clamp then
    i := GL_CLAMP_TO_EDGE
  else
    i := GL_CLAMP;
  GL.TexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, i);
  GL.TexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, i);
  GL.TexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
  GL.TexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);

  GL.CopyTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, 2, 2, texSize, texSize, 0);

  activeBuffer.RenderingContext.PipelineTransformation.Pop;

  GL.CheckError;
end;

// SetGlowGradient
//

procedure TVKLensFlare.SetGlowGradient(const val: TVKFlareGradient);
begin
  FGlowGradient.Assign(val);
  StructureChanged;
end;

// SetRingGradient
//

procedure TVKLensFlare.SetRingGradient(const val: TVKFlareGradient);
begin
  FRingGradient.Assign(val);
  StructureChanged;
end;

// SetStreaksGradient
//

procedure TVKLensFlare.SetStreaksGradient(const val: TVKFlareGradient);
begin
  FStreaksGradient.Assign(val);
  StructureChanged;
end;

// SetRaysGradient
//

procedure TVKLensFlare.SetRaysGradient(const val: TVKFlareGradient);
begin
  FRaysGradient.Assign(val);
  StructureChanged;
end;

// SetSecondariesGradient
//

procedure TVKLensFlare.SetSecondariesGradient(const val: TVKFlareGradient);
begin
  FSecondariesGradient.Assign(val);
  StructureChanged;
end;

// SetSize
//

procedure TVKLensFlare.SetSize(aValue: Integer);
begin
  FSize := aValue;
  StructureChanged;
end;

// SetSeed
//

procedure TVKLensFlare.SetSeed(aValue: Integer);
begin
  FSeed := aValue;
  StructureChanged;
end;

// SetSqueeze
//

procedure TVKLensFlare.SetSqueeze(aValue: Single);
begin
  FSqueeze := aValue;
  StructureChanged;
end;

// StoreSqueeze
//

function TVKLensFlare.StoreSqueeze: Boolean;
begin
  Result := (FSqueeze <> 1);
end;

// SetNumStreaks
//

procedure TVKLensFlare.SetNumStreaks(aValue: Integer);
begin
  FNumStreaks := aValue;
  StructureChanged;
end;

// SetStreakWidth
//

procedure TVKLensFlare.SetStreakWidth(aValue: Single);
begin
  FStreakWidth := aValue;
  StructureChanged;
end;

// StoreStreakWidth
//

function TVKLensFlare.StoreStreakWidth: Boolean;
begin
  Result := (FStreakWidth <> 2);
end;

// SetStreakAngle
//

procedure TVKLensFlare.SetStreakAngle(aValue: Single);
begin
  FStreakAngle := aValue;
  StructureChanged;
end;

// SetNumSecs
//

procedure TVKLensFlare.SetNumSecs(aValue: Integer);
begin
  FNumSecs := aValue;
  StructureChanged;
end;

// SetResolution
//

procedure TVKLensFlare.SetResolution(aValue: Integer);
begin
  if FResolution <> aValue then
  begin
    FResolution := aValue;
    StructureChanged;
    SetLength(FSin20Res, 20 * FResolution);
    SetLength(FCos20Res, 20 * FResolution);
    PrepareSinCosCache(FSin20Res, FCos20Res, 0, 360);
    SetLength(FSinRes, FResolution);
    SetLength(FCosRes, FResolution);
    PrepareSinCosCache(FSinRes, FCosRes, 0, 360);
  end;
end;

// SetAutoZTest
//

procedure TVKLensFlare.SetAutoZTest(aValue: Boolean);
begin
  if FAutoZTest <> aValue then
  begin
    FAutoZTest := aValue;
    StructureChanged;
  end;
end;

// SetElements
//

procedure TVKLensFlare.SetElements(aValue: TFlareElements);
begin
  if FElements <> aValue then
  begin
    FElements := aValue;
    StructureChanged;
  end;
end;

// SetDynamic
//

procedure TVKLensFlare.SetDynamic(aValue: Boolean);
begin
  if aValue <> FDynamic then
  begin
    FDynamic := aValue;
    NotifyChange(Self);
  end;
end;

// SetPreRenderPoint
//

procedure TVKLensFlare.SetPreRenderPoint(const val: TVKRenderPoint);
begin
  if val <> FPreRenderPoint then
  begin
    if Assigned(FPreRenderPoint) then
      FPreRenderPoint.UnRegisterCallBack(Self.PreRenderEvent);
    FPreRenderPoint := val;
    if Assigned(FPreRenderPoint) then
      FPreRenderPoint.RegisterCallBack(Self.PreRenderEvent,
        Self.PreRenderPointFreed);
  end;
end;

// PreRenderEvent
//

procedure TVKLensFlare.PreRenderEvent(Sender: TObject; var rci:
  TRenderContextInfo);
begin
  PreRender(rci.buffer as TVKSceneBuffer);
end;

// PreRenderPointFreed
//

procedure TVKLensFlare.PreRenderPointFreed(Sender: TObject);
begin
  FPreRenderPoint := nil;
end;

// ------------------------------------------------------------------
// ------------------------------------------------------------------
// ------------------------------------------------------------------
initialization
  // ------------------------------------------------------------------
  // ------------------------------------------------------------------
  // ------------------------------------------------------------------

  RegisterClasses([TVKLensFlare]);

end.
