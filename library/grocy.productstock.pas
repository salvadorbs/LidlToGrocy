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
    FTransactionType: string;
  public
    constructor Create(Amount: string; BestBeforeDate: TDateTime;
      Price: string; TransactionType: string; PurchasedDate: TDateTime);
  published
    property Amount: string read FAmount write FAmount;
    property BestBeforeDate: TDateTime read FBestBeforeDate write FBestBeforeDate;
    property Price: string read FPrice write FPrice;
    property PurchasedDate: TDateTime read FPurchasedDate write FPurchasedDate;
    property TransactionType: string read FTransactionType write FTransactionType;
  end;

implementation

{ TGrocyProductStock }

constructor TGrocyProductStock.Create(Amount: string; BestBeforeDate: TDateTime;
  Price: string; TransactionType: string; PurchasedDate: TDateTime);
begin
  FAmount := Amount;
  FBestBeforeDate := Trunc(BestBeforeDate);
  FPrice := Price;
  FTransactionType := TransactionType;
  FPurchasedDate := Trunc(PurchasedDate);
end;

initialization
  Rtti.ByTypeInfo[TypeInfo(TGrocyProductStock)].Props.NameChanges(
    ['Amount', 'BestBeforeDate', 'Price', 'PurchasedDate', 'TransactionType'],
    ['amount', 'best_before_date', 'price', 'purchased_date', 'transaction_type']);

end.
