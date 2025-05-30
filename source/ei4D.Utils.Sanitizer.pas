unit ei4D.Utils.Sanitizer;

interface

uses
  System.SysUtils;

type

  TeiSanificationType = (stUppercase, stNoSpaces);
  TeiSanificationTypeSet = set of TeiSanificationType;

  TeiSanitizer = class
  private
    class procedure _ForEachXMLValue(var AXMLText: string; const AFunc: TFunc<string, string>);
    class procedure _InternalSanitizeNameSpaces(var AXMLText: string);
    class procedure _InternalSanitizeAttributes(var AXMLText: string);
    class procedure _InternalSanitizeProlog(var AXMLText: string);
    class procedure _InternalSanitizeTagComments(var AXMLText: string);
    class procedure _InternalSanitizeCDATA(var AXMLText: string);
    class procedure _InternalSanitizeHtmlTags(var AXMLText: string);
    class procedure _InternalSanitizeSignature(var AXMLText: string);
    class procedure _InternalSanitizeCharInsideTags(var AXMLText: string; const AChar: Char);
    class procedure _InternalSanitizeCharAfterTags(var AXMLText: string; const AChar: Char);
    class procedure _InternalSanitizeByTag(var AXMLText: string; const ATag: string; const ASanificationType: TeiSanificationTypeSet);
    class function _InternalToAmpersand(const AXMLValue: string): string;
  public
    class procedure SanitizeToSendXML(var AXMLText: string);
    class function SanitizeReceivedXML(AXMLText: string): string;
    class procedure SanitizeJSON(var AJSONText: string);
    class procedure SanitizeJSONInvoiceNumberEscapeChar(var AJSONText: string);
  end;

implementation

uses System.StrUtils, System.Classes, System.Character, ei4D.Exception,
  ei4D.Utils;

{ TeiSanitizer }

class procedure TeiSanitizer._InternalSanitizeByTag(var AXMLText: string; const ATag: string; const ASanificationType: TeiSanificationTypeSet);
var
  LFromPos: integer;

  function _NestedSanitizeByTag(var AXMLText: string; const ATag: string;
    const ASanificationType: TeiSanificationTypeSet; const AFromPos: integer): integer;
  var
    LStartTag, LEndTag: string;
    LStartTagPos, LEndTagPos, LLength: integer;
    LToSanitize, LSanitized: string;
  begin
    LStartTag := '<' + ATag + '>';
    LEndTag := '</' + ATag + '>';

    LStartTagPos := PosEx(LStartTag, AXMLText, AFromPos);
    LEndTagPos := PosEx(LEndTag, AXMLText, LStartTagPos);

    if (LStartTagPos <> 0) and (LEndTagPos <> 0) then
    begin
      LStartTagPos := LStartTagPos + Length(LStartTag);
      LLength := LEndTagPos - LStartTagPos;
      // Uppercase
      if stUppercase in ASanificationType then
      begin
        LToSanitize := Copy(AXMLText, LStartTagPos, LLength);
        LSanitized := UpperCase(LToSanitize);
        AXMLText := StuffString(AXMLText, LStartTagPos, LLength, LSanitized);
      end;
      // NoSpaces
      if stNoSpaces in ASanificationType then
      begin
        LToSanitize := Copy(AXMLText, LStartTagPos, LLength);
        LSanitized := StringReplace(LToSanitize, ' ', '', [rfReplaceAll]);
        // AXMLText := StringReplace(AXMLText, LToSanitize, LSanitized, [rfReplaceAll]);
        AXMLText := StuffString(AXMLText, LStartTagPos, LLength, LSanitized);
      end;
      // Set the result
      Result := LStartTagPos + Length(LStartTag);
    end
    else
      Result := 0;
  end;

begin
  LFromPos := 1;
  while LFromPos <> 0 do
    LFromPos := _NestedSanitizeByTag(AXMLText, ATag, ASanificationType, LFromPos);
end;

