{
   GLEParticleMasksManager.pas
   This unit is part of GLE - GLScene Game Utilities Engine set by Kenneth Poulter difacane@telkomsa.net
   Module Number: 37

   Description: This is merely an addon to GLScene, since i don't want to edit GLScene's source code directly
                and make changes (since GLScene's source code constantly changes). What the manager does
                is to provide a basic tool for newly created particles to be modified (their position currently).
                Their position is set from 3 different masks, which create a "virtual" 3d object... meaning,
                an actual 3d object is not created, but an outline for particles or any other objects are positioned.

   ActualUsage: Create the component, create a new ParticleMask, set the material library, set the materials,
                and use the procedures provided in the managers root. positioning and scaling applicable aswell.

                The images should be 

   Licenses: Removed. Donated to GLScene's Code Base as long as the author (Kenneth Poulter) is not altered in this file.
             Theft of code also is not allowed, although alterations are allowed.

   History:
   28/12/2005 - Added - LX,LY,LZ for correct positioning;
                        Rotating;
                        GenerateParticleMaskFromProjection;
                        Targeting Objects (scales, positions and rotation of object applies)
   27/12/2005 - Added - Scale and Positioning
   27/12/2005 - Improved code speed significantly (could do better)
   26/12/2005 - Creation of base code from experimentation

}

unit GLEParticleMasksManager;

interface

uses
  SysUtils, Classes, Types, GLTexture, GLScene, GLVectorGeometry, GLVectorTypes,
  GLMisc, Graphics, GLParticleFX, Dialogs;

type

  TGLEProjectedParticleMask = (pptXMask, pptYMask, pptZMask);

  TGLEParticleMask = class;
  TGLEParticleMasks = class;

  TGLEParticleMask = class (TCollectionItem)
  private
    { Private Declarations }
    FName: String;
    FScale: TGLCoordinates;
    FPosition: TGLCoordinates;
    FYMask: TGLLibMaterialName;
    FZMask: TGLLibMaterialName;
    FXMask: TGLLibMaterialName;
    FMaterialLibrary: TGLMaterialLibrary;
    FBackgroundColor: TColor;
    FMaskColor: TColor;
    FMaxX, FMaxY, FMaxZ, FMinX, FMinY, FMinZ : integer;
    IXW, IXH, IYW, IYH, IZW, IZH : integer;
    LX, LY, LZ : integer;

    MX, MY : integer;
    BogusMask, BogusMaskX, BogusMaskY, BogusMaskZ : boolean; // we might have a pitch mask
    FRollAngle: single;
    FPitchAngle: single;
    FTurnAngle: single;
    procedure SetName(const Value: String);
    procedure SetXMask(const Value: TGLLibMaterialName);
    procedure SetYMask(const Value: TGLLibMaterialName);
    procedure SetZMask(const Value: TGLLibMaterialName);
    procedure SetMaterialLibrary(const Value: TGLMaterialLibrary);
    function XCan : TBitMap;
    function YCan : TBitMap;
    function ZCan : TBitMap;
  protected
    { Protected Declarations }
    function GetDisplayName : String; override;
  public
	 { Public Declarations }
	 constructor Create(Collection : TCollection); override;
	 destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    procedure UpdateExtents;
    procedure Roll(Angle : Single);
    procedure Turn(Angle : Single);
    procedure Pitch(Angle : Single);
    // this generates a xmask from another mask just to fill gaps, depth is dependant on frommask width and height
    procedure GenerateMaskFromProjection(FromMask, ToMask : TGLEProjectedParticleMask; Depth : integer);
  published
	 { Published Declarations }
    // scales and positions
    property Scale : TGLCoordinates read FScale write FScale;
    property Position : TGLCoordinates read FPosition write FPosition;
    // the reference name of the particle mask
    property Name : String read FName write SetName;
    property MaterialLibrary : TGLMaterialLibrary read FMaterialLibrary write SetMaterialLibrary;
    // mask images, make sure materiallibrary is assigned
    property XMask : TGLLibMaterialName read FXMask write SetXMask;
    property YMask : TGLLibMaterialName read FYMask write SetYMask;
    property ZMask : TGLLibMaterialName read FZMask write SetZMask;
    // background color is the color that prevents particles from being positioned there
    property BackgroundColor : TColor read FBackgroundColor write FBackgroundColor;
    // maskcolor is where particles are allowed to be positioned
    property MaskColor : TColor read FMaskColor write FMaskColor;
    // just the average angles for orientation
    property RollAngle : single read FRollAngle write FRollAngle;
    property PitchAngle : single read FPitchAngle write FPitchAngle;
    property TurnAngle : single read FTurnAngle write FTurnAngle;
  end;

  TGLEParticleMasks = class (TCollection)
  protected
	 { Protected Declarations }
    Owner : TComponent;
	 function GetOwner: TPersistent; override;
    procedure SetItems(index : Integer; const val : TGLEParticleMask);
	 function GetItems(index : Integer) : TGLEParticleMask;

  public
    { Public Declarations }
    function Add : TGLEParticleMask;
    constructor Create(AOwner : TComponent);
    property Items[index : Integer] : TGLEParticleMask read GetItems write SetItems; default;
  end;

  TGLEParticleMasksManager = class(TComponent)
  private
    FParticleMasks: TGLEParticleMasks;
    { Private declarations }
  protected
    { Protected declarations }
    procedure ApplyOrthoGraphic(var Vec : TVector3f; Mask : TGLEParticleMask);
    procedure ApplyRotation(var Vec : TVector3f; Mask : TGLEParticleMask);
    procedure ApplyRotationTarget(var Vec : TVector3f; Mask : TGLEParticleMask; TargetObject : TGLBaseSceneObject);
    procedure ApplyScaleAndPosition(var Vec : TVector3f; Mask : TGLEParticleMask);
    procedure ApplyScaleAndPositionTarget(var Vec : TVector3f; Mask : TGLEParticleMask; TargetObject : TGLBaseSceneObject);
    procedure FindParticlePosition(var Vec : TVector3f; Mask : TGLEParticleMask);
  public
    { Public declarations }
    constructor Create(AOwner : TComponent); override;
    destructor Destroy; override;
    function CreateParticlePositionFromMask(MaskName : string) : TVector3f;
    function TargetParticlePositionFromMask(TargetObject : TGLBaseSceneObject; MaskName : String) : TVector3f;
    procedure SetParticlePositionFromMask(Particle : TGLParticle; MaskName : string);
    procedure SetParticlePositionFromMaskTarget(Particle : TGLParticle; MaskName : String; TargetObject : TGLBaseSceneObject);
    function ParticleMaskByName(MaskName : string) : TGLEParticleMask;

  published
    { Published declarations }
    property ParticleMasks : TGLEParticleMasks read FParticleMasks write FParticleMasks;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('GLScene GameUtils', [TGLEParticleMasksManager]);
end;

{ TGLEParticleMasks }

function TGLEParticleMasks.Add: TGLEParticleMask;
begin
   Result:=(inherited Add) as TGLEParticleMask;
end;

constructor TGLEParticleMasks.Create(AOwner: TComponent);
begin
   inherited Create(TGLEParticleMask);
   Owner := AOwner;
end;

function TGLEParticleMasks.GetItems(index: Integer): TGLEParticleMask;
begin
   Result:=TGLEParticleMask(inherited Items[index]);
end;

function TGLEParticleMasks.GetOwner: TPersistent;
begin
   Result:=Owner;
end;

procedure TGLEParticleMasks.SetItems(index: Integer;
  const val: TGLEParticleMask);
begin
   inherited Items[index]:=val;
end;

{ TGLEParticleMask }

procedure TGLEParticleMask.Assign(Source: TPersistent);
begin
  if Source is TGLEParticleMask then
  begin
     FScale.Assign(TGLEParticleMask(Source).FScale);
     FPosition.Assign(TGLEParticleMask(Source).FPosition);
     FMaterialLibrary := TGLEParticleMask(Source).FMaterialLibrary;
     FXMask := TGLEParticleMask(Source).FXMask;
     FYMask := TGLEParticleMask(Source).FYMask;
     FZMask := TGLEParticleMask(Source).FZMask;
  end else
  inherited Assign(Source);
end;

constructor TGLEParticleMask.Create(Collection: TCollection);
begin
  inherited Create(Collection);

  FName := 'ParticleMask' + IntToStr(ID);

  FScale := TGLCoordinates.CreateInitialized(Self, XYZHMGVector, csPoint);
  FPosition := TGLCoordinates.CreateInitialized(Self, NullHmgPoint, csPoint);
  FMaterialLibrary := nil;

  FMaskColor := clWhite;
  FBackGroundColor := clBlack;

  FTurnAngle := 0;
  FRollAngle := 0;
  FPitchAngle := 0;

  FXMask := '';
  FYMask := '';
  FZMask := '';

  UpdateExtents;

end;

destructor TGLEParticleMask.Destroy;
begin
  FScale.Free;
  FPosition.Free;
  FMaterialLibrary := nil;
  FBackgroundColor := clBlack;
  FMaskColor := clWhite;
  FXMask := '';
  FYMask := '';
  FZMask := '';
  inherited Destroy;
end;

procedure TGLEParticleMask.GenerateMaskFromProjection(FromMask,
  ToMask: TGLEProjectedParticleMask; Depth: integer);

var FromBitMap : TBitmap;
    ToBitMap : TBitMap;
    X, Y : Integer;
    Rect : TRect;
begin

   FromBitMap := nil;
   ToBitMap := nil;

   if not assigned(FMaterialLibrary) then exit;

   if FromMask = ToMask then exit; // we can't project to the same mask

   if Depth < 0 then exit;

   case FromMask of
      pptXMask : FromBitMap := XCan;
      pptYMask : FromBitMap := YCan;
      pptZMask : FromBitMap := ZCan;
   end;

   if (FromBitMap.Width = 0) and (FromBitMap.Height = 0) then exit; // we can't use something that has no image

   case ToMask of
      pptXMask : ToBitMap := XCan;
      pptYMask : ToBitMap := YCan;
      pptZMask : ToBitMap := ZCan;
   end;

   ToBitMap.Width := FromBitMap.Width;
   ToBitMap.Height := FromBitMap.Height;

   ToBitMap.Canvas.Pen.Color := FBackgroundColor;
   ToBitMap.Canvas.Pen.Style := psSolid;
   ToBitMap.Canvas.Brush.Color := FBackgroundColor;
   ToBitMap.Canvas.Brush.Style := bsSolid;

   Rect.Left := 0;
   Rect.Top := 0;
   Rect.Right := ToBitMap.Width;
   Rect.Bottom := ToBitMap.Height;

   ToBitMap.Canvas.FillRect(Rect);

   ToBitMap.Canvas.Pen.Color := FMaskColor;
   ToBitMap.Canvas.Brush.Color := FMaskColor;

   for X := 0 to ToBitMap.Width do
      for Y := 0 to ToBitMap.Height do
      begin
         // from x mask
         if (FromMask = pptXMask) and (ToMask = pptYMask) then
            if FromBitMap.Canvas.Pixels[X,Y] = FMaskColor then
            begin
               ToBitMap.Canvas.MoveTo(((FromBitmap.Width - Depth) div 2), x);
               ToBitMap.Canvas.LineTo(((FromBitmap.Width + Depth) div 2), x);
            end;
         if (FromMask = pptXMask) and (ToMask = pptZMask) then
            if FromBitMap.Canvas.Pixels[X,Y] = FMaskColor then
            begin
               ToBitMap.Canvas.MoveTo(((FromBitmap.Width - Depth) div 2), y);
               ToBitMap.Canvas.LineTo(((FromBitmap.Width + Depth) div 2), y);
            end;
         // from y mask
         if (FromMask = pptYMask) and (ToMask = pptXMask) then
            if FromBitMap.Canvas.Pixels[X,Y] = FMaskColor then
            begin
               ToBitMap.Canvas.MoveTo(y, ((FromBitmap.Height - Depth) div 2));
               ToBitMap.Canvas.LineTo(y, ((FromBitmap.Height + Depth) div 2));
            end;
         if (FromMask = pptYMask) and (ToMask = pptZMask) then
            if FromBitMap.Canvas.Pixels[X,Y] = FMaskColor then
            begin
               ToBitMap.Canvas.MoveTo(x, ((FromBitmap.Height - Depth) div 2));
               ToBitMap.Canvas.LineTo(x, ((FromBitmap.Height + Depth) div 2));
            end;
         // from z mask
         if (FromMask = pptZMask) and (ToMask = pptXMask) then
            if FromBitMap.Canvas.Pixels[X,Y] = FMaskColor then
            begin
               ToBitMap.Canvas.MoveTo(((FromBitmap.Width - Depth) div 2), y);
               ToBitMap.Canvas.LineTo(((FromBitmap.Width + Depth) div 2), y);
            end;
         if (FromMask = pptZMask) and (ToMask = pptYMask) then
            if FromBitMap.Canvas.Pixels[X,Y] = FMaskColor then
            begin
               ToBitMap.Canvas.MoveTo(x, ((FromBitmap.Height - Depth) div 2));
               ToBitMap.Canvas.LineTo(x, ((FromBitmap.Height + Depth) div 2));
            end;

      end;

   UpdateExtents;

end;

function TGLEParticleMask.GetDisplayName: String;
begin
   Result := '';
   if FName <> '' then
      Result := FName
   else
      Result := 'TGLEParticleMask';
end;

procedure TGLEParticleMask.Pitch(Angle: Single);
begin
   FPitchAngle := FPitchAngle + Angle;
end;

procedure TGLEParticleMask.Roll(Angle: Single);
begin
   FRollAngle := FRollAngle + Angle;
end;

procedure TGLEParticleMask.SetMaterialLibrary(
  const Value: TGLMaterialLibrary);
begin
  FMaterialLibrary := Value;
  UpdateExtents;
end;

procedure TGLEParticleMask.SetName(const Value: String);
var i : integer;
begin
  for i := 1 to Length(Value) do
     if Value[i] = ' ' then
     begin
        raise Exception.Create('Cannot contain spaces or special characters.');
        Exit;
     end;
  FName := Value;
end;

procedure TGLEParticleMask.SetXMask(const Value: TGLLibMaterialName);
begin
  FXMask := Value;
  if assigned(FMaterialLibrary) then
     if not assigned(FMaterialLibrary.LibMaterialByName(FXMask)) then
     begin
        XCan.Width := 0;
        XCan.Height := 0;
     end;
  UpdateExtents;
end;

procedure TGLEParticleMask.SetYMask(const Value: TGLLibMaterialName);
begin
  FYMask := Value;
  if assigned(FMaterialLibrary) then
     if not assigned(FMaterialLibrary.LibMaterialByName(FYMask)) then
     begin
        YCan.Width := 0;
        YCan.Height := 0;
     end;
  UpdateExtents;
end;

procedure TGLEParticleMask.SetZMask(const Value: TGLLibMaterialName);
begin
  FZMask := Value;
  if assigned(FMaterialLibrary) then
     if not assigned(FMaterialLibrary.LibMaterialByName(FZMask)) then
     begin
        ZCan.Width := 0;
        ZCan.Height := 0;
     end;
  UpdateExtents;
end;

procedure TGLEParticleMask.Turn(Angle: Single);
begin
   FTurnAngle := FTurnAngle + Angle;
end;

procedure TGLEParticleMask.UpdateExtents;
var MinXX, MinXY, MinYX, MinYY, MinZX, MinZY : integer;
    MaxXX, MaxXY, MaxYX, MaxYY, MaxZX, MaxZY : integer;
    X,Y : integer;
begin

   FMinX := 0; // min extents
   FMinY := 0;
   FMinZ := 0;
   FMaxX := 0; // max extents
   FMaxY := 0;
   FMaxZ := 0;

   IXW := 0; // widths
   IYW := 0;
   IZW := 0;
   IXH := 0; // heights
   IYH := 0;
   IZH := 0;

   MinXX := 0; // min plane mask extents
   MinXY := 0;
   MinYX := 0;
   MinYY := 0;
   MinZX := 0;
   MinZY := 0;

   MaxXX := 0; // max plane mask extents
   MaxXY := 0;
   MaxYX := 0;
   MaxYY := 0;
   MaxZX := 0;
   MaxZY := 0;

   BogusMask := true; // prevents system locks
   BogusMaskX := true;
   BogusMaskY := true;
   BogusMaskZ := true;

   // we don't find it? no point in continuing
   if not assigned(FMaterialLibrary) then exit;

   // it is recommended to have 3 different masks
   // if there is only 2, the 3rd image will just take the largest extents and use them... creating not a very good effect

   if XCan <> nil then
   begin
      IXW := XCan.Width;
      IXH := XCan.Height;
   end;

   if YCan <> nil then
   begin
      IYW := YCan.Width;
      IYH := YCan.Height;
   end;

   if ZCan <> nil then
   begin
      IZW := ZCan.Width;
      IZH := ZCan.Height;
   end;

   // we find the largest dimensions of each image and give them to min mask extents so we work backwards

   MX := MaxInteger(MaxInteger(IXW, IYW),IZW);
   MY := MaxInteger(MaxInteger(IXH, IYH),IZH);

   if XCan <> nil then
   begin
      MinXX := MX;
      MinXY := MY;
   end;
   if YCan <> nil then
   begin
      MinYX := MX;
      MinYY := MY;
   end;
   if ZCan <> nil then
   begin
      MinZX := MX;
      MinZY := MY;
   end;

   // this is where we work backwards from to find the max size of the dimensions...
   // in a sense, this provides information for the randomizing, and speeds up the code
   for x := 0 to MX do
      for y := 0 to MY do
      begin
         if XCan <> nil then
         if (X <= XCan.Width) and (Y <= XCan.Height) then
            if (XCan.Canvas.Pixels[x,y] = FMaskColor) then
            begin
               if x > MaxXX then MaxXX := x;
               if y > MaxXY then MaxXY := y;
               if x < MinXX then MinXX := x;
               if x < MinXY then MinXY := y;
               BogusMaskX := false;
            end;
         if YCan <> nil then
         if (X <= YCan.Width) and (Y <= YCan.Height) then
            if (YCan.Canvas.Pixels[x,y] = FMaskColor) then
            begin
               if x > MaxYX then MaxYX := x;
               if y > MaxYY then MaxYY := y;
               if x < MinYX then MinYX := x;
               if x < MinYY then MinYY := y;
               BogusMaskY := false;
            end;
         if ZCan <> nil then
         if (X <= ZCan.Width) and (Y <= ZCan.Height) then
            if (ZCan.Canvas.Pixels[x,y] = FMaskColor) then
            begin
               if x > MaxZX then MaxZX := x;
               if y > MaxZY then MaxZY := y;
               if x < MinZX then MinZX := x;
               if x < MinZY then MinZY := y;
               BogusMaskZ := false;
            end;
      end;

   BogusMask := (BogusMaskX or BogusMaskY or BogusMaskZ);

   // here we find our 3d extents from a 1st angle orthographic shape

   FMinX := MinInteger(MinZX,MinYX);
   FMinY := MinInteger(MinXY,MinZY);
   FMinZ := MinInteger(MinXX,MinYY);

   FMaxX := MaxInteger(MaxZX,MaxYX);
   FMaxY := MaxInteger(MaxXY,MaxZY);
   FMaxZ := MaxInteger(MaxXX,MaxYY);

   // this is the largest mask image sizes converted to orthographic and extents... used later on

   LX := MaxInteger(IZW, IYW);
   LY := MaxInteger(IXH, IZH);
   LZ := MaxInteger(IXW, IYH);
end;

function TGLEParticleMask.XCan: TBitMap;
begin

   Result := nil;
   if not assigned(FMaterialLibrary) then exit;
   if not assigned(FMaterialLibrary.LibMaterialByName(FXMask)) then exit;
   if FMaterialLibrary.LibMaterialByName(FXMask).Material.Texture.ImageClassName <> TGLPersistentImage.ClassName then exit;

   Result := TBitMap((FMaterialLibrary.LibMaterialByName(FXMask).Material.Texture.Image as TGLPersistentImage).Picture.Bitmap);

end;

function TGLEParticleMask.YCan: TBitMap;
begin

   Result := nil;
   if not assigned(FMaterialLibrary) then exit;
   if not assigned(FMaterialLibrary.LibMaterialByName(FYMask)) then exit;
   if FMaterialLibrary.LibMaterialByName(FYMask).Material.Texture.ImageClassName <> TGLPersistentImage.ClassName then exit;

   Result := TBitMap((FMaterialLibrary.LibMaterialByName(FYMask).Material.Texture.Image as TGLPersistentImage).Picture.Bitmap);

end;

function TGLEParticleMask.ZCan: TBitMap;
begin

   Result := nil;
   if not assigned(FMaterialLibrary) then exit;
   if not assigned(FMaterialLibrary.LibMaterialByName(FZMask)) then exit;
   if FMaterialLibrary.LibMaterialByName(FZMask).Material.Texture.ImageClassName <> TGLPersistentImage.ClassName then exit;

   Result := TBitMap((FMaterialLibrary.LibMaterialByName(FZMask).Material.Texture.Image as TGLPersistentImage).Picture.Bitmap);

end;

{ TGLEParticleMasksManager }

procedure TGLEParticleMasksManager.ApplyOrthoGraphic(var Vec: TVector3f;
  Mask: TGLEParticleMask);
begin
   Vec[0] := (Mask.LX/2-Vec[0])/Mask.LX;
   Vec[1] := (Mask.LY/2-Vec[1])/Mask.LY;
   Vec[2] := (Mask.LZ/2-Vec[2])/Mask.LZ;
end;

procedure TGLEParticleMasksManager.ApplyRotation(var Vec: TVector3f;
  Mask: TGLEParticleMask);
begin
   Vec := VectorRotateAroundX(Vec, DegToRad(Mask.FPitchAngle));
   Vec := VectorRotateAroundY(Vec, DegToRad(Mask.FTurnAngle));
   Vec := VectorRotateAroundZ(Vec, DegToRad(Mask.FRollAngle));
end;

procedure TGLEParticleMasksManager.ApplyRotationTarget(var Vec: TVector3f;
  Mask: TGLEParticleMask; TargetObject: TGLBaseSceneObject);
begin

   Vec := VectorRotateAroundX(Vec, DegToRad(Mask.FPitchAngle + TargetObject.Rotation.X));
   Vec := VectorRotateAroundY(Vec, DegToRad(Mask.FTurnAngle + TargetObject.Rotation.Y));
   Vec := VectorRotateAroundZ(Vec, DegToRad(Mask.FRollAngle + TargetObject.Rotation.Z));
end;

procedure TGLEParticleMasksManager.ApplyScaleAndPosition(
  var Vec: TVector3f; Mask: TGLEParticleMask);
begin
   Vec[0] := Vec[0]*Mask.FScale.DirectX + Mask.FPosition.DirectX;
   Vec[1] := Vec[1]*Mask.FScale.DirectY + Mask.FPosition.DirectY;
   Vec[2] := Vec[2]*Mask.FScale.DirectZ + Mask.FPosition.DirectZ;
end;

procedure TGLEParticleMasksManager.ApplyScaleAndPositionTarget(
  var Vec: TVector3f; Mask: TGLEParticleMask;
  TargetObject: TGLBaseSceneObject);
begin
   Vec[0] := Vec[0]*Mask.FScale.DirectX*TargetObject.Scale.DirectX + Mask.FPosition.DirectX + TargetObject.AbsolutePosition[0];
   Vec[1] := Vec[1]*Mask.FScale.DirectY*TargetObject.Scale.DirectY + Mask.FPosition.DirectY + TargetObject.AbsolutePosition[1];
   Vec[2] := Vec[2]*Mask.FScale.DirectZ*TargetObject.Scale.DirectZ + Mask.FPosition.DirectZ + TargetObject.AbsolutePosition[2];
end;

constructor TGLEParticleMasksManager.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FParticleMasks := TGLEParticleMasks.Create(Self);
end;

function TGLEParticleMasksManager.CreateParticlePositionFromMask(
  MaskName: string): TVector3f;
var Mask : TGLEParticleMask;
begin
   Result := NullVector;

   Mask := ParticleMaskByName(MaskName);

   if not assigned(Mask) then exit;
   if Mask.BogusMask then exit;

   // finds the particle position on the masks
   FindParticlePosition(Result, Mask);
   // this converts 1st angle orthographic to 3rd angle orthograhic
   ApplyOrthoGraphic(Result, Mask);
   // this just turns it accordingly
   ApplyRotation(Result, Mask);
   // this applies the scales and positioning
   ApplyScaleAndPosition(Result, Mask);

end;

destructor TGLEParticleMasksManager.Destroy;
begin
  FParticleMasks.Destroy;
  inherited Destroy;
end;

procedure TGLEParticleMasksManager.FindParticlePosition(var Vec: TVector3f;
  Mask: TGLEParticleMask);
var X,Y,Z : integer;
begin
   repeat
      X := Random(Mask.FMaxX - Mask.FMinX) + Mask.FMinX;
      Y := Random(Mask.FMaxY - Mask.FMinY) + Mask.FMinY;
      Z := Random(Mask.FMaxZ - Mask.FMinZ) + Mask.FMinZ;
   until (Mask.XCan.Canvas.Pixels[Z,Y] = Mask.FMaskColor) and
         (Mask.YCan.Canvas.Pixels[X,Z] = Mask.FMaskColor) and
         (Mask.ZCan.Canvas.Pixels[X,Y] = Mask.FMaskColor);
   MakeVector(Vec, X, Y, Z);
end;

function TGLEParticleMasksManager.ParticleMaskByName(
  MaskName: string): TGLEParticleMask;
var i : integer;
begin
   Result := nil;
   if FParticleMasks.Count > 0 then
      for i := 0 to FParticleMasks.Count - 1 do
         if FParticleMasks.Items[i].FName = MaskName then Result := FParticleMasks.Items[i];
end;

procedure TGLEParticleMasksManager.SetParticlePositionFromMask(
  Particle: TGLParticle; MaskName: string);
begin
   if not assigned(Particle) then exit;
   Particle.Position := CreateParticlePositionFromMask(MaskName);
end;

procedure TGLEParticleMasksManager.SetParticlePositionFromMaskTarget(
  Particle : TGLParticle; MaskName: String; TargetObject: TGLBaseSceneObject);
begin
   if not assigned(Particle) then exit;

   Particle.Position := TargetParticlePositionFromMask(TargetObject, MaskName);
end;

function TGLEParticleMasksManager.TargetParticlePositionFromMask(
  TargetObject: TGLBaseSceneObject; MaskName: String): TVector3f;
var Mask : TGLEParticleMask;
begin

   Result := NullVector;
   if not assigned(TargetObject) then exit;

   Mask := ParticleMaskByName(MaskName);
   if not assigned(Mask) then exit;

   if Mask.BogusMask then exit;

   // finds the particle position on the masks
   FindParticlePosition(Result, Mask);
   // this converts 1st angle orthographic to 3rd angle orthograhic
   ApplyOrthoGraphic(Result, Mask);
   // this just turns it accordingly
   ApplyRotationTarget(Result, Mask, TargetObject);
   // this applies the scales and positioning
   ApplyScaleAndPositionTarget(Result, Mask, TargetObject);

end;

end.