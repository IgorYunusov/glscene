//
// This unit is part of the GLScene Project, http://glscene.org
//
{ : GLSkyBox<p>

  A TGLImmaterialSceneObject drawing 6 quads (plus another quad as "Cloud" plane)
  for use as a skybox always centered on the camera.<p>

  <b>History : </b><font size=-1><ul>
  <li>16/03/11 - Yar - Fixes after emergence of GLMaterialEx
  <li>23/08/10 - Yar - Added OpenGLTokens to uses, replaced OpenGL1x functions to OpenGLAdapter
  <li>22/04/10 - Yar - Fixes after GLState revision
  <li>05/03/10 - DanB - More state added to TGLStateCache
  <li>26/03/09 - DanB - Skybox is now a TGLCameraInvariantObject
  <li>10/10/08 - DanB - changed Skybox DoRender to use rci instead
  of Scene.CurrentGLCamera
  <li>30/03/07 - DaStr - Added $I GLScene.inc
  <li>28/03/07 - DaStr - Renamed parameters in some methods
  (thanks Burkhard Carstens) (Bugtracker ID = 1678658)
  <li>21/01/07 - DaStr - Added IGLMaterialLibrarySupported support
  <li>12/04/04 - EG - Added Style property, multipass support
  <li>27/11/03 - EG - Cleanup and fixes
  <li>09/11/03 - MRQZZZ - mandatory changes suggested by Eric.
  <li>02/09/03 - MRQZZZ - Creation
  </ul></font>
}
unit GLScene.Objects.SkyBox;

interface

{$I GLScene.inc}

uses
  Classes,
  GLScene.Core,
  GLScene.Material,
  GLScene.Base.Vector.Geometry,
  GLScene.Base.OpenGL.Tokens,
  GLScene.Base.Context.Info
{$IFDEF GLS_DELPHI},
  GLScene.Base.Vector.Types{$ENDIF};

