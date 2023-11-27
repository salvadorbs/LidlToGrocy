unit kernel.application;

{$mode DelphiUnicode}

interface

uses
  Classes, SysUtils, mormot.core.os, CustApp, Lidl.Ticket, Kernel.Configuration,
  OpenFoodFacts.ProductInfo, Lidl.ItemsLine, mormot.core.json, mormot.core.base,
  Grocy.Service, Grocy.Barcode, Grocy.Product, mormot.core.log, Math;

type

  TNotifyEvent = procedure(Sender: TObject) of object;

  { TLidlToGrocy }

  TLidlToGrocy = class(TCustomApplication)
  private
    FConsumeNow: boolean;
    FGrocyApiKey: string;
    FGrocyIp: string;
    FGrocyPort: string;
    FHelp: boolean;
    FLidlJsonFilePath: string;
    FLidlCountry: string;
    FLidlLanguage: string;
    FLidlToken: string;
    FNoOpenFoodFacts: boolean;
    FNoProductPicture: boolean;
    FNoStock: boolean;
    FOnHelp: TNotifyEvent;
    FSaveLidlJson: boolean;
    FVerbose: boolean;
    FLidlJson: RawUTf8;
    FLidlTickets: TLidlTicketArray;
    FConfiguration: TConfiguration;
    FGrocyService: TGrocyService;

    procedure AddGrocyProductInStock(const LidlProduct: TItemsLine; const GrocyProduct: TGrocyProduct;
      const LidlTicket: TLidlTicket);
    function AddNewGrocyProduct(LidlProduct: TItemsLine): TGrocyProduct;
    procedure ConsumeGrocyProduct(LidlProduct: TItemsLine);
    procedure DoHelp(Sender: TObject);
    function InsertOFFImageInGrocy(OFFProductInfo: TOFFProductInfo): boolean;
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
    property ConsumeNow: boolean read FConsumeNow write FConsumeNow;
    property NoStock: boolean read FNoStock write FNoStock;
    property NoOpenFoodFacts: boolean read FNoOpenFoodFacts write FNoOpenFoodFacts;
    property NoProductPicture: boolean read FNoProductPicture write FNoProductPicture;
    property SaveLidlJson: boolean read FSaveLidlJson write FSaveLidlJson;

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
  OpenFoodFacts.Service, Grocy.ProductStock, DateUtils, Kernel.Logger;

  { TGrocyFastLidlAdder }

procedure TLidlToGrocy.DoHelp(Sender: TObject);
begin
  ConsoleWrite(Executable.Command.FullDescription);
end;

function TLidlToGrocy.InsertOFFImageInGrocy(OFFProductInfo: TOFFProductInfo): boolean;
var
  ImageStream: TStream;
begin
  Result := False;
  if (OFFProductInfo.ImageUrl = '') then
    Exit;

  ImageStream := TOpenFoodFactsService.DownloadImage(OFFProductInfo);

  try
    Result := FGrocyService.UploadImageFile(ImageStream, OFFProductInfo.Code + '.jpg');
  finally
    TLogger.Info('Downloaded and uploaded product image in Grocy', []);
  end;
end;

function TLidlToGrocy.GetGrocyProduct(LidlProduct: TItemsLine): TGrocyProduct;
var
  GrocyProduct: TGrocyProduct;
begin
  TLogger.Info('Find product in Grocy', []);
  GrocyProduct := nil;
  try
    GrocyProduct := FGrocyService.GetProductByBarcode(LidlProduct.CodeInput);
    TLogger.Info('Found! Grocy Product ID = %d', [GrocyProduct.Id]);
  except
    TLogger.Info('Not found!', []);
    //In case of product doesn't exists in Grocy
    GrocyProduct := AddNewGrocyProduct(LidlProduct);
  end;

  Result := GrocyProduct;
end;

function TLidlToGrocy.AddNewGrocyProduct(LidlProduct: TItemsLine): TGrocyProduct;
var
  GrocyBarcode: TGrocyBarcode;
  OFFProductInfo: TOFFProductInfo;
  GrocyProduct: TGrocyProduct;
begin
  TLogger.InfoEnter('Create a new product with barcode %s', [LidlProduct.CodeInput]);
  TLogger.Info('Call OpenFoodFacts to get some informations', []);

  GrocyProduct := nil;
  GrocyBarcode := nil;

  try
    OFFProductInfo := GetOFFProductInfo(LidlProduct);
    try
      TLogger.Info('Insert product %s in Grocy', [OFFProductInfo.ProductName]);

      if not (NoProductPicture) then
        InsertOFFImageInGrocy(OFFProductInfo);

      GrocyProduct := FGrocyService.CreateProduct(OFFProductInfo);

      if Assigned(GrocyProduct) then
        GrocyBarcode := FGrocyService.AddBarcodeToProduct(GrocyProduct.Id, LidlProduct.CodeInput);
    finally
      OFFProductInfo.Free;
      GrocyBarcode.Free;
    end;
  except
    on E: Exception do
      TLogger.Exception(E);
  end;

  Result := GrocyProduct;
  if Assigned(GrocyProduct) then
    TLogger.InfoExit('Product inserted in Grocy. ID = %d', [GrocyProduct.Id]);
