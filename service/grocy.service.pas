unit Grocy.Service;

{$mode DelphiUnicode}

interface

uses
  Classes, SysUtils, Grocy.Product, mormot.core.json, fphttpclient, base64, ssockets,
  opensslsockets, mormot.core.os, mormot.core.Text, mormot.core.base,
  Grocy.Barcode, Grocy.ProductStock, OpenFoodFacts.ProductInfo, Kernel.Configuration;

type

  { TGrocyService }

  TGrocyService = class
  private
    FConfiguration: TConfiguration;
    FHost: string;
    FPort: string;
    FApiKey: string;
    FClient: TFPHTTPClient;
    function CreateGrocyProduct(const OFFProductInfo: TOFFProductInfo): TGrocyProduct;
    function CreateGrocyBarcode(const ProductId: integer; const Barcode: string): TGrocyBarcode;
    procedure FreeRequestBody;
    function GetBaseUrl: string;
    function GetGrocyProductFromJson(const Response: string): TGrocyProduct;
    function GetIdFromJsonGrocy(const Response: string; Field: string): integer;
  public
    constructor Create(Host: string; Port: string; ApiKey: string; Configuration: TConfiguration);
    destructor Destroy; override;

    property BaseUrl: string read GetBaseUrl;

    function CreateProduct(OFFProductInfo: TOFFProductInfo): TGrocyProduct;
    function AddBarcodeToProduct(const ProductId: integer; const Barcode: string): TGrocyBarcode;
    function GetProductByBarcode(Barcode: string): TGrocyProduct;
    function AddProductInStock(GrocyProductId: integer; ProductStock: TGrocyProductStock): boolean;
    function GetProductByName(Name: string): TGrocyProduct;
    function ConsumeByBarcode(Barcode: string; Amount: integer): boolean;
    function UploadImageFile(ImageStream: TStream; FileName: string): boolean;
  end;

const
  UrlProductByBarcode: string = 'stock/products/by-barcode/%s';
  UrlProductByName: string = 'objects/products?query[]=product.name=%s&limit=1';
  UrlCreateProduct: string = 'objects/products';
  UrlAddBarcode: string = 'objects/product_barcodes';
  UrlAddProductStock: string = 'stock/products/%d/add';
  UrlConsumeByBarcode: string = 'stock/products/by-barcode/%s/consume';
  UrlUploadFile: string = 'files/productpictures/%s';

implementation

uses
  fpjson, jsonparser, mormot.net.client, grocy.error, kernel.logger;

  { TGrocyService }

function TGrocyService.CreateGrocyProduct(const OFFProductInfo: TOFFProductInfo): TGrocyProduct;
var
  GrocyProduct: TGrocyProduct;
begin
  Result := nil;

  GrocyProduct := TGrocyProduct.Create();
  try
    GrocyProduct.DefaultSetup();

    GrocyProduct.Name := OFFProductInfo.ProductName;
    if (OFFProductInfo.ImageUrl <> '') then
      GrocyProduct.PictureFileName := OFFProductInfo.Code + '.jpg';

    with FConfiguration do
    begin
      GrocyProduct.Name := OFFProductInfo.ProductName;
      GrocyProduct.DefaultBestBeforeDays := IntToStr(GrocyDefaultBestBeforeDays);
      GrocyProduct.DefaultBestBeforeDaysAfterThawing := IntToStr(GrocyDefaultBestBeforeDaysAfterThawing);
      GrocyProduct.DefaultConsumeLocationId := IntToStr(GrocyDefaultConsumeLocation);
      GrocyProduct.LocationId := IntToStr(GrocyLocationId);
      GrocyProduct.QuIdConsume := IntToStr(GrocyQuIdConsume);
      GrocyProduct.QuIdPrice := IntToStr(GrocyQuIdPrice);
      GrocyProduct.QuIdPurchase := IntToStr(GrocyQuIdPurchase);
      GrocyProduct.QuIdStock := IntToStr(GrocyQuIdStock);
      GrocyProduct.ShoppingLocationId := IntToStr(GrocyShoppingLocationId);
    end;
  finally
    Result := GrocyProduct;
  end;
end;

