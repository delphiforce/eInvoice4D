unit ei4D.Validators.ExtraXSD;

interface

uses
  ei4D.Validators.Interfaces, ei4D.Invoice.Interfaces;

// Note controlli non implementati
// 00404 duplicazione fattura
// 00409 duplicazione fattura lotto
// 00460 relativo a fattura semplificata
// 00477 non possibile controllare dichiarazione d'intento

type
  TeiExtraXsdValidator = class(TeiCustomValidator)
  private
    class function FindAliquotaIva(const AListaAliquoteIva: array of double; const AValue: double): Boolean;
    class function FindNaturaEsenzioneIva(const AListaNaturaEsenzioneIva: array of string; const AValue: string): Boolean;
    class procedure ValidateHeader(const AHeader: IFatturaElettronicaHeaderType; const AResult: IeiValidationResultCollection);
    class procedure ValidateBody(const AInvoice: IFatturaElettronicaType; const AResult: IeiValidationResultCollection);
    class procedure ValidateHeaderBody(const AInvoice: IFatturaElettronicaType; const AResult: IeiValidationResultCollection);
    // Header validators
    class procedure ValidateHeader_00417(const AHeader: IFatturaElettronicaHeaderType; const AResult: IeiValidationResultCollection);
    // in data 22/12/23 (controllo 00426) Maurizio e Thomas verificata eliminazione del controllo: deve essere possibile inviare fattura senza codice destinatario e Pec (privati)
    class procedure ValidateHeader_00426(const AHeader: IFatturaElettronicaHeaderType; const AResult: IeiValidationResultCollection);
    class procedure ValidateHeader_00427(const AHeader: IFatturaElettronicaHeaderType; const AResult: IeiValidationResultCollection);
    class procedure ValidateHeader_00476(const AHeader: IFatturaElettronicaHeaderType; const AResult: IeiValidationResultCollection);
    { TODO : Implementare ? (controllo autofattura soggetti uguali TD non autofattura) }
    // class procedure ValidateHeader_Autofattura
    // Body validators
    class procedure ValidateBody_00400_00401(const ABody: IFatturaElettronicaBodyType; const AResult: IeiValidationResultCollection);
    class procedure ValidateBody_00411(const ABody: IFatturaElettronicaBodyType; const AResult: IeiValidationResultCollection);
    class procedure ValidateBody_00413_00414(const ABody: IFatturaElettronicaBodyType; const AResult: IeiValidationResultCollection);
    class procedure ValidateBody_00415(const ABody: IFatturaElettronicaBodyType; const AResult: IeiValidationResultCollection);
    class procedure ValidateBody_00418(const ABody: IFatturaElettronicaBodyType; const AResult: IeiValidationResultCollection);
    class procedure ValidateBody_00419(const ABody: IFatturaElettronicaBodyType; const AResult: IeiValidationResultCollection);
    class procedure ValidateBody_00420(const ABody: IFatturaElettronicaBodyType; const AResult: IeiValidationResultCollection);
    class procedure ValidateBody_00421(const ABody: IFatturaElettronicaBodyType; const AResult: IeiValidationResultCollection);
    class procedure ValidateBody_00422(const ABody: IFatturaElettronicaBodyType; const AResult: IeiValidationResultCollection);
    class procedure ValidateBody_00423(const ABody: IFatturaElettronicaBodyType; const AResult: IeiValidationResultCollection);
    class procedure ValidateBody_00424(const ABody: IFatturaElettronicaBodyType; const AResult: IeiValidationResultCollection);
    class procedure ValidateBody_00425(const ABody: IFatturaElettronicaBodyType; const AResult: IeiValidationResultCollection);
    class procedure ValidateBody_00429_00430(const ABody: IFatturaElettronicaBodyType; const AResult: IeiValidationResultCollection);
    class procedure ValidateBody_00437_00438(const ABody: IFatturaElettronicaBodyType; const AResult: IeiValidationResultCollection);
    class procedure ValidateBody_00443(const ABody: IFatturaElettronicaBodyType; const AResult: IeiValidationResultCollection);
    class procedure ValidateBody_00444(const ABody: IFatturaElettronicaBodyType; const AResult: IeiValidationResultCollection);
    class procedure ValidateBody_00445(const ABody: IFatturaElettronicaBodyType; const AResult: IeiValidationResultCollection);
    class procedure ValidateBody_00474(const ABody: IFatturaElettronicaBodyType; const AResult: IeiValidationResultCollection);
    // Both Header and Body involved
    class procedure ValidateHeaderBody_00471(const AHeader: IFatturaElettronicaHeaderType; const ABody: IFatturaElettronicaBodyType;
      const AResult: IeiValidationResultCollection);
    class procedure ValidateHeaderBody_00472(const AHeader: IFatturaElettronicaHeaderType; const ABody: IFatturaElettronicaBodyType;
      const AResult: IeiValidationResultCollection);
    class procedure ValidateHeaderBody_00473(const AHeader: IFatturaElettronicaHeaderType; const ABody: IFatturaElettronicaBodyType;
      const AResult: IeiValidationResultCollection);
    class procedure ValidateHeaderBody_00475(const AHeader: IFatturaElettronicaHeaderType; const ABody: IFatturaElettronicaBodyType;
      const AResult: IeiValidationResultCollection);
  public
    class procedure Validate(const AInvoice: IFatturaElettronicaType; const AResult: IeiValidationResultCollection); override;
  end;

implementation

uses
  ei4D.Invoice.Prop.Interfaces,
  System.Math,
  ei4D.Validators.Factory,
  System.SysUtils,
  System.RegularExpressions,
  System.Classes,
  System.StrUtils;

{ TeiExtraXsdValidator }

class function TeiExtraXsdValidator.FindAliquotaIva(const AListaAliquoteIva: array of double; const AValue: double): Boolean;
var
  LAliquota: double;
begin
  result := False;
  for LAliquota in AListaAliquoteIva do
  begin
    if SameValue(AValue, LAliquota) then
    begin
      result := True;
      Break;
    end;
  end;
end;

class function TeiExtraXsdValidator.FindNaturaEsenzioneIva(const AListaNaturaEsenzioneIva: array of string; const AValue: string): Boolean;
var
  LNatura: string;
begin
  result := False;
  for LNatura in AListaNaturaEsenzioneIva do
  begin
    if (AValue = LNatura) then
    begin
      result := True;
      Break;
    end;
  end;
end;

class procedure TeiExtraXsdValidator.Validate(const AInvoice: IFatturaElettronicaType; const AResult: IeiValidationResultCollection);
begin
  ValidateHeader(AInvoice.FatturaElettronicaHeader, AResult);
  ValidateBody(AInvoice, AResult);
  ValidateHeaderBody(AInvoice, AResult);
end;

class procedure TeiExtraXsdValidator.ValidateBody(const AInvoice: IFatturaElettronicaType; const AResult: IeiValidationResultCollection);
var
  LProp: IeIBaseProperty;
  LBody: IFatturaElettronicaBodyType;
begin
  for LProp in AInvoice.FatturaElettronicaBody do
  begin
    LBody := LProp as IFatturaElettronicaBodyType;
    ValidateBody_00400_00401(LBody, AResult);
    ValidateBody_00411(LBody, AResult);
    ValidateBody_00413_00414(LBody, AResult);
    ValidateBody_00415(LBody, AResult);
    ValidateBody_00418(LBody, AResult);
    ValidateBody_00419(LBody, AResult);
    ValidateBody_00420(LBody, AResult);
    ValidateBody_00421(LBody, AResult);
    ValidateBody_00422(LBody, AResult);
    ValidateBody_00423(LBody, AResult);
    ValidateBody_00424(LBody, AResult);
    ValidateBody_00425(LBody, AResult);
    ValidateBody_00429_00430(LBody, AResult);
    ValidateBody_00437_00438(LBody, AResult);
    ValidateBody_00443(LBody, AResult);
    ValidateBody_00444(LBody, AResult);
    ValidateBody_00445(LBody, AResult);
    ValidateBody_00474(LBody, AResult);
    // Add body validators here
  end;
