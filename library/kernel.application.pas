unit kernel.application;

{$mode DelphiUnicode}

interface

uses
  Classes, SysUtils, mormot.core.os, CustApp, Lidl.Ticket, Kernel.Configuration,
  OpenFoodFacts.ProductInfo, Lidl.ItemsLine, mormot.core.json, mormot.core.base,
  Grocy.Service, Grocy.Barcode, Grocy.Product, Grocy.Root;

type

  TNotifyEvent = procedure(Sender: TObject) of object;

  { TLidlToGrocy }

  TLidlToGrocy = class(TCustomApplication)
  private
    FGrocyApiKey: String;
    FGrocyIp: String;
    FGrocyPort: String;
    FHelp: Boolean;
    FLidlJsonFilePath: String;
    FLidlCountry: String;
    FLidlLanguage: String;
    FLidlToken: String;
    FNoStock: Boolean;
    FOnHelp: TNotifyEvent;
    FVerbose: Boolean;
    FLidlJson: RawUTf8;
    FLidlTickets: TLidlTicketArray;
    FConfiguration: TConfiguration;
    FGrocyService: TGrocyService;

    procedure AddGrocyProductInStock(const LidlProduct: TItemsLine;
      const GrocyProduct: TGrocyProduct; const LidlTicket: TLidlTicket);
    function AddNewGrocyProduct(LidlProduct: TItemsLine): TGrocyProduct;
    function CreateGrocyProduct(const OFFProductInfo: TOFFProductInfo): TGrocyProduct;
    function CreateGrocyBarcode(const ProductId: Integer; const Barcode: String
      ): TGrocyBarcode;
    procedure DoHelp(Sender: TObject);
    function GetLidlTickets: String;
  protected
    procedure DoRun; override;
  public
    constructor Create(TheOwner: TComponent); override;
    destructor Destroy; override;

    procedure SetupGrocy;

    property Verbose: Boolean read FVerbose write FVerbose;
    property Help: Boolean read FHelp write FHelp;
    property NoStock: Boolean read FNoStock write FNoStock;

    property GrocyIp: String read FGrocyIp write FGrocyIp;
    property GrocyPort: String read FGrocyPort write FGrocyPort;
    property GrocyApiKey: String read FGrocyApiKey write FGrocyApiKey;

    property LidlCountry: String read FLidlCountry write FLidlCountry;
    property LidlLanguage: String read FLidlLanguage write FLidlLanguage;
    property LidlToken: String read FLidlToken write FLidlToken;

    property LidlJsonFilePath: String read FLidlJsonFilePath write FLidlJsonFilePath;

    property OnHelp: TNotifyEvent read FOnHelp write FOnHelp;
  end;

const
  LIDL_PLUS_COMMANDLINE = 'lidl-plus --language=%s --country=%s --refresh-token=%s receipt --all';

implementation

uses
  OpenFoodFacts.Service, Grocy.ProductStock, DateUtils;

{ TGrocyFastLidlAdder }

procedure TLidlToGrocy.DoHelp(Sender: TObject);
begin
  ConsoleWrite(Executable.Command.FullDescription);
end;

function TLidlToGrocy.CreateGrocyProduct(const OFFProductInfo: TOFFProductInfo
  ): TGrocyProduct;
var
  GrocyProduct: TGrocyProduct;
