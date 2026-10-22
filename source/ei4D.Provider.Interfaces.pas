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
unit ei4D.Provider.Interfaces;

interface

uses ei4D.Response.Interfaces, ei4D.Invoice.Interfaces, ei4D.Params.Interfaces, System.SysUtils;

type
  // Stato SDI di una fattura inviata, letto in blocco dal provider (es. Aruba invoice/out/findByUsername)
  TeiSalesInvoiceStatus = record
    FileName: string; // nome file assegnato dal provider all'upload
    ProviderStatus: string; // stato testuale del provider (es. "Consegnata")
    // Tipo di notifica SDI corrispondente allo stato: rtAcceptedByProvider = nessuna notifica SDI ancora,
    // rtRejectedByProvider = errore di elaborazione del provider, rtUnknown = stato non riconosciuto
    ResponseType: TeiResponseType;
  end;

  IeiProvider = interface
    ['{DC65CE1B-2574-4044-9E86-61F132504116}']
    // Connect/Disconnect
    procedure Connect;
    procedure Disconnect;
    // Replaces the params used by an already-connected provider (e.g. per-tenant formatting
    // params) without re-authenticating: credentials/BaseUrl are re-validated but no new
    // login is triggered, so a single provider instance/token can be reused across tenants.
    procedure SetParams(const AParams: IeiParams);
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
    // Stato delle fatture inviate in blocco (paginato), per chiedere le notifiche solo di quelle cambiate.
    // AMaxPages limita il costo: se le pagine sono di piu' il risultato e' parziale e le fatture mancanti
    // vanno verificate singolarmente. Solleva eccezione se il provider non lo supporta.
    function ReceiveSalesInvoiceStatusCollection(const ACountrySender, AVatCodeSender: string; const AStartDate, AEndDate: TDateTime;
      const AMaxPages: Integer): TArray<TeiSalesInvoiceStatus>;
    // Notifications (purchase)
    function ReceivePurchaseInvoiceNotifications(const AInvoiceID: string): IeiResponseCollection;
  end;

implementation

end.
