object Form1: TForm1
  Left = 192
  Top = 114
  Caption = 'TGLMenu demo '
  ClientHeight = 502
  ClientWidth = 605
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnKeyPress = FormKeyPress
  PixelsPerInch = 96
  TextHeight = 13
  object GLSceneViewer1: TGLSceneViewer
    Left = 0
    Top = 0
    Width = 605
    Height = 475
    Camera = GLCamera1
    Buffer.BackgroundColor = clGray
    FieldOfView = 156.222686767578100000
    Align = alClient
    OnMouseDown = GLSceneViewer1MouseDown
    OnMouseMove = GLSceneViewer1MouseMove
    TabOrder = 0
  end
  object MainPanel: TPanel
    Left = 0
    Top = 475
    Width = 605
    Height = 27
    Align = alBottom
    TabOrder = 1
    OnResize = MainPanelResize
    object Label1: TLabel
      Left = 144
      Top = 6
      Width = 234
      Height = 13
      Caption = 'Press "W" or "S" to navigate or "Enter" to select '
    end
    object ShoTitleCheckbox: TCheckBox
      Left = 8
      Top = 6
      Width = 81
      Height = 17
      Caption = 'Show Title'
      Checked = True
      State = cbChecked
      TabOrder = 0
      OnClick = ShoTitleCheckboxClick
      OnKeyPress = FormKeyPress
    end
  end
  object GLScene1: TGLScene
    Left = 112
    Top = 48
    object GLDummyCube1: TGLDummyCube
      CubeSize = 1.000000000000000000
      object GLCube1: TGLCube
        Position.Coordinates = {0000803F00000000000000000000803F}
      end
    end
    object GLCamera1: TGLCamera
      DepthOfView = 100.000000000000000000
      FocalLength = 50.000000000000000000
      TargetObject = GLDummyCube1
      Position.Coordinates = {0000404000004040000040400000803F}
      object GLLightSource1: TGLLightSource
        ConstAttenuation = 1.000000000000000000
        Position.Coordinates = {0000204100002041000020410000803F}
        SpotCutOff = 180.000000000000000000
      end
    end
  end
  object GLCadencer1: TGLCadencer
    Scene = GLScene1
    OnProgress = GLCadencer1Progress
    Left = 184
    Top = 48
  end
  object GLMaterialLibrary1: TGLMaterialLibrary
    Materials = <
      item
        Name = 'LibMaterial'
        Tag = 0
        Material.Texture.Disabled = False
      end>
    Left = 216
    Top = 48
  end
  object GLSystemBitmapFont1: TGLSystemBitmapFont
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWhite
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    Left = 144
    Top = 48
  end
end