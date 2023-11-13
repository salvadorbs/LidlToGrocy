program LidlToGrocy;

{$mode delphiUnicode}

uses
  {$IFDEF UNIX}
  cthreads,
  {$ENDIF}
  Classes, SysUtils, mormot.core.os, kernel.application, mormot.core.base,
  mormot.core.unicode;

var
  Application: TLidlToGrocy;

function GetEx(const Name: array of RawUtf8; Description: RawUtf8; Default: RawUtf8 = ''): String;
var
  Arg: RawUtf8;
begin
  Executable.Command.Get(Name, Arg, Description, Default);
  Result := Utf8DecodeToUnicodeString(Arg);
end;

{$R *.res}

begin
  with Executable.Command do
  begin
    ExeDescription := 'An executable to add easily your Lidl receipts into Grocy';

    Application := TLidlToGrocy.Create(nil);

    Application.Verbose := Option(['v', 'verbose'], 'generate verbose output');
    //Application.SaveSettings := Option(['s', 'save-params'], 'save parameters in settings.json');
    Application.Help := Option(['?', 'help'], 'display this message');
    Application.NoStock := Option(['n', 'no-add-stock'], 'don''t add product in stock');

    Application.GrocyIp := GetEx(['i', 'grocy-ip'], 'grocy ip address');
    Application.GrocyPort := GetEx(['p', 'grocy-port'], 'grocy port', '9283');
    Application.GrocyApiKey := GetEx(['a', 'grocy-apikey'], 'grocy api key');

    Application.LidlCountry := GetEx(['c', 'lidl-country'], 'lidl country', 'EN');
    Application.LidlLanguage := GetEx(['l', 'lidl-lang'], 'lidl language', 'en');
    Application.LidlToken := GetEx(['t', 'lidl-token'], 'lidl token');

    Application.LidlJsonFilePath := GetEx(['f', 'lidl-filepath'], 'lidl json file (optional)');

    Application.Title := 'LidlToGrocy';

    Application.SetupGrocy;

    Application.Run;

    Application.Free;
  end;
end.

