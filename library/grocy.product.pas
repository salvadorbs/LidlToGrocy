unit Grocy.Product;

{$mode DelphiUnicode}

interface

uses
  Classes, SysUtils, mormot.core.json;

type

  { TGrocyProduct }

  TGrocyProduct = class(TSynAutoCreateFields)
  private
    FActive: string;
    FCalories: string;
    FCumulateMinStockAmountOfSubProducts: string;
    FDefaultBestBeforeDays: Integer;
    FDefaultBestBeforeDaysAfterFreezing: string;
    FDefaultBestBeforeDaysAfterOpen: string;
    FDefaultBestBeforeDaysAfterThawing: Integer;
    FDefaultConsumeLocationId: Integer;
    FDescription: string;
    FDueType: string;
    FEnableTareWeightHandling: string;
    FHideOnStockOverview: string;
    FId: string;
    FLocationId: Integer;
    FMinStockAmount: string;
    FMoveOnOpen: string;
    FName: string;
    FNoOwnStock: string;
    FNotCheckStockFulfillmentForRecipes: string;
    FParentProductId: string;
    FProductGroupId: Integer;
    FQuIdConsume: Integer;
    FQuIdPrice: Integer;
    FQuIdPurchase: Integer;
    FQuIdStock: Integer;
    FQuickConsumeAmount: string;
    FQuickOpenAmount: string;
    FShoppingLocationId: Integer;
    FShouldNotBeFrozen: string;
    FTreatOpenedAsOutOfStock: string;
  public
    procedure DefaultSetup();
  published
    property Active: string read FActive write FActive;
    property Calories: string read FCalories write FCalories;
    property Cumulate_Min_Stock_Amount_Of_Sub_Products: string read FCumulateMinStockAmountOfSubProducts write FCumulateMinStockAmountOfSubProducts;
    property Default_Best_Before_Days: Integer read FDefaultBestBeforeDays write FDefaultBestBeforeDays;
    property Default_Best_Before_Days_After_Freezing: string read FDefaultBestBeforeDaysAfterFreezing write FDefaultBestBeforeDaysAfterFreezing;
    property Default_Best_Before_Days_After_Open: string read FDefaultBestBeforeDaysAfterOpen write FDefaultBestBeforeDaysAfterOpen;
    property Default_Best_Before_Days_After_Thawing: Integer read FDefaultBestBeforeDaysAfterThawing write FDefaultBestBeforeDaysAfterThawing;
    property Default_Consume_Location_Id: Integer read FDefaultConsumeLocationId write FDefaultConsumeLocationId;
    property Description: string read FDescription write FDescription;
    property Due_Type: string read FDueType write FDueType;
    property Enable_Tare_Weight_Handling: string read FEnableTareWeightHandling write FEnableTareWeightHandling;
    property Hide_On_Stock_Overview: string read FHideOnStockOverview write FHideOnStockOverview;
    property Id: string read FId write FId;
    property Location_Id: Integer read FLocationId write FLocationId;
    property Min_Stock_Amount: string read FMinStockAmount write FMinStockAmount;
    property Move_On_Open: string read FMoveOnOpen write FMoveOnOpen;
    property Name: string read FName write FName;
    property No_Own_Stock: string read FNoOwnStock write FNoOwnStock;
    property Not_Check_Stock_Fulfillment_For_Recipes: string read FNotCheckStockFulfillmentForRecipes write FNotCheckStockFulfillmentForRecipes;
    property Parent_Product_Id: string read FParentProductId write FParentProductId;
    property Product_Group_Id: Integer read FProductGroupId write FProductGroupId;
    property Qu_Id_Consume: Integer read FQuIdConsume write FQuIdConsume;
    property Qu_Id_Price: Integer read FQuIdPrice write FQuIdPrice;
    property Qu_Id_Purchase: Integer read FQuIdPurchase write FQuIdPurchase;
    property Qu_Id_Stock: Integer read FQuIdStock write FQuIdStock;
    property Quick_Consume_Amount: string read FQuickConsumeAmount write FQuickConsumeAmount;
    property Quick_Open_Amount: string read FQuickOpenAmount write FQuickOpenAmount;
    property Shopping_Location_Id: Integer read FShoppingLocationId write FShoppingLocationId;
    property Should_Not_Be_Frozen: string read FShouldNotBeFrozen write FShouldNotBeFrozen;
    property Treat_Opened_As_Out_Of_Stock: string read FTreatOpenedAsOutOfStock write FTreatOpenedAsOutOfStock;
  end;

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

end.

