unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, Jpeg,

  //GLScene
  GLWin32Viewer, GLCadencer, GLScene, CgGl,
  GLTexture, GLCgShader, GLObjects, GLAsyncTimer, GLMaterial, GLCoordinates,
  GLCrossPlatform, GLBaseClasses, GLTextureFormat;

type
  TBumpDemo_frm = class(TForm)
    Scene: TGLScene;
    Cadencer: TGLCadencer;
    SceneViewer: TGLSceneViewer;
    Shaders_ctrl: TPageControl;
    ts_Fragment_Program: TTabSheet;
    ts_Vertex_Program: TTabSheet;
    FP_Memo: TMemo;
    VP_Memo: TMemo;
    VP_btn: TButton;
    FP_btn: TButton;
    FP_cb: TCheckBox;
    VP_cb: TCheckBox;
    CgShader: TCgShader;
    MaterialLibrary: TGLMaterialLibrary;
    Camera: TGLCamera;
    LightSource: TGLLightSource;
    Light_Sphere: TGLSphere;
    Dummy: TGLDummyCube;
    Cube_2: TGLCube;
    Timer: TGLAsyncTimer;
    GLSphere1: TGLSphere;
    procedure VP_cbClick(Sender: TObject);
    procedure FP_cbClick(Sender: TObject);
    procedure FP_btnClick(Sender: TObject);
    procedure VP_btnClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure VP_MemoChange(Sender: TObject);
    procedure FP_MemoChange(Sender: TObject);
    procedure SceneViewerMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure CadencerProgress(Sender: TObject; const deltaTime,
      newTime: Double);
    procedure CgShaderApplyFP(CgProgram: TCgProgram; Sender: TObject);
    procedure CgShaderApplyVP(CgProgram: TCgProgram; Sender: TObject);
    procedure TimerTimer(Sender: TObject);
  private
     
  public
    OldX, OldY: Integer;
     
  end;

var
  BumpDemo_frm: TBumpDemo_frm;

implementation

{$R *.dfm}

procedure TBumpDemo_frm.VP_cbClick(Sender: TObject);
begin
  CgShader.VertexProgram.Enabled := VP_cb.Checked;
  if CgShader.VertexProgram.Enabled = True then VP_btn.Click;
end;

procedure TBumpDemo_frm.FP_cbClick(Sender: TObject);
begin
  CgShader.FragmentProgram.Enabled := FP_cb.Checked;
  if CgShader.FragmentProgram.Enabled = True then FP_btn.Click;
end;

procedure TBumpDemo_frm.FP_btnClick(Sender: TObject);
begin
  CgShader.FragmentProgram.Code := FP_Memo.Lines;
  FP_btn.Enabled := False;
end;

procedure TBumpDemo_frm.VP_btnClick(Sender: TObject);
begin
  CgShader.VertexProgram.Code := VP_Memo.Lines;
  VP_btn.Enabled := False;
end;

procedure TBumpDemo_frm.FormCreate(Sender: TObject);
begin
  SetCurrentDir(ExtractFilePath(Application.ExeName));
  FP_Memo.Lines.LoadFromFile('BumpMapping_fp.cg');
  VP_Memo.Lines.LoadFromFile('BumpMapping_vp.cg');
  with MaterialLibrary do
    begin
      AddTextureMaterial('c_tex','c_tex.jpg');
      AddTextureMaterial('c_normal','c_normal.jpg');
      AddTextureMaterial('c2_tex','c2_tex.jpg');
      AddTextureMaterial('c2_normal','c2_normal.jpg');
      Materials[0].Material.Texture.FilteringQuality := tfAnisotropic;
      Materials[1].Material.Texture.FilteringQuality := tfAnisotropic;
      Materials[2].Material.Texture.FilteringQuality := tfAnisotropic;
      Materials[3].Material.Texture.FilteringQuality := tfAnisotropic;
      Materials[0].Texture2Name := 'c_normal';
      Materials[0].Shader := CgShader;
      Materials[2].Texture2Name := 'c2_normal';
      Materials[2].Shader := CgShader;
      Materials[1].Material.Texture.TextureFormat := tfNormalMap;
      Materials[3].Material.Texture.TextureFormat := tfNormalMap;
      Materials[1].Material.Texture.NormalMapScale := 0.005;
      Materials[3].Material.Texture.NormalMapScale := 0.005;
    end;
  Cube_2.Material.MaterialLibrary := MaterialLibrary;
  GLSphere1.Material.MaterialLibrary := MaterialLibrary;
  GLSphere1.Material.LibMaterialName := 'c_tex';
  Cube_2.Material.LibMaterialName := 'c2_tex';
end;

procedure TBumpDemo_frm.VP_MemoChange(Sender: TObject);
begin
  VP_btn.Enabled := True;
end;

procedure TBumpDemo_frm.FP_MemoChange(Sender: TObject);
begin
  FP_btn.Enabled := True;
end;

procedure TBumpDemo_frm.SceneViewerMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
  if ssLeft in Shift then Camera.MoveAroundTarget(OldY - y, oldX - x);
  OldX := x;
  Oldy := y;
end;

procedure TBumpDemo_frm.CadencerProgress(Sender: TObject; const deltaTime,
  newTime: Double);
begin
  LightSource.MoveObjectAround(Dummy, 0, deltatime * 20);
  SceneViewer.Invalidate;
end;

procedure TBumpDemo_frm.CgShaderApplyFP(CgProgram: TCgProgram;
  Sender: TObject);
begin
  CgProgram.ParamByName('tex1').SetAsTexture2D(0);
  CgProgram.ParamByName('tex2').SetAsTexture2D(1);
  CgProgram.ParamByName('lightcolor').SetAsVector(LightSource.Diffuse.Color);
end;

procedure TBumpDemo_frm.CgShaderApplyVP(CgProgram: TCgProgram;
  Sender: TObject);
begin
  CgProgram.ParamByName('lightpos').SetAsVector(LightSource.Position.AsAffineVector);
  CgProgram.ParamByName('ModelViewProj').SetAsStateMatrix(CG_GL_MODELVIEW_PROJECTION_MATRIX, CG_GL_MATRIX_IDENTITY);
end;

procedure TBumpDemo_frm.TimerTimer(Sender: TObject);
begin
  BumpDemo_frm.Caption := 'Cg BumpMapping FPS - '+SceneViewer.FramesPerSecondText(2);
  SceneViewer.ResetPerformanceMonitor;

end;

end.
