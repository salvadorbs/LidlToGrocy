unit Lidl.TenderChange;

{$mode DelphiUnicode}

interface

uses
  Classes, SysUtils, mormot.core.json;

type
  TTenderChange = class(TSynAutoCreateFields)
  private
    FAmount: string;
    FRoundingDifference: string;
    FType: string;
  published
    property Amount: string read FAmount write FAmount;
    property RoundingDifference: string read FRoundingDifference write FRoundingDifference;
    property &Type: string read FType write FType;
  end;

  TTenderChangeArray = array of TTenderChange;

implementation

end.
