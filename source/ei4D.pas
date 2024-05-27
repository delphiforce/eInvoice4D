{ *************************************************************************** }
{ }
{ eInvoice4D - (Fatturazione Elettronica per Delphi) }
{ }
{ Copyright (C) 2018  Delphi Force }
{ }
{ info@delphiforce.it }
{ https://github.com/delphiforce/eInvoice4D.git }
{ }
{ Delphi Force Team }
{ Antonio Polito }
{ Carlo Narcisi }
{ Fabio Codebue }
{ Marco Mottadelli }
{ Maurizio del Magno }
{ Omar Bossoni }
{ Thomas Ranzetti }
{ }
{ *************************************************************************** }
{ }
{ This file is part of eInvoice4D }
{ }
{ Licensed under the GNU Lesser General Public License, Version 3; }
{ you may not use this file except in compliance with the License. }
{ }
{ eInvoice4D is free software: you can redistribute it and/or modify }
{ it under the terms of the GNU Lesser General Public License as published }
{ by the Free Software Foundation, either version 3 of the License, or }
{ (at your option) any later version. }
{ }
{ eInvoice4D is distributed in the hope that it will be useful, }
{ but WITHOUT ANY WARRANTY; without even the implied warranty of }
{ MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the }
{ GNU Lesser General Public License for more details. }
{ }
{ You should have received a copy of the GNU Lesser General Public License }
{ along with eInvoice4D.  If not, see <http://www.gnu.org/licenses/>. }
{ }
{ *************************************************************************** }
unit ei4D;

interface

uses
  ei4D.Response.Interfaces, ei4D.Params.Interfaces, ei4D.Invoice.Interfaces,
  ei4D.Validators.Interfaces, ei4D.Provider.Interfaces,
  ei4D.Utils.P7mExtractor, System.Classes, System.SysUtils;

const
  EI4D_VERSION = '2.0 (preview)';

type

  // Type aliases to make sure you have to include fewer units (in practice only the "DForce.ei" unit) in the "uses" part of the units that use eInvoice4D
{$REGION 'Type aliases to make sure you have to include fewer units (in practice only the "DForce.ei" unit) in the "uses" part of the units that use eInvoice4D'}
  TeiResponseType = ei4D.Response.Interfaces.TeiResponseType;

  IeiParams = ei4D.Params.Interfaces.IeiParams;
  IeiProviderParams = ei4D.Params.Interfaces.IeiProviderParams;

  IeiResponse = ei4D.Response.Interfaces.IeiResponse;
  IeiResponseCollection = ei4D.Response.Interfaces.IeiResponseCollection;
  IeiInvoiceIDCollection = ei4D.Invoice.Interfaces.IeiInvoiceIDCollection;

  IeiValidatorsResultCollection = ei4D.Validators.Interfaces.IeiValidatorsResultCollection;
  IeiValidatorsResult = ei4D.Validators.Interfaces.IeiValidatorsResult;

  IeiProvider = ei4D.Provider.Interfaces.IeiProvider;

  // Invoice
  IFatturaElettronicaType = ei4D.Invoice.Interfaces.IFatturaElettronicaType;
  IFatturaElettronicaHeaderType = ei4D.Invoice.Interfaces.IFatturaElettronicaHeaderType;
  IFatturaElettronicaBodyType = ei4D.Invoice.Interfaces.IFatturaElettronicaBodyType;
  IContattiType = ei4D.Invoice.Interfaces.IContattiType;
  IIndirizzoType = ei4D.Invoice.Interfaces.IIndirizzoType;
  IIdFiscaleType = ei4D.Invoice.Interfaces.IIdFiscaleType;
  IAnagraficaType = ei4D.Invoice.Interfaces.IAnagraficaType;
  IRappresentanteFiscaleCessionarioType = ei4D.Invoice.Interfaces.IRappresentanteFiscaleCessionarioType;
  IDatiAnagraficiTerzoIntermediarioType = ei4D.Invoice.Interfaces.IDatiAnagraficiTerzoIntermediarioType;
  IDatiAnagraficiCessionarioType = ei4D.Invoice.Interfaces.IDatiAnagraficiCessionarioType;
  IDatiAnagraficiRappresentanteType = ei4D.Invoice.Interfaces.IDatiAnagraficiRappresentanteType;
  IDatiAnagraficiCedenteType = ei4D.Invoice.Interfaces.IDatiAnagraficiCedenteType;
  IIscrizioneREAType = ei4D.Invoice.Interfaces.IIscrizioneREAType;
  ITerzoIntermediarioSoggettoEmittenteType = ei4D.Invoice.Interfaces.ITerzoIntermediarioSoggettoEmittenteType;
  ICessionarioCommittenteType = ei4D.Invoice.Interfaces.ICessionarioCommittenteType;
  IRappresentanteFiscaleType = ei4D.Invoice.Interfaces.IRappresentanteFiscaleType;
  ICedentePrestatoreType = ei4D.Invoice.Interfaces.ICedentePrestatoreType;
  IContattiTrasmittenteType = ei4D.Invoice.Interfaces.IContattiTrasmittenteType;
  IIdTrasmittenteType = ei4D.Invoice.Interfaces.IIdTrasmittenteType;
  IDatiTrasmissioneType = ei4D.Invoice.Interfaces.IDatiTrasmissioneType;
  IDatiDDTType = ei4D.Invoice.Interfaces.IDatiDDTType;
  IDatiAnagraficiVettoreType = ei4D.Invoice.Interfaces.IDatiAnagraficiVettoreType;
  IDatiTrasportoType = ei4D.Invoice.Interfaces.IDatiTrasportoType;
  IDatiSALType = ei4D.Invoice.Interfaces.IDatiSALType;
  IDatiDocumentiCorrelatiType = ei4D.Invoice.Interfaces.IDatiDocumentiCorrelatiType;
  IScontoMaggiorazioneType = ei4D.Invoice.Interfaces.IScontoMaggiorazioneType;
  IDatiCassaPrevidenzialeType = ei4D.Invoice.Interfaces.IDatiCassaPrevidenzialeType;
  IDatiBolloType = ei4D.Invoice.Interfaces.IDatiBolloType;
  IDatiRitenutaType = ei4D.Invoice.Interfaces.IDatiRitenutaType;
  IDatiGeneraliDocumentoType = ei4D.Invoice.Interfaces.IDatiGeneraliDocumentoType;
  IFatturaPrincipaleType = ei4D.Invoice.Interfaces.IFatturaPrincipaleType;
  IDatiGeneraliType = ei4D.Invoice.Interfaces.IDatiGeneraliType;
  IAllegatiType = ei4D.Invoice.Interfaces.IAllegatiType;
  IAltriDatiGestionaliType = ei4D.Invoice.Interfaces.IAltriDatiGestionaliType;
  ICodiceArticoloType = ei4D.Invoice.Interfaces.ICodiceArticoloType;
  IDettaglioLineeType = ei4D.Invoice.Interfaces.IDettaglioLineeType;
  IDatiRiepilogoType = ei4D.Invoice.Interfaces.IDatiRiepilogoType;
  IDatiBeniServiziType = ei4D.Invoice.Interfaces.IDatiBeniServiziType;
  IDatiVeicoliType = ei4D.Invoice.Interfaces.IDatiVeicoliType;
  IDettaglioPagamentoType = ei4D.Invoice.Interfaces.IDettaglioPagamentoType;
  IDatiPagamentoType = ei4D.Invoice.Interfaces.IDatiPagamentoType;
  // Invoice collection
  IeiInvoiceCollection = ei4D.Invoice.Interfaces.IeiInvoiceCollection;
{$ENDREGION}

  ei = class
  public
    class function Version: String;
    class function Params: IeiParams;
    class function NewParams: IeiParams;

    class procedure SetCustomExtractP7mMethod(const AMethod: TeiExtractP7mMethod);
    class function ResponseTypeForHumans(const AResponseType: TeiResponseType): string;
    class function ResponseTypeToString(const AResponseType: TeiResponseType): string;
    class function StringToResponseType(const AResponseType: String): TeiResponseType;
    class procedure ProvidersAsStrings(const AStrings: TStrings); overload;
    class function ProvidersAsStrings: TStrings; overload;

    class procedure LogI(const ALogMessage: string);
    class procedure LogW(const ALogMessage: string);
    class procedure LogE(const ALogMessage: string); overload; // Error
    class procedure LogE(const E: Exception); overload; // Exception
    class procedure LogBlank;
    class procedure LogSeparator;

    class function NewInvoice(AParams: IeiParams = nil): IFatturaElettronicaType;
    class function NewInvoiceFromString(const AStringXML: String; AParams: IeiParams = nil): IFatturaElettronicaType;
    class function NewInvoiceFromStringBase64(const ABase64StringXML: String; AParams: IeiParams = nil): IFatturaElettronicaType;
    class function NewInvoiceFromFile(const AFileName: String; AParams: IeiParams = nil): IFatturaElettronicaType;
    class function NewInvoiceFromStream(const AStream: TStream; AParams: IeiParams = nil): IFatturaElettronicaType;
    class function NewInvoiceFromStreamBase64(const AStream: TStream; AParams: IeiParams = nil): IFatturaElettronicaType;

    class function InvoiceToString(const AInvoice: IFatturaElettronicaType): String;
    class function InvoiceToStringBase64(const AInvoice: IFatturaElettronicaType): String;
    class procedure InvoiceToFile(const AInvoice: IFatturaElettronicaType; const AFileName: String);
    class procedure InvoiceToStream(const AInvoice: IFatturaElettronicaType; const AStream: TStream);
    class procedure InvoiceToStreamBase64(const AInvoice: IFatturaElettronicaType; const AStream: TStream);

    class function NewProvider(AParams: IeiParams = nil): IeiProvider;

    class function NewInvoiceCollection: IeiInvoiceCollection;
    class function NewInvoiceIDCollection: IeiInvoiceIDCollection;

    class function NewResponse: IeiResponse;

    class function ValidateInvoice(const AInvoice: IFatturaElettronicaType): IeiValidatorsResultCollection; overload;
    class function ValidateInvoice(const AInvoice: IFatturaElettronicaType; const AKind: TeiValidatorKind): IeiValidatorsResultCollection; overload;
  end;

implementation

uses
  ei4D.Utils, ei4D.Logger, ei4D.Serializer.Factory, ei4D.Utils.Sanitizer,
  System.NetEncoding, ei4D.Params.Singleton, ei4D.Invoice.Factory,
  ei4D.Params.Factory, ei4D.Provider.Register, ei4D.Response.Factory,
  ei4D.Validators.Factory, ei4D.Provider.Notary, ei4D.Validators.Notary,
  ei4D.Validators.Register;

{ ei }
class procedure ei.LogE(const ALogMessage: string);
begin
  TeiLogger.LogE(ALogMessage);
end;

class procedure ei.InvoiceToFile(const AInvoice: IFatturaElettronicaType; const AFileName: String);
var
  LFileStream: TFileStream;
begin
  LFileStream := TFileStream.Create(AFileName, fmCreate);
  try
    TeiUtils.StringToStream(InvoiceToString(AInvoice), LFileStream);
  finally
    LFileStream.Free;
  end;
end;

class procedure ei.InvoiceToStream(const AInvoice: IFatturaElettronicaType; const AStream: TStream);
begin
  TeiUtils.StringToStream(InvoiceToString(AInvoice), AStream);
end;

class procedure ei.InvoiceToStreamBase64(const AInvoice: IFatturaElettronicaType; const AStream: TStream);
begin
  TeiUtils.StringToStream(InvoiceToStringBase64(AInvoice), AStream);
end;

class function ei.InvoiceToString(const AInvoice: IFatturaElettronicaType): String;
begin
  Result := TeiSerializerFactory.NewSerializer.ToXML(AInvoice);
  Result.Insert(0, '<?xml version="1.0" encoding="UTF-8"?>' + sLineBreak);
  Result := Result.Replace('<FatturaElettronica>',
    Format('<p:FatturaElettronica versione="%s" xmlns:p="http://ivaservizi.agenziaentrate.gov.it/docs/xsd/fatture/v1.2">',
    [AInvoice.FatturaElettronicaHeader.DatiTrasmissione.FormatoTrasmissione.Value]));
  Result := Result.Replace('</FatturaElettronica>', '</p:FatturaElettronica>');
  TeiSanitizer.SanitizeToSendXML(Result);
end;

class function ei.InvoiceToStringBase64(const AInvoice: IFatturaElettronicaType): String;
begin
  Result := TNetEncoding.Base64.Encode(InvoiceToString(AInvoice));
end;

class procedure ei.LogBlank;
begin
  TeiLogger.LogBlank;
end;

class procedure ei.LogE(const E: Exception);
begin
  TeiLogger.LogE(E);
end;

class procedure ei.LogI(const ALogMessage: string);
begin
  TeiLogger.LogI(ALogMessage);
end;

class procedure ei.LogSeparator;
begin
  TeiLogger.LogSeparator;
end;

class procedure ei.LogW(const ALogMessage: string);
begin
  TeiLogger.LogW(ALogMessage);
end;

class function ei.NewInvoice(AParams: IeiParams = nil): IFatturaElettronicaType;
begin
  TeiParamsSingleton.CheckParams(AParams);
  Result := TeiInvoiceFactory.NewInvoice(AParams);
end;

class function ei.NewInvoiceCollection: IeiInvoiceCollection;
begin
  Result := TeiInvoiceFactory.NewInvoiceCollection;
end;

class function ei.NewInvoiceFromFile(const AFileName: String; AParams: IeiParams = nil): IFatturaElettronicaType;
begin
  TeiParamsSingleton.CheckParams(AParams);
  Result := TeiInvoiceFactory.NewInvoiceFromFile(AFileName, AParams);
end;

class function ei.NewInvoiceFromStream(const AStream: TStream; AParams: IeiParams = nil): IFatturaElettronicaType;
begin
  TeiParamsSingleton.CheckParams(AParams);
  Result := TeiInvoiceFactory.NewInvoiceFromStream(AStream, AParams);
end;

class function ei.NewInvoiceFromStreamBase64(const AStream: TStream; AParams: IeiParams = nil): IFatturaElettronicaType;
begin
  TeiParamsSingleton.CheckParams(AParams);
  Result := TeiInvoiceFactory.NewInvoiceFromStreamBase64(AStream, AParams);
end;

class function ei.NewInvoiceFromString(const AStringXML: String; AParams: IeiParams = nil): IFatturaElettronicaType;
begin
  TeiParamsSingleton.CheckParams(AParams);
  Result := TeiInvoiceFactory.NewInvoiceFromString(AStringXML, AParams);
end;

class function ei.NewInvoiceFromStringBase64(const ABase64StringXML: String; AParams: IeiParams = nil): IFatturaElettronicaType;
begin
  TeiParamsSingleton.CheckParams(AParams);
  Result := TeiInvoiceFactory.NewInvoiceFromStringBase64(ABase64StringXML, AParams);
end;

class function ei.NewInvoiceIDCollection: IeiInvoiceIDCollection;
begin
  Result := TeiInvoiceFactory.NewInvoiceIDCollection;
end;

class function ei.Params: IeiParams;
begin
  Result := TeiParamsSingleton.GetInstance;
end;

class function ei.NewParams: IeiParams;
begin
  Result := TeiParamsFactory.NewParams;
end;

class function ei.NewProvider(AParams: IeiParams): IeiProvider;
begin
  TeiParamsSingleton.CheckParams(AParams);
  Result := TeiProviderRegister.NewProviderInstance(AParams);
end;

class function ei.NewResponse: IeiResponse;
begin
  Result := TeiResponseFactory.NewResponse;
end;

class function ei.ProvidersAsStrings: TStrings;
begin
  Result := TeiProviderRegister.ProvidersAsStrings;
end;

class function ei.ResponseTypeForHumans(const AResponseType: TeiResponseType): string;
begin
  Result := TeiUtils.ResponseTypeForHumans(AResponseType);
end;

class function ei.ResponseTypeToString(const AResponseType: TeiResponseType): string;
begin
  Result := TeiUtils.ResponseTypeToString(AResponseType);
end;

class procedure ei.ProvidersAsStrings(const AStrings: TStrings);
begin
  TeiProviderRegister.ProvidersAsStrings(AStrings);
end;

class function ei.StringToResponseType(const AResponseType: String): TeiResponseType;
begin
  Result := TeiUtils.StringToResponseType(AResponseType);
end;

class function ei.ValidateInvoice(const AInvoice: IFatturaElettronicaType; const AKind: TeiValidatorKind): IeiValidatorsResultCollection;
begin
  Result := TeiValidatorRegister.Validate(AInvoice, AKind);
end;

class function ei.Version: String;
begin
  Result := EI4D_VERSION;
end;

class function ei.ValidateInvoice(const AInvoice: IFatturaElettronicaType): IeiValidatorsResultCollection;
begin
  Result := TeiValidatorRegister.ValidateAll(AInvoice);
end;

class procedure ei.SetCustomExtractP7mMethod(const AMethod: TeiExtractP7mMethod);
begin
  TExtractP7m.SetCustomExtractP7mMethod(AMethod);
end;

initialization

TeiProviderNotary.BuildProviderRegister;
TeiVaildatorsNotary.BuildValidatorsRegister;

end.
