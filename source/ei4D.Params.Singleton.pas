unit ei4D.Params.Singleton;

interface

uses
  ei4D.Params.Interfaces;

type

  TeiParamsSingleton = class
  private
    class var FParams: IeiParams;
  public
    class constructor Create;
    class function GetInstance: IeiParams;
    class procedure CheckParams(var AParams: IeiParams);
  end;

implementation

uses
  ei4D.Params.Factory;

{ TeiParamsSingleton }

class constructor TeiParamsSingleton.Create;
begin
  FParams := nil;
end;

class function TeiParamsSingleton.GetInstance: IeiParams;
begin
  if not Assigned(FParams) then
    FParams := TeiParamsFactory.NewParams;
  Result := FParams;
end;

class procedure TeiParamsSingleton.CheckParams(var AParams: IeiParams);
begin
  if not Assigned(AParams) then
    AParams := GetInstance;
end;

end.