class procedure TeiSanitizer.SanitizeToSendXML(var AXMLText: string);
begin
  _ForEachXMLValue(AXMLText,
    function(AValue: string): string
    begin
      Result := _InternalToAmpersand(AValue);
    end);
  _InternalSanitizeByTag(AXMLText, 'CodiceDestinatario', [stUppercase, stNoSpaces]);
  _InternalSanitizeByTag(AXMLText, 'IdPaese', [stUppercase]);
  _InternalSanitizeByTag(AXMLText, 'IdCodice', [stUppercase, stNoSpaces]);
  _InternalSanitizeByTag(AXMLText, 'Ufficio', [stUppercase]);
  _InternalSanitizeByTag(AXMLText, 'ProvinciaAlbo', [stUppercase]);
  _InternalSanitizeByTag(AXMLText, 'Provincia', [stUppercase]);
  _InternalSanitizeByTag(AXMLText, 'Nazione', [stUppercase, stNoSpaces]);
  _InternalSanitizeByTag(AXMLText, 'CodiceFiscale', [stUppercase, stNoSpaces]);
  _InternalSanitizeByTag(AXMLText, 'IBAN', [stUppercase, stNoSpaces]);
end;

class procedure TeiSanitizer.SanitizeJSON(var AJSONText: string);
const
  ESCAPE = '\';
  // QUOTATION_MARK = '"';
  REVERSE_SOLIDUS = '\';
  SOLIDUS = '/';
  BACKSPACE = #8;
  FORM_FEED = #12;
  NEW_LINE = #10;
  CARRIAGE_RETURN = #13;
  HORIZONTAL_TAB = #9;
var
  LResult: string;
  LChar: Char;
begin
  LResult := '';
  for LChar in AJSONText do
  begin
    case LChar of
      // !! Double quote (") is handled by TJSONString
      // QUOTATION_MARK: Result := Result + ESCAPE + QUOTATION_MARK;
      REVERSE_SOLIDUS:
        LResult := LResult + ESCAPE + REVERSE_SOLIDUS;
      SOLIDUS:
        LResult := LResult + ESCAPE + SOLIDUS;
      BACKSPACE:
        LResult := LResult + ESCAPE + 'b';
      FORM_FEED:
        LResult := LResult + ESCAPE + 'f';
      NEW_LINE:
        LResult := LResult + ESCAPE + 'n';
      CARRIAGE_RETURN:
        LResult := LResult + ESCAPE + 'r';
      HORIZONTAL_TAB:
        LResult := LResult + ESCAPE + 't';
    else
      begin
        if (integer(LChar) < 32) or (integer(LChar) > 126) then
          LResult := LResult + ESCAPE + 'u' + IntToHex(integer(LChar), 4)
        else
          LResult := LResult + LChar;
      end;
    end;
  end;
  AJSONText := LResult;
end;

class procedure TeiSanitizer._InternalSanitizeNameSpaces(var AXMLText: string);
var
  LTagBegin, LTagEnd, LColonPos, LSpacePos: integer;
begin
  // Loop for all tags
  LTagBegin := Pos('<', AXMLText);
  while LTagBegin > 0 do
  begin
    LTagEnd := PosEx('>', AXMLText, LTagBegin);
    LColonPos := PosEx(':', AXMLText, LTagBegin);
    LSpacePos := PosEx(' ', AXMLText, LTagBegin);
    if AXMLText[LTagBegin + 1] = '/' then
      Inc(LTagBegin);
    if LSpacePos = 0 then
      LSpacePos := Length(AXMLText);
    if (LTagEnd > 0) and (LColonPos > 0) and (LColonPos < LTagEnd) and (LColonPos < LSpacePos) then
      Delete(AXMLText, LTagBegin + 1, LColonPos - LTagBegin);
    // Next tag
    LTagBegin := PosEx('<', AXMLText, LTagBegin + 1);
  end;
end;

class procedure TeiSanitizer._InternalSanitizeCDATA(var AXMLText: string);
const
  CDATA_BEGIN = '<![CDATA[';
  CDATA_END = ']]>';
var
  LTagBegin, LTagEnd, LValueLength: integer;
  LValue: String;
