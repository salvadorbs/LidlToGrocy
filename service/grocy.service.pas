unit Grocy.Service;

{$mode DelphiUnicode}

interface

uses
  Classes, SysUtils, Grocy.Product, mormot.core.json, fphttpclient, opensslsockets, mormot.core.os;

type

  { TGrocyService }

  TGrocyService = class
  private
    FHost: String;
    FPort: String;
    FApiKey: String;
    function GetBaseUrl: String;
    function GetGrocyProductFromJson(const Response: string): TGrocyProduct;
  public
    constructor Create(Host: String; Port: String; ApiKey: String);

    property BaseUrl: String read GetBaseUrl;

    function CreateProduct(GrocyProduct: TGrocyProduct): Boolean;
    function AddBarcodeToProduct(GrocyProduct: TGrocyProduct): Boolean;
    function GetProductByBarcode(Barcode: String): TGrocyProduct;
  end;

const
  UrlProductByBarcode: String = 'stock/products/by-barcode/%s';
  UrlCreateProduct: String = 'objects/products';
  UrlAddBarcode: String = 'objects/product_barcodes';

implementation

uses
  Grocy.Root, fpjson, jsonparser;

{ TGrocyService }

function TGrocyService.GetBaseUrl: String;
begin
  Result := Format('http://%s:%s/api/', [FHost, FPort]);
end;

function TGrocyService.GetGrocyProductFromJson(const Response: string): TGrocyProduct;
var
  GrocyRoot: TGrocyRoot;
begin
  GrocyRoot := TGrocyRoot.Create();
  try
    ObjectLoadJson(GrocyRoot, Response);
    Result := GrocyRoot.Product;
  finally
    GrocyRoot.Free;
  end;
end;

constructor TGrocyService.Create(Host: String; Port: String; ApiKey: String);
begin
  FHost := Host;
  FPort := Port;
  FApiKey := ApiKey;
end;

function TGrocyService.CreateProduct(GrocyProduct: TGrocyProduct): Boolean;
var
  Client: TFPHttpClient;
  Response: string;
  JObject: TJSONObject;
  JData: TJSONData;
begin
  Result := False;

  Client := TFPHttpClient.Create(nil);
  Client.AddHeader('User-Agent', 'Mozilla/5.0 (compatible; fpweb)');
  Client.AddHeader('Content-Type', 'application/json; charset=UTF-8');
  Client.AddHeader('Accept', 'application/json');
  Client.AddHeader('GROCY-API-KEY', FApiKey);
  Client.AllowRedirect := true;
  try
    Response := Client.Get(Self.BaseURL + UrlCreateProduct);
  finally
    if (Client.ResponseStatusCode = 200) then
    begin
      JData := GetJSON(Response);
      JObject := JData as TJSONObject;
      try
        GrocyProduct.Id := JObject.Get('created_object_id', '');
        Result := (GrocyProduct.Id <> '');
      finally
        JData.Free;
      end;
    end;

    Client.Free;
  end;
end;

function TGrocyService.AddBarcodeToProduct(GrocyProduct: TGrocyProduct
  ): Boolean;
var
  Client: TFPHttpClient;
  Response: string;
  JObject: TJSONObject;
  JData: TJSONData;
begin
  Result := False;

  Client := TFPHttpClient.Create(nil);
  Client.AddHeader('User-Agent', 'Mozilla/5.0 (compatible; fpweb)');
  Client.AddHeader('Content-Type', 'application/json; charset=UTF-8');
  Client.AddHeader('Accept', 'application/json');
  Client.AddHeader('GROCY-API-KEY', FApiKey);
  Client.AllowRedirect := true;
  try
    Response := Client.Get(Self.BaseURL + UrlAddBarcode);
  finally
    if (Client.ResponseStatusCode = 200) then
    begin
      JData := GetJSON(Response);
      JObject := JData as TJSONObject;
      try
        GrocyProduct.Id := JObject.Get('created_object_id', '');
        Result := (GrocyProduct.Id <> '');
      finally
        JData.Free;
      end;
    end;

    Client.Free;
  end;
end;

function TGrocyService.GetProductByBarcode(Barcode: String): TGrocyProduct;
var
  Client: TFPHttpClient;
  Response: string;
begin
  Result := nil;

  Client := TFPHttpClient.Create(nil);
  Client.AddHeader('User-Agent', 'Mozilla/5.0 (compatible; fpweb)');
  Client.AddHeader('Content-Type', 'application/json; charset=UTF-8');
  Client.AddHeader('Accept', 'application/json');
  Client.AddHeader('GROCY-API-KEY', FApiKey);
  Client.AllowRedirect := true;
  try
    Response := Client.Get(Format(Self.BaseURL + UrlProductByBarcode, [Barcode]));
  finally
    if(Client.ResponseStatusCode = 200) then
      Result := GetGrocyProductFromJson(Response);

    Client.Free;
  end;
end;

end.