end;

class procedure TeiExtraXsdValidator.ValidateHeader(const AHeader: IFatturaElettronicaHeaderType;
  const AResult: IeiValidationResultCollection);
begin
  ValidateHeader_00417(AHeader, AResult);
  ValidateHeader_00426(AHeader, AResult);
  ValidateHeader_00427(AHeader, AResult);
  ValidateHeader_00476(AHeader, AResult);
  // Add header validators here
end;

class procedure TeiExtraXsdValidator.ValidateHeaderBody(const AInvoice: IFatturaElettronicaType;
  const AResult: IeiValidationResultCollection);
var
  LProp: IeIBaseProperty;
  LBody: IFatturaElettronicaBodyType;
begin
  for LProp in AInvoice.FatturaElettronicaBody do
  begin
    LBody := LProp as IFatturaElettronicaBodyType;
    ValidateHeaderBody_00471(AInvoice.FatturaElettronicaHeader, LBody, AResult);
    ValidateHeaderBody_00472(AInvoice.FatturaElettronicaHeader, LBody, AResult);
    ValidateHeaderBody_00473(AInvoice.FatturaElettronicaHeader, LBody, AResult);
    ValidateHeaderBody_00475(AInvoice.FatturaElettronicaHeader, LBody, AResult);
    // Add header body validators here
  end;
end;

class procedure TeiExtraXsdValidator.ValidateBody_00443(const ABody: IFatturaElettronicaBodyType;
  const AResult: IeiValidationResultCollection);
var
  LProp: IeIBaseProperty;
  LDatiCassaPrevidenziale: IDatiCassaPrevidenzialeType;
  LDettaglioLinea: IDettaglioLineeType;
  i: integer;
  LListaAliquoteIvaRiepilogo: array of double;
begin
  // ---------------------------------------------------------------------------------------
  // Codice 00443 non c’è corrispondenza tra i valori indicati nell’elemento 2.2.1.12 <AliquotaIVA> o 2.1.1.7.5 <AliquotaIVA> e quelli dell’elemento 2.2.2.1 <ALiquotaIVA>

  // popolo un array con le aliquote IVA del riepilogo
  i := 0;
  SetLength(LListaAliquoteIvaRiepilogo, 0);
  for LProp in ABody.DatiBeniServizi.DatiRiepilogo do
  begin
    Inc(i);
    SetLength(LListaAliquoteIvaRiepilogo, i);
    LListaAliquoteIvaRiepilogo[i - 1] := (LProp as IDatiRiepilogoType).AliquotaIva.Value;
  end;

  // verifico per ogni aliquota iva in cassa previdenziale la presenza dell'aliquota nel riepilogo
  for LProp in ABody.DatiGenerali.DatiGeneraliDocumento.DatiCassaPrevidenziale do
  begin
    LDatiCassaPrevidenziale := LProp as IDatiCassaPrevidenzialeType;
    if not FindAliquotaIva(LListaAliquoteIvaRiepilogo, LDatiCassaPrevidenziale.AliquotaIva.Value) then
    begin
      AResult.Add(TeiValidatorsFactory.NewValidationResult(ABody.DatiGenerali.DatiGeneraliDocumento.DatiCassaPrevidenziale.
        FullQualifiedName, '00443',
        'non c’è corrispondenza tra i valori indicati nell’elemento 2.1.1.7.5 <AliquotaIVA> e quelli dell’elemento 2.2.2.1 <ALiquotaIVA>',
        vkExtraXSD));
    end;
  end;

  // verifico per ogni aliquota iva presente nelle linee la presenza dell'aliquota nel riepilogo
  for LProp in ABody.DatiBeniServizi.DettaglioLinee do
  begin
    LDettaglioLinea := LProp as IDettaglioLineeType;
    if not FindAliquotaIva(LListaAliquoteIvaRiepilogo, LDettaglioLinea.AliquotaIva.Value) then
    begin
      AResult.Add(TeiValidatorsFactory.NewValidationResult(ABody.DatiBeniServizi.DettaglioLinee.FullQualifiedName, '00443',
        Format('non c’è corrispondenza tra i valori indicati nell’elemento 2.2.1.12 <AliquotaIVA> e quelli dell’elemento 2.2.2.1 <ALiquotaIVA> (linea:%d)',
        [LDettaglioLinea.NumeroLinea.Value]), vkExtraXSD));
    end;
  end;
end;

class procedure TeiExtraXsdValidator.ValidateHeaderBody_00471(const AHeader: IFatturaElettronicaHeaderType;
  const ABody: IFatturaElettronicaBodyType; const AResult: IeiValidationResultCollection);
const
  LArrTD: TArray<String> = ['TD01', 'TD02', 'TD03', 'TD06', 'TD16', 'TD17', 'TD18', 'TD19', 'TD20', 'TD24', 'TD25', 'TD28', 'TD29'];
var
  LTipoDocumento: string;
begin
  // Codice 00471 per il valore indicato nell’elemento 2.1.1.1 <TipoDocumento> il cedente/prestatore non può essere uguale al cessionario/committente
  // NOTA: il controllo del codice fiscale non viene effettuato perchè la documentazione prevede di risalire all'aliquota iva tramite Anagrafe Tributaria (saltiamo quindi il controllo dei codici fiscali)
  LTipoDocumento := ABody.DatiGenerali.DatiGeneraliDocumento.TipoDocumento.Value;
  if MatchStr(LTipoDocumento, LArrTD) then
  begin
    if ((not AHeader.CedentePrestatore.DatiAnagrafici.IdFiscaleIVA.IdCodice.IsEmptyOrZero) and
      (not AHeader.CessionarioCommittente.DatiAnagrafici.IdFiscaleIVA.IdCodice.IsEmptyOrZero)) and
      (AHeader.CedentePrestatore.DatiAnagrafici.IdFiscaleIVA.IdCodice.Value = AHeader.CessionarioCommittente.DatiAnagrafici.IdFiscaleIVA.
      IdCodice.Value) then
      AResult.Add(TeiValidatorsFactory.NewValidationResult(ABody.DatiGenerali.DatiGeneraliDocumento.TipoDocumento.FullQualifiedName,
        '00471', 'per il valore indicato nell’elemento 2.1.1.1 <TipoDocumento> il cedente/prestatore non può essere uguale al cessionario/committente',
        vkExtraXSD));
  end;
end;

class procedure TeiExtraXsdValidator.ValidateHeaderBody_00472(const AHeader: IFatturaElettronicaHeaderType;
  const ABody: IFatturaElettronicaBodyType; const AResult: IeiValidationResultCollection);
begin
  // ---------------------------------------------------------------------------------------
  // Codice 00472 per il valore indicato nell’elemento 2.1.1.1 <TipoDocumento> il cedente/prestatore deve essere uguale al cessionario/committente
  // NOTA: per il tipo documento TD27 è preferibile lasciare che sia eventualmente lo SDI a scartare la fattura (abbiamo alcuni esempi di autofatture in cui per il cessionario è specificato solo il codice fiscale)
  if (ABody.DatiGenerali.DatiGeneraliDocumento.TipoDocumento.Value = 'TD21') then
  begin
    if ((not AHeader.CedentePrestatore.DatiAnagrafici.IdFiscaleIVA.IdCodice.IsEmptyOrZero) and
      (not AHeader.CessionarioCommittente.DatiAnagrafici.IdFiscaleIVA.IdCodice.IsEmptyOrZero)) and
      (AHeader.CedentePrestatore.DatiAnagrafici.IdFiscaleIVA.IdCodice.Value <> AHeader.CessionarioCommittente.DatiAnagrafici.IdFiscaleIVA.
      IdCodice.Value) then
      AResult.Add(TeiValidatorsFactory.NewValidationResult(ABody.DatiGenerali.DatiGeneraliDocumento.TipoDocumento.FullQualifiedName,
        '00472', 'per il valore indicato nell’elemento 2.1.1.1 <TipoDocumento> il cedente/prestatore deve essere uguale al cessionario/committente',
        vkExtraXSD));
  end;
