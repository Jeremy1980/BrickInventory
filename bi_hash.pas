unit bi_hash;

interface

uses
  SysUtils, Classes, bi_delphi;

const
  HASHSIZE = 4096;

type
  THashTable = class(TObject)
  private
    positions: array[0..HASHSIZE - 1] of TDNumberList;
    fList: TStringList;
  public
    constructor Create; virtual;
    destructor Destroy; override;
    procedure AssignStringList(const s: TStringList);
    procedure Insert(const str: string; const p: integer);
    procedure Clear;
    function GetPos(const value: string): integer;
    function CheckPos(const value: string): integer;
    property List: TStringList read fList;
  end;

type
  THashStringList = class(TStringList)
  protected
    fhash: THashTable;
    procedure InsertItem(Index: Integer; const S: string; AObject: TObject); override;
  public
    constructor Create;
    destructor Destroy; override;
    function IndexOf(const S: string): Integer; override;
    procedure RebuiltHash;
  end;

procedure FreeHashList(var s: THashStringList);

implementation

function Hash(const name: string): integer;
var
  b: Byte;
  i: integer;
  len: integer;
begin
  len := Length(name);
  if len = 0 then
  begin
    Result := 0;
    exit;
  end;

  b := Ord(name[1]);

  result := 5381 * 33 + b;

  for i := 2 to len do
  begin
    b := Ord(name[i]);
    result := result * 33 + b;
  end;

  result := result and (HASHSIZE - 1);
end;

constructor THashTable.Create;
begin
  inherited;
  flist := nil;
  FillChar(positions, SizeOf(positions), 0);
end;

destructor THashTable.Destroy;
var
  i: integer;
begin
  for i := 0 to HASHSIZE - 1 do
    if positions[i] <> nil then
      positions[i].Free;
  inherited;
end;

procedure THashTable.Insert(const str: string; const p: integer);
var
  h: integer;
begin
  if flist = nil then
    exit;

  h := Hash(str);
  if positions[h] = nil then
    positions[h] := TDNumberList.Create;
  positions[h].Add(p);
end;

procedure THashTable.AssignStringList(const s: TStringList);
var
  i: integer;
  h: integer;
begin
  Clear;
  flist := s;
  for i := 0 to flist.Count - 1 do
  begin
    h := Hash(flist.Strings[i]);
    if positions[h] = nil then
      positions[h] := TDNumberList.Create;
    positions[h].Add(i);
  end;
end;

procedure THashTable.Clear;
var
  i: integer;
begin
  for i := 0 to HASHSIZE - 1 do
    if positions[i] <> nil then
      positions[i].Clear;
end;

function THashTable.GetPos(const value: string): integer;
var
  h: integer;
  i: integer;
  n: integer;
begin
  if flist = nil then
  begin
    result := -1;
    exit;
  end;

  if flist.Count = 0 then
  begin
    result := -1;
    exit;
  end;

  h := Hash(value);
  if positions[h] = nil then
  begin
    result := fList.IndexOf(value);
    exit;
  end;

  for i := 0 to positions[h].Count - 1 do
  begin
    n := positions[h].Numbers[i];
    if (n > -1) and (n < fList.Count) then
      if flist.Strings[n] = value then
      begin
        result := n;
        exit;
      end;
  end;

  result := fList.IndexOf(value);
end;

function THashTable.CheckPos(const value: string): integer;
var
  h: integer;
  i: integer;
  n: integer;
begin
  h := Hash(value);
  if positions[h] = nil then
  begin
    result := -1;
    exit;
  end;

  for i := 0 to positions[h].Count - 1 do
  begin
    n := positions[h].Numbers[i];
    if (n > -1) and (n < fList.Count) then
      if flist.Strings[n] = value then
      begin
        result := n;
        exit;
      end;
  end;

  result := -1;
end;

constructor THashStringList.Create;
begin
  fhash := THashTable.Create;
  Inherited Create;
  fhash.AssignStringList(self);
end;

destructor THashStringList.Destroy;
begin
  Inherited;
  fhash.Free;
end;

procedure THashStringList.InsertItem(Index: Integer; const S: string; AObject: TObject);
var
  rebuildhash: boolean;
begin
  rebuildhash := Index < Count;
  inherited InsertItem(Index, S, AObject);
  if rebuildhash then
  begin
    if not Sorted then
      fhash.AssignStringList(self);
  end
  else
    fhash.Insert(s, Index);
end;

function THashStringList.IndexOf(const S: string): Integer;
begin
  if Sorted then
  begin
    if not Find(S, Result) then Result := -1;
    exit;
  end;

  if Count = 0 then
  begin
    Result := -1;
    exit;
  end;

  result := fhash.CheckPos(S);
end;

procedure FreeHashList(var s: THashStringList);
var
  i: integer;
begin
  if s = nil then
    exit;
  for i := 0 to s.Count - 1 do
    s.Objects[i].Free;
  s.Free;
  s := nil;
end;

procedure THashStringList.RebuiltHash;
begin
  fhash.AssignStringList(self);
end;

end.
