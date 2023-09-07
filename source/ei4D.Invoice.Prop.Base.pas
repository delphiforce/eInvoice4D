unit ei4D.Invoice.Prop.Base;

interface

uses
  ei4D.Invoice.Prop.Interfaces;

type

  TeiBaseProperty = class(TInterfacedObject, IeiBaseProperty)
  private
    FDecimals: Integer;
    FID: String;
    FIsNull: Boolean;
    FMaxDecimals: Integer;
    FMaxLength: Integer;
    FMinLength: Integer;
    FName: String;
    FOccurrence: TeiOccurrence;
    FRegEx: String;
    FTempData: String;
  protected
    procedure _SetPropIsNull(const AIsNull: Boolean);
  public
    constructor Create(const AID, AName: String; const AOccurrence: TeiOccurrence; const AMaxLength, AMinLength, AMaxDecimals, ADecimals: Integer; const ARegEx: String); virtual;
    // Begin: Leave this methods public to ensure RTTI informations on them
    procedure Clear; virtual;
    function Decimals: Integer;
    function FullQualifiedName: String; virtual;
    function ID: String; virtual;
    function IsEmptyOrZero: Boolean; virtual;
    function IsMandatory: Boolean;
    function IsNull: Boolean; virtual;
    function Kind: TeiPropKind; virtual;
    function MaxDecimals: Integer;
    function MaxLength: Integer;
    function MinLength: Integer;
    function Name: String; virtual;
    function Occurrence: TeiOccurrence; virtual;
    function OccurrenceAsString: String; virtual;
    function QualifiedName: String; virtual;
    procedure RaiseException(const AMsg: String); virtual;
    function RegEx: String;
    // TempData
    procedure SetTempData(const AValue: String);
    function GetTempData: String;
    property TempData: String read GetTempData write SetTempData;
    // ValueAsString property
    function GetValueAsString: String; virtual;
    procedure SetValueAsString(const AValue: String); virtual;
    property ValueAsString: String read GetValueAsString write SetValueAsString;
    // End: Leave this methods public to ensure RTTI informations on them
  end;

implementation

uses
  ei4D.Exception, System.SysUtils, ei4D.Params;

{ TeiBaseProperty<T> }

procedure TeiBaseProperty.RaiseException(const AMsg: String);
begin
  raise eiPropertyException.Create(Format('%s <%s>: %s', [FID, FName, AMsg]));
end;

function TeiBaseProperty.RegEx: String;
begin
  Result := FRegEx;
end;

procedure TeiBaseProperty._SetPropIsNull(const AIsNull: Boolean);
begin
  FIsNull := AIsNull;
end;

procedure TeiBaseProperty.SetTempData(const AValue: String);
begin
  FTempData := AValue;
end;

procedure TeiBaseProperty.SetValueAsString(const AValue: String);
begin
  raise eiPropertyException.Create(Format('Property "ValuesAsString" on property "%s" is not accessible', [Name]));
end;

procedure TeiBaseProperty.Clear;
begin
  FIsNull := True;
end;

function TeiBaseProperty.GetTempData: String;
begin
  Result := FTempData;
end;

function TeiBaseProperty.GetValueAsString: String;
begin
  raise eiPropertyException.Create(Format('Property "ValuesAsString" on property "%s" is not accessible', [Name]));
end;

constructor TeiBaseProperty.Create(const AID, AName: String; const AOccurrence: TeiOccurrence; const AMaxLength, AMinLength, AMaxDecimals, ADecimals: Integer; const ARegEx: String);
begin
  inherited Create;
  FDecimals := ADecimals;
  FID := AID;
  FIsNull := True;
  FMaxDecimals := AMaxDecimals;
  FMaxLength := AMaxLength;
  FMinLength := AMinLength;
  FName := AName;
  FOccurrence := AOccurrence;
  FRegEx := ARegEx;
  FTempData := String.Empty;
end;

function TeiBaseProperty.Decimals: Integer;
begin
  Result := FDecimals;
end;

function TeiBaseProperty.FullQualifiedName: String;
begin
  Result := Format('<%s> %s (%s)', [FID, FName, OccurrenceAsString])
end;

function TeiBaseProperty.ID: String;
begin
  Result := FID;
end;

function TeiBaseProperty.IsEmptyOrZero: Boolean;
begin
  Result := FIsNull;
end;

function TeiBaseProperty.IsMandatory: Boolean;
begin
  Result := FOccurrence in [o11, o1N];
end;

function TeiBaseProperty.IsNull: Boolean;
begin
  Result := FIsNull;
end;

function TeiBaseProperty.Kind: TeiPropKind;
begin
  Result := pkUndefined;
end;

function TeiBaseProperty.MaxDecimals: Integer;
begin
  Result := FMaxDecimals;
end;

function TeiBaseProperty.MaxLength: Integer;
begin
  Result := FMaxLength;
end;

function TeiBaseProperty.MinLength: Integer;
begin
  Result := FMinLength;
end;

function TeiBaseProperty.Name: String;
begin
  Result := FName;
end;

function TeiBaseProperty.Occurrence: TeiOccurrence;
begin
  Result := FOccurrence;
end;

function TeiBaseProperty.OccurrenceAsString: String;
begin
  case FOccurrence of
    o01:
      Result := ('0.1');
    o0N:
      Result := ('0.N');
    o11:
      Result := ('1.1');
    o1N:
      Result := ('1.N');
  end;
end;

function TeiBaseProperty.QualifiedName: String;
begin
  Result := Format('<%s> %s', [FID, FName])
end;

end.
