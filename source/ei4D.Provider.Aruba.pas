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
  System.SyncObjs,
  ei4D.Params.Interfaces,
  ei4D.Invoice.Interfaces;

const
  // Tempo minimo (in millisecondi) tra due richieste di autenticazione successive (signin o refresh).
  // ARUBA impone max 1 richiesta auth/minuto per IP (HTTP 429 oltre il limite).
  // Default 65000 ms (65 sec) per stare larghi sui 60 s nominali.
  CONST_MIN_AUTH_INTERVAL = 65000;

  // Dopo un HTTP 429 su invoice/upload gli invii vengono sospesi per questo tempo. Con il tiering
  // (sez. 7.3) ogni tentativo fa ripartire il TTL della quota oraria: ritentare prima peggiora il blocco.
  CONST_UPLOAD_BLOCK_MINUTES_AFTER_429 = 61;
  // Dopo un HTTP 429 sulle altre categorie (limite al minuto) si attende questo tempo prima di ritentare
  CONST_COOLDOWN_MS_AFTER_429 = 61000;
  // Dimensione massima del file fattura accettata da Aruba (oltre: HTTP 413)
  CONST_MAX_INVOICE_FILE_BYTES = 5 * 1024 * 1024;

type

  // Categorie di chiamata con limite SLA Aruba distinto (per IP, finestra di un minuto)
  // accSimulator: simulatore SdI dell'ambiente demo (sez. 14), limite non documentato: si usa quello delle ricerche
  TeiArubaCallCategory = (accAuth, accUpload, accSearchOut, accSearchIn, accNotificationOut, accNotificationIn, accSimulator);

  // Rate limiter a finestra mobile per categoria, condiviso da tutte le istanze del provider nel processo
  // (thread-safe). Prima di ogni chiamata si "prenota" uno slot: se nella finestra ci sono gia' LIMITS[cat]
  // chiamate si attende che la piu' vecchia esca dalla finestra. I tentativi falliti contano comunque,
  // come per Aruba. Non coordina processi diversi sullo stesso IP: vedi il mutex nel worker applicativo.
  // Per gli upload gestisce anche la quota oraria del tier (sez. 7.3) e il blocco dopo un 429: in questi
  // casi Acquire(accUpload) NON attende ma solleva eiRateLimitException, cosi' il chiamante interrompe gli
  // invii senza fare altri tentativi (che farebbero ripartire il TTL della quota).
  TeiArubaRateLimiter = class
  private const
    // SLA Aruba (sez. 3): auth 1/min, upload 30/min, ricerche e notifiche 12/min per ciascun tipo.
    // getByFilename/getByInvoiceFilename sono trattate come ricerche: la documentazione non le esclude.
    LIMITS: array [TeiArubaCallCategory] of Integer = (1, 30, 12, 12, 12, 12, 12);
    // Finestre in ms con margine sui 60 s nominali (auth piu' larga, come prima: 65 s)
    WINDOWS_MS: array [TeiArubaCallCategory] of UInt64 = (CONST_MIN_AUTH_INTERVAL, 61000, 61000, 61000, 61000, 61000, 61000);
    NAMES: array [TeiArubaCallCategory] of string = ('auth', 'upload', 'search-out', 'search-in', 'notification-out',
      'notification-in', 'sdi-simulator');
    // Finestra della quota oraria, con un minuto di margine
    UPLOAD_QUOTA_WINDOW_MINUTES = 61;
  private
    class var FLock: TCriticalSection;
    class var FCalls: array [TeiArubaCallCategory] of TQueue<UInt64>;
    class var FBlockedUntilTick: array [TeiArubaCallCategory] of UInt64;
    // Quota oraria upload: orari (UTC) dei tentativi di upload nell'ultima ora e blocco dopo 429.
    // Persistiti su file (se configurato) perche' sopravvivano a un riavvio del servizio.
    class var FMaxUploadsPerHour: Integer; // 0 = nessun limite orario
    class var FUploadHistory: TList<TDateTime>;
    class var FUploadBlockedUntil: TDateTime; // UTC, 0 = nessun blocco
    class var FStateFileName: string;
    class function UtcNow: TDateTime; static;
    class procedure PurgeUploadHistory(const AUtcNow: TDateTime);
    class procedure CheckUploadAllowed;
    class procedure LoadState;
    class procedure SaveState;
  public
    class constructor Create;
    class destructor Destroy;
    // AMaxUploadsPerHour: quota oraria del proprio tier (0 = nessun limite).
    // AStateFileName: file JSON dove persistere storico upload e blocco (vuoto = solo in memoria).
    class procedure ConfigureUploadQuota(const AMaxUploadsPerHour: Integer; const AStateFileName: string);
    // Upload ancora consentiti nell'ora corrente: -1 = nessun limite, 0 = quota esaurita o invii sospesi
    class function UploadQuotaRemaining: Integer;
    class procedure Acquire(const ACategory: TeiArubaCallCategory);
    // Da chiamare quando Aruba risponde HTTP 429
    class procedure RegisterTooManyRequests(const ACategory: TeiArubaCallCategory);
  end;

  // Simulatore del Sistema di Interscambio, disponibile SOLO nell'ambiente demo Aruba (doc. sez. 14).
  // Usa lo stesso token e lo stesso rate limiter del provider; solleva eccezione se BaseUrlWS non e' demo.
  TeiArubaSdiSimulator = class
  public const
    // Tipi di notifica accettati da sdisimulator/notificationOut
    NOTIFICATION_TYPES: array [0 .. 6] of string = ('NS', 'MC', 'AT', 'RC', 'NE_EC01', 'NE_EC02', 'DT');
  public
    class function IsDemo(const AParams: IeiParams): boolean; static;
    // Genera una notifica SDI per una fattura inviata; restituisce il nome file della notifica
    class function SimulateNotificationOut(const AParams: IeiParams; const AInvoiceFileName, ANotificationType: string): string; static;
    // Genera una fattura ricevuta (modello casuale) per il destinatario indicato; restituisce il nome file della fattura
    class function SimulateInvoiceIn(const AParams: IeiParams; const ACountryReceiver, AVatCodeReceiver: string;
      const AFiscalCodeReceiver: string = ''): string; static;
  end;

  TeiProviderAruba = class(TeiProviderBase)
  const
    // Massimo consentito da Aruba per findByUsername: meno pagine = meno chiamate nel limite di 12/min
    ARUBA_PAGE_SIZE = '100';
  private
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
    procedure DoReceivePurchaseInvoiceIDCollection(const AVatCodeReceiver: string; const AStartDate: TDateTime; AEndDate: TDateTime;
      const AInvoiceIDCollection: IeiInvoiceIDCollection); override;
    procedure DoReceivePurchaseInvoice(const AInvoiceID: string; const AResponseCollection: IeiResponseCollection); override;
    procedure DoReceivePurchaseInvoiceNotifications(const AInvoiceID: string; const AResponseCollection: IeiResponseCollection); override;
    procedure DoReceiveSalesInvoiceStatusCollection(const ACountrySender, AVatCodeSender: string; const AStartDate, AEndDate: TDateTime;
      const AMaxPages: Integer; const AResult: TList<TeiSalesInvoiceStatus>); override;
  end;

