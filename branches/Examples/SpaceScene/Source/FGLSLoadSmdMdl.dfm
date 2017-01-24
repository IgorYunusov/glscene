object GlsLoadSmdMdlFrm: TGlsLoadSmdMdlFrm
  Left = 204
  Top = 96
  HelpContext = 8500
  Caption = 'Load a .mdl or .qc file'
  ClientHeight = 341
  ClientWidth = 425
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  Icon.Data = {
    0000010001002020100000000000E80200001600000028000000200000004000
    0000010004000000000080020000000000000000000000000000000000000000
    000000008000008000000080800080000000800080008080000080808000C0C0
    C0000000FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF000990
    0000000009990000000999999000099900000100099900000009990000000999
    1000999009990000000990009990009999999990099900000009999999900000
    9999997009990000000099999000000000000000000000000000000000000000
    0000000000000000000000000000000099999100099999999000999991000099
    9999999009999999900999999990099990000990099900000099900009900999
    0000099009990000009990000990099000999990099900000000000099900990
    0099990009990000000009999990099000000000099900000009999990000999
    0000010009990000000999000000009910009990099900000009900099900099
    9999999009990000000999999990000999999970099900000000999999000000
    0000000000000000000000000000000000000000000000000000000000000000
    9999910009999999900099999100000999009990099999999009999099900999
    9000099009990000009990000990099900000990099900000099900009900990
    0099999009990000000000079990099000999990099900000000099999000990
    0000000009990000000999990000099900000100099900000009990000000999
    1000999009990000000990009990079999999990099900000009999999900009
    9999990009990000000099999000000000000000000000000000000000009FF8
    FE078FB8FE3F8718FE71C018FE01F018FF07FFFFFFFFFFFFFFFFF0380703C018
    06018798FC798F98FC799C18FFF19C38FF819FF8FE078FB8FE3FC718FE71C018
    FE01E018FF03FFFFFFFFFFFFFFFFF0380703E31806118798FC798F98FC799C18
    FFE19C18FF839FF8FE0F8FB8FE3F8718FE718018FE01E038FF07FFFFFFFF}
  OldCreateOrder = False
  Position = poScreenCenter
  ShowHint = True
  OnClose = FormClose
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object PageControl1: TPageControl
    Left = 0
    Top = 0
    Width = 417
    Height = 345
    HelpContext = 8500
    ActivePage = TabSheet1
    TabOrder = 0
    object TabSheet1: TTabSheet
      HelpContext = 8500
      Caption = 'mdl'
      object FileNameLabel: TLabel
        Left = 64
        Top = 8
        Width = 44
        Height = 13
        Caption = 'FileName'
      end
      object MDLoadBtn: TSpeedButton
        Left = 32
        Top = 0
        Width = 25
        Height = 23
        Hint = 'locate .mdl'
        Glyph.Data = {
          76010000424D7601000000000000760000002800000020000000100000000100
          04000000000000010000120B0000120B00001000000000000000000000000000
          800000800000008080008000000080008000808000007F7F7F00BFBFBF000000
          FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00333333333333
          3333333333333333333333333333333333333333333333333333333333333333
          33333FFFFFFFFFFFFFFF000000000000000077777777777777770F7777777777
          77707F3F3333333333370F988888888888707F733FFFFFFFF3370F8800000000
          88707F337777777733370F888888888888707F333FFFFFFFF3370F8800000000
          88707F337777777733370F888888888888707F333333333333370F8888888888
          88707F333333333333370FFFFFFFFFFFFFF07FFFFFFFFFFFFFF7000000000000
          0000777777777777777733333333333333333333333333333333333333333333
          3333333333333333333333333333333333333333333333333333}
        NumGlyphs = 2
        OnClick = MDLoadBtnClick
      end
      object PrintBtn: TSpeedButton
        Left = 8
        Top = 0
        Width = 23
        Height = 23
        Glyph.Data = {
          76010000424D7601000000000000760000002800000020000000100000000100
          04000000000000010000130B0000130B00001000000000000000000000000000
          800000800000008080008000000080008000808000007F7F7F00BFBFBF000000
          FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00300000000000
          00033FFFFFFFFFFFFFFF0888888888888880777777777777777F088888888888
          8880777777777777777F0000000000000000FFFFFFFFFFFFFFFF0F8F8F8F8F8F
          8F80777777777777777F08F8F8F8F8F8F9F0777777777777777F0F8F8F8F8F8F
          8F807777777777777F7F0000000000000000777777777777777F3330FFFFFFFF
          03333337F3FFFF3F7F333330F0000F0F03333337F77773737F333330FFFFFFFF
          03333337F3FF3FFF7F333330F00F000003333337F773777773333330FFFF0FF0
          33333337F3FF7F3733333330F08F0F0333333337F7737F7333333330FFFF0033
          33333337FFFF7733333333300000033333333337777773333333}
        NumGlyphs = 2
        OnClick = PrintBtnClick
      end
      object LBSequenz: TListBox
        Left = 248
        Top = 152
        Width = 153
        Height = 153
        Hint = 'Sequence'
        HelpContext = 8500
        ItemHeight = 13
        TabOrder = 0
      end
      object LBBones: TListBox
        Left = 8
        Top = 152
        Width = 233
        Height = 153
        Hint = 'dem Bones'
        HelpContext = 8500
        ItemHeight = 13
        TabOrder = 1
      end
      object LBMDL: TListBox
        Left = 8
        Top = 24
        Width = 233
        Height = 121
        Hint = 'Header'
        HelpContext = 8500
        ItemHeight = 13
        TabOrder = 2
      end
      object LBBoneController: TListBox
        Left = 248
        Top = 2
        Width = 153
        Height = 144
        Hint = 'Bone Controller'
        HelpContext = 8500
        ItemHeight = 13
        TabOrder = 3
      end
    end
    object TabSheet2: TTabSheet
      HelpContext = 8500
      Caption = 'qc'
      ImageIndex = 1
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      object QcPrintBtn: TSpeedButton
        Left = 8
        Top = 0
        Width = 23
        Height = 23
        Hint = 'print'
        Glyph.Data = {
          76010000424D7601000000000000760000002800000020000000100000000100
          04000000000000010000130B0000130B00001000000000000000000000000000
          800000800000008080008000000080008000808000007F7F7F00BFBFBF000000
          FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00300000000000
          00033FFFFFFFFFFFFFFF0888888888888880777777777777777F088888888888
          8880777777777777777F0000000000000000FFFFFFFFFFFFFFFF0F8F8F8F8F8F
          8F80777777777777777F08F8F8F8F8F8F9F0777777777777777F0F8F8F8F8F8F
          8F807777777777777F7F0000000000000000777777777777777F3330FFFFFFFF
          03333337F3FFFF3F7F333330F0000F0F03333337F77773737F333330FFFFFFFF
          03333337F3FF3FFF7F333330F00F000003333337F773777773333330FFFF0FF0
          33333337F3FF7F3733333330F08F0F0333333337F7737F7333333330FFFF0033
          33333337FFFF7733333333300000033333333337777773333333}
        NumGlyphs = 2
        OnClick = QcPrintBtnClick
      end
      object QcLoadBtn: TSpeedButton
        Left = 32
        Top = 0
        Width = 25
        Height = 23
        Hint = 'load .qc'
        Glyph.Data = {
          76010000424D7601000000000000760000002800000020000000100000000100
          04000000000000010000120B0000120B00001000000000000000000000000000
          800000800000008080008000000080008000808000007F7F7F00BFBFBF000000
          FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00333333333333
          3333333333333333333333333333333333333333333333333333333333333333
          33333FFFFFFFFFFFFFFF000000000000000077777777777777770F7777777777
          77707F3F3333333333370F988888888888707F733FFFFFFFF3370F8800000000
          88707F337777777733370F888888888888707F333FFFFFFFF3370F8800000000
          88707F337777777733370F888888888888707F333333333333370F8888888888
          88707F333333333333370FFFFFFFFFFFFFF07FFFFFFFFFFFFFF7000000000000
          0000777777777777777733333333333333333333333333333333333333333333
          3333333333333333333333333333333333333333333333333333}
        NumGlyphs = 2
        OnClick = QcLoadBtnClick
      end
      object QcFileNameLabel: TLabel
        Left = 88
        Top = 8
        Width = 44
        Height = 13
        Caption = 'FileName'
      end
      object QcSaveBtn: TSpeedButton
        Left = 58
        Top = 0
        Width = 25
        Height = 23
        Hint = 'save .qc'
        Glyph.Data = {
          76010000424D7601000000000000760000002800000020000000100000000100
          04000000000000010000130B0000130B00001000000000000000000000000000
          800000800000008080008000000080008000808000007F7F7F00BFBFBF000000
          FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00333333330070
          7700333333337777777733333333008088003333333377F73377333333330088
          88003333333377FFFF7733333333000000003FFFFFFF77777777000000000000
          000077777777777777770FFFFFFF0FFFFFF07F3333337F3333370FFFFFFF0FFF
          FFF07F3FF3FF7FFFFFF70F00F0080CCC9CC07F773773777777770FFFFFFFF039
          99337F3FFFF3F7F777F30F0000F0F09999937F7777373777777F0FFFFFFFF999
          99997F3FF3FFF77777770F00F000003999337F773777773777F30FFFF0FF0339
          99337F3FF7F3733777F30F08F0F0337999337F7737F73F7777330FFFF0039999
          93337FFFF7737777733300000033333333337777773333333333}
        NumGlyphs = 2
        OnClick = QcSaveBtnClick
      end
      object RichEdit1: TRichEdit
        Left = 8
        Top = 32
        Width = 393
        Height = 273
        HelpContext = 8500
        Font.Charset = RUSSIAN_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = []
        ParentFont = False
        ScrollBars = ssBoth
        TabOrder = 0
        WordWrap = False
        Zoom = 100
      end
    end
  end
  object OpenDialog1: TOpenDialog
    Left = 152
  end
  object SaveDialog1: TSaveDialog
    Left = 184
    Top = 8
  end
end
