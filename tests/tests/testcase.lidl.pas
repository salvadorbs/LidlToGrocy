unit Testcase.Lidl;

{$mode DelphiUnicode}

interface

uses
  Classes, SysUtils, TestFramework, mormot.core.json, mormot.core.os, mormot.core.base,
  Lidl.Expense, OpenFoodFacts.ProductInfo;

type

  { TTestCaseLidl }

  TTestCaseLidl = class(TTestCase)
  private
    FExpense: TExpenseArray;
  protected
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure ValidJsonObject;
    procedure CheckItemsLine;
  end;

implementation

procedure TTestCaseLidl.SetUp;
var
  json: RawUtf8;
begin
  json := StringFromFile('test_lidl.json');
  DynArrayLoadJson(FExpense, json, TypeInfo(TExpenseArray));
end;

procedure TTestCaseLidl.TearDown;
var
  I: Integer;
begin
  for I := 0 to length(FExpense) - 1 do
    FExpense[I].Free;
end;

procedure TTestCaseLidl.ValidJsonObject;
begin
  CheckEquals(Length(FExpense), 2);

  CheckEqualsUnicodeString(FExpense[0].id, '1');
  CheckEqualsUnicodeString(FExpense[1].id, '2');
end;

procedure TTestCaseLidl.CheckItemsLine;
begin
  CheckEquals(Length(FExpense), 2);

  CheckEquals(Length(FExpense[0].ItemsLine), 3);
  CheckEqualsUnicodeString(FExpense[0].ItemsLine[0].Name, 'PRODUCT1');
  CheckEqualsUnicodeString(FExpense[0].ItemsLine[0].TaxGroupName, 'A');
  CheckEqualsUnicodeString(FExpense[0].ItemsLine[1].Name, 'PRODUCT2');
  CheckEqualsUnicodeString(FExpense[0].ItemsLine[1].TaxGroupName, 'B');
  CheckEqualsUnicodeString(FExpense[0].ItemsLine[2].Name, 'PRODUCT3');
  CheckEqualsUnicodeString(FExpense[0].ItemsLine[2].TaxGroupName, 'C');

  CheckEquals(Length(FExpense[1].ItemsLine), 2);
  CheckEqualsUnicodeString(FExpense[1].ItemsLine[0].Name, 'PRODUCT1');
  CheckEqualsUnicodeString(FExpense[1].ItemsLine[0].TaxGroupName, 'A');
  CheckEqualsUnicodeString(FExpense[1].ItemsLine[1].Name, 'PRODUCT2');
  CheckEqualsUnicodeString(FExpense[1].ItemsLine[1].TaxGroupName, 'B');
end;

initialization
  RegisterTest(TTestCaseLidl.Suite);

end.

