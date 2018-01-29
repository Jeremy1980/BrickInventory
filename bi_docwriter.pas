unit bi_docwriter;

interface

uses
  Classes, Htmlview;

type
  TDocument = class(TObject)
  private
    buffer: string;
    capacity: integer;
    size: integer;
    hview: THTMLViewer;
  public
    constructor Create(const aview: THTMLViewer);
    destructor Destroy; override;
    procedure write(const i: integer); overload;
    procedure write(const s: string); overload;
    procedure write(const Fmt: string; const Args: array of const); overload;
    procedure BlancColorCell(const RGB: LongWord; const width: integer);
    procedure Flash;
  end;

implementation

uses
  SysUtils;

constructor TDocument.Create(const aview: THTMLViewer);
begin
  inherited Create;
  hview := aview;
  buffer := '';
  capacity := 0;
  size := 0;
end;

destructor TDocument.Destroy;
begin
  Inherited;
end;

procedure TDocument.write(const i: integer);
begin
  write(IntToStr(i));
end;

procedure TDocument.write(const s: string);
var
  i, l1: integer;
begin
  l1 := Length(s);
  if  capacity < l1 + size then
  begin
    capacity := (l1 + size + 2048) and not 1023;
    SetLength(buffer, capacity);
  end;
  for i := 1 to l1 do
    buffer[i + size] := s[i];
  size := size + l1;
end;

procedure TDocument.write(const Fmt: string; const Args: array of const);
var
  stmp: string;
begin
  FmtStr(stmp, Fmt, Args);
  write(stmp);
end;

procedure TDocument.BlancColorCell(const RGB: LongWord; const width: integer);
var
  hx: string;
  stmp: string;
begin
  hx := IntToHex(RGB, 6);
  stmp := '<table border=1 width=' + IntToStr(width) + ' bgcolor="#' + hx + '"><tr><td><br></td></tr></table>';
  write(stmp);
end;

procedure TDocument.Flash;
begin
  SetLength(buffer, size);
  hview.LoadFromString(buffer);
  buffer := '';
  size := 0;
  capacity := 0;
end;

end.
