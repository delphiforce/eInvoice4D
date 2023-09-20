unit ei4D.Validators.ExtraXSD;

interface

uses
  ei4D.Validators.Interfaces, ei4D.Invoice.Interfaces;

type

  TeiExtraXsdValidator = class(TeiCustomValidator)
  private
    class procedure ValidateHeader(const AHeader: IFatturaElettronicaHeaderType; const AResult: IeiValidatorsResultCollection);
    class procedure ValidateBody(const AInvoice: IFatturaElettronicaType; const AResult: IeiValidatorsResultCollection);
    // Header validators
    class procedure ValidateHeader_00417(const AHeader: IFatturaElettronicaHeaderType; const AResult: IeiValidatorsResultCollection);
    class procedure ValidateHeader_00426(const AHeader: IFatturaElettronicaHeaderType; const AResult: IeiValidatorsResultCollection);
    class procedure ValidateHeader_00427(const AHeader: IFatturaElettronicaHeaderType; const AResult: IeiValidatorsResultCollection);
    // Body validators
    class procedure ValidateBody_00400_00401(const ABody: IFatturaElettronicaBodyType; const AResult: IeiValidatorsResultCollection);
    class procedure ValidateBody_00411(const ABody: IFatturaElettronicaBodyType; const AResult: IeiValidatorsResultCollection);
    class procedure ValidateBody_00413_00414(const ABody: IFatturaElettronicaBodyType; const AResult: IeiValidatorsResultCollection);
    class procedure ValidateBody_00415(const ABody: IFatturaElettronicaBodyType; const AResult: IeiValidatorsResultCollection);
    class procedure ValidateBody_00418(const ABody: IFatturaElettronicaBodyType; const AResult: IeiValidatorsResultCollection);
    class procedure ValidateBody_00419(const ABody: IFatturaElettronicaBodyType; const AResult: IeiValidatorsResultCollection);
    class procedure ValidateBody_00420(const ABody: IFatturaElettronicaBodyType; const AResult: IeiValidatorsResultCollection);
    class procedure ValidateBody_00421(const ABody: IFatturaElettronicaBodyType; const AResult: IeiValidatorsResultCollection);
    class procedure ValidateBody_00422(const ABody: IFatturaElettronicaBodyType; const AResult: IeiValidatorsResultCollection);
    class procedure ValidateBody_00423(const ABody: IFatturaElettronicaBodyType; const AResult: IeiValidatorsResultCollection);
    class procedure ValidateBody_00424(const ABody: IFatturaElettronicaBodyType; const AResult: IeiValidatorsResultCollection);
    class procedure ValidateBody_00425(const ABody: IFatturaElettronicaBodyType; const AResult: IeiValidatorsResultCollection);
    class procedure ValidateBody_00429_00430(const ABody: IFatturaElettronicaBodyType; const AResult: IeiValidatorsResultCollection);
  public
    class procedure Validate(const AInvoice: IFatturaElettronicaType; const AResult: IeiValidatorsResultCollection); override;
  end;

implementation

uses
  ei4D.Invoice.Prop.Interfaces, System.Math, ei4D.Validators.Factory,
  System.SysUtils, System.RegularExpressions, System.Classes;

{ TeiExtraXsdValidator }

class procedure TeiExtraXsdValidator.Validate(const AInvoice: IFatturaElettronicaType; const AResult: IeiValidatorsResultCollection);
begin
  ValidateHeader(AInvoice.FatturaElettronicaHeader, AResult);
  ValidateBody(AInvoice, AResult);
end;

class procedure TeiExtraXsdValidator.ValidateBody(const AInvoice: IFatturaElettronicaType; const AResult: IeiValidatorsResultCollection);
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
    // Add body validators here
  end;
end;

class procedure TeiExtraXsdValidator.ValidateHeader(const AHeader: IFatturaElettronicaHeaderType;
  const AResult: IeiValidatorsResultCollection);
begin
  ValidateHeader_00417(AHeader, AResult);
  ValidateHeader_00426(AHeader, AResult);
  ValidateHeader_00427(AHeader, AResult);
  // Add header validators here
end;

class procedure TeiExtraXsdValidator.ValidateHeader_00417(const AHeader: IFatturaElettronicaHeaderType;
  const AResult: IeiValidatorsResultCollection);
