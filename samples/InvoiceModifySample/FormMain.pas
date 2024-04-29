unit FormMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls, ei4D;

type
  TMainForm = class(TForm)
    MemoXml: TMemo;
    panelActions: TPanel;
    panelXml: TPanel;
    Label1: TLabel;
    Label2: TLabel;
    SaveDialog1: TSaveDialog;
    ButtonLoadInvoiceFromFile: TButton;
    OpenDialog1: TOpenDialog;
    procedure ButtonLoadInvoiceFromFileClick(Sender: TObject);
  private
    { Private declarations }
    FInvoice: IFatturaElettronicaType;
  public
    { Public declarations }
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

procedure TMainForm.ButtonLoadInvoiceFromFileClick(Sender: TObject);
var
  LFatturaElettronicaBody: IFatturaElettronicaBodyType;
  LDettaglioLinea: IDettaglioLineeType;
  i: Integer;
begin
  if OpenDialog1.Execute then
  begin
    // load invoice object from file
    FInvoice := ei.NewInvoiceFromFile(OpenDialog1.FileName);

    MemoXml.Clear;

    // using index 0 to access the first element of the FatturaElettronicaBody list
    LFatturaElettronicaBody := FInvoice.FatturaElettronicaBody[0];
    // either using "Last" method to access the last element of the FatturaElettronicaBody list
    // LFatturaElettronicaBody := FInvoice.FatturaElettronicaBody.Last;

    // show invoice number from body (using index 0 to access the first element of the FatturaElettronicaBody list)
    MemoXml.Lines.Add(Format('Invoice number....: %s', [LFatturaElettronicaBody.DatiGenerali.DatiGeneraliDocumento.Numero.Value]));

    // show invoice date from body (using "Last" method to access the last element of the FatturaElettronicaBody list)
    MemoXml.Lines.Add(Format('Invoice date......: %s', [LFatturaElettronicaBody.DatiGenerali.DatiGeneraliDocumento.Data.ValueAsString]));

    // show invoice supplier
    if not FInvoice.FatturaElettronicaHeader.CedentePrestatore.DatiAnagrafici.Anagrafica.Denominazione.IsNull then
      MemoXml.Lines.Add(Format('Invoice supplier..: %s',
        [FInvoice.FatturaElettronicaHeader.CedentePrestatore.DatiAnagrafici.Anagrafica.Denominazione.Value]))
    else
      MemoXml.Lines.Add(Format('Invoice supplier..: %s %s',
        [FInvoice.FatturaElettronicaHeader.CedentePrestatore.DatiAnagrafici.Anagrafica.Cognome.Value,
        FInvoice.FatturaElettronicaHeader.CedentePrestatore.DatiAnagrafici.Anagrafica.Nome.Value]));

    // show invoice customer
    if not FInvoice.FatturaElettronicaHeader.CessionarioCommittente.DatiAnagrafici.Anagrafica.Denominazione.IsNull then
      MemoXml.Lines.Add(Format('Invoice customer..: %s',
        [FInvoice.FatturaElettronicaHeader.CessionarioCommittente.DatiAnagrafici.Anagrafica.Denominazione.Value]))
    else
      MemoXml.Lines.Add(Format('Invoice customer..: %s %s',
        [FInvoice.FatturaElettronicaHeader.CessionarioCommittente.DatiAnagrafici.Anagrafica.Cognome.Value,
        FInvoice.FatturaElettronicaHeader.CessionarioCommittente.DatiAnagrafici.Anagrafica.Nome.Value]));

      // show invoice lines
        for i := 0 to LFatturaElettronicaBody.DatiBeniServizi.DettaglioLinee.Count - 1 do begin MemoXml.Lines.Add(string.empty);
    // separator
    LDettaglioLinea := LFatturaElettronicaBody.DatiBeniServizi.DettaglioLinee[i];
    MemoXml.Lines.Add(Format('Line number......: %d', [LDettaglioLinea.NumeroLinea.Value]));
    MemoXml.Lines.Add(Format('Description......: %s', [LDettaglioLinea.Descrizione.Value]));
    if not LDettaglioLinea.Quantita.IsNull then
      MemoXml.Lines.Add(Format('Quantity.........: %s', [LDettaglioLinea.Quantita.ValueAsString]));
    MemoXml.Lines.Add(Format('Price......: %f', [LDettaglioLinea.PrezzoUnitario.Value]));
    MemoXml.Lines.Add(Format('Line total......: %f', [LDettaglioLinea.PrezzoTotale.Value]));
  end;

  MemoXml.Lines.Add(string.empty); // separator

  // show invoice total
  MemoXml.Lines.Add(Format('Invoice total..: %f',
    [FInvoice.FatturaElettronicaBody[0].DatiGenerali.DatiGeneraliDocumento.ImportoTotaleDocumento.Value]));

  MemoXml.Lines.Add(string.empty); // separator
  MemoXml.Lines.Add(string.empty); // separator
  MemoXml.Lines.Add(string.empty); // separator
  MemoXml.Lines.Add(string.empty); // separator

  // show on MemoXml
  MemoXml.Lines.Add(ei.InvoiceToString(FInvoice));

  MemoXml.Lines.Insert(0, string.empty);
  MemoXml.Lines.Insert(0, '*** Some invoice info ***');
  MemoXml.Lines.Insert(0, string.empty);
end;
end;

end.
