program FractalLandscape;

uses
  Forms,
  dlgFracLanU in 'dlgFracLanU.pas' {dlgFracLan},
  dlgProgressU in 'dlgProgressU.pas' {dlgProgress};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TdlgFracLan, dlgFracLan);
  Application.CreateForm(TdlgProgress, dlgProgress);
  Application.Run;
end.
