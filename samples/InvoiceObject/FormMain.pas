unit FormMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls, ei4D, System.Actions, Vcl.ActnList, Vcl.ComCtrls, Vcl.Imaging.pngimage,
  Vcl.Imaging.jpeg;

type
  TMainForm = class(TForm)
    MemoXml: TMemo;
    panelActions: TPanel;
    panelXml: TPanel;
    SaveDialog1: TSaveDialog;
    OpenDialog1: TOpenDialog;
    GroupBox1: TGroupBox;
    buttonCreate: TButton;
    ButtonHeaderData: TButton;
    ButtonBodyData: TButton;
    ButtonPaymentsData: TButton;
    GroupBox2: TGroupBox;
    ButtonAttachmentData: TButton;
    ButtonSaveAttachment: TButton;
    GroupBox3: TGroupBox;
    GroupBox4: TGroupBox;
    ButtonLoadInvoice: TButton;
    ButtonSaveInvoice: TButton;
    ButtonValidate: TButton;
    Label2: TLabel;
    Splitter1: TSplitter;
    TrackBar1: TTrackBar;
    Panel1: TPanel;
    Label1: TLabel;
    MemoValidationResults: TMemo;
    Label3: TLabel;
    Panel2: TPanel;
    Image1: TImage;
    procedure buttonCreateClick(Sender: TObject);
    procedure ButtonValidateClick(Sender: TObject);
    procedure ButtonHeaderDataClick(Sender: TObject);
    procedure ButtonBodyDataClick(Sender: TObject);
    procedure ButtonPaymentsDataClick(Sender: TObject);
    procedure ButtonAttachmentDataClick(Sender: TObject);
    procedure ButtonLoadInvoiceClick(Sender: TObject);
    procedure ButtonSaveInvoiceClick(Sender: TObject);
    procedure ButtonSaveAttachmentClick(Sender: TObject);
    procedure ActionList1Update(Action: TBasicAction; var Handled: Boolean);
    procedure TrackBar1Change(Sender: TObject);
  private
    { Private declarations }
    FInvoice: IFatturaElettronicaType;
    procedure CheckInvoiceInstance;
    procedure UpdateMemoXML;
    procedure UpdateMemoValidationResults(const AValidationResultCollection: IeiValidationResultCollection);
  public
    { Public declarations }
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

uses
  System.DateUtils,
  System.IOUtils;

procedure TMainForm.ActionList1Update(Action: TBasicAction; var Handled: Boolean);
begin
  buttonCreate.Enabled := not Assigned(FInvoice);
  ButtonHeaderData.Enabled := Assigned(FInvoice);
end;

procedure TMainForm.ButtonAttachmentDataClick(Sender: TObject);
var
  LInvoiceBody: IFatturaElettronicaBodyType;
  LAllegato: IAllegatiType;
  LFile: string;
begin
  CheckInvoiceInstance;

  if OpenDialog1.Execute then
  begin
    LFile := OpenDialog1.FileName;
    // LFatturaElettronicaBody := FInvoice.FatturaElettronicaBody[0];
    LInvoiceBody := FInvoice.FatturaElettronicaBody.Last;
    LAllegato := LInvoiceBody.Allegati.Add;
    LAllegato.Attachment.LoadFromFile(LFile);
    LAllegato.NomeAttachment.Value := TPath.GetFileName(LFile);
    LAllegato.FormatoAttachment.Value := TPath.GetExtension(LFile).Substring(1).ToLower;
  end;

  UpdateMemoXML;
end;

procedure TMainForm.ButtonBodyDataClick(Sender: TObject);
var
  LInvoiceBody: IFatturaElettronicaBodyType;
  LDatiRiepilogo: IDatiRiepilogoType;
