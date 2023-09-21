object ValidateAllForm: TValidateAllForm
  Left = 0
  Top = 0
  Caption = 'Validate all'
  ClientHeight = 608
  ClientWidth = 1006
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poScreenCenter
  TextHeight = 15
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 1006
    Height = 49
    Align = alTop
    TabOrder = 0
    ExplicitWidth = 628
    object btnValidateAll: TBitBtn
      Left = 19
      Top = 13
      Width = 134
      Height = 25
      Caption = 'Select directory'
      TabOrder = 0
      OnClick = btnValidateAllClick
    end
  end
  object PageControl1: TPageControl
    Left = 0
    Top = 49
    Width = 1006
    Height = 559
    Align = alClient
    TabOrder = 1
    ExplicitLeft = 320
    ExplicitTop = 128
    ExplicitWidth = 289
    ExplicitHeight = 193
  end
end
