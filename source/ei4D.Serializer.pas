unit ei4D.Serializer;

interface

uses
  ei4D.Serializer.Interfaces, ei4D.Invoice.Interfaces, ei4D.Invoice.Prop.Interfaces;

const
  INDENT_UNIT = 2;

type

  TeiSerializerXML = class(TInterfacedObject, IeiSerializer)
  private
    function PropToXML(const AProp: IeiBaseProperty; const AIndentLevel: Integer): String;
    function XMLExtractPropValue(const AXMLText, APropName: String; var APos: Integer): String;
    function XMLFindTag(const AXMLText: String; var APos: Integer): String;
    procedure XMLToProp(const AProp: IeiBaseProperty; const AXMLText: String; var APos: Integer);
  public
    procedure FromXML(const AInvoice: IFatturaElettronicaType; const AXMLText: String);
    function ToXML(const AInvoice: IFatturaElettronicaType): String;
  end;

implementation

uses
  System.SysUtils, ei4D.Exception, ei4D.Invoice.Factory;

{ TeiSerializerXML }

function TeiSerializerXML.PropToXML(const AProp: IeiBaseProperty; const AIndentLevel: Integer): String;
var
  LProp: IeiBaseProperty;
begin
  Result := '';
  if AProp.IsNull then
    Exit;
  case AProp.Kind of
    pkValue:
      Result := StringOfChar(' ', (AIndentLevel + 1) * INDENT_UNIT) + Format('<%s>%s</%s>' + sLineBreak, [AProp.Name, AProp.ValueAsString, AProp.Name]);
    pkBlock:
      begin
        Result := StringOfChar(' ', (AIndentLevel + 1) * INDENT_UNIT) + Format('<%s>' + sLineBreak, [AProp.Name]);
        for LProp in (AProp as IeiComplexProperty) do
          Result := Result + PropToXML(LProp, AIndentLevel + 1);
        Result := Result + StringOfChar(' ', (AIndentLevel + 1) * INDENT_UNIT) + Format('</%s>' + sLineBreak, [AProp.Name]);
      end;
    pkList:
      for LProp in (AProp as IeiComplexProperty) do
        Result := Result + PropToXML(LProp, AIndentLevel);
  end;
end;

function TeiSerializerXML.ToXML(const AInvoice: IFatturaElettronicaType): String;
begin
  Result := PropToXML(AInvoice, -1);
end;

function TeiSerializerXML.XMLExtractPropValue(const AXMLText, APropName: String; var APos: Integer): String;
var
  LStartPos: Integer;
begin
  LStartPos := APos;
  APos := AXMLText.IndexOf('</' + APropName + '>', APos);
  if (APos = -1) then
    raise eiSerializerException.Create(Format('Closing tag not found for property named "%s"', [APropName]));
  Result := AXMLText.Substring(LStartPos, APos - LStartPos);
  Inc(APos, APropName.Length + 3);
end;

function TeiSerializerXML.XMLFindTag(const AXMLText: String; var APos: Integer): String;
var
  LStartPos: Integer;
begin
  LStartPos := AXMLText.IndexOf('<', APos);
  APos := AXMLText.IndexOf('>', LStartPos);
  if (LStartPos = -1) or (APos = -1) then
    raise eiSerializerException.Create('Tag not found');
  Result := AXMLText.Substring(LStartPos + 1, APos - LStartPos - 1);
  Inc(APos);
end;

procedure TeiSerializerXML.XMLToProp(const AProp: IeiBaseProperty; const AXMLText: String; var APos: Integer);
var
  LCurrTagName: String;
begin
  case AProp.Kind of
    pkValue:
      AProp.ValueAsString := XMLExtractPropValue(AXMLText, AProp.Name, APos);
    pkBlock:
      begin
        repeat
          LCurrTagName := XMLFindTag(AXMLText, APos);
          if LCurrTagName.EndsWith('/') then
            Continue;
          if LCurrTagName.StartsWith('/') then
            Break;
          XMLToProp((AProp as IeiBlock).Props[LCurrTagName], AXMLText, APos);
        until False;
      end;
    pkList:
      XMLToProp((AProp as IeiList)._Add, AXMLText, APos);
  end;
end;

procedure TeiSerializerXML.FromXML(const AInvoice: IFatturaElettronicaType; const AXMLText: String);
var
  LPos: Integer;
begin
  LPos := 0;
  XMLFindTag(AXMLText, LPos);
  XMLToProp(AInvoice, AXMLText, LPos);
end;

end.
