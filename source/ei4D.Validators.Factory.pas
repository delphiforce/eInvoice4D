unit ei4D.Validators.Factory;

interface

uses
  ei4D.Validators.Interfaces;

type

  TeiValidatorsFactory = class
  public
    class function NewValidatorsResultCollection: IeiValidatorsResultCollection;
    class function NewValidatorsResult(const APropertyInfo, AErrorCode, AErrorMessage: string; const AValidatorKind: TeiValidatorKind): IeiValidatorsResult;
  end;

implementation

uses
  ei4D.Validators.ValidatorsResult;

{ TeiValidatorsFactory }

class function TeiValidatorsFactory.NewValidatorsResult(const APropertyInfo, AErrorCode, AErrorMessage: string; const AValidatorKind: TeiValidatorKind): IeiValidatorsResult;
begin
  result := TeiValidatorsResult.Create(APropertyInfo, AErrorCode, AErrorMessage, AValidatorKind);
end;

class function TeiValidatorsFactory.NewValidatorsResultCollection: IeiValidatorsResultCollection;
begin
  result := TeiValidatorsResultCollection.Create;
end;

end.
