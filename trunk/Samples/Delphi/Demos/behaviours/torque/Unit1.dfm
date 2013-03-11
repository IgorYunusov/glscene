object Form1: TForm1
  Left = 125
  Top = 119
  BorderWidth = 5
  Caption = 'Torque'
  ClientHeight = 280
  ClientWidth = 735
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
    Top = 78
    Width = 735
    Height = 161
    Camera = GLCamera1
    FieldOfView = 77.668128967285160000
    Align = alClient
    OnMouseMove = GLSceneViewer1MouseMove
    TabOrder = 0
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 735
    Height = 78
    Align = alTop
    TabOrder = 1
    object Label2: TLabel
      Left = 280
      Top = 8
      Width = 116
      Height = 39
      Alignment = taCenter
      Caption = 'Hexahedron has a small constant'#13#10'and linear damping'
      WordWrap = True
    end
    object Label3: TLabel
      Left = 472
      Top = 8
      Width = 100
      Height = 39
      Alignment = taCenter
      Caption = 'Dodecahedron has a'#13#10'small constant and'#13#10'quadratic damping'
      WordWrap = True
    end
    object Label4: TLabel
      Left = 128
      Top = 8
      Width = 109
      Height = 26
      Alignment = taCenter
      Caption = 'Octahedron has a'#13#10'only quadratic damping'
      WordWrap = True
    end
    object Label1: TLabel
      Left = 8
      Top = 10
      Width = 84
      Height = 39
      Caption = 'Tetrahedron has an only quadratic damping'
      WordWrap = True
    end
    object Label5: TLabel
      Left = 604
      Top = 8
      Width = 117
      Height = 39
      Alignment = taCenter
      Caption = 'Icosahedron has a small constant'#13#10'and linear damping'
      WordWrap = True
    end
    object CheckBox1: TCheckBox
      Left = 8
      Top = 55
      Width = 81
      Height = 17
      Caption = 'Double Mass'
      TabOrder = 0
      OnClick = CheckBox1Click
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 239
    Width = 735
    Height = 41
    Align = alBottom
    Caption = 'Move your mouse over an object and it will start spinning'
    TabOrder = 2
  end
  object GLScene1: TGLScene
    Left = 16
    Top = 80
    object GLLightSource1: TGLLightSource
      ConstAttenuation = 1.000000000000000000
      Position.Coordinates = {0000704100002041000020C10000803F}
      SpotCutOff = 180.000000000000000000
    end
    object DummyCube1: TGLDummyCube
      CubeSize = 1.000000000000000000
      object Tetrahedron: TGLTetrahedron
        Material.FrontProperties.Diffuse.Color = {BEBEBE3E999F1F3F999F1F3F0000803F}
        Material.BlendingMode = bmTransparency
        Direction.Coordinates = {2EF9E43E000000002EF9643F00000000}
        Position.Coordinates = {0000000000000000000080400000803F}
        Scale.Coordinates = {0000003F0000003F0000003F00000000}
        Up.Coordinates = {000000000000803F0000008000000000}
      end
      object Octahedron: TGLOctahedron
        Material.FrontProperties.Diffuse.Color = {CDCC4C3FF8FEFE3EACC8483E0000803F}
        Position.Coordinates = {0000000000000000000000400000803F}
        Scale.Coordinates = {CDCC4C3FCDCC4C3FCDCC4C3F00000000}
      end
      object Hexahedron: TGLCube
        Material.FrontProperties.Diffuse.Color = {F8FEFE3E0000803F000000000000803F}
        Direction.Coordinates = {0000003F00000000D7B35D3F00000000}
        TurnAngle = 30.000000000000000000
      end
      object Dodecahedron: TGLDodecahedron
        Material.FrontProperties.Diffuse.Color = {0000803F00000000000000000000803F}
        Position.Coordinates = {0000000000000000000000C00000803F}
        Scale.Coordinates = {9A99993F9A99993F9A99993F00000000}
      end
      object Icosahedron: TGLIcosahedron
        Material.FrontProperties.Diffuse.Color = {14AE073F8FC2F53DD7A3F03E0000803F}
        Position.Coordinates = {0000000000000000000080C00000803F}
        Scale.Coordinates = {9A99993F9A99993F9A99993F00000000}
      end
    end
    object GLCamera1: TGLCamera
      DepthOfView = 100.000000000000000000
      FocalLength = 100.000000000000000000
      TargetObject = DummyCube1
      Position.Coordinates = {000020410000A040000000000000803F}
    end
  end
  object GLCadencer1: TGLCadencer
    Scene = GLScene1
    OnProgress = GLCadencer1Progress
    Left = 88
    Top = 80
  end
end
