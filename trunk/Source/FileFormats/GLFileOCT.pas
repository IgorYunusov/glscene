{: GLFileOCT<p>

    Support-code to load OCT Files into TGLFreeForm-Components in GLScene.<br>
    (OCT being the format output from FSRad, http://www.fluidstudios.com/fsrad.html).<p>

	<b>History : </b><font size=-1><ul>
      <li>02/02/03 - EG - Creation
   </ul><p>
}
unit GLFileOCT;

interface

uses Classes, GLVectorFileObjects, GLMisc, Geometry, FileOCT;

type

   // TGLOCTVectorFile
   //
   {: The OCT vector file (FSRad output).<p> }
   TGLOCTVectorFile = class(TVectorFile)
      public
         { Public Declarations }
         class function Capabilities : TDataFileCapabilities; override;

         procedure LoadFromStream(aStream: TStream); override;
   end;

// ------------------------------------------------------------------
// ------------------------------------------------------------------
// ------------------------------------------------------------------
implementation
// ------------------------------------------------------------------
// ------------------------------------------------------------------
// ------------------------------------------------------------------

uses SysUtils, GLTexture, Graphics;

// ------------------
// ------------------ TGLOCTVectorFile ------------------
// ------------------

// Capabilities
//
class function TGLOCTVectorFile.Capabilities : TDataFileCapabilities;
begin
   Result:=[dfcRead];
end;

// LoadFromStream
//
procedure TGLOCTVectorFile.LoadFromStream(aStream : TStream);
var
   i, y, n : Integer;
   oct : TOCTFile;
   octFace : POCTFace;
   octLightmap : POCTLightmap;
   mo : TMeshObject;
   fg : TFGVertexIndexList;
   lightmapLib : TGLMaterialLibrary;
   lightmapBmp : TBitmap;
   libMat : TGLLibMaterial;
begin
   oct:=TOCTFile.Create(aStream);
   try
      mo:=TMeshObject.CreateOwned(Owner.MeshObjects);
      mo.Mode:=momFaceGroups;

      lightmapLib:=Owner.LightmapLibrary;
      if Assigned(lightmapLib) then begin
         // import lightmaps
         n:=oct.Header.numLightmaps;
         lightmapBmp:=TBitmap.Create;
         try
            lightmapBmp.PixelFormat:=pf24bit;
            lightmapBmp.Width:=128;
            lightmapBmp.Height:=128;
            for i:=0 to n-1 do begin
               octLightmap:=@oct.Lightmaps[i];
               // convert RAW RGB to BMP
               for y:=0 to 127 do
                  Move(octLightmap.map[y*128*3], lightmapBmp.ScanLine[127-y]^, 128*3);
               // spawn lightmap
               libMat:=lightmapLib.AddTextureMaterial(IntToStr(i), lightmapBmp);
               with libMat.Material.Texture do begin
                  MinFilter:=miLinear;
                  TextureWrap:=twNone;
                  TextureFormat:=tfRGB;
               end;
            end;
         finally
            lightmapBmp.Free;
         end;
      end;

      // import geometry
      n:=oct.Header.numVerts;

      mo.Vertices.AdjustCapacityToAtLeast(n);
      mo.TexCoords.AdjustCapacityToAtLeast(n);
      mo.LighmapTexCoords.AdjustCapacityToAtLeast(n);
      for i:=0 to n-1 do with oct.Vertices[i] do begin
         mo.Vertices.Add(pos[0], pos[1], pos[2]);
         mo.TexCoords.Add(tv.s, tv.t);
         mo.LighmapTexCoords.Add(lv.s, lv.t);
      end;
      // import faces
      n:=oct.Header.numFaces;
      for i:=0 to n-1 do begin
         octFace:=@oct.Faces[i];
         fg:=TFGVertexIndexList.CreateOwned(mo.FaceGroups);
         fg.Mode:=fgmmTriangleFan;
         fg.VertexIndices.AddSerie(octFace.start, 1, octFace.num);
         if Assigned(lightmapLib) then
            fg.LightMapIndex:=octFace.lid;
      end;

   finally
      oct.Free;
   end;
end;

// ------------------------------------------------------------------
// ------------------------------------------------------------------
// ------------------------------------------------------------------
initialization
// ------------------------------------------------------------------
// ------------------------------------------------------------------
// ------------------------------------------------------------------

   RegisterVectorFileFormat('oct', 'FSRad OCT files', TGLOCTVectorFile);

end.
