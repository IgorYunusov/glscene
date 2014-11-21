unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, OpenGL,

  GLWin32Viewer, GLTexture, GLCadencer, GLScene, ExtCtrls,
  GLContext, GLKeyboard, GLUtils, {OpenGL1x,} Jpeg, TGA, StdCtrls, GLHUDObjects,
  GLBitmapFont, GLWindowsFont, GLMaterial, GLCoordinates, GLCrossPlatform,
  GLRenderContextInfo, OpenGLTokens, GLBaseClasses;

type
  TForm1 = class(TForm)
    Scene: TGLScene;
    Timer1: TTimer;
    Viewer: TGLSceneViewer;
    GLCadencer: TGLCadencer;
    Mandelbrot: TGLDirectOpenGL;
    GLMatLib: TGLMaterialLibrary;
    GLCamera: TGLCamera;
    OpenDialog1: TOpenDialog;
    GLHUDText: TGLHUDText;
    GLWindowsBitmapFont: TGLWindowsBitmapFont;
    procedure FormCreate(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure GLCadencerProgress(Sender: TObject; const deltaTime,
      newTime: Double);
    procedure FormMouseWheel(Sender: TObject; Shift: TShiftState;
      WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
    procedure MandelbrotRender(Sender: TObject;
      var rci: TRenderContextInfo);
  private
    { Private declarations }
  public
    { Public declarations }
    MandelbrotProgram: TGLProgramHandle;
  end;

const
  HELP_TEXT = '+: Zoom in'#13#10
             +'-: Zoom out'#13#10
             +'Arrow keys: Move around'#13#10
             +'F3: Load colormap';

var
  Form1: TForm1;
  PositionX, PositionY, Scale: Single;


implementation

{$R *.dfm}



procedure TForm1.FormCreate(Sender: TObject);

begin
	PositionX:=-0.5;
	PositionY:= 0.0;
  Scale:=1.0;

  with GLMatLib do begin
    Materials[0].Material.Texture.Image.LoadFromFile('Textures\hot_metal.bmp');
  end;

  GLHUDText.Text:=HELP_TEXT;
end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
  Caption:=Format('Mandelbrot %.1f FPS', [Viewer.FramesPerSecond]);

  Viewer.ResetPerformanceMonitor;
end;

procedure TForm1.GLCadencerProgress(Sender: TObject; const deltaTime,
  newTime: Double);
var
  deltax, deltay: single;
  pt: TPoint;
begin
  if IsKeyDown(VK_F3)
  then
    if OpenDialog1.Execute
    then GLMatLib.Materials[0].Material.Texture.Image.LoadFromFile(OpenDialog1.FileName);

  if IsKeyDown('+') or IsKeyDown(VK_ADD)
	then Scale:= Scale * 1.0 / (1.0 + deltaTime * 0.5);

  if IsKeyDown('-') or IsKeyDown(VK_SUBTRACT)
  then Scale:= Scale * (1.0 + deltaTime * 0.5);

  if IsKeyDown(VK_UP) or IsKeyDown(VK_NUMPAD8)
  then PositionY:= PositionY + deltaTime*Scale*0.5;

  if IsKeyDown(VK_DOWN) or IsKeyDown(VK_NUMPAD2)
  then PositionY:= PositionY - deltaTime*Scale*0.5;

  if IsKeyDown(VK_RIGHT) or IsKeyDown(VK_NUMPAD6)
  then PositionX:= PositionX + deltaTime*Scale*0.5;

  if IsKeyDown(VK_LEFT) or IsKeyDown(VK_NUMPAD4)
  then PositionX:= PositionX - deltaTime*Scale*0.5;

  Viewer.Invalidate;
end;


procedure TForm1.FormMouseWheel(Sender: TObject; Shift: TShiftState;
  WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
var
  DistDelta: Single;
begin
end;

procedure TForm1.MandelbrotRender(Sender: TObject;
  var rci: TRenderContextInfo);
begin
  // shader init
  if not Assigned(MandelbrotProgram) then begin
    MandelbrotProgram := TGLProgramHandle.CreateAndAllocate;

    MandelbrotProgram.AddShader(TGLFragmentShaderHandle,
                          LoadAnsiStringFromFile('Shaders\Mandelbrot.frag'),
                          True);

    MandelbrotProgram.AddShader(TGLVertexShaderHandle,
                          LoadAnsiStringFromFile('Shaders\Mandelbrot.vert'),
                          True);


    if not MandelbrotProgram.LinkProgram
    then raise Exception.Create(MandelbrotProgram.InfoLog);

    if not MandelbrotProgram.ValidateProgram then
    raise Exception.Create(MandelbrotProgram.InfoLog);
  end;

  glPushAttrib(GL_ALL_ATTRIB_BITS);
  glMatrixMode(GL_MODELVIEW);
  glPushMatrix;
  glLoadIdentity;
  glMatrixMode(GL_PROJECTION);
  glPushMatrix;
  glLoadIdentity;

  MandelbrotProgram.UseProgramObject;

  MandelbrotProgram.Uniform1f['positionX']:=PositionX;
  MandelbrotProgram.Uniform1f['positionY']:=PositionY;
  MandelbrotProgram.Uniform1f['scale']:=Scale;

  glEnable(GL_TEXTURE_2D);
  GL.ActiveTexture(GL_TEXTURE0_ARB); //glActiveTextureARB(GL_TEXTURE0_ARB);
  glBindTexture(GL_TEXTURE_2D, GLMatLib.Materials[0].Material.Texture.Handle);
  MandelbrotProgram.Uniform1i['colorMap']:=0;

  // drawing rectangle over screen
  glDisable(GL_DEPTH_TEST);
  glDisable(GL_LIGHTING);

  glBegin(GL_QUADS);
  glTexCoord2f(0.0, 0.0); glVertex2f(-1.0, -1.0);
  glTexCoord2f(1.0, 0.0); glVertex2f( 1.0, -1.0);

  glTexCoord2f(1.0, 1.0); glVertex2f( 1.0,  1.0);
  glTexCoord2f(0.0, 1.0); glVertex2f(-1.0,  1.0);
  glEnd;

  MandelbrotProgram.EndUseProgramObject;

  glPopMatrix;
  glMatrixMode(GL_MODELVIEW);
  glPopMatrix;
  glPopAttrib;

  ///-CheckOpenGLError;
end;



end.

