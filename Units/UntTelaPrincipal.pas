unit UntTelaPrincipal;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error,
  FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool,
  FireDAC.Stan.Async, FireDAC.Phys, FireDAC.Phys.MySQL, FireDAC.Phys.MySQLDef,
  FireDAC.VCLUI.Wait, Data.DB, FireDAC.Comp.Client, Vcl.StdCtrls, classeCliente,
  FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.DApt,
  FireDAC.Comp.DataSet, Vcl.Mask, Vcl.ComCtrls, classeProduto, Vcl.Buttons,
  Datasnap.DBClient, Vcl.Grids, Vcl.DBGrids, Vcl.ExtCtrls, classePedido;

type
  TFrmPrincipal = class(TForm)
    FDConn: TFDConnection;
    FDPhysMySQLDriverLink1: TFDPhysMySQLDriverLink;
    Label1: TLabel;
    EdtCodigoCliente: TEdit;
    lblNomeCliente: TLabel;
    edtNumPedido: TEdit;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    EdtCodigoProduto: TEdit;
    lblDescProd: TLabel;
    Label6: TLabel;
    edtDataEmissao: TDateTimePicker;
    Label7: TLabel;
    edtQtd: TEdit;
    sbIncluir: TSpeedButton;
    SpeedButton2: TSpeedButton;
    DBGrid1: TDBGrid;
    cdsitens: TClientDataSet;
    cdsitenscodigo_produto: TIntegerField;
    cdsitensdescricao: TStringField;
    cdsitensquantidade: TIntegerField;
    cdsitensvalor_unitario: TFloatField;
    cdsitensvalor_total: TFloatField;
    dsitens: TDataSource;
    edtValorUnitario: TEdit;
    pnlValortotal: TPanel;
    Label5: TLabel;
    cdsitenssumvalor_total: TAggregateField;
    sbPesquisa: TSpeedButton;
    BitBtn1: TBitBtn;
    sbExcluir: TSpeedButton;
    procedure FormCreate(Sender: TObject);
    procedure EdtCodigoClienteKeyPress(Sender: TObject; var Key: Char);
    procedure EdtCodigoClienteExit(Sender: TObject);
    procedure edtNumPedidoKeyPress(Sender: TObject; var Key: Char);
    procedure edtDataEmissaoEnter(Sender: TObject);
    procedure EdtCodigoProdutoExit(Sender: TObject);
    procedure EdtCodigoProdutoKeyPress(Sender: TObject; var Key: Char);
    procedure sbIncluirClick(Sender: TObject);
    procedure edtQtdKeyPress(Sender: TObject; var Key: Char);
    procedure SpeedButton2Click(Sender: TObject);
    procedure DBGrid1KeyPress(Sender: TObject; var Key: Char);
    procedure DBGrid1DblClick(Sender: TObject);
    procedure edtValorUnitarioKeyPress(Sender: TObject; var Key: Char);
    procedure DBGrid1KeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure edtDataEmissaoKeyPress(Sender: TObject; var Key: Char);
    procedure BitBtn1Click(Sender: TObject);
    procedure sbPesquisaClick(Sender: TObject);
    procedure sbExcluirClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FrmPrincipal: TFrmPrincipal;
  Clientes : TCliente;
  Produtos : TProduto;
  Pedido   : TPedido;
  vOperacaoGrid: string;
  vOperacao : string;
implementation




{$R *.dfm}

{ TFrmPrincipal }


procedure TFrmPrincipal.BitBtn1Click(Sender: TObject);
begin
  with Pedido do
  begin
    Itens:= cdsitens;
    CodigoCliente:= StrToInt(EdtCodigoCliente.Text);
    ValorTotal:= StrToCurr(pnlValortotal.Caption);
    DataEmissao:= edtDataEmissao.Date;


    if vOperacao = '' then
      if Inserir then
        ShowMessage('Pedido de n�: '+IntToStr(NumeroPedido)+' salvo com sucesso!' );

    if vOperacao = 'A' then
      if Alterar(edtNumPedido.Text) then
        ShowMessage('Pedido de n�: '+edtNumPedido.Text+' alterado com sucesso!' );

    vOperacao:= '';
    EdtCodigoCliente.Clear;
    edtNumPedido.Clear;
    lblNomeCliente.Caption:= '';
    lblDescProd.Caption:= '';
    pnlValortotal.Caption:= '0,00';
    cdsitens.EmptyDataSet;
    sbPesquisa.Visible:= True;
    EdtCodigoCliente.SetFocus;
  end;
end;

procedure TFrmPrincipal.DBGrid1DblClick(Sender: TObject);
begin
  vOperacaoGrid:= 'A';
  EdtCodigoProduto.Text:= cdsitenscodigo_produto.AsString;
  edtValorUnitario.Text:= cdsitensvalor_unitario.AsString;
  edtQtd.Text:= cdsitensquantidade.AsString;
end;

procedure TFrmPrincipal.DBGrid1KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_DELETE then
  begin
    if messagedlg('Deseja realmente excluir o item?',mtconfirmation,[mbyes,mbno],0)= mryes then
      cdsitens.Delete;
  end;
end;

procedure TFrmPrincipal.DBGrid1KeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
  begin
    vOperacaoGrid:= 'A';
    EdtCodigoProduto.Text:= cdsitenscodigo_produto.AsString;
    lblDescProd.Caption:= cdsitensdescricao.AsString;
    edtValorUnitario.Text:= FormatCurr('0.00',cdsitensvalor_unitario.AsVariant);
    edtQtd.Text:= cdsitensquantidade.AsString;
  end;

end;

