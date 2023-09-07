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
unit ei4D.Provider.Aruba;

interface

uses ei4D.Provider.Base,
  ei4D.Provider.Interfaces,
  ei4D.Response.Interfaces,
  System.JSON,
  System.Generics.Collections,
  ei4D.Invoice.Interfaces;

type

  TeiProviderAruba = class(TeiProviderBase)
  const
    ARUBA_PAGE_SIZE = '50';
  private
    FAccessToken: string;
    procedure Authenticate;
    function JValueToDateTimeDefault(const AValue, ADefaultValue: TJSONValue): TDateTime;
    function JValueToString(const AJSONValue: TJSONValue): String;
    // function JValueToInteger(const AJSONValue: TJSONValue): Integer; // Code exists below
    function JValueToBoolean(const AJSONValue: TJSONValue): boolean;
    // function PurgeP7mSignature(const AString: string): string; // Code exists below
    function InternalReceivePurchaseInvoiceFileNameCollection(const AVatCodeReceiver: string; const AStartDate, AEndDate: TDateTime; const APage: Integer;
      AResult: IeiInvoiceIDCollection): boolean;
  public
    procedure DoConnect; override;
    procedure DoDisconnect; override;
    procedure DoSendInvoice(const AInvoice: string; const AResponseCollection: IeiResponseCollection); override;
    procedure DoReceiveInvoiceNotifications(const AInvoiceID: string; const AResponseCollection: IeiResponseCollection); override;
    procedure DoReceivePurchaseInvoiceIDCollection(const AVatCodeReceiver: string; const AStartDate: TDateTime; AEndDate: TDateTime; const AInvoiceIDCollection: IeiInvoiceIDCollection); override;
    procedure DoReceivePurchaseInvoice(const AInvoiceID: string; const AResponseCollection: IeiResponseCollection); override;
    procedure DoReceivePurchaseInvoiceNotifications(const AInvoiceID: string; const AResponseCollection: IeiResponseCollection); override;
  end;

implementation

uses System.UITypes,
  REST.Types,
  REST.Client,
  System.NetEncoding,
  System.SysUtils,
  ei4D.Exception,
  ei4D.Utils,
  ei4D.Response.Factory,
  System.Math,
  DateUtils,
  ei4D.Utils.P7mExtractor,
  ei4D.Utils.Sanitizer,
  System.Classes,
  System.IOUtils,
  System.Net.HttpClient, ei4D.Invoice.Factory, ei4D;

procedure TeiProviderAruba.Authenticate;
var
  LRESTClient: TRESTClient;
  LRESTRequest: TRESTRequest;
  LRESTResponse: TRESTResponse;
  LFullTokenJson: TJSONObject;
begin
  LFullTokenJson := nil;
  LRESTClient := TRESTClient.Create(nil);
  LRESTRequest := TRESTRequest.Create(nil);
  LRESTResponse := TRESTResponse.Create(nil);
  try

    LRESTClient.BaseURL := Params.Provider.BaseUrlAuth;
    LRESTClient.AllowCookies := True;
    LRESTClient.ContentType := 'application/x-www-form-urlencoded';

    // LRESTClient.SecureProtocols := [THTTPSecureProtocol.TLS12, THTTPSecureProtocol.TLS13];

    LRESTRequest.Resource := '/auth/signin';
    LRESTRequest.Method := rmPOST;
    LRESTRequest.Client := LRESTClient;
    LRESTRequest.Response := LRESTResponse;

    LRESTRequest.AddParameter('grant_type', 'password');
    LRESTRequest.AddParameter('username', Params.Provider.UserName);
    LRESTRequest.AddParameter('password', Params.Provider.Password);

    LRESTRequest.Execute;
    if LRESTResponse.StatusCode <> 200 then
      raise eiRESTAuthException.Create('Error during auth request');

    LFullTokenJson := TJSONObject.ParseJSONValue(LRESTResponse.JSONText) as TJSONObject;
    if not LFullTokenJson.TryGetValue<string>('access_token', FAccessToken) then
      raise eiRESTAuthException.Create('Error during auth request: access_token property not found');

  finally
    if Assigned(LFullTokenJson) then
      LFullTokenJson.Free;
    LRESTClient.Free;
    LRESTRequest.Free;
    LRESTResponse.Free;
  end;
