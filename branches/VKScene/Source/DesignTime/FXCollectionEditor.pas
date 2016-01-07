//
// VKScene project based on GLScene library, http://glscene.sourceforge.net 
//
{
  Edits a TXCollection 
   
}
unit FXCollectionEditor;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Rtti,
  System.Variants, System.Actions, System.TypInfo,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls,
  FMX.ListView.Types, FMX.ActnList, FMX.Menus, FMX.ListView,


  VKS.Scene, VKS.CrossPlatform, VKS.XCollection, VKS.Behaviours, VKS.MaterialEx;

type
  IDesigner = interface //in designintf -> (IDesigner200)
    ['{93F3FCBC-968E-45A9-9641-609E8FB3AC60}']
    function CreateChild(ComponentClass: TComponentClass; Parent: TComponent): TComponent;
  end;

  TInstProp = record
    Instance: TPersistent;
    PropInfo: PPropInfo;
  end;

  PInstPropList = ^TInstPropList;
  TInstPropList = array[0..1023] of TInstProp;


type
  TXCollectionEditor = class(TForm)
    ToolBar1: TToolBar;
    TBAdd: TButton;
    ListView: TListView;
    PMListView: TPopupMenu;
    PMToolBar: TPopupMenu;
    ActionList: TActionList;
    ACRemove: TAction;
    ACMoveUp: TAction;
    ACMoveDown: TAction;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    procedure ACRemoveExecute(Sender: TObject);
    procedure ACMoveUpExecute(Sender: TObject);
    procedure ACMoveDownExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormHide(Sender: TObject);
    procedure ListViewChange(Sender: TObject);
  private
    { Private declarations }
    FXCollection: TXCollection;
    // ownerComponent : TComponent;
    FDesigner: IDesigner;
    UpdatingListView: Boolean;
    procedure PrepareListView;
    procedure PrepareXCollectionItemPopup(parent: TMenuItem);
    procedure OnAddXCollectionItemClick(Sender: TObject);
    procedure OnNameChanged(Sender: TObject);
    procedure OnXCollectionDestroyed(Sender: TObject);
  public
    { Public declarations }
    procedure SetXCollection(aXCollection: TXCollection; designer: IDesigner);
  end;

function XCollectionEditor: TXCollectionEditor;
procedure ReleaseXCollectionEditor;


//------------------------------------------------------------------------
implementation
//------------------------------------------------------------------------

{$R *.fmx}

resourcestring
  cXCollectionEditor = 'XCollection editor';

var
  vXCollectionEditor: TXCollectionEditor;

function XCollectionEditor: TXCollectionEditor;
begin
  if not Assigned(vXCollectionEditor) then
    vXCollectionEditor := TXCollectionEditor.Create(nil);
  Result := vXCollectionEditor;
end;

procedure ReleaseXCollectionEditor;
begin
  if Assigned(vXCollectionEditor) then
  begin
    vXCollectionEditor.Release;
    vXCollectionEditor := nil;
  end;
end;

// FormCreate
//
procedure TXCollectionEditor.FormCreate(Sender: TObject);
begin
  RegisterGLBehaviourNameChangeEvent(OnNameChanged);
  RegisterGLMaterialExNameChangeEvent(OnNameChanged);
  RegisterXCollectionDestroyEvent(OnXCollectionDestroyed);
end;

// FormDestroy
//
procedure TXCollectionEditor.FormDestroy(Sender: TObject);
begin
  DeRegisterGLBehaviourNameChangeEvent(OnNameChanged);
  DeRegisterGLMaterialExNameChangeEvent(OnNameChanged);
  DeRegisterXCollectionDestroyEvent(OnXCollectionDestroyed);
end;

// FormHide
//
procedure TXCollectionEditor.FormHide(Sender: TObject);
begin
  SetXCollection(nil, nil);
  ReleaseXCollectionEditor;
end;

// SetXCollection
//
procedure TXCollectionEditor.SetXCollection(aXCollection: TXCollection;
  designer: IDesigner);
begin
  // if Assigned(ownerComponent) then
  // ownerComponent.RemoveFreeNotification(Self);
  FXCollection := aXCollection;
  FDesigner := designer;
  if Assigned(FXCollection) then
  begin
    // if Assigned(FXCollection.Owner) and (FXCollection.Owner is TComponent) then
    // ownerComponent:=TComponent(FXCollection.Owner);
    // if Assigned(ownerComponent) then
    // ownerComponent.FreeNotification(Self);
    Caption := FXCollection.GetNamePath;
  end
  else
  begin
    // ownerComponent:=nil;
    Caption := cXCollectionEditor;
  end;
  PrepareListView;
end;


