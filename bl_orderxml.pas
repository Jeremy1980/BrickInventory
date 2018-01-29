
{*******************************************************************************************}
{                                                                                           }
{                                     XML Data Binding                                      }
{                                                                                           }
{         Generated on: 4/24/2014 3:30:16 PM                                                }
{       Generated from: G:\PROGRAMMING\BrickInventory\bin\orders\bl_orderxml_20140424.xml   }
{   Settings stored in: G:\PROGRAMMING\BrickInventory\bin\orders\bl_orderxml_20140424.xdb   }
{                                                                                           }
{*******************************************************************************************}

unit bl_orderxml;

interface

uses xmldom, XMLDoc, XMLIntf;

type

{ Forward Decls }

  IXMLORDERSType = interface;
  IXMLORDERType = interface;
  IXMLITEMType = interface;
  IXMLITEMTypeList = interface;

{ IXMLORDERSType }

  IXMLORDERSType = interface(IXMLNodeCollection)
    ['{869D6A30-5DB3-44C9-821D-F73F1FCE1331}']
    { Property Accessors }
    function Get_ORDER(Index: Integer): IXMLORDERType;
    { Methods & Properties }
    function Add: IXMLORDERType;
    function Insert(const Index: Integer): IXMLORDERType;
    property ORDER[Index: Integer]: IXMLORDERType read Get_ORDER; default;
  end;

{ IXMLORDERType }

  IXMLORDERType = interface(IXMLNode)
    ['{320DB0B1-DF11-4FF2-A072-046501A92D67}']
    { Property Accessors }
    function Get_ORDERID: Integer;
    function Get_ORDERDATE: WideString;
    function Get_ORDERSTATUSCHANGED: WideString;
    function Get_SELLER: WideString;
    function Get_ORDERSHIPPING: WideString;
    function Get_ORDERINSURANCE: WideString;
    function Get_ORDERADDCHRG1: WideString;
    function Get_ORDERADDCHRG2: WideString;
    function Get_ORDERCREDIT: WideString;
    function Get_ORDERCREDITCOUPON: WideString;
    function Get_ORDERTOTAL: WideString;
    function Get_BASECURRENCYCODE: WideString;
    function Get_BASEGRANDTOTAL: WideString;
    function Get_PAYCURRENCYCODE: WideString;
    function Get_ORDERLOTS: Integer;
    function Get_ORDERITEMS: Integer;
    function Get_ORDERSTATUS: WideString;
    function Get_PAYMENTTYPE: WideString;
    function Get_ORDERTRACKNO: WideString;
    function Get_LOCATION: WideString;
    function Get_ITEM: IXMLITEMTypeList;
    procedure Set_ORDERID(Value: Integer);
    procedure Set_ORDERDATE(Value: WideString);
    procedure Set_ORDERSTATUSCHANGED(Value: WideString);
    procedure Set_SELLER(Value: WideString);
    procedure Set_ORDERSHIPPING(Value: WideString);
    procedure Set_ORDERINSURANCE(Value: WideString);
    procedure Set_ORDERADDCHRG1(Value: WideString);
    procedure Set_ORDERADDCHRG2(Value: WideString);
    procedure Set_ORDERCREDIT(Value: WideString);
    procedure Set_ORDERCREDITCOUPON(Value: WideString);
    procedure Set_ORDERTOTAL(Value: WideString);
    procedure Set_BASECURRENCYCODE(Value: WideString);
    procedure Set_BASEGRANDTOTAL(Value: WideString);
    procedure Set_PAYCURRENCYCODE(Value: WideString);
    procedure Set_ORDERLOTS(Value: Integer);
    procedure Set_ORDERITEMS(Value: Integer);
    procedure Set_ORDERSTATUS(Value: WideString);
    procedure Set_PAYMENTTYPE(Value: WideString);
    procedure Set_ORDERTRACKNO(Value: WideString);
    procedure Set_LOCATION(Value: WideString);
    { Methods & Properties }
    property ORDERID: Integer read Get_ORDERID write Set_ORDERID;
    property ORDERDATE: WideString read Get_ORDERDATE write Set_ORDERDATE;
    property ORDERSTATUSCHANGED: WideString read Get_ORDERSTATUSCHANGED write Set_ORDERSTATUSCHANGED;
    property SELLER: WideString read Get_SELLER write Set_SELLER;
    property ORDERSHIPPING: WideString read Get_ORDERSHIPPING write Set_ORDERSHIPPING;
    property ORDERINSURANCE: WideString read Get_ORDERINSURANCE write Set_ORDERINSURANCE;
    property ORDERADDCHRG1: WideString read Get_ORDERADDCHRG1 write Set_ORDERADDCHRG1;
    property ORDERADDCHRG2: WideString read Get_ORDERADDCHRG2 write Set_ORDERADDCHRG2;
    property ORDERCREDIT: WideString read Get_ORDERCREDIT write Set_ORDERCREDIT;
    property ORDERCREDITCOUPON: WideString read Get_ORDERCREDITCOUPON write Set_ORDERCREDITCOUPON;
    property ORDERTOTAL: WideString read Get_ORDERTOTAL write Set_ORDERTOTAL;
    property BASECURRENCYCODE: WideString read Get_BASECURRENCYCODE write Set_BASECURRENCYCODE;
    property BASEGRANDTOTAL: WideString read Get_BASEGRANDTOTAL write Set_BASEGRANDTOTAL;
    property PAYCURRENCYCODE: WideString read Get_PAYCURRENCYCODE write Set_PAYCURRENCYCODE;
    property ORDERLOTS: Integer read Get_ORDERLOTS write Set_ORDERLOTS;
    property ORDERITEMS: Integer read Get_ORDERITEMS write Set_ORDERITEMS;
    property ORDERSTATUS: WideString read Get_ORDERSTATUS write Set_ORDERSTATUS;
    property PAYMENTTYPE: WideString read Get_PAYMENTTYPE write Set_PAYMENTTYPE;
    property ORDERTRACKNO: WideString read Get_ORDERTRACKNO write Set_ORDERTRACKNO;
    property LOCATION: WideString read Get_LOCATION write Set_LOCATION;
    property ITEM: IXMLITEMTypeList read Get_ITEM;
  end;

