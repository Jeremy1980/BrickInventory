unit frm_batch;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls;

type
  TBatchLinkForm = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    Button1: TButton;
    Button2: TButton;
    Panel3: TPanel;
    Memo1: TMemo;
    Panel4: TPanel;
    Label1: TLabel;
  private
    { Private declarations }
  public
    { Public declarations }
  end;


function GetBatchLinks(const s: TStringList): boolean;

implementation

{$R *.dfm}

function GetBatchLinks(const s: TStringList): boolean;
var
  f: TBatchLinkForm;
begin
  result := false;
  f := TBatchLinkForm.Create(nil);
  try
    f.ShowModal;
    if f.ModalResult = mrOK then
    begin
      s.AddStrings(f.Memo1.Lines);
      result := true;
    end;
  finally
    f.Free;
  end;
end;

end.
