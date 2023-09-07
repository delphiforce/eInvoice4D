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
unit ei4D.Provider.OSItalia;

interface

uses
  System.SysUtils,
  System.Classes,
  System.JSon,
  System.Generics.Collections,
  System.Net.UrlClient,
  System.Net.HttpClient,
  System.Zip,
  System.NetEncoding,
  System.Math,
  System.DateUtils,

  ei4D.Provider.Interfaces,
  ei4D.Params.Interfaces,
  ei4D.Response.Interfaces,
  ei4D.Invoice.Interfaces,
  ei4D.Exception,
  ei4D.Provider.Base,
  ei4D.Response.Factory,
  ei4D.Utils.P7mExtractor;

type

  { TeiProviderOSItalia }

  TeiProviderOSItalia = class(TeiProviderBase)
  strict private
    FHttpClient: THttpClient;
    FToken: string;

    function GetAuthHeaders: TNetHeaders;
    function GetUrl(const AAuth: Boolean; const AUri: String): String;
    procedure CheckResponse(const AResponse: IHTTPResponse);
    procedure CheckToken;

    function InternalReceivePurchaseInvoiceIDCollection(const AFromDate: TDateTime; const AToDate: TDateTime; var ALastID: String; const AMaxRecords: Integer;
      const AInvoiceIDCollection: IeiInvoiceIDCollection): Boolean;
  public
    constructor Create(const AParams: IeiParams); override;
    destructor Destroy; override;

    procedure DoConnect; override;
    procedure DoDisconnect; override;

    procedure DoSendInvoice(const AInvoice: string; const AResponseCollection: IeiResponseCollection); override;
    procedure DoReceiveInvoiceNotifications(const AInvoiceID: string; const AResponseCollection: IeiResponseCollection); override;
    procedure DoReceivePurchaseInvoiceIDCollection(const AVatCodeReceiver: string; const AStartDate: TDateTime; AEndDate: TDateTime;
      const AInvoiceIDCollection: IeiInvoiceIDCollection); override;
    procedure DoReceivePurchaseInvoice(const AInvoiceID: string; const AResponseCollection: IeiResponseCollection); override;
    procedure DoReceivePurchaseInvoiceNotifications(const AInvoiceID: string; const AResponseCollection: IeiResponseCollection); override;
  end;

implementation

{$REGION 'Requests Classes'}
{ TLogonRequest }

type

  TLogonRequest = class
  strict private
    FUsername: String;
    FPassword: String;
  public
    constructor Create(const AUsername: String; const APassword: String);
    function ToStream: TStream;
  end;

constructor TLogonRequest.Create(const AUsername: String; const APassword: String);
begin
  inherited Create;
  FUsername := AUsername;
  FPassword := APassword;
end;

function TLogonRequest.ToStream: TStream;
var
  LJSon: TJSonObject;
begin
  LJSon := TJSonObject.Create;
  try
    LJSon.AddPair('Username', FUsername);
    LJSon.AddPair('Password', FPassword);

    result := TStringStream.Create(LJSon.ToJSon());
  finally
    LJSon.Free;
  end;
end;

{ TUploadInvoiceRequest }

type

  TUploadInvoiceRequest = class
  strict private
    FFileBase64: String;

    function ZipAndBase64(const AInvoice: String): String;
  public
    constructor Create(const AInvoice: String);

    function ToStream: TStream;
  end;

constructor TUploadInvoiceRequest.Create(const AInvoice: String);
begin
  inherited Create;
  FFileBase64 := ZipAndBase64(AInvoice);
end;

function TUploadInvoiceRequest.ZipAndBase64(const AInvoice: String): String;
var
  LInStream: TStringStream;
  LOutStream: TMemoryStream;
  LZip: TZipFile;
  LSize: Integer;
  LBytes: TBytes;
