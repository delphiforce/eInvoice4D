object MainForm: TMainForm
  Left = 0
  Top = 0
  Caption = 'Invoice create sample'
  ClientHeight = 502
  ClientWidth = 899
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poScreenCenter
  TextHeight = 15
  object panelActions: TPanel
    Left = 0
    Top = 0
    Width = 209
    Height = 502
    Align = alLeft
    BevelOuter = bvNone
    Ctl3D = False
    ParentCtl3D = False
    TabOrder = 0
    ExplicitHeight = 535
    object Label2: TLabel
      Left = 0
      Top = 0
      Width = 209
      Height = 15
      Align = alTop
      Alignment = taCenter
      Caption = 'ACTIONS'
    end
    object buttonCreate: TButton
      Left = 8
      Top = 56
      Width = 185
      Height = 33
      Caption = 'create and fill invoice'
      TabOrder = 0
      OnClick = buttonCreateClick
    end
    object CheckBoxSaveToFile: TCheckBox
      Left = 40
      Top = 104
      Width = 113
      Height = 17
      Caption = 'save to file (after)'
      TabOrder = 1
    end
  end
  object panelXml: TPanel
    Left = 209
    Top = 0
    Width = 690
    Height = 502
    Align = alClient
    BevelOuter = bvNone
    Color = clWhite
    ParentBackground = False
    TabOrder = 1
    ExplicitLeft = 369
    ExplicitWidth = 525
    ExplicitHeight = 535
    object Label1: TLabel
      Left = 0
      Top = 0
      Width = 690
      Height = 15
      Align = alTop
      Alignment = taCenter
      Caption = 'XML'
      ExplicitLeft = 64
      ExplicitTop = 8
      ExplicitWidth = 24
    end
    object MemoXml: TMemo
      Left = 0
      Top = 15
      Width = 690
      Height = 487
      Align = alClient
      BevelOuter = bvNone
      BorderStyle = bsNone
      ScrollBars = ssBoth
      TabOrder = 0
    end
  end
  object SaveDialog1: TSaveDialog
    DefaultExt = 'xml'
    FileName = 'invoice sample'
    Left = 72
    Top = 144
  end
end
