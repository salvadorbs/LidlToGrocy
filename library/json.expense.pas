unit Json.Expense;

{$mode DelphiUnicode}

interface

uses
  Classes, SysUtils, mormot.core.json, Json.ItemsLine, Json.CouponsUsed,
  Json.Payments, Json.Taxes, Generics.Collections, Json.Currency, Json.Store,
  Json.TotalTaxes, Json.TenderChange;

type
  { TExpense }

  TExpense = class(TSynAutoCreateFields)
  private
    FBarCode: string;
    FCouponsUsed: TCouponsUsedArray;
    FCurrency: TCurrency;
    FDate: TDateTime;
    FHasHtmlDocument: Boolean;
    FHtmlPrintedReceipt: string;
    FId: string;
    FIsEmployee: Boolean;
    FIsFavorite: Boolean;
    FIsHtml: Boolean;
    FItemsLine: TItemsLineArray;
    FLanguageCode: string;
    FLinesScannedCount: Integer;
    FPayments: TPaymentsArray;
    FPrintedReceiptState: string;
    FSequenceNumber: string;
    FStore: TStore;
    FTaxExemptTexts: string;
    FTaxes: TTaxesArray;
    FTenderChange: TTenderChangeArray;
    FTotalAmount: string;
    FTotalAmountNumeric: Double;
    FTotalDiscount: string;
    FTotalTaxes: TTotalTaxes;
    FWorkstation: string;
  published
    property BarCode: string read FBarCode write FBarCode;
    property CouponsUsed: TCouponsUsedArray read FCouponsUsed;
    property Currency: TCurrency read FCurrency;
    property Date: TDateTime read FDate write FDate;
    property HasHtmlDocument: Boolean read FHasHtmlDocument write FHasHtmlDocument;
    property HtmlPrintedReceipt: string read FHtmlPrintedReceipt write FHtmlPrintedReceipt;
    property Id: string read FId write FId;
    property IsEmployee: Boolean read FIsEmployee write FIsEmployee;
    property IsFavorite: Boolean read FIsFavorite write FIsFavorite;
    property IsHtml: Boolean read FIsHtml write FIsHtml;
    property ItemsLine: TItemsLineArray read FItemsLine;
    property LanguageCode: string read FLanguageCode write FLanguageCode;
    property LinesScannedCount: Integer read FLinesScannedCount write FLinesScannedCount;
    property Payments: TPaymentsArray read FPayments;
    property PrintedReceiptState: string read FPrintedReceiptState write FPrintedReceiptState;
    property SequenceNumber: string read FSequenceNumber write FSequenceNumber;
    property Store: TStore read FStore;
    property TaxExemptTexts: string read FTaxExemptTexts write FTaxExemptTexts;
    property Taxes: TTaxesArray read FTaxes;
    property TenderChange: TTenderChangeArray read FTenderChange;
    property TotalAmount: string read FTotalAmount write FTotalAmount;
    property TotalAmountNumeric: Double read FTotalAmountNumeric write FTotalAmountNumeric;
    property TotalDiscount: string read FTotalDiscount write FTotalDiscount;
    property TotalTaxes: TTotalTaxes read FTotalTaxes;
    property Workstation: string read FWorkstation write FWorkstation;
  end;

  TExpenseArray = array of TExpense;

implementation

{ TExpense }

end.