implementation

uses System.UITypes,
  REST.Types,
  REST.Client,
  System.NetEncoding,
  System.SysUtils,
  System.Math,
  DateUtils,
  System.Classes,
  System.IOUtils,
  System.Net.HttpClient,
  Winapi.windows,
  ei4D.Exception,
  ei4D.Utils,
  ei4D.Response.Factory,
  ei4D.Utils.P7mExtractor,
  ei4D.Utils.Sanitizer,
  ei4D.Logger,
  ei4D.Invoice.Factory,
  ei4D;

class constructor TeiArubaRateLimiter.Create;
var
  LCategory: TeiArubaCallCategory;
begin
  FLock := TCriticalSection.Create;
  for LCategory := Low(TeiArubaCallCategory) to High(TeiArubaCallCategory) do
  begin
    FCalls[LCategory] := TQueue<UInt64>.Create;
    FBlockedUntilTick[LCategory] := 0;
  end;
  FUploadHistory := TList<TDateTime>.Create;
  FMaxUploadsPerHour := 0;
  FUploadBlockedUntil := 0;
  FStateFileName := '';
end;

class destructor TeiArubaRateLimiter.Destroy;
var
  LCategory: TeiArubaCallCategory;
begin
  for LCategory := Low(TeiArubaCallCategory) to High(TeiArubaCallCategory) do
      FCalls[LCategory].Free;
  FUploadHistory.Free;
  FLock.Free;
end;

class function TeiArubaRateLimiter.UtcNow: TDateTime;
begin
  // UTC: lo stato persistito non deve risentire del cambio ora legale
  Result := TTimeZone.Local.ToUniversalTime(Now);
end;

class procedure TeiArubaRateLimiter.PurgeUploadHistory(const AUtcNow: TDateTime);
begin
  while (FUploadHistory.Count > 0) and (FUploadHistory[0] <= IncMinute(AUtcNow, -UPLOAD_QUOTA_WINDOW_MINUTES)) do
      FUploadHistory.Delete(0);
end;

class procedure TeiArubaRateLimiter.CheckUploadAllowed;
var
  LUtcNow, LResumeAt: TDateTime;
