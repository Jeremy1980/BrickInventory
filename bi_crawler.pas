unit bi_crawler;

interface

uses
  WinInet, SysUtils, Classes, bi_db;

function NET_GetPriceGuideForElement(id: string; const color: string;
  var ret1: priceguide_t; var ret2: availability_t; const cachefile: string): boolean;

function NET_GetBricklinkAlias(const id: string): string;

var
  AllowInternetAccess: Boolean = True;
  
implementation

uses
  Dialogs, Windows, bi_delphi, bi_script, bi_utils, bi_system, bi_globals;

var
  hSession: HInternet;

procedure OpenInetConnection;
begin
  hSession := InternetOpen(
                 'Microsoft Internet Explorer',  // agent. (can be "Microsoft Internet Explorer")
                 INTERNET_OPEN_TYPE_PRECONFIG,   // access
                 nil,                            // proxy server
                 nil,                            // defauts
                 0);                             // synchronous
end;

procedure CloseInetConnection;
begin
  InternetCloseHandle(hSession); // close connection to internet
end;

const
  BUFFERSIZE = $4000;
  MAXRETRY = 3;
  DELAYR = 10;

function GetURLString(const URL: string; XXX: integer = 0): string;
var
  hURL: HInternet;
  Buffer: array[1..BUFFERSIZE] of Char;
  BufferLen: Cardinal;
  i: integer;
  len: integer;
begin
  if not AllowInternetAccess then
  begin
    result := '';
    exit;
  end;

  if XXX > MAXRETRY then
  begin
    result := '';
    exit;
  end;

  if XXX = MAXRETRY then
  begin
    CloseInetConnection;
    OpenInetConnection;
  end;

  hURL := InternetOpenURL(
                 hSession,          // Handle to current session
                 PChar(URL),        // URL to read
                 nil,               // HTTP headers to send to server
                 0,                 // Header length
                 0, 0);             // flags   (might want to add some like INTERNET_FLAG_RELOAD with forces a reload from server and not from cache)

  if hURL = nil then
  begin
    inc(XXX);
    sleep(DELAYR);
    result := GetURLString(URL, XXX);
    exit;
  end;

  result := '';

  try
  repeat
    InternetReadFile(
        hURL,                  // File URL
        @Buffer,               // Buffer that receives data
        SizeOf(Buffer),        // bytes to read
        BufferLen);            // bytes read
    if (BufferLen > 0) then
    begin
      len := Length(Result);
      SetLength(result, Length(Result) + BufferLen);
      for i := 1 to BufferLen do
        result[len + i] := Buffer[i];
    end;
  until BufferLen = 0;
  except
    result := '';
    SetLength(result, 0);
    CloseInetConnection;
  end;
end;

function NET_GetPriceGuideForElement(id: string; const color: string;
  var ret1: priceguide_t; var ret2: availability_t; const cachefile: string): boolean;
const          
  setlink = 'http://www.bricklink.com/catalogPG.asp?S=';
  partlink = 'http://www.bricklink.com/catalogPG.asp?P=';
  figurelink = 'http://www.bricklink.com/catalogPG.asp?M=';
  gearlink = 'http://www.bricklink.com/catalogPG.asp?G=';
var
  link: string;
  cc: integer;
  htm, s1: string;
  i, p: integer;
  lvl: Integer;
  instr: boolean;
  strsign: char;
  c: char;
  sc: TScriptEngine;
  result_t: array[1..24] of Double;
  token: string;
  idx: integer;
  skeep: string;
  loadedfromcache: boolean;
