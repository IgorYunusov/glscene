{: Basic sample for loading and applying a cube map.<p>

   In this extremely simple demo, with a single teapot, we just setup and
   enabled reflection cube map environment mapping. Cube maps allow higher
   quality reflections than sphere map (no singularity) at the expense of
   memory use (they require 6 images instead of one).<p>
   Setting up a cube map is straightforward and similar to setting up any other
   kind of texture, all parameters and options apply, but instead of specifying
   a single image, you have to specify 6.<p>

   The cube map images used in this sample are from the Developper section
   of the nVidia website (http://www.nvidia.com).
}
unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, GLScene, GLLCLViewer, GLObjects, StdCtrls, GLTeapot,
  GLCrossPlatform, GLCoordinates, BaseClasses;

type
  TForm1 = class(TForm)
    GLScene1: TGLScene;
    GLSceneViewer1: TGLSceneViewer;
    GLCamera1: TGLCamera;
    DummyCube1: TGLDummyCube;
    GLLightSource1: TGLLightSource;
    Button1: TButton;
    Teapot1: TGLTeapot;
    procedure GLSceneViewer1MouseMove(Sender: TObject; Shift: TShiftState;
      X, Y: integer);
    procedure GLSceneViewer1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: integer);
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    mx, my: integer;
  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

uses GLTexture, FileUtil;

procedure TForm1.Button1Click(Sender: TObject);
var
  path: UTF8String;
  p: integer;
begin
  // Cube map warning message
  // If you don't check and turn off cube maps yourself in your apps when
  // cube maps aren't supported, GLScene will just turn off texturing
  // (ie. no error generated, just a different output)
  if not GLSceneViewer1.Buffer.RenderingContext.GL.ARB_texture_cube_map then
  begin
    ShowMessage('Your graphics board does not support cube maps...');
    Exit;
  end;

  // Our cube map images are here
  path := ExtractFilePath(ParamStrUTF8(0));
  p := Pos('DemosLCL', path);
  Delete(path, p + 5, Length(path));
  path := IncludeTrailingPathDelimiter(path) + 'media';
  SetCurrentDirUTF8(path);

  with Teapot1.Material.Texture do
  begin
    // We need a CubeMapImage, which unlike the "regular Images" stores
    // multiple images.
    ImageClassName := TGLCubeMapImage.ClassName;
    with Image as TGLCubeMapImage do
    begin
      // Load all 6 texture map components of the cube map
      // The 'PX', 'NX', etc. refer to 'positive X', 'negative X', etc.
      // and follow the RenderMan specs/conventions
      Picture[cmtPX].LoadFromFile('cm_left.jpg');
      Picture[cmtNX].LoadFromFile('cm_right.jpg');
      Picture[cmtPY].LoadFromFile('cm_top.jpg');
      Picture[cmtNY].LoadFromFile('cm_bottom.jpg');
      Picture[cmtPZ].LoadFromFile('cm_back.jpg');
      Picture[cmtNZ].LoadFromFile('cm_front.jpg');
    end;
    // Select reflection cube map environment mapping
    // This is the mode you'll most commonly use with cube maps, normal cube
    // map generation is also supported (used for diffuse environment lighting)
    MappingMode := tmmCubeMapReflection;
    // That's all folks, let us see the thing!
    Disabled := False;
  end;
  Button1.Visible := False;
end;

// standard issue handlers for mouse movement

procedure TForm1.GLSceneViewer1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: integer);
begin
  mx := x;
  my := y;
end;

procedure TForm1.GLSceneViewer1MouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: integer);
begin
  if Shift <> [] then
  begin
    if ssLeft in Shift then
      GLCamera1.MoveAroundTarget(my - y, mx - x)
    else
      GLCamera1.RotateTarget(my - y, mx - x);
    mx := x;
    my := y;
  end;
end;

end.

