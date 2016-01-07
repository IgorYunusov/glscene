//
// This unit is part of the DGLEngine Project, http://glscene.org
//
{ : DGLFBO
  @HTML (
  <p>Implements FBO support for DGLEngine.</p>
  <p>
  <b>History : </b><font size=-1><ul>
  <li>26/12/15 - JD - Imported and updated from GLScene
  </ul></font></p>
  <p>
  <b>Status : </b>DONE<br>
  <b>Todo : </b>
  <ul>
     <li></li>
  </ul></p> )
}
unit DGLFBO;

interface

{$I DGLEngine.inc}

uses
  System.SysUtils,
  // DGLE
  GLSLog,dglOpenGL, DGLContext, DGLContextHandles, DGLState,DGLRenderContextInfo,
  DGLTypes, DGLScene, DGLGraphics, DGLTextureFormat, DGLMaterial, DGLColor,
  DGLVectorTypes;
  // DGLMultisampleImage,


const
  MaxColorAttachments = 32;

type
  // ****************************************************************************************
  // TDGLRenderBuffer
  //
  TDGLRenderbuffer = class
  private
    FRenderbufferHandle: TDGLRenderbufferHandle;
    FWidth:              Integer;
    FHeight:             Integer;
    FStorageValid:       Boolean;
    function GetHandle: TGLuint;
    procedure SetHeight(const Value: Integer);
    procedure SetWidth(const Value: Integer);
  protected

    function GetInternalFormat: cardinal; virtual; abstract;

    procedure InvalidateStorage;
  public
    constructor Create;
    destructor Destroy; override;

    procedure Bind;
    procedure Unbind;
    { : Handle to the OpenGL render buffer object.<p>
      If the handle hasn't already been allocated, it will be allocated
      by this call (ie. do not use if no OpenGL context is active!) }
    property Handle: TGLuint read GetHandle;
    property Width: Integer read FWidth write SetWidth;
    property Height: Integer read FHeight write SetHeight;
  end;

  // ****************************************************************************************
  // TDGLDepthRBO
  //
  TDGLDepthRBO = class(TDGLRenderbuffer)
  private
    FDepthPrecision: TDGLDepthPrecision;
    procedure SetDepthPrecision(const Value: TDGLDepthPrecision);
  protected
    function GetInternalFormat: cardinal; override;
  public
    constructor Create;

    property DepthPrecision: TDGLDepthPrecision read FDepthPrecision write SetDepthPrecision;
  end;

  // ****************************************************************************************
  // TDGLStencilRBO
  //
  TDGLStencilRBO = class(TDGLRenderbuffer)
  private
    FStencilPrecision: TDGLStencilPrecision;
    procedure SetStencilPrecision(const Value: TDGLStencilPrecision);
  protected
    function GetInternalFormat: cardinal; override;
  public
    constructor Create;

    property StencilPrecision: TDGLStencilPrecision read FStencilPrecision write SetStencilPrecision;
  end;

  // ****************************************************************************************
  // TDGLFrameBuffer
  //
  TDGLFrameBuffer = class
  private
    FFrameBufferHandle: TDGLFramebufferHandle;
    FTarget:            TGLEnum;
    FWidth:             Integer;
    FHeight:            Integer;
    FLayer:             Integer;
    FLevel:             Integer;
    FTextureMipmap:     cardinal;
    FAttachedTexture:   array [0 .. MaxColorAttachments - 1] of TDGLFrameBufferAttachment;
    FDepthTexture:      TDGLFrameBufferAttachment;
    FDRBO:              TDGLDepthRBO;
    FSRBO:              TDGLStencilRBO;

    function GetStatus: TDGLFramebufferStatus;
    procedure SetHeight(const Value: Integer);
    procedure SetWidth(const Value: Integer);
    procedure SetLayer(const Value: Integer);
    procedure SetLevel(const Value: Integer);
  protected
    procedure AttachTexture(const attachment: TGLEnum; const textarget: TGLEnum; const texture: TGLuint; const level: TGLint; const layer: TGLint); overload;
    procedure ReattachTextures;
  public
    constructor Create;
    destructor Destroy; override;

    // attaches a depth rbo to the fbo
    // the depth buffer must have the same dimentions as the fbo
    procedure AttachDepthBuffer(DepthBuffer: TDGLDepthRBO); overload;
    // detaches depth attachment from the fbo
    procedure DetachDepthBuffer;

    // attaches a stencil rbo to the fbo
    // the stencil buffer must have the same dimentions as the fbo
    procedure AttachStencilBuffer(StencilBuffer: TDGLStencilRBO); overload;
    // detaches stencil attachment from the fbo
    procedure DetachStencilBuffer;

    // attaches a depth texture to the fbo
    // the depth texture must have the same dimentions as the fbo
    procedure AttachDepthTexture(texture: TDGLFrameBufferAttachment); overload;
    procedure DetachDepthTexture;

    procedure AttachTexture(n: cardinal; texture: TDGLFrameBufferAttachment); overload;
    procedure DetachTexture(n: cardinal);

    function GetStringStatus(out clarification: string): TDGLFramebufferStatus;
    property Status: TDGLFramebufferStatus read GetStatus;
    procedure Bind;
    procedure Unbind;

    procedure PreRender;
    procedure Render(var rci: TRenderContextInfo; baseObject: TDGLBaseSceneObject);
    procedure PostRender(const PostGenerateMipmap: Boolean);

    property Handle: TDGLFramebufferHandle read FFrameBufferHandle;
    property Width: Integer read FWidth write SetWidth;
    property Height: Integer read FHeight write SetHeight;
    property layer: Integer read FLayer write SetLayer;
    property level: Integer read FLevel write SetLevel;
  end;

