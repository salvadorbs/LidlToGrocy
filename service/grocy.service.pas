unit Grocy.Service;

{$mode DelphiUnicode}

interface

uses
  Classes, SysUtils, Grocy.Product, mormot.core.json, fphttpclient,
  opensslsockets, mormot.core.os, mormot.core.text, mormot.core.base,
  Grocy.Barcode, Grocy.ProductStock, Grocy.Root;

type

  { TGrocyService }

  TGrocyService = class
  private
    FHost: String;
    FPort: String;
    FApiKey: String;
    FClient: TFPHTTPClient;
    function GetBaseUrl: String;
    function GetGrocyProductFromJson(const Response: string): TGrocyRoot;
    function GetIdFromJsonGrocy(const Response: string; Field: string): Integer;
  public
    constructor Create(Host: String; Port: String; ApiKey: String);
    destructor Destroy; override;

    property BaseUrl: String read GetBaseUrl;

    function CreateProduct(GrocyProduct: TGrocyProduct): Integer;
    function AddBarcodeToProduct(GrocyBarcode: TGrocyBarcode): Integer;
    function GetProductByBarcode(Barcode: String): TGrocyRoot;
    function AddProductInStock(GrocyProductId: Integer;
      ProductStock: TGrocyProductStock): Boolean;
  end;

const
  UrlProductByBarcode: String = 'stock/products/by-barcode/%s';
  UrlCreateProduct: String = 'objects/products';
  UrlAddBarcode: String = 'objects/product_barcodes';
  UrlAddProductStock: String = 'stock/products/%d/add';

implementation

uses
  fpjson, jsonparser, mormot.net.client;

{ TGrocyService }

function TGrocyService.GetBaseUrl: String;
begin
  Result := Format('http://%s:%s/api/', [FHost, FPort]);
end;

function TGrocyService.GetGrocyProductFromJson(const Response: string): TGrocyRoot;
begin
  Result := TGrocyRoot.Create();
  try
    LoadJson(Result, Response, TypeInfo(TGrocyRoot));
  finally

  end;
end;

function TGrocyService.GetIdFromJsonGrocy(const Response: string; Field: string
  ): Integer;
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

constructor TGrocyService.Create(Host: String; Port: String; ApiKey: String);
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

function TGrocyService.CreateProduct(GrocyProduct: TGrocyProduct): Integer;
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

function TGrocyService.AddBarcodeToProduct(GrocyBarcode: TGrocyBarcode): Integer;
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

function TGrocyService.GetProductByBarcode(Barcode: String): TGrocyRoot;
var
  Response: string;
begin
  Result := nil;

  try
    Response := FClient.Get(Format(Self.BaseURL + UrlProductByBarcode, [Barcode]));
  finally
    if(FClient.ResponseStatusCode = 200) then
      Result := GetGrocyProductFromJson(Response);
  end;
end;

function TGrocyService.AddProductInStock(GrocyProductId: Integer;
  ProductStock: TGrocyProductStock): Boolean;
begin
  Result := False;

  try
    FileFromString(ObjectToJson(ProductStock), 'testa.json');
    FClient.RequestBody := TRawByteStringStream.Create(ObjectToJson(ProductStock));
    FClient.Post(Format(Self.BaseURL + UrlAddProductStock, [GrocyProductId]));
  finally
    Result := (FClient.ResponseStatusCode = 200);

    FClient.RequestBody.Free;
    FClient.RequestBody := nil;
  end;
end;

end.

