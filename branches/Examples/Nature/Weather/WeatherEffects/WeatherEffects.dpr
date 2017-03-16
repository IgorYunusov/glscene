////////////////////////////////////////////////////////////////////////
//  GLScene Rain Demo v1.0                                            //
//====================================================================//
//  ������������ ��������� "��������" �����, ����� � ������           //
//--------------------------------------------------------------------//
//                                                                    //
//  ��� ������������ ������ �������� ��������� - ���� ��������,       //
//  ��� ���������� �� ������� ������ � ����������...                 //
//                                                                    //
// �������                                                            //
//  ��������� PointLightPFX c AspectRatio � 0,05 �������� �����, ���� //
//  ��� �� ����� � ��������, ���� ������ ������ ���� (Rotation), ���  //
//  ����� (PFX Source->InitialVelocity) � ������� (PFX Source->Positi //
//  onDispersion), �� ���������� �������� ������ ����� =)             //
//  ��� �������� ������� ������ ����:                                 //
//  � Scene objects->Add object->Particle Systems->PFX Renderer       //
//  � ������� PointLightPFXManager �� ������� "GLScene PFX"           //
//  � ���������� � ���� "PFX Renderer" � ���������� GLCadencer        //
//  � � �������-"���������" ��������� Effects->Add->PFX Source        //
//  ��, "��������" ������, ������ ���� ��������� ���������:          //
//  � PointLightPFXManager->AspectRatio=0.05 ������ �������           //
//  � PointLightPFXManager->ParticleSize=0.1 ������ �� ��������       //
//  � PointLightPFXManager->ColorInner=[1,1,1,0.5] ��������������     //
//  � PFX Source->ParticleInterval=0.001 ��� ������, ��� ������       //
//  � PFX Source->PositionDispersionRange=[1,0,1] ������� �� ����     //
//  � PFX Source->PositionDispersion=5 ��������� ��������             //
//  ��������� ����������, ������ ����� GLCadencer ����� ���������     //
//  PFX Source->InitialPosition � PFX Source->InitialVelocity,        //
//  ������� ������ ���� ������ ����� PointLightPFXManager->Rotation   //
//                                                                    //
// �����                                                             //
//  �������� ����� ���������� �������� "�����":                       //
//  � ������� PointLightPFXManager �� ������� "GLScene PFX"           //
//  � ���������� � ���� "PFX Renderer" � ���������� GLCadencer        //
//  � � �������-"���������" ��������� Effects->Add->PFX Source        //
//  ������ ���������� ���������:                                      //
//  � PointLightPFXManager->AspectRatio=0.5 ������ ��������� �����    //
//  � PointLightPFXManager->ParticleSize=0.1 ������ ��������          //
//  � PointLightPFXManager->ColorInner=clrWhite ����� �������         //
//  � PFX Source->ParticleInterval=0.001 ��� ������, ��� ������       //
//  � PFX Source->PositionDispersionRange=[1,0,1] ������� �� ����     //
//  � PFX Source->PositionDispersion=5 ��������� ��������             //
//  � PFX Source->VelocityDispersion=1 ����� ������                  //
//  ��������� ����������, � ����� GLCadencer ����� ����� ���������    //
//  PFX Source->InitialPosition � PFX Source->InitialVelocity         //
//                                                                    //
// ������                                                            //
//  ����� ���� - ������� ��������� PerlinPFX ��� �������� ����������� //
//  �������� ������� ����������:                                      //
//  � ������� PerlinPFXManager �� ������� "GLScene PFX"               //
//  � ���������� � ���� "PFX Renderer" � ���������� GLCadencer        //
//  � � �������-"���������" ��������� Effects->Add->PFX Source        //
//  ���������� ���������:                                             //
//  � PointLightPFXManager->Brightness=0.2 ���������� �������         //
//  � PointLightPFXManager->ColorMode=scmFade ����� ������ ���������  //
//  � PointLightPFXManager->ColorInner=[1,1,1,0.5] ���� ������������  //
//  � PointLightPFXManager->ParticleSize=1.5 ������� ����� ����       //
//  � PFX Source->InitialPosition=[0,-3,0] ������� ������� �����      //
//  � PFX Source->InitialVelocity=[0,0.5,0] � ���������� �����        //
//  � PFX Source->ParticleInterval=0.005 ��� ������, ��� ����         //
//  � PFX Source->PositionDispersionRange=[4,0,1] ������� ����� ����� //
//  � PFX Source->RotationDispersion=1 ������� ��������               //
//  � PFX Source->VelocityDispersion=1 ����� ������                  //
//                                                                    //
//====================================================================//
//  GLScene.ru                                                        //
////////////////////////////////////////////////////////////////////////

program WeatherEffects;

uses
  Forms,
  Unit1 in 'Unit1.pas' {Form1};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
