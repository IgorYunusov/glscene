//
// This unit is part of the GLScene Project, http://glscene.org
//
{ : FXCollectionEditor<p>

  Edits a TXCollection<p>

  <b>History: </b><font size=-1><ul>
  <li>20/01/11 - DanB - Collection items are now grouped by ItemCategory
  <li>16/06/10 - YP - Fixed IDE exception when item removed
  <li>05/10/08 - DanB - removed Kylix support + some other old ifdefs
  <li>29/03/07 - DaStr - Renamed LINUX to KYLIX (BugTrackerID=1681585)
  <li>03/07/04 - LR - Make change for Linux
  <li>12/07/03 - DanB - Fixed crash when owner deleted
  <li>27/02/02 - Egg - Fixed crash after item deletion
  <li>11/04/00 - Egg - Fixed crashes in IDE
  <li>06/04/00 - Egg - Creation
  </ul></font>
}
unit FDGLXCollectionEditor;

interface

{$I GLScene.inc}

uses
  System.Classes, System.SysUtils, System.Actions,
  VCL.Forms, VCL.ImgList, VCL.Controls, VCL.ActnList, VCL.Menus,
  VCL.ComCtrls, VCL.ToolWin, VCL.Dialogs,

  DesignIntf,

  //GLS
  DGLScene,
  //DGLBehaviours,
  DGLMaterial,
  DGLXCollection, System.ImageList;

