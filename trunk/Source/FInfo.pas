//
// This unit is part of the GLScene Project, http://glscene.org
//
{  
  Informations on OpenGL driver. 

   History :  
   23/08/10 - Yar - Added OpenGLTokens to uses, replaced OpenGL1x functions to OpenGLAdapter
   13/06/10 - DaStr - Removed compiler hints
   04/05/10 - Yar - Redecoration (thanks Conferno and Predator)
   20/02/10 - DanB - Now uses correct DC, rather than using
  the info form (bug due to "with" keyword)
   25/10/08 - DanB - Delphi 2009 compatibility, extensions are now looked
  up from www.opengl.org/registry/
   29/03/07 - DaStr - Renamed LINUX to KYLIX (BugTrackerID=1681585)
   08/07/04 - LR - Suppress CommCtrl in the uses of Linux
   06/07/04 - LR - Display some infos for Linux
   03/07/04 - LR - Make change for Linux
   21/02/04 - EG - Added extensions popup menu and hyperlink to
  Delphi3D's hardware registry
   08/02/04 - NelC - Added option for modal
   09/09/03 - NelC - Added Renderer info
   26/06/03 - EG - Double-clicking an extension will now go to its OpenGL
  registry webpage
   22/05/03 - EG - Added Texture Units info
   21/07/02 - EG - No longer modal
   03/02/02 - EG - InfoForm registration mechanism
   24/08/01 - EG - Compatibility with new Buffer classes
   17/04/00 - EG - Creation of header, minor layout changes
   
}
unit FInfo;

interface

{$I GLScene.inc}

uses
  Winapi.Windows,
  System.SysUtils, System.Classes,
  VCL.Forms, VCL.Controls, VCL.Buttons, VCL.StdCtrls, VCL.ComCtrls,
  VCL.ExtCtrls, VCL.Graphics, VCL.Menus, VCL.Imaging.JPEG,

  GLScene, GLWin32Viewer,
  OpenGLTokens, OpenGLAdapter, GLContext, GLCrossPlatform;

type

  TGLInfoForm = class(TForm)
    AccLabel: TLabel;
    AccumLabel: TLabel;
    AuxLabel: TLabel;
    ClipLabel: TLabel;
    ColorLabel: TLabel;
    CopyLabel: TLabel;
    DepthLabel: TLabel;
    DoubleLabel: TLabel;
    EvalLabel: TLabel;
    Image: TImage;
    Label1: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    Label14: TLabel;
    Label15: TLabel;
    Label16: TLabel;
    Label17: TLabel;
    Label18: TLabel;
    Label2: TLabel;
    Label20: TLabel;
    Label23: TLabel;
    Label25: TLabel;
    Label26: TLabel;
    Label27: TLabel;
    Label28: TLabel;
    Label29: TLabel;
    Label3: TLabel;
    Label30: TLabel;
    LabelCommon: TLabel;
    LabelDepths: TLabel;
    LabelMaxValues: TLabel;
    Label34: TLabel;
    Label35: TLabel;
    Label37: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    LightLabel: TLabel;
    ListLabel: TLabel;
    MemoAbout: TMemo;
    MemoContributors: TMemo;
    ModelLabel: TLabel;
    NameLabel: TLabel;
    OverlayLabel: TLabel;
    PageControl: TPageControl;
    PixelLabel: TLabel;
    ProjLabel: TLabel;
    RendererLabel: TLabel;
    ScrollBoxInfo: TScrollBox;
    TabSheetInformation: TTabSheet;
    StencilLabel: TLabel;
    StereoLabel: TLabel;
    SubLabel: TLabel;
    TabSheetAbout: TTabSheet;
    TabSheetContributors: TTabSheet;
    TexSizeLabel: TLabel;
    TexStackLabel: TLabel;
    TexUnitsLabel: TLabel;
    UnderlayLabel: TLabel;
    VendorLabel: TLabel;
    VersionLabel: TLabel;
    TabSheetExtensions: TTabSheet;
    ListBoxExtensions: TListBox;
    PMWebLink: TPopupMenu;
    MIRegistryLink: TMenuItem;
    MIDelphi3D: TMenuItem;
    TabSheetGLScene: TTabSheet;
    CloseButton: TButton;
    VersionLbl: TLabel;
    ViewLabel: TLabel;
    WebsiteLbl: TLabel;
    procedure CloseButtonClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure ListBoxExtensionsDblClick(Sender: TObject);
    procedure ListBoxExtensionsClick(Sender: TObject);
    procedure ListBoxExtensionsKeyPress(Sender: TObject; var Key: Char);
    procedure FormShow(Sender: TObject);
    procedure MIDelphi3DClick(Sender: TObject);
    procedure WebsiteLblClick(Sender: TObject);
  protected
    procedure LoadContributors;
    function GetSceneVersion: string;
  public
    procedure GetInfoFrom(aSceneBuffer: TGLSceneBuffer);
  end;

