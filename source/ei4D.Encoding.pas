unit ei4D.Encoding;

interface

uses
  System.SysUtils;

type

  TeiUTFEncodingWithoutBOM = class(TUTF8Encoding)
  private
    class var FUTF8WithoutBOM: TEncoding;
  public
    function GetPreamble: TBytes; override;
    class function GetUTF8WithoutBOM: TEncoding; static;
  end;

implementation

{ TeiUTFEncodingWithoutBOM }

function TeiUTFEncodingWithoutBOM.GetPreamble: TBytes;
begin
//  Result := TBytes.Create($EF, $BB, $BF); // original code
  Result := TBytes.Create(); // Without BOM
end;

class function TeiUTFEncodingWithoutBOM.GetUTF8WithoutBOM: TEncoding;
var
  LEncoding: TEncoding;
begin
  if FUTF8WithoutBOM = nil then
  begin
    LEncoding := TeiUTFEncodingWithoutBOM.Create;
    if AtomicCmpExchange(Pointer(FUTF8WithoutBOM), Pointer(LEncoding), nil) <> nil then
      LEncoding.Free
{$IFDEF AUTOREFCOUNT}
    else
      FUTF8WithoutBOM.__ObjAddRef
{$ENDIF AUTOREFCOUNT};
  end;
  Result := FUTF8WithoutBOM;
end;

initialization

finalization
  FreeAndNil(TeiUTFEncodingWithoutBOM.FUTF8WithoutBOM);

end.
