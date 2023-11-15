unit Kernel.Configuration;

{$mode DelphiUnicode}

interface

uses
  Classes, SysUtils, jsonConf;

type

  { TConfiguration }
  TConfiguration = class
  private
    FGrocyDefaultBestBeforeDays: integer;
    FGrocyDefaultBestBeforeDaysAfterThawing: integer;
    FGrocyDefaultConsumeLocation: integer;
    FGrocyLocationId: integer;
    FGrocyQuIdConsume: integer;
    FGrocyQuIdPrice: integer;
    FGrocyQuIdPurchase: integer;
    FGrocyQuIdStock: integer;
    FGrocyShoppingLocationId: integer;

    procedure RestoreSettings(AJSONConfig: TJSONConfig);
    procedure SaveSettings(AJSONConfig: TJSONConfig);
  public
    constructor Create; overload;
    destructor Destroy; override;

    property GrocyLocationId: integer read FGrocyLocationId write FGrocyLocationId;
    property GrocyDefaultConsumeLocation: integer read FGrocyDefaultConsumeLocation write FGrocyDefaultConsumeLocation;
    property GrocyShoppingLocationId: integer read FGrocyShoppingLocationId write FGrocyShoppingLocationId;
    property GrocyDefaultBestBeforeDays: integer read FGrocyDefaultBestBeforeDays write FGrocyDefaultBestBeforeDays;
    property GrocyDefaultBestBeforeDaysAfterThawing: integer
      read FGrocyDefaultBestBeforeDaysAfterThawing write FGrocyDefaultBestBeforeDaysAfterThawing;
    property GrocyQuIdStock: integer read FGrocyQuIdStock write FGrocyQuIdStock;
    property GrocyQuIdPurchase: integer read FGrocyQuIdPurchase write FGrocyQuIdPurchase;
    property GrocyQuIdConsume: integer read FGrocyQuIdConsume write FGrocyQuIdConsume;
    property GrocyQuIdPrice: integer read FGrocyQuIdPrice write FGrocyQuIdPrice;

    procedure LoadConfig;
    procedure SaveConfig;
  end;

const
  CONFIG_GROCY_LOCATIONID = 'grocy/location_id';
  CONFIG_GROCY_DEFAULTCONSUMELOCATION = 'grocy/default_consume_location';
  CONFIG_GROCY_SHOPPINGLOCATIONID = 'grocy/shopping_location_id';
  CONFIG_GROCY_DEFAULTBESTBEFOREDAYS = 'grocy/default_best_before_days';
  CONFIG_GROCY_DEFAULTBESTBEFOREDAYSAFTERTHAWING = 'grocy/default_best_before_days_after_thawing';
  CONFIG_GROCY_QUIDSTOCK = 'grocy/qu_id_stock';
  CONFIG_GROCY_QUIDPURCHASE = 'grocy/qu_id_purchase';
  CONFIG_GROCY_QUIDCONSUME = 'grocy/qu_id_consume';
  CONFIG_GROCY_QUIDPRICE = 'grocy/qu_id_price';

implementation

{ TConfiguration }