{ IXMLITEMType }

  IXMLITEMType = interface(IXMLNode)
    ['{47654B73-8A80-4EC0-B2D4-208E254073B5}']
    { Property Accessors }
    function Get_ORDERITEMID: Integer;
    function Get_ORDERBATCH: Integer;
    function Get_CATEGORY: WideString;
    function Get_COLOR: Integer;
    function Get_PRICE: WideString;
    function Get_QTY: Integer;
    function Get_BULK: Integer;
    function Get_IMAGE: WideString;
    function Get_DESCRIPTION: WideString;
    function Get_CONDITION: WideString;
    function Get_ITEMTYPE: WideString;
    function Get_ITEMID: WideString;
    function Get_SALE: WideString;
    function Get_WEIGHT: WideString;
    function Get_LOTID: Integer;
    function Get_TQ1: WideString;
    function Get_TP1: WideString;
    function Get_TQ2: WideString;
    function Get_TP2: WideString;
    function Get_TQ3: WideString;
    function Get_TP3: WideString;
    function Get_SUBCONDITION: WideString;
    procedure Set_ORDERITEMID(Value: Integer);
    procedure Set_ORDERBATCH(Value: Integer);
    procedure Set_CATEGORY(Value: WideString);
    procedure Set_COLOR(Value: Integer);
    procedure Set_PRICE(Value: WideString);
    procedure Set_QTY(Value: Integer);
    procedure Set_BULK(Value: Integer);
    procedure Set_IMAGE(Value: WideString);
    procedure Set_DESCRIPTION(Value: WideString);
    procedure Set_CONDITION(Value: WideString);
    procedure Set_ITEMTYPE(Value: WideString);
    procedure Set_ITEMID(Value: WideString);
    procedure Set_SALE(Value: WideString);
    procedure Set_WEIGHT(Value: WideString);
    procedure Set_LOTID(Value: Integer);
    procedure Set_TQ1(Value: WideString);
    procedure Set_TP1(Value: WideString);
    procedure Set_TQ2(Value: WideString);
    procedure Set_TP2(Value: WideString);
    procedure Set_TQ3(Value: WideString);
    procedure Set_TP3(Value: WideString);
    procedure Set_SUBCONDITION(Value: WideString);
    { Methods & Properties }
    property ORDERITEMID: Integer read Get_ORDERITEMID write Set_ORDERITEMID;
    property ORDERBATCH: Integer read Get_ORDERBATCH write Set_ORDERBATCH;
    property CATEGORY: WideString read Get_CATEGORY write Set_CATEGORY;
    property COLOR: Integer read Get_COLOR write Set_COLOR;
    property PRICE: WideString read Get_PRICE write Set_PRICE;
    property QTY: Integer read Get_QTY write Set_QTY;
    property BULK: Integer read Get_BULK write Set_BULK;
    property IMAGE: WideString read Get_IMAGE write Set_IMAGE;
    property DESCRIPTION: WideString read Get_DESCRIPTION write Set_DESCRIPTION;
    property CONDITION: WideString read Get_CONDITION write Set_CONDITION;
    property ITEMTYPE: WideString read Get_ITEMTYPE write Set_ITEMTYPE;
    property ITEMID: WideString read Get_ITEMID write Set_ITEMID;
    property SALE: WideString read Get_SALE write Set_SALE;
    property WEIGHT: WideString read Get_WEIGHT write Set_WEIGHT;
    property LOTID: Integer read Get_LOTID write Set_LOTID;
    property TQ1: WideString read Get_TQ1 write Set_TQ1;
    property TP1: WideString read Get_TP1 write Set_TP1;
    property TQ2: WideString read Get_TQ2 write Set_TQ2;
    property TP2: WideString read Get_TP2 write Set_TP2;
    property TQ3: WideString read Get_TQ3 write Set_TQ3;
    property TP3: WideString read Get_TP3 write Set_TP3;
    property SUBCONDITION: WideString read Get_SUBCONDITION write Set_SUBCONDITION;
  end;