begin
  // Chiamato con FLock acquisito
  LUtcNow := UtcNow;
  if FUploadBlockedUntil > LUtcNow then
      raise eiRateLimitException.CreateFmt('Aruba: invio fatture sospeso fino alle %s dopo un HTTP 429 ' +
      '(ogni tentativo farebbe ripartire il conteggio della quota oraria)', [DateTimeToStr(TTimeZone.Local.ToLocalTime(FUploadBlockedUntil))]);
  if FMaxUploadsPerHour > 0 then
  begin
    PurgeUploadHistory(LUtcNow);
    if FUploadHistory.Count >= FMaxUploadsPerHour then
    begin
      LResumeAt := IncMinute(FUploadHistory[0], UPLOAD_QUOTA_WINDOW_MINUTES);
      raise eiRateLimitException.CreateFmt('Aruba: raggiunta la quota di %d invii/ora, invii sospesi fino alle %s',
        [FMaxUploadsPerHour, DateTimeToStr(TTimeZone.Local.ToLocalTime(LResumeAt))]);
    end;
  end;
end;

class procedure TeiArubaRateLimiter.LoadState;
var
  LJson: TJSONObject;
  LArray: TJSONArray;
  LValue: TJSONValue;
  LStr: string;
  I: Integer;
begin
  // Chiamato con FLock acquisito
  FUploadHistory.Clear;
  FUploadBlockedUntil := 0;
  if FStateFileName.IsEmpty or not TFile.Exists(FStateFileName) then
      Exit;
  try
    LJson := TJSONObject.ParseJSONValue(TFile.ReadAllText(FStateFileName, TEncoding.UTF8)) as TJSONObject;
    if not Assigned(LJson) then
        Exit;
    try
      if LJson.TryGetValue<string>('uploadBlockedUntil', LStr) and not LStr.IsEmpty then
          FUploadBlockedUntil := ISO8601ToDate(LStr, True);
      LValue := LJson.GetValue('uploads');
      if LValue is TJSONArray then
      begin
        LArray := TJSONArray(LValue);
        for I := 0 to LArray.Count - 1 do
            FUploadHistory.Add(ISO8601ToDate(LArray.Items[I].Value, True));
        FUploadHistory.Sort;
      end;
    finally
      LJson.Free;
    end;
    PurgeUploadHistory(UtcNow);
  except
    on E: Exception do
    begin
      FUploadHistory.Clear;
      FUploadBlockedUntil := 0;
      TeiLogger.LogW(Format('Aruba SLA: stato non leggibile da "%s", ripartenza da zero: %s', [FStateFileName, E.Message]));
    end;
  end;
end;

class procedure TeiArubaRateLimiter.SaveState;
var
  LJson: TJSONObject;
  LArray: TJSONArray;
  LTime: TDateTime;
begin
  // Chiamato con FLock acquisito. Un errore di scrittura non deve bloccare gli invii.
  if FStateFileName.IsEmpty then
      Exit;
  LJson := TJSONObject.Create;
  try
    if FUploadBlockedUntil > 0 then
        LJson.AddPair('uploadBlockedUntil', DateToISO8601(FUploadBlockedUntil, True))
    else
        LJson.AddPair('uploadBlockedUntil', '');
    LArray := TJSONArray.Create;
    for LTime in FUploadHistory do
        LArray.Add(DateToISO8601(LTime, True));
    LJson.AddPair('uploads', LArray);
    try
      TFile.WriteAllText(FStateFileName, LJson.ToJSON, TEncoding.UTF8);
    except
      on E: Exception do
          TeiLogger.LogW(Format('Aruba SLA: impossibile salvare lo stato su "%s": %s', [FStateFileName, E.Message]));
    end;
  finally
    LJson.Free;
  end;
end;

class procedure TeiArubaRateLimiter.ConfigureUploadQuota(const AMaxUploadsPerHour: Integer; const AStateFileName: string);
begin
  FLock.Enter;
  try
    FMaxUploadsPerHour := Max(0, AMaxUploadsPerHour);
    FStateFileName := AStateFileName;
    LoadState;
    TeiLogger.LogI(Format('Aruba SLA: quota upload %d/ora (0 = nessun limite), %d upload nell''ultima ora', [FMaxUploadsPerHour,
      FUploadHistory.Count]));
  finally
    FLock.Leave;
  end;
end;

class function TeiArubaRateLimiter.UploadQuotaRemaining: Integer;
var
  LUtcNow: TDateTime;
begin
  FLock.Enter;
  try
    LUtcNow := UtcNow;
    if FUploadBlockedUntil > LUtcNow then
        Exit(0);
    if FMaxUploadsPerHour <= 0 then
        Exit(-1);
    PurgeUploadHistory(LUtcNow);
    Result := Max(0, FMaxUploadsPerHour - FUploadHistory.Count);
  finally
    FLock.Leave;
  end;
end;

class procedure TeiArubaRateLimiter.Acquire(const ACategory: TeiArubaCallCategory);
var
  LQueue: TQueue<UInt64>;
  LNow, LWait: UInt64;
