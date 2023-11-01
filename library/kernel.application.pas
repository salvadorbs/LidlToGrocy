unit kernel.application;

{$mode DelphiUnicode}

interface

uses
  Classes, SysUtils, mormot.core.os, CustApp;

type

  TNotifyEvent = procedure(Sender: TObject) of object;

  { TLidlToGrocy }

  TLidlToGrocy = class(TCustomApplication)
  private
    FHelp: Boolean;
    FOnHelp: TNotifyEvent;
    FVerbose: Boolean;

    procedure DoHelp(Sender: TObject);
  protected
    procedure DoRun; override;
  public
    constructor Create(TheOwner: TComponent); override;
    destructor Destroy; override;

    property Verbose: Boolean read FVerbose write FVerbose;
    property Help: Boolean read FHelp write FHelp;

    property OnHelp: TNotifyEvent read FOnHelp write FOnHelp;
  end;

implementation

{ TGrocyFastLidlAdder }

procedure TLidlToGrocy.DoHelp(Sender: TObject);
begin
  ConsoleWrite(Executable.Command.FullDescription);
end;

procedure TLidlToGrocy.DoRun;
var
  boolArgs: Boolean;
begin
  boolArgs := Length(Executable.Command.Args) > 0;
  if boolArgs then
  begin
    if FHelp then
       FOnHelp(Self);

    Executable.Command.ConsoleWriteUnknown();
  end
  else
    ConsoleWrite(Executable.Command.FullDescription());

  Terminate;
end;

constructor TLidlToGrocy.Create(TheOwner: TComponent);
begin
  inherited Create(TheOwner);
  StopOnException:=True;

  Self.FOnHelp := DoHelp;
end;

destructor TLidlToGrocy.Destroy;
begin
  inherited Destroy;
end;

end.