implementation

{$R *.dfm}
{$R FInfo.res}

// ShowInfoForm
//
procedure ShowInfoForm(aSceneBuffer: TGLSceneBuffer; Modal: boolean);
var
  GLInfoForm: TGLInfoForm;
begin
  GLInfoForm := TGLInfoForm.Create(nil);
  try
    GLInfoForm.GetInfoFrom(aSceneBuffer);
    with GLInfoForm do
      if Modal then
        ShowModal
      else
        Show;
  except
    GLInfoForm.Free;
    raise;
  end;
end;

// FormCreate
//
procedure TGLInfoForm.FormCreate(Sender: TObject);
begin
  PageControl.ActivePageIndex := 0;
end;

// FormShow
//
procedure TGLInfoForm.FormShow(Sender: TObject);
begin
  PageControl.ActivePageIndex := 0;
end;

// GetInfoFrom
//
procedure TGLInfoForm.GetInfoFrom(aSceneBuffer: TGLSceneBuffer);
const
  DRIVER_MASK = PFD_GENERIC_FORMAT or PFD_GENERIC_ACCELERATED;
var
  pfd: TPixelformatDescriptor;
  pixelFormat: Integer;
  dc: HDC;
  i: Integer;
  ExtStr: String;

  procedure IntLimitToLabel(const aLabel: TLabel; const aLimit: TLimitType);
  begin
    aLabel.Caption := IntToStr(aSceneBuffer.LimitOf[aLimit]);
  end;

