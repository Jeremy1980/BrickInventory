object ImportFileForm: TImportFileForm
  Left = 527
  Top = 482
  BorderStyle = bsDialog
  Caption = 'Import File'
  ClientHeight = 130
  ClientWidth = 588
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 16
    Top = 11
    Width = 49
    Height = 16
    Caption = 'Source: '
    FocusControl = Edit1
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object Label2: TLabel
    Left = 76
    Top = 40
    Width = 24
    Height = 16
    Caption = 'Part'
    FocusControl = ComboBox1
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
  end
  object Label3: TLabel
    Left = 232
    Top = 40
    Width = 32
    Height = 16
    Caption = 'Color'
    FocusControl = ComboBox2
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
  end
  object Label4: TLabel
    Left = 384
    Top = 40
    Width = 48
    Height = 16
    Caption = 'Quantity'
    FocusControl = ComboBox3
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
  end
  object Edit1: TEdit
    Left = 80
    Top = 10
    Width = 401
    Height = 19
    AutoSelect = False
    Color = clSilver
    Ctl3D = False
    ParentCtl3D = False
    ReadOnly = True
    TabOrder = 0
  end
  object ComboBox1: TComboBox
    Left = 16
    Top = 64
    Width = 145
    Height = 21
    TabOrder = 1
  end
  object ComboBox2: TComboBox
    Left = 176
    Top = 64
    Width = 145
    Height = 21
    TabOrder = 2
  end
  object ComboBox3: TComboBox
    Left = 336
    Top = 64
    Width = 145
    Height = 21
    TabOrder = 3
  end
  object Button1: TButton
    Left = 496
    Top = 8
    Width = 75
    Height = 25
    Caption = 'Do It '
    ModalResult = 1
    TabOrder = 4
  end
  object Button2: TButton
    Left = 496
    Top = 40
    Width = 75
    Height = 25
    Caption = 'Abort'
    ModalResult = 3
    TabOrder = 5
  end
end
