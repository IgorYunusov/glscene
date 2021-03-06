// This unit is part of the GLScene Project, http://glscene.org
//
{: GLAtmosphere <p>

   This unit contains classes that imitate an atmosphere around a planet.<p>

   <b>History : </b><font size=-1><ul>
      <li>01/03/07 - DaStr - Fixed TGLAtmosphereBlendingMode
                                             (old version did not generate RTTI)
                             Added default values to all properties                
      <li>15/02/07 - DaStr - Added TGLCustomAtmosphere.AxisAlignedDimensionsUnscaled 
      <li>07/02/07 - DaStr - Initial version (donated to GLScene)


   Comments:
      1) Eats a lot of CPU (reduces FPS from 1240 to 520 on my PC with cSlices=100)
      2) Alpha in LowAtmColor, HighAtmColor is ignored.


Previous version history:
          v1.0     06 February '2005  Creation (based on demo "Earth" by Eric Grange)
          v1.1     28 February '2005  Don't remmember what...
          v1.2     16 March    '2005  Small improvements, including ability to
                                        load files using short (not full) paths
          v1.3     21 March    '2005  Positioning bugfix!!!
          v1.4     3 October   '2005  Camera parameter no longer needed
                                      "Enabled" is now a property
                                      LoadFromMemory added
                                      SaveToFile, SaveToMemory added
                                      Normal error message
          v1.5     4 November  '2005  BlendingMode1,2 added
                                      TogleBlengindMode added
                                      LoadFromMemory bugfix
          v1.6     28 February '2006  Became a standard GLScene object, child of TglBaseSceneObject
                                      Range bug fixed, along with a bug, the caused
                                        Atmosphere to draw itseft incorrectly on
                                        some occasions
                                      Demo inhanced
                                      New Load/Save code
          v1.6.2   05 June     '2006  Assign() added
                                      Alpha in LowAtmColor, HighAtmColor was
                                        removed from Loading/saving code
          v1.6.4   07 July     '2006  All variables in the class converted into properties
                                      TStrangeCustomAtmosphere added
          v1.6.6  08 October   '2006  Made compatible with the new persistance mechanism
          v1.7    22 October   '2006  Notification() and SetSun() added
          v1.8    08 February  '2007  TStrangeCustomAtmosphere.Assign fixed
                                      Blending mode Integer ---> Enumeration
                                      Donated to GLScene
}

unit GLAtmosphere;

interface

{$I GLScene.inc}

uses
  // VCL
  Windows, Messages, SysUtils, Classes, Graphics, Controls,

  // GLScene
  GLScene, GLObjects, GLMisc, GLTexture, GLCadencer, OpenGL1x, VectorGeometry,
  GLContext, GLStrings;

type
   {:
   With aabmOneMinusSrcAlpha atmosphere is transparent to other objects,
   but has problems, which are best seen when the Atmosphere radius is big.

   With bmOneMinusDstColor atmosphere doesn't have these problems, but offers
   limited transparency (when you look closely on the side).
  }
  TGLAtmosphereBlendingMode = (abmOneMinusDstColor, abmOneMinusSrcAlpha);

  {: This class imitates an atmosphere around a planet. }
  TGLCustomAtmosphere = class(TGLBaseSceneObject)
  private
    FSlices: Integer;
    FBlendingMode: TGLAtmosphereBlendingMode;
    FPlanetRadius: Single;
    FAtmosphereRadius: Single;
    FOpacity: Single;
    FLowAtmColor: TGLColor;
    FHighAtmColor: TGLColor;
    FSun: TglBaseSceneObject;
    procedure SetSun(const Value: TglBaseSceneObject);
    procedure SetAtmosphereRadius(const Value: Single);
    procedure SetPlanetRadius(const Value: Single);
    procedure EnableGLBlendingMode;
    function StoreAtmosphereRadius: Boolean;
    function StoreOpacity: Boolean;
    function StorePlanetRadius: Boolean;
  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
  public
    property Sun: TglBaseSceneObject read FSun write SetSun;

    property Slices: Integer read FSlices write FSlices default 60;
    property Opacity: Single read FOpacity write FOpacity stored StoreOpacity;

    //: AtmosphereRadius > PlanetRadius!!!
    property AtmosphereRadius: Single read FAtmosphereRadius write SetAtmosphereRadius stored StoreAtmosphereRadius;
    property PlanetRadius: Single read FPlanetRadius write SetPlanetRadius stored StorePlanetRadius;

    //: Use value slightly lower than actual radius, for antialiasing effect.
    property LowAtmColor: TGLColor read FLowAtmColor;
    property HighAtmColor: TGLColor read FHighAtmColor;
    property BlendingMode: TGLAtmosphereBlendingMode read FBlendingMode
                               write FBlendingMode default abmOneMinusSrcAlpha;

    procedure SetOptimalAtmosphere(const R: Single);  //absolute
    procedure SetOptimalAtmosphere2(const R: Single); //relative
    procedure TogleBlendingMode; //changes between 2 blending modes

    //: Standard component stuff.
    procedure Assign(Source: TPersistent); override;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    //: Main rendering procedure.
    procedure DoRender(var rci: TRenderContextInfo; renderSelf, renderChildren: Boolean); override;
    //: Used to determine extents.
    function AxisAlignedDimensionsUnscaled : TVector; override;
  end;

  TGLAtmosphere = class(TGLCustomAtmosphere)
  published
    property Sun;
    property Slices;
    property Opacity;
    property AtmosphereRadius;
    property PlanetRadius;
    property LowAtmColor;
    property HighAtmColor;
    property BlendingMode;

    property Position;
    property ObjectsSorting;
    property ShowAxes;
    property Visible;
    property OnProgress;
    property Behaviours;
    property Effects;
  end;