begin
  repeat
    FLock.Enter;
    try
      // Quota oraria e blocco dopo 429: per gli upload si interrompe (eccezione), non si attende
      if ACategory = accUpload then
          CheckUploadAllowed;
      LQueue := FCalls[ACategory];
      LNow := GetTickCount64;
      if FBlockedUntilTick[ACategory] > LNow then
          LWait := FBlockedUntilTick[ACategory] - LNow // cooldown dopo un 429
      else
      begin
        while (LQueue.Count > 0) and (LNow - LQueue.Peek >= WINDOWS_MS[ACategory]) do
            LQueue.Dequeue;
        if LQueue.Count < LIMITS[ACategory] then
        begin
          LQueue.Enqueue(LNow);
          LWait := 0;
          if ACategory = accUpload then
          begin
            FUploadHistory.Add(UtcNow);
            SaveState;
          end;
        end
        else
            LWait := WINDOWS_MS[ACategory] - (LNow - LQueue.Peek);
      end;
    finally
      FLock.Leave;
    end;
    // Attesa fuori dal lock: le altre categorie non restano bloccate
    if LWait > 0 then
    begin
      TeiLogger.LogI(Format('Waiting %d ms before next Aruba "%s" call (ARUBA SLA: %d/min/IP)', [LWait, NAMES[ACategory],
        LIMITS[ACategory]]));
      Sleep(Cardinal(LWait));
    end;
  until LWait = 0;
end;

class procedure TeiArubaRateLimiter.RegisterTooManyRequests(const ACategory: TeiArubaCallCategory);
begin
  FLock.Enter;
  try
    if ACategory = accUpload then
    begin
      FUploadBlockedUntil := IncMinute(UtcNow, CONST_UPLOAD_BLOCK_MINUTES_AFTER_429);
      SaveState;
      TeiLogger.LogW(Format('Aruba: HTTP 429 su upload, invii sospesi fino alle %s',
        [DateTimeToStr(TTimeZone.Local.ToLocalTime(FUploadBlockedUntil))]));
    end
    else
    begin
      FBlockedUntilTick[ACategory] := GetTickCount64 + CONST_COOLDOWN_MS_AFTER_429;
      TeiLogger.LogW(Format('Aruba: HTTP 429 su "%s", pausa di %d ms per questa categoria', [NAMES[ACategory],
        CONST_COOLDOWN_MS_AFTER_429]));
    end;
  finally
    FLock.Leave;
  end;
end;

type

  // Gestore del token Aruba condiviso da tutte le istanze del provider nel processo (thread-safe).
  // SLA Aruba: access_token valido 30 min (expires_in), refresh_token valido 60 min dall'emissione,
  // max 1 richiesta di autenticazione (signin o refresh) al minuto per IP.
  // Il token viene riusato finche' valido, poi rinnovato col refresh_token e solo in ultima istanza
  // con un nuovo signin (username/password).
  TeiArubaTokenManager = class
  private const
    // Margine prima della scadenza entro cui il token viene considerato gia' scaduto
    EXPIRY_MARGIN_MS = 120000;
    DEFAULT_ACCESS_TOKEN_LIFETIME_SEC = 1800;
    REFRESH_TOKEN_LIFETIME_MS = 60 * 60 * 1000;
  private
    class var FLock: TCriticalSection;
    class var FCredentialsKey: string;
    class var FAccessToken: string;
    class var FRefreshToken: string;
    class var FAccessExpiresTick: UInt64;
    class var FRefreshExpiresTick: UInt64;
    class procedure Clear;
    class procedure RequestToken(const AParams: IeiParams; const AGrantType: string);
  public
    class constructor Create;
    class destructor Destroy;
    // Restituisce un access token valido. Se ARejectedToken coincide con il token corrente
    // (es. la chiamata ha ricevuto 401), il token viene considerato scaduto e rinnovato.
    class function GetToken(const AParams: IeiParams; const ARejectedToken: string = ''): string;
  end;

class constructor TeiArubaTokenManager.Create;
begin
  FLock := TCriticalSection.Create;
  Clear;
end;

class destructor TeiArubaTokenManager.Destroy;
begin
  FLock.Free;
end;

class procedure TeiArubaTokenManager.Clear;
begin
  FAccessToken := '';
  FRefreshToken := '';
  FAccessExpiresTick := 0;
  FRefreshExpiresTick := 0;
end;

class procedure TeiArubaTokenManager.RequestToken(const AParams: IeiParams; const AGrantType: string);
var
  LRESTClient: TRESTClient;
  LRESTRequest: TRESTRequest;
  LRESTResponse: TRESTResponse;
  LFullTokenJson: TJSONObject;
  LAccessToken, LRefreshToken: string;
  LExpiresIn: Integer;
  LNow: UInt64;
