unit bi_tmp;

interface

procedure I_InitTempFiles;

procedure I_ShutDownTempFiles;

function I_NewTempFile(const name: string): string;

implementation

uses
  Windows,
  SysUtils,
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
  TmpDir: PChar;
begin
  TmpDir := StrAlloc(MAX_PATH);
  GetTempPath(MAX_PATH, TmpDir);
  Result := StringVal(TmpDir);
  StrDispose(TmpDir);

  if Result[Length(Result)] <> '\' then
    Result := Result + '\';
  Result := Result + fname(name);

  if Assigned(tempfiles) then tempfiles.Add(Result);
end;

end.

