object Form1: TForm1
  Left = 660
  Top = 395
  Caption = 'Form1'
  ClientHeight = 299
  ClientWidth = 635
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesigned
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object btnPaste: TButton
    Left = 168
    Top = 8
    Width = 75
    Height = 25
    Caption = #31896#36148'New'
    TabOrder = 1
    Visible = False
    OnClick = btnPasteClick
  end
  object btnCopy: TButton
    Left = 8
    Top = 8
    Width = 75
    Height = 25
    Caption = #22797#21046'New'
    TabOrder = 0
    Visible = False
    OnClick = btnCopyClick
  end
  object Button1: TButton
    Left = 80
    Top = 144
    Width = 75
    Height = 25
    Caption = 'Button1'
    TabOrder = 6
    Visible = False
    OnClick = Button1Click
  end
  object CopyNew: TButton
    Left = 8
    Top = 72
    Width = 75
    Height = 25
    Caption = #22797#21046
    TabOrder = 2
    Visible = False
    OnClick = CopyNewClick
  end
  object PasteNew: TButton
    Left = 168
    Top = 72
    Width = 75
    Height = 25
    Caption = #31896#36148
    TabOrder = 3
    Visible = False
    OnClick = PasteNewClick
  end
  object Button2: TButton
    Left = 376
    Top = 80
    Width = 75
    Height = 25
    Caption = 'Copy'
    TabOrder = 4
    OnClick = Button2Click
  end
  object Button3: TButton
    Left = 480
    Top = 80
    Width = 75
    Height = 25
    Caption = 'Paste'
    TabOrder = 5
    OnClick = Button3Click
  end
end
