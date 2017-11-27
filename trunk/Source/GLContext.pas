//
// This unit is part of the GLScene Project, http://glscene.org
//
{
   Prototypes and base implementation of TGLContext.

   History :
     22/07/01 - EG - Creation (glcontext.omm)
     The whole history is logged in previous version of the unit.
}
unit GLContext;

interface

{$I GLScene.inc}

uses
  Winapi.Windows,
  System.Classes,
  System.SysUtils,
  System.Types,
  System.SyncObjs,
  VCL.Forms,
  VCL.Controls,
  VCL.Consts,

{$IFDEF USE_SERVICE_CONTEXT}
  GLSGenerics,
{$ENDIF}
  GLState,
  GLSLog,
  GLCrossPlatform,
  OpenGLTokens,
  OpenGLAdapter,
  GLVectorGeometry,
  GLStrings,
  GLVectorTypes,
  XOpenGL,
  GLPipelineTransformation,
  GLTextureFormat;

// Buffer ID's for Multiple-Render-Targets (using GL_ATI_draw_buffers)
const
  MRT_BUFFERS: array[0..3] of Cardinal = (GL_FRONT_LEFT, GL_AUX0, GL_AUX1, GL_AUX2);

type
  TGLRCOption = (rcoDoubleBuffered, rcoStereo, rcoDebug, rcoOGL_ES);
  TGLRCOptions = set of TGLRCOption;

  TGLContextLayer = (clUnderlay2, clUnderlay1, clMainPlane, clOverlay1, clOverlay2);

  TFinishTaskEvent = class(TEvent)
  public
    constructor Create; reintroduce;
  end;

  TTaskProcedure = procedure of object; stdcall;
  TServiceContextTask = record
    Task: TTaskProcedure;
    Event: TFinishTaskEvent;
  end;