// -------------------------------------------------------------------------
// -------------------------------------------------------------------------
// -------------------------------------------------------------------------
implementation
// -------------------------------------------------------------------------
// -------------------------------------------------------------------------
// -------------------------------------------------------------------------


// ----------------
{ TDGLRenderbuffer }
{$IFDEF GLS_REGION}{$REGION 'TDGLRenderbuffer'}{$ENDIF}
constructor TDGLRenderbuffer.Create;
begin
  inherited Create;
  FRenderbufferHandle := TDGLRenderbufferHandle.Create;
  FWidth              := 256;
  FHeight             := 256;
end;

destructor TDGLRenderbuffer.Destroy;
begin
  FRenderbufferHandle.DestroyHandle;
  FRenderbufferHandle.Free;
  inherited Destroy;
end;

function TDGLRenderbuffer.GetHandle: GLuint;
begin
  if FRenderbufferHandle.Handle = 0 then
    FRenderbufferHandle.AllocateHandle;
  Result := FRenderbufferHandle.Handle;
end;

procedure TDGLRenderbuffer.InvalidateStorage;
begin
  FStorageValid := False;
end;

procedure TDGLRenderbuffer.SetHeight(const Value: Integer);
begin
  if FHeight <> Value then
  begin
    FHeight := Value;
    InvalidateStorage;
  end;
end;

procedure TDGLRenderbuffer.SetWidth(const Value: Integer);
begin
  if FWidth <> Value then
  begin
    FWidth := Value;
    InvalidateStorage;
  end;
end;

procedure TDGLRenderbuffer.Bind;
var
  internalFormat: cardinal;
begin
  FRenderbufferHandle.AllocateHandle;
  FRenderbufferHandle.Bind;
  if not FStorageValid then
  begin
    internalFormat := GetInternalFormat;
    FRenderbufferHandle.SetStorage(internalFormat, FWidth, FHeight);
  end;
end;

procedure TDGLRenderbuffer.Unbind;
begin
  FRenderbufferHandle.Unbind;
end;

{$IFDEF GLS_REGION}{$ENDREGION}{$ENDIF}

