unit FormMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls;

type
  TMainForm = class(TForm)
    MemoXml: TMemo;
    panelActions: TPanel;
    panelXml: TPanel;
    Label1: TLabel;
    Label2: TLabel;
    buttonCreate: TButton;
    CheckBoxSaveToFile: TCheckBox;
    SaveDialog1: TSaveDialog;
    procedure buttonCreateClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  MainForm: TMainForm;

implementation

uses
  ei4D;

{$R *.dfm}

procedure TMainForm.buttonCreateClick(Sender: TObject);
var
  LInvoice: IFatturaElettronicaType;
  LInvoiceBody: IFatturaElettronicaBodyType;
  LDatiRiepilogo: IDatiRiepilogoType;
  LResult: IeiValidatorsResultCollection;
  LItem: IeiValidatorsResult;
  LMsg: String;
begin
  // All library calls start with "ei."
  LInvoice := ei.NewInvoice;

  // LInvoice.FatturaElettronicaHeader.DatiTrasmissione
  LInvoice.FatturaElettronicaHeader.DatiTrasmissione.IdTrasmittente.IdCodice.Value := '13459520154';
  LInvoice.FatturaElettronicaHeader.DatiTrasmissione.IdTrasmittente.IdPaese.Value := 'IT';
  LInvoice.FatturaElettronicaHeader.DatiTrasmissione.ProgressivoInvio.Value := '123';
  LInvoice.FatturaElettronicaHeader.DatiTrasmissione.FormatoTrasmissione.Value := 'FPR12';
  LInvoice.FatturaElettronicaHeader.DatiTrasmissione.CodiceDestinatario.Value := '0000000';

  // LInvoice.FatturaElettronicaHeader.CedentePrestatore
  LInvoice.FatturaElettronicaHeader.CedentePrestatore.DatiAnagrafici.IdFiscaleIVA.IdPaese.Value := 'IT';
  LInvoice.FatturaElettronicaHeader.CedentePrestatore.DatiAnagrafici.IdFiscaleIVA.IdCodice.Value := '12345678901';
  LInvoice.FatturaElettronicaHeader.CedentePrestatore.DatiAnagrafici.CodiceFiscale.Value := '12345678901';
  LInvoice.FatturaElettronicaHeader.CedentePrestatore.DatiAnagrafici.Anagrafica.Denominazione.Value := 'ACME & € C. SRL';
  LInvoice.FatturaElettronicaHeader.CedentePrestatore.DatiAnagrafici.RegimeFiscale.Value := 'RF01';
  LInvoice.FatturaElettronicaHeader.CedentePrestatore.Sede.Indirizzo.Value := 'VIA ROMA 4/D';
  LInvoice.FatturaElettronicaHeader.CedentePrestatore.Sede.CAP.Value := '25100';
  LInvoice.FatturaElettronicaHeader.CedentePrestatore.Sede.Comune.Value := 'MILANO';
  LInvoice.FatturaElettronicaHeader.CedentePrestatore.Sede.Provincia.Value := 'MI';
  LInvoice.FatturaElettronicaHeader.CedentePrestatore.Sede.Nazione.Value := 'IT';

  // LInvoice.FatturaElettronicaHeader.CessionarioCommittente
  LInvoice.FatturaElettronicaHeader.CessionarioCommittente.DatiAnagrafici.IdFiscaleIVA.IdPaese.Value := 'IT';
  LInvoice.FatturaElettronicaHeader.CessionarioCommittente.DatiAnagrafici.IdFiscaleIVA.IdCodice.Value := '12345678901';
  LInvoice.FatturaElettronicaHeader.CessionarioCommittente.DatiAnagrafici.Anagrafica.Denominazione.Value := 'COMMITTENTE S.R.L.';
  LInvoice.FatturaElettronicaHeader.CessionarioCommittente.Sede.Indirizzo.Value := 'VIA NAPOLI 10';
  LInvoice.FatturaElettronicaHeader.CessionarioCommittente.Sede.CAP.Value := '20200';
  LInvoice.FatturaElettronicaHeader.CessionarioCommittente.Sede.Comune.Value := 'TORINO';
  LInvoice.FatturaElettronicaHeader.CessionarioCommittente.Sede.Provincia.Value := 'TO';
  LInvoice.FatturaElettronicaHeader.CessionarioCommittente.Sede.Nazione.Value := 'IT';

  // LInvoice.FatturaElettronicaBody (variable)
  LInvoiceBody := LInvoice.FatturaElettronicaBody.Add;

  // LInvoiceBody.DatiGenerali.DatiGeneraliDocumento
  LInvoiceBody.DatiGenerali.DatiGeneraliDocumento.TipoDocumento.Value := 'TD01';
  LInvoiceBody.DatiGenerali.DatiGeneraliDocumento.Divisa.Value := 'EUR';
  LInvoiceBody.DatiGenerali.DatiGeneraliDocumento.Data.Value := Date;
  LInvoiceBody.DatiGenerali.DatiGeneraliDocumento.Numero.Value := '1';
  LInvoiceBody.DatiGenerali.DatiGeneraliDocumento.ImportoTotaleDocumento.Value := 15.25;

  // LInvoiceBody.DatiBeniServizi.DettaglioLinee (with)
  with LInvoiceBody.DatiBeniServizi.DettaglioLinee.Add do
  begin
    NumeroLinea.Value := 1;
    Descrizione.Value := 'PIADINA PROSCIUTTO CRUDO, RUCOLA E SQUACQUERONE';
    Quantita.Value := 1;
    UnitaMisura.Value := 'NR';
    PrezzoUnitario.Value := 6.5;
    PrezzoTotale.Value := 6.5;
    AliquotaIVA.Value := 22;
  end;
  with LInvoiceBody.DatiBeniServizi.DettaglioLinee.Add do
  begin
    NumeroLinea.Value := 2;
    Descrizione.Value := 'PIADINA PROSCIUTTO COTTO, MOZZARELLA E FUNGHI';
    Quantita.Value := 1;
    UnitaMisura.Value := 'NR';
    PrezzoUnitario.Value := 6;
    PrezzoTotale.Value := 6;
    AliquotaIVA.Value := 22;
  end;

  // LInvoiceBody.DatiBeniServizi.DatiRiepilogo (variable)
  LDatiRiepilogo := LInvoiceBody.DatiBeniServizi.DatiRiepilogo.Add;
  LDatiRiepilogo.AliquotaIVA.Value := 22;
  LDatiRiepilogo.ImponibileImporto.Value := 12.5;
  LDatiRiepilogo.Imposta.Value := 2.75;

  // show on MemoXml
  MemoXml.Clear;
  MemoXml.Text := ei.InvoiceToString(LInvoice);

  // save to file
  if CheckBoxSaveToFile.Checked and SaveDialog1.Execute then
    ei.InvoiceToFile(LInvoice, SaveDialog1.FileName);
end;

end.