function TGrocyService.CreateGrocyBarcode(const ProductId: integer; const Barcode: string): TGrocyBarcode;
var
  GrocyBarcode: TGrocyBarcode;
begin
  Result := nil;

  GrocyBarcode := TGrocyBarcode.Create();
  try
    GrocyBarcode.DefaultSetup();
    GrocyBarcode.Barcode := Barcode;
    GrocyBarcode.ProductId := ProductId;
    GrocyBarcode.ShoppingLocationId := FConfiguration.GrocyShoppingLocationId;
  finally
    Result := GrocyBarcode;
  end;
end;

procedure TGrocyService.FreeRequestBody;
begin
  FClient.RequestBody.Free;
  FClient.RequestBody := nil;
end;

function TGrocyService.GetBaseUrl: string;
begin
  Result := Format('http://%s:%s/api/', [FHost, FPort]);
end;

function TGrocyService.GetGrocyProductFromJson(const Response: string): TGrocyProduct;
var
  jData, jProduct: TJSONData;
begin
  Result := TGrocyProduct.Create();
  try
    jData := GetJSON(Response);
    jProduct := jData.FindPath('product');
    if Assigned(jProduct) then
      LoadJson(Result, jProduct.AsJSON, TypeInfo(TGrocyProduct));
  finally
    jData.Free;
  end;
end;

function TGrocyService.GetIdFromJsonGrocy(const Response: string; Field: string): integer;
var
  JData: TJSONData;
  JObject: TJSONObject;
begin
  JData := GetJSON(Response);
  JObject := JData as TJSONObject;
  try
    Result := StrToInt(JObject.Get(Field, '-1'));
  finally
    JData.Free;
  end;
end;

constructor TGrocyService.Create(Host: string; Port: string; ApiKey: string; Configuration: TConfiguration);
begin
  FHost := Host;
  FPort := Port;
  FApiKey := ApiKey;
  FConfiguration := Configuration;

  FClient := TFPHttpClient.Create(nil);
  FClient.AddHeader('User-Agent', 'Mozilla/5.0 (compatible; fpweb)');
  FClient.AddHeader('Content-Type', 'application/json');
  FClient.AddHeader('Accept', 'application/json');
  FClient.AddHeader('GROCY-API-KEY', FApiKey);
  FClient.AllowRedirect := True;
end;

destructor TGrocyService.Destroy;
begin
  FClient.Free;

  inherited Destroy;
end;

function TGrocyService.CreateProduct(OFFProductInfo: TOFFProductInfo): TGrocyProduct;
var
  Response: string;
  GrocyProduct: TGrocyProduct;
  GrocyError: TGrocyError;
begin
  Result := nil;

  GrocyProduct := CreateGrocyProduct(OFFProductInfo);
  try
    FClient.RequestBody := TRawByteStringStream.Create(ObjectToJson(GrocyProduct));
    Response := FClient.Post(Self.BaseURL + UrlCreateProduct);
    if (FClient.ResponseStatusCode = 200) then
    begin
      GrocyProduct.Id := GetIdFromJsonGrocy(Response, 'created_object_id');
      Result := GrocyProduct;
    end
    else if (FClient.ResponseStatusCode = 400) then
    begin
      FreeRequestBody;

      GrocyError := TGrocyError.Create;
      try
        LoadJson(GrocyError, Response, TypeInfo(TGrocyError));
        if GrocyError.isErrorIntegrityUnique() then
        begin
          TLogger.Error('Failed to add a new product in Grocy due to violation of the uniqueness of the product name %s',
            [GrocyProduct.Name]);

          TLogger.Info('Finding Grocy product with same name "%s"', [GrocyProduct.Name]);
          Result := GetProductByName(GrocyProduct.Name);
          if Assigned(Result) then
            TLogger.Info('Found! Grocy Product ID = %d', [Result.Id]);
        end;
        // Now GrocyProduct doesn't need anymore
        GrocyProduct.Free;
        GrocyProduct := nil;
      finally
        GrocyError.Free;
      end;
    end;
  finally
    FreeRequestBody;
  end;
end;