begin
  CheckInvoiceInstance;

  // LInvoice.FatturaElettronicaBody (variable)
  LInvoiceBody := FInvoice.FatturaElettronicaBody.Add;

  // LInvoiceBody.DatiGenerali.DatiGeneraliDocumento
  LInvoiceBody.DatiGenerali.DatiGeneraliDocumento.TipoDocumento.Value := 'TD01';
  LInvoiceBody.DatiGenerali.DatiGeneraliDocumento.Divisa.Value := 'EUR';
  LInvoiceBody.DatiGenerali.DatiGeneraliDocumento.Data.Value := Date;
  LInvoiceBody.DatiGenerali.DatiGeneraliDocumento.Numero.Value := '1';
  LInvoiceBody.DatiGenerali.DatiGeneraliDocumento.ImportoTotaleDocumento.Value := 17.08;

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
    PrezzoUnitario.Value := 7.5;
    PrezzoTotale.Value := 7.5;
    AliquotaIVA.Value := 22;
  end;

  // LInvoiceBody.DatiBeniServizi.DatiRiepilogo (variable)
  LDatiRiepilogo := LInvoiceBody.DatiBeniServizi.DatiRiepilogo.Add;
  LDatiRiepilogo.AliquotaIVA.Value := 22;
  LDatiRiepilogo.ImponibileImporto.Value := 14.00;
  LDatiRiepilogo.Imposta.Value := 3.08;

  UpdateMemoXML;
end;

procedure TMainForm.buttonCreateClick(Sender: TObject);
begin
  FInvoice := ei.NewInvoice(ftprivati);

  UpdateMemoXML;
end;

procedure TMainForm.ButtonHeaderDataClick(Sender: TObject);
begin
  CheckInvoiceInstance;

  // LInvoice.FatturaElettronicaHeader.DatiTrasmissione
  FInvoice.FatturaElettronicaHeader.DatiTrasmissione.IdTrasmittente.IdCodice.Value := '13459520154';
  FInvoice.FatturaElettronicaHeader.DatiTrasmissione.IdTrasmittente.IdPaese.Value := 'IT';
  FInvoice.FatturaElettronicaHeader.DatiTrasmissione.ProgressivoInvio.Value := '123';
  FInvoice.FatturaElettronicaHeader.DatiTrasmissione.CodiceDestinatario.Value := '0000000';

  // FInvoice.FatturaElettronicaHeader.CedentePrestatore
  FInvoice.FatturaElettronicaHeader.CedentePrestatore.DatiAnagrafici.IdFiscaleIVA.IdPaese.Value := 'IT';
  FInvoice.FatturaElettronicaHeader.CedentePrestatore.DatiAnagrafici.IdFiscaleIVA.IdCodice.Value := '12345678901';
  FInvoice.FatturaElettronicaHeader.CedentePrestatore.DatiAnagrafici.CodiceFiscale.Value := '12345678901';
  FInvoice.FatturaElettronicaHeader.CedentePrestatore.DatiAnagrafici.Anagrafica.Denominazione.Value := 'ACME & € C. SRL';
  FInvoice.FatturaElettronicaHeader.CedentePrestatore.DatiAnagrafici.RegimeFiscale.Value := 'RF01';
  FInvoice.FatturaElettronicaHeader.CedentePrestatore.Sede.Indirizzo.Value := 'VIA ROMA 4/D';
  FInvoice.FatturaElettronicaHeader.CedentePrestatore.Sede.CAP.Value := '25100';
  FInvoice.FatturaElettronicaHeader.CedentePrestatore.Sede.Comune.Value := 'MILANO';
  FInvoice.FatturaElettronicaHeader.CedentePrestatore.Sede.Provincia.Value := 'MI';
  FInvoice.FatturaElettronicaHeader.CedentePrestatore.Sede.Nazione.Value := 'IT';

  // FInvoice.FatturaElettronicaHeader.CessionarioCommittente
  FInvoice.FatturaElettronicaHeader.CessionarioCommittente.DatiAnagrafici.IdFiscaleIVA.IdPaese.Value := 'IT';
  FInvoice.FatturaElettronicaHeader.CessionarioCommittente.DatiAnagrafici.IdFiscaleIVA.IdCodice.Value := '12345678902';
  FInvoice.FatturaElettronicaHeader.CessionarioCommittente.DatiAnagrafici.Anagrafica.Denominazione.Value := 'COMMITTENTE S.R.L.';
  FInvoice.FatturaElettronicaHeader.CessionarioCommittente.Sede.Indirizzo.Value := 'VIA NAPOLI 10';
  FInvoice.FatturaElettronicaHeader.CessionarioCommittente.Sede.CAP.Value := '20200';
  FInvoice.FatturaElettronicaHeader.CessionarioCommittente.Sede.Comune.Value := 'TORINO';
  FInvoice.FatturaElettronicaHeader.CessionarioCommittente.Sede.Provincia.Value := 'TO';
  FInvoice.FatturaElettronicaHeader.CessionarioCommittente.Sede.Nazione.Value := 'IT';

  UpdateMemoXML;
