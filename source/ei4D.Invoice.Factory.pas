unit ei4D.Invoice.Factory;

interface

uses
  ei4D.Invoice.Prop.Interfaces, system.Rtti,
  system.TypInfo, system.Generics.Collections, System.Classes,
  ei4D.Invoice.Interfaces, ei4D;

type

  TeiInvoiceFactory = class
  private
    class function InternalNewInvoiceFromString(AStringXML: String; const AParams: IeiParams): IFatturaElettronicaType;
  public
    class function NewBaseProp(const AID, AName: String; const AOccurrence: TeiOccurrence; const AMaxLength, AMinLength, AMaxDecimals, ADecimals: Integer; const ARegEx: String): IeiBaseProperty;
    class function NewProperty(const ATypeInfo: PTypeInfo; const AID, AName: String; const AParams: IeiParams; const AOccurrence: TeiOccurrence;
      const AMaxLength, AMinLength, AMaxDecimals, ADecimals: Integer; const ARegEx: String): IeiBaseProperty;

    class function NewInvoice(const AParams: IeiParams): IFatturaElettronicaType;
    class function NewInvoiceFromString(const AStringXML: String; const AParams: IeiParams): IFatturaElettronicaType;
    class function NewInvoiceFromStringBase64(const ABase64StringXML: String; const AParams: IeiParams): IFatturaElettronicaType;
    class function NewInvoiceFromFile(const AFileName: String; const AParams: IeiParams): IFatturaElettronicaType;
    class function NewInvoiceFromStream(const AStream: TStream; const AParams: IeiParams): IFatturaElettronicaType;
    class function NewInvoiceFromStreamBase64(const AStream: TStream; const AParams: IeiParams): IFatturaElettronicaType;

    class function NewInvoiceCollection: IeiInvoiceCollection;
    class function NewInvoiceIDCollection: IeiInvoiceIDCollection;
  end;

implementation

uses
  ei4D.Invoice.Prop.Base, ei4D.Invoice.Prop, ei4D.Invoice.Prop.Block,
  system.SysUtils, ei4D.Invoice.Prop.List,
  ei4D.Invoice.Prop.List.Enumerator, ei4D.Params,
  ei4D.Serializer.Factory, ei4D.Utils.Sanitizer,
  ei4D.Utils, System.NetEncoding, ei4D.Invoice.Collections;

{ TeiPropFactory }

class function TeiInvoiceFactory.InternalNewInvoiceFromString(AStringXML: String; const AParams: IeiParams): IFatturaElettronicaType;
begin
  AStringXML := TeiSanitizer.SanitizeReceivedXML(AStringXML);
  Result := TeiInvoiceFactory.NewInvoice(AParams);
  TeiSerializerFactory.NewSerializer.FromXML(Result, AStringXML);
end;

class function TeiInvoiceFactory.NewBaseProp(const AID, AName: String; const AOccurrence: TeiOccurrence; const AMaxLength, AMinLength, AMaxDecimals, ADecimals: Integer; const ARegEx: String): IeiBaseProperty;
begin
  Result := TeiBaseProperty.Create(AID, AName, AOccurrence, AMaxLength, AMinLength, AMaxDecimals, ADecimals, ARegEx); // Params value are not important
end;

class function TeiInvoiceFactory.NewProperty(const ATypeInfo: PTypeInfo; const AID, AName: String; const AParams: IeiParams; const AOccurrence: TeiOccurrence;
      const AMaxLength, AMinLength, AMaxDecimals, ADecimals: Integer; const ARegEx: String): IeiBaseProperty;
var
  LGUID: TGUID;
begin
  LGUID := ATypeInfo.TypeData.GUID;
  if LGUID = IeiDate then
    Result := TeiDateProperty.Create(AID, AName, AOccurrence, AMaxLength, AMinLength, AMaxDecimals, ADecimals, ARegEx)
  else if LGUID = IeiDateTime then
    Result := TeiDateTimeProperty.Create(AID, AName, AOccurrence, AMaxLength, AMinLength, AMaxDecimals, ADecimals, ARegEx)
  else if LGUID = IeiDecimal then
    Result := TeiDecimalProperty.Create(AID, AName, AOccurrence, AMaxLength, AMinLength, AMaxDecimals, ADecimals, ARegEx)
  else if LGUID = IeiInteger then
    Result := TeiIntegerProperty.Create(AID, AName, AOccurrence, AMaxLength, AMinLength, AMaxDecimals, ADecimals, ARegEx)
  else if LGUID = IeiString then
    Result := TeiStringProperty.Create(AID, AName, AOccurrence, AMaxLength, AMinLength, AMaxDecimals, ADecimals, ARegEx)
  else if LGUID = IeiBase64 then
    Result := TeiBase64Property.Create(AID, AName, AOccurrence, AMaxLength, AMinLength, AMaxDecimals, ADecimals, ARegEx)
  else if (AOccurrence = o0N) or (AOccurrence = o1N) then
    Result := TeiListProperty.Create(ATypeInfo, AID, AName, AParams, AOccurrence, AMaxLength, AMinLength, AMaxDecimals, ADecimals)
  else if (AOccurrence = o01) or (AOccurrence = o11) then
    Result := TeiBlockProperty.Create(ATypeInfo, AID, AName, AParams, AOccurrence);
end;

class function TeiInvoiceFactory.NewInvoice(const AParams: IeiParams): IFatturaElettronicaType;
begin
  Result := TeiBlockProperty.Create(TypeInfo(IFatturaElettronicaType), '', 'FatturaElettronica', AParams, oUndefined) as IFatturaElettronicaType;
end;

class function TeiInvoiceFactory.NewInvoiceCollection: IeiInvoiceCollection;
begin
  Result := TeiInvoiceCollectionEx.Create;
end;

class function TeiInvoiceFactory.NewInvoiceFromFile(const AFileName: String; const AParams: IeiParams): IFatturaElettronicaType;
var
  LFileStream: TFileStream;
begin
  LFileStream := TFileStream.Create(AFileName, fmOpenRead);
  try
    Result := InternalNewInvoiceFromString(TeiUtils.StreamToString(LFileStream), AParams);
  finally
    LFileStream.Free;
  end;
end;

class function TeiInvoiceFactory.NewInvoiceFromStream(const AStream: TStream; const AParams: IeiParams): IFatturaElettronicaType;
begin
  Result := InternalNewInvoiceFromString(TeiUtils.StreamToString(AStream), AParams);
end;

class function TeiInvoiceFactory.NewInvoiceFromStreamBase64(const AStream: TStream; const AParams: IeiParams): IFatturaElettronicaType;
begin
  Result := NewInvoiceFromStringBase64(TeiUtils.StreamToString(AStream), AParams);
end;

class function TeiInvoiceFactory.NewInvoiceFromString(const AStringXML: String; const AParams: IeiParams): IFatturaElettronicaType;
begin
  Result := InternalNewInvoiceFromString(AStringXML, AParams);
end;

class function TeiInvoiceFactory.NewInvoiceFromStringBase64(const ABase64StringXML: String; const AParams: IeiParams): IFatturaElettronicaType;
begin
  Result := InternalNewInvoiceFromString(TNetEncoding.Base64.Decode(ABase64StringXML), AParams);
end;

class function TeiInvoiceFactory.NewInvoiceIDCollection: IeiInvoiceIDCollection;
begin
  Result := TeiInvoiceIDCollectionEx.Create;
end;

end.
