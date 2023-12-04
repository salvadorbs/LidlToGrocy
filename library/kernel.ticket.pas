unit Kernel.Ticket;

{$mode DelphiUnicode}

interface

uses
  Classes, SysUtils, mormot.core.json;

type

  { TTicket }

  TTicket = class(TSynAutoCreateFields)
  private
    FConsumedProducts: TStringList;
    FId: string;
    FStockedProducts: TStringList;
  public
    destructor Destroy; override;

    function ExistsStockedProduct(Id: string): boolean;
    function ExistsConsumedProduct(Id: string): boolean;
  published
    property Id: string read FId write FId;
    property StockedProducts: TStringList read FStockedProducts write FStockedProducts;
    property ConsumedProducts: TStringList read FConsumedProducts write FConsumedProducts;
  end;

  TTicketArray = array of TTicket;

implementation

{ TTicket }

destructor TTicket.Destroy;
begin
  FStockedProducts.Free;
  FStockedProducts := nil;

  FConsumedProducts.Free;
  FConsumedProducts := nil;

  inherited Destroy;
end;

function TTicket.ExistsStockedProduct(Id: string): boolean;
begin
  Result := Self.StockedProducts.IndexOf(Id) <> -1;
end;

function TTicket.ExistsConsumedProduct(Id: string): boolean;
begin
  Result := Self.ConsumedProducts.IndexOf(Id) <> -1;
end;

end.
