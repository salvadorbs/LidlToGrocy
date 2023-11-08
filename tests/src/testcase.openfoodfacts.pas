unit Testcase.OpenFoodFacts;

{$mode DelphiUnicode}

interface

uses
  Classes, SysUtils, TestFramework, mormot.core.json, mormot.core.os, mormot.core.base,
  OpenFoodFacts.ProductInfo;

type

  { TTestcaseOpenFoodFacts }

  TTestcaseOpenFoodFacts = class(TTestCase)
  private
    FOFFProductInfo: TOFFProductInfo;
  protected
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure CheckClass;
  end;

implementation

{ TOpenFoodFacts }

procedure TTestcaseOpenFoodFacts.SetUp;
var
  json: RawUtf8;
begin
  json := StringFromFile('test_openfoodfacts.json');
  FOFFProductInfo := TOFFProductInfo.Create(json);
end;

procedure TTestcaseOpenFoodFacts.TearDown;
begin
  FOFFProductInfo.Free;
end;

procedure TTestcaseOpenFoodFacts.CheckClass;
begin
  CheckEqualsUnicodeString(FOFFProductInfo.Code, '3017620422003');
  CheckEqualsUnicodeString(FOFFProductInfo.ImageUrl, 'https://images.openfoodfacts.org/images/products/301/762/042/2003/front_it.467.400.jpg');
  CheckEqualsUnicodeString(FOFFProductInfo.ProductName, 'Nutella');
  CheckEquals(FOFFProductInfo.Status, 1);
  CheckEqualsUnicodeString(FOFFProductInfo.StatusVerbose, 'product found');
end;

initialization
  RegisterTest(TTestcaseOpenFoodFacts.Suite);

end.

