//
// This unit is part of the GLScene Project, http://glscene.org
//
{: GLBlur<p>

	Applies a blur effect over the viewport.<p>

	<b>History : </b><font size=-1><ul>
        <li>25/02/07 - DaStr  - Added DesignTime check in TGLMotionBlur.DoRender
        <li>23/02/07 - DaStr  - TGLMotionBlur.StoreIntensity bugfixed
                                TGLBlur - default values added to all properties,
                                Made some cosmetic and alignment changes
        <li>20/02/07 - DaStr  - TGLMotionBlur added (based on ToxBlur by Dave Gravel)
                                Added some default values to TGLBlur
        <li>11/06/04 - Mrqzzz - Creation
   </ul></font>
}
unit GLBlur;

interface

uses
  // VCL
  Classes, StdCtrls,

  // GLScene
  GLScene, VectorGeometry, GLMisc,  GLObjects, GLBitmapFont, GLTexture,
  GLHudObjects;

type
    TGLBlurPreset = (pNone,pGlossy,pBeastView,pOceanDepth,pDream,pOverBlur);

type
  TGLBlur = class (TGLHUDSprite)
  private
    FViewer : TGLMemoryViewer;
    OldTime :  Double;
    FDoingMemView : boolean;
    FBlurDeltaTime: Double;
    FBlurTop: Single;
    FBlurBottom: Single;
    FBlurLeft: Single;
    FBlurRight: Single;
    FRenderHeight: Integer;
    FRenderWidth: Integer;
    FPreset: TGLBlurPreset;
    procedure DoMemView(baseObject: TGLBaseSceneObject);
    procedure SetRenderHeight(const Value: Integer);
    procedure SetRenderWidth(const Value: Integer);
    procedure UpdateImageSettings;
    procedure SetPreset(const Value: TGLBlurPreset);

    function StoreBlurBottom: Boolean;
    function StoreBlurDeltaTime: Boolean;
    function StoreBlurRight: Boolean;
    function StoreBlurTop: Boolean;
    function StoreBlurLeft: Boolean;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure DoProgress(const progressTime : TProgressTimes); override;
    procedure DoRender(var rci : TRenderContextInfo;
                       renderSelf, renderChildren : Boolean); override;
  published
    property BlurDeltaTime: Double read FBlurDeltaTime write FBlurDeltaTime stored StoreBlurDeltaTime;
    property BlurLeft: Single read FBlurLeft write FBlurLeft stored StoreBlurLeft;
    property BlurTop: Single read FBlurTop write FBlurTop stored StoreBlurTop;
    property BlurRight: Single read FBlurRight write FBlurRight stored StoreBlurRight;
    property BlurBottom: Single read FBlurBottom write FBlurBottom stored StoreBlurBottom;
    property RenderWidth: Integer read FRenderWidth write SetRenderWidth default 256;
    property RenderHeight: Integer read FRenderHeight write SetRenderHeight default 256;
    property Preset: TGLBlurPreset read FPreset write SetPreset stored false;
  end;

{:
  This component blurs everything thatis rendered BEFORE it. So if you want part
  of your scene blured, the other not blured, make sure that the other part is
  rendered after this component.
  It is fast and does not require shaders.

  Note: it is FPS-dependant. Also also can produce a "blury trail effect", which
  stays on the screen until something new is rendered over it. It can be overcome
  by changing the Material.FrontProperties.Diffuse property. This, however, also
  has a drawback - the picture becomes more blured altogether. For example, if
  your backgroud color is Black, set the Material.FrontProperties.Diffuse to White.
  If it is White, set Material.FrontProperties.Diffuse to Black. I haven't tried
  any others, but I hope you get the idea ;)

  I've seen this effect in different Bruring components, even in shaders, but if
  anyone knows another way to fix this issue - please post it on the glscene
  newsgroup.
}
  TGLMotionBlur = class(TGLCustomSceneObject)
  private
    FIntensity: Single;
    function StoreIntensity: Boolean;
  public
    procedure DoRender(var rci: TRenderContextInfo; renderSelf, renderChildren: Boolean); override;
    constructor Create(aOwner: TComponent); override;
    procedure Assign(Source: TPersistent); override;
  published
    // The more the intersity, the more blur you have
    property Intensity: Single read FIntensity write FIntensity stored StoreIntensity;

    // From TGLBaseSceneObject.
    property Visible;
    property OnProgress;
    property Behaviours;
    property Effects;
    property Hint;
  end;

