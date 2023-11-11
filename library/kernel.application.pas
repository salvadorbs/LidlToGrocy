unit kernel.application;

{$mode DelphiUnicode}

interface

uses
  Classes, SysUtils, mormot.core.os, CustApp, Lidl.Ticket, Kernel.Configuration,
  OpenFoodFacts.ProductInfo, Lidl.ItemsLine, mormot.core.json, mormot.core.base,
  Grocy.Service;

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
    FOnHelp: TNotifyEvent;
    FVerbose: Boolean;
    FLidlJson: RawUTf8;
    FLidlTickets: TLidlTicketArray;
    FConfiguration: TConfiguration;
    FGrocyService: TGrocyService;

    function CreateGrocyProduct(const OFFProductInfo: TOFFProductInfo): String;
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
  Grocy.Product, OpenFoodFacts.Service;

{ TGrocyFastLidlAdder }

procedure TLidlToGrocy.DoHelp(Sender: TObject);
begin
  ConsoleWrite(Executable.Command.FullDescription);
end;

function TLidlToGrocy.CreateGrocyProduct(const OFFProductInfo: TOFFProductInfo
  ): String;
var
  GrocyProduct: TGrocyProduct;
begin
  Result := '';

  if Assigned(OFFProductInfo) then
  begin
    GrocyProduct := TGrocyProduct.Create();
    try
      GrocyProduct.DefaultSetup();

      GrocyProduct.Name := OFFProductInfo.ProductName;
      GrocyProduct.Default_Best_Before_Days := FConfiguration.GrocyDefaultBestBeforeDays;
      GrocyProduct.Default_Best_Before_Days_After_Thawing := FConfiguration.GrocyDefaultBestBeforeDaysAfterThawing;
      GrocyProduct.Default_Consume_Location_Id := FConfiguration.GrocyDefaultConsumeLocation;
      GrocyProduct.Location_Id := FConfiguration.GrocyLocationId;
      GrocyProduct.Qu_Id_Consume := FConfiguration.GrocyQuIdConsume;
      GrocyProduct.Qu_Id_Price := FConfiguration.GrocyQuIdPrice;
      GrocyProduct.Qu_Id_Purchase := FConfiguration.GrocyQuIdPurchase;
      GrocyProduct.Qu_Id_Stock := FConfiguration.GrocyQuIdStock;
      GrocyProduct.Shopping_Location_Id := FConfiguration.GrocyShoppingLocationId;

      FGrocyService.CreateProduct(GrocyProduct);
      FGrocyService.AddBarcodeToProduct(GrocyProduct);

      Result := GrocyProduct.Id;
    finally
      GrocyProduct.Free;
    end;
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
  ExistGrocyProduct: TGrocyProduct;
  OFFProductInfo: TOFFProductInfo;
  LidlProduct: TItemsLine;
  ProductId, GrocyProductId: String;
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
      try
        ExistGrocyProduct := FGrocyService.GetProductByBarcode(LidlProduct.CodeInput);
        GrocyProductId := ExistGrocyProduct.Id;
      except
        OFFProductInfo := TOpenFoodFactsService.GetProduct(LidlProduct.CodeInput);
        //TODO: Se OFF va in errore, nessun problema e vai avanti!
        GrocyProductId := CreateGrocyProduct(OFFProductInfo);
      end;

      //TGrocyService.AddProduct(GrocyProductId, LidlProduct.Quantity, LidlProduct.CurrentUnitPrice, LidlTicket.Date);
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
end;

procedure TLidlToGrocy.SetupGrocy;
begin
  FGrocyService := TGrocyService.Create(FGrocyIp, FGrocyPort, FGrocyApiKey);
end;

end.

