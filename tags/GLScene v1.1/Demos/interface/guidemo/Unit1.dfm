object Form1: TForm1
  Left = 182
  Top = 91
  Width = 513
  Height = 403
  Caption = 'Form1'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  Menu = MainMenu1
  OldCreateOrder = False
  OnKeyDown = FormKeyDown
  OnKeyPress = FormKeyPress
  OnKeyUp = FormKeyUp
  PixelsPerInch = 96
  TextHeight = 13
  object GLSceneViewer1: TGLSceneViewer
    Left = 0
    Top = 0
    Width = 505
    Height = 357
    Camera = GLCamera1
    Buffer.BackgroundColor = clBlack
    Align = alClient
    OnMouseDown = GLSceneViewer1MouseDown
    OnMouseMove = GLSceneViewer1MouseMove
    OnMouseUp = GLSceneViewer1MouseUp
  end
  object GLScene1: TGLScene
    ObjectsSorting = osNone
    Left = 16
    Top = 16
    object GLLightSource1: TGLLightSource
      ConstAttenuation = 1
      Position.Coordinates = {0000204100002041000020410000803F}
      SpotCutOff = 180
    end
    object GLForm1: TGLForm
      RedrawAtOnce = False
      GuiLayout = GLGuiLayout1
      GuiLayoutName = 'form'
      AlphaChannel = 0.5
      NoZWrite = False
      Width = 300
      Height = 170
      Left = 100
      Top = 100
      Position.Coordinates = {0000C8420000C842000000000000803F}
      BitmapFont = WindowsBitmapFont1
      DefaultColor = clMaroon
      Caption = 'Gui Form'
      TitleColor = clWhite
      object GLButton1: TGLButton
        RedrawAtOnce = False
        GuiLayout = GLGuiLayout1
        GuiLayoutName = 'panel'
        NoZWrite = False
        Width = 140
        Height = 25
        Left = 180
        Top = 220
        Position.Coordinates = {0000344300005C43000000000000803F}
        BitmapFont = WindowsBitmapFont1
        DefaultColor = clBlack
        Caption = 'Set Title'
        Focused = False
        FocusedColor = clBlack
        Group = -1
        Pressed = False
        OnButtonClick = GLButton1ButtonClick
        GuiLayoutNamePressed = 'panel'
        AllowUp = True
      end
      object GLEdit1: TGLEdit
        RedrawAtOnce = False
        GuiLayout = GLGuiLayout1
        GuiLayoutName = 'panel'
        NoZWrite = False
        Width = 180
        Height = 21
        Left = 200
        Top = 170
        Position.Coordinates = {0000484300002A43000000000000803F}
        BitmapFont = WindowsBitmapFont1
        DefaultColor = clBlack
        Caption = 'New Title'
        Focused = False
        FocusedColor = clBlack
        EditChar = '*'
        SelStart = 0
      end
      object GLLabel1: TGLLabel
        RedrawAtOnce = False
        GuiLayout = GLGuiLayout1
        NoZWrite = False
        Width = 80
        Height = 21
        Left = 110
        Top = 170
        Position.Coordinates = {0000DC4200002A43000000000000803F}
        BitmapFont = WindowsBitmapFont1
        DefaultColor = clBlack
        Caption = 'Title'
      end
    end
    object GLCamera1: TGLCamera
      DepthOfView = 100
      FocalLength = 50
      Position.Coordinates = {0000A04000004040000080400000803F}
      Left = 240
      Top = 152
    end
  end
  object GLCadencer1: TGLCadencer
    Scene = GLScene1
    OnProgress = GLCadencer1Progress
    Left = 16
    Top = 48
  end
  object Timer1: TTimer
    OnTimer = Timer1Timer
    Left = 16
    Top = 80
  end
  object WindowsBitmapFont1: TGLWindowsBitmapFont
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWhite
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    Left = 48
    Top = 48
  end
  object MainMenu1: TMainMenu
    Left = 112
    Top = 48
    object Font1: TMenuItem
      Caption = 'Font'
      object WindowsFont1: TMenuItem
        Caption = 'Set New Font'
        OnClick = WindowsFont1Click
      end
    end
  end
  object FontDialog1: TFontDialog
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    MinFontSize = 0
    MaxFontSize = 0
    Left = 112
    Top = 16
  end
  object GLGuiLayout1: TGLGuiLayout
    BitmapFont = WindowsBitmapFont1
    Material.MaterialLibrary = GLMaterialLibrary1
    Material.LibMaterialName = 'Gui'
    GuiComponents = <
      item
        Elements = <
          item
            TopLeft.Coordinates = {00003041000082420000000000000000}
            BottomRight.Coordinates = {000020420000BC420000000000000000}
            Scale.Coordinates = {0000803F0000803F0000000000000000}
            Align = GLAlCenter
            Name = 'center1'
          end
          item
            TopLeft.Coordinates = {00000000000000000000000000000000}
            BottomRight.Coordinates = {000088410000F0410000000000000000}
            Scale.Coordinates = {0000803F0000803F0000000000000000}
            Align = GLAlTopLeft
            Name = 'TopLeft1'
          end
          item
            TopLeft.Coordinates = {00008841000000000000000000000000}
            BottomRight.Coordinates = {0000E0420000F0410000000000000000}
            Scale.Coordinates = {0000803F0000803F0000000000000000}
            Align = GLAlTop
            Name = 'Top1'
          end
          item
            TopLeft.Coordinates = {000000000000F8410000000000000000}
            BottomRight.Coordinates = {000000410000DA420000000000000000}
            Scale.Coordinates = {0000803F0000803F0000000000000000}
            Align = GLAlLeft
            Name = 'Left1'
          end
          item
            TopLeft.Coordinates = {0000E042000000000000000000000000}
            BottomRight.Coordinates = {000000430000F0410000000000000000}
            Scale.Coordinates = {0000803F0000803F0000000000000000}
            Align = GLAlTopRight
            Name = 'TopRight1'
          end
          item
            TopLeft.Coordinates = {0000F0420000F0410000000000000000}
            BottomRight.Coordinates = {000000430000DE420000000000000000}
            Scale.Coordinates = {0000803F0000803F0000000000000000}
            Align = GLAlRight
            Name = 'Right1'
          end
          item
            TopLeft.Coordinates = {000000000000E2420000000000000000}
            BottomRight.Coordinates = {00007041000000430000000000000000}
            Scale.Coordinates = {0000803F0000803F0000000000000000}
            Align = GLAlBottomLeft
            Name = 'BottomLeft1'
          end
          item
            TopLeft.Coordinates = {000070410000F0420000000000000000}
            BottomRight.Coordinates = {0000E242000000430000000000000000}
            Scale.Coordinates = {0000803F0000803F0000000000000000}
            Align = GLAlBottom
            Name = 'Bottom1'
          end
          item
            TopLeft.Coordinates = {0000E2420000E2420000000000000000}
            BottomRight.Coordinates = {00000043000000430000000000000000}
            Scale.Coordinates = {0000803F0000803F0000000000000000}
            Align = GLAlBottomRight
            Name = 'BottomRight1'
          end>
        Name = 'form'
      end
      item
        Elements = <
          item
            TopLeft.Coordinates = {00003041000082420000000000000000}
            BottomRight.Coordinates = {000020420000BC420000000000000000}
            Scale.Coordinates = {0000803F0000803F0000000000000000}
            Align = GLAlCenter
            Name = 'center1'
          end
          item
            TopLeft.Coordinates = {00000041000078420000000000000000}
            BottomRight.Coordinates = {00005041000086420000000000000000}
            Scale.Coordinates = {0000803F0000803F0000000000000000}
            Align = GLAlTopLeft
            Name = 'TopLeft1'
          end
          item
            TopLeft.Coordinates = {00003041000078420000000000000000}
            BottomRight.Coordinates = {00002042000084420000000000000000}
            Scale.Coordinates = {0000803F0000803F0000000000000000}
            Align = GLAlTop
            Name = 'Top1'
          end
          item
            TopLeft.Coordinates = {00000041000082420000000000000000}
            BottomRight.Coordinates = {000040410000BC420000000000000000}
            Scale.Coordinates = {0000803F0000803F0000000000000000}
            Align = GLAlLeft
            Name = 'Left1'
          end
          item
            TopLeft.Coordinates = {00001842000078420000000000000000}
            BottomRight.Coordinates = {00002C42000086420000000000000000}
            Scale.Coordinates = {0000803F0000803F0000000000000000}
            Align = GLAlTopRight
            Name = 'TopRight1'
          end
          item
            TopLeft.Coordinates = {00001C42000082420000000000000000}
            BottomRight.Coordinates = {00002C420000BC420000000000000000}
            Scale.Coordinates = {0000803F0000803F0000000000000000}
            Align = GLAlRight
            Name = 'Right1'
          end
          item
            TopLeft.Coordinates = {000000410000B8420000000000000000}
            BottomRight.Coordinates = {000050410000C2420000000000000000}
            Scale.Coordinates = {0000803F0000803F0000000000000000}
            Align = GLAlBottomLeft
            Name = 'BottomLeft1'
          end
          item
            TopLeft.Coordinates = {000030410000BA420000000000000000}
            BottomRight.Coordinates = {000020420000C2420000000000000000}
            Scale.Coordinates = {0000803F0000803F0000000000000000}
            Align = GLAlBottom
            Name = 'Bottom1'
          end
          item
            TopLeft.Coordinates = {000018420000B8420000000000000000}
            BottomRight.Coordinates = {00002C420000C2420000000000000000}
            Scale.Coordinates = {0000803F0000803F0000000000000000}
            Align = GLAlBottomRight
            Name = 'BottomRight1'
          end>
        Name = 'panel'
      end
      item
        Elements = <
          item
            TopLeft.Coordinates = {00003041000082420000000000000000}
            BottomRight.Coordinates = {000020420000BC420000000000000000}
            Scale.Coordinates = {0000803F0000803F0000000000000000}
            Align = GLAlCenter
            Name = 'center1'
          end
          item
            TopLeft.Coordinates = {00000000000000000000000000000000}
            BottomRight.Coordinates = {000088410000F0410000000000000000}
            Scale.Coordinates = {0000803F0000803F0000000000000000}
            Align = GLAlTopLeft
            Name = 'TopLeft1'
          end
          item
            TopLeft.Coordinates = {00008841000000000000000000000000}
            BottomRight.Coordinates = {0000E0420000F0410000000000000000}
            Scale.Coordinates = {0000803F0000803F0000000000000000}
            Align = GLAlTop
            Name = 'Top1'
          end
          item
            TopLeft.Coordinates = {000000000000F8410000000000000000}
            BottomRight.Coordinates = {000000410000DA420000000000000000}
            Scale.Coordinates = {0000803F0000803F0000000000000000}
            Align = GLAlLeft
            Name = 'Left1'
          end
          item
            TopLeft.Coordinates = {0000E042000000000000000000000000}
            BottomRight.Coordinates = {000000430000F0410000000000000000}
            Scale.Coordinates = {0000803F0000803F0000000000000000}
            Align = GLAlTopRight
            Name = 'TopRight1'
          end
          item
            TopLeft.Coordinates = {0000F0420000F0410000000000000000}
            BottomRight.Coordinates = {000000430000DE420000000000000000}
            Scale.Coordinates = {0000803F0000803F0000000000000000}
            Align = GLAlRight
            Name = 'Right1'
          end
          item
            TopLeft.Coordinates = {000000000000E2420000000000000000}
            BottomRight.Coordinates = {00007041000000430000000000000000}
            Scale.Coordinates = {0000803F0000803F0000000000000000}
            Align = GLAlBottomLeft
            Name = 'BottomLeft1'
          end
          item
            TopLeft.Coordinates = {000070410000F0420000000000000000}
            BottomRight.Coordinates = {0000E242000000430000000000000000}
            Scale.Coordinates = {0000803F0000803F0000000000000000}
            Align = GLAlBottom
            Name = 'Bottom1'
          end
          item
            TopLeft.Coordinates = {0000E2420000E2420000000000000000}
            BottomRight.Coordinates = {00000043000000430000000000000000}
            Scale.Coordinates = {0000803F0000803F0000000000000000}
            Align = GLAlBottomRight
            Name = 'BottomRight1'
          end>
        Name = 'form'
      end
      item
        Elements = <
          item
            TopLeft.Coordinates = {00003041000082420000000000000000}
            BottomRight.Coordinates = {000020420000BC420000000000000000}
            Scale.Coordinates = {0000803F0000803F0000000000000000}
            Align = GLAlCenter
            Name = 'center1'
          end
          item
            TopLeft.Coordinates = {00000041000078420000000000000000}
            BottomRight.Coordinates = {00005041000086420000000000000000}
            Scale.Coordinates = {0000803F0000803F0000000000000000}
            Align = GLAlTopLeft
            Name = 'TopLeft1'
          end
          item
            TopLeft.Coordinates = {00003041000078420000000000000000}
            BottomRight.Coordinates = {00002042000084420000000000000000}
            Scale.Coordinates = {0000803F0000803F0000000000000000}
            Align = GLAlTop
            Name = 'Top1'
          end
          item
            TopLeft.Coordinates = {00000041000082420000000000000000}
            BottomRight.Coordinates = {000040410000BC420000000000000000}
            Scale.Coordinates = {0000803F0000803F0000000000000000}
            Align = GLAlLeft
            Name = 'Left1'
          end
          item
            TopLeft.Coordinates = {00001842000078420000000000000000}
            BottomRight.Coordinates = {00002C42000086420000000000000000}
            Scale.Coordinates = {0000803F0000803F0000000000000000}
            Align = GLAlTopRight
            Name = 'TopRight1'
          end
          item
            TopLeft.Coordinates = {00001C42000082420000000000000000}
            BottomRight.Coordinates = {00002C420000BC420000000000000000}
            Scale.Coordinates = {0000803F0000803F0000000000000000}
            Align = GLAlRight
            Name = 'Right1'
          end
          item
            TopLeft.Coordinates = {000000410000B8420000000000000000}
            BottomRight.Coordinates = {000050410000C2420000000000000000}
            Scale.Coordinates = {0000803F0000803F0000000000000000}
            Align = GLAlBottomLeft
            Name = 'BottomLeft1'
          end
          item
            TopLeft.Coordinates = {000030410000BA420000000000000000}
            BottomRight.Coordinates = {000020420000C2420000000000000000}
            Scale.Coordinates = {0000803F0000803F0000000000000000}
            Align = GLAlBottom
            Name = 'Bottom1'
          end
          item
            TopLeft.Coordinates = {000018420000B8420000000000000000}
            BottomRight.Coordinates = {00002C420000C2420000000000000000}
            Scale.Coordinates = {0000803F0000803F0000000000000000}
            Align = GLAlBottomRight
            Name = 'BottomRight1'
          end>
        Name = 'panel'
      end
      item
        Elements = <
          item
            TopLeft.Coordinates = {00003041000082420000000000000000}
            BottomRight.Coordinates = {000020420000BC420000000000000000}
            Scale.Coordinates = {0000803F0000803F0000000000000000}
            Align = GLAlCenter
            Name = 'center1'
          end
          item
            TopLeft.Coordinates = {00000000000000000000000000000000}
            BottomRight.Coordinates = {000088410000F0410000000000000000}
            Scale.Coordinates = {0000803F0000803F0000000000000000}
            Align = GLAlTopLeft
            Name = 'TopLeft1'
          end
          item
            TopLeft.Coordinates = {00008841000000000000000000000000}
            BottomRight.Coordinates = {0000E0420000F0410000000000000000}
            Scale.Coordinates = {0000803F0000803F0000000000000000}
            Align = GLAlTop
            Name = 'Top1'
          end
          item
            TopLeft.Coordinates = {000000000000F8410000000000000000}
            BottomRight.Coordinates = {000000410000DA420000000000000000}
            Scale.Coordinates = {0000803F0000803F0000000000000000}
            Align = GLAlLeft
            Name = 'Left1'
          end
          item
            TopLeft.Coordinates = {0000E042000000000000000000000000}
            BottomRight.Coordinates = {000000430000F0410000000000000000}
            Scale.Coordinates = {0000803F0000803F0000000000000000}
            Align = GLAlTopRight
            Name = 'TopRight1'
          end
          item
            TopLeft.Coordinates = {0000F0420000F0410000000000000000}
            BottomRight.Coordinates = {000000430000DE420000000000000000}
            Scale.Coordinates = {0000803F0000803F0000000000000000}
            Align = GLAlRight
            Name = 'Right1'
          end
          item
            TopLeft.Coordinates = {000000000000E2420000000000000000}
            BottomRight.Coordinates = {00007041000000430000000000000000}
            Scale.Coordinates = {0000803F0000803F0000000000000000}
            Align = GLAlBottomLeft
            Name = 'BottomLeft1'
          end
          item
            TopLeft.Coordinates = {000070410000F0420000000000000000}
            BottomRight.Coordinates = {0000E242000000430000000000000000}
            Scale.Coordinates = {0000803F0000803F0000000000000000}
            Align = GLAlBottom
            Name = 'Bottom1'
          end
          item
            TopLeft.Coordinates = {0000E2420000E2420000000000000000}
            BottomRight.Coordinates = {00000043000000430000000000000000}
            Scale.Coordinates = {0000803F0000803F0000000000000000}
            Align = GLAlBottomRight
            Name = 'BottomRight1'
          end>
        Name = 'form'
      end
      item
        Elements = <
          item
            TopLeft.Coordinates = {00003041000082420000000000000000}
            BottomRight.Coordinates = {000020420000BC420000000000000000}
            Scale.Coordinates = {0000803F0000803F0000000000000000}
            Align = GLAlCenter
            Name = 'center1'
          end
          item
            TopLeft.Coordinates = {00000041000078420000000000000000}
            BottomRight.Coordinates = {00005041000086420000000000000000}
            Scale.Coordinates = {0000803F0000803F0000000000000000}
            Align = GLAlTopLeft
            Name = 'TopLeft1'
          end
          item
            TopLeft.Coordinates = {00003041000078420000000000000000}
            BottomRight.Coordinates = {00002042000084420000000000000000}
            Scale.Coordinates = {0000803F0000803F0000000000000000}
            Align = GLAlTop
            Name = 'Top1'
          end
          item
            TopLeft.Coordinates = {00000041000082420000000000000000}
            BottomRight.Coordinates = {000040410000BC420000000000000000}
            Scale.Coordinates = {0000803F0000803F0000000000000000}
            Align = GLAlLeft
            Name = 'Left1'
          end
          item
            TopLeft.Coordinates = {00001842000078420000000000000000}
            BottomRight.Coordinates = {00002C42000086420000000000000000}
            Scale.Coordinates = {0000803F0000803F0000000000000000}
            Align = GLAlTopRight
            Name = 'TopRight1'
          end
          item
            TopLeft.Coordinates = {00001C42000082420000000000000000}
            BottomRight.Coordinates = {00002C420000BC420000000000000000}
            Scale.Coordinates = {0000803F0000803F0000000000000000}
            Align = GLAlRight
            Name = 'Right1'
          end
          item
            TopLeft.Coordinates = {000000410000B8420000000000000000}
            BottomRight.Coordinates = {000050410000C2420000000000000000}
            Scale.Coordinates = {0000803F0000803F0000000000000000}
            Align = GLAlBottomLeft
            Name = 'BottomLeft1'
          end
          item
            TopLeft.Coordinates = {000030410000BA420000000000000000}
            BottomRight.Coordinates = {000020420000C2420000000000000000}
            Scale.Coordinates = {0000803F0000803F0000000000000000}
            Align = GLAlBottom
            Name = 'Bottom1'
          end
          item
            TopLeft.Coordinates = {000018420000B8420000000000000000}
            BottomRight.Coordinates = {00002C420000C2420000000000000000}
            Scale.Coordinates = {0000803F0000803F0000000000000000}
            Align = GLAlBottomRight
            Name = 'BottomRight1'
          end>
        Name = 'panel'
      end
      item
        Elements = <
          item
            TopLeft.Coordinates = {00003041000082420000000000000000}
            BottomRight.Coordinates = {000020420000BC420000000000000000}
            Scale.Coordinates = {0000803F0000803F0000000000000000}
            Align = GLAlCenter
            Name = 'center1'
          end
          item
            TopLeft.Coordinates = {00000000000000000000000000000000}
            BottomRight.Coordinates = {000088410000F0410000000000000000}
            Scale.Coordinates = {0000803F0000803F0000000000000000}
            Align = GLAlTopLeft
            Name = 'TopLeft1'
          end
          item
            TopLeft.Coordinates = {00008841000000000000000000000000}
            BottomRight.Coordinates = {0000E0420000F0410000000000000000}
            Scale.Coordinates = {0000803F0000803F0000000000000000}
            Align = GLAlTop
            Name = 'Top1'
          end
          item
            TopLeft.Coordinates = {000000000000F8410000000000000000}
            BottomRight.Coordinates = {000000410000DA420000000000000000}
            Scale.Coordinates = {0000803F0000803F0000000000000000}
            Align = GLAlLeft
            Name = 'Left1'
          end
          item
            TopLeft.Coordinates = {0000E042000000000000000000000000}
            BottomRight.Coordinates = {000000430000F0410000000000000000}
            Scale.Coordinates = {0000803F0000803F0000000000000000}
            Align = GLAlTopRight
            Name = 'TopRight1'
          end
          item
            TopLeft.Coordinates = {0000F0420000F0410000000000000000}
            BottomRight.Coordinates = {000000430000DE420000000000000000}
            Scale.Coordinates = {0000803F0000803F0000000000000000}
            Align = GLAlRight
            Name = 'Right1'
          end
          item
            TopLeft.Coordinates = {000000000000E2420000000000000000}
            BottomRight.Coordinates = {00007041000000430000000000000000}
            Scale.Coordinates = {0000803F0000803F0000000000000000}
            Align = GLAlBottomLeft
            Name = 'BottomLeft1'
          end
          item
            TopLeft.Coordinates = {000070410000F0420000000000000000}
            BottomRight.Coordinates = {0000E242000000430000000000000000}
            Scale.Coordinates = {0000803F0000803F0000000000000000}
            Align = GLAlBottom
            Name = 'Bottom1'
          end
          item
            TopLeft.Coordinates = {0000E2420000E2420000000000000000}
            BottomRight.Coordinates = {00000043000000430000000000000000}
            Scale.Coordinates = {0000803F0000803F0000000000000000}
            Align = GLAlBottomRight
            Name = 'BottomRight1'
          end>
        Name = 'form'
      end
      item
        Elements = <
          item
            TopLeft.Coordinates = {00003041000082420000000000000000}
            BottomRight.Coordinates = {000020420000BC420000000000000000}
            Scale.Coordinates = {0000803F0000803F0000000000000000}
            Align = GLAlCenter
            Name = 'center1'
          end
          item
            TopLeft.Coordinates = {00000041000078420000000000000000}
            BottomRight.Coordinates = {00005041000086420000000000000000}
            Scale.Coordinates = {0000803F0000803F0000000000000000}
            Align = GLAlTopLeft
            Name = 'TopLeft1'
          end
          item
            TopLeft.Coordinates = {00003041000078420000000000000000}
            BottomRight.Coordinates = {00002042000084420000000000000000}
            Scale.Coordinates = {0000803F0000803F0000000000000000}
            Align = GLAlTop
            Name = 'Top1'
          end
          item
            TopLeft.Coordinates = {00000041000082420000000000000000}
            BottomRight.Coordinates = {000040410000BC420000000000000000}
            Scale.Coordinates = {0000803F0000803F0000000000000000}
            Align = GLAlLeft
            Name = 'Left1'
          end
          item
            TopLeft.Coordinates = {00001842000078420000000000000000}
            BottomRight.Coordinates = {00002C42000086420000000000000000}
            Scale.Coordinates = {0000803F0000803F0000000000000000}
            Align = GLAlTopRight
            Name = 'TopRight1'
          end
          item
            TopLeft.Coordinates = {00001C42000082420000000000000000}
            BottomRight.Coordinates = {00002C420000BC420000000000000000}
            Scale.Coordinates = {0000803F0000803F0000000000000000}
            Align = GLAlRight
            Name = 'Right1'
          end
          item
            TopLeft.Coordinates = {000000410000B8420000000000000000}
            BottomRight.Coordinates = {000050410000C2420000000000000000}
            Scale.Coordinates = {0000803F0000803F0000000000000000}
            Align = GLAlBottomLeft
            Name = 'BottomLeft1'
          end
          item
            TopLeft.Coordinates = {000030410000BA420000000000000000}
            BottomRight.Coordinates = {000020420000C2420000000000000000}
            Scale.Coordinates = {0000803F0000803F0000000000000000}
            Align = GLAlBottom
            Name = 'Bottom1'
          end
          item
            TopLeft.Coordinates = {000018420000B8420000000000000000}
            BottomRight.Coordinates = {00002C420000C2420000000000000000}
            Scale.Coordinates = {0000803F0000803F0000000000000000}
            Align = GLAlBottomRight
            Name = 'BottomRight1'
          end>
        Name = 'panel'
      end
      item
        Elements = <
          item
            TopLeft.Coordinates = {00003041000082420000000000000000}
            BottomRight.Coordinates = {000020420000BC420000000000000000}
            Scale.Coordinates = {0000803F0000803F0000000000000000}
            Align = GLAlCenter
            Name = 'center1'
          end
          item
            TopLeft.Coordinates = {00000000000000000000000000000000}
            BottomRight.Coordinates = {000088410000F0410000000000000000}
            Scale.Coordinates = {0000803F0000803F0000000000000000}
            Align = GLAlTopLeft
            Name = 'TopLeft1'
          end
          item
            TopLeft.Coordinates = {00008841000000000000000000000000}
            BottomRight.Coordinates = {0000E0420000F0410000000000000000}
            Scale.Coordinates = {0000803F0000803F0000000000000000}
            Align = GLAlTop
            Name = 'Top1'
          end
          item
            TopLeft.Coordinates = {000000000000F8410000000000000000}
            BottomRight.Coordinates = {000000410000DA420000000000000000}
            Scale.Coordinates = {0000803F0000803F0000000000000000}
            Align = GLAlLeft
            Name = 'Left1'
          end
          item
            TopLeft.Coordinates = {0000E042000000000000000000000000}
            BottomRight.Coordinates = {000000430000F0410000000000000000}
            Scale.Coordinates = {0000803F0000803F0000000000000000}
            Align = GLAlTopRight
            Name = 'TopRight1'
          end
          item
            TopLeft.Coordinates = {0000F0420000F0410000000000000000}
            BottomRight.Coordinates = {000000430000DE420000000000000000}
            Scale.Coordinates = {0000803F0000803F0000000000000000}
            Align = GLAlRight
            Name = 'Right1'
          end
          item
            TopLeft.Coordinates = {000000000000E2420000000000000000}
            BottomRight.Coordinates = {00007041000000430000000000000000}
            Scale.Coordinates = {0000803F0000803F0000000000000000}
            Align = GLAlBottomLeft
            Name = 'BottomLeft1'
          end
          item
            TopLeft.Coordinates = {000070410000F0420000000000000000}
            BottomRight.Coordinates = {0000E242000000430000000000000000}
            Scale.Coordinates = {0000803F0000803F0000000000000000}
            Align = GLAlBottom
            Name = 'Bottom1'
          end
          item
            TopLeft.Coordinates = {0000E2420000E2420000000000000000}
            BottomRight.Coordinates = {00000043000000430000000000000000}
            Scale.Coordinates = {0000803F0000803F0000000000000000}
            Align = GLAlBottomRight
            Name = 'BottomRight1'
          end>
        Name = 'form'
      end
      item
        Elements = <
          item
            TopLeft.Coordinates = {00003041000082420000000000000000}
            BottomRight.Coordinates = {000020420000BC420000000000000000}
            Scale.Coordinates = {0000803F0000803F0000000000000000}
            Align = GLAlCenter
            Name = 'center1'
          end
          item
            TopLeft.Coordinates = {00000041000078420000000000000000}
            BottomRight.Coordinates = {00005041000086420000000000000000}
            Scale.Coordinates = {0000803F0000803F0000000000000000}
            Align = GLAlTopLeft
            Name = 'TopLeft1'
          end
          item
            TopLeft.Coordinates = {00003041000078420000000000000000}
            BottomRight.Coordinates = {00002042000084420000000000000000}
            Scale.Coordinates = {0000803F0000803F0000000000000000}
            Align = GLAlTop
            Name = 'Top1'
          end
          item
            TopLeft.Coordinates = {00000041000082420000000000000000}
            BottomRight.Coordinates = {000040410000BC420000000000000000}
            Scale.Coordinates = {0000803F0000803F0000000000000000}
            Align = GLAlLeft
            Name = 'Left1'
          end
          item
            TopLeft.Coordinates = {00001842000078420000000000000000}
            BottomRight.Coordinates = {00002C42000086420000000000000000}
            Scale.Coordinates = {0000803F0000803F0000000000000000}
            Align = GLAlTopRight
            Name = 'TopRight1'
          end
          item
            TopLeft.Coordinates = {00001C42000082420000000000000000}
            BottomRight.Coordinates = {00002C420000BC420000000000000000}
            Scale.Coordinates = {0000803F0000803F0000000000000000}
            Align = GLAlRight
            Name = 'Right1'
          end
          item
            TopLeft.Coordinates = {000000410000B8420000000000000000}
            BottomRight.Coordinates = {000050410000C2420000000000000000}
            Scale.Coordinates = {0000803F0000803F0000000000000000}
            Align = GLAlBottomLeft
            Name = 'BottomLeft1'
          end
          item
            TopLeft.Coordinates = {000030410000BA420000000000000000}
            BottomRight.Coordinates = {000020420000C2420000000000000000}
            Scale.Coordinates = {0000803F0000803F0000000000000000}
            Align = GLAlBottom
            Name = 'Bottom1'
          end
          item
            TopLeft.Coordinates = {000018420000B8420000000000000000}
            BottomRight.Coordinates = {00002C420000C2420000000000000000}
            Scale.Coordinates = {0000803F0000803F0000000000000000}
            Align = GLAlBottomRight
            Name = 'BottomRight1'
          end>
        Name = 'panel'
      end>
    FileName = '..\..\media\default.layout'
    Left = 176
    Top = 16
  end
  object GLMaterialLibrary1: TGLMaterialLibrary
    Materials = <
      item
        Name = 'Gui'
        Material.Texture.ImageClassName = 'TGLPicFileImage'
        Material.Texture.Image.PictureFileName = '..\..\media\DefaultSkin.bmp'
        Material.Texture.ImageAlpha = tiaOpaque
        Material.Texture.Disabled = False
        Tag = 0
      end>
    Left = 144
    Top = 16
  end
end
