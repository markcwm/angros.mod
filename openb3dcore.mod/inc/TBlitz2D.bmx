
Rem
bbdoc: Blitz2D
EndRem
Type TBlitz2D

	Function BeginMax2D( version:Int=1 )
	
		Select version
		
		Case 0 ' Old begin function (by Oddball)
		
			' restore the last Max2D settings
			glPopClientAttrib() ' restore last client states from attribute stack
			glPopAttrib() ' restore last states from attribute stack
			glMatrixMode(GL_MODELVIEW) ' specify the matrix stack to use
			glPopMatrix() ' restore last matrix stack
			glMatrixMode(GL_PROJECTION)
			glPopMatrix()
			glMatrixMode(GL_TEXTURE)
			glPopMatrix()
			glMatrixMode(GL_COLOR)
			glPopMatrix()
			
		Case 1 ' New begin function, allows instant resolution switch (by Krischan)
		
			' restore the last Max2D settings
			glPopClientAttrib() ' restore last client states from attribute stack
			glPopAttrib() ' restore last states from attribute stack
			glMatrixMode(GL_MODELVIEW) ' specify the matrix stack to use
			glPopMatrix() ' restore last matrix stack
			glMatrixMode(GL_PROJECTION)
			glPopMatrix()
			glMatrixMode(GL_TEXTURE)
			glPopMatrix()
			glMatrixMode(GL_COLOR)
			glPopMatrix()
			
			Local x:Int, y:Int, w:Int, h:Int
			GetViewport(x, y, w, h)
			
			glDisable(GL_LIGHTING)
			glDisable(GL_DEPTH_TEST)
			glDisable(GL_SCISSOR_TEST)
			glDisable(GL_FOG)
			glDisable(GL_CULL_FACE)
			
			glMatrixMode GL_TEXTURE
			glLoadIdentity
			
			glMatrixMode GL_PROJECTION
			glLoadIdentity
			glOrtho(0, TGlobal3D.width[0], TGlobal3D.height[0], 0, -1, 1) ' TGlobal3D.w/h rather than GraphicsW/H for MaxGUI canvas
			
			glMatrixMode GL_MODELVIEW
			glLoadIdentity
			
			SetViewport x, y, w, h
			
			Local MaxTex:Int
			glGetIntegerv(GL_MAX_TEXTURE_UNITS, Varptr(MaxTex))
			
			' disable all texture layers
			For Local Layer:Int = 0 Until MaxTex
				glActiveTexture(GL_TEXTURE0+Layer)
				
				glDisable(GL_TEXTURE_2D)
				
				glDisable(GL_TEXTURE_CUBE_MAP)
				glDisable(GL_TEXTURE_GEN_S)
				glDisable(GL_TEXTURE_GEN_T)
				glDisable(GL_TEXTURE_GEN_R)
			Next
			
			glActiveTexture(GL_TEXTURE0)
			
			glViewport(0, 0, TGlobal3D.width[0], TGlobal3D.height[0])
			glScissor(0, 0, TGlobal3D.width[0], TGlobal3D.height[0])
			
			' Max2d does this
			'glEnable GL_BLEND
			'glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)
			
			glEnable(GL_TEXTURE_2D)
			
		End Select
		
	End Function
	
	Function EndMax2D( version:Int=1 )
	
		Select version
		
		Case 0 ' Old end function (by Oddball)
		
			' save the Max2D settings for later
			glPushAttrib(GL_ALL_ATTRIB_BITS) ' save all states to attribute stack (set by glEnable and others)
			glPushClientAttrib(GL_CLIENT_ALL_ATTRIB_BITS) ' save client states to attribute stack (set by glEnableClientState)
			glMatrixMode(GL_MODELVIEW) ' specify the matrix stack to use
			glPushMatrix() ' save matrix stack
			glMatrixMode(GL_PROJECTION)
			glPushMatrix()
			glMatrixMode(GL_TEXTURE)
			glPushMatrix()
			glMatrixMode(GL_COLOR)
			glPushMatrix()
			
			TGlobal3D.EnableStates() ' enables normals but not vertex colors
			
			glDisable(GL_TEXTURE_2D) ' needed as Draw in Max2d enables it, but doesn't disable after use
			
			' set render state flags (crash if fx2 not set?)
			TGlobal3D.alpha_enable[0]=0	' alpha blending was disabled by Max2d
			TGlobal3D.blend_mode[0]=1		' force alpha blending (default is 1)
			'TGlobal3D.fx1[0]=0			' full bright/surface normals was enabled
			'TGlobal3D.fx2[0]=1			' vertex colors was not enabled
			
			glLightModeli(GL_LIGHT_MODEL_COLOR_CONTROL,GL_SEPARATE_SPECULAR_COLOR)
			glLightModeli(GL_LIGHT_MODEL_LOCAL_VIEWER,GL_TRUE)
			
			glClearDepth(1.0)						
			glDepthFunc(GL_LEQUAL)
			glHint(GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST)
			
			glAlphaFunc(GL_GEQUAL,0.5)
			
			For Local cam:TCamera=EachIn TCamera.cam_list
				If cam=TGlobal3D.camera_in_use ' active camera - was if cam.hide[0]=0
					cam.UpdateFog() ' fog with Max2d fix
					Exit
				EndIf
			Next
			
		Case 1 ' New end function, allows instant resolution switch (by Krischan)
		
			' save the Max2D settings for later
			glPushAttrib(GL_ALL_ATTRIB_BITS) ' save all states to attribute stack (set by glEnable and others)
			glPushClientAttrib(GL_CLIENT_ALL_ATTRIB_BITS) ' save client states to attribute stack (set by glEnableClientState)
			glMatrixMode(GL_MODELVIEW) ' specify the matrix stack to use
			glPushMatrix() ' save matrix stack
			glMatrixMode(GL_PROJECTION)
			glPushMatrix()
			glMatrixMode(GL_TEXTURE)
			glPushMatrix()
			glMatrixMode(GL_COLOR)
			glPushMatrix()
			
			' don't disable states after restoring stack, unless you know it gets enabled again
			'glDisable(GL_TEXTURE_CUBE_MAP)
			'glDisable(GL_TEXTURE_GEN_S)
			'glDisable(GL_TEXTURE_GEN_T)
			'glDisable(GL_TEXTURE_GEN_R)
			'glDisable(GL_BLEND)
			
			TGlobal3D.EnableStates() ' enables normals but not vertex colors
			
			glDisable(GL_TEXTURE_2D) ' needed as Draw in Max2d enables it, but doesn't disable after use
			
			' set render state flags (crash if fx2 not set?)
			TGlobal3D.alpha_enable[0]=0	' alpha blending was disabled by Max2d
			TGlobal3D.blend_mode[0]=1		' force alpha blending (default is 1)
			'TGlobal3D.fx1[0]=0			' full bright/surface normals was enabled
			'TGlobal3D.fx2[0]=1			' vertex colors was not enabled
			
			glLightModeli(GL_LIGHT_MODEL_COLOR_CONTROL, GL_SEPARATE_SPECULAR_COLOR)
			glLightModeli(GL_LIGHT_MODEL_LOCAL_VIEWER,GL_TRUE)
			
			glClearDepth(1.0)
			glDepthFunc(GL_LEQUAL)
			glHint(GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST)
			
			glAlphaFunc(GL_GEQUAL, 0.5)
			
			For Local cam:TCamera=EachIn TCamera.cam_list ' active camera - was if cam.hide[0]=0
				If cam = TGlobal3D.camera_in_use ' fog with Max2d fix
					cam.UpdateFog()
					Exit
				EndIf
			Next
			
		End Select
		
	End Function
	
End Type
