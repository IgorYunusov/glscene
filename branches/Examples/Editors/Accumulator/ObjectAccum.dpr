program ObjectAccum;

uses
  Forms,
  Unit1 in 'Unit1.pas' {frmMain};

{$R *.res}

begin
  Application.Initialize;
  Application.Title := '���� - ����������� ��������';
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.