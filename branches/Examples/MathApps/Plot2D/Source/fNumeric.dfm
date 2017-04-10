object NumericForm: TNumericForm
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  ClientHeight = 699
  ClientWidth = 343
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'Tahoma'
  Font.Style = []
  FormStyle = fsStayOnTop
  KeyPreview = True
  OldCreateOrder = False
  Position = poDesigned
  ShowHint = True
  OnCloseQuery = FormCloseQuery
  OnDestroy = FormDestroy
  OnKeyDown = FormKeyDown
  OnShow = FormShow
  DesignSize = (
    343
    699)
  PixelsPerInch = 96
  TextHeight = 16
  object AddButton: TSpeedButton
    Left = 84
    Top = 443
    Width = 23
    Height = 23
    Cursor = crHandPoint
    Hint = 'Add a new numeric graph {+ Key }'
    Flat = True
    Glyph.Data = {
      F6000000424DF600000000000000760000002800000010000000100000000100
      0400000000008000000000000000000000001000000010000000000000000000
      8000008000000080800080000000800080008080000080808000C0C0C0000000
      FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00F4FFF4FF44FF
      44FFF4FFF4F4F4F4F4FFFF444FF4F4F4F4FFFF4F4FF4F4F4F4FFFF4F4FFF44FF
      44FFFFF4FFFFF4FFF4FFFFFFFFFFFFFFFFFFFFFFFFF00FFFFFFFFFFFFFF00FFF
      FFFFFFFFFFF00FFFFFFFFFFF00000000FFFFFFFF00000000FFFFFFFFFFF00FFF
      FFFFFFFFFFF00FFFFFFFFFFFFFF00FFFFFFFFFFFFFFFFFFFFFFF}
    ParentShowHint = False
    ShowHint = True
    OnClick = AddButtonClick
  end
  object DeleteButton: TSpeedButton
    Left = 113
    Top = 443
    Width = 23
    Height = 23
    Cursor = crHandPoint
    Hint = 'Delete the selected numeric  graph {- Key }'
    Flat = True
    Glyph.Data = {
      F6000000424DF600000000000000760000002800000010000000100000000100
      0400000000008000000000000000000000001000000010000000000000000000
      8000008000000080800080000000800080008080000080808000C0C0C0000000
      FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00FFF999FFF99F
      9FFFFFF9FF9F9FFF9FFFFFF9FF9F999F9FFFFFF9FF9F9F9F9FFFFFF9FF9FF9FF
      9FFFFFF999FFFFFF9FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFF00000000FFFFFFFF00000000FFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF}
    ParentShowHint = False
    ShowHint = True
    OnClick = DeleteButtonClick
  end
  object UpButton: TSpeedButton
    Left = 211
    Top = 443
    Width = 23
    Height = 23
    Cursor = crHandPoint
    Hint = 'Move selected graph up'
    Flat = True
    Glyph.Data = {
      36030000424D3603000000000000360000002800000010000000100000000100
      18000000000000030000120B0000120B00000000000000000000FF00FFFF00FF
      FF00FFFF00FFFF00FF7A451F7A451F7A451F7A451F7A451F7A451FFF00FFFF00
      FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF7A451F7A451FA14D18B14313B8
      360BB22E09A52D0B983A167A451F7A451FFF00FFFF00FFFF00FFFF00FFFF00FF
      7A451FA05B1FC25D18CA5714C54B11BB4515B63A10B42B07B1280BB8543B9C59
      367A451FFF00FFFF00FFFF00FF7A451FA56522D7791FD5701BCF5F16C45417E7
      EBEDE7EBEDB42E09B42D0CC65C41C769559E603F7A451FFF00FFFF00FF7A451F
      D88C26E28923DA781DD36717C65D1EE7EBEDE7EBEDB5340CB6300DC96044CE6F
      58C676637A451FFF00FF7A451FB78128EFA62AE69225DE801FD76C18C9631EE7
      EBEDE7EBEDB6350CB83511CA6448CE705AD4806FAC72537A451F7A451FDAA92E
      F3AF2DEA9824DD801DD86D16CB651FE7EBEDE7EBEDB6350BB83712C96448CF70
      5AD58272C989737A451F7A451FF4C132F6B02AD99A3CE9D0C9CB886ECB6017E7
      EBEDE7EBEDB22F06CB886EE9D0C9CF7763D58270DC98897A451F7A451FF4C032
      F6AC26CF9D53CAD5E5E7EBEDCB886EE7EBEDE7EBEDBC6F4EF7FBFCF4EBEACF7B
      67D58372DC998A7A451F7A451FDAA02DEFA629E38E20C99C68D1D9E2E7EBEDE7
      EBEDE7EBEDE7E9E9EFEBE7CC7D67CE705AD78776CA8B767A451F7A451FB67926
      EA9927E38921D87216C48F62D7DDE3E7EBEDE7EBEDE2E0DDC67458CA6045D075
      60D78777AC75567A451FFF00FF7A451FD38022DC7E1FD76E1ACC590FC0825BDC
      E6EBDEE0E0B85837C45131CB6950CF7560CB806C7A451FFF00FFFF00FF7A451F
      A15F20D06D1BD16518CC5714C2450CBD724DB75B39B7310CC75D41CA674FCC72
      5F9F65427A451FFF00FFFF00FFFF00FF7A451F9E571EBF5416C54D12C1430FBA
      3407B42904BA3B1AC65B41BF62499D5D3B7A451FFF00FFFF00FFFF00FFFF00FF
      FF00FF7A451F7A451FA04A18AF4011B6330BB12A07B04423A155327A451F7A45
      1FFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF7A451F7A451F7A
      451F7A451F7A451F7A451FFF00FFFF00FFFF00FFFF00FFFF00FF}
    ParentShowHint = False
    ShowHint = True
    OnClick = UpButtonClick
  end
  object DownButton: TSpeedButton
    Left = 240
    Top = 443
    Width = 23
    Height = 23
    Cursor = crHandPoint
    Hint = 'Move selected graph down'
    Flat = True
    Glyph.Data = {
      36030000424D3603000000000000360000002800000010000000100000000100
      18000000000000030000120B0000120B00000000000000000000FF00FFFF00FF
      FF00FFFF00FFFF00FF7A451F7A451F7A451F7A451F7A451F7A451FFF00FFFF00
      FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF7A451F7A451FA15532B04423B1
      2A07B6330BAF4011A04A187A451F7A451FFF00FFFF00FFFF00FFFF00FFFF00FF
      7A451F9D5D3BBF6249C65B41BA3B1AB42904BA3407C1430FC54D12BF54169E57
      1E7A451FFF00FFFF00FFFF00FF7A451F9F6542CC725FCA674FC75D41B7310CB7
      5B39BD724DC2450CCC5714D16518D06D1BA15F207A451FFF00FFFF00FF7A451F
      CB806CCF7560CB6950C45131B85837DEE0E0DCE6EBC0825BCC590FD76E1ADC7E
      1FD380227A451FFF00FF7A451FAC7556D78777D07560CA6045C67458E2E0DDE7
      EBEDE7EBEDD7DDE3C48F62D87216E38921EA9927B679267A451F7A451FCA8B76
      D78776CE705ACC7D67EFEBE7E7E9E9E7EBEDE7EBEDE7EBEDD1D9E2C99C68E38E
      20EFA629DAA02D7A451F7A451FDC998AD58372CF7B67F4EBEAF7FBFCBC6F4EE7
      EBEDE7EBEDCB886EE7EBEDCAD5E5CF9D53F6AC26F4C0327A451F7A451FDC9889
      D58270CF7763E9D0C9CB886EB22F06E7EBEDE7EBEDCB6017CB886EE9D0C9D99A
      3CF6B02AF4C1327A451F7A451FC98973D58272CF705AC96448B83712B6350BE7
      EBEDE7EBEDCB651FD86D16DD801DEA9824F3AF2DDAA92E7A451F7A451FAC7253
      D4806FCE705ACA6448B83511B6350CE7EBEDE7EBEDC9631ED76C18DE801FE692
      25EFA62AB781287A451FFF00FF7A451FC67663CE6F58C96044B6300DB5340CE7
      EBEDE7EBEDC65D1ED36717DA781DE28923D88C267A451FFF00FFFF00FF7A451F
      9E603FC76955C65C41B42D0CB42E09E7EBEDE7EBEDC45417CF5F16D5701BD779
      1FA565227A451FFF00FFFF00FFFF00FF7A451F9C5936B8543BB1280BB42B07B6
      3A10BB4515C54B11CA5714C25D18A05B1F7A451FFF00FFFF00FFFF00FFFF00FF
      FF00FF7A451F7A451F983A16A52D0BB22E09B8360BB14313A14D187A451F7A45
      1FFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF7A451F7A451F7A
      451F7A451F7A451F7A451FFF00FFFF00FFFF00FFFF00FFFF00FF}
    ParentShowHint = False
    ShowHint = True
    OnClick = DownButtonClick
  end
  object Label4: TLabel
    Left = 5
    Top = 419
    Width = 40
    Height = 16
    Caption = 'Name:'
    Font.Charset = ANSI_CHARSET
    Font.Color = clMaroon
    Font.Height = -13
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label2: TLabel
    Left = 6
    Top = 265
    Width = 214
    Height = 16
    Hint = 'Enter the coordinates for the point'
    Anchors = [akTop, akRight]
    Caption = 'Plot Cartesian Coordinates {x, y}'
    Font.Charset = ANSI_CHARSET
    Font.Color = clMaroon
    Font.Height = -13
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label1: TLabel
    Left = 5
    Top = 6
    Width = 150
    Height = 20
    Hint = 'Enter the x, y location for the tex block'
    Alignment = taRightJustify
    Anchors = [akTop, akRight]
    AutoSize = False
    Caption = 'Plot Data Coordinates'
    Font.Charset = ANSI_CHARSET
    Font.Color = clMaroon
    Font.Height = -13
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label3: TLabel
    Left = 27
    Top = 390
    Width = 90
    Height = 16
    Alignment = taRightJustify
    AutoSize = False
    Caption = 'Plot Pen Width:'
  end
  object PenSpeedButton: TSpeedButton
    Tag = 2
    Left = 213
    Top = 386
    Width = 93
    Height = 24
    Cursor = crHandPoint
    Hint = 'Select plot color'
    Caption = '&Pen Colour'
    Flat = True
    Glyph.Data = {
      36030000424D3603000000000000360000002800000010000000100000000100
      18000000000000030000120B0000120B00000000000000000000FF00FFBFBFBF
      BFBFBFBFBFBFBFBFBFBFBFBFBFBFBFBFBFBFBFBFBFBFBFBFBFBFBFBFBFBFBFBF
      BFBFBFBFFF00FFFF00FFFF00FFBFBFBFFF0000007F00D4E6F2D4E6F2D4E6F2D4
      E6F2D4E6F2D4E6F2D4E6F2D4E6F2D4E6F2BFBFBFFF00FFFF00FFFF00FFBFBFBF
      FF0000007F00D4E6F2D4E6F2D4E6F2D4E6F2D4E6F2D4E6F2D4E6F2D4E6F2D4E6
      F2BFBFBFFF00FFFF00FFFF00FFBFBFBF0000FFFF00000000FF0000FF0000FF00
      00FF0000FF0000FF0000FF0000FF0000FFBFBFBFFF00FFFF00FFFF00FFBFBFBF
      D4E6F2FF0000D4E6F2D4E6F2D4E6F2D4E6F2D4E6F2D4E6F2D4E6F2D4E6F2FF00
      00BFBFBFFF00FFFF00FFFF00FFBFBFBFD4E6F2007F00FF0000D4E6F2D4E6F2D4
      E6F2D4E6F2D4E6F2D4E6F2FF0000D4E6F2BFBFBFFF00FFFF00FFFF00FFBFBFBF
      D4E6F2007F00FF0000D4E6F2D4E6F2D4E6F2D4E6F2D4E6F2D4E6F2FF0000D4E6
      F2BFBFBFFF00FFFF00FFFF00FFBFBFBFD4E6F2007F00D4E6F2FF0000D4E6F2D4
      E6F2D4E6F2D4E6F2FF0000D4E6F2D4E6F2BFBFBFFF00FFFF00FFFF00FFBFBFBF
      D4E6F2007F00D4E6F2FF0000D4E6F2D4E6F2D4E6F2D4E6F2FF0000D4E6F2D4E6
      F2BFBFBFFF00FFFF00FFFF00FFBFBFBFD4E6F2007F00D4E6F2D4E6F2FF0000D4
      E6F2D4E6F2FF0000D4E6F2D4E6F2D4E6F2BFBFBFFF00FFFF00FFFF00FFBFBFBF
      D4E6F2007F00D4E6F2D4E6F2D4E6F2FF0000FF0000D4E6F2D4E6F2D4E6F2D4E6
      F2BFBFBFFF00FFFF00FFFF00FFBFBFBFD4E6F2007F00D4E6F2D4E6F2D4E6F2D4
      E6F2D4E6F2D4E6F2D4E6F2D4E6F2D4E6F2BFBFBFFF00FFFF00FFFF00FFBFBFBF
      D4E6F2007F00D4E6F2D4E6F2D4E6F2D4E6F2D4E6F2D4E6F2D4E6F2D4E6F2D4E6
      F2BFBFBFFF00FFFF00FFFF00FFBFBFBFD4E6F2007F00D4E6F2D4E6F2D4E6F2D4
      E6F2D4E6F2D4E6F2D4E6F2D4E6F2D4E6F2BFBFBFFF00FFFF00FFFF00FFBFBFBF
      D4E6F2007F00D4E6F2D4E6F2D4E6F2D4E6F2D4E6F2D4E6F2D4E6F2D4E6F2D4E6
      F2BFBFBFFF00FFFF00FFFF00FFBFBFBFBFBFBFBFBFBFBFBFBFBFBFBFBFBFBFBF
      BFBFBFBFBFBFBFBFBFBFBFBFBFBFBFBFBFBFBFBFFF00FFFF00FF}
    ParentShowHint = False
    ShowHint = True
    Spacing = -1
    OnClick = ColorClick
  end
  object PointSpeedButton: TSpeedButton
    Tag = 1
    Left = 241
    Top = 315
    Width = 65
    Height = 24
    Cursor = crHandPoint
    Hint = 'Select point color'
    Caption = 'Colour'
    Flat = True
    Glyph.Data = {
      36030000424D3603000000000000360000002800000010000000100000000100
      18000000000000030000120B0000120B00000000000000000000FF00FFBFBFBF
      BFBFBFBFBFBFBFBFBFBFBFBFBFBFBFBFBFBFBFBFBFBFBFBFBFBFBFBFBFBFBFBF
      BFBFBFBFFF00FFFF00FFFF00FFBFBFBFFF0000D4E6F2D4E6F2D4E6F2D4E6F2D4
      E6F2D4E6F2D4E6F2D4E6F2D4E6F2D4E6F2BFBFBFFF00FFFF00FFFF00FFBFBFBF
      FF0000D4E6F2D4E6F2D4E6F2D4E6F2D4E6F2D4E6F2D4E6F2D4E6F2D4E6F2D4E6
      F2BFBFBFFF00FFFF00FFFF00FFBFBFBFD4E6F2FF0000D4E6F2D4E6F2D4E6F2D4
      E6F2D4E6F2D4E6F2D4E6F2D4E6F2D4E6F2BFBFBFFF00FFFF00FFFF00FFBFBFBF
      D4E6F2FF00000000FFD4E6F2D4E6F2D4E6F2D4E6F2D4E6F2D4E6F2D4E6F2FF00
      00BFBFBFFF00FFFF00FFFF00FFBFBFBFD4E6F2D4E6F2FF0000D4E6F2D4E6F2D4
      E6F2D4E6F2D4E6F2D4E6F2FF0000D4E6F2BFBFBFFF00FFFF00FFFF00FFBFBFBF
      0000FF0000FFFF00000000FF0000FFD4E6F2D4E6F2D4E6F2D4E6F2FF0000D4E6
      F2BFBFBFFF00FFFF00FFFF00FFBFBFBFD4E6F2D4E6F20000FFFF0000D4E6F2D4
      E6F2D4E6F2D4E6F2FF0000D4E6F2D4E6F2BFBFBFFF00FFFF00FFFF00FFBFBFBF
      D4E6F2D4E6F20000FFFF0000D4E6F2D4E6F20000FFD4E6F2FF0000D4E6F2D4E6
      F2BFBFBFFF00FFFF00FFFF00FFBFBFBFD4E6F2D4E6F2D4E6F2D4E6F2FF0000D4
      E6F20000FFFF0000D4E6F2D4E6F2D4E6F2BFBFBFFF00FFFF00FFFF00FFBFBFBF
      D4E6F2D4E6F2D4E6F2D4E6F20000FFFF0000FF00000000FF0000FFD4E6F2D4E6
      F2BFBFBFFF00FFFF00FFFF00FFBFBFBFD4E6F2D4E6F2D4E6F2D4E6F2D4E6F2D4
      E6F20000FFD4E6F2D4E6F2D4E6F2D4E6F2BFBFBFFF00FFFF00FFFF00FFBFBFBF
      D4E6F2D4E6F2D4E6F2D4E6F2D4E6F2D4E6F20000FFD4E6F2D4E6F2D4E6F2D4E6
      F2BFBFBFFF00FFFF00FFFF00FFBFBFBFD4E6F2D4E6F2D4E6F2D4E6F2D4E6F2D4
      E6F2D4E6F2D4E6F2D4E6F2D4E6F2D4E6F2BFBFBFFF00FFFF00FFFF00FFBFBFBF
      D4E6F2D4E6F2D4E6F2D4E6F2D4E6F2D4E6F2D4E6F2D4E6F2D4E6F2D4E6F2D4E6
      F2BFBFBFFF00FFFF00FFFF00FFBFBFBFBFBFBFBFBFBFBFBFBFBFBFBFBFBFBFBF
      BFBFBFBFBFBFBFBFBFBFBFBFBFBFBFBFBFBFBFBFFF00FFFF00FF}
    ParentShowHint = False
    ShowHint = True
    Spacing = -1
    OnClick = PointColorClick
  end
  object Label5: TLabel
    Left = 6
    Top = 317
    Width = 56
    Height = 16
    Caption = 'Point Size'
  end
  object Label6: TLabel
    Left = 6
    Top = 629
    Width = 81
    Height = 16
    Caption = 'Curve Rate 30'
  end
  object PointUpBtn: TSpeedButton
    Left = 211
    Top = 0
    Width = 23
    Height = 23
    Cursor = crHandPoint
    Hint = 'Move selected control point up'
    Flat = True
    Glyph.Data = {
      36030000424D3603000000000000360000002800000010000000100000000100
      18000000000000030000120B0000120B00000000000000000000FF00FFFF00FF
      FF00FFFF00FFFF00FF7A451F7A451F7A451F7A451F7A451F7A451FFF00FFFF00
      FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF7A451F7A451FA14D18B14313B8
      360BB22E09A52D0B983A167A451F7A451FFF00FFFF00FFFF00FFFF00FFFF00FF
      7A451FA05B1FC25D18CA5714C54B11BB4515B63A10B42B07B1280BB8543B9C59
      367A451FFF00FFFF00FFFF00FF7A451FA56522D7791FD5701BCF5F16C45417E7
      EBEDE7EBEDB42E09B42D0CC65C41C769559E603F7A451FFF00FFFF00FF7A451F
      D88C26E28923DA781DD36717C65D1EE7EBEDE7EBEDB5340CB6300DC96044CE6F
      58C676637A451FFF00FF7A451FB78128EFA62AE69225DE801FD76C18C9631EE7
      EBEDE7EBEDB6350CB83511CA6448CE705AD4806FAC72537A451F7A451FDAA92E
      F3AF2DEA9824DD801DD86D16CB651FE7EBEDE7EBEDB6350BB83712C96448CF70
      5AD58272C989737A451F7A451FF4C132F6B02AD99A3CE9D0C9CB886ECB6017E7
      EBEDE7EBEDB22F06CB886EE9D0C9CF7763D58270DC98897A451F7A451FF4C032
      F6AC26CF9D53CAD5E5E7EBEDCB886EE7EBEDE7EBEDBC6F4EF7FBFCF4EBEACF7B
      67D58372DC998A7A451F7A451FDAA02DEFA629E38E20C99C68D1D9E2E7EBEDE7
      EBEDE7EBEDE7E9E9EFEBE7CC7D67CE705AD78776CA8B767A451F7A451FB67926
      EA9927E38921D87216C48F62D7DDE3E7EBEDE7EBEDE2E0DDC67458CA6045D075
      60D78777AC75567A451FFF00FF7A451FD38022DC7E1FD76E1ACC590FC0825BDC
      E6EBDEE0E0B85837C45131CB6950CF7560CB806C7A451FFF00FFFF00FF7A451F
      A15F20D06D1BD16518CC5714C2450CBD724DB75B39B7310CC75D41CA674FCC72
      5F9F65427A451FFF00FFFF00FFFF00FF7A451F9E571EBF5416C54D12C1430FBA
      3407B42904BA3B1AC65B41BF62499D5D3B7A451FFF00FFFF00FFFF00FFFF00FF
      FF00FF7A451F7A451FA04A18AF4011B6330BB12A07B04423A155327A451F7A45
      1FFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF7A451F7A451F7A
      451F7A451F7A451F7A451FFF00FFFF00FFFF00FFFF00FFFF00FF}
    ParentShowHint = False
    ShowHint = True
    OnClick = PointUpBtnClick
  end
  object PointDownBtn: TSpeedButton
    Left = 240
    Top = 0
    Width = 23
    Height = 23
    Cursor = crHandPoint
    Hint = 'Move selected control point down'
    Flat = True
    Glyph.Data = {
      36030000424D3603000000000000360000002800000010000000100000000100
      18000000000000030000120B0000120B00000000000000000000FF00FFFF00FF
      FF00FFFF00FFFF00FF7A451F7A451F7A451F7A451F7A451F7A451FFF00FFFF00
      FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF7A451F7A451FA15532B04423B1
      2A07B6330BAF4011A04A187A451F7A451FFF00FFFF00FFFF00FFFF00FFFF00FF
      7A451F9D5D3BBF6249C65B41BA3B1AB42904BA3407C1430FC54D12BF54169E57
      1E7A451FFF00FFFF00FFFF00FF7A451F9F6542CC725FCA674FC75D41B7310CB7
      5B39BD724DC2450CCC5714D16518D06D1BA15F207A451FFF00FFFF00FF7A451F
      CB806CCF7560CB6950C45131B85837DEE0E0DCE6EBC0825BCC590FD76E1ADC7E
      1FD380227A451FFF00FF7A451FAC7556D78777D07560CA6045C67458E2E0DDE7
      EBEDE7EBEDD7DDE3C48F62D87216E38921EA9927B679267A451F7A451FCA8B76
      D78776CE705ACC7D67EFEBE7E7E9E9E7EBEDE7EBEDE7EBEDD1D9E2C99C68E38E
      20EFA629DAA02D7A451F7A451FDC998AD58372CF7B67F4EBEAF7FBFCBC6F4EE7
      EBEDE7EBEDCB886EE7EBEDCAD5E5CF9D53F6AC26F4C0327A451F7A451FDC9889
      D58270CF7763E9D0C9CB886EB22F06E7EBEDE7EBEDCB6017CB886EE9D0C9D99A
      3CF6B02AF4C1327A451F7A451FC98973D58272CF705AC96448B83712B6350BE7
      EBEDE7EBEDCB651FD86D16DD801DEA9824F3AF2DDAA92E7A451F7A451FAC7253
      D4806FCE705ACA6448B83511B6350CE7EBEDE7EBEDC9631ED76C18DE801FE692
      25EFA62AB781287A451FFF00FF7A451FC67663CE6F58C96044B6300DB5340CE7
      EBEDE7EBEDC65D1ED36717DA781DE28923D88C267A451FFF00FFFF00FF7A451F
      9E603FC76955C65C41B42D0CB42E09E7EBEDE7EBEDC45417CF5F16D5701BD779
      1FA565227A451FFF00FFFF00FFFF00FF7A451F9C5936B8543BB1280BB42B07B6
      3A10BB4515C54B11CA5714C25D18A05B1F7A451FFF00FFFF00FFFF00FFFF00FF
      FF00FF7A451F7A451F983A16A52D0BB22E09B8360BB14313A14D187A451F7A45
      1FFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF7A451F7A451F7A
      451F7A451F7A451F7A451FFF00FFFF00FFFF00FFFF00FFFF00FF}
    ParentShowHint = False
    ShowHint = True
    OnClick = PointDownBtnClick
  end
  object CheckListBox: TCheckListBox
    Left = 5
    Top = 466
    Width = 332
    Height = 101
    Cursor = crHandPoint
    Hint = 'Select a function for editing etc'
    OnClickCheck = CheckListBoxClickCheck
    TabOrder = 13
    OnClick = CheckListBoxClick
  end
  object ApplyBitBtn: TBitBtn
    Left = 28
    Top = 657
    Width = 140
    Height = 27
    Cursor = crHandPoint
    Hint = 'Update any changes made'
    Caption = '&Apply Change'
    Default = True
    Glyph.Data = {
      36030000424D3603000000000000360000002800000010000000100000000100
      18000000000000030000120B0000120B00000000000000000000FF00FFFF00FF
      FF00FFFF00FFFF00FF936035936035936035936035936035936035FF00FFFF00
      FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF936035936035C6923DE3B445F7
      CE4AF7CF4BE3BB47C79940936035936035FF00FFFF00FFFF00FFFF00FFFF00FF
      936035B57A36DD9838F0AD38F3B538F5BC3BF6BE3CF5BB3BF3B63BE1A33DB87F
      38936035FF00FFFF00FFFF00FF936035B27233DC872FE4922DDCA457D7BC8FD7
      C097D8C096D8C199D5B582E69E38E09233B47634936035FF00FFFF00FF936035
      CD6F28DA7B25D2A374F9FDFEF9FDFEF9FDFEF9FDFEF9FDFEF9FDFEDF8E32E08A
      2FD0782C936035FF00FF936035B4652BD3661FD27A37F9FDFED5B69ADA8229DE
      892DDF8A2FD9852DDC8227DD832DDA7B2AD67226B5682C936035936035C05A21
      CE5A17D07D47F9FDFED18C57DA711CDB7B29DC7822F9FDFED2905BD76D1CD56E
      25D26722C25E24936035936035C64C18CA5015CB6A36F9FDFED8AD91CD5F16D0
      641BCF5E0FF9FDFEF9FDFECD7F4CCF5A15CD5B1EC7521B936035936035C24212
      C54613C5480FD5A38CF5FCFFF9FDFEF9FDFEF9FDFEF9FDFEF9FDFEF9FDFECB70
      43C84B12C34917936035936035C15F39C9552DC95124C54918D08464E4BDAEE7
      C8BCE6C5B8F9FDFEF9FDFEF9FDFEC7663FC33E0CB84618936035936035B5704B
      D3765CD4785BD47555D06842CD6239CC5E33C74D1DF9FDFEF7F5F4CA7252C23D
      0FC24119AD5428936035FF00FF936035CD7C64D6816AD7836AD8846BD8856BD8
      846AD77F63F9FDFED59B89D27154D4775CC86F55936035FF00FFFF00FF936035
      B17855D88B7ADA8E7BDA8E7BDA8E7ADA8D79DB8C78D58974D78570D98974D483
      70B07450936035FF00FFFF00FFFF00FF936035B37F5DD79886E09E90E09E8FDF
      9D8EDF9C8CDF9A8ADE9888D38F7DB27B59936035FF00FFFF00FFFF00FFFF00FF
      FF00FF936035936035BE8E71D6A28FE4AEA1E4ADA0D5A08CBE8B6E9360359360
      35FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF93603593603593
      6035936035936035936035FF00FFFF00FFFF00FFFF00FFFF00FF}
    TabOrder = 17
    Visible = False
    OnClick = ApplyBitBtnClick
  end
  object EditName: TEdit
    Left = 51
    Top = 416
    Width = 286
    Height = 24
    Hint = 'Enter a descriptive name'
    MaxLength = 255
    ParentShowHint = False
    ShowHint = True
    TabOrder = 12
    OnKeyDown = EditNameKeyDown
    OnKeyUp = EditNameKeyUp
  end
  object EditXCoord: TEdit
    Left = 5
    Top = 286
    Width = 163
    Height = 23
    Hint = 'Enter x coordinate'
    Anchors = [akTop, akRight]
    AutoSize = False
    TabOrder = 3
    OnEnter = EditXCoordEnter
    OnExit = EditCoordExit
    OnKeyPress = ParseKeyPress
    OnKeyUp = EditXCoordKeyUp
  end
  object EditYCoord: TEdit
    Left = 174
    Top = 286
    Width = 163
    Height = 23
    Hint = 'Enter y coordinate then press return to add to data'
    Anchors = [akTop, akRight]
    AutoSize = False
    TabOrder = 4
    OnEnter = EditYCoordEnter
    OnExit = EditCoordExit
    OnKeyPress = ParseKeyPress
    OnKeyUp = EditYCoordKeyUp
  end
  object CloseBitBtn: TBitBtn
    Left = 227
    Top = 657
    Width = 75
    Height = 27
    Cursor = crHandPoint
    Hint = 'Close'
    Caption = '&Close'
    Glyph.Data = {
      F6000000424DF600000000000000760000002800000010000000100000000100
      040000000000800000000000000000000000100000001000000000000000FFFF
      000000008400FF00FF0000FFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00330000000000
      0333330244444444033333022444444403333302224444440333330222044444
      0333330222044444033333022204444403333302220444440333330222044444
      0333330222044444033333022240444403333302220444440333330222044444
      0333330212044444033333021104444403333300000000000333}
    TabOrder = 18
    OnClick = CloseBitBtnClick
  end
  object EditPen: TEdit
    Left = 122
    Top = 387
    Width = 30
    Height = 24
    Hint = 'Enter a pen width'
    MaxLength = 2
    ParentShowHint = False
    ShowHint = True
    TabOrder = 9
    Text = '1'
    OnChange = EditPenChange
    OnKeyDown = EditNameKeyDown
    OnKeyPress = IntKeyPress
    OnKeyUp = EditPenKeyUp
  end
  object PenUpDown: TUpDown
    Left = 152
    Top = 387
    Width = 16
    Height = 24
    Cursor = crHandPoint
    Hint = 'Alter the pen width'
    Associate = EditPen
    Min = 1
    Max = 10
    ParentShowHint = False
    Position = 1
    ShowHint = True
    TabOrder = 10
    TabStop = True
    Thousands = False
  end
  object PenPanel: TPanel
    Tag = 2
    Left = 310
    Top = 386
    Width = 24
    Height = 24
    Cursor = crHandPoint
    Hint = 'Select plot color'
    Color = clBlack
    ParentBackground = False
    TabOrder = 11
    OnClick = ColorClick
  end
  object DataListBox: TListBox
    Left = 5
    Top = 23
    Width = 332
    Height = 131
    Hint = 'Adding data.'
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'DejaVu Sans Mono'
    Font.Style = []
    ParentFont = False
    ParentShowHint = False
    ShowHint = True
    TabOrder = 0
    OnClick = DataListBoxClick
    OnKeyDown = DataListBoxKeyDown
  end
  object InputRG: TRadioGroup
    Left = 6
    Top = 157
    Width = 331
    Height = 41
    Hint = 'Adding: Enter coordinates & press enter.'
    Caption = '  Input Options  '
    Columns = 3
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Tahoma'
    Font.Style = []
    ItemIndex = 0
    Items.Strings = (
      'Adding'
      'Editing'
      'Deleting')
    ParentFont = False
    TabOrder = 1
    OnClick = InputRGClick
  end
  object PointsCheckBox: TCheckBox
    Left = 186
    Top = 317
    Width = 53
    Height = 18
    Hint = 'Show or hide graph plot points'
    Caption = 'Show'
    TabOrder = 6
    OnClick = PointsCheckBoxClick
  end
  object SortCheckBox: TCheckBox
    Left = 6
    Top = 200
    Width = 95
    Height = 17
    Hint = 
      'Check to sort the coordinate data when entering x cordinate valu' +
      'e'
    Caption = 'Sort X values'
    Checked = True
    State = cbChecked
    TabOrder = 2
    OnClick = SortCheckBoxClick
  end
  object PointsRG: TRadioGroup
    Left = 5
    Top = 337
    Width = 332
    Height = 45
    Cursor = crHandPoint
    Caption = ' Style '
    Columns = 4
    ItemIndex = 0
    Items.Strings = (
      'Square'
      'Plus'
      'Cross'
      'Circle')
    TabOrder = 8
    OnClick = PointsRGClick
  end
  object PointPanel: TPanel
    Tag = 1
    Left = 310
    Top = 315
    Width = 24
    Height = 24
    Cursor = crHandPoint
    Hint = 'Select point color'
    Color = clBlack
    ParentBackground = False
    TabOrder = 7
    OnClick = PointColorClick
  end
  object GraphRG: TRadioGroup
    Left = 5
    Top = 571
    Width = 332
    Height = 49
    Hint = 'Lines point to point are displayed.'
    Caption = ' Interpolation '
    Columns = 4
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Tahoma'
    Font.Style = []
    ItemIndex = 1
    Items.Strings = (
      'None'
      'Linear'
      'Lagrange'
      'Hermite')
    ParentFont = False
    TabOrder = 14
    OnClick = GraphRGClick
  end
  object PointSizeTB: TTrackBar
    Left = 63
    Top = 315
    Width = 121
    Height = 20
    Cursor = crHandPoint
    Hint = 'Select a point size'
    Min = 1
    PageSize = 1
    Position = 2
    TabOrder = 5
    OnChange = PointSizeTBChange
  end
  object ExtrapolateCB: TCheckBox
    Left = 244
    Top = 630
    Width = 86
    Height = 17
    Caption = 'Extrapolate'
    TabOrder = 16
    OnClick = ExtrapolateCBClick
  end
  object CurveTB: TTrackBar
    Left = 98
    Top = 627
    Width = 141
    Height = 20
    Cursor = crHandPoint
    Hint = 'Adjust curve of plot'
    Max = 150
    Min = -10
    PageSize = 1
    Position = 5
    TabOrder = 15
    OnChange = CurveTBChange
  end
  object CoordsRG: TRadioGroup
    Left = 6
    Top = 222
    Width = 331
    Height = 41
    Caption = '  Plot/Enter Coordinates as...  '
    Columns = 3
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Tahoma'
    Font.Style = []
    ItemIndex = 0
    Items.Strings = (
      'Cartesian {X,Y}'
      'Polar { '#216', r}'
      'As a Vector')
    ParentFont = False
    TabOrder = 19
    OnClick = CoordsRGClick
  end
  object ColorDialog: TColorDialog
    Options = [cdFullOpen]
    Left = 132
    Top = 236
  end
end