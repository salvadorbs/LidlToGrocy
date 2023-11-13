unit Testcase.Grocy;

{$mode DelphiUnicode}

interface

uses
  Classes, SysUtils, TestFramework, Grocy.Root, mormot.core.json, mormot.core.base,
  mormot.core.os;

type

  { TTestCaseGrocy }

  TTestCaseGrocy = class(TTestCase)
    FGrocyRoot: TGrocyRoot;
  protected
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure ValidJsonObject;
  end;

implementation

procedure TTestCaseGrocy.ValidJsonObject;
begin
  CheckEqualsUnicodeString(FGrocyRoot.Product.Active, '1');
  CheckEquals(FGrocyRoot.Product.Id, 16);
  CheckEqualsUnicodeString(FGrocyRoot.Product.QuIdStock, '2');
end;

procedure TTestCaseGrocy.SetUp;
var
  json: RawByteString;
begin
  json := StringFromFile('test_grocy_product.json');

  FGrocyRoot := TGrocyRoot.Create;
  LoadJson(FGrocyRoot, json, TypeInfo(TGrocyRoot));
end;

procedure TTestCaseGrocy.TearDown;
begin
  FGrocyRoot.Free;
end;

initialization
  RegisterTest(TTestCaseGrocy.Suite);
end.

