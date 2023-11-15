unit kernel.application;

{$mode DelphiUnicode}

interface

uses
  Classes, SysUtils, mormot.core.os, CustApp, Lidl.Ticket, Kernel.Configuration,
  OpenFoodFacts.ProductInfo, Lidl.ItemsLine, mormot.core.json, mormot.core.base,
  Grocy.Service, Grocy.Barcode, Grocy.Product;

type

  TNotifyEvent = procedure(Sender: TObject) of object;

  { TLidlToGrocy }

  TLidlToGrocy = class(TCustomApplication)
  private
    FGrocyApiKey: string;
    FGrocyIp: string;
    FGrocyPort: string;
    FHelp: boolean;
    FLidlJsonFilePath: string;
    FLidlCountry: string;
    FLidlLanguage: string;
    FLidlToken: string;
    FNoOpenFoodFacts: boolean;
    FNoStock: boolean;
    FOnHelp: TNotifyEvent;
    FVerbose: boolean;
    FLidlJson: RawUTf8;
    FLidlTickets: TLidlTicketArray;
    FConfiguration: TConfiguration;
    FGrocyService: TGrocyService;

    procedure AddGrocyProductInStock(const LidlProduct: TItemsLine;
      const GrocyProduct: TGrocyProduct; const LidlTicket: TLidlTicket);
    function AddNewGrocyProduct(LidlProduct: TItemsLine): TGrocyProduct;
    function CreateGrocyProduct(const OFFProductInfo: TOFFProductInfo): TGrocyProduct;
    function CreateGrocyBarcode(const ProductId: integer;
      const Barcode: string): TGrocyBarcode;
    procedure DoHelp(Sender: TObject);
    function GetGrocyProduct(LidlProduct: TItemsLine): TGrocyProduct;
    function GetLidlTickets: string;
    function GetOFFProductInfo(var LidlProduct: TItemsLine): TOFFProductInfo;
  protected
    procedure DoRun; override;
  public
    constructor Create(TheOwner: TComponent); override;
    destructor Destroy; override;

    procedure SetupGrocy;

    property Verbose: boolean read FVerbose write FVerbose;
    property Help: boolean read FHelp write FHelp;
    property NoStock: boolean read FNoStock write FNoStock;
    property NoOpenFoodFacts: boolean read FNoOpenFoodFacts write FNoOpenFoodFacts;

    property GrocyIp: string read FGrocyIp write FGrocyIp;
    property GrocyPort: string read FGrocyPort write FGrocyPort;
    property GrocyApiKey: string read FGrocyApiKey write FGrocyApiKey;

    property LidlCountry: string read FLidlCountry write FLidlCountry;
    property LidlLanguage: string read FLidlLanguage write FLidlLanguage;
    property LidlToken: string read FLidlToken write FLidlToken;

    property LidlJsonFilePath: string read FLidlJsonFilePath write FLidlJsonFilePath;

    property OnHelp: TNotifyEvent read FOnHelp write FOnHelp;
  end;

const
  LIDL_PLUS_COMMANDLINE =
    'lidl-plus --language=%s --country=%s --refresh-token=%s receipt --all';

implementation

uses
  OpenFoodFacts.Service, Grocy.ProductStock, DateUtils;

  { TGrocyFastLidlAdder }

procedure TLidlToGrocy.DoHelp(Sender: TObject);
begin
  ConsoleWrite(Executable.Command.FullDescription);
end;

function TLidlToGrocy.GetGrocyProduct(LidlProduct: TItemsLine): TGrocyProduct;
var
  GrocyProduct: TGrocyProduct;
begin
  GrocyProduct := nil;
  try
    GrocyProduct := FGrocyService.GetProductByBarcode(LidlProduct.CodeInput);
  except
    //In case of product doesn't exists in Grocy
    GrocyProduct := AddNewGrocyProduct(LidlProduct);
  end;

  Result := GrocyProduct;
end;

function TLidlToGrocy.CreateGrocyProduct(
  const OFFProductInfo: TOFFProductInfo): TGrocyProduct;
var
  GrocyProduct: TGrocyProduct;
begin
  Result := nil;

  GrocyProduct := TGrocyProduct.Create();
  try
    GrocyProduct.DefaultSetup();

    GrocyProduct.Name := OFFProductInfo.ProductName;
    with FConfiguration do
    begin
      Result.Name := OFFProductInfo.ProductName;
      Result.DefaultBestBeforeDays := IntToStr(GrocyDefaultBestBeforeDays);
      Result.DefaultBestBeforeDaysAfterThawing := IntToStr(GrocyDefaultBestBeforeDaysAfterThawing);
      Result.DefaultConsumeLocationId := IntToStr(GrocyDefaultConsumeLocation);
      Result.LocationId := IntToStr(GrocyLocationId);
      Result.QuIdConsume := IntToStr(GrocyQuIdConsume);
      Result.QuIdPrice := IntToStr(GrocyQuIdPrice);
      Result.QuIdPurchase := IntToStr(GrocyQuIdPurchase);
      Result.QuIdStock := IntToStr(GrocyQuIdStock);
      Result.ShoppingLocationId := IntToStr(GrocyShoppingLocationId);
    end;
  finally
    Result := GrocyProduct;
  end;
end;

function TLidlToGrocy.AddNewGrocyProduct(LidlProduct: TItemsLine): TGrocyProduct;
var
  GrocyBarcode: TGrocyBarcode;
  OFFProductInfo: TOFFProductInfo;
  GrocyProduct: TGrocyProduct;
