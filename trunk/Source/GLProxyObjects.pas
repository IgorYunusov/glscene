// GLProxyObjects
{: Implements specific proxying classes.<p>

	<b>History : </b><font size=-1><ul>
      <li>06/12/03 - EG - Creation from GLScene.pas split
   </ul></font>
}
unit GLProxyObjects;

interface

uses Classes, GLScene, VectorGeometry, GLMisc, GLTexture, GLSilhouette,
   GLVectorFileObjects;

type

   // TGLColorProxyObject
   //
   {: A proxy object with its own color.<p>
      This proxy object can have a unique color. Note that multi-material
      objects (Freeforms linked to a material library f.i.) won't honour
      the color. }
   TGLColorProxyObject = class (TGLProxyObject)
      private
         { Private Declarations }
         FFrontColor: TGLFaceProperties;

      public
         { Public Declarations }
         constructor Create(AOwner: TComponent); override;
         destructor Destroy; override;

         procedure DoRender(var rci : TRenderContextInfo;
                            renderSelf, renderChildren : Boolean); override;
      published
         { Published Declarations }
         property FrontColor: TGLFaceProperties read FFrontColor;
   end;

   // TGLFreeFormProxyObject
   //
   {: A proxy object specialized for FreeForms.<p> }
   TGLFreeFormProxyObject = class (TGLProxyObject)
      protected
         { Protected Declarations }
         procedure SetMasterObject(const val : TGLBaseSceneObject); override;

      public
         { Public Declarations }

         {: If the MasterObject is a FreeForm, you can raycast against the Octree,
            which is alot faster.  You must build the octree before using. }
         function OctreeRayCastIntersect(const rayStart, rayVector : TVector;
                                         intersectPoint : PVector = nil;
                                         intersectNormal : PVector = nil) : Boolean;
   end;

//-------------------------------------------------------------
//-------------------------------------------------------------
//-------------------------------------------------------------
implementation
//-------------------------------------------------------------
//-------------------------------------------------------------
//-------------------------------------------------------------

uses SysUtils,OpenGL1x;

// ------------------
// ------------------ TGLColorProxyObject ------------------
// ------------------

// Create
//
constructor TGLColorProxyObject.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FFrontColor:=TGLFaceProperties.Create(Self);
end;

// Destroy
//
destructor TGLColorProxyObject.Destroy;
begin
   FFrontColor.Free;

   inherited Destroy;
end;

// Render
//
procedure TGLColorProxyObject.DoRender(var rci : TRenderContextInfo;
                                  renderSelf, renderChildren : Boolean);
var
   gotMaster, masterGotEffects, oldProxySubObject : Boolean;
begin
   if FRendering then Exit;
   FRendering:=True;
   try
      gotMaster:=Assigned(MasterObject);
      masterGotEffects:=gotMaster and (pooEffects in ProxyOptions)
                        and (MasterObject.Effects.Count>0);
      if gotMaster then begin
         if pooObjects in ProxyOptions then begin
            oldProxySubObject:=rci.proxySubObject;
            rci.proxySubObject:=True;
            if pooTransformation in ProxyOptions then
               glMultMatrixf(PGLFloat(MasterObject.MatrixAsAddress));
            TGLCustomSceneObject(MasterObject).Material.FrontProperties.Assign(FFrontColor);
            MasterObject.DoRender(rci, renderSelf, RenderChildren);
            rci.proxySubObject:=oldProxySubObject;
         end;
      end;
      // now render self stuff (our children, our effects, etc.)
      if renderChildren and (Count>0) then
         Self.RenderChildren(0, Count-1, rci);
      if masterGotEffects then
         MasterObject.Effects.RenderPostEffects(Scene.CurrentBuffer, rci);
   finally
      FRendering:=False;
   end;
   ClearStructureChanged;
end;

// ------------------
// ------------------ TGLFreeFormProxyObject ------------------
// ------------------

// SetMasterObject
//
procedure TGLFreeFormProxyObject.SetMasterObject(const val : TGLBaseSceneObject);
begin
   if Assigned(val) and not (val is TGLFreeForm) then
      raise Exception.Create(ClassName+' accepts only FreeForms as master!');
   inherited;
end;

// OctreeRayCastIntersect
//
function TGLFreeFormProxyObject.OctreeRayCastIntersect(const rayStart, rayVector : TVector;
                                 intersectPoint : PVector = nil;
                                 intersectNormal : PVector = nil) : Boolean;
var
   localRayStart, localRayVector : TVector;
begin
   if Assigned(MasterObject)
    and (MasterObject is TGLFreeForm)
    then begin
      SetVector(localRayStart, AbsoluteToLocal(rayStart));
      SetVector(localRayStart, MasterObject.LocalToAbsolute(localRayStart));
      SetVector(localRayVector, AbsoluteToLocal(rayVector));
      SetVector(localRayVector, MasterObject.LocalToAbsolute(localRayVector));
      NormalizeVector(localRayVector);

      Result:=TGLFreeForm(MasterObject).OctreeRayCastIntersect(localRayStart, localRayVector,
                                            intersectPoint, intersectNormal);
      if Result then begin
         if Assigned(intersectPoint) then begin
            SetVector(intersectPoint^, MasterObject.AbsoluteToLocal(intersectPoint^));
            SetVector(intersectPoint^, LocalToAbsolute(intersectPoint^));
         end;
         if Assigned(intersectNormal) then begin
            SetVector(intersectNormal^, MasterObject.AbsoluteToLocal(intersectNormal^));
            SetVector(intersectNormal^, LocalToAbsolute(intersectNormal^));
         end;
      end;
   end else Result:=False;
end;

//-------------------------------------------------------------
//-------------------------------------------------------------
//-------------------------------------------------------------
initialization
//-------------------------------------------------------------
//-------------------------------------------------------------
//-------------------------------------------------------------

   RegisterClasses([TGLColorProxyObject, TGLFreeFormProxyObject]);

end.