procedure TConfiguration.RestoreSettings(AJSONConfig: TJSONConfig);
begin
  GrocyLocationId := AJSONConfig.GetValue(CONFIG_GROCY_LOCATIONID, Self.GrocyLocationId);
  GrocyDefaultConsumeLocation := AJSONConfig.GetValue(CONFIG_GROCY_DEFAULTCONSUMELOCATION,
    Self.GrocyDefaultConsumeLocation);
  GrocyShoppingLocationId := AJSONConfig.GetValue(CONFIG_GROCY_SHOPPINGLOCATIONID, Self.GrocyShoppingLocationId);
  GrocyDefaultBestBeforeDays := AJSONConfig.GetValue(CONFIG_GROCY_DEFAULTBESTBEFOREDAYS,
    Self.GrocyDefaultBestBeforeDays);
  GrocyDefaultBestBeforeDaysAfterThawing :=
    AJSONConfig.GetValue(CONFIG_GROCY_DEFAULTBESTBEFOREDAYSAFTERTHAWING, Self.GrocyDefaultBestBeforeDaysAfterThawing);
  GrocyQuIdStock := AJSONConfig.GetValue(CONFIG_GROCY_QUIDSTOCK, Self.GrocyQuIdStock);
  GrocyQuIdPurchase := AJSONConfig.GetValue(CONFIG_GROCY_QUIDPURCHASE, Self.GrocyQuIdPurchase);
  GrocyQuIdConsume := AJSONConfig.GetValue(CONFIG_GROCY_QUIDCONSUME, Self.GrocyQuIdConsume);
  GrocyQuIdPrice := AJSONConfig.GetValue(CONFIG_GROCY_QUIDPRICE, Self.GrocyQuIdPrice);
end;

procedure TConfiguration.SaveSettings(AJSONConfig: TJSONConfig);
begin
  AJSONConfig.SetValue(CONFIG_GROCY_LOCATIONID, Self.GrocyLocationId);
  AJSONConfig.SetValue(CONFIG_GROCY_DEFAULTCONSUMELOCATION, Self.GrocyDefaultConsumeLocation);
  AJSONConfig.SetValue(CONFIG_GROCY_SHOPPINGLOCATIONID, Self.GrocyShoppingLocationId);
  AJSONConfig.SetValue(CONFIG_GROCY_DEFAULTBESTBEFOREDAYS, Self.GrocyDefaultBestBeforeDays);
  AJSONConfig.SetValue(CONFIG_GROCY_DEFAULTBESTBEFOREDAYSAFTERTHAWING, Self.GrocyDefaultBestBeforeDaysAfterThawing);
  AJSONConfig.SetValue(CONFIG_GROCY_QUIDSTOCK, Self.GrocyQuIdStock);
  AJSONConfig.SetValue(CONFIG_GROCY_QUIDPURCHASE, Self.GrocyQuIdPurchase);
  AJSONConfig.SetValue(CONFIG_GROCY_QUIDCONSUME, Self.GrocyQuIdConsume);
  AJSONConfig.SetValue(CONFIG_GROCY_QUIDPRICE, Self.GrocyQuIdPrice);
end;

constructor TConfiguration.Create;
begin
  FGrocyLocationId := 2;
  FGrocyDefaultConsumeLocation := 1;
  FGrocyShoppingLocationId := 1;
  FGrocyDefaultBestBeforeDays := 5;
  FGrocyDefaultBestBeforeDaysAfterThawing := 0;
  FGrocyQuIdStock := 2;
  FGrocyQuIdPurchase := 3;
  FGrocyQuIdConsume := 2;
  FGrocyQuIdPrice := 3;
end;

destructor TConfiguration.Destroy;
begin
  inherited Destroy;
end;

procedure TConfiguration.LoadConfig;
var
  JSONConfig: TJSONConfig;
begin
  JSONConfig := TJSONConfig.Create(nil);
  try
    JSONConfig.Formatted := True;
    JSONConfig.FormatIndentsize := 4;
    JSONConfig.Filename := IncludeLeadingPathDelimiter(GetCurrentDir) + 'settings.json';

    RestoreSettings(JSONConfig);
  finally
    JSONConfig.Free;
  end;
end;

procedure TConfiguration.SaveConfig;
var
  JSONConfig: TJSONConfig;
begin
  JSONConfig := TJSONConfig.Create(nil);
  try
    JSONConfig.Formatted := True;
    JSONConfig.FormatIndentsize := 4;

    JSONConfig.Filename := IncludeLeadingPathDelimiter(GetCurrentDir) + 'settings.json';
    SaveSettings(JSONConfig);
  finally
    JSONConfig.Free;
  end;
end;

end.