// ----------------
{ TDGLDepthRBO }
{$IFDEF GLS_REGION}{$REGION 'TDGLDepthRBO'}{$ENDIF}

constructor TDGLDepthRBO.Create;
begin
  inherited Create;
  FDepthPrecision := dpDefault;
end;

function TDGLDepthRBO.GetInternalFormat: cardinal;
begin
  case DepthPrecision of
    dp24bits:
      Result := GL_DEPTH_COMPONENT24;
    dp16bits:
      Result := GL_DEPTH_COMPONENT16;
    dp32bits:
      Result := GL_DEPTH_COMPONENT32;
  else
    // dpDefault
    Result := GL_DEPTH_COMPONENT24_ARB;
  end;
end;

procedure TDGLDepthRBO.SetDepthPrecision(const Value: TDGLDepthPrecision);
begin
  if FDepthPrecision <> Value then
  begin
    FDepthPrecision := Value;
    InvalidateStorage;
  end;
end;

{$IFDEF GLS_REGION}{$ENDREGION}{$ENDIF}

// ----------------
{ TDGLStencilRBO }
{$IFDEF GLS_REGION}{$REGION 'TDGLStencilRBO'}{$ENDIF}

constructor TDGLStencilRBO.Create;
begin
  inherited Create;
  FStencilPrecision := spDefault;
end;

function TDGLStencilRBO.GetInternalFormat: cardinal;
begin
  case StencilPrecision of
    spDefault:
      Result := GL_STENCIL_INDEX;
    sp1bit:
      Result := GL_STENCIL_INDEX1_EXT;
    sp4bits:
      Result := GL_STENCIL_INDEX4_EXT;
    sp8bits:
      Result := GL_STENCIL_INDEX8_EXT;
    sp16bits:
      Result := GL_STENCIL_INDEX16_EXT;
  else
    // spDefault
    Result := GL_STENCIL_INDEX;
  end;
end;

procedure TDGLStencilRBO.SetStencilPrecision(const Value: TDGLStencilPrecision);
begin
  if FStencilPrecision <> Value then
  begin
    FStencilPrecision := Value;
    InvalidateStorage;
  end;
end;

{$IFDEF GLS_REGION}{$ENDREGION}{$ENDIF}

// ----------------
{ TDGLFrameBuffer }
{$IFDEF GLS_REGION}{$REGION 'TDGLFrameBuffer'}{$ENDIF}

constructor TDGLFrameBuffer.Create;
begin
  inherited;
  FFrameBufferHandle := TDGLFramebufferHandle.Create;
  FWidth             := 256;
  FHeight            := 256;
  FLayer             := 0;
  FLevel             := 0;
  FTextureMipmap     := 0;
  FTarget            := GL_FRAMEBUFFER;
end;

destructor TDGLFrameBuffer.Destroy;
begin
  FFrameBufferHandle.DestroyHandle;
  FFrameBufferHandle.Free;
  inherited Destroy;
end;

procedure TDGLFrameBuffer.AttachTexture(n: cardinal; texture: TDGLFrameBufferAttachment);
var
  textarget: TDGLTextureTarget;
begin
  Assert(n < MaxColorAttachments);
  texture.Handle;
  FAttachedTexture[n] := texture;
  textarget           := texture.Image.NativeTextureTarget;
  // Store mipmaping requires
  if not((texture.MinFilter in [miNearest, miLinear]) or (textarget = ttTextureRect)) then
    FTextureMipmap := FTextureMipmap or (1 shl n);

  if texture.Image is TGLMultiSampleImage then
    FTextureMipmap := 0;

  AttachTexture(GL_COLOR_ATTACHMENT0_EXT + n, DecodeGLTextureTarget(textarget), texture.Handle, FLevel, FLayer);
end;

