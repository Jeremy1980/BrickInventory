unit bi_threadtimer;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs;

type
  TThreadComponent = class;

  TNestedThread = class(TThread)
    OwnerThreadComponent: TThreadComponent;
    procedure Execute; override;
    procedure DoExecute;
  end;

  TThreadComponent = class(TComponent)
  private
    FEnabled: Boolean;
    FOnExecute: TNotifyEvent;
    FOnTerminate: TNotifyEvent;
    FOnStart: TNotifyEvent;
    FThreadPriority: TThreadPriority;
    FNestedThread: TNestedThread;
    FSleep: DWORD;
  protected
    procedure SetEnabled(Value: Boolean);
    procedure SetOnExecute(Value: TNotifyEvent);
    procedure SetThreadPriority(Value: TThreadPriority);
    procedure Execute; dynamic;
    procedure Terminate; dynamic;
    procedure Start; dynamic;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    property Enabled: Boolean read FEnabled write SetEnabled default false;
    property OnExecute: TNotifyEvent read FOnExecute write SetOnExecute;
    property OnTerminate: TNotifyEvent read FOnTerminate write FOnTerminate;
    property OnStart: TNotifyEvent read FOnStart write FOnStart;
    property Sleep: DWORD read FSleep write FSleep default 1;
    property ThreadPriority: TThreadPriority read FThreadPriority write SetThreadPriority default tpNormal;
  end;

function GetNestedThreadsMaxSleep(AOwner: TComponent): DWORD;

implementation

procedure TNestedThread.Execute;
begin
  if (OwnerThreadComponent = nil) then
  repeat
    Sleep(10);
  until (OwnerThreadComponent <> nil) or Terminated;
  if not Terminated then
  repeat
    if not (csDestroying in OwnerThreadComponent.ComponentState) then
    begin
      SleepEx(OwnerThreadComponent.Sleep, false);
      Synchronize(DoExecute);
    end
    else
      Terminate
  until Terminated;
end;

procedure TNestedThread.DoExecute;
begin
  OwnerThreadComponent.Execute;
end;

constructor TThreadComponent.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FEnabled := false;
  FThreadPriority := tpNormal;
  FSleep := 1;
  FNestedThread := TNestedThread.Create(false);
  FNestedThread.OwnerThreadComponent := Self;
  FNestedThread.Suspend;
end;

destructor TThreadComponent.Destroy;
begin
  FNestedThread.Suspend;
  if FEnabled then Terminate;
  FNestedThread.Free;
  inherited Destroy;
end;

procedure TThreadComponent.SetEnabled(Value: Boolean);
begin
  if Value <> FEnabled then
  begin
    FEnabled := Value;
    if FEnabled then
    begin
      Start;
      FNestedThread.Resume
    end
    else
    begin
      FNestedThread.Suspend;
      Terminate
    end;
  end;
end;

procedure TThreadComponent.SetOnExecute(Value: TNotifyEvent);
begin
  FOnExecute := Value;
  if FEnabled then
  begin
    FNestedThread.Suspend;
    FNestedThread.Resume;
  end;
end;

procedure TThreadComponent.SetThreadPriority(Value: TThreadPriority);
begin
  if Value <> FThreadPriority then
  begin
    FThreadPriority := Value;
    if FEnabled then
    begin
      FNestedThread.Suspend;
      FNestedThread.Priority := FThreadPriority;
      FNestedThread.Resume;
    end;
  end;
end;

procedure TThreadComponent.Execute;
begin
  if Assigned(FOnExecute) then FOnExecute(Self);
end;

procedure TThreadComponent.Terminate;
begin
  if Assigned(FOnTerminate) then FOnTerminate(Self);
end;

procedure TThreadComponent.Start;
begin
  if Assigned(FOnStart) then FOnStart(Self);
end;

function GetNestedThreadsMaxSleep(AOwner: TComponent): DWORD;
var i: integer;
begin
  result := 0;
  for i := 0 to AOwner.ComponentCount - 1 do
  begin
    if (AOwner.Components[i] is TThreadComponent) then
      if result < (AOwner.Components[i] as TThreadComponent).Sleep then
        result := (AOwner.Components[i] as TThreadComponent).Sleep
  end;
end;

end.
