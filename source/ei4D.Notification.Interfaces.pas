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
unit ei4D.Notification.Interfaces;

interface

uses
  ei4D.Attributes, ei4D.Invoice.Prop.Interfaces;

type

  // Elemento Errore nella ListaErrori
  IErroreType = interface(IeiBlock)
    ['{7F3A8B2C-4D5E-6F01-9A2B-3C4D5E6F7A8B}']
    [eiProp(1, o11, 5, 5)]
    function Codice: IeiString;
    [eiProp(2, o11, 1, 200)]
    function Descrizione: IeiString;
  end;

  // Blocco ListaErrori contenente lista di errori
  IListaErroriType = interface(IeiBlock)
    ['{8E4B9C3D-5F6A-7B02-8C3D-4E5F6A7B8C9D}']
    [eiList(1, o1N)]
    function Errore: IeiList<IErroreType>;
  end;

  // Blocco opzionale RiferimentoArchivio
  IRiferimentoArchivioType = interface(IeiBlock)
    ['{9F5CAD4E-6A7B-8C03-9D4E-5F6A7B8C9D0E}']
    [eiProp(1, o11, 12, 12)]
    function IdentificativoSdI: IeiString;
    [eiProp(2, o11, 1, 50)]
    function NomeFile: IeiString;
  end;

  // Root: NotificaScarto (NS)
  // Specifica AdE pag. 43-44
  INotificaScartoType = interface(IeiBlock)
    ['{A06DBE5F-7B8C-9D04-AE5F-6A7B8C9D0E1F}']
    [eiProp(1, o11, 12, 12)]
    function IdentificativoSdI: IeiString;
    [eiProp(2, o11, 1, 50)]
    function NomeFile: IeiString;
    [eiProp(3, o11, 19, 19)]
    function DataOraRicezione: IeiDateTime;
    [eiBlock(4, o01)]
    function RiferimentoArchivio: IRiferimentoArchivioType;
    [eiBlock(5, o11)]
    function ListaErrori: IListaErroriType;
    [eiProp(6, o11, 1, 14)]
    function MessageId: IeiString;
    [eiProp(7, o01, 0, 255)]
    function PecMessageId: IeiString;
    [eiProp(8, o01, 0, 255)]
    function Note: IeiString;
  end;

implementation

end.
