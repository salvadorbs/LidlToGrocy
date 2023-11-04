program testcase;

{$mode objfpc}{$H+}

uses
  Interfaces, Forms, GUITestRunner, testcase1;

{$R *.res}

begin
  Application.Initialize;
  RunRegisteredTests;
end.