procedure TFrmPrincipal.EdtCodigoClienteExit(Sender: TObject);
begin
  if EdtCodigoCliente.Text <> '' then
  begin
    Clientes.Selecionar(StrToInt(EdtCodigoCliente.Text));
    lblNomeCliente.Caption:= Clientes.FNome +' - '+ Clientes.FCidade +' - '+ Clientes.FCidade;
    sbPesquisa.Visible:= False;
    sbExcluir.Visible:= False;
  end
  else
  begin
    sbPesquisa.Visible:= True;
    sbExcluir.Visible:= True;
  end;
end;

procedure TFrmPrincipal.EdtCodigoClienteKeyPress(Sender: TObject;
  var Key: Char);
begin
  if key = #13 then
    edtNumPedido.SetFocus;
end;

procedure TFrmPrincipal.EdtCodigoProdutoExit(Sender: TObject);
begin
  if EdtCodigoProduto.Text <> '' then
  begin
    Produtos.Selecionar(StrToInt(EdtCodigoProduto.Text));
    lblDescProd.Caption:= Produtos.FDescricao;
    edtValorUnitario.Text:= FormatCurr('0.00',Produtos.FPrecoVenda);
  end;
end;

procedure TFrmPrincipal.EdtCodigoProdutoKeyPress(Sender: TObject;
  var Key: Char);
begin
  if key = #13 then
    edtQtd.SetFocus;
end;

procedure TFrmPrincipal.edtDataEmissaoEnter(Sender: TObject);
begin
  edtDataEmissao.Date:= now;
end;

procedure TFrmPrincipal.edtDataEmissaoKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
    EdtCodigoProduto.SetFocus;
end;

procedure TFrmPrincipal.edtNumPedidoKeyPress(Sender: TObject; var Key: Char);
begin
  if Key =#13 then
  begin
    edtDataEmissao.SetFocus;
  end;
end;

procedure TFrmPrincipal.edtQtdKeyPress(Sender: TObject; var Key: Char);
begin
  If not (CharInSet(Key,['0'..'9',#13,#46,#08])) then
  begin
    Key:=#0;
  end;

  if Key = #13 then
    edtValorUnitario.SetFocus;
end;

procedure TFrmPrincipal.edtValorUnitarioKeyPress(Sender: TObject;
  var Key: Char);
begin
  If not (CharInSet(Key,['0'..'9',#13,#46,#08,',','.'])) then
  begin
    Key:=#0;
  end;

  if key = #13 then
    sbIncluirClick(nil);

end;

procedure TFrmPrincipal.FormCreate(Sender: TObject);
begin
  FDPhysMySQLDriverLink1.VendorLib:= ExtractFilePath(ExtractFilePath(Application.ExeName))+'Arquivos\libmysql.dll';
  FDConn.Connected:= False;
  FDConn.Params.Values['database']:=  'pedido_venda';
  FDConn.Params.Values['user_name']:= 'root';
  FDConn.Params.Values['password'] := 'Cup204468';
  FDConn.Params.Values['server'] := '127.0.0.1';
  FDConn.Connected:= True;
  Clientes := TCliente.Create(FDConn);
  Produtos := TProduto.Create(FDConn);
  Pedido   := TPedido.Create(FDConn);
end;

procedure TFrmPrincipal.sbExcluirClick(Sender: TObject);
begin
  if edtNumPedido.Text <> '' then
     if messagedlg('Deseja realmente excluir o item?',mtconfirmation,[mbyes,mbno],0)= mryes then
        if Pedido.Deletar(edtNumPedido.Text) then
           ShowMessage('Pedido Cancelado com Sucesso!');
end;

procedure TFrmPrincipal.sbIncluirClick(Sender: TObject);
begin
  if EdtCodigoProduto.Text <> '' then
  begin
    with cdsitens do
    begin
      if vOperacaoGrid = 'A' then
        Edit
      else
        Insert;

      cdsitenscodigo_produto.AsString:= EdtCodigoProduto.Text;
      cdsitensdescricao.AsString:= lblDescProd.Caption;
      cdsitensquantidade.AsString:= edtQtd.Text;
      cdsitensvalor_unitario.AsString:= edtValorUnitario.Text;
      cdsitensvalor_total.AsCurrency:= StrToCurr(edtQtd.Text)*StrToCurr(edtValorUnitario.Text);

      Post;
    end;

    pnlValortotal.Caption := FormatCurr('0.00',cdsitenssumvalor_total.AsVariant);
    EdtCodigoProduto.Clear;
    lblDescProd.Caption:= '';
    edtValorUnitario.Text:= '0,00';
    edtQtd.Text:= '1';
    vOperacaoGrid:= '';
    EdtCodigoProduto.SetFocus;

  end;
end;

procedure TFrmPrincipal.sbPesquisaClick(Sender: TObject);
begin
  if edtNumPedido.Text <> '' then
  begin
    with pedido do
    begin
      cdsitens.EmptyDataSet;
      Itens:= cdsitens;

      if Selecionar(edtNumPedido.Text) then
      begin
        cdsitens:= Itens;
        EdtCodigoCliente.Text:= IntToStr(CodigoCliente);
        EdtCodigoClienteExit(nil);
        pnlValortotal.Caption:= FormatFloat('0.00',ValorTotal);
        vOperacao:= 'A';
      end
      else
        ShowMessage('Pedido n�o encontrado!');
    end;
  end
  else
  begin
    ShowMessage('Informe o numero do pedido!');
    edtNumPedido.SetFocus;
  end;
end;

procedure TFrmPrincipal.SpeedButton2Click(Sender: TObject);
begin
  if messagedlg('Deseja realmente excluir o item?',mtconfirmation,[mbyes,mbno],0)= mryes then
    cdsitens.Delete;

end;

end.
