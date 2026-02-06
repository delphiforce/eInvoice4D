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
unit ei4D.Notification.Factory;

interface

uses
  System.Classes, ei4D.Notification.Interfaces, ei4D.Params.Interfaces;

type

  TeiNotificationFactory = class
  private
    class function InternalNewNotificaScartoFromString(AStringXML: String; const AParams: IeiParams): INotificaScartoType;
  public
    // Factory methods per NotificaScarto
    class function NewNotificaScarto(const AParams: IeiParams): INotificaScartoType;
    class function NewNotificaScartoFromString(const AStringXML: String; const AParams: IeiParams): INotificaScartoType;
    class function NewNotificaScartoFromStringBase64(const ABase64StringXML: String; const AParams: IeiParams): INotificaScartoType;
    class function NewNotificaScartoFromFile(const AFileName: String; const AParams: IeiParams): INotificaScartoType;
    class function NewNotificaScartoFromStream(const AStream: TStream; const AParams: IeiParams): INotificaScartoType;
    class function NewNotificaScartoFromStreamBase64(const AStream: TStream; const AParams: IeiParams): INotificaScartoType;
  end;

implementation

uses
  System.SysUtils, System.TypInfo, System.NetEncoding,
  ei4D.Invoice.Prop.Block, ei4D.Invoice.Prop.Interfaces,
  ei4D.Serializer.Factory, ei4D.Utils.Sanitizer, ei4D.Utils;

{ TeiNotificationFactory }

class function TeiNotificationFactory.InternalNewNotificaScartoFromString(AStringXML: String; const AParams: IeiParams): INotificaScartoType;
begin
  AStringXML := TeiSanitizer.SanitizeReceivedXML(AStringXML);
  Result := NewNotificaScarto(AParams);
  TeiSerializerFactory.NewSerializer.FromXML(Result, AStringXML);
end;

class function TeiNotificationFactory.NewNotificaScarto(const AParams: IeiParams): INotificaScartoType;
begin
  Result := TeiBlockProperty.Create(TypeInfo(INotificaScartoType), '', 'NotificaScarto', AParams, oUndefined)
    as INotificaScartoType;
end;

class function TeiNotificationFactory.NewNotificaScartoFromFile(const AFileName: String; const AParams: IeiParams): INotificaScartoType;
var
  LFileStream: TFileStream;
begin
  LFileStream := TFileStream.Create(AFileName, fmOpenRead);
  try
    Result := InternalNewNotificaScartoFromString(TeiUtils.StreamToString(LFileStream), AParams);
  finally
    LFileStream.Free;
  end;
end;

class function TeiNotificationFactory.NewNotificaScartoFromStream(const AStream: TStream; const AParams: IeiParams): INotificaScartoType;
begin
  Result := InternalNewNotificaScartoFromString(TeiUtils.StreamToString(AStream), AParams);
end;

class function TeiNotificationFactory.NewNotificaScartoFromStreamBase64(const AStream: TStream; const AParams: IeiParams): INotificaScartoType;
begin
  Result := NewNotificaScartoFromStringBase64(TeiUtils.StreamToString(AStream), AParams);
end;

class function TeiNotificationFactory.NewNotificaScartoFromString(const AStringXML: String; const AParams: IeiParams): INotificaScartoType;
begin
  Result := InternalNewNotificaScartoFromString(AStringXML, AParams);
end;

class function TeiNotificationFactory.NewNotificaScartoFromStringBase64(const ABase64StringXML: String; const AParams: IeiParams): INotificaScartoType;
begin
  Result := InternalNewNotificaScartoFromString(TNetEncoding.Base64.Decode(ABase64StringXML), AParams);
end;

end.
