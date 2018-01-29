unit bi_priceadjust;

interface

uses
  bi_db, bi_delphi, DateUtils;

procedure PRICEADJUST(const part: string; const color: integer; var pg: priceguide_t; var av: availability_t; const t: TDateTime); overload;

procedure PRICEADJUST(const part: string; const color: integer; const A: parecdate_p); overload;

implementation

procedure PRICEADJUST(const part: string; const color: integer; var pg: priceguide_t; var av: availability_t; const t: TDateTime); overload;
begin
  if color = 334 then
    if part = '3001' then
      if between(pg.uMaxPrice, 9999, 10000) then
      begin
        if pg.uTotalQty > 1 then
        begin
          pg.uQtyAvgPrice := (pg.uTotalQty * pg.uQtyAvgPrice - 9999.99) / (pg.uTotalQty - 1);
          pg.uTotalQty := pg.uTotalQty - 1;
        end
        else
          pg.uQtyAvgPrice := pg.nQtyAvgPrice * 0.8;
        pg.uAvgPrice := pg.uQtyAvgPrice;
      end;
end;

procedure PRICEADJUST(const part: string; const color: integer; const A: parecdate_p); overload;
begin
  PRICEADJUST(part, color, A.priceguide, A.availability, A.date);
end;

end.
