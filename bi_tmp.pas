unit bi_tmp;

interface

procedure I_InitTempFiles;

procedure I_ShutDownTempFiles;

function I_NewTempFile(const name: string): string;

implementation

uses
  Windows,
  bi_delphi;

var
  tempfiles: TDStringList;

procedure I_InitTempFiles;
begin
  printf('I_InitTempFiles: Initializing temporary file managment.'#13#10);
  tempfiles := TDStringList.Create;
end;

procedure I_ShutDownTempFiles;
var
  i: integer;
begin
  printf('I_ShutDownTempFiles: Shut down temporary file managment.'#13#10);
{$I-}
  for i := 0 to tempfiles.Count - 1 do
    fdelete(tempfiles.Strings[i]);
{$I+}    
  tempfiles.Free;
end;

function I_NewTempFile(const name: string): string;
var
  buf: array[0..1024] of char;
begin
  ZeroMemory(@buf, SizeOf(buf));
  GetTempPath(SizeOf(buf), buf);
  result :=  StringVal(buf) + '\' + fname(name);
  tempfiles.Add(result);
end;

end.