end;

procedure TeiProviderAruba.DoConnect;
begin
  inherited;
  Authenticate;
end;

procedure TeiProviderAruba.DoDisconnect;
begin
  inherited;
  // Nothing
end;

function TeiProviderAruba.InternalReceivePurchaseInvoiceFileNameCollection(const AVatCodeReceiver: string; const AStartDate, AEndDate: TDateTime;
  const APage: Integer; AResult: IeiInvoiceIDCollection): boolean;
var
  LRESTClient: TRESTClient;
  LRESTRequest: TRESTRequest;
  LRESTResponse: TRESTResponse;
  JObjResponse: TJSONObject;
  LJsonNotifications: TJSONArray;
  LJsonNotification: TJSONObject;
  I: Integer;
  LJValue: TJSONValue;
  LResponseText: String;
begin
  Result := True;
  JObjResponse := nil;

  LRESTClient := TRESTClient.Create(nil);
  LRESTRequest := TRESTRequest.Create(nil);
  LRESTResponse := TRESTResponse.Create(nil);
  try
    LRESTClient.BaseURL := Params.Provider.BaseURLWS;
    LRESTClient.AllowCookies := True;
    LRESTClient.ContentType := 'application/json';

    LRESTRequest.Resource := '/services/invoice/in/findByUsername';
    LRESTRequest.Client := LRESTClient;
    LRESTRequest.Response := LRESTResponse;
    LRESTRequest.Method := rmGET;

    LRESTRequest.AddParameter('Authorization', Format('Bearer %s', [FAccessToken]), TRESTRequestParameterKind.pkHTTPHEADER, [poDoNotEncode]);

    // selection parameters
    LRESTRequest.AddParameter('username', Params.Provider.UserName);
    LRESTRequest.AddParameter('page', APage.ToString);
    LRESTRequest.AddParameter('size', ARUBA_PAGE_SIZE);
    LRESTRequest.AddParameter('startDate', TeiUtils.DateTimeToUrlParam(AStartDate), TRESTRequestParameterKind.pkGETorPOST, [poDoNotEncode]);
    LRESTRequest.AddParameter('endDate', TeiUtils.DateTimeToUrlParam(AEndDate), TRESTRequestParameterKind.pkGETorPOST, [poDoNotEncode]);
    if not AVatCodeReceiver.Trim.IsEmpty then
    begin
      LRESTRequest.AddParameter('countryReceiver', 'IT');
      LRESTRequest.AddParameter('vatcodeReceiver', AVatCodeReceiver);
    end;

    // call
    LRESTRequest.Execute;
    if LRESTResponse.StatusCode <> 200 then
      raise eiGenericException.Create(Format('ReceivePurchaseInvoices error: %d - %s', [LRESTResponse.StatusCode, LRESTResponse.StatusText]));

    LResponseText := LRESTResponse.JSONText;
    TeiSanitizer.SanitizeJSONInvoiceNumberEscapeChar(LResponseText);

    // response
    JObjResponse := TJSONObject.ParseJSONValue(LResponseText) as TJSONObject;
    if Assigned(JObjResponse) then
    begin
      LJValue := JObjResponse.Values['content'];
      if (LJValue is TJSONArray) then
      begin
        LJsonNotifications := LJValue as TJSONArray;
        for I := 0 to LJsonNotifications.Count - 1 do
        begin
          LJsonNotification := LJsonNotifications.Items[I] as TJSONObject;
          AResult.Add(JValueToString(LJsonNotification.Values['filename']));
        end;
        Result := JValueToBoolean(JObjResponse.GetValue('last'));
      end;
    end;

  finally
    if Assigned(JObjResponse) then
      JObjResponse.Free;
    LRESTClient.Free;
    LRESTRequest.Free;
    LRESTResponse.Free;
  end;
end;

