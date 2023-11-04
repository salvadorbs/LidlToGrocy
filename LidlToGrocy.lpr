program LidlToGrocy;

{$mode delphiUnicode}

uses
  {$IFDEF UNIX}
  cthreads,
  {$ENDIF}
  Classes, SysUtils, mormot.core.os, kernel.application, json.payments,
json.currency, json.store, json.couponsused, json.totaltaxes, json.taxes,
json.discounts, json.itemsline, json.root;

var
  Application: TLidlToGrocy;

{$R *.res}

begin
  with Executable.Command do
  begin
    ExeDescription := 'An executable to add easily your Lidl receipts into Grocy';

    Application := TLidlToGrocy.Create(nil);

    Application.Verbose := Option(['v', 'verbose'], 'generate verbose output');
    Application.Help := Option(['?', 'help'], 'display this message');

    Application.Title := 'LidlToGrocy';

    Application.Run;

    Application.Free;
  end;
end.

