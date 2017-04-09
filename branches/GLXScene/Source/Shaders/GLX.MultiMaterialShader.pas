//
// VKScene Component Library, based on GLScene http://glscene.sourceforge.net 
//
{ 
   A shader that applies a render pass for each material in
   its assigned MaterialLibrary. 
   
}
unit GLX.MultiMaterialShader;

interface

uses
  System.Classes, 
  
  GLX.Material, GLX.RenderContextInfo, GLX.State;

type
   TGLMultiMaterialShader = class(TGLShader)
      private
         FPass : Integer;
         FMaterialLibrary : TGLMaterialLibrary;
         FVisibleAtDesignTime: boolean;
         FShaderActiveAtDesignTime : boolean;
    FShaderStyle: TGLShaderStyle;
    procedure SetVisibleAtDesignTime(const Value: boolean);
    procedure SetShaderStyle(const Value: TGLShaderStyle);
      protected
         procedure SetMaterialLibrary(const val : TGLMaterialLibrary);
         procedure DoApply(var rci : TGLRenderContextInfo; Sender : TObject); override;
         function DoUnApply(var rci : TGLRenderContextInfo) : Boolean; override;
      public
         constructor Create(aOwner : TComponent); override;
      published
         property MaterialLibrary : TGLMaterialLibrary read FMaterialLibrary write SetMaterialLibrary;
         property VisibleAtDesignTime : boolean read FVisibleAtDesignTime write SetVisibleAtDesignTime;
         property ShaderStyle:TGLShaderStyle read FShaderStyle write SetShaderStyle;
   end;

// ------------------------------------------------------------------
// ------------------------------------------------------------------
// ------------------------------------------------------------------
implementation
// ------------------
// ------------------ TGLMultiMaterialShader ------------------
// ------------------

// Create
//
constructor TGLMultiMaterialShader.Create(aOwner : TComponent);
begin
   inherited;
   FShaderStyle:=ssReplace;
   FVisibleAtDesignTime := False;
end;

// DoApply
//
procedure TGLMultiMaterialShader.DoApply(var rci: TGLRenderContextInfo; Sender : TObject);
begin
   if not Assigned(FMaterialLibrary) then exit;

   FShaderActiveAtDesignTime := FVisibleAtDesignTime;

   FPass:=1;
   if (not (csDesigning in ComponentState)) or FShaderActiveAtDesignTime then begin
      rci.ignoreDepthRequests := True;
      rci.VKStates.Enable(stDepthTest);
      rci.VKStates.DepthFunc := cfLEqual;
      if FMaterialLibrary.Materials.Count>0 then
         FMaterialLibrary.Materials[0].Apply(rci);
      rci.ignoreDepthRequests := False;
  end;
end;

// DoUnApply
//
function TGLMultiMaterialShader.DoUnApply(
   var rci: TGLRenderContextInfo): Boolean;
begin
   Result:=False;
   if not Assigned(FMaterialLibrary) then exit;
   if (not (csDesigning in ComponentState)) or FShaderActiveAtDesignTime then begin
      if FMaterialLibrary.Materials.Count>0 then
         // handle multi-pass materials
         if FMaterialLibrary.Materials[FPass-1].UnApply(rci) then
         begin
           Result:=true;
           Exit;
         end;
      if (FPass >= FMaterialLibrary.Materials.Count) then begin
         rci.VKStates.DepthFunc := cfLess;
         exit;
      end;
      FMaterialLibrary.Materials[FPass].Apply(rci);
      Result:=True;
      Inc(FPass);
   end;
end;

// SetMaterialLibrary
//
procedure TGLMultiMaterialShader.SetMaterialLibrary(
   const val: TGLMaterialLibrary);
begin
   if val<>FMaterialLibrary then begin
      FMaterialLibrary:=val;
      NotifyChange(Self);
   end;
end;

procedure TGLMultiMaterialShader.SetShaderStyle(const Value: TGLShaderStyle);
begin
  FShaderStyle := Value;
  inherited ShaderStyle :=FShaderStyle;
end;

procedure TGLMultiMaterialShader.SetVisibleAtDesignTime(
  const Value: boolean);
begin
  FVisibleAtDesignTime := Value;
  if csDesigning in ComponentState then
     NotifyChange(Self);
end;

end.
