unit ImportFileForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, StdCtrls, bi_db;

type
  TImportFileForm = class(TForm)
    Label1: TLabel;
    Edit1: TEdit;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    ComboBox1: TComboBox;
    ComboBox2: TComboBox;
    ComboBox3: TComboBox;
    Button1: TButton;
    Button2: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    { Private declarations }
    csvDBL: TStringList;
  public
    { Public declarations }
  end;

function GetDataFromFile(const filename: string; const source: sourcetype_t; var data: TStringList): boolean;

                          
implementation

uses
  bi_globals;


function GetDataFromFile(const filename: string; const source: sourcetype_t; var data: TStringList): boolean;
var
  delimeter: char;
  l: integer;
  csvLine,partType,partPrefix: string;
  f: TImportFileForm;
  partData: TStringList;
begin
  Result := false;
  f:= TImportFileForm.Create(nil);

  case source of
    stBrickLink: delimeter := #9;
    stRebrickable: delimeter := ',';
  end;
  try
    f.csvDBL.loadFromFile(filename);
    f.Edit1.Text:= filename;

    partData:= TStringList.Create;
    try
      ExtractStrings([delimeter], [], PChar(f.csvDBL[0]), partData);
      f.ComboBox1.Items.AddStrings(partData);
      f.ComboBox2.Items.AddStrings(partData);
      f.ComboBox3.Items.AddStrings(partData);
      f.ComboBox1.ItemIndex:= 0;
      f.ComboBox2.ItemIndex:= 0;
      f.ComboBox3.ItemIndex:= 0;
    finally
      partData.Free;
    end;

    f.ShowModal;
    if f.ModalResult = mrOK then
    begin
      Screen.Cursor := crHourglass;
      partData:= TStringList.Create;
      try
        for l:=1 to f.csvDBL.Count-1 do begin
          ExtractStrings([delimeter], [], PChar(f.csvDBL[l]), partData);
          if (partData.Count=f.ComboBox1.Items.Count) then begin
            partPrefix:= ' ';
            partType:= Trim(partData[f.ComboBox1.itemIndex]);
            case source of
              stBrickLink: partPrefix:= BLDATATYPE +' ';
            end;
            csvLine:= partPrefix+partType+','+
                partPrefix+Trim(partData[f.ComboBox2.itemIndex])+','+
                Trim(partData[f.ComboBox3.itemIndex]);
            data.Add(csvLine);
          end;
          partData.Clear;
        end;
      finally
        partData.Free;
        Screen.Cursor := crDefault;
      end;    
      Result:= true;
    end;
  finally
    f.Free;
  end;
end;

{$R *.dfm}

procedure TImportFileForm.FormCreate(Sender: TObject);
begin
  SendMessage(GetWindow(ComboBox1.Handle,GW_CHILD), EM_SETREADONLY, 1, 0);
  SendMessage(GetWindow(ComboBox2.Handle,GW_CHILD), EM_SETREADONLY, 1, 0);
  SendMessage(GetWindow(ComboBox3.Handle,GW_CHILD), EM_SETREADONLY, 1, 0);
  csvDBL:= TStringList.Create;
end;

procedure TImportFileForm.FormDestroy(Sender: TObject);
begin
  csvDBL.Free;
end;

end.