{ IXMLITEMTypeList }

  IXMLITEMTypeList = interface(IXMLNodeCollection)
    ['{9EBE2AB6-783D-43A4-942F-5A03C2C52B44}']
    { Methods & Properties }
    function Add: IXMLITEMType;
    function Insert(const Index: Integer): IXMLITEMType;
    function Get_Item(Index: Integer): IXMLITEMType;
    property Items[Index: Integer]: IXMLITEMType read Get_Item; default;
  end;

{ Forward Decls }

  TXMLORDERSType = class;
  TXMLORDERType = class;
  TXMLITEMType = class;
  TXMLITEMTypeList = class;

{ TXMLORDERSType }

  TXMLORDERSType = class(TXMLNodeCollection, IXMLORDERSType)
  protected
    { IXMLORDERSType }
    function Get_ORDER(Index: Integer): IXMLORDERType;
    function Add: IXMLORDERType;
    function Insert(const Index: Integer): IXMLORDERType;
  public
    procedure AfterConstruction; override;
  end;

{ TXMLORDERType }

  TXMLORDERType = class(TXMLNode, IXMLORDERType)
  private
    FITEM: IXMLITEMTypeList;
  protected
    { IXMLORDERType }
    function Get_ORDERID: Integer;
    function Get_ORDERDATE: WideString;
    function Get_ORDERSTATUSCHANGED: WideString;
    function Get_SELLER: WideString;
    function Get_ORDERSHIPPING: WideString;
    function Get_ORDERINSURANCE: WideString;
    function Get_ORDERADDCHRG1: WideString;
    function Get_ORDERADDCHRG2: WideString;
    function Get_ORDERCREDIT: WideString;
    function Get_ORDERCREDITCOUPON: WideString;
    function Get_ORDERTOTAL: WideString;
    function Get_BASECURRENCYCODE: WideString;
    function Get_BASEGRANDTOTAL: WideString;
    function Get_PAYCURRENCYCODE: WideString;
    function Get_ORDERLOTS: Integer;
    function Get_ORDERITEMS: Integer;
    function Get_ORDERSTATUS: WideString;
    function Get_PAYMENTTYPE: WideString;
    function Get_ORDERTRACKNO: WideString;
    function Get_LOCATION: WideString;
    function Get_ITEM: IXMLITEMTypeList;
    procedure Set_ORDERID(Value: Integer);
    procedure Set_ORDERDATE(Value: WideString);
    procedure Set_ORDERSTATUSCHANGED(Value: WideString);
    procedure Set_SELLER(Value: WideString);
    procedure Set_ORDERSHIPPING(Value: WideString);
    procedure Set_ORDERINSURANCE(Value: WideString);
    procedure Set_ORDERADDCHRG1(Value: WideString);
    procedure Set_ORDERADDCHRG2(Value: WideString);
    procedure Set_ORDERCREDIT(Value: WideString);
    procedure Set_ORDERCREDITCOUPON(Value: WideString);
    procedure Set_ORDERTOTAL(Value: WideString);
    procedure Set_BASECURRENCYCODE(Value: WideString);
    procedure Set_BASEGRANDTOTAL(Value: WideString);
    procedure Set_PAYCURRENCYCODE(Value: WideString);
    procedure Set_ORDERLOTS(Value: Integer);
    procedure Set_ORDERITEMS(Value: Integer);
    procedure Set_ORDERSTATUS(Value: WideString);
    procedure Set_PAYMENTTYPE(Value: WideString);
    procedure Set_ORDERTRACKNO(Value: WideString);
    procedure Set_LOCATION(Value: WideString);
  public
    procedure AfterConstruction; override;
  end;

