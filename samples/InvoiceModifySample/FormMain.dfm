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
    object Label2: TLabel
      Left = 0
      Top = 0
      Width = 209
      Height = 15
      Align = alTop
      Alignment = taCenter
      Caption = 'ACTIONS'
      ExplicitWidth = 49
    end
    object ButtonLoadInvoiceFromFile: TButton
      Left = 8
      Top = 40
      Width = 185
      Height = 33
      Caption = 'load invoice from file'
      TabOrder = 0
      OnClick = ButtonLoadInvoiceFromFileClick
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
    object Label1: TLabel
      Left = 0
      Top = 0
      Width = 690
      Height = 15
      Align = alTop
      Alignment = taCenter
      Caption = 'XML'
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
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Courier New'
      Font.Style = []
      ParentFont = False
      ScrollBars = ssBoth
      TabOrder = 0
    end
  end
  object SaveDialog1: TSaveDialog
    DefaultExt = 'xml'
    FileName = 'invoice sample'
    Left = 248
    Top = 152
  end
  object OpenDialog1: TOpenDialog
    DefaultExt = 'xml'
    Left = 248
    Top = 96
  end
end
