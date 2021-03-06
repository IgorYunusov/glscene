//
// VXScene Component Library, based on GLScene http://glscene.sourceforge.net 
//
{
	Quake2 MD2 vector file format implementation. 
	 
}
unit VXS.FileDAE;

interface

{$I VXScene.inc}

uses
  System.Classes, System.SysUtils,
  FMX.DAE.Importer, FMX.DAE.Model,

  VXS.VectorFileObjects, VXS.ApplicationFileIO;

type
   // TVXFileDAE
   //
   { The DAE vector file (COLLADA actor file). 
      Stores a set of "frames" describing the different postures of the actor,
      it may be animated by TVXActor. The "Skin" must be loaded indepentendly
      (the whole mesh uses a single texture bitmap). }
   TVXFileDAE = class(TVXVectorFile)
      public
         
         class function Capabilities : TVXDataFileCapabilities; override;
         procedure LoadFromStream(aStream : TStream); override;
   end;

// ------------------------------------------------------------------
// ------------------------------------------------------------------
// ------------------------------------------------------------------
implementation
// ------------------
// ------------------ TVXDAEVectorFile ------------------
// ------------------

// Capabilities
//
class function TVXFileDAE.Capabilities : TVXDataFileCapabilities;
begin
   Result:=[dfcRead];
end;

// LoadFromStream
//
procedure TVXFileDAE.LoadFromStream(aStream : TStream);
var
   i, j : Integer;
   DAEFile : TVXFileDAE;
   mesh : TVXMorphableMeshObject;
   faceGroup : TFGIndexTexCoordList;
   morphTarget : TVXMeshMorphTarget;
begin
   { TODO : E2035 Not enough actual parameters }
   (*DAEFile:=TVXFileDAE.Create();*)
   DAEFile.LoadFromStream(aStream);
   try
      // retrieve mesh data
      mesh:=TVXMorphableMeshObject.CreateOwned(Owner.MeshObjects);
      with mesh, DAEFile do begin
         Mode:=momFaceGroups;
         faceGroup:=TFGIndexTexCoordList.CreateOwned(FaceGroups);
         with faceGroup do begin
            MaterialName:='';
            { TODO : E2003 Undeclared identifier: 'iTriangles' }
            (*
            VertexIndices.Capacity:=iTriangles*3;
            TexCoords.Capacity:=iTriangles*3;
            // copy the face list
            for i:=0 to iTriangles-1 do with IndexList[i] do begin
               Add(a, a_s, -a_t);
               Add(b, b_s, -b_t);
               Add(c, c_s, -c_t);
            end;
            *)
         end;
         // retrieve frames data (morph targets)
         { TODO : E2003 Undeclared identifier: 'iFrames' }
         (*
         for i:=0 to iFrames-1 do begin
            morphTarget:=TVXMeshMorphTarget.CreateOwned(MorphTargets);
            with morphTarget do begin
               Name:='Frame'+IntToStr(i);
               Vertices.Capacity:=iVertices;
               for j:=0 to iVertices-1 do
                  Vertices.Add(VertexList[i][j]);
               BuildNormals(faceGroup.VertexIndices, momTriangles);
            end;
         end;
         *)
      end;
      if GetOwner is TVXActor then with TVXActor(GetOwner).Animations do begin
         Clear;
         { TODO : E2003 Undeclared identifier: 'frameNames' }
         (*
         with DAEFile do for i:=0 to frameNames.Count-1 do with Add do begin
            Name:=frameNames[i];
            Reference:=aarMorph;
            StartFrame:=Integer(frameNames.Objects[i]);
            if i<frameNames.Count-1 then
               EndFrame:=Integer(frameNames.Objects[i+1])-1
            else EndFrame:=iFrames-1;
         end;
         *)
      end;
      if mesh.MorphTargets.Count>0 then
         mesh.MorphTo(0);
   finally
      DAEFile.Free;
   end;
end;

// ------------------------------------------------------------------
// ------------------------------------------------------------------
// ------------------------------------------------------------------
initialization
// ------------------------------------------------------------------
// ------------------------------------------------------------------
// ------------------------------------------------------------------

   RegisterVectorFileFormat('dae', 'COLLADA model files', TVXFileDAE);

end.
