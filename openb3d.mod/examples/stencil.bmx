' stencil.bmx
' stencil reflections

Import angros.b3dglgraphics

Strict

Graphics3D 800,600,0,2


Local cam:TCamera=CreateCamera()
PositionEntity cam,0,8,-24
RotateEntity cam,20,0,0

Local light:TLight=CreateLight(2)
RotateEntity light,45,45,0
PositionEntity light,10,10,0
LightRange light,10

' ground
Local ground:TMesh=LoadMesh("media/grid.b3d")
ScaleEntity ground,0.5,1,0.5
Local ground_tex:TTexture=LoadTexture("media/Envwall.bmp")
EntityTexture ground,ground_tex
EntityAlpha ground,0.75

Local groundcopy:TMesh=LoadMesh("media/grid.b3d")
ScaleEntity groundcopy,0.5,1,0.5

' sky
Local sky:TMesh=CreateSphere(24)
ScaleEntity sky,500,500,500
FlipMesh sky
EntityFX sky,1
Local sky_tex:TTexture=LoadTexture("media/sky.bmp")
EntityTexture sky,sky_tex

' teapot
Local teapot:TMesh=LoadMesh("media/teapot.b3d")
ScaleEntity teapot,5,5,5
PositionEntity teapot,0,6,10

Local teapotcopy:TMesh=LoadMesh("media/teapot.b3d")
ScaleEntity teapotcopy,5,-5,5
FlipMesh teapotcopy
PositionEntity teapotcopy,0,-(EntityY(teapot)-EntityY(ground)),10

' cactus
Local cactus:TMesh=LoadMesh("media/cactus2.b3d")
FitMesh cactus,-5,0,0,2,6,0.5

Local cactuscopy:TMesh=LoadMesh("media/cactus2.b3d")
FitMesh cactuscopy,-5,0,0,2,-6,0.5
FlipMesh cactuscopy

' camel
Local camel:TMesh=LoadMesh("media/camel.b3d")
FitMesh camel,5,0,0,6,5,4

Local camelcopy:TMesh=LoadMesh("media/camel.b3d")
FitMesh camelcopy,5,0,0,6,-5,4
FlipMesh camelcopy

' load ufo to give us a dynamic moving object that the stencil will be able to reflect
Local ufo_piv:TPivot=CreatePivot()
PositionEntity ufo_piv,0,0,10
Local ufo:TMesh=LoadMesh("media/green_ufo.b3d",ufo_piv)
PositionEntity ufo,0,10,10

Local ufocopy:TMesh=LoadMesh("media/green_ufo.b3d",ufo_piv)
ScaleEntity ufocopy,1,-1,1
FlipMesh ufocopy
PositionEntity ufocopy,0,-(EntityY(ufo)-EntityY(ground)),10

' ball
Local sphere:TMesh=CreateSphere()
Local tex:TTexture=LoadTexture("media/Ball.bmp")
EntityTexture sphere,tex

Local spherecopy:TMesh=CreateSphere()
EntityTexture spherecopy,tex

Local stencil:TStencil=CreateStencil()
StencilMesh stencil,groundcopy,1
StencilMode stencil,1,1

' used by fps code
Local old_ms%=MilliSecs()
Local renders%, fps%, ticks%=0

Local xrotspeed#=1.5,yrotspeed#=0.5,height#=4.0


While Not KeyDown(KEY_ESCAPE)

	' move ball
	If KeyDown(KEY_EQUALS) Then height:+0.33
	If KeyDown(KEY_MINUS) Then height:-0.33
	If height<0 Then height=0
	
	PositionEntity sphere,0,height,0
	PositionEntity spherecopy,0,-(EntityY(sphere)-EntityY(ground)),0
	
	TurnEntity sphere,xrotspeed,yrotspeed,0
	TurnEntity spherecopy,xrotspeed,yrotspeed,0
	
	' control camera
	MoveEntity cam,KeyDown(KEY_D)-KeyDown(KEY_A),0,KeyDown(KEY_W)-KeyDown(KEY_S)
	TurnEntity cam,KeyDown(KEY_DOWN)-KeyDown(KEY_UP),KeyDown(KEY_LEFT)-KeyDown(KEY_RIGHT),0
	
	' turn ufo pivot, causing child ufo mesh to spin around it (and teapot)
	TurnEntity ufo_piv,0,1,0
	TurnEntity teapot,0,0.5,-0.1
	TurnEntity teapotcopy,0,0.5,-0.1
	
	' disable reflections, so they will be clipped outside their stencil surface
	UseStencil Null
	HideEntity teapotcopy
	HideEntity cactuscopy
	HideEntity camelcopy
	HideEntity ufocopy
	HideEntity spherecopy
	CameraClsMode cam,1,1
	
	RenderWorld
	
	' calculate fps
	renders=renders+1
	If MilliSecs()-old_ms>=1000
		old_ms=MilliSecs()
		fps=renders
		renders=0
	EndIf
	
	Text 0,0,"FPS: "+fps
	Text 0,20,"Plus/Minus: move ball, WSAD: move camera, Arrows: rotate camera"
	
	' enable reflections, don't clear camera buffers so we can draw over rest of the scene
	UseStencil stencil
	ShowEntity teapotcopy
	ShowEntity cactuscopy
	ShowEntity camelcopy
	ShowEntity ufocopy
	ShowEntity spherecopy
	CameraClsMode cam,0,0
	
	RenderWorld
	Flip
	
Wend
End
