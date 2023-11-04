unit json.itemsline;

{$mode DelphiUnicode}

interface

uses
  Classes, SysUtils, Generics.Collections, json.discounts, mormot.core.json, syncobjs;

type

  { TItemsLine }

  TItemsLine = class(TSynAutoCreateFields)
  private
    FCodeInput: string;
    FCurrentUnitPrice: string;
    FDiscounts: TDiscountsArray;
    FIsWeight: Boolean;
    FName: string;
    FOriginalAmount: string;
    FQuantity: string;
    FTaxGroupName: string;
  published
    property CodeInput: string read FCodeInput write FCodeInput;
    property CurrentUnitPrice: string read FCurrentUnitPrice write FCurrentUnitPrice;
    property Discounts: TDiscountsArray read FDiscounts;
    property IsWeight: Boolean read FIsWeight write FIsWeight;
    property Name: string read FName write FName;
    property OriginalAmount: string read FOriginalAmount write FOriginalAmount;
    property Quantity: string read FQuantity write FQuantity;
    property TaxGroupName: string read FTaxGroupName write FTaxGroupName;
  public
    destructor Destroy; override;
  end;

  TItemsLineArray = array of TItemsLine;

implementation

{ TItemsLine }

destructor TItemsLine.Destroy;
begin
  inherited Destroy;
end;

end.

