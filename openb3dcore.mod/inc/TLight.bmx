
Rem
bbdoc: Light entity
End Rem
Type TLight Extends TEntity

	Global light_no:Int Ptr ' internal counter - 0
	Global no_lights:Int Ptr ' number of lights - 0
	Global max_lights:Int Ptr ' constant - 8
	
	' enter gl consts here for each available light
	Global gl_light:Int Ptr ' array [] GL_LIGHT0..GL_LIGHT7
	
	Global light_list:TList=CreateList() ' Light vector
	
	Field cast_shadow:Byte Ptr ' 1
	Field light_type:Byte Ptr ' 0
	Field Range:Float Ptr ' (1.0/1000.0)
	Field red:Float Ptr,green:Float Ptr,blue:Float Ptr ' 1.0/1.0/1.0
	Field inner_ang:Float Ptr,outer_ang:Float Ptr ' 0.0/45.0
	
	' wrapper
	Global ambient#[8,4] ' [0.0,0.0,0.0,1.0]
	Global diffuse#[8,4] ' [1.0,1.0,1.0,1.0]
	Global specular#[8,4] ' [1.0,1.0,1.0,1.0]
	Global position#[8,4] ' [0.0,0.0,1.0,0.0]
	'vec4 halfVector derived
	Global spotDirection#[8,3] ' [0.0,0.0,-1.0]
	Global spotExponent#[8,1] ' [0.0]
	Global spotCutoff#[8,1] ' [180.0] (Range: [0.0,90.0], 180.0)
	'float spotCosCutoff derived
	Global constantAtt#[8,1] ' [1.0/0.0]
	Global linearAtt#[8,1] ' [0.0/0.001]
	Global quadraticAtt#[8,1] ' [0.0]
	
	Global light_list_id:Int=0
	
	Function CreateObject:TLight( inst:Byte Ptr ) ' Create and map object from C++ instance
	
		If inst=Null Then Return Null
		Local obj:TLight=New TLight
		?bmxng
		ent_map.Insert( inst,obj )
		?Not bmxng
		ent_map.Insert( String(Int(inst)),obj )
		?
		obj.instance=inst
		obj.InitFields()
		Return obj
		
	End Function
	
	Function InitGlobals() ' Once per Graphics3D
	
		' int
		light_no=StaticInt_( LIGHT_class,LIGHT_light_no )
		no_lights=StaticInt_( LIGHT_class,LIGHT_no_lights )
		max_lights=StaticInt_( LIGHT_class,LIGHT_max_lights )
		gl_light=StaticInt_( LIGHT_class,LIGHT_gl_light )
		
	End Function
	
	Method InitFields() ' Once per CreateObject
	
		Super.InitFields()
		
		' char
		cast_shadow=LightChar_( GetInstance(Self),LIGHT_cast_shadow )
		light_type=LightChar_( GetInstance(Self),LIGHT_light_type )
		
		' float
		Range=LightFloat_( GetInstance(Self),LIGHT_range )
		red=LightFloat_( GetInstance(Self),LIGHT_red )
		green=LightFloat_( GetInstance(Self),LIGHT_green )
		blue=LightFloat_( GetInstance(Self),LIGHT_blue )
		inner_ang=LightFloat_( GetInstance(Self),LIGHT_inner_ang )
		outer_ang=LightFloat_( GetInstance(Self),LIGHT_outer_ang )
		
		CopyList_(light_list)
		
	End Method
	
	Function DebugGlobals( debug_subobjects:Int=0,debug_base_types:Int=0 )
	
		Local pad:String
		Local loop:Int=debug_subobjects
		If debug_base_types>debug_subobjects Then loop=debug_base_types
		For Local i%=1 Until loop
			pad:+"  "
		Next
		If debug_subobjects Then debug_subobjects:+1
		If debug_base_types Then debug_base_types:+1
		DebugLog pad+" Light: "
		
		' int
		If light_no<>Null Then DebugLog(pad+" light_no: "+light_no[0]) Else DebugLog(pad+" light_no: Null")
		If no_lights<>Null Then DebugLog(pad+" no_lights: "+no_lights[0]) Else DebugLog(pad+" no_lights: Null")
		If max_lights<>Null Then DebugLog(pad+" max_lights: "+max_lights[0]) Else DebugLog(pad+" max_lights: Null")
		DebugLog pad+" gl_light: "+StringPtr(gl_light)
		
		DebugLog ""
		
	End Function
	
	Method DebugFields( debug_subobjects:Int=0,debug_base_types:Int=0 )
	
		Local pad:String
		Local loop:Int=debug_subobjects
		If debug_base_types>debug_subobjects Then loop=debug_base_types
		For Local i%=1 Until loop
			pad:+"  "
		Next
		If debug_subobjects Then debug_subobjects:+1
		If debug_base_types Then debug_base_types:+1
		DebugLog pad+" Light instance: "+StringPtr(GetInstance(Self))
		
		' char
		If cast_shadow<>Null Then DebugLog(pad+" cast_shadow: "+cast_shadow[0]) Else DebugLog(pad+" cast_shadow: Null")
		If light_type<>Null Then DebugLog(pad+" light_type: "+light_type[0]) Else DebugLog(pad+" light_type: Null")
		
		' float
		If Range<>Null Then DebugLog(pad+" Range: "+Range[0]) Else DebugLog(pad+" Range: Null")
		If red<>Null Then DebugLog(pad+" red: "+red[0]) Else DebugLog(pad+" red: Null")
		If green<>Null Then DebugLog(pad+" green: "+green[0]) Else DebugLog(pad+" green: Null")
		If blue<>Null Then DebugLog(pad+" blue: "+blue[0]) Else DebugLog(pad+" blue: Null")
		If inner_ang<>Null Then DebugLog(pad+" inner_ang: "+inner_ang[0]) Else DebugLog(pad+" inner_ang: Null")
		If outer_ang<>Null Then DebugLog(pad+" outer_ang: "+outer_ang[0]) Else DebugLog(pad+" outer_ang: Null")
		
		DebugLog ""
		
		If debug_base_types Then Super.DebugFields( debug_subobjects,debug_base_types )
		
	End Method
	
	Function AddList_( list:TList ) ' Global list
	
		Super.AddList_(list)
		
		Select list
			Case light_list
				If StaticListSize_( LIGHT_class,LIGHT_light_list )
					Local inst:Byte Ptr=StaticIterVectorLight_( LIGHT_class,LIGHT_light_list,Varptr light_list_id )
					Local obj:TLight=TLight( GetObject(inst) ) ' no CreateObject
					If obj Then ListAddLast( list,obj )
				EndIf
		End Select
		
	End Function
	
	Function CopyList_( list:TList ) ' Global list
	
		Super.CopyList_(list) ' calls ClearList
		
		Select list
			Case light_list
				light_list_id=0
				For Local id:Int=0 To StaticListSize_( LIGHT_class,LIGHT_light_list )-1
					Local inst:Byte Ptr=StaticIterVectorLight_( LIGHT_class,LIGHT_light_list,Varptr light_list_id )
					Local obj:TLight=TLight( GetObject(inst) ) ' no CreateObject
					If obj Then ListAddLast( list,obj )
				Next
		End Select
		
	End Function
	
	' Extra
	
	' at init, call after a RenderWorld
	Function GetLightValues()
		
		For Local i%=0 To no_lights[0]-1
			glGetLightfv(GL_LIGHT0+i, GL_AMBIENT, Varptr ambient[i,0])
			glGetLightfv(GL_LIGHT0+i, GL_DIFFUSE, Varptr diffuse[i,0])
			glGetLightfv(GL_LIGHT0+i, GL_SPECULAR, Varptr specular[i,0])
			glGetLightfv(GL_LIGHT0+i, GL_POSITION, Varptr position[i,0])
			glGetLightfv(GL_LIGHT0+i, GL_SPOT_DIRECTION, Varptr spotDirection[i,0]) ' if light_type=3
			glGetLightfv(GL_LIGHT0+i, GL_SPOT_EXPONENT, Varptr spotExponent[i,0]) ' if light_type=3
			glGetLightfv(GL_LIGHT0+i, GL_SPOT_CUTOFF, Varptr spotCutoff[i,0]) ' if light_type=3
			glGetLightfv(GL_LIGHT0+i, GL_CONSTANT_ATTENUATION, Varptr constantAtt[i,0]) ' if light_type>1
			glGetLightfv(GL_LIGHT0+i, GL_LINEAR_ATTENUATION, Varptr linearAtt[i,0]) ' if light_type>1
			glGetLightfv(GL_LIGHT0+i, GL_QUADRATIC_ATTENUATION, Varptr quadraticAtt[i,0]) ' if light_type>1
		Next
		
	End Function
	
	' in main loop, call before RenderWorld
	Function SetLightValues()
	
		For Local i%=0 To no_lights[0]-1
			glLightfv(GL_LIGHT0+i, GL_AMBIENT, Varptr ambient[i,0]) ' not set
			glLightfv(GL_LIGHT0+i, GL_DIFFUSE, Varptr diffuse[i,0]) ' set in Update
			glLightfv(GL_LIGHT0+i, GL_SPECULAR, Varptr specular[i,0]) ' set in CreateLight
			glLightfv(GL_LIGHT0+i, GL_POSITION, Varptr position[i,0]) ' set in Update
			glLightfv(GL_LIGHT0+i, GL_SPOT_DIRECTION, Varptr spotDirection[i,0]) ' set in Update
			glLightfv(GL_LIGHT0+i, GL_SPOT_EXPONENT, Varptr spotExponent[i,0]) ' set in CreateLight
			glLightfv(GL_LIGHT0+i, GL_SPOT_CUTOFF, Varptr spotCutoff[i,0]) ' set in Update
			glLightfv(GL_LIGHT0+i, GL_CONSTANT_ATTENUATION, Varptr constantAtt[i,0]) ' set in CreateLight
			glLightfv(GL_LIGHT0+i, GL_LINEAR_ATTENUATION, Varptr linearAtt[i,0]) ' set in Update
			glLightfv(GL_LIGHT0+i, GL_QUADRATIC_ATTENUATION, Varptr quadraticAtt[i,0]) ' not set
		Next
	
	End Function
	
	' Minib3d
	
	Method New()
	
		If TGlobal3D.Log_New
			DebugLog " New TLight"
		EndIf
		
	End Method
	
	Method Delete()
	
		If TGlobal3D.Log_Del
			DebugLog " Del TLight"
		EndIf
	
	End Method
	
	Method FreeEntity()
	
		If exists
			ListRemove( light_list,Self ) ; light_list_id:-1
			Super.FreeEntity()
		EndIf
		
	End Method
	
	Function CreateLight:TLight( light_type:Int=1,parent:TEntity=Null )
	
		Local inst:Byte Ptr=CreateLight_( light_type,GetInstance(parent) )
		Return CreateObject(inst)
		
	End Function
	
	Method LightRange( Range:Float )
	
		LightRange_( GetInstance(Self),Range )
		
	End Method
	
	Method LightColor( red:Float,green:Float,blue:Float )
	
		LightColor_( GetInstance(Self),red,green,blue )
		
	End Method
	
	Method LightConeAngles( inner_ang:Float,outer_ang:Float )
	
		LightConeAngles_( GetInstance(Self),inner_ang,outer_ang )
		
	End Method
	
	' Internal
	
	Method CopyEntity:TLight( parent:TEntity=Null )

		Local inst:Byte Ptr=CopyEntity_( GetInstance(Self),GetInstance(parent) )
		Local light:TLight=CreateObject(inst)
		If pick_mode[0] Then TPick.AddList_(TPick.ent_list)
		Return light
		
	End Method
	
	' called in Camera::Render
	Method Update()
	
		LightUpdate_( GetInstance(Self) )
		
	End Method
	
End Type
