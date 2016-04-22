//
// VKScene project, http://glscene.sourceforge.net 
//
{
   RGB+Alpha color editor. 
}
unit FRColorEditor;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Colors, FMX.Edit, FMX.Controls.Presentation, FMX.Objects,

  VKS.VectorGeometry, VKS.Color, VKS.Texture, VKS.VectorTypes,
  VKS.Crossplatform;

type
  TRColorEditor = class(TFrame)
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Panel1: TPanel;
    ColorEditorPaintBox: TPaintBox;
    RedEdit: TEdit;
    GreenEdit: TEdit;
    BlueEdit: TEdit;
    AlphaEdit: TEdit;
    PAPreview: TColorPanel;
    procedure TBEChange(Sender: TObject);
    procedure ColorEditorPaintBoxPaint(Sender: TObject; Canvas: TCanvas);
    procedure FrameResize(Sender: TObject);
    procedure ColorEditorPaintBoxMouseDown(Sender: TObject;
      Button: TMouseButton; Shift: TShiftState; X, Y: Single);
    procedure ColorEditorPaintBoxMouseMove(Sender: TObject; Shift: TShiftState;
      X, Y: Single);
    procedure ColorEditorPaintBoxMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Single);
    procedure RedEditChange(Sender: TObject);
    procedure GreenEditChange(Sender: TObject);
    procedure BlueEditChange(Sender: TObject);
    procedure AlphaEditChange(Sender: TObject);
    procedure PAPreviewDblClick(Sender: TObject);
  private
    { Private declarations }
    FOnChange : TNotifyEvent;
    Updating : Boolean;
    WorkBitmap : TBitmap;
    RedValue : Integer;
    GreenValue : integer;
    BlueValue : integer;
    AlphaVAlue : integer;
    DraggingValue : (None,Red,Green,Blue,Alpha);
    procedure SetColor(const val : THomogeneousFltVector);
    function GetColor : THomogeneousFltVector;
    procedure DrawContents;
    procedure DragColorSliderToPosition(XPos : integer);
    procedure ContentsChanged;
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property Color : THomogeneousFltVector read GetColor write SetColor;
  published
    property OnChange : TNotifyEvent read FOnChange write FOnChange;

  end;

implementation

{$R *.fmx}

const
  MaxColorValue = 255;
  MaxAlphaValue = 1000;

  ColorSliderLeft = 40;
  ColorSliderWidth = 128;
  ColorSliderHeight = 16;
  ColorViewHeight = 7;
  ColorSliderMaxValue = ColorSliderWidth - 2;

  RTop = 8;
  GTop = 30;
  BTop = 52;
  ATop = 74;

  PreviewPanelLeft = 216;
  PreviewPanelTop = 10;
  PreviewPanelWidth = 65;
  PreviewPanelHeight = 74;

  AlphaCheckSize = 9;
  AlphaChecksHigh = 4;
  AlphaChecksWide = 7;

procedure TRColorEditor.TBEChange(Sender: TObject);
begin
  PAPreview.Color:=RGB(RedValue, GreenValue, BlueValue);
  if (not updating) and Assigned(FOnChange) then FOnChange(Self);
end;

procedure TRColorEditor.SetColor(const val: THomogeneousFltVector);
begin
  RedValue:=Round(val.X*255);
  GreenValue:=Round(val.Y*255);
  BlueValue:=Round(val.Z*255);
  AlphaValue:=Round(val.W*1000);

  ContentsChanged;
end;

function TRColorEditor.GetColor: THomogeneousFltVector;
begin
   Result:=VectorMake(RedValue/255, GreenValue/255, BlueValue/255,
                      AlphaValue/1000);
end;

procedure TRColorEditor.ColorEditorPaintBoxPaint(Sender: TObject;
  Canvas: TCanvas);
begin
  ColorEditorPaintBox.Canvas.Bitmap.Assign(WorkBitmap);
  RedEdit.Height := 16;
  GreenEdit.Height := 16;
  BlueEdit.Height := 16;
  AlphaEdit.Height := 16;
end;

