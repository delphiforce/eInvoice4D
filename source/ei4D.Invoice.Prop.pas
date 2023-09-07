unit ei4D.Invoice.Prop;

interface

uses
  ei4D.Invoice.Prop.Interfaces, ei4D.Invoice.Prop.Base, System.Classes;

type

  TeiProperty<T> = class(TeiBaseProperty, IeiProperty<T>)
  strict private
    FValue: T;
  strict protected
    FValueAsString: String;
    function _IsValueToSetEmptyOrZero(const AValue: T): Boolean; virtual; abstract;
  public
    // Begin: Leave this methods public to ensure RTTI informations on them
    function IsEmptyOrZero: Boolean; override;
    function Kind: TeiPropKind; override;
    // Value property
    procedure SetValue(const AValue: T); virtual;
    function GetValue: T;
    property Value: T read GetValue write SetValue;
    // ValueDef property
    function GetValueDef: T; virtual; abstract;
    property ValueDef: T read GetValueDef;
    // ValueAsString property
    function GetValueAsString: String; override;
    procedure SetValueAsString(const AValue: String); override;
    // End: Leave this methods public to ensure RTTI informations on them
  end;

  TeiDateProperty = class(TeiProperty<TDate>, IeiDate)
  strict protected
    function _IsValueToSetEmptyOrZero(const AValue: TDate): Boolean; override;
  public
    // Begin: Leave this methods public to ensure RTTI informations on them
    function GetValueDef: TDate; override;
    procedure SetValue(const AValue: TDate); override;
    procedure SetValueAsString(const AValue: String); override;
    // End: Leave this methods public to ensure RTTI informations on them
  end;

  TeiDateTimeProperty = class(TeiProperty<TDateTime>, IeiDateTime)
  strict protected
    function _IsValueToSetEmptyOrZero(const AValue: TDateTime): Boolean; override;
  public
    // Begin: Leave this methods public to ensure RTTI informations on them
    function GetValueDef: TDateTime; override;
    procedure SetValue(const AValue: TDateTime); override;
    procedure SetValueAsString(const AValue: String); override;
    // End: Leave this methods public to ensure RTTI informations on them
  end;

  TeiDecimalProperty = class(TeiProperty<double>, IeiDecimal)
  strict protected
    function _IsValueToSetEmptyOrZero(const AValue: Double): Boolean; override;
  public
    // Begin: Leave this methods public to ensure RTTI informations on them
    function GetValueDef: Double; override;
    procedure SetValue(const AValue: Double); override;
    procedure SetValueAsString(const AValue: String); override;
    // End: Leave this methods public to ensure RTTI informations on them
  end;

  TeiIntegerProperty = class(TeiProperty<integer>, IeiInteger)
  strict protected
    function _IsValueToSetEmptyOrZero(const AValue: Integer): Boolean; override;
  public
    // Begin: Leave this methods public to ensure RTTI informations on them
    function GetValueDef: Integer; override;
    procedure SetValue(const AValue: Integer); override;
    procedure SetValueAsString(const AValue: String); override;
    // End: Leave this methods public to ensure RTTI informations on them
  end;

  TeiStringProperty = class(TeiProperty<string>, IeiString)
  strict protected
    function _IsValueToSetEmptyOrZero(const AValue: String): Boolean; override;
  public
    // Begin: Leave this methods public to ensure RTTI informations on them
    function GetValueDef: String; override;
    procedure SetValue(const AValue: String); override;
    procedure SetValueAsString(const AValue: String); override;
    // End: Leave this methods public to ensure RTTI informations on them
  end;

  TeiBase64Property = class(TeiProperty<string>, IeiBase64)
  strict private
    FStream: TBytesStream;
  strict protected
    function _IsValueToSetEmptyOrZero(const AValue: String): Boolean; override;
  public
    constructor Create(const AID, AName: String; const AOccurrence: TeiOccurrence; const AMaxLength, AMinLength, AMaxDecimals, ADecimals: Integer; const ARegEx: String); override;
    destructor Destroy; override;
    // Begin: Leave this methods public to ensure RTTI informations on them
    function GetValueDef: String; override;
    function GetValueAsString: String; override;
    procedure SetValueAsString(const AValue: String); override;
    procedure LoadFromStream(const AStream: TStream);
    procedure LoadFromFile(const AFileName: string);
    procedure SaveToStream(const AStream: TStream);
    procedure SaveToFile(const AFileName: string);
    function AsStream: TStream;
    // End: Leave this methods public to ensure RTTI informations on them
  end;

