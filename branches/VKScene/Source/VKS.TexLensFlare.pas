//
// VKScene project based on GLScene library, http://glscene.sourceforge.net 
//
{
   Texture-based Lens flare object. 
   
}
unit VKS.TexLensFlare;

interface

{$I VKScene.inc}

uses
  System.Classes,

  VKS.Scene, VKS.VectorGeometry, VKS.Objects, VKS.Texture,
  VKS.OpenGLTokens, VKS.Context, VKS.RenderContextInfo, VKS.BaseClasses,
  VKS.State, VKS.VectorTypes;

type

  // TVKTextureLensFlare
  //
  TVKTextureLensFlare = class(TVKBaseSceneObject)
  private
    { Private Declarations }
    FSize: integer;
    FCurrSize: Single;
    FNumSecs: integer;
    FAutoZTest: boolean;
    //used for internal calculation
    FDeltaTime: Double;
    FImgSecondaries: TVKTexture;
    FImgRays: TVKTexture;
    FImgRing: TVKTexture;
    FImgGlow: TVKTexture;
    FSeed: Integer;
    procedure SetImgGlow(const Value: TVKTexture);
    procedure SetImgRays(const Value: TVKTexture);
    procedure SetImgRing(const Value: TVKTexture);
    procedure SetImgSecondaries(const Value: TVKTexture);
    procedure SetSeed(const Value: Integer);
  protected
    { Protected Declarations }
    procedure SetSize(aValue: integer);
    procedure SetNumSecs(aValue: integer);
    procedure SetAutoZTest(aValue: boolean);
  public
    { Public Declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure BuildList(var rci: TRenderContextInfo); override;
    procedure DoProgress(const progressTime: TProgressTimes); override;
  published
    { Public Declarations }
    //: MaxRadius of the flare.
    property Size: integer read FSize write SetSize default 50;
    //: Random seed
    property Seed: Integer read FSeed write SetSeed;
    //: Number of secondary flares.
    property NumSecs: integer read FNumSecs write SetNumSecs default 8;
    //: Number of segments used when rendering circles.
    //property Resolution: integer read FResolution write SetResolution default 64;
    property AutoZTest: boolean read FAutoZTest write SetAutoZTest default True;
    // The Textures
    property ImgGlow: TVKTexture read FImgGlow write SetImgGlow;
    property ImgRays: TVKTexture read FImgRays write SetImgRays;
    property ImgRing: TVKTexture read FImgRing write SetImgRing;
    property ImgSecondaries: TVKTexture read FImgSecondaries write SetImgSecondaries;

    property ObjectsSorting;
    property Position;
    property Visible;
    property OnProgress;
    property Behaviours;
    property Effects;
  end;

implementation
// ------------------
// ------------------ TVKTextureLensFlare ------------------
// ------------------

constructor TVKTextureLensFlare.Create(AOwner: TComponent);
begin
  inherited;
  Randomize;
  FSeed := Random(2000) + 465;

  // Set default parameters:
  ObjectStyle := ObjectStyle + [osDirectDraw, osNoVisibilityCulling];
  FSize := 50;
  FCurrSize := FSize;
  FNumSecs := 8;
  FAutoZTest := True;

  FImgRays := TVKTexture.Create(Self);
  FImgSecondaries := TVKTexture.Create(Self);
  FImgRing := TVKTexture.Create(Self);
  FImgGlow := TVKTexture.Create(Self);
end;

procedure TVKTextureLensFlare.SetSize(aValue: integer);
begin
  if FSize <> aValue then
  begin
    FSize := aValue;
    FCurrSize := FSize;
    StructureChanged;
  end;
end;

procedure TVKTextureLensFlare.SetNumSecs(aValue: integer);
begin
  if FNumSecs <> aValue then
  begin
    FNumSecs := aValue;
    StructureChanged;
  end;
end;

// SetAutoZTest
//

procedure TVKTextureLensFlare.SetAutoZTest(aValue: boolean);
begin
  if FAutoZTest <> aValue then
  begin
    FAutoZTest := aValue;
    StructureChanged;
  end;
end;

// BuildList
//

procedure TVKTextureLensFlare.BuildList(var rci: TRenderContextInfo);
var
  v, rv, screenPos, posVector: TAffineVector;
  depth, rnd: Single;
  flag: Boolean;
  i: Integer;
  CurrentBuffer: TVKSceneBuffer;
begin
  CurrentBuffer := TVKSceneBuffer(rci.buffer);
  SetVector(v, AbsolutePosition);
  // are we looking towards the flare?
  rv := VectorSubtract(v, PAffineVector(@rci.cameraPosition)^);
  if VectorDotProduct(rci.cameraDirection, rv) > 0 then
  begin
    // find out where it is on the screen.
    screenPos := CurrentBuffer.WorldToScreen(v);
    if (screenPos.V[0] < rci.viewPortSize.cx) and (screenPos.V[0] >= 0)
      and (screenPos.V[1] < rci.viewPortSize.cy) and (screenPos.V[1] >= 0) then
    begin
      if FAutoZTest then
      begin
        depth := CurrentBuffer.GetPixelDepth(Round(ScreenPos.V[0]),
          Round(rci.viewPortSize.cy - ScreenPos.V[1]));
        // but is it behind something?
        if screenPos.V[2] >= 1 then
          flag := (depth >= 1)
        else
          flag := (depth >= screenPos.V[2]);
      end
      else
        flag := True;
    end
    else
      flag := False;
  end
  else
    flag := False;

  MakeVector(posVector,
    screenPos.V[0] - rci.viewPortSize.cx / 2,
    screenPos.V[1] - rci.viewPortSize.cy / 2, 0);

  // make the glow appear/disappear progressively

  if Flag then
    if FCurrSize < FSize then
      FCurrSize := FCurrSize + FDeltaTime * 200 {FSize * 4};
  if not Flag then
    if FCurrSize > 0 then
      FCurrSize := FCurrSize - FDeltaTime * 200 {FSize * 4};
  if FCurrSize <= 0 then
    Exit;

  // Prepare matrices
  GL.MatrixMode(GL_MODELVIEW);
  GL.PushMatrix;
  GL.LoadMatrixf(@CurrentBuffer.BaseProjectionMatrix);

  GL.MatrixMode(GL_PROJECTION);
  GL.PushMatrix;
  GL.LoadIdentity;
  GL.Scalef(2 / rci.viewPortSize.cx, 2 / rci.viewPortSize.cy, 1);

  rci.GLStates.Disable(stLighting);
  rci.GLStates.Disable(stDepthTest);
  rci.GLStates.Enable(stBlend);
  rci.GLStates.SetBlendFunc(bfOne, bfOne);

  //Rays and Glow on Same Position
  GL.PushMatrix;
  GL.Translatef(posVector.V[0], posVector.V[1], posVector.V[2]);

  if not ImgGlow.Disabled and Assigned(ImgGlow.Image) then
  begin
    ImgGlow.Apply(rci);
    GL.begin_(GL_QUADS);
    GL.TexCoord2f(0, 0);
    GL.Vertex3f(-FCurrSize, -FCurrSize, 0);
    GL.TexCoord2f(1, 0);
    GL.Vertex3f(FCurrSize, -FCurrSize, 0);
    GL.TexCoord2f(1, 1);
    GL.Vertex3f(FCurrSize, FCurrSize, 0);
    GL.TexCoord2f(0, 1);
    GL.Vertex3f(-FCurrSize, FCurrSize, 0);
    GL.end_;
    ImgGlow.UnApply(rci);
  end;

  if not ImgRays.Disabled and Assigned(ImgRays.Image) then
  begin
    ImgRays.Apply(rci);
    GL.begin_(GL_QUADS);
    GL.TexCoord2f(0, 0);
    GL.Vertex3f(-FCurrSize, -FCurrSize, 0);
    GL.TexCoord2f(1, 0);
    GL.Vertex3f(FCurrSize, -FCurrSize, 0);
    GL.TexCoord2f(1, 1);
    GL.Vertex3f(FCurrSize, FCurrSize, 0);
    GL.TexCoord2f(0, 1);
    GL.Vertex3f(-FCurrSize, FCurrSize, 0);
    GL.end_;
    ImgRays.UnApply(rci);
  end;
  GL.PopMatrix;

  if not ImgRing.Disabled and Assigned(ImgRing.Image) then
  begin
    GL.PushMatrix;
    GL.Translatef(posVector.V[0] * 1.1, posVector.V[1] * 1.1, posVector.V[2]);
    ImgRing.Apply(rci);
    GL.begin_(GL_QUADS);
    GL.TexCoord2f(0, 0);
    GL.Vertex3f(-FCurrSize, -FCurrSize, 0);
    GL.TexCoord2f(1, 0);
    GL.Vertex3f(FCurrSize, -FCurrSize, 0);
    GL.TexCoord2f(1, 1);
    GL.Vertex3f(FCurrSize, FCurrSize, 0);
    GL.TexCoord2f(0, 1);
    GL.Vertex3f(-FCurrSize, FCurrSize, 0);
    GL.end_;
    ImgRing.UnApply(rci);
    GL.PopMatrix;
  end;

  if not ImgSecondaries.Disabled and Assigned(ImgSecondaries.Image) then
  begin
    RandSeed := FSeed;
    GL.PushMatrix;
    ImgSecondaries.Apply(rci);
    for i := 1 to FNumSecs do
    begin
      rnd := 2 * Random - 1;
      v := PosVector;
      if rnd < 0 then
        ScaleVector(V, rnd)
      else
        ScaleVector(V, 0.8 * rnd);
      GL.PushMatrix;
      GL.Translatef(v.V[0], v.V[1], v.V[2]);

      rnd := random * 0.5 + 0.1;
      GL.begin_(GL_QUADS);
      GL.TexCoord2f(0, 0);
      GL.Vertex3f(-FCurrSize * rnd, -FCurrSize * rnd, 0);
      GL.TexCoord2f(1, 0);
      GL.Vertex3f(FCurrSize * rnd, -FCurrSize * rnd, 0);
      GL.TexCoord2f(1, 1);
      GL.Vertex3f(FCurrSize * rnd, FCurrSize * rnd, 0);
      GL.TexCoord2f(0, 1);
      GL.Vertex3f(-FCurrSize * rnd, FCurrSize * rnd, 0);
      GL.end_;
      GL.PopMatrix
    end;
    ImgSecondaries.UnApply(rci);
    GL.PopMatrix;
  end;

  // restore state

  GL.PopMatrix;
  GL.MatrixMode(GL_MODELVIEW);
  GL.PopMatrix;

  if Count > 0 then
    Self.RenderChildren(0, Count - 1, rci);
end;

// DoProgress
//

procedure TVKTextureLensFlare.DoProgress(const progressTime: TProgressTimes);
begin
  FDeltaTime := progressTime.deltaTime;
  inherited;
end;

procedure TVKTextureLensFlare.SetImgGlow(const Value: TVKTexture);
begin
  FImgGlow.Assign(Value);
  StructureChanged;
end;

procedure TVKTextureLensFlare.SetImgRays(const Value: TVKTexture);
begin
  FImgRays.Assign(Value);
  StructureChanged;
end;

procedure TVKTextureLensFlare.SetImgRing(const Value: TVKTexture);
begin
  FImgRing.Assign(Value);
  StructureChanged;
end;

procedure TVKTextureLensFlare.SetImgSecondaries(const Value: TVKTexture);
begin
  FImgSecondaries.Assign(Value);
  StructureChanged;
end;

destructor TVKTextureLensFlare.Destroy;
begin
  FImgRays.Free;
  FImgSecondaries.Free;
  FImgRing.Free;
  FImgGlow.Free;
  inherited;
end;

procedure TVKTextureLensFlare.SetSeed(const Value: Integer);
begin
  FSeed := Value;
  StructureChanged;
end;

// ------------------------------------------------------------------
// ------------------------------------------------------------------
// ------------------------------------------------------------------
initialization
  // ------------------------------------------------------------------
  // ------------------------------------------------------------------
  // ------------------------------------------------------------------

  RegisterClasses([TVKTextureLensFlare]);

end.