constructor TRColorEditor.Create(AOwner: TComponent);
begin
  inherited;
  WorkBitmap := TBitmap.Create;
  (* in VCL
  WorkBitmap.PixelFormat := glpf24bit;
  WorkBitmap.Handle := TBitmapHandleType.bmDib;
  *)
  RedValue := 200;
  GreenValue := 120;
  BlueValue := 60;
  AlphaValue := 450;
end;

destructor TRColorEditor.Destroy;
begin
  inherited;
  WorkBitmap.Free;
end;

procedure TRColorEditor.FrameResize(Sender: TObject);
begin
  WorkBitmap.Width := Round(ColorEditorPaintBox.Width);
  WorkBitmap.Height := Round(ColorEditorPaintBox.Height);
  with WorkBitmap.Canvas do
  begin
    { TODO : rewright to use TPath and SVG drawing }
    (*
    Pen.Color := TColors.Lime;
    MoveTo(0,0);
    LineTo(Width-1,Height-1);
    MoveTo(Width-1,0);
    LineTo(0,Height-1);
    *)
  end;
  DrawCOntents;

  // Edits have an annoying habit of forgetting their height if they are small
  RedEdit.Height := 18;
  GreenEdit.Height := 18;
  BlueEdit.Height := 18;
  AlphaEdit.Height := 18;
end;

function ColorValueToColorViewPosition(ColorValue : integer) : integer;
begin
  Result := Round( (ColorSliderMaxValue/(MaxColorValue+1)) * ColorValue);
end;

function AlphaValueToColorViewPosition(AlphaValue : integer) : integer;
begin
  Result := Round( (ColorSliderMaxValue/(MaxAlphaValue+1)) * AlphaValue);
end;

function ColorViewPositionToColorValue(ColorViewPosition : integer) : integer;
begin
  if ColorViewPosition < 0 then ColorViewPosition := 0;
  if ColorViewPosition > ColorSliderMaxValue then ColorViewPosition := ColorSliderMaxValue;

  Result := Round(ColorViewPosition / (ColorSliderMaxValue/(MaxColorValue)));
end;

function ColorViewPositionToAlphaValue(ColorViewPosition : integer) : integer;
begin
  if ColorViewPosition < 0 then ColorViewPosition := 0;
  if ColorViewPosition > ColorSliderMaxValue then ColorViewPosition := ColorSliderMaxValue;
  Result := Round(ColorViewPosition / (ColorSliderMaxValue/(MaxAlphaValue)));
end;

procedure TRColorEditor.DrawContents;
var
  Position : integer;
  tx,ty : integer;
  RViewColor : TColor;
  GViewColor : TColor;
  BViewColor : TColor;
  AViewColor : TColor;
  ViewLevel : Integer;
  WhiteCheckColor : TColor;
  BlackCheckColor : TColor;
  AValue : Single;
  ARect : TRectF;
