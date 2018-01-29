unit frm_multiplesets;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TMultipleSetsForm = class(TForm)
    Label1: TLabel;
    ListBox1: TListBox;
    Button1: TButton;
    Button2: TButton;
    AddButton: TButton;
    RemoveButton: TButton;
    ClearButton: TButton;
    procedure AddButtonClick(Sender: TObject);
    procedure RemoveButtonClick(Sender: TObject);
    procedure ClearButtonClick(Sender: TObject);
  private
    { Private declarations }
    procedure UpdateState;
  public
    { Public declarations }
  end;

function GetMultipleSetsList(const l: TStringList): Boolean;

implementation

uses
  searchset;

{$R *.dfm}

procedure TMultipleSetsForm.UpdateState;
begin
  Button1.Enabled:= ListBox1.Items.Count > 1;
end;

function GetMultipleSetsList(const l: TStringList): Boolean;
var
  f: TMultipleSetsForm;
begin
  result := false;
  f := TMultipleSetsForm.Create(nil);
  try
    f.ListBox1.Items.AddStrings(l);
    f.UpdateState;
    f.ShowModal;
    if f.ModalResult = mrOK then
    begin
      result := f.ListBox1.Items.Count > 1;
      l.Clear;
      l.AddStrings(f.ListBox1.Items);
    end;
  finally
    f.Free;
  end;
end;

procedure TMultipleSetsForm.AddButtonClick(Sender: TObject);
var
  setid: string;
begin
  if GetSetID(setid) then
  if ListBox1.Items.IndexOf(setid) = -1 then ListBox1.Items.Add(setid);
  UpdateState;
end;

procedure TMultipleSetsForm.RemoveButtonClick(Sender: TObject);
var
  i: integer;
begin
  i:= 0;
  if ListBox1.SelCount >= 0 then
   for i := ListBox1.Items.Count - 1 downto 0 do
    if ListBox1.Selected[i] then ListBox1.Items.Delete(i);
  UpdateState;
end;

procedure TMultipleSetsForm.ClearButtonClick(Sender: TObject);
begin
  ListBox1.Items.Clear;
  UpdateState;
end;

end.
