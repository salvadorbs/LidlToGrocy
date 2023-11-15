unit OpenFoodFacts.Service;

{$mode DelphiUnicode}

interface

uses
  Classes, SysUtils, fphttpclient, opensslsockets, OpenFoodFacts.ProductInfo;

type

  { TOpenFoodFactsService }

  TOpenFoodFactsService = class
  private
  public
    class function GetProduct(BarCode: string): TOFFProductInfo;
  end;

const
  BaseUrl: string = 'https://it.openfoodfacts.org/api/v2/product/';

implementation

class function TOpenFoodFactsService.GetProduct(BarCode: string): TOFFProductInfo;
var
  Client: TFPHttpClient;
  Response: string;
  OFFProductInfo: TOFFProductInfo;
begin
  Result := nil;

  Client := TFPHttpClient.Create(nil);
  Client.AddHeader('User-Agent', 'Mozilla/5.0 (compatible; fpweb)');
  Client.AddHeader('Content-Type', 'application/json; charset=UTF-8');
  Client.AddHeader('Accept', 'application/json');
  Client.AllowRedirect := True;
  try
    Response := Client.Get(BaseURL + BarCode + '.json');
    if (Client.ResponseStatusCode = 200) then
    begin
      try
        // In case of an invalid code, OFF returns 200 with an error message, so .ProductName will be blank
        OFFProductInfo := TOFFProductInfo.Create(Response);

        if OFFProductInfo.ProductName = '' then
          raise Exception.Create('Product name not found')
        else
          Result := OFFProductInfo;
      finally
        if Result = nil then
          OFFProductInfo.Free;
      end;
    end;
  finally
    Client.Free;
  end;
end;

end.
