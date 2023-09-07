unit ei4D.Params.Factory;

interface

uses
  ei4D.Params.Interfaces;

type

  TeiParamsFactory = class
  public
    class function NewParams: IeiParams;
  end;

implementation

uses
  ei4D.Params, ei4D.Params.Proxy;

{ TeiParamsFactory }

class function TeiParamsFactory.NewParams: IeiParams;
var
  LParams: IeiParams;
begin
  LParams := TeiParams.Create;
  Result := TeiProxy<IeiParams>.Create(LParams) as IeiParams;
end;

end.
