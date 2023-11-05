unit TestCase1;

{$mode DelphiUnicode}

interface

uses
  Classes, SysUtils, TestFramework, mormot.core.json, mormot.core.os, mormot.core.base,
  Json.Expense;

type

  { TLidlToGrocyTestCase }

  TLidlToGrocyTestCase = class(TTestCase)
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

procedure TLidlToGrocyTestCase.SetUp;
var
  json: RawUtf8;
begin
  json := StringFromFile('test.json');
  DynArrayLoadJson(FExpense, json, TypeInfo(TExpenseArray));
end;

procedure TLidlToGrocyTestCase.TearDown;
var
  I: Integer;
begin
  for I := 0 to length(FExpense) - 1 do
  begin
    FExpense[I].Free;
  end;
end;

procedure TLidlToGrocyTestCase.ValidJsonObject;
begin
  CheckEquals(Length(FExpense), 2);

  CheckEqualsUnicodeString(FExpense[0].id, '1');
  CheckEqualsUnicodeString(FExpense[1].id, '2');
end;

procedure TLidlToGrocyTestCase.CheckItemsLine;
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
  RegisterTest(TLidlToGrocyTestCase.Suite);
end.