type

  // TGLSkyBoxStyle
  //
  TGLSkyBoxStyle = (sbsFull, sbsTopHalf, sbsBottomHalf, sbTopTwoThirds,
    sbsTopHalfClamped);

  // TGLSkyBox
  //
  TGLSkyBox = class(TGLCameraInvariantObject, IGLMaterialLibrarySupported)
  private
    { Private Declarations }
    FMatNameTop: string;
    FMatNameRight: string;
    FMatNameFront: string;
    FMatNameLeft: string;
    FMatNameBack: string;
    FMatNameBottom: string;
    FMatNameClouds: string;
    FMaterialLibrary: TGLMaterialLibrary;
    FCloudsPlaneOffset: Single;
    FCloudsPlaneSize: Single;
    FStyle: TGLSkyBoxStyle;

    // implementing IGLMaterialLibrarySupported
    function GetMaterialLibrary: TGLAbstractMaterialLibrary;
  protected
    { Protected Declarations }
    procedure SetMaterialLibrary(const Value: TGLMaterialLibrary);
    procedure SetMatNameBack(const Value: string);
    procedure SetMatNameBottom(const Value: string);
    procedure SetMatNameFront(const Value: string);
    procedure SetMatNameLeft(const Value: string);
    procedure SetMatNameRight(const Value: string);
    procedure SetMatNameTop(const Value: string);
    procedure SetMatNameClouds(const Value: string);
    procedure SetCloudsPlaneOffset(const Value: Single);
    procedure SetCloudsPlaneSize(const Value: Single);
    procedure SetStyle(const Value: TGLSkyBoxStyle);

  public
    { Public Declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure DoRender(var ARci: TRenderContextInfo;
      ARenderSelf, ARenderChildren: Boolean); override;
    procedure BuildList(var ARci: TRenderContextInfo); override;
    procedure Notification(AComponent: TComponent;
      Operation: TOperation); override;

  published
    { Published Declarations }
    property MaterialLibrary: TGLMaterialLibrary read FMaterialLibrary
      write SetMaterialLibrary;
    property MatNameTop: TGLLibMaterialName read FMatNameTop
      write SetMatNameTop;
    property MatNameBottom: TGLLibMaterialName read FMatNameBottom
      write SetMatNameBottom;
    property MatNameLeft: TGLLibMaterialName read FMatNameLeft
      write SetMatNameLeft;
    property MatNameRight: TGLLibMaterialName read FMatNameRight
      write SetMatNameRight;
    property MatNameFront: TGLLibMaterialName read FMatNameFront
      write SetMatNameFront;
    property MatNameBack: TGLLibMaterialName read FMatNameBack
      write SetMatNameBack;
    property MatNameClouds: TGLLibMaterialName read FMatNameClouds
      write SetMatNameClouds;
    property CloudsPlaneOffset: Single read FCloudsPlaneOffset
      write SetCloudsPlaneOffset;
    property CloudsPlaneSize: Single read FCloudsPlaneSize
      write SetCloudsPlaneSize;
    property Style: TGLSkyBoxStyle read FStyle write FStyle default sbsFull;
  end;

  // ------------------------------------------------------------------
  // ------------------------------------------------------------------
  // ------------------------------------------------------------------
implementation

// ------------------------------------------------------------------
// ------------------------------------------------------------------
// ------------------------------------------------------------------

uses
  GLScene.Base.Context,
  GLScene.Base.GLStateMachine;

// ------------------
// ------------------ TGLSkyBox ------------------
// ------------------

// Create
//

constructor TGLSkyBox.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  CamInvarianceMode := cimPosition;
  ObjectStyle := ObjectStyle + [osDirectDraw, osNoVisibilityCulling];
  FCloudsPlaneOffset := 0.2;
  // this should be set far enough to avoid near plane clipping
  FCloudsPlaneSize := 32;
  // the bigger, the more this extends the clouds cap to the horizon
end;

// Destroy
//

destructor TGLSkyBox.Destroy;
begin
  inherited;
end;

// GetMaterialLibrary
//

function TGLSkyBox.GetMaterialLibrary: TGLAbstractMaterialLibrary;
begin
  Result := FMaterialLibrary;
end;

// Notification
//

procedure TGLSkyBox.Notification(AComponent: TComponent; Operation: TOperation);
begin
  if (Operation = opRemove) and (AComponent = FMaterialLibrary) then
    MaterialLibrary := nil;
  inherited;
end;

// DoRender
//

procedure TGLSkyBox.DoRender(var ARci: TRenderContextInfo;
  ARenderSelf, ARenderChildren: Boolean);
begin
  // We want children of the sky box to appear far away too
  // (note: simply not writing to depth buffer may not make this not work,
  // child objects may need the depth buffer to render themselves properly,
  // this may require depth buffer cleared after that. - DanB)
  ARci.GLStates.DepthWriteMask := False;
  ARci.ignoreDepthRequests := true;
  inherited;
  ARci.ignoreDepthRequests := False;
end;
// DoRender
//

procedure TGLSkyBox.BuildList(var ARci: TRenderContextInfo);
var
  f, cps, cof1: Single;
  oldStates: TGLStates;
  libMat: TGLLibMaterial;
begin
  if FMaterialLibrary = nil then
    Exit;

  with ARci.GLStates do
  begin
    oldStates := States;
    Disable(stDepthTest);
    Disable(stLighting);
    Disable(stFog);
  end;

  GL.PushMatrix;
  f := ARci.rcci.farClippingDistance * 0.5;
  GL.Scalef(f, f, f);

  try
    case Style of
      sbsFull:
        ;
      sbsTopHalf, sbsTopHalfClamped:
        begin
          GL.Translatef(0, 0.5, 0);
          GL.Scalef(1, 0.5, 1);
        end;
      sbsBottomHalf:
        begin
          GL.Translatef(0, -0.5, 0);
          GL.Scalef(1, 0.5, 1);
        end;
      sbTopTwoThirds:
        begin
          GL.Translatef(0, 1 / 3, 0);
          GL.Scalef(1, 2 / 3, 1);
        end;
    end;

    // FRONT
    libMat := MaterialLibrary.LibMaterialByName(FMatNameFront);
    if libMat <> nil then
    begin
      libMat.Apply(ARci);
      repeat
        GL.Begin_(GL_QUADS);
        GL.TexCoord2f(0.002, 0.998);
        GL.Vertex3f(-1, 1, -1);
        GL.TexCoord2f(0.002, 0.002);
        GL.Vertex3f(-1, -1, -1);
        GL.TexCoord2f(0.998, 0.002);
        GL.Vertex3f(1, -1, -1);
        GL.TexCoord2f(0.998, 0.998);
        GL.Vertex3f(1, 1, -1);
        if Style = sbsTopHalfClamped then
        begin
          GL.TexCoord2f(0.002, 0.002);
          GL.Vertex3f(-1, -1, -1);
          GL.TexCoord2f(0.002, 0.002);
          GL.Vertex3f(-1, -3, -1);
          GL.TexCoord2f(0.998, 0.002);
          GL.Vertex3f(1, -3, -1);
          GL.TexCoord2f(0.998, 0.002);
          GL.Vertex3f(1, -1, -1);
        end;
        GL.End_;
      until not libMat.UnApply(ARci);
    end;
    // BACK
    libMat := MaterialLibrary.LibMaterialByName(FMatNameBack);
    if libMat <> nil then
    begin
      libMat.Apply(ARci);
      repeat
        GL.Begin_(GL_QUADS);
        GL.TexCoord2f(0.002, 0.998);
        GL.Vertex3f(1, 1, 1);
        GL.TexCoord2f(0.002, 0.002);
        GL.Vertex3f(1, -1, 1);
        GL.TexCoord2f(0.998, 0.002);
        GL.Vertex3f(-1, -1, 1);
        GL.TexCoord2f(0.998, 0.998);
        GL.Vertex3f(-1, 1, 1);
        if Style = sbsTopHalfClamped then
        begin
          GL.TexCoord2f(0.002, 0.002);
          GL.Vertex3f(1, -1, 1);
          GL.TexCoord2f(0.002, 0.002);
          GL.Vertex3f(1, -3, 1);
          GL.TexCoord2f(0.998, 0.002);
          GL.Vertex3f(-1, -3, 1);
          GL.TexCoord2f(0.998, 0.002);
          GL.Vertex3f(-1, -1, 1);
        end;
        GL.End_;
      until not libMat.UnApply(ARci);
    end;
    // TOP
    libMat := MaterialLibrary.LibMaterialByName(FMatNameTop);
    if libMat <> nil then
    begin
      libMat.Apply(ARci);
      repeat
        GL.Begin_(GL_QUADS);
        GL.TexCoord2f(0.002, 0.998);
        GL.Vertex3f(-1, 1, 1);
        GL.TexCoord2f(0.002, 0.002);
        GL.Vertex3f(-1, 1, -1);
        GL.TexCoord2f(0.998, 0.002);
        GL.Vertex3f(1, 1, -1);
        GL.TexCoord2f(0.998, 0.998);
        GL.Vertex3f(1, 1, 1);
        GL.End_;
      until not libMat.UnApply(ARci);
    end;
    // BOTTOM
    libMat := MaterialLibrary.LibMaterialByName(FMatNameBottom);
    if libMat <> nil then
    begin
      libMat.Apply(ARci);
      repeat
        GL.Begin_(GL_QUADS);
        GL.TexCoord2f(0.002, 0.998);
        GL.Vertex3f(-1, -1, -1);
        GL.TexCoord2f(0.002, 0.002);
        GL.Vertex3f(-1, -1, 1);
        GL.TexCoord2f(0.998, 0.002);
        GL.Vertex3f(1, -1, 1);
        GL.TexCoord2f(0.998, 0.998);
        GL.Vertex3f(1, -1, -1);
        GL.End_;
      until not libMat.UnApply(ARci);
    end;
    // LEFT
    libMat := MaterialLibrary.LibMaterialByName(FMatNameLeft);
    if libMat <> nil then
    begin
      libMat.Apply(ARci);
      repeat
        GL.Begin_(GL_QUADS);
        GL.TexCoord2f(0.002, 0.998);
        GL.Vertex3f(-1, 1, 1);
        GL.TexCoord2f(0.002, 0.002);
        GL.Vertex3f(-1, -1, 1);
        GL.TexCoord2f(0.998, 0.002);
        GL.Vertex3f(-1, -1, -1);
        GL.TexCoord2f(0.998, 0.998);
        GL.Vertex3f(-1, 1, -1);
        if Style = sbsTopHalfClamped then
        begin
          GL.TexCoord2f(0.002, 0.002);
          GL.Vertex3f(-1, -1, 1);
          GL.TexCoord2f(0.002, 0.002);
          GL.Vertex3f(-1, -3, 1);
          GL.TexCoord2f(0.998, 0.002);
          GL.Vertex3f(-1, -3, -1);
          GL.TexCoord2f(0.998, 0.002);
          GL.Vertex3f(-1, -1, -1);
        end;
        GL.End_;
      until not libMat.UnApply(ARci);
    end;
    // RIGHT
    libMat := MaterialLibrary.LibMaterialByName(FMatNameRight);
    if libMat <> nil then
    begin
      libMat.Apply(ARci);
      repeat
        GL.Begin_(GL_QUADS);
        GL.TexCoord2f(0.002, 0.998);
        GL.Vertex3f(1, 1, -1);
        GL.TexCoord2f(0.002, 0.002);
        GL.Vertex3f(1, -1, -1);
        GL.TexCoord2f(0.998, 0.002);
        GL.Vertex3f(1, -1, 1);
        GL.TexCoord2f(0.998, 0.998);
        GL.Vertex3f(1, 1, 1);
        if Style = sbsTopHalfClamped then
        begin
          GL.TexCoord2f(0.002, 0.002);
          GL.Vertex3f(1, -1, -1);
          GL.TexCoord2f(0.002, 0.002);
          GL.Vertex3f(1, -3, -1);
          GL.TexCoord2f(0.998, 0.002);
          GL.Vertex3f(1, -3, 1);
          GL.TexCoord2f(0.998, 0.002);
          GL.Vertex3f(1, -1, 1);
        end;
        GL.End_;
      until not libMat.UnApply(ARci);
    end;
    // CLOUDS CAP PLANE
    libMat := MaterialLibrary.LibMaterialByName(FMatNameClouds);
    if libMat <> nil then
    begin
      // pre-calculate possible values to speed up
      cps := FCloudsPlaneSize * 0.5;
      cof1 := FCloudsPlaneOffset;

      libMat.Apply(ARci);
      repeat
        GL.Begin_(GL_QUADS);
        GL.TexCoord2f(0, 1);
        GL.Vertex3f(-cps, cof1, cps);
        GL.TexCoord2f(0, 0);
        GL.Vertex3f(-cps, cof1, -cps);
        GL.TexCoord2f(1, 0);
        GL.Vertex3f(cps, cof1, -cps);
        GL.TexCoord2f(1, 1);
        GL.Vertex3f(cps, cof1, cps);
        GL.End_;
      until not libMat.UnApply(ARci);
    end;

    GL.PopMatrix;

    if stLighting in oldStates then
      ARci.GLStates.Enable(stLighting);
    if stFog in oldStates then
      ARci.GLStates.Enable(stFog);
    if stDepthTest in oldStates then
      ARci.GLStates.Enable(stDepthTest);

  finally
  end;
end;

procedure TGLSkyBox.SetCloudsPlaneOffset(const Value: Single);
begin
  FCloudsPlaneOffset := Value;
  StructureChanged;
end;

procedure TGLSkyBox.SetCloudsPlaneSize(const Value: Single);
begin
  FCloudsPlaneSize := Value;
  StructureChanged;
end;

// SetStyle
//

procedure TGLSkyBox.SetStyle(const Value: TGLSkyBoxStyle);
begin
  FStyle := Value;
  StructureChanged;
end;

// SetMaterialLibrary
//

procedure TGLSkyBox.SetMaterialLibrary(const Value: TGLMaterialLibrary);
begin
  FMaterialLibrary := Value;
  StructureChanged;
end;

procedure TGLSkyBox.SetMatNameBack(const Value: string);
begin
  FMatNameBack := Value;
  StructureChanged;
end;

procedure TGLSkyBox.SetMatNameBottom(const Value: string);
begin
  FMatNameBottom := Value;
  StructureChanged;
end;

procedure TGLSkyBox.SetMatNameClouds(const Value: string);
begin
  FMatNameClouds := Value;
  StructureChanged;
end;

procedure TGLSkyBox.SetMatNameFront(const Value: string);
begin
  FMatNameFront := Value;
  StructureChanged;
end;

procedure TGLSkyBox.SetMatNameLeft(const Value: string);
begin
  FMatNameLeft := Value;
  StructureChanged;
end;

procedure TGLSkyBox.SetMatNameRight(const Value: string);
begin
  FMatNameRight := Value;
  StructureChanged;
end;

procedure TGLSkyBox.SetMatNameTop(const Value: string);
begin
  FMatNameTop := Value;
  StructureChanged;
end;

// ------------------------------------------------------------------
// ------------------------------------------------------------------
// ------------------------------------------------------------------
initialization

// ------------------------------------------------------------------
// ------------------------------------------------------------------
// ------------------------------------------------------------------

RegisterClass(TGLSkyBox);

end.