implementation

uses SysUtils, OpenGL1x, GLGraphics, XOpenGL, GLState;

const
  EPS = 0.001;

constructor TGLBlur.Create(AOwner: TComponent);
begin
  inherited;
  FBlurDeltaTime := 0.02;
  FBlurTop := 0.01;
  FBlurLeft := 0.01;
  FBlurRight := 0.01;
  FBlurBottom := 0.01;
  FRenderHeight := 256;
  FRenderWidth  := 256;
  FViewer := TGLMemoryViewer.create(self);
  FPreset := pNone;
  Material.Texture.Disabled := false;
  // init texture
  Material.Texture.ImageClassName := 'TGLBlankImage';
  TGLBlankImage(Material.Texture.Image).Width := FViewer.Width;
  TGLBlankImage(Material.Texture.Image).Height := FViewer.Height;
  Material.MaterialOptions := [moNoLighting];
  Material.Texture.TextureMode := TMModulate;  
  Material.BlendingMode := bmAdditive;
end;

destructor TGLBlur.Destroy;
begin
     FViewer.Free;
     inherited;
end;


procedure TGLBlur.UpdateImageSettings;
begin
     with TGLBlankImage(Material.Texture.Image) do
     begin
          Width := RenderWidth;
          Height := Renderheight;
     end;

     with FViewer do
     begin
          Width := RenderWidth;
          Height := Renderheight;
     end;
end;

procedure TGLBlur.DoProgress(const progressTime : TProgressTimes);
begin
     inherited;
     if self.Visible and (progressTime.newTime - OldTime > FBlurDeltaTime) then
     begin
          OldTime := progressTime.newTime;
          if Self.Parent is TGLBaseSceneObject then
             DoMemView(Self.Parent);
     end;

end;


procedure TGLBlur.DoMemView(baseObject: TGLBaseSceneObject);
var
   OldFocalLength:single;
   refsiz:single;
begin
     if FViewer.Camera<>Scene.CurrentGLCamera then
        FViewer.Camera := Scene.CurrentGLCamera;

     if FViewer.Camera<>nil then
     begin
          FDoingMemView := true;

          //Scene.RenderScene(FViewer.Buffer,FViewer.Width,FViewer.Height,dsRendering,baseObject);
          FViewer.Camera.BeginUpdate;

          OldFocalLength := FViewer.Camera.FocalLength;

          // CALCULATE SCALED FOCAL LENGTH FOR VIEWER
          if SCene.CurrentBuffer.Width>SCene.CurrentBuffer.height then
             refsiz := SCene.CurrentBuffer.Width
          else
              refsiz := SCene.CurrentBuffer.height;

          FViewer.Camera.FocalLength := FViewer.Camera.FocalLength*FViewer.Buffer.Width/refsiz;


          if FViewer.Buffer.BackgroundColor<>SCene.CurrentBuffer.BackgroundColor then
             FViewer.Buffer.BackgroundColor := SCene.CurrentBuffer.BackgroundColor;
          
          FViewer.Render(baseObject);
          FViewer.CopyToTexture(self.Material.Texture);


          FViewer.Camera.FocalLength := OldFocalLength;
          FViewer.Camera.EndUpdate;
          FDoingMemView := false;
     end;
end;

{$Warnings Off} //Suppress "unsafe" warning
procedure TGLBlur.DoRender(var rci : TRenderContextInfo;
                              renderSelf, renderChildren : Boolean);
var
	vx, vy, vx1, vy1, f : Single;
        offsx,offsy:single;
        MaxMeasure : integer;
