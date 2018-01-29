unit timing;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, bi_threadtimer;

type
  TTimingForm = class(TForm)
    CrawlerTimer: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure CrawlerTimerTimer(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    { Private declarations }
 //   tr: TThreadComponent;
    cancrowl: boolean;
  public
    { Public declarations }
    crawling: Boolean;
  end;

var
  TimingForm: TTimingForm;

implementation

{$R *.dfm}

uses
  bi_db, main, bi_globals;

procedure TTimingForm.FormCreate(Sender: TObject);
begin
  crawling := false;
  cancrowl := true;
end;

procedure TTimingForm.CrawlerTimerTimer(Sender: TObject);
begin
  if not cancrowl then
    exit;

  if db = nil then
    Exit;

  if crawling then
    exit;

  if MainForm.activebits > 0 then
    exit;
    
  crawling := true;
  db.Crawler;
  crawling := false;
end;

procedure TTimingForm.FormDestroy(Sender: TObject);
begin
  cancrowl := false;
end;

end.
