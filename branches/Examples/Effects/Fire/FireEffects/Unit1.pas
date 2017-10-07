////////////////////////////////////////////////////////////////////////
//                                                                    //
//  GLScene Fire Demo v1.0                                            //
//                                        - ��� ���������� � �������� //
//====================================================================//
//                                                                    //
// ������������ ��������� "��������" ����                             //
//--------------------------------------------------------------------//
// � FireFX [TGLFireFXManager]                                        //
// � PointLightPFX [TGLPointLightPFXManager]                          //
// � PolygonPFX [TGLPolygonPFXManager]                                //
// � PerlinPFX [TGLPerlinPFXManager]                                  //
// � AnimatedSprite [TGLAnimatedSprite]                               //
//--------------------------------------------------------------------//
//                                                                    //
//  ��� ������������ ������ �������� ��������� - ���� ��������,       //
//  � ��� ���������� ��� � �������� ���� � �������� "Effect"          //
//                                                                    //
//  ������� - �������, ������ ��������� � �����, ������� ��������� �� //
//  �� ������������� ������, ��������� ���������� ��� ������ �������  //
//                                                                    //
// FireFX - ���������, �������� ����� ������������� �������� �������  //
//  ��� ��� ���������� ���� ������� TGLFireFXManager �� "GLScene PFX" //
//  � ���������� � ���� GLCadencer, ������� ����� "������"            //
//  ������ ����� ������� "�������" ������ � � ��� ���������� �������� //
//  Effects->Add->FireFX, ����� � Manager �������� ���...             //
//  ...��, ����� ������ � ������ "������", �������� ���������...     //
//                                                                    //
// PFX - ������� ������, �.�. ��� �� �����, � ������ ����� ������, �� //
//  � ����� ������� ������� �������� � ���������� ������������, ���   //
//  ��������� ������� ��� �� ������ ����, �� ����� ����������         //
//  ���� ��������� ����������, �� � ����������� ��� ��������:         //
//  PointLightPFX, PerlinPFX, PolygonPFX                              //
//  ������ ��� ���������� � ��� ���� ��������, ��� �� ������ ������-  //
//  ������ ������������ Perlin-��� ��� ��������...                    //
//  ������ - PolygonPFX - ��������� ��������� ������������            //
//  ��� �� ������������� ����� ������� ���������:                     //
//  � Scene objects->Add object->Particle Systems->PFX Renderer       //
//  � ������� ������ Manager �� ������� "GLScene PFX"                 //
//  � ���������� � ���� "PFX Renderer" � "��������" GLCadencer        //
//  � � �������-"���������" Effects->Add->PFX Source                  //
//  ��, "��������" ������, ������ ���� ��������� ��������� =)        //
//                                                                    //
// AnimatedSprite - ��� ������, � �������� �������� ���������� ����-  //
//  ������ �� ������� � �����������, �������� ��������/�������...     //
//  ��� �����, ������� ����� ���������� ��� �������� �� ����� �����   //
//                                                                    //
//--------------------------------------------------------------------//
//                                                                    //
// ������� ����, �����������, AnimatedSprite, �� ������� ������ ���   //
//  �������� ���� � ���� ��������� � ���������� �������� "�������"    //
// FireFX �������, �� ��������� � ��� ������� - ������ �����          //
// PFX �� ����� ������� ��� ���, ��� �� ����� ������ ���������, ��    //
//  ���� ������� ����������� � ������� ������������                   //
//                                                                    //
//====================================================================//
//                                                                    //
// ������� � ��������!                                     GLScene.ru //
////////////////////////////////////////////////////////////////////////

unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages,
  System.SysUtils, System.Classes, System.Math,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
   
  GLCadencer, GLScene, GLObjects, GLAsyncTimer,
  GLWin32Viewer, GLGeomObjects, GLHUDObjects, GLTexture,
  GLVectorTypes, GLSpaceText, GLBitmapFont, GLWindowsFont, GLVectorGeometry,
  GLFireFX, GLParticleFX, GLPerlinPFX, GLAnimatedSprite, GLMaterial,
  GLCoordinates, GLCrossPlatform, GLBaseClasses;

