unit TestCase1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, TestFramework, mormot.core.json, mormot.core.os, mormot.core.base,
  json.root, json.currency, json.store, json.totaltaxes, json.itemsline;

type
  TLidlToGrocyTestCase= class(TTestCase)
  private
    FRoot: TRootArray;
  protected
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestHookUp;
  end;

implementation

procedure TLidlToGrocyTestCase.TestHookUp;
begin
  Fail('Write your own test');
end;

procedure TLidlToGrocyTestCase.SetUp;
var
  json: RawUtf8;
begin
  json := StringFromFile('test.json');
  DynArrayLoadJson(FRoot, json, TypeInfo(TRootArray));
end;

procedure TLidlToGrocyTestCase.TearDown;
begin
  //FRoot.Free;
end;

initialization
  RegisterTest(TLidlToGrocyTestCase.Suite);
end.

