unit ei4D.Serializer.Interfaces;

interface

uses
  ei4D.Invoice.Interfaces;

type

  IeiSerializer = interface
    ['{B4AA6E41-3B69-40EC-8083-C3FCB784DC76}']
    function ToXML(const AInvoice: IFatturaElettronicaType): String;
    procedure FromXML(const AInvoice: IFatturaElettronicaType; const AXMLText: String);
  end;

implementation

end.
