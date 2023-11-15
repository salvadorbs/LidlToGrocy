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
    FStatus: integer;
    FStatusVerbose: string;
    function GetValueFromJson(JObject: TJSONObject; Field: string): string;
  public
    constructor Create(JSON: string); overload;
    constructor Create(); overload;
  published
    property Code: string read FCode write FCode;
    property ImageUrl: string read FImageUrl write FImageUrl;
    property ProductName: string read FProductName write FProductName;
    property Status: integer read FStatus write FStatus;
    property StatusVerbose: string read FStatusVerbose write FStatusVerbose;
  end;

implementation

{ TOFFProductInfo }

function TOFFProductInfo.GetValueFromJson(JObject: TJSONObject; Field: string): string;
var
  pathImageUrl: TJSONData;
begin
  Result := '';

  pathImageUrl := JObject.FindPath(Field);
  if Assigned(pathImageUrl) then
    Result := pathImageUrl.AsString;
end;

constructor TOFFProductInfo.Create(JSON: string);
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
    FImageUrl := GetValueFromJson(JObject, 'product.image_url');
    FProductName := GetValueFromJson(JObject, 'product.product_name');
  finally
    JData.Free;
  end;
end;

constructor TOFFProductInfo.Create();
begin

end;

end.
