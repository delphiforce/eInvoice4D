unit ei4D.Validators.Core;

interface

uses
  ei4D.Invoice.Interfaces, ei4D.Invoice.Prop.Interfaces,
  ei4D.Validators.Interfaces;

type

  TeiCoreValidator = class(TeiCustomValidator)
  private
    class procedure ValidateProp(const AProp: IeiBaseProperty; const AResult: IeiValidatorsResultCollection);
  public
    class procedure Validate(const AInvoice: IFatturaElettronicaType; const AResult: IeiValidatorsResultCollection); override;
  end;

implementation

uses
  ei4D.Validators.Factory, System.Math, System.SysUtils;

{ TeiCoreValidator }

class procedure TeiCoreValidator.Validate(const AInvoice: IFatturaElettronicaType; const AResult: IeiValidatorsResultCollection);
begin
  ValidateProp(AInvoice, AResult);
end;

class procedure TeiCoreValidator.ValidateProp(const AProp: IeiBaseProperty; const AResult: IeiValidatorsResultCollection);
var
  LProp: IeiBaseProperty;
begin
  case AProp.Kind of
    pkValue:
      begin
        // Occurrence
        if (AProp.Occurrence = TeiOccurrence.o11) and AProp.IsNull then
          AResult.Add(TeiValidatorsFactory.NewValidatorsResult(AProp.FullQualifiedName, String.Empty, 'Proprietà obbligatoria non valorizzata', vkCore));
        // MinLength - MaxLength
        if not AProp.IsNull and (AProp.MinLength > 0) and (AProp.MaxLength > 0) and not InRange(AProp.ValueAsString.Length, AProp.MinLength, AProp.MaxLength)
        then
          AResult.Add(TeiValidatorsFactory.NewValidatorsResult(AProp.FullQualifiedName, String.Empty,
            Format('Lunghezza della proprietà non corretta (Min %d, Max %d)', [AProp.MinLength, AProp.MaxLength]), vkCore));
      end;
    pkBlock:
      begin
        // Occurrence
        if (AProp.Occurrence = TeiOccurrence.o11) and AProp.IsNull then
          AResult.Add(TeiValidatorsFactory.NewValidatorsResult(AProp.FullQualifiedName, String.Empty, 'Proprietà/blocco obbligatorio non presente', vkCore));
        // Recursion
        if not AProp.IsNull then
          for LProp in (AProp as IeiComplexProperty) do
            ValidateProp(LProp, AResult);
      end;
    pkList:
      begin
        // Occurrence
        if (AProp.Occurrence = TeiOccurrence.o1N) and AProp.IsEmptyOrZero then
          AResult.Add(TeiValidatorsFactory.NewValidatorsResult(AProp.FullQualifiedName, String.Empty, 'La lista deve contenere almeno un elemento', vkCore));
        // Recursion
        for LProp in (AProp as IeiComplexProperty) do
          ValidateProp(LProp, AResult);
      end;
  end;
end;

end.
