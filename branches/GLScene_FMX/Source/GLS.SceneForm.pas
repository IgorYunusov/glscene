﻿//
// This unit is part of the GLScene Project, http://glscene.org
//
{ : GLS.SceneForm<p>

  <b>History : </b><font size=-1><ul>
  <li>05/04/11 - Yar - Added property FullScreenVideoMode (thanks to ltyrosine)
  <li>08/12/10 - Yar - Added code for Lazarus (thanks Rustam Asmandiarov aka Predator)
  <li>23/08/10 - Yar - Creation
  </ul></font>
}

unit GLS.SceneForm;

interface

{$I GLScene.inc}

uses
  Winapi.Windows,
  Winapi.Messages,
  System.Classes,
  System.UITypes,
  FMX.Controls,
  FMX.Forms,
  FMX.Types,

  GLS.Scene,
  GLS.Context,
  GLS.CrossPlatform,
  GLS.Screen,
  GLS.SceneViewer;

const
  lcl_major = 0;
  lcl_minor = 0;
  lcl_release = 0;

type

  TGLSceneForm = class;

  // TGLFullScreenResolution
  //
  {: Defines how GLSceneForm will handle fullscreen request
     fcWindowMaximize: Use current resolution (just maximize form and hide OS bars)
     fcNearestResolution: Change to nearest valid resolution from current window size
     fcManualResolution: Use FFullScreenVideoMode settings }
  TGLFullScreenResolution = (
    fcUseCurrent,
    fcNearestResolution,
    fcManualResolution);

  // TGLFullScreenVideoMode
  //
  {: Screen mode settings }
  TGLFullScreenVideoMode = class(TPersistent)
  private
    FOwner: TGLSceneForm;
    FEnabled: Boolean;
    FAltTabSupportEnable: Boolean;
    FWidth: Integer;
    FHeight: Integer;
    FColorDepth: Integer;
    FFrequency: Integer;
    FResolutionMode: TGLFullScreenResolution;
    procedure SetEnabled(aValue: Boolean);
    procedure SetAltTabSupportEnable(aValue: Boolean);
  public
    constructor Create(AOwner: TGLSceneForm);
  published
    property Enabled: Boolean read FEnabled write SetEnabled default False;
    property AltTabSupportEnable: Boolean read FAltTabSupportEnable
      write SetAltTabSupportEnable default False;
    property ResolutionMode: TGLFullScreenResolution read FResolutionMode
      write FResolutionMode default fcUseCurrent;
    property Width: Integer read FWidth write FWidth;
    property Height: Integer read FHeight write FHeight;
    property ColorDepth: Integer read FColorDepth write FColorDepth;
    property Frequency: Integer read FFrequency write FFrequency;
  end;

  { TGLSceneForm }

  TGLSceneForm = class(TForm)
  private
    { Private Declarations }
    FBuffer: TGLSceneBuffer;
    FVSync: TVSyncMode;
    FOwnDC: HDC;
    FFullScreenVideoMode: TGLFullScreenVideoMode;
    procedure SetBeforeRender(const val: TNotifyEvent);
    function GetBeforeRender: TNotifyEvent;
    procedure SetPostRender(const val: TNotifyEvent);
    function GetPostRender: TNotifyEvent;
    procedure SetAfterRender(const val: TNotifyEvent);
    function GetAfterRender: TNotifyEvent;
    procedure SetCamera(const val: TGLCamera);
    function GetCamera: TGLCamera;
    procedure SetBuffer(const val: TGLSceneBuffer);

    function GetFieldOfView: single;
    procedure SetFieldOfView(const Value: single);
    function GetIsRenderingContextAvailable: Boolean;

    procedure WMEraseBkgnd(var Message: TWMEraseBkgnd); message WM_ERASEBKGND;
    procedure WMPaint(var Message: TWMPaint); message WM_PAINT;
    procedure WMSize(var Message: TWMSize); message WM_SIZE;
    procedure WMDestroy(var Message: TWMDestroy); message WM_DESTROY;
    procedure LastFocus(var Mess: TMessage); message WM_ACTIVATE;

    procedure SetFullScreenVideoMode(AValue: TGLFullScreenVideoMode);
    procedure StartupFS;
    procedure ShutdownFS;
  protected
    { Protected Declarations }
    procedure Notification(AComponent: TComponent; Operation: TOperation);
      override;
    { TODO : E2137 Method 'CreateWnd' not found in base class }
    (*procedure CreateWnd; override;*)
    procedure Loaded; override;

    procedure DoBeforeRender(Sender: TObject); dynamic;
    procedure DoBufferChange(Sender: TObject); virtual;
    procedure DoBufferStructuralChange(Sender: TObject); dynamic;

    procedure MouseMove(Shift: TShiftState; X, Y: Single); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    { TODO : E2137 Method 'DestroyWnd' not found in base class }
    (*procedure DestroyWnd; override;*)

    property IsRenderingContextAvailable: Boolean read
      GetIsRenderingContextAvailable;
    property RenderDC: HDC read FOwnDC;
  published
    { Published Declarations }
    { : Camera from which the scene is rendered. }
    property Camera: TGLCamera read GetCamera write SetCamera;

    { : Specifies if the refresh should be synchronized with the VSync signal.<p>
      If the underlying OpenGL ICD does not support the WGL_EXT_swap_control
      extension, this property is ignored. }
    property VSync: TVSyncMode read FVSync write FVSync default vsmNoSync;

    { : Triggered before the scene's objects get rendered.<p>
      You may use this event to execute your own OpenGL rendering. }
    property BeforeRender: TNotifyEvent read GetBeforeRender write
      SetBeforeRender;
    { : Triggered just after all the scene's objects have been rendered.<p>
      The OpenGL context is still active in this event, and you may use it
      to execute your own OpenGL rendering.<p> }
    property PostRender: TNotifyEvent read GetPostRender write SetPostRender;
    { : Called after rendering.<p>
      You cannot issue OpenGL calls in this event, if you want to do your own
      OpenGL stuff, use the PostRender event. }
    property AfterRender: TNotifyEvent read GetAfterRender write SetAfterRender;

    { : Access to buffer properties. }
    property Buffer: TGLSceneBuffer read FBuffer write SetBuffer;

    { : Returns or sets the field of view for the viewer, in degrees.<p>
      This value depends on the camera and the width and height of the scene.
      The value isn't persisted, if the width/height or camera.focallength is
      changed, FieldOfView is changed also. }
    property FieldOfView: single read GetFieldOfView write SetFieldOfView;

    property FullScreenVideoMode: TGLFullScreenVideoMode read
      FFullScreenVideoMode
      write SetFullScreenVideoMode;
  end;

