//
// VKScene Component Library, based on GLScene http://glscene.sourceforge.net 
//
{
   Material Preview frame. 
}

unit FRMaterialPreview;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Variants, System.Math.Vectors,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Media, FMX.Viewport3D, FMX.ListBox, FMX.Types3D, FMX.Controls3D,
  FMX.Objects3D, FMX.MaterialSources,

  VKS.Scene, VKS.BaseClasses, VKS.SceneViewer, VKS.Material, VKS.Teapot,
  VKS.HUDObjects, VKS.GeomObjects, VKS.Color, VKS.Coordinates, FMX.Layers3D;

type
  TRMaterialPreview = class(TFrame)
    CBObject: TComboBox;
    Camera: TCamera;
    Cube: TCube;
    Sphere: TSphere;
    LightSource: TLight;
    CBBackground: TComboBox;
    BackGroundSprite: TImage3D;
    LightMaterialSource: TLightMaterialSource;
    Cone: TCone;
    Teapot: TModel3D;
    World: TDummy;
    Light: TDummy;
    FireSphere: TSphere;
    GLSViewer: TViewport3D;
    procedure CBObjectChange(Sender: TObject);
    procedure CBBackgroundChange(Sender: TObject);
    procedure GLSViewerMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Single);
    procedure GLSViewerMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Single);
    procedure GLSViewerMouseWheel(Sender: TObject; Shift: TShiftState;
      WheelDelta: Integer; var Handled: Boolean);
    procedure GLSViewerMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Single);
  private
    FLibMaterial: TVKAbstractLibMaterial;
    function GetMaterial: TVKMaterial;
    procedure SetMaterial(const Value: TVKMaterial);
    function GetLibMaterial: TVKAbstractLibMaterial;
    procedure SetLibMaterial(const Value: TVKAbstractLibMaterial);
    
  public
    
    IsMouseUp : Boolean;
    Down : TPointF;
    GLMaterialLibrary: TVKMaterialLibrary;
    constructor Create(AOwner : TComponent); override;
    property Material : TVKMaterial read GetMaterial
      write SetMaterial;
    property LibMaterial : TVKAbstractLibMaterial read GetLibMaterial
      write SetLibMaterial;
  end;

implementation

{$R *.fmx}

var
  MX, MY: Integer;

{ TRMaterialPreview }

constructor TRMaterialPreview.Create(AOwner: TComponent);
begin
  inherited;
   BackGroundSprite.Position.X := GLSViewer.Width/2;
   BackGroundSprite.Position.Y := GLSViewer.Height/2;
   BackGroundSprite.Width := GLSViewer.Width;
   BackGroundSprite.Height := GLSViewer.Height;

   CBObject.ItemIndex:=0;       CBObjectChange(Self);
   CBBackground.ItemIndex:=0;   CBBackgroundChange(Self);
end;

procedure TRMaterialPreview.CBObjectChange(Sender: TObject);
var
   i : Integer;
begin
   i:=CBObject.ItemIndex;
   Cube.Visible   := I = 0;
   Sphere.Visible := I = 1;
   Cone.Visible   := I = 2;
   Teapot.Visible := I = 3;
end;

procedure TRMaterialPreview.CBBackgroundChange(Sender: TObject);
var
   bgColor : TColor;
begin
   case CBBackground.ItemIndex of
      1 : bgColor := TColors.White;
      2 : bgColor := TColors.Black;
      3 : bgColor := TColors.Blue;
      4 : bgColor := TColors.Red;
      5 : bgColor := TColors.Green;
   else
      bgColor := TColors.SysNone;
   end;
   if (bgColor<>TColors.SysNone) then
     BackGroundSprite.Bitmap.Canvas.Fill.Color := bgColor;
end;

procedure TRMaterialPreview.GLSViewerMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Single);
begin
  if (ssLeft in Shift) and (ssLeft in Shift) then
  begin
    World.RotationAngle.X := World.RotationAngle.X - ((Y - Down.Y) * 0.3);
    World.RotationAngle.Y := World.RotationAngle.Y + ((X - Down.X) * 0.3);

    Down := PointF(X, Y);
  end;
end;

procedure TRMaterialPreview.GLSViewerMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
  IsMouseUp := False;
end;

procedure TRMaterialPreview.GLSViewerMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
  Down := PointF(X, Y);
  IsMouseUp := True;
end;

procedure TRMaterialPreview.GLSViewerMouseWheel(Sender: TObject;
  Shift: TShiftState; WheelDelta: Integer; var Handled: Boolean);
var
  AVector: TVector3D;
begin
  AVector := Vector3D(0, 0, 1);
  Camera.Position.Vector := Camera.Position.Vector + AVector * (WheelDelta / 120) * 0.3;
end;

function TRMaterialPreview.GetMaterial: TVKMaterial;
begin
  Result := GLMaterialLibrary.Materials[0].Material;
end;

procedure TRMaterialPreview.SetMaterial(const Value: TVKMaterial);
begin
  GLMaterialLibrary.Materials[0].Material.Assign(Value.GetActualPrimaryMaterial);
end;

function TRMaterialPreview.GetLibMaterial: TVKAbstractLibMaterial;
begin
  Result := FLibMaterial;
end;

procedure TRMaterialPreview.SetLibMaterial(const Value: TVKAbstractLibMaterial);
begin
  FLibMaterial := Value;
  if Assigned(FLibMaterial) then
  begin
    with GLMaterialLibrary.Materials[0] do
    begin
      Material.MaterialLibrary := FLibMaterial.MaterialLibrary;
      Material.LibMaterialName := FLibMaterial.Name
    end;
  end
  else
  with GLMaterialLibrary.Materials[0] do
  begin
    Material.MaterialLibrary := nil;
    Material.LibMaterialName := '';
  end;
end;

end.
