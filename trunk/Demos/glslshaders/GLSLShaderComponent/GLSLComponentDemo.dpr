program GLSLComponentDemo;

{%File 'Shaders\Shader.Frag'}
{%File 'Shaders\Shader.Vert'}

uses
  FastMM4,
  Forms,
  uMainForm in 'uMainForm.pas' {GLSLTestForm};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TGLSLTestForm, GLSLTestForm);
  Application.Run;
end.
