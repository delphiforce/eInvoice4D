unit ei4D.Validators.Factory;

interface

uses
  ei4D.Validators.Interfaces;

type

  TeiValidatorsFactory = class
  public
    class function NewValidationResultCollection: IeiValidationResultCollection;
    class function NewValidationResult(const APropertyInfo, AErrorCode, AErrorMessage: string; const AValidatorKind: TeiValidatorKind): IeiValidationResult;
  end;

implementation

uses
  ei4D.Validators.ValidationResult;

{ TeiValidatorsFactory }

class function TeiValidatorsFactory.NewValidationResult(const APropertyInfo, AErrorCode, AErrorMessage: string; const AValidatorKind: TeiValidatorKind): IeiValidationResult;
begin
  result := TeiValidationResult.Create(APropertyInfo, AErrorCode, AErrorMessage, AValidatorKind);
end;

class function TeiValidatorsFactory.NewValidationResultCollection: IeiValidationResultCollection;
begin
  result := TeiValidationResultCollection.Create;
end;

end.
