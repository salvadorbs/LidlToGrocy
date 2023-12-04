unit Kernel.Ticket;

{$mode DelphiUnicode}

interface

uses
  Classes, SysUtils, mormot.core.json;

type

  { TTicket }

  TTicket = class(TSynAutoCreateFields)
  private
    FConsumedProducts: TStrings;
    FId: string;
    FStockedProducts: TStrings;
  public
    constructor Create; override;
    destructor Destroy; override;
  published
    property Id: string read FId write FId;
    property StockedProducts: TStrings read FStockedProducts write FStockedProducts;
    property ConsumedProducts: TStrings read FConsumedProducts write FConsumedProducts;
  end;

  TTicketArray = array of TTicket;

implementation

{ TTicket }

constructor TTicket.Create;
begin
  inherited Create;

  FStockedProducts := TStringList.Create;
  FConsumedProducts := TStringList.Create;
end;

destructor TTicket.Destroy;
begin
  FStockedProducts.Free;
  FConsumedProducts.Free;

  inherited Destroy;
end;

end.
