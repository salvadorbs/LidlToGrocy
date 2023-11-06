unit lidl.Taxes;

{$mode DelphiUnicode}

interface

uses
  Classes, SysUtils, mormot.core.json;

type
  TTaxes = class(TSynAutoCreateFields)
  private
    FAmount: string;
    FNetAmount: string;
    FPercentage: string;
    FTaxGroupName: string;
    FTaxableAmount: string;
  published
    property Amount: string read FAmount write FAmount;
    property NetAmount: string read FNetAmount write FNetAmount;
    property Percentage: string read FPercentage write FPercentage;
    property TaxGroupName: string read FTaxGroupName write FTaxGroupName;
    property TaxableAmount: string read FTaxableAmount write FTaxableAmount;
  end;

  TTaxesArray = array of TTaxes;

implementation

end.

