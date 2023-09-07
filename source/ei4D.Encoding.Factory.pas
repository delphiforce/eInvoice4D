unit ei4D.Encoding.Factory;

interface

uses
  System.Classes, System.SysUtils;

type

  TeiEncodingFactory = class
  public
    class function GetEncoding(const AStream: TStream): TEncoding;
  end;

implementation

uses
  ei4D.Encoding;

{ TeiEncodingFactory }

class function TeiEncodingFactory.GetEncoding(const AStream: TStream): TEncoding;
var
  LStringStream: TStringStream;
begin
  LStringStream := TStringStream.Create;
  try
    AStream.Position := 0;
    LStringStream.CopyFrom(AStream, 1024);
    if LStringStream.DataString.ToLower.Contains('windows-1252') then
      Result := TEncoding.GetEncoding(1252)
    else
      Result := TeiUTFEncodingWithoutBOM.Create;
  finally
    LStringStream.Free;
  end;
end;

end.