{ TXMLITEMType }

  TXMLITEMType = class(TXMLNode, IXMLITEMType)
  protected
    { IXMLITEMType }
    function Get_ORDERITEMID: Integer;
    function Get_ORDERBATCH: Integer;
    function Get_CATEGORY: WideString;
    function Get_COLOR: Integer;
    function Get_PRICE: WideString;
    function Get_QTY: Integer;
    function Get_BULK: Integer;
    function Get_IMAGE: WideString;
    function Get_DESCRIPTION: WideString;
    function Get_CONDITION: WideString;
    function Get_ITEMTYPE: WideString;
    function Get_ITEMID: WideString;
    function Get_SALE: WideString;
    function Get_WEIGHT: WideString;
    function Get_LOTID: Integer;
    function Get_TQ1: WideString;
    function Get_TP1: WideString;
    function Get_TQ2: WideString;
    function Get_TP2: WideString;
    function Get_TQ3: WideString;
    function Get_TP3: WideString;
    function Get_SUBCONDITION: WideString;
    procedure Set_ORDERITEMID(Value: Integer);
    procedure Set_ORDERBATCH(Value: Integer);
    procedure Set_CATEGORY(Value: WideString);
    procedure Set_COLOR(Value: Integer);
    procedure Set_PRICE(Value: WideString);
    procedure Set_QTY(Value: Integer);
    procedure Set_BULK(Value: Integer);
    procedure Set_IMAGE(Value: WideString);
    procedure Set_DESCRIPTION(Value: WideString);
    procedure Set_CONDITION(Value: WideString);
    procedure Set_ITEMTYPE(Value: WideString);
    procedure Set_ITEMID(Value: WideString);
    procedure Set_SALE(Value: WideString);
    procedure Set_WEIGHT(Value: WideString);
    procedure Set_LOTID(Value: Integer);
    procedure Set_TQ1(Value: WideString);
    procedure Set_TP1(Value: WideString);
    procedure Set_TQ2(Value: WideString);
    procedure Set_TP2(Value: WideString);
    procedure Set_TQ3(Value: WideString);
    procedure Set_TP3(Value: WideString);
    procedure Set_SUBCONDITION(Value: WideString);
  end;

