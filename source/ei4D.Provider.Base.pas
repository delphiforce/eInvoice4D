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
unit ei4D.Provider.Base;

interface

// DO NOT REMOVE !!! IPPeerClient necessary for all REST calls in derived classes
// DO NOT REMOVE !!! IPPeerClient necessary for all REST calls in derived classes
// DO NOT REMOVE !!! IPPeerClient necessary for all REST calls in derived classes
uses IPPeerClient, ei4D.Response.Interfaces, ei4D.Provider.Interfaces,
  ei4D.Invoice.Interfaces, ei4D.Params.Interfaces, System.SysUtils;

type

  TeiProviderClassRef = class of TeiProviderBase;

  TeiProviderBase = class(TInterfacedObject, IeiProvider)
  private
    FParams: IeiParams;
    procedure _InternalSendInvoice(const AInvoice: IFatturaElettronicaType; const AResponseCollection: IeiResponseCollection);
    procedure _InternalReceivePurchaseInvoice(const AInvoiceID: string; const AResponseCollection: IeiResponseCollection);
    procedure _InternalReceiveInvoiceNotifications(const AInvoiceID: string; const AResponseCollection: IeiResponseCollection);
  protected
    property Params: IeiParams read FParams;
    procedure ValidateParams(const AParams: IeiParams); virtual;
    // Methods to be implemented by descendant concrete providers
    procedure DoConnect; virtual; abstract;
    procedure DoDisconnect; virtual; abstract;
    procedure DoSendInvoice(const AInvoice: string; const AResponseCollection: IeiResponseCollection); virtual; abstract;
    procedure DoReceiveInvoiceNotifications(const AInvoiceID: string; const AResponseCollection: IeiResponseCollection); virtual; abstract;
    procedure DoReceivePurchaseInvoiceIDCollection(const AVatCodeReceiver: string; const AStartDate: TDateTime; AEndDate: TDateTime;
      const AInvoiceIDCollection: IeiInvoiceIDCollection); virtual; abstract;
    procedure DoReceivePurchaseInvoice(const AInvoiceID: string; const AResponseCollection: IeiResponseCollection); virtual; abstract;
    procedure DoReceivePurchaseInvoiceNotifications(const AInvoiceID: string; const AResponseCollection: IeiResponseCollection); virtual; abstract;
  public
    constructor Create(const AParams: IeiParams); virtual;
    // Connect/Disconnect
    procedure Connect;
    procedure Disconnect;
    // Send
    function SendInvoice(const AInvoice: string): IeiResponseCollection; overload;
    function SendInvoice(const AInvoice: IFatturaElettronicaType): IeiResponseCollection; overload;
    function SendInvoiceCollection(const AInvoiceCollection: IeiInvoiceCollection): IeiResponseCollection; overload;
    procedure SendInvoiceCollection(const AInvoiceCollection: IeiInvoiceCollection; const AAfterEachMethod: TProc<IeiResponseCollection>;
      const AOnEachErrorMethod: TProc<IeiResponseCollection, Exception> = nil); overload;
    // Receive
    function ReceivePurchaseInvoiceIDCollection(const AVatCodeReceiver: string; const AStartDate: TDateTime; AEndDate: TDateTime = 0): IeiInvoiceIDCollection;
    function ReceivePurchaseInvoice(const AInvoiceID: string): IeiResponseCollection;
    function ReceivePurchaseInvoiceCollection(const AInvoiceIDCollection: IeiInvoiceIDCollection): IeiResponseCollection; overload;
    procedure ReceivePurchaseInvoiceCollection(const AInvoiceIDCollection: IeiInvoiceIDCollection;
      const AAfterEachMethod: TProc<IeiResponseCollection, String>;
      const AOnEachErrorMethod: TProc<IeiResponseCollection, Exception, String> = nil); overload;
    // Notifications (sales)
    function ReceiveInvoiceNotifications(const AInvoiceID: string): IeiResponseCollection;
    function ReceiveInvoiceCollectionNotifications(const AInvoiceIDCollection: IeiInvoiceIDCollection): IeiResponseCollection; overload;
    procedure ReceiveInvoiceCollectionNotifications(const AInvoiceIDCollection: IeiInvoiceIDCollection;
      const AAfterEachMethod: TProc<IeiResponseCollection, String>;
      const AOnEachErrorMethod: TProc<IeiResponseCollection, Exception, String> = nil); overload;
    // Notifications (purchase)
    function ReceivePurchaseInvoiceNotifications(const AInvoiceID: string): IeiResponseCollection;
{ TODO : Fare anche le versioni a liste come sopra? Anche con i metodi anonimi? }
  end;

