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
    FId: integer;
    FNote: string;
    FProductId: integer;
    FQuId: string;
    FShoppingLocationId: integer;
  public
    procedure DefaultSetup();
  published
    property Amount: string read FAmount write FAmount;
    property Barcode: string read FBarcode write FBarcode;
    property Id: integer read FId write FId default -1;
    property Note: string read FNote write FNote;
    property ProductId: integer read FProductId write FProductId;
    property QuId: string read FQuId write FQuId;
    property ShoppingLocationId: integer read FShoppingLocationId write FShoppingLocationId;
  end;

implementation

{ TGrocyBarcode }

procedure TGrocyBarcode.DefaultSetup();
begin
  FAmount := '1';
  FId := -1;
  FQuId := '1';
  FNote := 'Automatically created by LidlToGrocy';
end;

initialization
  Rtti.ByTypeInfo[TypeInfo(TGrocyBarcode)].Props.NameChanges(
    ['Amount', 'Barcode', 'Id', 'Note', 'ProductId', 'QuId', 'ShoppingLocationId'],
    ['amount', 'barcode', 'id', 'note', 'product_id', 'qu_id', 'shopping_location_id']);

end.
