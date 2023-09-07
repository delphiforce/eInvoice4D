unit ei4D.Validators.Register;

interface

uses
  System.Generics.Collections, ei4D.Validators.Interfaces, ei4D.Invoice.Interfaces;

type

  TeiValidatorRegisterItem = class;

  TeiValidatorRegister = class
  strict private
    class var FContainer: TObjectList<TeiValidatorRegisterItem>;
    class procedure InternalValidate(const AInvoice: IFatturaElettronicaType; const AKind: TeiValidatorKind; const AResult: IeiValidatorsResultCollection);
  private
    class procedure Build;
    class procedure CleanUp;
  public
    class procedure RegisterValidator(const AValidator: TeiCustomValidatorRef; const AKind: TeiValidatorKind);
    class function Validate(const AInvoice: IFatturaElettronicaType; const AKind: TeiValidatorKind): IeiValidatorsResultCollection;
    class function ValidateAll(const AInvoice: IFatturaElettronicaType): IeiValidatorsResultCollection;
  end;

  TeiValidatorRegisterItem = class
  strict private
    FValidator: TeiCustomValidatorRef;
    FKind: TeiValidatorKind;
  public
    constructor Create(const AValidator: TeiCustomValidatorRef; const AKind: TeiValidatorKind);
    property Validator: TeiCustomValidatorRef read FValidator;
    property Kind: TeiValidatorKind read FKind;
  end;

implementation

uses
  ei4D.Validators.Factory;

{ TeiValidatorRegister }

class procedure TeiValidatorRegister.Build;
begin
  FContainer := TObjectList<TeiValidatorRegisterItem>.Create;
end;

class procedure TeiValidatorRegister.CleanUp;
begin
  FContainer.Free;
end;

class procedure TeiValidatorRegister.RegisterValidator(const AValidator: TeiCustomValidatorRef; const AKind: TeiValidatorKind);
begin
  FContainer.Add(TeiValidatorRegisterItem.Create(AValidator, AKind));
end;

class procedure TeiValidatorRegister.InternalValidate(const AInvoice: IFatturaElettronicaType; const AKind: TeiValidatorKind; const AResult: IeiValidatorsResultCollection);
var
  LValidatorRegisterItem: TeiValidatorRegisterItem;
begin
  for LValidatorRegisterItem in FContainer do
    if LValidatorRegisterItem.Kind = AKind then
      LValidatorRegisterItem.Validator.Validate(AInvoice, AResult);
end;

class function TeiValidatorRegister.Validate(const AInvoice: IFatturaElettronicaType; const AKind: TeiValidatorKind): IeiValidatorsResultCollection;
begin
  Result := TeiValidatorsFactory.NewValidatorsResultCollection;
  InternalValidate(AInvoice, AKind, Result);
end;

class function TeiValidatorRegister.ValidateAll(const AInvoice: IFatturaElettronicaType): IeiValidatorsResultCollection;
var
  LKind: TeiValidatorKind;
begin
  Result := TeiValidatorsFactory.NewValidatorsResultCollection;
  for LKind := Low(TeiValidatorKind) to High(TeiValidatorKind) do
    InternalValidate(AInvoice, LKind, Result);
end;

{ TeiValidatorRegisterItem }

constructor TeiValidatorRegisterItem.Create(const AValidator: TeiCustomValidatorRef; const AKind: TeiValidatorKind);
begin
  FValidator := AValidator;
  FKind := AKind;
end;

initialization

TeiValidatorRegister.Build;

finalization

TeiValidatorRegister.CleanUp;

end.