function TeiProviderAruba.JValueToDateTimeDefault(const AValue, ADefaultValue: TJSONValue): TDateTime;
begin
  // Value
  if Assigned(AValue) and (not AValue.Null) and not AValue.Value.Trim.IsEmpty then
    Result := TeiUtils.StringToDateTime(AValue.Value, False)
  else
    // Default value
    if Assigned(ADefaultValue) and (not ADefaultValue.Null) and not ADefaultValue.Value.Trim.IsEmpty then
      Result := TeiUtils.StringToDateTime(ADefaultValue.Value, False)
    else
      Result := 0;
end;

// function TeiProviderAruba.JValueToInteger(const AJSONValue: TJSONValue): Integer;
// begin
// if Assigned(AJSONValue) and (not AJSONValue.Null) and (not AJSONValue.Value.Trim.IsEmpty) and (AJSONValue is TJSONNumber) then
// Result := (AJSONValue as TJSONNumber).AsInt
// else
// Result := 0;
// end;

function TeiProviderAruba.JValueToBoolean(const AJSONValue: TJSONValue): boolean;
begin
  if Assigned(AJSONValue) and (not AJSONValue.Null) and (not AJSONValue.Value.Trim.IsEmpty) and (AJSONValue is TJSONBool) then
    Result := (AJSONValue as TJSONBool).AsBoolean
  else
    Result := False;
end;

function TeiProviderAruba.JValueToString(const AJSONValue: TJSONValue): String;
begin
  if Assigned(AJSONValue) and (not AJSONValue.Null) and (not AJSONValue.Value.Trim.IsEmpty) then
    Result := AJSONValue.Value;
end;

procedure TeiProviderAruba.DoSendInvoice(const AInvoice: string; const AResponseCollection: IeiResponseCollection);
var
  LRESTClient: TRESTClient;
  LRESTRequest: TRESTRequest;
  LRESTResponse: TRESTResponse;
  LJSONBody: string;
  JObjResponse: TJSONObject;
  LBase64Invoice: string;
  LResponse: IeiResponse;
begin
{$IFNDEF VER280}
  inherited;
  JObjResponse := nil;

  LBase64Invoice := TNetEncoding.Base64.Encode(AInvoice);

  LJSONBody := '{"dataFile" : "' + LBase64Invoice + '","credential" : "","domain" : ""}';
  // Correzione per ambiente TEST Aruba: non accetta fatture con lunghezza > 75 caratteri
  if SameText(Params.Provider.BaseURLWS, 'https://testws.fatturazioneelettronica.aruba.it') then
  begin
    LBase64Invoice := LBase64Invoice.Substring(0, 75);
    LJSONBody := '{"dataFile" : "' + LBase64Invoice + '","credential" : "cred_firma","domain" : "dom_firma"}';
  end;

  LRESTClient := TRESTClient.Create(nil);
  LRESTRequest := TRESTRequest.Create(nil);
  LRESTResponse := TRESTResponse.Create(nil);
  try
    LRESTClient.BaseURL := Params.Provider.BaseURLWS;
    LRESTClient.AllowCookies := True;
    LRESTClient.ContentType := 'application/json;charset=UTF-8';

    LRESTRequest.Resource := '/services/invoice/upload';
    LRESTRequest.Client := LRESTClient;
    LRESTRequest.Response := LRESTResponse;
    LRESTRequest.Method := rmPOST;
    LRESTRequest.AddParameter('Authorization', Format('Bearer %s', [FAccessToken]), TRESTRequestParameterKind.pkHTTPHEADER, [poDoNotEncode]);

    TeiSanitizer.SanitizeJSON(LJSONBody);
    LRESTRequest.Body.Add(LJSONBody, TRESTContentType.ctAPPLICATION_JSON);

    LRESTRequest.Execute;
    if LRESTResponse.StatusCode <> 200 then
      raise eiGenericException.Create(Format('Sending invoice error: %d - %s --> %s', [LRESTResponse.StatusCode, LRESTResponse.StatusText,
        LRESTResponse.Content]));
    // Modifica proposta da Ivan Revelli per  visualizzare anche il Content della risposta Aruba che contiene una descrizione dell'errore.
    // OLD CODE:  raise eiGenericException.Create(Format('Sending invoice error: %d - %s', [LRESTResponse.StatusCode, LRESTResponse.StatusText]));
    JObjResponse := TJSONObject.ParseJSONValue(LRESTResponse.JSONText) as TJSONObject;
    LResponse := TeiResponseFactory.NewResponse;
    LResponse.MsgCode := JValueToString(JObjResponse.Values['errorCode']);
    LResponse.MsgText := JValueToString(JObjResponse.Values['errorDescription']);
    LResponse.FileName := JValueToString(JObjResponse.Values['uploadFileName']);
    LResponse.ResponseDate := Now;
    LResponse.NotificationDate := LResponse.ResponseDate;

    if LResponse.MsgCode.Trim.IsEmpty or (LResponse.MsgCode.Trim = '0000') then
      LResponse.ResponseType := rtAcceptedByProvider
    else
      LResponse.ResponseType := rtRejectedByProvider;
    AResponseCollection.Add(LResponse);

  finally
    if Assigned(JObjResponse) then
      JObjResponse.Free;
    LRESTClient.Free;
    LRESTRequest.Free;
    LRESTResponse.Free;
  end;
{$ENDIF VER280}
end;

