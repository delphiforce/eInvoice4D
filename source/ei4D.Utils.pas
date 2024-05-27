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
unit ei4D.Utils;

interface

uses
  System.SysUtils, System.Classes, ei4D.Response.Interfaces;

type
  TeiRoundMode = (rmRaise, rmRound, rmTrunc);

  TeiConfig = class
  class var
    FRoundMode: TeiRoundMode;
  end;

  TeiUtils = class
  public
    class function GetFormatSettings: TFormatSettings;
    class function DateToString(const AValue: TDateTime): string;
    class function DateTimeToString(const AValue: TDateTime): string;
    class function DateTimeToUrlParam(const AValue: TDateTime): string;
    class function StringToDate(const AValue: String): TDateTime;
    class function StringToDateTime(const AValue: String; const AReturnUTC: Boolean = True): TDateTime;
    class function FloatToString(const AValue: Double; const ADecimals: Byte): String;
    class function StringToFloat(const AValue: String): Double;
    class function NumberToString(const AValue: extended; const ADecimals: integer): string; // Deprecated???
    class function ResponseTypeToEnum(const AResponseType: string; const ANotificationXML: String = ''): TeiResponseType;
    class function ResponseTypeForHumans(const AResponseType: TeiResponseType): string;
    class function ResponseTypeToString(const AResponseType: TeiResponseType): string;
    class function StringToResponseType(const AResponseType: String): TeiResponseType;
    // class procedure FillInvoiceSample(const AInvoice: IeiInvoiceEx);
    // class procedure CopyObjectState(const ASource, ADestination: TObject); overload;
    // class procedure CopyObjectState(const ASource, ADestination: IInterface); overload;
    class procedure StringToStream(const ASourceString: String; const ADestStream: TStream);
    class function StreamToString(const ASourceStream: TStream): string;
    // class function ExtractInvoiceIDFromNotification(const ANotificationXML: string): string; deprecated; // Deprecated??? // To test???
    class function XMLFindTag(const AXMLText: String; var APos: Integer): string;
  end;

implementation

uses
  ei4D.Exception, System.DateUtils, System.Math,
  System.TypInfo, ei4D.Encoding.Factory, ei4D.Encoding;

{ TeiUtils }

class procedure TeiUtils.StringToStream(const ASourceString: String; const ADestStream: TStream);
var
  LStringStream: TStringStream;
  LEncoding: TEncoding;
begin
  // Check the stream
  if not Assigned(ADestStream) then
    raise eiGenericException.Create('"AStream" parameter not assigned');
  // Save invoice into the stream
  LEncoding := TeiUTFEncodingWithoutBOM.Create;
  LStringStream := TStringStream.Create(ASourceString, LEncoding);
  try
    ADestStream.CopyFrom(LStringStream, 0);
  finally
    LStringStream.Free;
  end;
end;

class function TeiUtils.XMLFindTag(const AXMLText: String; var APos: Integer): string;
var
  LStartPos: Integer;
begin
  LStartPos := AXMLText.IndexOf('<', APos);
  APos := AXMLText.IndexOf('>', LStartPos);
  if (LStartPos = -1) or (APos = -1) then
    raise eiGenericException.Create('Tag not found');
  Result := AXMLText.Substring(LStartPos + 1, APos - LStartPos - 1);
  Inc(APos);
end;

class function TeiUtils.DateToString(const AValue: TDateTime): string;
begin
  result := FormatDateTime('yyyy-mm-dd', AValue, GetFormatSettings);
end;

class function TeiUtils.StringToDate(const AValue: String): TDateTime;
begin
  result := StrToDateTime(AValue, GetFormatSettings);
end;

class function TeiUtils.StringToDateTime(const AValue: String; const AReturnUTC: Boolean = True): TDateTime;
begin
  // NB: Con AReturnUTC = True ritorna  la data e ora ricevuta come Value così come è senza aggiungere il
  // timezone offset, se invece AReturnUTC = False allora considera Value come ora UTC standard
  // e la converte in locale aggiungendo il TimeZoneOffset
  result := ISO8601ToDate(AValue, AReturnUTC);
end;

class function TeiUtils.StringToFloat(const AValue: String): Double;
begin
  result := StrToFloat(AValue, GetFormatSettings);
end;

class function TeiUtils.StringToResponseType(const AResponseType: String): TeiResponseType;
begin
  result := TeiResponseType(GetEnumValue(TypeInfo(TeiResponseType), AResponseType));
end;

class function TeiUtils.StreamToString(const ASourceStream: TStream): string;
var
  LStringStream: TStringStream;
  LEncoding: TEncoding;
begin
  LEncoding := TeiEncodingFactory.GetEncoding(ASourceStream);
  LStringStream := TStringStream.Create('', LEncoding);
  try
    LStringStream.CopyFrom(ASourceStream, 0);
    result := LStringStream.DataString;
  finally
    LStringStream.Free;
  end;
end;

class function TeiUtils.FloatToString(const AValue: Double; const ADecimals: Byte): String;
var
  FPrevRoundingMode: TRoundingMode;
begin
  FPrevRoundingMode := GetROundMode;
  SetRoundMode(rmUp);
  try
    result := FloatToStrF(AValue, ffFixed, 15, ADecimals, GetFormatSettings)
  finally
    SetRoundMode(FPrevRoundingMode);
  end;
