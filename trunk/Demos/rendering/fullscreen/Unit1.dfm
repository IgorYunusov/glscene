object DataModule1: TDataModule1
  OldCreateOrder = False
  OnCreate = DataModuleCreate
  Left = 285
  Top = 161
  Height = 479
  Width = 741
  object GLScene1: TGLScene
    Left = 16
    Top = 8
    object GLLightSource1: TGLLightSource
      ConstAttenuation = 1
      Position.Coordinates = {0000484200004842000048420000803F}
      SpotCutOff = 180
    end
    object Teapot1: TTeapot
      Material.Texture.ImageClassName = 'TGLBlankImage'
      Material.Texture.TextureMode = tmReplace
    end
    object DCBlueLight: TDummyCube
      Direction.Coordinates = {3ACD133F3ACD133F3ACD133F00000000}
      Up.Coordinates = {EB05D1BEEB05513FEB05D1BE00000000}
      CubeSize = 1
      object GLLightSource2: TGLLightSource
        ConstAttenuation = 1
        Diffuse.Color = {00000000000000000000803F0000803F}
        Position.Coordinates = {0000A04100000000000000000000803F}
        SpotCutOff = 180
      end
    end
    object GLCamera1: TGLCamera
      DepthOfView = 100
      FocalLength = 50
      TargetObject = Teapot1
      Position.Coordinates = {0000404000000040000000400000803F}
    end
  end
  object GLFullScreenViewer1: TGLFullScreenViewer
    Camera = GLCamera1
    Width = 800
    Height = 600
    PostRender = GLFullScreenViewer1PostRender
    Buffer.BackgroundColor = clBlack
    Buffer.AntiAliasing = aaNone
    StayOnTop = True
    RefreshRate = 100
    OnKeyPress = GLFullScreenViewer1KeyPress
    Left = 104
    Top = 8
  end
end