procedure TXCollectionEditor.ListViewChange(Sender: TObject);
var
  sel: Boolean;
begin
  if (*(Change = ctState) and *)Assigned(FDesigner) and (not updatingListView) then
  begin
    // setup enablings
    sel := (ListView.Selected <> nil);
    TBAdd.Enabled := Assigned(FDesigner);
    ACRemove.Enabled := sel;
    ACMoveUp.Enabled := sel and (ListView.Selected.Index > 0);
    ACMoveDown.Enabled := sel and
      (ListView.Selected.Index < ListView.Items.Count - 1);
    if Assigned(FDesigner) then
    { TODO : E2003 Undeclared identifier: 'SelectComponent' }
    (*
      if sel then
        FDesigner.SelectComponent(TXCollectionItem(ListView.Selected.Data))
      else
        FDesigner.SelectComponent(nil);
     *)
  end;
end;

procedure TXCollectionEditor.ACMoveDownExecute(Sender: TObject);
begin
  if ListView.Selected <> nil then
  begin
    /// to do
  end;
end;

procedure TXCollectionEditor.ACMoveUpExecute(Sender: TObject);
begin
  if ListView.Selected <> nil then
  begin
    /// to do
  end;
end;

procedure TXCollectionEditor.ACRemoveExecute(Sender: TObject);
begin
  if ListView.Selected <> nil then
  begin
    /// to do
  end;
end;

procedure TXCollectionEditor.OnAddXCollectionItemClick(Sender: TObject);
begin
  /// to do
end;

procedure TXCollectionEditor.OnNameChanged(Sender: TObject);
begin
  /// to do
end;

// OnXCollectionDestroyed
//
procedure TXCollectionEditor.OnXCollectionDestroyed(Sender: TObject);
begin
  if TXCollection(Sender) = FXCollection then
    Close;
end;

procedure TXCollectionEditor.PrepareListView;
var
  i: Integer;
  prevSelData: TValue;   // prev Pointer;
  XCollectionItem: TXCollectionItem;
  DisplayedName: String;
begin
  Assert(Assigned(ListView));
  updatingListView := True;
  try
    if ListView.Selected <> nil then
      prevSelData := ListView.Selected.Data[DisplayedName]
    else
      prevSelData := nil;
    with ListView.Items do
    begin
      BeginUpdate;
      Clear;
      if Assigned(FXCollection) then
      begin
        for i := 0 to FXCollection.Count - 1 do
          with Add do
          begin
            XCollectionItem := FXCollection[i];
            DisplayedName := XCollectionItem.Name;
            if DisplayedName = '' then
              DisplayedName := '(unnamed)';
            Caption := Format('%d - %s', [i, DisplayedName]);
            { TODO : E2003 Undeclared identifier: 'SubItems' }
            (*SubItems.Add(XCollectionItem.FriendlyName);*)
            Data[DisplayedName] := XCollectionItem;
          end;
        { TODO : E2015 Operator not applicable to this operand type }
        (*
        if prevSelData <> nil then
          ListView.Selected := ListView.FindData(0, prevSelData, True, False);
        *)
      end;
      EndUpdate;
    end;
  finally
    updatingListView := False;
  end;
  ListViewChange(Self);
end;

// PrepareXCollectionItemPopup
//
procedure TXCollectionEditor.PrepareXCollectionItemPopup(parent: TMenuItem);
var
  i: Integer;
  list: TList;
  XCollectionItemClass: TXCollectionItemClass;
  mi, categoryItem: TMenuItem;
begin
  list := GetXCollectionItemClassesList(FXCollection.ItemsClass);
  try
    parent.Clear;
    for i := 0 to list.Count - 1 do
    begin
      XCollectionItemClass := TXCollectionItemClass(list[i]);
      if XCollectionItemClass.ItemCategory <> '' then
      begin
        { TODO : E2003 Undeclared identifier: 'Find' }
        (*categoryItem := parent.Find(XCollectionItemClass.ItemCategory);*)
        if categoryItem = nil then
        begin
          categoryItem := TMenuItem.Create(owner);
          categoryItem.Text := XCollectionItemClass.ItemCategory;
          parent.AddObject(categoryItem);
        end;
      end
      else
        categoryItem := parent;

      mi := TMenuItem.Create(owner);
      mi.Text := XCollectionItemClass.FriendlyName;
      mi.OnClick := OnAddXCollectionItemClick;
      mi.Tag := Integer(XCollectionItemClass);
      mi.Enabled := Assigned(FXCollection) and
        FXCollection.CanAdd(XCollectionItemClass);
      categoryItem.AddObject(mi);
    end;
  finally
    list.Free;
  end;
end;

end.