end;

class function TeiUtils.NumberToString(const AValue: extended; const ADecimals: integer): string;
var
  _fs: TFormatSettings;
  LLocalValue: extended;
  LParteIntera, LParteDecimale: string;
begin
  // ho utilizzato la versione con il FormatSettings perchè quella senza non è ThreadSafe
  if not InRange(ADecimals, 2, 8) then
    raise eiDecimalsException.Create('TeiUtils.NumberToString: il numero di decimali deve essere compreso tra 2 e 8.');

  LLocalValue := AValue;
  case TeiConfig.FRoundMode of
    rmRaise:
      begin
        LParteDecimale := FloatToStr(Frac(LLocalValue));
        if (Length(FloatToStr(Frac(LLocalValue))) - 2) > ADecimals then
          raise eiDecimalsException.Create
            ('TeiUtils.NumberToString: il numero di decimali specificati è diverso al numero di decimali del valore da convertire.');
        _fs := TFormatSettings.Create;
        _fs.DecimalSeparator := '.';
        result := FormatFloat('#0.' + StringOfChar('0', ADecimals), LLocalValue, _fs);
      end;
    rmRound:
      begin
        SetRoundMode(rmUp);
        LLocalValue := SimpleRoundTo(LLocalValue, -ADecimals);
        SetRoundMode(rmNearest);
        _fs := TFormatSettings.Create;
        _fs.DecimalSeparator := '.';
        result := FormatFloat('#0.' + StringOfChar('0', ADecimals), LLocalValue, _fs);
      end;
    rmTrunc:
      begin
        LParteIntera := Trunc(LLocalValue).ToString;
        LParteDecimale := Frac(LLocalValue).ToString;
        result := LParteIntera + '.' + LParteDecimale.Substring(2, ADecimals);
      end
  else
    raise eiDecimalsException.Create('TeiUtils.NumberToString: Metodo di arrotondamento in conversione non valido.');
  end;
end;

class function TeiUtils.ResponseTypeForHumans(const AResponseType: TeiResponseType): string;
begin
  case AResponseType of
    rtSDIMessageRC:
      result := 'Ricevuta di consegna';
    rtSDIMessageNS:
      result := 'Notifica di scarto';
    rtSDIMessageMC:
      result := 'Notifica di mancata consegna';
    rtSDIMessageNEAccepted:
      result := 'Notifica esito fattura accettata';
    rtSDIMessageNERejected:
      result := 'Notifica esito fattura rifiutata';
    rtSDIMessageMT:
      result := 'Notifica di metadati del file fattura';
    rtSDIMessageEC:
      result := 'Notifica di esito cessionario/committente';
    rtSDIMessageSE:
      result := 'Notifica di scarto esito cessionario/committente';
    rtSDIMessageDT:
      result := 'Notifica decorrenza termini';
    rtSDIMessageAT:
      result := 'Attestazione di avvenuta trasmissione della fattura con impossibilità di recapito';
  else
    result := 'Tipo sconosciuto';
  end;
end;

class function TeiUtils.ResponseTypeToEnum(const AResponseType, ANotificationXML: String): TeiResponseType;
begin
  if AResponseType = 'RC' then
    result := rtSDIMessageRC
  else if AResponseType = 'NS' then
    result := rtSDIMessageNS
  else if AResponseType = 'MC' then
    result := rtSDIMessageMC
  else if AResponseType = 'MT' then
    result := rtSDIMessageMT
  else if AResponseType = 'EC' then
    result := rtSDIMessageEC
  else if AResponseType = 'SE' then
    result := rtSDIMessageSE
  else if AResponseType = 'DT' then
    result := rtSDIMessageDT
  else if AResponseType = 'AT' then
    result := rtSDIMessageAT
  else if AResponseType = 'NE' then
  begin
    if ANotificationXML.Contains('<Esito>EC01</Esito>') then
      result := rtSDIMessageNEAccepted
    else
      result := rtSDIMessageNERejected
  end
  else
    result := rtUnknown;
end;

class function TeiUtils.ResponseTypeToString(const AResponseType: TeiResponseType): string;
begin
  result := GetEnumName(TypeInfo(TeiResponseType), Ord(AResponseType));
end;

class function TeiUtils.GetFormatSettings: TFormatSettings;
var
  FFormatSettings: TFormatSettings;
begin
  FFormatSettings.Create;
  // Float
  FFormatSettings.DecimalSeparator := '.';
  FFormatSettings.ThousandSeparator := ',';
  // Date
  FFormatSettings.DateSeparator := '-';
  FFormatSettings.ShortDateFormat := 'yyyy-mm-dd';
  // Time
  FFormatSettings.TimeSeparator := ':';
  FFormatSettings.ShortTimeFormat := 'hh:nn:ss';
  // Return the result
  result := FFormatSettings;
end;

class function TeiUtils.DateTimeToString(const AValue: TDateTime): string;
begin
  result := FormatDateTime('yyyy-mm-dd"T"hh:nn:ss', AValue, GetFormatSettings);
end;

class function TeiUtils.DateTimeToUrlParam(const AValue: TDateTime): string;
begin
  result := FormatDateTime('yyyy-mm-dd"T"hh%3Ann%3Ass', AValue);
end;

initialization

TeiConfig.FRoundMode := rmRaise;

end.