begin
  LInStream := TStringStream.Create(AInvoice);
  try
    LInStream.Position := 0;

    LOutStream := TMemoryStream.Create;
    try
      LZip := TZipFile.Create;
      try
        LZip.Open(LOutStream, TZipMode.zmWrite);
        LZip.Add(LInStream, 'Fattura.xml');
      finally
        LZip.Free;
      end;

      LOutStream.Position := 0;
      LSize := LOutStream.Size;
      SetLength(LBytes, LSize);
      LOutStream.Read(LBytes, LSize);

      result := TNetEncoding.Base64.EncodeBytesToString(LBytes);
    finally
      LOutStream.Free;
    end;
  finally
    LInStream.Free;
  end;
end;

function TUploadInvoiceRequest.ToStream: TStream;
var
  LJSon: TJSonObject;
begin
  LJSon := TJSonObject.Create;
  try
    LJSon.AddPair('file', FFileBase64);
    result := TStringStream.Create(LJSon.ToJSon());
  finally
    LJSon.Free;
  end;
end;

{ TDownloadByFileNameRequest }

type

  TDownloadByFileNameRequest = class
  strict private
    FFileName: String;
  public
    constructor Create(const AFileName: String);

    function ToStream: TStream;
  end;

constructor TDownloadByFileNameRequest.Create(const AFileName: String);
begin
  inherited Create;
  FFileName := AFileName;
end;

function TDownloadByFileNameRequest.ToStream: TStream;
var
  LJSon: TJSonObject;
begin
  LJSon := TJSonObject.Create;
  try
    LJSon.AddPair('fileName', FFileName);
    result := TStringStream.Create(LJSon.ToJSon());
  finally
    LJSon.Free;
  end;
end;

{ TDownloadPurchaseInvoicesRequest }

type

  TDownloadPurchaseInvoicesRequest = class
  strict private
    FFromDate: TDateTime;
    FToDate: TDateTime;
    FMaxRecords: Integer;
    FLastID: String;
  public
    constructor Create(const AFromDate: TDateTime; const AToDate: TDateTime; const AMaxRecords: Integer; const ALastID: String);

    function ToStream: TStream;
  end;

constructor TDownloadPurchaseInvoicesRequest.Create(const AFromDate: TDateTime; const AToDate: TDateTime; const AMaxRecords: Integer; const ALastID: String);
begin
  inherited Create;
  FFromDate := AFromDate;
  FToDate := AToDate;
  FMaxRecords := AMaxRecords;
  FLastID := ALastID;
end;

function TDownloadPurchaseInvoicesRequest.ToStream: TStream;
var
  LJSon: TJSonObject;
begin
  LJSon := TJSonObject.Create;
  try
    LJSon.AddPair('fromDate', FormatDateTime('yyyymmdd', FFromDate));
    LJSon.AddPair('toDate', FormatDateTime('yyyymmdd', FToDate));
    LJSon.AddPair('maxRecords', TJSonNumber.Create(FMaxRecords));
    LJSon.AddPair('lastID', FLastID);

    result := TStringStream.Create(LJSon.ToJSon());
  finally
    LJSon.Free;
  end;
end;

{$ENDREGION}
{$REGION 'Responses Classes'}
{ TLogonResponse }

type

  TLogonResponse = class
  strict private
    FToken: String;
  public
    constructor Create(const AJSon: String);

    property Token: String read FToken;
  end;

constructor TLogonResponse.Create(const AJSon: String);
var
  LJSon: TJSonValue;
begin
  inherited Create;
  LJSon := TJSonObject.ParseJSONValue(AJSon, False, True);
  try
    FToken := LJSon.GetValue<String>('Token', String.Empty);
  finally
    LJSon.Free;
  end;
end;

{ TUploadInvoiceResponse }

type

  TUploadInvoiceResponse = class
  strict private
    FFileName: String;
  public
    constructor Create(const AJSon: String);

    property FileName: String read FFileName;
  end;

constructor TUploadInvoiceResponse.Create(const AJSon: String);
var
  LJSon: TJSonValue;
begin
  inherited Create;
  LJSon := TJSonObject.ParseJSONValue(AJSon, False, True);
  try
    FFileName := LJSon.GetValue<String>('fileName', String.Empty);
  finally
    LJSon.Free;
  end;
end;

{ TDownloadNotificationsResponseItem }

