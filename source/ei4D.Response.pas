{***************************************************************************}
{                                                                           }
{           eInvoice4D - (Fatturazione Elettronica per Delphi)              }
{                                                                           }
{           Copyright (C) 2018  Delphi Force                                }
{                                                                           }
{           info@delphiforce.it                                             }
{           https://github.com/delphiforce/eInvoice4D.git                   }
{                                                                  	        }
{           Delphi Force Team                                      	        }
{             Antonio Polito                                                }
{             Carlo Narcisi                                                 }
{             Fabio Codebue                                                 }
{             Marco Mottadelli                                              }
{             Maurizio del Magno                                            }
{             Omar Bossoni                                                  }
{             Thomas Ranzetti                                               }
{                                                                           }
{***************************************************************************}
{                                                                           }
{  This file is part of eInvoice4D                                          }
{                                                                           }
{  Licensed under the GNU Lesser General Public License, Version 3;         }
{  you may not use this file except in compliance with the License.         }
{                                                                           }
{  eInvoice4D is free software: you can redistribute it and/or modify       }
{  it under the terms of the GNU Lesser General Public License as published }
{  by the Free Software Foundation, either version 3 of the License, or     }
{  (at your option) any later version.                                      }
{                                                                           }
{  eInvoice4D is distributed in the hope that it will be useful,            }
{  but WITHOUT ANY WARRANTY; without even the implied warranty of           }
{  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the            }
{  GNU Lesser General Public License for more details.                      }
{                                                                           }
{  You should have received a copy of the GNU Lesser General Public License }
{  along with eInvoice4D.  If not, see <http://www.gnu.org/licenses/>.      }
{                                                                           }
{***************************************************************************}
unit ei4D.Response;

interface

uses ei4D.Response.Interfaces, System.Generics.Collections, System.Classes,
  ei4D.GenericCollection, ei4D.Invoice.Interfaces;

type

  TeiGenericResponse = class(TInterfacedObject, IeiResponseBase)

  end;

  TeiResponse = class(TeiGenericResponse, IeiResponse)
  private
    FFileName: string;
    FResponseDate: TDateTime;
    FResponseType: TeiResponseType;
    FNotificationDate: TDateTime;
    FMsgCode: string;
    FMsgText: string;
    FMsgRaw: string;
    FInvoice: IFatturaElettronicaType;
  protected
    // FileName
    function GetFileName: string;
    procedure SetFileName(const Value: string);
    // ResponseDate
    function GetResponseDate: TDateTime;
    procedure SetResponseDate(const AValue: TDateTime);
    // Status: stato dell'azione sulla fattura
    function GetResponseType: TeiResponseType;
    procedure SetResponseType(const AValue: TeiResponseType);
    // NotificationDate
    function GetNotificationDate: TDateTime;
    procedure SetNotificationDate(const AValue: TDateTime);
    // MsgCode
    function GetMsgCode: string;
    procedure SetMsgCode(const AValue: string);
    // MsgText
    function GetMsgText: string;
    procedure SetMsgText(const AValue: string);
    // RawResponse
    function GetMsgRaw: string;
    procedure SetMsgRaw(const AValue: string);
    // Invoice
    function GetInvoice: IFatturaElettronicaType;
    procedure SetInvoice(const AInvoice: IFatturaElettronicaType);
  end;

  TeiResponseList = TeiCollection<IeiResponse>;

implementation

uses
  System.SysUtils;

function TeiResponse.GetFileName: string;
begin
  Result := FFileName;
end;

function TeiResponse.GetResponseDate: TDateTime;
begin
  Result := FResponseDate;
end;

function TeiResponse.GetResponseType: TeiResponseType;
begin
  Result := FResponseType;
end;

function TeiResponse.GetNotificationDate: TDateTime;
begin
  Result := FNotificationDate;
end;

function TeiResponse.GetInvoice: IFatturaElettronicaType;
begin
  Result := FInvoice;
end;

function TeiResponse.GetMsgCode: string;
begin
  Result := FMsgCode;
end;

function TeiResponse.GetMsgText: string;
begin
  Result := FMsgText;
end;

function TeiResponse.GetMsgRaw: string;
begin
  Result := FMsgRaw
end;

procedure TeiResponse.SetFileName(const Value: string);
begin
  FFileName := Trim(Value);
end;

procedure TeiResponse.SetInvoice(const AInvoice: IFatturaElettronicaType);
begin
  FInvoice := AInvoice;
end;

procedure TeiResponse.SetResponseDate(const AValue: TDateTime);
begin
  FResponseDate := AValue;
end;

procedure TeiResponse.SetResponseType(const AValue: TeiResponseType);
begin
  FResponseType := AValue;
end;

procedure TeiResponse.SetNotificationDate(const AValue: TDateTime);
begin
  FNotificationDate := AValue;
end;

procedure TeiResponse.SetMsgCode(const AValue: string);
begin
  FMsgCode := AValue;
end;

procedure TeiResponse.SetMsgText(const AValue: string);
begin
  FMsgText := AValue;
end;

procedure TeiResponse.SetMsgRaw(const AValue: string);
begin
  FMsgRaw := AValue;
end;

end.