begin

   if rci.ignoreMaterials then Exit;
  	Material.Apply(rci);
   repeat
      if AlphaChannel<>1 then
         rci.GLStates.SetGLMaterialAlphaChannel(GL_FRONT, AlphaChannel);
      // Prepare matrices
      glMatrixMode(GL_MODELVIEW);
      glPushMatrix;
      glLoadMatrixf(@Scene.CurrentBuffer.BaseProjectionMatrix);
      if rci.renderDPI=96 then
         f:=1
      else f:=rci.renderDPI/96;
      glScalef(2/rci.viewPortSize.cx, 2/rci.viewPortSize.cy, 1);

      // center of viewport:
      glTranslatef(0,0, Position.Z);

      if Rotation<>0 then
         glRotatef(Rotation, 0, 0, 1);
      glMatrixMode(GL_PROJECTION);
      glPushMatrix;
      glLoadIdentity;
      glPushAttrib(GL_ENABLE_BIT);
      glDisable(GL_DEPTH_TEST);
      glDepthMask(False);


     // calculate offsets in order to keep the quad a square centered in the view
     if rci.viewPortSize.cx>rci.viewPortSize.cy then
     begin
          offsx := 0;
          offsy := (rci.viewPortSize.cx-rci.viewPortSize.cy)*0.5;
          MaxMeasure := rci.viewPortSize.cx;
     end
     else
     begin
          offsx := (rci.viewPortSize.cy-rci.viewPortSize.cx)*0.5;
          offsy := 0;
          MaxMeasure := rci.viewPortSize.cy;
     end;

      // precalc coordinates
      vx:=-rci.viewPortSize.cx*0.5*f;     vx1:=vx+rci.viewPortSize.cx*f;
      vy:=+rci.viewPortSize.cy*0.5*f;     vy1:=vy-rci.viewPortSize.cy*f;


      vx := vx - offsx; vx1 := vx1 + offsx;
      vy := vy + offsy; vy1 := vy1 - offsy;

      // Cause the radial scaling
      if FDoingMemView then
      begin
           vx := vx - FBlurLeft*MaxMeasure;    vx1 := vx1 + FBlurRight*MaxMeasure;
           vy := vy + FBlurTop*MaxMeasure;    vy1 := vy1 - FBlurBottom*MaxMeasure;
      end;

      // issue quad
      glBegin(GL_QUADS);
         glNormal3fv(@YVector);
         xglTexCoord2f(0, 0);           glVertex2f( vx, vy1);
         xglTexCoord2f(XTiles, 0);      glVertex2f(vx1, vy1);
         xglTexCoord2f(XTiles, YTiles); glVertex2f(vx1,  vy);
         xglTexCoord2f(0, YTiles);      glVertex2f( vx,  vy);
      glEnd;
      // restore state
      glDepthMask(True);
      glPopAttrib;
      glPopMatrix;
      glMatrixMode(GL_MODELVIEW);
      glPopMatrix;
   until not Material.UnApply(rci);
   if Count>0 then
      Self.RenderChildren(0, Count-1, rci);
end;
{$Warnings On}

procedure TGLBlur.SetRenderHeight(const Value: integer);
begin
  FRenderHeight := Value;
  UpdateImageSettings;
end;

procedure TGLBlur.SetRenderWidth(const Value: integer);
begin
  FRenderWidth := Value;
  UpdateImageSettings;
end;

procedure TGLBlur.SetPreset(const Value: TGLBlurPreset);
begin
     FPreset := Value;

     case FPreset of
     pNone       : begin
                       // do nothing
                  end;
     pGlossy     : begin
                      Material.BlendingMode := bmAdditive;
                      Material.FrontProperties.Diffuse.SetColor(1, 1, 1, 0.7);
                      BlurTop := 0.02;
                      BlurLeft := 0.02;
                      BlurRight := 0.02;
                      BlurBottom := 0.02;
                      BlurDeltaTime := 0.02;

                  end;
     pBeastView  : begin
                      Material.BlendingMode := bmAdditive;
                      Material.FrontProperties.Diffuse.SetColor(1, 0, 0, 0.8);
                      BlurTop := 0.001;
                      BlurLeft := 0.03;
                      BlurRight := 0.03;
                      BlurBottom := 0.001;
                      BlurDeltaTime := 0.02;

                  end;
     pOceanDepth : begin
                      Material.BlendingMode := bmTransparency;
                      Material.FrontProperties.Diffuse.SetColor(0.2, 0.2, 1, 0.99);
                      BlurTop := 0.04;
                      BlurLeft := 0.02;
                      BlurRight := 0.02;
                      BlurBottom := 0.04;
                      BlurDeltaTime := 0.02;
                  end;
     pDream      : begin
                      Material.BlendingMode := bmTransparency;
                      Material.FrontProperties.Diffuse.SetColor(1, 1, 1, 0.992);
                      BlurTop := 0.02;
                      BlurLeft := 0.02;
                      BlurRight := 0.02;
                      BlurBottom := 0.02;
                      BlurDeltaTime := 0.1;
                  end;
     pOverBlur  : begin
                      Material.BlendingMode := bmAdditive;
                      Material.FrontProperties.Diffuse.SetColor(0.95,0.95, 0.95, 0.98);
                      BlurTop := 0.01;
                      BlurLeft := 0.01;
                      BlurRight := 0.01;
                      BlurBottom := 0.01;
                      BlurDeltaTime := 0.02;
                  end;
     end;

