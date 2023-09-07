unit ei4D.Invoice.Prop.List;

interface

uses
  System.Rtti, System.Generics.Collections, ei4D.Invoice.Prop.Interfaces,
  System.TypInfo, ei4D;

type

  TeiListProperty = class(TVirtualInterface, IeiBaseProperty, IeiComplexProperty, IeiList)
  private
    FItemTypeInfo: PTypeInfo;
    FList: TList<IeiBaseProperty>;
    FParams: IeiParams;
    FPropInfo: IeiBaseProperty;
    FTempData: String;
    procedure DoInvoke(AMethod: TRttiMethod; const Args: TArray<TValue>; out Result: TValue);
    function TryInvokeMethod(const AInstance: TObject; const AMethod: TRttiMethod; const Args: TArray<TValue>; var AResultValue: TValue): Boolean;
    procedure ExtractItemTypeInfo(const PIID: PTypeInfo);
    procedure RaiseException(const AMsg: String);
    function GetEnumerator: TEnumerator<IeiBaseProperty>;
    function _Add: IeiBaseProperty;
  protected
  public
    constructor Create(const PIID: PTypeInfo; const AID, AName: String; const AParams: IeiParams; const AOccurrence: TeiOccurrence;
      const AMaxLength, AMinLength, AMaxDecimals, ADecimals: Integer); overload;
    destructor Destroy; override;
    // Begin: Leave this methods public to ensure RTTI informations on them
    procedure Clear;
    function Decimals: Integer;
    function FullQualifiedName: String;
    function ID: String;
    function IsEmptyOrZero: Boolean;
    function IsMandatory: Boolean;
    function IsNull: Boolean;
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

    function Add: IeiBaseProperty;
    function Count: Integer;
    function Last(const ACreateFirstIfEmpty: Boolean = False): IeiBaseProperty;
    // End: Leave this methods public to ensure RTTI informations on them
  end;

implementation

uses
  ei4D.Invoice.Factory, System.SysUtils, ei4D.Exception;

{ TeiListProperty }

function TeiListProperty.Add: IeiBaseProperty;
begin
  Result := TeiInvoiceFactory.NewProperty(FItemTypeInfo, ID, Name, FParams, o01, MaxLength, MinLength, MaxDecimals, Decimals, RegEx);
  // o01 perchè altrimenti considera la item come lista
  FList.Add(Result);
end;

function TeiListProperty.Last(const ACreateFirstIfEmpty: Boolean = False): IeiBaseProperty;
begin
  if ACreateFirstIfEmpty and (FList.Count = 0) then
    Result := Add
  else
    Result := FList[FList.Count - 1];
end;

function TeiListProperty.Decimals: Integer;
begin
  Result := FPropInfo.Decimals;
end;

destructor TeiListProperty.Destroy;
begin
  FList.Free;
  inherited;
end;

procedure TeiListProperty.DoInvoke(AMethod: TRttiMethod; const Args: TArray<TValue>; out Result: TValue);
begin
  // First try to execute method in the self class (if exists)
  if not TryInvokeMethod(Self, AMethod, Args, Result) then
    // Second try to execute method in the FList class (if exists)
    if not TryInvokeMethod(FList, AMethod, Args, Result) then
      // Else raise an exception
      RaiseException(Format('"%s" method not found.', [AMethod.Name]));
end;

function TeiListProperty.TryInvokeMethod(const AInstance: TObject; const AMethod: TRttiMethod; const Args: TArray<TValue>; var AResultValue: TValue): Boolean;
var
  LConcreteMethod: TRttiMethod;
  LArgs: TArray<TValue>;
  LPropPtr: Pointer;
begin
  LConcreteMethod := TRttiContext.Create.GetType(AInstance.ClassInfo).GetMethod(AMethod.Name);
  Result := Assigned(LConcreteMethod);
  if Result then
  begin
    // Do not consider the first element of Args
    LArgs := Copy(Args, 1, Length(Args));
    AResultValue := LConcreteMethod.Invoke(AInstance, LArgs);
    // If the ReturnType of the method is an IieProperty descendant then cast it properly
    if (not AResultValue.IsEmpty) and (AResultValue.TypeInfo.TypeData.GUID = IeiBaseProperty) then
    begin
      Supports(AResultValue.AsType<IeiBaseProperty>, (AMethod.ReturnType as TRttiInterfaceType).GUID, LPropPtr);
      TValue.MakeWithoutCopy(@LPropPtr, AMethod.ReturnType.Handle, AResultValue, not AMethod.ReturnType.IsManaged);
    end;
  end;
