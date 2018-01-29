unit bi_binaryset;

interface

uses
  SysUtils, Classes, bi_delphi, bi_hash;

const
  RECNAMESIZE = 15;
  CACHESIZE = 8;

type
  TBinarySetItem = packed record
    piece: string[RECNAMESIZE];
    color: integer;
    num: integer;
    cost: double;
  end;

const
  MAXSETITEMS = 300;

type
  TBinarySetData = array[0..MAXSETITEMS - 1] of TBinarySetItem;
  PBinarySetData = ^TBinarySetData;

type
  TBinarySetRecord = record
    name: string[RECNAMESIZE];
    desc: string[128];
    year: integer;
    numitems: Integer;
    data: TBinarySetData;
  end;
  PBinarySetRecord = ^TBinarySetRecord;

type
  TBinarySetCollection = class(TObject)
  private
    fsets: THashStringList;
    fvoids: TDNumberList;
    fname: string;
    f: TFileStream;
    cacheidx: integer;
    cache: array[0..CACHESIZE - 1] of TBinarySetRecord;
  public
    constructor Create(const aname: string); virtual;
    destructor Destroy; override;
    function GetSet(const setname: string): PBinarySetRecord;
    function GetSetAsText(const setname: string): string;
    function UpdateSetFromTextFile(const aset, aTextFileName: string): boolean;
    function UpdateSetFromText(const aset, aText: string): boolean; overload;
    function UpdateSetFromText(const aset: string; str: TStringList): boolean; overload;
    function DeleteSet(const aset: string): boolean;
  end;


implementation

uses
  bi_globals, bi_utils;

type
  TRecordInfo = class
  public
    position: Int64;
    constructor Create(const apos: Int64);
  end;

constructor TRecordInfo.Create(const apos: Int64);
begin
  position := apos;
end;

constructor TBinarySetCollection.Create(const aname: string);
var
  i: integer;
  setname: string[RECNAMESIZE];
begin
  cacheidx := 0;
  ZeroMemory(@cache, SizeOf(cache));
  fname := aname;
  fsets := THashStringList.Create;
  fvoids := TDNumberList.Create;

  if not fexists(fname) then
  begin
    f := TFileStream.Create(fname, fmCreate or fmShareDenyWrite);
    f.Free;
  end;
  {$IFDEF CRAWLER}
  f := TFileStream.Create(fname, fmOpenRead or fmShareDenyNone);
  {$ELSE}
  if fexists(fname) then
    backupfile(fname);
  f := TFileStream.Create(fname, fmOpenReadWrite or fmShareDenyWrite);
  {$ENDIF}
  for i := 0 to (f.Size div SizeOf(TBinarySetRecord)) - 1 do
  begin
    f.Position := i * SizeOf(TBinarySetRecord);
    f.read(setname, SizeOf(setname));
    if setname = '' then
      fvoids.Add(i * SizeOf(TBinarySetRecord))
    else
      fsets.AddObject(setname, TRecordInfo.Create(i * SizeOf(TBinarySetRecord)));
  end;

  inherited Create;
end;

destructor TBinarySetCollection.Destroy;
begin
  FreeHashList(fsets);
  f.Free;
  fvoids.Free;
  inherited;
end;

function TBinarySetCollection.GetSet(const setname: string): PBinarySetRecord;
var
  idx: integer;
begin
  idx := fsets.IndexOf(setname);
  if idx < 0 then
  begin
    result := nil;
    exit;
  end;

  f.Position := (fsets.Objects[idx] as TRecordInfo).position;
  f.Read(cache[cacheidx], SizeOf(TBinarySetRecord));
  Result := @cache[cacheidx];
  Inc(cacheidx);
  if cacheidx >= CACHESIZE then
    cacheidx := 0;
end;

function TBinarySetCollection.GetSetAsText(const setname: string): string;
var
  rec: TBinarySetRecord;
  i, idx: integer;
begin
  result := 'Part,Color,Num';
  idx := fsets.IndexOf(setname);
  if idx < 0 then
    exit;

  f.Position := (fsets.Objects[idx] as TRecordInfo).position;
  f.Read(rec, SizeOf(TBinarySetRecord));
  for i := 0 to rec.numitems - 1 do
    result := result + #13#10 + rec.data[i].piece + ',' + itoa(rec.data[i].color) + ',' + itoa(rec.data[i].num);
end;

function TBinarySetCollection.UpdateSetFromTextFile(const aset, aTextFileName: string): boolean;
var
  s: TStringList;
