unit ei4D.Attributes;

interface

uses
  ei4D.Invoice.Prop.Interfaces;

type

{$REGION '===== BASE ATTRIBUTESS ====='}

eiBaseAttribute = class(TCustomAttribute)
end;

eiBaseIntegerAttribute = class(eiBaseAttribute)
private
  FValue: Integer;
public
  constructor Create(const AValue: Integer);
  property Value: Integer read FValue;
end;

eiBaseStringAttribute = class(eiBaseAttribute)
private
  FValue: String;
public
  constructor Create(const AValue: String);
  property Value: String read FValue;
end;

eiBasePropAttribute = class(eiBaseAttribute)
private
  FID: Byte;
  FOccurrence: TeiOccurrence;
public
  constructor Create(const AID: Byte; const AOccurrence: TeiOccurrence);
  function FullID(const AParentID: String): String;
  property Occurrence: TeiOccurrence read FOccurrence;
end;

eiBasePropValueAttribute = class(eiBasePropAttribute)
private
  FMaxLength: Integer;
  FMinLength: Integer;
public
  constructor Create(const AID: Byte; const AOccurrence: TeiOccurrence; const AMinLength, AMaxLength: Integer);
  property MaxLength: Integer read FMaxLength;
  property MinLength: Integer read FMinLength;
end;

{$ENDREGION} // END OF BASE ATTRIBUTES

eiProp = class(eiBasePropValueAttribute)
end;

eiBase64 = class(eiBasePropAttribute)
end;

eiBlock = class(eiBasePropAttribute)
end;

eiList = class(eiBasePropValueAttribute)
public
  constructor Create(const AID: Byte; const AOccurrence: TeiOccurrence); overload;
end;

eiMaxDecimals = class(eiBaseIntegerAttribute)
end;

eiRowQuantity = class(eiBaseAttribute)
end;

eiRowCurrency = class(eiBaseAttribute)
end;

eiRegEx = class(eiBaseStringAttribute)
end;

implementation

uses
  System.SysUtils;

{ eiPropertyAttribute }

constructor eiBasePropAttribute.Create(const AID: Byte; const AOccurrence: TeiOccurrence);
begin
  inherited Create;
  FID := AID;
  FOccurrence := AOccurrence;
end;

function eiBasePropAttribute.FullID(const AParentID: String): String;
begin
  Result := Format('%s.%d', [AParentID, FID]).Trim(['.']);
end;

{ eiBaseIntegerAttribute }

constructor eiBaseIntegerAttribute.Create(const AValue: Integer);
begin
  inherited Create;
  FValue := AValue;
end;

{ eiBasePropValueAttribute }

constructor eiBasePropValueAttribute.Create(const AID: Byte; const AOccurrence: TeiOccurrence; const AMinLength, AMaxLength: Integer);
begin
  inherited Create(AID, AOccurrence);
  FMaxLength := AMaxLength;
  FMinLength := AMinLength;
end;

{ eiList }

constructor eiList.Create(const AID: Byte; const AOccurrence: TeiOccurrence);
begin
  inherited Create(AID, AOccurrence, -1, -1);
end;

{ eiBaseStringAttribute }

constructor eiBaseStringAttribute.Create(const AValue: String);
begin
  FValue := AValue;
end;

end.
