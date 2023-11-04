unit json.totaltaxes;

{$mode DelphiUnicode}

interface

uses
  Classes, SysUtils;

type
  TTotalTaxes = class
  private
    FTotalAmount: string;
    FTotalNetAmount: string;
    FTotalTaxableAmount: string;
  published
    property TotalAmount: string read FTotalAmount write FTotalAmount;
    property TotalNetAmount: string read FTotalNetAmount write FTotalNetAmount;
    property TotalTaxableAmount: string read FTotalTaxableAmount write FTotalTaxableAmount;
  end;

implementation

end.

