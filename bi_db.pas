unit bi_db;

interface

uses
  SysUtils, Classes, Dialogs, bi_hash, bi_threads, bi_currency, bi_delphi,
  bi_binaryset;

const
  SPECIALCHARS : set of char = ['.','/','!','@','#','$','%','^','&','*','''','"',';','_','(',')',':','|','[',']'];
  BLDATATYPE: string = 'BL';
  MAXBRICKLINKCOLOR = 256;
  MAXINFOCOLOR = 9999;
  NOACTIONCAPTION: string = 'Nothing to do';
  MINYEAR = 1932;

type
  sourcetype_t = (stUnsuported, stBrickLink ,stRebrickable ,stLDCad);

  colorinfo_t = record
    id: integer;
    name: string[24];
    RGB: LongWord;
    nParts: integer;
    nSets: integer;
    fYear: integer;
    yYear: integer;
    legoColor: string[24];
    ldrawColor: integer;
    BrickLinkColor: integer;
    PeeronColor: string[24];
    alternateid: integer;
    knownpieces: THashStringList;
  end;
  colorinfo_p = ^colorinfo_t;

  colorinfoarray_t = array[-1..MAXINFOCOLOR] of colorinfo_t;
  colorinfoarray_p = ^colorinfoarray_t;

type
  progressfunc_t = procedure (const s: string; a: double) of object;

  brickpool_t = record
    part: string[15];
    color: integer;
    num: integer;
  end;

  brickpool_p = ^brickpool_t;
  brickpool_a = array[0..$FFFF] of brickpool_t;
  brickpool_pa = ^brickpool_a;

  set_t = record
    setid: string[15];
    num: integer;
    dismantaled: integer;
  end;

  set_p = ^set_t;
  set_a = array[0..$FFFF] of set_t;
  set_pa = ^set_a;

type
  partout_t = record
    percentage: Double;
    value: Double;
  end;

const
  B_HASHSIZE = $FFF;

type
  bhashitem_t = record
    position: integer;
  end;
  bhashtable_t = array[0..B_HASHSIZE] of bhashitem_t;

type
  brickstatshistory_t = record
    time: TDateTime;
    Sold_nAvg: partout_t;
    Sold_nQtyAvg: partout_t;
    Sold_uAvg: partout_t;
    Sold_uQtyAvg: partout_t;
    Avail_nAvg: partout_t;
    Avail_nQtyAvg: partout_t;
    Avail_uAvg: partout_t;
    Avail_uQtyAvg: partout_t;
    nDemand: partout_t;
    uDemand: partout_t;
  end;

type
  pieceinventoryhistory_t = record
    time: TDateTime;
    nnew: integer;
    nused: integer;
    nbuilded: integer;
    ndismantaled: integer;
  end;

type
  TBrickInventory = class(TObject)
  private
    flooseparts: brickpool_pa;
    bhash: bhashtable_t;
    fsets: set_pa;
    fneedsReorganize: boolean;
    fnumlooseparts: integer;
    fnumsets: integer;
    frealnumlooseparts: integer;
    frealnumsets: integer;
    fupdatetime: TDateTime;
    fupdatetimeout: double;
    fSoldPartOutValue_nAvg: partout_t;
    fSoldPartOutValue_nQtyAvg: partout_t;
    fSoldPartOutValue_uAvg: partout_t;
    fSoldPartOutValue_uQtyAvg: partout_t;
    fAvailablePartOutValue_nAvg: partout_t;
    fAvailablePartOutValue_nQtyAvg: partout_t;
    fAvailablePartOutValue_uAvg: partout_t;
    fAvailablePartOutValue_uQtyAvg: partout_t;
    procedure _growparts;
    procedure _growsets;
  protected
    procedure AddLoosePartFast(const part: string; color: integer; num: integer);
  public
    constructor Create; virtual;
    destructor Destroy; override;
    function LoadLooseParts(const fname: string): boolean;
    function LoadSets(const fname: string): boolean;
    procedure SaveLooseParts(const fname: string);
    procedure SaveLoosePartsWantedListNew(const fname: string; const pricefactor: Double = 1.0; const wl: Integer = 0);
    procedure SaveLoosePartsWantedListUsed(const fname: string; const pricefactor: Double = 1.0; const wl: Integer = 0);
    procedure SavePartsInventoryPriceguide(const fname: string);
    procedure SaveSets(const fname: string);
    procedure AddLoosePart(const part: string; color: integer; num: integer);
    function RemoveLoosePart(const part: string; color: integer; num: integer): boolean;
    function LoosePartCount(const part: string; color: integer): integer;
    procedure AddSet(const setid: string; dismantaled: boolean);
    procedure GetSetInfo(const setid: string; const s: set_p);
    function RemoveSet(const setid: string; dismantaled: boolean): boolean;
    function DismandalSet(const setid: string): boolean;
    function DismandalAllSets: boolean;
    function BuildSet(const setid: string): boolean;
    function BuildAllSets: boolean;
    function CanBuildSet(const setid: string): boolean;
    function MissingToBuildSet(const setid: string): integer;
    function InventoryForMissingToBuildSet(const setid: string; const nsets: integer = 1): TBrickInventory;
    function CanBuildInventory(const inv: TBrickInventory): boolean;
    function MissingToBuildInventory(const inv: TBrickInventory): integer;
    function InventoryForMissingToBuildInventory(const inv: TBrickInventory): TBrickInventory;
    function LoosePartsWeight: double;
    procedure UpdateCostValues;
    procedure DoUpdateCostValues;
    function SoldPartOutValue_nAvg: partout_t;
    function SoldPartOutValue_nQtyAvg: partout_t;
    function SoldPartOutValue_uAvg: partout_t;
    function SoldPartOutValue_uQtyAvg: partout_t;
    function AvailablePartOutValue_nAvg: partout_t;
    function AvailablePartOutValue_nQtyAvg: partout_t;
    function AvailablePartOutValue_uAvg: partout_t;
    function AvailablePartOutValue_uQtyAvg: partout_t;
    function nDemand: partout_t;
    function uDemand: partout_t;
    procedure Reorganize;
    procedure Clear;
    procedure MergeWith(const inv: TBrickInventory);
    function Clone: TBrickInventory;
    function numlotsbycolor(const col: integer): integer;
    function numlotsbycatcolor(const col: integer; const cat: integer): integer;
    function numlotsbypart(const pt: string): integer;
    function numlotsbycategory(const cat: integer): integer;
    function totalloosepartsbycolor(const col: integer): integer;
    function totalloosepartsbycatcolor(const col: integer; const cat: integer): integer;
    function totalloosepartsbypart(const pt: string): integer;
    function totalloosepartsbycategory(const cat: integer): integer;
    function weightbycategory(const cat: integer): double;
    function weightbycolor(const col: integer): double;
    function weightbycatcolor(const col: integer; const cat: integer): double;
    function totallooseparts: integer;
    function totalsetsbuilted: integer;
    function totalsetsdismantaled: integer;
    function GetMoldList: TStringList;
    function GetDismandaledSets: TStringList;
    function GetHistoryStatsRec: brickstatshistory_t;
    procedure StoreHistoryStatsRec(const fn: string; const pl: integer = 0);
    function GetPieceInventoryStatsRec(const piece: string; const color: integer): pieceinventoryhistory_t;
    procedure StorePieceInventoryStatsRec(const fn: string; const piece: string; const color: integer; const pl: integer = 0);
    procedure SortPieces;
    property numlooseparts: integer read fnumlooseparts;
    property looseparts: brickpool_pa read flooseparts;
    property numsets: integer read fnumsets;
    property sets: set_pa read fsets;
    property updatetimeout: double read fupdatetimeout write fupdatetimeout;
  end;

type
  categoryinfo_t = record
    name: string[32];
    knownpieces: THashStringList;
  end;
  categoryinfo_p = ^categoryinfo_t;

const
  MAXCATEGORIES = 1024;

type
  categoryinfoarray_t = array[0..MAXCATEGORIES - 1] of categoryinfo_t;
  categoryinfoarray_p = ^categoryinfoarray_t;

type
  TPieceInfo = class(TObject)
  public
    desc: string;
    category: integer;
    weight: Double;
    dimentionx: Double;
    dimentiony: Double;
    dimentionz: Double;
    constructor Create; virtual;
  end;

type
  TSetExtraInfo = class(TObject)
  public
    text: string;
    year: integer;
    moc: boolean;
    similars: string;
  end;

  TString = class(TObject)
  public
    text: string;
  end;

type
  priceguide_t = record
    nTimesSold: integer;
    nTotalQty: integer;
    nMinPrice: double;
    nAvgPrice: double;
    nQtyAvgPrice: double;
    nMaxPrice: double;
    uTimesSold: integer;
    uTotalQty: integer;
    uMinPrice: double;
    uAvgPrice: double;
    uQtyAvgPrice: double;
    uMaxPrice: double;
  end;
  priceguide_p = ^priceguide_t;

  availability_t = record
    nTotalLots: integer;
    nTotalQty: integer;
    nMinPrice: double;
    nAvgPrice: double;
    nQtyAvgPrice: double;
    nMaxPrice: double;
    uTotalLots: integer;
    uTotalQty: integer;
    uMinPrice: double;
    uAvgPrice: double;
    uQtyAvgPrice: double;
    uMaxPrice: double;
  end;
  availability_p = ^availability_t;

  parec_t = record
    priceguide: priceguide_t;
    availability: availability_t;
  end;

  parecdate_t = record
    priceguide: priceguide_t;
    availability: availability_t;
    date: TDateTime;
  end;

  parecdate_p = ^parecdate_t;

  TPieceColorInfo = class(TObject)
  private
    fneedssave: boolean;
    fhasloaded: boolean;
    fhash: LongWord;
    fpriceguide: priceguide_t;
    favailability: availability_t;
    fappearsinsets: integer;      // In how many sets appears?
    fappearsinsetstotal: integer; // How many pieces in all set?
    fpiece: string;
    fcolor: integer;
    fcolorstr: string;
    fsets: TStringList;
    fstorage: TStringList;
    fdate: TDateTime;
    fsetmost: string;
    fsetmostnum: integer;
  public
    constructor Create(const apiece: string; const acolor: integer); virtual;
    destructor Destroy; override;
    procedure Assign(const pg: priceguide_t); overload;
    procedure Assign(const av: availability_t); overload;
    function Check: boolean;
    procedure AddSetReference(const aset: string; const numpieces: integer);
    function LoadFromDisk: boolean;
    procedure Load;
    procedure SaveToDisk;
    procedure InternetUpdate;
    function EvaluatePriceNew: double;
    function EvaluatePriceUsed: double;
    function dbExportString: string;
    function nDemand: double;
    function uDemand: double;
    function ItemType: string;
    property priceguide: priceguide_t read fpriceguide;
    property availability: availability_t read favailability;
    property appearsinsets: integer read fappearsinsets;
    property appearsinsetstotal: integer read fappearsinsetstotal;
    property piece: string read fpiece;
    property color: integer read fcolor;
    property hasloaded: boolean read fhasloaded;
    property sets: TStringList read fsets;
    property storage: TStringList read fstorage;
    property Hash: LongWord read fhash;
    property setmost: string read fsetmost;
    property setmostnum: integer read fsetmostnum;
    function invalid: boolean;
  end;

const
  CACHEDBHASHSIZE = $20000;
  CACHEDBSTRINGSIZE = 16;

type
  cachedbitem_t = record
    partid: array[0..CACHEDBSTRINGSIZE - 1] of char;
    color: integer;
    parec: parecdate_t;
  end;
  cachedbitem_p = ^cachedbitem_t;

  cachedbparec_t = array[0..CACHEDBHASHSIZE - 1] of cachedbitem_t;
  cachedbparec_p = ^cachedbparec_t;

type
  TSetsDatabase = class;

  TCacheDB = class(TObject)
  private
    fname: string;
    fstream: TFileStream;
    parecs: cachedbparec_p;
    waitlist: TDNumberList;
    function OpenDB1(const mode: char): TFileStream;
  protected
    function TryOpenDB(const mode: char; const maxretry: integer = 10000): TFileStream; virtual;
    function apart(const it: cachedbitem_p): string;
    procedure Flash; virtual;
  public
    constructor Create(const aname: string); virtual;
    procedure OpenDB(const mode: char); virtual;
    procedure CloseDB; virtual;
    function LoadPCI(const p: TPieceColorInfo): boolean; virtual;
    function SavePCI(const p: TPieceColorInfo): boolean; virtual;
    destructor Destroy; override;
  end;


  fpciloaderparams_t = record
    db: TSetsDatabase;
  end;
  fpciloaderparams_p = ^fpciloaderparams_t;

  TSetsDatabase = class(TObject)
  private
    floaded: boolean;
    fallsets: THashStringList;
    fallsetswithoutextra: THashStringList;
    fcategories: categoryinfoarray_t;
    fpieces: TStringList;
    fpieceshash: THashTable;
    fsets: TStringList;
    fsetshash: THashTable;
    fpiecesaliasBL: THashStringList;
    fpiecesaliasRB: THashStringList;
    fCrawlerLinks: TStringList;
    fcolorpieces: TStringList;
    fcrawlerpriority: TStringList;
    flastcrawlpiece: string;
    fstorage: TStringList;
    fstubpieceinfo: TPieceInfo;
    fcurrencies: TCurrency;
    fcrawlerfilename: string;
    fbricklinkcolortorebricablecolor: array[0..MAXBRICKLINKCOLOR - 1] of integer;
    fCacheDB: TCacheDB;
    fbinarysets: TBinarySetCollection;
    st_pciloads: integer;
    st_pciloadscache: integer;
    procedure InitColors;
    procedure InitCategories;
    procedure InitPieces;
    procedure InitPiecesAlias;
    procedure InitCrawlerLinks;
    procedure InitSets;
    procedure InitSetReferences;
  public
    fcolors: colorinfoarray_t;
    progressfunc: progressfunc_t;
    constructor Create; virtual;
    procedure InitCreate(const app: string = ''); virtual;
    destructor Destroy; override;
    function LoadFromDisk(const fname: string): boolean;
    function SaveSetInformationToDisk: boolean;
    procedure AddSetPiece(const setid: string; const part: string; const typ: string; color: integer; num: integer);
    procedure AddPieceAlias(const bl, rb: string);
    procedure AddCrawlerLink(const part: string; const color: integer; const link: string);
    function CrawlerLink(const part: string; const color: integer): string;
    function GetSetInventory(const setid: string): TBrickInventory;
    function GetSetInventoryWithOutExtra(const setid: string): TBrickInventory;
    procedure ReloadCache;
    procedure GetCacheHashEfficiency(var hits, total: integer);
    function Colors(const i: Integer): colorinfo_p;
    function PieceDesc(const s: string): string;
    function BrickLinkPart(const s: string): string;
    function BrickLinkColorToRebrickableColor(const c: integer): integer;
    function RebrickablePart(const s: string): string;
    function GetDesc(const s: string): string;
    function GetYear(const s: string): integer;
    function GetSimilars(const s: string): string;
    function IsMoc(const s: string): boolean;
    function SetListAtYear(const y: integer): TStringList;
    function PieceListForSets(const slist: TStringList): TStringList;
    function PieceListForYear(const y: integer): TStringList;
    function PieceInfo(const piece: string): TPieceInfo;
    function PieceColorInfo(const piece: string; const color: integer): TPieceColorInfo;
    function Priceguide(const piece: string; const color: integer = -1): priceguide_t;
    function Availability(const piece: string; const color: integer = -1): availability_t;
    function ConvertCurrency(const cur: string): double;
    procedure CrawlerPriorityPart(const piece: string; const color: integer = -1);
    procedure ExportPriceGuide(const fname: string);
    procedure ExportPartOutGuide(const fname: string);
    procedure Crawler;
    procedure SaveStorage;
    procedure LoadStorage;
    function StorageBins: TStringlist;
    function StorageBinsForMold(const mld: string): TStringlist;
    function InventoryForStorageBin(const st: string): TBrickInventory;
    function InventoryForAllStorageBins: TBrickInventory;
    procedure SetPieceStorage(const piece: string; const color: integer; const st: TStringList);
    function RefreshInv(const inv: TBrickInventory): boolean;
    function RefreshSet(const s: string; const lite: boolean = false): boolean;
    function RefreshPart(const s: string): boolean;
    function UpdateSet(const s: string; const data: string = ''): boolean;
    procedure UpdateExtraInfos(const str: TStrings);
    function UpdateSetInformation(const ident: string; const desc: string = '';
        const year: integer = 0; const ismoc: boolean = false; const conn: string = ''): boolean;
    property lastcrawlpiece: string read flastcrawlpiece;
    property loaded: boolean read floaded;
    property categories: categoryinfoarray_t read fcategories;
    property AllSets: THashStringList read fallsets;
    property AllSetsWithOutExtra: THashStringList read fallsetswithoutextra;
    property AllPieces: TStringList read fpieces;
    property crawlerfilename: string read fcrawlerfilename write fcrawlerfilename;
    property CacheDB: TCacheDB read fCacheDB;
    property pciloads: integer read st_pciloads;
    property pciloadscache: integer read st_pciloadscache;
    property binarysets: TBinarySetCollection read fbinarysets;
  end;

function PieceColorCacheDir(const piece, color: string): string;
function PieceColorCacheFName(const piece, color: string): string;

var
  basedefault: string = '';

function F_nDemand(const favailability: availability_t; const fpriceguide: priceguide_t): double;
function F_uDemand(const favailability: availability_t; const fpriceguide: priceguide_t): double;


implementation

uses
  bi_system, bi_utils, bi_crawler, StrUtils, bi_priceadjust, bi_tmp, bi_globals;

function MkBHash(const part: string; color: integer): Longword;
var
  i: integer;
  check: string;
  b: byte;
begin
  check := strupper(part) + ',' + itoa(color);

  b := Ord(check[1]);

  result := 5381 * 33 + b;

  for i := 2 to Length(check) do
  begin
    b := Ord(check[i]);
    result := result * 33 + b;
  end;

  result := result and $FFF;
end;

function MkPCIHash(const part: string; color: integer): Longword;
var
  i: integer;
  check: string;
  b: byte;
begin
  check := strupper(part) + ',' + itoa(color);

  b := Ord(check[1]);

  result := 5381 * 33 + b;

  for i := 2 to Length(check) do
  begin
    b := Ord(check[i]);
    result := result * 33 + b;
  end;

  result := result and (CACHEDBHASHSIZE - 1);
end;

constructor TBrickInventory.Create;
begin
  inherited Create;

  fupdatetime := 0.0;
  fupdatetimeout := 1 / 48; // half an hour
  ZeroMemory(@bhash, SizeOf(bhashtable_t));
  ZeroMemory(@fSoldPartOutValue_nAvg, SizeOf(partout_t));
  ZeroMemory(@fSoldPartOutValue_nQtyAvg, SizeOf(partout_t));
  ZeroMemory(@fSoldPartOutValue_uAvg, SizeOf(partout_t));
  ZeroMemory(@fSoldPartOutValue_uQtyAvg, SizeOf(partout_t));
  ZeroMemory(@fAvailablePartOutValue_nAvg, SizeOf(partout_t));
  ZeroMemory(@fAvailablePartOutValue_nQtyAvg, SizeOf(partout_t));
  ZeroMemory(@fAvailablePartOutValue_uAvg, SizeOf(partout_t));
  ZeroMemory(@fAvailablePartOutValue_uQtyAvg, SizeOf(partout_t));

  fnumlooseparts := 0;
  fnumsets := 0;
  frealnumlooseparts := 0;
  frealnumsets := 0;
  flooseparts := nil;
  fsets := nil;
  fneedsReorganize := false;
end;



procedure TBrickInventory._growparts;
begin
  if fnumlooseparts >= frealnumlooseparts then
  begin
    frealnumlooseparts := frealnumlooseparts + 64;
    ReallocMem(flooseparts, frealnumlooseparts * SizeOf(brickpool_t));
  end;
end;

procedure TBrickInventory._growsets;
begin
  if fnumsets >= frealnumsets then
  begin
    frealnumsets := frealnumsets + 16;
    ReallocMem(fsets, frealnumsets * SizeOf(set_t));
  end;
end;

destructor TBrickInventory.Destroy;
begin
  Clear;
  Inherited;
end;

function TBrickInventory.LoadLooseParts(const fname: string): boolean;
var
  s: TStringList;
  i: integer;
  spart, scolor, snum, scost: string;
  np: integer;
begin
  s := TStringList.Create;
  s.LoadFromFile(fname);
  if s.Count = 0 then
  begin
    s.Free;
    Result := false;
    exit;
  end;

  if (s.Strings[0] = 'Part,Color,Num') or (s.Strings[0] = 'Part,Color,Num,Cost') then
  begin
    for i := 1 to s.Count - 1 do
    begin
      splitstringex(s.Strings[i], spart, scolor, snum, scost, ',');
      spart:= Trim(spart);
      scolor:= Trim(scolor);
      scost:= Trim(scost);
      np := StrToIntDef(Trim(snum), 0);
      if Pos('BL ', spart) = 1 then
        spart := db.RebrickablePart(Copy(spart, 4, Length(spart) - 3))
      else
        spart := db.RebrickablePart(spart);
      if Pos('BL', scolor) = 1 then
      begin
        scolor := Copy(scolor, 3, Length(scolor) - 2);

        if np > 0 then
          AddLoosePartFast(spart, db.BrickLinkColorToRebrickableColor(StrToIntDef(scolor, 0)), np)
        else
          AddLoosePart(spart, db.BrickLinkColorToRebrickableColor(StrToIntDef(scolor, 0)), np);
      end
      else
      begin
        if np > 0 then
          AddLoosePartFast(spart, StrToIntDef(scolor, 0), np)
        else
          AddLoosePart(spart, StrToIntDef(scolor, 0), np);
      end;
    end;
    Reorganize;
    s.Free;

    Result := True;
  end
  else
  begin
    s.Free;
    Result := false;
  end;
end;

function TBrickInventory.LoadSets(const fname: string): boolean;
var
  s: TStringList;
  i, j: integer;
  sset, snum, sdismantaled: string;
begin
  s := TStringList.Create;
  s.LoadFromFile(fname);
  if s.Count = 0 then
  begin
    s.Free;
    Result := false;
    exit;
  end;

  if s.Strings[0] <> 'Set,Num,Dismantaled' then
  begin
    s.Free;
    Result := false;
    exit;
  end;

  for i := 1 to s.Count - 1 do
  begin
    splitstringex(s.Strings[i], sset, snum, sdismantaled, ',');
    sset:= Trim(sset);
    snum:= Trim(snum);
    sdismantaled:= Trim(sdismantaled);
    for j := 0 to StrToIntDef(snum, 0) - 1 do
      AddSet(sset, false);
    for j := 0 to StrToIntDef(sdismantaled, 0) - 1 do
      AddSet(sset, true);
  end;
  s.Free;

  Result := True;
end;

procedure TBrickInventory.SaveLooseParts(const fname: string);
var
  s: TStringList;
  i: integer;
begin
  s := TStringList.Create;
  s.Add('Part,Color,Num');
  try
    for i := 0 to fnumlooseparts - 1 do
     s.Add(Format('%s,%d,%d', [flooseparts[i].part, flooseparts[i].color, flooseparts[i].num]));
    backupfile(fname);
    s.SaveToFile(fname);
  except
    I_Warning('TBrickInventory.SaveLooseParts(): Can not save file %s'#13#10, [fname]);
  end;
  s.Free;
end;

procedure TBrickInventory.SaveLoosePartsWantedListNew(const fname: string;
  const pricefactor: Double = 1.0; const wl: Integer = 0);
var
  s: TStringList;
  i: integer;
  pci: TPieceColorInfo;
begin
  s := TStringList.Create;
  s.Add('<INVENTORY>');
  for i := 0 to fnumlooseparts - 1 do
  begin
    pci := db.PieceColorInfo(flooseparts[i].part, flooseparts[i].color);
    if pci <> nil then
    begin
      if pci.EvaluatePriceNew > 0 then
        s.Add(
          Format(
            '<ITEM><ITEMTYPE>%s</ITEMTYPE><ITEMID>%s</ITEMID><COLOR>%d</COLOR><MAXPRICE>%2.4f</MAXPRICE><MINQTY>%d</MINQTY><NOTIFY>N</NOTIFY><WANTEDLISTID>%d</WANTEDLISTID></ITEM>',
            [pci.ItemType, db.BrickLinkPart(flooseparts[i].part), db.colors(flooseparts[i].color).BrickLinkColor, pci.EvaluatePriceNew * pricefactor, flooseparts[i].num, wl]))
      else
        s.Add(
          Format(
            '<ITEM><ITEMTYPE>%s</ITEMTYPE><ITEMID>%s</ITEMID><COLOR>%d</COLOR><MINQTY>%d</MINQTY><NOTIFY>N</NOTIFY><WANTEDLISTID>%d</WANTEDLISTID></ITEM>',
            [pci.ItemType, db.BrickLinkPart(flooseparts[i].part), db.colors(flooseparts[i].color).BrickLinkColor, flooseparts[i].num, wl]));
    end
    else
    begin
      s.Add(
        Format(
          '<ITEM><ITEMTYPE>P</ITEMTYPE><ITEMID>%s</ITEMID><COLOR>%d</COLOR><MINQTY>%d</MINQTY><NOTIFY>N</NOTIFY><WANTEDLISTID>%d</WANTEDLISTID></ITEM>',
          [db.BrickLinkPart(flooseparts[i].part), db.colors(flooseparts[i].color).BrickLinkColor, flooseparts[i].num, wl]));
    end;
  end;
  s.Add('</INVENTORY>');
  try
    s.SaveToFile(fname);
  except
    I_Warning('TBrickInventory.SaveLoosePartsWantedList(): Can not save file %s'#13#10, [fname]);
  end;
  s.Free;
end;

procedure TBrickInventory.SaveLoosePartsWantedListUsed(const fname: string;
  const pricefactor: Double = 1.0; const wl: Integer = 0);
var
  s: TStringList;
  i: integer;
  pci: TPieceColorInfo;
begin
  s := TStringList.Create;
  s.Add('<INVENTORY>');
  for i := 0 to fnumlooseparts - 1 do
  begin
    pci := db.PieceColorInfo(flooseparts[i].part, flooseparts[i].color);
    if pci <> nil then
    begin
      if pci.EvaluatePriceNew > 0 then
        s.Add(
          Format(
            '<ITEM><ITEMTYPE>%s</ITEMTYPE><ITEMID>%s</ITEMID><COLOR>%d</COLOR><MAXPRICE>%2.4f</MAXPRICE><MINQTY>%d</MINQTY><NOTIFY>N</NOTIFY><WANTEDLISTID>%d</WANTEDLISTID></ITEM>',
            [pci.ItemType, db.BrickLinkPart(flooseparts[i].part), db.colors(flooseparts[i].color).BrickLinkColor, pci.EvaluatePriceUsed * pricefactor, flooseparts[i].num, wl]))
      else
        s.Add(
          Format(
            '<ITEM><ITEMTYPE>%s</ITEMTYPE><ITEMID>%s</ITEMID><COLOR>%d</COLOR><MINQTY>%d</MINQTY><NOTIFY>N</NOTIFY><WANTEDLISTID>%d</WANTEDLISTID></ITEM>',
            [pci.ItemType, db.BrickLinkPart(flooseparts[i].part), db.colors(flooseparts[i].color).BrickLinkColor, flooseparts[i].num, wl]));
    end
    else
    begin
      s.Add(
        Format(
          '<ITEM><ITEMTYPE>P</ITEMTYPE><ITEMID>%s</ITEMID><COLOR>%d</COLOR><MINQTY>%d</MINQTY><NOTIFY>N</NOTIFY><WANTEDLISTID>%d</WANTEDLISTID></ITEM>',
          [db.BrickLinkPart(flooseparts[i].part), db.colors(flooseparts[i].color).BrickLinkColor, flooseparts[i].num, wl]));
    end;
  end;
  s.Add('</INVENTORY>');
  try
    s.SaveToFile(fname);
  except
    I_Warning('TBrickInventory.SaveLoosePartsWantedList(): Can not save file %s'#13#10, [fname]);
  end;
  s.Free;
end;

procedure TBrickInventory.SavePartsInventoryPriceguide(const fname: string);
var
  s: TStringList;
  i: integer;
  pci: TPieceColorInfo;
begin
  s := TStringList.Create;
  s.Add('Part;Color;Num;pg_nTimesSold;pg_nTotalQty;pg_nMinPrice;pg_nAvgPrice;' +
        'pg_nQtyAvgPrice;pg_nMaxPrice;pg_uTimesSold;pg_uTotalQty;pg_uMinPrice;' +
        'pg_uAvgPrice;pg_uQtyAvgPrice;pg_uMaxPrice;av_nTotalLots;av_nTotalQty;' +
        'av_nMinPrice;av_nAvgPrice;av_nQtyAvgPrice;av_nMaxPrice;av_uTotalLots;' +
        'av_uTotalQty;av_uMinPrice;av_uAvgPrice;av_uQtyAvgPrice;av_uMaxPrice;' +
        'EvaluatePriceNew;EvaluatePriceUsed');
  for i := 0 to fnumlooseparts - 1 do
  begin
    pci := db.PieceColorInfo(flooseparts[i].part, flooseparts[i].color);
    if pci <> nil then
    begin
      if not pci.hasloaded then
        pci.Load;
      s.Add(Format('%s;%d;%d;%d;%d;%2.5f;%2.5f;%2.5f;%2.5f;%d;%d;%2.5f;%2.5f;%2.5f;%2.5f'+
      ';%d;%d;%2.5f;%2.5f;%2.5f;%2.5f;%d;%d;%2.5f;%2.5f;%2.5f;%2.5f;%2.5f;%2.5f', [
        flooseparts[i].part,
        flooseparts[i].color,
        flooseparts[i].num,
        pci.priceguide.nTimesSold,
        pci.priceguide.nTotalQty,
        pci.priceguide.nMinPrice,
        pci.priceguide.nAvgPrice,
        pci.priceguide.nQtyAvgPrice,
        pci.priceguide.nMaxPrice,
        pci.priceguide.uTimesSold,
        pci.priceguide.uTotalQty,
        pci.priceguide.uMinPrice,
        pci.priceguide.uAvgPrice,
        pci.priceguide.uQtyAvgPrice,
        pci.priceguide.uMaxPrice,
        pci.availability.nTotalLots,
        pci.availability.nTotalQty,
        pci.availability.nMinPrice,
        pci.availability.nAvgPrice,
        pci.availability.nQtyAvgPrice,
        pci.availability.nMaxPrice,
        pci.availability.uTotalLots,
        pci.availability.uTotalQty,
        pci.availability.uMinPrice,
        pci.availability.uAvgPrice,
        pci.availability.uQtyAvgPrice,
        pci.availability.uMaxPrice,
        pci.EvaluatePriceNew,
        pci.EvaluatePriceUsed
      ]));
    end
    else
      s.Add(Format('%s,%d,%d', [flooseparts[i].part, flooseparts[i].color, flooseparts[i].num]));
  end;
  try
    backupfile(fname);
    s.SaveToFile(fname);
  except
    I_Warning('TBrickInventory.SavePartsInventoryPriceguide(): Can not save file %s'#13#10, [fname]);
  end;
  s.Free;
end;

procedure TBrickInventory.SaveSets(const fname: string);
var
  s: TStringList;
  i: integer;
begin
  s := TStringList.Create;
  s.Add('Set,Num,Dismantaled');
  for i := 0 to fnumsets - 1 do
    s.Add(Format('%s,%d,%d', [fsets[i].setid, fsets[i].num, fsets[i].dismantaled]));
  try
    backupfile(fname);
    s.SaveToFile(fname);
  except
    I_Warning('TBrickInventory.SaveSets(): Can not save file %s'#13#10, [fname]);
  end;
  s.Free;
end;

procedure TBrickInventory.Reorganize;
var
  nparts: brickpool_pa;
  nnum: integer;
  i: integer;
  pci: TPieceColorInfo;
begin
  if not fneedsReorganize then
    exit;
  if fnumlooseparts = 0 then
    exit;
  nnum := fnumlooseparts;
  GetMem(nparts, nnum * SizeOf(brickpool_t));
  for i := 0 to nnum - 1 do
    nparts[i] := flooseparts[i];
  FreeMem(flooseparts);
  flooseparts := nil;
  fnumlooseparts := 0;
  frealnumlooseparts := 0;
  for i := 0 to nnum - 1 do
  begin
    AddLoosePart(nparts[i].part, nparts[i].color, nparts[i].num);
    pci := db.PieceColorInfo(nparts[i].part, nparts[i].color);
    if pci = nil then
    begin
      pci := TPieceColorInfo.Create(nparts[i].part, nparts[i].color);
      if db.Colors(nparts[i].color).knownpieces = nil then
        db.Colors(nparts[i].color).knownpieces := THashStringList.Create;
      db.Colors(nparts[i].color).knownpieces.AddObject(nparts[i].part, pci);
    end;
  end;
  FreeMem(nparts, nnum * SizeOf(brickpool_t));
  fneedsReorganize := false;
end;

procedure TBrickInventory.Clear;
begin
  if flooseparts <> nil then
  begin
    FreeMem(flooseparts);
    flooseparts := nil;
  end;
  fnumlooseparts := 0;
  frealnumlooseparts := 0;

  if fsets <> nil then
  begin
    FreeMem(fsets);
    fsets := nil;
  end;
  fnumsets := 0;
  frealnumsets := 0;
end;

procedure TBrickInventory.MergeWith(const inv: TBrickInventory);
var
  i, j: integer;
begin
  if inv = nil then
    exit;
    
  for i := 0 to inv.fnumsets - 1 do
  begin
    for j := 0 to inv.fsets[i].num - 1 do
      AddSet(inv.fsets[i].setid, false);
    for j := 0 to inv.fsets[i].dismantaled - 1 do
      AddSet(inv.fsets[i].setid, true);
  end;
  for i := 0 to inv.fnumlooseparts - 1 do
    AddLoosePart(inv.flooseparts[i].part, inv.flooseparts[i].color, inv.flooseparts[i].num);
end;

function TBrickInventory.Clone: TBrickInventory;
begin
  result := TBrickInventory.Create;
  result.MergeWith(self);
end;

function TBrickInventory.numlotsbycolor(const col: integer): integer;
var
  i: integer;
begin
  if col = -1 then
  begin
    result := fnumlooseparts;
    exit;
  end;
  result := 0;
  for i := 0 to fnumlooseparts - 1 do
    if flooseparts[i].color = col then
      inc(result);
end;

function TBrickInventory.numlotsbypart(const pt: string): integer;
var
  i: integer;
begin
  if pt = '' then
  begin
    result := fnumlooseparts;
    exit;
  end;
  result := 0;
  for i := 0 to fnumlooseparts - 1 do
    if flooseparts[i].part = pt then
      inc(result);
end;

function TBrickInventory.numlotsbycatcolor(const col: integer; const cat: integer): integer;
var
  i: integer;
begin
  if cat = -1 then
  begin
    result := totallooseparts;
    exit;
  end;
  result := 0;
  for i := 0 to fnumlooseparts - 1 do
    if flooseparts[i].color = col then
      if db.PieceInfo(flooseparts[i].part).category = cat then
        inc(result);
end;

function TBrickInventory.numlotsbycategory(const cat: integer): integer;
var
  i: integer;
begin
  if cat = -1 then
  begin
    result := totallooseparts;
    exit;
  end;
  result := 0;
  for i := 0 to fnumlooseparts - 1 do
    if db.PieceInfo(flooseparts[i].part).category = cat then
      inc(result);
end;

function TBrickInventory.totalloosepartsbycolor(const col: integer): integer;
var
  i: integer;
begin
  if col = -1 then
  begin
    result := totallooseparts;
    exit;
  end;
  result := 0;
  for i := 0 to fnumlooseparts - 1 do
    if flooseparts[i].color = col then
      inc(result, flooseparts[i].num);
end;

function TBrickInventory.totalloosepartsbycatcolor(const col: integer; const cat: integer): integer;
var
  i: integer;
begin
  if col = -1 then
  begin
    result := totallooseparts;
    exit;
  end;
  result := 0;
  for i := 0 to fnumlooseparts - 1 do
    if flooseparts[i].color = col then
      if db.PieceInfo(flooseparts[i].part).category = cat then
        inc(result, flooseparts[i].num);
end;

function TBrickInventory.totalloosepartsbypart(const pt: string): integer;
var
  i: integer;
begin
  if pt = '' then
  begin
    result := totallooseparts;
    exit;
  end;
  result := 0;
  for i := 0 to fnumlooseparts - 1 do
    if flooseparts[i].part = pt then
      inc(result, flooseparts[i].num);
end;

function TBrickInventory.totalloosepartsbycategory(const cat: integer): integer;
var
  i: integer;
begin
  if cat = -1 then
  begin
    result := totallooseparts;
    exit;
  end;
  result := 0;
  for i := 0 to fnumlooseparts - 1 do
    if db.PieceInfo(flooseparts[i].part).category = cat then
      inc(result, flooseparts[i].num);
end;

function TBrickInventory.weightbycategory(const cat: integer): double;
var
  i: integer;
begin
  result := 0.0;
  if cat = -1 then
  begin
    for i := 0 to fnumlooseparts - 1 do
      result := result + flooseparts[i].num * db.PieceInfo(flooseparts[i].part).Weight;
    exit;
  end;
  for i := 0 to fnumlooseparts - 1 do
    if db.PieceInfo(flooseparts[i].part).category = cat then
      result := result + flooseparts[i].num * db.PieceInfo(flooseparts[i].part).Weight;
end;

function TBrickInventory.weightbycatcolor(const col: integer; const cat: integer): double;
var
  i: integer;
begin
  result := 0.0;
  for i := 0 to fnumlooseparts - 1 do
    if (cat = -1) or (db.PieceInfo(flooseparts[i].part).category = cat) then
      if (col = -1) or (flooseparts[i].color = col) then
        result := result + flooseparts[i].num * db.PieceInfo(flooseparts[i].part).Weight;
end;

function TBrickInventory.weightbycolor(const col: integer): double;
var
  i: integer;
begin
  result := 0.0;
  if col = -1 then
  begin
    for i := 0 to fnumlooseparts - 1 do
      result := result + flooseparts[i].num * db.PieceInfo(flooseparts[i].part).Weight;
    exit;
  end;
  for i := 0 to fnumlooseparts - 1 do
    if flooseparts[i].color = col then
      result := result + flooseparts[i].num * db.PieceInfo(flooseparts[i].part).Weight;
end;


function TBrickInventory.totallooseparts: integer;
var
  i: integer;
begin
  result := 0;
  for i := 0 to fnumlooseparts - 1 do
    inc(result, flooseparts[i].num);
end;

function TBrickInventory.totalsetsbuilted: integer;
var
  i: integer;
begin
  result := 0;
  for i := fnumsets - 1 downto 0  do
    result := result + fsets[i].num;
end;

function TBrickInventory.totalsetsdismantaled: integer;
var
  i: integer;
begin
  result := 0;
  for i := fnumsets - 1 downto 0  do
    result := result + fsets[i].dismantaled;
end;

function TBrickInventory.GetMoldList: TStringList;
var
  i: integer;
begin
  result := TStringList.Create;
  for i := 0 to fnumlooseparts - 1 do
    if result.IndexOf(flooseparts[i].part) < 0 then
      result.Add(flooseparts[i].part)
end;

function TBrickInventory.GetDismandaledSets: TStringList;
var
  i, j: integer;
begin
  result := TStringList.Create;
  for i := 0 to fnumsets - 1 do
    for j := 0 to fsets[i].dismantaled - 1 do
      result.Add(fsets[i].setid)
end;

function TBrickInventory.GetHistoryStatsRec: brickstatshistory_t;
begin
  result.Sold_nAvg := SoldPartOutValue_nAvg;
  result.Sold_nQtyAvg := SoldPartOutValue_nQtyAvg;
  result.Sold_uAvg := SoldPartOutValue_uAvg;
  result.Sold_uQtyAvg := SoldPartOutValue_uQtyAvg;
  result.Avail_nAvg := AvailablePartOutValue_nAvg;
  result.Avail_nQtyAvg := AvailablePartOutValue_nQtyAvg;
  result.Avail_uAvg := AvailablePartOutValue_uAvg;
  result.Avail_uQtyAvg := AvailablePartOutValue_uQtyAvg;
  result.nDemand := nDemand;
  result.uDemand := uDemand;
  result.time := Now;
end;

procedure TBrickInventory.StoreHistoryStatsRec(const fn: string; const pl: integer = 0);
var
  h: brickstatshistory_t;
  f: TFileStream;
begin
  if pl > 3 then
    exit;

  h := GetHistoryStatsRec;

  try
    if fexists(fn) then
    begin
      f := TFileStream.Create(fn, fmOpenReadWrite or fmShareDenyWrite);
      f.Position := f.Size;
    end
    else
      f := TFileStream.Create(fn, fmCreate or fmShareDenyWrite);

    f.Write(h, SizeOf(h));
    f.Free;
  except
    Sleep(50);
    StoreHistoryStatsRec(fn, pl + 1);
  end;
end;

function TBrickInventory.GetPieceInventoryStatsRec(const piece: string; const color: integer): pieceinventoryhistory_t;
var
  st: set_t;
begin
  if color = -1 then
  begin
    GetSetInfo(piece, @st);
    result.nnew := 0;
    result.nused := 0;
    result.nbuilded := st.num;
    result.ndismantaled := st.dismantaled;
  end
  else
  begin
    result.nnew := 0;
    result.nused := LoosePartCount(piece, color);
    result.nbuilded := 0;
    result.ndismantaled := 0;
  end;
  result.time := Now;
end;

procedure TBrickInventory.StorePieceInventoryStatsRec(const fn: string; const piece: string; const color: integer; const pl: integer = 0);
var
  h: pieceinventoryhistory_t;
  f: TFileStream;
begin
  if pl > 3 then
    exit;

  h := GetPieceInventoryStatsRec(piece, color);

  try
    if fexists(fn) then
    begin
      f := TFileStream.Create(fn, fmOpenReadWrite or fmShareDenyWrite);
      f.Position := f.Size;
    end
    else
    begin
      ForceDirectories(ExtractFilePath(fn));
      f := TFileStream.Create(fn, fmCreate or fmShareDenyWrite);
    end;

    f.Write(h, SizeOf(h));
    f.Free;
  except
    Sleep(50);
    StoreHistoryStatsRec(fn, pl + 1);
  end;
end;

procedure TBrickInventory.SortPieces;

  procedure QuickSort(const A: brickpool_pa; iLo, iHi: Integer);
  var
     Lo, Hi: integer;
     Pivot: string;
     T: brickpool_t;
  begin
    Lo := iLo;
    Hi := iHi;
    Pivot := db.PieceDesc(A[(Lo + Hi) div 2].part);
    repeat
      while db.PieceDesc(A[Lo].part) < Pivot do Inc(Lo) ;
      while db.PieceDesc(A[Hi].part) > Pivot do Dec(Hi) ;
      if Lo <= Hi then
      begin
        T := A[Lo];
        A[Lo] := A[Hi];
        A[Hi] := T;
        Inc(Lo) ;
        Dec(Hi) ;
      end;
    until Lo > Hi;
    if Hi > iLo then QuickSort(A, iLo, Hi);
    if Lo < iHi then QuickSort(A, Lo, iHi);
  end;

begin
  Reorganize;
  if fnumlooseparts > 0 then
    QuickSort(flooseparts, 0, fnumlooseparts - 1);
end;

procedure TBrickInventory.AddLoosePartFast(const part: string; color: integer; num: integer);
var
  bp: brickpool_p;
  p: integer;
  i: integer;
  h: integer;
begin
  if color = -1 then
  begin
    p := Pos('-', part);
    if (p > 1) and (p < Length(part)) then
    begin
      if num > 0 then
      begin
        for i := 0 to num - 1 do
          AddSet(part, false);
      end
      else if num < 0 then
      begin
        for i := 0 to -num - 1 do
          RemoveSet(part, false);
      end;
      exit;
    end;
  end;

  if num > 0 then
  begin
    _growparts;
    bp := @flooseparts[fnumlooseparts];
    bp.part := part;
    bp.color := color;
    h := MkBHash(part, color);
    bhash[h].position := fnumlooseparts;
    bp.num := num;
    Inc(fnumlooseparts);
    fneedsReorganize := true;
    fupdatetime := 0;
  end
  else if num < 0 then
    RemoveLoosePart(part, color, -num);
end;

procedure TBrickInventory.AddLoosePart(const part: string; color: integer; num: integer);
var
  i: Integer;
  p: integer;
  h: integer;
  hl: longword;
begin
  if color = -1 then
  begin
    p := Pos('-', part);
    if (p > 1) and (p < Length(part)) then
    begin
      if num > 0 then
      begin
        for i := 0 to num - 1 do
          AddSet(part, false);
      end
      else if num < 0 then
      begin
        for i := 0 to num - 1 do
          RemoveSet(part, false);
      end;
      exit;
    end;
  end;

  if num <= 0 then
  begin
    if num < 0 then
      RemoveLoosePart(part, color, -num);
    exit;
  end;

  hl := MkBHash(part, color);
  h := bhash[hl].position;
  if h < fnumlooseparts then
    if flooseparts[h].color = color then
      if flooseparts[h].part = part then
      begin
        flooseparts[h].num := flooseparts[h].num + num;
        fupdatetime := 0;
        exit;
      end;

  for i := 0 to fnumlooseparts - 1 do
    if  flooseparts[i].color = color then
      if flooseparts[i].part = part then
      begin
        flooseparts[i].num := flooseparts[i].num + num;
        fupdatetime := 0;
        exit;
      end;

  _growparts;
  flooseparts[fnumlooseparts].part := part;
  flooseparts[fnumlooseparts].color := color;
  flooseparts[fnumlooseparts].num := num;
  bhash[hl].position := fnumlooseparts;
  Inc(fnumlooseparts);
  fupdatetime := 0;
end;

function TBrickInventory.RemoveLoosePart(const part: string; color: integer; num: integer): boolean;
var
  i, h: Integer;
  p: integer;
begin
  if color = -1 then
  begin
    p := Pos('-', part);
    if (p > 1) and (p < Length(part)) then
    begin
      if num > 0 then
      begin
        for i := 0 to num - 1 do
          RemoveSet(part, false);
      end
      else if num < 0 then
      begin
        for i := 0 to -num - 1 do
          AddSet(part, false);
      end;
      result := True;
      Exit;
    end;
  end;

  if num <= 0 then
  begin
    if num < 0 then
      AddLoosePart(part, color, num);
    Result := true;
    Exit;
  end;

  h := bhash[MkBHash(part, color)].position;
  if h < fnumlooseparts then
    if flooseparts[h].color = color then
      if flooseparts[h].part = part then
      begin
        if flooseparts[h].num >= num then
        begin
          flooseparts[h].num := flooseparts[h].num - num;
          result := True;
          fneedsReorganize := flooseparts[h].num = 0;
          fupdatetime := 0;
        end
        else
          result := false;
        exit;
      end;

  for i := 0 to fnumlooseparts - 1 do
    if flooseparts[i].color = color then
      if flooseparts[i].part = part then
      begin
        if flooseparts[i].num >= num then
        begin
          flooseparts[i].num := flooseparts[i].num - num;
          result := True;
          fneedsReorganize := flooseparts[i].num = 0;
          fupdatetime := 0;
        end
        else
          result := false;
        exit;
      end;
  result := false;
end;

function TBrickInventory.LoosePartCount(const part: string; color: integer): integer;
var
  h, i: integer;
begin
  if not fneedsReorganize then
  begin
    h := bhash[MkBHash(part, color)].position;
    if h < fnumlooseparts then
      if flooseparts[h].color = color then
        if flooseparts[h].part = part then
        begin
          result := flooseparts[h].num;
          exit;
        end;
  end;


  result := 0;
  for i := 0 to fnumlooseparts - 1 do
    if flooseparts[i].color = color then
      if flooseparts[i].part = part then
      begin
        result := result + flooseparts[i].num; // SOS maybe exit here!!
        if not fneedsReorganize then
          Exit;
      end;
end;

procedure TBrickInventory.AddSet(const setid: string; dismantaled: boolean);
var
  i: Integer;
begin
  for i := fnumsets - 1 downto 0  do
    if  fsets[i].setid = setid then
    begin
      if dismantaled then
        Inc(fsets[i].dismantaled)
      else
        Inc(fsets[i].num);
      fupdatetime := 0;
      exit;
    end;

  _growsets;
  fsets[fnumsets].setid := setid;
  if dismantaled then
  begin
    fsets[fnumsets].num := 0;
    fsets[fnumsets].dismantaled := 1;
  end
  else
  begin
    fsets[fnumsets].num := 1;
    fsets[fnumsets].dismantaled := 0;
  end;
  Inc(fnumsets);
  fupdatetime := 0;
end;

procedure TBrickInventory.GetSetInfo(const setid: string; const s: set_p);
var
  i: integer;
begin
  s.setid := setid;
  s.num := 0;
  s.dismantaled := 0;
  for i := 0 to fnumsets - 1 do
    if fsets[i].setid = setid then
    begin
      s.num := s.num + fsets[i].num;
      s.dismantaled := s.dismantaled + fsets[i].dismantaled;
    end;
end;

function TBrickInventory.RemoveSet(const setid: string; dismantaled: boolean): boolean;
var
  i, j: integer;
  inv: TBrickInventory;
begin
  result := true;
  for i := 0 to fnumsets - 1 do
    if  fsets[i].setid = setid then
    begin
      if dismantaled then
      begin
        if fsets[i].dismantaled = 0 then
        begin
          Result := false;
          exit;
        end;
        dec(fsets[i].dismantaled);
        inv := db.GetSetInventory(setid);
        if inv <> nil then
        begin
          for j := 0 to inv.numlooseparts - 1 do
            RemoveLoosePart(inv.flooseparts[j].part, inv.flooseparts[j].color, inv.flooseparts[j].num);
        end;
      end
      else
      begin
        if fsets[i].num = 0 then
        begin
          Result := false;
          exit;
        end;
        dec(fsets[i].num);
      end;
      fupdatetime := 0;
      exit;
    end;
  Result := false;
end;

function TBrickInventory.DismandalSet(const setid: string): boolean;
var
  i, j, k: integer;
  inv: TBrickInventory;
begin
  result := true;
  for i := 0 to fnumsets - 1 do
    if  fsets[i].setid = setid then
    begin
      if fsets[i].num = 0 then
      begin
        Result := false;
        exit;
      end;
      dec(fsets[i].num);
      inc(fsets[i].dismantaled);
      inv := db.GetSetInventory(setid);
      if inv <> nil then
      begin
        for j := 0 to inv.numlooseparts - 1 do
          AddLoosePart(inv.flooseparts[j].part, inv.flooseparts[j].color, inv.flooseparts[j].num);
        for j := 0 to inv.fnumsets - 1 do
          for k := 0 to inv.fsets[j].num - 1 do
            AddSet(inv.fsets[j].setid, false);
      end;
      exit;
    end;
  Result := false;
end;

function TBrickInventory.DismandalAllSets: boolean;
var
  i, j: integer;
  ret: boolean;
begin
  result := true;
  for i := 0 to fnumsets - 1 do
    for j := 0 to fsets[i].num - 1 do
    begin
      ret := DismandalSet(fsets[i].setid);
      result := result and ret;
    end;
end;

function TBrickInventory.BuildSet(const setid: string): boolean;
var
  i: integer;
  inv: TBrickInventory;
begin
  result := CanBuildSet(setid);
  if not Result then
    Exit;

  inv := db.GetSetInventory(setid);
  if inv <> nil then
  begin
    AddSet(setid, false);
    for i := 0 to inv.numlooseparts - 1 do
      RemoveLoosePart(inv.flooseparts[i].part, inv.flooseparts[i].color, inv.flooseparts[i].num);
    Reorganize;

    for i := 0 to fnumsets - 1 do
      if  fsets[i].setid = setid then
        if fsets[i].dismantaled > 0 then
        begin
          dec(fsets[i].dismantaled);
          break;
        end;
  end;
end;

function TBrickInventory.BuildAllSets: boolean;
var
  i, j: integer;
  ret: boolean;
begin
  result := true;
  for i := 0 to fnumsets - 1 do
    for j := 0 to fsets[i].dismantaled - 1 do
    begin
      ret := BuildSet(fsets[i].setid);
      result := result and ret;
    end;
end;

function TBrickInventory.CanBuildSet(const setid: string): boolean;
begin
  result := MissingToBuildSet(setid) = 0;
end;

function TBrickInventory.MissingToBuildSet(const setid: string): integer;
begin
  Result := MissingToBuildInventory(db.GetSetInventory(setid));
end;

function TBrickInventory.InventoryForMissingToBuildSet(
  const setid: string; const nsets: integer = 1): TBrickInventory;
var
  inv: TBrickInventory;
  j, n: integer;
begin
  Reorganize;
  result := TBrickInventory.Create;
  inv := db.GetSetInventory(setid);
  if inv <> nil then
  begin
    for j := 0 to inv.numlooseparts - 1 do
    begin
      n := LoosePartCount(inv.flooseparts[j].part, inv.flooseparts[j].color);
      if n < nsets * inv.flooseparts[j].num then
        result.AddLoosePart(inv.flooseparts[j].part, inv.flooseparts[j].color, nsets * inv.flooseparts[j].num - n);
    end;
  end;
end;

function TBrickInventory.CanBuildInventory(const inv: TBrickInventory): boolean;
begin
  result := MissingToBuildInventory(inv) = 0;
end;

function TBrickInventory.MissingToBuildInventory(const inv: TBrickInventory): integer;
var
  j, n: integer;
begin
  Reorganize;
  result := 0;
  if inv <> nil then
  begin
    for j := 0 to inv.numlooseparts - 1 do
    begin
      n := LoosePartCount(inv.flooseparts[j].part, inv.flooseparts[j].color);
      if n < inv.flooseparts[j].num then
        result := Result + (inv.flooseparts[j].num - n);
    end;
  end;
end;

function TBrickInventory.InventoryForMissingToBuildInventory(const inv: TBrickInventory): TBrickInventory;
var
  j, n: integer;
begin
  Reorganize;
  result := TBrickInventory.Create;
  if inv <> nil then
  begin
    for j := 0 to inv.numlooseparts - 1 do
    begin
      n := LoosePartCount(inv.flooseparts[j].part, inv.flooseparts[j].color);
      if n < inv.flooseparts[j].num then
        result.AddLoosePart(inv.flooseparts[j].part, inv.flooseparts[j].color, inv.flooseparts[j].num - n);
    end;
  end;
end;

function TBrickInventory.LoosePartsWeight: double;
var
  i: integer;
begin
  result := 0.0;
  for i := 0 to numlooseparts - 1 do
    result := result + db.PieceInfo(flooseparts[i].part).weight * flooseparts[i].num;
end;

procedure TBrickInventory.UpdateCostValues;
begin
  if Now() - fupdatetime < fupdatetimeout then
    exit;
  DoUpdateCostValues;
end;

procedure TBrickInventory.DoUpdateCostValues;
var
  i: integer;
  brick: brickpool_p;
  pg: priceguide_t;
  av: availability_t;
  miss: array[0..7] of integer;
  tot: integer;
  inv: TBrickInventory;
begin
  fupdatetime := Now();

  ZeroMemory(@fSoldPartOutValue_nAvg, SizeOf(partout_t));
  ZeroMemory(@fSoldPartOutValue_nQtyAvg, SizeOf(partout_t));
  ZeroMemory(@fSoldPartOutValue_uAvg, SizeOf(partout_t));
  ZeroMemory(@fSoldPartOutValue_uQtyAvg, SizeOf(partout_t));
  ZeroMemory(@fAvailablePartOutValue_nAvg, SizeOf(partout_t));
  ZeroMemory(@fAvailablePartOutValue_nQtyAvg, SizeOf(partout_t));
  ZeroMemory(@fAvailablePartOutValue_uAvg, SizeOf(partout_t));
  ZeroMemory(@fAvailablePartOutValue_uQtyAvg, SizeOf(partout_t));
  if (fnumlooseparts = 0) and (totalsetsbuilted = 0) then
    exit;

  if totalsetsbuilted > 0 then
  begin
    inv := Clone;
    inv.DismandalAllSets;
    inv.DoUpdateCostValues;
    fSoldPartOutValue_nAvg := inv.fSoldPartOutValue_nAvg;
    fSoldPartOutValue_nQtyAvg := inv.fSoldPartOutValue_nQtyAvg;
    fSoldPartOutValue_uAvg := inv.fSoldPartOutValue_uAvg;
    fSoldPartOutValue_uQtyAvg := inv.fSoldPartOutValue_uQtyAvg;
    fAvailablePartOutValue_nAvg := inv.fAvailablePartOutValue_nAvg;
    fAvailablePartOutValue_nQtyAvg := inv.fAvailablePartOutValue_nQtyAvg;
    fAvailablePartOutValue_uAvg := inv.fAvailablePartOutValue_uAvg;
    fAvailablePartOutValue_uQtyAvg := inv.fAvailablePartOutValue_uQtyAvg;
    inv.Free;
    exit;
  end;

  ZeroMemory(@miss, SizeOf(miss));
  tot := 0;

  brick := @flooseparts[0];
  for i := 0 to fnumlooseparts - 1 do
  begin
    pg := db.Priceguide(brick.part, brick.color);
    if pg.nTimesSold = 0 then
    begin
      db.CrawlerPriorityPart(brick.part, brick.color);
      Inc(miss[0], brick.num);
      Inc(miss[1], brick.num);
    end
    else
    begin
      fSoldPartOutValue_nAvg.value := fSoldPartOutValue_nAvg.value + pg.nAvgPrice * brick.num;
      fSoldPartOutValue_nQtyAvg.value := fSoldPartOutValue_nQtyAvg.value + pg.nQtyAvgPrice * brick.num;
    end;

    if pg.uTimesSold = 0 then
    begin
      db.CrawlerPriorityPart(brick.part, brick.color);
      Inc(miss[2], brick.num);
      Inc(miss[3], brick.num);
    end
    else
    begin
      fSoldPartOutValue_uAvg.value := fSoldPartOutValue_uAvg.value + pg.uAvgPrice * brick.num;
      fSoldPartOutValue_uQtyAvg.value := fSoldPartOutValue_uQtyAvg.value + pg.uQtyAvgPrice * brick.num;
    end;

    av := db.Availability(brick.part, brick.color);
    if av.nTotalLots = 0 then
    begin
      Inc(miss[4], brick.num);
      Inc(miss[5], brick.num);
    end
    else
    begin
      fAvailablePartOutValue_nAvg.value := fAvailablePartOutValue_nAvg.value + av.nAvgPrice * brick.num;
      fAvailablePartOutValue_nQtyAvg.value := fAvailablePartOutValue_nQtyAvg.value + av.nQtyAvgPrice * brick.num;
    end;

    if av.uTotalLots = 0 then
    begin
      Inc(miss[6], brick.num);
      Inc(miss[7], brick.num);
    end
    else
    begin
      fAvailablePartOutValue_uAvg.value := fAvailablePartOutValue_uAvg.value + av.uAvgPrice * brick.num;
      fAvailablePartOutValue_uQtyAvg.value := fAvailablePartOutValue_uQtyAvg.value + av.uQtyAvgPrice * brick.num;
    end;

    Inc(tot, brick.num);
    Inc(brick);
  end;

  if tot = 0 then
    Exit;

  fSoldPartOutValue_nAvg.percentage := 1.0 - miss[0] / tot;
  fSoldPartOutValue_nQtyAvg.percentage := 1.0 - miss[1] / tot;
  fSoldPartOutValue_uAvg.percentage := 1.0 - miss[2] / tot;
  fSoldPartOutValue_uQtyAvg.percentage := 1.0 - miss[3] / tot;
  fAvailablePartOutValue_nAvg.percentage := 1.0 - miss[4] / tot;
  fAvailablePartOutValue_nQtyAvg.percentage := 1.0 - miss[5] / tot;
  fAvailablePartOutValue_uAvg.percentage := 1.0 - miss[6] / tot;
  fAvailablePartOutValue_uQtyAvg.percentage := 1.0 - miss[7] / tot;
end;

function TBrickInventory.SoldPartOutValue_nAvg: partout_t;
var
  i: integer;
  brick: brickpool_p;
  pg: priceguide_t;
  tot, miss: integer;
  inv: TBrickInventory;
begin
  FillChar(Result, SizeOf(partout_t), 0);
  if (fnumlooseparts = 0) and (totalsetsbuilted = 0) then
    exit;

  if Now() - fupdatetime < fupdatetimeout then
  begin
    result := fSoldPartOutValue_nAvg;
    exit;
  end;

  if totalsetsbuilted > 0 then
  begin
    inv := Clone;
    inv.DismandalAllSets;
    result := inv.SoldPartOutValue_nAvg;
    inv.Free;
    exit;
  end;

  miss := 0;
  tot := 0;
  brick := @flooseparts[0];
  for i := 0 to fnumlooseparts - 1 do
  begin
    pg := db.Priceguide(brick.part, brick.color);
    if pg.nTimesSold = 0 then
    begin
      db.CrawlerPriorityPart(brick.part, brick.color);
      Inc(miss, brick.num);
    end
    else
      Result.value := Result.value + pg.nAvgPrice * brick.num;
    Inc(tot, brick.num);
    Inc(brick);
  end;
  if tot = 0 then
    Exit;
  result.percentage := 1.0 - miss / tot;
end;

function TBrickInventory.SoldPartOutValue_nQtyAvg: partout_t;
var
  i: integer;
  brick: brickpool_p;
  pg: priceguide_t;
  tot, miss: integer;
  inv: TBrickInventory;
begin
  FillChar(Result, SizeOf(partout_t), 0);
  if (fnumlooseparts = 0) and (totalsetsbuilted = 0) then
    exit;

  if Now() - fupdatetime < fupdatetimeout then
  begin
    result := fSoldPartOutValue_nQtyAvg;
    exit;
  end;

  if totalsetsbuilted > 0 then
  begin
    inv := Clone;
    inv.DismandalAllSets;
    result := inv.SoldPartOutValue_nQtyAvg;
    inv.Free;
    exit;
  end;

  miss := 0;
  tot := 0;
  brick := @flooseparts[0];
  for i := 0 to fnumlooseparts - 1 do
  begin
    pg := db.Priceguide(brick.part, brick.color);
    if pg.nTimesSold = 0 then
    begin
      db.CrawlerPriorityPart(brick.part, brick.color);
      Inc(miss, brick.num);
    end
    else
      Result.value := Result.value + pg.nQtyAvgPrice * brick.num;
    Inc(tot, brick.num);
    Inc(brick);
  end;
  if tot = 0 then
    Exit;
  result.percentage := 1.0 - miss / tot;
end;

function TBrickInventory.SoldPartOutValue_uAvg: partout_t;
var
  i: integer;
  brick: brickpool_p;
  pg: priceguide_t;
  tot, miss: integer;
  inv: TBrickInventory;
begin
  FillChar(Result, SizeOf(partout_t), 0);
  if (fnumlooseparts = 0) and (totalsetsbuilted = 0) then
    exit;

  if Now() - fupdatetime < fupdatetimeout then
  begin
    result := fSoldPartOutValue_uAvg;
    exit;
  end;

  if totalsetsbuilted > 0 then
  begin
    inv := Clone;
    inv.DismandalAllSets;
    result := inv.SoldPartOutValue_uAvg;
    inv.Free;
    exit;
  end;

  miss := 0;
  tot := 0;
  brick := @flooseparts[0];
  for i := 0 to fnumlooseparts - 1 do
  begin
    pg := db.Priceguide(brick.part, brick.color);
    if pg.uTimesSold = 0 then
    begin
      db.CrawlerPriorityPart(brick.part, brick.color);
      Inc(miss, brick.num);
    end
    else
      Result.value := Result.value + pg.uAvgPrice * brick.num;
    Inc(tot, brick.num);
    Inc(brick);
  end;
  if tot = 0 then
    Exit;
  result.percentage := 1.0 - miss / tot;
end;

function TBrickInventory.SoldPartOutValue_uQtyAvg: partout_t;
var
  i: integer;
  brick: brickpool_p;
  pg: priceguide_t;
  tot, miss: integer;
  inv: TBrickInventory;
begin
  FillChar(Result, SizeOf(partout_t), 0);
  if (fnumlooseparts = 0) and (totalsetsbuilted = 0) then
    exit;

  if Now() - fupdatetime < fupdatetimeout then
  begin
    result := fSoldPartOutValue_uQtyAvg;
    exit;
  end;

  if totalsetsbuilted > 0 then
  begin
    inv := Clone;
    inv.DismandalAllSets;
    result := inv.SoldPartOutValue_uQtyAvg;
    inv.Free;
    exit;
  end;

  miss := 0;
  tot := 0;
  brick := @flooseparts[0];
  for i := 0 to fnumlooseparts - 1 do
  begin
    pg := db.Priceguide(brick.part, brick.color);
    if pg.uTimesSold = 0 then
    begin
      db.CrawlerPriorityPart(brick.part, brick.color);
      Inc(miss, brick.num);
    end
    else
      Result.value := Result.value + pg.uQtyAvgPrice * brick.num;
    Inc(tot, brick.num);
    Inc(brick);
  end;
  if tot = 0 then
    Exit;
  result.percentage := 1.0 - miss / tot;
end;

function TBrickInventory.AvailablePartOutValue_nAvg: partout_t;
var
  i: integer;
  brick: brickpool_p;
  av: availability_t;
  tot, miss: integer;
  inv: TBrickInventory;
begin
  FillChar(Result, SizeOf(partout_t), 0);
  if (fnumlooseparts = 0) and (totalsetsbuilted = 0) then
    exit;

  if Now() - fupdatetime < fupdatetimeout then
  begin
    result := fAvailablePartOutValue_nAvg;
    exit;
  end;

  if totalsetsbuilted > 0 then
  begin
    inv := Clone;
    inv.DismandalAllSets;
    result := inv.AvailablePartOutValue_nAvg;
    inv.Free;
    exit;
  end;

  miss := 0;
  tot := 0;
  brick := @flooseparts[0];
  for i := 0 to fnumlooseparts - 1 do
  begin
    av := db.Availability(brick.part, brick.color);
    if av.nTotalLots = 0 then
      Inc(miss, brick.num)
    else
      Result.value := Result.value + av.nAvgPrice * brick.num;
    Inc(tot, brick.num);
    Inc(brick);
  end;
  if tot = 0 then
    Exit;
  result.percentage := 1.0 - miss / tot;
end;

function TBrickInventory.AvailablePartOutValue_nQtyAvg: partout_t;
var
  i: integer;
  brick: brickpool_p;
  av: availability_t;
  tot, miss: integer;
  inv: TBrickInventory;
begin
  FillChar(Result, SizeOf(partout_t), 0);
  if (fnumlooseparts = 0) and (totalsetsbuilted = 0) then
    exit;

  if Now() - fupdatetime < fupdatetimeout then
  begin
    result := fAvailablePartOutValue_nQtyAvg;
    exit;
  end;

  if totalsetsbuilted > 0 then
  begin
    inv := Clone;
    inv.DismandalAllSets;
    result := inv.AvailablePartOutValue_nQtyAvg;
    inv.Free;
    exit;
  end;

  miss := 0;
  tot := 0;
  brick := @flooseparts[0];
  for i := 0 to fnumlooseparts - 1 do
  begin
    av := db.Availability(brick.part, brick.color);
    if av.nTotalLots = 0 then
      Inc(miss, brick.num)
    else
      Result.value := Result.value + av.nQtyAvgPrice * brick.num;
    Inc(tot, brick.num);
    Inc(brick);
  end;
  if tot = 0 then
    Exit;
  result.percentage := 1.0 - miss / tot;
end;

function TBrickInventory.AvailablePartOutValue_uAvg: partout_t;
var
  i: integer;
  brick: brickpool_p;
  av: availability_t;
  tot, miss: integer;
  inv: TBrickInventory;
begin
  FillChar(Result, SizeOf(partout_t), 0);
  if (fnumlooseparts = 0) and (totalsetsbuilted = 0) then
    exit;

  if Now() - fupdatetime < fupdatetimeout then
  begin
    result := fAvailablePartOutValue_uAvg;
    exit;
  end;

  if totalsetsbuilted > 0 then
  begin
    inv := Clone;
    inv.DismandalAllSets;
    result := inv.AvailablePartOutValue_uAvg;
    inv.Free;
    exit;
  end;

  miss := 0;
  tot := 0;
  brick := @flooseparts[0];
  for i := 0 to fnumlooseparts - 1 do
  begin
    av := db.Availability(brick.part, brick.color);
    if av.uTotalLots = 0 then
      Inc(miss, brick.num)
    else
      Result.value := Result.value + av.uAvgPrice * brick.num;
    if av.uAvgPrice > 1000 then
      av.uAvgPrice := 1;
    Inc(tot, brick.num);
    Inc(brick);
  end;
  if tot = 0 then
    Exit;
  result.percentage := 1.0 - miss / tot;
end;

function TBrickInventory.AvailablePartOutValue_uQtyAvg: partout_t;
var
  i: integer;
  brick: brickpool_p;
  av: availability_t;
  tot, miss: integer;
  inv: TBrickInventory;
begin
  FillChar(Result, SizeOf(partout_t), 0);
  if (fnumlooseparts = 0) and (totalsetsbuilted = 0) then
    exit;

  if Now() - fupdatetime < fupdatetimeout then
  begin
    result := fAvailablePartOutValue_uQtyAvg;
    exit;
  end;

  if totalsetsbuilted > 0 then
  begin
    inv := Clone;
    inv.DismandalAllSets;
    result := inv.SoldPartOutValue_nAvg;
    inv.Free;
    exit;
  end;

  miss := 0;
  tot := 0;
  brick := @flooseparts[0];
  for i := 0 to fnumlooseparts - 1 do
  begin
    av := db.Availability(brick.part, brick.color);
    if av.uTotalLots = 0 then
      Inc(miss, brick.num)
    else
      Result.value := Result.value + av.uQtyAvgPrice * brick.num;
    Inc(tot, brick.num);
    Inc(brick);
  end;
  if tot = 0 then
    Exit;
  result.percentage := 1.0 - miss / tot;
end;

function TBrickInventory.nDemand: partout_t;
var
  i: integer;
  tot, miss: integer;
  pci: TPieceColorInfo;
  d1, d2: double;
  brick: brickpool_p;
  price: double;
  inv: TBrickInventory;
begin
  FillChar(Result, SizeOf(partout_t), 0);
  if (fnumlooseparts = 0) and (totalsetsbuilted = 0) then
    exit;

  if totalsetsbuilted > 0 then
  begin
    inv := Clone;
    inv.DismandalAllSets;
    result := inv.nDemand;
    inv.Free;
    exit;
  end;

  d1 := 0.0;
  d2 := 0.0;
  tot := 0;
  miss := 0;
  brick := @flooseparts[0];
  for i := 0 to fnumlooseparts - 1 do
  begin
    Inc(tot, brick.num);
    pci := db.PieceColorInfo(brick.part, brick.color);
    if pci <> nil then
    begin
      price := pci.priceguide.nQtyAvgPrice;
      d1 := d1 + pci.nDemand * price * brick.num;
      d2 := d2 + price * brick.num;
      if price = 0.0 then
        Inc(miss, brick.num);
    end;
    Inc(brick);
  end;

  if d2 > 0.0 then
    result.value := d1 / d2
  else
    result.value := 0.0;
  if tot = 0 then
    exit;
  result.percentage := 1.0 - miss / tot;
end;

function TBrickInventory.uDemand: partout_t;
var
  i: integer;
  tot, miss: integer;
  pci: TPieceColorInfo;
  d1, d2: double;
  brick: brickpool_p;
  price: double;
  inv: TBrickInventory;
begin
  FillChar(Result, SizeOf(partout_t), 0);
  if (fnumlooseparts = 0) and (totalsetsbuilted = 0) then
    exit;

  if totalsetsbuilted > 0 then
  begin
    inv := Clone;
    inv.DismandalAllSets;
    result := inv.uDemand;
    inv.Free;
    exit;
  end;

  d1 := 0.0;
  d2 := 0.0;
  tot := 0;
  miss := 0;
  brick := @flooseparts[0];
  for i := 0 to fnumlooseparts - 1 do
  begin
    Inc(tot, brick.num);
    pci := db.PieceColorInfo(brick.part, brick.color);
    if pci <> nil then
    begin
      price := pci.priceguide.uQtyAvgPrice;
      d1 := d1 + pci.uDemand * price * brick.num;
      d2 := d2 + price * brick.num;
      if price = 0.0 then
        Inc(miss, brick.num);
    end;
    Inc(brick);
  end;

  if d2 > 0.0 then
    result.value := d1 / d2
  else
    result.value := 0.0;
  if tot = 0 then
    exit;
  result.percentage := 1.0 - miss / tot;
end;

function fpciloaderworker(parms: fpciloaderparams_p): integer; stdcall;
var
  i, j: integer;
begin
  for i := -1 to MAXINFOCOLOR do
    if parms.db.fcolors[i].id = i then
    begin
      if parms.db.fcolors[i].knownpieces <> nil then
        for j := 0 to parms.db.fcolors[i].knownpieces.Count - 1 do
          (parms.db.fcolors[i].knownpieces.Objects[j] as TPieceColorInfo).Load;
    end;
  result := 0;
end;

//------------------------------------------------------------------------------
constructor TCacheDB.Create(const aname: string);
begin
  waitlist := TDNumberList.Create;
  parecs := malloc(SizeOf(cachedbparec_t));
  fname := aname;
  fstream := nil;
  if fexists(aname) then
  begin
    OpenDB('r');
    if fstream <> nil then
    begin
      fstream.Read(parecs^, SizeOf(cachedbparec_t));
      CloseDB;
    end
    else
      ZeroMemory(parecs, SizeOf(cachedbparec_t));
  end
  else
  begin
    ZeroMemory(parecs, SizeOf(cachedbparec_t));
    OpenDB('c');
    if fstream <> nil then
    begin
      fstream.Write(parecs^, SizeOf(cachedbparec_t));
      CloseDB;
    end;
  end;
  Inherited Create;
end;

function TCacheDB.apart(const it: cachedbitem_p): string;
var
  i: integer;
  c: char;
begin
  result := '';
  for i := 0 to CACHEDBSTRINGSIZE - 1 do
  begin
    c := it.partid[i];
    if c <> #0 then
      result := result + c
    else
      exit;
  end;
end;

function TCacheDB.OpenDB1(const mode: char): TFileStream;
begin
  if mode = 'w' then
  begin
    try
      result := TFileStream.Create(fname, fmOpenReadWrite {or fmShareDenyWrite});
    except
      result := nil;
    end;
    exit;
  end
  else if mode = 'r' then
  begin
    try
      result := TFileStream.Create(fname, fmOpenRead{ or fmShareDenyWrite});
    except
      result := nil;
    end;
    exit;
  end
  else if mode = 'c' then
  begin
    try
      result := TFileStream.Create(fname, fmCreate {or fmShareDenyWrite});
    except
      result := nil;
    end;
    exit;
  end
  else
    result := nil;
end;

function TCacheDB.TryOpenDB(const mode: char; const maxretry: integer = 10000): TFileStream;
var
  i: integer;
  limit: integer;
begin
  result := nil;
  limit := round(maxretry * 0.8999);
  for i := 0 to maxretry - 1 do
  begin
    result := OpenDB1(mode);
    if result <> nil then
      exit;
    if i >= limit then
      Sleep(10)
    else
      Sleep(1);
  end;
end;

procedure TCacheDB.OpenDB(const mode: char);
begin
  CloseDB;
  fstream := TryOpenDB(mode);
end;

procedure TCacheDB.CloseDB;
begin
  if fstream <> nil then
  begin
    fstream.Free;
    fstream := nil;
  end;
end;

function TCacheDB.LoadPCI(const p: TPieceColorInfo): boolean;
var
  idx: integer;
  pc: cachedbitem_p;
  i: integer;
begin
  idx := p.fhash;
  for i := idx to idx + 20 do
  begin
    pc := @parecs[i mod CACHEDBHASHSIZE];
    if pc.color = p.color then
      if apart(pc) = p.piece then
      begin
        p.Assign(pc.parec.priceguide);
        p.Assign(pc.parec.availability);
        p.fdate := pc.parec.date;                                                            ;
        result := true;
        exit;
      end;
  end;
  result := false;
end;

function TCacheDB.SavePCI(const p: TPieceColorInfo): boolean;
var
  idx, idx2: integer;
  pc: cachedbitem_p;
  i, len: integer;
  spiece: string;
begin
  idx := p.Hash;
  idx2 := idx;
  spiece := p.piece;
  pc := @parecs[idx];
  for i := idx to idx + 20 do
  begin
    pc := @parecs[i mod CACHEDBHASHSIZE];
    if pc.color = p.color then
      if apart(pc) = p.piece then
      begin
        idx2 := i mod CACHEDBHASHSIZE;
        Break;
      end;
    if pc.color = 0 then
      if apart(pc) = '' then
      begin
        idx2 := i mod CACHEDBHASHSIZE;
        Break;
      end;
  end;
  pc := @parecs[idx2];

  len := length(spiece);
  if len > CACHEDBSTRINGSIZE then
    len := CACHEDBSTRINGSIZE;
  for i := 1 to len do
    pc.partid[i - 1] := spiece[i];
  for i := len to CACHEDBSTRINGSIZE - 1 do
    pc.partid[i] := #0;
  pc.color := p.color;
  pc.parec.priceguide := p.priceguide;
  pc.parec.availability := p.availability;
  pc.parec.date := p.fdate;
  waitlist.Add(idx2);
  if waitlist.Count > 5 then
    Flash;
  result := true;
end;

procedure TCacheDB.Flash;
var
  i, idx: integer;
begin
  OpenDB('w');
  if fstream <> nil then
  begin
    for i := 0 to waitlist.Count - 1 do
    begin
      idx := waitlist.Numbers[i];
      fstream.Position := idx * SizeOf(cachedbitem_t);
      fstream.Write(parecs[idx], SizeOf(cachedbitem_t));
    end;
    CloseDB;
    waitlist.Clear;
  end;
end;

destructor TCacheDB.Destroy;
begin
  Flash;
  CloseDB;
  waitlist.Free;
  memfree(pointer(parecs), SizeOf(cachedbparec_t));
  Inherited;
end;

//------------------------------------------------------------------------------
constructor TSetsDatabase.Create;
begin
  db := self;
  inherited Create;
  flastcrawlpiece := '';
  progressfunc := nil;
end;

procedure TSetsDatabase.InitCreate(const app: string = '');
begin
  if app = '' then
    fcrawlerfilename := 'crawler.tmp'
  else
    crawlerfilename := app + '.tmp';
  if not DirectoryExists(basedefault + 'cache') then
    MkDir(basedefault + 'cache');
  if not DirectoryExists(basedefault + 'storage') then
    MkDir(basedefault + 'storage');
  fCacheDB := TCacheDB.Create(basedefault + 'cache\cache.db');
  fbinarysets := TBinarySetCollection.Create(basedefault + 'db\sets.db');

  st_pciloads := 0;
  st_pciloadscache := 0;

  ZeroMemory(@fbricklinkcolortorebricablecolor, SizeOf(fbricklinkcolortorebricablecolor));
  fstubpieceinfo := TPieceInfo.Create;
  fstubpieceinfo.desc := '(Unknown)';
  floaded := false;
  fallsets := THashStringList.Create;
  fallsetswithoutextra := THashStringList.Create;
  fcolorpieces := TStringList.Create;
  fcrawlerpriority := TStringList.Create;
  fstorage := TStringList.Create;
  InitColors;
  InitPieces;
  InitSets;
  InitCategories;
end;

function FindAproxColorIndex(const colors: colorinfoarray_p; id: integer): integer;
var
  r, g, b: integer;
  rc, gc, bc: integer;
  dr, dg, db1: integer;
  i: integer;
  c, cc: LongWord;
  dist: LongWord;
  mindist: LongWord;
begin
  c := colors[id].RGB;
  r := c and $FF;
  g := (c shr 8) and $FF;
  b := (c shr 16) and $FF;
  result := -1;
  mindist := LongWord($ffffffff);
  for i := 0 to MAXINFOCOLOR do
    if i <> id then
    begin
      cc := colors[i].RGB;
      rc := cc and $FF;
      gc := (cc shr 8) and $FF;
      bc := (cc shr 16) and $FF;
      dr := r - rc;
      dg := g - gc;
      db1 := b - bc;
      dist := dr * dr + dg * dg + db1 * db1;
      if dist < mindist then
      begin
        result := i;
        mindist := dist;
      end;
    end;
end;

procedure TSetsDatabase.InitColors;
var
  s: TStringList;
  i: integer;
  id: integer;
  s1: TStringList;
  fc: colorinfo_p;
begin
  ZeroMemory(@fcolors, SizeOf(colorinfoarray_t));
  fcolors[MAXINFOCOLOR].id := MAXINFOCOLOR;
  s := TStringList.Create;
  s1 := TStringList.Create;
  s.LoadFromFile(basedefault + 'db\db_colors.txt');
  if s.Count > 0 then
    if s.Strings[0] = 'ID,Name,RGB,Num Parts,Num Sets,From Year,To Year,LEGO Color,LDraw Color,Bricklink Color,Peeron Color' then
    begin
      for i := 1 to s.Count - 1 do
      begin
        s1.Text := StringReplace(s.Strings[i], ',', #13#10, [rfReplaceAll]);
        if s1.Count >= 11 then
        begin
          id := StrToIntDef(s1.Strings[0], -1);
          if (id >= 0) and (id <= MAXINFOCOLOR) then
          begin
            fc := @fcolors[id];
            fc.id := id;
            fc.name := s1.Strings[1];
            fc.RGB := HexToInt(s1.Strings[2]);
            fc.nParts := StrToIntDef(s1.Strings[3], 0);
            fc.nSets := StrToIntDef(s1.Strings[4], 0);
            fc.fYear := StrToIntDef(s1.Strings[5], 0);
            fc.yYear := StrToIntDef(s1.Strings[6], 0);
            fc.legoColor := s1.Strings[7];
            fc.ldrawColor := StrToIntDef(s1.Strings[8], 0);
            fc.BrickLinkColor := StrToIntDef(s1.Strings[9], 0);
            fbricklinkcolortorebricablecolor[fc.BrickLinkColor] := id;
            fc.PeeronColor := s1.Strings[10];
          end;
        end;

      end;
    end;

  fbricklinkcolortorebricablecolor[0] := -1;
  fcolors[-1].alternateid := -1;
  for i := 0 to MAXINFOCOLOR do
    if fcolors[i].id <> 0 then
      fcolors[i].alternateid := FindAproxColorIndex(@fcolors, i);

  fcolors[-1].knownpieces := THashStringList.Create;

  s.Free;
  s1.Free;
end;

procedure TSetsDatabase.InitCategories;
var
  sl: TStringList;
  s, s1, s2: string;
  idx: integer;
  i: integer;
  pinf: TPieceInfo;
  scat, spiece, sweight, sdim: string;
  sdimx, sdimy, sdimz: string;
begin
  ZeroMemory(@fcategories, SizeOf(categoryinfoarray_t));
  for i := 0 to MAXCATEGORIES - 1 do
    fcategories[i].knownpieces := THashStringList.Create;

  sl := TStringList.Create;
  sl.LoadFromFile(basedefault + 'db\db_categories.txt');
  if sl.Count > 0 then
    if sl.Strings[0] = 'Category_ID,Category_Name' then
      for i := 1 to sl.Count - 1 do
      begin
        s := sl.Strings[i];
        splitstringex(s, s1, s2, ',');
        idx := StrToIntDef(s1, -1);
        if (idx >= 0) and (idx < MAXCATEGORIES) then
          fcategories[idx].name := s2;
      end;
  sl.Free;

  sl := TStringList.Create;
  sl.LoadFromFile(basedefault + 'db\db_pieces_bl.txt');
  if sl.Count > 0 then
    if sl.Strings[0] = 'Category_ID,Part,Weight,Dimensions' then
      for i := 1 to sl.Count - 1 do
      begin
        s := sl.Strings[i];
        splitstringex(s, scat, spiece, sweight, sdim, ',');
        splitstringex(sdim, sdimx, sdimy, sdimz, 'x');
        sdimx := Trim(sdimx);
        sdimy := Trim(sdimy);
        sdimz := Trim(sdimz);
        spiece := RebrickablePart(spiece);
        idx := IndexOfString(fpieceshash, spiece);
        if idx > -1 then
        begin
          pinf := fpieces.Objects[idx] as TPieceInfo;
          pinf.weight := atof(sweight, 0.0);
          pinf.dimentionx := atof(sdimx, 0.0);
          pinf.dimentiony := atof(sdimy, 0.0);
          pinf.dimentionz := atof(sdimz, 0.0);
          idx := StrToIntDef(scat, 0);
          pinf.category := idx;
          fcategories[idx].knownpieces.AddObject(spiece, pinf);
        end;

      end;
  sl.Free;
end;

function TSetsDatabase.Colors(const i: Integer): colorinfo_p;
begin
  if (i >= 0) and (i <= MAXINFOCOLOR) then
    Result := @fcolors[i]
  else
    Result := @fcolors[-1];
end;

procedure TSetsDatabase.InitSets;
var
  i: integer;

  procedure _loadsets(const fn: string; const ismoc: boolean);
  var
    s: TStringList;
    ss: TSetExtraInfo;
    stmp: string;
    stmp2: string;
    i, p, idx: integer;
    tx: string;
    tx2: string;
    year: integer;
    sname: string;
  begin
    s := TStringList.Create;
    s.LoadFromFile(fn);
    stmp := s.Text;
    SetLength(stmp2, Length(stmp));
    for i := 1 to Length(stmp) do
      if stmp[i] = '"' then
        stmp2[i] := ' '
      else
        stmp2[i] := stmp[i];

    s.Text := stmp2;
    if s.Count > 0 then
      if Trim(s.Strings[0]) = 'set_id,descr,year' then
      begin
        for i := 1 to s.Count - 1 do
        begin
          if i mod 200 = 0 then
            if Assigned(progressfunc) then
              if ismoc then
                progressfunc('Initializing mocs...', i / s.Count)
              else
                progressfunc('Initializing sets...', i / s.Count);

          stmp := s.Strings[i];
          p := Pos(',', stmp);
          if p > 0 then
          begin
            sname := Trim(Copy(stmp, 1, p - 1));
            if fsets.IndexOf(sname) < 0 then
            begin
              ss := TSetExtraInfo.Create;
              ss.Moc := ismoc;
              splitstringex(Trim(Copy(stmp, p + 1, Length(stmp) - p)), tx, tx2, ',');
              year := atoi(tx2);
              idx := fsets.AddObject(sname, ss);
              (fsets.Objects[idx] as TSetExtraInfo).Text := tx;
              (fsets.Objects[idx] as TSetExtraInfo).Year := year;
            end;
          end;
        end;
      end;
    s.Free;
  end;

begin
  fsets := TStringList.Create;
  fsetshash := THashTable.Create;
  fsets.Sorted := True;

  _loadsets(basedefault + 'db\db_sets.txt', false);
  _loadsets(basedefault + 'db\db_mocs.txt', true);

  fsetshash.AssignStringList(fsets);
  for i := 0 to fsets.Count - 1 do
    fcolors[-1].knownpieces.AddObject(fsets.Strings[i], TPieceColorInfo.Create(fsets.Strings[i], -1));
end;


procedure TSetsDatabase.InitSetReferences;
var
  i: integer;
  binset: PBinarySetRecord;
  numrecs: integer;
  pci: TPieceColorInfo;
  spiece, scolor, snum, scost, sset: string;
  s: TStringList;
  idx, j: integer;
  cc, num: integer;
begin
  s := TStringList.Create;
  for i := 0 to fsets.Count - 1 do
  begin
    if i mod 500 = 0 then
      if Assigned(progressfunc) then
        progressfunc('Loading sets...', i / fsets.Count);

    sset := fsets.strings[i];
    if fallsets.IndexOf(sset) < 0 then
      if fallsetswithoutextra.IndexOf(sset) < 0 then
      begin
        binset := fbinarysets.GetSet(sset);
        if binset <> nil then
        begin
          numrecs := binset.numitems;
          for j := 0 to numrecs - 1 do
          begin
            spiece := binset.data[j].piece;
            cc := binset.data[j].color;
            num := binset.data[j].num;

            AddSetPiece(sset, spiece, '1', cc, num);

            if (cc >= -1) and (cc <= MAXINFOCOLOR) then
            begin
              idx := fcolors[cc].knownpieces.Indexof(spiece);
              if idx < 0 then
              begin
                pci := TPieceColorInfo.Create(spiece, cc);
                fcolors[cc].knownpieces.AddObject(spiece, pci);
              end
              else
                pci := fcolors[cc].knownpieces.Objects[idx] as TPieceColorInfo;
              pci.AddSetReference(sset, num);
            end;
          end;
        end
        else if FileExists(basedefault + 'db\sets\' + sset + '.txt') then
        begin        
          s.LoadFromFile(basedefault + 'db\sets\' + sset + '.txt');

          for j := 1 to s.Count - 1 do
          begin
            splitstringex(s.strings[j], spiece, scolor, snum, scost, ',');

            if Pos('BL ', spiece) = 1 then
              spiece := RebrickablePart(Copy(spiece, 4, Length(spiece) - 3))
            else
              spiece := RebrickablePart(spiece);
            if Pos('BL', scolor) = 1 then
            begin
              scolor := Copy(scolor, 3, Length(scolor) - 2);
              cc := BrickLinkColorToRebrickableColor(StrToIntDef(scolor, 0));
            end
            else
              cc := atoi(scolor);

            num := atoi(snum);
            AddSetPiece(sset, spiece, '1', cc, num);

            if (cc >= -1) and (cc <= MAXINFOCOLOR) then
            begin
              idx := fcolors[cc].knownpieces.Indexof(spiece);
              if idx < 0 then
              begin
                pci := TPieceColorInfo.Create(spiece, cc);
                fcolors[cc].knownpieces.AddObject(spiece, pci);
              end
              else
                pci := fcolors[cc].knownpieces.Objects[idx] as TPieceColorInfo;
              pci.AddSetReference(sset, num);
            end;

          end;
          fbinarysets.UpdateSetFromText(sset, s);

        end;
      end;
  end;

  s.Free;
end;

procedure TSetsDatabase.InitPieces;
var
  s: TBStringList;
  sp: TPieceInfo;
  stmp,stmp2,stmp3: string;
  i, p: integer;
begin
  fpieces := TStringList.Create;
  fpieceshash := THashTable.Create;

  s := TBStringList.Create;
  s.LoadFromFile(basedefault + 'db\db_pieces.txt');
  if FileExists(basedefault + 'db\db_pieces.extra.txt') then
    s.AppendFromFile(basedefault + 'db\db_pieces.extra.txt');

  stmp := s.Text;
  SetLength(stmp2, Length(stmp));
  for i := 1 to Length(stmp) do
    if stmp[i] = '"' then
      stmp2[i] := ' '
    else
      stmp2[i] := stmp[i];

  s.Text := stmp2;
  if s.Count > 0 then
    if Trim(s.Strings[0]) = 'piece_id,descr' then
    begin
      for i := 1 to s.Count - 1 do
      begin
        stmp := s.Strings[i];
        p := Pos(',', stmp);
        if p > 0 then
        begin
          sp := TPieceInfo.Create;
          sp.desc := Trim(Copy(stmp, p + 1, Length(stmp) - p));
          stmp3 := Trim(Copy(stmp, 1, p - 1));
          if Length(stmp3)>0 then fpieces.AddObject(stmp3, sp);
        end;
      end;
    end;
  fpieces.Sorted := True;
  fpieceshash.AssignStringList(fpieces);
  s.Free;

  InitPiecesAlias;
  InitCrawlerLinks;
end;

procedure TSetsDatabase.InitPiecesAlias;
var
  s: TBStringList;
  i, p, idx: integer;
  stmp: string;
  s1, s2: string;
  ss: TString;
begin
  fpiecesaliasBL := THashStringList.Create;
  fpiecesaliasRB := THashStringList.Create;
  s := TBStringList.Create;
  s.LoadFromFile(basedefault + 'db\db_pieces_alias.txt');

  if s.Count > 0 then
    if Trim(s.Strings[0]) = 'bricklink,rebricable' then
    begin
      for i := s.Count - 1 downto 1 do
      begin
        stmp := s.Strings[i]; idx:= -1;
        p := Pos(',', stmp);
        if p > 0 then
        begin
          s1 := Trim(Copy(stmp, p + 1, Length(stmp) - p));
          s2 := Trim(Copy(stmp, 1, p - 1));
          // jval Maybe remove the following if
          if (fpiecesaliasBL.IndexOf(s1) < 0) and (fpiecesaliasRB.IndexOf(s2) < 0) then
          begin
            ss := TString.Create;
            ss.Text := s2;
            if Length(s1)>0 then idx := fpiecesaliasBL.AddObject(s1, ss);

            ss := TString.Create;
            ss.Text := s1;
            if Length(s2)>0 then idx := fpiecesaliasRB.AddObject(s2, ss);
          end;
        end;
      end;
    end;

  s.Free;
end;

procedure TSetsDatabase.InitCrawlerLinks;
var
  s: TBStringList;
  i, idx: integer;
  stmp: string;
  s1, s2, s3: string;
  ss: TString;
begin
  fCrawlerLinks := TStringList.Create;
  s := TBStringList.Create;
  s.LoadFromFile(basedefault + 'db\db_crawlerlinks.txt');

  if s.Count > 0 then
    if Trim(s.Strings[0]) = 'part,color,bllink' then
    begin
      for i := s.Count - 1 downto 1 do
      begin
        stmp := Trim(s.Strings[i]);
        splitstringex(stmp, s1, s2, s3, ',');
        if fCrawlerLinks.IndexOf(s1 + ',' + s2) < 0 then
        begin
          ss := TString.Create;
          idx := fCrawlerLinks.AddObject(s1 + ',' + s2, ss);
          (fCrawlerLinks.Objects[idx] as TString).Text := s3;
        end;
      end;
    end;

  fCrawlerLinks.Sorted := true;
  s.Free;
end;


procedure TSetsDatabase.AddPieceAlias(const bl, rb: string);
var
  s: TBStringList;
  ch: string;
  idx: integer;
begin
  if strtrim(bl) <> '' then
    AddPieceAlias('', rb);

  s := TBStringList.Create;
  s.LoadFromFile(basedefault + 'db\db_pieces_alias.txt');
  // Rebrickable part = SPACES, delete reference
  if strtrim(bl) = '' then
  begin
    ch := strtrim(BricklinkPart(rb)) + ',' + strtrim(rb);
    idx := s.IndexOf(ch);
    if idx > 0 then
    begin
      s.delete(idx);
      FreeHashList(fpiecesaliasBL);
      FreeHashList(fpiecesaliasRB);
      backupfile(basedefault + 'db\db_pieces_alias.txt');
      s.SaveToFile(basedefault + 'db\db_pieces_alias.txt');
      InitPiecesAlias;
    end;
  end
  else
  begin
    if strtrim(strupper(bl)) <>  strtrim(strupper(rb)) then
    begin
      ch := strtrim(bl) + ',' + strtrim(rb);
      if s.IndexOf(ch) < 0 then
      begin
        FreeHashList(fpiecesaliasBL);
        FreeHashList(fpiecesaliasRB);
        s.Add(ch);
        backupfile(basedefault + 'db\db_pieces_alias.txt');
        s.SaveToFile(basedefault + 'db\db_pieces_alias.txt');
        InitPiecesAlias;
      end;
    end;
  end;
  s.Free;
end;

procedure TSetsDatabase.AddCrawlerLink(const part: string; const color: integer; const link: string);
var
  ch: string;
  idx: integer;
  s: TStringList;
  i: integer;
begin
  // link = SPACES, delete reference
  if strtrim(link) = '' then
  begin
    ch := strtrim(part) + ',' + itoa(color);
    idx := fCrawlerLinks.IndexOf(ch);
    if idx > 0 then
    begin
      fCrawlerLinks.Objects[idx].Free;
      fCrawlerLinks.delete(idx);
    end
    else
      exit;
  end
  else
  begin
    ch := strtrim(part) + ',' + itoa(color);
    idx := fCrawlerLinks.IndexOf(ch);
    if idx < 0 then
      idx := fCrawlerLinks.AddObject(ch, TString.Create);
    (fCrawlerLinks.Objects[idx] as TString).Text := link;
  end;
  s := TStringList.Create;
  s.Add('part,color,bllink');
  for i := 0 to fCrawlerLinks.Count - 1 do
    s.Add(fCrawlerLinks.Strings[i] + ',' + (fCrawlerLinks.Objects[i] as TString).Text);
  backupfile(basedefault + 'db\db_crawlerlinks.txt');
  s.SaveToFile(basedefault + 'db\db_crawlerlinks.txt');
  s.Free;
end;

function TSetsDatabase.CrawlerLink(const part: string; const color: integer): string;
var
  ch: string;
  idx: integer;
begin
  ch := strtrim(part) + ',' + itoa(color);
  idx := fCrawlerLinks.IndexOf(ch);
  if idx >= 0 then
    result := strtrim((fCrawlerLinks.Objects[idx] as TString).Text)
  else
    result := '';
end;

function TSetsDatabase.BrickLinkPart(const s: string): string;
var
  idx: integer;
begin
  idx := fpiecesaliasBL.IndexOf(s);
  if idx > -1 then
    Result := (fpiecesaliasBL.Objects[idx] as TString).Text
  else
    result := s;
end;

function TSetsDatabase.BrickLinkColorToRebrickableColor(const c: integer): integer;
begin
  if c >=0 then
    if c <= MAXBRICKLINKCOLOR then
    begin
      result := fbricklinkcolortorebricablecolor[c];
      exit;
    end;
  Result := 0;
end;

function TSetsDatabase.RebrickablePart(const s: string): string;
var
  idx: integer;
begin
  idx := fpiecesaliasRB.IndexOf(s);
  if idx > -1 then
    Result := (fpiecesaliasRB.Objects[idx] as TString).Text
  else
    result := s;
end;

function TSetsDatabase.GetDesc(const s: string): string;
var
  idx: integer;
begin
  idx := fsetshash.GetPos(s);
  if idx = -1 then
  begin
    Result := '';
    exit;
  end;
  if fsets.Strings[idx] = s then
    Result := (fsets.Objects[idx] as TSetExtraInfo).Text
  else
  begin
    idx := fsets.IndexOf(s);
    if idx >= 0 then
      Result := (fsets.Objects[idx] as TSetExtraInfo).Text
    else
      Result := '';
  end;
end;

function TSetsDatabase.GetYear(const s: string): integer;
var
  idx: integer;
begin
  idx := fsetshash.GetPos(s);
  if idx = -1 then
  begin
    Result := 0;
    exit;
  end;
  if fsets.Strings[idx] = s then
    Result := (fsets.Objects[idx] as TSetExtraInfo).year
  else
  begin
    idx := fsets.IndexOf(s);
    if idx >= 0 then
      Result := (fsets.Objects[idx] as TSetExtraInfo).year
    else
      Result := 0;
  end;
end;

function TSetsDatabase.IsMoc(const s: string): boolean;
var
  idx: integer;
begin
  idx := fsetshash.GetPos(s);
  if idx = -1 then
  begin
    Result := false;
    exit;
  end;
  if fsets.Strings[idx] = s then
    Result := (fsets.Objects[idx] as TSetExtraInfo).moc
  else
  begin
    idx := fsets.IndexOf(s);
    if idx >= 0 then
      Result := (fsets.Objects[idx] as TSetExtraInfo).moc
    else
      Result := false;
  end;
end;

function TSetsDatabase.GetSimilars(const s: string): string;
var
  idx: integer;
begin
  idx := fsetshash.GetPos(s);
  if idx = -1 then
  begin
    Result := '';
    exit;
  end;
  if fsets.Strings[idx] = s then
    Result := (fsets.Objects[idx] as TSetExtraInfo).similars
  else
  begin
    idx := fsets.IndexOf(s);
    if idx >= 0 then
      Result := (fsets.Objects[idx] as TSetExtraInfo).similars
    else
      Result := '';
  end;
end;

function TSetsDatabase.SetListAtYear(const y: integer): TStringList;
var
  i: integer;
begin
  result := TStringList.Create;
  for i := 0 to AllSets.Count - 1 do
    if not IsMoc(AllSets.Strings[i]) then
      if GetYear(AllSets.Strings[i]) = y then
        result.Add(AllSets.Strings[i]);
end;

function TSetsDatabase.PieceListForSets(const slist: TStringList): TStringList;
var
  i: integer;
  tmpinv: TBrickInventory;
begin
  result := TStringList.Create;
  tmpinv := TBrickInventory.Create;
  for i := 0 to slist.Count - 1 do
    tmpinv.MergeWith(GetSetInventory(slist.Strings[i]));
  tmpinv.Reorganize;
  for i := 0 to tmpinv.numlooseparts - 1 do
    result.Add(tmpinv.looseparts[i].part + ',' + itoa(tmpinv.looseparts[i].color));
  tmpinv.Free;
end;

function TSetsDatabase.PieceListForYear(const y: integer): TStringList;
var
  l: TStringList;
begin
  l := SetListAtYear(y);
  result := PieceListForSets(l);
  l.Free;
end;

function TSetsDatabase.PieceDesc(const s: string): string;
var
  idx: integer;
begin
  idx := fpieceshash.GetPos(s);
  if idx = -1 then
  begin
    idx := fpieceshash.GetPos(BrickLinkPart(s));
    if idx = -1 then
    begin
      idx := fpieceshash.GetPos(RebrickablePart(s));
      if idx = -1 then
      begin
        result := '';
        exit;
      end;
    end;
  end;
  Result := (fpieces.Objects[idx] as TPieceInfo).desc;
end;

destructor TSetsDatabase.Destroy;
var
  i: integer;
begin
  fcurrencies.Free;
  SaveStorage;

  for i := -1 to MAXINFOCOLOR do
    FreeHashList(fcolors[i].knownpieces);

  for i := 0 to MAXCATEGORIES - 1 do
    fcategories[i].knownpieces.Free;

  FreeHashList(fpiecesaliasBL);
  FreeHashList(fpiecesaliasRB);
  FreeList(fCrawlerLinks);
  FreeHashList(fallsets);
  FreeHashList(fallsetswithoutextra);
  FreeList(fpieces);
  fpieceshash.Free;
  fsetshash.Free;
  fcolorpieces.Free;
  try
    fcrawlerpriority.SaveToFile(basedefault + 'cache\' + fcrawlerfilename);
  except
    I_Warning('fcrawlerpriority.SaveToFile(): Can not save tmp file'#13#10);
  end;
  FreeList(fstorage);
  fcrawlerpriority.Free;
  fstubpieceinfo.Free;
  FreeList(fsets);
  fCacheDB.Free;
  fbinarysets.Free;
  inherited;
end;

procedure TSetsDatabase.SaveStorage;
begin
  backupfile(basedefault + 'db\db_storage.txt');
  fstorage.SaveToFile(basedefault + 'db\db_storage.txt');
end;

procedure TSetsDatabase.LoadStorage;
var
  i: integer;
  s1: TStringList;
  s2: TStringList;
  pt, cls: string;
  cl: integer;
  pci: TPieceColorInfo;
  x1, x2: string;
begin
  fstorage.Clear;
  fstorage.Add('Part,Color,Storage');
  if not FileExists(basedefault + 'db\db_storage.txt') then
    exit;
  s1 := TStringList.Create;
  s1.LoadFromFile(basedefault + 'db\db_storage.txt');
  if s1.Count <= 1 then
  begin
    s1.Free;
    exit;
  end;
  if s1.Strings[0] <> 'Part,Color,Storage' then
    exit;
  for i := 1 to s1.Count - 1 do
  begin
    splitstringex(s1.strings[i], x1, x2, ',');
    x1 := RebrickablePart(x1);
    s1.Strings[i] := x1 + ',' + x2;
    s2 := string2stringlist(s1.Strings[i], ',');
    if s2.Count > 2 then
    begin
      pt := s2.Strings[0];
      cls := s2.Strings[1];
      cl := atoi(cls);
      pci := PieceColorInfo(pt, cl);

      if pci = nil then
      begin
        pci := TPieceColorInfo.Create(pt, cl);
        if fcolors[cl].knownpieces = nil then
          fcolors[cl].knownpieces := THashStringList.Create;
        fcolors[cl].knownpieces.AddObject(pt, pci);
        pci.Load;
      end;

      if pci <> nil then
      begin
        fstorage.Add(s1.Strings[i]);
        s2.Delete(0);
        s2.Delete(0);
        pci.Storage.Text := s2.Text;
      end;
    end;
    s2.Free;
  end;
  s1.Free;
end;

function TSetsDatabase.StorageBins: TStringlist;
var
  i, j: integer;
  s1, s2: TStringList;
  s_Storage, s_Num, s_Remarks, stmp: string;
begin
  result := TStringList.Create;
  if not FileExists(basedefault + 'db\db_storage.txt') then
    exit;
  s1 := TStringList.Create;
  s1.LoadFromFile(basedefault + 'db\db_storage.txt');
  if s1.Count <= 1 then
  begin
    s1.Free;
    exit;
  end;
  if s1.Strings[0] <> 'Part,Color,Storage' then
    exit;
  for i := 1 to s1.Count - 1 do
  begin
    s2 := string2stringlist(s1.Strings[i], ',');
    for j := 2 to s2.Count - 1 do
    begin
      stmp := s2.Strings[j];
      splitstringex(stmp, s_Storage, s_Num, s_Remarks, ':');
      if result.IndexOf(s_Storage) < 0 then
        result.Add(s_Storage);
    end;
    s2.Free;
  end;
  s1.Free;
  result.Sort;
end;

function TSetsDatabase.StorageBinsForMold(const mld: string): TStringlist;
var
  i, j: integer;
  s1, s2: TStringList;
  s_Storage, s_Num, s_Remarks, stmp: string;
begin
  result := TStringList.Create;
  if not FileExists(basedefault + 'db\db_storage.txt') then
    exit;
  s1 := TStringList.Create;
  s1.LoadFromFile(basedefault + 'db\db_storage.txt');
  if s1.Count <= 1 then
  begin
    s1.Free;
    exit;
  end;
  if s1.Strings[0] <> 'Part,Color,Storage' then
    exit;
  for i := 1 to s1.Count - 1 do
  begin
    s2 := string2stringlist(s1.Strings[i], ',');
    if s2.Count > 0 then
      if s2.Strings[0] = mld then
        for j := 2 to s2.Count - 1 do
        begin
          stmp := s2.Strings[j];
          splitstringex(stmp, s_Storage, s_Num, s_Remarks, ':');
          if result.IndexOf(s_Storage) < 0 then
            result.Add(s_Storage);
        end;
    s2.Free;
  end;
  s1.Free;
  result.Sort;
end;

function TSetsDatabase.InventoryForStorageBin(const st: string): TBrickInventory;
var
  i, j: integer;
  s1, s2: TStringList;
  s_Part, s_Color, s_Storage, s_Num, s_Remarks, stmp: string;
  ss: string;
begin
  result := TBrickInventory.Create;
  if not FileExists(basedefault + 'db\db_storage.txt') then
    exit;
  s1 := TStringList.Create;
  s1.LoadFromFile(basedefault + 'db\db_storage.txt');
  if s1.Count <= 1 then
  begin
    s1.Free;
    exit;
  end;
  if s1.Strings[0] <> 'Part,Color,Storage' then
    exit;
  for i := 1 to s1.Count - 1 do
  begin
    splitstringex(s1.Strings[i], s_Part, s_Color, ss, ',');
    s2 := string2stringlist(ss, ',');
    for j := 0 to s2.Count - 1 do
    begin
      stmp := s2.Strings[j];
      splitstringex(stmp, s_Storage, s_Num, s_Remarks, ':');
      if s_Storage = st then
        if s_Num <> '' then
          result.AddLoosePart(s_Part, atoi(s_Color), atoi(s_Num));
    end;
    s2.Free;
  end;
  s1.Free;
end;

function TSetsDatabase.InventoryForAllStorageBins: TBrickInventory;
var
  i, j: integer;
  s1, s2: TStringList;
  s_Part, s_Color, s_Storage, s_Num, s_Remarks, stmp: string;
  ss: string;
begin
  result := TBrickInventory.Create;
  if not FileExists(basedefault + 'db\db_storage.txt') then
    exit;
  s1 := TStringList.Create;
  s1.LoadFromFile(basedefault + 'db\db_storage.txt');
  if s1.Count <= 1 then
  begin
    s1.Free;
    exit;
  end;
  if s1.Strings[0] <> 'Part,Color,Storage' then
    exit;
  for i := 1 to s1.Count - 1 do
  begin
    splitstringex(s1.Strings[i], s_Part, s_Color, ss, ',');
    s2 := string2stringlist(ss, ',');
    for j := 0 to s2.Count - 1 do
    begin
      stmp := s2.Strings[j];
      splitstringex(stmp, s_Storage, s_Num, s_Remarks, ':');
      if s_Num <> '' then
        result.AddLoosePart(s_Part, atoi(s_Color), atoi(s_Num));
    end;
    s2.Free;
  end;
  s1.Free;
end;

procedure TSetsDatabase.SetPieceStorage(const piece: string; const color: integer; const st: TStringList);
var
  pci: TPieceColorInfo;
  s: string;
  len: integer;
  i, j: integer;
  idx: integer;
begin
  pci := PieceColorInfo(piece, color);
  if pci <> nil then
  begin
    for i := 0 to st.Count - 1 do
    begin
      s := st.Strings[i];
      for j := 1 to length(s) do
        if s[j] = ',' then
          s[j] := ';';
      st.Strings[i] := s;
    end;
    pci.storage.Text := st.Text;
    s := Format('%s,%d,', [piece, color]);
    len := Length(s);
    idx := -1;
    for i := 1 to fstorage.Count - 1 do
      if LeftStr(fstorage.Strings[i], len) = s then
      begin
        idx := i;
        break;
      end;
    if idx = -1 then
      fstorage.Add(s + stringlist2string(st, ','))
    else
      fstorage.Strings[idx] := s + stringlist2string(st, ',');
  end;
end;

function TSetsDatabase.RefreshInv(const inv: TBrickInventory): boolean;
var
  slist: TStringList;
  i, j: integer;
  bl, blnew: string;
  cnt: integer;
  pci: TPieceColorInfo;
begin
  result := false;
  cnt := 0;
  slist := inv.GetMoldList;
  if assigned(progressfunc) then
    progressfunc('Refreshing...', 0);
  for i := 0 to slist.Count - 1 do
  begin
    bl := BrickLinkPart(slist.Strings[i]);
    if strupper(bl) = strupper(slist.Strings[i]) then
    begin
      blNew := NET_GetBricklinkAlias(slist.Strings[i]);
      if (Pos('3068bpb', blnew) = 1) and (length(blnew) = 10) then
        blnew := '3068bpb0' + blnew[8] + blnew[9] + blnew[10];
      if (blnew <> '') and (strupper(bl) <> strupper(blnew)) then
      begin
        AddPieceAlias(blnew, slist.Strings[i]);
        for j := 0 to inv.numlooseparts - 1 do
          if strupper(inv.looseparts[j].part) = strupper(slist.Strings[i]) then
          begin
            pci := PieceColorInfo(slist.Strings[i], inv.looseparts[j].color);
            if pci <> nil then
              pci.InternetUpdate;
          end;
        inc(cnt);
      end;
    end;
    if assigned(progressfunc) then
      progressfunc('Refreshing...', ((1 + i) / slist.count) * (2 / 3));
  end;

  for i := 0 to inv.numlooseparts - 1 do
  begin
    pci := PieceColorInfo(inv.looseparts[i].part, inv.looseparts[i].color);
    if pci <> nil then
      if pci.invalid then
      begin
        pci.InternetUpdate;
        if not pci.invalid then
          inc(cnt);
      end;
    if assigned(progressfunc) then
      progressfunc('Refreshing...', ((1 + i) / inv.numlooseparts) / 3 + 2 / 3);
  end;

  if cnt > 0 then
    result := true;

  slist.Free;
end;

function TSetsDatabase.RefreshSet(const s: string; const lite: boolean = false): boolean;
var
  inv: TBrickInventory;
  pci: TPieceColorInfo;
  idx: integer;
begin
  result := false;

  inv := GetSetInventory(s);

  if inv = nil then
    exit;

  if FileExists(basedefault + 'db\sets\' + s + '.txt') then
  begin
    inv.Clear;
    inv.LoadLooseParts(basedefault + 'db\sets\' + s + '.txt');
    idx := fallsetswithoutextra.IndexOf(s);
    if idx > -1 then
    begin
      (fallsetswithoutextra.Objects[idx] as TBrickInventory).Clear;
      (fallsetswithoutextra.Objects[idx] as TBrickInventory).MergeWith(inv);
    end;
    result := true;
    if not lite then
      RefreshInv(inv);
    fbinarysets.UpdateSetFromTextFile(s, basedefault + 'db\sets\' + s + '.txt')
  end
  else
    if not lite then
      result := RefreshInv(inv);

  if result then
    if not lite then
    begin
      pci := PieceColorInfo(s, -1);
      if pci <> nil then
        pci.InternetUpdate;

      inv.DoUpdateCostValues;
    end;

end;

function TSetsDatabase.RefreshPart(const s: string): boolean;
var
  inv: TBrickInventory;
  i: integer;
begin
  inv := TBrickInventory.Create;
  for i := -1 to MAXINFOCOLOR do
    if Colors(i).knownpieces <> nil then
      if Colors(i).knownpieces.IndexOf(s) > - 1 then
        inv.AddLoosePartFast(s, i, 1);

  result := RefreshInv(inv);

  inv.Free;
end;

function TSetsDatabase.UpdateSetInformation(const ident: string; const desc: string = '';
          const year: integer = 0; const ismoc: boolean = false;
          const conn: string = ''): boolean;
var
  idx,n,m: integer;
  official: TStringList;
  unofficial: TStringList;          
begin
  Result := false;
  if (Length(Trim(ident)) < 4) or (Length(Trim(desc)) < 4) or (year < MINYEAR) then begin
    exit;
  end;
  idx := fsetshash.GetPos(ident);
  if idx = -1 then
  begin
    idx := fsetshash.List.AddObject(ident,TSetExtraInfo.Create);
  end;                                  
  if not (fsets.Strings[idx] = ident) then idx := fsets.IndexOf(ident);
  if idx >= 0 then begin
    (fsets.Objects[idx] as TSetExtraInfo).text:= desc;
    (fsets.Objects[idx] as TSetExtraInfo).year:= year;
    (fsets.Objects[idx] as TSetExtraInfo).moc:= ismoc;
    (fsets.Objects[idx] as TSetExtraInfo).similars:= conn;
    Result:= true;
  end;
end;

procedure TSetsDatabase.UpdateExtraInfos(const str: TStrings);
var
  idx,i: integer;
  ident: string;
begin
  for i:= 0 to str.Count-1 do begin
    ident:= str.Names[i];
    idx := fsetshash.GetPos(ident);
    if idx = -1 then continue;
    if not (fsets.Strings[idx] = ident) then idx := fsets.IndexOf(ident);
    if idx > 0 then (fsets.Objects[idx] as TSetExtraInfo).similars:= str.ValueFromIndex[i];
  end;
end;


function TSetsDatabase.UpdateSet(const s: string; const data: string = ''): boolean;
var
  i: integer;
  slist: TStringList;
  sout: TStringList;
  spiece, scolor, snum, scost: string;
  color: integer;
  stmp2: TStringList;
  pci: TPieceColorInfo;
  idx: integer;
  pi: TPieceInfo;
  pcolor: colorinfo_p;
begin
  slist := TStringList.Create;
  slist.Text := data;
  if slist.Count < 2 then
  begin
    slist.Free;
    result := false;
    exit;
  end;

  sout := TStringList.Create;
  sout.Add('Part,Color,Num');

  for i := 1 to slist.Count - 1 do
  begin
    splitstringex(slist.Strings[i], spiece, scolor, snum, scost, ',');
    if spiece = '' then
      Continue;

    sout.Add(spiece + ',' + scolor + ',' + snum);

    if Pos('BL ', spiece) = 1 then
      spiece := db.RebrickablePart(Copy(spiece, 4, Length(spiece) - 3))
    else
      spiece := db.RebrickablePart(spiece);

    if Pos('BL', scolor) = 1 then
    begin
      scolor := Copy(scolor, 3, Length(scolor) - 2);

      color := db.BrickLinkColorToRebrickableColor(StrToIntDef(scolor, 0))
    end
    else
      color := StrToIntDef(scolor, 0);

    pci := PieceColorInfo(spiece, color);
    if pci = nil then
    begin
      pci := TPieceColorInfo.Create(spiece, color);
      pcolor := db.Colors(color);
      if pcolor.knownpieces = nil then
        pcolor.knownpieces := THashStringList.Create;
      pcolor.knownpieces.AddObject(spiece, pci);
    end;
    if PieceDesc(spiece) = '' then
    begin
      pi := TPieceInfo.Create;
      pi.desc := spiece;
      idx := fpieces.AddObject(spiece, pi);
      stmp2 := TStringList.Create;
      if fexists(basedefault + 'db\db_pieces.extra.txt') then
        stmp2.LoadFromFile(basedefault + 'db\db_pieces.extra.txt');
      stmp2.Add(spiece + ',' + spiece);
      backupfile(basedefault + 'db\db_pieces.extra.txt');
      stmp2.SaveToFile(basedefault + 'db\db_pieces.extra.txt');
      stmp2.Free;
    end;
  end;
  sout.SaveToFile(basedefault + 'db\sets\' + s + '.txt');
  fbinarysets.UpdateSetFromText(s, sout);

  sout.Free;
  slist.Free;
  result := true;
  if GetDesc(s) = '' then
  begin
    stmp2 := TStringList.Create;
    if fexists(basedefault + 'db\db_mocs.txt') then
      stmp2.LoadFromFile(basedefault + 'db\db_mocs.txt')
    else
      stmp2.Add('set_id,descr,year');
    stmp2.Add(s + ',' + s + ',0');
    stmp2.SaveToFile(basedefault + 'db\db_mocs.txt');
    stmp2.Free;
  end;
  if fcolors[-1].knownpieces.IndexOf(s) = -1 then
    fcolors[-1].knownpieces.AddObject(s, TPieceColorInfo.Create(s, -1));
  RefreshSet(s, true);
end;

function TSetsDatabase.PieceInfo(const piece: string): TPieceInfo;
var
  idx: integer;
begin
  idx := fpieceshash.GetPos(piece);
  if idx = -1 then
  begin
    idx := fpieceshash.GetPos(RebrickablePart(piece));
    if idx = -1 then
    begin
      idx := fpieceshash.GetPos(BricklinkPart(piece));
      if idx = -1 then
      begin
        Result := fstubpieceinfo;
        exit;
      end;
    end;
  end;
  Result := (fpieces.Objects[idx] as TPieceInfo);
end;

function TSetsDatabase.PieceColorInfo(const piece: string; const color: integer): TPieceColorInfo;
var
  idx: integer;

  function _checkset: TPieceColorInfo;
  begin
    if Pos('-', piece) > 1 then
      if color <> -1 then
      begin
        Result := PieceColorInfo(piece, -1);
        exit;
      end;
    Result := nil;
  end;

begin

  if (color < -1) or (color > MAXINFOCOLOR) then
  begin
    result := _checkset;
    Exit;
  end;

  if fcolors[color].knownpieces = nil then
  begin
    result := _checkset;
    Exit;
  end;

  idx := fcolors[color].knownpieces.IndexOf(piece);
  if idx < 0 then
  begin
    idx := fcolors[color].knownpieces.IndexOf(RebrickablePart(piece));
    if idx = -1 then
    begin
      result := _checkset;
      Exit;
    end;
  end;
  result := fcolors[color].knownpieces.Objects[idx] as TPieceColorInfo;
end;

function TSetsDatabase.Priceguide(const piece: string; const color: integer = -1): priceguide_t;
var
  pci: TPieceColorInfo;
begin
  pci := PieceColorInfo(piece, color);
  if pci = nil then
  begin
    FillChar(Result, SizeOf(Result), 0);
    exit;
  end;

  if not pci.hasloaded then
    pci.Load;

  Result := pci.priceguide;
end;

function TSetsDatabase.Availability(const piece: string; const color: integer = -1): availability_t;
var
  pci: TPieceColorInfo;
begin
  pci := PieceColorInfo(piece, color);
  if pci = nil then
  begin
    FillChar(Result, SizeOf(Result), 0);
    exit;
  end;

  if not pci.hasloaded then
    pci.Load;

  Result := pci.availability;
end;

function TSetsDatabase.ConvertCurrency(const cur: string): double;
begin
  Result := fcurrencies.Convert(cur);
end;

procedure TSetsDatabase.CrawlerPriorityPart(const piece: string; const color: integer = -1);
var
  cnt, i: integer;
  s: string;
  sl: TStringList;
  dn: integer;
begin
  if not floaded then
    exit;
  if not AllowInternetAccess then
    exit;
  cnt := fcrawlerpriority.Count;
  if cnt > 100000 then
  begin
    sl := TStringList.Create;
    for i := 50000 to cnt - 1 do
      sl.Add(fcrawlerpriority.Strings[i]);
    fcrawlerpriority.Clear;
    fcrawlerpriority.AddStrings(sl);
    sl.Free;
  end;
  s := IntToStr(color) + ',' + piece;

  dn := cnt - 500;
  if dn < 0 then
    dn := 0;
  for i := cnt - 1 downto dn do
    if fcrawlerpriority.Strings[i] = s then
      Exit;
  fcrawlerpriority.Add(s);
end;

procedure TSetsDatabase.Crawler;
var
  spart, scolor: string;
  idx: integer;
  pci: TPieceColorInfo;
  s: string;
  inv: TBrickInventory;
begin
  if not floaded then
    exit;

  if fcrawlerpriority.Count = 0 then
    fcrawlerpriority.AddStrings(fcolorpieces);

  if fcrawlerpriority.Count mod 100 = 99 then
  try
    fcrawlerpriority.SaveToFile(basedefault + 'cache\' + fcrawlerfilename);
  except
    I_Warning('fcrawlerpriority.SaveToFile(): Can not save tmp file'#13#10);
  end;

  idx := fcrawlerpriority.Count;
  if idx = 0 then
    exit;

  Dec(idx);
  s := fcrawlerpriority.Strings[idx];
  flastcrawlpiece := s;
  splitstringex(s, scolor, spart, ',');
  fcrawlerpriority.Delete(idx);

  idx := fcrawlerpriority.IndexOf(s);
  if idx > -1 then
    fcrawlerpriority.Delete(idx);

  pci := PieceColorInfo(spart, StrToIntDef(scolor, -1));
  if pci = nil then
    Exit;

  pci.InternetUpdate;

  if (scolor = '89') or (scolor = '') or ((scolor = '-1') and (Pos('-', spart) > 0))  then // set
  begin
    inv := GetSetInventory(spart);
    if inv <> nil then
    begin
      if not DirectoryExists(basedefault + 'out\' + spart + '\') then
        ForceDirectories(basedefault + 'out\' + spart + '\');
      inv.StoreHistoryStatsRec(basedefault + 'out\' + spart + '\' + spart + '.stats');
    end;
  end;
end;

procedure TSetsDatabase.ExportPriceGuide(const fname: string);
var
  s: TStringList;
  i, j: integer;
  k, tot: integer;
begin
  AllowInternetAccess := False;

  if Assigned(progressfunc) then
    progressfunc('Export price guide...', 0.0);

  printf('TSetsDatabase.ExportPriceGuide(' + fname + ')');

  s := TStringList.Create;
  s.Add('Part;Color;BLPart;BLColor;pg_nTimesSold;pg_nTotalQty;pg_nMinPrice;pg_nAvgPrice;' +
        'pg_nQtyAvgPrice;pg_nMaxPrice;pg_uTimesSold;pg_uTotalQty;pg_uMinPrice;' +
        'pg_uAvgPrice;pg_uQtyAvgPrice;pg_uMaxPrice;av_nTotalLots;av_nTotalQty;' +
        'av_nMinPrice;av_nAvgPrice;av_nQtyAvgPrice;av_nMaxPrice;av_uTotalLots;' +
        'av_uTotalQty;av_uMinPrice;av_uAvgPrice;av_uQtyAvgPrice;av_uMaxPrice;' +
        'EvaluatePriceNew;EvaluatePriceUsed');

  tot := 0;
  for i := -1 to MAXINFOCOLOR do
    if fcolors[i].id = i then
      Inc(tot);

  k := 0;
  for i := -1 to MAXINFOCOLOR do
    if fcolors[i].id = i then
    begin
      inc(k);
      if Assigned(progressfunc) then
        progressfunc('Export price guide...', k / tot);
      if fcolors[i].knownpieces <> nil then
        for j := 0 to fcolors[i].knownpieces.Count - 1 do
        begin
          s.Add((fcolors[i].knownpieces.Objects[j] as TPieceColorInfo).dbExportString);
        end;
    end;

  s.SaveToFile(fname);
  s.Free;

  if Assigned(progressfunc) then
    progressfunc('Export price guide...', 1.0);

  AllowInternetAccess := True;
end;

procedure TSetsDatabase.ExportPartOutGuide(const fname: string);
var
  i: integer;
  inv: TBrickInventory;
  pg: priceguide_t;
  av: availability_t;
  sold_nAvg: partout_t;
  sold_nQtyAvg: partout_t;
  sold_uAvg: partout_t;
  sold_uQtyAvg: partout_t;
  avail_nAvg: partout_t;
  avail_nQtyAvg: partout_t;
  avail_uAvg: partout_t;
  avail_uQtyAvg: partout_t;
  s: TStringList;
  sset: string;
begin
  AllowInternetAccess := False;

  if Assigned(progressfunc) then
    progressfunc('Export partout guide...', 0.0);

  printf('TSetsDatabase.ExportPartOutGuide(' + fname + ')');

  s := TStringList.Create;

  s.Add('Set,pg_nTimesSold,pg_nTotalQty,pg_nMinPrice,pg_nAvgPrice,' +
        'pg_nQtyAvgPrice,pg_nMaxPrice,pg_uTimesSold,pg_uTotalQty,pg_uMinPrice,' +
        'pg_uAvgPrice,pg_uQtyAvgPrice,pg_uMaxPrice,av_nTotalLots,av_nTotalQty,' +
        'av_nMinPrice,av_nAvgPrice,av_nQtyAvgPrice,av_nMaxPrice,av_uTotalLots,' +
        'av_uTotalQty,av_uMinPrice,av_uAvgPrice,av_uQtyAvgPrice,av_uMaxPrice,' +
        'sold_nPct,sold_nAvg,sold_nQtyAvg,sold_uPct,sold_uAvg,sold_uQtyAvg,' +
        'avail_nPct,avail_nAvg,avail_nQtyAvg,avail_uPct,avail_uAvg,avail_uQtyAvg');

  for i := 0 to fallsets.Count - 1 do
  begin
    if i mod 100 = 0 then
      if Assigned(progressfunc) then
        progressfunc('Export partout guide...', i / fallsets.Count);

    sset := fallsets.Strings[i];
    pg := Priceguide(sset);
    av := Availability(sset);
    inv := fallsets.Objects[i] as TBrickInventory;
    inv.UpdateCostValues;
    sold_nAvg := inv.SoldPartOutValue_nAvg;
    sold_nQtyAvg := inv.SoldPartOutValue_nQtyAvg;
    sold_uAvg := inv.SoldPartOutValue_uAvg;
    sold_uQtyAvg := inv.SoldPartOutValue_uQtyAvg;
    avail_nAvg := inv.AvailablePartOutValue_nAvg;
    avail_nQtyAvg := inv.AvailablePartOutValue_nQtyAvg;
    avail_uAvg := inv.AvailablePartOutValue_uAvg;
    avail_uQtyAvg := inv.AvailablePartOutValue_uQtyAvg;

    s.Add(
      Format(
        '%s;%d;%d;%2.2f;%2.2f;%2.2f;%2.2f;%d;%d;%2.2f;%2.2f;%2.2f;%2.2f;' +
        '%d;%d;%2.2f;%2.2f;%2.2f;%2.2f;%d;%d;%2.2f;%2.2f;%2.2f;%2.2f;' +
        '%2.2f;%2.2f;%2.2f;%2.2f;%2.2f;%2.2f;%2.2f;%2.2f;%2.2f;%2.2f;%2.2f;%2.2f',
       [sset,
        pg.nTimesSold,
        pg.nTotalQty,
        pg.nMinPrice,
        pg.nAvgPrice,
        pg.nQtyAvgPrice,
        pg.nMaxPrice,
        pg.uTimesSold,
        pg.uTotalQty,
        pg.uMinPrice,
        pg.uAvgPrice,
        pg.uQtyAvgPrice,
        pg.uMaxPrice,
        av.nTotalLots,
        av.nTotalQty,
        av.nMinPrice,
        av.nAvgPrice,
        av.nQtyAvgPrice,
        av.nMaxPrice,
        av.uTotalLots,
        av.uTotalQty,
        av.uMinPrice,
        av.uAvgPrice,
        av.uQtyAvgPrice,
        av.uMaxPrice,
        sold_nAvg.percentage,
        sold_nAvg.value,
        sold_nQtyAvg.value,
        sold_uAvg.percentage,
        sold_uAvg.value,
        sold_uQtyAvg.value,
        avail_nAvg.percentage,
        avail_nAvg.value,
        avail_nQtyAvg.value,
        avail_uAvg.percentage,
        avail_uAvg.value,
        avail_uQtyAvg.value]));
  end;

  backupfile(fname);
  s.SaveToFile(fname);
  s.Free;

  if Assigned(progressfunc) then
    progressfunc('Export partout guide...', 1.0);

  AllowInternetAccess := true;
end;


constructor TPieceInfo.Create;
begin
  desc := '';
  category := 0;
  weight := 0;
  dimentionx := 0;
  dimentiony := 0;
  dimentionz := 0;
  inherited;
end;

constructor TPieceColorInfo.Create(const apiece: string; const acolor: integer);
begin
  fsetmost := '';
  fsetmostnum := 0;
  fsets := TStringList.Create;
  fsets.Sorted := true;
  fstorage := TStringList.Create;
  FillChar(fpriceguide, SizeOf(priceguide_t), 0);
  FillChar(favailability, SizeOf(availability_t), 0);
  fappearsinsets := 0;
  fappearsinsetstotal := 0;
  fpiece := Trim(apiece);
  fcolor := acolor;
  fhash := MkPCIHash(apiece, acolor);
  fcolorstr := IntToStr(fcolor);
  fneedssave := false;
  fhasloaded := false;
  fdate := Now;
  inherited Create;
end;

destructor TPieceColorInfo.Destroy;
var
  i: integer;
begin
  for i := 0 to fsets.Count - 1 do
    if fsets.Objects[i] <> nil then
      fsets.Objects[i].Free;
  fsets.Free;
  fstorage.Free;
  inherited;
end;

function TPieceColorInfo.LoadFromDisk: boolean;
var
  fname: string;
  f: TFileStream;
  pa: parec_t;
  pad: parecdate_t;
  sz: integer;
begin
  inc(db.st_pciloads);
  if db.CacheDB.LoadPCI(self) then
  begin
    inc(db.st_pciloadscache);
    fneedssave := false;
    result := true;
    exit;
  end;
  result := false;
  fname := PieceColorCacheFName(fpiece, fcolorstr);
  if FileExists(fname) then
  begin
    try
      f := TFileStream.Create(fname, fmOpenRead or fmShareDenyWrite);
    except
      Sleep(50);
      try
        f := TFileStream.Create(fname, fmOpenRead or fmShareDenyWrite);
      except
        Exit;
      end;
    end;
    sz := f.Size;
    if sz = SizeOf(priceguide_t) + SizeOf(availability_t) then
    begin
      f.Read(pa, SizeOf(parec_t));
      f.Free;
      fdate := GetFileCreationTime(fname);
    end
    else if sz = SizeOf(priceguide_t) then
    begin
      f.Read(pa.priceguide, SizeOf(priceguide_t));
      ZeroMemory(@pa.availability, SizeOf(availability_t));
      f.Free;
      fdate := GetFileCreationTime(fname);
    end
    else if (sz mod SizeOf(parecdate_t) = 0) and (sz >= SizeOf(parecdate_t)) then
    begin
      f.Position := sz - SizeOf(parecdate_t);
      f.Read(pad, SizeOf(parecdate_t));
      pa.priceguide := pad.priceguide;
      pa.availability := pad.availability;
      fdate := pad.date;
      f.Free;
    end
    else
    begin
      ZeroMemory(@pa.priceguide, SizeOf(priceguide_t));
      ZeroMemory(@pa.availability, SizeOf(availability_t));
      f.Free;
      fdate := GetFileCreationTime(fname);
    end;
    PRICEADJUST(fpiece, fcolor, pa.priceguide, pa.availability, fdate);
    Assign(pa.priceguide);
    Assign(pa.availability);
    fneedssave := false;
    result := Check;
  end;
end;

procedure TPieceColorInfo.Load;
begin
  if not LoadFromDisk then
  begin
    printf('Can not find cache info for part=%s, color=%d', [fpiece, fcolor]);
    InternetUpdate;
  end;
end;

procedure TPieceColorInfo.SaveToDisk;
var
  fname: string;
  fdir: string;
  f: TFileStream;
  pa: parec_t;
  pad: parecdate_t;
  d: TDateTime;
  sz: Int64;
begin
  if not fneedssave then
    Exit;

  if not fhasloaded then
    Exit;

  fdir := PieceColorCacheDir(fpiece, fcolorstr);
  if not DirectoryExists(fdir) then
    ForceDirectories(fdir);
  fname := PieceColorCacheFName(fpiece, fcolorstr);

  if not FileExists(fname) then
  begin
    try
      f := TFileStream.Create(fname, fmCreate or fmShareDenyWrite);
    except
      Sleep(50);
      try
        f := TFileStream.Create(fname, fmCreate or fmShareDenyWrite);
      except
        Exit;
      end;
    end;
  end
  else
  begin
    d := GetFileCreationTime(fname);
    f := TFileStream.Create(fname, fmOpenReadWrite or fmShareDenyWrite);
    sz := f.size;
    if sz = SizeOf(parec_t) then
    begin
      f.Read(pa, SizeOf(parec_t));
      pad.priceguide := pa.priceguide;
      pad.availability := pa.availability;
      pad.date := d - 1.0;
      f.Position := 0;
      f.Write(pad, SizeOf(pad))
    end
    else if sz = SizeOf(priceguide_t) then
    begin
      f.Read(pa.priceguide, SizeOf(priceguide_t));
      ZeroMemory(@pa.availability, SizeOf(availability_t));
      pad.priceguide := pa.priceguide;
      pad.availability := pa.availability;
      pad.date := d - 1.0;
      f.Position := 0;
      f.Write(pad, SizeOf(pad));
    end;
  end;

  f.Position := f.Size;
  Check;
  f.Write(fpriceguide, SizeOf(priceguide_t));
  f.Write(favailability, SizeOf(availability_t));
  f.Write(fdate, SizeOf(TDateTime));

  f.Free;

  db.CacheDB.SavePCI(self);
  fneedssave := false;
end;

procedure TPieceColorInfo.InternetUpdate;
var
  pg: priceguide_t;
  av: availability_t;
  fdir, fname: string;
begin
  fdir := PieceColorCacheDir(fpiece, fcolorstr);
  if not DirectoryExists(fdir) then
    ForceDirectories(fdir);
  fname := PieceColorCacheFName(fpiece, fcolorstr) + '.htm';
  if NET_GetPriceGuideForElement(fpiece, fcolorstr, pg, av, fname) then
  begin
    fdate := Now;
    PRICEADJUST(fpiece, fcolor, pg, av, fdate);
    Assign(pg);
    Assign(av);
    SaveToDisk;
  end
  else if not FileExists(PieceColorCacheFName(fpiece, fcolorstr)) then
  begin
    FillChar(pg, SizeOf(priceguide_t), 0);
    FillChar(av, SizeOf(availability_t), 0);
    fdate := Now;
    PRICEADJUST(fpiece, fcolor, pg, av, fdate);
    Assign(pg);
    Assign(av);
    SaveToDisk;
  end;
end;

function TPieceColorInfo.invalid: boolean;
begin
  result := fpriceguide.nTimesSold + fpriceguide.nTotalQty + fpriceguide.uTimesSold + fpriceguide.uTotalQty +
            favailability.nTotalLots + favailability.nTotalQty + favailability.uTotalLots + favailability.uTotalQty = 0;
end;

procedure TPieceColorInfo.AddSetReference(const aset: string; const numpieces: integer);
begin
  if numpieces > 0 then
  begin
    Inc(fappearsinsets);
    Inc(fappearsinsetstotal, numpieces);
    if fsets.IndexOf(aset) < 0 then
      fsets.Add(aset);
    if numpieces > fsetmostnum then
    begin
      fsetmost := aset;
      fsetmostnum := numpieces;
    end;
  end;
end;

function TPieceColorInfo.Check: boolean;
const
  MAXPRICE = 250000.00;

begin
  result := true;

  if between(fpriceguide.nTimesSold, 0, MaxInt) and
     between(fpriceguide.nTotalQty, 0, MaxInt) and
     (fpriceguide.nTimesSold <= fpriceguide.nTotalQty) and
     between(fpriceguide.nMinPrice, 0, MAXPRICE) and
     between(fpriceguide.nAvgPrice, 0, MAXPRICE) and
     between(fpriceguide.nQtyAvgPrice, 0, MAXPRICE) and
     between(fpriceguide.nMaxPrice, 0, MAXPRICE) and
     (fpriceguide.nMaxPrice >= fpriceguide.nQtyAvgPrice) and
     (fpriceguide.nMaxPrice >= fpriceguide.nAvgPrice) and
     (fpriceguide.nMaxPrice >= fpriceguide.nMinPrice) and
     (fpriceguide.nMinPrice <= fpriceguide.nQtyAvgPrice) and
     (fpriceguide.nMinPrice <= fpriceguide.nAvgPrice) then
  else
  begin
    fpriceguide.nTimesSold := 0;
    fpriceguide.nTotalQty := 0;
    fpriceguide.nMinPrice := 0;
    fpriceguide.nAvgPrice := 0;
    fpriceguide.nQtyAvgPrice := 0;
    fpriceguide.nMaxPrice := 0;
    fneedssave := true;
    result := false;
  end;

  if between(fpriceguide.uTimesSold, 0, MaxInt) and
     between(fpriceguide.uTotalQty, 0, MaxInt) and
     (fpriceguide.uTimesSold <= fpriceguide.uTotalQty) and
     between(fpriceguide.uMinPrice, 0, MAXPRICE) and
     between(fpriceguide.uAvgPrice, 0, MAXPRICE) and
     between(fpriceguide.uQtyAvgPrice, 0, MAXPRICE) and
     between(fpriceguide.uMaxPrice, 0, MAXPRICE) and
     (fpriceguide.uMaxPrice >= fpriceguide.uQtyAvgPrice) and
     (fpriceguide.uMaxPrice >= fpriceguide.uAvgPrice) and
     (fpriceguide.uMaxPrice >= fpriceguide.uMinPrice) and
     (fpriceguide.uMinPrice <= fpriceguide.uQtyAvgPrice) and
     (fpriceguide.uMinPrice <= fpriceguide.uAvgPrice) then
  else
  begin
    fpriceguide.uTimesSold := 0;
    fpriceguide.uTotalQty := 0;
    fpriceguide.uMinPrice := 0;
    fpriceguide.uAvgPrice := 0;
    fpriceguide.uQtyAvgPrice := 0;
    fpriceguide.uMaxPrice := 0;
    fneedssave := true;
    result := false;
  end;

  if between(favailability.nTotalLots, 0, MaxInt) and
     between(favailability.nTotalQty, 0, MaxInt) and
     (favailability.nTotalLots <= favailability.nTotalQty) and
     between(favailability.nMinPrice, 0, MAXPRICE) and
     between(favailability.nAvgPrice, 0, MAXPRICE) and
     between(favailability.nQtyAvgPrice, 0, MAXPRICE) and
     between(favailability.nMaxPrice, 0, MAXPRICE) and
     (favailability.nMaxPrice >= favailability.nQtyAvgPrice) and
     (favailability.nMaxPrice >= favailability.nAvgPrice) and
     (favailability.nMaxPrice >= favailability.nMinPrice) and
     (favailability.nMinPrice <= favailability.nQtyAvgPrice) and
     (favailability.nMinPrice <= favailability.nAvgPrice) then
  else
  begin
    favailability.nTotalLots := 0;
    favailability.nTotalQty := 0;
    favailability.nMinPrice := 0;
    favailability.nAvgPrice := 0;
    favailability.nQtyAvgPrice := 0;
    favailability.nMaxPrice := 0;
    fneedssave := true;
    result := false;
  end;

  if between(favailability.uTotalLots, 0, MaxInt) and
     between(favailability.uTotalQty, 0, MaxInt) and
     (favailability.uTotalLots <= favailability.uTotalQty) and
     between(favailability.uMinPrice, 0, MAXPRICE) and
     between(favailability.uAvgPrice, 0, MAXPRICE) and
     between(favailability.uQtyAvgPrice, 0, MAXPRICE) and
     between(favailability.uMaxPrice, 0, MAXPRICE) and
     (favailability.uMaxPrice >= favailability.uQtyAvgPrice) and
     (favailability.uMaxPrice >= favailability.uAvgPrice) and
     (favailability.uMaxPrice >= favailability.uMinPrice) and
     (favailability.uMinPrice <= favailability.uQtyAvgPrice) and
     (favailability.uMinPrice <= favailability.uAvgPrice) then
  else
  begin
    favailability.uTotalLots := 0;
    favailability.uTotalQty := 0;
    favailability.uMinPrice := 0;
    favailability.uAvgPrice := 0;
    favailability.uQtyAvgPrice := 0;
    favailability.uMaxPrice := 0;
    fneedssave := true;
    result := false;
  end;

end;

procedure TPieceColorInfo.Assign(const pg: priceguide_t);
begin
  fpriceguide.nTimesSold := pg.nTimesSold;
  fpriceguide.nTotalQty := pg.nTotalQty;
  if pg.nMinPrice > 0 then
    fpriceguide.nMinPrice := pg.nMinPrice;
  if pg.nAvgPrice > 0 then
    fpriceguide.nAvgPrice := pg.nAvgPrice;
  if pg.nQtyAvgPrice > 0 then
    fpriceguide.nQtyAvgPrice := pg.nQtyAvgPrice;
  if pg.nMaxPrice > 0 then
    fpriceguide.nMaxPrice := pg.nMaxPrice;
  fpriceguide.uTimesSold := pg.uTimesSold;
  fpriceguide.uTotalQty := pg.uTotalQty;
  if pg.uMinPrice > 0 then
    fpriceguide.uMinPrice := pg.uMinPrice;
  if pg.uAvgPrice > 0 then
    fpriceguide.uAvgPrice := pg.uAvgPrice;
  if pg.uQtyAvgPrice > 0 then
    fpriceguide.uQtyAvgPrice := pg.uQtyAvgPrice;
  if pg.uMaxPrice > 0 then
    fpriceguide.uMaxPrice := pg.uMaxPrice;
  fneedssave := true;
  fhasloaded := true;
end;

procedure TPieceColorInfo.Assign(const av: availability_t);
begin
  favailability.nTotalLots := av.nTotalLots;
  favailability.nTotalQty := av.nTotalQty;
  if av.nMinPrice > 0 then
    favailability.nMinPrice := av.nMinPrice;
  if av.nAvgPrice > 0 then
    favailability.nAvgPrice := av.nAvgPrice;
  if av.nQtyAvgPrice > 0 then
    favailability.nQtyAvgPrice := av.nQtyAvgPrice;
  if av.nMaxPrice > 0 then
    favailability.nMaxPrice := av.nMaxPrice;
  favailability.uTotalLots := av.uTotalLots;
  favailability.uTotalQty := av.uTotalQty;
  if av.uMinPrice > 0 then
    favailability.uMinPrice := av.uMinPrice;
  if av.uAvgPrice > 0 then
    favailability.uAvgPrice := av.uAvgPrice;
  if av.uQtyAvgPrice > 0 then
    favailability.uQtyAvgPrice := av.uQtyAvgPrice;
  if av.uMaxPrice > 0 then
    favailability.uMaxPrice := av.uMaxPrice;
  fneedssave := true;
  fhasloaded := true;
end;

function TPieceColorInfo.EvaluatePriceNew: double;
begin
  if not fhasloaded then
    Load;
  if fpriceguide.nTimesSold > 0 then              
    Result := fpriceguide.nQtyAvgPrice
  else if fpriceguide.uTimesSold > 0 then
    Result := fpriceguide.uQtyAvgPrice * 1.20
  else if favailability.nTotalLots > 0 then
    Result := favailability.nQtyAvgPrice
  else  if favailability.uTotalLots > 0 then
    Result := favailability.uQtyAvgPrice * 1.20
  else
    Result := 0;
end;

function TPieceColorInfo.EvaluatePriceUsed: double;
begin
  if not fhasloaded then
    Load;
  if fpriceguide.uTimesSold > 0 then
    Result := fpriceguide.uQtyAvgPrice
  else if fpriceguide.nTimesSold > 0 then
    Result := fpriceguide.nQtyAvgPrice / 1.20
  else if favailability.uTotalLots > 0 then
    Result := favailability.uQtyAvgPrice
  else  if favailability.nTotalLots > 0 then
    Result := favailability.nQtyAvgPrice / 1.20
  else
    Result := 0;
end;

function TPieceColorInfo.dbExportString: string;
begin
  if not fhasloaded then
    Load;

  result :=
    Format('%s;%d;%s;%d;%d;%d;%2.5f;%2.5f;%2.5f;%2.5f;%d;%d;%2.5f;%2.5f;%2.5f;%2.5f'+
           ';%d;%d;%2.5f;%2.5f;%2.5f;%2.5f;%d;%d;%2.5f;%2.5f;%2.5f;%2.5f;%2.5f;%2.5f', [
        fpiece,
        fcolor,
        db.BrickLinkPart(fpiece),
        db.Colors(fcolor).BrickLinkColor,
        fpriceguide.nTimesSold,
        fpriceguide.nTotalQty,
        fpriceguide.nMinPrice,
        fpriceguide.nAvgPrice,
        fpriceguide.nQtyAvgPrice,
        fpriceguide.nMaxPrice,
        fpriceguide.uTimesSold,
        fpriceguide.uTotalQty,
        fpriceguide.uMinPrice,
        fpriceguide.uAvgPrice,
        fpriceguide.uQtyAvgPrice,
        fpriceguide.uMaxPrice,
        favailability.nTotalLots,
        favailability.nTotalQty,
        favailability.nMinPrice,
        favailability.nAvgPrice,
        favailability.nQtyAvgPrice,
        favailability.nMaxPrice,
        favailability.uTotalLots,
        favailability.uTotalQty,
        favailability.uMinPrice,
        favailability.uAvgPrice,
        favailability.uQtyAvgPrice,
        favailability.uMaxPrice,
        EvaluatePriceNew,
        EvaluatePriceUsed
      ]);
end;

function F_nDemand(const favailability: availability_t; const fpriceguide: priceguide_t): double;
begin
  if favailability.nTotalQty = 0 then
  begin
    result := fpriceguide.nTotalQty + 1.0;
    if result > 10.0 then
      result := 10.0;
    exit;
  end;

  result := fpriceguide.nTotalQty / favailability.nTotalQty;
  if result > 3.0 then
    result := 3.0;
end;

function TPieceColorInfo.nDemand: double;
begin
  if not fhasloaded then
    Load;

  result := F_nDemand(favailability, fpriceguide);
end;

function F_uDemand(const favailability: availability_t; const fpriceguide: priceguide_t): double;
begin
  if favailability.uTotalQty = 0 then
  begin
    result := fpriceguide.uTotalQty + 1.0;
    if result > 10.0 then
      result := 10.0;
    exit;
  end;

  result := fpriceguide.uTotalQty / favailability.uTotalQty;
  if result > 3.0 then
    result := 3.0;
end;

function TPieceColorInfo.uDemand: double;
begin
  if not fhasloaded then
    Load;

  result := F_uDemand(favailability, fpriceguide);
end;

function TPieceColorInfo.ItemType: string;
begin
  if Pos('-', fpiece) > 0 then
    result := 'S'
  else if fcolor = -1 then
    result := 'M'
  else
    result := 'P';
end;

function TSetsDatabase.SaveSetInformationToDisk: boolean;
var
  desc,set_id,csvline: string;
  year,idx: integer;
  ismoc: boolean;
  str1,str2: TStringList;
begin
   result:= false;
   if not Assigned(fsets) then exit;

   csvline:= 'set_id,descr,year';
   str1:= TStringList.Create;
   str2:= TStringList.Create;
   str1.Add(csvline);
   str2.Add(csvline);

   try
     str1.BeginUpdate; str2.BeginUpdate;
     printf('Save extra information of sets to disk...');
     for idx:=0 to fsets.Count -1 do begin
       set_id:= fsets.Strings[idx];
       desc:= (fsets.Objects[idx] as TSetExtraInfo).Text;
       year:= (fsets.Objects[idx] as TSetExtraInfo).year;
       ismoc:= (fsets.Objects[idx] as TSetExtraInfo).moc;

       csvline:= Format('%s,%s,%d',[set_id,desc,year]);
       if ismoc then str2.Add(csvline) else str1.Add(csvline);

     end;
     str1.EndUpdate; str2.EndUpdate;
     str1.SaveToFile(basedefault +'db\db_sets.txt');
     str2.SaveToFile(basedefault +'db\db_mocs.txt');
   finally;
     printf(#9'Done.');
     str1.Free;
     str2.Free;
    end;
end;

function TSetsDatabase.LoadFromDisk(const fname: string): boolean;
var
  s: TStringList;
  kp: THashStringList;
  i, j, tot: integer;
  sset, snum, spiece, scolor, stype: string[255];
  npieces: integer;
  cc: integer;
  pci: TPieceColorInfo;
  idx: integer;
  k, len: integer;
  ss: string;
  prosets: TStringList;
  lastignoredset: string;
  sout: TStringList;
begin
  AllowInternetAccess := false;
  fcurrencies := TCurrency.Create(basedefault + 'db\db_currency.txt');

  InitSetReferences;

  s := TStringList.Create;
  s.LoadFromFile(fname);
  if s.Count = 0 then
  begin
    s.Free;
    Result := false;
    AllowInternetAccess := true;
    exit;
  end;

  if s.Strings[0] <> 'set_id,piece_id,num,color,type' then
  begin
    s.Free;
    Result := false;
    AllowInternetAccess := true;
    exit;
  end;

  sout := TStringList.Create;
  sout.Add('set_id,piece_id,num,color,type');

  if Assigned(progressfunc) then
    progressfunc('Loading database...', 0.0);

  prosets := TStringList.Create;
  prosets.AddStrings(fallsets);
  prosets.Sorted := true;
  lastignoredset := '';

  s.Delete(0);
  s.Sort;
  for i := 0 to s.Count - 1 do
  begin
    if i mod 2000 = 0 then
      if Assigned(progressfunc) then
        progressfunc('Loading database...', i / s.Count);
      ss := s.strings[i];
      len := Length(ss);
      sset := '';

      k := 0;

      while k < len do
      begin
        Inc(k);
        if ss[k] <> ',' then
          sset := sset + ss[k]
        else
          Break;
      end;

      if sset = lastignoredset then
        Continue;

      if prosets.IndexOf(sset) >= 0 then
      begin
        lastignoredset := sset;
        Continue;
      end;

      sout.Add(ss);

      spiece := '';
      snum := '';
      scolor := '';
      stype := '';

      while k < len do
      begin
        Inc(k);
        if ss[k] <> ',' then
          spiece := spiece + ss[k]
        else
          Break;
      end;
      spiece := RebrickablePart(spiece);


      while k < len do
      begin
        Inc(k);
        if ss[k] <> ',' then
          snum := snum + ss[k]
        else
          Break;
      end;

      while k < len do
      begin
        Inc(k);
        if ss[k] <> ',' then
          scolor := scolor + ss[k]
        else
          Break;
      end;

      while k < len do
      begin
        Inc(k);
        if ss[k] <> ',' then
          stype := stype + ss[k]
        else
          Break;
      end;


    cc := StrToIntDef(scolor, 0);
    npieces := StrToIntDef(snum, 0);
    AddSetPiece(sset, spiece, stype, cc, npieces);
    if (cc >= -1) and (cc <= MAXINFOCOLOR) then
    begin
      idx := fcolors[cc].knownpieces.Indexof(spiece);
      if idx < 0 then
      begin
        pci := TPieceColorInfo.Create(spiece, cc);
        fcolors[cc].knownpieces.AddObject(spiece, pci);
      end
      else
        pci := fcolors[cc].knownpieces.Objects[idx] as TPieceColorInfo;
      pci.AddSetReference(sset, npieces);
    end;
  end;

  if sout.Count <> s.Count + 1 then
  begin
    backupfile(fname);
    sout.SaveToFile(fname);
  end;
  sout.Free;
  for i := -1 to MAXINFOCOLOR do
  begin
    kp := fcolors[i].knownpieces;
    if kp <> nil then
    begin
      scolor := IntToStr(i) + ',';
      for j := 0 to kp.Count - 1 do
        fcolorpieces.AddObject(scolor + kp.Strings[j], kp.Objects[j]);
    end;
  end;

  prosets.Free;

  fcolorpieces.Sorted := True;
  if FileExists(basedefault + 'cache\' + fcrawlerfilename) then
    fcrawlerpriority.LoadFromFile(basedefault + 'cache\' + fcrawlerfilename)
  else
    fcrawlerpriority.AddStrings(fcolorpieces);

  if Assigned(progressfunc) then
    progressfunc('Loading database...', 1.0);


  tot := 0;
  for i := -1 to MAXINFOCOLOR do
    if fcolors[i].id = i then
      Inc(tot);

  k := 0;
  for i := -1 to MAXINFOCOLOR do
    if fcolors[i].id = i then
    begin
      inc(k);
      if Assigned(progressfunc) then
        progressfunc('Loading cache...', k / tot);
      kp := fcolors[i].knownpieces;
      if kp <> nil then
        for j := 0 to kp.Count - 1 do
          (kp.Objects[j] as TPieceColorInfo).Load;
    end;

  LoadStorage;

  result := True;
  AllowInternetAccess := true;
  floaded := True;
end;

var
  cacheidx: Integer = -1;
  cacheidx2: Integer = -1;

procedure TSetsDatabase.AddSetPiece(
  const setid: string; const part: string; const typ: string; color: integer; num: integer);
var
  idx: integer;
  inv: TBrickInventory;
begin
  if (cacheidx >= 0) and (cacheidx < fallsets.Count) and (fallsets.Strings[cacheidx] = setid) then
    inv := fallsets.Objects[cacheidx] as TBrickInventory
  else
  begin
    idx := fallsets.IndexOf(setid);
    if idx < 0 then
    begin
      inv := TBrickInventory.Create;
      idx := fallsets.AddObject(setid, inv);
    end
    else
      inv := fallsets.Objects[idx] as TBrickInventory;
    cacheidx := idx;
  end;
  if fcolors[color].knownpieces = nil then
    fcolors[color].knownpieces := THashStringList.Create;
  inv.AddLoosePartFast(part, color, num);

  if typ <> '1' then
    exit;

  if (cacheidx2 >= 0) and (cacheidx2 < fallsetswithoutextra.Count) and (fallsetswithoutextra.Strings[cacheidx2] = setid) then
    inv := fallsetswithoutextra.Objects[cacheidx2] as TBrickInventory
  else
  begin
    idx := fallsetswithoutextra.IndexOf(setid);
    if idx < 0 then
    begin
      inv := TBrickInventory.Create;
      idx := fallsetswithoutextra.AddObject(setid, inv);
    end
    else
      inv := fallsetswithoutextra.Objects[idx] as TBrickInventory;
    cacheidx2 := idx;
  end;
  inv.AddLoosePartFast(part, color, num);
end;

function TSetsDatabase.GetSetInventory(const setid: string): TBrickInventory;
var
  idx: integer;
begin
  idx := fallsets.IndexOf(setid);
  if idx < 0 then
  begin
    if FileExists(basedefault + 'db\sets\' + setid + '.txt') then
    begin
      idx := fallsets.Add(setid);
      fallsets.Objects[idx] := TBrickInventory.Create;
      (fallsets.Objects[idx] as TBrickInventory).LoadLooseParts(basedefault + 'db\sets\' + setid + '.txt');
      Result := (fallsets.Objects[idx] as TBrickInventory);
    end
    else if FileExists(basedefault + 'mosaic\' + setid + '.txt') then
    begin
      idx := fallsets.Add(setid);
      fallsets.Objects[idx] := TBrickInventory.Create;
      (fallsets.Objects[idx] as TBrickInventory).LoadLooseParts(basedefault + 'mosaic\' + setid + '.txt');
      Result := (fallsets.Objects[idx] as TBrickInventory);
    end
    else if FileExists(basedefault + 'out\' + setid + '\' + setid + '.txt') then
    begin
      idx := fallsets.Add(setid);
      fallsets.Objects[idx] := TBrickInventory.Create;
      (fallsets.Objects[idx] as TBrickInventory).LoadLooseParts(basedefault + 'out\' + setid + '\' + setid + '.txt');
      Result := (fallsets.Objects[idx] as TBrickInventory);
    end
    else
      Result := nil;
    exit;
  end
  else if Pos('mosaic_', setid) = 1 then
  begin
    if FileExists(basedefault + 'mosaic\' + setid + '.txt') then
    begin
      (fallsets.Objects[idx] as TBrickInventory).Clear;
      (fallsets.Objects[idx] as TBrickInventory).LoadLooseParts(basedefault + 'mosaic\' + setid + '.txt');
      Result := (fallsets.Objects[idx] as TBrickInventory);
      exit;
    end;
  end;

  Result := fallsets.Objects[idx] as TBrickInventory;
end;

function TSetsDatabase.GetSetInventoryWithOutExtra(const setid: string): TBrickInventory;
var
  idx: integer;
begin
  idx := fallsetswithoutextra.IndexOf(setid);
  if idx < 0 then
  begin
    if FileExists(basedefault + 'db\sets\' + setid + '.txt') then
    begin
      idx := fallsetswithoutextra.Add(setid);
      fallsetswithoutextra.Objects[idx] := TBrickInventory.Create;
      (fallsetswithoutextra.Objects[idx] as TBrickInventory).LoadLooseParts(basedefault + 'db\sets\' + setid + '.txt');
      Result := (fallsetswithoutextra.Objects[idx] as TBrickInventory);
    end
    else
      Result := nil;
    exit;
  end;
  Result := fallsetswithoutextra.Objects[idx] as TBrickInventory;
end;

procedure TSetsDatabase.ReloadCache;
var
  i, j: integer;
  k, mx: integer;
begin
 if assigned(progressfunc) then
   progressfunc('Reloading cache...', 0.0);

  mx := 0;
  for i := -1 to MAXINFOCOLOR do
    if fcolors[i].id = i then
      inc(mx);

  st_pciloads := 0;
  st_pciloadscache := 0;
  fCacheDB.Free;
  fCacheDB := TCacheDB.Create(basedefault + 'cache\cache.db');
  k := 0;
  for i := -1 to MAXINFOCOLOR do
  begin
    if fcolors[i].id = i then
    begin
      inc(k);
      if assigned(progressfunc) then
        progressfunc('Reloading cache...', k / mx);
      if fcolors[i].knownpieces <> nil then
        for j := 0 to fcolors[i].knownpieces.Count - 1 do
          (fcolors[i].knownpieces.Objects[j] as TPieceColorInfo).Load;
    end;
  end;

 if assigned(progressfunc) then
   progressfunc('Reloading cache...', 1.0);

end;

procedure TSetsDatabase.GetCacheHashEfficiency(var hits, total: integer);
var
  i, j: integer;
  k, mx: integer;
  pci: TPieceColorInfo;
  A: array[0..CACHEDBHASHSIZE - 1] of integer;
begin
 if assigned(progressfunc) then
   progressfunc('Calculating...', 0.0);

  ZeroMemory(@A, SizeOf(A));
  hits := 0;
  total := 0;

  mx := 0;
  for i := -1 to MAXINFOCOLOR do
    if fcolors[i].id = i then
      inc(mx);

  if mx > 0 then
  begin
    k := 0;
    for i := -1 to MAXINFOCOLOR do
    begin
      if fcolors[i].id = i then
      begin
        inc(k);
        if assigned(progressfunc) then
          progressfunc('Calculating...', k / mx);
        if fcolors[i].knownpieces <> nil then
          for j := 0 to fcolors[i].knownpieces.Count - 1 do
          begin
            pci := fcolors[i].knownpieces.Objects[j] as TPieceColorInfo;
            inc(A[MkPCIHash(pci.piece, pci.color)]);
            inc(total);
          end;
      end;
    end;
  end;

  for i := 0 to CACHEDBHASHSIZE - 1 do
    if A[i] > 0 then
      inc(hits);

 if assigned(progressfunc) then
   progressfunc('Calculating...', 1.0);
end;


function PieceColorCacheDir(const piece, color: string): string;
begin
  if color = '-1' then
    result := basedefault + 'cache\9999\'
  else
    result := basedefault + 'cache\' + color + '\' ;
end;

function PieceColorCacheFName(const piece, color: string): string;
begin
  result := PieceColorCacheDir(piece, color) +  piece + '.cache';
end;

initialization
  basedefault := ParamStr(0);
  if Pos('\', basedefault) > 0 then
  begin
    while basedefault[Length(basedefault)] <> '\' do
      SetLength(basedefault, Length(basedefault) - 1);
  end
  else
    basedefault := '';

end.

