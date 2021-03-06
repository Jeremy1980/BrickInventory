unit searchpart;

interface

uses
  Windows, Messages, SysUtils, StrUtils, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TSearchPartForm = class(TForm)
    Label1: TLabel;
    Edit1: TEdit;
    ListBox1: TListBox;
    Button1: TButton;
    Button2: TButton;
    procedure FormCreate(Sender: TObject);
    procedure ListBox1Click(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure Edit1KeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    { Private declarations }
    FList: TStringList;
  public
    { Public declarations }
  end;

function GetPieceID(var pieceid: string): boolean;

implementation

{$R *.dfm}

uses
  bi_db, bi_globals;

function GetPieceID(var pieceid: string): boolean;
var
  f: TSearchPartForm;
begin
  Result := false;
  f := TSearchPartForm.Create(nil);
  try
    f.ShowModal;
    if f.ModalResult = mrOK then
    begin
      result := True;
      pieceid := f.Edit1.Text;
    end;
  finally
    f.Free;
  end;
end;

procedure TSearchPartForm.FormCreate(Sender: TObject);
begin
  if db = nil then
    Exit;

  ListBox1.Items.Clear;
  ListBox1.Items.AddStrings(db.AllPieces);
  FList := TStringList.Create;
  FList.Assign(db.AllPieces);
end;

procedure TSearchPartForm.ListBox1Click(Sender: TObject);
begin
  if ListBox1.Itemindex >= 0 then
    Edit1.Text := ListBox1.Items.Strings[ListBox1.Itemindex];
end;

procedure TSearchPartForm.FormDestroy(Sender: TObject);
begin
  FList.Free;
end;

procedure TSearchPartForm.FormKeyPress(Sender: TObject; var Key: Char);
begin
  if (Key = #27) then Close;
end;

procedure TSearchPartForm.Edit1KeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  i: integer;
  s: string;
begin
  ListBox1.Clear;
  try
    ListBox1.Items.BeginUpdate;
    S := Edit1.Text;
    for I := 0 to FList.Count - 1 do begin
      if AnsiContainsText(FList[I], S) then
        ListBox1.Items.Add(FList[I]);
    end;
  finally
    ListBox1.Items.EndUpdate;
  end;
  if Edit1.GetTextLen < 1 then ListBox1.Items:= FList;
end;

end.
