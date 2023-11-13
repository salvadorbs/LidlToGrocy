unit Grocy.Root;

{$mode DelphiUnicode}

interface

uses
  Classes, SysUtils, mormot.core.json, Grocy.Product, mormot.core.rtti;

type
  { TGrocyRoot }

  TGrocyRoot = class(TSynAutoCreateFields)
  private
    FProduct: TGrocyProduct;
  published
    property Product: TGrocyProduct read FProduct;
  end;

implementation

initialization
  Rtti.ByTypeInfo[TypeInfo(TGrocyRoot)].Props.NameChanges(
    ['Product'],
    ['product']);

end.