implementation

uses ei4D.Exception, ei4D.Logger, ei4D.Response.Factory,
  ei4D.Invoice.Factory, ei4D.Utils.Sanitizer, ei4D;

{ TeiProviderBase }

constructor TeiProviderBase.Create(const AParams: IeiParams);
begin
  inherited Create;
  ValidateParams(AParams);
  FParams := AParams;
end;

procedure TeiProviderBase.Connect;
begin
  TeiLogger.LogSeparator;
  TeiLogger.LogI(Format('Trying to connect to %S', [FParams.Provider.ID]));
  try
    DoConnect;
    TeiLogger.LogI(Format('Connected to %S', [FParams.Provider.ID]));
  except
    on E: Exception do
    begin
      TeiLogger.LogE(E);
      raise;
    end;
  end;
end;

procedure TeiProviderBase.Disconnect;
begin
  TeiLogger.LogI(Format('Disconnecting from %S', [FParams.Provider.ID]));
  try
    DoDisconnect;
    TeiLogger.LogI(Format('Disconnected from %S', [FParams.Provider.ID]));
  except
    on E: Exception do
    begin
      TeiLogger.LogE(E);
      raise;
    end;
  end;
end;

function TeiProviderBase.ReceiveInvoiceCollectionNotifications(const AInvoiceIDCollection: IeiInvoiceIDCollection): IeiResponseCollection;
var
  LInvoiceID: string;
begin
  Result := TeiResponseFactory.NewResponseCollection;
  for LInvoiceID in AInvoiceIDCollection do
    _InternalReceiveInvoiceNotifications(LInvoiceID, Result);
end;

procedure TeiProviderBase.ReceiveInvoiceCollectionNotifications(const AInvoiceIDCollection: IeiInvoiceIDCollection;
  const AAfterEachMethod: TProc<IeiResponseCollection, String>; const AOnEachErrorMethod: TProc<IeiResponseCollection, Exception, String>);
var
  LInvoiceID: string;
  LResponseCollection: IeiResponseCollection;
begin
  for LInvoiceID in AInvoiceIDCollection do
  begin
    try
      LResponseCollection := TeiResponseFactory.NewResponseCollection;
      _InternalReceiveInvoiceNotifications(LInvoiceID, LResponseCollection);
      if Assigned(AAfterEachMethod) then
        AAfterEachMethod(LResponseCollection, LInvoiceID);
    except
      on E: Exception do
      begin
        TeiLogger.LogE(E);
        if Assigned(AOnEachErrorMethod) then
          AOnEachErrorMethod(LResponseCollection, E, LInvoiceID)
        else
          raise;
      end;
    end;
  end;
end;

function TeiProviderBase.ReceiveInvoiceNotifications(const AInvoiceID: string): IeiResponseCollection;
begin
  Result := TeiResponseFactory.NewResponseCollection;
  _InternalReceiveInvoiceNotifications(AInvoiceID, Result);
end;

function TeiProviderBase.ReceivePurchaseInvoice(const AInvoiceID: string): IeiResponseCollection;
begin
  Result := TeiResponseFactory.NewResponseCollection;
  _InternalReceivePurchaseInvoice(AInvoiceID, Result);
end;

procedure TeiProviderBase.ReceivePurchaseInvoiceCollection(const AInvoiceIDCollection: IeiInvoiceIDCollection;
  const AAfterEachMethod: TProc<IeiResponseCollection, String>; const AOnEachErrorMethod: TProc<IeiResponseCollection, Exception, String>);
