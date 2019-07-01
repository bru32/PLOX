object MainForm: TMainForm
  Left = 0
  Top = 0
  Caption = 'demo'
  ClientHeight = 573
  ClientWidth = 895
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  DesignSize = (
    895
    573)
  PixelsPerInch = 96
  TextHeight = 13
  object Memo1: TMemo
    Left = 8
    Top = 39
    Width = 433
    Height = 515
    Anchors = [akLeft, akTop, akBottom]
    Font.Charset = DEFAULT_CHARSET
    Font.Color = 8421440
    Font.Height = -17
    Font.Name = 'Consolas'
    Font.Style = []
    Lines.Strings = (
      'fn test(a) {'
      '  return 2*a;'
      '}'
      ''
      'x = test(2.0);'
      'y = tesy(3.0);'
      'z = x + y;')
    ParentFont = False
    TabOrder = 0
    ExplicitHeight = 670
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
    Width = 440
    Height = 515
    Anchors = [akLeft, akTop, akRight, akBottom]
    Font.Charset = DEFAULT_CHARSET
    Font.Color = 8421440
    Font.Height = -17
    Font.Name = 'Consolas'
    Font.Style = []
    ParentFont = False
    TabOrder = 2
    ExplicitWidth = 510
    ExplicitHeight = 670
  end
end
