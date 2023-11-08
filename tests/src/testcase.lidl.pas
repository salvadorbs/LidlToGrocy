unit Testcase.Lidl;

{$mode DelphiUnicode}

interface

uses
  Classes, SysUtils, TestFramework, mormot.core.json, mormot.core.os, mormot.core.base,
  Lidl.Ticket, OpenFoodFacts.ProductInfo;

type

  { TTestCaseLidl }

  TTestCaseLidl = class(TTestCase)
  private
    FTicket: TLidlTicketArray;
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
  DynArrayLoadJson(FTicket, json, TypeInfo(TLidlTicketArray));
end;

procedure TTestCaseLidl.TearDown;
var
  I: Integer;
begin
  for I := 0 to length(FTicket) - 1 do
    FTicket[I].Free;
end;

procedure TTestCaseLidl.ValidJsonObject;
begin
  CheckEquals(Length(FTicket), 2);

  CheckEqualsUnicodeString(FTicket[0].id, '1');
  CheckEqualsUnicodeString(FTicket[1].id, '2');
end;

procedure TTestCaseLidl.CheckItemsLine;
begin
  CheckEquals(Length(FTicket), 2);

  CheckEquals(Length(FTicket[0].ItemsLine), 3);
  CheckEqualsUnicodeString(FTicket[0].ItemsLine[0].Name, 'PRODUCT1');
  CheckEqualsUnicodeString(FTicket[0].ItemsLine[0].TaxGroupName, 'A');
  CheckEqualsUnicodeString(FTicket[0].ItemsLine[1].Name, 'PRODUCT2');
  CheckEqualsUnicodeString(FTicket[0].ItemsLine[1].TaxGroupName, 'B');
  CheckEqualsUnicodeString(FTicket[0].ItemsLine[2].Name, 'PRODUCT3');
  CheckEqualsUnicodeString(FTicket[0].ItemsLine[2].TaxGroupName, 'C');

  CheckEquals(Length(FTicket[1].ItemsLine), 2);
  CheckEqualsUnicodeString(FTicket[1].ItemsLine[0].Name, 'PRODUCT1');
  CheckEqualsUnicodeString(FTicket[1].ItemsLine[0].TaxGroupName, 'A');
  CheckEqualsUnicodeString(FTicket[1].ItemsLine[1].Name, 'PRODUCT2');
  CheckEqualsUnicodeString(FTicket[1].ItemsLine[1].TaxGroupName, 'B');
end;

initialization
  RegisterTest(TTestCaseLidl.Suite);

end.