end;

function TGLBlur.StoreBlurBottom: Boolean;
begin
  Result := Abs(FBlurBottom - 0.01) > EPS;
end;

function TGLBlur.StoreBlurDeltaTime: Boolean;
begin
  Result := Abs(FBlurDeltaTime - 0.02) > EPS;
end;

function TGLBlur.StoreBlurLeft: Boolean;
begin
  Result := Abs(FBlurLeft - 0.01) > EPS;
end;

function TGLBlur.StoreBlurRight: Boolean;
begin
  Result := Abs(FBlurRight - 0.01) > EPS;
end;

function TGLBlur.StoreBlurTop: Boolean;
begin
  Result := Abs(FBlurTop - 0.01) > EPS;
end;

{ TGLMotionBlur }

procedure TGLMotionBlur.Assign(Source: TPersistent);
begin
  inherited;
  if Source is TGLMotionBlur then
  begin
    FIntensity := TGLMotionBlur(Source).FIntensity;
  end;
end;

constructor TGLMotionBlur.Create(aOwner: TComponent);
begin
  inherited Create(aOwner);
  Material.FrontProperties.Diffuse.Initialize(clrBlack);
  Material.MaterialOptions := [moNoLighting, moIgnoreFog];
  Material.Texture.Disabled := False;
  Material.BlendingMode := bmTransparency;
  FIntensity := 0.975;
end;

{$Warnings Off}
procedure TGLMotionBlur.DoRender(var rci: TRenderContextInfo; renderSelf, renderChildren: Boolean);
begin
  if rci.ignoreMaterials then Exit;
  if csDesigning in ComponentState then Exit;

  glPushMatrix;
    glEnable( GL_TEXTURE_RECTANGLE_NV );
    Material.Apply( rci );
    glMatrixMode( GL_PROJECTION );
    glPushMatrix;
      glLoadIdentity;
      glOrtho( 0, rci.viewPortSize.cx, rci.viewPortSize.cy, 0, 0, 1 );
      glMatrixMode(GL_MODELVIEW);
      glLoadMatrixf(@Scene.CurrentBuffer.BaseProjectionMatrix);
      glLoadIdentity;
      glDisable(GL_DEPTH_TEST);
      glDepthMask( FALSE );
      glBegin( GL_QUADS );
        glTexCoord2f( 0.0, rci.viewPortSize.cy ); glVertex2f( 0, 0 );
        glTexCoord2f( 0.0, 0.0); glVertex2f( 0, rci.viewPortSize.cy );
        glTexCoord2f( rci.viewPortSize.cx, 0.0 ); glVertex2f( rci.viewPortSize.cx, rci.viewPortSize.cy );
        glTexCoord2f( rci.viewPortSize.cx, rci.viewPortSize.cy ); glVertex2f( rci.viewPortSize.cx, 0 );
      glEnd;
      glDepthMask( TRUE );
      glMatrixMode( GL_PROJECTION );
    glPopMatrix;
    glMatrixMode( GL_MODELVIEW );
    Material.UnApply( rci );
    glDisable( GL_TEXTURE_RECTANGLE_NV );
  glPopMatrix;

  glCopyTexImage2D( GL_TEXTURE_RECTANGLE_NV, 0, GL_RGB, 0, 0, rci.viewPortSize.cx, rci.viewPortSize.cy, 0 );
  if Count>0 then Self.RenderChildren(0, Count-1, rci);

  Material.FrontProperties.Diffuse.Alpha := FIntensity;
  Material.FrontProperties.Diffuse.NotifyChange(Self);
end;
{$Warnings On}

function TGLMotionBlur.StoreIntensity: Boolean;
begin
  Result := Abs(FIntensity - 0.975) > EPS;
end;

// ------------------------------------------------------------------
// ------------------------------------------------------------------
// ------------------------------------------------------------------
initialization
// ------------------------------------------------------------------
// ------------------------------------------------------------------
// ------------------------------------------------------------------

   // class registrations
   RegisterClass(TGLBlur);
   RegisterClass(TGLMotionBlur);

end.