var
  LInvoiceID: string;
  LResponseCollection: IeiResponseCollection;
begin
  for LInvoiceID in AInvoiceIDCollection do
  begin
    try
      LResponseCollection := TeiResponseFactory.NewResponseCollection;
      _InternalReceivePurchaseInvoice(LInvoiceID, LResponseCollection);
      if Assigned(AAfterEachMethod) then
        AAfterEachMethod(LResponseCollection, LInvoiceID);
    except
      on E: Exception do
      begin
        TeiLogger.LogE(E);
        if Assigned(AOnEachErrorMethod) then
          AOnEachErrorMethod(LResponseCollection, E, LInvoiceID)
        else
          raise;
      end;
    end;
  end;
end;

function TeiProviderBase.ReceivePurchaseInvoiceCollection(const AInvoiceIDCollection: IeiInvoiceIDCollection): IeiResponseCollection;
var
  LInvoiceID: string;
begin
  Result := TeiResponseFactory.NewResponseCollection;
  for LInvoiceID in AInvoiceIDCollection do
    _InternalReceivePurchaseInvoice(LInvoiceID, Result);
end;

function TeiProviderBase.ReceivePurchaseInvoiceIDCollection(const AVatCodeReceiver: string; const AStartDate: TDateTime; AEndDate: TDateTime)
  : IeiInvoiceIDCollection;
begin
  // Wait for InterOperationDelay (depending on provider, for example Aruba = 5100ms)
  Sleep(FParams.InterOperationDelay);
  try
    Result := TeiInvoiceFactory.NewInvoiceIDCollection;
    DoReceivePurchaseInvoiceIDCollection(AVatCodeReceiver, AStartDate, AEndDate, Result);
  except
    on E: Exception do
    begin
      TeiLogger.LogE(E);
      raise;
    end;
  end;
end;

function TeiProviderBase.ReceivePurchaseInvoiceNotifications(const AInvoiceID: string): IeiResponseCollection;
begin
  // Wait for InterOperationDelay (depending on provider, for example Aruba = 5100ms)
  Sleep(FParams.InterOperationDelay);
  try
    Result := TeiResponseFactory.NewResponseCollection;
    // Type here the code to be executed...
    TeiLogger.LogI(Format('Getting notifications for purchase invoice "%s"', [AInvoiceID]));
    DoReceivePurchaseInvoiceNotifications(AInvoiceID, Result);
    TeiLogger.LogI(Format('Got notifications for purchase invoice "%s"', [AInvoiceID]));
  except
    on E: Exception do
    begin
      TeiLogger.LogE(E);
      raise;
    end;
  end;
end;

function TeiProviderBase.SendInvoice(const AInvoice: string): IeiResponseCollection;
begin
  Result := TeiResponseFactory.NewResponseCollection;
  _InternalSendInvoice(ei.NewInvoiceFromString(AInvoice), Result);
end;

function TeiProviderBase.SendInvoice(const AInvoice: IFatturaElettronicaType): IeiResponseCollection;
begin
  Result := TeiResponseFactory.NewResponseCollection;
  _InternalSendInvoice(AInvoice, Result);
end;

procedure TeiProviderBase.SendInvoiceCollection(const AInvoiceCollection: IeiInvoiceCollection; const AAfterEachMethod: TProc<IeiResponseCollection>;
  const AOnEachErrorMethod: TProc<IeiResponseCollection, Exception>);
var
  LInvoice: IFatturaElettronicaType;
  LResponseCollection: IeiResponseCollection;
begin
  for LInvoice in AInvoiceCollection do
  begin
    try
      LResponseCollection := TeiResponseFactory.NewResponseCollection;
      _InternalSendInvoice(LInvoice, LResponseCollection);
      if Assigned(AAfterEachMethod) then
        AAfterEachMethod(LResponseCollection);
    except
      on E: Exception do
      begin
        TeiLogger.LogE(E);
        if Assigned(AOnEachErrorMethod) then
          AOnEachErrorMethod(LResponseCollection, E)
        else
          raise;
      end;
    end;
  end;