begin
  WorkBitmap.Canvas.Fill.Color := TColors.cBTNFACE;
  ARect := TRectF.Create(0,0,WorkBitmap.Width,WorkBitmap.Height);
  WorkBitmap.Canvas.BeginScene;
  WorkBitmap.Canvas.FillRect(ARect,20,40,AllCorners,100);
  WorkBitmap.Canvas.EndScene;
    { TODO : must be replaced with fmx font, brush and textout }
    (*
    Font.Color := TColors.Black;
    Font.Name := 'Arial';
    Font.Height := 14;

    TextOut(6,5,'Red');
    TextOut(6,26,'Green');
    TextOut(6,48,'Blue');
    TextOut(6,70,'Alpha');

    Brush.Color := TColors.Black;
    FrameRect(Rect(ColorSliderLeft,RTop,ColorSliderLeft+ColorSliderWidth,RTop+ColorViewHeight));
    FrameRect(Rect(ColorSliderLeft,GTop,ColorSliderLeft+ColorSliderWidth,GTop+ColorViewHeight));
    FrameRect(Rect(ColorSliderLeft,BTop,ColorSliderLeft+ColorSliderWidth,BTop+ColorViewHeight));
    FrameRect(Rect(ColorSliderLeft,ATop,ColorSliderLeft+ColorSliderWidth,ATop+ColorViewHeight));

    // Color View Frames
    Pen.Color := TColors.cBTNSHADOW;
    PolyLine([  Point(ColorSliderLeft-1,RTop+ColorViewHeight),
                Point(ColorSliderLeft-1,RTop-1),
                Point(ColorSliderLeft+ColorSliderWidth+1,RTop-1)  ]);

    PolyLine([  Point(ColorSliderLeft-1,GTop+ColorViewHeight),
                Point(ColorSliderLeft-1,GTop-1),
                Point(ColorSliderLeft+ColorSliderWidth+1,GTop-1)  ]);

    PolyLine([  Point(ColorSliderLeft-1,BTop+ColorViewHeight),
                Point(ColorSliderLeft-1,BTop-1),
                Point(ColorSliderLeft+ColorSliderWidth+1,BTop-1)  ]);

    PolyLine([  Point(ColorSliderLeft-1,ATop+ColorViewHeight),
                Point(ColorSliderLeft-1,ATop-1),
                Point(ColorSliderLeft+ColorSliderWidth+1,ATop-1)  ]);

    Pen.Color := TColors.cBTNHIGHLIGHT;

    PolyLine([  Point(ColorSliderLeft,RTop+ColorViewHeight),
                Point(ColorSliderLeft+ColorSliderWidth,RTop+ColorViewHeight),
                Point(ColorSliderLeft+ColorSliderWidth,RTop) ]);

    PolyLine([  Point(ColorSliderLeft,GTop+ColorViewHeight),
                Point(ColorSliderLeft+ColorSliderWidth,GTop+ColorViewHeight),
                Point(ColorSliderLeft+ColorSliderWidth,GTop) ]);

    PolyLine([  Point(ColorSliderLeft,BTop+ColorViewHeight),
                Point(ColorSliderLeft+ColorSliderWidth,BTop+ColorViewHeight),
                Point(ColorSliderLeft+ColorSliderWidth,BTop) ]);

    PolyLine([  Point(ColorSliderLeft,ATop+ColorViewHeight),
                Point(ColorSliderLeft+ColorSliderWidth,ATop+ColorViewHeight),
                Point(ColorSliderLeft+ColorSliderWidth,ATop) ]);

  // Color pointer triangles

    Pen.Color := clBlack;
    Position:=ColorValueToColorViewPosition(RedValue) + ColorSliderLeft;
    PolyLine([ Point(Position,RTop+ColorViewHeight+2),
               Point(Position+6,RTop+ColorViewHeight+8),
               Point(Position-6,RTop+ColorViewHeight+8),
               Point(Position,RTop+ColorViewHeight+2)]);

    Position:=ColorValueToColorViewPosition(GreenValue) + ColorSliderLeft;
    PolyLine([ Point(Position,GTop+ColorViewHeight+2),
               Point(Position+6,GTop+ColorViewHeight+8),
               Point(Position-6,GTop+ColorViewHeight+8),
               Point(Position,GTop+ColorViewHeight+2)]);

    Position:=ColorValueToColorViewPosition(BlueValue) + ColorSliderLeft;
    PolyLine([ Point(Position,BTop+ColorViewHeight+2),
               Point(Position+6,BTop+ColorViewHeight+8),
               Point(Position-6,BTop+ColorViewHeight+8),
               Point(Position,BTop+ColorViewHeight+2)]);

    Position:=AlphaValueToColorViewPosition(AlphaValue) + ColorSliderLeft;
    PolyLine([ Point(Position,ATop+ColorViewHeight+2),
               Point(Position+6,ATop+ColorViewHeight+8),
               Point(Position-6,ATop+ColorViewHeight+8),
               Point(Position,ATop+ColorViewHeight+2)]);

    // Color view spectrums
    For tx := 1 to ColorSliderWidth - 2 do
    begin
      ViewLevel := (tx * 256) div ColorSliderWidth;
      AViewColor := (ViewLevel) + (ViewLevel shl 8) + (viewLevel shl 16);
      RViewColor := (ViewLevel) + (GreenValue Shl 8) + (BlueValue Shl 16);
      GViewColor := (RedValue) + (ViewLevel shl 8) + (BlueValue Shl 16);
      BViewColor := (RedValue) + (GreenValue Shl 8) + (ViewLevel Shl 16);
      For ty := 1 to ColorViewHeight -2 do
      begin
         Pixels[ColorSliderLeft+tx,Rtop+Ty]:=RViewCOlor;
         Pixels[ColorSliderLeft+tx,Gtop+Ty]:=GViewColor;
         Pixels[ColorSliderLeft+tx,Btop+Ty]:=BViewColor;
         Pixels[ColorSliderLeft+tx,Atop+Ty]:=AViewColor;
      end;
    end;

    // Color preview panel
    Pen.Color := clBtnShadow;
    PolyLine([  Point(PreviewPanelLeft-1,PreviewPanelTop+PreviewPanelHeight),
                Point(PreviewPanelLeft-1,PreviewPanelTop-1),
                Point(PreviewPanelLeft+PreviewPanelWidth,PreviewPanelTop-1) ]);
    Pen.Color := clBtnHighlight;
    PolyLine([  Point(PreviewPanelLeft,PreviewPanelTop+PreviewPanelHeight),
                Point(PreviewPanelLeft+PreviewPanelWidth,PreviewPanelTop+PreviewPanelHeight),
                Point(PreviewPanelLeft+PreviewPanelWidth,PreviewPanelTop) ]);

    Brush.Color := (RedValue) + (GreenValue Shl 8) + (BlueValue Shl 16);
    Pen.Color := clBlack;
    Rectangle(Rect(PreviewPanelLeft,PreviewPanelTop,PreviewPanelLeft+PreviewPanelWidth,PreviewPanelTop+PreviewPanelHeight div 2 ) );
    PolyLine([  Point(PreviewPanelLeft,PreviewPanelTop+PreviewPanelHeight div 2 -1),
                Point(PreviewPanelLeft,PreviewPanelTop+PreviewPanelHeight -1),
                Point(PreviewPanelLeft+PreviewPanelWidth-1,PreviewPanelTop+PreviewPanelHeight-1),
                Point(PreviewPanelLeft+PreviewPanelWidth-1,PreviewPanelTop+PreviewPanelHeight div 2-1)
             ]);

    AValue := AlphaValue / MaxAlphaValue;
    BlackCheckColor := Round(RedValue * Avalue) + Round(GreenValue*AValue) shl 8 + Round(BlueValue*AValue) shl 16;
    WhiteCheckColor := Round(RedValue * Avalue + (255 * (1-AValue))) + Round(GreenValue*AValue + (255 * (1-AValue))) shl 8 +  Round(BlueValue*AValue + (255 * (1-AValue))) shl 16;
    For ty := 0 to AlphaChecksHigh - 1 do
    begin
      For tx := 0 to AlphaChecksWide - 1 do
      begin
        if (tx+ty) and 1 = 0 then Brush.Color := BlackCheckColor else Brush.Color := WhiteCheckColor;
        FillRect(Rect(  PreviewPanelLeft+1 + tx*AlphaCheckSize,
                        PreviewPanelTop+PreviewPanelHeight Div 2 + ty*AlphaCheckSize,
                        PreviewPanelLeft+1 + (tx+1)*AlphaCheckSize,
                        PreviewPanelTop+PreviewPanelHeight Div 2 + (ty+1)*AlphaCheckSize
                      ));
      end;
    end;
    *)
