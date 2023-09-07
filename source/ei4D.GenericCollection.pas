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
unit ei4D.GenericCollection;

interface

uses
  ei4D.GenericCollection.Interfaces, System.Generics.Collections;

type

  TeiCollection<T> = class(TInterfacedObject, IeiCollection<T>)
  private
    FCollection: TList<T>;
  protected
    procedure Clear;
    function Add(const AItem: T): Integer;
    function GetEnumerator: TEnumerator<T>;
    procedure AddRange(const Collection: IeiCollection<T>);
    procedure Delete(const AIndex: Integer);
    function Last: T;
    function IsEmpty: Boolean;
    // Count
    function GetCount: Integer;
    // Items
    procedure SetItem(Index: Integer; const AItem: T);
    function GetItem(Index: Integer): T;
  public
    constructor Create; reintroduce;
    destructor Destroy; override;
  end;

implementation

{ TeiCollection<T> }

function TeiCollection<T>.Add(const AItem: T): Integer;
begin
  FCollection.Add(AItem);
end;

procedure TeiCollection<T>.AddRange(const Collection: IeiCollection<T>);
var
  LItem: T;
begin
  for LItem in Collection do
    FCollection.Add(LItem);
end;

procedure TeiCollection<T>.Clear;
begin
  FCollection.Clear;
end;

constructor TeiCollection<T>.Create;
begin
  inherited;
  FCollection := TList<T>.Create;
end;

procedure TeiCollection<T>.Delete(const AIndex: Integer);
begin
  FCollection.Delete(AIndex);
end;

destructor TeiCollection<T>.Destroy;
begin
  FCollection.Free;
  inherited;
end;

function TeiCollection<T>.GetCount: Integer;
begin
  Result := FCollection.Count;
end;

function TeiCollection<T>.GetEnumerator: TEnumerator<T>;
begin
  Result := FCollection.GetEnumerator;
end;

function TeiCollection<T>.GetItem(Index: Integer): T;
begin
  Result := FCollection.Items[Index];
end;

function TeiCollection<T>.IsEmpty: Boolean;
begin
  Result := GetCount = 0;
end;

function TeiCollection<T>.Last: T;
begin
  Result := FCollection.Last;
end;

procedure TeiCollection<T>.SetItem(Index: Integer; const AItem: T);
begin
  FCollection.Items[Index] := AItem;
end;

end.