type

  TDownloadNotificationsResponseItem = record
  strict private
    FFileName: String;
    FFileData: String;
    FDataRicezione: TDateTime;
    FTipoNotifica: TeiResponseType;

    function GetTipoNotifica(const AValue: String): TeiResponseType;
  public
    constructor Create(const AJSon: TJSonValue);

    property FileName: String read FFileName;
    property FileData: String read FFileData;
    property DataRicezione: TDateTime read FDataRicezione;
    property TipoNotifica: TeiResponseType read FTipoNotifica;
  end;

constructor TDownloadNotificationsResponseItem.Create(const AJSon: TJSonValue);
begin
  FFileName := AJSon.GetValue<String>('fileName', String.Empty);
  FFileData := AJSon.GetValue<String>('file', String.Empty);
  if not FFileData.IsEmpty then
    FFileData := TNetEncoding.Base64.Decode(FFileData);
  FDataRicezione := AJSon.GetValue<TDateTime>('dataRicezione', 0);
  FTipoNotifica := GetTipoNotifica(AJSon.GetValue<String>('tipoNotifica', String.Empty));
end;

function TDownloadNotificationsResponseItem.GetTipoNotifica(const AValue: String): TeiResponseType;
begin
  if AValue = 'RC' then
    result := rtSDIMessageRC
  else if AValue = 'NS' then
    result := rtSDIMessageNS
  else if AValue = 'MC' then
    result := rtSDIMessageMC
  else if AValue = 'MT' then
    result := rtSDIMessageMT
  else if AValue = 'EC' then
    result := rtSDIMessageEC
  else if AValue = 'SE' then
    result := rtSDIMessageSE
  else if AValue = 'DT' then
    result := rtSDIMessageDT
  else if AValue = 'AT' then
    result := rtSDIMessageAT
  else if AValue = 'N1' then
    result := rtSDIMessageNEAccepted
  else if AValue = 'N2' then
    result := rtSDIMessageNERejected
  else
    result := rtUnknown;
end;

{ TDownloadNotificationsResponse }

type

  TDownloadNotificationsResponse = class
  strict private
    FItems: TList<TDownloadNotificationsResponseItem>;
  public
    constructor Create(const AJSon: String);
    destructor Destroy; override;

    property Items: TList<TDownloadNotificationsResponseItem> read FItems;
  end;

constructor TDownloadNotificationsResponse.Create(const AJSon: String);
var
  LJSon, LItem: TJSonValue;
begin
  inherited Create;
  FItems := TList<TDownloadNotificationsResponseItem>.Create;
  LJSon := TJSonObject.ParseJSONValue(AJSon, False, True);
  try
    if LJSon is TJSonArray then
      for LItem in TJSonArray(LJSon) do
        FItems.Add(TDownloadNotificationsResponseItem.Create(LItem));
  finally
    LJSon.Free;
  end;
end;

destructor TDownloadNotificationsResponse.Destroy;
begin
  FItems.Free;
  inherited Destroy;
end;

{ TDownloadPurchaseInvoicesResponseItem }

type

  TDownloadPurchaseInvoicesResponseItem = record
  strict private
    FID: String;
    FFileName: String;
  public
    constructor Create(const AJSon: TJSonValue);

    property ID: String read FID;
    property FileName: String read FFileName;
  end;

constructor TDownloadPurchaseInvoicesResponseItem.Create(const AJSon: TJSonValue);
begin
  FID := AJSon.GetValue<String>('id', String.Empty);
  FFileName := AJSon.GetValue<String>('fileName', String.Empty);
end;

{ TDownloadPurchaseInvoicesResponse }

type

  TDownloadPurchaseInvoicesResponse = class
  strict private
    FItems: TList<TDownloadPurchaseInvoicesResponseItem>;
  public
    constructor Create(const AJSon: String);
    destructor Destroy; override;

    property Items: TList<TDownloadPurchaseInvoicesResponseItem> read FItems;
  end;

constructor TDownloadPurchaseInvoicesResponse.Create(const AJSon: String);
var
  LJSon, LItem: TJSonValue;
