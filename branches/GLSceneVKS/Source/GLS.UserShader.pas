//
// GLScene on Vulkan, http://glscene.sourceforge.net 
//
{
   A shader that passes control of the DoApply and DoUnApply
   methods through published events. This component is 
   designed to make it a little easier to implement a 
   customized shader. Be sure to keep the shader balanced
   by returning the OpenGL state to how you found it. 
               
}
unit GLS.UserShader;

interface

uses
  System.Classes, 
  //GLS
  GLS.Material, GLS.RenderContextInfo;

type
  TOnDoApplyEvent = procedure (Sender : TObject; var rci : TRenderContextInfo) of Object;
  TOnDoUnApplyEvent = procedure (Sender : TObject; Pass:Integer; var rci : TRenderContextInfo; var Continue : Boolean) of Object;
  
  TVKUserShader = class(TVKShader)
    private
      FPass : Integer;
      FOnDoApply : TOnDoApplyEvent;
      FOnDoUnApply : TOnDoUnApplyEvent;
    protected
      procedure DoApply(var rci : TRenderContextInfo; Sender : TObject); override;
      function DoUnApply(var rci : TRenderContextInfo) : Boolean; override;
    published
      property OnDoApply : TOnDoApplyEvent read FOnDoApply write FOnDoApply;
      property OnDoUnApply : TOnDoUnApplyEvent read FOnDoUnApply write FOnDoUnApply;
      property ShaderStyle;
  end;

// ------------------------------------------------------------------
// ------------------------------------------------------------------
// ------------------------------------------------------------------
implementation
// ------------------
// ------------------ TVKUserShader ------------------
// ------------------

// DoApply
//
procedure TVKUserShader.DoApply(var rci: TRenderContextInfo; Sender : TObject);
begin
  FPass:=1;
  if Assigned(FOnDoApply) and (not (csDesigning in ComponentState)) then
    FOnDoApply(Self,rci);
end;

// DoUnApply
//
function TVKUserShader.DoUnApply(var rci: TRenderContextInfo): Boolean;
begin
  Result:=False;
  if Assigned(FOnDoUnApply) and (not (csDesigning in ComponentState)) then begin
    FOnDoUnApply(Self,FPass,rci,Result);
    Inc(FPass);
  end;
end;

end.