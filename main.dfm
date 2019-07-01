object MainForm: TMainForm
  Left = 0
  Top = 0
  Caption = 'demo'
  ClientHeight = 452
  ClientWidth = 853
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Memo1: TMemo
    Left = 8
    Top = 39
    Width = 433
    Height = 394
    Lines.Strings = (
      'print 1 + 2;')
    TabOrder = 0
  end
  object Button1: TButton
    Left = 8
    Top = 8
    Width = 75
    Height = 25
    Caption = 'Scan'
    TabOrder = 1
    OnClick = Button1Click
  end
  object Memo2: TMemo
    Left = 447
    Top = 39
    Width = 398
    Height = 394
    TabOrder = 2
  end
end