implementation

uses VectorTypes;

const
  EPS = 0.0001;
  cIntDivTable: array [2..20] of Single =
    (1 / 2, 1 / 3, 1 / 4, 1 / 5, 1 / 6, 1 / 7, 1 / 8, 1 / 9, 1 / 10,
    1 / 11, 1 / 12, 1 / 13, 1 / 14, 1 / 15, 1 / 16, 1 / 17, 1 / 18, 1 / 19, 1 / 20);

procedure TGLCustomAtmosphere.SetOptimalAtmosphere(const R: Single);
begin
  FAtmosphereRadius := R + 0.25;
  FPlanetRadius := R - 0.07;
end;


procedure TGLCustomAtmosphere.SetOptimalAtmosphere2(const R: Single);
begin
  FAtmosphereRadius := R + R / 15;
  FPlanetRadius := R - R / 50;
end;

constructor TGLCustomAtmosphere.Create(AOwner: TComponent);
begin
  inherited;
  FLowAtmColor := TGLColor.Create(Self);
  FHighAtmColor := TGLColor.Create(Self);

  FOpacity := 2.1;
  FSlices := 60;
  FAtmosphereRadius := 3.55;
  FPlanetRadius := 3.395;
  FLowAtmColor.Color := VectorMake(1, 1, 1, 1);
  FHighAtmColor.Color := VectorMake(0, 0, 1, 1);

  FBlendingMode := abmOneMinusSrcAlpha;
end;


destructor TGLCustomAtmosphere.Destroy;
begin
  FLowAtmColor.Destroy;
  FHighAtmColor.Destroy;
  inherited;
end;