{ TXMLITEMTypeList }

  TXMLITEMTypeList = class(TXMLNodeCollection, IXMLITEMTypeList)
  protected
    { IXMLITEMTypeList }
    function Add: IXMLITEMType;
    function Insert(const Index: Integer): IXMLITEMType;
    function Get_Item(Index: Integer): IXMLITEMType;
  end;

{ Global Functions }

function GetORDERS(Doc: IXMLDocument): IXMLORDERSType;
function LoadORDERS(const FileName: WideString): IXMLORDERSType;
function NewORDERS: IXMLORDERSType;

const
  TargetNamespace = '';

implementation

uses
  bi_delphi;

{ Global Functions }

function GetORDERS(Doc: IXMLDocument): IXMLORDERSType;
begin
  Result := Doc.GetDocBinding('ORDERS', TXMLORDERSType, TargetNamespace) as IXMLORDERSType;
end;

function LoadORDERS(const FileName: WideString): IXMLORDERSType;
begin
  Result := LoadXMLDocument(FileName).GetDocBinding('ORDERS', TXMLORDERSType, TargetNamespace) as IXMLORDERSType;
end;

function NewORDERS: IXMLORDERSType;
begin
  Result := NewXMLDocument.GetDocBinding('ORDERS', TXMLORDERSType, TargetNamespace) as IXMLORDERSType;
end;

{ TXMLORDERSType }

procedure TXMLORDERSType.AfterConstruction;
begin
  RegisterChildNode('ORDER', TXMLORDERType);
  ItemTag := 'ORDER';
  ItemInterface := IXMLORDERType;
  inherited;
end;

function TXMLORDERSType.Get_ORDER(Index: Integer): IXMLORDERType;
begin
  Result := List[Index] as IXMLORDERType;
end;

function TXMLORDERSType.Add: IXMLORDERType;
begin
  Result := AddItem(-1) as IXMLORDERType;
end;

function TXMLORDERSType.Insert(const Index: Integer): IXMLORDERType;
begin
  Result := AddItem(Index) as IXMLORDERType;
end;

{ TXMLORDERType }

procedure TXMLORDERType.AfterConstruction;
begin
  RegisterChildNode('ITEM', TXMLITEMType);
  FITEM := CreateCollection(TXMLITEMTypeList, IXMLITEMType, 'ITEM') as IXMLITEMTypeList;
  inherited;
end;

function TXMLORDERType.Get_ORDERID: Integer;
begin
  Result := ChildNodes['ORDERID'].NodeValue;
end;

procedure TXMLORDERType.Set_ORDERID(Value: Integer);
begin
  ChildNodes['ORDERID'].NodeValue := Value;
end;

function TXMLORDERType.Get_ORDERDATE: WideString;
begin
  Result := ChildNodes['ORDERDATE'].Text;
end;

procedure TXMLORDERType.Set_ORDERDATE(Value: WideString);
begin
  ChildNodes['ORDERDATE'].NodeValue := Value;
end;

function TXMLORDERType.Get_ORDERSTATUSCHANGED: WideString;
begin
  Result := ChildNodes['ORDERSTATUSCHANGED'].Text;
end;

procedure TXMLORDERType.Set_ORDERSTATUSCHANGED(Value: WideString);
begin
  ChildNodes['ORDERSTATUSCHANGED'].NodeValue := Value;
end;

function TXMLORDERType.Get_SELLER: WideString;
begin
  Result := ChildNodes['SELLER'].Text;
end;

procedure TXMLORDERType.Set_SELLER(Value: WideString);
begin
  ChildNodes['SELLER'].NodeValue := Value;
end;

function TXMLORDERType.Get_ORDERSHIPPING: WideString;
begin
  Result := ChildNodes['ORDERSHIPPING'].Text;
end;