implementation

constructor TGLSceneForm.Create(AOwner: TComponent);
begin
  FBuffer := TGLSceneBuffer.Create(Self);
  FVSync := vsmNoSync;
  FBuffer.ViewerBeforeRender := DoBeforeRender;
  FBuffer.OnChange := DoBufferChange;
  FBuffer.OnStructuralChange := DoBufferStructuralChange;
  FFullScreenVideoMode := TGLFullScreenVideoMode.Create(Self);
  inherited Create(AOwner);
end;

destructor TGLSceneForm.Destroy;
begin
  FBuffer.Free;
  FBuffer := nil;
  FFullScreenVideoMode.Destroy;
  inherited Destroy;
end;

// Notification
//

procedure TGLSceneForm.Notification(AComponent: TComponent; Operation:
  TOperation);
begin
  if (Operation = opRemove) and (FBuffer <> nil) then
  begin
    if (AComponent = FBuffer.Camera) then
      FBuffer.Camera := nil;
  end;
  inherited;
end;

// CreateWnd
//
(*
procedure TGLSceneForm.CreateWnd;
begin
  inherited CreateWnd;
  // initialize and activate the OpenGL rendering context
  // need to do this only once per window creation as we have a private DC
  FBuffer.Resize(0, 0, Self.Width, Self.Height);
  FOwnDC := GetDC(Handle);
  FBuffer.CreateRC(FOwnDC, false);
end;
*)
// DestroyWnd
//
(*
procedure TGLSceneForm.DestroyWnd;
begin
  if Assigned(FBuffer) then
  begin
    FBuffer.DestroyRC;
    if FOwnDC <> 0 then
    begin
      ReleaseDC(Handle, FOwnDC);
      FOwnDC := 0;
    end;
  end;
  inherited;
end;
*)
// Loaded
//

procedure TGLSceneForm.Loaded;
begin
  inherited Loaded;
  // initiate window creation
  { TODO : E2003 Undeclared identifier: 'HandleNeeded' }
  (*HandleNeeded;*)
  if not (csDesigning in ComponentState) then
  begin
    if FFullScreenVideoMode.FEnabled then
      StartupFS;
  end;
