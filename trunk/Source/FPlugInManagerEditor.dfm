object PlugInManagerEditor: TPlugInManagerEditor
  Left = 371
  Top = 143
  BorderIcons = []
  BorderStyle = bsSizeToolWin
  Caption = 'Plug-in registration :'
  ClientHeight = 429
  ClientWidth = 496
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  Icon.Data = {
    0000010001001010000000000000680500001600000028000000100000002000
    000001000800000000004001000000000000000000000001000000000000D0E8
    ED00FFFFFF00ACEEEE00BBF2F200B2FFFF00A6D2D20097F5F5009AE6E6008BF5
    F50081F5F50087F7F70087F6F60087F5F50086F5F50086F4F40086F3F30085F3
    F30085F2F20085F1F10084F1F10084F0F0008BE7E70084EDED0084EFEF0083EF
    EF0083EEEE0083EDED0082EDED0082ECEC0083E8E80081EBEB0081EAEA0080E9
    E90080E8E8008ED1D100879B9B00BFBFBF00A4B7B70090A8AE0098B7B7008BB3
    B3008DBABA0083BABA0085BFBF0083B5B50068E6E60076F5F50079EAEA007FE7
    E7007FE6E6007EE5E5007EE4E4007DE3E3007DE2E2007DE0E0007CE1E1007CE0
    E0007BE0E00066F4F4006CCCCC007BDFDF007BDEDE007ADEDE007ADDDD007ADC
    DC0079DCDC0078DADA0079DBDB0079DADA0078D8D80078D9D90070DCDC0077D8
    D80073D0D00075D4D40076D6D60077D7D70076D5D50053E8E8005BF4F40050D3
    D3004FB0C7004BACC3004CADC4004AA9C0004AABC20078ADAD007AB5B5007ABA
    BA0073B5B5006DBABA006BB5B50064B9B90064B5B50062B2B20061B1B10069A9
    A90064ADAD0060AEAE00728D8D0059B8B80054B4B40050A5A5005EACAC005DAA
    AA005AA3A30047BABA004CB3B30044B4B40048A6BD004AA8BF0046A4BB0047A6
    BD0044A2B80045A3BA0042A1B60042A1B50046A8A800509595003EE1E10033CB
    CB0039B8B80033B5B50038AAAA0028BABA002BB4B40024B5B50028A9A9003C9B
    B0003E9EB2003D9EB2003897AB003B9BAF003A99AD003695A9003796AA003594
    A8003592A6003693A7003692A600348FA300338EA200338DA1002F9191003A83
    9400328C9F00328B9E00318A9C00308799003780910030849600318294002F82
    940018BABA001CB3B30015B4B40019A5A500128A8A00377F900031788700367D
    8E00337A8B002C798B002E7D8F002E7A8C002C768600297382004B5E63007F7F
    7F00607B7B00536B7100537979005E787800597F7F005E7676005C6D6D00526D
    6D0050686E004B7777004C797900437A7A004279790042777700417676004075
    75004C6669004C646900565C5C0046565800397A7A00397575003D7070003F72
    72003E7171003F6A70003A6469003C6A6C003C6E6E0032646A00316369003062
    66002A78780028707F00266A7800266C7B00276D7C00276F7E00266B7A002465
    720024667300226E6E002E61660024616E00385E6300225662002C5D6200225D
    6A0027586300215966002F4D4E0035585B002A565A0022515B0023525E002251
    5D0027484900167070001F5461001D515D001D4F59001C4B55001B4B55001A4A
    540019465000134B4B0019424C0019454F000A595900163D4500143A42003F3F
    3F00283E3E000B3A3A001735380012343C00112D330012282A000F2E33000000
    00000E292E000D252A000A1C2100050E110008191C000611130002070800F8F8
    F8F8F8F8F8F8F8002229F8F8F8F8F8F8F8F8F8F8F8033D3D4B8305F8F8F8F8F8
    F8F8F8023C4A3C3C3D712BF8F8F8F8F80007343B6D3B22343C6468F8F8F8F800
    34303B5515040404153B89F8F8F8F8F8343C743B04040404024B8900F8F8F8F8
    155C8D070404040404348305F8F8F8F8026B85040404023B0215702BF8F8F8F8
    03546D150204045A04076461F8F8F8F80051743B2204040404153B89F8F8F8F8
    003B8D02040404040430478900F8F8F8F8309758040404040230308905F8F8F8
    F8075CCC07040404163034742BF8F8F8F802105CC669071616344A5800F8F8F8
    F803171717343D050500F8F8F8F8F8F8F80007050000F8F8F8F8F8F8F8F8FF8F
    FFFFFE07FFFFF807FFFFC007FFFF8007FFFFC003FFFFC003FFFFC003FFFFC003
    FFFFC003FFFFC001FFFFE001FFFFE001FFFFE001FFFFE00FFFFFE0FFFFFF}
  OldCreateOrder = True
  PixelsPerInch = 96
  TextHeight = 16
  object Label1: TLabel
    Left = 8
    Top = 31
    Width = 124
    Height = 16
    Caption = 'Registered Plug-ins :'
  end
  object Label2: TLabel
    Left = 17
    Top = 272
    Width = 82
    Height = 16
    Caption = 'Ceation date :'
  end
  object Label3: TLabel
    Left = 17
    Top = 303
    Width = 55
    Height = 16
    Caption = 'File size :'
  end
  object DateLabel: TLabel
    Left = 113
    Top = 272
    Width = 21
    Height = 16
    Caption = '???'
    Enabled = False
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clTeal
    Font.Height = -13
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
  end
  object SizeLabel: TLabel
    Left = 113
    Top = 304
    Width = 21
    Height = 16
    Caption = '???'
    Enabled = False
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clTeal
    Font.Height = -13
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
  end
  object Label4: TLabel
    Left = 233
    Top = 272
    Width = 59
    Height = 16
    Caption = 'Services :'
  end
  object Label5: TLabel
    Left = 233
    Top = 304
    Width = 47
    Height = 16
    Caption = 'Names:'
  end
  object ListBox: TListBox
    Left = 8
    Top = 53
    Width = 473
    Height = 204
    MultiSelect = True
    Sorted = True
    TabOrder = 0
    OnClick = ListBoxClick
  end
  object GroupBox: TGroupBox
    Left = 0
    Top = 347
    Width = 496
    Height = 82
    Align = alBottom
    Caption = 'Description : '
    TabOrder = 1
    object DescriptionMemo: TMemo
      Left = 17
      Top = 24
      Width = 449
      Height = 97
      BorderStyle = bsNone
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clTeal
      Font.Height = -13
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentColor = True
      ParentFont = False
      ReadOnly = True
      TabOrder = 0
    end
  end
  object ServiceBox: TComboBox
    Left = 297
    Top = 268
    Width = 184
    Height = 24
    Style = csDropDownList
    Ctl3D = True
    Enabled = False
    ParentCtl3D = False
    TabOrder = 2
    OnChange = ServiceBoxChange
  end
  object NameBox: TComboBox
    Left = 297
    Top = 300
    Width = 184
    Height = 24
    Style = csDropDownList
    Enabled = False
    TabOrder = 3
  end
  object ToolBar1: TToolBar
    Left = 0
    Top = 0
    Width = 496
    Height = 29
    Caption = 'ToolBar'
    Images = ImageList
    TabOrder = 4
    object ToolButton1: TToolButton
      Left = 0
      Top = 0
      Caption = 'ToolButtonLoad'
      ImageIndex = 0
      OnClick = LoadButtonClick
    end
    object ToolButton2: TToolButton
      Left = 23
      Top = 0
      Caption = 'ToolButton2'
      ImageIndex = 1
      OnClick = UnloadButtonClick
    end
    object ToolButton3: TToolButton
      Left = 46
      Top = 0
      Caption = 'ToolButton3'
      ImageIndex = 2
      OnClick = OKButtonClick
    end
  end
  object OpenDialog: TOpenDialog
    Filter = 'GLScene plug-ins (*.DLL)|*.DLL|all files (*.*)|*.*'
    Options = [ofHideReadOnly, ofAllowMultiSelect, ofPathMustExist, ofFileMustExist]
    Left = 56
    Top = 120
  end
  object ImageList: TImageList
    Left = 168
    Top = 128
    Bitmap = {
      494C0101030008003C0010001000FFFFFFFFFF10FFFFFFFFFFFFFFFF424D3600
      0000000000003600000028000000400000001000000001002000000000000010
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
      000000FFFF00C0C0C00000FFFF00C0C0C00000FFFF00C0C0C00000FFFF00C0C0
      C00000FFFF000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000FF0000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000FFFF
      FF000000000000FFFF00C0C0C00000FFFF00C0C0C00000FFFF00C0C0C00000FF
      FF00C0C0C00000FFFF000000000000000000000000000000FF000000FF000000
      FF000000FF000000FF000000FF00000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000FF000000FF000000FF00000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000000000000000000000FF
      FF00FFFFFF000000000000FFFF00C0C0C00000FFFF00C0C0C00000FFFF00C0C0
      C00000FFFF00C0C0C00000FFFF0000000000000000000000FF000000FF000000
      FF000000FF000000FF000000FF00000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000FF000000FF000000FF00000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000FFFF
      FF0000FFFF00FFFFFF0000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      FF000000FF000000FF000000FF000000FF000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000000000000000000000FF
      FF00FFFFFF0000FFFF00FFFFFF0000FFFF00FFFFFF0000FFFF00FFFFFF0000FF
      FF00000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000000000000000FF000000
      FF000000FF000000FF000000FF000000FF000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000FFFF0000000000FFFF
      FF0000FFFF00FFFFFF0000FFFF00FFFFFF0000FFFF00FFFFFF0000FFFF00FFFF
      FF00000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000808080000000FF000000
      FF0000000000000000000000FF000000FF000000FF0000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF000000000000FF
      FF00FFFFFF0000FFFF00FFFFFF0000FFFF00FFFFFF0000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000FF0000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000808080000000FF00000000000000
      00000000000000000000000000000000FF000000FF0000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000FFFF00FFFFFF000000
      000000FFFF00FFFFFF0000FFFF00FFFFFF000000000000FFFF00000000000000
      000000000000000000000000000000000000000000000000000000000000FF00
      0000FF0000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000FF000000FF000000FF00000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF0000FFFF008080
      80000000000000000000000000000000000080808000FFFFFF00000000000000
      00000000000000000000000000000000000000000000FF000000FF000000FF00
      0000FF000000FF000000FF000000FF000000FF000000FF000000FF0000000000
      00000000FF000000FF0000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000FF000000FF00000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000FFFF00FFFFFF0000FF
      FF00FFFFFF0000FFFF00FFFFFF0000FFFF00FFFFFF0000FFFF00000000000000
      00000000000000000000000000000000000000000000FF000000FF000000FF00
      0000FF000000FF000000FF000000FF000000FF000000FF000000FF0000000000
      00000000FF000000FF0000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000FF000000FF000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF0000FFFF00FFFF
      FF0000FFFF00FFFFFF0000FFFF00FFFFFF0000FFFF00FFFFFF00000000000000
      000000000000000000000000000000000000000000000000000000000000FF00
      0000FF0000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000808080000000
      FF00000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000FF0000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000008080
      80000000FF000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000FFFFFF0000FF
      FF00FFFFFF0000FFFF0000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000FF000000FF00000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000080808000000000000000
      0000000000000000000080808000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000424D3E000000000000003E000000
      2800000040000000100000000100010000000000800000000000000000000000
      000000000000000000000000FFFFFF00FFFFFFFFFFFF0000E007FFF8FFFF0000
      C003FFF8F9FF0000C00181FFF0FF0000C00081FCF0FF0000C000FFFCE07F0000
      8007FFFFC07F00000007FFFC843F0000000FF7FC1E3F0000001FE7FFFE1F0000
      001F8013FF1F0000001F8013FF8F0000001FE7FFFFC70000003FF7F8FFE30000
      81FFFFF8FFF8000081FFFFFFFFFF000000000000000000000000000000000000
      000000000000}
  end
end