begin
  // ---------------------------------------------------------------------------------------
  // Codice 00417 1.4.1.1 <IdFiscaleIVA> e 1.4.1.2 <CodiceFiscale> non valorizzati (almeno uno dei due deve essere valorizzato)
  if (AHeader.CessionarioCommittente.DatiAnagrafici.IdFiscaleIVA.IsEmptyOrZero) and
    (AHeader.CessionarioCommittente.DatiAnagrafici.CodiceFiscale.IsEmptyOrZero) then
    AResult.Add(TeiValidatorsFactory.NewValidatorsResult(AHeader.DatiTrasmissione.CodiceDestinatario.FullQualifiedName, '00417',
      '1.4.1.1 <IdFiscaleIVA> e 1.4.1.2 <CodiceFiscale> non valorizzati (almeno uno dei due deve essere valorizzato)', vkExtraXSD));
end;

class procedure TeiExtraXsdValidator.ValidateHeader_00426(const AHeader: IFatturaElettronicaHeaderType;
  const AResult: IeiValidatorsResultCollection);
begin
  // ---------------------------------------------------------------------------------------
  // Codice 00426 1.1.6 <PECDestinatario> non valorizzato a fronte di 1.1.4 <CodiceDestinatario> con valore 0000000
  if (AHeader.DatiTrasmissione.PECDestinatario.IsEmptyOrZero) and (AHeader.DatiTrasmissione.CodiceDestinatario.ValueDef = '0000000') then
    AResult.Add(TeiValidatorsFactory.NewValidatorsResult(AHeader.DatiTrasmissione.CodiceDestinatario.FullQualifiedName, '00426',
      '1.1.6 <PECDestinatario> non valorizzato a fronte di 1.1.4 <CodiceDestinatario> con valore 0000000', vkExtraXSD));
  // ---------------------------------------------------------------------------------------
  // Codice 00426 1.1.6 <PECDestinatario> valorizzato a fronte di 1.1.4 <Codice Destinatario> con valore diverso da 0000000
  if (not AHeader.DatiTrasmissione.PECDestinatario.IsEmptyOrZero) and (AHeader.DatiTrasmissione.CodiceDestinatario.ValueDef <> '0000000')
  then
    AResult.Add(TeiValidatorsFactory.NewValidatorsResult(AHeader.DatiTrasmissione.CodiceDestinatario.FullQualifiedName, '00426',
      '1.1.6 <PECDestinatario> valorizzato a fronte di 1.1.4 <Codice Destinatario> con valore diverso da 0000000', vkExtraXSD));
end;

class procedure TeiExtraXsdValidator.ValidateHeader_00427(const AHeader: IFatturaElettronicaHeaderType;
  const AResult: IeiValidatorsResultCollection);
begin
  // ---------------------------------------------------------------------------------------
  // Codice 00427 1.1.4 <CodiceDestinatario> di 7 caratteri non ammesso a fronte di 1.1.3 <FormatoTrasmissione> con valore FPA12
  if (AHeader.DatiTrasmissione.FormatoTrasmissione.ValueDef = 'FPA12') and (AHeader.DatiTrasmissione.CodiceDestinatario.ValueDef.Length = 7)
  then
    AResult.Add(TeiValidatorsFactory.NewValidatorsResult(AHeader.DatiTrasmissione.CodiceDestinatario.FullQualifiedName, '00427',
      '1.1.4 <CodiceDestinatario> di 7 caratteri non ammesso a fronte di 1.1.3 <FormatoTrasmissione> con valore FPA12', vkExtraXSD));
  // ---------------------------------------------------------------------------------------
  // Codice 00427 1.1.4 <CodiceDestinatario> di 6 caratteri non ammesso a fronte di 1.1.3 <FormatoTrasmissione> con valore FPR12 o FSM10
  if (AHeader.DatiTrasmissione.FormatoTrasmissione.ValueDef = 'FPR12') and (AHeader.DatiTrasmissione.CodiceDestinatario.ValueDef.Length = 6)
  then
    AResult.Add(TeiValidatorsFactory.NewValidatorsResult(AHeader.DatiTrasmissione.CodiceDestinatario.FullQualifiedName, '00427',
      '1.1.4 <CodiceDestinatario> di 6 caratteri non ammesso a fronte di 1.1.3 <FormatoTrasmissione> con valore FPR12', vkExtraXSD));