procedure TDGLFrameBuffer.AttachDepthBuffer(DepthBuffer: TDGLDepthRBO);

  procedure AttachDepthRB;
  begin
    // forces initialization
    DepthBuffer.Bind;
    DepthBuffer.Unbind;
    glFramebufferRenderbuffer(FTarget, GL_DEPTH_ATTACHMENT_EXT, GL_RENDERBUFFER_EXT, DepthBuffer.Handle);
  end;

var
  dp: TDGLDepthPrecision;
begin
  if Assigned(FDRBO) then
    DetachDepthBuffer;
  FDRBO := DepthBuffer;

  Bind;
  AttachDepthRB;

  // if default format didn't work, try something else
  // crude, but might work
  if (Status = fsUnsupported) and (DepthBuffer.DepthPrecision = dpDefault) then
  begin
    // try the other formats
    // best quality first
    for dp := high(dp) downto low(dp) do
    begin
      if dp = dpDefault then
        Continue;

      DepthBuffer.DepthPrecision := dp;

      AttachDepthRB;

      if not(Status = fsUnsupported) then
        Break;
    end;
  end;
  Status;
  Unbind;
end;

procedure TDGLFrameBuffer.AttachDepthTexture(texture: TDGLFrameBufferAttachment);
begin
  FDepthTexture := texture;

  if FDepthTexture.Image is TGLMultiSampleImage then
  begin
    if not IsDepthFormat(FDepthTexture.TextureFormatEx) then
    begin
      // Force texture properties to depth compatibility
      FDepthTexture.TextureFormatEx                   := tfDEPTH_COMPONENT24;
      TGLMultiSampleImage(FDepthTexture.Image).Width  := Width;
      TGLMultiSampleImage(FDepthTexture.Image).Height := Height;
    end;
    FTextureMipmap := 0;
  end
  else
  begin
    if not IsDepthFormat(FDepthTexture.TextureFormatEx) then
    begin
      // Force texture properties to depth compatibility
      FDepthTexture.ImageClassName              := TGLBlankImage.ClassName;
      FDepthTexture.TextureFormatEx             := tfDEPTH_COMPONENT24;
      TGLBlankImage(FDepthTexture.Image).Width  := Width;
      TGLBlankImage(FDepthTexture.Image).Height := Height;
    end;
    if FDepthTexture.TextureFormatEx = tfDEPTH24_STENCIL8 then
    begin
      TGLBlankImage(FDepthTexture.Image).GetBitmap32.SetColorFormatDataType(GL_DEPTH_STENCIL, GL_UNSIGNED_INT_24_8);
      TGLBlankImage(FDepthTexture.Image).ColorFormat := GL_DEPTH_STENCIL;
    end
    else
    begin
      TGLBlankImage(FDepthTexture.Image).GetBitmap32.SetColorFormatDataType(GL_DEPTH_COMPONENT, GL_UNSIGNED_BYTE);
      TGLBlankImage(FDepthTexture.Image).ColorFormat := GL_DEPTH_COMPONENT;
    end;
    // Depth texture mipmaping
    if not((FDepthTexture.MinFilter in [miNearest, miLinear])) then
      FTextureMipmap := FTextureMipmap or cardinal(1 shl MaxColorAttachments);
  end;

  AttachTexture(GL_DEPTH_ATTACHMENT, DecodeGLTextureTarget(FDepthTexture.Image.NativeTextureTarget), FDepthTexture.Handle, FLevel, FLayer);

  if FDepthTexture.TextureFormatEx = tfDEPTH24_STENCIL8 then
    AttachTexture(GL_STENCIL_ATTACHMENT, DecodeGLTextureTarget(FDepthTexture.Image.NativeTextureTarget), FDepthTexture.Handle, FLevel, FLayer);
end;

procedure TDGLFrameBuffer.DetachDepthTexture;
begin
  if Assigned(FDepthTexture) then
  begin
    FTextureMipmap := FTextureMipmap and (not(1 shl MaxColorAttachments));
    AttachTexture(GL_DEPTH_ATTACHMENT, DecodeGLTextureTarget(FDepthTexture.Image.NativeTextureTarget), 0, 0, 0);
    FDepthTexture := nil;
  end;
