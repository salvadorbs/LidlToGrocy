unit OpenFoodFacts.ProductInfo;

{$mode DelphiUnicode}

interface

uses
  Classes, SysUtils, fpjson, jsonparser;

type

  { TOFFProductInfo }

  TOFFProductInfo = class
  private
    FCode: string;
    FImageUrl: string;
    FProductName: string;
    FStatus: Integer;
    FStatusVerbose: string;
  public
    constructor Create(JSON: String);
  published
    property Code: string read FCode write FCode;
    property ImageUrl: string read FImageUrl write FImageUrl;
    property ProductName: string read FProductName write FProductName;
    property Status: Integer read FStatus write FStatus;
    property StatusVerbose: string read FStatusVerbose write FStatusVerbose;
  end;

implementation

{ TOFFProductInfo }

constructor TOFFProductInfo.Create(JSON: String);
var
  JObject: TJSONObject;
  JData: TJSONData;
begin
  inherited Create;

  JData := GetJSON(JSON);
  JObject := JData as TJSONObject;
  try
    FCode := JObject.Get('code', '');
    FStatus := JObject.Get('status', 0);
    FStatusVerbose := JObject.Get('status_verbose', 'product not found');
    FImageUrl := JObject.FindPath('product.image_url').AsString;
    FProductName := JObject.FindPath('product.product_name').AsString;
  finally
    JData.Free;
  end;
end;

end.