end;

// WMEraseBkgnd
//

procedure TGLSceneForm.WMEraseBkgnd(var Message: TWMEraseBkgnd);
begin
  if GetIsRenderingContextAvailable then
    Message.Result := 1
  else
    inherited;
end;

// WMSize
//

procedure TGLSceneForm.WMSize(var Message: TWMSize);
begin
  inherited;
  if Assigned(FBuffer) then
    FBuffer.Resize(0, 0, Message.Width, Message.Height);
end;

// WMPaint
//

procedure TGLSceneForm.WMPaint(var Message: TWMPaint);
var
  PS: TPaintStruct;
begin
  { TODO : E2010 Incompatible types: 'HWND' and 'TWindowHandle' }
  (*BeginPaint(Handle, PS);*)
  try
    if GetIsRenderingContextAvailable and (Width > 0) and (Height > 0) then
      FBuffer.Render;
  finally
  (*  EndPaint(Handle, PS); *)
    Message.Result := 0;
  end;
end;

// WMDestroy
//

procedure TGLSceneForm.WMDestroy(var Message: TWMDestroy);
begin
  if Assigned(FBuffer) then
  begin
    FBuffer.DestroyRC;
    if FOwnDC <> 0 then
    begin
      { TODO : E2010 Incompatible types: 'HWND' and 'TWindowHandle' }
      (*ReleaseDC(Handle, FOwnDC);*)
      FOwnDC := 0;
    end;
  end;
  inherited;
end;

// LastFocus
//

procedure TGLSceneForm.LastFocus(var Mess: TMessage);
begin
  if not (csDesigning in ComponentState)
    and FFullScreenVideoMode.FEnabled
    and FFullScreenVideoMode.FAltTabSupportEnable then
    begin
      if Mess.wParam = WA_INACTIVE then
      begin
        ShutdownFS;
      end
      else
      begin
        StartupFS;
      end;
    end;
  inherited;
end;

procedure TGLFullScreenVideoMode.SetEnabled(aValue: Boolean);
begin
  if FEnabled <> aValue then
  begin
    FEnabled := aValue;
    if not ((csDesigning in FOwner.ComponentState)
      or (csLoading in FOwner.ComponentState)) then
    begin
      if FEnabled then
        FOwner.StartupFS
      else
        FOwner.ShutdownFS;
    end;
  end;
end;

constructor TGLFullScreenVideoMode.Create(AOwner: TGLSceneForm);
begin
  inherited Create;
  FOwner := AOwner;
  FEnabled := False;
  FAltTabSupportEnable := False;
  ReadVideoModes;
{$IFDEF MSWINDOWS}
  FWidth := vVideoModes[0].Width;
  FHeight := vVideoModes[0].Height;
  FColorDepth := vVideoModes[0].ColorDepth;
  FFrequency := vVideoModes[0].MaxFrequency;
{$ENDIF}
{$IFDEF GLS_X11_SUPPORT}
  FWidth := vVideoModes[0].vdisplay;
  FHeight := vVideoModes[0].hdisplay;
  FColorDepth := 32;
  FFrequency := 0;
{$ENDIF}
{$IFDEF DARWIN}
  FWidth := 1280;
  FHeight := 1024;
  FColorDepth := 32;
  FFrequency := 0;
  {$Message Hint 'Fullscreen mode not yet implemented for Darwin OSes' }
{$ENDIF}
  if FFrequency = 0 then
    FFrequency := 50;
  FResolutionMode := fcUseCurrent;
end;

procedure TGLFullScreenVideoMode.SetAltTabSupportEnable(aValue: Boolean);
begin
  if FAltTabSupportEnable <> aValue then
    FAltTabSupportEnable := aValue;
end;

procedure TGLSceneForm.StartupFS;
begin
  case FFullScreenVideoMode.FResolutionMode of
    fcNearestResolution:
      begin
        SetFullscreenMode(GetIndexFromResolution(ClientWidth, ClientHeight,
{$IFDEF MSWINDOWS}
        vVideoModes[0].ColorDepth));
{$ELSE}
        32));
{$ENDIF}
      end;
    fcManualResolution:
      begin
        SetFullscreenMode(GetIndexFromResolution(FFullScreenVideoMode.Width , FFullScreenVideoMode.Height, FFullScreenVideoMode.ColorDepth), FFullScreenVideoMode.Frequency);
      end;
  end;

  Left := 0;
  Top := 0;
  BorderStyle := TFmxFormBorderStyle.None;
  FormStyle := TFormStyle.StayOnTop;
  BringToFront;
  WindowState := TWindowState.wsMaximized;
   { TODO : E2003 Undeclared identifier: 'MainFormOnTaskBar' }
  (*Application.MainFormOnTaskBar := True;*)