end;

procedure TDGLFrameBuffer.AttachStencilBuffer(StencilBuffer: TGLStencilRBO);

  procedure AttachStencilRB;
  begin
    // forces initialization
    StencilBuffer.Bind;
    StencilBuffer.Unbind;
    GL.FramebufferRenderbuffer(FTarget, GL_STENCIL_ATTACHMENT, GL_RENDERBUFFER_EXT, StencilBuffer.Handle);
  end;

var
  sp: TGLStencilPrecision;
begin
  if Assigned(FSRBO) then
    DetachStencilBuffer;
  FSRBO := StencilBuffer;

  Bind;
  AttachStencilRB;

  // if default format didn't work, try something else
  // crude, but might work
  if (Status = fsUnsupported) and (StencilBuffer.StencilPrecision = spDefault) then
  begin
    // try the other formats
    // best quality first
    for sp := high(sp) downto low(sp) do
    begin
      if sp = spDefault then
        Continue;

      StencilBuffer.StencilPrecision := sp;

      AttachStencilRB;

      if not(Status = fsUnsupported) then
        Break;
    end;
  end;
  Status;
  Unbind;
end;

procedure TDGLFrameBuffer.AttachTexture(const attachment: TGLEnum; const textarget: TGLEnum; const texture: TGLuint; const level: TGLint; const layer: TGLint);
var
  storeDFB: TGLuint;
  RC:       TDGLContext;
begin
  RC       := CurrentDGLContext;
  storeDFB := RC.GLStates.DrawFrameBuffer;
  if storeDFB <> FFrameBufferHandle.Handle then
    Bind;

  with FFrameBufferHandle do
    case textarget of
      GL_TEXTURE_1D:
        Attach1DTexture(FTarget, attachment, textarget, texture, level);

      GL_TEXTURE_2D:
        Attach2DTexture(FTarget, attachment, textarget, texture, level);

      GL_TEXTURE_RECTANGLE: // Rectangle texture can't be leveled
        Attach2DTexture(FTarget, attachment, textarget, texture, 0);

      GL_TEXTURE_3D:
        Attach3DTexture(FTarget, attachment, textarget, texture, level, layer);

      GL_TEXTURE_CUBE_MAP:
        Attach2DTexture(FTarget, attachment, GL_TEXTURE_CUBE_MAP_POSITIVE_X + layer, texture, level);

      GL_TEXTURE_CUBE_MAP_POSITIVE_X, GL_TEXTURE_CUBE_MAP_NEGATIVE_X, GL_TEXTURE_CUBE_MAP_POSITIVE_Y, GL_TEXTURE_CUBE_MAP_NEGATIVE_Y, GL_TEXTURE_CUBE_MAP_POSITIVE_Z, GL_TEXTURE_CUBE_MAP_NEGATIVE_Z:
        Attach2DTexture(FTarget, attachment, textarget, texture, level);

      GL_TEXTURE_CUBE_MAP_ARRAY, GL_TEXTURE_1D_ARRAY, GL_TEXTURE_2D_ARRAY:
        AttachLayer(FTarget, attachment, texture, level, layer);

      GL_TEXTURE_2D_MULTISAMPLE: // Multisample texture can't be leveled
        Attach2DTexture(FTarget, attachment, textarget, texture, 0);

      GL_TEXTURE_2D_MULTISAMPLE_ARRAY:
        AttachLayer(FTarget, attachment, texture, 0, layer);
    end;

  if storeDFB <> FFrameBufferHandle.Handle then
    RC.GLStates.SetFrameBuffer(storeDFB);
end;

procedure TDGLFrameBuffer.Bind;
begin
  if Handle.IsDataNeedUpdate then
    ReattachTextures
  else
    Handle.Bind;
end;

procedure TDGLFrameBuffer.Unbind;
begin
  FFrameBufferHandle.Unbind;
end;

