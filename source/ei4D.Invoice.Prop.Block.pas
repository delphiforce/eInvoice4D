unit ei4D.Invoice.Prop.Block;

interface

uses
  System.Rtti, System.Generics.Collections, ei4D.Invoice.Prop.Interfaces,
  System.TypInfo, ei4D;

type

  TeiPropCollection = TList<IeiBaseProperty>;

  TeiBlockProperty = class(TVirtualInterface, IeiBaseProperty, IeiComplexProperty, IeiBlock)
  private
    FPropInfo: IeiBaseProperty;
    FProps: TeiPropCollection;
    FTempData: String;
    procedure DoInvoke(Method: TRttiMethod; const Args: TArray<TValue>; out Result: TValue);
    procedure FillProps(PIID: PTypeInfo; const AParams: IeiParams);
    function PropertyExists(const APropName: String): boolean;
  public
    constructor Create(PIID: PTypeInfo; const AID, AName: String; const AParams: IeiParams; const AOccurrence: TeiOccurrence); overload;
    destructor Destroy; override;
    // Begin: Leave this methods public to ensure RTTI informations on them
    procedure Clear;
    function Decimals: Integer;
    function FullQualifiedName: String;
    function ID: String;
    function IsEmptyOrZero: boolean;
    function IsMandatory: boolean;
    function IsNull: boolean;
    function Kind: TeiPropKind;
    function MaxDecimals: Integer;
    function MaxLength: Integer;
    function MinLength: Integer;
    function Name: String;
    function Occurrence: TeiOccurrence;
    function OccurrenceAsString: String;
    function QualifiedName: String;
    function RegEx: String;
    // TempData
    procedure SetTempData(const AValue: String);
    function GetTempData: String;
    property TempData: String read GetTempData write SetTempData;
    // ValueAsString property
    function GetValueAsString: String; virtual;
    procedure SetValueAsString(const AValue: String); virtual;
    // Props property
    function GetEnumerator: TEnumerator<IeiBaseProperty>;
    function GetProps(const APropName: String): IeiBaseProperty;
    property Props[const APropName: String]: IeiBaseProperty read GetProps;
    // End: Leave this methods public to ensure RTTI informations on them
  end;

implementation

uses
  ei4D.Invoice.Factory, System.SysUtils, ei4D.Attributes,
  ei4D.Exception, ei4D.Params;

{ TeiInsaneVirtualProp }

function TeiBlockProperty.PropertyExists(const APropName: String): boolean;
var
  LProp: IeiBaseProperty;
begin
  Result := False;
  for LProp in FProps do
    if LProp.Name.Equals(APropName) then
      Exit(True);
end;

constructor TeiBlockProperty.Create(PIID: PTypeInfo; const AID, AName: String; const AParams: IeiParams; const AOccurrence: TeiOccurrence);
begin
  inherited Create(PIID);
  FPropInfo := TeiInvoiceFactory.NewBaseProp(AID, AName, AOccurrence, AParams.DefaultMaxLength, AParams.DefaultMinLength, AParams.DefaultMaxDecimals,
    AParams.DefaultDecimals, String.Empty);
  FProps := TeiPropCollection.Create;
  FillProps(PIID, AParams);
  FTempData := String.Empty;
  OnInvoke := DoInvoke;
end;

function TeiBlockProperty.Decimals: Integer;
begin
  Result := FPropInfo.Decimals;
end;

destructor TeiBlockProperty.Destroy;
begin
  FProps.Free;
  inherited;
end;

procedure TeiBlockProperty.DoInvoke(Method: TRttiMethod; const Args: TArray<TValue>; out Result: TValue);
var
  LConcreteMethod: TRttiMethod;
  LPropPtr: Pointer;
begin
  // If the method is a VirtualProperty then return it...
  if PropertyExists(Method.Name) then
  begin
    Supports(Props[Method.Name], (Method.ReturnType as TRttiInterfaceType).GUID, LPropPtr);
    TValue.MakeWithoutCopy(@LPropPtr, Method.ReturnType.Handle, Result, not Method.ReturnType.IsManaged);
  end
  // ...else invoke as self concrete method
  else
  begin
    // Get the destination RttiMethod
    LConcreteMethod := TRttiContext.Create.GetType(Self.ClassInfo).GetMethod(Method.Name);
    // Invoke the method
    Result := LConcreteMethod.Invoke(Self, Copy(Args, 1, Length(Args))); // Do not consider the first element of Args
  end;
end;

procedure TeiBlockProperty.FillProps(PIID: PTypeInfo; const AParams: IeiParams);
var
  LAttribute: TCustomAttribute;
  LContext: TRttiContext;
  LDecimals: Byte;
  LFullID: String;
  LMethod: TRttiMethod;
  LMaxDecimals: Integer;
  LMaxLength: Integer;
  LMinLength: Integer;
  LOccurrence: TeiOccurrence;
  LRegEx: String;
  LType: TRttiType;
