unit ei4D.Validators.Notary;

interface

type

  TeiVaildatorsNotary = class
  public
    class procedure BuildValidatorsRegister;
  end;

implementation

uses
  ei4D.Validators.Register, ei4D.Validators.Core, ei4D.Validators.Interfaces, ei4D.Validators.XSD,
  ei4D.Validators.ExtraXSD;

{ TeiVaildatorsNotary }

class procedure TeiVaildatorsNotary.BuildValidatorsRegister;
begin
  TeiValidatorRegister.RegisterValidator(TeiCoreValidator, vkCore);
  TeiValidatorRegister.RegisterValidator(TeiXsdValidator, vkXSD);
  TeiValidatorRegister.RegisterValidator(TeiExtraXsdValidator, vkExtraXSD);
end;

end.