implementation

uses
  System.NetEncoding, System.SysUtils, ei4D.Utils, ei4D.Exception, System.Math;

{ TeiProperty<T> }

function TeiProperty<T>.GetValue: T;
begin
  if IsNull then
    RaiseException('Cannot read a NULL property.');
  Result := FValue;
end;

function TeiProperty<T>.GetValueAsString: String;
begin
  Result := FValueAsString;
end;

function TeiProperty<T>.IsEmptyOrZero: Boolean;
begin
  Result := IsNull or _IsValueToSetEmptyOrZero(FValue);
end;

function TeiProperty<T>.Kind: TeiPropKind;
begin
  Result := pkValue;
end;

procedure TeiProperty<T>.SetValue(const AValue: T);
begin
  FValue := AValue;
  _SetPropIsNull(_IsValueToSetEmptyOrZero(AValue) and not IsMandatory);
end;

procedure TeiProperty<T>.SetValueAsString(const AValue: String);
begin
  FValueAsString := AValue;
end;

{ TeiPropertyBase64 }

constructor TeiBase64Property.Create(const AID, AName: String; const AOccurrence: TeiOccurrence; const AMaxLength, AMinLength, AMaxDecimals, ADecimals: Integer; const ARegEx: String);
begin
  inherited;
  FStream := nil;
end;

destructor TeiBase64Property.Destroy;
begin
  if Assigned(FStream) then
    FStream.Free;
  inherited;
end;

function TeiBase64Property.AsStream: TStream;
begin
  if Assigned(FStream) then
    FStream.Free;
  FStream := TBytesStream.Create(TNetEncoding.Base64.DecodeStringToBytes(Value));
  Result := FStream;
end;

procedure TeiBase64Property.LoadFromFile(const AFileName: string);
var
  LFileStream: TFileStream;
begin
  LFileStream := TFileStream.Create(AFileName, fmOpenRead or fmShareDenyWrite);
  try
    Self.LoadFromStream(LFileStream);
  finally
    LFileStream.Free;
  end;
end;

procedure TeiBase64Property.LoadFromStream(const AStream: TStream);
var
  LStringStream: TStringStream;
begin
  LStringStream := TStringStream.Create;
  try
    TNetEncoding.Base64.Encode(AStream, LStringStream);
    Value := LStringStream.DataString;
  finally
    LStringStream.Free;
  end;
end;

procedure TeiBase64Property.SaveToFile(const AFileName: string);
var
  LFileStream: TFileStream;
begin
  LFileStream := TFileStream.Create(AFileName, fmCreate);
  try
    Self.SaveToStream(LFileStream);
  finally
    LFileStream.Free;
  end;
end;

procedure TeiBase64Property.SaveToStream(const AStream: TStream);
var
  LBytesStream: TBytesStream;
begin
  LBytesStream := TBytesStream.Create(TNetEncoding.Base64.DecodeStringToBytes(Value));
  try
    AStream.CopyFrom(LBytesStream, 0);
  finally
    LBytesStream.Free;
  end;
end;

function TeiBase64Property.GetValueAsString: String;
begin
  // Note: Base64 property do not use FValueAsString field but FValue only
  Result := Value;
end;

function TeiBase64Property.GetValueDef: String;
begin
  if IsNull then
    Result := String.Empty
  else
    Result := Value;
end;

procedure TeiBase64Property.SetValueAsString(const AValue: String);
begin
  // Note: Base64 property do not use FValueAsString field but FValue only
  Value := AValue;