end;

procedure TMainForm.ButtonLoadInvoiceClick(Sender: TObject);
begin
  if OpenDialog1.Execute then
  begin
    FInvoice := ei.NewInvoiceFromFile(OpenDialog1.FileName);

    UpdateMemoXML;
  end;
end;

procedure TMainForm.ButtonPaymentsDataClick(Sender: TObject);
var
  LFatturaElettronicaBody: IFatturaElettronicaBodyType;
  LDatiPagamento: IDatiPagamentoType;
  LDettaglioPagamento: IDettaglioPagamentoType;
  i: Integer;
begin
  CheckInvoiceInstance;

  // LFatturaElettronicaBody := FInvoice.FatturaElettronicaBody[0];
  LFatturaElettronicaBody := FInvoice.FatturaElettronicaBody.Last;
  LDatiPagamento := LFatturaElettronicaBody.DatiPagamento.Add;
  LDatiPagamento.CondizioniPagamento.Value := 'TP01';
  for i := 1 to 2 do
  begin
    LDettaglioPagamento := LDatiPagamento.DettaglioPagamento.Add;
    LDettaglioPagamento.ModalitaPagamento.Value := 'MP12';
    LDettaglioPagamento.DataScadenzaPagamento.Value := EndOfTheMonth(IncMonth(Date, i));
    LDettaglioPagamento.ImportoPagamento.Value := 8.54;
    LDettaglioPagamento.ABI.Value := '12345';
    LDettaglioPagamento.CAB.Value := '54321';
  end;

  UpdateMemoXML;
end;

procedure TMainForm.ButtonSaveAttachmentClick(Sender: TObject);
var
  LFatturaElettronicaBody: IFatturaElettronicaBodyType;
  LAllegato: IAllegatiType;
begin
  CheckInvoiceInstance;

  // LFatturaElettronicaBody := FInvoice.FatturaElettronicaBody[0];
  LFatturaElettronicaBody := FInvoice.FatturaElettronicaBody.Last;
  if not LFatturaElettronicaBody.Allegati.IsNull then
  begin
    // LAllegato := LFatturaElettronicaBody.Allegati[0];
    LAllegato := LFatturaElettronicaBody.Allegati.Last;
    SaveDialog1.FileName := LAllegato.NomeAttachment.Value;
    if SaveDialog1.Execute then
      LAllegato.Attachment.SaveToFile(SaveDialog1.FileName);
  end;
end;

procedure TMainForm.ButtonSaveInvoiceClick(Sender: TObject);
begin
  CheckInvoiceInstance;

  if SaveDialog1.Execute then
    ei.InvoiceToFile(FInvoice, SaveDialog1.FileName);
end;

procedure TMainForm.ButtonValidateClick(Sender: TObject);
var
  LInvoice: IFatturaElettronicaType;
  LValidationResult: IeiValidationResultCollection;
begin
  if not MemoXml.Lines.Text.Trim.IsEmpty then
  begin
    LInvoice := ei.NewInvoiceFromString(MemoXml.Lines.Text);
    LValidationResult := ei.ValidateInvoice(LInvoice);
    UpdateMemoValidationResults(LValidationResult);
  end;
end;

procedure TMainForm.CheckInvoiceInstance;
begin
  if not Assigned(FInvoice) then
    raise Exception.Create('You need to create or load an invoice first!');
end;

procedure TMainForm.TrackBar1Change(Sender: TObject);
begin
  MemoXml.Font.Size := TrackBar1.Position;
  MemoValidationResults.Font.Size := TrackBar1.Position;
end;

procedure TMainForm.UpdateMemoValidationResults(const AValidationResultCollection: IeiValidationResultCollection);
var
  LResult: IeiValidationResult;
begin
  MemoValidationResults.Clear;
  if AValidationResultCollection.Count > 0 then
    for LResult in AValidationResultCollection do
    begin
      MemoValidationResults.Lines.Add(LResult.ToString);
      MemoValidationResults.Lines.Add(string.Empty);
    end;
end;

procedure TMainForm.UpdateMemoXML;
begin
  if Assigned(FInvoice) then
    MemoXml.Lines.Text := ei.InvoiceToString(FInvoice)
  else
    MemoXml.Clear;
end;

end.