begin
  // Loop for all stylesheet tags
  LTagBegin := Pos(CDATA_BEGIN, AXMLText);
  while LTagBegin > 0 do
  begin
    // Remove CDATA begin part
    Delete(AXMLText, LTagBegin, Length(CDATA_BEGIN));
    // Search the EndPart of CDATA
    LTagEnd := PosEx(CDATA_END, AXMLText, LTagBegin);
    if LTagEnd > 0 then
    begin
      // Sanitize value inside the CDATA
      LTagEnd := PosEx(CDATA_END, AXMLText, LTagBegin);
      LValueLength := LTagEnd - LTagBegin;
      LValue := Copy(AXMLText, LTagBegin, LValueLength);
      LValue := _InternalToAmpersand(LValue);
      AXMLText := StuffString(AXMLText, LTagBegin, LValueLength, LValue);
      // Search the EndPart of CDATA again
      LTagEnd := PosEx(CDATA_END, AXMLText, LTagBegin);
      if LTagEnd > 0 then
        Delete(AXMLText, LTagEnd, Length(CDATA_END));
    end;
    // Next
    LTagBegin := Pos(CDATA_BEGIN, AXMLText);
  end;
end;
// class procedure TeiSanitizer._InternalSanitizeCDATA(var AXMLText: string);
// const
// CDATA_BEGIN = '<![CDATA[';
// CDATA_END = ']]>';
// var
// LTagBegin, LTagEnd: integer;
// begin
// // Loop for all stylesheet tags
// LTagBegin := Pos(CDATA_BEGIN, AXMLText);
// while LTagBegin > 0 do
// begin
// // Remove CDATA begin part
// Delete(AXMLText, LTagBegin, Length(CDATA_BEGIN));
// // Search the EndPart of CDATA and delete it
// LTagEnd := PosEx(CDATA_END, AXMLText, LTagBegin);
// if LTagEnd > 0 then
// Delete(AXMLText, LTagEnd, Length(CDATA_END));
// // Next
// LTagBegin := Pos(CDATA_BEGIN, AXMLText);
// end;
// end;

class procedure TeiSanitizer._InternalSanitizeCharAfterTags(var AXMLText: string; const AChar: Char);
var
  LTagEnd: integer;
begin
  // Loop for all tags
  LTagEnd := Pos('>', AXMLText);
  while (LTagEnd > 0) and (LTagEnd < AXMLText.Length) do
  begin
    while AXMLText[LTagEnd + 1] = AChar do
      Delete(AXMLText, LTagEnd + 1, 1);
    // Next tag
    LTagEnd := PosEx('>', AXMLText, LTagEnd + 1);
  end;
end;

class procedure TeiSanitizer._InternalSanitizeCharInsideTags(var AXMLText: string; const AChar: Char);
var
  LTagBegin, LNextTagBegin, LTagEnd, LTagLength: integer;
  LTag: String;
begin
  // Loop for all tags
  LTagBegin := Pos('<', AXMLText);
  while LTagBegin > 0 do
  begin
    LTagEnd := PosEx('>', AXMLText, LTagBegin);
    // NB: Individua il prossimo TagBegin e se questo � all'interno dell'intervallo
    // tra LTagBegin e LTagEnd (� dentro il presunto "tag" che stiamo elaborando)
    // in realt� significa che quello che stiamo considerando LTagBegin � un carattere
    // "<" che non � l'inizio di un tag bens� � all'nterno di un "valore" quindi lo salta
    // e passa al prossimo.
    LNextTagBegin := PosEx('<', AXMLText, LTagBegin + 1);
    if (LNextTagBegin > LTagEnd) or (LNextTagBegin = 0) then
    begin
      LTagLength := LTagEnd - LTagBegin + 1; // < e > compresi
      LTag := Copy(AXMLText, LTagBegin, LTagLength);
      LTag := StringReplace(LTag, AChar, ' ', [rfReplaceAll, rfIgnoreCase]);
      AXMLText := StuffString(AXMLText, LTagBegin, LTagLength, LTag);
    end;
    // Next tag
    LTagBegin := PosEx('<', AXMLText, LTagBegin + 1);
  end;
end;

class procedure TeiSanitizer._InternalSanitizeHtmlTags(var AXMLText: string);
const
  HTML_TAGS = '<br>;<p>;</p>;<span>;</span>;<details>;</details>;<h1>;</h1>;<h2>;</h2>;<h3>;</h3>;<h4>;</h4>;<h5>;</h5>;<h6>;</h6>;' +
    '<b>;</b>;<em>;</em>;<i>;</i>;<pre>;</pre>;<small>;</small>;<strong>;</strong>;<sub>;</sub>;<sup>;</sup>';