end;

procedure TRColorEditor.ColorEditorPaintBoxMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
  DraggingValue := None;
  if Button = TMouseButton(mbLeft) then
  begin
    if (X > ColorSliderLeft-5) and ( X < (ColorSliderLeft+ColorSliderMaxValue+5)) then
    begin
      // In X range For Color Sliders
      If (Y > RTop) and ( (RTop+ColorSliderHeight) > Y ) then DraggingValue := Red;
      If (Y > GTop) and ( (GTop+ColorSliderHeight) > Y ) then DraggingValue := Green;
      If (Y > BTop) and ( (BTop+ColorSliderHeight) > Y ) then DraggingValue := Blue;
      If (Y > ATop) and ( (ATop+ColorSliderHeight) > Y ) then DraggingValue := Alpha;

      If DraggingValue <> None then
        DragColorSliderToPosition(Round(X)-ColorSliderLeft-1);
    end
  end;
end;

procedure TRColorEditor.DragColorSliderToPosition(XPos: integer);
begin
  case DraggingValue of
    Red: RedValue := ColorViewPositionToColorValue(XPos);
    Green: GreenValue := ColorViewPositionToColorValue(XPos);
    Blue: BlueValue := ColorViewPositionToColorValue(XPos);
    Alpha: AlphaValue := ColorViewPositionToAlphaValue(XPos);
  end;
  ContentsChanged;
