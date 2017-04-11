//
// VKScene Component Library, based on GLScene http://glscene.sourceforge.net 
//
{ 
   Scene Editor, for adding + removing scene objects within the Delphi IDE. 

}

unit FSceneEditor;

interface

uses
  System.SysUtils,
  System.Types,
  System.UITypes,
  System.Classes,
  System.Variants,
  System.Actions,
  FMX.Types,
  FMX.Controls,
  FMX.Forms,
  FMX.Graphics,
  FMX.Dialogs,
  FMX.Menus,
  FMX.ActnList,
  FMX.StdCtrls,
  FMX.Layouts,
  FMX.TreeView,
  FMX.ListView.Types,
  FMX.ListView,
  FMX.Objects,
  FMX.ListView.Appearances,
  FMX.ListView.Adapters.Base,
  FMX.Controls.Presentation,
  VKS.Scene,
  VKS.Win64Viewer,
  VKS.SceneRegister,
  VKS.Strings,
  FInfo,
  VKS.XCollection,
  VKS.CrossPlatform;

type
  TVKSceneEditorForm = class(TForm)
    ToolBar: TToolBar;
    PATree: TPanel;
    PAGallery: TPanel;
    PAEffects: TPanel;
    ActionList: TActionList;
    PMToolBar: TPopupMenu;
    PopupMenu: TPopupMenu;
    SaveDialog: TSaveDialog;
    OpenDialog: TOpenDialog;
    Tree: TTreeView;
    PABehaviours: TPanel;
    PMBehavioursToolBar: TPopupMenu;
    PMEffectsToolBar: TPopupMenu;
    BehavioursPopupMenu: TPopupMenu;
    ToolBarBehaviours: TToolBar;
    ToolBarEffects: TToolBar;
    GalleryListView: TListView;
    BehavioursListView: TListView;
    EffectsListView: TListView;
    ACLoadScene: TAction;
    ACSaveScene: TAction;
    ACStayOnTop: TAction;
    ACAddObject: TAction;
    ACAddBehaviour: TAction;
    ACAddEffect: TAction;
    ACMoveUp: TAction;
    ACMoveDown: TAction;
    ACExpand: TAction;
    ACDeleteObject: TAction;
    ACDeleteBehaviour: TAction;
    ACCut: TAction;
    ACCopy: TAction;
    ACPaste: TAction;
    ACInfo: TAction;
    TBLoadScene: TSpeedButton;
    ImLoadScene: TImage;
    TBInfo: TSpeedButton;
    ImInfo: TImage;
    TBPaste: TSpeedButton;
    ImPaste: TImage;
    TBCopy: TSpeedButton;
    ImCopy: TImage;
    TBCut: TSpeedButton;
    ImCut: TImage;
    TBDeleteObject: TSpeedButton;
    ImDeleteObject: TImage;
    TBExpand: TSpeedButton;
    ImExpand: TImage;
    TBMoveDown: TSpeedButton;
    ImMoveDown: TImage;
    TBMoveUp: TSpeedButton;
    ImMoveUp: TImage;
    TBCharacterPanels: TSpeedButton;
    ImCharacterPanels: TImage;
    TBGalleryPanel: TSpeedButton;
    ImGalleryPanel: TImage;
    TBAddObjects: TSpeedButton;
    ImAddObjects: TImage;
    TBStayOnTop: TSpeedButton;
    ImStayOnTop: TImage;
    TBSaveScene: TSpeedButton;
    ImSaveScene: TImage;
    TBSeparator1: TSpeedButton;
    TBSeparator2: TSpeedButton;
    TBSeparator3: TSpeedButton;
    TBSeparator4: TSpeedButton;
    ACGallery: TAction;
    ImArrowDown: TImage;
    ImArrowDownBeh: TImage;
    ImArrowDownEff: TImage;
    TBAddBehaviours: TSpeedButton;
    TBAddEffects: TSpeedButton;
    MIAddObject: TMenuItem;
    MIAddBehaviour: TMenuItem;
    MIAddEffect: TMenuItem;
    MICut: TMenuItem;
    MICopy: TMenuItem;
    MIPaste: TMenuItem;
    MIDelObject: TMenuItem;
    MIMoveUp: TMenuItem;
    MIMoveDown: TMenuItem;
    StyleBook: TStyleBook;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure ACInfoExecute(Sender: TObject);
  private
    
  public
    
  end;

function VKSceneEditorForm: TVKSceneEditorForm;
procedure ReleaseVKSceneEditorForm;