end;

function TeiListProperty._Add: IeiBaseProperty;
begin
  Result := Self.Add;
end;

procedure TeiListProperty.ExtractItemTypeInfo(const PIID: PTypeInfo);
var
  LContext: TRttiContext;
  LListType: TRttiInterfaceType;
begin
  LContext := TRttiContext.Create;
  try
    LListType := LContext.GetType(PIID) as TRttiInterfaceType;
    FItemTypeInfo := (LListType.GetMethod('GetItem').ReturnType as TRttiInterfaceType).Handle;
  finally
    LContext.Free;
  end;
end;

procedure TeiListProperty.RaiseException(const AMsg: String);
begin
  raise eiPropertyException.Create(Format('%s <%s>: %s', [ID, Name, AMsg]));
end;

function TeiListProperty.RegEx: String;
begin
  Result := FPropInfo.RegEx;
end;

procedure TeiListProperty.Clear;
begin
  FList.Clear;
end;

function TeiListProperty.Count: Integer;
begin
  Result := FList.Count;
end;

function TeiListProperty.GetEnumerator: TEnumerator<IeiBaseProperty>;
begin
  Result := FList.GetEnumerator;
end;

function TeiListProperty.GetTempData: String;
begin
  Result := FTempData;
end;

function TeiListProperty.GetValueAsString: String;
begin
  raise eiPropertyException.Create(Format('Property "ValuesAsString" on list type property "%s" is not accessible', [Name]));
end;

constructor TeiListProperty.Create(const PIID: PTypeInfo; const AID, AName: String; const AParams: IeiParams; const AOccurrence: TeiOccurrence;
      const AMaxLength, AMinLength, AMaxDecimals, ADecimals: Integer);
begin
  inherited Create(PIID);
  FList := TList<IeiBaseProperty>.Create;
  FParams := AParams;
  FPropInfo := TeiInvoiceFactory.NewBaseProp(AID, AName, AOccurrence, AMaxLength, AMinLength, AMaxDecimals, ADecimals, String.Empty);
  ExtractItemTypeInfo(PIID);
  FTempData := String.Empty;
  OnInvoke := DoInvoke;
end;

function TeiListProperty.FullQualifiedName: String;
begin
  Result := FPropInfo.FullQualifiedName;
end;

function TeiListProperty.ID: String;
begin
  Result := FPropInfo.ID;
end;

function TeiListProperty.IsEmptyOrZero: Boolean;
begin
  Result := FList.Count = 0;
end;

function TeiListProperty.IsMandatory: Boolean;
begin
  Result := FPropInfo.IsMandatory;
end;

function TeiListProperty.IsNull: Boolean;
var
  LProperty: IeiBaseProperty;
begin
  Result := True;
  for LProperty in FList do
    if not LProperty.IsNull then
      Exit(False);
end;

function TeiListProperty.Kind: TeiPropKind;
begin
  Result := pkList;
end;

function TeiListProperty.MaxDecimals: Integer;
begin
  Result := FPropInfo.MaxDecimals;
end;

function TeiListProperty.MaxLength: Integer;
begin
  Result := FPropInfo.MaxLength;
end;

function TeiListProperty.MinLength: Integer;
begin
  Result := FPropInfo.MinLength;
end;

function TeiListProperty.Name: String;
begin
  Result := FPropInfo.Name;
end;

function TeiListProperty.Occurrence: TeiOccurrence;
begin
  Result := FPropInfo.Occurrence;
end;

function TeiListProperty.OccurrenceAsString: String;
begin
  Result := FPropInfo.OccurrenceAsString;
end;

function TeiListProperty.QualifiedName: String;
begin
  Result := FPropInfo.QualifiedName;
end;

procedure TeiListProperty.SetTempData(const AValue: String);
begin
  FTempData := AValue;
end;

procedure TeiListProperty.SetValueAsString(const AValue: String);
begin
  raise eiPropertyException.Create(Format('Property "ValuesAsString" on list type property "%s" is not accessible', [Name]));
end;

end.
