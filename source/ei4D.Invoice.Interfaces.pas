unit ei4D.Invoice.Interfaces;

interface

uses
  ei4D.Attributes, ei4D.Invoice.Prop.Interfaces,
  ei4D.GenericCollection.Interfaces;

type

  // USED IN: [1.2.5]
  IContattiType = interface(IeiBlock)
    ['{446AFB1D-11AD-4BBF-A216-55AD5A4CBD71}']
    [eiProp(1, o01, 5, 12)]
    function Telefono: IeiString;
    [eiProp(2, o01, 5, 12)]
    function Fax: IeiString;
    [eiProp(3, o01, 7, 256)]
    function Email: IeiString;
  end;

  // USED IN: [1.2.2, 1.2.3]
  IIndirizzoType = interface(IeiBlock)
    ['{EEBAFE77-4E37-43D0-AC50-9022227BEADB}']
    [eiProp(1, o11, 1, 60)]
    function Indirizzo: IeiString;
    [eiProp(2, o01, 1, 8)]
    function NumeroCivico: IeiString;
    [eiProp(3, o11, 5, 5)]
    function CAP: IeiString;
    [eiProp(4, o11, 1, 60)]
    function Comune: IeiString;
    [eiProp(5, o01, 2, 2), eiRegEx('^[A-Z]{2}$')]
    function Provincia: IeiString;
    // [eiProp(6, o11, 2, 2), eiRegEx('^[A-Z]{2}$')]
    [eiProp(6, o11, 0, 2), eiRegEx('^[A-Z]{0,2}$')]
    function Nazione: IeiString;
  end;

  // USED IN: [1.2.1, 1.1]
  IIdFiscaleType = interface(IeiBlock)
    ['{19E8DD8A-DC6C-4A6D-92F8-972C9F25319E}']
    [eiProp(1, o11, 2, 2), eiRegEx('^[A-Z]{2}$')]
    function IdPaese: IeiString;
    [eiProp(2, o11, 1, 28)]
    function IdCodice: IeiString;
  end;

  // USED IN: [1.2.1]
  IAnagraficaType = interface(IeiBlock)
    ['{BDE73096-491D-4ADB-9C26-575E2DF39CBE}']
    [eiProp(1, o01, 1, 80)]
    function Denominazione: IeiString;
    [eiProp(2, o01, 1, 60)]
    function Nome: IeiString;
    [eiProp(3, o01, 1, 60)]
    function Cognome: IeiString;
    [eiProp(4, o01, 2, 10)]
    function Titolo: IeiString;
    [eiProp(5, o01, 13, 17)]
    function CodEORI: IeiString;
  end;

  // USED IN: [1.4]
  IRappresentanteFiscaleCessionarioType = interface(IeiBlock)
    ['{DB41CE79-529B-44AD-B658-5F5F2DB17CE0}']
    [eiBlock(1, o11)]
    function IdFiscaleIVA: IIdFiscaleType;
    [eiProp(2, o01, 1, 80)]
    function Denominazione: IeiString;
    [eiProp(3, o01, 1, 60)]
    function Nome: IeiString;
    [eiProp(4, o01, 1, 60)]
    function Cognome: IeiString;
  end;

  // USED IN: [1.5.1]
  IDatiAnagraficiTerzoIntermediarioType = interface(IeiBlock)
    ['{B162B489-CED8-4ABA-97A8-73B88D6EADE8}']
    [eiBlock(1, o01)]
    function IdFiscaleIVA: IIdFiscaleType;
    [eiProp(2, o01, 11, 16)] (* ,eiRegEx('^[A-Z0-9]{11,16}$')] *)
    function CodiceFiscale: IeiString;
    [eiBlock(3, o11)]
    function Anagrafica: IAnagraficaType;
  end;

  // USED IN: [1.4]
  IDatiAnagraficiCessionarioType = interface(IeiBlock)
    ['{70B37729-891E-4505-98B6-65357B70CF50}']
    [eiBlock(1, o01)]
    function IdFiscaleIVA: IIdFiscaleType;
    [eiProp(2, o01, 11, 16)] (* ,eiRegEx('^[A-Z0-9]{11,16}$')] *)
    function CodiceFiscale: IeiString;
    [eiBlock(3, o11)]
    function Anagrafica: IAnagraficaType;
  end;

  // USED IN: [1.3]
  IDatiAnagraficiRappresentanteType = interface(IeiBlock)
    ['{A055B04C-BB78-4D68-BCB0-A864AB01957A}']
    [eiBlock(1, o11)]
    function IdFiscaleIVA: IIdFiscaleType;
    [eiProp(2, o01, 11, 16)] (* ,eiRegEx('^[A-Z0-9]{11,16}$')] *)
    function CodiceFiscale: IeiString;
    [eiBlock(3, o11)]
    function Anagrafica: IAnagraficaType;
  end;

  // USED IN: [1.2]
  IDatiAnagraficiCedenteType = interface(IeiBlock)
    ['{EBDAB68D-BA13-4CFB-899C-43C70F0A7224}']
    [eiBlock(1, o11)]
    function IdFiscaleIVA: IIdFiscaleType;
    [eiProp(2, o01, 11, 16)] (* ,eiRegEx('^[A-Z0-9]{11,16}$')] *)
    function CodiceFiscale: IeiString;
    [eiBlock(3, o11)]
    function Anagrafica: IAnagraficaType;
    [eiProp(4, o01, 1, 60)]
    function AlboProfessionale: IeiString;
    [eiProp(5, o01, 2, 2), eiRegEx('^[A-Z]{2}$')]
    function ProvinciaAlbo: IeiString;
    [eiProp(6, o01, 1, 60)]
    function NumeroIscrizioneAlbo: IeiString;
    [eiProp(7, o01, 10, 10)]
    function DataIscrizioneAlbo: IeiDate;
    [eiProp(8, o11, 4, 4), eiRegEx('RF01|RF02|RF04|RF05|RF06|RF07|RF08|RF09|RF10|RF11|RF12|RF13|RF14|RF15|RF16|RF17|RF18|RF19|RF20')]
    function RegimeFiscale: IeiString;
  end;

  // ID: 1.2.4
  IIscrizioneREAType = interface(IeiBlock)
    ['{ED54E8C3-8F0F-4D9A-A9D8-89159C2F9EE7}']
    [eiProp(1, o11, 2, 2), eiRegEx('^[A-Z]{2}$')]
    function Ufficio: IeiString;
    [eiProp(2, o11, 1, 20)]
    function NumeroREA: IeiString;
    [eiProp(3, o01, 4, 15)]
    function CapitaleSociale: IeiDecimal;
    [eiProp(4, o01, 2, 2), eiRegEx('SU|SM')]
    function SocioUnico: IeiString;
    [eiProp(5, o11, 2, 2), eiRegEx('LS|LN')]
    function StatoLiquidazione: IeiString;
  end;

  // ID: 1.5
  ITerzoIntermediarioSoggettoEmittenteType = interface(IeiBlock)
    ['{4341E58A-A3BD-4386-BE54-BF95179A507A}']
    [eiBlock(1, o11)]
    function DatiAnagrafici: IDatiAnagraficiTerzoIntermediarioType;
  end;

  // ID: 1.4
  ICessionarioCommittenteType = interface(IeiBlock)
    ['{D8428F8A-6B94-4546-897E-EE685EC78F2D}']
    [eiBlock(1, o11)]
    function DatiAnagrafici: IDatiAnagraficiCessionarioType;
    [eiBlock(2, o11)]
    function Sede: IIndirizzoType;
    [eiBlock(3, o01)]
    function StabileOrganizzazione: IIndirizzoType;
    [eiBlock(4, o01)]
    function RappresentanteFiscale: IRappresentanteFiscaleCessionarioType;
  end;

  // ID: 1.3
  IRappresentanteFiscaleType = interface(IeiBlock)
    ['{6B267E01-4790-4CB9-8471-092271EE7B6A}']
    [eiBlock(1, o11)]
    function DatiAnagrafici: IDatiAnagraficiRappresentanteType;
  end;

  // ID: 1.2
  ICedentePrestatoreType = interface(IeiBlock)
    ['{7F3FD4FD-9734-41DE-864E-27D53ABB74C1}']
    [eiBlock(1, o11)]
    function DatiAnagrafici: IDatiAnagraficiCedenteType;
    [eiBlock(2, o11)]
    function Sede: IIndirizzoType;
    [eiBlock(3, o01)]
    function StabileOrganizzazione: IIndirizzoType;
    [eiBlock(4, o01)]
    function IscrizioneREA: IIscrizioneREAType;
    [eiBlock(5, o01)]
    function Contatti: IContattiType;
    [eiProp(6, o01, 1, 20)]
    function RiferimentoAmministrazione: IeiString;
  end;

  // ID: 1.1.5
  IContattiTrasmittenteType = interface(IeiBlock)
    ['{03F5C39F-EA87-4A38-BE41-3B7ABF3D7EE5}']
    [eiProp(1, o01, 5, 12)]
    function Telefono: IeiString;
    [eiProp(2, o01, 7, 256)]
    function Email: IeiString;
  end;

  // ID: 1.1.1
  IIdTrasmittenteType = interface(IeiBlock)
    ['{0CF9B862-DD3C-405A-AB0B-C366EF1B41EC}']
    [eiProp(1, o11, 2, 2), eiRegEx('^[A-Z]{2}$')]
    function IdPaese: IeiString;
    [eiProp(2, o11, 1, 28)]
    function IdCodice: IeiString;
  end;

  // ID: 1.1
  IDatiTrasmissioneType = interface(IeiBlock)
    ['{0C1398C5-3955-4D87-AB55-86A8D0C7A41D}']
    [eiBlock(1, o11)]
    function IdTrasmittente: IIdFiscaleType;
    [eiProp(2, o11, 1, 10)]
    function ProgressivoInvio: IeiString;
    [eiProp(3, o11, 5, 5), eiRegEx('FPA12|FPR12')]
    function FormatoTrasmissione: IeiString;
    [eiProp(4, o11, 6, 7), eiRegEx('^[A-Z0-9]{6,7}$')]
    function CodiceDestinatario: IeiString;
    [eiBlock(5, o01)]
    function ContattiTrasmittente: IContattiTrasmittenteType;
    [eiProp(6, o01, 7, 256)]
    function PECDestinatario: IeiString;
  end;

  // USED IN: [1.1]
  IFatturaElettronicaHeaderType = interface(IeiBlock)
    ['{B569FA15-2FC8-4896-B457-FE23B17B164C}']
    [eiBlock(1, o11)]
    function DatiTrasmissione: IDatiTrasmissioneType;
    [eiBlock(2, o11)]
    function CedentePrestatore: ICedentePrestatoreType;
    [eiBlock(3, o01)]
    function RappresentanteFiscale: IRappresentanteFiscaleType;
    [eiBlock(4, o11)]
    function CessionarioCommittente: ICessionarioCommittenteType;
    [eiBlock(5, o01)]
    function TerzoIntermediarioOSoggettoEmittente: ITerzoIntermediarioSoggettoEmittenteType;
    [eiProp(6, o01, 2, 2), eiRegEx('CC|TZ')]
    function SoggettoEmittente: IeiString;
  end;

  // ID: 2.1.8
  IDatiDDTType = interface(IeiBlock)
    ['{9532249E-BB96-40E2-BE3B-B13C3D0A74C2}']
    [eiProp(1, o11, 1, 20)]
    function NumeroDDT: IeiString;
    [eiProp(2, o11, 10, 10)]
    function DataDDT: IeiDate;
    [eiList(3, o0N, 1, 4)]
    function RiferimentoNumeroLinea: IeiList<IeiInteger>;
  end;

  // ID: 2.1.9.1
  IDatiAnagraficiVettoreType = interface(IeiBlock)
    ['{07489FC3-EA5C-4AC2-913E-F158862F77DA}']
    [eiBlock(1, o11)]
    function IdFiscaleIVA: IIdFiscaleType;
    [eiProp(2, o01, 11, 16)] (* ,eiRegEx('^[A-Z0-9]{11,16}$')] *)
    function CodiceFiscale: IeiString;
    [eiBlock(3, o11)]
    function Anagrafica: IAnagraficaType;
    [eiProp(4, o01, 1, 20)]
    function NumeroLicenzaGuida: IeiString;
  end;

  // ID: 2.1.9
  IDatiTrasportoType = interface(IeiBlock)
    ['{42C58E1E-72E1-4F2E-9809-6B84DDA0929F}']
    [eiBlock(1, o01)]
    function DatiAnagraficiVettore: IDatiAnagraficiVettoreType;
    [eiProp(2, o01, 1, 80)]
    function MezzoTrasporto: IeiString;
    [eiProp(3, o01, 1, 100)]
    function CausaleTrasporto: IeiString;
    [eiProp(4, o01, 1, 4)]
    function NumeroColli: IeiInteger;
    [eiProp(5, o01, 1, 100)]
    function Descrizione: IeiString;
    [eiProp(6, o01, 1, 10)]
    function UnitaMisuraPeso: IeiString;
    [eiProp(7, o01, 4, 7)]
    function PesoLordo: IeiDecimal;
    [eiProp(8, o01, 4, 7)]
    function PesoNetto: IeiDecimal;
    [eiProp(9, o01, 19, 19)]
    function DataOraRitiro: IeiDateTime;
    [eiProp(10, o01, 10, 10)]
    function DataInizioTrasporto: IeiDate;
    [eiProp(11, o01, 3, 3), eiRegEx('^[A-Z]{3}$')]
    function TipoResa: IeiString;
    [eiBlock(12, o01)]
    function IndirizzoResa: IIndirizzoType;
    [eiProp(13, o01, 19, 19)]
    function DataOraConsegna: IeiDateTime;
  end;

  // ID: 2.1.7
  IDatiSALType = interface(IeiBlock)
    ['{F6E6CC36-36B8-445B-AF42-454584E7AE4A}']
    [eiProp(1, o11, 1, 3)]
    function RiferimentoFase: IeiInteger;
  end;

  // USED IN: [2.1.2, 2.1.3, 2.1.4, 2.1.5, 2.1.6]
  IDatiDocumentiCorrelatiType = interface(IeiBlock)
    ['{67CB6F8C-8833-424A-BC3A-536AE3C84ACB}']
    [eiList(1, o0N, 1, 4)]
    function RiferimentoNumeroLinea: IeiList<IeiInteger>;
    [eiProp(2, o11, 1, 20)]
    function IdDocumento: IeiString;
    [eiProp(3, o01, 10, 10)]
    function Data: IeiDate;
    [eiProp(4, o01, 1, 20)]
    function NumItem: IeiString;
    [eiProp(5, o01, 1, 100)]
    function CodiceCommessaConvenzione: IeiString;
    [eiProp(6, o01, 1, 15)]
    function CodiceCUP: IeiString;
    [eiProp(7, o01, 1, 15)]
    function CodiceCIG: IeiString;
  end;

  // ID: 2.1.1.8
  IScontoMaggiorazioneType = interface(IeiBlock)
    ['{EECF1603-27F5-4E1C-A624-FA8A8CFD3993}']
    [eiProp(1, o11, 2, 2), eiRegEx('SC|MG')]
    function Tipo: IeiString;
    [eiProp(2, o01, 4, 6)]
    function Percentuale: IeiDecimal;
    [eiProp(3, o01, 4, 21)]
    // , eiRowCurrency, eiMaxDecimals(8)]
    function Importo: IeiDecimal;
  end;

  // ID: 2.1.1.7
  IDatiCassaPrevidenzialeType = interface(IeiBlock)
    ['{64D1C712-60CB-4AFF-8ED0-0EC3B466647A}']
    [eiProp(1, o11, 4, 4),
      eiRegEx('TC01|TC02|TC03|TC04|TC05|TC06|TC07|TC08|TC09|TC10|TC11|TC12|TC13|TC14|TC15|TC16|TC17|TC18|TC19|TC20|TC21|TC22')]
    function TipoCassa: IeiString;
    [eiProp(2, o11, 4, 6)]
    function AlCassa: IeiDecimal;
    [eiProp(3, o11, 4, 15)]
    function ImportoContributoCassa: IeiDecimal;
    [eiProp(4, o01, 4, 15)]
    function ImponibileCassa: IeiDecimal;
    [eiProp(5, o11, 4, 6)]
    function AliquotaIVA: IeiDecimal;
    [eiProp(6, o01, 2, 2)]
    function Ritenuta: IeiString;
    [eiProp(7, o01, 2, 4), eiRegEx('N1|N2.1|N2.2|N3.1|N3.2|N3.3|N3.4|N3.5|N3.6|N4|N5|N6.1|N6.2|N6.3|N6.4|N6.5|N6.6|N6.7|N6.8|N6.9|N7')]
    function Natura: IeiString;
    [eiProp(8, o01, 1, 20)]
    function RiferimentoAmministrazione: IeiString;
  end;

  // ID: 2.1.1.6
  IDatiBolloType = interface(IeiBlock)
    ['{53681255-21FA-4015-829F-DA5EF124DE1C}']
    [eiProp(1, o11, 2, 2), eiRegEx('SI')]
    function BolloVirtuale: IeiString;
    [eiProp(2, o01, 4, 15)]
    function ImportoBollo: IeiDecimal;
  end;

  // ID: 2.1.1.5
  IDatiRitenutaType = interface(IeiBlock)
    ['{DBFCDE27-32DA-44DA-8079-73B2D9879013}']
    [eiProp(1, o11, 4, 4), eiRegEx('RT01|RT02|RT03|RT04|RT05|RT06')]
    function TipoRitenuta: IeiString;
    [eiProp(2, o11, 4, 15)]
    function ImportoRitenuta: IeiDecimal;
    [eiProp(3, o11, 4, 6)]
    function AliquotaRitenuta: IeiDecimal;
    [eiProp(4, o11, 1, 2), eiRegEx('^(([ABCDEFGHILMNOPQRSTUVWXY]){1})$|^(L1|M1)$')]
    function CausalePagamento: IeiString;
  end;

  // ID: 2.1.1
  IDatiGeneraliDocumentoType = interface(IeiBlock)
    ['{540CBE61-D4C2-44F7-990E-DCF30C204027}']
    [eiProp(1, o11, 4, 4), eiRegEx('TD01|TD02|TD03|TD04|TD05|TD06|TD16|TD17|TD18|TD19|TD20|TD21|TD22|TD23|TD24|TD25|TD26|TD27|TD28|TD29')]
    function TipoDocumento: IeiString;
    [eiProp(2, o11, 3, 3), eiRegEx('^[A-Z]{3}$')]
    function Divisa: IeiString;
    [eiProp(3, o11, 10, 10)]
    function Data: IeiDate;
    [eiProp(4, o11, 1, 20)]
    function Numero: IeiString;
    [eiList(5, o0N)]
    function DatiRitenuta: IeiList<IDatiRitenutaType>;
    [eiBlock(6, o01)]
    function DatiBollo: IDatiBolloType;
    [eiList(7, o0N)]
    function DatiCassaPrevidenziale: IeiList<IDatiCassaPrevidenzialeType>;
    [eiList(8, o0N)]
    function ScontoMaggiorazione: IeiList<IScontoMaggiorazioneType>;
    [eiProp(9, o01, 4, 15)]
    function ImportoTotaleDocumento: IeiDecimal;
    [eiProp(10, o01, 4, 15)]
    function Arrotondamento: IeiDecimal;
    [eiList(11, o0N, 1, 200)]
    function Causale: IeiList<IeiString>;
    [eiProp(12, o01, 2, 2), eiRegEx('SI')]
    function Art73: IeiString;
  end;

  // ID: 2.1.10
  IFatturaPrincipaleType = interface(IeiBlock)
    ['{5329B95F-4517-4D6B-BD38-6BCDB721C092}']
    [eiProp(1, o11, 1, 20)]
    function NumeroFatturaPrincipale: IeiString;
    [eiProp(2, o11, 10, 10)]
    function DataFatturaPrincipale: IeiDate;
  end;

  // ID: 2.1
  IDatiGeneraliType = interface(IeiBlock)
    ['{CEAFBFC2-3A11-4E70-87E8-136208F9FFC7}']
    [eiBlock(1, o11)]
    function DatiGeneraliDocumento: IDatiGeneraliDocumentoType;
    [eiList(2, o0N)]
    function DatiOrdineAcquisto: IeiList<IDatiDocumentiCorrelatiType>;
    [eiList(3, o0N)]
    function DatiContratto: IeiList<IDatiDocumentiCorrelatiType>;
    [eiList(4, o0N)]
    function DatiConvenzione: IeiList<IDatiDocumentiCorrelatiType>;
    [eiList(5, o0N)]
    function DatiRicezione: IeiList<IDatiDocumentiCorrelatiType>;
    [eiList(6, o0N)]
    function DatiFattureCollegate: IeiList<IDatiDocumentiCorrelatiType>;
    [eiList(7, o0N)]
    function DatiSAL: IeiList<IDatiSALType>;
    [eiList(8, o0N)]
    function DatiDDT: IeiList<IDatiDDTType>;
    [eiBlock(9, o01)]
    function DatiTrasporto: IDatiTrasportoType;
    [eiBlock(10, o01)]
    function FatturaPrincipale: IFatturaPrincipaleType;
  end;

  // ID: 1.2.5
  IAllegatiType = interface(IeiBlock)
    ['{140ACCBC-8495-4C4E-BE66-74707421DB31}']
    [eiProp(1, o11, 1, 60)]
    function NomeAttachment: IeiString;
    [eiProp(2, o01, 1, 10)]
    function AlgoritmoCompressione: IeiString;
    [eiProp(3, o01, 1, 10)]
    function FormatoAttachment: IeiString;
    [eiProp(4, o01, 1, 100)]
    function DescrizioneAttachment: IeiString;
    [eiBase64(5, o11)]
    function Attachment: IeiBase64;
  end;

  // ID: 2.2.1.16
  IAltriDatiGestionaliType = interface(IeiBlock)
    ['{EC760CBC-AB52-4145-8AF6-8F7C48F771C4}']
    [eiProp(1, o11, 1, 10)]
    function TipoDato: IeiString;
    [eiProp(2, o01, 1, 60)]
    function RiferimentoTesto: IeiString;
    [eiProp(3, o01, 4, 21)]
    function RiferimentoNumero: IeiDecimal;
    [eiProp(4, o01, 10, 10)]
    function RiferimentoData: IeiDate;
  end;

  // ID: 2.2.1.3
  ICodiceArticoloType = interface(IeiBlock)
    ['{3235670C-9F34-408E-AF02-BF5D4D34B102}']
    [eiProp(1, o11, 1, 35)]
    function CodiceTipo: IeiString;
    [eiProp(2, o11, 1, 35)]
    function CodiceValore: IeiString;
  end;

  // ID: 2.2.1
  IDettaglioLineeType = interface(IeiBlock)
    ['{A27AE555-17D7-436D-8AEF-08DFDC89D7DC}']
    [eiProp(1, o11, 1, 4)]
    function NumeroLinea: IeiInteger;
    [eiProp(2, o01, 2, 2), eiRegEx('SC|PR|AB|AC')]
    function TipoCessionePrestazione: IeiString;
    [eiList(3, o0N)]
    function CodiceArticolo: IeiList<ICodiceArticoloType>;
    [eiProp(4, o11, 1, 1000)]
    function Descrizione: IeiString;
    [eiProp(5, o01, 4, 21), eiRowQuantity, eiMaxDecimals(8), eiRegEx('^[0-9]{1,12}\.[0-9]{2,8}$')]
    function Quantita: IeiDecimal;
    [eiProp(6, o01, 1, 10)]
    function UnitaMisura: IeiString;
    [eiProp(7, o01, 10, 10)]
    function DataInizioPeriodo: IeiDate;
    [eiProp(8, o01, 10, 10)]
    function DataFinePeriodo: IeiDate;
    [eiProp(9, o11, 4, 21), eiRowCurrency, eiMaxDecimals(8)]
    function PrezzoUnitario: IeiDecimal;
    [eiList(10, o0N)]
    function ScontoMaggiorazione: IeiList<IScontoMaggiorazioneType>;
    [eiProp(11, o11, 4, 21), eiRowCurrency, eiMaxDecimals(8)]
    function PrezzoTotale: IeiDecimal;
    [eiProp(12, o11, 4, 6)]
    function AliquotaIVA: IeiDecimal;
    [eiProp(13, o01, 2, 2), eiRegEx('SI')]
    function Ritenuta: IeiString;
    [eiProp(14, o01, 2, 4), eiRegEx('N1|N2.1|N2.2|N3.1|N3.2|N3.3|N3.4|N3.5|N3.6|N4|N5|N6.1|N6.2|N6.3|N6.4|N6.5|N6.6|N6.7|N6.8|N6.9|N7')]
    function Natura: IeiString;
    [eiProp(15, o01, 1, 20)]
    function RiferimentoAmministrazione: IeiString;
    [eiList(16, o0N)]
    function AltriDatiGestionali: IeiList<IAltriDatiGestionaliType>;
  end;

  // ID: 2.2.2
  IDatiRiepilogoType = interface(IeiBlock)
    ['{1B817E26-ED0F-41A6-B1CD-953193529933}']
    [eiProp(1, o11, 4, 6)]
    function AliquotaIVA: IeiDecimal;
    [eiProp(2, o01, 2, 4), eiRegEx('N1|N2.1|N2.2|N3.1|N3.2|N3.3|N3.4|N3.5|N3.6|N4|N5|N6.1|N6.2|N6.3|N6.4|N6.5|N6.6|N6.7|N6.8|N6.9|N7')]
    function Natura: IeiString;
    [eiProp(3, o01, 4, 15)]
    function SpeseAccessorie: IeiDecimal;
    [eiProp(4, o01, 4, 21)]
    function Arrotondamento: IeiDecimal;
    [eiProp(5, o11, 4, 15)]
    function ImponibileImporto: IeiDecimal;
    [eiProp(6, o11, 4, 15)]
    function Imposta: IeiDecimal;
    [eiProp(7, o01, 1, 1), eiRegEx('D|I|S')]
    function EsigibilitaIVA: IeiString;
    [eiProp(8, o01, 1, 100)]
    function RiferimentoNormativo: IeiString;
  end;

  // ID: 2.2
  IDatiBeniServiziType = interface(IeiBlock)
    ['{82C1E1B3-E6EE-4E24-8A87-EF821CD64AB7}']
    [eiList(1, o1N)]
    function DettaglioLinee: IeiList<IDettaglioLineeType>;
    [eiList(2, o1N)]
    function DatiRiepilogo: IeiList<IDatiRiepilogoType>;
  end;

  // ID: 2.3
  IDatiVeicoliType = interface(IeiBlock)
    ['{2F1BFE81-8577-4815-8F55-24A1B0A5AF7B}']
    [eiProp(1, o11, 10, 10)]
    function Data: IeiDate;
    [eiProp(2, o11, 1, 15)]
    function TotalePercorso: IeiString;
  end;

  // ID. 2.4.2
  IDettaglioPagamentoType = interface(IeiBlock)
    ['{DBB70934-AC84-4C80-A7C6-9BC8DB7BB048}']
    [eiProp(1, o01, 1, 200)]
    function Beneficiario: IeiString;
    [eiProp(2, o11, 4, 4),
      eiRegEx('MP01|MP02|MP03|MP04|MP05|MP06|MP07|MP08|MP09|MP10|MP11|MP12|MP13|MP14|MP15|MP16|MP17|MP18|MP19|MP20|MP21|MP22|MP23')
      ]
    function ModalitaPagamento: IeiString;
    [eiProp(3, o01, 10, 10)]
    function DataRiferimentoTerminiPagamento: IeiDate;
    [eiProp(4, o01, 1, 3)]
    function GiorniTerminiPagamento: IeiInteger;
    [eiProp(5, o01, 10, 10)]
    function DataScadenzaPagamento: IeiDate;
    [eiProp(6, o11, 4, 15)]
    function ImportoPagamento: IeiDecimal;
    [eiProp(7, o01, 1, 20)]
    function CodUfficioPostale: IeiString;
    [eiProp(8, o01, 1, 60)]
    function CognomeQuietanzante: IeiString;
    [eiProp(9, o01, 1, 60)]
    function NomeQuietanzante: IeiString;
    [eiProp(10, o01, 16, 16)] (* ,eiRegEx('^[A-Z0-9]{11,16}$')] *)
    function CFQuietanzante: IeiString;
    [eiProp(11, o01, 2, 10)]
    function TitoloQuietanzante: IeiString;
    [eiProp(12, o01, 1, 80)]
    function IstitutoFinanziario: IeiString;
    [eiProp(13, o01, 15, 34)]
    function IBAN: IeiString;
    [eiProp(14, o01, 5, 5), eiRegEx('^[0-9]{5}$')]
    function ABI: IeiString;
    [eiProp(15, o01, 5, 5), eiRegEx('^[0-9]{5}$')]
    function CAB: IeiString;
    [eiProp(16, o01, 8, 11)]
    function BIC: IeiString;
    [eiProp(17, o01, 4, 15)]
    function ScontoPagamentoAnticipato: IeiDecimal;
    [eiProp(18, o01, 10, 10)]
    function DataLimitePagamentoAnticipato: IeiDate;
    [eiProp(19, o01, 4, 15)]
    function PenalitaPagamentiRitardati: IeiDecimal;
    [eiProp(20, o01, 10, 10)]
    function DataDecorrenzaPenale: IeiDate;
    [eiProp(21, o01, 1, 60)]
    function CodicePagamento: IeiString;
  end;

  // ID. 2.4
  IDatiPagamentoType = interface(IeiBlock)
    ['{61CC85C4-1DEC-410D-8D41-BF25C276D44B}']
    [eiProp(1, o11, 4, 4), eiRegEx('TP01|TP02|TP03')]
    function CondizioniPagamento: IeiString;
    [eiList(2, o1N)]
    function DettaglioPagamento: IeiList<IDettaglioPagamentoType>;
  end;

  // ID: 2
  IFatturaElettronicaBodyType = interface(IeiBlock)
    ['{2690076D-A79B-47CB-B56D-86F9434D67C6}']
    [eiBlock(1, o11)]
    function DatiGenerali: IDatiGeneraliType;
    [eiBlock(2, o11)]
    function DatiBeniServizi: IDatiBeniServiziType;
    [eiBlock(3, o01)]
    function DatiVeicoli: IDatiVeicoliType;
    [eiList(4, o0N)]
    function DatiPagamento: IeiList<IDatiPagamentoType>;
    [eiList(5, o0N)]
    function Allegati: IeiList<IAllegatiType>;
  end;

  // ID: 1
  IFatturaElettronicaType = interface(IeiBlock)
    ['{FD813671-4E2F-44BA-827B-F2F15FADD5E4}']
    [eiBlock(1, o11)]
    function FatturaElettronicaHeader: IFatturaElettronicaHeaderType;
    [eiList(2, o1N)]
    function FatturaElettronicaBody: IeiList<IFatturaElettronicaBodyType>;
  end;

  IeiInvoiceCollection = IeiCollection<IFatturaElettronicaType>;

  IeiInvoiceIDCollection = IeiCollection<string>;

implementation

end.
