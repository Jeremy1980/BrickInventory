unit compare2sets;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, searchset;

type
  TCompare2SetsForm = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Edit1: TEdit;
    Edit2: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Button3: TButton;
    Button4: TButton;
    procedure Button4Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Edit1Change(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

function Compare2SetsQuery(var set1, set2: string): boolean;

implementation

{$R *.dfm}

function Compare2SetsQuery(var set1, set2: string): boolean;
var
  f: TCompare2SetsForm;
begin
  Result := false;
  f := TCompare2SetsForm.Create(nil);
  try
    f.ShowModal;
    if f.ModalResult = mrOK then
    begin
      set1 := f.Edit1.Text;
      set2 := f.Edit2.Text;
      result := True;
    end;
  finally
    f.Free;
  end;
end;


procedure TCompare2SetsForm.Button4Click(Sender: TObject);
var
  setid: string;
begin
  if GetSetID(setid) then
    Edit2.Text:= setid;
end;

procedure TCompare2SetsForm.Button3Click(Sender: TObject);
var
  setid: string;
begin
  if GetSetID(setid) then
    Edit1.Text:= setid;
end;

procedure TCompare2SetsForm.Edit1Change(Sender: TObject);
begin
  Button1.Enabled:= (Length(Edit1.Text) > 0) and (Length(Edit2.Text) > 0);
end;

procedure TCompare2SetsForm.FormKeyPress(Sender: TObject; var Key: Char);
begin
  if (Key = #27) then Close;
end;

end.
