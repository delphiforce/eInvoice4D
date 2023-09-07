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
unit ei4D.Response.Interfaces;

interface

uses
  System.Generics.Collections, ei4D.GenericCollection.Interfaces,
  ei4D.Invoice.Interfaces;

type

  TeiResponseType = (rtUnknown, rtException, rtAcceptedByProvider, rtRejectedByProvider, rtSDIMessageRC, rtSDIMessageNS,
    rtSDIMessageMC, rtSDIMessageNEAccepted, rtSDIMessageNERejected, rtSDIMessageMT, rtSDIMessageEC, rtSDIMessageSE, rtSDIMessageDT,
    rtSDIMessageAT, rtReceivedFromProvider);

  IeiResponseBase = interface
    ['{9AD972BD-4C98-43A6-9E9A-32EC88ADCA20}']
    // da implementare se rilevati comportamenti comuni
  end;

  IeiResponse = interface(IeiResponseBase)
    ['{316681F2-30F2-4253-8662-584E4654E47C}']
    // FileName
    function GetFileName: string;
    procedure SetFileName(const Value: string);
    property FileName: string read GetFileName write SetFileName;
    // ResponseDate
    function GetResponseDate: TDateTime;
    procedure SetResponseDate(const AValue: TDateTime);
    property ResponseDate: TDateTime read GetResponseDate write SetResponseDate;
    // Status: stato dell'azione sulla fattura
    function GetResponseType: TeiResponseType;
    procedure SetResponseType(const AValue: TeiResponseType);
    property ResponseType: TeiResponseType read GetResponseType write SetResponseType;
    // NotificationDate
    function GetNotificationDate: TDateTime;
    procedure SetNotificationDate(const AValue: TDateTime);
    property NotificationDate: TDateTime read GetNotificationDate write SetNotificationDate;
    // MsgCode
    function GetMsgCode: string;
    procedure SetMsgCode(const AValue: string);
    property MsgCode: string read GetMsgCode write SetMsgCode;
    // MsgText
    function GetMsgText: string;
    procedure SetMsgText(const AValue: string);
    property MsgText: string read GetMsgText write SetMsgText;
    // RawResponse
    function GetMsgRaw: string;
    procedure SetMsgRaw(const AValue: string);
    property MsgRaw: string read GetMsgRaw write SetMsgRaw;
    // Invoice
    function GetInvoice: IFatturaElettronicaType;
    procedure SetInvoice(const AInvoice: IFatturaElettronicaType);
    property Invoice: IFatturaElettronicaType read GetInvoice write SetInvoice;
  end;

  IeiResponseCollection = IeiCollection<IeiResponse>;

implementation

end.