procedure TeiProviderAruba.DoReceiveInvoiceNotifications(const AInvoiceID: string; const AResponseCollection: IeiResponseCollection);
var
  LRESTClient: TRESTClient;
  LRESTRequest: TRESTRequest;
  LRESTResponse: TRESTResponse;
  LResponse: IeiResponse;
  JObjResponse: TJSONObject;
  LJsonNotifications: TJSONArray;
  LJsonNotification: TJSONObject;
  LJValue: TJSONValue;
  I: Integer;
begin
  inherited;
  JObjResponse := nil;

  LRESTClient := TRESTClient.Create(nil);
  LRESTRequest := TRESTRequest.Create(nil);
  LRESTResponse := TRESTResponse.Create(nil);
  try
    LRESTClient.BaseURL := Params.Provider.BaseURLWS;
    LRESTClient.AllowCookies := True;
    LRESTClient.ContentType := 'application/json;charset=UTF-8';

    LRESTRequest.Resource := '/services/notification/out/getByInvoiceFilename';
    LRESTRequest.Client := LRESTClient;
    LRESTRequest.Response := LRESTResponse;
    LRESTRequest.Method := rmGET;

    LRESTRequest.AddParameter('invoiceFilename', AInvoiceID);
    LRESTRequest.AddParameter('Authorization', Format('Bearer %s', [FAccessToken]), TRESTRequestParameterKind.pkHTTPHEADER, [poDoNotEncode]);

    LRESTRequest.Execute;
    if LRESTResponse.StatusCode <> 200 then
      raise eiGenericException.Create(Format('out/getByInvoiceFilename error: %d - %s', [LRESTResponse.StatusCode, LRESTResponse.StatusText]));

    JObjResponse := TJSONObject.ParseJSONValue(LRESTResponse.JSONText) as TJSONObject;
    if Assigned(JObjResponse) then
    begin
      LJValue := JObjResponse.GetValue('notifications');
      if not(LJValue is TJSONNull) then
      begin
        LJsonNotifications := JObjResponse.GetValue<TJSONArray>('notifications');

        for I := 0 to LJsonNotifications.Count - 1 do
        begin
          LJsonNotification := LJsonNotifications.Items[I] as TJSONObject;
          LResponse := TeiResponseFactory.NewResponse;
          LResponse.MsgCode := '';
          LResponse.MsgText := '';
          LResponse.MsgRaw := JValueToString(LJsonNotification.Values['file']);
          if not LResponse.MsgRaw.IsEmpty then
            LResponse.MsgRaw := TNetEncoding.Base64.Decode(LResponse.MsgRaw);
          LResponse.ResponseType := TeiUtils.ResponseTypeToEnum(LJsonNotification.GetValue<TJSONString>('docType').Value, LResponse.MsgRaw);
          LResponse.FileName := JValueToString(LJsonNotification.Values['filename']);
          LResponse.ResponseDate := JValueToDateTimeDefault(LJsonNotification.Values['date'], LJsonNotification.Values['notificationDate']);
          LResponse.NotificationDate := JValueToDateTimeDefault(LJsonNotification.Values['notificationDate'], LJsonNotification.Values['date']);
          AResponseCollection.Add(LResponse);
        end;
      end;
    end;

  finally
    if Assigned(JObjResponse) then
      JObjResponse.Free;
    LRESTClient.Free;
    LRESTRequest.Free;
    LRESTResponse.Free;
  end;
