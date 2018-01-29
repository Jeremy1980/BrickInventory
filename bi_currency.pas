unit bi_currency;

interface

uses
  SysUtils, Classes;

type
  TCurrency = class(TObject)
  private
    currencies: TStringList;
  public
    constructor Create(const afile: string); virtual;
    destructor Destroy; override;
    function Convert(const cur: string): double;
  end;

implementation

uses
  bi_delphi, bi_utils;

constructor TCurrency.Create(const afile: string);
var
  s: TStringList;
  i: integer;
  s1, s2: string;
begin
  currencies := TStringList.Create;
  currencies.Sorted := True;
  s := TStringList.Create;
  s.LoadFromFile(afile);
  if s.Count > 0 then
    if s.Strings[0] = 'currency,euro' then
      for i := 1 to s.Count - 1 do
      begin
        splitstringex(s.Strings[i], s1, s2, ',');
        currencies.AddObject(s1, TDouble.Create(atof(s2, 1.0)));
      end;
  Inherited Create;
end;

destructor TCurrency.Destroy;
begin
  FreeList(currencies);
  Inherited;
end;

function TCurrency.Convert(const cur: string): double;
var
  idx: integer;
begin
  idx := currencies.IndexOf(cur);
  if idx < 0 then
    Result := 1.0
  else
    Result := (currencies.Objects[idx] as TDouble).value;
end;

end.
