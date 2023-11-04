unit json.discounts;

{$mode DelphiUnicode}

interface

uses
  Classes, SysUtils;

type
  TDiscounts = class
  private
    FAmount: string;
    FDescription: string;
  published
    property Amount: string read FAmount write FAmount;
    property Description: string read FDescription write FDescription;
  end;

  TDiscountsArray = array of TDiscounts;

implementation

end.