begin
  Caption := Caption + ' (current context in ' +
    (aSceneBuffer.Owner as TComponent).Name + ')';
  aSceneBuffer.RenderingContext.Activate;
  try
    with aSceneBuffer do
    begin
      // common properties
      VendorLabel.Caption := String(GL.GetString(GL_VENDOR));
      RendererLabel.Caption := String(GL.GetString(GL_RENDERER));
      dc := wglGetCurrentDC();
      pixelFormat := GetPixelFormat(dc);
      DescribePixelFormat(dc, pixelFormat, SizeOf(pfd), pfd);
      // figure out the driver type
      if (DRIVER_MASK and pfd.dwFlags) = 0 then
        AccLabel.Caption := 'Installable Client Driver'
      else if (DRIVER_MASK and pfd.dwFlags) = DRIVER_MASK then
        AccLabel.Caption := 'Mini-Client Driver'
      else if (DRIVER_MASK and pfd.dwFlags) = PFD_GENERIC_FORMAT then
        AccLabel.Caption := 'Generic Software Driver';
      VersionLabel.Caption := String(GL.GetString(GL_VERSION));
      ExtStr := String(GL.GetString(GL_EXTENSIONS));
      ListBoxExtensions.Clear;
      while Length(ExtStr) > 0 do
      begin
        i := Pos(' ', ExtStr);
        if i = 0 then
          i := 255;
        ListBoxExtensions.Items.Add(Copy(ExtStr, 1, i - 1));
        Delete(ExtStr, 1, i);
      end;

      if LimitOf[limDoubleBuffer] = GL_TRUE then
        DoubleLabel.Caption := 'yes'
      else
        DoubleLabel.Caption := 'no';

      if LimitOf[limStereo] = GL_TRUE then
        StereoLabel.Caption := 'yes'
      else
        StereoLabel.Caption := 'no';

      // Include WGL extensions
      if GL.W_ARB_extensions_string then
      begin
        ExtStr := String(GL.WGetExtensionsStringARB(dc));
        while Length(ExtStr) > 0 do
        begin
          i := Pos(' ', ExtStr);
          if i = 0 then
            i := 255;
          ListBoxExtensions.Items.Add(Copy(ExtStr, 1, i - 1));
          Delete(ExtStr, 1, i);
        end;
      end;

      // Some extra info about the double buffer mode
      if (pfd.dwFlags and PFD_DOUBLEBUFFER) = PFD_DOUBLEBUFFER then
      begin
        CopyLabel.Caption := '';
        if (pfd.dwFlags and PFD_SWAP_EXCHANGE) > 0 then
          CopyLabel.Caption := 'exchange';
        if (pfd.dwFlags and PFD_SWAP_COPY) > 0 then
        begin
          if Length(CopyLabel.Caption) > 0 then
            CopyLabel.Caption := CopyLabel.Caption + ', ';
          CopyLabel.Caption := CopyLabel.Caption + 'copy';
        end;
        if Length(CopyLabel.Caption) = 0 then
          CopyLabel.Caption := 'no info available';
      end
      else
      begin
        CopyLabel.Caption := 'n/a';
      end;
      // buffer and pixel depths
      ColorLabel.Caption :=
        Format('red: %d,  green: %d,  blue: %d,  alpha: %d  bits',
        [LimitOf[limRedBits], LimitOf[limGreenBits], LimitOf[limBlueBits],
        LimitOf[limAlphaBits]]);
      DepthLabel.Caption := Format('%d bits', [LimitOf[limDepthBits]]);
      StencilLabel.Caption := Format('%d bits', [LimitOf[limStencilBits]]);
      AccumLabel.Caption :=
        Format('red: %d,  green: %d,  blue: %d,  alpha: %d  bits',
        [LimitOf[limAccumRedBits], LimitOf[limAccumGreenBits],
        LimitOf[limAccumBlueBits], LimitOf[limAccumAlphaBits]]);
      IntLimitToLabel(AuxLabel, limAuxBuffers);
      IntLimitToLabel(SubLabel, limSubpixelBits);
      OverlayLabel.Caption := IntToStr(pfd.bReserved and 7);
      UnderlayLabel.Caption := IntToStr(pfd.bReserved shr 3);

      // Maximum values
      IntLimitToLabel(ClipLabel, limClipPlanes);
      IntLimitToLabel(EvalLabel, limEvalOrder);
      IntLimitToLabel(LightLabel, limLights);
      IntLimitToLabel(ListLabel, limListNesting);
      IntLimitToLabel(ModelLabel, limModelViewStack);
      IntLimitToLabel(ViewLabel, limViewportDims);

      IntLimitToLabel(NameLabel, limNameStack);
      IntLimitToLabel(PixelLabel, limPixelMapTable);
      IntLimitToLabel(ProjLabel, limProjectionStack);
      IntLimitToLabel(TexSizeLabel, limTextureSize);
      IntLimitToLabel(TexStackLabel, limTextureStack);
      IntLimitToLabel(TexUnitsLabel, limNbTextureUnits);
    end;
    VersionLbl.Caption := GetSceneVersion;
  finally
    aSceneBuffer.RenderingContext.Deactivate;
  end;
end;

// CloseButtonClick
//
procedure TGLInfoForm.CloseButtonClick(Sender: TObject);
begin
  Close;
end;

// -------------------------------------------------------------------
//
procedure TGLInfoForm.FormKeyPress(Sender: TObject; var Key: Char);

