//
// VXScene Component Library, based on GLScene http://glscene.sourceforge.net 
//
{
   A TVXImmaterialSceneObject drawing 6 quads (plus another quad as "Cloud" plane)
   for use as a skybox always centered on the camera. 
    
}
unit VXS.SkyBox;

interface

{$I VXScene.inc}

uses
  Winapi.OpenGL,
  Winapi.OpenGLext,
  System.Classes,

  VXS.XOpenGL,
  VXS.Scene,
  VXS.Material,
  VXS.VectorGeometry,
  VXS.RenderContextInfo,
  VXS.VectorTypes;

type

  TVXSkyBoxStyle = (sbsFull, sbsTopHalf, sbsBottomHalf, sbTopTwoThirds,
    sbsTopHalfClamped);

  TVXSkyBox = class(TVXCameraInvariantObject, IVXMaterialLibrarySupported)
  private
    FMatNameTop: string;
    FMatNameRight: string;
    FMatNameFront: string;
    FMatNameLeft: string;
    FMatNameBack: string;
    FMatNameBottom: string;
    FMatNameClouds: string;
    FMaterialLibrary: TVXMaterialLibrary;
    FCloudsPlaneOffset: Single;
    FCloudsPlaneSize: Single;
    FStyle: TVXSkyBoxStyle;
    //implementing IGLMaterialLibrarySupported
    function GetMaterialLibrary: TVXAbstractMaterialLibrary;
  protected
    procedure SetMaterialLibrary(const Value: TVXMaterialLibrary);
    procedure SetMatNameBack(const Value: string);
    procedure SetMatNameBottom(const Value: string);
    procedure SetMatNameFront(const Value: string);
    procedure SetMatNameLeft(const Value: string);
    procedure SetMatNameRight(const Value: string);
    procedure SetMatNameTop(const Value: string);
    procedure SetMatNameClouds(const Value: string);
    procedure SetCloudsPlaneOffset(const Value: single);
    procedure SetCloudsPlaneSize(const Value: single);
    procedure SetStyle(const value: TVXSkyBoxStyle);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure DoRender(var ARci: TVXRenderContextInfo;
      ARenderSelf, ARenderChildren: Boolean); override;
    procedure BuildList(var ARci: TVXRenderContextInfo); override;
    procedure Notification(AComponent: TComponent; Operation: TOperation);
      override;
  published
    property MaterialLibrary: TVXMaterialLibrary read FMaterialLibrary write
      SetMaterialLibrary;
    property MatNameTop: TVXLibMaterialName read FMatNameTop write
      SetMatNameTop;
    property MatNameBottom: TVXLibMaterialName read FMatNameBottom write
      SetMatNameBottom;
    property MatNameLeft: TVXLibMaterialName read FMatNameLeft write
      SetMatNameLeft;
    property MatNameRight: TVXLibMaterialName read FMatNameRight write
      SetMatNameRight;
    property MatNameFront: TVXLibMaterialName read FMatNameFront write
      SetMatNameFront;
    property MatNameBack: TVXLibMaterialName read FMatNameBack write
      SetMatNameBack;
    property MatNameClouds: TVXLibMaterialName read FMatNameClouds write
      SetMatNameClouds;
    property CloudsPlaneOffset: Single read FCloudsPlaneOffset write
      SetCloudsPlaneOffset;
    property CloudsPlaneSize: Single read FCloudsPlaneSize write
      SetCloudsPlaneSize;
    property Style: TVXSkyBoxStyle read FStyle write FStyle default sbsFull;
  end;

//===================================================================
implementation
//===================================================================

uses
  VXS.Context,
  VXS.State;

// ------------------
// ------------------ TVXSkyBox ------------------
// ------------------

constructor TVXSkyBox.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  CamInvarianceMode := cimPosition;
  ObjectStyle := ObjectStyle + [osDirectDraw, osNoVisibilityCulling];
  FCloudsPlaneOffset := 0.2;
    // this should be set far enough to avoid near plane clipping
  FCloudsPlaneSize := 32;
    // the bigger, the more this extends the clouds cap to the horizon
end;

destructor TVXSkyBox.Destroy;
begin
  inherited;
end;

function TVXSkyBox.GetMaterialLibrary: TVXAbstractMaterialLibrary;
begin
  Result := FMaterialLibrary;
end;

procedure TVXSkyBox.Notification(AComponent: TComponent; Operation: TOperation);
begin
  if (Operation = opRemove) and (AComponent = FMaterialLibrary) then
    MaterialLibrary := nil;
  inherited;
end;

// DoRender
//

procedure TVXSkyBox.DoRender(var ARci: TVXRenderContextInfo; ARenderSelf,
  ARenderChildren: Boolean);
