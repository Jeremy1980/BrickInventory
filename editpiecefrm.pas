unit editpiecefrm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, Buttons;

type
  TEditPieceForm = class(TForm)
    Image1: TImage;
    Label1: TLabel;
    Label2: TLabel;
    Edit1: TEdit;
    SpeedButton1: TSpeedButton;
    SpeedButton2: TSpeedButton;
    Label3: TLabel;
    Memo1: TMemo;
    Button1: TButton;
    Button2: TButton;
    Label4: TLabel;
    Panel1: TPanel;
    AliasLabel: TLabel;
    AliasEdit: TEdit;
    Edit2: TEdit;
    AutodetectButton: TButton;
    LinkEdit: TEdit;
    Label5: TLabel;
    procedure SpeedButton1Click(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure AutodetectButtonClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

function EditPiece(const part: string; const color: integer): boolean;

implementation

{$R *.dfm}

uses
  bi_db, bi_delphi, bi_utils, bi_crawler, bi_globals;

function EditPiece(const part: string; const color: integer): boolean;
var
  f: TEditPieceForm;
  pci: TPieceColorInfo;
  num: integer;
  newnum: integer;
  s: TStringList;
  initialalias: string;
begin
  result := false;
  f := TEditPieceForm.Create(nil);
  try
    if color = -1 then
    begin
      f.Label1.Caption := db.GetDesc(part);
      f.Label3.Visible := false;
      f.Label4.Visible := false;
      f.Memo1.Visible := false;
      f.Panel1.Visible := false;
      f.AliasLabel.Visible := false;
      f.AliasEdit.Visible := false;
      f.AliasEdit.Text := '';
      f.AutodetectButton.Visible := false;
    end
    else
    begin
      f.Label1.Caption := db.PieceDesc(part);
      f.Label3.Visible := true;
      f.Label4.Visible := true;
      f.Memo1.Visible := true;
      f.Panel1.Visible := true;
      f.Label4.Caption := db.colors(color).name;
      f.AliasLabel.Visible := true;
      f.AliasEdit.Visible := true;
      if StrUpper(part) <> StrUpper(db.BrickLinkPart(part)) then
        f.AliasEdit.Text := db.BrickLinkPart(part)
      else
        f.AliasEdit.Text := '';
      f.AutodetectButton.Visible := true;
    end;
    f.LinkEdit.Text := db.CrawlerLink(part, color);
    f.Edit2.Text := part;
    initialalias := f.AliasEdit.Text;
    pci := db.PieceColorInfo(part, color);
    PieceToImage(f.Image1, part, color);
    if pci <> nil then
    begin
      f.Panel1.Color := RGBInvert(db.colors(color).RGB);
      f.Memo1.Lines.Text := pci.storage.Text;
      num := inventory.LoosePartCount(part, color);
      f.Edit1.Text := itoa(num);
      f.ShowModal;
      if f.ModalResult = mrOK then
      begin
        result := true;
        if strupper(strtrim(f.AliasEdit.Text)) <> strupper(strtrim(initialalias)) then
          db.AddPieceAlias(f.AliasEdit.Text, part);
        newnum := atoi(f.Edit1.Text);
        inventory.AddLoosePart(part, color, newnum - num);
        s := TStringList.Create;
        s.Text := f.Memo1.Lines.Text;
        db.AddCrawlerLink(part, color, f.LinkEdit.Text);
        db.SetPieceStorage(part, color, s);
        db.CrawlerPriorityPart(part, color);
        s.Free;
      end;
    end;
  finally
    f.Free;
  end;
end;

var
  last_pos: string = 'BOX01';

procedure TEditPieceForm.SpeedButton1Click(Sender: TObject);
var
  value: string;
begin
  value := '1';
  if InputQuery(Caption, 'Add pieces', value) then
  begin
    Edit1.Text := itoa(atoi(Edit1.Text) + atoi(value));
    if last_pos <> '' then
      Memo1.Lines.Add(last_pos + ':' + value);
  end;
end;

procedure TEditPieceForm.SpeedButton2Click(Sender: TObject);
var
  value: string;
  num: integer;
begin
  value := '1';
  if InputQuery(Caption, 'Remove pieces', value) then
  begin
    num := atoi(Edit1.Text) - atoi(value);
    if num < 0 then
      num := 0;
    Edit1.Text := itoa(num);
    if last_pos <> '' then
      Memo1.Lines.Add(last_pos + ':-' + value);
  end;
end;

procedure TEditPieceForm.FormClose(Sender: TObject;
  var Action: TCloseAction);
var
  s: string;
  i: integer;
  p: integer;
  s1, s2: string;
begin
  for i := Memo1.Lines.Count - 1 downto 0 do
  begin
    Memo1.Lines.Strings[i] := trim(Memo1.Lines.Strings[i]);
    if Memo1.Lines.Strings[i] = '' then
      Memo1.Lines.Delete(i);
  end;
  if Memo1.Lines.Count = 0 then
    exit;
  s := Memo1.Lines.Strings[Memo1.Lines.Count - 1];
  p := Pos(':', s);
  if p <= 0 then
    exit;
  splitstringex(s, s1, s2, ':');
  if s1 <> '' then
    last_pos := s1;
end;

procedure TEditPieceForm.AutodetectButtonClick(Sender: TObject);
var
  s: string;
begin
  Screen.Cursor := crHourglass;
  s := NET_GetBricklinkAlias(Edit2.Text);
  Screen.Cursor := crDefault;
  if s = '' then
    if AliasEdit.Text <> '' then
      exit;
  AliasEdit.Text := s;
end;

end.
