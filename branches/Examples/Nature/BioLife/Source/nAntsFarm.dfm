object AntsForm: TAntsForm
  Left = 543
  Top = 126
  Hint = 'Ants picnic farm'
  HelpContext = 7000
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'Ants'
  ClientHeight = 230
  ClientWidth = 242
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  Icon.Data = {
    0000010001002020100000000000E80200001600000028000000200000004000
    0000010004000000000080020000000000000000000000000000000000000000
    0000000080000080000000808000800000008000800080800000C0C0C0008080
    80000000FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00FFFF
    FF22FFFFCCFF99FF222222FFCCFFFFFFFF22FFFFCCFF99FF222222FFCCFFFFFF
    FFFFFFFFCCCCFFFFFFFFFFFFCCCCFFFFFFFFFFFFCCCCFFFFFFFFFFFFCCCCCCCC
    CCCCCCFFFFCCFF22FFFFFFFFFFFFCCCCCCCCCCFFFFCCFF22FFFFFFFFFFFFCCFF
    FFCCCCFFFFFFFF22FFBBBBBBFFFFCCFFFFCCCCFFFFFFFF22FFBBBBBBFFFFFFFF
    22FFFFCCCCFFFFFFFFBBFFBBFFFFFFFF22FFFFCCCCFFFFFFFFBBFFBBFFFFFFFF
    FFFF99FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF99FFFFFFFFFFFFFFFFFFFFFFFFFF
    FFFFFFCCFFFFFFFF99FFFFCCCCFFFFFFFFFFFFCCFFFFFFFF99FFFFCCCCFFFFFF
    CCCCFFCCFFCCFFFFFFFFCCCCFFFFFFFFCCCCFFCCFFCCFFFFFFFFCCCCFFFFCCCC
    FFFFFFFFFFCCCCCCFFCCCCCCFFFFCCCCFFFFFFFFFFCCCCCCFFCCCCCCFFFFFFFF
    FFBBBBBBFFFFFFFFCCCCCCFFFFFFFFFFFFBBBBBBFFFFFFFFCCCCCCFFFFFFFFFF
    FFFFFFBBFFFFFFCCCCFFCCFFBBBBFFFFFFFFFFBBFFFFFFCCCCFFCCFFBBBBFFFF
    FFFFFFFFFFFFFFFFFFFFFFFFFFBBFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFBBFFFF
    FFFFFFFFFFFFFF22FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF22FFFFFFFFFFFFFFFF
    FFFFFF22FFFF99FFFFCCCCCCCCFFFFFFFFFFFF22FFFF99FFFFCCCCCCCCFFFFFF
    FFFF99FFFF22FFCCCCCCFFCCFFFFFFFFFFFF99FFFF22FFCCCCCCFFCCFFFFFFFF
    FFFFFFFFFFFFFFFFFFCCFFFFFF99FFFFFFFFFFFFFFFFFFFFFFCCFFFFFF990000
    0000000000000000000000000000000000000000000000000000000000000000
    0000000000000000000000000000000000000000000000000000000000000000
    0000000000000000000000000000000000000000000000000000000000000000
    000000000000000000000000000000000000000000000000000000000000}
  OldCreateOrder = False
  ShowHint = True
  OnClose = FormClose
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object AntsPanel: TPanel
    Left = 90
    Top = 0
    Width = 150
    Height = 230
    TabOrder = 0
    object Image1: TImage
      Left = 1
      Top = 1
      Width = 148
      Height = 228
      Hint = 'Left quit, Right Save'
      OnMouseUp = Image1MouseUp
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 0
    Width = 90
    Height = 230
    Hint = 'Ant farm'
    HelpContext = 7000
    Align = alLeft
    TabOrder = 1
    object HelpBtn: TSpeedButton
      Left = 12
      Top = 168
      Width = 23
      Height = 25
      Hint = 'Help or F1 something'
      Glyph.Data = {
        BE060000424DBE06000000000000360400002800000024000000120000000100
        0800000000008802000000000000000000000001000000000000000000000000
        BF0000BF000000BFBF00BF000000BF00BF00BFBF0000C0C0C000C0DCC000F0C8
        A400000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000000
        000000000000000000000000000000000000F0FBFF00A4A0A000808080000000
        FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00030303030303
        03030606030303030303030303030303030303FFFF0303030303030303030303
        0303030303060404060303030303030303030303030303F8F8FF030303030303
        030303030303030303FE06060403030303030303030303030303F8FF03F8FF03
        0303030303030303030303030303FE060603030303030303030303030303F8FF
        FFF8FF0303030303030303030303030303030303030303030303030303030303
        030303F8F8030303030303030303030303030303030304040603030303030303
        0303030303030303FFFF03030303030303030303030303030306060604030303
        0303030303030303030303F8F8F8FF0303030303030303030303030303FE0606
        0403030303030303030303030303F8FF03F8FF03030303030303030303030303
        03FE06060604030303030303030303030303F8FF03F8FF030303030303030303
        030303030303FE060606040303030303030303030303F8FF0303F8FF03030303
        0303030303030303030303FE060606040303030303030303030303F8FF0303F8
        FF030303030303030303030404030303FE060606040303030303030303FF0303
        F8FF0303F8FF030303030303030306060604030303FE06060403030303030303
        F8F8FF0303F8FF0303F8FF03030303030303FE06060604040406060604030303
        030303F8FF03F8FFFFFFF80303F8FF0303030303030303FE0606060606060606
        06030303030303F8FF0303F8F8F8030303F8FF030303030303030303FEFE0606
        060606060303030303030303F8FFFF030303030303F803030303030303030303
        0303FEFEFEFEFE03030303030303030303F8F8FFFFFFFFFFF803030303030303
        0303030303030303030303030303030303030303030303F8F8F8F8F803030303
        0303}
      NumGlyphs = 2
      OnClick = HelpBtnClick
    end
    object Label3: TLabel
      Left = 4
      Top = 48
      Width = 59
      Height = 13
      Caption = 'Picnic % Full'
    end
    object Label4: TLabel
      Left = 40
      Top = 8
      Width = 27
      Height = 13
      Caption = '% Full'
    end
    object Label2: TLabel
      Left = 4
      Top = 8
      Width = 21
      Height = 13
      Caption = 'Ants'
    end
    object AntsCB: TCheckBox
      Left = 40
      Top = 170
      Width = 41
      Height = 17
      Hint = 'Where was i'
      HelpContext = 7000
      Caption = 'Ants'
      Checked = True
      State = cbChecked
      TabOrder = 0
    end
    object AntsizeRG: TRadioGroup
      Left = 2
      Top = 88
      Width = 87
      Height = 73
      Hint = 'sorta screen size'
      HelpContext = 7000
      Caption = 'Ant Farm Size'
      ItemIndex = 0
      Items.Strings = (
        '148x228'
        '540x452'
        '135x113@4'
        '179x143@4')
      TabOrder = 1
    end
    object AntChipPerEdit: TEdit
      Left = 48
      Top = 64
      Width = 33
      Height = 21
      Hint = 'limitation'
      HelpContext = 7000
      Color = clMenu
      TabOrder = 2
      Text = '20'
    end
    object AntsPerEdit: TEdit
      Left = 48
      Top = 24
      Width = 33
      Height = 21
      Hint = 'limitation'
      HelpContext = 7000
      Color = clMenu
      TabOrder = 3
      Text = '20'
    end
    object AntsEdit: TEdit
      Left = 4
      Top = 24
      Width = 33
      Height = 21
      Hint = 'how many'
      HelpContext = 7000
      TabOrder = 4
      Text = '20'
    end
    object AntChipEdit: TEdit
      Left = 4
      Top = 64
      Width = 33
      Height = 21
      Hint = 'food'
      HelpContext = 7000
      TabOrder = 5
      Text = '20'
    end
    object AntsOkBtn: TButton
      Left = 48
      Top = 200
      Width = 35
      Height = 25
      Hint = 'Ants rule'
      HelpContext = 7000
      Caption = 'Go'
      TabOrder = 6
      OnClick = AntsOKBtnClick
    end
    object CancelBtn: TButton
      Left = 8
      Top = 200
      Width = 33
      Height = 25
      Hint = 'picnics over'
      HelpContext = 7000
      Caption = 'Stop'
      TabOrder = 7
      OnClick = CancelBitBtnClick
    end
  end
  object SaveDialog1: TSaveDialog
    Left = 184
    Top = 80
  end
end