begin
  if Key = #27 then
    Close;
end;

// -------------------------------------------------------------------
//
procedure TGLInfoForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Release;
end;

// -------------------------------------------------------------------
//
procedure TGLInfoForm.ListBoxExtensionsDblClick(Sender: TObject);
var
  p: Integer;
  url, buf: String;
begin
  with ListBoxExtensions do
  begin
    if ItemIndex < 0 then
      Exit;
    url := Items[ItemIndex];
  end;
  p := Pos('_', url);
  buf := Copy(url, 1, p - 1);
  url := Copy(url, p + 1, 255);
  if (buf <> 'GL') and (buf <> 'WGL') and (buf <> 'GLX') then
    Exit;
  p := Pos('_', url);
  buf := Copy(url, 1, p - 1);
  url := 'http://www.opengl.org/registry/specs/' + buf + '/' +
    Copy(url, p + 1, 255) + '.txt';
  ShowHTMLUrl(url);
end;

// -------------------------------------------------------------------
//
procedure TGLInfoForm.MIDelphi3DClick(Sender: TObject);
var
  url: String;
begin
  with ListBoxExtensions do
  begin
    if ItemIndex < 0 then
      Exit;
    url := 'http://www.delphi3d.net/hardware/extsupport.php?extension=' +
      Items[ItemIndex];
  end;
  ShowHTMLUrl(url);
end;

// -------------------------------------------------------------------
//
procedure TGLInfoForm.ListBoxExtensionsClick(Sender: TObject);
var
  extName: String;
begin
  if ListBoxExtensions.ItemIndex < 0 then
    ListBoxExtensions.PopupMenu := nil
  else
  begin
    ListBoxExtensions.PopupMenu := PMWebLink;
    extName := ListBoxExtensions.Items[ListBoxExtensions.ItemIndex];
    MIRegistryLink.Caption := 'View OpenGL Extension Registry for ' + extName;
    MIDelphi3D.Caption := 'View Delphi3D Hardware Registry for ' + extName;
  end;
end;

procedure TGLInfoForm.ListBoxExtensionsKeyPress(Sender: TObject; var Key: Char);
begin
  ListBoxExtensionsClick(Sender);
end;

// -------------------------------------------------------------------
//
procedure TGLInfoForm.LoadContributors;
// var
// ContributorsFileName: string;
begin
  // In the future, will be loaded from a file

  { ContributorsFileName:=
    // 'GLSceneContributors.txt';

    if FileExistsUTF8(ContributorsFileName) then
    MemoContributors.Lines.LoadFromFile(UTF8ToSys(ContributorsFileName))
    else
    MemoContributors.Lines.Text:='Cannot find contributors list.';
    MemoContributors.Lines.Add( ContributorsFileName) }
end;

// -------------------------------------------------------------------
//
function TGLInfoForm.GetSceneVersion: string;
var
  FExePath, FGLSceneRevision: string;
begin
  FGLSceneRevision := Copy(GLSCENE_REVISION, 12, 4);
  FExePath := ExtractFilePath(ParamStr(0));
  if FileExists(FExePath + 'GLSceneRevision') then
  try
    with TStringList.Create do
    try
      LoadFromFile(FExePath + 'GLSceneRevision');
      if (Count >= 1) and (trim(Strings[0]) <> '') then
        FGLSceneRevision:= trim(Strings[0]);
    finally
      Free;
    end;
  except
  end;

  Result := Format(GLSCENE_VERSION, [FGLSceneRevision]);
end;

// ------------------------------------------------------------------------------
// ------------------------------------------------------------------------------
// ------------------------------------------------------------------------------
procedure TGLInfoForm.WebsiteLblClick(Sender: TObject);
begin
  ShowHTMLUrl(WebsiteLbl.Caption);
end;

initialization

// ------------------------------------------------------------------------------
// ------------------------------------------------------------------------------
// ------------------------------------------------------------------------------

RegisterInfoForm(ShowInfoForm);

end.