end;

class procedure TeiExtraXsdValidator.ValidateHeaderBody_00473(const AHeader: IFatturaElettronicaHeaderType;
  const ABody: IFatturaElettronicaBodyType; const AResult: IeiValidationResultCollection);
const
  LArrTD: TArray<String> = ['TD17', 'TD18', 'TD19', 'TD28'];
var
  LTipoDocumento: string;
begin
  // ---------------------------------------------------------------------------------------
  // Codice 00473 Per il valore indicato nell’elemento 2.1.1.1 <TipoDocumento> non è ammesso il valore IT nell’elemento 1.2.1.1.1 <IdPaese>
  LTipoDocumento := ABody.DatiGenerali.DatiGeneraliDocumento.TipoDocumento.Value;
  // autofatture per acquisti dall'estero
  if MatchStr(LTipoDocumento, LArrTD) and (AHeader.CedentePrestatore.DatiAnagrafici.IdFiscaleIVA.IdPaese.Value = 'IT') then
    AResult.Add(TeiValidatorsFactory.NewValidationResult(ABody.DatiGenerali.DatiGeneraliDocumento.TipoDocumento.FullQualifiedName, '00473',
      'per il valore indicato nell’elemento 2.1.1.1 <TipoDocumento> non è ammesso il valore IT nell’elemento 1.2.1.1.1 <IdPaese>',
      vkExtraXSD));
  // autofatture per acquisti dall'estero
  if (LTipoDocumento = 'TD29') and (AHeader.CedentePrestatore.DatiAnagrafici.IdFiscaleIVA.IdPaese.Value <> 'IT') then
    AResult.Add(TeiValidatorsFactory.NewValidationResult(ABody.DatiGenerali.DatiGeneraliDocumento.TipoDocumento.FullQualifiedName, '00473',
      'per il valore indicato nell’elemento 2.1.1.1 <TipoDocumento> non può essere diverso da IT nell’elemento 1.2.1.1.1 <IdPaese>',
      vkExtraXSD));
  // omesso il controllo per TD17 e TD19 (che possono avere OO, operazioni effettuate da residenti Livigno e Campione d'Italia, in quanto impliciti nel controllo IdPaese che sia diverso da IT
end;

class procedure TeiExtraXsdValidator.ValidateHeader_00417(const AHeader: IFatturaElettronicaHeaderType;
  const AResult: IeiValidationResultCollection);
begin
  // ---------------------------------------------------------------------------------------
  // Codice 00417 1.4.1.1 <IdFiscaleIVA> e 1.4.1.2 <CodiceFiscale> non valorizzati (almeno uno dei due deve essere valorizzato)
  if (AHeader.CessionarioCommittente.DatiAnagrafici.IdFiscaleIVA.IsEmptyOrZero) and
    (AHeader.CessionarioCommittente.DatiAnagrafici.CodiceFiscale.IsEmptyOrZero) then
    AResult.Add(TeiValidatorsFactory.NewValidationResult(AHeader.DatiTrasmissione.CodiceDestinatario.FullQualifiedName, '00417',
      '1.4.1.1 <IdFiscaleIVA> e 1.4.1.2 <CodiceFiscale> non valorizzati (almeno uno dei due deve essere valorizzato)', vkExtraXSD));
end;

// in data 22/12/23 Mauri e Thomas verificata eliminazione del controllo: deve essere possibile inviare fattura senza codice destinatario e Pec (privati)
class procedure TeiExtraXsdValidator.ValidateHeader_00426(const AHeader: IFatturaElettronicaHeaderType;
  const AResult: IeiValidationResultCollection);
begin
  // // ---------------------------------------------------------------------------------------
  // // Codice 00426 1.1.6 <PECDestinatario> non valorizzato a fronte di 1.1.4 <CodiceDestinatario> con valore 0000000
  // if (AHeader.DatiTrasmissione.PECDestinatario.IsEmptyOrZero) and (AHeader.DatiTrasmissione.CodiceDestinatario.ValueDef = '0000000') then
  // AResult.Add(TeiValidatorsFactory.NewValidationResult(AHeader.DatiTrasmissione.CodiceDestinatario.FullQualifiedName, '00426',
  // '1.1.6 <PECDestinatario> non valorizzato a fronte di 1.1.4 <CodiceDestinatario> con valore 0000000', vkExtraXSD));
  // // ---------------------------------------------------------------------------------------
  // // Codice 00426 1.1.6 <PECDestinatario> valorizzato a fronte di 1.1.4 <Codice Destinatario> con valore diverso da 0000000
  // if (not AHeader.DatiTrasmissione.PECDestinatario.IsEmptyOrZero) and (AHeader.DatiTrasmissione.CodiceDestinatario.ValueDef <> '0000000')
  // then
  // AResult.Add(TeiValidatorsFactory.NewValidationResult(AHeader.DatiTrasmissione.CodiceDestinatario.FullQualifiedName, '00426',
  // '1.1.6 <PECDestinatario> valorizzato a fronte di 1.1.4 <Codice Destinatario> con valore diverso da 0000000', vkExtraXSD));
end;

class procedure TeiExtraXsdValidator.ValidateHeader_00427(const AHeader: IFatturaElettronicaHeaderType;
  const AResult: IeiValidationResultCollection);
begin
  // ---------------------------------------------------------------------------------------
  // Codice 00427 1.1.4 <CodiceDestinatario> di 7 caratteri non ammesso a fronte di 1.1.3 <FormatoTrasmissione> con valore FPA12
  if (AHeader.DatiTrasmissione.FormatoTrasmissione.ValueDef = 'FPA12') and (AHeader.DatiTrasmissione.CodiceDestinatario.ValueDef.Length = 7)
  then
    AResult.Add(TeiValidatorsFactory.NewValidationResult(AHeader.DatiTrasmissione.CodiceDestinatario.FullQualifiedName, '00427',
      '1.1.4 <CodiceDestinatario> di 7 caratteri non ammesso a fronte di 1.1.3 <FormatoTrasmissione> con valore FPA12', vkExtraXSD));
  // ---------------------------------------------------------------------------------------
  // Codice 00427 1.1.4 <CodiceDestinatario> di 6 caratteri non ammesso a fronte di 1.1.3 <FormatoTrasmissione> con valore FPR12 o FSM10
  if (AHeader.DatiTrasmissione.FormatoTrasmissione.ValueDef = 'FPR12') and (AHeader.DatiTrasmissione.CodiceDestinatario.ValueDef.Length = 6)
  then
    AResult.Add(TeiValidatorsFactory.NewValidationResult(AHeader.DatiTrasmissione.CodiceDestinatario.FullQualifiedName, '00427',
      '1.1.4 <CodiceDestinatario> di 6 caratteri non ammesso a fronte di 1.1.3 <FormatoTrasmissione> con valore FPR12', vkExtraXSD));
end;

class procedure TeiExtraXsdValidator.ValidateHeader_00476(const AHeader: IFatturaElettronicaHeaderType;
  const AResult: IeiValidationResultCollection);
