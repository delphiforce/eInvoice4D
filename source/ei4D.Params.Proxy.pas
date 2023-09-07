unit ei4D.Params.Proxy;

interface

uses
  System.Rtti;

type

  TeiProxy<T: IInterface> = class(TVirtualInterface)
  private
    FInstanceAsTValue: TValue;
    procedure DoInvoke(AMethod: TRttiMethod; const Args: TArray<TValue>; out Result: TValue);
  public
    constructor Create(const AInstance: T); reintroduce;
  end;

implementation

{ TeiProxy<T> }

constructor TeiProxy<T>.Create(const AInstance: T);
begin
  inherited Create(TypeInfo(T));
  FInstanceAsTValue := TValue.From<T>(AInstance);
  OnInvoke := DoInvoke;
end;

procedure TeiProxy<T>.DoInvoke(AMethod: TRttiMethod; const Args: TArray<TValue>; out Result: TValue);
begin
  TMonitor.Enter(Self);
  try
    Result := AMethod.Invoke(FInstanceAsTValue, Copy(Args, 1, Length(Args))); // Do not consider the first element of Args
  finally
    TMonitor.Exit(Self);
  end;
end;

end.
