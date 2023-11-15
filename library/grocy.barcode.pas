unit Grocy.Barcode;

{$mode DelphiUnicode}

interface

uses
  Classes, SysUtils, mormot.core.json, mormot.core.rtti;

type

  { TGrocyBarcode }

  TGrocyBarcode = class(TSynAutoCreateFields)
  private
    FAmount: string;
    FBarcode: string;
    FNote: string;
    FProductId: integer;
    FQuId: string;
    FShoppingLocationId: integer;
  published
    property Amount: string read FAmount write FAmount;
    property Barcode: string read FBarcode write FBarcode;
    property Note: string read FNote write FNote;
    property ProductId: integer read FProductId write FProductId;
    property QuId: string read FQuId write FQuId;
    property ShoppingLocationId: integer read FShoppingLocationId write FShoppingLocationId;
  end;

implementation

initialization
  Rtti.ByTypeInfo[TypeInfo(TGrocyBarcode)].Props.NameChanges(
    ['Amount', 'Barcode', 'Note', 'ProductId', 'QuId', 'ShoppingLocationId'],
    ['amount', 'barcode', 'note', 'product_id', 'qu_id', 'shopping_location_id']);

end.