begin
  // ---------------------------------------------------------------------------------------
  // Codice 00476 in caso di fatture ordinarie: gli elementi 1.2.1.1.1 <IdPaese> e 1.4.1.1.1 <IdPaese> non possono essere entrambi valorizzati con codice diverso da IT
  if (AHeader.CedentePrestatore.DatiAnagrafici.IdFiscaleIVA.IdPaese.Value <> 'IT') and
    (AHeader.CessionarioCommittente.DatiAnagrafici.IdFiscaleIVA.IdPaese.Value <> 'IT') then
    AResult.Add(TeiValidatorsFactory.NewValidationResult(AHeader.DatiTrasmissione.CodiceDestinatario.FullQualifiedName, '00476',
      'in caso di fatture ordinarie: gli elementi 1.2.1.1.1 <IdPaese> e 1.4.1.1.1 <IdPaese> non possono essere entrambi valorizzati con codice diverso da IT',
      vkExtraXSD));
end;

class procedure TeiExtraXsdValidator.ValidateBody_00400_00401(const ABody: IFatturaElettronicaBodyType;
  const AResult: IeiValidationResultCollection);
var
  LProp: IeIBaseProperty;
  LDettaglioLinea: IDettaglioLineeType;
begin
  for LProp in ABody.DatiBeniServizi.DettaglioLinee do
  begin
    LDettaglioLinea := LProp as IDettaglioLineeType;
    // ---------------------------------------------------------------------------------------
    // Codice 00400 2.2.1.14 <Natura> non presente a fronte di 2.2.1.12 <AliquotaIVA> pari a zero
    if LDettaglioLinea.AliquotaIva.IsEmptyOrZero and LDettaglioLinea.Natura.IsEmptyOrZero then
      AResult.Add(TeiValidatorsFactory.NewValidationResult(LDettaglioLinea.FullQualifiedName, '00400',
        Format('2.2.1.14 <Natura> non presente a fronte di 2.2.1.12 <AliquotaIVA> pari a zero (linea %d)',
        [LDettaglioLinea.NumeroLinea.Value]), vkExtraXSD));
    // ---------------------------------------------------------------------------------------
    // - Codice 00401 2.2.1.14 <Natura> presente a fronte di 2.2.1.12 <AliquotaIVA> diversa da zero
    if (not LDettaglioLinea.AliquotaIva.IsEmptyOrZero) and (not LDettaglioLinea.Natura.IsEmptyOrZero) then
      AResult.Add(TeiValidatorsFactory.NewValidationResult(LDettaglioLinea.FullQualifiedName, '00401',
        Format('2.2.1.14 <Natura> presente a fronte di 2.2.1.12 <AliquotaIVA> diversa da zero (linea %d)',
        [LDettaglioLinea.NumeroLinea.Value]), vkExtraXSD));
  end;
end;

class procedure TeiExtraXsdValidator.ValidateBody_00411(const ABody: IFatturaElettronicaBodyType;
  const AResult: IeiValidationResultCollection);
var
  LDettaglioLinea: IDettaglioLineeType;
  LProp: IeIBaseProperty;
  LControlloRitenuta: Boolean;
begin
  // ---------------------------------------------------------------------------------------
  // Codice 00411 2.1.1.5 <DatiRitenuta> non presente a fronte di almeno un blocco 2.2.1 <DettaglioLinee> con 2.2.1.13 <Ritenuta> uguale a SI
  LControlloRitenuta := False;
  for LProp in ABody.DatiBeniServizi.DettaglioLinee do
  begin
    LDettaglioLinea := LProp as IDettaglioLineeType;
    if not(LDettaglioLinea.Ritenuta.IsEmptyOrZero) then
    begin
      LControlloRitenuta := True;
      Break;
    end;
  end;
  if LControlloRitenuta then
  begin
    if ABody.DatiGenerali.DatiGeneraliDocumento.DatiRitenuta.IsEmptyOrZero then
    begin
      AResult.Add(TeiValidatorsFactory.NewValidationResult(ABody.DatiGenerali.DatiGeneraliDocumento.DatiRitenuta.FullQualifiedName, '00411',
        '2.1.1.5 <DatiRitenuta> non presente a fronte di almeno un blocco 2.2.1 <DettaglioLinee> con 2.2.1.13 <Ritenuta> uguale a SI',
        vkExtraXSD));
    end;
  end;
end;

class procedure TeiExtraXsdValidator.ValidateBody_00413_00414(const ABody: IFatturaElettronicaBodyType;
  const AResult: IeiValidationResultCollection);
var
  LProp: IeIBaseProperty;
  LDatiCassaPrevidenziale: IDatiCassaPrevidenzialeType;
begin
  for LProp in ABody.DatiGenerali.DatiGeneraliDocumento.DatiCassaPrevidenziale do
  begin
    LDatiCassaPrevidenziale := LProp as IDatiCassaPrevidenzialeType;
    // ---------------------------------------------------------------------------------------
    // Codice 00413 2.1.1.7.7 <Natura> non presente a fronte di 2.1.1.7.5 <AliquotaIVA> pari a zero
    if (LDatiCassaPrevidenziale.AliquotaIva.IsEmptyOrZero) then
    begin
      if (LDatiCassaPrevidenziale.Natura.IsEmptyOrZero) then
        AResult.Add(TeiValidatorsFactory.NewValidationResult(ABody.DatiGenerali.DatiGeneraliDocumento.DatiCassaPrevidenziale.
          FullQualifiedName, '00413', '00413 2.1.1.7.7 <Natura> non presente a fronte di 2.1.1.7.5 <AliquotaIVA> pari a zero', vkExtraXSD));
    end
    else
    begin
      // ---------------------------------------------------------------------------------------
      // Codice 00414 2.1.1.7.7 <Natura> presente a fronte di 2.1.1.7.5 <Aliquota IVA> diversa da zero
      if not(LDatiCassaPrevidenziale.Natura.IsEmptyOrZero) then
        AResult.Add(TeiValidatorsFactory.NewValidationResult(ABody.DatiGenerali.DatiGeneraliDocumento.DatiCassaPrevidenziale.
          FullQualifiedName, '00414', '00414 2.1.1.7.7 <Natura> presente a fronte di 2.1.1.7.5 <Aliquota IVA> diversa da zero',
          vkExtraXSD));
    end;
  end;
end;

class procedure TeiExtraXsdValidator.ValidateBody_00415(const ABody: IFatturaElettronicaBodyType;
  const AResult: IeiValidationResultCollection);
var
  LProp: IeIBaseProperty;
  LDatiCassaPrevidenziale: IDatiCassaPrevidenzialeType;
begin
  // ---------------------------------------------------------------------------------------
  // Codice 00415 2.1.1.5 <DatiRitenuta> non presente a fronte di 2.1.1.7.6 <Ritenuta> uguale a SI
  for LProp in ABody.DatiGenerali.DatiGeneraliDocumento.DatiCassaPrevidenziale do
  begin
    LDatiCassaPrevidenziale := LProp as IDatiCassaPrevidenzialeType;
    if (LDatiCassaPrevidenziale.Ritenuta.ValueDef = 'SI') and ABody.DatiGenerali.DatiGeneraliDocumento.DatiRitenuta.IsEmptyOrZero then
    begin
      AResult.Add(TeiValidatorsFactory.NewValidationResult(ABody.DatiGenerali.DatiGeneraliDocumento.DatiRitenuta.FullQualifiedName, '00415',
        '2.1.1.5 <DatiRitenuta> non presente a fronte di 2.1.1.7.6 <Ritenuta> uguale a SI', vkExtraXSD));
      Break;
    end;
  end;
end;

class procedure TeiExtraXsdValidator.ValidateBody_00418(const ABody: IFatturaElettronicaBodyType;
  const AResult: IeiValidationResultCollection);
