unit ei4D.Validators.Interfaces;

interface

uses
  ei4D.Invoice.Interfaces, ei4D.GenericCollection.Interfaces;

type

  TeiValidatorKind = (vkCore, vkXSD, vkExtraXSD);

  IeiValidationResult = interface
    ['{1122D41C-97BE-4572-9A8A-1527170294E3}']
    function ToString: string;
    function GetPropertyInfo: string;
    function GetErrorCode: string;
    function GetErrorMessage: string;
    function GetValidatorKind: TeiValidatorKind;
    property PropertyInfo: string read GetPropertyInfo;
    property ErrorCode: string read GetErrorCode;
    property ErrorMessage: string read GetErrorMessage;
    property ValidatorKind: TeiValidatorKind read GetValidatorKind;
  end;

  IeiValidationResultCollection = IeiCollection<IeiValidationResult>;

  TeiCustomValidatorRef = class of TeiCustomValidator;
  TeiCustomValidator = class abstract
  public
    class procedure Validate(const AInvoice: IFatturaElettronicaType; const AResult: IeiValidationResultCollection); virtual; abstract;
  end;

implementation

end.