begin
  LFullTokenJson := nil;
  LRESTClient := TRESTClient.Create(nil);
  LRESTRequest := TRESTRequest.Create(nil);
  LRESTResponse := TRESTResponse.Create(nil);
  try
    LRESTClient.BaseURL := AParams.Provider.BaseUrlAuth;
    LRESTClient.AllowCookies := True;
    LRESTClient.ContentType := 'application/x-www-form-urlencoded';

    // LRESTClient.SecureProtocols := [THTTPSecureProtocol.TLS12, THTTPSecureProtocol.TLS13];

    LRESTRequest.Resource := '/auth/signin';
    LRESTRequest.Method := rmPOST;
    LRESTRequest.Client := LRESTClient;
    LRESTRequest.Response := LRESTResponse;

    LRESTRequest.AddParameter('grant_type', AGrantType);
    if AGrantType = 'refresh_token' then
        LRESTRequest.AddParameter('refresh_token', FRefreshToken)
    else
    begin
      LRESTRequest.AddParameter('username', AParams.Provider.UserName);
      LRESTRequest.AddParameter('password', AParams.Provider.Password);
    end;

    // Rate limit auth ARUBA (1/min/IP). Si attende tenendo il lock del token manager:
    // le altre richieste di token restano in coda, ed e' voluto.
    TeiArubaRateLimiter.Acquire(accAuth);
    LRESTRequest.Execute;
    if LRESTResponse.StatusCode = 429 then
    begin
      TeiArubaRateLimiter.RegisterTooManyRequests(accAuth);
      raise eiRateLimitException.CreateFmt('Aruba auth (%s): HTTP 429 Too Many Requests - %s', [AGrantType, LRESTResponse.Content]);
    end;
    if LRESTResponse.StatusCode <> 200 then
        raise eiRESTAuthException.Create(Format('Error during auth request (%s): %d - %s', [AGrantType, LRESTResponse.StatusCode,
        LRESTResponse.Content]));

    LFullTokenJson := TJSONObject.ParseJSONValue(LRESTResponse.JSONText) as TJSONObject;
    if not Assigned(LFullTokenJson) or not LFullTokenJson.TryGetValue<string>('access_token', LAccessToken) or LAccessToken.IsEmpty then
        raise eiRESTAuthException.Create('Error during auth request: access_token property not found');
    if not LFullTokenJson.TryGetValue<string>('refresh_token', LRefreshToken) then
        LRefreshToken := '';
    if not LFullTokenJson.TryGetValue<Integer>('expires_in', LExpiresIn) or (LExpiresIn <= 0) then
        LExpiresIn := DEFAULT_ACCESS_TOKEN_LIFETIME_SEC;

    LNow := GetTickCount64;
    FAccessToken := LAccessToken;
    FAccessExpiresTick := LNow + UInt64(LExpiresIn) * 1000;
    FRefreshToken := LRefreshToken;
    if LRefreshToken.IsEmpty then
        FRefreshExpiresTick := 0
    else
        FRefreshExpiresTick := LNow + REFRESH_TOKEN_LIFETIME_MS;

    TeiLogger.LogI(Format('Aruba token obtained (%s), expires in %d s', [AGrantType, LExpiresIn]));
  finally
    if Assigned(LFullTokenJson) then
        LFullTokenJson.Free;
    LRESTClient.Free;
    LRESTRequest.Free;
    LRESTResponse.Free;
  end;
end;

class function TeiArubaTokenManager.GetToken(const AParams: IeiParams; const ARejectedToken: string): string;
var
  LCredentialsKey: string;
begin
  FLock.Enter;
  try
    // Cambio di account o ambiente (es. demo/produzione): il token in cache non e' piu' valido
    LCredentialsKey := AParams.Provider.BaseUrlAuth + '|' + AParams.Provider.UserName + '|' + AParams.Provider.Password;
    if LCredentialsKey <> FCredentialsKey then
    begin
      Clear;
      FCredentialsKey := LCredentialsKey;
    end;

    // Token rifiutato dal server (401): lo si considera scaduto, il refresh_token resta utilizzabile
    if (not ARejectedToken.IsEmpty) and (ARejectedToken = FAccessToken) then
        FAccessExpiresTick := 0;

    // 1) Token ancora valido: riuso, nessuna chiamata di autenticazione
    if (not FAccessToken.IsEmpty) and (GetTickCount64 + EXPIRY_MARGIN_MS < FAccessExpiresTick) then
        Exit(FAccessToken);

    // 2) Rinnovo col refresh_token; su errore si ripiega sul signin
    if (not FRefreshToken.IsEmpty) and (GetTickCount64 + EXPIRY_MARGIN_MS < FRefreshExpiresTick) then
    begin
      try
        RequestToken(AParams, 'refresh_token');
        Exit(FAccessToken);
      except
        on E: Exception do
        begin
          TeiLogger.LogW('Aruba token refresh failed, falling back to signin: ' + E.Message);
          Clear;
        end;
      end;
    end;

    // 3) Nuovo signin con username/password
    Clear;
    RequestToken(AParams, 'password');
    Result := FAccessToken;
  finally
    FLock.Leave;
  end;