begin
  inherited Create;
  FItems := TList<TDownloadPurchaseInvoicesResponseItem>.Create;
  LJSon := TJSonObject.ParseJSONValue(AJSon, False, True);
  try
    if LJSon is TJSonArray then
    begin
      for LItem in TJSonArray(LJSon) do
        FItems.Add(TDownloadPurchaseInvoicesResponseItem.Create(LItem));
    end;
  finally
    LJSon.Free;
  end;
end;

destructor TDownloadPurchaseInvoicesResponse.Destroy;
begin
  FItems.Free;
  inherited Destroy;
end;

{ TDownloadPurchaseResponse }

type

  TDownloadPurchaseResponse = class
  strict private
    FFileName: String;
    FFileData: String;
    FDataRicezione: TDateTime;
  public
    constructor Create(const AJSon: String);

    property FileName: String read FFileName;
    property FileData: String read FFileData;
    property DataRicezione: TDateTime read FDataRicezione;
  end;

constructor TDownloadPurchaseResponse.Create(const AJSon: String);
var
  LJSon: TJSonValue;
begin
  inherited Create;
  LJSon := TJSonObject.ParseJSONValue(AJSon, False, True);
  try
    FFileName := LJSon.GetValue<String>('fileName', String.Empty);
    FFileData := LJSon.GetValue<String>('file', String.Empty);
    if not FFileData.IsEmpty then
      FFileData := TNetEncoding.Base64.Decode(FFileData);
    FDataRicezione := LJSon.GetValue<TDateTime>('dataRicezione', 0);
  finally
    LJSon.Free;
  end;
end;

{$ENDREGION}
{ TeiProviderOSItalia }

constructor TeiProviderOSItalia.Create(const AParams: IeiParams);
begin
  inherited Create(AParams);
  FHttpClient := THttpClient.Create;
  FToken := String.Empty;
end;

destructor TeiProviderOSItalia.Destroy;
begin
  FHttpClient.Free;
  inherited Destroy;
end;

function TeiProviderOSItalia.GetAuthHeaders: TNetHeaders;
begin
  SetLength(result, 1);
  result[0].Create('Authorization', Format('Bearer %s', [FToken]));
end;

function TeiProviderOSItalia.GetUrl(const AAuth: Boolean; const AUri: String): String;
begin
  if AAuth then
    result := Format('%s/%s', [Params.Provider.BaseUrlAuth, AUri])
  else
    result := Format('%s/%s', [Params.Provider.BaseUrlWS, AUri]);
end;

procedure TeiProviderOSItalia.CheckResponse(const AResponse: IHTTPResponse);
begin
  if (AResponse.StatusCode < 200) or (AResponse.StatusCode > 299) then
    raise eiGenericException.CreateFmt('%s (%d).', [AResponse.ContentAsString(), AResponse.StatusCode]);
end;

procedure TeiProviderOSItalia.CheckToken;
begin
  if FToken.IsEmpty then
    raise eiGenericException.Create('Authentication required');
end;

procedure TeiProviderOSItalia.DoConnect;
var
  LRequest: TLogonRequest;
  LStream: TStream;
  LIResponse: IHTTPResponse;
  LResponse: TLogonResponse;
begin
  LRequest := TLogonRequest.Create(Params.Provider.UserName, Params.Provider.Password);
  try
    LStream := LRequest.ToStream();
    try
      LIResponse := FHttpClient.Post(GetUrl(True, 'logon'), LStream);
      CheckResponse(LIResponse);
      LResponse := TLogonResponse.Create(LIResponse.ContentAsString());
      try
        FToken := LResponse.Token;
      finally
        LResponse.Free;
      end;
    finally
      LStream.Free;
    end;
  finally
    LRequest.Free;
  end;
end;

procedure TeiProviderOSItalia.DoDisconnect;
begin
  FToken := String.Empty;
end;

procedure TeiProviderOSItalia.DoSendInvoice(const AInvoice: string; const AResponseCollection: IeiResponseCollection);
var
  LRequest: TUploadInvoiceRequest;
  LStream: TStream;
  LIResponse: IHTTPResponse;
  LResponse: TUploadInvoiceResponse;
  LResultResponse: IeiResponse;
