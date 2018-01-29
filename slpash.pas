unit slpash;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, ExtCtrls;

type
  TSplashForm = class(TForm)
    Panel1: TPanel;
    Label1: TLabel;
    ProgressBar1: TProgressBar;
    Label2: TLabel;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  SplashForm: TSplashForm;

procedure ShowSplash;
procedure HideSplash;

procedure SplashProgress(const msg: string; d: Double);

implementation

{$R *.dfm}

procedure ShowSplash;
begin
  SplashForm.Show;
  SplashForm.BringToFront;
  SplashForm.ProgressBar1.Position := 0;
  SplashForm.Repaint;
end;

procedure HideSplash;
begin
  SplashForm.Hide;
end;

procedure SplashProgress(const msg: string; d: Double);
begin
  if SplashForm.Label1.Caption <> msg then
  begin
    SplashForm.Label1.Caption := msg;
    SplashForm.Repaint;
  end;
  SplashForm.ProgressBar1.Position := Round(d * 100);
end;

end.