// ------------------------------------------------------------------
// ------------------------------------------------------------------
// ------------------------------------------------------------------
implementation
// ------------------------------------------------------------------
// ------------------------------------------------------------------
// ------------------------------------------------------------------

{$R *.fmx}

const
  cRegistryKey = 'Software\VKScene\VKSceneEdit';

var
  vVKSceneEditorForm: TVKSceneEditorForm;

function VKSceneEditorForm: TVKSceneEditorForm;
begin
  if not Assigned(vVKSceneEditorForm) then
    vVKSceneEditorForm := TVKSceneEditorForm.Create(nil);
  Result := vVKSceneEditorForm;
end;

procedure ReleaseVKSceneEditorForm;
begin
  if Assigned(vVKSceneEditorForm) then
  begin
    vVKSceneEditorForm.Free;
    vVKSceneEditorForm := nil;
  end;
end;

function ReadRegistryInteger(reg: TRegistry; const Name: string;
  defaultValue: Integer): Integer;
begin
  if reg.ValueExists(name) then
    Result := reg.ReadInteger(name)
  else
    Result := defaultValue;
end;

procedure TVKSceneEditorForm.FormCreate(Sender: TObject);
var
  CurrentNode: TTreeNode;
  reg: TRegistry;
begin
  RegisterGLBaseSceneObjectNameChangeEvent(OnBaseSceneObjectNameChanged);
  Tree.Images := ObjectManager.ObjectIcons;
  Tree.Indent := ObjectManager.ObjectIcons.Width;
  with Tree.Items do
  begin
    // first add the scene root
    CurrentNode := Add(nil, glsSceneRoot);
    with CurrentNode do
    begin
      ImageIndex := ObjectManager.SceneRootIndex;
      SelectedIndex := ImageIndex;
    end;
    // and the root for all objects
    FObjectNode := AddChild(CurrentNode, glsObjectRoot);
    FSceneObjects := FObjectNode;
    with FObjectNode do
    begin
      ImageIndex := ObjectManager.ObjectRootIndex;
      SelectedIndex := ImageIndex;
    end;
  end;
  // Build SubMenus
  SetObjectsSubItems(MIAddObject);
  MIAddObject.SubMenuImages := ObjectManager.ObjectIcons;
  SetObjectsSubItems(PMToolBar.Items);
  PMToolBar.Images := ObjectManager.ObjectIcons;

  SetBehavioursSubItems(MIAddBehaviour, nil);
  SetBehavioursSubItems(PMBehavioursToolbar.Items, nil);
  SetEffectsSubItems(MIAddEffect, nil);
  SetEffectsSubItems(PMEffectsToolbar.Items, nil);

  reg := TRegistry.Create;
  try
    if reg.OpenKey(cRegistryKey, true) then
    begin
      if reg.ValueExists('CharacterPanels') then
        TBCharacterPanels.Down := reg.ReadBool('CharacterPanels');
      TBCharacterPanelsClick(Self);

      if reg.ValueExists('ExpandTree') then
        TBExpand.Down := reg.ReadBool('ExpandTree');
      ACExpandExecute(Self);

      Left := ReadRegistryInteger(reg, 'Left', Left);
      Top := ReadRegistryInteger(reg, 'Top', Top);
      Width := ReadRegistryInteger(reg, 'Width', 250);
      Height := ReadRegistryInteger(reg, 'Height', Height);
    end;
  finally
    reg.Free;
  end;

  // Trigger the event OnEdited manualy
  Tree.OnEdited := TreeEdited;
end;

procedure TVKSceneEditorForm.FormDestroy(Sender: TObject);
var
  reg: TRegistry;
begin
  DeRegisterGLBaseSceneObjectNameChangeEvent(OnBaseSceneObjectNameChanged);

  reg := TRegistry.Create;
  try
    if reg.OpenKey(cRegistryKey, true) then
    begin
      reg.WriteBool('CharacterPanels', TBCharacterPanels.Down);
      reg.WriteBool('ExpandTree', TBExpand.Down);
      reg.WriteInteger('Left', Left);
      reg.WriteInteger('Top', Top);
      reg.WriteInteger('Width', Width);
      reg.WriteInteger('Height', Height);
    end;
  finally
    reg.Free;
  end;
end;

procedure TVKSceneEditorForm.ACInfoExecute(Sender: TObject);
var
  AScene: TVKSceneViewer;
begin
  AScene := TVKSceneViewer.Create(Self);
  AScene.Name := 'GLSceneEditor';
  AScene.Width := 0;
  AScene.Height := 0;
  AScene.parent := Self;
  try
    AScene.Buffer.ShowInfo;
  finally
    AScene.Free;
  end;
end;


end.