end;

procedure TLidlToGrocy.ConsumeGrocyProduct(LidlProduct: TItemsLine);
begin
  if (FConsumeNoW) then
  begin
    TLogger.Info('Consume product now', [LidlProduct.Quantity]);
    FGrocyService.ConsumeByBarcode(LidlProduct.CodeInput, StrToInt(LidlProduct.Quantity));
  end;
end;

procedure TLidlToGrocy.AddGrocyProductInStock(const LidlProduct: TItemsLine;
  const GrocyProduct: TGrocyProduct; const LidlTicket: TLidlTicket);
var
  GrocyProductStock: TGrocyProductStock;
begin
  if not (FNoStock) then
  begin
    TLogger.Info('Adding quantity (%s) in Grocy', [LidlProduct.Quantity]);
    GrocyProductStock := TGrocyProductStock.Create(LidlProduct.Quantity,
      IncDay(LidlTicket.Date, FConfiguration.GrocyDefaultBestBeforeDays), LidlProduct.CurrentUnitPrice,
      'purchase', LidlTicket.Date, IntToStr(FConfiguration.GrocyShoppingLocationId));
    try
      if not FGrocyService.AddProductInStock(GrocyProduct.Id, GrocyProductStock) then
        TLogger.Error('Error adding quantity to product in Grocy', []);
    finally
      GrocyProductStock.Free;
    end;
  end;
end;

function TLidlToGrocy.GetLidlTickets(): string;
var
  output: string;
begin
  Result := '';
  if (FLidlToken <> '') then
  begin
    TLogger.Info('Run python script lidl-plus with parameters [%s, %s, %s]',
      [FLidlLanguage, FLidlCountry, FLidlToken]);
    output := RunRedirect(Format(LIDL_PLUS_COMMANDLINE, [FLidlLanguage, FLidlCountry, FLidlToken]));
    if output <> '' then
    begin
      Result := output;
      if SaveLidlJson then
        FileFromString(output, 'lidl.json');
    end;
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
      TLogger.Error('Product not found in OpenFoodFacts', []);
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
  Value: double;
begin
  if ((FGrocyApiKey = '') or (FLidlToken = '') or (FGrocyApiKey = '')) then
  begin
    ConsoleWrite(Executable.Command.FullDescription);
    Terminate;

    Exit;
  end;

  if (FLidlJsonFilePath <> '') and FileExists(FLidlJsonFilePath) then
  begin
    TLogger.Info('Loading json from file %s', [FLidlJsonFilePath]);
    FLidlJson := StringFromFile(FLidlJsonFilePath);
  end
  else begin
    TLogger.Info('Get Json from LidlPlus web site', []);
    FLidlJson := GetLidlTickets();
  end;

  TLogger.Debug('Loading JSON', []);

  DynArrayLoadJson(FLidlTickets, FLidlJson, TypeInfo(TLidlTicketArray));

  if (Length(FLidlTickets) = 0) then
    TLogger.Error('Invalid lidl json file', []);

  for LidlTicket in FLidlTickets do
  begin
    if (FConfiguration.LidlTickets.IndexOf(LidlTicket.BarCode) <> -1) then
    begin
      TLogger.Info('LIDL receipt already inserted in Grocy (barcode %s). I move on to the next one',
        [LidlTicket.BarCode]);
      continue;
    end;

    TLogger.InfoEnter('Started processing LIDL receipt (barcode %s)', [LidlTicket.BarCode]);
    for LidlProduct in LidlTicket.ItemsLine do
    begin
      TLogger.InfoEnter('Started processing item (barcode %s)', [LidlProduct.CodeInput]);
      GrocyProduct := nil;
      try
        if TryStrToFloat(LidlProduct.Quantity, Value) and (frac(Value) <> 0) then
          LidlProduct.Quantity := IntToStr(Ceil(Value));

        GrocyProduct := GetGrocyProduct(LidlProduct);

        if Assigned(GrocyProduct) then
        begin
          AddGrocyProductInStock(LidlProduct, GrocyProduct, LidlTicket);
          ConsumeGrocyProduct(LidlProduct);
        end;
      finally
        if Assigned(GrocyProduct) then
          GrocyProduct.Free;
      end;
      TLogger.InfoExit('Completed processing', []);
    end;

    FConfiguration.LidlTickets.Add(LidlTicket.BarCode);
    FConfiguration.SaveConfig;

    TLogger.InfoExit('Completed processing', []);

    Sleep(30000);
  end;

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
  FConfiguration.SaveConfig;

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
  FGrocyService := TGrocyService.Create(FGrocyIp, FGrocyPort, FGrocyApiKey, FConfiguration);
end;

end.