end;

// Su HTTP 429 registra il blocco nel rate limiter e solleva eiRateLimitException
procedure CheckTooManyRequests(const ARequest: TRESTRequest; const ACategory: TeiArubaCallCategory);
begin
  if ARequest.Response.StatusCode = 429 then
  begin
    TeiArubaRateLimiter.RegisterTooManyRequests(ACategory);
    raise eiRateLimitException.CreateFmt('Aruba %s: HTTP 429 Too Many Requests - %s', [ARequest.Resource, ARequest.Response.Content]);
  end;
end;

// Esegue una richiesta verso i servizi Aruba aggiungendo il Bearer token e rispettando il rate limit
// della categoria (anche per il ritentativo). Su 401 rinnova il token e ritenta UNA sola volta.
// Su 429 solleva eiRateLimitException (nessun ritentativo).
procedure ExecuteAuthorized(const AParams: IeiParams; const ARequest: TRESTRequest; const ACategory: TeiArubaCallCategory);
var
  LToken: string;
begin
  LToken := TeiArubaTokenManager.GetToken(AParams);
  ARequest.AddParameter('Authorization', Format('Bearer %s', [LToken]), TRESTRequestParameterKind.pkHTTPHEADER, [poDoNotEncode]);
  TeiArubaRateLimiter.Acquire(ACategory);
  ARequest.Execute;
  CheckTooManyRequests(ARequest, ACategory);
  if ARequest.Response.StatusCode = 401 then
  begin
    TeiLogger.LogW(Format('Aruba %s: 401 Unauthorized, renewing token and retrying once', [ARequest.Resource]));
    LToken := TeiArubaTokenManager.GetToken(AParams, LToken);
    ARequest.Params.ParameterByName('Authorization').Value := Format('Bearer %s', [LToken]);
    TeiArubaRateLimiter.Acquire(ACategory);
    ARequest.Execute;
    CheckTooManyRequests(ARequest, ACategory);
  end;
end;

// Stati delle fatture inviate (doc. Aruba sez. 8.1) -> tipo di notifica SDI corrispondente
function ArubaOutStatusToResponseType(const AStatus: string): TeiResponseType;
var
  LStatus: string;
begin
  LStatus := AStatus.Trim.ToLower;
  if (LStatus = 'presa in carico') or (LStatus = 'inviata') then
      Result := rtAcceptedByProvider // nessuna notifica SDI ancora
  else if LStatus = 'errore elaborazione' then
      Result := rtRejectedByProvider
  else if LStatus = 'scartata' then
      Result := rtSDIMessageNS
  else if LStatus = 'non consegnata' then
      Result := rtSDIMessageMC
  else if LStatus = 'recapito impossibile' then
      Result := rtSDIMessageAT
  else if LStatus = 'consegnata' then
      Result := rtSDIMessageRC
  else if LStatus = 'accettata' then
      Result := rtSDIMessageNEAccepted
  else if LStatus = 'rifiutata' then
      Result := rtSDIMessageNERejected
  else if LStatus = 'decorrenza termini' then
      Result := rtSDIMessageDT
  else
      Result := rtUnknown;
end;

procedure TeiProviderAruba.DoConnect;
begin
  inherited;
  // Nessun signin a ogni Connect: si riusa il token in cache se ancora valido (TeiArubaTokenManager).
  // Si chiede comunque il token qui per fallire subito in caso di credenziali errate.
  TeiArubaTokenManager.GetToken(Params);
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
    ExecuteAuthorized(Params, LRESTRequest, accSearchIn);
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

  // Limite Aruba sul file fattura: si evita una chiamata (che conterebbe nella quota) destinata a un 413
  if TEncoding.UTF8.GetByteCount(AInvoice) > CONST_MAX_INVOICE_FILE_BYTES then
      raise eiGenericException.CreateFmt('Sending invoice error: file fattura di %d byte, oltre il limite Aruba di %d byte (5 MB)',
      [TEncoding.UTF8.GetByteCount(AInvoice), CONST_MAX_INVOICE_FILE_BYTES]);

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

    TeiSanitizer.SanitizeJSON(LJSONBody);
    LRESTRequest.Body.Add(LJSONBody, TRESTContentType.ctAPPLICATION_JSON);

    ExecuteAuthorized(Params, LRESTRequest, accUpload);
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

    ExecuteAuthorized(Params, LRESTRequest, accNotificationOut);
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

procedure TeiProviderAruba.DoReceivePurchaseInvoiceIDCollection(const AVatCodeReceiver: string; const AStartDate: TDateTime; AEndDate: TDateTime;
  const AInvoiceIDCollection: IeiInvoiceIDCollection);
