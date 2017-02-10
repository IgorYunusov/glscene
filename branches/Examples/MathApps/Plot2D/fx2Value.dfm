object fx2ValueForm: Tfx2ValueForm
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  ClientHeight = 264
  ClientWidth = 497
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'Tahoma'
  Font.Style = []
  FormStyle = fsStayOnTop
  Icon.Data = {
    0000010001003030100001000400680600001600000028000000300000006000
    0000010004000000000000000000000000000000000000000000000000000000
    000000008000008000000080800080000000800080008080000080808000C0C0
    C0000000FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF000000
    0000000000000000000000000000000000000000000000000000000000000000
    0000000000000000000000000000000000000000000000000000000000000000
    0000000000000000000000000000000000000000000000000000008000000000
    0000000000000000000000000000000000000888000000000000000000000000
    0000000000000000000088888000000000000000000000000000000000000000
    0008888800000000000000000000000000000000000000000088888000000000
    0000000000000000000000000000000008888800000000000000000000000000
    0000000000000000888880000000000000000000000000000000000000000008
    8888000000000000000000000000000000000000000000888880000000000000
    0000000000000000000000000000088888000000000000000000000000000000
    0000000000008888800000000000000000000000000000000000000000088888
    0000000000000000000000000000000000000000008888800000000000000000
    0000000000000000000000000888880000000000000000000000000007777770
    0000000088888000000000000000000000000077788888877700000888880000
    0000000000000000000077888FFFFFF888770088888000000000000000000000
    000788FFFFFFFFFEE88878888800000000000000000000000078FFFFFFFFFFFF
    FEEE8788800000000000000000000000078FFFFFFFFFFFFFFFFFE87800000000
    000000000000000078FFFFFFFFFFFFFFFFFFFE87000000000000000000000007
    8FFFFFFFFFFFFFFFFFFFFFE87000000000000000000000078FFFFFFFFFFFFFFF
    FFFFFFE8700000000000000000000078FFFFFFFFFFFFFFFFFFFFFFFE87000000
    0000000000000078FFFFFFFFFFFFFFFFFFFFFFFE870000000000000000000078
    FFFFFFFFFFFFFFFFFFFFFFFE87000000000000000000078FFFFFFFFFFFFFFFFF
    FFFFFFFE87000000000000000000078FFFFFFFFFFFFFFFFFFFFFFFFEE8700000
    000000000000078FFFFFFFFFFFFFFFFFFFFFFFFEE8700000000000000000078F
    FFFFFFFFFFFFFFFFFFFFFFFEE8700000000000000000078FFFFFFFFFFFFFFFFF
    FFFFFFFEE8700000000000000000078FFFFFFFFFFFFFFFFFFFFFFFFE87000000
    0000000000000078FFFFFFFFFFFFFFFFFFFFFFFE870000000000000000000078
    FFFFFFFFFFFFFFFFFFFFFFEE870000000000000000000078FFFFFFFFFFFFFFFF
    FFFFFFEE8700000000000000000000078FFFFFFFFFFFFFFFFFFFFEE870000000
    00000000000000078FFFFFFFFFFFFFFFFFFFFEE8700000000000000000000000
    78FFFFFFFFFFFFFFFFFFEE87000000000000000000000000078EEFFFFFFFFFFF
    FFEEE8700000000000000000000000000078EEEFFFFFFFFFEEEE870000000000
    0000000000000000000788EEEEEEEEEEEE887000000000000000000000000000
    000077888EEEEEE8887700000000000000000000000000000000007778888887
    7700000000000000000000000000000000000000077777700000000000000000
    000000000000000000000000000000000000000000000000000000000000FFFF
    FFFFFFFF0000FFFFFFFFFFFF0000FFFFFFFFFF8F0000FFFFFFFFFF070000FFFF
    FFFFFE030000FFFFFFFFFC030000FFFFFFFFF8030000FFFFFFFFF0070000FFFF
    FFFFE00F0000FFFFFFFFC01F0000FFFFFFFF803F0000FFFFFFFF007F0000FFFF
    FFFE00FF0000FFFFFFFC01FF0000FFFFFFF803FF0000FFFFFFF007FF0000FFFF
    FFE00FFF0000FFF81FC01FFF0000FFC003803FFF0000FF0000007FFF0000FE00
    0000FFFF0000FC000001FFFF0000F8000003FFFF0000F0000007FFFF0000E000
    0007FFFF0000E0000007FFFF0000C0000003FFFF0000C0000003FFFF0000C000
    0003FFFF000080000003FFFF000080000001FFFF000080000001FFFF00008000
    0001FFFF000080000001FFFF000080000003FFFF0000C0000003FFFF0000C000
    0003FFFF0000C0000003FFFF0000E0000007FFFF0000E0000007FFFF0000F000
    000FFFFF0000F800001FFFFF0000FC00003FFFFF0000FE00007FFFFF0000FF00
    00FFFFFF0000FFC003FFFFFF0000FFF81FFFFFFF0000FFFFFFFFFFFF0000}
  OldCreateOrder = False
  ShowHint = True
  OnActivate = FormActivate
  OnCloseQuery = FormCloseQuery
  OnDestroy = FormDestroy
  OnDeactivate = FormDeactivate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 16
  object Label1: TLabel
    Left = 28
    Top = 8
    Width = 201
    Height = 16
    Caption = 'Find values for x, given f"(x) = '
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clMaroon
    Font.Height = -13
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label2: TLabel
    Left = 99
    Top = 36
    Width = 6
    Height = 16
    Caption = 'x'
  end
  object Label3: TLabel
    Left = 306
    Top = 36
    Width = 25
    Height = 16
    Caption = 'f"(x)'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object RecalcBtn: TBitBtn
    Left = 120
    Top = 216
    Width = 99
    Height = 28
    Cursor = crHandPoint
    Hint = 'Calculate values for x for current function '
    Caption = '&Recalculate'
    Default = True
    DoubleBuffered = True
    Glyph.Data = {
      F6000000424DF600000000000000760000002800000010000000100000000100
      04000000000080000000000000000000000010000000100000004646FF00FF91
      9F00FF91AF00FF91BD00FF91D900FF91F700FF91FF00FF91FF00FFAD9F00FFD2
      9F00FFE99F00FFFF9F00FFFF9F00FFFF9F00FFFF9F00FFB8FF00BFFFFFFFFF77
      777BFFFFFFF777777766FFF7000000066666F770077666005555770766665554
      4444700665554444422260555444333222885044433322188888403332218880
      099930211888890000AA200889999000000A880999AAAAA00AAA9900AAAAAA00
      0AAAAAA000000000AAAAAAAAA00000AAAAAABAAAAAAAAAAAAAAB}
    ParentDoubleBuffered = False
    ParentShowHint = False
    ShowHint = True
    TabOrder = 0
    OnClick = RecalcBtnClick
  end
  object Editfx2: TEdit
    Left = 225
    Top = 5
    Width = 218
    Height = 24
    Hint = 'Enter the value of f"(x) required '
    TabOrder = 1
    OnKeyPress = Editfx2KeyPress
    OnKeyUp = Editfx2KeyUp
  end
  object CloseBtn: TBitBtn
    Left = 263
    Top = 216
    Width = 99
    Height = 28
    Cursor = crHandPoint
    Hint = 'Close'
    Caption = '&Close'
    DoubleBuffered = True
    Glyph.Data = {
      36040000424D3604000000000000360000002800000010000000100000000100
      2000000000000004000000000000000000000000000000000000FF00FF00FF00
      FF00000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00000000000000800000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FF
      FF0000FFFF0000FFFF0000000000FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF0000000000000080000000800000FFFF0000FFFF0000FFFF0000FFFF0000FF
      FF0000FFFF0000FFFF0000000000FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF000000000000008000000080000000800000FFFF0000FFFF0000FFFF0000FF
      FF0000FFFF0000FFFF0000000000FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00000000000000800000008000000080000000000000FFFF0000FFFF0000FF
      FF0000FFFF0000FFFF0000000000FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00000000000000800000008000000080000000000000FFFF0000FFFF0000FF
      FF0000FFFF0000FFFF0000000000FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00000000000000800000008000000080000000000000FFFF0000FFFF0000FF
      FF0000FFFF0000FFFF0000000000FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00000000000000800000008000000080000000000000FFFF0000FFFF0000FF
      FF0000FFFF0000FFFF0000000000FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00000000000000800000008000000080000000000000FFFF0000FFFF0000FF
      FF0000FFFF0000FFFF0000000000FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00000000000000800000008000000080000000000000FFFF0000FFFF0000FF
      FF0000FFFF0000FFFF0000000000FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF000000000000008000000080000000800000FFFF000000000000FFFF0000FF
      FF0000FFFF0000FFFF0000000000FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00000000000000800000008000000080000000000000FFFF0000FFFF0000FF
      FF0000FFFF0000FFFF0000000000FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00000000000000800000008000000080000000000000FFFF0000FFFF0000FF
      FF0000FFFF0000FFFF0000000000FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF000000000000008000FFFF0000000080000000000000FFFF0000FFFF0000FF
      FF0000FFFF0000FFFF0000000000FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF000000000000008000FFFF0000FFFF00000000000000FFFF0000FFFF0000FF
      FF0000FFFF0000FFFF0000000000FF00FF00FF00FF00FF00FF00FF00FF00FF00
      FF00000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000FF00FF00FF00FF00FF00FF00}
    ParentDoubleBuffered = False
    TabOrder = 2
    OnClick = CloseBtnClick
  end
  object ListBox1: TListBox
    Left = 8
    Top = 58
    Width = 481
    Height = 143
    Hint = 'Click to copy x value to clipboard'
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = 'Courier New'
    Font.Style = []
    ItemHeight = 17
    ParentFont = False
    TabOrder = 3
    OnClick = ListBox1Click
  end
end
