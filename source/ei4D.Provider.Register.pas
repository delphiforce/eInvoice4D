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
unit ei4D.Provider.Register;

interface

uses System.Generics.Collections, ei4D.Provider.Interfaces, ei4D.Provider.Base,
  System.Classes, ei4D;

type

  TeiProviderRegisterItem = class;

  TeiProviderRegister = class
  private
    class var FContainer: TObjectDictionary<String, TeiProviderRegisterItem>;
    class procedure Build;
    class procedure CleanUp;
  public
    class procedure ProvidersAsStrings(const AStrings: TStrings); overload;
    class function ProvidersAsStrings: TStrings; overload;
    class function NewProviderInstance(const AParams: IeiParams): IeiProvider;
    class procedure RegisterProviderClass<T: TeiProviderBase>(const AProviderID: String; const APredefinedBaseUrlWS: String = ''; const APredefinedBaseUrlAuth: String = '');
  end;

  TeiProviderRegisterItem = class
  strict private
    FProviderClassRef: TeiProviderClassRef;
    FPredefinedBaseUrlWS: String;
    FPredefinedBaseUrlAuth: String;
  strict protected
    procedure SetPredefinedBaseUrlAuth(const Value: String);
    procedure SetPredefinedBaseUrlWS(const Value: String);
  protected
    property ProviderClassRef: TeiProviderClassRef read FProviderClassRef write FProviderClassRef;
    property PredefinedBaseUrlWS: String read FPredefinedBaseUrlWS write SetPredefinedBaseUrlWS;
    property PredefinedBaseUrlAuth: String read FPredefinedBaseUrlAuth write SetPredefinedBaseUrlAuth;
  public
    constructor Create(const AProviderClassRef: TeiProviderClassRef; const APredefinedBaseUrlWS, APredefinedBaseUrlAuth: String);
  end;

implementation

uses ei4D.Exception, System.SysUtils;

{ TeiProviderContainer }

class procedure TeiProviderRegister.Build;
begin
  FContainer := TObjectDictionary<String, TeiProviderRegisterItem>.Create([doOwnsValues]);;
end;

class procedure TeiProviderRegister.CleanUp;
begin
  FContainer.Free;
end;

class function TeiProviderRegister.NewProviderInstance(const AParams: IeiParams): IeiProvider;
var
  LProviderRegisterItem: TeiProviderRegisterItem;
begin
  // Find the provider
  if not FContainer.ContainsKey(AParams.Provider.ID) then
    raise eiGenericException.Create(Format('Provider "%s" is not registered', [AParams.Provider.ID]));
  LProviderRegisterItem := FContainer.Items[AParams.Provider.ID];
  // Check params for provider predefined values (BaseUrlWS/Auth)
  AParams.Provider.CheckPredefinedValues(LProviderRegisterItem.PredefinedBaseUrlAuth, LProviderRegisterItem.PredefinedBaseUrlWS);
  // Build the provider instance
  Result := LProviderRegisterItem.ProviderClassRef.Create(AParams);
end;

class procedure TeiProviderRegister.ProvidersAsStrings(const AStrings: TStrings);
var
  LStr: String;
begin
  if not Assigned(AStrings) then
    raise eiGenericException.Create('TeiProviderRegister.ProvidersAsStrings: parameter not assigned');
  for LStr in FContainer.Keys do
    AStrings.Add(LStr);
end;

class function TeiProviderRegister.ProvidersAsStrings: TStrings;
begin
  Result := TStringList.Create;
  ProvidersAsStrings(Result);
end;

class procedure TeiProviderRegister.RegisterProviderClass<T>(const AProviderID, APredefinedBaseUrlWS, APredefinedBaseUrlAuth: String);
begin
  if FContainer.ContainsKey(AProviderID) then
    raise eiGenericException.Create(Format('Provider "%s" already registered', [AProviderID]));
  FContainer.Add(AProviderID, TeiProviderRegisterItem.Create(T, APredefinedBaseUrlWS, APredefinedBaseUrlAuth));
end;

{ TeiProviderRegisterItem }

constructor TeiProviderRegisterItem.Create(const AProviderClassRef: TeiProviderClassRef; const APredefinedBaseUrlWS, APredefinedBaseUrlAuth: String);
begin
  FProviderClassRef := AProviderClassRef;
  FPredefinedBaseUrlWS := APredefinedBaseUrlWS.Trim;
  FPredefinedBaseUrlAuth := APredefinedBaseUrlAuth.Trim;
end;

procedure TeiProviderRegisterItem.SetPredefinedBaseUrlAuth(const Value: String);
begin
  if not Value.Trim.IsEmpty then
    FPredefinedBaseUrlAuth := Value.Trim;
end;

procedure TeiProviderRegisterItem.SetPredefinedBaseUrlWS(const Value: String);
begin
  if not Value.Trim.IsEmpty then
    FPredefinedBaseUrlWS := Value.Trim;
end;

initialization
  TeiProviderRegister.Build;

finalization
  TeiProviderRegister.CleanUp;

end.
