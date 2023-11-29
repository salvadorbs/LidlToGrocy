unit Grocy.ProductStock;

{$mode DelphiUnicode}

interface

uses
  Classes, SysUtils, mormot.core.json, mormot.core.rtti, Lidl.ItemsLine;

type

  { TGrocyProductStock }

  TGrocyProductStock = class(TSynAutoCreateFields)
  private
    FAmount: string;
    FBestBeforeDate: TDateTime;
    FPrice: string;
    FPurchasedDate: TDateTime;
    FShoppingLocationId: string;
    FTransactionType: string;
  public
    constructor Create(LidlProduct: TItemsLine; BestBeforeDate: TDateTime; TransactionType: string;
      PurchasedDate: TDateTime; ShoppingLocationId: string); overload;
  published
    property Amount: string read FAmount write FAmount;
    property BestBeforeDate: TDateTime read FBestBeforeDate write FBestBeforeDate;
    property Price: string read FPrice write FPrice;
    property PurchasedDate: TDateTime read FPurchasedDate write FPurchasedDate;
    property ShoppingLocationId: string read FShoppingLocationId write FShoppingLocationId;
    property TransactionType: string read FTransactionType write FTransactionType;
  end;

implementation

{ TGrocyProductStock }

constructor TGrocyProductStock.Create(LidlProduct: TItemsLine; BestBeforeDate: TDateTime;
  TransactionType: string; PurchasedDate: TDateTime; ShoppingLocationId: string);
var
  I: integer;
  TotalDiscounts, CurrentUnitPrice, Total: Real;
  fs: TFormatSettings;
begin
  inherited Create;
  FAmount := LidlProduct.Quantity;
  FBestBeforeDate := Trunc(BestBeforeDate);
  FShoppingLocationId := ShoppingLocationId;
  FTransactionType := TransactionType;
  FPurchasedDate := Trunc(PurchasedDate);

  fs := DefaultFormatSettings;
  fs.ThousandSeparator := '.';
  fs.DecimalSeparator  := ',';

  TotalDiscounts := 0;
  for I := 0 to length(LidlProduct.Discounts) - 1 do
    TotalDiscounts := TotalDiscounts + StrToFloatDef(LidlProduct.Discounts[I].Amount, 0, fs);

  CurrentUnitPrice := StrToFloatDef(LidlProduct.CurrentUnitPrice, 0, fs);

  Total := CurrentUnitPrice;
  if (CurrentUnitPrice >= TotalDiscounts) then
    Total := CurrentUnitPrice - TotalDiscounts;

  fs.ThousandSeparator := ',';
  fs.DecimalSeparator  := '.';
  FPrice := FloatToStr(Total, fs);
end;

initialization
  Rtti.ByTypeInfo[TypeInfo(TGrocyProductStock)].Props.NameChanges(
    ['Amount', 'BestBeforeDate', 'Price', 'PurchasedDate', 'ShoppingLocationId', 'TransactionType'],
    ['amount', 'best_before_date', 'price', 'purchased_date', 'shopping_location_id', 'transaction_type']);

end.
