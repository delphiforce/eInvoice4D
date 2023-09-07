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
    class procedure ValidateHeader_00427(const AHeader: IFatturaElettronicaHeaderType; const AResult: IeiValidatorsResultCollection);
    // Body validators
    class procedure ValidateBody_00400_00401(const ABody: IFatturaElettronicaBodyType; const AResult: IeiValidatorsResultCollection);
    class procedure ValidateBody_00415(const ABody: IFatturaElettronicaBodyType; const AResult: IeiValidatorsResultCollection);
  public
    class procedure Validate(const AInvoice: IFatturaElettronicaType; const AResult: IeiValidatorsResultCollection); override;
  end;

implementation

uses
  ei4D.Invoice.Prop.Interfaces, System.Math, ei4D.Validators.Factory,
  System.SysUtils;

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
    ValidateBody_00415(LBody, AResult);
    // Add body validators here
  end;
end;

class procedure TeiExtraXsdValidator.ValidateHeader(const AHeader: IFatturaElettronicaHeaderType; const AResult: IeiValidatorsResultCollection);
begin
  ValidateHeader_00427(AHeader, AResult);
  // Add header validators here
end;

class procedure TeiExtraXsdValidator.ValidateHeader_00427(const AHeader: IFatturaElettronicaHeaderType; const AResult: IeiValidatorsResultCollection);
begin
  // ---------------------------------------------------------------------------------------
  // Codice 00427 1.1.4 <CodiceDestinatario> di 7 caratteri non ammesso a fronte di 1.1.3 <FormatoTrasmissione> con valore FPA12
  if (AHeader.DatiTrasmissione.FormatoTrasmissione.ValueDef = 'FPA12') and (AHeader.DatiTrasmissione.CodiceDestinatario.ValueDef.Length = 7) then
    AResult.Add(TeiValidatorsFactory.NewValidatorsResult(AHeader.DatiTrasmissione.CodiceDestinatario.FullQualifiedName, '00427',
      '1.1.4 <CodiceDestinatario> di 7 caratteri non ammesso a fronte di 1.1.3 <FormatoTrasmissione> con valore FPA12', vkExtraXSD));
  // ---------------------------------------------------------------------------------------
  // Codice 00427 1.1.4 <CodiceDestinatario> di 6 caratteri non ammesso a fronte di 1.1.3 <FormatoTrasmissione> con valore FPR12 o FSM10
  if (AHeader.DatiTrasmissione.FormatoTrasmissione.ValueDef = 'FPR12') and (AHeader.DatiTrasmissione.CodiceDestinatario.ValueDef.Length = 6) then
    AResult.Add(TeiValidatorsFactory.NewValidatorsResult(AHeader.DatiTrasmissione.CodiceDestinatario.FullQualifiedName, '00427',
      '1.1.4 <CodiceDestinatario> di 6 caratteri non ammesso a fronte di 1.1.3 <FormatoTrasmissione> con valore FPR12', vkExtraXSD));
end;

class procedure TeiExtraXsdValidator.ValidateBody_00400_00401(const ABody: IFatturaElettronicaBodyType; const AResult: IeiValidatorsResultCollection);
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
        Format('2.2.1.14 <Natura> non presente a fronte di 2.2.1.12 <AliquotaIVA> pari a zero (linea %d)', [LDettaglioLinea.NumeroLinea.ValueDef]), vkExtraXSD));
    // ---------------------------------------------------------------------------------------
    // - Codice 00401 2.2.1.14 <Natura> presente a fronte di 2.2.1.12 <AliquotaIVA> diversa da zero
    if (not LDettaglioLinea.AliquotaIVA.IsEmptyOrZero) and (not LDettaglioLinea.Natura.IsEmptyOrZero) then
      AResult.Add(TeiValidatorsFactory.NewValidatorsResult(LDettaglioLinea.FullQualifiedName, '00401',
        Format('2.2.1.14 <Natura> presente a fronte di 2.2.1.12 <AliquotaIVA> diversa da zero (linea %d)', [LDettaglioLinea.NumeroLinea.ValueDef]), vkExtraXSD));
  end;
end;

class procedure TeiExtraXsdValidator.ValidateBody_00415(const ABody: IFatturaElettronicaBodyType; const AResult: IeiValidatorsResultCollection);
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

end.