var
  LastPage: boolean;
  LCurrentPage: Integer;
begin
  if IsZero(AEndDate) then
      AEndDate := EndOfTheDay(Date);
  LCurrentPage := 1;
  repeat
    LastPage := InternalReceivePurchaseInvoiceFileNameCollection(AVatCodeReceiver, AStartDate, AEndDate, LCurrentPage, AInvoiceIDCollection);
    // Nessuna attesa fissa tra le pagine: la spaziatura e' gestita da TeiArubaRateLimiter (accSearchIn)
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

    ExecuteAuthorized(Params, LRESTRequest, accSearchIn);
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

    ExecuteAuthorized(Params, LRESTRequest, accNotificationIn);
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

procedure TeiProviderAruba.DoReceiveSalesInvoiceStatusCollection(const ACountrySender, AVatCodeSender: string;
  const AStartDate, AEndDate: TDateTime; const AMaxPages: Integer; const AResult: TList<TeiSalesInvoiceStatus>);
var
  LRESTClient: TRESTClient;
  LRESTRequest: TRESTRequest;
  LRESTResponse: TRESTResponse;
  JObjResponse: TJSONObject;
  LJValue, LJInvoices: TJSONValue;
  LJItem: TJSONObject;
  LStatus: TeiSalesInvoiceStatus;
  LPage, LTotalPages, I: Integer;
  LLastPage: boolean;
  LEndDate: TDateTime;
begin
  LEndDate := AEndDate;
  if IsZero(LEndDate) then
      LEndDate := EndOfTheDay(Date);
  LPage := 1;
  repeat
    JObjResponse := nil;
    LRESTClient := TRESTClient.Create(nil);
    LRESTRequest := TRESTRequest.Create(nil);
    LRESTResponse := TRESTResponse.Create(nil);
    try
      LRESTClient.BaseURL := Params.Provider.BaseURLWS;
      LRESTClient.AllowCookies := True;
      LRESTClient.ContentType := 'application/json';

      LRESTRequest.Resource := '/services/invoice/out/findByUsername';
      LRESTRequest.Client := LRESTClient;
      LRESTRequest.Response := LRESTResponse;
      LRESTRequest.Method := rmGET;

      LRESTRequest.AddParameter('username', Params.Provider.UserName);
      LRESTRequest.AddParameter('page', LPage.ToString);
      LRESTRequest.AddParameter('size', ARUBA_PAGE_SIZE);
      LRESTRequest.AddParameter('startDate', TeiUtils.DateTimeToUrlParam(AStartDate), TRESTRequestParameterKind.pkGETorPOST, [poDoNotEncode]);
      LRESTRequest.AddParameter('endDate', TeiUtils.DateTimeToUrlParam(LEndDate), TRESTRequestParameterKind.pkGETorPOST, [poDoNotEncode]);
      // Account unico per piu' ditte: filtro sul cedente (obbligatorio per gli utenti Premium)
      if not AVatCodeSender.Trim.IsEmpty then
      begin
        LRESTRequest.AddParameter('countrySender', ACountrySender);
        LRESTRequest.AddParameter('vatcodeSender', AVatCodeSender);
      end;

      ExecuteAuthorized(Params, LRESTRequest, accSearchOut);
      if LRESTResponse.StatusCode <> 200 then
          raise eiGenericException.Create(Format('out/findByUsername error: %d - %s', [LRESTResponse.StatusCode, LRESTResponse.StatusText]));

      LLastPage := True;
      LTotalPages := LPage;
      JObjResponse := TJSONObject.ParseJSONValue(LRESTResponse.JSONText) as TJSONObject;
      if Assigned(JObjResponse) then
      begin
        LJValue := JObjResponse.Values['content'];
        if LJValue is TJSONArray then
          for I := 0 to TJSONArray(LJValue).Count - 1 do
          begin
            LJItem := TJSONArray(LJValue).Items[I] as TJSONObject;
            LStatus.FileName := JValueToString(LJItem.Values['filename']);
            LStatus.ProviderStatus := '';
            // Lo stato e' per singola fattura del file (lotto): si usa la prima, il lotto ha un'unica notifica SDI
            LJInvoices := LJItem.Values['invoices'];
            if (LJInvoices is TJSONArray) and (TJSONArray(LJInvoices).Count > 0) and (TJSONArray(LJInvoices).Items[0] is TJSONObject) then
                LStatus.ProviderStatus := JValueToString(TJSONObject(TJSONArray(LJInvoices).Items[0]).Values['status']);
            LStatus.ResponseType := ArubaOutStatusToResponseType(LStatus.ProviderStatus);
            if not LStatus.FileName.IsEmpty then
                AResult.Add(LStatus);
          end;
        LLastPage := JValueToBoolean(JObjResponse.GetValue('last'));
        if JObjResponse.GetValue('totalPages') is TJSONNumber then
            LTotalPages := TJSONNumber(JObjResponse.GetValue('totalPages')).AsInt;
      end;
    finally
      if Assigned(JObjResponse) then
          JObjResponse.Free;
      LRESTClient.Free;
      LRESTRequest.Free;
      LRESTResponse.Free;
    end;

    if (not LLastPage) and (LPage >= AMaxPages) then
    begin
      TeiLogger.LogI(Format('out/findByUsername: %d pagine totali, lette %d (limite): risultato parziale', [LTotalPages, LPage]));
      Break;
    end;
    Inc(LPage);
  until LLastPage;
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

