{$A8,B-,C+,D+,E-,F-,G+,H+,I+,J-,K-,L+,M-,N+,O+,P+,Q-,R-,S-,T-,U-,V+,W-,X+,Y+,Z1}
{$MINSTACKSIZE $00004000}
{$MAXSTACKSIZE $00100000}
{$IMAGEBASE $00400000}
{$APPTYPE GUI}
{$WARN SYMBOL_DEPRECATED ON}
{$WARN SYMBOL_LIBRARY ON}
{$WARN SYMBOL_PLATFORM ON}
{$WARN UNIT_LIBRARY ON}
{$WARN UNIT_PLATFORM ON}
{$WARN UNIT_DEPRECATED ON}
{$WARN HRESULT_COMPAT ON}
{$WARN HIDING_MEMBER ON}
{$WARN HIDDEN_VIRTUAL ON}
{$WARN GARBAGE ON}
{$WARN BOUNDS_ERROR ON}
{$WARN ZERO_NIL_COMPAT ON}
{$WARN STRING_CONST_TRUNCED ON}
{$WARN FOR_LOOP_VAR_VARPAR ON}
{$WARN TYPED_CONST_VARPAR ON}
{$WARN ASG_TO_TYPED_CONST ON}
{$WARN CASE_LABEL_RANGE ON}
{$WARN FOR_VARIABLE ON}
{$WARN CONSTRUCTING_ABSTRACT ON}
{$WARN COMPARISON_FALSE ON}
{$WARN COMPARISON_TRUE ON}
{$WARN COMPARING_SIGNED_UNSIGNED ON}
{$WARN COMBINING_SIGNED_UNSIGNED ON}
{$WARN UNSUPPORTED_CONSTRUCT ON}
{$WARN FILE_OPEN ON}
{$WARN FILE_OPEN_UNITSRC ON}
{$WARN BAD_GLOBAL_SYMBOL ON}
{$WARN DUPLICATE_CTOR_DTOR ON}
{$WARN INVALID_DIRECTIVE ON}
{$WARN PACKAGE_NO_LINK ON}
{$WARN PACKAGED_THREADVAR ON}
{$WARN IMPLICIT_IMPORT ON}
{$WARN HPPEMIT_IGNORED ON}
{$WARN NO_RETVAL ON}
{$WARN USE_BEFORE_DEF ON}
{$WARN FOR_LOOP_VAR_UNDEF ON}
{$WARN UNIT_NAME_MISMATCH ON}
{$WARN NO_CFG_FILE_FOUND ON}
{$WARN MESSAGE_DIRECTIVE ON}
{$WARN IMPLICIT_VARIANTS ON}
{$WARN UNICODE_TO_LOCALE ON}
{$WARN LOCALE_TO_UNICODE ON}
{$WARN IMAGEBASE_MULTIPLE ON}
{$WARN SUSPICIOUS_TYPECAST ON}
{$WARN PRIVATE_PROPACCESSOR ON}
{$WARN UNSAFE_TYPE ON}
{$WARN UNSAFE_CODE ON}
{$WARN UNSAFE_CAST ON}
unit bi_io;

interface

uses
  bi_delphi, Classes;

var
  debugfile: TFileStream = nil;
  stderr: TFileStream = nil;
  stdout: TFileStream = nil;
  stdoutbuffer: TDStringList = nil;

procedure I_InitializeIO;

procedure I_ShutDownIO;

procedure I_IOMessageBox(const s: string);

procedure I_IOErrorMessageBox(const s: string);

procedure I_IOprintf(const s: string);

implementation

uses
  Windows, Forms, main;

procedure I_IOMessageBox(const s: string);
begin
  MessageBox(MainForm.Handle, PChar(s), PChar(Application.Title), MB_OK);
end;

procedure I_IOErrorMessageBox(const s: string);
begin
  MessageBox(MainForm.Handle, PChar(s), PChar(Application.Title), MB_OK or MB_ICONERROR or MB_APPLMODAL);
end;

var
  io_lastNL: boolean = true;

procedure I_IOprintf(const s: string);
var
  p: integer;
  do_add: boolean;
  len: integer;
begin
  len := Length(s);
  if len = 0 then
    exit;

  do_add := false;
  if io_lastNL then
  begin
    p := Pos(#10, s);
    if (p = 0) or (p = len) then
      do_add := true
  end;

  io_lastNL := s[len] = #10;

  if do_add then
  begin
    if len >= 2 then
    begin
      if s[len - 1] = #13 then
      begin
        stdoutbuffer.Add(Copy(s, 1, len - 2));
      end
      else
      begin
        stdoutbuffer.Add(Copy(s, 1, len - 1));
      end
    end
    else
    begin
      stdoutbuffer.Add('');
    end;
  end
  else
  begin
    stdoutbuffer.Text := stdoutbuffer.Text + s;
  end;


  if IsConsole then
    write(s);
end;

procedure I_AddText(const txt: string);
begin
  if stdout = nil then
    Exit;
  fprintf(stdout, txt);
end;

procedure I_InitializeIO;
var
  dfilename: string;
  efilename: string;
  sfilename: string;
begin
  dfilename := 'bi_debug.txt';
  efilename := 'bi_stderr.txt';
  sfilename := 'bi_stdout.txt';

  printf(' error output to: %s', [efilename]);
  stderr := TFileStream.Create(efilename, fCreate);
  printf(' debug output to: %s', [dfilename]);
  debugfile := TFileStream.Create(dfilename, fCreate);
  printf(' standard output to: %s', [sfilename]);
  stdout := TFileStream.Create(sfilename, fCreate);

  fprintf(stdout, stdoutbuffer.Text);

  outproc := @I_AddText;
end;


procedure I_ShutDownIO;
begin
  stderr.Free;
  debugfile.Free;
  stdout.Free;
end;

initialization

  stdoutbuffer := TDStringList.Create;

finalization

  stdoutbuffer.Free;

end.