end;

procedure TGLSceneForm.ShutdownFS;
begin
  RestoreDefaultMode;
  SendToBack;
  WindowState := TWindowState.wsNormal;
  BorderStyle := TFmxFormBorderStyle.bsSingle;
  FormStyle := TFormStyle.fsNormal;
  Left := (Screen.Width div 2) - (Width div 2);
  Top := (Screen.Height div 2) - (Height div 2);
end;

// DoBeforeRender
//

procedure TGLSceneForm.DoBeforeRender(Sender: TObject);
begin
  SetupVSync(VSync);
end;

// DoBufferChange
//

procedure TGLSceneForm.DoBufferChange(Sender: TObject);
begin
  if (not Buffer.Rendering) and (not Buffer.Freezed) then
    Invalidate;
end;

// DoBufferStructuralChange
//

procedure TGLSceneForm.DoBufferStructuralChange(Sender: TObject);
begin
  { TODO : E2003 Undeclared identifier: 'RecreateWnd' }
  (*RecreateWnd;*)
end;

procedure TGLSceneForm.MouseMove(Shift: TShiftState; X, Y: Single);
begin
  inherited;
  { TODO : E2003 Undeclared identifier: 'csDesignInteractive' }
  (*if csDesignInteractive in ControlStyle then*)
    FBuffer.NotifyMouseMove(Shift, X, Y);
end;

// SetBeforeRender
//

procedure TGLSceneForm.SetBeforeRender(const val: TNotifyEvent);
begin
  FBuffer.BeforeRender := val;
end;

// GetBeforeRender
//

function TGLSceneForm.GetBeforeRender: TNotifyEvent;
begin
  Result := FBuffer.BeforeRender;
end;

// SetPostRender
//

procedure TGLSceneForm.SetPostRender(const val: TNotifyEvent);
begin
  FBuffer.PostRender := val;
end;

// GetPostRender
//

function TGLSceneForm.GetPostRender: TNotifyEvent;
begin
  Result := FBuffer.PostRender;
end;

// SetAfterRender
//

procedure TGLSceneForm.SetAfterRender(const val: TNotifyEvent);
begin
  FBuffer.AfterRender := val;
end;

// GetAfterRender
//

function TGLSceneForm.GetAfterRender: TNotifyEvent;
begin
  Result := FBuffer.AfterRender;
end;

// SetCamera
//

procedure TGLSceneForm.SetCamera(const val: TGLCamera);
begin
  FBuffer.Camera := val;
end;

// GetCamera
//

function TGLSceneForm.GetCamera: TGLCamera;
begin
  Result := FBuffer.Camera;
end;

// SetBuffer
//

procedure TGLSceneForm.SetBuffer(const val: TGLSceneBuffer);
begin
  FBuffer.Assign(val);
end;

// GetFieldOfView
//

function TGLSceneForm.GetFieldOfView: single;
begin
  if not Assigned(Camera) then
    Result := 0
  else if Width < Height then
    Result := Camera.GetFieldOfView(Width)
  else
    Result := Camera.GetFieldOfView(Height);
end;

// SetFieldOfView
//

procedure TGLSceneForm.SetFieldOfView(const Value: single);
begin
  if Assigned(Camera) then
  begin
    if Width < Height then
      Camera.SetFieldOfView(Value, Width)
    else
      Camera.SetFieldOfView(Value, Height);
  end;
end;

procedure TGLSceneForm.SetFullScreenVideoMode(AValue: TGLFullScreenVideoMode);
begin
end;

// GetIsRenderingContextAvailable
//

function TGLSceneForm.GetIsRenderingContextAvailable: Boolean;
begin
  Result := FBuffer.RCInstantiated and FBuffer.RenderingContext.IsValid;
end;

// ------------------------------------------------------------------
// ------------------------------------------------------------------
// ------------------------------------------------------------------
initialization

  // ------------------------------------------------------------------
  // ------------------------------------------------------------------
  // ------------------------------------------------------------------

  RegisterClass(TGLSceneForm);

end.