program Village;

uses
  Forms,
  u_Main in 'u_Main.pas' {Form1},
  uLog in 'uLog.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
