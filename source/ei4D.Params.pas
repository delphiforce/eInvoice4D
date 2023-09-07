unit ei4D.Params;

interface

uses
  ei4D.Params.Interfaces, ei4D.Invoice.Prop.Interfaces;

type

  {$RTTI EXPLICIT METHODS([vcPublic, vcProtected])} // Force creation of RTTI Info for protected methods
  TeiProviderParams = class(TInterfacedObject, IeiProviderParams)
  strict private
    FID: String;
    FBaseUrlAuth: String;
    FBaseUrlWS: String;
    FPassword: String;
    FUserName: String;
  strict protected
    // ID
    procedure SetID(const Value: String);
    function GetID: String;
    // ABaseUrlAuth
    procedure SetBaseUrlAuth(const Value: String);
    function GetBaseUrlAuth: String;
    // BaseUrlWS
    procedure SetBaseUrlWS(const Value: String);
    function GetBaseUrlWS: String;
    // Password
    procedure SetPassword(const Value: String);
    function GetPassword: String;
    // UserName
    procedure SetUserName(const Value: String);
    function GetUserName: String;
  public
    constructor Create;
    procedure CheckPredefinedValues(const APredefinedBaseUrlAuth, APredefinedBaseUrlWS: String);
    property ID: String read GetID write SetID;
    property BaseUrlAuth: String read GetBaseUrlAuth write SetBaseUrlAuth;
    property BaseUrlWS: String read GetBaseUrlWS write SetBaseUrlWS;
    property Password: String read GetPassword write SetPassword;
    property UserName: String read GetUserName write SetUserName;
  end;

  {$RTTI EXPLICIT METHODS([vcPublic, vcProtected])} // Force creation of RTTI Info for protected methods
  TeiParams = class(TInterfacedObject, IeiParams)
  strict private
    FDefaultDecimals: Byte;
    FDefaultMaxDecimals: Byte;
    FDefaultMaxLength: Integer;
    FDefaultMinLength: Integer;
    FDefaultOccurrence: TeiOccurrence;
    FInterOperationDelay: Integer; // Aruba = 5100
    FProvider: IeiProviderParams;
    FRowCurrencyDecimals: Byte;
    FRowQuantityDecimals: Byte;
    FSanitizePurchaseInvoices: Boolean;
  strict protected
    // DefaultDecimals
    procedure SetDefaultDecimals(const Value: Byte);
    function GetDefaultDecimals: Byte;
    // DefaultMaxDecimals
    procedure SetDefaultMaxDecimals(const Value: Byte);
    function GetDefaultMaxDecimals: Byte;
    // DefaultMaxLength
    procedure SetDefaultMaxLength(const Value: Integer);
    function GetDefaultMaxLength: Integer;
    // DefaultMinLength
    procedure SetDefaultMinLength(const Value: Integer);
    function GetDefaultMinLength: Integer;
    // DefaultOccurrence
    procedure SetDefaultOccurrence(const Value: TeiOccurrence);
    function GetDefaultOccurrence: TeiOccurrence;
    // InterOperationDelay
    procedure SetInterOperationDelay(const Value: Integer);
    function GetInterOperationDelay: Integer;
    // Provider
    function GetProvider: IeiProviderParams;
    // RowCurrencyDecimals
    procedure SetRowCurrencyDecimals(const Value: Byte);
    function GetRowCurrencyDecimals: Byte;
    // RowQuantityDecimals
    procedure SetRowQuantityDecimals(const Value: Byte);
    function GetRowQuantityDecimals: Byte;
    // SanitizePurchaseInvoices
    procedure SetSanitizePurchaseInvoices(const Value: Boolean);
    function GetSanitizePurchaseInvoices: Boolean;
  public
    constructor Create;
    property DefaultDecimals: Byte read GetDefaultDecimals write SetDefaultDecimals;
    property DefaultMaxDecimals: Byte read getDefaultMaxDecimals write SetDefaultMaxDecimals;
    property DefaultMaxLength: Integer read GetDefaultMaxLength write SetDefaultMaxLength;
    property DefaultMinLength: Integer read GetDefaultMinLength write SetDefaultMinLength;
    property DefaultOccurrence: TeiOccurrence read GetDefaultOccurrence write SetDefaultOccurrence;
    property InterOperationDelay: Integer read GetInterOperationDelay write SetInterOperationDelay; // Aruba = 5100
    property Provider: IeiProviderParams read GetProvider;
    property RowCurrencyDecimals: Byte read GetRowCurrencyDecimals write SetRowCurrencyDecimals;
    property RowQuantityDecimals: Byte read GetRowQuantityDecimals write SetRowQuantityDecimals;
    property SanitizePurchaseInvoices: Boolean read GetSanitizePurchaseInvoices write SetSanitizePurchaseInvoices;
  end;

implementation

uses
  System.SysUtils;

{ TeiProviderParams }