procedure TXMLORDERType.Set_ORDERSHIPPING(Value: WideString);
begin
  ChildNodes['ORDERSHIPPING'].NodeValue := Value;
end;

function TXMLORDERType.Get_ORDERINSURANCE: WideString;
begin
  Result := ChildNodes['ORDERINSURANCE'].Text;
end;

procedure TXMLORDERType.Set_ORDERINSURANCE(Value: WideString);
begin
  ChildNodes['ORDERINSURANCE'].NodeValue := Value;
end;

function TXMLORDERType.Get_ORDERADDCHRG1: WideString;
begin
  Result := ChildNodes['ORDERADDCHRG1'].Text;
end;

procedure TXMLORDERType.Set_ORDERADDCHRG1(Value: WideString);
begin
  ChildNodes['ORDERADDCHRG1'].NodeValue := Value;
end;

function TXMLORDERType.Get_ORDERADDCHRG2: WideString;
begin
  Result := ChildNodes['ORDERADDCHRG2'].Text;
end;

procedure TXMLORDERType.Set_ORDERADDCHRG2(Value: WideString);
begin
  ChildNodes['ORDERADDCHRG2'].NodeValue := Value;
end;

function TXMLORDERType.Get_ORDERCREDIT: WideString;
begin
  Result := ChildNodes['ORDERCREDIT'].Text;
end;

procedure TXMLORDERType.Set_ORDERCREDIT(Value: WideString);
begin
  ChildNodes['ORDERCREDIT'].NodeValue := Value;
end;

function TXMLORDERType.Get_ORDERCREDITCOUPON: WideString;
begin
  Result := ChildNodes['ORDERCREDITCOUPON'].Text;
end;

procedure TXMLORDERType.Set_ORDERCREDITCOUPON(Value: WideString);
begin
  ChildNodes['ORDERCREDITCOUPON'].NodeValue := Value;
end;

function TXMLORDERType.Get_ORDERTOTAL: WideString;
begin
  Result := ChildNodes['ORDERTOTAL'].Text;
end;

procedure TXMLORDERType.Set_ORDERTOTAL(Value: WideString);
begin
  ChildNodes['ORDERTOTAL'].NodeValue := Value;
end;

function TXMLORDERType.Get_BASECURRENCYCODE: WideString;
begin
  Result := ChildNodes['BASECURRENCYCODE'].Text;
end;

procedure TXMLORDERType.Set_BASECURRENCYCODE(Value: WideString);
begin
  ChildNodes['BASECURRENCYCODE'].NodeValue := Value;
end;

function TXMLORDERType.Get_BASEGRANDTOTAL: WideString;
begin
  Result := ChildNodes['BASEGRANDTOTAL'].Text;
end;

procedure TXMLORDERType.Set_BASEGRANDTOTAL(Value: WideString);
begin
  ChildNodes['BASEGRANDTOTAL'].NodeValue := Value;
end;

function TXMLORDERType.Get_PAYCURRENCYCODE: WideString;
begin
  Result := ChildNodes['PAYCURRENCYCODE'].Text;
end;

procedure TXMLORDERType.Set_PAYCURRENCYCODE(Value: WideString);
begin
  ChildNodes['PAYCURRENCYCODE'].NodeValue := Value;
end;

function TXMLORDERType.Get_ORDERLOTS: Integer;
begin
  Result := ChildNodes['ORDERLOTS'].NodeValue;
end;

procedure TXMLORDERType.Set_ORDERLOTS(Value: Integer);
begin
  ChildNodes['ORDERLOTS'].NodeValue := Value;
end;

function TXMLORDERType.Get_ORDERITEMS: Integer;
begin
  Result := ChildNodes['ORDERITEMS'].NodeValue;
end;

procedure TXMLORDERType.Set_ORDERITEMS(Value: Integer);
begin
  ChildNodes['ORDERITEMS'].NodeValue := Value;
end;

function TXMLORDERType.Get_ORDERSTATUS: WideString;
begin
  Result := ChildNodes['ORDERSTATUS'].Text;
end;

