unit OpenFoodFacts.Service;

{$mode Delphi}{$H+}

interface

uses
  Classes, SysUtils, fphttpclient, opensslsockets, OpenFoodFacts.ProductInfo;

type

  { TOpenFoodFactsService }

  TOpenFoodFactsService = class
  private
  public
    class function GetProduct(BarCode: String): TOFFProductInfo;
  end;

const
  BaseUrl: String = 'https://it.openfoodfacts.org/api/v2/product/';

implementation

class function TOpenFoodFactsService.GetProduct(BarCode: String): TOFFProductInfo;
var
  Client: TFPHttpClient;
  Response: string;
begin
  Result := nil;

  Client := TFPHttpClient.Create(nil);
  Client.AddHeader('User-Agent', 'Mozilla/5.0 (compatible; fpweb)');
  Client.AddHeader('Content-Type', 'application/json; charset=UTF-8');
  Client.AddHeader('Accept', 'application/json');
  Client.AllowRedirect := true;
  try
    Response := Client.Get(BaseURL + BarCode + '.json');
    if(Client.ResponseStatusCode = 200) then
      Result := TOFFProductInfo.Create(Response);
  finally
    Client.Free;
  end;
end;

end.

