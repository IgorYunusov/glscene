object Form1: TForm1
  Left = 291
  Top = 1010
  Caption = 'Click on an object'
  ClientHeight = 519
  ClientWidth = 971
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object GLSceneViewer1: TGLSceneViewer
    Left = 0
    Top = 0
    Width = 971
    Height = 519
    Camera = GLCamera1
    FieldOfView = 158.188003540039100000
    Align = alClient
    OnMouseDown = GLSceneViewer1MouseDown
    TabOrder = 0
  end
  object GLScene1: TGLScene
    Left = 32
    Top = 48
    object GLSphere1: TGLSphere
      Position.Coordinates = {000040C000000000000000000000803F}
      Radius = 0.500000000000000000
    end
    object GLCone1: TGLCone
      Position.Coordinates = {0000000000000000000000C00000803F}
      BottomRadius = 0.500000000000000000
      Height = 1.000000000000000000
    end
    object GLCube1: TGLCube
      Position.Coordinates = {0000404000000000000000400000803F}
    end
    object GLPlane1: TGLPlane
      Direction.Coordinates = {000000000000803F0000000000000000}
      Position.Coordinates = {00000000000000BF000000000000803F}
      Up.Coordinates = {0000000000000000000080BF00000000}
      Height = 20.000000000000000000
      Width = 20.000000000000000000
    end
    object Target: TGLDummyCube
      ShowAxes = True
      CubeSize = 1.000000000000000000
    end
    object oldTarget: TGLDummyCube
      CubeSize = 1.000000000000000000
    end
    object GLCamera1: TGLCamera
      DepthOfView = 100.000000000000000000
      FocalLength = 50.000000000000000000
      TargetObject = Target
      Position.Coordinates = {000080BF00004040000040400000803F}
      object GLLightSource1: TGLLightSource
        ConstAttenuation = 1.000000000000000000
        SpotCutOff = 180.000000000000000000
      end
    end
  end
  object GLCadencer1: TGLCadencer
    Scene = GLScene1
    OnProgress = GLCadencer1Progress
    Left = 32
    Top = 16
  end
end
