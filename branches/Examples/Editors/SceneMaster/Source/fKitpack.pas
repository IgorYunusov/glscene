(*  Scene Master 3D *)
unit fKitpack;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.ExtCtrls,
  Vcl.ComCtrls,

  dImages,
  fInitial;

type
  TfmKitpack = class(TInitialForm)
    twBasicGeometry: TTreeView;
    Panel1: TPanel;
    TreeView2: TTreeView;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  fmKitpack: TfmKitpack;

implementation

{$R *.dfm}

end.
