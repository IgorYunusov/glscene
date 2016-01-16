//
// This unit is part of the GLScene Project, http://glscene.org
//
{
   Editor for a vector. 

    History :  
       05/10/08 - DanB - Removed Kylix support
       29/03/07 - DaStr - Renamed LINUX to KYLIX (BugTrackerID=1681585)
       03/07/04 - LR - Make change for Linux
       ?/?/? -  - Creation
    
}
unit FVectorEditor;

interface

{$I GLScene.inc}

uses
  System.Classes, System.SysUtils,
  VCL.Forms, VCL.ComCtrls, VCL.StdCtrls, VCL.ToolWin,
  VCL.ExtCtrls, VCL.Buttons, VCL.Graphics, VCL.Controls,
  //GLS
  GLVectorGeometry, GLUtils, GLVectorTypes;

type
  TGLVectorEditorForm = class(TForm)
    EDx: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    EDy: TEdit;
    EDz: TEdit;
    BBok: TBitBtn;
    BBcancel: TBitBtn;
    IMx: TImage;
    IMy: TImage;
    IMz: TImage;
    SpeedButton1: TSpeedButton;
    SBmX: TSpeedButton;
    SpeedButton3: TSpeedButton;
    SBmY: TSpeedButton;
    SpeedButton5: TSpeedButton;
    SBmZ: TSpeedButton;
    SpeedButton7: TSpeedButton;
    SBUnit: TSpeedButton;
    SpeedButton9: TSpeedButton;
    Bevel1: TBevel;
    SBInvert: TSpeedButton;
    procedure TBxClick(Sender: TObject);
    procedure TByClick(Sender: TObject);
    procedure TBzClick(Sender: TObject);
    procedure TBnullClick(Sender: TObject);
    procedure EDxChange(Sender: TObject);
    procedure EDyChange(Sender: TObject);
    procedure EDzChange(Sender: TObject);
    procedure SBmXClick(Sender: TObject);
    procedure SBmYClick(Sender: TObject);
    procedure SBmZClick(Sender: TObject);
    procedure SBUnitClick(Sender: TObject);
    procedure SpeedButton9Click(Sender: TObject);
    procedure SBInvertClick(Sender: TObject);
  private
    { Private declarations }
    vx, vy, vz : Single;
    procedure TestInput(edit : TEdit; imError : TImage; var dest : Single);
  public
    { Public declarations }
    function Execute(var x, y, z : Single) : Boolean;
  end;

function GLVectorEditorForm : TGLVectorEditorForm;
procedure ReleaseVectorEditorForm;

// ------------------------------------------------------------------
// ------------------------------------------------------------------
// ------------------------------------------------------------------
implementation
// ------------------------------------------------------------------
// ------------------------------------------------------------------
// ------------------------------------------------------------------

{$R *.dfm}

var
	vGLVectorEditorForm : TGLVectorEditorForm;

function GLVectorEditorForm : TGLVectorEditorForm;
begin
	if not Assigned(vGLVectorEditorForm) then
      vGLVectorEditorForm:=TGLVectorEditorForm.Create(nil);
	Result:=vGLVectorEditorForm;
end;

procedure ReleaseVectorEditorForm;
begin
	if Assigned(vGLVectorEditorForm) then begin
	   vGLVectorEditorForm.Free; vGLVectorEditorForm:=nil;
	end;
end;

// Execute
//
function TGLVectorEditorForm.Execute(var x, y, z : Single) : Boolean;
begin
   // setup dialog fields
   vx:=x;
   vy:=y;
   vz:=z;
   EDx.Text:=FloatToStr(vx);
   EDy.Text:=FloatToStr(vy);
   EDz.Text:=FloatToStr(vz);
   // show the dialog
   Result:=(ShowModal=mrOk);
   if Result then begin
      x:=vx;
      y:=vy;
      z:=vz;
   end;
end;

procedure TGLVectorEditorForm.TestInput(edit : TEdit; imError : TImage; var dest : Single);
begin
   if Visible then begin
      try
         dest:=StrToFloat(edit.Text);
         imError.Visible:=False;
      except
         imError.Visible:=True;
      end;
      BBOk.Enabled:=not (IMx.Visible or IMy.Visible or IMz.Visible);
   end;
end;

procedure TGLVectorEditorForm.TBxClick(Sender: TObject);
begin
   EDx.Text:='1'; EDy.Text:='0'; EDz.Text:='0';
end;

procedure TGLVectorEditorForm.TByClick(Sender: TObject);
begin
   EDx.Text:='0'; EDy.Text:='1'; EDz.Text:='0';
end;

procedure TGLVectorEditorForm.TBzClick(Sender: TObject);
begin
   EDx.Text:='0'; EDy.Text:='0'; EDz.Text:='1';
end;

procedure TGLVectorEditorForm.TBnullClick(Sender: TObject);
begin
   EDx.Text:='0'; EDy.Text:='0'; EDz.Text:='0';
end;

procedure TGLVectorEditorForm.EDxChange(Sender: TObject);
begin
   TestInput(EDx, IMx, vx);
end;

procedure TGLVectorEditorForm.EDyChange(Sender: TObject);
begin
   TestInput(EDy, IMy, vy);
end;

procedure TGLVectorEditorForm.EDzChange(Sender: TObject);
begin
   TestInput(EDz, IMz, vz);
end;

procedure TGLVectorEditorForm.SBmXClick(Sender: TObject);
begin
   EDx.Text:='-1'; EDy.Text:='0'; EDz.Text:='0';
end;

procedure TGLVectorEditorForm.SBmYClick(Sender: TObject);
begin
   EDx.Text:='0'; EDy.Text:='-1'; EDz.Text:='0';
end;

procedure TGLVectorEditorForm.SBmZClick(Sender: TObject);
begin
   EDx.Text:='0'; EDy.Text:='0'; EDz.Text:='-1';
end;

procedure TGLVectorEditorForm.SBUnitClick(Sender: TObject);
begin
   EDx.Text:='1'; EDy.Text:='1'; EDz.Text:='1';
end;

procedure TGLVectorEditorForm.SpeedButton9Click(Sender: TObject);
var
   v : TAffineVector;
begin
   SetVector(v, GLUtils.StrToFloatDef(EDx.Text, 0), GLUtils.StrToFloatDef(EDy.Text, 0), GLUtils.StrToFloatDef(EDz.Text, 0));
   if VectorLength(v)=0 then
      v:=NullVector
   else NormalizeVector(v);
   EDx.Text:=FloatToStr(v.V[0]);
   EDy.Text:=FloatToStr(v.V[1]);
   EDz.Text:=FloatToStr(v.V[2]);
end;

procedure TGLVectorEditorForm.SBInvertClick(Sender: TObject);
var
   v : TAffineVector;
begin
   SetVector(v, GLUtils.StrToFloatDef(EDx.Text, 0), GLUtils.StrToFloatDef(EDy.Text, 0), GLUtils.StrToFloatDef(EDz.Text, 0));
   NegateVector(v);
   EDx.Text:=FloatToStr(v.V[0]);
   EDy.Text:=FloatToStr(v.V[1]);
   EDz.Text:=FloatToStr(v.V[2]);
end;

// ------------------------------------------------------------------
// ------------------------------------------------------------------
// ------------------------------------------------------------------
initialization
// ------------------------------------------------------------------
// ------------------------------------------------------------------
// ------------------------------------------------------------------

finalization

   ReleaseVectorEditorForm;

end.



