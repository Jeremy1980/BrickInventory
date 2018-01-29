unit frm_editsetastext;

interface

uses
  Windows, Messages, SysUtils, StrUtils, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, ComCtrls, bi_db, ImportFileForm;

type
  TEditSetAsTextForm = class(TForm)
    Panel1: TPanel;
    Button1: TButton;
    Button2: TButton;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    Label1: TLabel;
    Edit1: TEdit;
    Label2: TLabel;
    Edit2: TEdit;
    Panel2: TPanel;
    Panel3: TPanel;
    txtPart: TEdit;
    boxColor: TComboBox;
    txtNum: TEdit;
    btnAdd: TButton;
    btnModify: TButton;
    Label3: TLabel;
    CheckBox1: TCheckBox;
    Button3: TButton;
    OpenDialog1: TOpenDialog;
    Memo1: TMemo;
    grpSimilars: TGroupBox;
    pnlSimilars: TPanel;
    lstSimilars: TListBox;
    procedure btnAddClick(Sender: TObject);
    procedure btnModifyClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure txtNumKeyPress(Sender: TObject; var Key: Char);
    procedure FormDestroy(Sender: TObject);
    procedure Panel3Enter(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure txtPartKeyPress(Sender: TObject; var Key: Char);
    procedure Button3Click(Sender: TObject);
  private
    { Private declarations }
    LineIndex: Integer;
    partData: TStringList;
    procedure listColors(const colors: colorinfoarray_t);
    function InLineData: String;
  public
    { Public declarations }
  end;

function EditSetAsTextForm(const setid: string; const colors: colorinfoarray_t;
    var data: string; var setinfo: TSetExtraInfo): boolean;


implementation

{$R *.dfm}

uses bi_delphi, bi_utils, timing, searchset, bi_globals;

function EditSetAsTextForm(const setid: string; const colors: colorinfoarray_t;
    var data: string; var setinfo: TSetExtraInfo): boolean;
var
  f: TEditSetAsTextForm;
  i: integer;
  s: string;
begin
  result := false;
  f := TEditSetAsTextForm.Create(nil);
  try
    f.Caption := f.Caption + ' - ' + setid;
    f.LineIndex := -1;
    f.Memo1.Text := data;
    f.CheckBox1.Checked:= setinfo.moc;
    f.Edit1.Text := setinfo.text;
    f.Edit2.Text := itoa(setinfo.year);
    ExtractStrings([FormatSettings.ListSeparator],[],PChar(setinfo.similars),f.lstSimilars.Items);

    f.listColors(colors);
    f.ShowModal;
    if f.ModalResult = mrOK then
    begin
      s:= '';
      for i:=0 to f.Memo1.Lines.Count-1 do begin
        s:= s + ReplaceWhiteSpace(f.Memo1.Lines[i],'_',false)+sLineBreak;
      end;  
      s:= StringReplace(s, '_', '', [rfReplaceAll]);
      data := s;
      setinfo.moc := f.CheckBox1.Checked;
      setinfo.text := Trim(f.Edit1.Text);
      setinfo.year := atoi(Trim(f.Edit2.Text));

      s:= Trim(ReplaceWhiteSpace(f.lstSimilars.Items.Text ,' ' ,false));
      s:= StringReplace(s, '  ', FormatSettings.ListSeparator, [rfReplaceAll]);
      setinfo.similars:= s;

      result := true;
    end;
  finally
    f.Free;
  end;
end;

function TEditSetAsTextForm.InLineData: String;
var
  F,C: String;
begin
   C:= Trim(Copy(boxColor.Text,0,Pos(':',boxColor.Text)-1));
   F:= Trim(txtPart.Text) +', '+C+','+Trim(txtNum.Text);
   result:= F;
end;

procedure TEditSetAsTextForm.listColors(const colors: colorinfoarray_t);
var
  n,m: integer;
  color: colorinfo_t;
begin
  boxColor.AddItem('   0 : Black', TObject(0));
  for n:=0 to Length(colors) -1 do begin
    color:= colors[n];
    if (color.id > 0) and (Length(Trim(color.name))>0) then
      boxColor.AddItem(LeftPad(IntToStr(color.id),4,' ')+' : '+color.name, TObject(color.id));
  end;
end;

procedure TEditSetAsTextForm.btnAddClick(Sender: TObject);
begin
   LineIndex:= 1;
   Memo1.Lines.Insert(1,InLineData());
end;

procedure TEditSetAsTextForm.btnModifyClick(Sender: TObject);
begin
   If LineIndex > 0 then
   begin
     Memo1.Lines.BeginUpdate();
     try
       Memo1.Lines[LineIndex]:= InLineData();
     finally
       Memo1.Lines.EndUpdate();
     end;
    end;
end;

procedure TEditSetAsTextForm.FormCreate(Sender: TObject);
var
  i,j,n,prev,index : integer;
  full,name : string;
begin
  SendMessage(GetWindow(boxColor.Handle,GW_CHILD), EM_SETREADONLY, 1, 0);
  partData:= TStringList.Create();
end;

procedure TEditSetAsTextForm.txtNumKeyPress(Sender: TObject;
  var Key: Char);
begin
  if not (Key in [#8, '0'..'9', FormatSettings.DecimalSeparator]) then begin
    Key := #0;
  end
end;

procedure TEditSetAsTextForm.FormDestroy(Sender: TObject);
begin
  partData.Free;
end;

procedure TEditSetAsTextForm.Panel3Enter(Sender: TObject);
var
  i,j: integer;
begin
  LineIndex:= Memo1.CaretPos.Y;
  If LineIndex > 0 then
  try
    partData.Clear;
    ExtractStrings([','], [], PChar(Memo1.Lines[LineIndex]), partData);
 finally
   If partData.Count = 3 then begin
     txtPart.Text:= partData[0];

     i:= StrToIntDef(RemoveChars(partData[1] ,true),-1);
     if (Pos(BLDATATYPE+' ',partData[1])<>0) then
      i:= db.BrickLinkColorToRebrickableColor(i);

     j:= boxColor.Items.IndexOfObject(TObject(i));
     boxColor.ItemIndex:= j;

     txtNum.Text:= RemoveChars(partData[2] ,true);
    end;
  end;
end;

procedure TEditSetAsTextForm.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  TimingForm.CrawlerTimer.Enabled := true;
end;

procedure TEditSetAsTextForm.FormShow(Sender: TObject);
begin
  TimingForm.CrawlerTimer.Enabled := false;
end;

procedure TEditSetAsTextForm.txtPartKeyPress(Sender: TObject;
  var Key: Char);
begin
  if (Key in SPECIALCHARS) then Key:= #0;
end;

procedure TEditSetAsTextForm.Button3Click(Sender: TObject);
var
  data: TStringList;
  ordValue: integer;
  source: sourcetype_t;
begin
  if OpenDialog1.Execute then
  begin
    data:= TStringList.Create;
    try
      ordValue:= OpenDialog1.FilterIndex;
      if (ordValue >= Ord(Low(sourcetype_t))) and (ordValue <= Ord(High(sourcetype_t)))
       then source:= sourcetype_t(ordValue)
       else source:= stBrickLink;

      if source = stLDCad
        then Memo1.Lines.Add( LDCadToCSV(OpenDialog1.FileName) )
        else if GetDataFromFile(OpenDialog1.FileName, source, data) then
          Memo1.Lines.AddStrings(data);
    finally
      data.Free;
    end;
  end;
end;

end.
