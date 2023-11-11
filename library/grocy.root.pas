unit Grocy.Root;

{$mode DelphiUnicode}

interface

uses
  Classes, SysUtils, mormot.core.json, Grocy.Product;

type
  { TGrocyRoot }

  TGrocyRoot = class(TSynAutoCreateFields)
  private
    FProduct: TGrocyProduct;
  published
    property Product: TGrocyProduct read FProduct;
  end;

implementation

end.

