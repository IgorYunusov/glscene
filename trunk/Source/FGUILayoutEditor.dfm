object layouts_form: Tlayouts_form
  Left = 208
  Top = 187
  BorderIcons = [biSystemMenu]
  Caption = 'GUI Layout Editor'
  ClientHeight = 419
  ClientWidth = 600
  Color = clBtnFace
  Constraints.MinHeight = 420
  Constraints.MinWidth = 600
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = True
  Position = poOwnerFormCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 600
    Height = 41
    Align = alTop
    TabOrder = 0
    DesignSize = (
      600
      41)
    object x_label: TLabel
      Left = 415
      Top = 9
      Width = 13
      Height = 13
      Anchors = [akTop, akRight]
      Caption = 'X: '
      Color = clBtnFace
      ParentColor = False
    end
    object y_label: TLabel
      Left = 415
      Top = 25
      Width = 13
      Height = 13
      Anchors = [akTop, akRight]
      Caption = 'Y: '
      Color = clBtnFace
      ParentColor = False
    end
    object open_image_button: TBitBtn
      Left = 8
      Top = 10
      Width = 81
      Height = 25
      Caption = 'Load skin'
      Glyph.Data = {
        36050000424D3605000000000000360400002800000010000000100000000100
        08000000000000010000C40E0000C40E00000001000000010000000000007030
        1000503830005040300060504000705850008030100080381000803820008040
        2000804820008048300080605000A0685000A070500090686000907060009078
        7000A078600000FF000090807000A0807000B0807000B08870002050C0002050
        D0003060D0004090D00070C0FF00B0908000B0988000B0A09000C0908000C098
        8000C0989000C0A09000C0A89000D0A09000D0A89000C0A8A000D0B0A000D0B8
        A000D0B0B000D0B8B000E0B0A000E0B8A000F0B8A000E0B8B000D0C0B000FFC0
        A000E0C0B000FFC8B000D0C8D000FFD0C000FFD8C000F0D0D000F0D8D000F0E0
        D000FFE0D000D0D8F000C0E8FF00F0E0E000F0E8E000FFE8E000FFF0E000F0F0
        F000FFF0F000FFF8F000FFF8FF00FFFFFF000000000000000000000000000000
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
        0000000000000000000000000000000000000000000000000000131313131313
        13131313131313131313130D0B0A0A0909090807070601010113130E39292120
        1715100F0C0402020113131241383226252117150C030504011313124442392D
        262523150314110006131316154142392C2F2605271F001D071313173D153E3E
        372B053030002E1E07131320453D153E38042804042C31220813132145453D15
        15383A3635333323091313234545454342403419182A33260913132445454545
        43421A1C1B183528091313264545454545431A3C1C19362C0A13132645454545
        45453B1A1A343A2D0A131326454545454545454342403F3A0B13132626262624
        232120171612120E0D1313131313131313131313131313131313}
      TabOrder = 0
      OnClick = open_image_buttonClick
    end
    object open_button: TBitBtn
      Left = 95
      Top = 10
      Width = 89
      Height = 25
      Caption = 'Open'
      Glyph.Data = {
        36030000424D3603000000000000360000002800000010000000100000000100
        18000000000000030000000000000000000000000000000000000000FF0000FF
        0000FF0000FF0000FF0000FF0000FF0000FF0000FF0000FF0000FF0000FF0000
        FF0000FF0000FF0000FF738A9463829463798452718452617342596342495231
        38422130312120311018211010101010210000FF0000FF0000FF738A9494A2B5
        73B2D60092D60092D60092D60092C6108AC61082B51082B52179A52171942149
        630000FF0000FF0000FF848A9484C3D694AAB584E3FF63D3FF52CBFF52CBFF42
        C3F731B2F731AAF721A2E71092D62169846359520000FF0000FF8492A584D3F7
        94AAB594C3D673DBFF63D3FF63D3FF52CBFF52C3FF42BAF731B2F731AAF7108A
        D62149630000FF0000FF8492A584DBF784CBE794AAB584E3FF73D3FF63DBFF63
        D3FF63D3FF52CBFF42C3F742BAF731B2F72169846B7D7B0000FF849AA594E3F7
        94E3FF94AAB594BAC673DBFF63DBFF63DBFF63DBFF63D3FF52D3FF52CBFF42BA
        F731A2E74A65730000FF849AA594E3F7A5EBFF84CBE794AAB584E3FF84E3FF84
        E3FF84E3FF84E3FF84E3FF84E3FF73DBFF73DBFF52AAD68C827B94A2A5A5EBF7
        A5EBFFA5EBFF94B2C694B2C694AAB594AAB584A2B584A2B5849AA5849AA58492
        A58492A5848A94738A9494A2B5A5EBF7A5F3FFA5EBFFA5EBFF84DBFF63DBFF63
        DBFF63DBFF63DBFF63DBFF63DBFF738A940000FF0000FF0000FF94A2B5A5F3F7
        B5F3F7A5F3FFA5EBFFA5EBFF73DBFF94A2A5849AA5849AA58492A5849294738A
        940000FF0000FF0000FF94AAB5A5D3E7B5F3F7B5F3F7A5F3FFA5EBFF94A2B5BD
        C7BD0000FF0000FF0000FF0000FF0000FF9469529469529469520000FF94AAB5
        94AAB594AAB594AAB594AAB5BDC3BD0000FF0000FF0000FF0000FF0000FF0000
        FF0000FF9469529469520000FF0000FF0000FF0000FF0000FF0000FF0000FF00
        00FF0000FF947963CEAA940000FF0000FFA592840000FF9479630000FF0000FF
        0000FF0000FF0000FF0000FF0000FF0000FF0000FF0000FFA59284A58A84B59A
        84C6AA940000FF0000FF0000FF0000FF0000FF0000FF0000FF0000FF0000FF00
        00FF0000FF0000FF0000FF0000FF0000FF0000FF0000FF0000FF}
      TabOrder = 1
      OnClick = open_buttonClick
    end
    object save_button: TBitBtn
      Left = 191
      Top = 10
      Width = 89
      Height = 25
      Caption = 'Save'
      Glyph.Data = {
        36030000424D3603000000000000360000002800000010000000100000000100
        18000000000000030000000000000000000000000000000000000000FF0000FF
        C66963B55952A55152A55152A551529449529449429449428441428438428438
        427338427338310000FF0000FFD66973F79294E78284B54921423021C6BAB5C6
        BAB5D6C3C6D6CBC6525152A54131A54131A538317338420000FF0000FFD67173
        FF9AA5F78A84E78284735952424131947973F7E3E7F7EBE7948273A54131A541
        42A541318438420000FF0000FFD67973FFA2A5F79294F78A8473595200000042
        4131F7DBD6F7E3D6847963B54942B54942A541428441420000FF0000FFD67984
        FFAAB5FFA2A5F79294735952735952735952735952736152846963C65952B551
        52B549428441420000FF0000FFE78284FFB2B5FFB2B5FFA2A5F79294F78A84E7
        8284E77984D67173D66973C66163C65952B551529449420000FF0000FFE78A94
        FFBAC6FFBAB5D66163C66152C65952C65142B55131B54931A54121A53810C661
        63C659529449420000FF0000FFE79294FFC3C6D66963FFFFFFFFFFFFFFFBF7F7
        F3F7F7EBE7F7DBD6E7D3C6E7CBC6A53810C661639449520000FF0000FFE79AA5
        FFC3C6D67173FFFFFFFFFFFFFFFFFFFFFBF7F7F3F7F7EBE7F7DBD6E7D3C6A541
        21D66963A551520000FF0000FFF7A2A5FFC3C6E77973FFFFFFFFFFFFFFFFFFFF
        FFFFFFFBF7F7F3F7F7EBE7F7DBD6B54931D67173A551520000FF0000FFF7AAA5
        FFC3C6E78284FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFBF7F7F3F7F7EBE7B551
        31E77984A551520000FF0000FFF7B2B5FFC3C6F78A94FFFFFFFFFFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFBF7F7F3F7C65142633031B559520000FF0000FFF7B2B5
        FFC3C6FF9294FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFBF7C659
        52B55963B559630000FF0000FFF7BAB5F7BAB5F7B2B5F7B2B5F7AAB5F7A2A5E7
        9AA5E79294E79294E78A94E78284D67984D67973D671730000FF0000FF0000FF
        0000FF0000FF0000FF0000FF0000FF0000FF0000FF0000FF0000FF0000FF0000
        FF0000FF0000FF0000FF0000FF0000FF0000FF0000FF0000FF0000FF0000FF00
        00FF0000FF0000FF0000FF0000FF0000FF0000FF0000FF0000FF}
      TabOrder = 2
      OnClick = save_buttonClick
    end
    object BitBtn4: TBitBtn
      Tag = 1
      Left = 488
      Top = 10
      Width = 25
      Height = 25
      Anchors = [akTop, akRight]
      Glyph.Data = {
        36030000424D3603000000000000360000002800000010000000100000000100
        18000000000000030000000000000000000000000000000000000000FFA5A6A5
        9C9A9CADAEAD0000FF0000FF0000FF0000FF0000FF0000FF0000FF0000FF0000
        FF0000FF0000FF0000FF8C8E8C5A6163424D52737173ADAAAD0000FF0000FF00
        00FF0000FF0000FF0000FF0000FF0000FF0000FF0000FF0000FF8C96A53186C6
        18699C394952636563A5A2A50000FF0000FF0000FF0000FF0000FF0000FF0000
        FF0000FF0000FF0000FF94CBDE39A2F71879CE216DA5314D5A6361639C9E9C00
        00FF0000FF0000FF0000FF0000FF0000FF0000FF0000FF0000FF0000FF94CFDE
        42AAF71882D61871A53151635A5D5AA5A6A50000FF0000FF0000FF0000FF0000
        FF0000FF0000FF0000FF0000FF0000FF9CCFDE4AAEF71882DE1871AD4A555A7B
        797B8C8E8C7375736B696B7B797B0000FF0000FF0000FF0000FF0000FF0000FF
        0000FFA5CBD65ABAF7739EBD8C86847361639C827BC6AEA5BDA6A58C75735249
        4A7371730000FF0000FF0000FF0000FF0000FF0000FFB5C3C6BDB6B5BDA6A5E7
        CFADF7E7C6FFFFEFFFFFFFFFFFFFDEC7C65A494A7375730000FF0000FF0000FF
        0000FF0000FF0000FFA58E8CEFD7B5E7CF94EFE7CEFF714AD6B66BFFFFFFFFFF
        FFCEB6AD524D4A0000FF0000FF0000FF0000FF0000FF0000FFBD9E94E7D3A5DE
        BA84E7CBA5FF0000D6B66BF7DBBDF7E3C6EFDFBD6B595A0000FF0000FF0000FF
        0000FF0000FF0000FFC6AE9CE7D39CFF714AFF0000FF0000FF0000FF714AE7B6
        7BF7DFB57B69630000FF0000FF0000FF0000FF0000FF0000FFBD9E94EFDFB5E7
        CB9CEFDFBDFF0000E7C794E7C794DEBE84EFDBB57365630000FF0000FF0000FF
        0000FF0000FF0000FFB59A9CE7CFADFFFFF7FFFFFFFF714AE7C794D6B66BEFDB
        ADC6AE9C8482840000FF0000FF0000FF0000FF0000FF0000FF0000FFAD928CDE
        CBBDFFFBEFFFF7DEEFDFB5EFDFB5CEAE9C8C7D7B0000FF0000FF0000FF0000FF
        0000FF0000FF0000FF0000FF0000FFB5A2A5B5968CBD9E8CBD9E8CA5928CA59E
        9C0000FF0000FF0000FF0000FF0000FF0000FF0000FF0000FF0000FF0000FF00
        00FF0000FF0000FF0000FF0000FF0000FF0000FF0000FF0000FF}
      TabOrder = 3
      OnClick = BitBtn4Click
    end
    object BitBtn5: TBitBtn
      Tag = -1
      Left = 520
      Top = 10
      Width = 25
      Height = 25
      Anchors = [akTop, akRight]
      Glyph.Data = {
        36030000424D3603000000000000360000002800000010000000100000000100
        18000000000000030000000000000000000000000000000000000000FFA5A6A5
        A5A2A59C9E9C0000FF0000FF0000FF0000FF0000FF0000FF0000FF0000FF0000
        FF0000FF0000FF0000FF8C8E8C5A6163525D63424D527B7D7B0000FF0000FF00
        00FF0000FF0000FF0000FF0000FF0000FF0000FF0000FF0000FF8C96A53186C6
        2982C62165943949527375730000FF0000FF0000FF0000FF0000FF0000FF0000
        FF0000FF0000FF0000FF94CBDE39A2F7319EF71879C621699439495273757300
        00FF0000FF0000FF0000FF0000FF0000FF0000FF0000FF0000FF0000FF94CFDE
        94CFE7399EF7187DCE2169943945527B7D7B0000FF0000FF0000FF0000FF0000
        FF0000FF0000FF0000FF0000FF0000FFBDC3C68CCFE739A2F71079CE316D9452
        51528C8A8C8482846B6D6B7375730000FF0000FF0000FF0000FF0000FF0000FF
        0000FFBDC3C694CFDE52A6E78496A57B716B846D6BB59E94BDAAA594827B5A4D
        4A6365630000FF0000FF0000FF0000FF0000FF0000FFBDBEBDBDC7CECEBAB5CE
        AE9CF7DFBDFFF3DEFFFFFFFFFFFFEFDFDE6355527371730000FF0000FF0000FF
        0000FF0000FF0000FFBDBABDBDA29CEFDBADE7D7ADF7EFDEFFFFFFFFFFFFFFFF
        FFD6BEB5524D4A0000FF0000FF0000FF0000FF0000FF0000FFADA2A5DECBB5E7
        CB8CFF714AFF714AFF714AFF714AEFCBA5F7E7CE6B5D5A0000FF0000FF0000FF
        0000FF0000FF0000FFB5A29CE7D7BDDEBE7BDE4900DE4900DE4900DE4900DEAA
        6BF7DFB57B6D6B0000FF0000FF0000FF0000FF0000FF0000FFB5AAADDECBADE7
        CF9CE7D3A5EFDBB5E7D3A5DEC794DEBE84EFD7AD7B69630000FF0000FF0000FF
        0000FF0000FF0000FFBDBABDB59A8CF7F3D6FFFBF7F7E7CEDEC38CCEA652E7CF
        94DEBEAD84797B0000FF0000FF0000FF0000FF0000FF0000FF0000FFB5AAADC6
        A694FFF3EFFFFBEFEFDFB5EFDBADE7CBB58C797BB5B6B50000FF0000FF0000FF
        0000FF0000FF0000FF0000FF0000FFBDB2B5B5968CC6A28CC6A694B5968C9C8E
        8CBDBABD0000FF0000FF0000FF0000FF0000FF0000FF0000FF0000FF0000FF00
        00FF0000FF0000FF0000FF0000FF0000FF0000FF0000FF0000FF}
      TabOrder = 4
      OnClick = BitBtn4Click
    end
    object BitBtn6: TBitBtn
      Left = 568
      Top = 10
      Width = 25
      Height = 25
      Anchors = [akTop, akRight]
      Glyph.Data = {
        36050000424D3605000000000000360400002800000010000000100000000100
        08000000000000010000C40E0000C40E00000001000000010000703010004038
        3000503830005040400050484000705840007058500070686000803010008038
        100080382000804020008048200080483000A0502000B0583000B0603000C060
        300080685000A070500090786000A0786000C0684000C0704000D0704000D078
        4000E07E580000FF0000B0806000A0807000A0887000B0807000B0887000D48C
        5C00E0805000F0885000D0886000E0886000E18C6200E0906000F0906000FF90
        6000E09870003048C0003058D0002078D0005068D0006070C0006070D00050A0
        F00050A8F000A0888000A0908000B0908000B0989000B0A09000C0908000C098
        8000C99D8900D0988000D0A08000C0A09000C0A89000D0A89000F8A58100FFA8
        8000E3AD9200E4B49C00C0A8A000D2B1A200D5B9AC00C0B8B000E0B0A000E5C1
        AF00F0C0A000F0C0B0009098D000A0A8E00090C0F000D0C0D000F0C8C000F0D0
        C000E0D8D000F0D8D000FFD8D000E0E0D000F0E0D000F0E8E000E0E0F000E0E8
        F000F0E8F000FFF0F000FFF8F000FFF8FF00FFFFFF0000000000000000000000
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
        00000000000000000000000000000000000000000000000000001B1B1B1B1B15
        0D0D0C0B0B0A090800001B1B1B1B1B1C5B3F39381D14120204001B1B1B1B1B20
        5E56483C3B39021E01001B1B1B1B1B20375D56483F06470703091B1B1B1B1B35
        57365C56053334024A091B1B1B1B1B395E523633444444544B0A1B1B1B1B1B3D
        5E5E5553582E2C4F500B1B1B1B1B1B3D5E5E5E5E30312D2B510B1B1B1B171B3E
        5E5B3B5E4C4E322F530B1B1B170F1B3F5C3B0E5E594D4C5A5B0C1B17210F3A24
        170E0F3935201F151513172840180F111016461B1B1B1B1B1B1B2A4129232225
        1A451B1B1B1B1B1B1B1B1B2A41264243491B1B1B1B1B1B1B1B1B1B1B2A191B1B
        1B1B1B1B1B1B1B1B1B1B1B1B1B271B1B1B1B1B1B1B1B1B1B1B1B}
      TabOrder = 5
      OnClick = BitBtn6Click
    end
    object BitBtn1: TBitBtn
      Left = 286
      Top = 10
      Width = 89
      Height = 25
      Caption = 'Done'
      Glyph.Data = {
        EE040000424DF004000000000000360400002800000010000000100000000100
        08000100000000000000120B0000120B00000000000000000000000000000000
        80000080000000808000800000008000800080800000C0C0C000C0DCC000F0CA
        A6000020400000206000002080000020A0000020C0000020E000004000000040
        20000040400000406000004080000040A0000040C0000040E000006000000060
        20000060400000606000006080000060A0000060C0000060E000008000000080
        20000080400000806000008080000080A0000080C0000080E00000A0000000A0
        200000A0400000A0600000A0800000A0A00000A0C00000A0E00000C0000000C0
        200000C0400000C0600000C0800000C0A00000C0C00000C0E00000E0000000E0
        200000E0400000E0600000E0800000E0A00000E0C00000E0E000400000004000
        20004000400040006000400080004000A0004000C0004000E000402000004020
        20004020400040206000402080004020A0004020C0004020E000404000004040
        20004040400040406000404080004040A0004040C0004040E000406000004060
        20004060400040606000406080004060A0004060C0004060E000408000004080
        20004080400040806000408080004080A0004080C0004080E00040A0000040A0
        200040A0400040A0600040A0800040A0A00040A0C00040A0E00040C0000040C0
        200040C0400040C0600040C0800040C0A00040C0C00040C0E00040E0000040E0
        200040E0400040E0600040E0800040E0A00040E0C00040E0E000800000008000
        20008000400080006000800080008000A0008000C0008000E000802000008020
        20008020400080206000802080008020A0008020C0008020E000804000008040
        20008040400080406000804080008040A0008040C0008040E000806000008060
        20008060400080606000806080008060A0008060C0008060E000808000008080
        20008080400080806000808080008080A0008080C0008080E00080A0000080A0
        200080A0400080A0600080A0800080A0A00080A0C00080A0E00080C0000080C0
        200080C0400080C0600080C0800080C0A00080C0C00080C0E00080E0000080E0
        200080E0400080E0600080E0800080E0A00080E0C00080E0E000C0000000C000
        2000C0004000C0006000C0008000C000A000C000C000C000E000C0200000C020
        2000C0204000C0206000C0208000C020A000C020C000C020E000C0400000C040
        2000C0404000C0406000C0408000C040A000C040C000C040E000C0600000C060
        2000C0604000C0606000C0608000C060A000C060C000C060E000C0800000C080
        2000C0804000C0806000C0808000C080A000C080C000C080E000C0A00000C0A0
        2000C0A04000C0A06000C0A08000C0A0A000C0A0C000C0A0E000C0C00000C0C0
        2000C0C04000C0C06000C0C08000C0C0A000F0FBFF00A4A0A000808080000000
        FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00100300000403
        02040A0300000303010402020104090300000203010404020104080300000103
        010406020104070300000104030201FA040201040603000003020003FA03FA00
        03020104060300000003FA02FA00030301FA0302010405030000010301FA0503
        01FA0302010404030000080301FA0302010403030000090301FA030201040203
        00000A0301FA03020104010400000B0301FA0302010200000C0301FA02020102
        00000D0301FA020200000E0301FA01FA0000}
      ModalResult = 1
      TabOrder = 6
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 41
    Width = 185
    Height = 378
    Align = alLeft
    TabOrder = 1
    object Label1: TLabel
      Left = 8
      Top = 291
      Width = 10
      Height = 13
      Caption = 'X:'
      Color = clBtnFace
      ParentColor = False
    end
    object Label2: TLabel
      Left = 8
      Top = 315
      Width = 10
      Height = 13
      Caption = 'Y:'
      Color = clBtnFace
      ParentColor = False
    end
    object Label3: TLabel
      Left = 80
      Top = 315
      Width = 34
      Height = 13
      Caption = 'Height:'
      Color = clBtnFace
      ParentColor = False
    end
    object Label4: TLabel
      Left = 80
      Top = 291
      Width = 31
      Height = 13
      Caption = 'Width:'
      Color = clBtnFace
      ParentColor = False
    end
    object Label5: TLabel
      Left = 24
      Top = 155
      Width = 28
      Height = 13
      Caption = 'Name'
      Color = clBtnFace
      ParentColor = False
    end
    object items_list: TListBox
      Left = 8
      Top = 8
      Width = 169
      Height = 105
      ItemHeight = 13
      TabOrder = 0
      OnClick = items_listClick
    end
    object delete_item_button: TBitBtn
      Left = 96
      Top = 120
      Width = 73
      Height = 25
      Caption = 'Delete'
      Glyph.Data = {
        36030000424D3603000000000000360000002800000010000000100000000100
        1800000000000003000000000000000000000000000000000000000080000080
        0000800000800000800000800000800000800000800000800000800000800000
        80000080000080000080000080000080B5A29463493163493163493163493163
        4931634931634931634931634931634931000080000080000080000080000080
        B5A294FFFFFFB5A294B5A294B5A294B5A294B5A294B5A294B5A294B5A2946349
        31000080000080000080000080000080B5A294FFFFFFFFFFFFFFFBFFF7F3F7F7
        EBE7F7E3D6E7D3D6E7CBC6B5A294634931000080000080000080000080000080
        B5A294FFFFFFFFFFFFFFFFFFFFFBF7F7F3F7F7E3E7F7DBD6E7D3C6B5A2946349
        31000080000080000080000080000080B5A294FFFFFFFFFFFFFFFFFFFFFFFFFF
        F3F7F7EBE7F7E3E7E7DBD6B5A294634931000080000080000080000080000080
        C6AA94FFFFFFFFFFFFFFFFFFFFFFFFFFFBF7F7F3F7F7EBE7F7DBD6B5A2946349
        31000080000080000080000080000080C6AAA5FFFFFFFFFFFFFFFFFFFFFFFFFF
        FFFFFFFBF7F7EBE7F7E3E7B5A294634931000080000080000080000080000080
        C6B2A5FFFFFFFFFFFFFFFFFFFFFFFF0000FFFFFBFFF7F3F7F7EBE7B5A2946349
        31000080000080000080000080000080D6B2A5FFFFFFFFFFFFFFFFFFFFFFFF00
        00FF0000FFFFFBF7F7F3F70000FF634931000080000080000080000080000080
        D6BAA5FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000FFFFFFFFB5A2940000FF0000
        FF000080000080000080000080000080D6BAB5FFFFFFFFFFFFFFFFFFFFFFFFFF
        FFFF0000FF0000FF0000FF0000FF634931000080000080000080000080000080
        D6C3B5FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000FF0000FF0000FF0000
        80000080000080000080000080000080E7C3B5FFFFFFFFFFFFFFFFFFFFFFFFFF
        FFFF0000FF0000FF6349310000FF0000FF000080000080000080000080000080
        E7C3B5E7C3B5E7C3B5E7C3B5E7C3B50000FF0000FFD6B2A50000800000800000
        FF0000FF00008000008000008000008000008000008000008000008000008000
        0080000080000080000080000080000080000080000080000080}
      TabOrder = 1
      OnClick = delete_item_buttonClick
    end
    object add_button: TBitBtn
      Left = 17
      Top = 121
      Width = 73
      Height = 25
      Caption = 'Add'
      Glyph.Data = {
        36030000424D3603000000000000360000002800000010000000100000000100
        18000000000000030000000000000000000000000000000000000000FF0000FF
        0000FF0000FF0000FF0000FF0000FF0000FF0000FF0000FF0000FF0000FF0000
        FF0000FF0000FF0000FF0000FF0000FFB5A29463493163493163493163493163
        49316349316349316349316349316349310000FF0000FF0000FF0000FF0000FF
        B5A294FFFFFFB5A294B5A294B5A294B5A294B5A294B5A294B5A294B5A2946349
        310000FF0000FF0000FF0000FF0000FFB5A294FFFFFFFFFFFFFFFBFFF7F3F7F7
        EBE7F7E3D6E7D3D6E7CBC6B5A2946349310000FF0000FF0000FF0000FF0000FF
        B5A294FFFFFFFFFFFFFFFFFFFFFBF7F7F3F7F7E3E7F7DBD6E7D3C6B5A2946349
        310000FF0000FF0000FF0000FF0000FFB5A294FFFFFFFFFFFFFFFFFFFFFFFFFF
        F3F7F7EBE7F7E3E7E7DBD6B5A2946349310000FF0000FF0000FF0000FF0000FF
        C6AA94FFFFFFFFFFFFFFFFFFFFFFFFFFFBF7F7F3F7F7EBE7F7DBD6B5A2946349
        310000FF0000FF0000FF0000FF0000FFC6AAA5FFFFFFFFFFFFFFFFFFFFFFFFFF
        FFFFFFFBF70080000080000080006349310000FF0000FF0000FF0000FF0000FF
        C6B2A5FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFBFF00800000FF000080006349
        310000FF0000FF0000FF0000FF0000FFD6B2A5FFFFFFFFFFFFFFFFFFFFFFFFFF
        FFFFFFFFFF00800000FF000080006349310000FF0000FF0000FF0000FF0000FF
        D6BAA5FFFFFFFFFFFFFFFFFF00800000800000800000800000FF000080000080
        000080000080000000FF0000FF0000FFD6BAB5FFFFFFFFFFFFFFFFFF00800000
        FF0000FF0000FF0000FF0000FF0000FF0000FF000080000000FF0000FF0000FF
        D6C3B5FFFFFFFFFFFFFFFFFF00800000800000800000800000FF000080000080
        000080000080000000FF0000FF0000FFE7C3B5FFFFFFFFFFFFFFFFFFFFFFFFFF
        FFFFFFFFFF00800000FF000080000000FF0000FF0000FF0000FF0000FF0000FF
        E7C3B5E7C3B5E7C3B5E7C3B5E7C3B5D6C3B5D6BAB500800000FF000080000000
        FF0000FF0000FF0000FF0000FF0000FF0000FF0000FF0000FF0000FF0000FF00
        00FF0000FF0080000080000080000000FF0000FF0000FF0000FF}
      TabOrder = 2
      OnClick = add_buttonClick
    end
    object left_edit: TSpinEdit
      Left = 24
      Top = 288
      Width = 49
      Height = 22
      MaxValue = 0
      MinValue = 0
      TabOrder = 3
      Value = 0
      OnChange = left_editChange
    end
    object top_edit: TSpinEdit
      Left = 24
      Top = 312
      Width = 49
      Height = 22
      MaxValue = 0
      MinValue = 0
      TabOrder = 4
      Value = 0
      OnChange = top_editChange
    end
    object height_edit: TSpinEdit
      Left = 128
      Top = 312
      Width = 49
      Height = 22
      MaxValue = 0
      MinValue = 0
      TabOrder = 5
      Value = 0
      OnChange = height_editChange
    end
    object width_edit: TSpinEdit
      Left = 128
      Top = 288
      Width = 49
      Height = 22
      MaxValue = 0
      MinValue = 0
      TabOrder = 6
      Value = 0
      OnChange = width_editChange
    end
    object name_edit: TEdit
      Left = 58
      Top = 152
      Width = 103
      Height = 21
      TabOrder = 7
      OnExit = name_editExit
      OnKeyPress = name_editKeyPress
    end
    object elements_grid: TStringGrid
      Left = 54
      Top = 192
      Width = 78
      Height = 78
      ColCount = 3
      DefaultColWidth = 24
      FixedCols = 0
      RowCount = 3
      FixedRows = 0
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine]
      ParentFont = False
      TabOrder = 8
      OnClick = elements_gridClick
      OnDblClick = elements_gridDblClick
    end
    object Panel3: TPanel
      Left = 40
      Top = 181
      Width = 105
      Height = 4
      TabOrder = 9
    end
  end
  object ScrollBox1: TScrollBox
    Left = 185
    Top = 41
    Width = 415
    Height = 378
    Align = alClient
    BorderStyle = bsNone
    TabOrder = 2
    object PaintBox1: TPaintBox
      Left = 0
      Top = 0
      Width = 201
      Height = 201
    end
    object Image1: TImage
      Left = 0
      Top = 0
      Width = 177
      Height = 177
      AutoSize = True
    end
    object Image2: TImage
      Left = 0
      Top = 0
      Width = 153
      Height = 153
      Cursor = crCross
      Transparent = True
      OnMouseDown = Image1MouseDown
      OnMouseMove = Image1MouseMove
      OnMouseUp = Image1MouseUp
    end
  end
  object OpenDialog1: TOpenDialog
    DefaultExt = '.layout'
    Filter = 'File with ext (*.layout)|*.layout'
    Options = [ofOverwritePrompt, ofPathMustExist, ofFileMustExist, ofEnableSizing, ofDontAddToRecent]
    Left = 200
    Top = 96
  end
  object SaveDialog1: TSaveDialog
    DefaultExt = '.layout'
    Filter = 'File with ext (*.layout)|*.layout'
    Options = [ofPathMustExist, ofEnableSizing, ofDontAddToRecent]
    Left = 248
    Top = 96
  end
  object GLGuiLayout1: TGLGuiLayout
    GuiComponents = <>
    Left = 297
    Top = 97
  end
end
