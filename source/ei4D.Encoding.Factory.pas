unit ei4D.Encoding.Factory;

interface

uses
  System.Classes, System.SysUtils;

type

  TeiEncodingFactory = class
  public
    class function GetEncoding(const AStream: TStream): TEncoding; overload;
    class function GetEncoding(const ABase64String: string): TEncoding; overload;
  end;

implementation

uses
  System.Math, System.NetEncoding, System.RegularExpressions,
  ei4D.Encoding;

{ TeiEncodingFactory }

class function TeiEncodingFactory.GetEncoding(const AStream: TStream): TEncoding;
var
  LBuffer: TBytes;
  LBytesToRead: Integer;
  LXmlDeclaration: string;
  LSavedPosition: Int64;
begin
  LSavedPosition := AStream.Position;
  try
    AStream.Position := 0;

    // 1. Controlla BOM (metodo piu' affidabile)
    SetLength(LBuffer, 3);
    if AStream.Read(LBuffer, 3) >= 3 then
    begin
      // UTF-8 BOM
      if (LBuffer[0] = $EF) and (LBuffer[1] = $BB) and (LBuffer[2] = $BF) then
        Exit(TEncoding.UTF8);
      // UTF-16 LE BOM
      if (LBuffer[0] = $FF) and (LBuffer[1] = $FE) then
        Exit(TEncoding.Unicode);
      // UTF-16 BE BOM
      if (LBuffer[0] = $FE) and (LBuffer[1] = $FF) then
        Exit(TEncoding.BigEndianUnicode);
    end;

    // 2. Nessun BOM, analizza la dichiarazione XML
    AStream.Position := 0;
    LBytesToRead := Min(512, AStream.Size);
    SetLength(LBuffer, LBytesToRead);
    AStream.Read(LBuffer, LBytesToRead);

    // Leggi come ASCII per trovare la dichiarazione
    LXmlDeclaration := TEncoding.ASCII.GetString(LBuffer);

    // 3. Cerca encoding con regex (gestisce spazi opzionali intorno all'uguale)
    if TRegEx.IsMatch(LXmlDeclaration, 'encoding\s*=\s*[''"]windows-1252[''"]', [roIgnoreCase]) then
      Exit(TEncoding.GetEncoding(1252))
    else if TRegEx.IsMatch(LXmlDeclaration, 'encoding\s*=\s*[''"]iso-8859-1[''"]', [roIgnoreCase]) then
      Exit(TEncoding.GetEncoding(28591))
    else if TRegEx.IsMatch(LXmlDeclaration, 'encoding\s*=\s*[''"]iso-8859-15[''"]', [roIgnoreCase]) then
      Exit(TEncoding.GetEncoding(28605));

    // 4. Default: UTF-8 senza BOM (singleton)
    Result := TeiUTFEncodingWithoutBOM.GetUTF8WithoutBOM;
  finally
    AStream.Position := LSavedPosition;
  end;
end;

class function TeiEncodingFactory.GetEncoding(const ABase64String: string): TEncoding;
var
  LBytes: TBytes;
  LStream: TBytesStream;
begin
  LBytes := TNetEncoding.Base64.DecodeStringToBytes(ABase64String);
  LStream := TBytesStream.Create(LBytes);
  try
    Result := GetEncoding(LStream);
  finally
    LStream.Free;
  end;
end;

end.
