unit FormMain;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.StdCtrls,
  Vcl.ExtCtrls,
  Vcl.Imaging.jpeg,
  ei4D, Vcl.ComCtrls;

type

  { TMainForm }

  TMainForm = class(TForm)
    PanelActions: TPanel;
    OpenDialog: TFileOpenDialog;
    Panel2: TPanel;
    Image1: TImage;
    GroupBox1: TGroupBox;
    ProviderLabel: TLabel;
    Label1: TLabel;
    Label2: TLabel;
    ComboBoxProviders: TComboBox;
    EditUserName: TEdit;
    EditPassword: TEdit;
    ButtonConnect: TButton;
    ButtonDisconnect: TButton;
    GroupBox2: TGroupBox;
    ButtonSendInvoice: TButton;
    ComboBoxFilenames: TComboBox;
    FilenamesLabel: TLabel;
    ButtonReadNotifications: TButton;
    GroupBox3: TGroupBox;
    ButtonPurchaseInvoiceList: TButton;
    PurchaseFilenameLabel: TLabel;
    ComboBoxPurchaseInvoiceList: TComboBox;
    ButtonPurchaseInvoice: TButton;
    ButtonPurchaseNotification: TButton;
    Panel1: TPanel;
    Label3: TLabel;
    Memo: TMemo;
    Label4: TLabel;
    TrackBar1: TTrackBar;
    ButtonVersion: TButton;
    procedure ButtonSendInvoiceClick(Sender: TObject);
    procedure ButtonReadNotificationsClick(Sender: TObject);
    procedure ButtonPurchaseInvoiceListClick(Sender: TObject);
    procedure ButtonPurchaseInvoiceClick(Sender: TObject);
    procedure ButtonPurchaseNotificationClick(Sender: TObject);
    procedure ButtonConnectClick(Sender: TObject);
    procedure ButtonDisconnectClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure TrackBar1Change(Sender: TObject);
    procedure ButtonVersionClick(Sender: TObject);
  strict private
    FProvider: IeiProvider;
    procedure EnableButtons(const AEnabled: Boolean);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}
{ TMainForm }

constructor TMainForm.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FProvider := nil;
end;

destructor TMainForm.Destroy;
begin
  if Assigned(FProvider) then
    FProvider.Disconnect;
  inherited Destroy;
end;

procedure TMainForm.EnableButtons(const AEnabled: Boolean);
begin
  ButtonConnect.Enabled := not AEnabled;
  ButtonDisconnect.Enabled := AEnabled;
  ButtonSendInvoice.Enabled := AEnabled;
  ButtonReadNotifications.Enabled := AEnabled;
  ButtonPurchaseInvoiceList.Enabled := AEnabled;
  ButtonPurchaseInvoice.Enabled := AEnabled;
  ButtonPurchaseNotification.Enabled := AEnabled;
  ComboBoxFilenames.Enabled := AEnabled;
  ComboBoxPurchaseInvoiceList.Enabled := AEnabled;
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  ei.ProvidersAsStrings(ComboBoxProviders.Items);
  EnableButtons(False);
end;

procedure TMainForm.TrackBar1Change(Sender: TObject);
begin
  Memo.Font.Size := TrackBar1.Position;
end;

procedure TMainForm.ButtonConnectClick(Sender: TObject);
begin
  if (ComboBoxProviders.ItemIndex = -1) or (Trim(EditUserName.Text) = '') or (Trim(EditPassword.Text) = '') then
    raise Exception.Create('Select provider and fill UserName and Password first!');
  // Set provider params
  ei.Params.Provider.ID := ComboBoxProviders.Text;
  ei.Params.Provider.UserName := EditUserName.Text;
  ei.Params.Provider.Password := EditPassword.Text;
  // Get the provider instance and connect
  FProvider := ei.NewProvider;
  FProvider.Connect;
  // Enable buttons
  EnableButtons(True);
  // Update Memo
  Memo.Clear;
  Memo.Lines.Add('Connected..');
