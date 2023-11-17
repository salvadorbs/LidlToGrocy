unit Grocy.Error;

{$mode DelphiUnicode}

interface

uses
  Classes, SysUtils, mormot.core.rtti, mormot.core.json;

type

  { TGrocyError }

  TGrocyError = class(TSynAutoCreateFields)
  private
    FErrorMessage: string;
  public
    function isErrorIntegrityUnique: Boolean;
  published
    property ErrorMessage: string read FErrorMessage write FErrorMessage;
  end;

implementation

{ TGrocyError }

function TGrocyError.isErrorIntegrityUnique(): Boolean;
begin
  Result := (FErrorMessage = 'SQLSTATE[23000]: Integrity constraint violation: 19 UNIQUE constraint failed: products.name');
end;

initialization
  Rtti.ByTypeInfo[TypeInfo(TGrocyError)].Props.NameChanges(
    ['ErrorMessage'], ['error_message']);

end.