var
  LProp: IeIBaseProperty;
  LDocumentiCorrelati: IDatiDocumentiCorrelatiType;
begin
  // ---------------------------------------------------------------------------------------
  // Codice 00418 2.1.1.3 <Data> antecedente a 2.1.6.3 <Data>
  if (ABody.DatiGenerali.DatiGeneraliDocumento.TipoDocumento.Value = 'TD04') then
  begin
    for LProp in ABody.DatiGenerali.DatiFattureCollegate do
    begin
      LDocumentiCorrelati := LProp as IDatiDocumentiCorrelatiType;
      if (ABody.DatiGenerali.DatiGeneraliDocumento.Data.Value < LDocumentiCorrelati.Data.Value) then
        AResult.Add(TeiValidatorsFactory.NewValidationResult(ABody.DatiGenerali.DatiGeneraliDocumento.FullQualifiedName, '00418',
          '2.1.1.3 <Data> antecedente a 2.1.6.3 <Data>', vkExtraXSD));
    end;
  end;
end;

class procedure TeiExtraXsdValidator.ValidateBody_00419(const ABody: IFatturaElettronicaBodyType;
  const AResult: IeiValidationResultCollection);
var
  LProp: IeIBaseProperty;
  LDatiCassaPrevidenziale: IDatiCassaPrevidenzialeType;
  LDettaglioLinee: IDettaglioLineeType;
  LListaAliquoteIvaRiepilogo: array of double;
  LListaAliquoteIvaUsate: array of double;
  i: integer;
begin
  // ---------------------------------------------------------------------------------------
  // Codice 00419 2.2.2 <DatiRiepilogo> non presente in corrispondenza di almeno un valore di 2.1.1.7.5 <AliquotaIVA> o 2.2.1.12 <AliquotaIVA>
  i := 0;
  SetLength(LListaAliquoteIvaUsate, 0);
  SetLength(LListaAliquoteIvaRiepilogo, 0);
  for LProp in ABody.DatiBeniServizi.DatiRiepilogo do
  begin
    if not FindAliquotaIva(LListaAliquoteIvaRiepilogo, (LProp as IDatiRiepilogoType).AliquotaIva.Value) then
    begin
      Inc(i);
      SetLength(LListaAliquoteIvaRiepilogo, i);
      LListaAliquoteIvaRiepilogo[i - 1] := (LProp as IDatiRiepilogoType).AliquotaIva.Value;
    end;
  end;

  for LProp in ABody.DatiGenerali.DatiGeneraliDocumento.DatiCassaPrevidenziale do
  begin
    LDatiCassaPrevidenziale := LProp as IDatiCassaPrevidenzialeType;

    // Aggiunta dell'aliquota nell'array di aliquote iva utilizzate nei dettagli documento (DatiCassaPrevidenziale)
    if not FindAliquotaIva(LListaAliquoteIvaUsate, LDatiCassaPrevidenziale.AliquotaIva.Value) then
    begin
      SetLength(LListaAliquoteIvaUsate, Length(LListaAliquoteIvaUsate) + 1);
      LListaAliquoteIvaUsate[Length(LListaAliquoteIvaUsate) - 1] := LDatiCassaPrevidenziale.AliquotaIva.Value;
    end;
  end;

  for LProp in ABody.DatiBeniServizi.DettaglioLinee do
  begin
    LDettaglioLinee := LProp as IDettaglioLineeType;

    // Aggiunta dell'aliquota nell'array di aliquote iva utilizzate nei dettagli documento (DettaglioLinee)
    if not FindAliquotaIva(LListaAliquoteIvaUsate, LDettaglioLinee.AliquotaIva.Value) then
    begin
      SetLength(LListaAliquoteIvaUsate, Length(LListaAliquoteIvaUsate) + 1);
      LListaAliquoteIvaUsate[Length(LListaAliquoteIvaUsate) - 1] := LDettaglioLinee.AliquotaIva.Value;
    end;
  end;

  // Confronto il numero delle aliquote iva dichiarate nei dati di riepilogo rispetto alle dichiarate nei dettagli documento
  if Length(LListaAliquoteIvaRiepilogo) <> Length(LListaAliquoteIvaUsate) then
  begin
    AResult.Add(TeiValidatorsFactory.NewValidationResult(ABody.DatiBeniServizi.DatiRiepilogo.FullQualifiedName, '00419',
      '2.2.2 <DatiRiepilogo> non presente in corrispondenza di almeno un valore di 2.1.1.7.5 <AliquotaIVA> o 2.2.1.12 <AliquotaIVA>',
      vkExtraXSD));
  end;
end;

class procedure TeiExtraXsdValidator.ValidateBody_00420(const ABody: IFatturaElettronicaBodyType;
  const AResult: IeiValidationResultCollection);
var
  LProp: IeIBaseProperty;
  LDatiRiepilogoType: IDatiRiepilogoType;
begin
  // ---------------------------------------------------------------------------------------
  // - Codice 00420 2.2.2.2 <Natura> con valore di tipo N6 a fronte di 2.2.2.7 <EsigibilitaIVA> uguale a S (scissione pagamenti)
  for LProp in ABody.DatiBeniServizi.DatiRiepilogo do
  begin
    LDatiRiepilogoType := (LProp as IDatiRiepilogoType);
    if (LDatiRiepilogoType.EsigibilitaIVA.ValueDef = 'S') and not(LDatiRiepilogoType.Natura.IsEmptyOrZero) and
      ((LDatiRiepilogoType.Natura.Value = 'N6') or (LDatiRiepilogoType.Natura.Value = 'N6.1') or (LDatiRiepilogoType.Natura.Value = 'N6.2')
      or (LDatiRiepilogoType.Natura.Value = 'N6.3') or (LDatiRiepilogoType.Natura.Value = 'N6.4') or
      (LDatiRiepilogoType.Natura.Value = 'N6.5') or (LDatiRiepilogoType.Natura.Value = 'N6.6') or (LDatiRiepilogoType.Natura.Value = 'N6.7')
      or (LDatiRiepilogoType.Natura.Value = 'N6.8') or (LDatiRiepilogoType.Natura.Value = 'N6.9')) then
    begin
      AResult.Add(TeiValidatorsFactory.NewValidationResult(ABody.DatiBeniServizi.DatiRiepilogo.FullQualifiedName, '00420',
        '2.2.2.2 <Natura> con valore di tipo N6 a fronte di 2.2.2.7 <EsigibilitaIVA> uguale a S (scissione pagamenti)', vkExtraXSD));
    end;
  end;
end;

class procedure TeiExtraXsdValidator.ValidateBody_00421(const ABody: IFatturaElettronicaBodyType;
  const AResult: IeiValidationResultCollection);
var
  LProp: IeIBaseProperty;
  LDatiRiepilogoType: IDatiRiepilogoType;
begin
  // ---------------------------------------------------------------------------------------
  // - Codice 00421 2.2.2.6 <Imposta> non calcolato secondo le regole definite nelle specifiche tecniche
  for LProp in ABody.DatiBeniServizi.DatiRiepilogo do
  begin
    LDatiRiepilogoType := (LProp as IDatiRiepilogoType);
    if not SameValue(LDatiRiepilogoType.Imposta.Value, (LDatiRiepilogoType.AliquotaIva.Value * LDatiRiepilogoType.ImponibileImporto.Value /
      100), 0.01) then
      AResult.Add(TeiValidatorsFactory.NewValidationResult(ABody.DatiBeniServizi.DatiRiepilogo.FullQualifiedName, '00421',
        '2.2.2.6 <Imposta> non calcolato secondo le regole definite nelle specifiche tecniche', vkExtraXSD));
  end;
