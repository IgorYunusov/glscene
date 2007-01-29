object Form1: TForm1
  Left = 250
  Top = 151
  Width = 782
  Height = 644
  Caption = 'Form1'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnMouseWheel = FormMouseWheel
  PixelsPerInch = 96
  TextHeight = 13
  object Splitter1: TSplitter
    Left = 584
    Top = 0
    Width = 8
    Height = 581
    Align = alRight
    Beveled = True
    MinSize = 200
    ResizeStyle = rsLine
  end
  object MaskBox: TGroupBox
    Left = 592
    Top = 0
    Width = 182
    Height = 581
    Align = alRight
    Caption = 'Particle Masks'
    TabOrder = 0
    object XImage: TImage
      Left = 16
      Top = 32
      Width = 150
      Height = 150
      Stretch = True
    end
    object XLabel: TLabel
      Left = 16
      Top = 16
      Width = 36
      Height = 13
      Caption = 'X Mask'
    end
    object YLabel: TLabel
      Left = 16
      Top = 200
      Width = 36
      Height = 13
      Caption = 'Y Mask'
    end
    object ZLabel: TLabel
      Left = 16
      Top = 400
      Width = 36
      Height = 13
      Caption = 'Z Mask'
    end
    object YImage: TImage
      Left = 16
      Top = 224
      Width = 150
      Height = 150
      Stretch = True
    end
    object ZImage: TImage
      Left = 16
      Top = 416
      Width = 150
      Height = 150
      Stretch = True
    end
    object Button1: TButton
      Left = 64
      Top = 12
      Width = 99
      Height = 17
      Caption = 'View from XMask'
      TabOrder = 0
      OnClick = Button1Click
    end
    object Button2: TButton
      Left = 72
      Top = 196
      Width = 99
      Height = 17
      Caption = 'View from YMask'
      TabOrder = 1
      OnClick = Button2Click
    end
    object Button3: TButton
      Left = 72
      Top = 396
      Width = 99
      Height = 17
      Caption = 'View from ZMask'
      TabOrder = 2
      OnClick = Button3Click
    end
  end
  object SceneViewer: TGLSceneViewer
    Left = 0
    Top = 0
    Width = 584
    Height = 581
    Camera = Camera
    Buffer.BackgroundColor = clBackground
    FieldOfView = 176.056930541992200000
    Align = alClient
    OnMouseMove = SceneViewerMouseMove
  end
  object Panel1: TPanel
    Left = 0
    Top = 581
    Width = 774
    Height = 36
    Align = alBottom
    TabOrder = 2
    object Label1: TLabel
      Left = 8
      Top = 11
      Width = 29
      Height = 13
      Caption = 'Depth'
    end
    object Label2: TLabel
      Left = 88
      Top = 11
      Width = 46
      Height = 13
      Caption = 'Character'
    end
    object Label3: TLabel
      Left = 176
      Top = 11
      Width = 54
      Height = 13
      Caption = 'Pitch Angle'
    end
    object Label4: TLabel
      Left = 304
      Top = 11
      Width = 48
      Height = 13
      Caption = 'Roll Angle'
    end
    object Label5: TLabel
      Left = 424
      Top = 11
      Width = 52
      Height = 13
      Caption = 'Turn Angle'
    end
    object Button4: TButton
      Left = 1032
      Top = 3
      Width = 43
      Height = 30
      Caption = 'GO'
      TabOrder = 0
      OnClick = Button4Click
    end
    object Edit1: TEdit
      Left = 40
      Top = 8
      Width = 33
      Height = 21
      TabOrder = 1
      Text = '50'
    end
    object Edit2: TEdit
      Left = 144
      Top = 8
      Width = 25
      Height = 21
      TabOrder = 2
      Text = 'A'
      OnChange = Edit2Change
    end
    object Edit3: TEdit
      Left = 240
      Top = 8
      Width = 57
      Height = 21
      TabOrder = 3
      Text = '0'
      OnChange = Edit3Change
    end
    object Edit4: TEdit
      Left = 360
      Top = 8
      Width = 57
      Height = 21
      TabOrder = 4
      Text = '0'
      OnChange = Edit4Change
    end
    object Edit5: TEdit
      Left = 488
      Top = 7
      Width = 57
      Height = 21
      TabOrder = 5
      Text = '0'
      OnChange = Edit5Change
    end
    object CheckBox1: TCheckBox
      Left = 552
      Top = 8
      Width = 97
      Height = 17
      Caption = 'Target Sphere'
      TabOrder = 6
      OnClick = CheckBox1Click
    end
  end
  object GLScene: TGLScene
    ObjectsSorting = osRenderFarthestFirst
    Left = 8
    Top = 8
    object Target: TGLDummyCube
      CubeSize = 1.000000000000000000
      EffectsData = {
        0201061254474C536F7572636550465845666665637402010609504C4D616E61
        676572050000000000000080FF3F020602000802000802000805000000000000
        000000000500000000000000000000050000000000FAEDEBF43F020002000905
        00000000000000000000080200}
    end
    object XPlane: TGLPlane
      Material.MaterialLibrary = MatLib
      Material.LibMaterialName = 'XMask'
      Direction.Coordinates = {0000803F000000002EBD3BB300000000}
      Position.Coordinates = {000040C000000000000000000000803F}
      TurnAngle = 90.000000000000000000
      Up.Coordinates = {00000000FFFF7F3F0000000000000000}
      Height = 3.000000000000000000
      Width = 3.000000000000000000
      NoZWrite = False
    end
    object YPlane: TGLPlane
      Material.MaterialLibrary = MatLib
      Material.LibMaterialName = 'YMask'
      Direction.Coordinates = {000000000000803F31BD3BB300000000}
      PitchAngle = 90.000000000000000000
      Position.Coordinates = {00000000000040C0000000000000803F}
      RollAngle = 180.000000000000000000
      Up.Coordinates = {010000B331BD3B330000803F00000000}
      Height = 3.000000000000000000
      Width = 3.000000000000000000
      NoZWrite = False
    end
    object ZPlane: TGLPlane
      Material.MaterialLibrary = MatLib
      Material.LibMaterialName = 'ZMask'
      Direction.Coordinates = {00000000010000B30000803F00000000}
      Position.Coordinates = {0000000000000000000040C00000803F}
      Up.Coordinates = {000000000000803F0100003300000000}
      Hint = '0'
      Height = 3.000000000000000000
      Width = 3.000000000000000000
      NoZWrite = False
    end
    object PFXRenderer: TGLParticleFXRenderer
    end
    object Sphere: TGLSphere
      Direction.Coordinates = {0000000000000000FFFF7F3F00000000}
      Position.Coordinates = {0000004000000000000000000000803F}
      Visible = False
      Radius = 0.250000000000000000
      object GLArrowLine1: TGLArrowLine
        Direction.Coordinates = {0000803F000000002EBD3BB300000000}
        Position.Coordinates = {CDCCCC3D00000000000000000000803F}
        TurnAngle = 90.000000000000000000
        Up.Coordinates = {00000000FFFF7F3F0000000000000000}
        BottomRadius = 0.100000001490116100
        Height = 0.500000000000000000
        TopRadius = 0.100000001490116100
        TopArrowHeadHeight = 0.500000000000000000
        TopArrowHeadRadius = 0.200000002980232200
        BottomArrowHeadHeight = 0.500000000000000000
        BottomArrowHeadRadius = 0.200000002980232200
      end
    end
    object Camera: TGLCamera
      DepthOfView = 100.000000000000000000
      FocalLength = 10.000000000000000000
      TargetObject = Target
      CameraStyle = csOrthogonal
      Position.Coordinates = {0000803F00000040000040400000803F}
      object Light: TGLLightSource
        ConstAttenuation = 1.000000000000000000
        SpotCutOff = 180.000000000000000000
      end
    end
  end
  object GLCadencer: TGLCadencer
    Scene = GLScene
    OnProgress = GLCadencerProgress
    Left = 72
    Top = 8
  end
  object MatLib: TGLMaterialLibrary
    Materials = <
      item
        Name = 'XMask'
        Material.Texture.Image.Picture.Data = {07544269746D617000000000}
        Material.Texture.ImageAlpha = tiaInverseLuminance
        Material.Texture.MagFilter = maNearest
        Material.Texture.MinFilter = miNearest
        Material.Texture.Disabled = False
        Tag = 0
      end
      item
        Name = 'YMask'
        Material.Texture.Image.Picture.Data = {07544269746D617000000000}
        Material.Texture.ImageAlpha = tiaInverseLuminance
        Material.Texture.MagFilter = maNearest
        Material.Texture.MinFilter = miNearest
        Material.Texture.Disabled = False
        Tag = 0
      end
      item
        Name = 'ZMask'
        Material.Texture.Image.Picture.Data = {07544269746D617000000000}
        Material.Texture.ImageAlpha = tiaInverseLuminance
        Material.Texture.MagFilter = maNearest
        Material.Texture.MinFilter = miNearest
        Material.Texture.Disabled = False
        Tag = 0
      end>
    Left = 40
    Top = 8
  end
  object WinFont: TGLWindowsBitmapFont
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWhite
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    Left = 104
    Top = 8
  end
  object PLManager: TGLPointLightPFXManager
    Cadencer = GLCadencer
    Renderer = PFXRenderer
    OnCreateParticle = PLManagerCreateParticle
    Friction = 1.000000000000000000
    ColorMode = scmFade
    ParticleSize = 0.200000002980232200
    ColorInner.Color = {00000000000000000000000000000000}
    LifeColors = <
      item
        ColorInner.Color = {9A99993E9A99993E0000803F0000803F}
        LifeTime = 3.000000000000000000
        SizeScale = 1.000000000000000000
      end>
    Left = 136
    Top = 8
  end
  object GLEParticleMasksManager1: TGLEParticleMasksManager
    ParticleMasks = <
      item
        Scale.Coordinates = {0000A0400000A0400000A04000000000}
        Name = 'mask'
        MaterialLibrary = MatLib
        XMask = 'XMask'
        YMask = 'YMask'
        ZMask = 'ZMask'
        BackgroundColor = clBlack
        MaskColor = clWhite
      end>
    Left = 168
    Top = 8
  end
  object AsyncTimer1: TAsyncTimer
    Enabled = True
    OnTimer = AsyncTimer1Timer
    ThreadPriority = tpNormal
    Left = 200
    Top = 8
  end
end
