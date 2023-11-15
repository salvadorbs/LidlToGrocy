unit Lidl.currency;

{$mode DelphiUnicode}

interface

uses
  Classes, SysUtils, mormot.core.json;

type
  TCurrency = class(TSynAutoCreateFields)
  private
    FCode: string;
    FSymbol: string;
  published
    property Code: string read FCode write FCode;
    property Symbol: string read FSymbol write FSymbol;
  end;

implementation

end.