begin
  Result := false;
  FillChar(ret1, SizeOf(priceguide_t), 0);
  FillChar(ret2, SizeOf(availability_t), 0);
  link := db.CrawlerLink(id, atoi(color));
  if link = '' then
  begin
    id := db.BrickLinkPart(id);
    if (color = '89') or (color = '') or ((color = '-1') and (Pos('-', id) > 0))  then // set
      link := setlink + id + '--&colorID=0&v=D&viewExclude=Y&cID=Y&prDec=6'
    else if color = '-1' then // minifigure
      link := figurelink + id + '&prDec=6'
    else // part
    begin
      cc := StrToIntDef(color, -2);
      if (cc < -1) or (cc > MAXINFOCOLOR) then
        link := partlink + id + '&colorID=0&prDec=6'
      else
        link := partlink + id + '&colorID=' + IntToStr(db.colors(cc).BrickLinkColor) + '&prDec=6';
    end;
  end;
  loadedfromcache := false;
  htm := GetURLString(link);
  if htm <> '' then
    skeep := htm
  else
  begin
    skeep := '';
    if FileExists(cachefile) then
    begin
      with TStringList.Create do
      try
        LoadFromFile(cachefile);
        loadedfromcache := true;
        skeep := Text;
        htm := skeep;
      finally
        Free;
      end;
    end;
  end;
  if htm = '' then
    exit;

  cc := StrToIntDef(color, -2);
  p := Pos('Last 6 Months Sales', htm);
  if p <= 0 then
  begin
    if (Pos('3068bpb', id) = 1) and (length(id) = 10) then
    begin
      id := '3068bpb0' + id[8] + id[9] + id[10];
      cc := StrToIntDef(color, -2);
      if (cc < -1) or (cc > MAXINFOCOLOR) then
        link := partlink + id + '&colorID=0&prDec=6'
      else
        link := partlink + id + '&colorID=' + IntToStr(db.colors(cc).BrickLinkColor) + '&prDec=6';
      loadedfromcache := false;
      htm := GetURLString(link);
      if htm <> '' then
        skeep := htm
    end
    else if color = '9999' then
    begin
      cc := StrToIntDef(color, -2);
      link := figurelink + id + '&prDec=6';
      loadedfromcache := false;
      htm := GetURLString(link);
      if htm <> '' then
        skeep := htm
    end
    else
    begin
      cc := StrToIntDef(color, -2);
      if (cc < -1) or (cc > MAXINFOCOLOR) then
        link := gearlink + id + '&colorID=0&prDec=6'
      else
        link := gearlink + id + '&colorID=' + IntToStr(db.colors(cc).BrickLinkColor) + '&prDec=6';
      loadedfromcache := false;
      htm := GetURLString(link);
      if htm <> '' then
        skeep := htm
    end;
  end;
  
  p := Pos('Last 6 Months Sales', htm);
  if p <= 0 then
  begin
  {$IFNDEF CRAWLER}
    I_Warning('NET_GetPriceGuideForElement(): Can not retrieve bricklink info for part=%s, color=%s', [id, itoa(cc)]);
  {$ENDIF}
    Exit;
  end;

  htm := Copy(htm, p, Length(htm) - p + 1);

  lvl := 0;
  instr := false;
  s1 := '';
  strsign := ' ';
  for i := 1 to Length(htm) do
  begin
    c := htm[i];
    if c = '<' then
    begin
      if not instr then
        inc(lvl);
    end
    else if c = '>' then
    begin
      if not instr then
        Dec(lvl);
    end
    else if (c in ['''','"']) and (lvl = 0) then
    begin
      if instr then
      begin
        if strsign = c then
          instr := false
      end
      else
      begin
        strsign := c;
        instr := True;
      end;
    end;
    if not instr and (lvl = 0) then
      if not (c in ['>', '''', '"']) then
        s1 := s1 + c
      else
        s1 := s1 + ' ';
  end;

  s1 := StringReplace(s1, '&nbsp;', ' ', [rfReplaceAll, rfIgnoreCase]);
  s1 := StringReplace(s1, ':', ' ', [rfReplaceAll, rfIgnoreCase]);
  s1 := StringReplace(s1, '~EUR' , '',  [rfReplaceAll, rfIgnoreCase]);
  s1 := StringReplace(s1, 'EUR' , '',  [rfReplaceAll, rfIgnoreCase]);
  s1 := StringReplace(s1, 'Times Sold' , 'TimesSold',  [rfReplaceAll, rfIgnoreCase]);
  s1 := StringReplace(s1, 'Total Lots' , 'TotalLots',  [rfReplaceAll, rfIgnoreCase]);
  s1 := StringReplace(s1, 'Total Qty' , 'TotalQty',  [rfReplaceAll, rfIgnoreCase]);
  s1 := StringReplace(s1, 'Min Price' , 'MinPrice',  [rfReplaceAll, rfIgnoreCase]);
  s1 := StringReplace(s1, 'Qty Avg Price' , 'QtyAvgPrice',  [rfReplaceAll, rfIgnoreCase]);
  s1 := StringReplace(s1, 'Avg Price' , 'AvgPrice',  [rfReplaceAll, rfIgnoreCase]);
  s1 := StringReplace(s1, 'Max Price' , 'MaxPrice',  [rfReplaceAll, rfIgnoreCase]);

  FillChar(result_t, SizeOf(result_t), 0);

  idx := 1;

  sc := TScriptEngine.Create(s1);
  while sc.GetString do
  begin
    token := UpperCase(sc._String);
    if token = 'UNAVAILABLE' then
      idx := idx + 6
    else if (token = 'TIMESSOLD') or (token = 'TOTALQTY') or (token = 'TOTALLOTS') then
    begin
      sc.MustGetInteger;
      result_t[idx] := sc._Integer;
      Inc(idx);
    end
    else if (token = 'MINPRICE') or (token = 'MAXPRICE') or (token = 'QTYAVGPRICE') or (token = 'AVGPRICE') then
    begin
      sc.MustGetFloat;
      result_t[idx] := sc._Float;
      Inc(idx);
    end;
    if idx > 24 then
      Break;
  end;
  sc.Free;

  if idx <= 24 then
    exit;

  ret1.nTimesSold := Round(result_t[1]);
  ret1.nTotalQty := Round(result_t[2]);
  ret1.nMinPrice := result_t[3];
  ret1.nAvgPrice := result_t[4];
  ret1.nQtyAvgPrice := result_t[5];
  ret1.nMaxPrice := result_t[6];
  ret1.uTimesSold := Round(result_t[7]);
  ret1.uTotalQty := Round(result_t[8]);
  ret1.uMinPrice := result_t[9];
  ret1.uAvgPrice := result_t[10];
  ret1.uQtyAvgPrice := result_t[11];
  ret1.uMaxPrice := result_t[12];

  ret2.nTotalLots := Round(result_t[12 + 1]);
  ret2.nTotalQty := Round(result_t[12 + 2]);
  ret2.nMinPrice := result_t[12 + 3];
  ret2.nAvgPrice := result_t[12 + 4];
  ret2.nQtyAvgPrice := result_t[12 + 5];
  ret2.nMaxPrice := result_t[12 + 6];
  ret2.uTotalLots := Round(result_t[12 + 7]);
  ret2.uTotalQty := Round(result_t[12 + 8]);
  ret2.uMinPrice := result_t[12 + 9];
  ret2.uAvgPrice := result_t[12 + 10];
  ret2.uQtyAvgPrice := result_t[12 + 11];
  ret2.uMaxPrice := result_t[12 + 12];

  with TStringList.Create do
  try
    Text := skeep;
{    if not loadedfromcache then
      backupfile(cachefile);}
    try
      SaveToFile(cachefile);
    except
      
    end;
  finally
    Free;
  end;
  result := true;
end;

function NET_GetBricklinkAlias(const id: string): string;
var
  s: string;
  s1: string;
  p: integer;
  i: integer;
begin
  result := '';
  s := GetURLString('http://rebrickable.com/parts/' + strtrim(id));
  s1 := 'http://www.bricklink.com/catalogItem.asp?P=';
  p := Pos(s1, s);
  if p > 0 then
  begin
    p := p + Length(s1);
    for i := p to length(s) do
    begin
      if s[i] = '''' then
        break
      else
        result := result + s[i];
    end;
  end;
end;

initialization
  OpenInetConnection;

finalization
  CloseInetConnection;

end.