var
  LTagList: TStringList;
  LTag: String;
begin
  LTagList := TStringList.Create;
  try
    LTagList.Delimiter := ';';
    LTagList.DelimitedText := HTML_TAGS;
    for LTag in LTagList do
      AXMLText := StringReplace(AXMLText, LTag, '', [rfReplaceAll, rfIgnoreCase]);
  finally
    LTagList.Free;
  end;
end;

class procedure TeiSanitizer.SanitizeJSONInvoiceNumberEscapeChar(var AJSONText: string);
const
  NUMBER_BEGIN = '"number":"';
var
  LTagBegin, LTagEnd, LTagLength: integer;
  LValue: String;
begin
  // Loop for all stylesheet tags
  LTagBegin := Pos(NUMBER_BEGIN, AJSONText);
  while LTagBegin > 0 do
  begin
    Inc(LTagBegin, Length(NUMBER_BEGIN));
    LTagEnd := PosEx('",', AJSONText, LTagBegin);
    LTagLength := LTagEnd - LTagBegin;
    LValue := Copy(AJSONText, LTagBegin, LTagLength);
    LValue := StringReplace(LValue, '\', '\\', [rfReplaceAll]);
    AJSONText := StuffString(AJSONText, LTagBegin, LTagLength, LValue);
    // Next one
    LTagBegin := PosEx(NUMBER_BEGIN, AJSONText, LTagEnd);
  end;
end;

class procedure TeiSanitizer._InternalSanitizeTagComments(var AXMLText: string);
var
  LTagBegin, LTagEnd, LTagLength: integer;
begin
  // Loop for all stylesheet tags
  LTagBegin := Pos('<!--', AXMLText);
  while LTagBegin > 0 do
  begin
    LTagEnd := PosEx('-->', AXMLText, LTagBegin);
    LTagLength := LTagEnd - LTagBegin + 3; // Compresi i "<" ">"
    // Remove StyleSheet tag
    Delete(AXMLText, LTagBegin, LTagLength);
    // Remove spaces or CR or LF after the tag
    while (AXMLText[LTagBegin] = ' ') or (AXMLText[LTagBegin] = #13) or (AXMLText[LTagBegin] = #10) do
      Delete(AXMLText, LTagBegin, 1);
    // Next tag
    LTagBegin := Pos('<!--', AXMLText);
  end;
end;

class procedure TeiSanitizer._ForEachXMLValue(var AXMLText: string; const AFunc: TFunc<string, string>);
var
  LPosStart: integer;
  LPosEnd: integer;
  LStartTagName: string;
  LEndTagName: string;
  LValue: string;
begin
  LPosStart := 0;
  repeat
    LStartTagName := TeiUtils.XMLFindTag(AXMLText, LPosStart);
    if LStartTagName.StartsWith('/') and LStartTagName.EndsWith(':FatturaElettronica') then
      Break;
    if LStartTagName.StartsWith('/') or LStartTagName.EndsWith('/') then
      Continue;
    if LStartTagName.StartsWith('?xml', True) then
      Continue;
    if LStartTagName.Contains(':FatturaElettronica') then
      Continue;
    LPosEnd := LPosStart;
    LEndTagName := TeiUtils.XMLFindTag(AXMLText, LPosEnd);
    if LEndTagName.Equals('/' + LStartTagName) then
    begin
      LValue := AXMLText.Substring(LPosStart, LPosEnd - LEndTagName.Length - LPosStart - 2);
      AXMLText := StuffString(AXMLText, LPosStart + 1, LValue.Length, AFunc(LValue));
    end;
  until False;
end;

class procedure TeiSanitizer._InternalSanitizeAttributes(var AXMLText: string);
var
  LTagBegin, LTagEnd, LSpacePos: integer;
begin
  // Loop for all tags
  LTagBegin := Pos('<', AXMLText);
  while LTagBegin > 0 do
  begin
    LTagEnd := PosEx('>', AXMLText, LTagBegin);
    LSpacePos := PosEx(' ', AXMLText, LTagBegin);
    if (LTagEnd > 0) and (LSpacePos > 0) and (LSpacePos < LTagEnd) and (AXMLText[LTagBegin + 1] <> '?') and (AXMLText[LTagEnd - 1] <> '/')
    then
      Delete(AXMLText, LSpacePos, LTagEnd - LSpacePos);
    // Next tag
    LTagBegin := PosEx('<', AXMLText, LTagBegin + 1);
  end;
end;

class procedure TeiSanitizer._InternalSanitizeProlog(var AXMLText: string);
var
  LStartPos, LEndPos, LLength: integer;
begin
  // Loop for all prologs
  LStartPos := Pos('<?', AXMLText);
  while LStartPos > 0 do
  begin
    LEndPos := PosEx('?>', AXMLText, LStartPos);
    LLength := LEndPos - LStartPos + 2; // Compresi i "<?" "?>"
    // Remove current prolog
    Delete(AXMLText, LStartPos, LLength);
    // Remove spaces or CR or LF after the tag
    while (AXMLText[LStartPos] = ' ') or (AXMLText[LStartPos] = #13) or (AXMLText[LStartPos] = #10) do
      Delete(AXMLText, LStartPos, 1);
    // Search next prolog
    LStartPos := Pos('<?', AXMLText);
  end;
end;

class procedure TeiSanitizer._InternalSanitizeSignature(var AXMLText: string);
const
  PREVIUS_TAG = '</FatturaElettronicaBody>';
  NEXT_TAG = '</FatturaElettronica>';
var
  LXadesBegin, LXadesEnd, LXadesLength: integer;
begin
  LXadesBegin := Pos(PREVIUS_TAG, AXMLText);
  LXadesEnd := Pos(NEXT_TAG, AXMLText);
  if (LXadesBegin = 0) or (LXadesEnd = 0) then
    Exit;
  Inc(LXadesBegin, Length(PREVIUS_TAG));
  LXadesLength := LXadesEnd - LXadesBegin;
  Delete(AXMLText, LXadesBegin, LXadesLength);
end;

class function TeiSanitizer._InternalToAmpersand(const AXMLValue: string): string;
var
  I: integer;
  O: integer;
begin
  // TODO: subordinare ad un ciclo che faccia la conversione solo dei valori nei tags (ora converte anche i TAG!)
  Result := '';
  if AXMLValue = '' then
    Exit;
  for I := 1 to Length(AXMLValue) do
  begin
    O := System.Character.TCharacter.ConvertToUtf32(AXMLValue, I);
    case O of
      { * FCM INIT 2019.01.23 - special char* }
      0 .. 9:
        Result := Result + ' ';
      10:
        Result := Result + AXMLValue[I];
      11 .. 12:
        Result := Result + ' ';
      13:
        Result := Result + AXMLValue[I];
      14 .. 32:
        Result := Result + ' ';
      39 .. 59:
        Result := Result + AXMLValue[I];
      61:
        Result := Result + AXMLValue[I];
      63 .. 126:
        Result := Result + AXMLValue[I];
      { * FCM END 2019.01.23 - special char* }
    else
      Result := Result + '&#' + IntToStr(O) + ';';
    end;
  end;
end;

class function TeiSanitizer.SanitizeReceivedXML(AXMLText: string): string;
begin
  _InternalSanitizeCharInsideTags(AXMLText, #13);
  _InternalSanitizeCharInsideTags(AXMLText, #10);
  _InternalSanitizeCharInsideTags(AXMLText, #9);
  _InternalSanitizeCDATA(AXMLText);
  _InternalSanitizeTagComments(AXMLText);
  _InternalSanitizeHtmlTags(AXMLText);
  _InternalSanitizeProlog(AXMLText);
  _InternalSanitizeNameSpaces(AXMLText);
  _InternalSanitizeAttributes(AXMLText);
  // _InternalSanitizeCharInsideTags(AXMLText, #13);
  // _InternalSanitizeCharInsideTags(AXMLText, #10);
  // _InternalSanitizeCharInsideTags(AXMLText, #9);
  _InternalSanitizeCharAfterTags(AXMLText, ' ');
  _InternalSanitizeSignature(AXMLText);
  Result := AXMLText;
end;

end.