begin
  LContext := TRttiContext.Create;
  try
    LType := LContext.GetType(PIID);
    for LMethod in LType.GetMethods do
    begin
      LDecimals := AParams.DefaultDecimals;
      LMaxDecimals := AParams.DefaultMaxDecimals;
      LMaxLength := AParams.DefaultMaxLength;
      LMinLength := AParams.DefaultMinLength;
      LOccurrence := AParams.DefaultOccurrence;
      LRegEx := String.Empty;
      for LAttribute in LMethod.GetAttributes do
      begin
        if LAttribute is eiBasePropAttribute then
        begin
          LFullID := eiBasePropAttribute(LAttribute).FullID(Self.ID);
          LOccurrence := eiBasePropAttribute(LAttribute).Occurrence;
        end;
        if LAttribute is eiBasePropValueAttribute then
        begin
          LMaxLength := eiBasePropValueAttribute(LAttribute).MaxLength;
          LMinLength := eiBasePropValueAttribute(LAttribute).MinLength;
        end;
        if LAttribute is eiMaxDecimals then
          LMaxDecimals := eiMaxDecimals(LAttribute).Value;
        if LAttribute is eiRowQuantity then
          LDecimals := AParams.RowQuantityDecimals;
        if LAttribute is eiRowCurrency then
          LDecimals := AParams.RowCurrencyDecimals;
        if LAttribute is eiRegEx then
          LRegEx := eiRegEx(LAttribute).Value;
      end;
      // To avoid GetProps function mapping as property
      if LOccurrence > oUndefined then
        FProps.Add(TeiInvoiceFactory.NewProperty(LMethod.ReturnType.Handle, LFullID, LMethod.Name, AParams, LOccurrence, LMaxLength, LMinLength, LMaxDecimals,
          LDecimals, LRegEx));
    end;
  finally
    LContext.Free;
  end;
end;

function TeiBlockProperty.GetEnumerator: TEnumerator<IeiBaseProperty>;
begin
  Result := FProps.GetEnumerator;
end;

function TeiBlockProperty.GetProps(const APropName: String): IeiBaseProperty;
var
  LProp: IeiBaseProperty;
begin
  for LProp in FProps do
    if LProp.Name.Equals(APropName) then
      Exit(LProp);
  raise eiPropertyException.Create(Format('Property "%s" not found on block "%s"', [APropName, Name]));
end;

function TeiBlockProperty.GetTempData: String;
begin
  Result := FTempData;
end;

procedure TeiBlockProperty.Clear;
begin
  FPropInfo.Clear;
end;

function TeiBlockProperty.GetValueAsString: String;
begin
  raise eiPropertyException.Create(Format('Property "ValuesAsString" on block type property "%s" is not accessible', [Name]));
end;

function TeiBlockProperty.FullQualifiedName: String;
begin
  Result := FPropInfo.FullQualifiedName;
end;

function TeiBlockProperty.ID: String;
begin
  Result := FPropInfo.ID;
end;

function TeiBlockProperty.IsEmptyOrZero: boolean;
var
  LProperty: IeiBaseProperty;
begin
  Result := True;
  for LProperty in FProps do
    if not LProperty.IsEmptyOrZero then
      Exit(False);
end;

function TeiBlockProperty.IsMandatory: boolean;
begin
  Result := FPropInfo.IsMandatory;
end;

function TeiBlockProperty.IsNull: boolean;
var
  LProperty: IeiBaseProperty;
begin
  Result := True;
  for LProperty in FProps do
    if not LProperty.IsNull then
      Exit(False);
end;

function TeiBlockProperty.Kind: TeiPropKind;
begin
  Result := pkBlock;
end;

function TeiBlockProperty.MaxDecimals: Integer;
begin
  Result := FPropInfo.MaxDecimals;
end;

function TeiBlockProperty.MaxLength: Integer;
begin
  Result := FPropInfo.MaxLength;
end;

function TeiBlockProperty.MinLength: Integer;
begin
  Result := FPropInfo.MinLength;
end;

function TeiBlockProperty.Name: String;
begin
  Result := FPropInfo.Name;
end;

function TeiBlockProperty.Occurrence: TeiOccurrence;
begin
  Result := FPropInfo.Occurrence;
end;

function TeiBlockProperty.OccurrenceAsString: String;
begin
  Result := FPropInfo.OccurrenceAsString;
end;

function TeiBlockProperty.QualifiedName: String;
begin
  Result := FPropInfo.QualifiedName;
end;

function TeiBlockProperty.RegEx: String;
begin
  Result := FPropInfo.RegEx;
end;

procedure TeiBlockProperty.SetTempData(const AValue: String);
begin
  FTempData := AValue;
end;

procedure TeiBlockProperty.SetValueAsString(const AValue: String);
begin
  raise eiPropertyException.Create(Format('Property "ValuesAsString" on block type property "%s" is not accessible', [Name]));
end;

end.