{$IFDEF USE_SERVICE_CONTEXT}
  TServiceContextTaskList = {$IFDEF GLS_GENERIC_PREFIX} specialize {$ENDIF}
    GThreadList < TServiceContextTask > ;
{$ENDIF USE_SERVICE_CONTEXT}

  TGLContextManager = class;

  TGLContextAcceleration = (chaUnknown, chaHardware, chaSoftware);

  TGLAntiAliasing = (// Multisample Antialiasing
    aaDefault, aaNone, aa2x, aa2xHQ, aa4x, aa4xHQ,
    aa6x, aa8x, aa16x,
    // Coverage Sampling Antialiasing
    csa8x, csa8xHQ, csa16x, csa16xHQ);

  TGLVSyncMode = (vsmSync, vsmNoSync);

  { Wrapper around an OpenGL rendering context.
    The aim of this class is to offer platform-independant
    initialization, activation and management of OpenGL
    rendering context. The class also offers notifications
    event and error/problems detection.
    This is a virtual abstract a class, and platform-specific
    subclasses must be used. All rendering context share the same lists. }
  TGLContext = class
  private
    FColorBits, FAlphaBits: Integer;
    FDepthBits: Integer;
    FStencilBits: Integer;
    FAccumBits: Integer;
    FAuxBuffers: Integer;
    FAntiAliasing: TGLAntiAliasing;
    FOptions: TGLRCOptions;
    FOnDestroyContext: TNotifyEvent;
    FManager: TGLContextManager;
    FActivationCount: Integer;
    FOwnedHandlesCount: Integer;
    FIsPraparationNeed: Boolean;
    procedure SetColorBits(const aColorBits: Integer); inline;
    procedure SetAlphaBits(const aAlphaBits: Integer); inline;
    procedure SetDepthBits(const val: Integer); inline;
    procedure SetStencilBits(const aStencilBits: Integer); inline;
    procedure SetAccumBits(const aAccumBits: Integer); inline;
    procedure SetAuxBuffers(const aAuxBuffers: Integer); inline;
    procedure SetOptions(const aOptions: TGLRCOptions); inline;
    procedure SetAntiAliasing(const val: TGLAntiAliasing); inline;
    procedure SetAcceleration(const val: TGLContextAcceleration); inline;
    function GetActive: Boolean; inline;
    procedure SetActive(const aActive: Boolean); inline;
    procedure SetLayer(const Value: TGLContextLayer); inline;
  protected
    FGL: TGLExtensionsAndEntryPoints;
    FXGL: TGLMultitextureCoordinator;
    FGLStates: TGLStateCache;
    FTransformation: TGLTransformation;
    FAcceleration: TGLContextAcceleration;
    FLayer: TGLContextLayer;
{$IFNDEF USE_MULTITHREAD}
    FSharedContexts: TList;
{$ELSE}
    FSharedContexts: TThreadList;
    FLock: TCriticalSection;
{$ENDIF}
    procedure PropagateSharedContext;
    procedure DoCreateContext(ADeviceHandle: HDC); virtual; abstract;
    procedure DoCreateMemoryContext(outputDevice: HWND; width, height:
      Integer; BufferCount: integer = 1); virtual; abstract;
    function DoShareLists(aContext: TGLContext): Boolean; virtual; abstract;
    procedure DoDestroyContext; virtual; abstract;
    procedure DoActivate; virtual; abstract;
    procedure DoDeactivate; virtual; abstract;
    class function ServiceContext: TGLContext;
    procedure MakeGLCurrent;
  public
    constructor Create; virtual;
    destructor Destroy; override;
    {An application-side cache of global per-context OpenGL states
       and parameters }
    property GLStates: TGLStateCache read FGLStates;
    property PipelineTransformation: TGLTransformation read FTransformation;
    // Context manager reference
    property Manager: TGLContextManager read FManager;
    {Color bits for the rendering context }
    property ColorBits: Integer read FColorBits write SetColorBits;
    {Alpha bits for the rendering context }
    property AlphaBits: Integer read FAlphaBits write SetAlphaBits;
    {Depth bits for the rendering context }
    property DepthBits: Integer read FDepthBits write SetDepthBits;
    {Stencil bits for the rendering context }
    property StencilBits: Integer read FStencilBits write SetStencilBits;
    {Accumulation buffer bits for the rendering context }
    property AccumBits: Integer read FAccumBits write SetAccumBits;
    {Auxiliary buffers bits for the rendering context }
    property AuxBuffers: Integer read FAuxBuffers write SetAuxBuffers;
    { AntiAliasing option.
      Ignored if not hardware supported, currently based on ARB_multisample. }
    property AntiAliasing: TGLAntiAliasing read FAntiAliasing write
      SetAntiAliasing;
    {Specifies the layer plane that the rendering context is bound to. }
    property Layer: TGLContextLayer read FLayer write SetLayer;
    {Rendering context options. }
    property Options: TGLRCOptions read FOptions write SetOptions;
    {Allows reading and defining the activity for the context.
       The methods of this property are just wrappers around calls
       to Activate and Deactivate. }
    property Active: Boolean read GetActive write SetActive;
    {Indicates if the context is hardware-accelerated. }
    property Acceleration: TGLContextAcceleration read FAcceleration write SetAcceleration;
    {Triggered whenever the context is destroyed. 
       This events happens *before* the context has been
       actually destroyed, OpenGL resource cleanup can
       still occur here. }
    property OnDestroyContext: TNotifyEvent read FOnDestroyContext write
      FOnDestroyContext;
    {Creates the context.
       This method must be invoked before the context can be used. }
    procedure CreateContext(ADeviceHandle: HDC); overload;
    {Creates an in-memory context.
       The function should fail if no hardware-accelerated memory context
       can be created (the CreateContext method can handle software OpenGL
       contexts). }
    procedure CreateMemoryContext(outputDevice: HWND; width, height:
      Integer; BufferCount: integer = 1);
    {Setup display list sharing between two rendering contexts. 
       Both contexts must have the same pixel format. }
    procedure ShareLists(aContext: TGLContext);
    {Destroy the context. 
       Will fail if no context has been created.
       The method will first invoke the OnDestroyContext
       event, then attempts to deactivate the context
       (if it is active) before destroying it. }
    procedure DestroyContext;
    {Activates the context. 
       A context can be activated multiple times (and must be
       deactivated the same number of times), but this function
       will fail if another context is already active. }
    procedure Activate;
    { Deactivates the context.
      Will fail if the context is not active or another
      context has been activated. }
    procedure Deactivate;
    {Call OnPrepare for all handles.  }
    procedure PrepareHandlesData;
    {Returns true if the context is valid.
       A context is valid from the time it has been successfully
       created to the time of its destruction. }
    function IsValid: Boolean; virtual; abstract;
    {Request to swap front and back buffers if they were defined. }
    procedure SwapBuffers; virtual; abstract;
    {Returns the first compatible context that isn't self in the shares. }
    function FindCompatibleContext: TGLContext;
    procedure DestroyAllHandles;
    function RenderOutputDevice: Pointer; virtual; abstract;
    {Access to OpenGL command and extension. }
    property GL: TGLExtensionsAndEntryPoints read FGL;
    property MultitextureCoordinator: TGLMultitextureCoordinator read FXGL;
    property IsPraparationNeed: Boolean read FIsPraparationNeed;
  end;

  TGLContextClass = class of TGLContext;

  {A TGLContext with screen control property and methods.
     This variety of contexts is for drivers that access windows and OpenGL
     through an intermediate opaque cross-platform API. 
     TGLSceneViewer won't use them, TGLMemoryViewer may be able to use them,
     but most of the time they will be accessed through a specific viewer
     class/subclass. }
  TGLScreenControlingContext = class(TGLContext)
  strict private
    FWidth, FHeight: Integer;
    FFullScreen: Boolean;
  protected
  public
    property Width: Integer read FWidth write FWidth;
    property Height: Integer read FHeight write FHeight;
    property FullScreen: Boolean read FFullScreen write FFullScreen;
  end;

  PGLRCHandle = ^TGLRCHandle;
  TGLRCHandle = record
    FRenderingContext: TGLContext;
    FHandle: Cardinal;
    FChanged: Boolean;
  end;

  TOnPrepareHandleData = procedure(AContext: TGLContext) of object;

  {Wrapper around an OpenGL context handle.
     This wrapper also takes care of context registrations and data releases
     related to context releases an cleanups. This is an abstract class,
     use the TGLListHandle and TGLTextureHandle subclasses. }
  TGLContextHandle = class
  private
    FHandles: TList;
    FLastHandle : PGLRCHandle;
    FOnPrepare: TOnPrepareHandleData;
    function GetHandle: Cardinal; inline;
    function GetContext: TGLContext;
    function SearchRC(AContext: TGLContext): PGLRCHandle;
    function RCItem(AIndex: integer): PGLRCHandle; inline;
    procedure CheckCurrentRC;
  protected
    // Invoked by when there is no compatible context left for relocation
    procedure ContextDestroying;
    // Specifies if the handle can be transfered across shared contexts
    class function Transferable: Boolean; virtual;
    class function IsValid(const ID: Cardinal): Boolean; virtual;
    function DoAllocateHandle: Cardinal; virtual; abstract;
    procedure DoDestroyHandle(var AHandle: Cardinal); virtual; abstract;
  public
    constructor Create; virtual;
    constructor CreateAndAllocate(failIfAllocationFailed: Boolean = True);
    destructor Destroy; override;
    {Return OpenGL identifier in current context. }
    property Handle: Cardinal read GetHandle;
    {Return current rendering context if handle is allocated in it
       or first context where handle is allocated. }
    property RenderingContext: TGLContext read GetContext;
    {Return True is data need update in current context. }
    function IsDataNeedUpdate: Boolean; inline;
    {Return True if data updated in all contexts. }
    function IsDataComplitelyUpdated: Boolean;
    {Notify the data was updated in current context. }
    procedure NotifyDataUpdated;
    { Notify the data was changed through all context. }
    procedure NotifyChangesOfData; inline;
    // Checks if required extensions / OpenGL version are met
    class function IsSupported: Boolean; virtual;
    function IsAllocatedForContext(AContext: TGLContext = nil): Boolean;
    function IsShared: Boolean;
    function  AllocateHandle: Cardinal;
    procedure DestroyHandle;
    property OnPrapare: TOnPrepareHandleData read FOnPrepare write FOnPrepare;
  end;

  TGLVirtualHandle = class;
  TGLVirtualHandleEvent = procedure(Sender: TGLVirtualHandle; var handle:
    Cardinal) of object;

  {A context handle with event-based handle allocation and destruction. }
  TGLVirtualHandle = class(TGLContextHandle)
  private
    FOnAllocate, FOnDestroy: TGLVirtualHandleEvent;
    FTag: Integer;
  protected
    function DoAllocateHandle: Cardinal; override;
    procedure DoDestroyHandle(var AHandle: Cardinal); override;
    class function Transferable: Boolean; override;
  public
    property OnAllocate: TGLVirtualHandleEvent read FOnAllocate write
      FOnAllocate;
    property OnDestroy: TGLVirtualHandleEvent read FOnDestroy write FOnDestroy;
    property Tag: Integer read FTag write FTag;
  end;

  {Transferable virtual handle. }
  TGLVirtualHandleTransf = class(TGLVirtualHandle)
  protected
    class function Transferable: Boolean; override;
  end;

  {Manages a handle to a display list. }
  TGLListHandle = class(TGLContextHandle)
  protected
    function DoAllocateHandle: Cardinal; override;
    procedure DoDestroyHandle(var AHandle: Cardinal); override;
    class function IsValid(const ID: Cardinal): Boolean; override;
  public
    procedure NewList(mode: Cardinal); inline;
    procedure EndList; inline;
    procedure CallList; inline;
  end;

  {Manages a handle to a texture. }
  TGLTextureHandle = class(TGLContextHandle)
  private
    FTarget: TGLTextureTarget;
    procedure SetTarget(ATarget: TGLTextureTarget);
  protected
    function DoAllocateHandle: Cardinal; override;
    procedure DoDestroyHandle(var AHandle: Cardinal); override;
    class function IsValid(const ID: Cardinal): Boolean; override;
  public
    property Target: TGLTextureTarget read FTarget write SetTarget;
  end;

  { Manages a handle to a sampler. }
  TGLSamplerHandle = class(TGLContextHandle)
  protected
    function DoAllocateHandle: Cardinal; override;
    procedure DoDestroyHandle(var AHandle: Cardinal); override;
    class function IsValid(const ID: Cardinal): Boolean; override;
  public

    class function IsSupported: Boolean; override;
  end;

  {Manages a handle to a query.
     Do not use this class directly, use one of its subclasses instead. }
  TGLQueryHandle = class(TGLContextHandle)
  private
    FActive: Boolean;
  protected
    class function Transferable: Boolean; override;
    function DoAllocateHandle: Cardinal; override;
    procedure DoDestroyHandle(var AHandle: Cardinal); override;
    function GetTarget: Cardinal; virtual; abstract;
    function GetQueryType: TQueryType; virtual; abstract;
    class function IsValid(const ID: Cardinal): Boolean; override;
  public
    procedure BeginQuery;
    procedure EndQuery;
    // Check if result is available from the query.  Result may not be available
    // immediately after ending the query
    function IsResultAvailable: boolean;
    // Number of bits used to store the query result. eg. 32/64 bit
    function CounterBits: integer;
    // Retrieve query result, may cause a stall if the result is not available yet
    function QueryResultInt: TGLInt;
    function QueryResultUInt: Cardinal;
    function QueryResultInt64: TGLint64EXT;
    function QueryResultUInt64: TGLuint64EXT;
    function QueryResultBool: TGLboolean;
    property Target: Cardinal read GetTarget;
    property QueryType: TQueryType read GetQueryType;
    {True if within a Begin/EndQuery. }
    property Active: Boolean read FActive;
  end;

  {Manages a handle to an occlusion query.
     Requires OpenGL 1.5+
     Does *NOT* check for extension availability, this is assumed to have been
     checked by the user. }
  TGLOcclusionQueryHandle = class(TGLQueryHandle)
  protected
    function GetTarget: Cardinal; override;
    function GetQueryType: TQueryType; override;
  public
    class function IsSupported: Boolean; override;
    // Number of samples (pixels) drawn during the query, some pixels may
    // be drawn to several times in the same query
    function PixelCount: Integer;
  end;

  TGLBooleanOcclusionQueryHandle = class(TGLQueryHandle)
  protected
    function GetTarget: Cardinal; override;
    function GetQueryType: TQueryType; override;
  public
    class function IsSupported: Boolean; override;
  end;

  { Manages a handle to a timer query.
    Requires GL_EXT_timer_query extension.
    Does *NOT* check for extension availability, this is assumed to have been
    checked by the user. }
  TGLTimerQueryHandle = class(TGLQueryHandle)
  protected
    function GetTarget: Cardinal; override;
    function GetQueryType: TQueryType; override;
  public
    class function IsSupported: Boolean; override;
    // Time, in nanoseconds (1 ns = 10^-9 s) between starting + ending the query.
    // with 32 bit integer can measure up to approximately 4 seconds, use
    // QueryResultUInt64 if you may need longer
    function Time: Integer;
  end;

  {Manages a handle to a primitive query.
     Requires OpenGL 3.0+
     Does *NOT* check for extension availability, this is assumed to have been
     checked by the user. }
  TGLPrimitiveQueryHandle = class(TGLQueryHandle)
  protected
    function GetTarget: Cardinal; override;
    function GetQueryType: TQueryType; override;
  public
    class function IsSupported: Boolean; override;
    // Number of primitives (eg. Points, Triangles etc.) drawn whilst the
    // query was active
    function PrimitivesGenerated: Integer;
  end;

  { Manages a handle to a Buffer Object.
    Does *NOT* check for extension availability, this is assumed to have been
    checked by the user. }
  TGLBufferObjectHandle = class(TGLContextHandle)
  private
    FSize: Integer;
  protected
    function DoAllocateHandle: Cardinal; override;
    procedure DoDestroyHandle(var AHandle: Cardinal); override;
    function GetTarget: Cardinal; virtual; abstract;
    class function IsValid(const ID: Cardinal): Boolean; override;
  public
    {Creates the buffer object buffer and initializes it. }
    constructor CreateFromData(p: Pointer; size: Integer; bufferUsage: Cardinal);
    procedure Bind; virtual; abstract;
    {Note that it is not necessary to UnBind before Binding another buffer. }
    procedure UnBind; virtual; abstract;
    {Bind a buffer object to an indexed target, used by transform feedback
       buffer objects and uniform buffer objects. (OpenGL 3.0+) }
    procedure BindRange(index: Cardinal; offset: TGLintptr; size: TGLsizeiptr);
      virtual;
    {Equivalent to calling BindRange with offset = 0, and size = the size of buffer.}
    procedure BindBase(index: Cardinal); virtual;
    procedure UnBindBase(index: Cardinal); virtual;
    { Specifies buffer content.
      Common bufferUsage values are GL_STATIC_DRAW_ARB for data that will
      change rarely, but be used often, GL_STREAM_DRAW_ARB for data specified
      once but used only a few times, and GL_DYNAMIC_DRAW_ARB for data
      that is re-specified very often.
      Valid only if the buffer has been bound. }
    procedure BufferData(p: Pointer; size: Integer; bufferUsage: Cardinal);
    // Invokes Bind then BufferData
    procedure BindBufferData(p: Pointer; size: Integer; bufferUsage: Cardinal);
    {Updates part of an already existing buffer.
       offset and size indicate which part of the data in the buffer is
       to bo modified and p where the data should be taken from. }
    procedure BufferSubData(offset, size: Integer; p: Pointer);
    {Map buffer content to memory. 
       Values for access are GL_READ_ONLY_ARB, GL_WRITE_ONLY_ARB and
       GL_READ_WRITE_ARB.
       Valid only if the buffer has been bound, must be followed by
       an UnmapBuffer, only one buffer may be mapped at a time. }
    function MapBuffer(access: Cardinal): Pointer;
    function MapBufferRange(offset: TGLint; len: TGLsizei; access: TGLbitfield):
      Pointer;
    procedure Flush(offset: TGLint; len: TGLsizei);
    {Unmap buffer content from memory. 
       Must follow a MapBuffer, and happen before the buffer is unbound. }
    function UnmapBuffer: Boolean;
    class function IsSupported: Boolean; override;
    property Target: Cardinal read GetTarget;
    property BufferSize: Integer read FSize;
  end;

  { Manages a handle to an Vertex Buffer Object.
    Does *NOT* check for extension availability, this is assumed to have been
    checked by the user.
    Do not use this class directly, use one of its subclasses instead. }
  TGLVBOHandle = class(TGLBufferObjectHandle)
  private
    function GetVBOTarget: Cardinal;
  public
    property VBOTarget: Cardinal read GetVBOTarget;
  end;

  { Manages a handle to VBO Array Buffer. Typically used to store vertices, normals, texcoords, etc.}
  TGLVBOArrayBufferHandle = class(TGLVBOHandle)
  protected
    function GetTarget: Cardinal; override;
  public
    procedure Bind; override;
    procedure UnBind; override;
  end;

  {Manages a handle to VBO Element Array Buffer. Typically used to store vertex indices. }
  TGLVBOElementArrayHandle = class(TGLVBOHandle)
  protected
    function GetTarget: Cardinal; override;
  public
    procedure Bind; override;
    procedure UnBind; override;
  end;

  { Manages a handle to PBO Pixel Pack Buffer.
    When bound, commands such as ReadPixels write their data into a buffer object. }
  TGLPackPBOHandle = class(TGLBufferObjectHandle)
  protected
    function GetTarget: Cardinal; override;
  public
    procedure Bind; override;
    procedure UnBind; override;
    class function IsSupported: Boolean; override;
  end;

  {Manages a handle to PBO Pixel Unpack Buffer.
     When bound, commands such as DrawPixels read
     their data from a buffer object. }
  TGLUnpackPBOHandle = class(TGLBufferObjectHandle)
  protected
    function GetTarget: Cardinal; override;
  public
    procedure Bind; override;
    procedure UnBind; override;
    class function IsSupported: Boolean; override;
  end;

  {Manages a handle to a Transform Feedback Buffer Object.
     Transform feedback buffers can be used to capture vertex data from the
     vertex or geometry shader stage to perform further processing without
     going on to the fragment shader stage. }
  TGLTransformFeedbackBufferHandle = class(TGLBufferObjectHandle)
    //    FTransformFeedbackBufferBuffer: array[0..15] of Cardinal; // (0, 0, 0, ...)
    //    FTransformFeedbackBufferStart: array[0..15] of TGLuint64; // (0, 0, 0, ...)
    //    FTransformFeedbackBufferSize: array[0..15] of TGLuint64; // (0, 0, 0, ...)
  protected
    function GetTarget: Cardinal; override;
  public
    procedure Bind; override;
    procedure UnBind; override;
    procedure BeginTransformFeedback(primitiveMode: Cardinal);
    procedure EndTransformFeedback();
    procedure BindRange(index: Cardinal; offset: TGLintptr; size: TGLsizeiptr); override;
    procedure BindBase(index: Cardinal); override;
    procedure UnBindBase(index: Cardinal); override;

    class function IsSupported: Boolean; override;
  end;

  {Manages a handle to a Buffer Texture. (TBO) }
  TGLTextureBufferHandle = class(TGLBufferObjectHandle)
  protected
    function GetTarget: Cardinal; override;
  public
    procedure Bind; override;
    procedure UnBind; override;
    class function IsSupported: Boolean; override;
  end;

  {Manages a handle to a Uniform Buffer Object (UBO).
     Uniform buffer objects store "uniform blocks"; groups of uniforms
     that can be passed as a group into a GLSL program. }
  TGLUniformBufferHandle = class(TGLBufferObjectHandle)
    //    FUniformBufferBuffer: array[0..15] of Cardinal; // (0, 0, 0, ...)
    //    FUniformBufferStart: array[0..15] of TGLuint64; // (0, 0, 0, ...)
    //    FUniformBufferSize: array[0..15] of TGLuint64; // (0, 0, 0, ...)
  protected
    function GetTarget: Cardinal; override;
  public
    procedure Bind; override;
    procedure UnBind; override;
    procedure BindRange(index: Cardinal; offset: TGLintptr; size: TGLsizeiptr); override;
    procedure BindBase(index: Cardinal); override;
    procedure UnBindBase(index: Cardinal); override;
    class function IsSupported: Boolean; override;
  end;

  {Manages a handle to a Vertex Array Object (VAO).
     Vertex array objects are used to rapidly switch between large sets
     of array state. }
  TGLVertexArrayHandle = class(TGLContextHandle)
  protected
    class function Transferable: Boolean; override;
    function DoAllocateHandle: Cardinal; override;
    procedure DoDestroyHandle(var AHandle: Cardinal); override;
    class function IsValid(const ID: Cardinal): Boolean; override;
  public
    procedure Bind;
    procedure UnBind;
    class function IsSupported: Boolean; override;
  end;

  TGLFramebufferStatus = (fsComplete, fsIncompleteAttachment,
    fsIncompleteMissingAttachment,
    fsIncompleteDuplicateAttachment, fsIncompleteDimensions,
    fsIncompleteFormats,
    fsIncompleteDrawBuffer, fsIncompleteReadBuffer, fsUnsupported,
    fsIncompleteMultisample,
    fsStatusError);

  {Manages a handle to a Framebuffer Object (FBO).
     Framebuffer objects provide a way of drawing to rendering
     destinations other than the buffers provided to the GL by the
     window-system.  One or more "framebuffer-attachable images" can be attached
     to a Framebuffer for uses such as: offscreen rendering, "render to texture" +
     "multiple render targets" (MRT).
     There are several types of framebuffer-attachable images:
     - The image of a renderbuffer object, which is always 2D.
     - A single level of a 1D texture, which is treated as a 2D image with a height of one.
     - A single level of a 2D or rectangle texture.
     - A single face of a cube map texture level, which is treated as a 2D image.
     - A single layer of a 1D or 2D array texture or 3D texture, which is treated as a 2D image.
     Additionally, an entire level of a 3D texture, cube map texture,
     or 1D or 2D array texture can be attached to an attachment point.
     Such attachments are treated as an array of 2D images, arranged in
     layers, and the corresponding attachment point is considered to be layered. }
  TGLFramebufferHandle = class(TGLContextHandle)
  protected
    class function Transferable: Boolean; override;
    function DoAllocateHandle: Cardinal; override;
    procedure DoDestroyHandle(var AHandle: Cardinal); override;
    class function IsValid(const ID: Cardinal): Boolean; override;
  public
    // Bind framebuffer for both drawing + reading
    procedure Bind;
    // Bind framebuffer for drawing
    procedure BindForDrawing;
    // Bind framebuffer for reading
    procedure BindForReading;
    {Note that it is not necessary to unbind before binding another framebuffer. }
    procedure UnBind;
    procedure UnBindForDrawing;
    procedure UnBindForReading;
    // target = GL_DRAW_FRAMEBUFFER, GL_READ_FRAMEBUFFER, GL_FRAMEBUFFER (attach to both READ + DRAW)
    // attachment = COLOR_ATTACHMENTi, DEPTH_ATTACHMENT, STENCIL_ATTACHMENT, DEPTH_STENCIL_ATTACHMENT
    procedure Attach1DTexture(target: Cardinal; attachment: Cardinal; textarget:
      Cardinal; texture: Cardinal; level: TGLint);
    procedure Attach2DTexture(target: Cardinal; attachment: Cardinal; textarget:
      Cardinal; texture: Cardinal; level: TGLint);
    procedure Attach3DTexture(target: Cardinal; attachment: Cardinal; textarget:
      Cardinal; texture: Cardinal; level: TGLint; layer: TGLint);
    procedure AttachLayer(target: Cardinal; attachment: Cardinal; texture:
      Cardinal; level: TGLint; layer: TGLint);
    procedure AttachRenderBuffer(target: Cardinal; attachment: Cardinal;
      renderbuffertarget: Cardinal; renderbuffer: Cardinal);
    // OpenGL 3.2+ only.
    // If texture is the name of a three-dimensional texture, cube map texture, one-or
    // two-dimensional array texture, or two-dimensional multisample array texture, the
    // texture level attached to the framebuffer attachment point is an array of images,
    // and the framebuffer attachment is considered layered.
    procedure AttachTexture(target: Cardinal; attachment: Cardinal; texture:
      Cardinal; level: TGLint);
    // OpenGL 3.2+ only
    procedure AttachTextureLayer(target: Cardinal; attachment: Cardinal; texture:
      Cardinal; level: TGLint; layer: TGLint);

    // copy rect from bound read framebuffer to bound draw framebuffer
    procedure Blit(srcX0: TGLint; srcY0: TGLint; srcX1: TGLint; srcY1: TGLint;
      dstX0: TGLint; dstY0: TGLint; dstX1: TGLint; dstY1: TGLint;
      mask: TGLbitfield; filter: Cardinal);
    // target = GL_DRAW_FRAMEBUFFER, GL_READ_FRAMEBUFFER, GL_FRAMEBUFFER (equivalent to GL_DRAW_FRAMEBUFFER)
    // If default framebuffer (0) is bound:
    // attachment = GL_FRONT_LEFT, GL_FRONT_RIGHT, GL_BACK_LEFT, or GL_BACK_RIGHT, GL_DEPTH, GL_STENCIL
    // if a framebuffer object is bound:
    // attachment = GL_COLOR_ATTACHMENTi, GL_DEPTH_ATTACHMENT, GL_STENCIL_ATTACHMENT, GL_DEPTH_STENCIL_ATTACHMENT
    // param = GL_FRAMEBUFFER_ATTACHMENT_(OBJECT_TYPE, OBJECT_NAME,
    //       RED_SIZE, GREEN_SIZE, BLUE_SIZE, ALPHA_SIZE, DEPTH_SIZE, STENCIL_SIZE,
    //       COMPONENT_TYPE, COLOR_ENCODING, TEXTURE_LEVEL, LAYERED, TEXTURE_CUBE_MAP_FACE, TEXTURE_LAYER
    function GetAttachmentParameter(target: Cardinal; attachment: Cardinal; pname:
      Cardinal): TGLint;
    // Returns the type of object bound to attachment point:
    // GL_NONE, GL_FRAMEBUFFER_DEFAULT, GL_TEXTURE, or GL_RENDERBUFFER
    function GetAttachmentObjectType(target: Cardinal; attachment: Cardinal):
      TGLint;
    // Returns the name (ID) of the texture or renderbuffer attached to attachment point
    function GetAttachmentObjectName(target: Cardinal; attachment: Cardinal):
      TGLint;

    function GetStatus: TGLFramebufferStatus;
    function GetStringStatus(out clarification: string): TGLFramebufferStatus;

    class function IsSupported: Boolean; override;
  end;

  {Manages a handle to a Renderbuffer Object.
     A Renderbuffer is a "framebuffer-attachable image" for generalized offscreen
     rendering and it also provides a means to support rendering to GL logical
     buffer types which have no corresponding texture format (stencil, accum, etc). }
  TGLRenderbufferHandle = class(TGLContextHandle)
  protected
    function DoAllocateHandle: Cardinal; override;
    procedure DoDestroyHandle(var AHandle: Cardinal); override;
    class function IsValid(const ID: Cardinal): Boolean; override;
  public
    procedure Bind;
    procedure UnBind;
    procedure SetStorage(internalformat: Cardinal; width, height: TGLsizei);
    procedure SetStorageMultisample(internalformat: Cardinal; samples: TGLsizei;
      width, height: TGLsizei);
    class function IsSupported: Boolean; override;
  end;

  TGLARBProgramHandle = class(TGLContextHandle)
  private
     
    FReady: Boolean;
    FInfoLog: string;
  protected
    function DoAllocateHandle: Cardinal; override;
    procedure DoDestroyHandle(var AHandle: Cardinal); override;
    class function IsValid(const ID: Cardinal): Boolean; override;
    class function GetTarget: Cardinal; virtual; abstract;
  public
    procedure LoadARBProgram(const AText: string);
    procedure Enable;
    procedure Disable;
    procedure Bind;
    property Ready: Boolean read FReady;
    property InfoLog: string read FInfoLog;
  end;

  TGLARBVertexProgramHandle = class(TGLARBProgramHandle)
  protected
    class function GetTarget: Cardinal; override;
  public
    class function IsSupported: Boolean; override;
  end;

  TGLARBFragmentProgramHandle = class(TGLARBProgramHandle)
  protected
    class function GetTarget: Cardinal; override;
  public
    class function IsSupported: Boolean; override;
  end;

  TGLARBGeometryProgramHandle = class(TGLARBProgramHandle)
  protected
    class function GetTarget: Cardinal; override;
  public
    class function IsSupported: Boolean; override;
  end;

  {Base class for GLSL handles (programs and shaders).
     Do not use this class directly, use one of its subclasses instead. }
  TGLSLHandle = class(TGLContextHandle)
  protected
    procedure DoDestroyHandle(var AHandle: Cardinal); override;
  public
    function InfoLog: string;
    class function IsSupported: Boolean; override;
  end;

  {Manages a handle to a Shader Object.
     Does *NOT* check for extension availability, this is assumed to have been
     checked by the user.
     Do not use this class directly, use one of its subclasses instead. }
  TGLShaderHandle = class(TGLSLHandle)
  private
    FShaderType: Cardinal;
  protected
    function DoAllocateHandle: Cardinal; override;
    class function IsValid(const ID: Cardinal): Boolean; override;
  public
    procedure ShaderSource(const source: AnsiString); overload;
    // Returns True if compilation sucessful
    function CompileShader: Boolean;
    property ShaderType: Cardinal read FShaderType;
  end;

  TGLShaderHandleClass = class of TGLShaderHandle;

  {Manages a handle to a Vertex Shader Object. }
  TGLVertexShaderHandle = class(TGLShaderHandle)
  public
    constructor Create; override;
    class function IsSupported: Boolean; override;
  end;

  {Manages a handle to a Geometry Shader Object. }
  TGLGeometryShaderHandle = class(TGLShaderHandle)
  public
    constructor Create; override;
    class function IsSupported: Boolean; override;
  end;

  {Manages a handle to a Fragment Shader Object. }
  TGLFragmentShaderHandle = class(TGLShaderHandle)
  public
    constructor Create; override;
    class function IsSupported: Boolean; override;
  end;

  {Manages a handle to a Tessellation Control Shader Object. }
  TGLTessControlShaderHandle = class(TGLShaderHandle)
  public
    constructor Create; override;
    class function IsSupported: Boolean; override;
  end;

  {Manages a handle to a Tessellation Evaluation Shader Object. }
  TGLTessEvaluationShaderHandle = class(TGLShaderHandle)
  public
    constructor Create; override;
    class function IsSupported: Boolean; override;
  end;

  {Manages a GLSL Program Object.
     Does *NOT* check for extension availability, this is assumed to have been
     checked by the user. }
  TGLProgramHandle = class(TGLSLHandle)
  public
    class function IsValid(const ID: Cardinal): Boolean; override;
  private
    FName: string;
    function GetUniform1i(const index: string): Integer;
    procedure SetUniform1i(const index: string; val: Integer);
    function GetUniform2i(const index: string): TVector2i;
    procedure SetUniform2i(const index: string; const Value: TVector2i);
    function GetUniform3i(const index: string): TVector3i;
    procedure SetUniform3i(const index: string; const Value: TVector3i);
    function GetUniform4i(const index: string): TVector4i;
    procedure SetUniform4i(const index: string; const Value: TVector4i);
    function GetUniform1f(const index: string): Single;
    procedure SetUniform1f(const index: string; val: Single);
    function GetUniform2f(const index: string): TVector2f;
    procedure SetUniform2f(const index: string; const val: TVector2f);
    function GetUniform3f(const index: string): TAffineVector;
    procedure SetUniform3f(const index: string; const val: TAffineVector);
    function GetUniform4f(const index: string): TVector;
    procedure SetUniform4f(const index: string; const val: TVector);
    function GetUniformMatrix2fv(const index: string): TMatrix2f;
    procedure SetUniformMatrix2fv(const index: string; const val: TMatrix2f);
    function GetUniformMatrix3fv(const index: string): TMatrix3f;
    procedure SetUniformMatrix3fv(const index: string; const val: TMatrix3f);
    function GetUniformMatrix4fv(const index: string): TMatrix;
    procedure SetUniformMatrix4fv(const index: string; const val: TMatrix);
    function GetUniformTextureHandle(const index: string;
      const TextureIndex: Integer; const TextureTarget: TGLTextureTarget):
      Cardinal;
    procedure SetUniformTextureHandle(const index: string;
      const TextureIndex: Integer; const TextureTarget: TGLTextureTarget;
      const Value: Cardinal);
    procedure SetUniformBuffer(const index: string;
      Value: TGLUniformBufferHandle);
  protected
    function DoAllocateHandle: cardinal; override;
  public
    property Name: string read FName write FName;
    constructor Create; override;
    {Compile and attach a new shader.
       Raises an EGLShader exception in case of failure. }
    procedure AddShader(shaderType: TGLShaderHandleClass; const shaderSource:
      string;
      treatWarningsAsErrors: Boolean = False);
    procedure AttachObject(shader: TGLShaderHandle);
    procedure DetachAllObject;
    procedure BindAttribLocation(index: Integer; const aName: string);
    procedure BindFragDataLocation(index: Integer; const aName: string);
    function LinkProgram: Boolean;
    function ValidateProgram: Boolean;
    function GetAttribLocation(const aName: string): Integer;
    function GetUniformLocation(const aName: string): Integer;
    function GetUniformOffset(const aName: string): PGLInt;
    function GetUniformBlockIndex(const aName: string): Integer;
    function GetVaryingLocation(const aName: string): Integer;
    // Currently, NVidia-specific.
    procedure AddActiveVarying(const aName: string);
    // Currently, NVidia-specific.
    function GetUniformBufferSize(const aName: string): Integer;
    procedure UseProgramObject;
    procedure EndUseProgramObject;
    procedure SetUniformi(const index: string; const val: integer); overload;
    procedure SetUniformi(const index: string; const val: TVector2i); overload;
    procedure SetUniformi(const index: string; const val: TVector3i); overload;
    procedure SetUniformi(const index: string; const val: TVector4i); overload;
    procedure SetUniformf(const index: string; const val: single); overload;
    procedure SetUniformf(const index: string; const val: TVector2f); overload;
    procedure SetUniformf(const index: string; const val: TVector3f); overload;
    procedure SetUniformf(const index: string; const val: TVector4f); overload;
    {Shader parameters. }
    property Uniform1i[const index: string]: Integer read GetUniform1i write
    SetUniform1i;
    property Uniform2i[const index: string]: TVector2i read GetUniform2i write
    SetUniform2i;
    property Uniform3i[const index: string]: TVector3i read GetUniform3i write
    SetUniform3i;
    property Uniform4i[const index: string]: TVector4i read GetUniform4i write
    SetUniform4i;
    property Uniform1f[const index: string]: Single read GetUniform1f write
    SetUniform1f;
    property Uniform2f[const index: string]: TVector2f read GetUniform2f write
    SetUniform2f;
    property Uniform3f[const index: string]: TAffineVector read GetUniform3f
    write SetUniform3f;
    property Uniform4f[const index: string]: TVector read GetUniform4f write
    SetUniform4f;
    property UniformMatrix2fv[const index: string]: TMatrix2f read
    GetUniformMatrix2fv write SetUniformMatrix2fv;
    property UniformMatrix3fv[const index: string]: TMatrix3f read
    GetUniformMatrix3fv write SetUniformMatrix3fv;
    property UniformMatrix4fv[const index: string]: TMatrix read
    GetUniformMatrix4fv write SetUniformMatrix4fv;
    property UniformTextureHandle[const index: string; const TextureIndex:
    Integer; const TextureTarget: TGLTextureTarget]: Cardinal read
    GetUniformTextureHandle write SetUniformTextureHandle;
    property UniformBuffer[const index: string]: TGLUniformBufferHandle write
    SetUniformBuffer;
  end;

  TGLContextNotification = record
    obj: TObject;
    event: TNotifyEvent;
  end;

  {Stores and manages all the TGLContext objects.  }
  TGLContextManager = class
  private

    FList: TThreadList;
    FTerminated: Boolean;
    FNotifications: array of TGLContextNotification;
    FCreatedRCCount: Integer;

{$IFNDEF USE_MULTITHREAD}
    FHandles: TList;
{$ELSE}
    FHandles: TThreadList;
{$ENDIF USE_MULTITHREAD}

{$IFDEF USE_SERVICE_CONTEXT}
    FThread: TThread;
    FServiceStarter: TEvent;
    FThreadTask: TServiceContextTaskList;
{$ENDIF}
    FServiceContext: TGLContext;
  protected
    procedure Lock;
    procedure UnLock;
    procedure RegisterContext(aContext: TGLContext);
    procedure UnRegisterContext(aContext: TGLContext);
    procedure ContextCreatedBy(aContext: TGLContext);
    procedure DestroyingContextBy(aContext: TGLContext);

{$IFDEF USE_SERVICE_CONTEXT}
    {Create a special service and resource-keeper context. }
    procedure CreateServiceContext;
    procedure QueueTaskDepleted;
    property ServiceStarter: TEvent read FServiceStarter;
{$ENDIF}
    property ServiceContext: TGLContext read FServiceContext;
  public
    constructor Create;
    destructor Destroy; override;
    {Returns an appropriate, ready-to use context.
       The returned context should be freed by caller. }
    function CreateContext(AClass: TGLContextClass = nil): TGLContext;
    {Returns the number of TGLContext object.
       This is *not* the number of OpenGL rendering contexts! }
    function ContextCount: Integer;
    {Registers a new object to notify when the last context is destroyed.
       When the last rendering context is destroyed, the 'anEvent' will
       be invoked with 'anObject' as parameter.
       Note that the registration is kept until the notification is triggered
       or a RemoveNotification on 'anObject' is issued. }
    procedure LastContextDestroyNotification(anObject: TObject; anEvent:
      TNotifyEvent);
    {Unregisters an object from the notification lists.  }
    procedure RemoveNotification(anObject: TObject);
    // Marks the context manager for termination
    procedure Terminate;
    {Request all contexts to destroy all their handles. }
    procedure DestroyAllHandles;
    {Notify all contexts about necessity of handles preparation. }
    procedure NotifyPreparationNeed;
  end;

  EGLContext = class(Exception);
  EPBuffer = class(Exception);
  EGLShader = class(EGLContext);

  {Drivers should register themselves via this function. }
procedure RegisterGLContextClass(aGLContextClass: TGLContextClass);
{The TGLContext that is the currently active context, if any.
   Returns nil if no context is active. }
function CurrentGLContext: TGLContext; inline;
function SafeCurrentGLContext: TGLContext; inline;
function IsMainThread: Boolean;
function IsServiceContextAvaible: Boolean;
function GetServiceWindow: TForm;
{$IFDEF USE_SERVICE_CONTEXT}
procedure AddTaskForServiceContext(ATask: TTaskProcedure; FinishEvent: TFinishTaskEvent = nil);
{$ENDIF}

var
  GLContextManager: TGLContextManager;
  vIgnoreOpenGLErrors: Boolean = False;
  vContextActivationFailureOccurred: Boolean = false;

{$IFNDEF USE_MULTITHREAD}
var
{$ELSE}
threadvar
{$ENDIF}

  vCurrentGLContext: TGLContext;
  GL: TGLExtensionsAndEntryPoints;
  xgl: TGLMultitextureCoordinator;
  vMainThread: Boolean;
  GLwithoutContext: TGLExtensionsAndEntryPoints;


// ------------------------------------------------------------------
implementation
// ------------------------------------------------------------------

{$IFDEF USE_SERVICE_CONTEXT}
type
  TServiceContextThread = class(TThread)
  private
    FDC: HDC;
    FWindow: TForm;
    FLastTaskStartTime: Double;
    FReported: Boolean;
  protected
    procedure Execute; override;
    procedure DoCreateServiceContext; stdcall;
  public
    constructor Create;
    destructor Destroy; override;
  end;
{$ENDIF}

var
  vContextClasses: TList;
  vServiceWindow: TForm;
{$IFDEF USE_SERVICE_CONTEXT}
  OldInitProc: Pointer;
{$ENDIF}

function CurrentGLContext: TGLContext; inline;
begin
  Result := vCurrentGLContext;
end;

function SafeCurrentGLContext: TGLContext; inline;
begin
  Result := CurrentGLContext;
  if not Assigned(Result) then
  begin
   {$IFDEF USE_LOGGING}
     GLSLogger.LogError(strNoActiveRC);
   {$ENDIF}
    Abort;
  end;
end;

function IsMainThread: Boolean;
begin
  Result := vMainThread;
end;

function IsServiceContextAvaible: Boolean;
begin
  Result := GLContextManager.ServiceContext <> nil;
end;

function GetServiceWindow: TForm;
begin
  Result := vServiceWindow;
end;

procedure RegisterGLContextClass(aGLContextClass: TGLContextClass);
begin
  if not Assigned(vContextClasses) then
    vContextClasses := TList.Create;
  vContextClasses.Add(aGLContextClass);
end;

// ------------------
// ------------------ TGLContext ------------------
// ------------------


constructor TGLContext.Create;
begin
  inherited Create;
{$IFDEF USE_MULTITHREAD}
  FLock := TCriticalSection.Create;
{$ENDIF}
  FColorBits := 32;
  FStencilBits := 0;
  FAccumBits := 0;
  FAuxBuffers := 0;
  FLayer := clMainPlane;
  FOptions := [];
{$IFNDEF USE_MULTITHREAD}
  FSharedContexts := TList.Create;
{$ELSE}
  FSharedContexts := TThreadList.Create;
{$ENDIF}
  FSharedContexts.Add(Self);
  FAcceleration := chaUnknown;
  FGLStates := TGLStateCache.Create;
  FGL := TGLExtensionsAndEntryPoints.Create;
  FTransformation := TGLTransformation.Create;
  FTransformation.LoadMatricesEnabled := True;
  GLContextManager.RegisterContext(Self);
  FIsPraparationNeed := True;
  FXGL := TGLMultitextureCoordinator.Create;
end;

destructor TGLContext.Destroy;
begin
  if IsValid then
    DestroyContext;
  GLContextManager.UnRegisterContext(Self);
  FGLStates.Free;
  FGL.Free;
  FXGL.Free;
  FTransformation.Free;
  FSharedContexts.Free;
{$IFDEF USE_MULTITHREAD}
  FLock.Free;
{$ENDIF}
  inherited Destroy;
end;

procedure TGLContext.SetColorBits(const aColorBits: Integer);
begin
  if Active then
    raise EGLContext.Create(strCannotAlterAnActiveContext)
  else
    FColorBits := aColorBits;
end;

procedure TGLContext.SetAlphaBits(const aAlphaBits: Integer);
begin
  if Active then
    raise EGLContext.Create(strCannotAlterAnActiveContext)
  else
    FAlphaBits := aAlphaBits;
end;

procedure TGLContext.SetDepthBits(const val: Integer);
begin
  if Active then
    raise EGLContext.Create(strCannotAlterAnActiveContext)
  else
    FDepthBits := val;
end;

procedure TGLContext.SetLayer(const Value: TGLContextLayer);
begin
  if Active then
    raise EGLContext.Create(strCannotAlterAnActiveContext)
  else
    FLayer := Value;
end;

procedure TGLContext.SetStencilBits(const aStencilBits: Integer);
begin
  if Active then
    raise EGLContext.Create(strCannotAlterAnActiveContext)
  else
    FStencilBits := aStencilBits;
end;

procedure TGLContext.SetAccumBits(const aAccumBits: Integer);
begin
  if Active then
    raise EGLContext.Create(strCannotAlterAnActiveContext)
  else
    FAccumBits := aAccumBits;
end;

procedure TGLContext.SetAuxBuffers(const aAuxBuffers: Integer);
begin
  if Active then
    raise EGLContext.Create(strCannotAlterAnActiveContext)
  else
    FAuxBuffers := aAuxBuffers;
end;

procedure TGLContext.SetOptions(const aOptions: TGLRCOptions);
begin
  if Active then
    raise EGLContext.Create(strCannotAlterAnActiveContext)
  else
    FOptions := aOptions;
end;

procedure TGLContext.SetAntiAliasing(const val: TGLAntiAliasing);
begin
  if Active then
    raise EGLContext.Create(strCannotAlterAnActiveContext)
  else
    FAntiAliasing := val;
end;

procedure TGLContext.SetAcceleration(const val: TGLContextAcceleration);
begin
  if Active then
    raise EGLContext.Create(strCannotAlterAnActiveContext)
  else
    FAcceleration := val;
end;

function TGLContext.GetActive: Boolean;
begin
  Result := (FActivationCount > 0);
end;

procedure TGLContext.SetActive(const aActive: Boolean);
begin
  // activation/deactivation can be nested...
  while aActive <> Active do
  begin
    if aActive then
      Activate
    else
      Deactivate;
  end;
end;

procedure TGLContext.CreateContext(ADeviceHandle: HDC);
begin
  if IsValid then
    raise EGLContext.Create(strContextAlreadyCreated);
  DoCreateContext(ADeviceHandle);
  Manager.ContextCreatedBy(Self);
end;

procedure TGLContext.CreateMemoryContext(outputDevice: HWND;
  width, height: Integer; BufferCount: integer);
begin
  if IsValid then
    raise EGLContext.Create(strContextAlreadyCreated);
  DoCreateMemoryContext(outputDevice, width, height, BufferCount);
  Manager.ContextCreatedBy(Self);
end;

procedure TGLContext.PrepareHandlesData;
var
  I: Integer;
  LHandle: TGLContextHandle;
begin
  if vCurrentGLContext = Self then
  begin
{$IFNDEF USE_MULTITHREAD}
    for i := Manager.FHandles.Count - 1 downto 0 do
    begin
      LHandle := TGLContextHandle(Manager.FHandles[i]);
      if Assigned(LHandle.FOnPrepare) then
        LHandle.FOnPrepare(Self);
    end;
{$ELSE}
    with Manager.FHandles.LockList do
      try
        for i := Count - 1 downto 0 do
        begin
          LHandle := TGLContextHandle(Items[i]);
          if Assigned(LHandle.FOnPrepare) then
            LHandle.FOnPrepare(Self);
        end;
      finally
        Manager.FHandles.UnlockList;
      end;
{$ENDIF}
    FIsPraparationNeed := False;
  end;
end;

procedure TGLContext.PropagateSharedContext;
var
  i, j: Integer;
  otherContext: TGLContext;
  otherList: TList;
begin
{$IFNDEF USE_MULTITHREAD}
  with FSharedContexts do
  begin
    for i := 1 to Count - 1 do
    begin
      otherContext := TGLContext(Items[i]);
      otherList := otherContext.FSharedContexts;
      for J := 0 to otherList.Count - 1 do
        if IndexOf(otherList[J]) < 0 then
          Add(otherList[J]);
    end;
    for i := 1 to Count - 1 do
    begin
      otherContext := TGLContext(Items[i]);
      otherList := otherContext.FSharedContexts;
      if otherList.IndexOf(Self) < 0 then
        otherList.Add(Self);
    end;
  end;
{$ELSE}
  with FSharedContexts.LockList do
    try
      for i := 1 to Count - 1 do
      begin
        otherContext := TGLContext(Items[i]);
        otherList := otherContext.FSharedContexts.LockList;
        for J := 0 to otherList.Count - 1 do
          if IndexOf(otherList[J]) < 0 then
            Add(otherList[J]);
        otherContext.FSharedContexts.UnlockList;
      end;
      for i := 1 to Count - 1 do
      begin
        otherContext := TGLContext(Items[i]);
        otherList := otherContext.FSharedContexts.LockList;
        if otherList.IndexOf(Self) < 0 then
          otherList.Add(Self);
        otherContext.FSharedContexts.UnlockList;
      end;
    finally
      FSharedContexts.UnlockList;
    end;
{$ENDIF}
end;

procedure TGLContext.ShareLists(aContext: TGLContext);
begin
{$IFNDEF USE_MULTITHREAD}
  if FSharedContexts.IndexOf(aContext) < 0 then
  begin
    if DoShareLists(aContext) then
    begin
      FSharedContexts.Add(aContext);
      PropagateSharedContext;
    end;
  end;
{$ELSE}
  with FSharedContexts.LockList do
    try
      if IndexOf(aContext) < 0 then
      begin
        if DoShareLists(aContext) then
        begin
          Add(aContext);
          PropagateSharedContext;
        end;
      end;
    finally
      FSharedContexts.UnlockList;
    end;
{$ENDIF}
end;

procedure TGLContext.DestroyAllHandles;
var
  i: Integer;
begin
  Activate;
  try
{$IFNDEF USE_MULTITHREAD}
    for i := Manager.FHandles.Count - 1 downto 0 do
      TGLContextHandle(Manager.FHandles[i]).ContextDestroying;
{$ELSE}
    with Manager.FHandles.LockList do
      try
        for i := Count - 1 downto 0 do
          TGLContextHandle(Items[i]).ContextDestroying;
      finally
        Manager.FHandles.UnlockList;
      end;
{$ENDIF}
  finally
    Deactivate;
  end;
end;

procedure TGLContext.DestroyContext;
var
  I: Integer;
  oldContext, otherContext: TGLContext;
  contextHandle: TGLContextHandle;
  aList: TList;
begin

  if vCurrentGLContext <> Self then
  begin
    oldContext := vCurrentGLContext;
    if Assigned(oldContext) then
      oldContext.Deactivate;
  end
  else
    oldContext := nil;

  Activate;
  try
{$IFNDEF USE_MULTITHREAD}
    for i := Manager.FHandles.Count - 1 downto 0 do
    begin
      contextHandle := TGLContextHandle(Manager.FHandles[i]);
      contextHandle.ContextDestroying;
    end;
{$ELSE}
    aList := Manager.FHandles.LockList;
    try
      for i := aList.Count - 1 downto 0 do
      begin
        contextHandle := TGLContextHandle(aList[i]);
        contextHandle.ContextDestroying;
      end;
    finally
      Manager.FHandles.UnlockList;
    end;
{$ENDIF}
    Manager.DestroyingContextBy(Self);

{$IFDEF USE_MULTITHREAD}
    aList := FSharedContexts.LockList;
{$ELSE}
    aList := FSharedContexts;
{$ENDIF}
    for I := 1 to aList.Count - 1 do
    begin
      otherContext := TGLContext(aList[I]);
      otherContext.FSharedContexts.Remove(Self);
    end;
    FSharedContexts.Clear;
    FSharedContexts.Add(Self);
{$IFDEF USE_MULTITHREAD}
    FSharedContexts.UnlockList;
{$ENDIF}
    Active := False;
    DoDestroyContext;
  finally
    if Assigned(oldContext) then
      oldContext.Activate;
  end;
  FAcceleration := chaUnknown;
  FGL.Close;
end;

procedure TGLContext.Activate;
begin
{$IFDEF USE_MULTITHREAD}
  FLock.Enter;
{$ENDIF}
  if FActivationCount = 0 then
  begin
    if not IsValid then
      raise EGLContext.Create(strContextNotCreated);

    vContextActivationFailureOccurred := False;
    try
      DoActivate;
    except
      vContextActivationFailureOccurred := True;
    end;
    GLContext.GL := FGL;
    XGL := FXGL;
    vCurrentGLContext := Self;
  end
  else
    Assert(vCurrentGLContext = Self, 'vCurrentGLContext <> Self');
  Inc(FActivationCount);
end;

procedure TGLContext.Deactivate;
begin
  Assert(vCurrentGLContext = Self);
  Dec(FActivationCount);
  if FActivationCount = 0 then
  begin
    if not IsValid then
      raise EGLContext.Create(strContextNotCreated);
    if not vContextActivationFailureOccurred then
      DoDeactivate;
    vCurrentGLContext := nil;
    GLContext.GL := GLwithoutContext;
    XGL := nil;
  end
  else if FActivationCount < 0 then
    raise EGLContext.Create(strUnbalancedContexActivations);
{$IFDEF USE_MULTITHREAD}
  FLock.Leave;
{$ENDIF}
end;

function TGLContext.FindCompatibleContext: TGLContext;
var
  i: Integer;
begin
  Result := nil;
{$IFNDEF USE_MULTITHREAD}
  for i := 0 to FSharedContexts.Count - 1 do
    if TGLContext(FSharedContexts[i]) <> Self then
    begin
      Result := TGLContext(FSharedContexts[i]);
      Break;
    end;
{$ELSE}
  with FSharedContexts.LockList do
    try
      for i := 0 to Count - 1 do
        if TGLContext(Items[i]) <> Self then
        begin
          Result := TGLContext(Items[i]);
          Break;
        end;
    finally
      FSharedContexts.UnlockList;
    end;
{$ENDIF}
end;

class function TGLContext.ServiceContext: TGLContext;
begin
  Result := GLContextManager.FServiceContext;
end;

procedure TGLContext.MakeGLCurrent;
begin
  GLContext.GL := FGL;
end;


// ------------------
// ------------------ TGLContextHandle ------------------
// ------------------

constructor TGLContextHandle.Create;
begin
  inherited Create;
  FHandles := TList.Create;
  //first is a dummy record
  new(FLastHandle);
  FillChar(FLastHandle^, sizeof(FLastHandle^), 0);
  FHandles.Add(FLastHandle);
  GLContextManager.FHandles.Add(Self);
end;

constructor TGLContextHandle.CreateAndAllocate(failIfAllocationFailed: Boolean =
  True);
begin
  Create;
  AllocateHandle;
  if failIfAllocationFailed and (Handle = 0) then
    raise EGLContext.Create('Auto-allocation failed');
end;

destructor TGLContextHandle.Destroy;
var
  i : integer;
begin
  DestroyHandle;
  for i := 0 to FHandles.Count-1 do
    Dispose(RCItem(i));
  FHandles.Free;
  if Assigned(GLContextManager) then
    GLContextManager.FHandles.Remove(Self);
  inherited Destroy;
end;

function TGLContextHandle.AllocateHandle: Cardinal;
var
  I: Integer;
  bSucces: Boolean;
  aList: TList;
  p : PGLRCHandle;

begin
  // if handle aready allocated in current context
  Result := GetHandle;
  if Result <> 0 then
    exit;

  if vCurrentGLContext = nil then
  begin
    {$IFDEF USE_LOGGING}
    GLSLogger.LogError('Failed to allocate OpenGL identifier - no active rendering context!');
    {$ENDIF}
    exit;
  end;

  //add entry
  New(FLastHandle);
  FillChar(FLastHandle^, sizeof(FLastHandle^), 0);
  FHandles.Add(FLastHandle);
  FLastHandle.FRenderingContext := vCurrentGLContext;

  bSucces := False;
  if Transferable then
  begin
{$IFNDEF USE_MULTITHREAD}
    aList := vCurrentGLContext.FSharedContexts;
{$ELSE}
    aList := vCurrentGLContext.FSharedContexts.LockList;
    try
{$ENDIF}
      for I := aList.Count - 1 downto 0 do
      begin
        P := SearchRC(aList[I]);
        if (P.FHandle > 0) then
        begin
          // Copy shared handle
          //FLastHandle.FRenderingContext := vCurrentGLContext;
          FLastHandle.FHandle           := P.FHandle;
          FLastHandle.FChanged          := P.FChanged;
          Inc(vCurrentGLContext.FOwnedHandlesCount);
          bSucces := True;
          break;
        end;
      end;
{$IFNDEF USE_MULTITHREAD}
{$ELSE}
    finally
      vCurrentGLContext.FSharedContexts.UnlockList;
    end;
{$ENDIF}
  end;

  if not bSucces then
  begin
    // Allocate handle in current context
    FLastHandle.FHandle := DoAllocateHandle;
    bSucces := FLastHandle.FHandle <> 0;
    FLastHandle.FChanged := bSucces;
    if bSucces then
      Inc(vCurrentGLContext.FOwnedHandlesCount);
  end;

  Result := FLastHandle.FHandle;
  if not bSucces then
    GLSLogger.LogError(strNoActiveRC)
  else if Assigned(FOnPrepare) then
    GLContextManager.NotifyPreparationNeed;
end;

function TGLContextHandle.IsAllocatedForContext(AContext: TGLContext = nil): Boolean;
begin
  Result := SearchRC(AContext).FHandle > 0;
end;

function TGLContextHandle.SearchRC(AContext: TGLContext): PGLRCHandle;
var
  i : integer;
begin
  if AContext = nil then
    AContext := vCurrentGLContext;

  if AContext = FLastHandle.FRenderingContext then
  begin
    Result := FLastHandle;
    exit;
  end;

  for i := 1 to FHandles.Count-1 do
    if RCItem(i).FRenderingContext = AContext then
    begin
      Result := RCItem(i);
      exit;
    end;

  //first handle is always a dummy
  Result := FHandles[0];
end;

procedure TGLContextHandle.CheckCurrentRC;
begin
  if vCurrentGLContext <> FLastHandle.FRenderingContext then
    FLastHandle := SearchRC(vCurrentGLContext);
end;

function TGLContextHandle.GetHandle: Cardinal;
begin
//  CheckCurrentRC;
//inline doesn't always work... so optimize it here
  if vCurrentGLContext <> FLastHandle.FRenderingContext then
    FLastHandle := SearchRC(vCurrentGLContext);

  Result := FLastHandle.FHandle;
end;

procedure TGLContextHandle.DestroyHandle;
var
  oldContext: TGLContext;
  P : PGLRCHandle;
  I: Integer;
begin
  oldContext := vCurrentGLContext;
  if Assigned(oldContext) then
    oldContext.Deactivate;
  try
    for I := FHandles.Count-1 downto 1 do
    begin
      P := FHandles[I];
      if P.FHandle > 0 then
      begin
        P.FRenderingContext.Activate;
        if IsValid(P.FHandle) then
          DoDestroyHandle(P.FHandle);
        Dec(P.FRenderingContext.FOwnedHandlesCount);
        P.FRenderingContext.Deactivate;
        P.FRenderingContext := nil;
        P.FHandle := 0;
        P.FChanged := True;
      end;
      Dispose(P);
    end;
    FHandles.Count := 1; //delete all in 1 step
    FLastHandle := FHandles[0];
  finally
    if Assigned(vCurrentGLContext) then
      vCurrentGLContext.Deactivate;
    if Assigned(oldContext) then
      oldContext.Activate;
  end;
end;

procedure TGLContextHandle.ContextDestroying;
var
  I: Integer;
  P: PGLRCHandle;
  aList: TList;
  bShared: Boolean;
begin
  if Assigned(vCurrentGLContext) then
  begin
    bShared := False;
    if Transferable then
    begin
    {$IFNDEF USE_MULTITHREAD}
      aList := vCurrentGLContext.FSharedContexts;
    {$ELSE}
      aList := vCurrentGLContext.FSharedContexts.LockList;
      try
    {$ENDIF USE_MULTITHREAD}
        for I := FHandles.Count-1 downto 1 do
        begin
          P := RCItem(I);
          if (P.FRenderingContext <> vCurrentGLContext)
            and (P.FHandle <> 0)
            and (aList.IndexOf(P.FRenderingContext) > -1) then
            begin
              bShared := True;
              break;
            end;
        end;
    {$IFDEF USE_MULTITHREAD}
      finally
        vCurrentGLContext.FSharedContexts.UnLockList;
      end;
    {$ENDIF USE_MULTITHREAD}
    end;

    for I := FHandles.Count-1 downto 1 do
    begin
      P := RCItem(I);
      if (P.FRenderingContext = vCurrentGLContext) and (P.FHandle <> 0) then
      begin
        if not bShared then
          if IsValid(P.FHandle) then
            DoDestroyHandle(P.FHandle);
        Dec(P.FRenderingContext.FOwnedHandlesCount);
        P.FHandle := 0;
        P.FRenderingContext := nil;
        P.FChanged := True;
        Dispose(P);
        FHandles.Delete(I);
        if FLastHandle = P then
          FLastHandle := FHandles[0];
        exit;
      end;
    end;
  end;
end;

function TGLContextHandle.GetContext: TGLContext;
var
  I: Integer;
  P: PGLRCHandle;
begin
  Result := nil;
  // Return first context where handle is allocated
  for I := FHandles.Count-1 downto 1 do
  begin
    P := RCItem(I);
    if (P.FRenderingContext <> nil) and (P.FHandle <> 0) then
    begin
      Result := P.FRenderingContext;
      // If handle allocated in active context - return it
      if (Result = vCurrentGLContext) then
        exit;
    end;
  end;
end;

function TGLContextHandle.IsDataNeedUpdate: Boolean;
begin
  if GetHandle = 0 then
    CheckCurrentRC;
  Result := (FLastHandle.FHandle = 0) or FLastHandle.FChanged;
end;

function TGLContextHandle.IsDataComplitelyUpdated: Boolean;
var
  I: Integer;
begin
  Result := false;
  for I := FHandles.Count-1 downto 1 do
  begin
    with RCItem(i)^ do
      if (FRenderingContext <> nil) and (FHandle <> 0) and FChanged then exit;
  end;
  Result := true;
end;

procedure TGLContextHandle.NotifyDataUpdated;
var
  I: Integer;
  aList: TList;
begin
  if Assigned(vCurrentGLContext) then
  begin
    if not Transferable then
    begin
      CheckCurrentRC();
      if FLastHandle.FHandle <> 0 then
      begin
        FLastHandle.FChanged := False;
        exit;
      end;
    end
    else
    begin
  {$IFNDEF USE_MULTITHREAD}
      aList := vCurrentGLContext.FSharedContexts;
  {$ELSE}
      aList := vCurrentGLContext.FSharedContexts.LockList;
      try
  {$ENDIF}
        for I := 0 to aList.Count - 1 do
        begin
          with SearchRC(aList[I])^ do
            if (FHandle <> 0) then
              FChanged := False;
        end;
  {$IFDEF USE_MULTITHREAD}
      finally
        vCurrentGLContext.FSharedContexts.UnlockList;
      end;
  {$ENDIF}
    end;
  end
   {$IFDEF USE_LOGGING}
  else
    GLSLogger.LogError(strNoActiveRC);
    {$ENDIF}
end;

function TGLContextHandle.RCItem(AIndex: integer): PGLRCHandle;
begin
  Result := FHandles[AIndex];
end;

procedure TGLContextHandle.NotifyChangesOfData;
var
  I: Integer;
begin
  for I := FHandles.Count-1 downto 1 do
    RCItem(I).FChanged := True;
  if Assigned(FOnPrepare) then
    GLContextManager.NotifyPreparationNeed;
end;

function TGLContextHandle.IsShared: Boolean;
var
  I: Integer;
  vContext: TGLContext;
  aList: TList;
begin
  Result := False;
  // untransferable handles can't be shared
  if not Transferable then
    exit;
  Result := True;
{$IFNDEF USE_MULTITHREAD}
  aList := vCurrentGLContext.FSharedContexts;
{$ELSE}
  aList := vCurrentGLContext.FSharedContexts.LockList;
  try
{$ENDIF}
    for I := 0 to aList.Count - 1 do
    begin
      vContext := aList[I];
      if (vContext <> vCurrentGLContext) and
        // at least one context is friendly
        (SearchRC(vContext).FHandle <> 0) then
        exit;
    end;
{$IFDEF USE_MULTITHREAD}
  finally
    vCurrentGLContext.FSharedContexts.UnlockList;
  end;
{$ENDIF}
  Result := false;
end;

class function TGLContextHandle.Transferable: Boolean;
begin
  Result := True;
end;

class function TGLContextHandle.IsValid(const ID: Cardinal): Boolean;
begin
  Result := True;
end;

class function TGLContextHandle.IsSupported: Boolean;
begin
  Result := True;
end;

// ------------------
// ------------------ TGLVirtualHandle ------------------
// ------------------

function TGLVirtualHandle.DoAllocateHandle: Cardinal;
begin
  Result := 0;
  if Assigned(FOnAllocate) then
    FOnAllocate(Self, Result);
end;

procedure TGLVirtualHandle.DoDestroyHandle(var AHandle: Cardinal);
begin
  if not vContextActivationFailureOccurred then
  with GL do
  begin
    // reset error status
    ClearError;
    // delete
    if Assigned(FOnDestroy) then
      FOnDestroy(Self, AHandle);
    // check for error
    CheckError;
  end;
end;

class function TGLVirtualHandle.Transferable: Boolean;
begin
  Result := False;
end;

{ TGLVirtualHandleTransf }

class function TGLVirtualHandleTransf.Transferable: Boolean;
begin
  Result := True;
end;

// ------------------
// ------------------ TGLListHandle ------------------
// ------------------

function TGLListHandle.DoAllocateHandle: Cardinal;
begin
  Result := GL.GenLists(1);
end;

procedure TGLListHandle.DoDestroyHandle(var AHandle: Cardinal);
begin
  if not vContextActivationFailureOccurred then
  with GL do
  begin
    // reset error status
    ClearError;
    // delete
    DeleteLists(AHandle, 1);
    // check for error
    CheckError;
  end;
end;

class function TGLListHandle.IsValid(const ID: Cardinal): Boolean;
begin
  Result := GL.IsList(ID);
end;

procedure TGLListHandle.NewList(mode: Cardinal);
begin
  vCurrentGLContext.GLStates.NewList(GetHandle, mode);
end;

procedure TGLListHandle.EndList;
begin
  vCurrentGLContext.GLStates.EndList;
end;

procedure TGLListHandle.CallList;
begin
  vCurrentGLContext.GLStates.CallList(GetHandle);
end;

// ------------------
// ------------------ TGLTextureHandle ------------------
// ------------------

function TGLTextureHandle.DoAllocateHandle: Cardinal;
begin
  Result := 0;
  GL.GenTextures(1, @Result);
  FTarget := ttNoShape;
end;

procedure TGLTextureHandle.DoDestroyHandle(var AHandle: Cardinal);
var
  a: TGLint;
  t: TGLTextureTarget;
begin
  if not vContextActivationFailureOccurred then
  with GL do
  begin
    // reset error status
    GetError;
    {Unbind identifier from all image selectors. }
    if ARB_multitexture then
    begin
      with GetContext.GLStates do
      begin
        for a := 0 to MaxTextureImageUnits - 1 do
          for t := Low(TGLTextureTarget) to High(TGLTextureTarget) do
            if TextureBinding[a, t] = AHandle then
              TextureBinding[a, t] := 0;
      end
    end
    else
      with GetContext.GLStates do
        for t := Low(TGLTextureTarget) to High(TGLTextureTarget) do
          if TextureBinding[0, t] = AHandle then
            TextureBinding[0, t] := 0;

    DeleteTextures(1, @AHandle);
    // check for error
    CheckError;
  end;
end;

class function TGLTextureHandle.IsValid(const ID: Cardinal): Boolean;
begin
  Result := GL.IsTexture(ID);
end;

procedure TGLTextureHandle.SetTarget(ATarget: TGLTextureTarget);
begin
  if FTarget = ttNoShape then
    FTarget := ATarget;
end;

// ------------------
// ------------------ TGLSamplerHandle ------------------
// ------------------

function TGLSamplerHandle.DoAllocateHandle: Cardinal;
begin
  Result := 0;
  GL.GenSamplers(1, @Result);
end;

procedure TGLSamplerHandle.DoDestroyHandle(var AHandle: Cardinal);
begin
  if not vContextActivationFailureOccurred then
  with GL do
  begin
    // reset error status
    GetError;
    // delete
    DeleteSamplers(1, @AHandle);
    // check for error
    CheckError;
  end;
end;

class function TGLSamplerHandle.IsSupported: Boolean;
begin
  Result := GL.ARB_sampler_objects;
end;

class function TGLSamplerHandle.IsValid(const ID: Cardinal): Boolean;
begin
  Result := GL.IsSampler(ID);
end;

// ------------------
// ------------------ TGLQueryHandle ------------------
// ------------------

procedure TGLQueryHandle.BeginQuery;
begin
  if vCurrentGLContext.GLStates.CurrentQuery[QueryType] = 0 then
    vCurrentGLContext.GLStates.BeginQuery(QueryType, GetHandle);
  Factive := True;
end;

function TGLQueryHandle.CounterBits: integer;
begin
  GL.GetQueryiv(Target, GL_QUERY_COUNTER_BITS, @Result);
end;

function TGLQueryHandle.DoAllocateHandle: Cardinal;
begin
  Result := 0;
  GL.GenQueries(1, @Result);
end;

procedure TGLQueryHandle.DoDestroyHandle(var AHandle: Cardinal);
begin
  if not vContextActivationFailureOccurred then
  with GL do
  begin
    // reset error status
    GetError;
    // delete
    DeleteQueries(1, @AHandle);
    // check for error
    CheckError;
  end;
end;

class function TGLQueryHandle.IsValid(const ID: Cardinal): Boolean;
begin
  Result := GL.IsQuery(ID);
end;

procedure TGLQueryHandle.EndQuery;
begin
  Assert(FActive = true, 'Cannot end a query before it begins');
  Factive := False;
  Assert(Handle <> 0);
  //glEndQuery(Target);
  vCurrentGLContext.GLStates.EndQuery(QueryType);
end;

function TGLQueryHandle.IsResultAvailable: boolean;
begin
  GL.GetQueryObjectiv(Handle, GL_QUERY_RESULT_AVAILABLE, @Result);
end;

function TGLQueryHandle.QueryResultInt: TGLInt;
begin
  GL.GetQueryObjectiv(Handle, GL_QUERY_RESULT, @Result);
end;

function TGLQueryHandle.QueryResultInt64: TGLint64EXT;
begin
  GL.GetQueryObjecti64v(Handle, GL_QUERY_RESULT, @Result);
end;

function TGLQueryHandle.QueryResultUInt: Cardinal;
begin
  GL.GetQueryObjectuiv(Handle, GL_QUERY_RESULT, @Result);
end;

function TGLQueryHandle.QueryResultUInt64: TGLuint64EXT;
begin
  GL.GetQueryObjectui64v(Handle, GL_QUERY_RESULT, @Result);
end;

function TGLQueryHandle.QueryResultBool: TGLboolean;
var
  I: Cardinal;
begin
  GL.GetQueryObjectuiv(Handle, GL_QUERY_RESULT, @I);
  Result := I > 0;
end;

class function TGLQueryHandle.Transferable: Boolean;
begin
  Result := False;
end;

// ------------------
// ------------------ TGLOcclusionQueryHandle ------------------
// ------------------

function TGLOcclusionQueryHandle.GetQueryType: TQueryType;
begin
  Result := qrySamplesPassed;
end;

function TGLOcclusionQueryHandle.GetTarget: Cardinal;
begin
  Result := GL_SAMPLES_PASSED;
end;

class function TGLOcclusionQueryHandle.IsSupported: Boolean;
begin
  Result := GL.VERSION_1_5;
end;

function TGLOcclusionQueryHandle.PixelCount: Integer;
begin
  Result := QueryResultUInt;
end;

// ------------------
// ------------------ TGLBooleanOcclusionQueryHandle ------------------
// ------------------

function TGLBooleanOcclusionQueryHandle.GetQueryType: TQueryType;
begin
  Result := qryAnySamplesPassed;
end;

function TGLBooleanOcclusionQueryHandle.GetTarget: Cardinal;
begin
  Result := GL_ANY_SAMPLES_PASSED;
end;

class function TGLBooleanOcclusionQueryHandle.IsSupported: Boolean;
begin
  Result := GL.ARB_occlusion_query2;
end;

// ------------------
// ------------------ TGLTimerQueryHandle ------------------
// ------------------

function TGLTimerQueryHandle.GetQueryType: TQueryType;
begin
  Result := qryTimeElapsed;
end;

function TGLTimerQueryHandle.GetTarget: Cardinal;
begin
  Result := GL_TIME_ELAPSED;
end;

class function TGLTimerQueryHandle.IsSupported: Boolean;
begin
  Result := GL.EXT_timer_query or GL.ARB_timer_query;
end;

function TGLTimerQueryHandle.Time: Integer;
begin
  Result := QueryResultUInt;
end;

// ------------------
// ------------------ TGLPrimitiveQueryHandle ------------------
// ------------------

function TGLPrimitiveQueryHandle.GetQueryType: TQueryType;
begin
  Result := qryPrimitivesGenerated;
end;

function TGLPrimitiveQueryHandle.GetTarget: Cardinal;
begin
  Result := GL_PRIMITIVES_GENERATED;
end;

class function TGLPrimitiveQueryHandle.IsSupported: Boolean;
begin
  Result := GL.VERSION_3_0;
end;

function TGLPrimitiveQueryHandle.PrimitivesGenerated: Integer;
begin
  Result := QueryResultUInt;
end;

// ------------------
// ------------------ TGLBufferObjectHandle ------------------
// ------------------

constructor TGLBufferObjectHandle.CreateFromData(p: Pointer; size: Integer;
  bufferUsage: Cardinal);
begin
  Create;
  AllocateHandle;
  Bind;
  BufferData(p, size, bufferUsage);
  UnBind;
end;

function TGLBufferObjectHandle.DoAllocateHandle: Cardinal;
begin
  Result := 0;
  GL.GenBuffers(1, @Result);
end;

procedure TGLBufferObjectHandle.DoDestroyHandle(var AHandle: Cardinal);
begin
  if not vContextActivationFailureOccurred then
  with GL do
  begin
    // reset error status
    GetError;
    UnBind;
    // delete
    DeleteBuffers(1, @AHandle);
    // check for error
    CheckError;
  end;
end;

class function TGLBufferObjectHandle.IsValid(const ID: Cardinal): Boolean;
begin
  Result := GL.IsBuffer(ID);
end;

class function TGLBufferObjectHandle.IsSupported: Boolean;
begin
  Result := GL.ARB_vertex_buffer_object;
end;

procedure TGLBufferObjectHandle.BindRange(index: Cardinal; offset: TGLintptr;
  size: TGLsizeiptr);
begin
  Assert(False, 'BindRange only XBO and UBO');
end;

procedure TGLBufferObjectHandle.BindBase(index: Cardinal);
begin
  Assert(False, 'BindRange only XBO and UBO');
end;

procedure TGLBufferObjectHandle.UnBindBase(index: Cardinal);
begin
  Assert(False, 'BindRange only XBO and UBO');
end;

procedure TGLBufferObjectHandle.BufferData(p: Pointer; size: Integer;
  bufferUsage: Cardinal);
begin
  FSize := size;
  GL.BufferData(Target, size, p, bufferUsage);
end;

procedure TGLBufferObjectHandle.BindBufferData(p: Pointer; size: Integer;
  bufferUsage: Cardinal);
begin
  Bind;
  FSize := size;
  GL.BufferData(Target, size, p, bufferUsage);
end;

procedure TGLBufferObjectHandle.BufferSubData(offset, size: Integer; p:
  Pointer);
begin
  Assert(offset + size <= FSize);
  GL.BufferSubData(Target, offset, size, p);
end;

function TGLBufferObjectHandle.MapBuffer(access: Cardinal): Pointer;
begin
  Result := GL.MapBuffer(Target, access);
end;

function TGLBufferObjectHandle.MapBufferRange(offset: TGLint; len: TGLsizei;
  access: TGLbitfield): Pointer;
begin
  Result := GL.MapBufferRange(Target, offset, len, access);
end;

procedure TGLBufferObjectHandle.Flush(offset: TGLint; len: TGLsizei);
begin
  GL.FlushMappedBufferRange(Target, offset, len);
end;

function TGLBufferObjectHandle.UnmapBuffer: Boolean;
begin
  Result := GL.UnmapBuffer(Target);
end;

// ------------------
// ------------------ TGLVBOHandle ------------------
// ------------------

function TGLVBOHandle.GetVBOTarget: Cardinal;
begin
  Result := Target;
end;

// ------------------
// ------------------ TGLVBOArrayBufferHandle ------------------
// ------------------

procedure TGLVBOArrayBufferHandle.Bind;
begin
  vCurrentGLContext.GLStates.ArrayBufferBinding := Handle;
end;

procedure TGLVBOArrayBufferHandle.UnBind;
begin
  vCurrentGLContext.GLStates.ArrayBufferBinding := 0;
end;

function TGLVBOArrayBufferHandle.GetTarget: Cardinal;
begin
  Result := GL_ARRAY_BUFFER;
end;

// ------------------
// ------------------ TGLVBOElementArrayHandle ------------------
// ------------------

procedure TGLVBOElementArrayHandle.Bind;
begin
  vCurrentGLContext.GLStates.ElementBufferBinding := Handle;
end;

procedure TGLVBOElementArrayHandle.UnBind;
begin
  vCurrentGLContext.GLStates.ElementBufferBinding := 0;
end;

function TGLVBOElementArrayHandle.GetTarget: Cardinal;
begin
  Result := GL_ELEMENT_ARRAY_BUFFER;
end;

// ------------------
// ------------------ TGLPackPBOHandle ------------------
// ------------------

procedure TGLPackPBOHandle.Bind;
begin
  vCurrentGLContext.GLStates.PixelPackBufferBinding := Handle;
end;

procedure TGLPackPBOHandle.UnBind;
begin
  vCurrentGLContext.GLStates.PixelPackBufferBinding := 0;
end;

function TGLPackPBOHandle.GetTarget: Cardinal;
begin
  Result := GL_PIXEL_PACK_BUFFER;
end;

class function TGLPackPBOHandle.IsSupported: Boolean;
begin
  Result := GL.ARB_pixel_buffer_object;
end;

// ------------------
// ------------------ TGLUnpackPBOHandle ------------------
// ------------------

procedure TGLUnpackPBOHandle.Bind;
begin
  vCurrentGLContext.GLStates.PixelUnpackBufferBinding := Handle;
end;

procedure TGLUnpackPBOHandle.UnBind;
begin
  vCurrentGLContext.GLStates.PixelUnpackBufferBinding := 0;
end;

// GetTarget
//

function TGLUnpackPBOHandle.GetTarget: Cardinal;
begin
  Result := GL_PIXEL_UNPACK_BUFFER;
end;

class function TGLUnpackPBOHandle.IsSupported: Boolean;
begin
  Result := GL.ARB_pixel_buffer_object;
end;

// ------------------
// ------------------ TGLTransformFeedbackBufferHandle ------------------
// ------------------

procedure TGLTransformFeedbackBufferHandle.Bind;
begin
  vCurrentGLContext.GLStates.TransformFeedbackBufferBinding := Handle;
end;

procedure TGLTransformFeedbackBufferHandle.UnBind;
begin
  vCurrentGLContext.GLStates.TransformFeedbackBufferBinding := 0;
end;

function TGLTransformFeedbackBufferHandle.GetTarget: Cardinal;
begin
  Result := GL_TRANSFORM_FEEDBACK_BUFFER;
end;

// BeginTransformFeedback
//

procedure TGLTransformFeedbackBufferHandle.BeginTransformFeedback(primitiveMode:
  Cardinal);
begin
  GL.BeginTransformFeedback(primitiveMode);
end;

// EndTransformFeedback
//

procedure TGLTransformFeedbackBufferHandle.EndTransformFeedback();
begin
  GL.EndTransformFeedback();
end;

procedure TGLTransformFeedbackBufferHandle.BindRange(index: Cardinal; offset: TGLintptr;
  size: TGLsizeiptr);
begin
  vCurrentGLContext.GLStates.SetBufferIndexedBinding(Handle, bbtTransformFeedBack,
    index, offset, size);
end;

procedure TGLTransformFeedbackBufferHandle.BindBase(index: Cardinal);
begin
  vCurrentGLContext.GLStates.SetBufferIndexedBinding(Handle, bbtTransformFeedBack,
    index, BufferSize);
end;

procedure TGLTransformFeedbackBufferHandle.UnBindBase(index: Cardinal);
begin
  vCurrentGLContext.GLStates.SetBufferIndexedBinding(0, bbtTransformFeedBack,
    index, 0);
end;

class function TGLTransformFeedbackBufferHandle.IsSupported: Boolean;
begin
  Result := GL.EXT_transform_feedback or GL.VERSION_3_0;
end;

// ------------------
// ------------------ TGLTextureBufferHandle ------------------
// ------------------

procedure TGLTextureBufferHandle.Bind;
begin
  vCurrentGLContext.GLStates.TextureBufferBinding := Handle;
end;

procedure TGLTextureBufferHandle.UnBind;
begin
  vCurrentGLContext.GLStates.TextureBufferBinding := 0;
end;

// GetTarget
//

function TGLTextureBufferHandle.GetTarget: Cardinal;
begin
  Result := GL_TEXTURE_BUFFER;
end;

// IsSupported
//

class function TGLTextureBufferHandle.IsSupported: Boolean;
begin
  Result := GL.EXT_texture_buffer_object or GL.ARB_texture_buffer_object or
    GL.VERSION_3_1;
end;

// ------------------
// ------------------ TGLUniformBufferHandle ------------------
// ------------------

procedure TGLUniformBufferHandle.Bind;
begin
  vCurrentGLContext.GLStates.UniformBufferBinding := Handle;
end;

procedure TGLUniformBufferHandle.UnBind;
begin
  vCurrentGLContext.GLStates.UniformBufferBinding := 0;
end;

procedure TGLUniformBufferHandle.BindRange(index: Cardinal; offset: TGLintptr;
  size: TGLsizeiptr);
begin
  vCurrentGLContext.GLStates.SetBufferIndexedBinding(Handle, bbtUniform,
    index, offset, size);
end;

procedure TGLUniformBufferHandle.BindBase(index: Cardinal);
begin
  vCurrentGLContext.GLStates.SetBufferIndexedBinding(Handle, bbtUniform,
    index, BufferSize);
end;

procedure TGLUniformBufferHandle.UnBindBase(index: Cardinal);
begin
  vCurrentGLContext.GLStates.SetBufferIndexedBinding(0, bbtUniform,
    index, 0);
end;

function TGLUniformBufferHandle.GetTarget: Cardinal;
begin
  Result := GL_UNIFORM_BUFFER;
end;

class function TGLUniformBufferHandle.IsSupported: Boolean;
begin
  Result := GL.ARB_uniform_buffer_object;
end;

// ------------------
// ------------------ TGLVertexArrayHandle ------------------
// ------------------

function TGLVertexArrayHandle.DoAllocateHandle: Cardinal;
begin
  Result := 0;
  GL.GenVertexArrays(1, @Result);
end;

procedure TGLVertexArrayHandle.DoDestroyHandle(var AHandle: Cardinal);
begin
  if not vContextActivationFailureOccurred then
  with GL do
  begin
    // reset error status
    GetError;
    // delete
    DeleteVertexArrays(1, @AHandle);
    // check for error
    CheckError;
  end;
end;

class function TGLVertexArrayHandle.IsValid(const ID: Cardinal): Boolean;
begin
  Result := GL.IsVertexArray(ID);
end;

procedure TGLVertexArrayHandle.Bind;
begin
  Assert(vCurrentGLContext <> nil);
  vCurrentGLContext.GLStates.VertexArrayBinding := Handle;
end;

procedure TGLVertexArrayHandle.UnBind;
begin
  Assert(vCurrentGLContext <> nil);
  vCurrentGLContext.GLStates.VertexArrayBinding := 0;
end;

class function TGLVertexArrayHandle.IsSupported: Boolean;
begin
  Result := GL.ARB_vertex_array_object;
end;

class function TGLVertexArrayHandle.Transferable: Boolean;
begin
  Result := False;
end;

// ------------------
// ------------------ TGLFramebufferHandle ------------------
// ------------------

function TGLFramebufferHandle.DoAllocateHandle: Cardinal;
begin
  Result := 0;
  GL.GenFramebuffers(1, @Result)
end;

procedure TGLFramebufferHandle.DoDestroyHandle(var AHandle: Cardinal);
begin
  if not vContextActivationFailureOccurred then
  with GL do
  begin
    // reset error status
    GetError;
    // delete
    DeleteFramebuffers(1, @AHandle);
    // check for error
    CheckError;
  end;
end;

class function TGLFramebufferHandle.IsValid(const ID: Cardinal): Boolean;
begin
  Result := GL.IsFramebuffer(ID);
end;

procedure TGLFramebufferHandle.Bind;
begin
  Assert(vCurrentGLContext <> nil);
  vCurrentGLContext.GLStates.SetFrameBuffer(Handle);
end;

procedure TGLFramebufferHandle.BindForDrawing;
begin
  Assert(vCurrentGLContext <> nil);
  vCurrentGLContext.GLStates.DrawFrameBuffer := Handle;
end;

procedure TGLFramebufferHandle.BindForReading;
begin
  Assert(vCurrentGLContext <> nil);
  vCurrentGLContext.GLStates.ReadFrameBuffer := Handle;
end;

procedure TGLFramebufferHandle.UnBind;
begin
  Assert(vCurrentGLContext <> nil);
  vCurrentGLContext.GLStates.SetFrameBuffer(0);
end;

procedure TGLFramebufferHandle.UnBindForDrawing;
begin
  Assert(vCurrentGLContext <> nil);
  vCurrentGLContext.GLStates.DrawFrameBuffer := 0;
end;

procedure TGLFramebufferHandle.UnBindForReading;
begin
  Assert(vCurrentGLContext <> nil);
  vCurrentGLContext.GLStates.ReadFrameBuffer := 0;
end;

procedure TGLFramebufferHandle.Attach1DTexture(target: Cardinal; attachment:
  Cardinal; textarget: Cardinal; texture: Cardinal; level: TGLint);
begin
  GL.FramebufferTexture1D(target, attachment, textarget, texture, level);
end;

procedure TGLFramebufferHandle.Attach2DTexture(target: Cardinal; attachment:
  Cardinal; textarget: Cardinal; texture: Cardinal; level: TGLint);
begin
  GL.FramebufferTexture2D(target, attachment, textarget, texture, level);
end;

procedure TGLFramebufferHandle.Attach3DTexture(target: Cardinal; attachment:
  Cardinal; textarget: Cardinal; texture: Cardinal; level: TGLint; layer: TGLint);
begin
  GL.FramebufferTexture3D(target, attachment, textarget, texture, level, layer);
end;

procedure TGLFramebufferHandle.AttachLayer(target: Cardinal; attachment: Cardinal;
  texture: Cardinal; level: TGLint; layer: TGLint);
begin
  GL.FramebufferTextureLayer(target, attachment, texture, level, layer);
end;

procedure TGLFramebufferHandle.AttachRenderBuffer(target: Cardinal; attachment:
  Cardinal; renderbuffertarget: Cardinal; renderbuffer: Cardinal);
begin
  GL.FramebufferRenderbuffer(target, attachment, renderbuffertarget,
    renderbuffer);
end;

procedure TGLFramebufferHandle.AttachTexture(target: Cardinal; attachment:
  Cardinal; texture: Cardinal; level: TGLint);
begin
  GL.FramebufferTexture(target, attachment, texture, level);
end;

procedure TGLFramebufferHandle.AttachTextureLayer(target: Cardinal; attachment:
  Cardinal; texture: Cardinal; level: TGLint; layer: TGLint);
begin
  GL.FramebufferTextureLayer(target, attachment, texture, level, layer);
end;

procedure TGLFramebufferHandle.Blit(srcX0: TGLint; srcY0: TGLint; srcX1: TGLint;
  srcY1: TGLint;
  dstX0: TGLint; dstY0: TGLint; dstX1: TGLint; dstY1: TGLint;
  mask: TGLbitfield; filter: Cardinal);
begin
  GL.BlitFramebuffer(srcX0, srcY0, srcX1, srcY1, dstX0, dstY0, dstX1, dstY1,
    mask, filter);
end;

function TGLFramebufferHandle.GetAttachmentParameter(target: Cardinal;
  attachment: Cardinal; pname: Cardinal): TGLint;
begin
  GL.GetFramebufferAttachmentParameteriv(target, attachment, pname, @Result)
end;

function TGLFramebufferHandle.GetAttachmentObjectType(target: Cardinal;
  attachment: Cardinal): TGLint;
begin
  GL.GetFramebufferAttachmentParameteriv(target, attachment,
    GL_FRAMEBUFFER_ATTACHMENT_OBJECT_TYPE, @Result);
end;

function TGLFramebufferHandle.GetAttachmentObjectName(target: Cardinal;
  attachment: Cardinal): TGLint;
begin
  GL.GetFramebufferAttachmentParameteriv(target, attachment,
    GL_FRAMEBUFFER_ATTACHMENT_OBJECT_NAME, @Result);
end;

function TGLFramebufferHandle.GetStatus: TGLFramebufferStatus;
var
  Status: cardinal;
begin
  Status := GL.CheckFramebufferStatus(GL_FRAMEBUFFER);

  case Status of
    GL_FRAMEBUFFER_COMPLETE_EXT: Result := fsComplete;
    GL_FRAMEBUFFER_INCOMPLETE_ATTACHMENT_EXT: Result := fsIncompleteAttachment;
    GL_FRAMEBUFFER_INCOMPLETE_MISSING_ATTACHMENT_EXT: Result :=
      fsIncompleteMissingAttachment;
    GL_FRAMEBUFFER_INCOMPLETE_DUPLICATE_ATTACHMENT_EXT: Result :=
      fsIncompleteDuplicateAttachment;
    GL_FRAMEBUFFER_INCOMPLETE_DIMENSIONS_EXT: Result := fsIncompleteDimensions;
    GL_FRAMEBUFFER_INCOMPLETE_FORMATS_EXT: Result := fsIncompleteFormats;
    GL_FRAMEBUFFER_INCOMPLETE_DRAW_BUFFER_EXT: Result := fsIncompleteDrawBuffer;
    GL_FRAMEBUFFER_INCOMPLETE_READ_BUFFER_EXT: Result := fsIncompleteReadBuffer;
    GL_FRAMEBUFFER_UNSUPPORTED_EXT: Result := fsUnsupported;
    GL_FRAMEBUFFER_INCOMPLETE_MULTISAMPLE: Result := fsIncompleteMultisample;
  else
    Result := fsStatusError;
  end;
end;

function TGLFramebufferHandle.GetStringStatus(out clarification: string):
  TGLFramebufferStatus;
const
  cFBOStatus: array[TGLFramebufferStatus] of string = (
    'Complete',
    'Incomplete attachment',
    'Incomplete missing attachment',
    'Incomplete duplicate attachment',
    'Incomplete dimensions',
    'Incomplete formats',
    'Incomplete draw buffer',
    'Incomplete read buffer',
    'Unsupported',
    'Incomplite multisample',
    'Status Error');
begin
  Result := GetStatus;
  clarification := cFBOStatus[Result];
end;

class function TGLFramebufferHandle.IsSupported: Boolean;
begin
  Result := GL.EXT_framebuffer_object or GL.ARB_framebuffer_object;
end;

class function TGLFramebufferHandle.Transferable: Boolean;
begin
  Result := False;
end;

// ------------------
// ------------------ TGLRenderbufferObject ------------------
// ------------------

function TGLRenderbufferHandle.DoAllocateHandle: Cardinal;
begin
  Result := 0;
  GL.GenRenderbuffers(1, @Result);
end;

procedure TGLRenderbufferHandle.DoDestroyHandle(var AHandle: Cardinal);
begin
  if not vContextActivationFailureOccurred then
  with GL do
  begin
    // reset error status
    GetError;
    // delete
    DeleteRenderbuffers(1, @AHandle);
    // check for error
    CheckError;
  end;
end;

class function TGLRenderbufferHandle.IsValid(const ID: Cardinal): Boolean;
begin
  Result := GL.IsRenderbuffer(ID);
end;

procedure TGLRenderbufferHandle.Bind;
begin
  vCurrentGLContext.GLStates.RenderBuffer := GetHandle;
end;

procedure TGLRenderbufferHandle.UnBind;
begin
  if vCurrentGLContext <> nil then
    vCurrentGLContext.GLStates.RenderBuffer := 0;
end;

procedure TGLRenderbufferHandle.SetStorage(internalformat: Cardinal; width,
  height: TGLsizei);
begin
  GL.RenderbufferStorage(GL_RENDERBUFFER, internalformat, width, height);
end;

procedure TGLRenderbufferHandle.SetStorageMultisample(internalformat: Cardinal;
  samples: TGLsizei; width, height: TGLsizei);
begin
  GL.RenderbufferStorageMultisample(GL_RENDERBUFFER, samples, internalformat,
    width, height);
end;

class function TGLRenderbufferHandle.IsSupported: Boolean;
begin
  Result := GL.EXT_framebuffer_object or GL.ARB_framebuffer_object;
end;

// ------------------
// ------------------ TGLARBProgramHandle ------------------
// ------------------

function TGLARBProgramHandle.DoAllocateHandle: Cardinal;
begin
  Result := 0;
  GL.GenPrograms(1, @Result);
  FReady := False;
end;

procedure TGLARBProgramHandle.DoDestroyHandle(var AHandle: Cardinal);
begin
  if not vContextActivationFailureOccurred then
  with GL do
  begin
    // reset error status
    GetError;
    // delete
    DeletePrograms(1, @AHandle);
    // check for error
    CheckError;
  end;
end;

class function TGLARBProgramHandle.IsValid(const ID: Cardinal): Boolean;
begin
  Result := GL.IsProgram(ID);
end;

procedure TGLARBProgramHandle.LoadARBProgram(const AText: string);
const
  cProgType: array[0..2] of string =
    ('ARB vertex', 'ARB fragment', 'NV geometry');
var
  errPos, P: Integer;
begin
  Bind;
  GL.ProgramString(GetTarget, GL_PROGRAM_FORMAT_ASCII_ARB,
    Length(AText), PAnsiChar(AnsiString(AText)));
  GL.GetIntegerv(GL_PROGRAM_ERROR_POSITION_ARB, @errPos);
  if errPos > -1 then
  begin
    FInfoLog := string(GL.GetString(GL_PROGRAM_ERROR_STRING_ARB));
    case GetTarget of
      GL_VERTEX_PROGRAM_ARB: P := 0;
      GL_FRAGMENT_PROGRAM_ARB: P := 1;
    else
      P := 2;
    end;
    GLSLogger.LogError(Format('%s Program Error - [Pos: %d][Error %s]', [cProgType[P], errPos, FInfoLog]));
    FReady := False;
  end
  else
  begin
    FReady := True;
    FInfoLog := '';
  end;
end;

procedure TGLARBProgramHandle.Enable;
begin
  if FReady then
    GL.Enable(GetTarget)
  else
    Abort;
end;

procedure TGLARBProgramHandle.Disable;
begin
  GL.Disable(GetTarget);
end;

procedure TGLARBProgramHandle.Bind;
begin
  GL.BindProgram(GetTarget, Handle);
end;

class function TGLARBVertexProgramHandle.GetTarget: Cardinal;
begin
  Result := GL_VERTEX_PROGRAM_ARB;
end;

class function TGLARBVertexProgramHandle.IsSupported: Boolean;
begin
  Result := GL.ARB_vertex_program;
end;

class function TGLARBFragmentProgramHandle.GetTarget: Cardinal;
begin
  Result := GL_FRAGMENT_PROGRAM_ARB;
end;

class function TGLARBFragmentProgramHandle.IsSupported: Boolean;
begin
  Result := GL.ARB_vertex_program;
end;

class function TGLARBGeometryProgramHandle.GetTarget: Cardinal;
begin
  Result := GL_GEOMETRY_PROGRAM_NV;
end;

class function TGLARBGeometryProgramHandle.IsSupported: Boolean;
begin
  Result := GL.NV_geometry_program4;
end;

// ------------------
// ------------------ TGLSLHandle ------------------
// ------------------

procedure TGLSLHandle.DoDestroyHandle(var AHandle: Cardinal);
begin
  if not vContextActivationFailureOccurred then
  with GL do
  begin
    // reset error status
    ClearError;
    // delete
    DeleteObject(AHandle);
    // check for error
    CheckError;
  end;
end;

function TGLSLHandle.InfoLog: string;
var
  maxLength: Integer;
  log: AnsiString;
begin
  maxLength := 0;
  GL.GetObjectParameteriv(GetHandle, GL_OBJECT_INFO_LOG_LENGTH_ARB, @maxLength);
  SetLength(log, maxLength);
  if maxLength > 0 then
  begin
    GL.GetInfoLog(GetHandle, maxLength, @maxLength, @log[1]);
    SetLength(log, maxLength);
  end;
  Result := string(log);
end;

class function TGLSLHandle.IsSupported: Boolean;
begin
  Result := GL.ARB_shader_objects;
end;

// ------------------
// ------------------ TGLShaderHandle ------------------
// ------------------

function TGLShaderHandle.DoAllocateHandle: Cardinal;
begin
  Result := GL.CreateShader(FShaderType)
end;

class function TGLShaderHandle.IsValid(const ID: Cardinal): Boolean;
begin
  Result := GL.IsShader(ID);
end;

procedure TGLShaderHandle.ShaderSource(const source: AnsiString);
var
  p: PAnsiChar;
begin
  p := PAnsiChar(AnsiString(source));
  GL.ShaderSource(GetHandle, 1, @p, nil);
end;

function TGLShaderHandle.CompileShader: Boolean;
var
  compiled: Integer;
  glH: Cardinal;
begin
  glH := GetHandle;
  GL.CompileShader(glH);
  compiled := 0;
  GL.GetShaderiv(glH, GL_COMPILE_STATUS, @compiled);
  Result := (compiled <> 0);
end;

// ------------------
// ------------------ TGLVertexShaderHandle ------------------
// ------------------


constructor TGLVertexShaderHandle.Create;
begin
  FShaderType := GL_VERTEX_SHADER_ARB;
  inherited;
end;

class function TGLVertexShaderHandle.IsSupported: Boolean;
begin
  Result := GL.ARB_vertex_shader;
end;

// ------------------
// ------------------ TGLGeometryShaderHandle ------------------
// ------------------

constructor TGLGeometryShaderHandle.Create;
begin
  FShaderType := GL_GEOMETRY_SHADER_EXT;
  inherited;
end;

class function TGLGeometryShaderHandle.IsSupported: Boolean;
begin
  Result := GL.EXT_geometry_shader4;
end;

// ------------------
// ------------------ TGLFragmentShaderHandle ------------------
// ------------------

constructor TGLFragmentShaderHandle.Create;
begin
  FShaderType := GL_FRAGMENT_SHADER_ARB;
  inherited;
end;

class function TGLFragmentShaderHandle.IsSupported: Boolean;
begin
  Result := GL.ARB_fragment_shader;
end;

// ------------------
// ------------------ TGLTessControlShaderHandle ------------------
// ------------------

constructor TGLTessControlShaderHandle.Create;
begin
  FShaderType := GL_TESS_CONTROL_SHADER;
  inherited;
end;

class function TGLTessControlShaderHandle.IsSupported: Boolean;
begin
  Result := GL.ARB_tessellation_shader;
end;

// ------------------
// ------------------ TGLTessEvaluationShaderHandle ------------------
// ------------------

constructor TGLTessEvaluationShaderHandle.Create;
begin
  FShaderType := GL_TESS_EVALUATION_SHADER;
  inherited;
end;

class function TGLTessEvaluationShaderHandle.IsSupported: Boolean;
begin
  Result := GL.ARB_tessellation_shader;
end;

// ------------------
// ------------------ TGLProgramHandle ------------------
// ------------------

function TGLProgramHandle.DoAllocateHandle: cardinal;
begin
  Result := GL.CreateProgram();
end;

class function TGLProgramHandle.IsValid(const ID: Cardinal): Boolean;
begin
  Result := GL.IsProgram(ID);
end;

procedure TGLProgramHandle.AddShader(shaderType: TGLShaderHandleClass; const
  shaderSource: string;
  treatWarningsAsErrors: Boolean = False);
var
  shader: TGLShaderHandle;
begin
  shader := shaderType.CreateAndAllocate;
  try
    if shader.Handle = 0 then
      raise EGLShader.Create('Couldn''t allocate ' + shaderType.ClassName);
    shader.ShaderSource(AnsiString(shaderSource));
    if (not shader.CompileShader)
      or (treatWarningsAsErrors and (Pos('warning', LowerCase(shader.InfoLog)) >
      0)) then
      raise EGLShader.Create(FName + ' (' + shader.ClassName + '): '#13#10 +
        shader.InfoLog);
    AttachObject(shader);
  finally
    shader.Free;
  end;
  GL.CheckError;
end;

procedure TGLProgramHandle.AttachObject(shader: TGLShaderHandle);
begin
  GL.AttachShader(GetHandle, shader.Handle);
end;

procedure TGLProgramHandle.DetachAllObject;
var
  glH: Cardinal;
  I: Integer;
  count: TGLsizei;
  buffer: array[0..255] of Cardinal;
begin
  glH := GetHandle;
  if glH > 0 then
  begin
    GL.GetAttachedShaders(glH, Length(buffer), @count, @buffer[0]);
    count := MinInteger(count, Length(buffer));
    for I := 0 to count - 1 do
      GL.DetachShader(glH, buffer[I]);
    NotifyChangesOfData;
  end;
end;

procedure TGLProgramHandle.BindAttribLocation(index: Integer; const aName:
  string);
begin
  GL.BindAttribLocation(GetHandle, index, PAnsiChar(AnsiString(aName)));
end;

procedure TGLProgramHandle.BindFragDataLocation(index: Integer; const aName:
  string);
begin
  GL.BindFragDataLocation(GetHandle, index, PAnsiChar(AnsiString(name)));
end;

function TGLProgramHandle.LinkProgram: Boolean;
var
  status: Integer;
  glH: Cardinal;
begin
  glH := GetHandle;
  GL.LinkProgram(glH);
  status := 0;
  GL.GetProgramiv(glH, GL_LINK_STATUS, @status);
  Result := (status <> 0);
end;

function TGLProgramHandle.ValidateProgram: Boolean;
var
  validated: Integer;
  h: Cardinal;
begin
  h := GetHandle;
  GL.ValidateProgram(h);
  validated := 0;
  GL.GetProgramiv(h, GL_VALIDATE_STATUS, @validated);
  Result := (validated <> 0);
end;


function TGLProgramHandle.GetAttribLocation(const aName: string): Integer;
begin
  Result := GL.GetAttribLocation(GetHandle, PAnsiChar(AnsiString(aName)));
  Assert(Result >= 0, Format(strUnknownParam, ['attrib', aName, Name]));
end;


function TGLProgramHandle.GetUniformLocation(const aName: string): Integer;
begin
  Result := GL.GetUniformLocation(GetHandle, PAnsiChar(AnsiString(aName)));
  Assert(Result >= 0, Format(strUnknownParam, ['uniform', aName, Name]));
end;


function TGLProgramHandle.GetVaryingLocation(const aName: string): Integer;
begin
  Result := GL.GetVaryingLocation(GetHandle, PAnsiChar(AnsiString(aName)));
  Assert(Result >= 0, Format(strUnknownParam, ['varying', aName, Name]));
end;


procedure TGLProgramHandle.AddActiveVarying(const aName: string);
begin
  GL.ActiveVarying(GetHandle, PAnsiChar(AnsiString(aName)));
end;


procedure TGLProgramHandle.UseProgramObject;
begin
  Assert(vCurrentGLContext <> nil);
  vCurrentGLContext.GLStates.CurrentProgram := Handle;
end;


procedure TGLProgramHandle.EndUseProgramObject;
begin
  Assert(vCurrentGLContext <> nil);
  vCurrentGLContext.GLStates.CurrentProgram := 0;
end;


function TGLProgramHandle.GetUniform1i(const index: string): Integer;
begin
  GL.GetUniformiv(GetHandle, GetUniformLocation(index), @Result);
end;


function TGLProgramHandle.GetUniform2i(const index: string): TVector2i;
begin
  GL.GetUniformiv(GetHandle, GetUniformLocation(index), @Result);
end;


function TGLProgramHandle.GetUniform3i(const index: string): TVector3i;
begin
  GL.GetUniformiv(GetHandle, GetUniformLocation(index), @Result);
end;


function TGLProgramHandle.GetUniform4i(const index: string): TVector4i;
begin
  GL.GetUniformiv(GetHandle, GetUniformLocation(index), @Result);
end;


procedure TGLProgramHandle.SetUniform1f(const index: string; val: Single);
begin
  GL.Uniform1f(GetUniformLocation(index), val);
end;


function TGLProgramHandle.GetUniform1f(const index: string): Single;
begin
  GL.GetUniformfv(GetHandle, GetUniformLocation(index), @Result);
end;


procedure TGLProgramHandle.SetUniform1i(const index: string; val: Integer);
begin
  GL.Uniform1i(GetUniformLocation(index), val);
end;


procedure TGLProgramHandle.SetUniform2i(const index: string;
  const Value: TVector2i);
begin
  GL.Uniform2i(GetUniformLocation(index), Value.X, Value.Y);
end;


procedure TGLProgramHandle.SetUniform3i(const index: string;
  const Value: TVector3i);
begin
  GL.Uniform3i(GetUniformLocation(index), Value.X, Value.Y, Value.Z);
end;


procedure TGLProgramHandle.SetUniform4i(const index: string;
  const Value: TVector4i);
begin
  GL.Uniform4i(GetUniformLocation(index), Value.X, Value.Y, Value.Z,
    Value.W);
end;


function TGLProgramHandle.GetUniform2f(const index: string): TVector2f;
begin
  GL.GetUniformfv(GetHandle, GetUniformLocation(index), @Result);
end;


procedure TGLProgramHandle.SetUniform2f(const index: string; const val:
  TVector2f);
begin
  GL.Uniform2f(GetUniformLocation(index), val.X, val.Y);
end;


function TGLProgramHandle.GetUniform3f(const index: string): TAffineVector;
begin
  GL.GetUniformfv(GetHandle, GetUniformLocation(index), @Result);
end;


procedure TGLProgramHandle.SetUniform3f(const index: string; const val:
  TAffineVector);
begin
  GL.Uniform3f(GetUniformLocation(index), val.X, val.Y, val.Z);
end;


function TGLProgramHandle.GetUniform4f(const index: string): TVector;
begin
  GL.GetUniformfv(GetHandle, GetUniformLocation(index), @Result);
end;


procedure TGLProgramHandle.SetUniform4f(const index: string; const val:
  TVector);
begin
  GL.Uniform4f(GetUniformLocation(index), val.X, val.Y, val.Z, val.W);
end;


function TGLProgramHandle.GetUniformMatrix2fv(const index: string): TMatrix2f;
begin
  GL.GetUniformfv(GetHandle, GetUniformLocation(index), @Result);
end;


procedure TGLProgramHandle.SetUniformMatrix2fv(const index: string; const val:
  TMatrix2f);
begin
  GL.UniformMatrix2fv(GetUniformLocation(index), 1, False, @val);
end;


function TGLProgramHandle.GetUniformMatrix3fv(const index: string): TMatrix3f;
begin
  GL.GetUniformfv(GetHandle, GetUniformLocation(index), @Result);
end;


procedure TGLProgramHandle.SetUniformMatrix3fv(const index: string; const val:
  TMatrix3f);
begin
  GL.UniformMatrix3fv(GetUniformLocation(index), 1, False, @val);
end;


function TGLProgramHandle.GetUniformMatrix4fv(const index: string): TMatrix;
begin
  GL.GetUniformfv(GetHandle, GetUniformLocation(index), @Result);
end;


procedure TGLProgramHandle.SetUniformMatrix4fv(const index: string; const val:
  TMatrix);
begin
  GL.UniformMatrix4fv(GetUniformLocation(index), 1, False, @val);
end;


procedure TGLProgramHandle.SetUniformf(const index: string;
  const val: single);
begin
  SetUniform1f(index, val);
end;


procedure TGLProgramHandle.SetUniformf(const index: string; const val:
  TVector2f);
begin
  SetUniform2f(index, val);
end;


procedure TGLProgramHandle.SetUniformf(const index: string;
  const val: TVector3f);
begin
  SetUniform3f(index, val);
end;


procedure TGLProgramHandle.SetUniformf(const index: string;
  const val: TVector4f);
begin
  SetUniform4f(index, val);
end;


procedure TGLProgramHandle.SetUniformi(const index: string;
  const val: integer);
begin
  SetUniform1f(index, val);
end;


procedure TGLProgramHandle.SetUniformi(const index: string; const val:
  TVector2i);
begin
  SetUniform2i(index, val);
end;


procedure TGLProgramHandle.SetUniformi(const index: string;
  const val: TVector3i);
begin
  SetUniform3i(index, val);
end;


procedure TGLProgramHandle.SetUniformi(const index: string;
  const val: TVector4i);
begin
  SetUniform4i(index, val);
end;


function TGLProgramHandle.GetUniformTextureHandle(const index: string;
  const TextureIndex: Integer; const TextureTarget: TGLTextureTarget): Cardinal;
begin
  Result := GetUniform1i(index);
end;


procedure TGLProgramHandle.SetUniformTextureHandle(const index: string;
  const TextureIndex: Integer; const TextureTarget: TGLTextureTarget;
  const Value: Cardinal);
begin
  vCurrentGLContext.GLStates.TextureBinding[0, TextureTarget] := Value;
  SetUniform1i(index, TextureIndex);
end;


procedure TGLProgramHandle.SetUniformBuffer(const index: string;
  Value: TGLUniformBufferHandle);
begin
  GL.UniformBuffer(Handle, GetUniformLocation(index), Value.Handle);
end;


function TGLProgramHandle.GetUniformBufferSize(const aName: string): Integer;
begin
  Result := GL.GetUniformBufferSize(Handle, GetUniformLocation(aName));
end;


function TGLProgramHandle.GetUniformOffset(const aName: string): PGLInt;
begin
  Result := GL.GetUniformOffset(Handle, GetUniformLocation(aName));
end;


function TGLProgramHandle.GetUniformBlockIndex(const aName: string): Integer;
begin
  Result := GL.GetUniformBlockIndex(Handle, PAnsiChar(AnsiString(aName)));
  Assert(Result >= 0, Format(strUnknownParam, ['uniform block', aName, Name]));
end;

constructor TGLProgramHandle.Create;
begin
  inherited Create;
  FName := 'DefaultShaderName';
end;

// ------------------
// ------------------ TGLContextManager ------------------
// ------------------

{$IFDEF USE_SERVICE_CONTEXT}
procedure OnApplicationInitialize;
begin
  InitProc := OldInitProc;
  Application.Initialize;
  GLContextManager.CreateServiceContext;
end;
{$ENDIF}


constructor TGLContextManager.Create;
begin
  inherited Create;
{$IFNDEF USE_MULTITHREAD}
  FHandles := TList.Create;
{$ELSE}
  FHandles := TThreadList.Create;
{$ENDIF USE_MULTITHREAD}
  FList := TThreadList.Create;
end;


destructor TGLContextManager.Destroy;
begin
  FHandles.Free;
  FList.Free;
  inherited Destroy;
end;


function TGLContextManager.CreateContext(AClass: TGLContextClass): TGLContext;
begin
  if Assigned(AClass) then
  begin
    Result := AClass.Create;
    Result.FManager := Self;
  end
  else if Assigned(vContextClasses) and (vContextClasses.Count > 0) then
  begin
    Result := TGLContextClass(vContextClasses.Last).Create;
    Result.FManager := Self;
  end
  else
    Result := nil;
end;

{$IFDEF USE_SERVICE_CONTEXT}

procedure TGLContextManager.CreateServiceContext;
begin
  FServiceContext := CreateContext;
  FThreadTask := TServiceContextTaskList.Create;
  FServiceStarter := TFinishTaskEvent.Create;
  FThread := TServiceContextThread.Create;
  AddTaskForServiceContext(TServiceContextThread(FThread).DoCreateServiceContext);
end;

procedure TGLContextManager.QueueTaskDepleted;
var
  TaskRec: TServiceContextTask;
  I: Integer;
  nowTime: Double;
begin
  with FThreadTask.LockList do
    try
      for I := 0 to Count - 1 do
      begin
        TaskRec := Items[I];
        if Assigned(TaskRec.Task) then
        begin
          FThreadTask.UnlockList;
          // Task queue not empty
          FServiceStarter.SetEvent;
          exit;
        end;
      end;
    finally
      FThreadTask.UnlockList;
    end;

  FServiceStarter.ResetEvent;
  FThreadTask.Clear;
  nowTime := GLSTime;
  with TServiceContextThread(FThread) do
  if (nowTime - FLastTaskStartTime > 30000)
    and not FReported then
  begin
    FReported := True;
    GLSLogger.LogInfo('Service context queue task depleted');
  end;
end;

{$ENDIF USE_SERVICE_CONTEXT}


procedure TGLContextManager.Lock;
begin
  FList.LockList;
end;

procedure TGLContextManager.NotifyPreparationNeed;
var
  I: Integer;
  LList: TList;
begin
  LList := FList.LockList;
  try
    for I := LList.Count - 1 downto 0 do
      TGLContext(LList[I]).FIsPraparationNeed := True;
  finally
    FList.UnlockList;
  end;
end;

procedure TGLContextManager.UnLock;
begin
  FList.UnlockList;
end;

function TGLContextManager.ContextCount: Integer;
begin
  // try..finally just a waste of CPU here, if Count fails, the list is amok,
  // and so is the lock...
  Result := FList.LockList.Count;
  FList.UnLockList;
end;


procedure TGLContextManager.RegisterContext(aContext: TGLContext);
begin
  with FList.LockList do
    try
      if IndexOf(aContext) >= 0 then
        raise EGLContext.Create(strInvalidContextRegistration)
      else
        Add(aContext);
    finally
      FList.UnlockList;
    end;
end;


procedure TGLContextManager.UnRegisterContext(aContext: TGLContext);
begin
  with FList.LockList do
    try
      if IndexOf(aContext) < 0 then
        raise EGLContext.Create(strInvalidContextRegistration)
      else
        Remove(aContext);
    finally
      FList.UnlockList;
    end;
end;


procedure TGLContextManager.ContextCreatedBy(aContext: TGLContext);
begin
  Lock;
  try
    Inc(FCreatedRCCount);
  finally
    UnLock;
  end;
end;


procedure TGLContextManager.DestroyingContextBy(aContext: TGLContext);
var
  cn: TGLContextNotification;
begin
  Lock;
  try
    Dec(FCreatedRCCount);
    if FCreatedRCCount = 0 then
    begin
      // yes, slow and bulky, but allows for the triggered event to
      // cascade-remove notifications safely
      while Length(FNotifications) > 0 do
      begin
        cn := FNotifications[High(FNotifications)];
        SetLength(FNotifications, Length(FNotifications) - 1);
        cn.event(cn.obj);
      end;
    end;
  finally
    UnLock;
  end;
end;


procedure TGLContextManager.LastContextDestroyNotification(
  anObject: TObject; anEvent: TNotifyEvent);
begin
  Lock;
  try
    SetLength(FNotifications, Length(FNotifications) + 1);
    with FNotifications[High(FNotifications)] do
    begin
      obj := anObject;
      event := anEvent;
    end;
  finally
    UnLock;
  end;
end;


procedure TGLContextManager.RemoveNotification(anObject: TObject);
var
  i: Integer;
  found: Boolean;
begin
  Lock;
  try
    found := False;
    i := Low(FNotifications);
    while i <= High(FNotifications) do
    begin
      if FNotifications[i].obj = anObject then
      begin
        found := True;
        while i <= High(FNotifications) do
        begin
          FNotifications[i] := FNotifications[i + 1];
          Inc(i);
        end;
        SetLength(FNotifications, Length(FNotifications) - 1);
        Break;
      end;
      Inc(i);
    end;
    if not found then
      raise EGLContext.Create(strInvalidNotificationRemoval);
  finally
    UnLock;
  end;
end;


procedure TGLContextManager.Terminate;
begin
  FTerminated := True;
{$IFDEF USE_SERVICE_CONTEXT}
  // Sevice context may not be created becouse Application.Initialize not happened
  if Assigned(FServiceContext) then
  begin
    CheckSynchronize;
    FThread.Terminate;
    FServiceStarter.SetEvent;
    FThread.WaitFor;
    FThread.Destroy;
    GLSLogger.LogDebug('Service thread destroyed');
    FServiceStarter.Destroy;
    FThreadTask.Destroy;
  end;
{$ENDIF}
  if ContextCount = 0 then
  begin
    GLContextManager := nil;
    Free;
  end;
end;

procedure TGLContextManager.DestroyAllHandles;
var
  i: Integer;
begin
  with FList.LockList do
    try
      for i := Count - 1 downto 0 do
        TGLContext(Items[i]).DestroyAllHandles;
    finally
      FList.UnLockList;
    end;
end;

{$IFDEF USE_SERVICE_CONTEXT}

constructor TServiceContextThread.Create;
begin
  FWindow := TForm.CreateNew(nil);
  FWindow.Hide;
  FWindow.Position := poScreenCenter;
  FWindow.Width := 1;
  FWindow.Height := 1;
  FWindow.BorderStyle := bsNone;
  FWindow.FormStyle := fsStayOnTop;
  FWindow.Color := 0;
  vServiceWindow := FWindow;
{$IFDEF MSWINDOWS}
  FDC := GetDC(FWindow.Handle);
{$ENDIF}
{$IFDEF LINUX}
  FDC := FWindow.Handle;
{$ENDIF}
  inherited Create(False);
end;

destructor TServiceContextThread.Destroy;
begin
  ReleaseDC(FWindow.Handle, FDC);
  FWindow.Free;
  inherited;
end;

procedure TServiceContextThread.DoCreateServiceContext; stdcall;

  procedure Fail;
  begin
    GLSLogger.LogError(Format('%s: can''t initialize rendering context', [ClassName]));
    FWindow.Destroy;
    vServiceWindow := nil;
  end;

begin
  try
    GLContextManager.ServiceContext.Acceleration := chaHardware;
    GLContextManager.ServiceContext.CreateMemoryContext(FDC, 1, 1, 1);
  except
    on EGLContext do
    begin
      Fail;
      exit;
    end;
    on EPBuffer do
    begin
      GLSLogger.LogWarning(Format('%s: can''t initialize memory rendering context. Try initialize common context.', [ClassName]));
      try
        GLContextManager.ServiceContext.CreateContext(FDC);
      except
        Fail;
        exit;
      end;
    end;
  end;
  GLSLogger.LogNotice('Service context successfuly initialized');
  GLContextManager.ServiceContext.Activate;
  FWindow.Hide;
  vServiceWindow := nil;
end;

procedure TServiceContextThread.Execute;
var
  TaskRec: TServiceContextTask;

  procedure NextTask;
  const
    NullTask: TServiceContextTask = (Task: nil; Event: nil);
  var
    I: Integer;
  begin
    TaskRec.Task := nil;
    with GLContextManager.FThreadTask.LockList do
      try
        for I := 0 to Count - 1 do
        begin
          TaskRec := Items[I];
          if Assigned(TaskRec.Task) then
          begin
            Items[I] := NullTask;
            break;
          end;
        end;
      finally
        GLContextManager.FThreadTask.UnlockList;
      end;
  end;

begin
  with GLContextManager do
  begin
    vMainThread := False;
    GLSLogger.LogNotice('Service thread started');
    Sleep(100);
    try
      while not Terminated do
      begin
        NextTask;
        if Assigned(TaskRec.Task) then
        begin
          with GLContextManager.ServiceContext do
          begin
            if IsValid then
              Activate;
            try
              TaskRec.Task;
            except
              GLSLogger.LogError('Service thread task raised exception');
            end;
            if IsValid then
              Deactivate;
            if Assigned(TaskRec.Event) then
              TaskRec.Event.SetEvent;
          end;
         end
        else
          Synchronize(GLContextManager.QueueTaskDepleted);
        ServiceStarter.WaitFor(30000);
      end;
    finally
      ServiceContext.Destroy;
      FServiceContext := nil;
      GLSLogger.LogNotice('Service thread finished');
    end;
  end;
end;

procedure AddTaskForServiceContext(ATask: TTaskProcedure; FinishEvent: TFinishTaskEvent = nil);
var
  TaskRec: TServiceContextTask;
  rEvent: TFinishTaskEvent;
begin
  if vMainThread then
  begin
    rEvent := nil;
    if Assigned(GLContextManager.ServiceContext) and Assigned(ATask) then
    begin
      CheckSynchronize;
      with GLContextManager.FThreadTask.LockList do
        try
          TaskRec.Task := ATask;
          if FinishEvent = nil then
          begin // Synchronous call
            rEvent := TFinishTaskEvent.Create;
            TaskRec.Event := rEvent;
          end
          else  // Asynchronous call
            TaskRec.Event := FinishEvent;
          Add(TaskRec);
          with TServiceContextThread(GLContextManager.FThread) do
          begin
            FLastTaskStartTime := GLSTime;
            FReported := False;
          end;
        finally
          GLContextManager.FThreadTask.UnlockList;
        end;
      GLContextManager.ServiceStarter.SetEvent;
    end;
    // Wait task finishing
    if Assigned(rEvent) then
    begin
      rEvent.WaitFor(INFINITE);
      rEvent.Destroy;
      CheckSynchronize;
    end;
  end
  else
  begin // Direct task execution in service thread
    try
      ATask;
    except
      GLSLogger.LogError('Service thread task raised exception');
    end;
    if Assigned(FinishEvent) then
      FinishEvent.SetEvent;
  end;
end;

{$ENDIF USE_SERVICE_CONTEXT}

constructor TFinishTaskEvent.Create;
begin
  inherited Create(nil, True, False, '');
end;

// ------------------------------------------------------------------
initialization
// ------------------------------------------------------------------

  vMainThread := True;
{$IFDEF USE_SERVICE_CONTEXT}
  OldInitProc := InitProc;
  InitProc := @OnApplicationInitialize;
{$ENDIF USE_SERVICE_CONTEXT}
  GLContextManager := TGLContextManager.Create;
  GLwithoutContext := TGLExtensionsAndEntryPoints.Create;
  GLwithoutContext.Close;
  //vLocalGL := @GL;

finalization

  GLContextManager.Terminate;
  vContextClasses.Free;
  vContextClasses := nil;
  GLwithoutContext.Free;
  GLwithoutContext := nil;

end.