procedure TDGLFrameBuffer.DetachTexture(n: cardinal);
begin
  // textarget ignored when binding 0
  if Assigned(FAttachedTexture[n]) then
  begin
    Bind;
    AttachTexture(GL_COLOR_ATTACHMENT0 + n, GL_TEXTURE_2D, // target does not matter
      0, 0, 0);

    FTextureMipmap      := FTextureMipmap and (not(1 shl n));
    FAttachedTexture[n] := nil;
    Unbind;
  end;
end;

procedure TDGLFrameBuffer.DetachDepthBuffer;
begin
  Bind;
  glFramebufferRenderbuffer(FTarget, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, 0);
  Unbind;
  FDRBO := nil;
end;

procedure TDGLFrameBuffer.DetachStencilBuffer;
begin
  Bind;
  glFramebufferRenderbuffer(FTarget, GL_STENCIL_ATTACHMENT, GL_RENDERBUFFER, 0);
  Unbind;
  FSRBO := nil;
end;

function TDGLFrameBuffer.GetStatus: TDGLFramebufferStatus;
var
  Status: cardinal;
begin
  Status := glCheckFramebufferStatus(FTarget);

  case Status of
    GL_FRAMEBUFFER_COMPLETE_EXT:
      Result := fsComplete;
    GL_FRAMEBUFFER_INCOMPLETE_ATTACHMENT_EXT:
      Result := fsIncompleteAttachment;
    GL_FRAMEBUFFER_INCOMPLETE_MISSING_ATTACHMENT_EXT:
      Result := fsIncompleteMissingAttachment;
    GL_FRAMEBUFFER_INCOMPLETE_DUPLICATE_ATTACHMENT_EXT:
      Result := fsIncompleteDuplicateAttachment;
    GL_FRAMEBUFFER_INCOMPLETE_DIMENSIONS_EXT:
      Result := fsIncompleteDimensions;
    GL_FRAMEBUFFER_INCOMPLETE_FORMATS_EXT:
      Result := fsIncompleteFormats;
    GL_FRAMEBUFFER_INCOMPLETE_DRAW_BUFFER_EXT:
      Result := fsIncompleteDrawBuffer;
    GL_FRAMEBUFFER_INCOMPLETE_READ_BUFFER_EXT:
      Result := fsIncompleteReadBuffer;
    GL_FRAMEBUFFER_UNSUPPORTED_EXT:
      Result := fsUnsupported;
    GL_FRAMEBUFFER_INCOMPLETE_MULTISAMPLE:
      Result := fsIncompleteMultisample;
  else
    Result := fsStatusError;
  end;
end;

function TDGLFrameBuffer.GetStringStatus(out clarification: string): TDGLFramebufferStatus;
const
  cFBOStatus: array [TDGLFramebufferStatus] of string = ('Complete', 'Incomplete attachment', 'Incomplete missing attachment', 'Incomplete duplicate attachment', 'Incomplete dimensions', 'Incomplete formats', 'Incomplete draw buffer',
    'Incomplete read buffer', 'Unsupported', 'Incomplite multisample', 'Status Error');
begin
  Result        := GetStatus;
  clarification := cFBOStatus[Result];
end;

procedure TDGLFrameBuffer.PostRender(const PostGenerateMipmap: Boolean);
var
  n:         Integer;
  textarget: TDGLTextureTarget;
begin
  if (FTextureMipmap > 0) and PostGenerateMipmap then
  begin
    for n := 0 to MaxColorAttachments - 1 do
      if Assigned(FAttachedTexture[n]) then
      begin
        if FTextureMipmap and (1 shl n) = 0 then
          Continue;
        textarget := FAttachedTexture[n].Image.NativeTextureTarget;
        with FFrameBufferHandle.RenderingContext.GLStates do
          TextureBinding[ActiveTexture, textarget] := FAttachedTexture[n].Handle;
        glGenerateMipmap(DecodeGLTextureTarget(textarget));
      end;
  end;
end;

