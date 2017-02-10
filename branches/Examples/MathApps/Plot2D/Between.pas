unit Between;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, ComCtrls, Menus, ExtCtrls;

type
  TBetweenForm = class(TForm)
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label1: TLabel;
    Label2: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    PositiveButton: TSpeedButton;
    NegativeButton: TSpeedButton;
    NegAreaLabel: TLabel;
    PosAreaLabel: TLabel;
    TotalAreaLabel: TLabel;
    EditIntegMin: TEdit;
    EditIntegMax: TEdit;
    EditCount: TEdit;
    UpDown1: TUpDown;
    EditOpacity: TEdit;
    UpDown2: TUpDown;
    RecalcBtn: TBitBtn;
    CloseBtn: TBitBtn;
    ColorDialog: TColorDialog;
    KeepRangeCheckBox: TCheckBox;
    PositivePanel: TPanel;
    NegativePanel: TPanel;
    SumAreaLabel: TLabel;
    procedure FormShow(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure FormDeactivate(Sender: TObject);

    procedure ParseKeyPress(Sender: TObject; var Key: Char);
    procedure IntKeyPress(Sender: TObject; var Key: Char);
    procedure EditIntegMinKeyUp(Sender: TObject; var Key: Word;
                                 Shift: TShiftState);
    procedure EditIntegMaxKeyUp(Sender: TObject; var Key: Word;
                                 Shift: TShiftState);
    procedure EditCountKeyUp(Sender: TObject; var Key: Word;
                              Shift: TShiftState);

    procedure EditOpacityKeyUp(Sender: TObject; var Key: Word;
                                Shift: TShiftState);

    procedure UpDown1Click(Sender: TObject; Button: TUDBtnType);
    procedure UpDown2Click(Sender: TObject; Button: TUDBtnType);
    procedure UpDown1MouseUp(Sender: TObject; Button: TMouseButton;
                              Shift: TShiftState; X, Y: Integer);

    procedure PositiveButtonClick(Sender: TObject);
    procedure NegativeButtonClick(Sender: TObject);
    procedure RecalcBtnClick(Sender: TObject);
    procedure CloseBtnClick(Sender: TObject);
    procedure IntegLabelClick(Sender: TObject);
    procedure KeepRangeCheckBoxClick(Sender: TObject);
  private
    { Private declarations }
    procedure UpdateRangeData;
  public
    { Public declarations }
    procedure ShowData;
  end;

var
  BetweenForm: TBetweenForm;

implementation

uses
  uParser,
  uGlobal, Functs, Main, Clipbrd, Math;

{$R *.dfm}

procedure TBetweenForm.FormShow(Sender: TObject);
begin
  KeepRangeCheckBox.Checked := KeepRange;
  ShowData;
end;

procedure TBetweenForm.FormActivate(Sender: TObject);
begin
  EditIntegMin.SetFocus;
  EditIntegMin.SelText;
end;

procedure TBetweenForm.FormKeyPress(Sender: TObject; var Key: Char);
begin
  case Key of
#13:begin
      RecalcBtnClick(Sender);
      Key := #0;
    end;
#27:begin
      Key := #0;
      Close;
    end;
  end;
end;

procedure TBetweenForm.FormDeactivate(Sender: TObject);
begin
  if KeepRange then UpdateRangeData;
end;

procedure TBetweenForm.ParseKeyPress(Sender: TObject; var Key: Char);
begin
  with Sender as TEdit do
  begin
    if not CharInSet(UpCase(Key),
   [' ', '!', '(', ')', '*', '+', '-', '.', ',', '/', '0'..'9',
    'A'..'C', 'E', 'G'..'I', 'L', 'N'..'T', 'X', '^', '`', #8]) then
    begin
      Key := #0;
      Exit;
    end;
    if Key = '`' then Key := '�';
  end;
end;

procedure TBetweenForm.IntKeyPress(Sender: TObject; var Key: Char);
begin
  with Sender as TEdit do
  if not CharInSet(Key, ['0'..'9', #8]) then Key := #0
end;

procedure TBetweenForm.EditIntegMinKeyUp(Sender: TObject; var Key: Word;
                                          Shift: TShiftState);
var
  s: string;
  e: byte;

begin
  s := ScanText(EditIntegMin.Text);
  IntegMin := ParseAndEvaluate(s, e);
//if isNAN(IntegMin) then IntegMin := 0;
//if e > 0 then IntegMin := 0;
  if isNAN(IntegMin) or isInfinite(IntegMin) or (e > 0) then IntegMin := 0;
end;

procedure TBetweenForm.EditIntegMaxKeyUp(Sender: TObject; var Key: Word;
                                          Shift: TShiftState);
var
  s: string;
  e: byte;

begin
  s := ScanText(EditIntegMax.Text);
  IntegMax := ParseAndEvaluate(s, e);
//if isNAN(IntegMax) then IntegMax := 0;
//if e > 0 then IntegMax := 0;
  if isNAN(IntegMax) or isInfinite(IntegMax) or (e > 0) then IntegMax := 0;
end;

procedure TBetweenForm.EditCountKeyUp(Sender: TObject; var Key: Word;
                                       Shift: TShiftState);
begin
  with GraphData do
  begin
    try
      IntegCount := StrToInt(EditCount.Text);
      if IntegCount = 0 then IntegCount := IntegCountPos;
    except
      IntegCount := IntegCountPos;
    end;
    if IntegCount > IntegCountMax then IntegCount := IntegCountMax;
  end;
  Altered := true;
end;

procedure TBetweenForm.EditOpacityKeyUp(Sender: TObject; var Key: Word;
                                         Shift: TShiftState);
var
  n: integer;

begin
  try
    n := StrToInt(EditOpacity.Text);
  except
    n := 1;
  end;
  GraphData.AreaAlpha := n/100;
  Altered := true;
  MainForm.GLViewer.Invalidate;
end;

procedure TBetweenForm.UpDown1Click(Sender: TObject; Button: TUDBtnType);
var
  k: word;

begin
  k := 0;
  EditCountKeyUp(Sender, k, []);
end;

procedure TBetweenForm.UpDown2Click(Sender: TObject; Button: TUDBtnType);
var
  k: word;

begin
  k := 0;
  EditOpacityKeyUp(Sender, k, []);
end;

procedure TBetweenForm.UpDown1MouseUp(Sender: TObject; Button: TMouseButton;
                                      Shift: TShiftState; X, Y: Integer);
begin
  RecalcBtnClick(Sender);
end;

procedure TBetweenForm.PositiveButtonClick(Sender: TObject);
begin
  ColorDialog.Color := GraphData.PosAreaColor;
  if ColorDialog.Execute then
  begin
    GraphData.PosAreaColor := ColorDialog.Color;
    PositivePanel.Color := GraphData.PosAreaColor;
    MainForm.GLViewer.Invalidate;
    Altered := TRUE
  end;
end;

procedure TBetweenForm.NegativeButtonClick(Sender: TObject);
begin
  ColorDialog.Color := GraphData.NegAreaColor;
  if ColorDialog.Execute then
  begin
    GraphData.NegAreaColor := ColorDialog.Color;
    NegativePanel.Color := GraphData.NegAreaColor;
    MainForm.GLViewer.Invalidate;
    Altered := TRUE
  end;
end;

procedure TBetweenForm.RecalcBtnClick(Sender: TObject);
begin
  MainForm.GLViewer.Invalidate;
end;

procedure TBetweenForm.IntegLabelClick(Sender: TObject);
begin
  Clipboard.Clear;
  with Sender as TLabel do
  Clipboard.AsText := Copy(Caption,  pos('=', Caption)+2, Length(Caption));
end;

procedure TBetweenForm.KeepRangeCheckBoxClick(Sender: TObject);
begin
  KeepRange := KeepRangeCheckBox.Checked;
end;

procedure TBetweenForm.CloseBtnClick(Sender: TObject);
begin
  Close;
end;

procedure TBetweenForm.UpdateRangeData;
begin
  KeptMin := IntegMin;
  KeptMax := IntegMax;
end;

procedure TBetweenForm.ShowData;
begin
  with GraphData, PlotData do
  begin
    EditCount.Text := IntToStr(IntegCount);
    UpDown2.Position := round(AreaAlpha*100);
    if TextStr = '' then Caption := '' else Caption := 'y = '+TextStr;

    KeepRangeCheckBox.Checked := KeepRange;
    PositivePanel.Color := PosAreaColor;
    NegativePanel.Color := NegAreaColor;

    if IsSegment then
    begin
      if KeepRange then
      begin
        IntegMin := KeptMin;
        IntegMax := KeptMax;
      end
      else
      begin
        IntegMin := SegMin;
        IntegMax := SegMax;
      end;
    end
    else
    begin
      if KeepRange then
      begin
        IntegMin := KeptMin;
        IntegMax := KeptMax;
      end
      else
      begin
        IntegMin := xMin;
        IntegMax := xMax;
      end;
    end;
  end;
  EditIntegMin.Text := FloatToStrF(IntegMin, ffGeneral, 13, 4);
  EditIntegMax.Text := FloatToStrF(IntegMax, ffGeneral, 13, 4);
end;

end.
