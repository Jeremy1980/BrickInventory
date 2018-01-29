unit removepiecefromstoragefrm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls;

type
  TRemovePieceFromStorageForm = class(TForm)
    Image1: TImage;
    Button1: TButton;
    Button2: TButton;
    Edit1: TEdit;
    Label5: TLabel;
    Label2: TLabel;
    Label1: TLabel;
    Panel1: TPanel;
    Label4: TLabel;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

function RemovePieceFromStorageForSet(const part: string; const color: integer; const setid: string; const storage: string): boolean;
function RemovePieceFromStorage(const part: string; const color: integer; num: integer; const storage: string): boolean;

implementation

{$R *.dfm}

uses
  bi_delphi, bi_utils, bi_db, bi_globals;

function RemovePieceFromStorageForSet(const part: string; const color: integer; const setid: string; const storage: string): boolean;
var
  inv: TBrickInventory;
  num: integer;
begin
  inv := db.GetSetInventory(setid);
  if inv = nil then
  begin
    result := false;
    exit;
  end;
  num := inv.LoosePartCount(part, color);
  if num = 0 then
  begin
    Result := false;
    Exit;
  end;
  Result := RemovePieceFromStorage(part, color, num, storage);
end;

function RemovePieceFromStorage(const part: string; const color: integer; num: integer; const storage: string): boolean;
var
  f: TRemovePieceFromStorageForm;
  pci: TPieceColorInfo;
  inv: TBrickInventory;
  s: TStringList;
  invmax: integer;
begin
  result := false;
  if color = -1 then
    Exit;
  inv := db.InventoryForStorageBin(storage);
  if inv = nil then
    Exit;
  invmax := inv.LoosePartCount(part, color);
  if invmax < num then
    num := invmax;
  inv.Free;
  if num <= 0 then
    Exit;

  f := TRemovePieceFromStorageForm.Create(nil);
  try
    f.Label1.Caption := db.PieceDesc(part);
    f.Label2.Visible := true;
    f.Label4.Visible := true;
    f.Label5.Visible := true;
    f.Panel1.Visible := true;
    f.Label4.Caption := db.colors(color).name;
    f.Edit1.Text := itoa(num);
    if num = 1 then
      f.Label2.Caption := 'piece from storage ' + storage + '?'
    else
      f.Label2.Caption := 'pieces from storage ' + storage + '?';
    pci := db.PieceColorInfo(part, color);
    PieceToImage(f.Image1, part, color);
    if pci <> nil then
    begin
      f.Panel1.Color := RGBInvert(db.colors(color).RGB);
      f.ShowModal;
      if f.ModalResult = mrOK then
      begin
        s := TStringList.Create;
        s.Text := pci.storage.Text;

        num := atoi(f.Edit1.Text);
        if num > invmax then
          num := invmax;
        if num > 0 then
        begin
          s.Add(storage + ':-' + itoa(num));
          db.SetPieceStorage(part, color, s);
          Result := true;
        end
        else
        begin
          Result := false;
        end;
        s.Free;
      end;
    end;

  finally
    f.Free;
  end;
end;

end.