begin
  OFFProductInfo := GetOFFProductInfo(LidlProduct);
  GrocyProduct := nil;
  GrocyBarcode := nil;

  try
    GrocyProduct := CreateGrocyProduct(OFFProductInfo);
    GrocyProduct.Id := FGrocyService.CreateProduct(GrocyProduct);

    GrocyBarcode := CreateGrocyBarcode(GrocyProduct.Id, LidlProduct.CodeInput);
    FGrocyService.AddBarcodeToProduct(GrocyBarcode);
  finally
    OFFProductInfo.Free;
    GrocyBarcode.Free;
  end;

  Result := GrocyProduct;
end;

procedure TLidlToGrocy.AddGrocyProductInStock(const LidlProduct: TItemsLine;
  const GrocyProduct: TGrocyProduct; const LidlTicket: TLidlTicket);
var
  GrocyProductStock: TGrocyProductStock;
begin
  if not (FNoStock) then
  begin
    GrocyProductStock := TGrocyProductStock.Create(LidlProduct.Quantity,
      IncDay(LidlTicket.Date, FConfiguration.GrocyDefaultBestBeforeDays),
      LidlProduct.CurrentUnitPrice, 'purchase', LidlTicket.Date);
    try
      FGrocyService.AddProductInStock(GrocyProduct.Id, GrocyProductStock);
    finally
      GrocyProductStock.Free;
    end;
  end;
end;

function TLidlToGrocy.CreateGrocyBarcode(const ProductId: integer;
  const Barcode: string): TGrocyBarcode;
var
  GrocyBarcode: TGrocyBarcode;
begin
  Result := nil;

  GrocyBarcode := TGrocyBarcode.Create();
  try
    GrocyBarcode.Amount := '1';
    GrocyBarcode.Barcode := Barcode;
    GrocyBarcode.ProductId := ProductId;
    GrocyBarcode.ShoppingLocationId := FConfiguration.GrocyShoppingLocationId;
    GrocyBarcode.QuId := '1';
    GrocyBarcode.Note := 'Automatically created by LidlToGrocy';
  finally
    Result := GrocyBarcode;
  end;
end;

function TLidlToGrocy.GetLidlTickets(): string;
var
  output: string;
begin
  Result := '';
  if (FLidlToken <> '') then
  begin
    output := RunRedirect(Format(LIDL_PLUS_COMMANDLINE,
      [FLidlLanguage, FLidlCountry, FLidlToken]));
    if output <> '' then
    begin
      //TODO throw error and terminate
      Result := output;
    end;
  end
  else
  begin
    //TODO throw error and terminate
  end;
end;

function TLidlToGrocy.GetOFFProductInfo(var LidlProduct: TItemsLine): TOFFProductInfo;
var
  OFFProductInfo: TOFFProductInfo;
begin
  OFFProductInfo := nil;
  if not NoOpenFoodFacts then
  begin
    try
      OFFProductInfo := TOpenFoodFactsService.GetProduct(LidlProduct.CodeInput);
    except
    end;
  end;

  if OFFProductInfo = nil then
    OFFProductInfo := TOFFProductInfo.Create();

  // I manually enter the name in these two cases:
  // - In case of valid code, but product not found, OFF returns 404 with error message
  // - In case of invalid code, OFF returns 200 with error message, so .ProductName will be blank
  if OFFProductInfo.ProductName = '' then
    OFFProductInfo.ProductName := LidlProduct.Name;

  Result := OFFProductInfo;
end;

procedure TLidlToGrocy.DoRun;
var
  LidlTicket: TLidlTicket;
  GrocyProduct: TGrocyProduct;
  LidlProduct: TItemsLine;
begin
  if (FLidlJsonFilePath <> '') and FileExists(FLidlJsonFilePath) then
    FLidlJson := StringFromFile(FLidlJsonFilePath)
  else
    FLidlJson := GetLidlTickets();

  DynArrayLoadJson(FLidlTickets, FLidlJson, TypeInfo(TLidlTicketArray));

  for LidlTicket in FLidlTickets do
  begin
    for LidlProduct in LidlTicket.ItemsLine do
    begin
      GrocyProduct := nil;
      try
        GrocyProduct := GetGrocyProduct(LidlProduct);

        if Assigned(GrocyProduct) then
          AddGrocyProductInStock(LidlProduct, GrocyProduct, LidlTicket);
      finally
        if Assigned(GrocyProduct) then
          GrocyProduct.Free;
      end;
    end;
  end;
  //boolOpts := Length(Executable.Command.Options) > 0;
  //if boolOpts then
  //begin
  //  if FHelp then
  //    FOnHelp(Self)
  //  else
  //    TOpenFoodFactsService.GetProduct('3017620422003');

  //  Executable.Command.ConsoleWriteUnknown();
  //end
  //else
  //  ConsoleWrite(Executable.Command.FullDescription());
  //end;

  Terminate;
end;

constructor TLidlToGrocy.Create(TheOwner: TComponent);
begin
  inherited Create(TheOwner);
  StopOnException := True;

  Self.FOnHelp := DoHelp;

  FLidlTickets := nil;
  FLidlJson := '';

  FConfiguration := TConfiguration.Create;
  FConfiguration.LoadConfig;
end;

destructor TLidlToGrocy.Destroy;
var
  I: integer;
begin
  if Assigned(FLidlTickets) then
  begin
    for I := 0 to length(FLidlTickets) - 1 do
      FLidlTickets[I].Free;
    SetLength(FLidlTickets, 0);
  end;

  FConfiguration.Free;
  FGrocyService.Free;

  inherited Destroy;
end;

procedure TLidlToGrocy.SetupGrocy;
begin
  FGrocyService := TGrocyService.Create(FGrocyIp, FGrocyPort, FGrocyApiKey);
end;

end.