end;

procedure TeiProviderAruba.DoReceivePurchaseInvoiceIDCollection(const AVatCodeReceiver: string; const AStartDate: TDateTime; AEndDate: TDateTime; const AInvoiceIDCollection: IeiInvoiceIDCollection);
var
  LastPage: boolean;
  LCurrentPage: Integer;
begin
  if IsZero(AEndDate) then
    AEndDate := EndOfTheDay(Date);
  LCurrentPage := 1;
  repeat
    LastPage := InternalReceivePurchaseInvoiceFileNameCollection(AVatCodeReceiver, AStartDate, AEndDate, LCurrentPage, AInvoiceIDCollection);
    if not LastPage then
      Sleep(Params.InterOperationDelay);
    Inc(LCurrentPage);
  until LastPage;
end;

procedure TeiProviderAruba.DoReceivePurchaseInvoice(const AInvoiceID: string; const AResponseCollection: IeiResponseCollection);
var
  LRESTClient: TRESTClient;
  LRESTRequest: TRESTRequest;
  LRESTResponse: TRESTResponse;
  LResponse: IeiResponse;
  JObjResponse: TJSONObject;
  LXml: string;
  LResponseText: String;
begin
  inherited;
  JObjResponse := nil;

  LRESTClient := TRESTClient.Create(nil);
  LRESTRequest := TRESTRequest.Create(nil);
  LRESTResponse := TRESTResponse.Create(nil);
  try
    LRESTClient.BaseURL := Params.Provider.BaseURLWS;
    LRESTClient.AllowCookies := True;
    LRESTClient.ContentType := 'application/json';

    LRESTRequest.Resource := '/services/invoice/in/getByFilename';
    LRESTRequest.Client := LRESTClient;
    LRESTRequest.Response := LRESTResponse;
    LRESTRequest.Method := rmGET;

    LRESTClient.ContentType := 'application/json;charset=UTF-8';
    LRESTRequest.AddParameter('filename', AInvoiceID);
    LRESTRequest.AddParameter('Authorization', Format('Bearer %s', [FAccessToken]), TRESTRequestParameterKind.pkHTTPHEADER, [poDoNotEncode]);

    LRESTRequest.Execute;
    if LRESTResponse.StatusCode <> 200 then
      raise eiGenericException.Create(Format('getByFilename error: %d - %s', [LRESTResponse.StatusCode, LRESTResponse.StatusText]));

    try
      LResponseText := LRESTResponse.JSONText;
      TeiSanitizer.SanitizeJSONInvoiceNumberEscapeChar(LResponseText);

      JObjResponse := TJSONObject.ParseJSONValue(LResponseText) as TJSONObject;
      if Assigned(JObjResponse) then
      begin
        LResponse := TeiResponseFactory.NewResponse;
        LResponse.ResponseType := rtReceivedFromProvider;
        LResponse.FileName := JValueToString(JObjResponse.Values['filename']);
        LResponse.ResponseDate := Date;
        LResponse.NotificationDate := JValueToDateTimeDefault(JObjResponse.Values['lastUpdate'], nil);
        LXml := JValueToString(JObjResponse.Values['file']);
        if pos('.p7m', LowerCase(LResponse.FileName)) > 0 then
        begin
          // estrazione xml da file p7m
          LResponse.MsgRaw := TExtractP7m.Extract(LXml)
        end
        else
        begin
          // estrazione xml senza p7m
          LResponse.MsgRaw := LXml;
          if not LResponse.MsgRaw.IsEmpty then
            LResponse.MsgRaw := TNetEncoding.Base64.Decode(LResponse.MsgRaw);
        end;
        AResponseCollection.Add(LResponse);
      end;
    except
      on E: Exception do
        raise eiGenericException.CreateFmt('Invoice ID:%s; Exception: %s', [AInvoiceID, E.Message]);
    end;

  finally
    if Assigned(JObjResponse) then
      JObjResponse.Free;
    LRESTClient.Free;
    LRESTRequest.Free;
    LRESTResponse.Free;
  end;