end;

function TeiBase64Property._IsValueToSetEmptyOrZero(const AValue: String): Boolean;
begin
  Result := AValue.IsEmpty;
end;

{ TeiDateProperty }

function TeiDateProperty.GetValueDef: TDate;
begin
  if IsNull then
    Result := 0
  else
    Result := Value;
end;

procedure TeiDateProperty.SetValue(const AValue: TDate);
begin
  if _IsValueToSetEmptyOrZero(AValue) and IsMandatory then
    raise eiPropertyException.Create(Format('"Zero" is not a valid value for a mandatory DateTime property "%s" ()', [FullQualifiedName]));
  inherited;
  FValueAsString := TeiUtils.DateToString(AValue);
end;

procedure TeiDateProperty.SetValueAsString(const AValue: String);
begin
  inherited;
  inherited SetValue(TeiUtils.StringToDate(AValue));
end;

function TeiDateProperty._IsValueToSetEmptyOrZero(const AValue: TDate): Boolean;
begin
  Result := IsZero(AValue);
end;

{ TeiDecimalProperty }

function TeiDecimalProperty.GetValueDef: Double;
begin
  if IsNull then
    Result := 0
  else
    Result := Value;
end;

procedure TeiDecimalProperty.SetValue(const AValue: Double);
begin
  inherited;
  FValueAsString := TeiUtils.FloatToString(AValue, Decimals);
end;

procedure TeiDecimalProperty.SetValueAsString(const AValue: String);
begin
  inherited;
  inherited SetValue(TeiUtils.StringToFloat(AValue));
end;

function TeiDecimalProperty._IsValueToSetEmptyOrZero(const AValue: Double): Boolean;
begin
  Result := IsZero(AValue);
end;

{ TeiIntegerProperty }

function TeiIntegerProperty.GetValueDef: Integer;
begin
  if IsNull then
    Result := 0
  else
    Result := Value;
end;

procedure TeiIntegerProperty.SetValue(const AValue: Integer);
begin
  inherited;
  FValueAsString := AValue.ToString;
end;

procedure TeiIntegerProperty.SetValueAsString(const AValue: String);
begin
  inherited;
  inherited SetValue(AValue.ToInteger);
end;

function TeiIntegerProperty._IsValueToSetEmptyOrZero(const AValue: Integer): Boolean;
begin
  Result := IsZero(AValue);
end;

{ TeiStringProperty }

function TeiStringProperty.GetValueDef: String;
begin
  if IsNull then
    Result := String.Empty
  else
    Result := Value;
end;

procedure TeiStringProperty.SetValue(const AValue: String);
begin
  inherited;
  FValueAsString := AValue;
end;

procedure TeiStringProperty.SetValueAsString(const AValue: String);
begin
  inherited;
  inherited SetValue(AValue);
end;

function TeiStringProperty._IsValueToSetEmptyOrZero(const AValue: String): Boolean;
begin
  Result := AValue.IsEmpty;
end;

{ TeiDateTimeProperty }

function TeiDateTimeProperty.GetValueDef: TDateTime;
begin
  if IsNull then
    Result := 0
  else
    Result := Value;
end;

procedure TeiDateTimeProperty.SetValue(const AValue: TDateTime);
begin
  if _IsValueToSetEmptyOrZero(AValue) and IsMandatory then
    raise eiPropertyException.Create(Format('"Zero" is not a valid value for a mandatory DateTime property "%s" ()', [FullQualifiedName]));
  inherited;
  FValueAsString := TeiUtils.DateTimeToString(AValue);
end;

procedure TeiDateTimeProperty.SetValueAsString(const AValue: String);
begin
  inherited;
  inherited SetValue(TeiUtils.StringToDateTime(AValue));
end;

function TeiDateTimeProperty._IsValueToSetEmptyOrZero(const AValue: TDateTime): Boolean;
begin
  Result := IsZero(AValue);
end;

end.