begin
  CheckToken;
  LRequest := TUploadInvoiceRequest.Create(AInvoice);
  try
    LStream := LRequest.ToStream;
    try
      LIResponse := FHttpClient.Post(GetUrl(False, 'fe/upload'), LStream, nil, GetAuthHeaders);
      CheckResponse(LIResponse);
      LResponse := TUploadInvoiceResponse.Create(LIResponse.ContentAsString());
      try
        LResultResponse := TeiResponseFactory.NewResponse;
        LResultResponse.MsgCode := String.Empty;
        LResultResponse.MsgText := String.Empty;
        LResultResponse.FileName := LResponse.FileName;
        LResultResponse.ResponseDate := Now;
        LResultResponse.NotificationDate := LResultResponse.ResponseDate;
        LResultResponse.ResponseType := rtAcceptedByProvider;

        AResponseCollection.Add(LResultResponse);
      finally
        LResponse.Free;
      end;
    finally
      LStream.Free;
    end;
  finally
    LRequest.Free;
  end;
end;

procedure TeiProviderOSItalia.DoReceiveInvoiceNotifications(const AInvoiceID: string; const AResponseCollection: IeiResponseCollection);
var
  LRequest: TDownloadByFileNameRequest;
  LStream: TStream;
  LIResponse: IHTTPResponse;
  LResponse: TDownloadNotificationsResponse;
  LItem: TDownloadNotificationsResponseItem;
  LResultResponse: IeiResponse;
begin
  CheckToken;
  LRequest := TDownloadByFileNameRequest.Create(AInvoiceID);
  try
    LStream := LRequest.ToStream;
    try
      LIResponse := FHttpClient.Post(GetUrl(False, 'fe/notifiche'), LStream, nil, GetAuthHeaders);
      CheckResponse(LIResponse);
      LResponse := TDownloadNotificationsResponse.Create(LIResponse.ContentAsString());
      try
        for LItem in LResponse.Items do
        begin
          LResultResponse := TeiResponseFactory.NewResponse;
          LResultResponse.MsgCode := String.Empty;
          LResultResponse.MsgText := String.Empty;
          LResultResponse.FileName := LItem.FileName;
          LResultResponse.MsgRaw := LItem.FileData;
          LResultResponse.ResponseDate := LItem.DataRicezione;
          LResultResponse.NotificationDate := LResultResponse.ResponseDate;
          LResultResponse.ResponseType := LItem.TipoNotifica;

          AResponseCollection.Add(LResultResponse);
        end;
      finally
        LResponse.Free;
      end;
    finally
      LStream.Free;
    end;
  finally
    LRequest.Free;
  end;
end;

function TeiProviderOSItalia.InternalReceivePurchaseInvoiceIDCollection(const AFromDate: TDateTime; const AToDate: TDateTime; var ALastID: String;
  const AMaxRecords: Integer; const AInvoiceIDCollection: IeiInvoiceIDCollection): Boolean;
var
  LRequest: TDownloadPurchaseInvoicesRequest;
  LStream: TStream;
  LIResponse: IHTTPResponse;
  LResponse: TDownloadPurchaseInvoicesResponse;
  LItem: TDownloadPurchaseInvoicesResponseItem;
begin
  LRequest := TDownloadPurchaseInvoicesRequest.Create(AFromDate, AToDate, AMaxRecords, ALastID);
  try
    LStream := LRequest.ToStream;
    try
      LIResponse := FHttpClient.Post(GetUrl(False, 'fe/fatture'), LStream, nil, GetAuthHeaders);
      CheckResponse(LIResponse);
      LResponse := TDownloadPurchaseInvoicesResponse.Create(LIResponse.ContentAsString());
      try
        for LItem in LResponse.Items do
        begin
          ALastID := LItem.ID;
          AInvoiceIDCollection.Add(LItem.FileName);
        end;

        result := LResponse.Items.Count < AMaxRecords;
      finally
        LResponse.Free;
      end;
    finally
      LStream.Free;
    end;
  finally
    LRequest.Free;
  end;