end;

function TeiProviderBase.SendInvoiceCollection(const AInvoiceCollection: IeiInvoiceCollection): IeiResponseCollection;
var
  LInvoice: IFatturaElettronicaType;
begin
  Result := TeiResponseFactory.NewResponseCollection;
  for LInvoice in AInvoiceCollection do
    _InternalSendInvoice(LInvoice, Result);
end;

procedure TeiProviderBase.ValidateParams(const AParams: IeiParams);
begin
  // UserName
  if AParams.Provider.UserName.Trim.IsEmpty then
    raise eiGenericException.Create('UserName is empty');
  // Password
  if AParams.Provider.Password.Trim.IsEmpty then
    raise eiGenericException.Create('Password is empty');
  // BaseUrlAuth
  if AParams.Provider.BaseUrlAuth.Trim.IsEmpty then
    raise eiGenericException.Create('BaseUrlAuth is empty');
  // BaseUrlWS
  if AParams.Provider.BaseUrlWS.Trim.IsEmpty then
    raise eiGenericException.Create('BaseUrlWS is empty');
end;

procedure TeiProviderBase._InternalReceiveInvoiceNotifications(const AInvoiceID: string; const AResponseCollection: IeiResponseCollection);
begin
  // Wait for InterOperationDelay (depending on provider, for example Aruba = 5100ms)
  Sleep(FParams.InterOperationDelay);
  try
    // Type here the code to be executed...
    TeiLogger.LogI(Format('Getting notifications for invoice "%s"', [AInvoiceID]));
    DoReceiveInvoiceNotifications(AInvoiceID, AResponseCollection);
    TeiLogger.LogI(Format('Got notifications for invoice "%s"', [AInvoiceID]));
  except
    on E: Exception do
    begin
      TeiLogger.LogE(E);
      raise;
    end;
  end;
end;

procedure TeiProviderBase._InternalReceivePurchaseInvoice(const AInvoiceID: string; const AResponseCollection: IeiResponseCollection);
begin
  // Wait for InterOperationDelay (depending on provider, for example Aruba = 5100ms)
  Sleep(FParams.InterOperationDelay);
  try
    TeiLogger.LogI(Format('Receiving invoice "%s"', [AInvoiceID]));
    DoReceivePurchaseInvoice(AInvoiceID, AResponseCollection);
    TeiLogger.LogI(Format('Invoice "%s" received', [AInvoiceID]));
    if FParams.SanitizePurchaseInvoices then
    begin
      TeiLogger.LogI(Format('Sanitizing XML structure for invoice "%s"', [AInvoiceID]));
      AResponseCollection.Last.MsgRaw := TeiSanitizer.SanitizeReceivedXML(AResponseCollection.Last.MsgRaw);
    end;
  except
    on E: Exception do
    begin
      TeiLogger.LogE(E);
      raise;
    end;
  end;
end;

procedure TeiProviderBase._InternalSendInvoice(const AInvoice: IFatturaElettronicaType; const AResponseCollection: IeiResponseCollection);
var
  LDocNum: string;
begin
  // Wait for InterOperationDelay (depending on provider, for example Aruba = 5100ms)
  Sleep(FParams.InterOperationDelay);
  try
    // Extract the document number
    TeiLogger.LogI('Trying to extract the document number');
    LDocNum := AInvoice.FatturaElettronicaBody[0].DatiGenerali.DatiGeneraliDocumento.Numero.Value;
    // Send the invoice
    TeiLogger.LogI(Format('Sending invoice "%s"', [LDocNum]));
    DoSendInvoice(ei.InvoiceToString(AInvoice), AResponseCollection);
    AResponseCollection.Last.Invoice := AInvoice; // Inject the Invoice itself in the first (and only) response
    TeiLogger.LogI(Format('Invoice "%s" sent', [LDocNum]));
  except
    on E: Exception do
    begin
      TeiLogger.LogE(E);
      raise;
    end;
  end;
end;

end.