end;

class procedure TeiExtraXsdValidator.ValidateBody_00422(const ABody: IFatturaElettronicaBodyType;
  const AResult: IeiValidationResultCollection);
type
  TRecDatiRiepilogoIva = record
    AliquotaIva: double;
    Natura: string;
    ImponibileImporto: double;
    Arrotondamento: double;
  end;
var
  LProp: IeIBaseProperty;
  LPropLinee: IeIBaseProperty;
  LPropDatiCassaPrevidenziale: IeIBaseProperty;
  LDettaglioLinea: IDettaglioLineeType;
  LDatiRiepilogoType: IDatiRiepilogoType;
  LDatiCassaPrevidenziale: IDatiCassaPrevidenzialeType;
  LImponibileImporto: double;
  LArrotondamento: double;
  LPrezzoTotale: double;
  LImportoContrCassa: double;
  LArrayDatiRiepilogo: array of TRecDatiRiepilogoIva;
  i: integer;
  LRecDatiRiepilogoIva: TRecDatiRiepilogoIva;
  LDatiRiepilogoIndex: integer;

  // function FindDatiRiepilogoItem(const ARecDatiRiepilogoIva: TRecDatiRiepilogoIva; const AArrayDatiRiepilogo: array of TRecDatiRiepilogoIva): integer;
  function FindDatiRiepilogoItem: integer;
  var
    j: integer;
  begin
    result := -1;
    for j := 0 to Length(LArrayDatiRiepilogo) - 1 do
    begin
      if SameValue(LArrayDatiRiepilogo[j].AliquotaIva, LRecDatiRiepilogoIva.AliquotaIva) and
        (LArrayDatiRiepilogo[j].Natura = LRecDatiRiepilogoIva.Natura) then
      begin
        result := j;
        Break;
      end;
    end;
  end;

begin
  // ---------------------------------------------------------------------------------------
  // - Codice 00422 2.2.2.5 <ImponibileImporto> non calcolato secondo le regole definite nelle specifiche tecniche

  i := 0;
  for LProp in ABody.DatiBeniServizi.DatiRiepilogo do
  begin
    LDatiRiepilogoType := (LProp as IDatiRiepilogoType);
    LRecDatiRiepilogoIva.AliquotaIva := LDatiRiepilogoType.AliquotaIva.Value;
    LRecDatiRiepilogoIva.Natura := LDatiRiepilogoType.Natura.ValueDef;
    LRecDatiRiepilogoIva.ImponibileImporto := LDatiRiepilogoType.ImponibileImporto.Value;
    LDatiRiepilogoIndex := FindDatiRiepilogoItem;
    if LDatiRiepilogoIndex < 0 then
    begin
      SetLength(LArrayDatiRiepilogo, i + 1);
      LArrayDatiRiepilogo[i].AliquotaIva := LDatiRiepilogoType.AliquotaIva.Value;
      LArrayDatiRiepilogo[i].Natura := LDatiRiepilogoType.Natura.ValueDef;
      LArrayDatiRiepilogo[i].ImponibileImporto := LDatiRiepilogoType.ImponibileImporto.Value;
      LArrayDatiRiepilogo[i].Arrotondamento := LDatiRiepilogoType.Arrotondamento.ValueDef;
      Inc(i);
    end
    else
    begin
      LArrayDatiRiepilogo[LDatiRiepilogoIndex].ImponibileImporto := LArrayDatiRiepilogo[LDatiRiepilogoIndex].ImponibileImporto +
        LRecDatiRiepilogoIva.ImponibileImporto;
      LArrayDatiRiepilogo[LDatiRiepilogoIndex].Arrotondamento := LArrayDatiRiepilogo[LDatiRiepilogoIndex].Arrotondamento +
        LRecDatiRiepilogoIva.Arrotondamento;
    end;
  end;

  for i := 0 to Length(LArrayDatiRiepilogo) - 1 do
  begin
    LImponibileImporto := LArrayDatiRiepilogo[i].ImponibileImporto;
    LArrotondamento := LArrayDatiRiepilogo[i].Arrotondamento;

    LPrezzoTotale := 0;
    for LPropLinee in ABody.DatiBeniServizi.DettaglioLinee do
    begin
      LDettaglioLinea := (LPropLinee as IDettaglioLineeType);
      if SameValue(LDettaglioLinea.AliquotaIva.Value, LArrayDatiRiepilogo[i].AliquotaIva) and
        (LDettaglioLinea.Natura.ValueDef = LArrayDatiRiepilogo[i].Natura) then
        LPrezzoTotale := LPrezzoTotale + LDettaglioLinea.PrezzoTotale.Value;
    end;
    LImportoContrCassa := 0;
    for LPropDatiCassaPrevidenziale in ABody.DatiGenerali.DatiGeneraliDocumento.DatiCassaPrevidenziale do
    begin
      LDatiCassaPrevidenziale := (LPropDatiCassaPrevidenziale as IDatiCassaPrevidenzialeType);
      if SameValue(LDatiCassaPrevidenziale.AliquotaIva.Value, LArrayDatiRiepilogo[i].AliquotaIva) and
        (LDatiCassaPrevidenziale.Natura.ValueDef = LArrayDatiRiepilogo[i].Natura) then
        LImportoContrCassa := LImportoContrCassa + LDatiCassaPrevidenziale.ImportoContributoCassa.Value;
    end;

    if not SameValue(LImponibileImporto, LPrezzoTotale + LImportoContrCassa + LArrotondamento, 1) then
      AResult.Add(TeiValidatorsFactory.NewValidationResult(ABody.DatiBeniServizi.DatiRiepilogo.FullQualifiedName, '00422',
        '2.2.2.5 <ImponibileImporto> non calcolato secondo le regole definite nelle specifiche tecniche', vkExtraXSD));
  end;
end;

class procedure TeiExtraXsdValidator.ValidateBody_00423(const ABody: IFatturaElettronicaBodyType;
  const AResult: IeiValidationResultCollection);
var
  LProp: IeIBaseProperty;
  LDettaglioLinea: IDettaglioLineeType;
  LPropSconti: IeIBaseProperty;
  LPropScontoMaggiorazione: IScontoMaggiorazioneType;
  LPrezzoUnitarioNetto: double;
  LSegno: integer;
  LQuantita: double;
begin
  // ---------------------------------------------------------------------------------------
  // - Codice 00423 2.2.1.11 <PrezzoTotale> non calcolato secondo le regole definite nelle specifiche tecniche
  for LProp in ABody.DatiBeniServizi.DettaglioLinee do
  begin
    LDettaglioLinea := (LProp as IDettaglioLineeType);

    LPrezzoUnitarioNetto := LDettaglioLinea.PrezzoUnitario.Value;
    for LPropSconti in LDettaglioLinea.ScontoMaggiorazione do
    begin
      LPropScontoMaggiorazione := (LPropSconti as IScontoMaggiorazioneType);
      if (LPropScontoMaggiorazione.tipo.Value = 'SC') then
        LSegno := -1
      else if (LPropScontoMaggiorazione.tipo.Value = 'MG') then
        LSegno := 1
      else
        LSegno := 0;
      if not LPropScontoMaggiorazione.Importo.IsEmptyOrZero then
        // sconto a valore (considerato prioritario rispetto alla percentuale)
        LPrezzoUnitarioNetto := LPrezzoUnitarioNetto + (LSegno * LPropScontoMaggiorazione.Importo.Value)
      else if not LPropScontoMaggiorazione.Percentuale.IsEmptyOrZero then
        // sconto a percentuale
        LPrezzoUnitarioNetto := LPrezzoUnitarioNetto + (LSegno * (LPrezzoUnitarioNetto * LPropScontoMaggiorazione.Percentuale.Value / 100));
    end;
    if not LDettaglioLinea.Quantita.IsNull then
      LQuantita := LDettaglioLinea.Quantita.Value
    else
      LQuantita := 1;
    // Quantità specificata
    if not SameValue(LDettaglioLinea.PrezzoTotale.Value, LPrezzoUnitarioNetto * LQuantita, 0.01000001) then
    begin
      AResult.Add(TeiValidatorsFactory.NewValidationResult(ABody.DatiBeniServizi.DettaglioLinee.FullQualifiedName, '00423',
        Format('2.2.1.11 <PrezzoTotale> non calcolato secondo le regole definite nelle specifiche tecniche (riga %d)',
        [LDettaglioLinea.NumeroLinea.Value]), vkExtraXSD));
    end;
  end;