procedure TeiProviderParams.CheckPredefinedValues(const APredefinedBaseUrlAuth, APredefinedBaseUrlWS: String);
begin
  // BaseUrlAuth
  if (FBaseUrlAuth.Trim.ToUpper = EMPTY_BASE_URL) or FBaseUrlAuth.Trim.IsEmpty then
    FBaseUrlAuth := APredefinedBaseUrlAuth;
  // BaseUrlWS
  if (FBaseUrlWS.Trim.ToUpper = EMPTY_BASE_URL) or FBaseUrlWS.Trim.IsEmpty then
    FBaseUrlWS := APredefinedBaseUrlWS;
end;

constructor TeiProviderParams.Create;
begin
  FID := String.Empty;
  FBaseUrlAuth := EMPTY_BASE_URL;
  FBaseUrlWS := EMPTY_BASE_URL;
  FPassword := String.Empty;
  FUserName := String.Empty;
end;

function TeiProviderParams.GetBaseUrlAuth: String;
begin
  Result := FBaseUrlAuth;
end;

function TeiProviderParams.GetBaseUrlWS: String;
begin
  Result := FBaseUrlWS;
end;

function TeiProviderParams.GetID: String;
begin
  Result := FID;
end;

function TeiProviderParams.GetPassword: String;
begin
  Result := FPassword;
end;

function TeiProviderParams.GetUserName: String;
begin
  Result := FUserName;
end;

procedure TeiProviderParams.SetBaseUrlAuth(const Value: String);
begin
  FBaseUrlAuth := Value;
end;

procedure TeiProviderParams.SetBaseUrlWS(const Value: String);
begin
  FBaseUrlWS := Value;
end;

procedure TeiProviderParams.SetID(const Value: String);
begin
  FID := Value;
end;

procedure TeiProviderParams.SetPassword(const Value: String);
begin
  FPassword := Value;
end;

procedure TeiProviderParams.SetUserName(const Value: String);
begin
  FUserName := Value;
end;

{ TeiParams }

constructor TeiParams.Create;
begin
  FDefaultDecimals := 2;
  FDefaultMaxDecimals := 2;
  FDefaultMaxLength := 0;
  FDefaultMinLength := 0;
  FDefaultOccurrence := oUndefined;
  FInterOperationDelay := 0; // Aruba = 5100
  FProvider := TeiProviderParams.Create;
  FRowCurrencyDecimals := 2;
  FRowQuantityDecimals := 2;
  FSanitizePurchaseInvoices := False;
end;

function TeiParams.GetDefaultDecimals: Byte;
begin
  Result := FDefaultDecimals;
end;

function TeiParams.GetDefaultMaxDecimals: Byte;
begin
  Result := FDefaultMaxDecimals;
end;

function TeiParams.GetDefaultMaxLength: Integer;
begin
  Result := FDefaultMaxLength;
end;

function TeiParams.GetDefaultMinLength: Integer;
begin
  Result := FDefaultMinLength;
end;

function TeiParams.GetDefaultOccurrence: TeiOccurrence;
begin
  Result := FDefaultOccurrence;
end;

function TeiParams.GetInterOperationDelay: Integer;
begin
  Result := FInterOperationDelay;
end;

function TeiParams.GetProvider: IeiProviderParams;
begin
  Result := FProvider;
end;

function TeiParams.GetRowCurrencyDecimals: Byte;
begin
  Result := FRowCurrencyDecimals;
end;

function TeiParams.GetRowQuantityDecimals: Byte;
begin
  Result := FRowQuantityDecimals;
end;

function TeiParams.GetSanitizePurchaseInvoices: Boolean;
begin
  Result := FSanitizePurchaseInvoices;
end;

procedure TeiParams.SetDefaultDecimals(const Value: Byte);
begin
  FDefaultDecimals := Value;
end;

procedure TeiParams.SetDefaultMaxDecimals(const Value: Byte);
begin
  FDefaultMaxDecimals := Value;
end;

procedure TeiParams.SetDefaultMaxLength(const Value: Integer);
begin
  FDefaultMaxLength := Value;
end;

procedure TeiParams.SetDefaultMinLength(const Value: Integer);
begin
  FDefaultMinLength := Value;
end;

procedure TeiParams.SetDefaultOccurrence(const Value: TeiOccurrence);
begin
  FDefaultOccurrence := Value;
end;

procedure TeiParams.SetInterOperationDelay(const Value: Integer);
begin
  FInterOperationDelay := Value;
end;

procedure TeiParams.SetRowCurrencyDecimals(const Value: Byte);
begin
  FRowCurrencyDecimals := Value;
end;

procedure TeiParams.SetRowQuantityDecimals(const Value: Byte);
begin
  FRowQuantityDecimals := Value;
end;

procedure TeiParams.SetSanitizePurchaseInvoices(const Value: Boolean);
begin
  FSanitizePurchaseInvoices := Value;
end;

end.
