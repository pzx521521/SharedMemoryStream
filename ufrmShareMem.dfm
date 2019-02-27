object frmShareMem: TfrmShareMem
  Left = 0
  Top = 0
  Caption = 'frmShareMem'
  ClientHeight = 242
  ClientWidth = 1083
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object Memo1: TMemo
    Left = 0
    Top = 0
    Width = 209
    Height = 241
    TabOrder = 0
  end
  object BtnCreatFile: TButton
    Left = 224
    Top = 39
    Width = 75
    Height = 25
    Caption = 'BtnCreatFile'
    TabOrder = 3
    Visible = False
    OnClick = BtnCreatFileClick
  end
  object BtnOpenFile: TButton
    Left = 224
    Top = 8
    Width = 75
    Height = 25
    Caption = 'BtnOpenFile'
    TabOrder = 1
    Visible = False
    OnClick = BtnOpenFileClick
  end
  object BtnBuildMapping: TButton
    Left = 215
    Top = 120
    Width = 114
    Height = 25
    Caption = 'BtnBuildMapping'
    TabOrder = 9
    Visible = False
    OnClick = BtnBuildMappingClick
  end
  object BtnWriteInfoIntoMem: TButton
    Left = 215
    Top = 168
    Width = 113
    Height = 25
    Caption = 'BtnWriteInfoIntoMem'
    TabOrder = 15
    Visible = False
    OnClick = BtnWriteInfoIntoMemClick
  end
  object BtnRemoveTheBindding: TButton
    Left = 335
    Top = 120
    Width = 129
    Height = 25
    Caption = 'BtnRemoveTheBindding'
    TabOrder = 10
    Visible = False
    OnClick = BtnRemoveTheBinddingClick
  end
  object BtnCloseTheMappingFile: TButton
    Left = 335
    Top = 168
    Width = 129
    Height = 25
    Caption = 'BtnCloseTheMappingFile'
    TabOrder = 16
    Visible = False
    OnClick = BtnCloseTheMappingFileClick
  end
  object BtnReadTheInfo: TButton
    Left = 335
    Top = 72
    Width = 97
    Height = 25
    Caption = 'BtnReadTheInfo'
    TabOrder = 8
    Visible = False
    OnClick = BtnReadTheInfoClick
  end
  object BtnClear: TButton
    Left = 389
    Top = 8
    Width = 75
    Height = 25
    Caption = 'BtnClear'
    TabOrder = 2
    Visible = False
    OnClick = BtnClearClick
  end
  object btnCopy: TButton
    Left = 488
    Top = 64
    Width = 75
    Height = 25
    Caption = 'btnCopy'
    TabOrder = 4
    Visible = False
    OnClick = btnCopyClick
  end
  object BtnPast: TButton
    Left = 488
    Top = 120
    Width = 75
    Height = 25
    Caption = 'Past'
    TabOrder = 11
    Visible = False
    OnClick = BtnPastClick
  end
  object CopyNew: TButton
    Left = 632
    Top = 64
    Width = 75
    Height = 25
    Caption = 'btnCopy'
    TabOrder = 5
    Visible = False
    OnClick = CopyNewClick
  end
  object PasteNew: TButton
    Left = 632
    Top = 120
    Width = 75
    Height = 25
    Caption = 'Past'
    TabOrder = 12
    Visible = False
    OnClick = PasteNewClick
  end
  object FreeWhenClose: TButton
    Left = 632
    Top = 176
    Width = 125
    Height = 25
    Caption = 'FreeWhenClose'
    TabOrder = 17
    Visible = False
    OnClick = FreeWhenCloseClick
  end
  object Button1: TButton
    Left = 784
    Top = 64
    Width = 75
    Height = 25
    Caption = 'ButtonCopy'
    TabOrder = 6
    Visible = False
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 784
    Top = 120
    Width = 75
    Height = 25
    Caption = 'ButtonPaste'
    TabOrder = 13
    Visible = False
    OnClick = Button2Click
  end
  object Button3: TButton
    Left = 784
    Top = 176
    Width = 75
    Height = 25
    Caption = 'Button3'
    TabOrder = 18
    Visible = False
    OnClick = Button3Click
  end
  object Button4: TButton
    Left = 912
    Top = 64
    Width = 105
    Height = 25
    Caption = 'Button4MgrCopy'
    TabOrder = 7
    OnClick = Button4Click
  end
  object Button5: TButton
    Left = 912
    Top = 128
    Width = 105
    Height = 25
    Caption = 'Button5MgrPaste'
    TabOrder = 14
    OnClick = Button5Click
  end
end
