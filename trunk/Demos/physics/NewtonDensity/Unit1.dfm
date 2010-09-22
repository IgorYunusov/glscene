object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Form1'
  ClientHeight = 507
  ClientWidth = 723
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object GLSceneViewer1: TGLSceneViewer
    Left = 0
    Top = 0
    Width = 723
    Height = 507
    Camera = GLCamera1
    FieldOfView = 157.684555053710900000
    Align = alClient
    TabOrder = 0
  end
  object Button1: TButton
    Left = 16
    Top = 56
    Width = 75
    Height = 25
    Caption = 'Shoot'
    TabOrder = 1
    OnClick = Button1Click
  end
  object SpinEdit1: TSpinEdit
    Left = 16
    Top = 103
    Width = 75
    Height = 22
    EditorEnabled = False
    MaxValue = 100
    MinValue = 0
    TabOrder = 2
    Value = 1
    OnChange = SpinEdit1Change
  end
  object GLScene1: TGLScene
    Left = 144
    Top = 16
    object GLCamera1: TGLCamera
      DepthOfView = 100.000000000000000000
      FocalLength = 50.000000000000000000
      TargetObject = GLDummyCube1
      Position.Coordinates = {000000000000A040000070410000803F}
      object GLLightSource1: TGLLightSource
        ConstAttenuation = 1.000000000000000000
        SpotCutOff = 180.000000000000000000
      end
    end
    object GLPlane1: TGLPlane
      Material.FrontProperties.Diffuse.Color = {000000000000803F0000803F0000803F}
      Material.FrontProperties.Emission.Color = {00000000F8FEFE3E0000803F0000803F}
      Material.BlendingMode = bmModulate
      Direction.Coordinates = {000000000000803F0000000000000000}
      Up.Coordinates = {0000000000000000000080BF00000000}
      Height = 10.000000000000000000
      Width = 20.000000000000000000
    end
    object GLDummyCube1: TGLDummyCube
      Position.Coordinates = {000000000000A0C0000000000000803F}
      CubeSize = 1.000000000000000000
    end
    object GLPaperSphere: TGLSphere
      Material.FrontProperties.Diffuse.Color = {0000803F0000803F0000803F0000803F}
      Position.Coordinates = {000080C00000A0C0000000000000803F}
      Up.Coordinates = {000000000000803F0000008000000000}
      Radius = 2.000000000000000000
      BehavioursData = {
        0458434F4C02010201060D54474C4E474444796E616D69630200060B4E474420
        44796E616D696302000200060D474C4E47444D616E6167657231080200020009
        0FCDCCCC3D0FCDCCCC3D08080802000802000802000802000802000900000000
        00000000000000000000803F020008020008}
    end
    object GLLeadSphere: TGLSphere
      Material.FrontProperties.Diffuse.Color = {3D0A173F85EBD13E52B89E3E0000803F}
      Position.Coordinates = {000080C00000803F000040C00000803F}
      Up.Coordinates = {000000000000803F0000008000000000}
      Radius = 2.000000000000000000
      BehavioursData = {
        0458434F4C02010201060D54474C4E474444796E616D69630200060B4E474420
        44796E616D696302000200060D474C4E47444D616E6167657231080200020009
        0FCDCCCC3D0F0000204108080802000802000802000802000802000900000000
        00000000000000000000803F020008020008}
    end
    object SubMarine: TGLCube
      Direction.Coordinates = {F304353FFFFFFF3E0100003F00000000}
      PitchAngle = 45.000000000000000000
      Position.Coordinates = {0000A0400000C040000000000000803F}
      TurnAngle = 45.000000000000000000
      Up.Coordinates = {5C67A332F404353FF20435BF00000000}
      BehavioursData = {
        0458434F4C02010201060D54474C4E474444796E616D69630200060B4E474420
        44796E616D696302000200060D474C4E47444D616E6167657231080200020009
        0FCDCCCC3D0F0000803F08080802000802000802000802000802000900000000
        00000000000000000000803F020008020008}
      CubeSize = {0000803F0000803F0000A040}
    end
    object GLCube1: TGLCube
      Position.Coordinates = {00000000000020C1000000000000803F}
      Up.Coordinates = {000000000000803F0000008000000000}
      BehavioursData = {
        0458434F4C02010201060C54474C4E47445374617469630200060A4E47442053
        746174696302000200060D474C4E47444D616E6167657231080200}
      CubeSize = {0000A0410000803F00002041}
    end
    object GLHUDText1: TGLHUDText
      Position.Coordinates = {0000704100000243000000000000803F}
      BitmapFont = GLStoredBitmapFont1
      Text = 'Water Density'
      ModulateColor.Color = {0000000000000000000000000000803F}
    end
  end
  object GLCadencer1: TGLCadencer
    Scene = GLScene1
    OnProgress = GLCadencer1Progress
    Left = 200
    Top = 16
  end
  object GLNGDManager1: TGLNGDManager
    Visible = True
    WaterDensity = 1.000000000000000000
    Left = 296
    Top = 16
  end
  object GLSimpleNavigation1: TGLSimpleNavigation
    Form = Owner
    GLSceneViewer = GLSceneViewer1
    FormCaption = 'Form1 - %FPS'
    KeyCombinations = <
      item
        ShiftState = [ssLeft, ssRight]
        Action = snaZoom
      end
      item
        ShiftState = [ssLeft]
        Action = snaMoveAroundTarget
      end
      item
        ShiftState = [ssRight]
        Action = snaMoveAroundTarget
      end>
    Left = 80
    Top = 16
  end
  object GLStoredBitmapFont1: TGLStoredBitmapFont
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWhite
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    Left = 376
    Top = 16
  end
end