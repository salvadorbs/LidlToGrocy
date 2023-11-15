unit Grocy.Service;

{$mode DelphiUnicode}

interface

uses
  Classes, SysUtils, Grocy.Product, mormot.core.json, fphttpclient,
  opensslsockets, mormot.core.os, mormot.core.Text, mormot.core.base,
  Grocy.Barcode, Grocy.ProductStock;

type

  { TGrocyService }

  TGrocyService = class
  private
    FHost: string;
    FPort: string;
    FApiKey: string;
    FClient: TFPHTTPClient;
    function GetBaseUrl: string;
    function GetGrocyProductFromJson(const Response: string): TGrocyProduct;
    function GetIdFromJsonGrocy(const Response: string; Field: string): integer;
  public
    constructor Create(Host: string; Port: string; ApiKey: string);
    destructor Destroy; override;

    property BaseUrl: string read GetBaseUrl;

    function CreateProduct(GrocyProduct: TGrocyProduct): integer;
    function AddBarcodeToProduct(GrocyBarcode: TGrocyBarcode): integer;
    function GetProductByBarcode(Barcode: string): TGrocyProduct;
    function AddProductInStock(GrocyProductId: integer; ProductStock: TGrocyProductStock): boolean;
  end;

const
  UrlProductByBarcode: string = 'stock/products/by-barcode/%s';
  UrlCreateProduct: string = 'objects/products';
  UrlAddBarcode: string = 'objects/product_barcodes';
  UrlAddProductStock: string = 'stock/products/%d/add';

implementation

uses
  fpjson, jsonparser, mormot.net.client;

  { TGrocyService }

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

constructor TGrocyService.Create(Host: string; Port: string; ApiKey: string);
begin
  FHost := Host;
  FPort := Port;
  FApiKey := ApiKey;

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

function TGrocyService.CreateProduct(GrocyProduct: TGrocyProduct): integer;
var
  Response: string;
begin
  Result := -1;

  try
    FClient.RequestBody := TRawByteStringStream.Create(ObjectToJson(GrocyProduct));
    Response := FClient.Post(Self.BaseURL + UrlCreateProduct);
  finally
    if (FClient.ResponseStatusCode = 200) then
      Result := GetIdFromJsonGrocy(Response, 'created_object_id');

    FClient.RequestBody.Free;
    FClient.RequestBody := nil;
  end;
end;

function TGrocyService.AddBarcodeToProduct(GrocyBarcode: TGrocyBarcode): integer;
var
  Response: string;
begin
  Result := -1;

  try
    FClient.RequestBody := TRawByteStringStream.Create(ObjectToJson(GrocyBarcode));
    Response := FClient.Post(Self.BaseURL + UrlAddBarcode);
  finally
    if (FClient.ResponseStatusCode = 200) then
      Result := GetIdFromJsonGrocy(Response, 'created_object_id');

    FClient.RequestBody.Free;
    FClient.RequestBody := nil;
  end;
end;

function TGrocyService.GetProductByBarcode(Barcode: string): TGrocyProduct;
var
  Response: string;
begin
  Result := nil;

  try
    Response := FClient.Get(Format(Self.BaseURL + UrlProductByBarcode, [Barcode]));
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
    FClient.Post(Format(Self.BaseURL + UrlAddProductStock, [GrocyProductId]));
  finally
    Result := (FClient.ResponseStatusCode = 200);

    FClient.RequestBody.Free;
    FClient.RequestBody := nil;
  end;
end;

end.