end;

class procedure TeiExtraXsdValidator.ValidateBody_00400_00401(const ABody: IFatturaElettronicaBodyType;
  const AResult: IeiValidatorsResultCollection);
var
  LProp: IeIBaseProperty;
  LDettaglioLinea: IDettaglioLineeType;
begin
  for LProp in ABody.DatiBeniServizi.DettaglioLinee do
  begin
    LDettaglioLinea := LProp as IDettaglioLineeType;
    // ---------------------------------------------------------------------------------------
    // Codice 00400 2.2.1.14 <Natura> non presente a fronte di 2.2.1.12 <AliquotaIVA> pari a zero
    if LDettaglioLinea.AliquotaIVA.IsEmptyOrZero and LDettaglioLinea.Natura.IsEmptyOrZero then
      AResult.Add(TeiValidatorsFactory.NewValidatorsResult(LDettaglioLinea.FullQualifiedName, '00400',
        Format('2.2.1.14 <Natura> non presente a fronte di 2.2.1.12 <AliquotaIVA> pari a zero (linea %d)',
        [LDettaglioLinea.NumeroLinea.ValueDef]), vkExtraXSD));
    // ---------------------------------------------------------------------------------------
    // - Codice 00401 2.2.1.14 <Natura> presente a fronte di 2.2.1.12 <AliquotaIVA> diversa da zero
    if (not LDettaglioLinea.AliquotaIVA.IsEmptyOrZero) and (not LDettaglioLinea.Natura.IsEmptyOrZero) then
      AResult.Add(TeiValidatorsFactory.NewValidatorsResult(LDettaglioLinea.FullQualifiedName, '00401',
        Format('2.2.1.14 <Natura> presente a fronte di 2.2.1.12 <AliquotaIVA> diversa da zero (linea %d)',
        [LDettaglioLinea.NumeroLinea.ValueDef]), vkExtraXSD));
  end;
end;

class procedure TeiExtraXsdValidator.ValidateBody_00411(const ABody: IFatturaElettronicaBodyType;
  const AResult: IeiValidatorsResultCollection);
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
      AResult.Add(TeiValidatorsFactory.NewValidatorsResult(ABody.DatiGenerali.DatiGeneraliDocumento.DatiRitenuta.FullQualifiedName, '00411',
        '2.1.1.5 <DatiRitenuta> non presente a fronte di almeno un blocco 2.2.1 <DettaglioLinee> con 2.2.1.13 <Ritenuta> uguale a SI',
        vkExtraXSD));
    end;
  end;
end;

class procedure TeiExtraXsdValidator.ValidateBody_00413_00414(const ABody: IFatturaElettronicaBodyType;
  const AResult: IeiValidatorsResultCollection);
var
  LProp: IeIBaseProperty;
  LDatiCassaPrevidenziale: IDatiCassaPrevidenzialeType;
begin
  for LProp in ABody.DatiGenerali.DatiGeneraliDocumento.DatiCassaPrevidenziale do
  begin
    LDatiCassaPrevidenziale := LProp as IDatiCassaPrevidenzialeType;
    // ---------------------------------------------------------------------------------------
    // Codice 00413 2.1.1.7.7 <Natura> non presente a fronte di 2.1.1.7.5 <AliquotaIVA> pari a zero
    if (LDatiCassaPrevidenziale.AliquotaIVA.IsEmptyOrZero) then
    begin
      if (LDatiCassaPrevidenziale.Natura.IsEmptyOrZero) then
        AResult.Add(TeiValidatorsFactory.NewValidatorsResult(ABody.DatiGenerali.DatiGeneraliDocumento.DatiCassaPrevidenziale.
          FullQualifiedName, '00413', '00413 2.1.1.7.7 <Natura> non presente a fronte di 2.1.1.7.5 <AliquotaIVA> pari a zero', vkExtraXSD));
    end
    else
    begin
      // ---------------------------------------------------------------------------------------
      // Codice 00414 2.1.1.7.7 <Natura> presente a fronte di 2.1.1.7.5 <Aliquota IVA> diversa da zero
      if not(LDatiCassaPrevidenziale.Natura.IsEmptyOrZero) then
        AResult.Add(TeiValidatorsFactory.NewValidatorsResult(ABody.DatiGenerali.DatiGeneraliDocumento.DatiCassaPrevidenziale.
          FullQualifiedName, '00414', '00414 2.1.1.7.7 <Natura> presente a fronte di 2.1.1.7.5 <Aliquota IVA> diversa da zero',
          vkExtraXSD));
    end;
  end;