type
  TDGLXCollectionEditor = class(TForm)
    ListView: TListView;
    PMListView: TPopupMenu;
    ActionList: TActionList;
    ACRemove: TAction;
    ACMoveUp: TAction;
    ACMoveDown: TAction;
    ImageList: TImageList;
    MIAdd: TMenuItem;
    N1: TMenuItem;
    N2: TMenuItem;
    Moveup1: TMenuItem;
    Movedown1: TMenuItem;
    ToolBar1: TToolBar;
    TBAdd: TToolButton;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    ToolButton4: TToolButton;
    ToolButton5: TToolButton;
    ToolButton6: TToolButton;
    PMToolBar: TPopupMenu;
    procedure TBAddClick(Sender: TObject);
    procedure ListViewChange(Sender: TObject; Item: TListItem;
      Change: TItemChange);
    procedure ACRemoveExecute(Sender: TObject);
    procedure ACMoveUpExecute(Sender: TObject);
    procedure ACMoveDownExecute(Sender: TObject);
    procedure PMToolBarPopup(Sender: TObject);
    procedure PMListViewPopup(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormHide(Sender: TObject);
  private
    { Private declarations }
    FXCollection: TDGLXCollection;
    // ownerComponent : TComponent;
    FDesigner: IDesigner;
    UpdatingListView: Boolean;
    procedure PrepareListView;
    procedure PrepareXCollectionItemPopup(parent: TMenuItem);
    procedure OnAddXCollectionItemClick(Sender: TObject);
    procedure OnNameChanged(Sender: TObject);
    procedure OnXCollectionDestroyed(Sender: TObject);
  protected
    procedure Notification(AComponent: TComponent;
      Operation: TOperation); override;
  public
    { Public declarations }
    procedure SetXCollection(aXCollection: TDGLXCollection; designer: IDesigner );
  end;

function DGLXCollectionEditor: TDGLXCollectionEditor;
procedure ReleaseDGLXCollectionEditor;

// ------------------------------------------------------------------
// ------------------------------------------------------------------
// ------------------------------------------------------------------
implementation
// ------------------------------------------------------------------
// ------------------------------------------------------------------
// ------------------------------------------------------------------

{$R *.dfm}

resourcestring
  cXCollectionEditor = 'XCollection editor';

var
  vXCollectionEditor: TDGLXCollectionEditor;

function DGLXCollectionEditor: TDGLXCollectionEditor;
begin
  if not Assigned(vXCollectionEditor) then
    vXCollectionEditor := TDGLXCollectionEditor.Create(nil);
  Result := vXCollectionEditor;
end;

procedure ReleaseDGLXCollectionEditor;
begin
  if Assigned(vXCollectionEditor) then
  begin
    vXCollectionEditor.Release;
    vXCollectionEditor := nil;
  end;
end;

// FormCreate
//
procedure TDGLXCollectionEditor.FormCreate(Sender: TObject);
begin
  RegisterGLBehaviourNameChangeEvent(OnNameChanged);
  RegisterGLMaterialNameChangeEvent(OnNameChanged);
  RegisterXCollectionDestroyEvent(OnXCollectionDestroyed);
end;

// FormDestroy
//
procedure TDGLXCollectionEditor.FormDestroy(Sender: TObject);
begin
  DeRegisterGLBehaviourNameChangeEvent(OnNameChanged);
  DeRegisterGLMaterialNameChangeEvent(OnNameChanged);
  DeRegisterXCollectionDestroyEvent(OnXCollectionDestroyed);
end;

// FormHide
//
procedure TDGLXCollectionEditor.FormHide(Sender: TObject);
begin
  SetXCollection(nil, nil);
  ReleaseDGLXCollectionEditor;
end;

// SetXCollection
//
procedure TDGLXCollectionEditor.SetXCollection(aXCollection: TDGLXCollection; designer: IDesigner);
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

// TBAddClick
//
procedure TDGLXCollectionEditor.TBAddClick(Sender: TObject);
begin
  TBAdd.CheckMenuDropdown;
end;

// ListViewChange
//
procedure TDGLXCollectionEditor.ListViewChange(Sender: TObject; Item: TListItem; Change: TItemChange);
var
  sel: Boolean;
begin
  if (Change = ctState) and Assigned(FDesigner) and (not updatingListView) then
  begin
    // setup enablings
    sel := (ListView.Selected <> nil);
    TBAdd.Enabled := Assigned(FDesigner);
    ACRemove.Enabled := sel;
    ACMoveUp.Enabled := sel and (ListView.Selected.Index > 0);
    ACMoveDown.Enabled := sel and
      (ListView.Selected.Index < ListView.Items.Count - 1);
    if Assigned(FDesigner) then
      if sel then
        FDesigner.SelectComponent(TDGLXCollectionItem(ListView.Selected.Data))
      else
        FDesigner.SelectComponent(nil);
  end;
end;

// PrepareListView
//
procedure TDGLXCollectionEditor.PrepareListView;
var
  i: Integer;
  prevSelData: Pointer;
  XCollectionItem: TDGLXCollectionItem;
  DisplayedName: String;
begin
  Assert(Assigned(ListView));
  updatingListView := True;
  try
    if ListView.Selected <> nil then
      prevSelData := ListView.Selected.Data
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
            SubItems.Add(XCollectionItem.FriendlyName);
            Data := XCollectionItem;
          end;
        if prevSelData <> nil then
          ListView.Selected := ListView.FindData(0, prevSelData, True, False);
      end;
      EndUpdate;
    end;
  finally
    updatingListView := False;
  end;
  ListViewChange(Self, nil, ctState);
end;

// PrepareXCollectionItemPopup
//
procedure TDGLXCollectionEditor.PrepareXCollectionItemPopup(parent: TMenuItem);
var
  i: Integer;
  list: TList;
  XCollectionItemClass: TDGLXCollectionItemClass;
  mi, categoryItem: TMenuItem;
begin
  list := GetDGLXCollectionItemClassesList(FXCollection.ItemsClass);
  try
    parent.Clear;
    for i := 0 to list.Count - 1 do
    begin
      XCollectionItemClass := TDGLXCollectionItemClass(list[i]);
      if XCollectionItemClass.ItemCategory <> '' then
      begin
        categoryItem := parent.Find(XCollectionItemClass.ItemCategory);
        if categoryItem = nil then
        begin
          categoryItem := TMenuItem.Create(owner);
          categoryItem.Caption := XCollectionItemClass.ItemCategory;
          parent.Add(categoryItem);
        end;
      end
      else
        categoryItem := parent;

      mi := TMenuItem.Create(owner);
      mi.Caption := XCollectionItemClass.FriendlyName;
      mi.OnClick := OnAddXCollectionItemClick;
      mi.Tag := Integer(XCollectionItemClass);
      mi.Enabled := Assigned(FXCollection) and
        FXCollection.CanAdd(XCollectionItemClass);
      categoryItem.Add(mi);
    end;
  finally
    list.Free;
  end;
end;

// OnNameChanged
//
procedure TDGLXCollectionEditor.OnNameChanged(Sender: TObject);
begin
  if TDGLXCollectionItem(Sender).owner = FXCollection then
    PrepareListView;
end;

// OnXCollectionDestroyed
//
procedure TDGLXCollectionEditor.OnXCollectionDestroyed(Sender: TObject);
begin
  if TDGLXCollection(Sender) = FXCollection then
    Close;
end;

// Notification
//
procedure TDGLXCollectionEditor.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  { if (Operation=opRemove) and (AComponent=ownerComponent) then begin
    ownerComponent:=nil;
    SetXCollection(nil, nil);
    Close;
    end;
  }
  inherited;
end;

// OnAddXCollectionItemClick
//
procedure TDGLXCollectionEditor.OnAddXCollectionItemClick(Sender: TObject);
var
  XCollectionItemClass: TDGLXCollectionItemClass;
  XCollectionItem: TDGLXCollectionItem;
begin
  XCollectionItemClass := TDGLXCollectionItemClass((Sender as TMenuItem).Tag);
  XCollectionItem := XCollectionItemClass.Create(FXCollection);
  PrepareListView;
  ListView.Selected := ListView.FindData(0, XCollectionItem, True, False);
  FDesigner.Modified;
end;

// ACRemoveExecute
//
procedure TDGLXCollectionEditor.ACRemoveExecute(Sender: TObject);
begin
  if ListView.Selected <> nil then
  begin
    FDesigner.Modified;
    FDesigner.SelectComponent(FXCollection.owner);

    TDGLXCollectionItem(ListView.Selected.Data).Free;
    ListView.Selected.Free;
    ListViewChange(Self, nil, ctState);
  end;
end;

// ACMoveUpExecute
//
procedure TDGLXCollectionEditor.ACMoveUpExecute(Sender: TObject);
begin
  if ListView.Selected <> nil then
  begin
    TDGLXCollectionItem(ListView.Selected.Data).MoveUp;
    PrepareListView;
    FDesigner.Modified;
  end;
end;

// ACMoveDownExecute
//
procedure TDGLXCollectionEditor.ACMoveDownExecute(Sender: TObject);
begin
  if ListView.Selected <> nil then
  begin
    TDGLXCollectionItem(ListView.Selected.Data).MoveDown;
    PrepareListView;
    FDesigner.Modified;
  end;
end;

// PMToolBarPopup
//
procedure TDGLXCollectionEditor.PMToolBarPopup(Sender: TObject);
begin
  PrepareXCollectionItemPopup(PMToolBar.Items);
end;

// PMListViewPopup
//
procedure TDGLXCollectionEditor.PMListViewPopup(Sender: TObject);
begin
  PrepareXCollectionItemPopup(MIAdd);
end;

initialization

finalization

ReleaseDGLXCollectionEditor;

end.
