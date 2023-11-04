unit json.currency;

{$mode DelphiUnicode}

interface

uses
  Classes, SysUtils;

type
  TCurrency = class
  private
    FCode: string;
    FSymbol: string;
  published
    property Code: string read FCode write FCode;
    property Symbol: string read FSymbol write FSymbol;
  end;

implementation

end.

