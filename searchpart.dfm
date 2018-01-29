object SearchPartForm: TSearchPartForm
  Left = 842
  Top = 350
  BorderStyle = bsDialog
  Caption = 'Seach Part'
  ClientHeight = 397
  ClientWidth = 256
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -10
  Font.Name = 'Tahoma'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnKeyPress = FormKeyPress
  PixelsPerInch = 96
  TextHeight = 12
  object Label1: TLabel
    Left = 18
    Top = 6
    Width = 62
    Height = 16
    Caption = 'Enter Part:'
    FocusControl = Edit1
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object Edit1: TEdit
    Left = 88
    Top = 6
    Width = 153
    Height = 18
    Ctl3D = False
    ParentCtl3D = False
    TabOrder = 0
    OnKeyUp = Edit1KeyUp
  end
  object ListBox1: TListBox
    Left = 12
    Top = 36
    Width = 229
    Height = 317
    Ctl3D = False
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Tahoma'
    Font.Style = []
    ItemHeight = 14
    ParentCtl3D = False
    ParentFont = False
    TabOrder = 1
    OnClick = ListBox1Click
  end
  object Button1: TButton
    Left = 70
    Top = 366
    Width = 56
    Height = 19
    Caption = 'OK'
    Default = True
    ModalResult = 1
    TabOrder = 2
  end
  object Button2: TButton
    Left = 148
    Top = 366
    Width = 56
    Height = 19
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 3
  end
end