end;

procedure TeiProviderAruba.DoReceivePurchaseInvoiceNotifications(const AInvoiceID: string; const AResponseCollection: IeiResponseCollection);
var
  LRESTClient: TRESTClient;
  LRESTRequest: TRESTRequest;
  LRESTResponse: TRESTResponse;
  LResponse: IeiResponse;
  JObjResponse: TJSONObject;
  LJsonNotifications: TJSONArray;
  LJsonNotification: TJSONObject;
  LJValue: TJSONValue;
  I: Integer;
begin
  inherited;
  JObjResponse := nil;

  LRESTClient := TRESTClient.Create(nil);
  LRESTRequest := TRESTRequest.Create(nil);
  LRESTResponse := TRESTResponse.Create(nil);
  try
    LRESTClient.BaseURL := Params.Provider.BaseURLWS;
    LRESTClient.AllowCookies := True;
    LRESTClient.ContentType := 'application/json;charset=UTF-8';

    LRESTRequest.Resource := '/services/notification/in/getByInvoiceFilename';
    LRESTRequest.Client := LRESTClient;
    LRESTRequest.Response := LRESTResponse;
    LRESTRequest.Method := rmGET;

    LRESTRequest.AddParameter('invoiceFilename', AInvoiceID);
    LRESTRequest.AddParameter('Authorization', Format('Bearer %s', [FAccessToken]), TRESTRequestParameterKind.pkHTTPHEADER, [poDoNotEncode]);

    LRESTRequest.Execute;
    if LRESTResponse.StatusCode <> 200 then
      raise eiGenericException.Create(Format('in/getByInvoiceFilename error: %d - %s', [LRESTResponse.StatusCode, LRESTResponse.StatusText]));

    JObjResponse := TJSONObject.ParseJSONValue(LRESTResponse.JSONText) as TJSONObject;
    if Assigned(JObjResponse) then
    begin
      LJValue := JObjResponse.GetValue('notifications');
      if not(LJValue is TJSONNull) then
      begin
        LJsonNotifications := JObjResponse.GetValue<TJSONArray>('notifications');

        for I := 0 to LJsonNotifications.Count - 1 do
        begin
          LJsonNotification := LJsonNotifications.Items[I] as TJSONObject;
          LResponse := TeiResponseFactory.NewResponse;
          LResponse.MsgCode := '';
          LResponse.MsgText := '';
          LResponse.MsgRaw := JValueToString(LJsonNotification.Values['file']);
          if not LResponse.MsgRaw.IsEmpty then
            LResponse.MsgRaw := TNetEncoding.Base64.Decode(LResponse.MsgRaw);
          LResponse.ResponseType := TeiUtils.ResponseTypeToEnum(LJsonNotification.GetValue<TJSONString>('docType').Value, LResponse.MsgRaw);
          LResponse.FileName := JValueToString(LJsonNotification.Values['filename']);
          LResponse.ResponseDate := JValueToDateTimeDefault(LJsonNotification.Values['date'], LJsonNotification.Values['notificationDate']);
          LResponse.NotificationDate := JValueToDateTimeDefault(LJsonNotification.Values['notificationDate'], LJsonNotification.Values['date']);
          AResponseCollection.Add(LResponse);
        end;
      end;
    end;

  finally
    if Assigned(JObjResponse) then
      JObjResponse.Free;
    LRESTClient.Free;
    LRESTRequest.Free;
    LRESTResponse.Free;
  end;
end;

// function TeiProviderAruba.PurgeP7mSignature(const AString: string): string;
// var
// LStartPos: Integer;
// LEndPos: Integer;
// begin
// // rimuovo tutti i caratteri antecedenti "<?xml" e oltre "FatturaElettronica>"
// LStartPos := pos('?xml', AString);
// Result := AString.Substring(LStartPos - 1);
// LEndPos := pos('FatturaElettronica>', Result);
// Result := '<' + Result.Substring(0, LEndPos + 18);
// end;

end.
