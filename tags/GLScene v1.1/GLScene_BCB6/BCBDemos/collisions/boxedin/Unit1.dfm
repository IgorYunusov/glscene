object Form1: TForm1
  Left = 180
  Top = 115
  Width = 705
  Height = 574
  Caption = 'Form1'
  Color = clGray
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object GLSceneViewer2: TGLSceneViewer
    Left = 0
    Top = 65
    Width = 697
    Height = 475
    Camera = GLCamera2
    Buffer.BackgroundColor = 8404992
    Buffer.ShadeModel = smFlat
    FieldOfView = 156.222686767578
    Align = alClient
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 697
    Height = 65
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 1
    object Label1: TLabel
      Left = 424
      Top = 8
      Width = 32
      Height = 13
      Caption = 'Label1'
    end
    object Label2: TLabel
      Left = 424
      Top = 24
      Width = 32
      Height = 13
      Caption = 'Label2'
    end
    object Label3: TLabel
      Left = 424
      Top = 40
      Width = 32
      Height = 13
      Caption = 'Label3'
    end
    object Label4: TLabel
      Left = 216
      Top = 8
      Width = 37
      Height = 13
      Caption = 'Velocity'
    end
    object TrackBar1: TTrackBar
      Left = 112
      Top = 24
      Width = 265
      Height = 25
      Max = 50
      Orientation = trHorizontal
      Frequency = 1
      Position = 1
      SelEnd = 0
      SelStart = 0
      TabOrder = 0
      TickMarks = tmBottomRight
      TickStyle = tsAuto
    end
    object Button1: TButton
      Left = 8
      Top = 24
      Width = 75
      Height = 25
      Caption = 'Reset'
      TabOrder = 1
      OnClick = Button1Click
    end
  end
  object GLScene1: TGLScene
    Left = 72
    Top = 88
    object GLLightSource1: TGLLightSource
      Ambient.Color = {000000001283003F9CC4403F0000803F}
      ConstAttenuation = 1
      Diffuse.Color = {1283003F1283003F1283003F0000803F}
      Position.Coordinates = {00004842000016430000C8420000803F}
      LightStyle = lsOmni
      Specular.Color = {0000803F0000803F0000803F0000803F}
      SpotCutOff = 180
    end
    object DummyCube1: TGLDummyCube
      CubeSize = 1
      object FreeForm1: TGLFreeForm
        Material.Texture.MappingTCoordinates.Coordinates = {000000000000803F0000000000000000}
        Direction.Coordinates = {000000000000803F0000000000000000}
        Up.Coordinates = {00000000000000000000803F00000000}
      end
    end
    object Sphere1: TGLSphere
      Material.FrontProperties.Emission.Color = {0000803F0000803F000000000000803F}
      Material.Texture.MappingTCoordinates.Coordinates = {000000000000803F0000000000000000}
      Direction.Coordinates = {000000000000803F0000000000000000}
      Up.Coordinates = {E9DC72BF000000009BE8A13E00000000}
      Radius = 0.100000001490116
      Slices = 6
      Stacks = 6
      object ArrowLine1: TGLArrowLine
        Material.FrontProperties.Diffuse.Color = {CDCC4C3FCDCC4C3FCDCC4C3F9A99193F}
        Material.FrontProperties.Emission.Color = {1283803E1283803E000000000000803F}
        Material.BlendingMode = bmTransparency
        Material.Texture.MappingTCoordinates.Coordinates = {000000000000803F0000000000000000}
        Position.Coordinates = {0000000000000000CDCCCC3D0000803F}
        BottomRadius = 0.0500000007450581
        Height = 1
        TopRadius = 0.100000001490116
        TopArrowHeadHeight = 2
        TopArrowHeadRadius = 0.200000002980232
        BottomArrowHeadHeight = 0.5
        BottomArrowHeadRadius = 0.200000002980232
      end
    end
    object DummyCube2: TGLDummyCube
      CubeSize = 1
    end
    object Sphere2: TGLSphere
      Material.FrontProperties.Diffuse.Color = {0000803F00000000000000000000803F}
      Material.FrontProperties.Shininess = 128
      Material.FrontProperties.Specular.Color = {0000803F0000803F0000803F0000803F}
      VisibilityCulling = vcObjectBased
      Direction.Coordinates = {4A602B3FC61C69BE490635BF00000000}
      Position.Coordinates = {000000000000E040000000C00000803F}
      Up.Coordinates = {B819C33EF71E6C3FCDAE823D00000000}
      Radius = 20
      Slices = 24
      Stacks = 24
    end
    object GLLightSource2: TGLLightSource
      Ambient.Color = {000000001283803E1283003F0000803F}
      ConstAttenuation = 1
      Diffuse.Color = {BEC0403FBEC0403FBEC0403F0000803F}
      Specular.Color = {0000803F0000803F0000803F0000803F}
      SpotCutOff = 180
    end
    object Lines1: TGLLines
      LineColor.Color = {0000803F0000803F0000003F3333733F}
      LineWidth = 3
      NodeColor.Color = {0000803F0000803F000000000000803F}
      Nodes = <>
      NodesAspect = lnaCube
      NodeSize = 10
      Options = [loUseNodeColorForLines]
    end
    object GLCamera2: TGLCamera
      DepthOfView = 1000
      FocalLength = 50
      TargetObject = Sphere2
      Position.Coordinates = {0000000000008040000040C00000803F}
      Direction.Coordinates = {00000000000000800000803F00000000}
    end
  end
  object GLCadencer1: TGLCadencer
    Scene = GLScene1
    OnProgress = GLCadencer1Progress
    Left = 8
    Top = 88
  end
  object Timer1: TTimer
    OnTimer = Timer1Timer
    Left = 40
    Top = 88
  end
end