begin
  if not fexists(aTextFileName) then
  begin
    Result := false;
    exit;
  end;
  s := TStringList.Create;
  s.LoadFromFile(aTextFileName);
  Result := UpdateSetFromText(aset, s);
  s.Free;
end;

function TBinarySetCollection.UpdateSetFromText(const aset, aText: string): boolean;
var
  s: TStringList;
begin
  s := TStringList.Create;
  s.Text := aText;
  Result := UpdateSetFromText(aset, s);
  s.Free;
end;

function TBinarySetCollection.UpdateSetFromText(const aset: string; str: TStringList): boolean;
var
  rec: TBinarySetRecord;
  i, idx: integer;
  spart, scolor, snum, scost: string;
begin
  {$IFDEF CRAWLER}
  result := false;
  Exit;                                  
  {$ENDIF}
  if str = nil then
  begin
    result := false;
    exit;
  end;
  if str.count = 0 then
  begin
    result := false;
    exit;
  end;
  if str.count > MAXSETITEMS then
  begin
    result := false;
    exit;
  end;
  if fvoids.Count = 0 then
    if f.Size > 2147418112 - 2 * SizeOf(TBinarySetRecord) then
    begin
      result := false;
      exit;
    end;

  ZeroMemory(@rec, SizeOf(TBinarySetRecord));
  rec.name := aset;
  rec.numitems := str.Count - 1;
  if (str.Strings[0] = 'Part,Color,Num') then
  begin
    for i := 1 to str.count - 1 do
    begin
      splitstringex(str.Strings[i], spart, scolor, snum, ',');
      if Pos('BL ', spart) = 1 then
        rec.data[i - 1].piece := db.RebrickablePart(Copy(spart, 4, Length(spart) - 3))
      else
        rec.data[i - 1].piece := db.RebrickablePart(spart);

      if Pos('BL', scolor) = 1 then
      begin
        scolor := Copy(scolor, 3, Length(scolor) - 2);

        rec.data[i - 1].color := db.BrickLinkColorToRebrickableColor(StrToIntDef(scolor, 0));
      end
      else
      begin
        rec.data[i - 1].color := StrToIntDef(scolor, 0);
      end;
      rec.data[i - 1].num := atoi(snum);

      rec.data[i - 1].cost := 0.0;
    end;
  end;
  if (str.Strings[0] = 'Part,Color,Num,Cost') then
  begin
    for i := 1 to str.count - 1 do
    begin
      splitstringex(str.Strings[i], spart, scolor, snum, scost, ',');
      if Pos('BL ', spart) = 1 then
        rec.data[i - 1].piece := db.RebrickablePart(Copy(spart, 4, Length(spart) - 3))
      else
        rec.data[i - 1].piece := db.RebrickablePart(spart);

      if Pos('BL', scolor) = 1 then
      begin
        scolor := Copy(scolor, 3, Length(scolor) - 2);

        rec.data[i - 1].color := db.BrickLinkColorToRebrickableColor(StrToIntDef(scolor, 0));
      end
      else
      begin
        rec.data[i - 1].color := StrToIntDef(scolor, 0);
      end;
      rec.data[i - 1].num := atoi(snum);

      rec.data[i - 1].cost := atof(scost);
    end;
  end;

  idx := fsets.indexOf(aset);
  if idx < 0 then
  begin
    if fvoids.Count > 0 then
    begin
      idx := fsets.AddObject(aset, TRecordInfo.Create(fvoids.Numbers[fvoids.Count - 1]));
      fvoids.Delete(fvoids.Count - 1)
    end
    else
      idx := fsets.AddObject(aset, TRecordInfo.Create(f.size));
  end;
  f.Position := (fsets.Objects[idx] as TRecordInfo).position;
  f.Write(rec, SizeOf(TBinarySetRecord));
  result := true;
end;

function TBinarySetCollection.DeleteSet(const aset: string): boolean;
var
  rec: TBinarySetRecord;
  idx: integer;
begin
  idx := fsets.indexOf(aset);
  if idx < 0 then
  begin
    result := false;
    exit;
  end;

  ZeroMemory(@rec, RECNAMESIZE * SizeOf(Char));
  f.Position := (fsets.Objects[idx] as TRecordInfo).position;
  f.Write(rec, RECNAMESIZE * SizeOf(Char));
  fsets.Delete(idx);
  fsets.RebuiltHash;
  result:= true;
end;

end.