end;

procedure TRColorEditor.ContentsChanged;
var
  ARect : TRectF;
begin
  if Not Updating then
  begin
    UpDating := True;
    DrawContents;
    ARect := TRectF.Create(0,0,WorkBitmap.Width,WorkBitmap.Height);
    WorkBitmap.Canvas.BeginScene();
    ColorEditorPaintBox.Canvas.DrawBitmap(WorkBitmap,ARect,ARect,50);
    WorkBitmap.Canvas.EndScene();

    RedEdit.Text := IntToStr(RedValue);
    GreenEdit.Text := IntToStr(GreenValue);
    BlueEdit.Text := IntToStr(BlueValue);
    AlphaEdit.Text := IntToStr(AlphaValue);

    PaPreview.Color := RedValue + (GreenValue Shl 8) + (BlueValue Shl 16);
    UpDating := False;

    TBEChange(Self);
  end;
end;

procedure TRColorEditor.ColorEditorPaintBoxMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Single);
begin
 if DraggingValue <> None then DragColorSliderToPosition(Round(X)-ColorSliderLeft-1);
end;

procedure TRColorEditor.ColorEditorPaintBoxMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
  if Button = TMouseButton(mbLeft) then DraggingValue := None;
end;

procedure TRColorEditor.RedEditChange(Sender: TObject);
var
  IntValue : integer;
begin
  IntValue := StrToIntDef(RedEdit.Text,-1);

  If (IntValue < 0) or (IntValue > MaxColorValue) then
  begin
    RedEdit.TextSettings.FontColor:= TColors.Red;
  end
  else
  begin
    RedEdit.TextSettings.FontColor:=TColors.cWINDOW;
    RedValue := IntValue;
    ContentsChanged;
  end;
end;


procedure TRColorEditor.GreenEditChange(Sender: TObject);
var
  IntValue : integer;
begin
  IntValue := StrToIntDef(GreenEdit.Text,-1);

  If (IntValue < 0) or (IntValue > MaxColorValue) then
  begin
    GreenEdit.TextSettings.FontColor:=TColors.Red;
  end
  else
  begin
    GreenEdit.TextSettings.FontColor:=TColors.cWINDOW;
    GreenValue := IntValue;
    ContentsChanged;
  end;
end;

procedure TRColorEditor.PAPreviewDblClick(Sender: TObject);
begin
  SetColor(ConvertWinColor(PAPreview.Color));
end;

procedure TRColorEditor.BlueEditChange(Sender: TObject);
var
  IntValue : integer;
begin
  IntValue := StrToIntDef(BlueEdit.Text,-1);

  If (IntValue < 0) or (IntValue > MaxColorValue) then
  begin
    BlueEdit.TextSettings.FontColor:=TColors.Red;
  end
  else
  begin
    BlueEdit.TextSettings.FontColor:=TColors.cWINDOW;
    BlueValue := IntValue;
    ContentsChanged;
  end;
end;

procedure TRColorEditor.AlphaEditChange(Sender: TObject);
var
  IntValue : integer;
begin
  IntValue := StrToIntDef(AlphaEdit.Text,-1);

  If (IntValue < 0) or (IntValue > MaxAlphaValue) then
  begin
    AlphaEdit.TextSettings.FontColor:=TColors.Red;
  end
  else
  begin
    AlphaEdit.TextSettings.FontColor:=TColors.cWINDOW;
    AlphaValue := IntValue;
    ContentsChanged;
  end;
end;

end.
