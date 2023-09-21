unit FValidateAll;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls, Vcl.Buttons, Vcl.ComCtrls;

type
  TValidateAllForm = class(TForm)
    Panel1: TPanel;
    btnValidateAll: TBitBtn;
    PageControl1: TPageControl;
    procedure btnValidateAllClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation

uses
  ei4D.Validators.Interfaces, Vcl.FileCtrl, System.IOUtils,
  ei4D.Invoice.Interfaces, ei4D;

{$R *.dfm}

procedure TValidateAllForm.btnValidateAllClick(Sender: TObject);
var
  LFile: string;
  LResult: IeiValidatorsResultCollection;
  LItem: IeiValidatorsResult;
  LDir: string;
  LInvoice: IFatturaElettronicaType;
  LTabSheet: TTabSheet;
  LMemo: TMemo;
  LMemoInfo: TMemo;
begin
  if not SelectDirectory('Select a directory', '', LDir) then
    Exit;
  PageControl1.Visible := False;
  while PageControl1.PageCount > 0 do
    PageControl1.Pages[0].Free;
  PageControl1.Visible := True;
  // TabShet con memo per avanzamento...
  LTabSheet := TTabSheet.Create(PageControl1);
  LTabSheet.Caption := TPath.GetFileName(LFile);
  LTabSheet.PageControl := PageControl1;
  LMemoInfo := TMemo.Create(LTabSheet);
  LMemoInfo.Parent := LTabSheet;
  LMemoInfo.Align := TAlign.alClient;

  for LFile in TDirectory.GetFiles(LDir, '*.xml') do
  begin
    try
      LInvoice := ei.NewInvoiceFromFile(LFile);
      LResult := ei.ValidateInvoice(LInvoice);
      if LResult.Count > 0 then
      begin
        LTabSheet := TTabSheet.Create(PageControl1);
        LTabSheet.Caption := TPath.GetFileName(LFile);
        LTabSheet.PageControl := PageControl1;
        LMemo := TMemo.Create(LTabSheet);
        LMemo.Parent := LTabSheet;
        LMemo.Align := TAlign.alClient;
        for LItem in LResult do
          LMemo.Lines.Add(LItem.ToString);
        LMemoInfo.Lines.Add(TPath.GetFileName(LFile) + ' - HAS ERRORS');
      end
      else
        LMemoInfo.Lines.Add(TPath.GetFileName(LFile) + ' - OK');
    except
      on E: Exception do
      begin
        LTabSheet := TTabSheet.Create(PageControl1);
        LTabSheet.Caption := TPath.GetFileName(LFile);
        LTabSheet.PageControl := PageControl1;
        LMemo := TMemo.Create(LTabSheet);
        LMemo.Parent := LTabSheet;
        LMemo.Align := TAlign.alClient;
        LMemo.Lines.Add('Exception in ' + TPath.GetFileName(LFile) + ': ' + E.Message);
        LMemoInfo.Lines.Add(TPath.GetFileName(LFile) + ' - RAISED AN EXCEPTION');
        Break;
      end;
    end;
  end;
  ShowMessage('Validazione terminata');
end;

end.