end;

class procedure TeiExtraXsdValidator.ValidateBody_00424(const ABody: IFatturaElettronicaBodyType;
  const AResult: IeiValidationResultCollection);
var
  LProp: IeIBaseProperty;
  LPropDatiCassaPrevidenziale: IeIBaseProperty;
  LDettaglioLinea: IDettaglioLineeType;
  LDatiRiepilogoType: IDatiRiepilogoType;
  LDatiCassaPrevidenziale: IDatiCassaPrevidenzialeType;
begin
  // ---------------------------------------------------------------------------------------
  // 2.2.1.12 <AliquotaIVA>  CassaPrevidenziale
  for LPropDatiCassaPrevidenziale in ABody.DatiGenerali.DatiGeneraliDocumento.DatiCassaPrevidenziale do
  begin
    LDatiCassaPrevidenziale := (LPropDatiCassaPrevidenziale as IDatiCassaPrevidenzialeType);
    if (not LDatiCassaPrevidenziale.AliquotaIva.IsEmptyOrZero) and (LDatiCassaPrevidenziale.AliquotaIva.Value < 1) then
      AResult.Add(TeiValidatorsFactory.NewValidationResult(ABody.DatiGenerali.DatiGeneraliDocumento.DatiCassaPrevidenziale.
        FullQualifiedName, '00424', Format('2.2.1.12 <AliquotaIVA> non indicata in termini percentuali (aliquota=%n)',
        [LDatiCassaPrevidenziale.AliquotaIva.Value]), vkExtraXSD));
  end;
  // ---------------------------------------------------------------------------------------
  // 2.2.2.1 <AliquotaIVA>  AliquotaIva Linea
  for LProp in ABody.DatiBeniServizi.DettaglioLinee do
  begin
    LDettaglioLinea := (LProp as IDettaglioLineeType);
    if (not LDettaglioLinea.AliquotaIva.IsEmptyOrZero) and (LDettaglioLinea.AliquotaIva.Value < 1) then
      AResult.Add(TeiValidatorsFactory.NewValidationResult(ABody.DatiBeniServizi.DettaglioLinee.FullQualifiedName, '00424',
        Format('2.2.2.1< AliquotaIVA> non indicata in termini percentuali (linea %d)', [LDettaglioLinea.NumeroLinea.Value]), vkExtraXSD));
  end;
  // ---------------------------------------------------------------------------------------
  // 2.1.1.7.5 <AliquotaIVA>  Dati Riepilogo
  for LProp in ABody.DatiBeniServizi.DatiRiepilogo do
  begin
    LDatiRiepilogoType := (LProp as IDatiRiepilogoType);
    if (not LDatiRiepilogoType.AliquotaIva.IsEmptyOrZero) and (LDatiRiepilogoType.AliquotaIva.Value < 1) then
      AResult.Add(TeiValidatorsFactory.NewValidationResult(ABody.DatiBeniServizi.DatiRiepilogo.FullQualifiedName, '00424',
        Format('2.1.1.7.5 <AliquotaIVA> non indicata in termini percentuali (aliquota=%n)', [LDatiRiepilogoType.AliquotaIva.Value]),
        vkExtraXSD));
  end;
end;

class procedure TeiExtraXsdValidator.ValidateBody_00425(const ABody: IFatturaElettronicaBodyType;
  const AResult: IeiValidationResultCollection);
begin
  // ---------------------------------------------------------------------------------------
  // Codice 00425 2.1.1.4 <Numero> non contenente caratteri numerici
  if not TRegEx.IsMatch(ABody.DatiGenerali.DatiGeneraliDocumento.Numero.ValueAsString, '\d') then
    AResult.Add(TeiValidatorsFactory.NewValidationResult(ABody.DatiGenerali.DatiGeneraliDocumento.Numero.FullQualifiedName, '00425',
      '2.1.1.4 <Numero> non contenente caratteri numerici', vkExtraXSD));
end;

class procedure TeiExtraXsdValidator.ValidateBody_00429_00430(const ABody: IFatturaElettronicaBodyType;
  const AResult: IeiValidationResultCollection);
var
  LProp: IeIBaseProperty;
  LDatiRiepilogo: IDatiRiepilogoType;
begin
  for LProp in ABody.DatiBeniServizi.DatiRiepilogo do
  begin
    LDatiRiepilogo := (LProp as IDatiRiepilogoType);
    // ---------------------------------------------------------------------------------------
    // - Codice 00429 2.2.2.2 <Natura> non presente a fronte di 2.2.2.1 <AliquotaIVA> pari a zero
    if (LDatiRiepilogo.Natura.IsEmptyOrZero) and (IsZero(LDatiRiepilogo.AliquotaIva.Value)) then
      AResult.Add(TeiValidatorsFactory.NewValidationResult(ABody.DatiBeniServizi.DatiRiepilogo.FullQualifiedName, '00429',
        '2.2.2.2 <Natura> non presente a fronte di 2.2.2.1 <AliquotaIVA> pari a zero', vkExtraXSD));
    // ---------------------------------------------------------------------------------------
    // - Codice 00430 2.2.2.2 <Natura> presente a fronte di 2.2.2.1 <Aliquota IVA> diversa da zero
    if (not LDatiRiepilogo.Natura.IsEmptyOrZero) and (not IsZero(LDatiRiepilogo.AliquotaIva.Value)) then
      AResult.Add(TeiValidatorsFactory.NewValidationResult(ABody.DatiBeniServizi.DatiRiepilogo.FullQualifiedName, '00430',
        '2.2.2.2 <Natura> presente a fronte di 2.2.2.1 <Aliquota IVA> diversa da zero', vkExtraXSD));
  end;
end;

class procedure TeiExtraXsdValidator.ValidateBody_00437_00438(const ABody: IFatturaElettronicaBodyType;
  const AResult: IeiValidationResultCollection);
var
  LProp: IeIBaseProperty;
  LPropScontoMaggiorazione: IeIBaseProperty;
  LDettaglioLinea: IDettaglioLineeType;
  LScontoMaggiorazione: IScontoMaggiorazioneType;