end;

procedure TeiProviderOSItalia.DoReceivePurchaseInvoiceIDCollection(const AVatCodeReceiver: string; const AStartDate: TDateTime; AEndDate: TDateTime;
  const AInvoiceIDCollection: IeiInvoiceIDCollection);
const
  MaxRecords: Integer = 10;
var
  LLastID: String;
  LTerminate: Boolean;
begin
  CheckToken;
  if IsZero(AEndDate) then
    AEndDate := EndOfTheDay(Date);
  LLastID := String.Empty;
  LTerminate := False;
  while not LTerminate do
    LTerminate := InternalReceivePurchaseInvoiceIDCollection(AStartDate, AEndDate, LLastID, MaxRecords, AInvoiceIDCollection);
end;

procedure TeiProviderOSItalia.DoReceivePurchaseInvoice(const AInvoiceID: string; const AResponseCollection: IeiResponseCollection);
var
  LRequest: TDownloadByFileNameRequest;
  LStream: TStream;
  LIResponse: IHTTPResponse;
  LResponse: TDownloadPurchaseResponse;
  LResultResponse: IeiResponse;
begin
  CheckToken;
  LRequest := TDownloadByFileNameRequest.Create(AInvoiceID);
  try
    LStream := LRequest.ToStream;
    try
      LIResponse := FHttpClient.Post(GetUrl(False, 'fe/fatturap'), LStream, nil, GetAuthHeaders);
      CheckResponse(LIResponse);
      LResponse := TDownloadPurchaseResponse.Create(LIResponse.ContentAsString());
      try
        LResultResponse := TeiResponseFactory.NewResponse;
        LResultResponse.MsgCode := String.Empty;
        LResultResponse.MsgText := String.Empty;
        LResultResponse.FileName := LResponse.FileName;
        LResultResponse.MsgRaw := LResponse.FileData;
        if LResultResponse.FileName.ToLower.EndsWith('.p7m') then
          LResultResponse.MsgRaw := TExtractP7m.Extract(LResultResponse.MsgRaw);
        LResultResponse.ResponseDate := Date;
        LResultResponse.NotificationDate := LResponse.DataRicezione;
        LResultResponse.ResponseType := rtReceivedFromProvider;

        AResponseCollection.Add(LResultResponse);
      finally
        LResponse.Free;
      end;
    finally
      LStream.Free;
    end;
  finally
    LRequest.Free;
  end;
end;

procedure TeiProviderOSItalia.DoReceivePurchaseInvoiceNotifications(const AInvoiceID: string; const AResponseCollection: IeiResponseCollection);
var
  LRequest: TDownloadByFileNameRequest;
  LStream: TStream;
  LIResponse: IHTTPResponse;
  LResponse: TDownloadPurchaseResponse;
  LResultResponse: IeiResponse;
begin
  CheckToken;
  LRequest := TDownloadByFileNameRequest.Create(AInvoiceID);
  try
    LStream := LRequest.ToStream;
    try
      LIResponse := FHttpClient.Post(GetUrl(False, 'fe/notificap'), LStream, nil, GetAuthHeaders);
      CheckResponse(LIResponse);
      LResponse := TDownloadPurchaseResponse.Create(LIResponse.ContentAsString());
      try
        LResultResponse := TeiResponseFactory.NewResponse;
        LResultResponse.MsgCode := String.Empty;
        LResultResponse.MsgText := String.Empty;
        LResultResponse.FileName := LResponse.FileName;
        LResultResponse.MsgRaw := LResponse.FileData;
        LResultResponse.ResponseDate := LResponse.DataRicezione;
        LResultResponse.NotificationDate := LResponse.DataRicezione;
        LResultResponse.ResponseType := rtSDIMessageMT;

        AResponseCollection.Add(LResultResponse);
      finally
        LResponse.Free;
      end;
    finally
      LStream.Free;
    end;
  finally
    LRequest.Free;
  end;
end;

end.
