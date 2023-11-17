unit Grocy.Product;

{$mode DelphiUnicode}

interface

uses
  Classes, SysUtils, mormot.core.json, mormot.core.rtti;

type

  { TGrocyProduct }

  TGrocyProduct = class(TSynAutoCreateFields)
  private
    FActive: string;
    FCalories: string;
    FCumulateMinStockAmountOfSubProducts: string;
    FDefaultBestBeforeDays: string;
    FDefaultBestBeforeDaysAfterFreezing: string;
    FDefaultBestBeforeDaysAfterOpen: string;
    FDefaultBestBeforeDaysAfterThawing: string;
    FDefaultConsumeLocationId: string;
    FDescription: string;
    FDueType: string;
    FEnableTareWeightHandling: string;
    FHideOnStockOverview: string;
    FId: integer;
    FLocationId: string;
    FMinStockAmount: string;
    FMoveOnOpen: string;
    FName: string;
    FNoOwnStock: string;
    FNotCheckStockFulfillmentForRecipes: string;
    FParentProductId: string;
    FProductGroupId: string;
    FQuIdConsume: string;
    FQuIdPrice: string;
    FQuIdPurchase: string;
    FQuIdStock: string;
    FQuickConsumeAmount: string;
    FQuickOpenAmount: string;
    FShoppingLocationId: string;
    FShouldNotBeFrozen: string;
    FTreatOpenedAsOutOfStock: string;
  public
    procedure DefaultSetup();
  published
    property Active: string read FActive write FActive;
    property Calories: string read FCalories write FCalories;
    property CumulateMinStockAmountOfSubProducts: string read FCumulateMinStockAmountOfSubProducts
      write FCumulateMinStockAmountOfSubProducts;
    property DefaultBestBeforeDays: string read FDefaultBestBeforeDays write FDefaultBestBeforeDays;
    property DefaultBestBeforeDaysAfterFreezing: string read FDefaultBestBeforeDaysAfterFreezing
      write FDefaultBestBeforeDaysAfterFreezing;
    property DefaultBestBeforeDaysAfterOpen: string read FDefaultBestBeforeDaysAfterOpen
      write FDefaultBestBeforeDaysAfterOpen;
    property DefaultBestBeforeDaysAfterThawing: string read FDefaultBestBeforeDaysAfterThawing
      write FDefaultBestBeforeDaysAfterThawing;
    property DefaultConsumeLocationId: string read FDefaultConsumeLocationId write FDefaultConsumeLocationId;
    property Description: string read FDescription write FDescription;
    property DueType: string read FDueType write FDueType;
    property EnableTareWeightHandling: string read FEnableTareWeightHandling write FEnableTareWeightHandling;
    property HideOnStockOverview: string read FHideOnStockOverview write FHideOnStockOverview;
    property Id: integer read FId write FId default -1;
    property LocationId: string read FLocationId write FLocationId;
    property MinStockAmount: string read FMinStockAmount write FMinStockAmount;
    property MoveOnOpen: string read FMoveOnOpen write FMoveOnOpen;
    property Name: string read FName write FName;
    property NoOwnStock: string read FNoOwnStock write FNoOwnStock;
    property NotCheckStockFulfillmentForRecipes: string read FNotCheckStockFulfillmentForRecipes
      write FNotCheckStockFulfillmentForRecipes;
    property ParentProductId: string read FParentProductId write FParentProductId;
    property ProductGroupId: string read FProductGroupId write FProductGroupId;
    property QuIdConsume: string read FQuIdConsume write FQuIdConsume;
    property QuIdPrice: string read FQuIdPrice write FQuIdPrice;
    property QuIdPurchase: string read FQuIdPurchase write FQuIdPurchase;
    property QuIdStock: string read FQuIdStock write FQuIdStock;
    property QuickConsumeAmount: string read FQuickConsumeAmount write FQuickConsumeAmount;
    property QuickOpenAmount: string read FQuickOpenAmount write FQuickOpenAmount;
    property ShoppingLocationId: string read FShoppingLocationId write FShoppingLocationId;
    property ShouldNotBeFrozen: string read FShouldNotBeFrozen write FShouldNotBeFrozen;
    property TreatOpenedAsOutOfStock: string read FTreatOpenedAsOutOfStock write FTreatOpenedAsOutOfStock;
  end;

  TGrocyProductArray = array of TGrocyProduct;

implementation

{ TGrocyProduct }

procedure TGrocyProduct.DefaultSetup();
begin
  FActive := '1';
  FCalories := '0';
  FCumulateMinStockAmountOfSubProducts := '0';
  FDefaultBestBeforeDaysAfterFreezing := '0';
  FDefaultBestBeforeDaysAfterOpen := '0';
  FDescription := 'Automatically created by LidlToGrocy';
  FDueType := '1';
  FEnableTareWeightHandling := '0';
  FHideOnStockOverview := '0';
  FId := -1;
  FMinStockAmount := '0';
  FMoveOnOpen := '0';
  FNoOwnStock := '0';
  FNotCheckStockFulfillmentForRecipes := '0';
  FParentProductId := '';
  FQuickConsumeAmount := '1';
  FQuickOpenAmount := '1';
  FShouldNotBeFrozen := '0';
  FTreatOpenedAsOutOfStock := '1';
end;

initialization
  Rtti.ByTypeInfo[TypeInfo(TGrocyProduct)].Props.NameChanges(
    ['Active', 'Calories', 'CumulateMinStockAmountOfSubProducts', 'DefaultBestBeforeDays',
    'DefaultBestBeforeDaysAfterFreezing', 'DefaultBestBeforeDaysAfterOpen',
    'DefaultBestBeforeDaysAfterThawing', 'DefaultConsumeLocationId', 'Description', 'DueType',
    'EnableTareWeightHandling', 'HideOnStockOverview', 'Id', 'LocationId', 'MinStockAmount',
    'MoveOnOpen', 'Name', 'NoOwnStock', 'NotCheckStockFulfillmentForRecipes', 'ParentProductId',
    'ProductGroupId', 'QuIdConsume', 'QuIdPrice', 'QuIdPurchase', 'QuIdStock', 'QuickConsumeAmount',
    'QuickOpenAmount', 'ShoppingLocationId', 'ShouldNotBeFrozen', 'TreatOpenedAsOutOfStock'],
    ['active', 'calories', 'cumulate_min_stock_amount_of_sub_products', 'default_best_before_days',
    'default_best_before_days_after_freezing', 'default_best_before_days_after_open',
    'default_best_before_days_after_thawing', 'default_consume_location_id', 'description',
    'due_type', 'enable_tare_weight_handling', 'hide_on_stock_overview', 'id', 'location_id',
    'min_stock_amount', 'move_on_open', 'name', 'no_own_stock', 'not_check_stock_fulfillment_for_recipes',
    'parent_product_id', 'product_group_id', 'qu_id_consume', 'qu_id_price', 'qu_id_purchase',
    'qu_id_stock', 'quick_consume_amount', 'quick_open_amount', 'shopping_location_id',
    'should_not_be_frozen', 'treat_opened_as_out_of_stock']);

end.