begin
  Result := nil;

  GrocyProduct := TGrocyProduct.Create();
  try
    GrocyProduct.DefaultSetup();

    GrocyProduct.Name := OFFProductInfo.ProductName;
    GrocyProduct.DefaultBestBeforeDays := IntToStr(FConfiguration.GrocyDefaultBestBeforeDays);
    GrocyProduct.DefaultBestBeforeDaysAfterThawing := IntToStr(FConfiguration.GrocyDefaultBestBeforeDaysAfterThawing);
    GrocyProduct.DefaultConsumeLocationId := IntToStr(FConfiguration.GrocyDefaultConsumeLocation);
    GrocyProduct.LocationId := IntToStr(FConfiguration.GrocyLocationId);
    GrocyProduct.QuIdConsume := IntToStr(FConfiguration.GrocyQuIdConsume);
    GrocyProduct.QuIdPrice := IntToStr(FConfiguration.GrocyQuIdPrice);
    GrocyProduct.QuIdPurchase := IntToStr(FConfiguration.GrocyQuIdPurchase);
    GrocyProduct.QuIdStock := IntToStr(FConfiguration.GrocyQuIdStock);
    GrocyProduct.ShoppingLocationId := IntToStr(FConfiguration.GrocyShoppingLocationId);
  finally
    Result := GrocyProduct;
  end;
end;

function TLidlToGrocy.AddNewGrocyProduct(LidlProduct: TItemsLine
  ): TGrocyProduct;
var
  GrocyBarcode: TGrocyBarcode;
  OFFProductInfo: TOFFProductInfo;
  GrocyProduct: TGrocyProduct;
begin
  try
    OFFProductInfo := TOpenFoodFactsService.GetProduct(LidlProduct.CodeInput);
  except
    OFFProductInfo := TOFFProductInfo.Create();
    OFFProductInfo.ProductName := LidlProduct.Name;
  end;

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
  if not(FNoStock) then
  begin
    GrocyProductStock := TGrocyProductStock.Create(LidlProduct.Quantity, IncDay(LidlTicket.Date, FConfiguration.GrocyDefaultBestBeforeDays), LidlProduct.CurrentUnitPrice, 'purchase', LidlTicket.Date);
    try
      FGrocyService.AddProductInStock(GrocyProduct.Id, GrocyProductStock);
    finally
      GrocyProductStock.Free;
    end;
  end;
end;

function TLidlToGrocy.CreateGrocyBarcode(const ProductId: Integer;
  const Barcode: String): TGrocyBarcode;
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

function TLidlToGrocy.GetLidlTickets(): String;
var
  output: String;
begin
  Result := '';
  if (FLidlToken <> '') then
  begin
    output := RunRedirect(Format(LIDL_PLUS_COMMANDLINE, [FLidlLanguage, FLidlCountry, FLidlToken]));
    if output <> '' then
    begin
      //TODO throw error and terminate
      Result := output;
    end;
  end
  else begin
    //TODO throw error and terminate
  end;
end;

procedure TLidlToGrocy.DoRun;
var
  LidlTicket: TLidlTicket;
  GrocyProduct: TGrocyProduct;
  LidlProduct: TItemsLine;
  GrocyRoot: TGrocyRoot;
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
      GrocyRoot := nil;
      GrocyProduct := nil;
      try
        try
          GrocyRoot := FGrocyService.GetProductByBarcode(LidlProduct.CodeInput);
          GrocyProduct := GrocyRoot.Product;
        except
          GrocyProduct := AddNewGrocyProduct(LidlProduct);
        end;

        if Assigned(GrocyProduct) then
           AddGrocyProductInStock(LidlProduct, GrocyProduct, LidlTicket);
      finally
        if Assigned(GrocyRoot) then
          GrocyRoot.Free;
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
  //
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
  StopOnException:=True;

  Self.FOnHelp := DoHelp;

  FLidlTickets := nil;
  FLidlJson := '';

  FConfiguration := TConfiguration.Create;
  FConfiguration.LoadConfig;
end;

destructor TLidlToGrocy.Destroy;
var
  I: Integer;
begin
  inherited Destroy;

  if Assigned(FLidlTickets) then
  begin
    for I := 0 to length(FLidlTickets) - 1 do
      FLidlTickets[I].Free;
  end;

  FGrocyService.Free;
end;

procedure TLidlToGrocy.SetupGrocy;
begin
  FGrocyService := TGrocyService.Create(FGrocyIp, FGrocyPort, FGrocyApiKey);
end;

end.