begin
  // ---------------------------------------------------------------------------------------
  // Codice errore 00437: 2.1.1.8.2 <Percentuale> e 2.1.1.8.3 <Importo> non presenti a fronte di 2.1.1.8.1 <Tipo> valorizzato
  for LProp in ABody.DatiGenerali.DatiGeneraliDocumento.ScontoMaggiorazione do
  begin
    LScontoMaggiorazione := (LProp as IScontoMaggiorazioneType);
    if not LScontoMaggiorazione.tipo.IsEmptyOrZero then
    begin
      if LScontoMaggiorazione.Percentuale.IsNull and LScontoMaggiorazione.Importo.IsNull then
        AResult.Add(TeiValidatorsFactory.NewValidationResult(ABody.DatiGenerali.DatiGeneraliDocumento.ScontoMaggiorazione.FullQualifiedName,
          '00437', '2.1.1.8.2 <Percentuale> e 2.1.1.8.3 <Importo> non presenti a fronte di 2.1.1.8.1 <Tipo> valorizzato', vkExtraXSD));
    end;
  end;
  for LProp in ABody.DatiBeniServizi.DettaglioLinee do
  begin
    LDettaglioLinea := LProp as IDettaglioLineeType;
    for LPropScontoMaggiorazione in LDettaglioLinea.ScontoMaggiorazione do
    begin
      LScontoMaggiorazione := (LPropScontoMaggiorazione as IScontoMaggiorazioneType);
      // ---------------------------------------------------------------------------------------
      // Codice errore 00438: 2.2.1.10.2 <Percentuale> e 2.2.1.10.3 <Importo> non presenti a fronte di 2.2.1.10.1 <Tipo> valorizzato
      if not LScontoMaggiorazione.tipo.IsEmptyOrZero then
      begin
        if LScontoMaggiorazione.Percentuale.IsNull and LScontoMaggiorazione.Importo.IsNull then
          AResult.Add(TeiValidatorsFactory.NewValidationResult(ABody.DatiBeniServizi.DettaglioLinee.FullQualifiedName, '00438',
            Format('2.2.1.10.2 <Percentuale> e 2.2.1.10.3 <Importo> non presenti a fronte di 2.2.1.10.1 <Tipo> valorizzato (linea %d)',
            [LDettaglioLinea.NumeroLinea.Value]), vkExtraXSD));
      end;
    end;
  end;
end;

class procedure TeiExtraXsdValidator.ValidateBody_00444(const ABody: IFatturaElettronicaBodyType;
  const AResult: IeiValidationResultCollection);
var
  LProp: IeIBaseProperty;
  LDatiCassaPrevidenziale: IDatiCassaPrevidenzialeType;
  LDettaglioLinea: IDettaglioLineeType;
  i: integer;
  LListaNaturaRiepilogo: array of string;
begin
  // ---------------------------------------------------------------------------------------
  // Codice 00444 non c’è corrispondenza tra i valori indicati nell’elemento 2.2.1.14 <Natura> o 2.1.1.7.7 <Natura> e quelli dell’elemento 2.2.2.2 <Natura>

  // popolo un array con le nature del riepilogo
  i := 0;
  SetLength(LListaNaturaRiepilogo, 0);
  for LProp in ABody.DatiBeniServizi.DatiRiepilogo do
  begin
    if not(LProp as IDatiRiepilogoType).Natura.IsEmptyOrZero then
    begin
      Inc(i);
      SetLength(LListaNaturaRiepilogo, i);
      LListaNaturaRiepilogo[i - 1] := (LProp as IDatiRiepilogoType).Natura.Value;
    end;
  end;

  // verifico per ogni natura esenzione in cassa previdenziale la presenza della natura nel riepilogo
  for LProp in ABody.DatiGenerali.DatiGeneraliDocumento.DatiCassaPrevidenziale do
  begin
    LDatiCassaPrevidenziale := LProp as IDatiCassaPrevidenzialeType;
    if not LDatiCassaPrevidenziale.Natura.IsEmptyOrZero and not FindNaturaEsenzioneIva(LListaNaturaRiepilogo,
      LDatiCassaPrevidenziale.Natura.Value) then
    begin
      AResult.Add(TeiValidatorsFactory.NewValidationResult(ABody.DatiGenerali.DatiGeneraliDocumento.DatiCassaPrevidenziale.
        FullQualifiedName, '00444',
        'non c’è corrispondenza tra i valori indicati nell’elemento 2.2.1.14 <Natura> e quelli dell’elemento 2.2.2.2 <Natura>',
        vkExtraXSD));
    end;
  end;

  // verifico per ogni aliquota iva presente nelle linee la presenza dell'aliquota nel riepilogo
  for LProp in ABody.DatiBeniServizi.DettaglioLinee do
  begin
    LDettaglioLinea := LProp as IDettaglioLineeType;
    if not LDettaglioLinea.Natura.IsEmptyOrZero and not FindNaturaEsenzioneIva(LListaNaturaRiepilogo, LDettaglioLinea.Natura.Value) then
    begin
      AResult.Add(TeiValidatorsFactory.NewValidationResult(ABody.DatiBeniServizi.DettaglioLinee.FullQualifiedName, '00444',
        Format('non c’è corrispondenza tra i valori indicati nell’elemento 2.1.1.7.7 <Natura> e quelli dell’elemento 2.2.2.2 <Natura> (linea:%d)',
        [LDettaglioLinea.NumeroLinea.Value]), vkExtraXSD));
    end;
  end;
end;

class procedure TeiExtraXsdValidator.ValidateBody_00445(const ABody: IFatturaElettronicaBodyType;
  const AResult: IeiValidationResultCollection);
begin
  // ---------------------------------------------------------------------------------------
  // Codice 00445: non è più ammesso il valore generico N2, N3 o N6 come codice natura dell’operazione- --
  // NOTE: Implicit implemented in Validators.XSD by RexEx
end;

class procedure TeiExtraXsdValidator.ValidateBody_00474(const ABody: IFatturaElettronicaBodyType;
  const AResult: IeiValidationResultCollection);
var
  LProp: IeIBaseProperty;
  LDettaglioLinea: IDettaglioLineeType;
begin
  // ---------------------------------------------------------------------------------------
  // Codice 00474 per il valore indicato nell’elemento 2.1.1.1 <TipoDocumento> non sono ammesse linee di dettaglio con l’elemento 2.2.1.12 <AliquotaIVA> contenente valore zero
  if (ABody.DatiGenerali.DatiGeneraliDocumento.TipoDocumento.Value = 'TD21') then
  begin
    for LProp in ABody.DatiBeniServizi.DettaglioLinee do
    begin
      LDettaglioLinea := LProp as IDettaglioLineeType;
      if IsZero(LDettaglioLinea.AliquotaIva.Value) then
        AResult.Add(TeiValidatorsFactory.NewValidationResult(ABody.DatiBeniServizi.DettaglioLinee.FullQualifiedName, '00474',
          Format('per il valore indicato nell’elemento 2.1.1.1 <TipoDocumento> non sono ammesse linee di dettaglio con l’elemento 2.2.1.12 <AliquotaIVA> contenente valore zero (linea %d)',
          [LDettaglioLinea.NumeroLinea.Value]), vkExtraXSD));
    end;
  end;
end;

class procedure TeiExtraXsdValidator.ValidateHeaderBody_00475(const AHeader: IFatturaElettronicaHeaderType;
  const ABody: IFatturaElettronicaBodyType; const AResult: IeiValidationResultCollection);
const
  LArrTD: TArray<String> = ['TD16', 'TD17', 'TD18', 'TD19', 'TD20', 'TD22', 'TD23', 'TD28', 'TD29'];
begin
  // ---------------------------------------------------------------------------------------
  // Codice 00475 per il valore indicato nell’elemento 2.1.1.1 <TipoDocumento> deve essere presente l’elemento 1.4.1.1 <IdFiscaleIVA> del cessionario/committente
  if MatchStr(ABody.DatiGenerali.DatiGeneraliDocumento.TipoDocumento.Value, LArrTD) and
    AHeader.CessionarioCommittente.DatiAnagrafici.IdFiscaleIVA.IsNull then
    AResult.Add(TeiValidatorsFactory.NewValidationResult(ABody.DatiGenerali.DatiGeneraliDocumento.TipoDocumento.FullQualifiedName, '00475',
      'per il valore indicato nell’elemento 2.1.1.1 <TipoDocumento> deve essere presente l’elemento 1.4.1.1 <IdFiscaleIVA> del cessionario/committente',
      vkExtraXSD));
end;

end.
