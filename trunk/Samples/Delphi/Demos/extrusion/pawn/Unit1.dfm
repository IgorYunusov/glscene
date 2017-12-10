object Form1: TForm1
  Left = 166
  Top = 89
  BorderWidth = 3
  Caption = 'Pawn'
  ClientHeight = 379
  ClientWidth = 510
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object GLSceneViewer1: TGLSceneViewer
    Left = 0
    Top = 0
    Width = 381
    Height = 379
    Camera = GLCamera1
    Buffer.BackgroundColor = clBackground
    FieldOfView = 150.438476562500000000
    Align = alClient
    OnMouseDown = GLSceneViewer1MouseDown
    OnMouseMove = GLSceneViewer1MouseMove
    TabOrder = 0
  end
  object Panel1: TPanel
    Left = 381
    Top = 0
    Width = 129
    Height = 379
    Align = alRight
    TabOrder = 1
    object Label1: TLabel
      Left = 23
      Top = 8
      Width = 59
      Height = 18
      Caption = 'Options'
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'Arial'
      Font.Style = [fsBold, fsItalic]
      ParentFont = False
    end
    object Label3: TLabel
      Left = 38
      Top = 149
      Width = 28
      Height = 13
      Caption = 'Slices'
    end
    object Label4: TLabel
      Left = 40
      Top = 205
      Width = 42
      Height = 13
      Caption = 'Divisions'
    end
    object Label2: TLabel
      Left = 44
      Top = 247
      Width = 22
      Height = 13
      Caption = 'Stop'
    end
    object LabelTri: TLabel
      Left = 16
      Top = 312
      Width = 43
      Height = 13
      Caption = 'Triangles'
    end
    object CheckBox1: TCheckBox
      Left = 9
      Top = 49
      Width = 113
      Height = 17
      Caption = 'Spline interpolation'
      Checked = True
      State = cbChecked
      TabOrder = 0
      OnClick = CheckBox1Click
    end
    object CheckBox2: TCheckBox
      Left = 9
      Top = 72
      Width = 113
      Height = 17
      Caption = 'Normals smoothing'
      Checked = True
      State = cbChecked
      TabOrder = 1
      OnClick = CheckBox2Click
    end
    object CheckBox3: TCheckBox
      Left = 9
      Top = 97
      Width = 113
      Height = 17
      Caption = 'Texture map'
      Checked = True
      State = cbChecked
      TabOrder = 2
      OnClick = CheckBox3Click
    end
    object CheckBox4: TCheckBox
      Left = 9
      Top = 120
      Width = 113
      Height = 17
      Caption = 'Modulate texture'
      Checked = True
      State = cbChecked
      TabOrder = 3
      OnClick = CheckBox4Click
    end
    object TrackBar2: TTrackBar
      Left = 9
      Top = 168
      Width = 113
      Height = 17
      Max = 64
      Min = 4
      Frequency = 16
      Position = 24
      TabOrder = 4
      ThumbLength = 10
      OnChange = TrackBar2Change
    end
    object TrackBar3: TTrackBar
      Left = 9
      Top = 224
      Width = 113
      Height = 17
      Max = 30
      Min = 1
      Frequency = 10
      Position = 10
      TabOrder = 5
      ThumbLength = 10
      OnChange = TrackBar3Change
    end
    object TrackBar1: TTrackBar
      Left = 9
      Top = 266
      Width = 113
      Height = 17
      Max = 360
      Min = 30
      Frequency = 45
      Position = 360
      TabOrder = 6
      ThumbLength = 10
      OnChange = TrackBar1Change
    end
  end
  object GLScene1: TGLScene
    Left = 8
    Top = 8
    object GLLightSource1: TGLLightSource
      ConstAttenuation = 1.000000000000000000
      Position.Coordinates = {0000484200004842000048420000803F}
      SpotCutOff = 180.000000000000000000
    end
    object DummyCube1: TGLDummyCube
      CubeSize = 1.000000000000000000
      object RotationSolid1: TGLRevolutionSolid
        Material.Texture.Image.Picture.Data = {
          0A544A504547496D61676553240000FFD8FFE000104A46494600010101004800
          480000FFDB0043000503040404030504040405050506070C08070707070F0B0B
          090C110F1212110F111113161C1713141A1511111821181A1D1D1F1F1F131722
          24221E241C1E1F1EFFDB0043010505050706070E08080E1E1411141E1E1E1E1E
          1E1E1E1E1E1E1E1E1E1E1E1E1E1E1E1E1E1E1E1E1E1E1E1E1E1E1E1E1E1E1E1E
          1E1E1E1E1E1E1E1E1E1E1E1E1EFFC00011080100010003012200021101031101
          FFC4001F0000010501010101010100000000000000000102030405060708090A
          0BFFC400B5100002010303020403050504040000017D01020300041105122131
          410613516107227114328191A1082342B1C11552D1F02433627282090A161718
          191A25262728292A3435363738393A434445464748494A535455565758595A63
          6465666768696A737475767778797A838485868788898A92939495969798999A
          A2A3A4A5A6A7A8A9AAB2B3B4B5B6B7B8B9BAC2C3C4C5C6C7C8C9CAD2D3D4D5D6
          D7D8D9DAE1E2E3E4E5E6E7E8E9EAF1F2F3F4F5F6F7F8F9FAFFC4001F01000301
          01010101010101010000000000000102030405060708090A0BFFC400B5110002
          0102040403040705040400010277000102031104052131061241510761711322
          328108144291A1B1C109233352F0156272D10A162434E125F11718191A262728
          292A35363738393A434445464748494A535455565758595A636465666768696A
          737475767778797A82838485868788898A92939495969798999AA2A3A4A5A6A7
          A8A9AAB2B3B4B5B6B7B8B9BAC2C3C4C5C6C7C8C9CAD2D3D4D5D6D7D8D9DAE2E3
          E4E5E6E7E8E9EAF2F3F4F5F6F7F8F9FAFFDA000C03010002110311003F0040D1
          EDC097F5A52A841FDF119FF6AAA0D3E327BE31C60D3D2CA245C0C9CFA9AF8BB1
          F484AAB1A2E3CFCFB939A5464C643A62A31611E73CE28FB1C6B901588239C516
          026F3550755FCE813478277A818F5A6A5ADBE0718F6A536D6C5C9F2C71ED4AC3
          13ED319E03C7F89A4FB4A91B7E4C63A834AD696E33FB95E6836D6FDA0EBED458
          2E8433A0500BAE31EB51ADC4215879AC7F1A93CB81067CAC7FC06811DB373E58
          39F6C530221796C46DF39876E4D3FCFB720133B0C7FB54C7B30CDCDB02B9E30D
          424200CFD83E9861420D004D0EE2DE6353C5FDAA8DA656C9E94E44001DD6E47B
          0229C91C07198F1ED8A0442351B61905987E14ABA85B1FE273F41563C9B72082
          ABEF4D786CC29C88C0C52190B6A16C0F2CE33EA290EA36C700331FC2AC08ACD9
          46046463834BE4DB800055F6A0080DFDAB0DA256C8EB4C3343B83798D53BC700
          CE23CFB629AE8081B6DC9F6245310DF3EDC0244EC73FED530DE5B01B7CE63DB8
          343C208CFD83EB9614259856E2D805CF396A18F415AE212AA3CD61F8D482742A
          4075C63D6831DB2F3E5818F6CD1E5C0E33E567FE0340681F695036FC98C75269
          4DCC6382F1FE06816D6FDE0E9ED42DA5B9C7EE578A560BA1C668F00EF5231EB4
          79AAE3AAFE7482DAD8383E58E7DA91ED6DF078CFB516103B26325D3148CB1BAE
          3CFC7B838A67D8E36C02AC001C6683611E73CE29D80982A003F7C4E3FDAA42D1
          EDC197F5A81ECA275C1C8C7A1A61D3E307BE31CE4D160162177D5A41F4C53C8B
          C3C0718C7A5316F940CF9669FF006D27A47D7A734C7A8805D60E67FA71479374
          4733529BB7FF009E27F3A6497D30E16D49F7CD2BA0B36385BCE47CD2FD38A5FB
          24AC78B96FA545F6FB9FF9F5C7AE4D385FCB924DB818ED45D05980B19D739BAF
          CEA44B4900E6E1CFB0AACD7F29CE1557EB4E8EF26DBC14EBDE81EA58366C5799
          588CFAD1F63917EECADF4DD51B5DDC6C276A923DE923B9BB2325500349316A3F
          EC93ED39663F46A60B3941C79D20FAD49F68B93F7557EB51B4B7BCE3CBFA914E
          E166235A4A011E7B827BF34D8ACE5CFCCF919F5352096F0F5D8298EF76A01329
          27D852B8D5C77D8E40C40C6DFAF5A86E2DC721E066EDF29ED42497A5F990E3E9
          4924B73939761F45A770B0E820C80160D98E304D4BF6390B0071B7EBD2A149EE
          881866F72568792F43F121C7D286C1263E5B3973F2BE067D4D396D25200F3DC9
          1DF9A447BB60489483EE29E65BC1D361A5706843672938F3A43F4A7FD927DA30
          CC3EAD4C596F78CF97F502A4FB45C8FBCABF5A771598BF6391BEF4ADF4DD40B3
          60BC4AC067D6A292E6EC0C8542052ADDDC6C076A827DE95C351EF69211C5C38F
          63519B19DB18BAFCA9925E4DB7929D7B5356FE518CAAB7D298F52C7D92553CDC
          B7D290DBCE07CB2FD78A69BF97208B7073DA9BF6FB9FF9F5CFA60D1742B324F2
          6E80E26A08BAC0C4FF005E29B1DF4C786B523DF34F176FFF003C4FE745C2CD00
          178382E318F4A64A2EFAAC83E98A79BD23AC7D3AF34C6BE5233E59A61A8C3241
          92372039FEF52A35B15C965E3DEA2FB02EFE2D867FDEA7AD97CB86B65C7719A9
          E51A687996D76F322FE749E65A9F97CC5FCE8FECF80A902D147D0D28D3E03D6D
          46718E0D2B05D06FB63C19067EB4ACF6CBFF002D07FDF548BA65BED24DBBFD33
          4A74CB5753BA19067D4D160E641BA1C644B9F6CD3247B6DBF34AB8FA54B1E9B0
          28E15C71C0CD4A2CA22854C7B81A394399150CB6AB19FDEA8534D46B774C2CCA
          31D306A76B48C1DA60256A58ECE100911AFE547287322BA3A2003CDCFBF341B9
          85549F333EBD6AE35B45B48D83A7AD40F668FF00C2A7D7E6A561F322B1BB8882
          DE63014D17AA17EF381EB5696CC27DD8015FF7E9C96B1A9E63CFFC0FA5160E64
          558AF51F389A4C7AEDA492EC1190FBB8FEED68AC2814E047F9D2794B91831E07
          BD3B0B98A0972026E3263D82512DEA26333498F5DB57FCA4C9E63C1ED9A56850
          A8C88FF3A394398CD37AA57EF391EB4E1771001BCC622AD3DAC6C788F1FF0003
          EB4D6B30FF007A0017FDFA561F32231730B283E663D3AD0EE8E08F371EFCD4A9
          6689FC2A3D3E6A9D6DA2DA06C1D3D68B073233DDADD130D329CF5C9A7096D5A3
          1FBD52A2AD4967090098D7F2A896D2327688085A7CA2E64471BDB6DF9655C7D2
          9FBA1C64CB8F6CD4E6CA2081447B40A8A4D36061CAB9E3919A3943990D57B66F
          F9683FEFAA4DF6C38120CFD6946996A8A36C321C7A1A46D32DF6822DDFE99A2C
          1CC84F32D47CBE62FE74A25B5DBC48BF9D074F8074B519C639349FD9F00500DA
          29FA9A2C1740ED6C1721979F7A4124190372139FEF523597CB85B65C7619A67D
          8177F36C33FEF53E506D0E26E872D74719FEE1A5F32E149537048F753528BE2C
          0821411EF4D3773118DAB9EC7D69D89235964393F69E3D36D3D52691729718F5
          F969C2E6E71C5BA9F7A5F36EDBE654F97D281A11629DB8371F953BC862D87B83
          9F66A417370AB936FCFA534DCDC93816E8ADEB4D0ACC945BC847FAF6E3D4D3C4
          129E04C7F3A8967B8E49856817372063C81F9D2B8598A6DEE07FCB7349F6499C
          732B7E7486EAE7F8601B7D734E5B8BAFF9E6306986A446C5C9F99D98FF00BF42
          59EC0700927FDBA90DC5C607C807A714E49AE76E4A2FE22906A4296841DDFBDF
          71BEA46B77DBF2A37E75279971DC7E94196E82E41E3B822818D5B77039889A69
          8493CC2C29CD35D1E87F02B43BDCE3EF0FCA84037C960702063EFC539ADDC8E2
          2228492E88EA3DF8A166BA1D4FE016860356DDF6FCC8DF9D46F6849DDFBDF61B
          EAC096E8AE49E3B0028F32E3B0FD2802BBD9EF0320823FDBA058B83F2BB29FF7
          EA679AE76E422FE029A2E2E307E407D78A05A87D92641C4ADF9D28B7B83FF2DC
          D0D7175FF3CC605345D5CFF14036FAE6986A4C609470663F9D30DBC807FAF6E7
          D0D34DCDC918F207E7434F71C110AD2B8598790C1B097073EED4D68A75E05C7E
          7482E6E41C1B7466F5A71B9B865C8B7E7D29B0D46324D1AE5EE33E9F2D31A590
          60FDA78F4DB5379B76BF3327CBE9486E6E71CDBA8F7A4323F32E188517040F65
          3480DD1E56E8E33FDC3520BB980C6D5CF73E94E37C540002927DE8B095C64973
          6A067C8CE7DA923BAB76FF00962401ED574451721852BC301EDDA8560B9516EA
          DD8805187E14F3750AF015FF002AB2B142053F6C20724548EE53179081D1BE98
          A3EDB00249661F855978ED9BBF3DF06A316D6CBCEFFAE4D34849917DAE0DA4EF
          6FCA8FB640C3E5918E3B62AC7950ECF926515108A351FEBA2CE3A9140C8FED09
          82D897F2A05EC6ABB7E71F875A98060389216147CBC9FDDF1E868B79888CDFA7
          408C7B74A77DB94A9F91BA7A5488D177D98FAD28309FEE8FC68B068406F801FE
          ADCFA71482EE53C885FF00115383086CEE5E071CD377C4339917F034EC172317
          9938689BF2A71BA3D0465AA412438DBB97D8E6A32C7385962FC451A000B92386
          42B4D379838589BF2A70625B0658F1EC2A432438DBB97DCE68D01901BB947261
          7FC0528BE047FAB71EBC549BE238C48BF89A73184B6772F239E68B05C8FEDCA1
          47C8DD3D29A2FD3A1461DBA54E4C23FBA7F1A4768BB6CC7D6958342B9BD8D976
          FCE7F0E947DA1301B12FE5537CBC1FDDF3EA682188E64854516F3022FB640A3E
          691867B628FB5C1B41DEDF953CC51B0FF5D1671D40A97CA8767CF329A0657FB6
          C0482198FE141BC848E8DF4C54A6DAD9B9DFF4C1A9123B65EFCF6C9A1A136561
          750B7055FF002A635D5BA920231FC2AFED848E08A634509148772849756EBFF2
          C4907DA963B9B5233E4631ED575218076ED48628B80A2A9D85720FB1AF3966FA
          EEA3ECAAA3FD6374E7E6A6C935D95EABC7B75A04976571B5467D45016058212B
          B4CEFF00F7D53D2DA22BF7CB63D5AA126FC71B50E69E05CEDC315145C69798EF
          B112D9DBD7B86A56B15638DF20FA1A6AADC631E77E548D14EC0ED9F9ED9A403C
          698A0F13C9F4A6BE909BC379C4E3B11491C5381FF1F2D9EF4F314A47FAC627BE
          69A0B8BFD9CA571BB8F4C53D34F8D5718A8842FB32666CFB544603CE6F6407F1
          A05A96FEC5085C1527DA83651EDEFF004AA70C4AA33F6C93D79069E339245D49
          F8834016859438C6CE7DA9A2CA0C60A367DEA11338183744FE06A502565CA5C3
          1FC284C3E621B48C9E14E73D4834D92C4E4FCA94E1F6BC604DF98A6B4D74072E
          A7F0A03E60962DB87CA98A70B48C1E54E73D4034825BA2321D7F2A53F6BC60CD
          F90A03E638D9418C046CFB538D9438C6CE7DE9844AAB97B861F85446672302E8
          8FC0D0D87CC9C5947B7BFD28FB142570148F6AAC73904DD49F8034C9A25619FB
          649EBC034016DF4F8D9718A67F67285C6EE3D3150080F18BD909FC6A530BECC8
          99B3EF406A226909BCB79C467B014E3A6293CCF27D28114A07FAC607B6299245
          391FF1F2D9ED431DC7AD8AA9C6F90FD4D27D8886CEDE9DCB535629D40DD3F3DF
          14ACB718C79DF9D201CF6D105FBE573E8D4C68210BB44EFF00F7D5045CEDC295
          34C06FCF1B50629DC1AF325FB2AB0FF58DD38F9A8FB1AF1866FAEEA6992EC2E3
          6A9C7A0A239AEC2F55E7DBA502B118D40B020C2FF9506FC768D89A689CAF0D12
          8F7CE697CF8C9FF96648FC28B2402FDB4153BA06149F6DE33F6766E3BD3E3962
          6FE05E9D9AA44300070BF8668B21900BC3FF003EE46690DC383FF1ECC7D31529
          F24107CB63F46A789622DB7047B934857221753123106DA5FB6CD8C7938F4A9D
          5A2FEF01C7AD2B3C23F894FE346832017971D044290DDDCF6B606A7596023EF0
          E9D6813440FDF1F5A7A010FDB2E80FF8F6147DBEE31FEA2ACADD440637834866
          85BF897F3A340D483EDB300736C7DB8A517B301CC07E98AB0258CFA1C74E697C
          D4E7A1FC451A015D6FD9948685D48EBC5352F5187CC8C39EE2AE2989876E9EB4
          D92DE290E4647B834242B951AF907DD8D8FD053DAFD9540585D89E9C5598E08A
          31D09C7726958C4A3B74F5A1A0B950DECC47101FA6293EDB310316C7DF8AB5E6
          A71D07E2290CB18F419EBCD1A0CABF6FB8C7FA8A3ED97447FC7B0AB026857F89
          7F3A56BA888C6F028D0352A8BBB9EF6C0529BCB8E86215319A227EF8FAD0D2C0
          07DE1D3AD1A0107DB66C63C9CFAD21BA981398375595784FF128FC6919A2FEF0
          3C7AD2D00A82E1C9FF008F661EB9A53787FE7DC9C54E658836DC13EE0D307924
          93E5B0FAB502B91FDB78CFD9D978ED4BF6D0146D818D4CE6020657F0CD4724B1
          2FF02F4EED4EC86345F8EF1B0341D40A80042FF95279F183FF002CC13F8D219C
          B70B129F7CE28B5C422411FDD2EAC3B64D4A2DC3AFC89137E34A8262397E7FDD
          A3370BF724FAE4530086CDD8126187F06A78B29429FF00478FDB0D4D125C6DCF
          98ABF852A4D3AE73383C7A51A813476671F344471FDEC8A7B58A918310E2AA96
          B87E04C79F4A4C5D053B666CE7D68D445C5B28B18317D7341B1B73926151C554
          DB3B2E0DC3669AC975CE26FCCD2289CD95AE31C253469F6CD9C4EB8F63512C57
          4460CAA78F5A4305C2AF0CA3F3A07A937F672B7093C74E934B04E778E78C8AAE
          904C0E4BB7D452F933E4E66907A60D316A4A34A957215C15F434D934C93A248A
          BEB51917633FBF90D394CEAD9F364E94089574C941C6F5E9D69AF652A9C0793F
          034096EC1C89811EE286B99D304ED6E298AEC48EC25279790FD4D3DB4C949C6F
          5E9D681713BAEE52ABF8534CB764E4CC00F61405D889A649D1E456F4A71D2A56
          C067017D0546C6766CF9B274A6817671FBF905219623D2C039DE38E3269BFD9C
          ABC3CF1D45E4CF9189A43EB9348F04C4E43B7D4D03D498E9F6CB8CCEB8F734E1
          656B8C70F55C4170CBCB29FCE95A2BA0302551C7AD21EA5D1636E30442A78A1A
          CA2C6045F4C55254BAE3337E469DB6755C0B86CD0C45A5B15030221CD324B338
          F962278FEF60557C5D151BA66CE7D69435C270663C7AD3D491C6CA52A3FD1E3F
          7CB5326B375008861FC5A9CF34ED8C4E071E94864B8DB9F315BF0A3518D36E11
          7E74897F1A89E08FEE87551DF06A6CDC37DF93E981438980E1F9FF00768020DF
          72873E582291A5B927021AB49A8D9B27328C7724528BFB46F944AA78F4A43451
          DF74A72EB8148F7376A48587771EB5A1F6AB32A733A8A8A49ADDBEEDDB8FF77A
          1A3404545BCB8081982A9F422A413DC1381247EF4B38520017FC770D1839A7A4
          F66A76CB246CDEC98A340123376781E5E3151C935D02373C6BCF6ABB0DCDAAE7
          6F7F414F37109FE163F85302824D39F95268B3DA9E4DE14FF5899EF8AB2D7102
          AE3C87CF6F968FB4A0E90383FEED202BA2DE8C1273EB4ED978727701568DE420
          7DD71FF01A63DFA2F5573E9C530D4ACC2ED78C2B0EF49BAF7195453F5352C9A8
          8ED6F311EC2986FE42B85B79803DF14011E2FB19217AF201A5325CE70611F89A
          71BF994E3CA9BDF2952477C5972CAC0F4E529A132157BAC63C91F81A4C5F6320
          2F5E01353C97EC17011C9FF72A317F331C79537B61286026EBDC659147D0D2A8
          BB6E30AA3B528BF902E1ADE62077C53E3D4477B7980F71487A8DD9783077034D
          75BD3920E3D2ACA5FA374571EBC53C5E4247DD73FF0001A03529037813FD6267
          B6698F34E3E579A2CF7AB9F6943D60727FDDA16E2065C790F9EFF2D20D4A51CD
          7449DAF1B73DEA490DD8E0F978C55C17108FE161F85326B9B56C6EEDEA29814C
          CF700E0C91FB546D797050B28563E8055879ECD8ED8A48D5BDD334C8028041BF
          E3B058C0C52D00892E6ED880D0EDE3D6977DD31CA2E455A8E6B75FBD76E7FDEE
          82A5FB55985189D4D0AC0CA625B907061A5DF72E73E5802AD1BFB45F94CAA38F
          4A47D46CD5389463B10280771A91607CD08FC854A90C6064A283E9B45416DA73
          E4F98EC07FBD5249A646D8C171F8D0A2FB8AE8905B47C10B163E952085003FBB
          8F18F4AAEBA6A81F2CB27E7520B20576977F739A7CA09A2448A155E522F7A708
          206E7CB4FA8AAFFD9A00C0734EFECF1B76F9868B30D0B0B1C406020FAD38041C
          6063B5525D31BF8676C0EDEB4F36042E37B11EB4ECC45AFDC8FEEE7EB4C94DB9
          5C165FC0D561A70039393FE7DE9F0D82E70CA0FE14582C88DA3B366E276E3D1E
          982DEDD492B3CCC3FDECD5836101FF0096433F4A77D82363FEAC01F4A15C7A10
          C621DA332CC0FB9A9D521E7E763DFAD46DA5C3DC63DA9469F028FE21F8D1661A
          138F2821C38CFB9A0883392CA3DF3502E9F100464FB7340B0B7CE49C9FCE9598
          89D443D4329FC683E51419719F63503585B641079FAD0DA7C440193EFCD1A868
          3D921E3E761DFAD41208769C4B313EC6A43A7C0C3F88FE348BA5C3D867DA9D98
          F42036F6EC4169E651FEF629EB1D9AB733B73EAF53FD82353FEAC11F4A68B080
          7FCB219FA50EE1A12C46DC2E032FE269FF00B93FDDCFD6AB4D60B9C2A81F8530
          E9C08E0E0FF9F7A2C2B22E10878C0C77A6B471118283EB55C5812B8DEC07AD31
          B4C6FE29DB07B7A516605968205E7CB4FA9A6BC50B2F0917B547FD9E36EDF30D
          37FB341182E69598F42630A103F771E31E9519B68F92562C7D2836402ED0EFEC
          7351B69AA47CD2C9F9D1CA1743DE18C8C84527D368A89E2C8F9611F90A747A64
          6B9C973F8D4773A73E4796EC47FBD438BEE17444ED740E7ED683D8D01AE9C717
          EBF80A7FDBA45C86B3278FEED396FC98BFE3D581FF0074D1718D592E91706ED0
          FD56A5492E88E2EE2C7FBB4DFB61DA0F95B476C8FF00EB5396F5766404C50087
          FF00A675171191F4A1C5F7513478F714D5B9739DBB381D01A72DD4E7830A8FA1
          A40005E81CCC9F80A5517BDAE1707DA9E2E250322214D6B99C8F960539F7A621
          A63BDE9F6B4FCA9D1A5D1CABDC6E3EA38A679D7008FF0045073DE8FB45DA8FF8
          F43F8524C7625FB2DD6726E59693ECF763A5D9383E9519BABA5C9780FD314DFB
          6C98C98B6FD41A01129B7BCED75F98A8DADAFC9CFDAD71F4A67F68499DBB907D
          7340BE94F1BD0E3D0D5012C76931521E76273EB4D3653467FD7E17AF53409EE1
          B90D8FC6959EE88CF18C7340B51A2C6676CF9DF2FD4D3E4B49828093B039F5A0
          35DAF24AE3B60D34CF70BC96CFE3406A0B6D7E0E7ED6B8FA5482DEF3BDD7E42A
          037D28E37A0CFA9A3FB424CEDDC87E99A0658FB3DD9EB76464FA52FD96EB3917
          2CD507DB64C6445BBE80D385D5D360A407E98A9063E44BA1854B8DA7D4F34D11
          DEF4FB5A7E549F68BB61FF001E87F1A3CEB824FF00A2818EF436161CC2F7BDC2
          E07B52117A471327E229CB73381F340A31EF4E6B8948C98853111A0BEEA668F1
          EC28FF004CEA6E2303E9435D4E3810A9FA9A6B5CB8C6ED9C8E84D2188F25D01C
          DDC58FF76A2792E9D702ED07D16A56BD5D9921314DFB61DA4F95B877C0FF00EB
          530212D74839BF5FC4508D744E7ED687D854AD7E445FF1EAC4FF00BA69BF6E91
          B016CC8E3FBB45C0998D8E796FC89A725C59A8DA256F6C93532DB2038DE3F21C
          D29B600606DF60052168575B8B3C93F69719ED934F5B8B51C07639F6AB115A20
          53B9549CE7902A448508C00A0FAE280562A24D0007A9CFAAD299AD8F51D7DAAC
          98F0DC3A60FAAD23C39FE28C1FF76802B46F6EA7032297CD8532016C1A90C048
          38F2F3EE295624079298F61401035E42AB8DCD9A70BD899724B2D4E6084F2426
          7E94AD0C2415CA6280204BE87BB31A3EDD1B0C88CB0CD3C5AC4A7388FF002A91
          62839F993DE8195C5EC649061EBF4A4796DC8C9B71F5C55A2210B91E5F1D0535
          8213B415E7D2842B953CFB551916F827B814D171691F21197270315731000431
          8F81D08A6ED848FBCBF80A6172A9B9B294EED8CD838CD3BCFB561936F923B915
          64F91B400507D452E20200531F23A01401024B6E0645B8FAE294DEC608021E9F
          4A9D4203B495E3D69C0425727CBE7A8A4C2E57FB746A32632A3343DF43D99854
          ED141C7CC9ED519B5898E711FE540C8CDEC4AB9059A9AB790B2E37366AD08610
          02E53149E442390133F4A0441E6C2F804B605248F6EC70726A668909E0A63DC5
          20808033E5E7D85004626B61D074F6A479A0207518F45AB290E3F8A327FDDA51
          1E5B974C0F45A00A8D716A782EC31ED4C6B8B3C83F69738ED9357DE140304293
          EB8A8E5B442A36AA839CF00500EC557B8B361B4CADEF8269AA6C73C37E64D591
          6C08C1DBEE08A46B64271BC7E438A034208E0947DE690F3D9AA5FB239E97322F
          7EB5502DCE41033C7534E5FB58E0B03F5068B31DCB5F639B1FF1F0D8F506952D
          195799266FA1AAE925CA139C7E669FF6AB88C125D071D0D1610089C3E36CDF43
          527D9F772C255F739A83FB42707896127D09C53BED578C7025871FDDCD032416
          71127F7AF93EA4D1F638B23F7A4F1EA6904B7BB72248FF002E94E596EFBB46DC
          71814583E606C633CF98C0FB352FF6703C891BF3A6837CEB9322AFFC068135E2
          0DA141F7C5160BF9922D80538693767A834834D8C1E323F1A84CD7ED9055073D
          48A5592FCBFDE8F1F4A2C2B930D390838CFE269834D0A7218FD33446F7D83B9D
          338E314D325F83FEB231F853B30BF983E9BB9B249E3DE86D3A3E41240C7AD2EF
          BDDA3F791FE551CCF700E19E3CE3AED347C813F31E9A7213C12463A934269BB5
          B209E7DE9237B923E578C7BED34EDF7BB4FEF23FCA8F9037E629D3431C963F4C
          D3CE9C800CE7F0351092FC9FF5919FC29D23DF606D74CE39CD1661F31C74D8C9
          E727F1A56B00C70B26DC7402A1692FC3FDE8F1F4A4135FAE00543CF5029582E4
          BFD9C072646FCE9058C639F3189F76A4335E38DA540F7C504DF22E448ADFF01A
          2C3BF987D8E2C9FDE91C7A9A0D9C408FDEBE47A134AD2DDF668D78E7229A65BD
          DB93247F975A2C1F31DF67DBCA895BDC66A331397C6D9BE8293ED578A7065871
          FDDCD37FB42727996107D01CD00587B4665E24997EA693EC7363FE3E1B1EA4D4
          7F6AB890021D0F1D0531E4B972318FCCD161137D91C75B991BBF5A8A48253F75
          A41CF76A8DBED6780C07D01A695B9C924638EA28B31DC95EFEDFAE187E140BD8
          B69DA5BAF7A6C8B130F998FE22811A71F32FE545C3950E4BC527219BE98A16F1
          429C1918FA6D14D44084FEF169EAAA09CCF8FC68B8D446B5D83F33407FEF9A41
          79116CFD97E61DF653CB2819F3C67DCD2ACA1B8F307E6290112EA718C8F2323F
          DDA72EA71ECCAC43D295654C1C91F98A1E6847545FC3145C2C20D5571C478FC6
          85D5430FF527F13479906DE157F4A14DB32E485140590E1A9B1000B763F42294
          EA2E33FE8CDFF7D0A681699EA07B834863B4CF1377F5A698AC489A913FF2ECFC
          D21BC6638FB3E7EA69365B85C99FF5A6936A9FF2F045170B2245BAE0936CC38A
          67F68383816CF4E492DC8E2E690CB0E7FE3E87E540584FED07279B67C1A7B5D7
          008B663C5344B0838372338F4A5792DC0E6E680B00BC6538FB3E3E8695F5223F
          E5D9F8A8C1B57FF978269DB2DCAE44FF00AD170B2146A2E71FE8CDFF007D0A43
          A9B0041B761F5229A23B4CF3377F5A522D33D41F72686C2C236AA147FA93F81A
          0EAAB8E63CFE3431B655C80A68F320DBCAAFE9487640DA9C7B32D10F4A6B6A71
          9C0F2303FDDA7A4D09E88BF8E28695303047E628B85869BC88367ECBF31EFB29
          56EC0F99603FF7CD3DA50BC7983F31481948CF9E33EC68011AF14A8C9914FA6D
          143DE28392CDF4C52B2A92313E7F1A63A0723F78B4EE0E238DEC5B46E2DD7B50
          97F6FD70C7F0A698D39F997F2A2358947CAC7F014EE2E543CD9C2D1E19DBD790
          69458C58FBC738A4D9739E2E5BDE9E05D63E5756FAD327505D3612307BD2C7A6
          46B939DD9F6A5517D9E4AF4ED415BFC70D83D7B521FCC0E9B013831A7E34834B
          8067080034B1ADD67E72D9EDD2858AF73FEBB8F7148061D36DFA98FE9C9A6BE9
          76E0F087FEFBA97ECB72721E4CE69AF6D721701FA7A8A561AF52B369D6FC8C48
          3F1CD48B6508DB8573EC0D0D1DC21FE1614243719CFC8BE94D20B9325AC40FFA
          A3D3BE294DA465B1E583F514C8E3B927993F214EF2EEB9C4B8F4E3A53D45F31F
          F6384AE0AAFD31482D21C630A7F0A89A3BFC712C64FAD3025F8E7233ECD46A04
          AD0D9A7531FE5513DBD8B1DCC63C7AF4A6F937AFF7C01EB822956D6E369196CF
          B814B51D823B7B10772B467DFAD4CB0D9BF431FE5501B5B9C0CEECE3A8C73479
          37A9F7003E99228D42C5A3690E31851F852FD8E10B80ABF4C556297E79C8CFBB
          53D63BFC732C60FAD3D44482D230D8F2C0FA0A47B5889FF547A76C51E5DD7199
          73EBC75A6C91DC83C49F98A350F991B594277655C7B1351AE9D6FC0C487F1C54
          8F0DC673F237AD0B1DC39FE15149A1DC726976E4F287FEFBA70D36DFA88FEBC9
          A54B6B92B82FD7D053BECB7230124C629583E621D2E038CA020528D360070234
          FC2868AF73FEBB8FA5122DD67E42D9EFD29884934C8DB073B71ED48DA6C20607
          6A705BFC72D93D7B50C2FB3C15E9DE987CC8CD8C58FBC738A41670AC78576F5E
          01A791758F99D57E94CD9739E6E5BDA98B519FDA6873B533F8D346A6B8FF0053
          F91A6F9F6FD15973EC28134383C2FE02958BD0962D5948C79327B50FAAED5398
          2427DAA133AE31B4FE0290DE42A39CFE5409589A3D48E09D8C3D8D397563961E
          5903DEAAADD231E2373CF5C54C671B72606FCA81E84A75564524A81D8734C5D6
          6463C46A571D9B9A87ED0854FEE49C7AAD37ED098C0B66041FEED005BFED3936
          7FA91F9D0B7F295F9523FA135516F173B4C0E3FE0347DAE3DDB4DABE71D76D02
          B16D753908C796AADEC68FB6CE491B14FE35596E23CF101CE39C8A469E31806D
          B39ED40685B4BAB82082894D135C6E2362FD6AB899C67166D8EDCD2ADCC801FF
          004739FAD301E5AF012C1C73D8D385C5D93C95C63D2A1FB4DC3127EC8DF89A6F
          9F3ED25AD587A734AC058FB45E018057EB8A686BC243171C7615099EE3682B6A
          71DF9A77DA6E1483F646FC0D3B0160CD71B80D8BF5A73DD5C000044AACD73210
          3FD1CE7EB4866738CD9B63BF346A059FB6CE081B147E3436A72018F2D59BDCD5
          559E33902DB18ED4AD711E7980E71C60520D0B2D7F285F9923FA0347F69C9B3F
          D48FCEAA7DAE3DDB45ABE71D76D0D78B9DA2073FF01A02C586D66453CC6A171D
          DB9A78D559D410A0F63CD54FB426306D98927FBB4EFB42051FB9233E8B40CB0D
          AB1CA8F2C91ED4D93523807631F614D138DB91037E550B5D229E6371CF5C501A
          165355DCA310480FBD12EACA063C993DEA01790B0E33F95289D718DA7F11409D
          879D4D71FEA7F334EFED3418DC98FC6A3334381C2FE228F3EDFA332E7DC503D0
          FFD9}
        Material.Texture.MinFilter = miLinear
        Material.Texture.TextureMode = tmModulate
        Material.Texture.Disabled = False
        Nodes = <
          item
            Y = 0.899999976158142100
          end
          item
            X = 0.400000005960464500
            Y = 0.800000011920929000
          end
          item
            X = 0.449999988079071000
            Y = 0.500000000000000000
          end
          item
            X = 0.250000000000000000
            Y = 0.300000011920929000
          end
          item
            X = 0.250000000000000000
            Y = -0.100000001490116100
          end
          item
            X = 0.600000023841857900
            Y = -0.500000000000000000
          end
          item
            X = 0.600000023841857900
            Y = -0.899999976158142100
          end
          item
            X = 0.589999973773956300
            Y = -0.949999988079071000
          end
          item
            X = 0.600000023841857900
            Y = -1.000000000000000000
          end
          item
            X = 0.600000023841857900
            Y = -1.000000000000000000
          end
          item
            X = 0.500000000000000000
            Y = -1.000000000000000000
          end
          item
            Y = -1.000000000000000000
          end>
        SplineMode = lsmCubicSpline
        Slices = 24
        Normals = nsSmooth
      end
    end
    object GLCamera1: TGLCamera
      DepthOfView = 100.000000000000000000
      FocalLength = 50.000000000000000000
      TargetObject = DummyCube1
      Position.Coordinates = {0000804000000000000000000000803F}
      Left = 208
      Top = 136
    end
  end
  object Timer1: TTimer
    OnTimer = Timer1Timer
    Left = 8
    Top = 40
  end
end