begin
  // We want children of the sky box to appear far away too
  // (note: simply not writing to depth buffer may not make this not work,
  //  child objects may need the depth buffer to render themselves properly,
  //  this may require depth buffer cleared after that. - DanB)
  Arci.VXStates.DepthWriteMask := False;
  Arci.ignoreDepthRequests := true;
  inherited;
  Arci.ignoreDepthRequests := False;
end;
// DoRender
//

procedure TVXSkyBox.BuildList(var ARci: TVXRenderContextInfo);
var
  f, cps, cof1: Single;
  oldStates: TVXStates;
  libMat: TVXLibMaterial;
begin
  if FMaterialLibrary = nil then
    Exit;

  with ARci.VxStates do
  begin
    oldStates := States;
    Disable(stDepthTest);
    Disable(stLighting);
    Disable(stFog);
  end;

  glPushMatrix;
  f := ARci.rcci.farClippingDistance * 0.5;
  glScalef(f, f, f);

  try
    case Style of
      sbsFull: ;
      sbsTopHalf, sbsTopHalfClamped:
        begin
          glTranslatef(0, 0.5, 0);
          glScalef(1, 0.5, 1);
        end;
      sbsBottomHalf:
        begin
          glTranslatef(0, -0.5, 0);
          glScalef(1, 0.5, 1);
        end;
      sbTopTwoThirds:
        begin
          glTranslatef(0, 1 / 3, 0);
          glScalef(1, 2 / 3, 1);
        end;
    end;

    // FRONT
    libMat := MaterialLibrary.LibMaterialByName(FMatNameFront);
    if libMat <> nil then
    begin
      libMat.Apply(ARci);
      repeat
        glBegin(GL_QUADS);
        glTexCoord2f(0.002, 0.998);
        glVertex3f(-1, 1, -1);
        glTexCoord2f(0.002, 0.002);
        glVertex3f(-1, -1, -1);
        glTexCoord2f(0.998, 0.002);
        glVertex3f(1, -1, -1);
        glTexCoord2f(0.998, 0.998);
        glVertex3f(1, 1, -1);
        if Style = sbsTopHalfClamped then
        begin
          glTexCoord2f(0.002, 0.002);
          glVertex3f(-1, -1, -1);
          glTexCoord2f(0.002, 0.002);
          glVertex3f(-1, -3, -1);
          glTexCoord2f(0.998, 0.002);
          glVertex3f(1, -3, -1);
          glTexCoord2f(0.998, 0.002);
          glVertex3f(1, -1, -1);
        end;
        glEnd;
      until not libMat.UnApply(ARci);
    end;
    // BACK
    libMat := MaterialLibrary.LibMaterialByName(FMatNameBack);
    if libMat <> nil then
    begin
      libMat.Apply(ARci);
      repeat
        glBegin(GL_QUADS);
        glTexCoord2f(0.002, 0.998);
        glVertex3f(1, 1, 1);
        glTexCoord2f(0.002, 0.002);
        glVertex3f(1, -1, 1);
        glTexCoord2f(0.998, 0.002);
        glVertex3f(-1, -1, 1);
        glTexCoord2f(0.998, 0.998);
        glVertex3f(-1, 1, 1);
        if Style = sbsTopHalfClamped then
        begin
          glTexCoord2f(0.002, 0.002);
          glVertex3f(1, -1, 1);
          glTexCoord2f(0.002, 0.002);
          glVertex3f(1, -3, 1);
          glTexCoord2f(0.998, 0.002);
          glVertex3f(-1, -3, 1);
          glTexCoord2f(0.998, 0.002);
          glVertex3f(-1, -1, 1);
        end;
        glEnd;
      until not libMat.UnApply(ARci);
    end;
    // TOP
    libMat := MaterialLibrary.LibMaterialByName(FMatNameTop);
    if libMat <> nil then
    begin
      libMat.Apply(ARci);
      repeat
        glBegin(GL_QUADS);
        glTexCoord2f(0.002, 0.998);
        glVertex3f(-1, 1, 1);
        glTexCoord2f(0.002, 0.002);
        glVertex3f(-1, 1, -1);
        glTexCoord2f(0.998, 0.002);
        glVertex3f(1, 1, -1);
        glTexCoord2f(0.998, 0.998);
        glVertex3f(1, 1, 1);
        glEnd;
      until not libMat.UnApply(ARci);
    end;
    // BOTTOM
    libMat := MaterialLibrary.LibMaterialByName(FMatNameBottom);
    if libMat <> nil then
    begin
      libMat.Apply(ARci);
      repeat
        glBegin(GL_QUADS);
        glTexCoord2f(0.002, 0.998);
        glVertex3f(-1, -1, -1);
        glTexCoord2f(0.002, 0.002);
        glVertex3f(-1, -1, 1);
        glTexCoord2f(0.998, 0.002);
        glVertex3f(1, -1, 1);
        glTexCoord2f(0.998, 0.998);
        glVertex3f(1, -1, -1);
        glEnd;
      until not libMat.UnApply(ARci);
    end;
    // LEFT
    libMat := MaterialLibrary.LibMaterialByName(FMatNameLeft);
    if libMat <> nil then
    begin
      libMat.Apply(ARci);
      repeat
        glBegin(GL_QUADS);
        glTexCoord2f(0.002, 0.998);
        glVertex3f(-1, 1, 1);
        glTexCoord2f(0.002, 0.002);
        glVertex3f(-1, -1, 1);
        glTexCoord2f(0.998, 0.002);
        glVertex3f(-1, -1, -1);
        glTexCoord2f(0.998, 0.998);
        glVertex3f(-1, 1, -1);
        if Style = sbsTopHalfClamped then
        begin
          glTexCoord2f(0.002, 0.002);
          glVertex3f(-1, -1, 1);
          glTexCoord2f(0.002, 0.002);
          glVertex3f(-1, -3, 1);
          glTexCoord2f(0.998, 0.002);
          glVertex3f(-1, -3, -1);
          glTexCoord2f(0.998, 0.002);
          glVertex3f(-1, -1, -1);
        end;
        glEnd;
      until not libMat.UnApply(ARci);
    end;
    // RIGHT
    libMat := MaterialLibrary.LibMaterialByName(FMatNameRight);
    if libMat <> nil then
    begin
      libMat.Apply(ARci);
      repeat
        glBegin(GL_QUADS);
        glTexCoord2f(0.002, 0.998);
        glVertex3f(1, 1, -1);
        glTexCoord2f(0.002, 0.002);
        glVertex3f(1, -1, -1);
        glTexCoord2f(0.998, 0.002);
        glVertex3f(1, -1, 1);
        glTexCoord2f(0.998, 0.998);
        glVertex3f(1, 1, 1);
        if Style = sbsTopHalfClamped then
        begin
          glTexCoord2f(0.002, 0.002);
          glVertex3f(1, -1, -1);
          glTexCoord2f(0.002, 0.002);
          glVertex3f(1, -3, -1);
          glTexCoord2f(0.998, 0.002);
          glVertex3f(1, -3, 1);
          glTexCoord2f(0.998, 0.002);
          glVertex3f(1, -1, 1);
        end;
        glEnd;
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
        glBegin(GL_QUADS);
        glTexCoord2f(0, 1);
        glVertex3f(-cps, cof1, cps);
        glTexCoord2f(0, 0);
        glVertex3f(-cps, cof1, -cps);
        glTexCoord2f(1, 0);
        glVertex3f(cps, cof1, -cps);
        glTexCoord2f(1, 1);
        glVertex3f(cps, cof1, cps);
        glEnd;
      until not libMat.UnApply(ARci);
    end;

    glPopMatrix;

    if stLighting in oldStates then
      ARci.VXStates.Enable(stLighting);
    if stFog in oldStates then
      ARci.VXStates.Enable(stFog);
    if stDepthTest in oldStates then
      ARci.VXStates.Enable(stDepthTest);

  finally
  end;