end;

class procedure TeiExtraXsdValidator.ValidateBody_00415(const ABody: IFatturaElettronicaBodyType;
  const AResult: IeiValidatorsResultCollection);
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
      AResult.Add(TeiValidatorsFactory.NewValidatorsResult(ABody.DatiGenerali.DatiGeneraliDocumento.DatiRitenuta.FullQualifiedName, '00415',
        '2.1.1.5 <DatiRitenuta> non presente a fronte di 2.1.1.7.6 <Ritenuta> uguale a SI', vkExtraXSD));
      Break;
    end;
  end;
end;

class procedure TeiExtraXsdValidator.ValidateBody_00418(const ABody: IFatturaElettronicaBodyType;
  const AResult: IeiValidatorsResultCollection);
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
        AResult.Add(TeiValidatorsFactory.NewValidatorsResult(ABody.DatiGenerali.DatiGeneraliDocumento.FullQualifiedName, '00418',
          '2.1.1.3 <Data> antecedente a 2.1.6.3 <Data>', vkExtraXSD));
    end;
  end;
end;

class procedure TeiExtraXsdValidator.ValidateBody_00419(const ABody: IFatturaElettronicaBodyType;
  const AResult: IeiValidatorsResultCollection);
var
  LProp: IeIBaseProperty;
  LDatiCassaPrevidenziale: IDatiCassaPrevidenzialeType;
  LDettaglioLinee: IDettaglioLineeType;
  LListaAliquoteIvaRiepilogo: array of double;
  LListaAliquoteIvaUsate: array of double;
  i: integer;

  function FindAliquotaIva(const AListaAliquoteIva: array of double; const AValue: double): Boolean;
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

begin
  // ---------------------------------------------------------------------------------------
  // Codice 00419 2.2.2 <DatiRiepilogo> non presente in corrispondenza di almeno un valore di 2.1.1.7.5 <AliquotaIVA> o 2.2.1.12 <AliquotaIVA>
  i := 0;
  SetLength(LListaAliquoteIvaUsate, 0);
  SetLength(LListaAliquoteIvaRiepilogo, 0);
  for LProp in ABody.DatiBeniServizi.DatiRiepilogo do
  begin
    Inc(i);
    SetLength(LListaAliquoteIvaRiepilogo, i);
    LListaAliquoteIvaRiepilogo[i - 1] := (LProp as IDatiRiepilogoType).AliquotaIVA.Value;
  end;

  for LProp in ABody.DatiGenerali.DatiGeneraliDocumento.DatiCassaPrevidenziale do
  begin
    LDatiCassaPrevidenziale := LProp as IDatiCassaPrevidenzialeType;

    // Aggiunta dell'aliquota nell'array di aliquote iva utilizzate nei dettagli documento (DatiCassaPrevidenziale)
    if not FindAliquotaIva(LListaAliquoteIvaUsate, LDatiCassaPrevidenziale.AliquotaIVA.Value) then
    begin
      SetLength(LListaAliquoteIvaUsate, Length(LListaAliquoteIvaUsate) + 1);
      LListaAliquoteIvaUsate[Length(LListaAliquoteIvaUsate) - 1] := LDatiCassaPrevidenziale.AliquotaIVA.Value;
    end;
  end;

  for LProp in ABody.DatiBeniServizi.DettaglioLinee do
  begin
    LDettaglioLinee := LProp as IDettaglioLineeType;

    // Aggiunta dell'aliquota nell'array di aliquote iva utilizzate nei dettagli documento (DettaglioLinee)
    if not FindAliquotaIva(LListaAliquoteIvaUsate, LDettaglioLinee.AliquotaIVA.Value) then
    begin
      SetLength(LListaAliquoteIvaUsate, Length(LListaAliquoteIvaUsate) + 1);
      LListaAliquoteIvaUsate[Length(LListaAliquoteIvaUsate) - 1] := LDettaglioLinee.AliquotaIVA.Value;
    end;
  end;

  // Confronto il numero delle aliquote iva dichiarate nei dati di riepilogo rispetto alle dichiarate nei dettagli documento
  if Length(LListaAliquoteIvaRiepilogo) <> Length(LListaAliquoteIvaUsate) then
  begin
    AResult.Add(TeiValidatorsFactory.NewValidatorsResult(ABody.DatiBeniServizi.DatiRiepilogo.FullQualifiedName, '00419',
      '2.2.2 <DatiRiepilogo> non presente in corrispondenza di almeno un valore di 2.1.1.7.5 <AliquotaIVA> o 2.2.1.12 <AliquotaIVA>',
      vkExtraXSD));
  end;
