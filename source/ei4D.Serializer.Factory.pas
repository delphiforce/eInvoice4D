unit ei4D.Serializer.Factory;

interface

uses
  ei4D.Serializer.Interfaces;

type

  TeiSerializerFactory = class
  public
    class function NewSerializer: IeiSerializer;
  end;

implementation

uses
  ei4D.Serializer;

{ TeiSerializerFactory }

class function TeiSerializerFactory.NewSerializer: IeiSerializer;
begin
  Result := TeiSerializerXML.Create;
end;

end.