end;

procedure TVXSkyBox.SetCloudsPlaneOffset(const Value: single);
begin
  FCloudsPlaneOffset := Value;
  StructureChanged;
end;

procedure TVXSkyBox.SetCloudsPlaneSize(const Value: single);
begin
  FCloudsPlaneSize := Value;
  StructureChanged;
end;

// SetStyle
//

procedure TVXSkyBox.SetStyle(const value: TVXSkyBoxStyle);
begin
  FStyle := value;
  StructureChanged;
end;

// SetMaterialLibrary
//

procedure TVXSkyBox.SetMaterialLibrary(const value: TVXMaterialLibrary);
begin
  FMaterialLibrary := value;
  StructureChanged;
end;

procedure TVXSkyBox.SetMatNameBack(const Value: string);
begin
  FMatNameBack := Value;
  StructureChanged;
end;

procedure TVXSkyBox.SetMatNameBottom(const Value: string);
begin
  FMatNameBottom := Value;
  StructureChanged;
end;

procedure TVXSkyBox.SetMatNameClouds(const Value: string);
begin
  FMatNameClouds := Value;
  StructureChanged;
end;

procedure TVXSkyBox.SetMatNameFront(const Value: string);
begin
  FMatNameFront := Value;
  StructureChanged;
end;

procedure TVXSkyBox.SetMatNameLeft(const Value: string);
begin
  FMatNameLeft := Value;
  StructureChanged;
end;

procedure TVXSkyBox.SetMatNameRight(const Value: string);
begin
  FMatNameRight := Value;
  StructureChanged;
end;

procedure TVXSkyBox.SetMatNameTop(const Value: string);
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

  RegisterClass(TVXSkyBox);

end.

