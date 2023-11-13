program testcase;

{$mode objfpc}{$H+}

uses
  Interfaces, Forms, GUITestRunner, testcase.lidl, testcase.openfoodfacts,
  Testcase.Grocy;

{$R *.res}

begin
  Application.Initialize;
  RunRegisteredTests;
end.

