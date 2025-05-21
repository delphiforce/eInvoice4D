unit ei4D.Validators.XSD;

interface

uses
  ei4D.Validators.Interfaces, ei4D.Invoice.Prop.Interfaces, ei4D;

type

  TeiXsdValidator = class(TeiCustomValidator)
  private
    class procedure ValidateProp(const AProp: IeiBaseProperty; const AResult: IeiValidationResultCollection);
  public
    class procedure Validate(const AInvoice: IFatturaElettronicaType; const AResult: IeiValidationResultCollection); override;
  end;

implementation

uses
  System.SysUtils, System.RegularExpressions, ei4D.Validators.Factory;

{ TeiXsdValidator }

class procedure TeiXsdValidator.Validate(const AInvoice: IFatturaElettronicaType; const AResult: IeiValidationResultCollection);
begin
  ValidateProp(AInvoice, AResult);
end;

class procedure TeiXsdValidator.ValidateProp(const AProp: IeiBaseProperty; const AResult: IeiValidationResultCollection);
var
  LProp: IeiBaseProperty;
begin
  if AProp.Kind = pkValue then
  begin
    if (not AProp.RegEx.IsEmpty) and (not AProp.IsEmptyOrZero) and (not TRegEx.IsMatch(AProp.ValueAsString, AProp.RegEx)) then
      AResult.Add(TeiValidatorsFactory.NewValidationResult(AProp.FullQualifiedName, String.Empty,
        Format('Valore "%s" non valido', [AProp.ValueAsString]), vkXSD));
  end
  else
    if (AProp.Kind = pkList) or not AProp.IsNull then
      for LProp in (AProp as IeiComplexProperty) do
        ValidateProp(LProp, AResult); // Recursion
end;

end.