procedure TGLCustomAtmosphere.DoRender(var rci: TRenderContextInfo; renderSelf, renderChildren: Boolean);
var
  radius, invAtmosphereHeight:    Single;
  sunPos, eyePos, lightingVector: TVector;
  diskNormal, diskRight, diskUp:  TVector;


  function AtmosphereColor(const rayStart, rayEnd: TVector): TColorVector;
  var
    I, n:     Integer;
    atmPoint, normal: TVector;
    altColor: TColorVector;
    alt, rayLength, contrib, decay, intensity, invN: Single;
  begin
    Result := clrTransparent;
    rayLength := VectorDistance(rayStart, rayEnd);
    n := Round(3 * rayLength * invAtmosphereHeight) + 2;
    if n > 10 then
      n := 10;
    invN := cIntDivTable[n];//1/n;
    contrib := rayLength * invN * Opacity;
    decay := 1 - contrib * 0.5;
    contrib := contrib * (1 / 1.1);
    for I := n - 1 downto 0 do
    begin
      VectorLerp(rayStart, rayEnd, I * invN, atmPoint);
      // diffuse lighting normal
      normal := VectorNormalize(atmPoint);
      // diffuse lighting intensity
      intensity := VectorDotProduct(normal, lightingVector) + 0.1;
      if PInteger(@intensity)^ > 0 then
      begin
        // sample on the lit side
        intensity := intensity * contrib;
        alt := (VectorLength(atmPoint) - PlanetRadius) * invAtmosphereHeight;
        VectorLerp(LowAtmColor.Color, HighAtmColor.Color, alt, altColor);
        Result.Coord[0] := Result.Coord[0] * decay + altColor.Coord[0] * intensity;
        Result.Coord[1] := Result.Coord[1] * decay + altColor.Coord[1] * intensity;
        Result.Coord[2] := Result.Coord[2] * decay + altColor.Coord[2] * intensity;
      end
      else
      begin
        // sample on the dark sid
        Result.Coord[0] := Result.Coord[0] * decay;
        Result.Coord[1] := Result.Coord[1] * decay;
        Result.Coord[2] := Result.Coord[2] * decay;
      end;
    end;
    Result.Coord[3] := n * contrib * Opacity * 0.1;
  end;


  function ComputeColor(var rayDest: TVector; mayHitGround: Boolean): TColorVector;
  var
    ai1, ai2, pi1, pi2: TVector;
    rayVector: TVector;
  begin
    rayVector := VectorNormalize(VectorSubtract(rayDest, eyePos));
    if RayCastSphereIntersect(eyePos, rayVector, NullHmgPoint,
      AtmosphereRadius, ai1, ai2) > 1 then
    begin
      // atmosphere hit
      if mayHitGround and (RayCastSphereIntersect(eyePos, rayVector,
        NullHmgPoint, PlanetRadius, pi1, pi2) > 0) then
      begin
        // hit ground
        Result := AtmosphereColor(ai1, pi1);
      end
      else
      begin
        // through atmosphere only
        Result := AtmosphereColor(ai1, ai2);
      end;
      rayDest := ai1;
    end
    else
      Result := clrTransparent;
  end;

var
  I, J, k0, k1:    Integer;
  cosCache, sinCache: array of Single;
  pVertex, pColor: PVectorArray;
begin
  if FSun <> nil then
  begin
    SetLength(cosCache, Slices + 1);
    SetLength(sinCache, Slices + 1);

    sunPos := VectorSubtract(FSun.AbsolutePosition, AbsolutePosition);
    eyepos := VectorSubtract(rci.CameraPosition, AbsolutePosition);

    diskNormal := VectorNegate(eyePos);
    NormalizeVector(diskNormal);
    diskRight := VectorCrossProduct(rci.CameraUp, diskNormal);
    NormalizeVector(diskRight);
    diskUp := VectorCrossProduct(diskNormal, diskRight);
    NormalizeVector(diskUp);

    invAtmosphereHeight := 1 / (AtmosphereRadius - PlanetRadius);
    lightingVector := VectorNormalize(sunPos); // sun at infinity
    PrepareSinCosCache(sinCache, cosCache, 0, 360);

    GetMem(pVertex, 2 * (Slices + 1) * SizeOf(TVector));
    GetMem(pColor, 2 * (Slices + 1) * SizeOf(TVector));

    glPushAttrib(GL_ENABLE_BIT);
    glDepthMask(False);
    glDisable(GL_LIGHTING);
    glEnable(GL_BLEND);
    EnableGLBlendingMode;
    for I := 0 to 13 do
    begin
      if I < 5 then
        radius := FPlanetRadius * Sqrt(I * (1 / 5))
      else
        radius := FPlanetRadius + (I - 5.1) * (FAtmosphereRadius - FPlanetRadius) * (1 / 6.9);
      radius := SphereVisibleRadius(VectorLength(eyePos), radius);
      k0 := (I and 1) * (Slices + 1);
      k1 := (Slices + 1) - k0;
      for J := 0 to Slices do
      begin
        VectorCombine(diskRight, diskUp,
          cosCache[J] * radius, sinCache[J] * radius,
          pVertex[k0 + J]);
        if I < 13 then
          pColor[k0 + J] := ComputeColor(pVertex[k0 + J], I <= 7);
        if I = 0 then
          Break;
      end;

      if I > 1 then
      begin
        if I = 13 then
        begin
          // glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
          glBegin(GL_QUAD_STRIP);
          for J := Slices downto 0 do
          begin
            glColor4fv(@pColor[k1 + J]);
            glVertex3fv(@pVertex[k1 + J]);
            glColor4fv(@clrTransparent);
            glVertex3fv(@pVertex[k0 + J]);
          end;
          glEnd;
        end
        else
        begin
          // glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_DST_COLOR);
          glBegin(GL_QUAD_STRIP);
          for J := Slices downto 0 do
          begin
            glColor4fv(@pColor[k1 + J]);
            glVertex3fv(@pVertex[k1 + J]);
            glColor4fv(@pColor[k0 + J]);
            glVertex3fv(@pVertex[k0 + J]);
          end;
          glEnd;
        end;
      end
      else if I = 1 then
      begin
        //glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
        glBegin(GL_TRIANGLE_FAN);
        glColor4fv(@pColor[k1]);
        glVertex3fv(@pVertex[k1]);
        for J := k0 + Slices downto k0 do
        begin
          glColor4fv(@pColor[J]);
          glVertex3fv(@pVertex[J]);
        end;
        glEnd;
      end;
    end;
    glDepthMask(True);
    glPopAttrib;

    FreeMem(pVertex);
    FreeMem(pColor);
  end;
  inherited;
