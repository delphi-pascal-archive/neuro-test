object Form1: TForm1
  Left = 264
  Top = 132
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = #1053#1077#1081#1088#1086#1089#1077#1090#1100
  ClientHeight = 869
  ClientWidth = 976
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -14
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 120
  TextHeight = 16
  object Label1: TLabel
    Left = 20
    Top = 17
    Width = 70
    Height = 25
    Caption = #1057#1083#1086#1077#1074':'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -20
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label2: TLabel
    Left = 620
    Top = 20
    Width = 131
    Height = 16
    Caption = #1050#1088#1091#1090#1080#1079#1085#1072' '#1089#1080#1075#1084#1086#1080#1076#1072':'
  end
  object Label3: TLabel
    Left = 620
    Top = 49
    Width = 132
    Height = 16
    Caption = #1050#1086#1101#1092'. '#1080#1084#1087#1091#1083#1100#1089#1072' '#1053#1057'::'
  end
  object Label4: TLabel
    Left = 620
    Top = 79
    Width = 130
    Height = 16
    Caption = #1057#1082#1086#1088#1086#1089#1090#1100' '#1086#1073#1091#1095#1077#1085#1080#1103':'
  end
  object Label5: TLabel
    Left = 20
    Top = 847
    Width = 127
    Height = 16
    Caption = #1057#1050#1042' '#1054#1096#1080#1073#1082#1072' '#1053#1072#1095'.:  0'
  end
  object Label6: TLabel
    Left = 295
    Top = 847
    Width = 125
    Height = 16
    Caption = #1057#1050#1042' '#1054#1096#1080#1073#1082#1072' '#1058#1077#1082'.:  0'
  end
  object Label7: TLabel
    Left = 571
    Top = 847
    Width = 114
    Height = 16
    Caption = #1069#1087#1086#1093' '#1086#1073#1091#1095#1077#1085#1080#1103':  0'
  end
  object Label8: TLabel
    Left = 496
    Top = 811
    Width = 155
    Height = 16
    Caption = #1044#1086#1087#1091#1089#1090#1080#1084#1072#1103' '#1086#1096#1080#1073#1082#1072' '#1053#1057':'
  end
  object Label9: TLabel
    Left = 807
    Top = 847
    Width = 102
    Height = 16
    Caption = #1055#1086#1087#1072#1083#1080' '#1074' '#1084#1080#1085': 0'
  end
  object CreateNeuro: TButton
    Left = 827
    Top = 10
    Width = 139
    Height = 50
    Caption = #1057#1086#1079#1076#1072#1090#1100' '#1053#1057
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -17
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 0
    OnClick = CreateNeuroClick
  end
  object InVector: TStringGrid
    Left = 10
    Top = 108
    Width = 119
    Height = 677
    Hint = #1042#1093#1086#1076#1085#1086#1081' '#1074#1077#1082#1090#1086#1088' 0...1'
    ColCount = 2
    DefaultColWidth = 35
    RowCount = 2
    FixedRows = 0
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -17
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goEditing]
    ParentFont = False
    ParentShowHint = False
    ShowHint = True
    TabOrder = 1
  end
  object OutVector: TStringGrid
    Left = 827
    Top = 108
    Width = 139
    Height = 677
    Hint = #1042#1099#1093#1086#1076#1085#1086#1081' '#1074#1077#1082#1090#1086#1088' 0...1'
    ColCount = 2
    DefaultColWidth = 35
    RowCount = 1
    FixedRows = 0
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -17
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goEditing]
    ParentFont = False
    ParentShowHint = False
    ShowHint = True
    TabOrder = 2
    ColWidths = (
      35
      70)
  end
  object SloiCol: TStringGrid
    Left = 138
    Top = 10
    Width = 365
    Height = 90
    Hint = #1050'-'#1074#1086' '#1085#1077#1081#1088#1086#1085#1086#1074' '#1074' '#1089#1083#1086#1077'.'
    ColCount = 4
    DefaultColWidth = 50
    FixedCols = 0
    RowCount = 2
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -17
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goEditing]
    ParentFont = False
    ParentShowHint = False
    ShowHint = True
    TabOrder = 3
  end
  object SpinEdit1: TSpinEdit
    Left = 20
    Top = 49
    Width = 90
    Height = 31
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -20
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    MaxValue = 20
    MinValue = 2
    ParentFont = False
    TabOrder = 4
    Value = 4
    OnChange = SpinEdit1Change
  end
  object RadioGroup1: TRadioGroup
    Left = 512
    Top = 10
    Width = 100
    Height = 90
    Caption = ' '#1057#1076#1074#1080#1075' '#1089#1077#1090#1080' '
    ItemIndex = 0
    Items.Strings = (
      '+1'
      #1053#1077#1090)
    TabOrder = 5
  end
  object Edit1: TEdit
    Left = 758
    Top = 16
    Width = 51
    Height = 21
    TabOrder = 6
    Text = '1,0'
  end
  object Edit2: TEdit
    Left = 758
    Top = 44
    Width = 51
    Height = 21
    TabOrder = 7
    Text = '0,9'
  end
  object Edit3: TEdit
    Left = 758
    Top = 74
    Width = 51
    Height = 21
    TabOrder = 8
    Text = '0,01'
  end
  object SaveNSris: TButton
    Left = 827
    Top = 69
    Width = 139
    Height = 31
    Caption = #1057#1086#1093#1088'. '#1053#1057' '#1082#1072#1082' '#1088#1080#1089'.'
    Enabled = False
    TabOrder = 9
    OnClick = SaveNSrisClick
  end
  object Raschet: TButton
    Left = 10
    Top = 798
    Width = 129
    Height = 40
    Caption = #1056#1072#1089#1095#1077#1090' '#1089#1077#1090#1080
    Enabled = False
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -17
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 10
    OnClick = RaschetClick
  end
  object Panel1: TPanel
    Left = 138
    Top = 108
    Width = 680
    Height = 681
    TabOrder = 11
    object Image1: TImage
      Left = 1
      Top = 1
      Width = 677
      Height = 677
      ParentShowHint = False
      ShowHint = True
      OnMouseMove = Image1MouseMove
    end
  end
  object Obuch: TButton
    Left = 758
    Top = 798
    Width = 208
    Height = 40
    Caption = #1054#1073#1091#1095#1080#1090#1100' '#1087#1086' '#1074#1099#1073#1086#1088#1082#1077
    Enabled = False
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -17
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 12
    OnClick = ObuchClick
  end
  object SaveVes: TButton
    Left = 315
    Top = 798
    Width = 159
    Height = 40
    Caption = #1057#1086#1093#1088#1072#1085#1080#1090#1100' '#1074#1077#1089#1072
    Enabled = False
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -17
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 13
    OnClick = SaveVesClick
  end
  object LoadVes: TButton
    Left = 148
    Top = 798
    Width = 158
    Height = 40
    Caption = #1047#1072#1075#1088#1091#1079#1080#1090#1100' '#1074#1077#1089#1072
    Enabled = False
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -17
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 14
    OnClick = LoadVesClick
  end
  object Edit4: TEdit
    Left = 670
    Top = 807
    Width = 70
    Height = 21
    TabOrder = 15
    Text = '0,05'
  end
end