procedure TXMLORDERType.Set_ORDERSTATUS(Value: WideString);
begin
  ChildNodes['ORDERSTATUS'].NodeValue := Value;
end;

function TXMLORDERType.Get_PAYMENTTYPE: WideString;
begin
  Result := ChildNodes['PAYMENTTYPE'].Text;
end;

procedure TXMLORDERType.Set_PAYMENTTYPE(Value: WideString);
begin
  ChildNodes['PAYMENTTYPE'].NodeValue := Value;
end;

function TXMLORDERType.Get_ORDERTRACKNO: WideString;
begin
  Result := ChildNodes['ORDERTRACKNO'].Text;
end;

procedure TXMLORDERType.Set_ORDERTRACKNO(Value: WideString);
begin
  ChildNodes['ORDERTRACKNO'].NodeValue := Value;
end;

function TXMLORDERType.Get_LOCATION: WideString;
begin
  Result := ChildNodes['LOCATION'].Text;
end;

procedure TXMLORDERType.Set_LOCATION(Value: WideString);
begin
  ChildNodes['LOCATION'].NodeValue := Value;
end;

function TXMLORDERType.Get_ITEM: IXMLITEMTypeList;
begin
  Result := FITEM;
end;

{ TXMLITEMType }

function TXMLITEMType.Get_ORDERITEMID: Integer;
begin
  Result := ChildNodes['ORDERITEMID'].NodeValue;
end;

procedure TXMLITEMType.Set_ORDERITEMID(Value: Integer);
begin
  ChildNodes['ORDERITEMID'].NodeValue := Value;
end;

function TXMLITEMType.Get_ORDERBATCH: Integer;
begin
  Result := ChildNodes['ORDERBATCH'].NodeValue;
end;

procedure TXMLITEMType.Set_ORDERBATCH(Value: Integer);
begin
  ChildNodes['ORDERBATCH'].NodeValue := Value;
end;

function TXMLITEMType.Get_CATEGORY: WideString;
begin
  Result := ChildNodes['CATEGORY'].Text;
end;

procedure TXMLITEMType.Set_CATEGORY(Value: WideString);
begin
  ChildNodes['CATEGORY'].NodeValue := Value;
end;

function TXMLITEMType.Get_COLOR: Integer;
begin
  Result := ChildNodes['COLOR'].NodeValue;
end;

procedure TXMLITEMType.Set_COLOR(Value: Integer);
begin
  ChildNodes['COLOR'].NodeValue := Value;
end;

function TXMLITEMType.Get_PRICE: WideString;
begin
  Result := ChildNodes['PRICE'].Text;
end;

procedure TXMLITEMType.Set_PRICE(Value: WideString);
begin
  ChildNodes['PRICE'].NodeValue := Value;
end;

function TXMLITEMType.Get_QTY: Integer;
begin
  Result := atoi(ChildNodes['QTY'].Text);
end;

procedure TXMLITEMType.Set_QTY(Value: Integer);
begin
  ChildNodes['QTY'].NodeValue := Value;
end;

function TXMLITEMType.Get_BULK: Integer;
begin
  Result := ChildNodes['BULK'].NodeValue;
end;

procedure TXMLITEMType.Set_BULK(Value: Integer);
begin
  ChildNodes['BULK'].NodeValue := Value;
end;

function TXMLITEMType.Get_IMAGE: WideString;
begin
  Result := ChildNodes['IMAGE'].Text;
end;

procedure TXMLITEMType.Set_IMAGE(Value: WideString);
begin
  ChildNodes['IMAGE'].NodeValue := Value;
end;

function TXMLITEMType.Get_DESCRIPTION: WideString;
begin
  Result := ChildNodes['DESCRIPTION'].Text;
end;

procedure TXMLITEMType.Set_DESCRIPTION(Value: WideString);
begin
  ChildNodes['DESCRIPTION'].NodeValue := Value;
end;

function TXMLITEMType.Get_CONDITION: WideString;
begin
  Result := ChildNodes['CONDITION'].Text;
end;

