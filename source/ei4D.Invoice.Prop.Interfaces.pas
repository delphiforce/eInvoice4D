unit ei4D.Invoice.Prop.Interfaces;

interface

uses
  System.Generics.Collections, System.Classes;

type

  TeiPropKind = (pkUndefined, pkValue, pkBlock, pkList);
  TeiOccurrence = (oUndefined, o01, o0N, o11, o1N);

  IeiBaseProperty = interface(IInvokable)
    ['{62E253B1-834E-4DC0-86BD-D582E6FFEF02}']
    procedure Clear;
    function Decimals: Integer;
    function FullQualifiedName: String;
    function ID: String;
    function IsEmptyOrZero: Boolean;
    function IsMandatory: Boolean;
    function IsNull: Boolean;
    function Kind: TeiPropKind;
    function MaxDecimals: Integer;
    function MaxLength: Integer;
    function MinLength: Integer;
    function Name: String;
    function Occurrence: TeiOccurrence;
    function OccurrenceAsString: String;
    function QualifiedName: String;
    function RegEx: String;
    // TempData
    procedure SetTempData(const AValue: String);
    function GetTempData: String;
    property TempData: String read GetTempData write SetTempData;
    // ValueAsString property
    procedure SetValueAsString(const AValue: String);
    function GetValueAsString: String;
    property ValueAsString: String read GetValueAsString write SetValueAsString;
  end;

  IeiComplexProperty = interface(IeiBaseProperty)
    ['{416A8C47-4B66-451C-9025-FB7AEB662415}']
    function GetEnumerator: TEnumerator<IeiBaseProperty>;
  end;

  IeiBlock = interface(IeiComplexProperty)
    ['{883EC805-04A7-403B-96A7-4331854A1F57}']
    // Props property
    function GetProps(const APropName: String): IeiBaseProperty;
    property Props[const APropName: String]: IeiBaseProperty read GetProps;
  end;

  IeiList = interface(IeiComplexProperty)
    ['{71F9F872-DA90-4934-97F7-B9F44D3DA5F7}']
    function _Add: IeiBaseProperty;
  end;

  IeiList<T: IeiBaseProperty> = interface(IeiComplexProperty)
    ['{CEE209E4-5CC5-4429-B831-FA377BF6D67D}']
    function Count: Integer;
    function Add: T;
    function Last(const ACreateFirstIfEmpty: Boolean = False): T;
    // Items property
    function GetItem(Index: Integer): T;
    property Items[Index: Integer]: T read GetItem; default;
  end;

  IeiProperty<T> = interface(IeiBaseProperty)
    ['{A667DCAE-06FA-46C4-8273-B46A53FEAA96}']
    // Value
    procedure SetValue(const AValue: T);
    function GetValue: T;
    property Value: T read GetValue write SetValue;
    // ValueDef property
    function GetValueDef: T;
    property ValueDef: T read GetValueDef;
  end;

  IeiDate = interface(IeiProperty<TDate>)
    ['{2B689F47-754F-46A6-BA77-309280B5E6AB}']
    // ValueAsString
    procedure SetValueAsString(const AValue: String);
    function GetValueAsString: String;
    property ValueAsString: String read GetValueAsString write SetValueAsString;
  end;

  IeiDateTime = interface(IeiProperty<TDateTime>)
    ['{A0E9A41A-9381-436D-8567-26C02282F98B}']
    // ValueAsString
    procedure SetValueAsString(const AValue: String);
    function GetValueAsString: String;
    property ValueAsString: String read GetValueAsString write SetValueAsString;
  end;

  IeiDecimal = interface(IeiProperty<Double>)
    ['{994BFD3A-1232-49C0-9289-DAC0AC72AD00}']
    // ValueAsString
    procedure SetValueAsString(const AValue: String);
    function GetValueAsString: String;
    property ValueAsString: String read GetValueAsString write SetValueAsString;
  end;

  IeiInteger = interface(IeiProperty<Integer>)
    ['{E4AB24FC-CD6E-4274-9800-C89537049B10}']
    // ValueAsString
    procedure SetValueAsString(const AValue: String);
    function GetValueAsString: String;
    property ValueAsString: String read GetValueAsString write SetValueAsString;
  end;

  IeiString = interface(IeiProperty<String>)
    ['{E82B7999-8360-4F65-8EA8-28BDC2D6FFC4}']
    // ValueAsString
    procedure SetValueAsString(const AValue: String);
    function GetValueAsString: String;
    property ValueAsString: String read GetValueAsString write SetValueAsString;
  end;

  IeiBase64 = interface(IeiProperty<string>)
    ['{D4A6CEE9-76AA-4BCD-A6A7-3BBCF3782441}']
    procedure LoadFromStream(const AStream: TStream);
    procedure LoadFromFile(const AFileName: string);
    procedure SaveToStream(const AStream: TStream);
    procedure SaveToFile(const AFileName: string);
    function AsStream: TStream;
    // ValueAsString property
    procedure SetValueAsString(const AValue: String);
    function GetValueAsString: String;
    property ValueAsString: String read GetValueAsString write SetValueAsString;
  end;

implementation

end.