end;

class procedure TeiExtraXsdValidator.ValidateBody_00420(const ABody: IFatturaElettronicaBodyType;
  const AResult: IeiValidatorsResultCollection);
var
  LProp: IeIBaseProperty;
  LDatiRiepilogoType: IDatiRiepilogoType;
begin
  // ---------------------------------------------------------------------------------------
  // - Codice 00420 2.2.2.2 <Natura> con valore di tipo N6 a fronte di 2.2.2.7 <EsigibilitaIVA> uguale a S (scissione pagamenti)
  for LProp in ABody.DatiBeniServizi.DatiRiepilogo do
  begin
    LDatiRiepilogoType := (LProp as IDatiRiepilogoType);

    if (LDatiRiepilogoType.EsigibilitaIVA.Value = 'S') and
      ((LDatiRiepilogoType.Natura.Value = 'N6') or (LDatiRiepilogoType.Natura.Value = 'N6.1') or (LDatiRiepilogoType.Natura.Value = 'N6.2')
      or (LDatiRiepilogoType.Natura.Value = 'N6.3') or (LDatiRiepilogoType.Natura.Value = 'N6.4') or
      (LDatiRiepilogoType.Natura.Value = 'N6.5') or (LDatiRiepilogoType.Natura.Value = 'N6.6') or (LDatiRiepilogoType.Natura.Value = 'N6.7')
      or (LDatiRiepilogoType.Natura.Value = 'N6.8') or (LDatiRiepilogoType.Natura.Value = 'N6.9')) then
    begin
      AResult.Add(TeiValidatorsFactory.NewValidatorsResult(ABody.DatiBeniServizi.DatiRiepilogo.FullQualifiedName, '00420',
        '2.2.2.2 <Natura> con valore di tipo N6 a fronte di 2.2.2.7 <EsigibilitaIVA> uguale a S (scissione pagamenti)', vkExtraXSD));
    end;
  end;
end;

class procedure TeiExtraXsdValidator.ValidateBody_00421(const ABody: IFatturaElettronicaBodyType;
  const AResult: IeiValidatorsResultCollection);
var
  LProp: IeIBaseProperty;
  LDatiRiepilogoType: IDatiRiepilogoType;
begin
  // ---------------------------------------------------------------------------------------
  // - Codice 00421 2.2.2.6 <Imposta> non calcolato secondo le regole definite nelle specifiche tecniche
  for LProp in ABody.DatiBeniServizi.DatiRiepilogo do
  begin
    LDatiRiepilogoType := (LProp as IDatiRiepilogoType);
    if not SameValue(LDatiRiepilogoType.Imposta.Value, (LDatiRiepilogoType.AliquotaIVA.Value * LDatiRiepilogoType.ImponibileImporto.Value /
      100), 0.01) then
      AResult.Add(TeiValidatorsFactory.NewValidatorsResult(ABody.DatiBeniServizi.DatiRiepilogo.FullQualifiedName, '00421',
        '2.2.2.6 <Imposta> non calcolato secondo le regole definite nelle specifiche tecniche', vkExtraXSD));
  end;
end;

