unit Lidl.ItemsLine;

{$mode DelphiUnicode}

interface

uses
  Classes, SysUtils, Lidl.Discounts, mormot.core.json, Math;

type

  { TItemsLine }

  TItemsLine = class(TSynAutoCreateFields)
  private
    FCodeInput: string;
    FCurrentUnitPrice: string;
    FDiscounts: TDiscountsArray;
    FIsWeight: boolean;
    FName: string;
    FOriginalAmount: string;
    FQuantity: string;
    FTaxGroupName: string;
  published
    property CodeInput: string read FCodeInput write FCodeInput;
    property CurrentUnitPrice: string read FCurrentUnitPrice write FCurrentUnitPrice;
    property Discounts: TDiscountsArray read FDiscounts;
    property IsWeight: boolean read FIsWeight write FIsWeight;
    property Name: string read FName write FName;
    property OriginalAmount: string read FOriginalAmount write FOriginalAmount;
    property Quantity: string read FQuantity write FQuantity;
    property TaxGroupName: string read FTaxGroupName write FTaxGroupName;
  public
    destructor Destroy; override;

    procedure FixQuantity;
  end;

  TItemsLineArray = array of TItemsLine;

implementation

{ TItemsLine }

destructor TItemsLine.Destroy;
begin
  inherited Destroy;
end;

procedure TItemsLine.FixQuantity;
var
  Value: Double;
begin
  if TryStrToFloat(FQuantity, Value) and (frac(Value) <> 0) then
    FQuantity := IntToStr(Ceil(Value));
end;

end.
