object Form1: TForm1
  Left = 170
  Top = 79
  Width = 513
  Height = 287
  AutoSize = True
  Caption = 'Form1'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Arial'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 14
  object Bevel2: TBevel
    Left = 280
    Top = 49
    Width = 225
    Height = 209
  end
  object Bevel1: TBevel
    Left = 0
    Top = 49
    Width = 225
    Height = 209
  end
  object PaintBox1: TPaintBox
    Left = 288
    Top = 56
    Width = 209
    Height = 193
  end
  object GLSceneViewer1: TGLSceneViewer
    Left = 8
    Top = 57
    Width = 209
    Height = 193
    Camera = GLCamera1
  end
  object BUCast: TButton
    Left = 232
    Top = 89
    Width = 41
    Height = 25
    Caption = 'Cast!'
    TabOrder = 1
    OnClick = BUCastClick
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 505
    Height = 49
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 2
    object Label1: TLabel
      Left = 0
      Top = 0
      Width = 505
      Height = 22
      Align = alTop
      Alignment = taCenter
      AutoSize = False
      Caption = 'RayCasting demo/testbed'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Arial'
      Font.Style = [fsBold]
      ParentFont = False
      Layout = tlCenter
    end
    object Label2: TLabel
      Left = 8
      Top = 32
      Width = 100
      Height = 14
      Caption = 'OpenGL scene view'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Arial'
      Font.Style = []
      ParentFont = False
    end
    object Label3: TLabel
      Left = 288
      Top = 32
      Width = 136
      Height = 14
      Caption = 'RayCasted/RayTraced view'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Arial'
      Font.Style = []
      ParentFont = False
    end
  end
  object GLScene1: TGLScene
    Left = 16
    Top = 64
    object Sphere1: TGLSphere
      Material.FrontProperties.Diffuse.Color = {8D8C0C3F8D8C0C3F0000803F0000803F}
      Radius = 0.200000002980232
    end
    object DummyCube1: TGLDummyCube
      Direction.Coordinates = {00000000000080330000803F00000000}
      Up.Coordinates = {EE8384BEEA46773FEA4677B300000000}
      CubeSize = 1
      object Torus1: TGLTorus
        Direction.Coordinates = {5D1C7C3F02004032CED0313E00000000}
        Position.Coordinates = {000000BF00000000000000000000803F}
        Up.Coordinates = {00C02FB20000803F0000403200000000}
        Visible = False
        Material.FrontProperties.Diffuse.Color = {0000803F00000000000000000000803F}
        MajorRadius = 0.400000005960464
        MinorRadius = 0.100000001490116
      end
      object Plane1: TGLPlane
        Material.FrontProperties.Diffuse.Color = {0000803F0000803F000000000000803F}
        Material.FaceCulling = fcNoCull
        Height = 0.699999988079071
        Width = 0.300000011920929
      end
      object Cylinder1: TGLCylinder
        Direction.Coordinates = {00000000010000BFD6B35D3F00000000}
        Position.Coordinates = {0000003F00000000000000000000803F}
        Up.Coordinates = {00000000D6B35D3F0100003F00000000}
        Material.FrontProperties.Diffuse.Color = {0000803F0000803F8180003F0000803F}
        BottomRadius = 0.100000001490116
        Height = 0.600000023841858
        TopRadius = 0.100000001490116
        object GLAnnulus1: TGLAnnulus
          Material.FrontProperties.Diffuse.Color = {00000000000000000000803F0000803F}
          BottomRadius = 0.230000004172325
          Height = 0.200000002980232
          BottomInnerRadius = 0.180000007152557
          TopInnerRadius = 0.180000007152557
          TopRadius = 0.230000004172325
        end
      end
      object GLCube1: TGLCube
        Direction.Coordinates = {00000000B28F70BF431DAF3E00000000}
        Position.Coordinates = {000000BF00000000000000000000803F}
        Up.Coordinates = {00000000431DAF3EB28F703F00000000}
        Material.FrontProperties.Diffuse.Color = {0000803F00000000000000000000803F}
        CubeSize = {CDCC4C3ECDCCCC3D9A99993E}
      end
    end
    object GLLightSource1: TGLLightSource
      ConstAttenuation = 1
      Position.Coordinates = {0000204100001041000070410000803F}
      SpotCutOff = 180
    end
    object GLCamera1: TGLCamera
      DepthOfView = 100
      FocalLength = 50
      Position.Coordinates = {0000000000000000000040400000803F}
      Left = 256
      Top = 160
    end
  end
  object GLCadencer1: TGLCadencer
    Scene = GLScene1
    OnProgress = GLCadencer1Progress
    Left = 56
    Top = 64
  end
end
