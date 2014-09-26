//---------------------------------------------------------------------------

#ifndef Unit1H
#define Unit1H
//---------------------------------------------------------------------------
#include <Classes.hpp>
#include <Controls.hpp>
#include <StdCtrls.hpp>
#include <Forms.hpp>
#include "AsyncTimer.hpp"
#include "GLCadencer.hpp"
#include "GLMisc.hpp"
#include "GLObjects.hpp"
#include "GLPhongShader.hpp"
#include "GLScene.hpp"
#include "GLTeapot.hpp"
#include "GLTexture.hpp"
#include "GLWin32Viewer.hpp"
#include "GLAsmShader.hpp"
#include "GLCustomShader.hpp"
//---------------------------------------------------------------------------
class TForm1 : public TForm
{
__published:	// Composants g�r�s par l'EDI
        TGLSceneViewer *GLSceneViewer1;
        TCheckBox *CheckBox1;
        TGLScene *GLScene1;
        TGLDummyCube *GLDummyCube1;
        TGLCamera *GLCamera1;
        TGLLightSource *GLLightSource1;
        TGLTeapot *GLTeapot1;
        TGLMaterialLibrary *GLMaterialLibrary1;
        TGLPhongShader *GLPhongShader1;
        TGLCadencer *GLCadencer1;
        TAsyncTimer *AsyncTimer1;
        void __fastcall GLSceneViewer1MouseDown(TObject *Sender,
          TMouseButton Button, TShiftState Shift, int X, int Y);
        void __fastcall GLSceneViewer1MouseMove(TObject *Sender,
          TShiftState Shift, int X, int Y);
        void __fastcall AsyncTimer1Timer(TObject *Sender);
        void __fastcall CheckBox1Click(TObject *Sender);
        void __fastcall GLCadencer1Progress(TObject *Sender,
          const double deltaTime, const double newTime);
private:	// D�clarations de l'utilisateur
public:		// D�clarations de l'utilisateur
        __fastcall TForm1(TComponent* Owner);
        int mx, my;
};
//---------------------------------------------------------------------------
extern PACKAGE TForm1 *Form1;
//---------------------------------------------------------------------------
#endif