end;

procedure TGLCustomAtmosphere.TogleBlendingMode;
begin
  if FBlendingMode = abmOneMinusSrcAlpha then
    FBlendingMode := abmOneMinusDstColor
  else
    FBlendingMode := abmOneMinusSrcAlpha;
end;

procedure TGLCustomAtmosphere.Assign(Source: TPersistent);
begin
  inherited;
  if Source is TGLCustomAtmosphere then
  begin
    FSlices := TGLCustomAtmosphere(Source).FSlices;
    FOpacity := TGLCustomAtmosphere(Source).FOpacity;
    FAtmosphereRadius := TGLCustomAtmosphere(Source).FAtmosphereRadius;
    FPlanetRadius := TGLCustomAtmosphere(Source).FPlanetRadius;
    FLowAtmColor.Color := TGLCustomAtmosphere(Source).FLowAtmColor.Color;
    FHighAtmColor.Color := TGLCustomAtmosphere(Source).FHighAtmColor.Color;
    FBlendingMode := TGLCustomAtmosphere(Source).FBlendingMode;
    SetSun(TGLCustomAtmosphere(Source).FSun);
  end;
end;

procedure TGLCustomAtmosphere.SetSun(const Value: TglBaseSceneObject);
begin
  if FSun <> nil then FSun.RemoveFreeNotification(Self);
  FSun := Value;
  if FSun <> nil then FSun.FreeNotification(Self);
end;

function TGLCustomAtmosphere.AxisAlignedDimensionsUnscaled : TVector;
begin
  Result.Coord[0] := FAtmosphereRadius;
  Result.Coord[1] := Result.Coord[0];
  Result.Coord[2] := Result.Coord[0];
  Result.Coord[3] := 0;
end;

procedure TGLCustomAtmosphere.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited;
  if (Operation = opRemove) and (AComponent = FSun) then
    FSun := nil;
end;

procedure TGLCustomAtmosphere.SetAtmosphereRadius(
  const Value: Single);
begin
  if Value > FPlanetRadius then
    FAtmosphereRadius := Value;
end;

procedure TGLCustomAtmosphere.SetPlanetRadius(const Value: Single);
begin
  if Value < FAtmosphereRadius then
    FPlanetRadius := Value;
end;

procedure TGLCustomAtmosphere.EnableGLBlendingMode;
begin
  case FBlendingMode of
    abmOneMinusDstColor: glBlendFunc(GL_DST_ALPHA, GL_ONE_MINUS_DST_COLOR);
    abmOneMinusSrcAlpha: glBlendFunc(GL_DST_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
  else
    Assert(False, glsUnknownType);
  end;
end;

function TGLCustomAtmosphere.StoreAtmosphereRadius: Boolean;
begin
  Result := Abs(FAtmosphereRadius - 3.55) > EPS;
end;

function TGLCustomAtmosphere.StoreOpacity: Boolean;
begin
  Result := Abs(FOpacity - 2.1) > EPS;
end;

function TGLCustomAtmosphere.StorePlanetRadius: Boolean;
begin
  Result := Abs(FPlanetRadius - 3.395) > EPS;
end;

initialization
  RegisterClasses([TGLCustomAtmosphere, TGLAtmosphere]);

end.