class procedure TeiExtraXsdValidator.ValidateBody_00422(const ABody: IFatturaElettronicaBodyType;
  const AResult: IeiValidatorsResultCollection);
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
begin
  // ---------------------------------------------------------------------------------------
  // - Codice 00422 2.2.2.5 <ImponibileImporto> non calcolato secondo le regole definite nelle specifiche tecniche
  for LProp in ABody.DatiBeniServizi.DatiRiepilogo do
  begin
    LDatiRiepilogoType := (LProp as IDatiRiepilogoType);

    LImponibileImporto := LDatiRiepilogoType.ImponibileImporto.Value;
    LArrotondamento := LDatiRiepilogoType.Arrotondamento.ValueDef;

    LPrezzoTotale := 0;
    for LPropLinee in ABody.DatiBeniServizi.DettaglioLinee do
    begin
      LDettaglioLinea := (LPropLinee as IDettaglioLineeType);
      if SameValue(LDettaglioLinea.AliquotaIVA.Value, LDatiRiepilogoType.AliquotaIVA.Value) then
        LPrezzoTotale := LPrezzoTotale + LDettaglioLinea.PrezzoTotale.Value;
    end;
    LImportoContrCassa := 0;
    for LPropDatiCassaPrevidenziale in ABody.DatiGenerali.DatiGeneraliDocumento.DatiCassaPrevidenziale do
    begin
      LDatiCassaPrevidenziale := (LPropDatiCassaPrevidenziale as IDatiCassaPrevidenzialeType);
      if SameValue(LDatiCassaPrevidenziale.AliquotaIVA.Value, LDatiRiepilogoType.AliquotaIVA.Value) then
        LImportoContrCassa := LImportoContrCassa + LDatiCassaPrevidenziale.ImportoContributoCassa.Value;
    end;

    if not SameValue(LImponibileImporto, LPrezzoTotale + LImportoContrCassa + LArrotondamento, 1) then
      AResult.Add(TeiValidatorsFactory.NewValidatorsResult(ABody.DatiBeniServizi.DatiRiepilogo.FullQualifiedName, '00422',
        '2.2.2.5 <ImponibileImporto> non calcolato secondo le regole definite nelle specifiche tecniche', vkExtraXSD));
  end;
end;

class procedure TeiExtraXsdValidator.ValidateBody_00423(const ABody: IFatturaElettronicaBodyType;
  const AResult: IeiValidatorsResultCollection);
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
      if (LPropScontoMaggiorazione.Tipo.Value = 'SC') then
        LSegno := -1
      else if (LPropScontoMaggiorazione.Tipo.Value = 'MG') then
        LSegno := 1
      else
        LSegno := 0;
      if not LPropScontoMaggiorazione.Percentuale.IsEmptyOrZero then
      begin
        // sconto a percentuale
        LPrezzoUnitarioNetto := LPrezzoUnitarioNetto + (LSegno * (LPrezzoUnitarioNetto * LPropScontoMaggiorazione.Percentuale.Value / 100));
      end
      else
      begin
        // sconto a valore
        LPrezzoUnitarioNetto := LPrezzoUnitarioNetto + (LSegno * LPropScontoMaggiorazione.Importo.Value);
      end;
    end;
    if not LDettaglioLinea.Quantita.IsEmptyOrZero then
      LQuantita := LDettaglioLinea.Quantita.Value
    else
      LQuantita := 1;
    // Quantità specificata
    if not SameValue(LDettaglioLinea.PrezzoTotale.Value, LPrezzoUnitarioNetto * LQuantita, 0.01000001) then
    begin
      AResult.Add(TeiValidatorsFactory.NewValidatorsResult(ABody.DatiBeniServizi.DettaglioLinee.FullQualifiedName, '00423',
        '2.2.1.11 <PrezzoTotale> non calcolato secondo le regole definite nelle specifiche tecniche', vkExtraXSD));
    end;
  end;
end;