procedure TDGLFrameBuffer.PreRender;
begin

end;

procedure TDGLFrameBuffer.Render(var rci: TRenderContextInfo; baseObject: TGLBaseSceneObject);
var
  backColor: TColorVector;
  buffer:    TDGLSceneBuffer;
begin
  Bind;
  Assert(Status = fsComplete, 'Framebuffer not complete');

  buffer := TDGLSceneBuffer(rci.buffer);

  backColor := ConvertWinColor(buffer.BackgroundColor);
  glClearColor(backColor.V[0], backColor.V[1], backColor.V[2], buffer.BackgroundAlpha);
  rci.GLStates.SetColorMask(cAllColorComponents);
  rci.GLStates.DepthWriteMask := True;
  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);

  baseObject.Render(rci);
  Unbind;
end;

procedure TDGLFrameBuffer.SetHeight(const Value: Integer);
begin
  if FHeight <> Value then
  begin
    FHeight := Value;
  end;
end;

procedure TDGLFrameBuffer.SetWidth(const Value: Integer);
begin
  if FWidth <> Value then
  begin
    FWidth := Value;
  end;
end;

procedure TDGLFrameBuffer.ReattachTextures;
var
  n:      Integer;
  bEmpty: Boolean;
  s:      String;
begin
  Handle.AllocateHandle;
  Handle.Bind;
  // Reattach layered textures
  bEmpty := True;

  for n := 0 to MaxColorAttachments - 1 do
    if Assigned(FAttachedTexture[n]) then
    begin
      AttachTexture(GL_COLOR_ATTACHMENT0_EXT + n, DecodeGLTextureTarget(FAttachedTexture[n].Image.NativeTextureTarget), FAttachedTexture[n].Handle, FLevel, FLayer);
      bEmpty := False;
    end;

  if Assigned(FDepthTexture) then
  begin
    AttachTexture(GL_DEPTH_ATTACHMENT, DecodeGLTextureTarget(FDepthTexture.Image.NativeTextureTarget), FDepthTexture.Handle, FLevel, FLayer);
    bEmpty := False;
  end;

  if Assigned(FDRBO) then
  begin
    FDRBO.Bind;
    FDRBO.Unbind;
    glFramebufferRenderbuffer(FTarget, GL_DEPTH_ATTACHMENT_EXT, GL_RENDERBUFFER_EXT, FDRBO.Handle);
    bEmpty := False;
  end;

  if Assigned(FSRBO) then
  begin
    FSRBO.Bind;
    FSRBO.Unbind;
    glFramebufferRenderbuffer(FTarget, GL_STENCIL_ATTACHMENT, GL_RENDERBUFFER_EXT, FSRBO.Handle);
    bEmpty := False;
  end;

  if not bEmpty and (GetStringStatus(s) <> fsComplete) then
    GLSLogger.LogErrorFmt('Framebuffer error: %s. Deactivated', [s]);

  Handle.NotifyDataUpdated;
end;

procedure TDGLFrameBuffer.SetLayer(const Value: Integer);
var
  RC: TDGLContext;
begin
  if FLayer <> Value then
  begin
    FLayer := Value;
    RC     := CurrentDGLContext;
    if Assigned(RC) then
    begin
      if RC.GLStates.DrawFrameBuffer = FFrameBufferHandle.Handle then
        ReattachTextures;
    end;
  end;
end;

procedure TDGLFrameBuffer.SetLevel(const Value: Integer);
var
  RC: TDGLContext;
begin
  if FLevel <> Value then
  begin
    FLevel := Value;
    RC     := CurrentDGLContext;
    if Assigned(RC) then
    begin
      if RC.GLStates.DrawFrameBuffer = FFrameBufferHandle.Handle then
        ReattachTextures;
    end;
  end;
end;

{$IFDEF GLS_REGION}{$ENDREGION}{$ENDIF}

//----------------------------------------------------------------
//----------------------------------------------------------------
//----------------------------------------------------------------

end.