procedure TXMLITEMType.Set_CONDITION(Value: WideString);
begin
  ChildNodes['CONDITION'].NodeValue := Value;
end;

function TXMLITEMType.Get_ITEMTYPE: WideString;
begin
  Result := ChildNodes['ITEMTYPE'].Text;
end;

procedure TXMLITEMType.Set_ITEMTYPE(Value: WideString);
begin
  ChildNodes['ITEMTYPE'].NodeValue := Value;
end;

function TXMLITEMType.Get_ITEMID: WideString;
begin
  Result := ChildNodes['ITEMID'].Text;
end;

procedure TXMLITEMType.Set_ITEMID(Value: WideString);
begin
  ChildNodes['ITEMID'].NodeValue := Value;
end;

function TXMLITEMType.Get_SALE: WideString;
begin
  Result := ChildNodes['SALE'].Text;
end;

procedure TXMLITEMType.Set_SALE(Value: WideString);
begin
  ChildNodes['SALE'].NodeValue := Value;
end;

function TXMLITEMType.Get_WEIGHT: WideString;
begin
  Result := ChildNodes['WEIGHT'].Text;
end;

procedure TXMLITEMType.Set_WEIGHT(Value: WideString);
begin
  ChildNodes['WEIGHT'].NodeValue := Value;
end;

function TXMLITEMType.Get_LOTID: Integer;
begin
  Result := ChildNodes['LOTID'].NodeValue;
end;

procedure TXMLITEMType.Set_LOTID(Value: Integer);
begin
  ChildNodes['LOTID'].NodeValue := Value;
end;

function TXMLITEMType.Get_TQ1: WideString;
begin
  Result := ChildNodes['TQ1'].Text
end;

procedure TXMLITEMType.Set_TQ1(Value: WideString);
begin
  ChildNodes['TQ1'].NodeValue := Value;
end;

function TXMLITEMType.Get_TP1: WideString;
begin
  Result := ChildNodes['TP1'].Text;
end;

procedure TXMLITEMType.Set_TP1(Value: WideString);
begin
  ChildNodes['TP1'].NodeValue := Value;
end;

function TXMLITEMType.Get_TQ2: WideString;
begin
  Result := ChildNodes['TQ2'].Text;
end;

procedure TXMLITEMType.Set_TQ2(Value: WideString);
begin
  ChildNodes['TQ2'].NodeValue := Value;
end;

function TXMLITEMType.Get_TP2: WideString;
begin
  Result := ChildNodes['TP2'].Text;
end;

procedure TXMLITEMType.Set_TP2(Value: WideString);
begin
  ChildNodes['TP2'].NodeValue := Value;
end;

function TXMLITEMType.Get_TQ3: WideString;
begin
  Result := ChildNodes['TQ3'].Text;
end;

procedure TXMLITEMType.Set_TQ3(Value: WideString);
begin
  ChildNodes['TQ3'].NodeValue := Value;
end;

function TXMLITEMType.Get_TP3: WideString;
begin
  Result := ChildNodes['TP3'].Text;
end;

procedure TXMLITEMType.Set_TP3(Value: WideString);
begin
  ChildNodes['TP3'].NodeValue := Value;
end;

function TXMLITEMType.Get_SUBCONDITION: WideString;
begin
  Result := ChildNodes['SUBCONDITION'].Text;
end;

procedure TXMLITEMType.Set_SUBCONDITION(Value: WideString);
begin
  ChildNodes['SUBCONDITION'].NodeValue := Value;
end;

{ TXMLITEMTypeList }

function TXMLITEMTypeList.Add: IXMLITEMType;
begin
  Result := AddItem(-1) as IXMLITEMType;
end;

function TXMLITEMTypeList.Insert(const Index: Integer): IXMLITEMType;
begin
  Result := AddItem(Index) as IXMLITEMType;
end;
function TXMLITEMTypeList.Get_Item(Index: Integer): IXMLITEMType;
begin
  Result := List[Index] as IXMLITEMType;
end;

end.