type
  TForm1 = class(TForm)
    GLScene1: TGLScene;
    vp: TGLSceneViewer;
    GLCadencer1: TGLCadencer;
    GLCamera1: TGLCamera;
    GLPointLightPFXManager1: TGLPointLightPFXManager;
    GLParticleFXRenderer1: TGLParticleFXRenderer;
    GLPerlinPFXManager1: TGLPerlinPFXManager;
    dc_plight: TGLDummyCube;
    dc_perlin: TGLDummyCube;
    dc_poly: TGLDummyCube;
    GLPolygonPFXManager1: TGLPolygonPFXManager;
    dc_fire: TGLDummyCube;
    GLDummyCube5: TGLDummyCube;
    GLFireFXManager1: TGLFireFXManager;
    AsyncTimer1: TGLAsyncTimer;
    asprite: TGLAnimatedSprite;
    matlib: TGLMaterialLibrary;
    txt_fire: TGLHUDText;
    GLWindowsBitmapFont1: TGLWindowsBitmapFont;
    txt_plight: TGLHUDText;
    txt_perlin: TGLHUDText;
    txt_poly: TGLHUDText;
    txt_asprite: TGLHUDText;
    dc_asprite: TGLDummyCube;
    GLLines1: TGLLines;
    GLDummyCube1: TGLDummyCube;
    GLLightSource1: TGLLightSource;
    txt_gl: TGLSpaceText;
    txt_scene: TGLSpaceText;
    procedure FormMouseWheel(Sender: TObject; Shift: TShiftState;
      WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
    procedure GLCadencer1Progress(Sender: TObject; const deltaTime,
      newTime: Double);
    procedure AsyncTimer1Timer(Sender: TObject);
    procedure vpMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure vpMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
  private
  public
  end;

var
  Form1:TForm1;
  _shift:boolean=false; // ��������� ������� ����� ������ "����"
  _mx,_my:Integer;      // ���������� ���������� "����"
  _zoom:single=0;       //

implementation

{$R *.DFM}

procedure TForm1.FormMouseWheel(Sender: TObject; Shift: TShiftState;
  WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
begin
  _zoom:=WheelDelta/120; // ���������� ��������� ������� "����"
end;

procedure TForm1.GLCadencer1Progress(Sender: TObject; const deltaTime,
  newTime: Double);
var v:TVector4f;
begin
  // ������� ��� FireFX
  v:=vp.Buffer.WorldToScreen(dc_fire.AbsolutePosition);
    txt_fire.AbsolutePosition:=VectorMake(v.X,height-v.Y,0);
  // ������� ��� PointLightPFX
  v:=vp.Buffer.WorldToScreen(dc_plight.AbsolutePosition);
    txt_plight.AbsolutePosition:=VectorMake(v.X,height-v.Y,0);
  // ������� ��� PolygonPFX
  v:=vp.Buffer.WorldToScreen(dc_poly.AbsolutePosition);
    txt_poly.AbsolutePosition:=VectorMake(v.X,height-v.Y,0);
  // ������� ��� PerlinPFX
  v:=vp.Buffer.WorldToScreen(dc_perlin.AbsolutePosition);
    txt_perlin.AbsolutePosition:=VectorMake(v.X,height-v.Y,0);
  // ������� ��� AnimatedSprite
  v:=vp.Buffer.WorldToScreen(dc_asprite.AbsolutePosition);
    txt_asprite.AbsolutePosition:=VectorMake(v.X,height-v.Y,0);

  if _shift then begin
    gldummycube1.Pitch(_my-mouse.CursorPos.y); // ���� ������ ������, ��
    gldummycube5.Turn(_mx-mouse.CursorPos.x);  // �������� ������ �� "����"
    end
  else gldummycube5.Turn(deltatime*10); // ����� �������������� �������

    _my:=mouse.CursorPos.y; // ��������� ���������� "����"
    _mx:=mouse.CursorPos.x; //

  GLCamera1.AdjustDistanceToTarget(Power(1.1, _zoom));

    _zoom:=0; // ��������

end;

procedure TForm1.AsyncTimer1Timer(Sender: TObject);
begin
  caption:=vp.FramesPerSecondText(2); // ������� ���������� ������ � �������
  vp.ResetPerformanceMonitor;         // � �������� �������
end;

procedure TForm1.vpMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  _shift:=true; // ������ ������
end;

procedure TForm1.vpMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  _shift:=false; // ������ ������
end;

end.