function TGrocyService.AddBarcodeToProduct(const ProductId: integer; const Barcode: string): TGrocyBarcode;
var
  Response: string;
  GrocyBarcode: TGrocyBarcode;
begin
  Result := nil;

  GrocyBarcode := CreateGrocyBarcode(ProductId, Barcode);
  try
    FClient.RequestBody := TRawByteStringStream.Create(ObjectToJson(GrocyBarcode));
    Response := FClient.Post(Self.BaseURL + UrlAddBarcode);
  finally
    if (FClient.ResponseStatusCode = 200) then
    begin
      GrocyBarcode.Id := GetIdFromJsonGrocy(Response, 'created_object_id');
      Result := GrocyBarcode;
    end
    else
      GrocyBarcode.Free;

    FreeRequestBody;
  end;
end;

function TGrocyService.GetProductByBarcode(Barcode: string): TGrocyProduct;
var
  Response: string;
begin
  Result := nil;

  try
    try
      Response := FClient.Get(Format(Self.BaseURL + UrlProductByBarcode, [Barcode]));
    except
      on E: ESocketError do
        TLogger.Exception(E);
    end;
  finally
    if (FClient.ResponseStatusCode = 200) then
      Result := GetGrocyProductFromJson(Response);
  end;
end;

function TGrocyService.AddProductInStock(GrocyProductId: integer; ProductStock: TGrocyProductStock): boolean;
begin
  Result := False;

  try
    FClient.RequestBody := TRawByteStringStream.Create(ObjectToJson(ProductStock));
    try
      FClient.Post(Format(Self.BaseURL + UrlAddProductStock, [GrocyProductId]));
    except
      on E: ESocketError do
        TLogger.Exception(E);
    end;
  finally
    Result := (FClient.ResponseStatusCode = 200);

    FreeRequestBody;
  end;
end;

function TGrocyService.GetProductByName(Name: string): TGrocyProduct;
var
  Response: string;
  GrocyProducts: TGrocyProductArray;
  I: integer;
begin
  Result := nil;
  GrocyProducts := nil;
  try
    try
      Response := FClient.Get(Format(Self.BaseURL + UrlProductByName, [EncodeURLElement(Name)]));
    except
      on E: ESocketError do
        TLogger.Exception(E);
    end;
  finally
    if (FClient.ResponseStatusCode = 200) then
    begin
      DynArrayLoadJson(GrocyProducts, Response, TypeInfo(TGrocyProductArray));

      if Length(GrocyProducts) = 1 then
        Result := TGrocyProduct.Create(GrocyProducts[0]);

      if Assigned(GrocyProducts) then
      begin
        for I := Low(GrocyProducts) to High(GrocyProducts) do
          GrocyProducts[I].Free;
        SetLength(GrocyProducts, 0);
      end;
    end;
  end;
end;

function TGrocyService.ConsumeByBarcode(Barcode: string; Amount: integer): boolean;
var
  jObject: TJSONObject;
begin
  Result := False;
  jObject := TJSONObject.Create;
  jObject.Add('amount', Amount);
  jObject.Add('transaction_type', 'consume');
  jObject.Add('spoiled', False);

  try
    FClient.RequestBody := TRawByteStringStream.Create(jObject.AsJSON);
    try
      FClient.Post(Format(Self.BaseURL + UrlConsumeByBarcode, [Barcode]));
    except
      on E: ESocketError do
        TLogger.Exception(E);
    end;
  finally
    Result := (FClient.ResponseStatusCode = 200);
    FreeRequestBody;
    jObject.Free;
  end;
end;

function TGrocyService.UploadImageFile(ImageStream: TStream; FileName: string): boolean;
begin
  Result := False;

  FileName := EncodeStringBase64(FileName);
  try
    FClient.AddHeader('Content-Type', 'application/octet-stream');
    ImageStream.Position := 0;
    FClient.RequestBody := ImageStream;
    try
      FClient.Put(Format(Self.BaseURL + UrlUploadFile, [FileName]));
    except
      on E: ESocketError do
        TLogger.Exception(E);
    end;
  finally
    Result := (FClient.ResponseStatusCode = 204);
    FClient.AddHeader('Content-Type', 'application/json');

    FreeRequestBody;
  end;
end;

end.
