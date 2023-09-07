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
unit ei4D.Validators.ValidatorsResult;

interface

uses ei4D.Validators.Interfaces, ei4D.GenericCollection;

type

  TeiValidatorsResultCollection = TeiCollection<IeiValidatorsResult>;

  TeiValidatorsResult = class(TInterfacedObject, IeiValidatorsResult)
  private
    FPropertyInfo: string;
    FErrorCode: string;
    FErrorMessage: string;
    FValidatorKind: TeiValidatorKind;
  protected
    function GetPropertyInfo: string;
    function GetErrorCode: string;
    function GetErrorMessage: string;
    function GetValidatorKind: TeiValidatorKind;
  public
    constructor Create(const APropertyInfo, AErrorCode, AErrorMessage: string; const AValidatorKind: TeiValidatorKind);
    function ToString: string; reintroduce;
    property PropertyInfo: string read GetPropertyInfo;
    property ErrorCode: string read GetErrorCode;
    property ErrorMessage: string read GetErrorMessage;
    property ValidatorKind: TeiValidatorKind read GetValidatorKind;
  end;

implementation

uses System.SysUtils, System.TypInfo;

{ TeiValidatorsResult }

constructor TeiValidatorsResult.Create(const APropertyInfo, AErrorCode, AErrorMessage: string; const AValidatorKind: TeiValidatorKind);
begin
  inherited Create;
  FPropertyInfo := APropertyInfo;
  FErrorCode := AErrorCode;
  FErrorMessage := AErrorMessage;
  FValidatorKind := AValidatorKind;
end;

function TeiValidatorsResult.GetErrorCode: string;
begin
  result := FErrorCode;
end;

function TeiValidatorsResult.GetErrorMessage: string;
begin
  result := FErrorMessage;
end;

function TeiValidatorsResult.GetPropertyInfo: string;
begin
  result := FPropertyInfo;
end;

function TeiValidatorsResult.GetValidatorKind: TeiValidatorKind;
begin
  Result := FValidatorKind;
end;

function TeiValidatorsResult.ToString: string;
var
  LTmp: String;
begin
  LTmp := GetEnumName(TypeInfo(TeiValidatorKind), Ord(FValidatorKind));
  if not FErrorCode.IsEmpty then
    LTmp := LTmp + '-' + FErrorCode;
  Result := Format('(%s) %s: %s', [LTmp, FPropertyInfo, FErrorMessage]);
end;

end.
