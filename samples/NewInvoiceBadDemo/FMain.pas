unit FMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.ExtDlgs, ei4D, Vcl.Buttons;

type
  TMainForm = class(TForm)
    ButtonNewInvoice: TButton;
    ButtonSetProgressivoInvio: TButton;
    Label1: TLabel;
    EditProgressivoInvio: TEdit;
    ButtonClearProgressivoInvio: TButton;
    Label2: TLabel;
    LabelProgressivoInvio: TLabel;
    ButtonSetIdPaese: TButton;
    Label3: TLabel;
    EditIdPaese: TEdit;
    ButtonClearIdPaese: TButton;
    Label4: TLabel;
    LabelIdPaese: TLabel;
    ButtonSetIdCodice: TButton;
    Label6: TLabel;
    EditIdCodice: TEdit;
    ButtonClearIdCodice: TButton;
    Label7: TLabel;
    LabelIdCodice: TLabel;
    Timer1: TTimer;
    ButtonShowData: TButton;
    Label5: TLabel;
    Label8: TLabel;
    LabelTipoDocumento: TLabel;
    ButtonSetTipoDocumento: TButton;
    EditTipoDocumento: TEdit;
    ButtonClearTipoDocumento: TButton;
    Label9: TLabel;
    Label10: TLabel;
    LabelNomeAttachment1: TLabel;
    ButtonSetNomeAttachment1: TButton;
    EditNomeAttachment1: TEdit;
    ButtonClearNomeAttachment1: TButton;
    ImageAttachment1: TImage;
    Label12: TLabel;
    ButtonLoadAttachment1: TButton;
    ButtonClearAttachment1: TButton;
    ButtonSaveAttachment1: TButton;
    MemoAllegato1: TMemo;
    OpenPictureDialog1: TOpenPictureDialog;
    SavePictureDialog1: TSavePictureDialog;
    Shape1: TShape;
    Label11: TLabel;
    Label13: TLabel;
    LabelNomeAttachment2: TLabel;
    ImageAttachment2: TImage;
    Label15: TLabel;
    ButtonSetNomeAttachment2: TButton;
    EditNomeAttachment2: TEdit;
    ButtonClearNomeAttachment2: TButton;
    ButtonLoadAttachment2: TButton;
    ButtonClearAttachment2: TButton;
    ButtonAddAllegato: TButton;
    ButtonSaveAttachment2: TButton;
    MemoAllegato2: TMemo;
    Shape2: TShape;
    ButtonListAttachments: TButton;
    ButtonDateConversion: TButton;
    ButtonDateTimeConversion: TButton;
    ButtonTipoDocumentoGetID: TButton;
    Button1: TButton;
    MemoXML: TMemo;
    ButtonLoadInvoiceFromFile: TButton;
    OpenDialog1: TOpenDialog;
    ButtonValidate: TButton;
    btnValidateAll: TBitBtn;
    procedure ButtonNewInvoiceClick(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure ButtonShowDataClick(Sender: TObject);
    procedure ButtonClearProgressivoInvioClick(Sender: TObject);
    procedure ButtonSetProgressivoInvioClick(Sender: TObject);
    procedure ButtonSetIdPaeseClick(Sender: TObject);
    procedure ButtonSetIdCodiceClick(Sender: TObject);
    procedure ButtonClearIdPaeseClick(Sender: TObject);
    procedure ButtonClearIdCodiceClick(Sender: TObject);
    procedure ButtonSetTipoDocumentoClick(Sender: TObject);
    procedure ButtonClearTipoDocumentoClick(Sender: TObject);
    procedure ButtonSetNomeAttachment1Click(Sender: TObject);
    procedure ButtonClearNomeAttachment1Click(Sender: TObject);
    procedure ButtonClearAttachment1Click(Sender: TObject);
    procedure ButtonLoadAttachment1Click(Sender: TObject);
    procedure ButtonSaveAttachment1Click(Sender: TObject);
    procedure ButtonAddAllegatoClick(Sender: TObject);
    procedure ButtonSetNomeAttachment2Click(Sender: TObject);
    procedure ButtonClearNomeAttachment2Click(Sender: TObject);
    procedure ButtonLoadAttachment2Click(Sender: TObject);
    procedure ButtonSaveAttachment2Click(Sender: TObject);
    procedure ButtonClearAttachment2Click(Sender: TObject);
    procedure ButtonListAttachmentsClick(Sender: TObject);
    procedure ButtonDateConversionClick(Sender: TObject);
    procedure ButtonDateTimeConversionClick(Sender: TObject);
    procedure ButtonTipoDocumentoGetIDClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure ButtonLoadInvoiceFromFileClick(Sender: TObject);
    procedure ButtonValidateClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnValidateAllClick(Sender: TObject);
  private
    { Private declarations }
    FInvoice: IFatturaElettronicaType;
    procedure ShowData;
  public
    { Public declarations }
  end;

var
  MainForm: TMainForm;

implementation

uses
  System.DateUtils, ei4D.Utils, ei4D.Validators.Register, System.IOUtils, Vcl.FileCtrl;

{$R *.dfm}

procedure TMainForm.ButtonNewInvoiceClick(Sender: TObject);
begin
  FInvoice := ei.NewInvoice;
  FInvoice.FatturaElettronicaHeader.DatiTrasmissione.FormatoTrasmissione.Value := 'FPR12';
  Timer1.Enabled := True;
end;

procedure TMainForm.ButtonShowDataClick(Sender: TObject);
begin
  ShowData;
end;

procedure TMainForm.ButtonTipoDocumentoGetIDClick(Sender: TObject);
begin
  ShowMessage(FInvoice.FatturaElettronicaBody.Last.DatiGenerali.DatiGeneraliDocumento.TipoDocumento.FullQualifiedName);
end;

procedure TMainForm.ButtonValidateClick(Sender: TObject);
var
  LResult: IeiValidatorsResultCollection;
  LItem: IeiValidatorsResult;
  LMsg: String;
begin
  LMsg := 'Ci sono degli errori:';
  LResult := ei.ValidateInvoice(FInvoice);
  if LResult.Count > 0 then
  begin
    for LItem in LResult do
      LMsg := LMsg + #13 + LItem.ToString;
    ShowMessage(LMsg);
  end;
end;

procedure TMainForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  FInvoice := nil;
end;

procedure TMainForm.btnValidateAllClick(Sender: TObject);
var
  LFile: string;
  LResult: IeiValidatorsResultCollection;
  LItem: IeiValidatorsResult;
  LMsg: String;
  LDir: string;
begin
  if not SelectDirectory('Select a directory', '', LDir) then
    Exit;
  for LFile in TDirectory.GetFiles(LDir, '*.xml') do
  begin
    FInvoice := ei.NewInvoiceFromFile(LFile);
    LResult := ei.ValidateInvoice(FInvoice);
    if LResult.Count > 0 then
    begin
      for LItem in LResult do
        LMsg := LMsg + #13 + LItem.ToString;
      ShowMessage(LMsg);
    end;
  end;
  ShowMessage('Fine');
end;

procedure TMainForm.Button1Click(Sender: TObject);
begin
  MemoXML.Text := ei.InvoiceToString(FInvoice);
  MemoXML.Align := alClient;
end;

procedure TMainForm.ButtonAddAllegatoClick(Sender: TObject);
begin
  FInvoice.FatturaElettronicaBody.Last(True).Allegati.Add;
end;

procedure TMainForm.ButtonClearAttachment1Click(Sender: TObject);
begin
  FInvoice.FatturaElettronicaBody[0].Allegati[0].Attachment.Clear;
end;

procedure TMainForm.ButtonClearAttachment2Click(Sender: TObject);
begin
  FInvoice.FatturaElettronicaBody[0].Allegati[1].Attachment.Clear;
end;

procedure TMainForm.ButtonClearIdCodiceClick(Sender: TObject);
begin
  FInvoice.FatturaElettronicaHeader.DatiTrasmissione.IdTrasmittente.IdCodice.Clear;
end;

procedure TMainForm.ButtonClearIdPaeseClick(Sender: TObject);
begin
  FInvoice.FatturaElettronicaHeader.DatiTrasmissione.IdTrasmittente.IdPaese.Clear;
end;

procedure TMainForm.ButtonClearNomeAttachment1Click(Sender: TObject);
begin
  FInvoice.FatturaElettronicaBody[0].Allegati[0].NomeAttachment.Clear;
end;

procedure TMainForm.ButtonClearNomeAttachment2Click(Sender: TObject);
begin
  FInvoice.FatturaElettronicaBody[0].Allegati[1].NomeAttachment.Clear;
end;

procedure TMainForm.ButtonClearProgressivoInvioClick(Sender: TObject);
begin
  FInvoice.FatturaElettronicaHeader.DatiTrasmissione.ProgressivoInvio.Clear;
end;

procedure TMainForm.ButtonClearTipoDocumentoClick(Sender: TObject);
begin
  FInvoice.FatturaElettronicaBody.Last(True).DatiGenerali.DatiGeneraliDocumento.TipoDocumento.Clear;
end;

procedure TMainForm.ButtonDateConversionClick(Sender: TObject);
var
  LValue: TDate;
  LValueStr: String;
begin
  LValue := Today;
  LValueStr := TeiUtils.DateToString(LValue);
  ShowMessage(LValueStr);
  LValue := TeiUtils.StringToDate(LValueStr);
  LValueStr := TeiUtils.DateToString(LValue);
  ShowMessage(LValueStr);
end;

procedure TMainForm.ButtonDateTimeConversionClick(Sender: TObject);
var
  LValue: TDateTime;
  LValueStr: String;
begin
  LValue := Now;
  LValueStr := TeiUtils.DateTimeToString(LValue);
  ShowMessage(LValueStr);
  LValue := TeiUtils.StringToDateTime(LValueStr, False);
  LValueStr := TeiUtils.DateTimeToString(LValue);
  ShowMessage(LValueStr);
end;

procedure TMainForm.ButtonListAttachmentsClick(Sender: TObject);
// var
// LAllegato: IAllegatiType;
// LMsg: String;
// LEnumerator: IEnumerator<IAllegatiType>;
begin
  // LMsg := Format('Ci sono %d allegati:', [FInvoice.FatturaElettronicaBody.Current.Allegati.Count]);
  // LEnumerator := FInvoice.FatturaElettronicaBody.Current.Allegati.GetEnumerator;
  // LEnumerator.MoveNext;
  // for LAllegato in FInvoice.FatturaElettronicaBody.Current.Allegati do
  // LMsg := LMsg + #13 + LAllegato.NomeAttachment.Value;
  // ShowMessage(LMsg);
end;

procedure TMainForm.ButtonLoadAttachment1Click(Sender: TObject);
begin
  if OpenPictureDialog1.Execute then
    FInvoice.FatturaElettronicaBody[0].Allegati[0].Attachment.LoadFromFile(OpenPictureDialog1.FileName);
end;

procedure TMainForm.ButtonLoadAttachment2Click(Sender: TObject);
begin
  if OpenPictureDialog1.Execute then
    FInvoice.FatturaElettronicaBody[0].Allegati[1].Attachment.LoadFromFile(OpenPictureDialog1.FileName);
end;

procedure TMainForm.ButtonLoadInvoiceFromFileClick(Sender: TObject);
begin
  if OpenDialog1.Execute then
    FInvoice := ei.NewInvoiceFromFile(OpenDialog1.FileName);
end;

procedure TMainForm.ButtonSaveAttachment1Click(Sender: TObject);
begin
  if SavePictureDialog1.Execute then
    FInvoice.FatturaElettronicaBody[0].Allegati[0].Attachment.SaveToFile(SavePictureDialog1.FileName);
end;

procedure TMainForm.ButtonSaveAttachment2Click(Sender: TObject);
begin
  if SavePictureDialog1.Execute then
    FInvoice.FatturaElettronicaBody[0].Allegati[1].Attachment.SaveToFile(SavePictureDialog1.FileName);
end;

procedure TMainForm.ButtonSetIdCodiceClick(Sender: TObject);
begin
  FInvoice.FatturaElettronicaHeader.DatiTrasmissione.IdTrasmittente.IdCodice.Value := EditIdCodice.Text;
end;

procedure TMainForm.ButtonSetIdPaeseClick(Sender: TObject);
begin
  FInvoice.FatturaElettronicaHeader.DatiTrasmissione.IdTrasmittente.IdPaese.Value := EditIdPaese.Text;
end;

procedure TMainForm.ButtonSetNomeAttachment1Click(Sender: TObject);
begin
  FInvoice.FatturaElettronicaBody[0].Allegati[0].NomeAttachment.Value := EditNomeAttachment1.Text;
end;

procedure TMainForm.ButtonSetNomeAttachment2Click(Sender: TObject);
begin
  FInvoice.FatturaElettronicaBody[0].Allegati[1].NomeAttachment.Value := EditNomeAttachment2.Text;
end;

procedure TMainForm.ButtonSetProgressivoInvioClick(Sender: TObject);
begin
  FInvoice.FatturaElettronicaHeader.DatiTrasmissione.ProgressivoInvio.Value := EditProgressivoInvio.Text;
end;

procedure TMainForm.ButtonSetTipoDocumentoClick(Sender: TObject);
begin
  FInvoice.FatturaElettronicaBody.Last(True).DatiGenerali.DatiGeneraliDocumento.TipoDocumento.Value := EditTipoDocumento.Text;
end;

procedure TMainForm.ShowData;
begin
  // 1.1.2 <ProgressivoInvio>
  if not FInvoice.FatturaElettronicaHeader.DatiTrasmissione.ProgressivoInvio.IsNull then
    LabelProgressivoInvio.Caption := FInvoice.FatturaElettronicaHeader.DatiTrasmissione.ProgressivoInvio.Value
  else
    LabelProgressivoInvio.Caption := 'NULL';
  // 1.1.1.1 <IdPaese>
  if not FInvoice.FatturaElettronicaHeader.DatiTrasmissione.IdTrasmittente.IdPaese.IsNull then
    LabelIdPaese.Caption := FInvoice.FatturaElettronicaHeader.DatiTrasmissione.IdTrasmittente.IdPaese.Value
  else
    LabelIdPaese.Caption := 'NULL';
  // 1.1.1.2 <IdCodice>
  if not FInvoice.FatturaElettronicaHeader.DatiTrasmissione.IdTrasmittente.IdCodice.IsNull then
    LabelIdCodice.Caption := FInvoice.FatturaElettronicaHeader.DatiTrasmissione.IdTrasmittente.IdCodice.Value
  else
    LabelIdCodice.Caption := 'NULL';
  // 2.1.1.1 <TipoDocumento>
  if not FInvoice.FatturaElettronicaBody.Last(True).DatiGenerali.DatiGeneraliDocumento.TipoDocumento.IsNull then
    LabelTipoDocumento.Caption := FInvoice.FatturaElettronicaBody.Last(True).DatiGenerali.DatiGeneraliDocumento.TipoDocumento.Value
  else
    LabelTipoDocumento.Caption := 'NULL';

  // ----- 2.5 Allegato 1 -----
  if (FInvoice.FatturaElettronicaBody.Last(True).Allegati.Count > 0) then
  begin

    // 2.5.1 <NomeAttachment>
    if not FInvoice.FatturaElettronicaBody.Last(True).Allegati[0].NomeAttachment.IsNull then
      LabelNomeAttachment1.Caption := FInvoice.FatturaElettronicaBody.Last(True).Allegati[0].NomeAttachment.Value
    else
      LabelNomeAttachment1.Caption := 'NULL';
    // 2.5.5 <Attachment>
    if not FInvoice.FatturaElettronicaBody.Last(True).Allegati[0].Attachment.IsNull then
    begin
      MemoAllegato1.Text := FInvoice.FatturaElettronicaBody.Last(True).Allegati[0].Attachment.Value;
      // ImageAttachment1.Picture.LoadFromStream(FInvoice.FatturaElettronicaBody.Current.Allegati[0].Attachment.AsStream);
    end
    else
    begin
      MemoAllegato1.Text := 'NULL';
      ImageAttachment1.Picture := nil;
    end;

  end
  else
  begin
    LabelNomeAttachment1.Caption := 'Unissigned';
    MemoAllegato1.Text := 'Unissigned';
    ImageAttachment1.Picture := nil;
  end;

  // ----- 2.5 Allegato 2 -----
  if (FInvoice.FatturaElettronicaBody.Last(True).Allegati.Count > 1) then
  begin

    // 2.5.1 <NomeAttachment>
    if not FInvoice.FatturaElettronicaBody.Last(True).Allegati[1].NomeAttachment.IsNull then
      LabelNomeAttachment2.Caption := FInvoice.FatturaElettronicaBody.Last(True).Allegati[1].NomeAttachment.Value
    else
      LabelNomeAttachment2.Caption := 'NULL';
    // 2.5.5 <Attachment>
    if not FInvoice.FatturaElettronicaBody.Last(True).Allegati[1].Attachment.IsNull then
    begin
      MemoAllegato2.Text := FInvoice.FatturaElettronicaBody.Last(True).Allegati[1].Attachment.Value;
      // ImageAttachment2.Picture.LoadFromStream(FInvoice.FatturaElettronicaBody.Current.Allegati[1].Attachment.AsStream);
    end
    else
    begin
      MemoAllegato2.Text := 'NULL';
      ImageAttachment2.Picture := nil;
    end;

  end
  else
  begin
    LabelNomeAttachment2.Caption := 'Unissigned';
    MemoAllegato2.Text := 'Unissigned';
    ImageAttachment2.Picture := nil;
  end;
end;

procedure TMainForm.Timer1Timer(Sender: TObject);
begin
  if Assigned(FInvoice) then
    ShowData;
end;

end.
