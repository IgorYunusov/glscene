object Master: TMaster
  Left = 264
  Top = 241
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'Sort Algorithms Demo'
  ClientHeight = 466
  ClientWidth = 640
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Arial'
  Font.Style = []
  Icon.Data = {
    0000010001002020000001000800A80800001600000028000000200000004000
    0000010008000000000000000000000000000000000000000000000000000000
    0000FF800000C4C4C4004080FF000000FF000000000000000000000000000000
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
    0000000000000000000000000000000000000000000000000000000000000000
    0000000000000000000000000000000000000000000000000000000000000000
    0000000000000000000000000000000000000000000000000000000000000000
    0000000000000000000000000000000000000000000000000000000000000000
    0000000000000000000000000000000000000000000000000000000000000000
    0000000000000000000000000000000000000000000000000000000000000000
    0000000000000000000000000000000000000000000000000000000000000001
    0101010101010101010101010101010101010101010101010101010101000001
    0202020202020202020202020202020202020202020202020202020201000001
    0203030303030303030303030303030303030303030303030303030201000001
    0203020202020202020202020202020202020202020202020202030201000001
    0203020202020202020202020202020202020202020202020202030201000001
    0203020202020202020202020202020202020202020202020202030201000001
    0203020202020202020202020202020202020202020202020202030201000001
    0203020202020202020202020202020202020202020202020202030201000001
    0203020202020202020202020202020202020202020202020202030201000001
    0203020202020404020204040204020402040402040402020202030201000001
    0203020202020404040204040204020402040402040402020202030201000001
    0203020202020400040202020204020402020202020202020202030201000001
    0203020202020404020202020204020402020202020202020202030201000001
    0203020202020202020202020202020202020202020202020202030201000001
    0203020202020202020202020202020202020202020202020202030201000001
    0203020202020202020202020202020202020202020202020202030201000001
    0203020202020202020202020202020202020202020202020202030201000001
    0203020202020202020202020202020202020202020202020202030201000001
    0203020202020202020202020202020202020202020202020202030201000001
    0203030303030303030303030303030303030303030303030303030201000001
    0202020202020202020202020202020202020202020202020202020201000001
    0101010101010101010101010101010101010101010101010101010101000000
    0000000000000000000000000000000000000000000000000000000000000000
    0000000000000000000000000000000000000000000000000000000000000000
    0000000000000000000000000000000000000000000000000000000000000000
    0000000000000000000000000000000000000000000000000000000000000000
    0000000000000000000000000000000000000000000000000000000000000000
    000000000000000000000000000000000000000000000000000000000000FFFF
    FFFFFFFFFFFFFFFFFFFFFFFFFFFF800000018000000180000001800000018000
    0001800000018000000180000001800000018000000180000001804000018000
    0001800000018000000180000001800000018000000180000001800000018000
    000180000001FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF}
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 15
  object pgcDemo: TPageControl
    Left = 0
    Top = 0
    Width = 640
    Height = 466
    ActivePage = tsDemo
    Align = alClient
    TabOrder = 0
    object tsReadMe: TTabSheet
      Caption = 'Read Me'
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      object redInfo: TRichEdit
        Left = 0
        Top = 0
        Width = 632
        Height = 436
        Align = alClient
        Font.Charset = RUSSIAN_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Arial'
        Font.Style = []
        ParentFont = False
        ReadOnly = True
        ScrollBars = ssVertical
        TabOrder = 0
        Zoom = 100
      end
    end
    object tsDemo: TTabSheet
      Caption = 'Demo'
      ImageIndex = 1
      object rgSorts: TRadioGroup
        Left = 0
        Top = 0
        Width = 185
        Height = 436
        Align = alLeft
        Caption = 'Algorithm'
        ItemIndex = 0
        Items.Strings = (
          'Bubble'
          'Selection'
          'Insertion'
          'Heap'
          'Merge'
          'Quick'
          'Shell')
        TabOrder = 0
        OnClick = DoSortSelect
      end
      object pnlDemo: TPanel
        Left = 185
        Top = 0
        Width = 447
        Height = 436
        Align = alClient
        TabOrder = 1
        object splitSort: TSplitter
          Left = 1
          Top = 191
          Width = 445
          Height = 8
          Cursor = crVSplit
          Align = alTop
          Beveled = True
        end
        object memoRaw: TMemo
          Left = 1
          Top = 1
          Width = 445
          Height = 190
          Align = alTop
          ReadOnly = True
          ScrollBars = ssVertical
          TabOrder = 0
        end
        object pnlSorted: TPanel
          Left = 1
          Top = 199
          Width = 445
          Height = 236
          Align = alClient
          TabOrder = 1
          object memoSorted: TMemo
            Left = 1
            Top = 1
            Width = 443
            Height = 190
            Align = alTop
            Lines.Strings = (
              '')
            ReadOnly = True
            ScrollBars = ssVertical
            TabOrder = 0
          end
          object stTime: TStaticText
            Left = 336
            Top = 202
            Width = 100
            Height = 19
            Alignment = taCenter
            AutoSize = False
            BorderStyle = sbsSunken
            Caption = 'Not Sorted'
            Color = 15323580
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -12
            Font.Name = 'Arial'
            Font.Style = [fsBold]
            ParentColor = False
            ParentFont = False
            TabOrder = 1
          end
          object pnlCtrl: TPanel
            Left = 1
            Top = 191
            Width = 320
            Height = 44
            Align = alLeft
            BevelOuter = bvNone
            TabOrder = 2
            object cbCount: TComboBox
              Left = 8
              Top = 10
              Width = 145
              Height = 23
              Style = csDropDownList
              ItemIndex = 3
              TabOrder = 0
              Text = '6 Values'
              OnChange = RePopulate
              Items.Strings = (
                '1 Value'
                '3 Values'
                '5 Values'
                '6 Values'
                '8 Values'
                '11 Values'
                '20 Values'
                '32 Values'
                '59 Values'
                '96 Values'
                '200 Values'
                '500 Values'
                '1000 Values'
                '2000 Values'
                '5000 Values'
                '10000 Values')
            end
            object btnSort: TButton
              Left = 239
              Top = 8
              Width = 75
              Height = 25
              Caption = 'Sort'
              TabOrder = 1
              OnClick = DoSort
            end
          end
        end
      end
    end
  end
end
