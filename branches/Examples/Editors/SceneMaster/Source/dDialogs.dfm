object DMDialogs: TDMDialogs
  OldCreateOrder = False
  Height = 334
  Width = 390
  object ColorDialog: TColorDialog
    Color = 14540253
    Options = [cdFullOpen, cdAnyColor]
    Left = 46
    Top = 24
  end
  object OpenDialog: TOpenDialog
    Options = [ofHideReadOnly, ofFileMustExist, ofEnableSizing]
    Left = 150
    Top = 24
  end
  object SaveDialog: TSaveDialog
    Options = [ofHideReadOnly, ofPathMustExist, ofEnableSizing]
    Left = 232
    Top = 24
  end
  object odTextures: TOpenDialog
    DefaultExt = 'glml'
    Filter = 'GLScene Material Library (*.glml)|*.glml|All files (*.*)|*.*'
    Options = [ofHideReadOnly, ofFileMustExist, ofEnableSizing]
    Left = 46
    Top = 80
  end
  object sdTextures: TSaveDialog
    DefaultExt = 'glml'
    Filter = 'GLScene Material Library (*.glml)|*.glml|All files (*.*)|*.*'
    Options = [ofHideReadOnly, ofPathMustExist, ofEnableSizing]
    Left = 150
    Top = 80
  end
  object opDialog: TOpenPictureDialog
    Options = [ofHideReadOnly, ofFileMustExist, ofEnableSizing]
    Left = 230
    Top = 80
  end
end