class procedure TeiExtraXsdValidator.ValidateBody_00424(const ABody: IFatturaElettronicaBodyType;
  const AResult: IeiValidatorsResultCollection);
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
    if (not LDatiCassaPrevidenziale.AliquotaIVA.IsEmptyOrZero) and (LDatiCassaPrevidenziale.AliquotaIVA.Value < 1) then
      AResult.Add(TeiValidatorsFactory.NewValidatorsResult(ABody.DatiGenerali.DatiGeneraliDocumento.DatiCassaPrevidenziale.
        FullQualifiedName, '00424', '2.2.1.12 <AliquotaIVA> non indicata in termini percentuali', vkExtraXSD));
  end;
  // ---------------------------------------------------------------------------------------
  // 2.2.2.1 <AliquotaIVA>  AliquotaIva Linea
  for LProp in ABody.DatiBeniServizi.DettaglioLinee do
  begin
    LDettaglioLinea := (LProp as IDettaglioLineeType);
    if (not LDettaglioLinea.AliquotaIVA.IsEmptyOrZero) and (LDettaglioLinea.AliquotaIVA.Value < 1) then
      AResult.Add(TeiValidatorsFactory.NewValidatorsResult(ABody.DatiBeniServizi.DettaglioLinee.FullQualifiedName, '00424',
        '2.2.2.1< AliquotaIVA> non indicata in termini percentuali', vkExtraXSD));
  end;
  // ---------------------------------------------------------------------------------------
  // 2.1.1.7.5 <AliquotaIVA>  Dati Riepilogo
  for LProp in ABody.DatiBeniServizi.DatiRiepilogo do
  begin
    LDatiRiepilogoType := (LProp as IDatiRiepilogoType);
    if (not LDatiRiepilogoType.AliquotaIVA.IsEmptyOrZero) and (LDatiRiepilogoType.AliquotaIVA.Value < 1) then
      AResult.Add(TeiValidatorsFactory.NewValidatorsResult(ABody.DatiBeniServizi.DatiRiepilogo.FullQualifiedName, '00424',
        '2.1.1.7.5 <AliquotaIVA> non indicata in termini percentuali', vkExtraXSD));
  end;
end;

class procedure TeiExtraXsdValidator.ValidateBody_00425(const ABody: IFatturaElettronicaBodyType;
  const AResult: IeiValidatorsResultCollection);
begin
  // ---------------------------------------------------------------------------------------
  // Codice 00425 2.1.1.4 <Numero> non contenente caratteri numerici
  if not TRegEx.IsMatch(ABody.DatiGenerali.DatiGeneraliDocumento.Numero.ValueAsString, '\d') then
    AResult.Add(TeiValidatorsFactory.NewValidatorsResult(ABody.DatiGenerali.DatiGeneraliDocumento.Numero.FullQualifiedName, '00425',
      '2.1.1.4 <Numero> non contenente caratteri numerici', vkExtraXSD));
end;

class procedure TeiExtraXsdValidator.ValidateBody_00429_00430(const ABody: IFatturaElettronicaBodyType;
  const AResult: IeiValidatorsResultCollection);
var
  LProp: IeIBaseProperty;
  LDatiRiepilogo: IDatiRiepilogoType;
begin
  for LProp in ABody.DatiBeniServizi.DatiRiepilogo do
  begin
    LDatiRiepilogo := (LProp as IDatiRiepilogoType);
    // ---------------------------------------------------------------------------------------
    // - Codice 00429 2.2.2.2 <Natura> non presente a fronte di 2.2.2.1 <AliquotaIVA> pari a zero
    if (LDatiRiepilogo.Natura.IsEmptyOrZero) and (IsZero(LDatiRiepilogo.AliquotaIVA.Value)) then
      AResult.Add(TeiValidatorsFactory.NewValidatorsResult(ABody.DatiBeniServizi.DatiRiepilogo.FullQualifiedName, '00429',
        '2.2.2.2 <Natura> non presente a fronte di 2.2.2.1 <AliquotaIVA> pari a zero', vkExtraXSD));
    // ---------------------------------------------------------------------------------------
    // - Codice 00430 2.2.2.2 <Natura> presente a fronte di 2.2.2.1 <Aliquota IVA> diversa da zero
    if (not LDatiRiepilogo.Natura.IsEmptyOrZero) and (not IsZero(LDatiRiepilogo.AliquotaIVA.Value)) then
      AResult.Add(TeiValidatorsFactory.NewValidatorsResult(ABody.DatiBeniServizi.DatiRiepilogo.FullQualifiedName, '00430',
        '2.2.2.2 <Natura> presente a fronte di 2.2.2.1 <Aliquota IVA> diversa da zero', vkExtraXSD));
  end;
end;

end.