{ TeiArubaSdiSimulator }

class function TeiArubaSdiSimulator.IsDemo(const AParams: IeiParams): boolean;
begin
  Result := AParams.Provider.BaseUrlWS.ToLower.Contains('demows.fatturazioneelettronica.aruba.it');
end;

// POST JSON verso il simulatore e restituisce il campo AResultField della risposta (201 Created)
function SimulatorPost(const AParams: IeiParams; const AResource: string; const ABody: TJSONObject; const AResultField: string): string;
var
  LRESTClient: TRESTClient;
  LRESTRequest: TRESTRequest;
  LRESTResponse: TRESTResponse;
  JObjResponse: TJSONValue;
begin
  if not TeiArubaSdiSimulator.IsDemo(AParams) then
      raise eiGenericException.Create('Simulatore SdI disponibile solo nell''ambiente demo Aruba (BaseUrlWS attuale: ' +
      AParams.Provider.BaseUrlWS + ')');

  LRESTClient := TRESTClient.Create(nil);
  LRESTRequest := TRESTRequest.Create(nil);
  LRESTResponse := TRESTResponse.Create(nil);
  try
    LRESTClient.BaseURL := AParams.Provider.BaseUrlWS;
    LRESTRequest.Resource := AResource;
    LRESTRequest.Client := LRESTClient;
    LRESTRequest.Response := LRESTResponse;
    LRESTRequest.Method := rmPOST;
    LRESTRequest.Accept := 'application/json';
    LRESTRequest.Body.Add(ABody.ToJSON, TRESTContentType.ctAPPLICATION_JSON);

    ExecuteAuthorized(AParams, LRESTRequest, accSimulator);
    if not (LRESTResponse.StatusCode in [200, 201]) then
        raise eiGenericException.Create(Format('Aruba %s: %d - %s %s', [AResource, LRESTResponse.StatusCode, LRESTResponse.StatusText,
        LRESTResponse.Content]));

    Result := '';
    JObjResponse := TJSONObject.ParseJSONValue(LRESTResponse.Content);
    try
      if JObjResponse is TJSONObject then
          Result := TJSONObject(JObjResponse).GetValue<string>(AResultField, '');
    finally
      JObjResponse.Free;
    end;
    TeiLogger.LogI(Format('Aruba %s: %s', [AResource, LRESTResponse.Content]));
  finally
    LRESTClient.Free;
    LRESTRequest.Free;
    LRESTResponse.Free;
  end;
end;

class function TeiArubaSdiSimulator.SimulateNotificationOut(const AParams: IeiParams; const AInvoiceFileName, ANotificationType: string): string;
var
  LBody: TJSONObject;
begin
  if AInvoiceFileName.Trim.IsEmpty then
      raise eiGenericException.Create('Simulatore SdI: nome file della fattura inviata obbligatorio');
  LBody := TJSONObject.Create;
  try
    LBody.AddPair('invoiceFileName', AInvoiceFileName.Trim);
    LBody.AddPair('notificationType', ANotificationType.Trim.ToUpper);
    Result := SimulatorPost(AParams, '/services/sdisimulator/notificationOut', LBody, 'notificationFileName');
  finally
    LBody.Free;
  end;
end;

class function TeiArubaSdiSimulator.SimulateInvoiceIn(const AParams: IeiParams; const ACountryReceiver, AVatCodeReceiver,
  AFiscalCodeReceiver: string): string;
var
  LBody: TJSONObject;
begin
  if AVatCodeReceiver.Trim.IsEmpty then
      raise eiGenericException.Create('Simulatore SdI: partita IVA del destinatario obbligatoria');
  LBody := TJSONObject.Create;
  try
    LBody.AddPair('countryReceiver', ACountryReceiver.Trim.ToUpper);
    LBody.AddPair('vatcodeReceiver', AVatCodeReceiver.Trim);
    if AFiscalCodeReceiver.Trim.IsEmpty then
        LBody.AddPair('fiscalcodeReceiver', TJSONNull.Create)
    else
        LBody.AddPair('fiscalcodeReceiver', AFiscalCodeReceiver.Trim);
    Result := SimulatorPost(AParams, '/services/sdisimulator/invoiceIn', LBody, 'invoiceFileName');
  finally
    LBody.Free;
  end;
end;

end.
