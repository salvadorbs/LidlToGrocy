unit Lidl.Ticket;

{$mode DelphiUnicode}

interface

uses
  Classes, SysUtils, mormot.core.json, Lidl.ItemsLine, Lidl.CouponsUsed,
  Lidl.Payments, Lidl.Taxes, Lidl.currency, Lidl.Store, Lidl.TotalTaxes,
  Lidl.TenderChange;

type
  { TLidlTicket }

  TLidlTicket = class(TSynAutoCreateFields)
  private
    FBarCode: string;
    FCouponsUsed: TCouponsUsedArray;
    FCurrency: TCurrency;
    FDate: TDateTime;
    FHasHtmlDocument: boolean;
    FHtmlPrintedReceipt: string;
    FId: string;
    FIsEmployee: boolean;
    FIsFavorite: boolean;
    FIsHtml: boolean;
    FItemsLine: TItemsLineArray;
    FLanguageCode: string;
    FLinesScannedCount: integer;
    FPayments: TPaymentsArray;
    FPrintedReceiptState: string;
    FSequenceNumber: string;
    FStore: TStore;
    FTaxExemptTexts: string;
    FTaxes: TTaxesArray;
    FTenderChange: TTenderChangeArray;
    FTotalAmount: string;
    FTotalAmountNumeric: double;
    FTotalDiscount: string;
    FTotalTaxes: TTotalTaxes;
    FWorkstation: string;
  published
    property BarCode: string read FBarCode write FBarCode;
    property CouponsUsed: TCouponsUsedArray read FCouponsUsed;
    property currency: TCurrency read FCurrency;
    property Date: TDateTime read FDate write FDate;
    property HasHtmlDocument: boolean read FHasHtmlDocument write FHasHtmlDocument;
    property HtmlPrintedReceipt: string read FHtmlPrintedReceipt write FHtmlPrintedReceipt;
    property Id: string read FId write FId;
    property IsEmployee: boolean read FIsEmployee write FIsEmployee;
    property IsFavorite: boolean read FIsFavorite write FIsFavorite;
    property IsHtml: boolean read FIsHtml write FIsHtml;
    property ItemsLine: TItemsLineArray read FItemsLine;
    property LanguageCode: string read FLanguageCode write FLanguageCode;
    property LinesScannedCount: integer read FLinesScannedCount write FLinesScannedCount;
    property Payments: TPaymentsArray read FPayments;
    property PrintedReceiptState: string read FPrintedReceiptState write FPrintedReceiptState;
    property SequenceNumber: string read FSequenceNumber write FSequenceNumber;
    property Store: TStore read FStore;
    property TaxExemptTexts: string read FTaxExemptTexts write FTaxExemptTexts;
    property Taxes: TTaxesArray read FTaxes;
    property TenderChange: TTenderChangeArray read FTenderChange;
    property TotalAmount: string read FTotalAmount write FTotalAmount;
    property TotalAmountNumeric: double read FTotalAmountNumeric write FTotalAmountNumeric;
    property TotalDiscount: string read FTotalDiscount write FTotalDiscount;
    property TotalTaxes: TTotalTaxes read FTotalTaxes;
    property Workstation: string read FWorkstation write FWorkstation;
  end;

  TLidlTicketArray = array of TLidlTicket;

implementation

{ TLidlTicket }

end.
