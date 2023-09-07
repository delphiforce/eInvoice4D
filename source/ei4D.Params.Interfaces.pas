unit ei4D.Params.Interfaces;

interface

uses
  ei4D.Invoice.Prop.Interfaces;

const
  EMPTY_BASE_URL = 'AUTO';

type

  IeiProviderParams = interface(IInvokable)
    ['{C5778DA6-B7EA-426E-A474-C1098D81C088}']
    procedure CheckPredefinedValues(const APredefinedBaseUrlAuth, APredefinedBaseUrlWS: String);
    // ID
    procedure SetID(const Value: String);
    function GetID: String;
    property ID: String read GetID write SetID;
    // ABaseUrlAuth
    procedure SetBaseUrlAuth(const Value: String);
    function GetBaseUrlAuth: String;
    property BaseUrlAuth: String read GetBaseUrlAuth write SetBaseUrlAuth;
    // BaseUrlWS
    procedure SetBaseUrlWS(const Value: String);
    function GetBaseUrlWS: String;
    property BaseUrlWS: String read GetBaseUrlWS write SetBaseUrlWS;
    // Password
    procedure SetPassword(const Value: String);
    function GetPassword: String;
    property Password: String read GetPassword write SetPassword;
    // UserName
    procedure SetUserName(const Value: String);
    function GetUserName: String;
    property UserName: String read GetUserName write SetUserName;
  end;

  IeiParams = interface(IInvokable)
    ['{F7AC897D-D291-4FDD-A059-A64999432ED3}']
    // DefaultDecimals
    procedure SetDefaultDecimals(const Value: Byte);
    function GetDefaultDecimals: Byte;
    property DefaultDecimals: Byte read GetDefaultDecimals write SetDefaultDecimals;
    // DefaultMaxDecimals
    procedure SetDefaultMaxDecimals(const Value: Byte);
    function GetDefaultMaxDecimals: Byte;
    property DefaultMaxDecimals: Byte read getDefaultMaxDecimals write SetDefaultMaxDecimals;
    // DefaultMaxLength
    procedure SetDefaultMaxLength(const Value: Integer);
    function GetDefaultMaxLength: Integer;
    property DefaultMaxLength: Integer read GetDefaultMaxLength write SetDefaultMaxLength;
    // DefaultMinLength
    procedure SetDefaultMinLength(const Value: Integer);
    function GetDefaultMinLength: Integer;
    property DefaultMinLength: Integer read GetDefaultMinLength write SetDefaultMinLength;
    // DefaultOccurrence
    procedure SetDefaultOccurrence(const Value: TeiOccurrence);
    function GetDefaultOccurrence: TeiOccurrence;
    property DefaultOccurrence: TeiOccurrence read GetDefaultOccurrence write SetDefaultOccurrence;
    // InterOperationDelay
    procedure SetInterOperationDelay(const Value: Integer);
    function GetInterOperationDelay: Integer;
    property InterOperationDelay: Integer read GetInterOperationDelay write SetInterOperationDelay; // Aruba = 5100
    // Provider
    function GetProvider: IeiProviderParams;
    property Provider: IeiProviderParams read GetProvider;
    // RowCurrencyDecimals
    procedure SetRowCurrencyDecimals(const Value: Byte);
    function GetRowCurrencyDecimals: Byte;
    property RowCurrencyDecimals: Byte read GetRowCurrencyDecimals write SetRowCurrencyDecimals;
    // RowQuantityDecimals
    procedure SetRowQuantityDecimals(const Value: Byte);
    function GetRowQuantityDecimals: Byte;
    property RowQuantityDecimals: Byte read GetRowQuantityDecimals write SetRowQuantityDecimals;
    // SanitizePurchaseInvoices
    procedure SetSanitizePurchaseInvoices(const Value: Boolean);
    function GetSanitizePurchaseInvoices: Boolean;
    property SanitizePurchaseInvoices: Boolean read GetSanitizePurchaseInvoices write SetSanitizePurchaseInvoices;
  end;

implementation

end.
