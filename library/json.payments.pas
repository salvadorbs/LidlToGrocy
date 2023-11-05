unit Json.Payments;

{$mode DelphiUnicode}

interface

uses
  Classes, SysUtils;

type
  TPayments = class
  private
    FAmount: string;
    FDescription: string;
    FRawPaymentInformationHTML: string;
    FRoundingDifference: string;
    FType: string;
  published
    property Amount: string read FAmount write FAmount;
    property Description: string read FDescription write FDescription;
    property RawPaymentInformationHTML: string read FRawPaymentInformationHTML write FRawPaymentInformationHTML;
    property RoundingDifference: string read FRoundingDifference write FRoundingDifference;
    property &Type: string read FType write FType;
  end;

  TPaymentsArray = array of TPayments;

implementation

end.

