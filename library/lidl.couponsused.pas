unit Lidl.CouponsUsed;

{$mode DelphiUnicode}

interface

uses
  Classes, SysUtils, mormot.core.json;

type
  TCouponsUsed = class(TSynAutoCreateFields)
  private
    FBlock2Description: string;
    FDiscount: string;
    FTitle: string;
  published
    property Block2Description: string read FBlock2Description write FBlock2Description;
    property Discount: string read FDiscount write FDiscount;
    property Title: string read FTitle write FTitle;
  end;

  TCouponsUsedArray = array of TCouponsUsed;

implementation

end.
