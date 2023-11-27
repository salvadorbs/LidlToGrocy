unit Grocy.ProductStock;

{$mode DelphiUnicode}

interface

uses
  Classes, SysUtils, mormot.core.json, mormot.core.rtti;

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
    constructor Create(Amount: string; BestBeforeDate: TDateTime; Price: string;
      TransactionType: string; PurchasedDate: TDateTime; ShoppingLocationId: string); overload;
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

constructor TGrocyProductStock.Create(Amount: string; BestBeforeDate: TDateTime; Price: string;
  TransactionType: string; PurchasedDate: TDateTime; ShoppingLocationId: string);
begin
  inherited Create;
  FAmount := Amount;
  FBestBeforeDate := Trunc(BestBeforeDate);
  FPrice := StringReplace(Price, ',', '.', [rfReplaceAll]);
  FShoppingLocationId := ShoppingLocationId;
  FTransactionType := TransactionType;
  FPurchasedDate := Trunc(PurchasedDate);
end;

initialization
  Rtti.ByTypeInfo[TypeInfo(TGrocyProductStock)].Props.NameChanges(
    ['Amount', 'BestBeforeDate', 'Price', 'PurchasedDate', 'ShoppingLocationId', 'TransactionType'],
    ['amount', 'best_before_date', 'price', 'purchased_date', 'shopping_location_id', 'transaction_type']);

end.
