unit ei4D.Invoice.Prop.List.Enumerator;

interface

uses
  System.Rtti, System.Generics.Collections, ei4D.Invoice.Prop.Interfaces,
  System.TypInfo;

type

  TeiEnumerator<T: IeiBaseProperty> = class(TEnumerator<T>)
  private
    FList: TList<IeiBaseProperty>;
    FIndex: Integer;
  protected
  public
    constructor Create(const AList: TList<IeiBaseProperty>);
    // Begin: Leave this methods public to ensure RTTI informations on them
    function GetCurrent: T;
    function MoveNext: Boolean;
    procedure Reset;
    // Begin: Leave this methods public to ensure RTTI informations on them
  end;

implementation

uses
  System.SysUtils, ei4D.Exception;

{ TeiEnumerator }

constructor TeiEnumerator<T>.Create(const AList: TList<IeiBaseProperty>);
begin
  FList := AList;
  Reset;
end;

function TeiEnumerator<T>.GetCurrent: T;
var
  LRttiType: TRttiInterfaceType;
  LCurrent: IeiBaseProperty;
begin
  LRttiType := TRttiContext.Create.GetType(TypeInfo(T)) as TRttiInterfaceType;
  LCurrent := FList[FIndex];
  if not Supports(LCurrent, LRttiType.GUID, Result) then
    raise eiGenericException.Create(Format('%s.%s: Current object does not support %s interface', [ClassName, 'GetCurrent', LRttiType.Name]));
end;

function TeiEnumerator<T>.MoveNext: Boolean;
begin
  Result := FIndex < (FList.Count - 1);
  if Result then
    Inc(FIndex);
end;

procedure TeiEnumerator<T>.Reset;
begin
  FIndex := -1;
end;

end.