end;

procedure TMainForm.ButtonDisconnectClick(Sender: TObject);
begin
  FProvider.Disconnect;
  EnableButtons(False);
  Memo.Lines.Add('Disconnected..');
end;

procedure TMainForm.ButtonSendInvoiceClick(Sender: TObject);
var
  LInvoice: IFatturaElettronicaType;
  LResponseCollection: IeiResponseCollection;
  LResponse: IeiResponse;
begin
  if OpenDialog.Execute then
  begin
    // Create invoice instance
    LInvoice := ei.NewInvoiceFromFile(OpenDialog.FileName);
    // Send invoice
    LResponseCollection := FProvider.SendInvoice(LInvoice);
    // Collect sent invoice filenames and fill the related combo
    for LResponse in LResponseCollection do
      ComboBoxFilenames.Items.Add(LResponse.FileName);
    // Show the invoice on the memo
    Memo.Text := ei.InvoiceToString(LInvoice);
  end;
end;

procedure TMainForm.ButtonVersionClick(Sender: TObject);
begin
  ShowMessage(ei.Version);
end;

procedure TMainForm.ButtonReadNotificationsClick(Sender: TObject);
var
  LResponseCollection: IeiResponseCollection;
  LResponse: IeiResponse;
begin
  // Get the notifications for the selected invoice
  LResponseCollection := FProvider.ReceiveInvoiceNotifications(ComboBoxFilenames.Text);
  // Write the notification on the memo
  Memo.Lines.Clear;
  for LResponse in LResponseCollection do
    Memo.Lines.Add(LResponse.MsgRaw);
end;

procedure TMainForm.ButtonPurchaseInvoiceListClick(Sender: TObject);
var
  LResult: IeiInvoiceIDCollection;
  LValue: String;
  LPartitaIva: string;
  LStartDate: TDateTime;
  LEndDate: TDateTime;
begin
  // Put here your VAT number, search start date, search end date
  LPartitaIva := string.Empty;
  LStartDate := Date - 30;
  LEndDate := 0;
  // Get a list of purchase invoice to be downloaded
  LResult := FProvider.ReceivePurchaseInvoiceIDCollection(LPartitaIva, LStartDate, LEndDate);
  // Fill the relative combo
  ComboBoxPurchaseInvoiceList.Items.Clear;
  for LValue in LResult do
    ComboBoxPurchaseInvoiceList.Items.Add(LValue);
  // Select the first if exists
  if ComboBoxPurchaseInvoiceList.Items.Count > 0 then
    ComboBoxPurchaseInvoiceList.ItemIndex := 0;
  // Update Memo
  Memo.Lines.Assign(ComboBoxPurchaseInvoiceList.Items);
end;

procedure TMainForm.ButtonPurchaseInvoiceClick(Sender: TObject);
var
  LResponses: IeiResponseCollection;
  LResponse: IeiResponse;
begin
  // Get the selected invoice
  LResponses := FProvider.ReceivePurchaseInvoice(ComboBoxPurchaseInvoiceList.Text);
  // Write the invoice xml on the memo lines
  Memo.Lines.Clear;
  for LResponse in LResponses do
  begin
    Memo.Lines.Add(LResponse.MsgRaw);
    Memo.Lines.Add(String.Empty);
  end;
end;

procedure TMainForm.ButtonPurchaseNotificationClick(Sender: TObject);
var
  LResponses: IeiResponseCollection;
  LResponse: IeiResponse;
begin
  // Get notifications for the selected purchase invoice
  LResponses := FProvider.ReceivePurchaseInvoiceNotifications(ComboBoxPurchaseInvoiceList.Text);
  // Write the notification xml on the memo lines
  Memo.Lines.Clear;
  for LResponse in LResponses do
  begin
    Memo.Lines.Add(LResponse.MsgRaw);
    Memo.Lines.Add(String.Empty);
  end;
end;

end.
