unit Lidl.Store;

{$mode DelphiUnicode}

interface

uses
  Classes, SysUtils, mormot.core.json;

type
  TStore = class(TSynAutoCreateFields)
  private
    FAddress: string;
    FId: string;
    FLocality: string;
    FName: string;
    FPostalCode: string;
    FSchedule: string;
  published
    property Address: string read FAddress write FAddress;
    property Id: string read FId write FId;
    property Locality: string read FLocality write FLocality;
    property Name: string read FName write FName;
    property PostalCode: string read FPostalCode write FPostalCode;
    property Schedule: string read FSchedule write FSchedule;
  end;

implementation

end.
