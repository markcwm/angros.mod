
Rem
bbdoc: Entity
End Rem
Type TEntity
	
	Global entity_list:TList=CreateList() ' Entity list
	Field child_list:TList=CreateList() ' Entity list
	Field parent:TEntity ' returned by GetParent - NULL
	
	' transform
	Field mat:TMatrix ' returned by EntityX/Y/Z (global) - LoadIdentity
	Field rotmat:TMatrix ' rotation matrix: used in EntityPitch/Yaw/Roll (global) - LoadIdentity
	Field px:Float Ptr,py:Float Ptr,pz:Float Ptr ' returned by EntityX/Y/Z (local) - 0.0/0.0/0.0
	Field sx:Float Ptr,sy:Float Ptr,sz:Float Ptr ' returned by EntityScaleX/Y/Z (local) - 1.0/1.0/1.0
	Field rx:Float Ptr,ry:Float Ptr,rz:Float Ptr ' rotation euler (unused) - 0.0/0.0/0.0
	Field qw:Float Ptr,qx:Float Ptr,qy:Float Ptr,qz:Float Ptr ' quaternion (unused) - 1.0/0.0/0.0/0.0
	
	' material
	Field brush:TBrush
	
	' visibility
	Field order:Int Ptr ' set in EntityOrder - 0
	Field alpha_order:Float Ptr ' distance from camera - 0.0
	Field hide:Int Ptr ' set in Hide/ShowEntity - false
	Field cull_radius:Float Ptr ' set in MeshCullRadius - 0.0
	
	' properties
	Field name:Byte Ptr ' string returned by EntityName - ""
	Field class_name:Byte Ptr ' string returned by EntityClass - ""
	
	' anim
	Global animate_list:TList=CreateList() ' openb3d: Entity list (currently animating)
	Field anim:Int Ptr ' true if mesh contains anim data - false
	Field anim_render:Int Ptr ' true to render as anim mesh - false
	Field anim_mode:Int Ptr ' 0
	Field anim_time:Float Ptr ' 0.0
	Field anim_speed:Float Ptr ' 0.0
	Field anim_seq:Int Ptr ' 0
	Field anim_trans:Int Ptr ' 0
	Field anim_dir:Int Ptr ' 1=forward, -1=backward - 1
	Field anim_seqs_first:Int Ptr ' vector animation frame sequences
	Field anim_seqs_last:Int Ptr ' vector
	Field no_seqs:Int Ptr ' 0
	Field anim_update:Int Ptr ' 0
	Field anim_list:Int Ptr ' openb3d: entity in animate_list - false
	
	' collisions
	Field collision_type:Int Ptr ' returned by GetEntityType - 0
	Field radius_x:Float Ptr,radius_y:Float Ptr ' set in EntityRadius - 1.0/1.0
	Field box_x:Float Ptr,box_y:Float Ptr,box_z:Float Ptr ' set in EntityBox - -1.0/-1.0/-1.0
	Field box_w:Float Ptr,box_h:Float Ptr,box_d:Float Ptr ' set in EntityBox - 2.0/2.0/2.0
	Field no_collisions:Int Ptr ' returned by CountCollisions - 0
	'Field collision:TList=CreateList() ' CollisionImpact vector - used in CollisionX/Y/Z/NX/NY/NZ/Time/Entity/Surface/Triangle
	'Field old_x:Float Ptr,old_y:Float Ptr,old_z:Float Ptr ' used by Collisions - 0.0/0.0/0.0
	'Field old_pitch:Float Ptr,old_yaw:Float Ptr,old_roll:Float Ptr ' openb3d
	'Field new_x:Float Ptr,new_y:Float Ptr,new_z:Float Ptr ' openb3d - 0.0/0.0/0.0
	'Field new_no:Int Ptr ' openb3d - 0
	
	'Field old_mat:TMatrix ' openb3d - LoadIdentity
	'Field dynamic:Int Ptr ' openb3d - false
	'Field dynamic_x:Float Ptr,dynamic_y:Float Ptr,dynamic_z:Float Ptr ' openb3d - 0.0/0.0/0.0
	'Field dynamic_yaw:Float Ptr,dynamic_pitch:Float Ptr,dynamic_roll:Float Ptr ' openb3d - 0.0/0.0/0.0
	
	' picking
	Field pick_mode:Int Ptr ' set in EntityPickMode - 0
	Field obscurer:Int Ptr ' set in EntityPickMode - false
	
	' tform
	Global tformed_x:Float Ptr ' returned by TFormedX - 0.0
	Global tformed_y:Float Ptr ' returned by TFormedY - 0.0
	Global tformed_z:Float Ptr ' returned by TFormedZ - 0.0
	
	' minib3d
	'Field auto_fade:Int,fade_near#,fade_far#,fade_alpha# ' EntityAutoFade
	'Field link:TLink ' entity_list tlink, for quick removal of entity from list (not used)
	
	' wrapper
	?bmxng
	Global ent_map:TPtrMap=New TPtrMap
	?Not bmxng
	Global ent_map:TMap=New TMap
	?
	Field instance:Byte Ptr
	
	Global entity_list_id:Int=0
	Global animate_list_id:Int=0
	Field child_list_id:Int=0
	Field exists:Int=0 ' FreeEntity
	Field is_anim:Int=0
	Global child_list_queue:TList=CreateList()
	
	Method CopyEntity:TEntity( parent_ent:TEntity=Null ) Abstract
	Method Update() Abstract
	
	'Function CreateObject:TEntity( inst:Byte Ptr ) ' Not needed
	
	Function FreeObject( inst:Byte Ptr )
	
		?bmxng
		ent_map.Remove( inst )
		?Not bmxng
		ent_map.Remove( String(Int(inst)) )
		?
		
	End Function
	
	Function GetObject:TEntity( inst:Byte Ptr )
	
		?bmxng
		Return TEntity( ent_map.ValueForKey( inst ) )
		?Not bmxng
		Return TEntity( ent_map.ValueForKey( String(Int(inst)) ) )
		?
		
	End Function
	
	Function GetInstance:Byte Ptr( obj:TEntity ) ' Get C++ instance from object
	
		If obj=Null Then Return Null ' Attempt to pass null object to function
		Return obj.instance
		
	End Function
	
	Function InitGlobals() ' Once per Graphics3D
	
		tformed_x=StaticFloat_( ENTITY_class,ENTITY_tformed_x )
		tformed_y=StaticFloat_( ENTITY_class,ENTITY_tformed_y )
		tformed_z=StaticFloat_( ENTITY_class,ENTITY_tformed_z )
		
	End Function
	
	Method InitFields() ' Once per CreateObject
	
		CopyList(child_list)
		
		' int
		order=EntityInt_( GetInstance(Self),ENTITY_order )
		hide=EntityInt_( GetInstance(Self),ENTITY_hide )
		anim=EntityInt_( GetInstance(Self),ENTITY_anim )
		anim_render=EntityInt_( GetInstance(Self),ENTITY_anim_render )
		anim_mode=EntityInt_( GetInstance(Self),ENTITY_anim_mode )
		anim_seq=EntityInt_( GetInstance(Self),ENTITY_anim_seq )
		anim_trans=EntityInt_( GetInstance(Self),ENTITY_anim_trans )
		anim_dir=EntityInt_( GetInstance(Self),ENTITY_anim_dir )
		anim_seqs_first=EntityInt_( GetInstance(Self),ENTITY_anim_seqs_first )
		anim_seqs_last=EntityInt_( GetInstance(Self),ENTITY_anim_seqs_last )
		no_seqs=EntityInt_( GetInstance(Self),ENTITY_no_seqs )
		anim_update=EntityInt_( GetInstance(Self),ENTITY_anim_update )
		anim_list=EntityInt_( GetInstance(Self),ENTITY_anim_list )
		collision_type=EntityInt_( GetInstance(Self),ENTITY_collision_type )
		no_collisions=EntityInt_( GetInstance(Self),ENTITY_no_collisions )
		'new_no=EntityInt_( GetInstance(Self),ENTITY_new_no )
		'dynamic=EntityInt_( GetInstance(Self),ENTITY_dynamic )
		pick_mode=EntityInt_( GetInstance(Self),ENTITY_pick_mode )
		obscurer=EntityInt_( GetInstance(Self),ENTITY_obscurer )
		
		' float
		px=EntityFloat_( GetInstance(Self),ENTITY_px )
		py=EntityFloat_( GetInstance(Self),ENTITY_py )
		pz=EntityFloat_( GetInstance(Self),ENTITY_pz )
		sx=EntityFloat_( GetInstance(Self),ENTITY_sx )
		sy=EntityFloat_( GetInstance(Self),ENTITY_sy )
		sz=EntityFloat_( GetInstance(Self),ENTITY_sz )
		rx=EntityFloat_( GetInstance(Self),ENTITY_rx )
		ry=EntityFloat_( GetInstance(Self),ENTITY_ry )
		rz=EntityFloat_( GetInstance(Self),ENTITY_rz )
		qw=EntityFloat_( GetInstance(Self),ENTITY_qw )
		qx=EntityFloat_( GetInstance(Self),ENTITY_qx )
		qy=EntityFloat_( GetInstance(Self),ENTITY_qy )
		qz=EntityFloat_( GetInstance(Self),ENTITY_qz )
		alpha_order=EntityFloat_( GetInstance(Self),ENTITY_alpha_order )
		cull_radius=EntityFloat_( GetInstance(Self),ENTITY_cull_radius )
		anim_time=EntityFloat_( GetInstance(Self),ENTITY_anim_time )
		anim_speed=EntityFloat_( GetInstance(Self),ENTITY_anim_speed )
		radius_x=EntityFloat_( GetInstance(Self),ENTITY_radius_x )
		radius_y=EntityFloat_( GetInstance(Self),ENTITY_radius_y )
		box_x=EntityFloat_( GetInstance(Self),ENTITY_box_x )
		box_y=EntityFloat_( GetInstance(Self),ENTITY_box_y )
		box_z=EntityFloat_( GetInstance(Self),ENTITY_box_z )
		box_w=EntityFloat_( GetInstance(Self),ENTITY_box_w )
		box_h=EntityFloat_( GetInstance(Self),ENTITY_box_h )
		box_d=EntityFloat_( GetInstance(Self),ENTITY_box_d )
		'old_x=EntityFloat_( GetInstance(Self),ENTITY_old_x )
		'old_y=EntityFloat_( GetInstance(Self),ENTITY_old_y )
		'old_z=EntityFloat_( GetInstance(Self),ENTITY_old_z )
		'old_pitch=EntityFloat_( GetInstance(Self),ENTITY_old_pitch )
		'old_yaw=EntityFloat_( GetInstance(Self),ENTITY_old_yaw )
		'old_roll=EntityFloat_( GetInstance(Self),ENTITY_old_roll )
		'new_x=EntityFloat_( GetInstance(Self),ENTITY_new_x )
		'new_y=EntityFloat_( GetInstance(Self),ENTITY_new_y )
		'new_z=EntityFloat_( GetInstance(Self),ENTITY_new_z )
		'dynamic_x=EntityFloat_( GetInstance(Self),ENTITY_dynamic_x )
		'dynamic_y=EntityFloat_( GetInstance(Self),ENTITY_dynamic_y )
		'dynamic_z=EntityFloat_( GetInstance(Self),ENTITY_dynamic_z )
		'dynamic_yaw=EntityFloat_( GetInstance(Self),ENTITY_dynamic_yaw )
		'dynamic_pitch=EntityFloat_( GetInstance(Self),ENTITY_dynamic_pitch )
		'dynamic_roll=EntityFloat_( GetInstance(Self),ENTITY_dynamic_roll )
		
		' string
		name=EntityString_( GetInstance(Self),ENTITY_name )
		class_name=EntityString_( GetInstance(Self),ENTITY_class_name )
		
		' entity
		Local inst:Byte Ptr=EntityEntity_( GetInstance(Self),ENTITY_parent )
		parent=GetObject(inst) ' no CreateObject
		
		If parent<>Null Then parent.CopyList(parent.child_list)
		
		' matrix
		inst=EntityMatrix2_( GetInstance(Self),ENTITY_mat )
		mat=TMatrix.GetObject(inst)
		If mat=Null And inst<>Null Then mat=TMatrix.CreateObject(inst)
		inst=EntityMatrix2_( GetInstance(Self),ENTITY_rotmat )
		rotmat=TMatrix.GetObject(inst)
		If rotmat=Null And inst<>Null Then rotmat=TMatrix.CreateObject(inst)
		'inst=EntityMatrix2_( GetInstance(Self),ENTITY_old_mat )
		'old_mat=TMatrix.GetObject(inst)
		'If old_mat=Null And inst<>Null Then old_mat=TMatrix.CreateObject(inst)
		
		' brush
		inst=EntityBrush_( GetInstance(Self),ENTITY_brush )
		brush=TBrush.GetObject(inst)
		If brush=Null And inst<>Null Then brush=TBrush.CreateObject(inst)
		
		CopyList_(entity_list)
		If parent=Null And TGlobal3D.root_ent Then CopyList_(TGlobal3D.root_ent.child_list) ' list of all non-child/root entities
		exists=1
		
	End Method
	
	Method DebugFields( debug_subobjects:Int=0,debug_base_types:Int=0 )
	
		Local pad:String
		Local loop:Int=debug_subobjects
		If debug_base_types>debug_subobjects Then loop=debug_base_types
		For Local i%=1 Until loop
			pad:+"  "
		Next
		If debug_subobjects Then debug_subobjects:+1
		If debug_base_types Then debug_base_types:+1
		DebugLog pad+" Entity instance: "+StringPtr(GetInstance(Self))
		
		' int
		If order<>Null Then DebugLog(pad+" order: "+order[0]) Else DebugLog(pad+" order: Null")
		If hide<>Null Then DebugLog(pad+" hide: "+hide[0]) Else DebugLog(pad+" hide: Null")
		If anim<>Null Then DebugLog(pad+" anim: "+anim[0]) Else DebugLog(pad+" anim: Null")
		If anim_render<>Null Then DebugLog(pad+" anim_render: "+anim_render[0]) Else DebugLog(pad+" anim_render: Null")
		If anim_mode<>Null Then DebugLog(pad+" anim_mode: "+anim_mode[0]) Else DebugLog(pad+" anim_mode: Null")
		If anim_seq<>Null Then DebugLog(pad+" anim_seq: "+anim_seq[0]) Else DebugLog(pad+" anim_seq: Null")
		If anim_trans<>Null Then DebugLog(pad+" anim_trans: "+anim_trans[0]) Else DebugLog(pad+" anim_trans: Null")
		If anim_dir<>Null Then DebugLog(pad+" anim_dir: "+anim_dir[0]) Else DebugLog(pad+" anim_dir: Null")
		If anim_seqs_first<>Null Then DebugLog(pad+" anim_seqs_first: "+anim_seqs_first[0]) Else DebugLog(pad+" anim_seqs_first: Null")
		If anim_seqs_last<>Null Then DebugLog(pad+" anim_seqs_last: "+anim_seqs_last[0]) Else DebugLog(pad+" anim_seqs_last: Null")
		If no_seqs<>Null Then DebugLog(pad+" no_seqs: "+no_seqs[0]) Else DebugLog(pad+" no_seqs: Null")
		If anim_update<>Null Then DebugLog(pad+" anim_update: "+anim_update[0]) Else DebugLog(pad+" anim_update: Null")
		If anim_list<>Null Then DebugLog(pad+" anim_list: "+anim_list[0]) Else DebugLog(pad+" anim_list: Null")
		If collision_type<>Null Then DebugLog(pad+" collision_type: "+collision_type[0]) Else DebugLog(pad+" collision_type: Null")
		If no_collisions<>Null Then DebugLog(pad+" no_collisions: "+no_collisions[0]) Else DebugLog(pad+" no_collisions: Null")
		'If new_no<>Null Then DebugLog(pad+" new_no: "+new_no[0]) Else DebugLog(pad+" new_no: Null")
		'If dynamic<>Null Then DebugLog(pad+" dynamic: "+dynamic[0]) Else DebugLog(pad+" dynamic: Null")
		If pick_mode<>Null Then DebugLog(pad+" pick_mode: "+pick_mode[0]) Else DebugLog(pad+" pick_mode: Null")
		If obscurer<>Null Then DebugLog(pad+" obscurer: "+obscurer[0]) Else DebugLog(pad+" obscurer: Null")
		
		' float
		If px<>Null Then DebugLog(pad+" px: "+px[0]) Else DebugLog(pad+" px: Null")
		If py<>Null Then DebugLog(pad+" py: "+py[0]) Else DebugLog(pad+" py: Null")
		If pz<>Null Then DebugLog(pad+" pz: "+pz[0]) Else DebugLog(pad+" pz: Null")
		If sx<>Null Then DebugLog(pad+" sx: "+sx[0]) Else DebugLog(pad+" sx: Null")
		If sy<>Null Then DebugLog(pad+" sy: "+sy[0]) Else DebugLog(pad+" sy: Null")
		If sz<>Null Then DebugLog(pad+" sz: "+sz[0]) Else DebugLog(pad+" sz: Null")
		If rx<>Null Then DebugLog(pad+" rx: "+rx[0]) Else DebugLog(pad+" rx: Null")
		If ry<>Null Then DebugLog(pad+" ry: "+ry[0]) Else DebugLog(pad+" ry: Null")
		If rz<>Null Then DebugLog(pad+" rz: "+rz[0]) Else DebugLog(pad+" rz: Null")
		If qw<>Null Then DebugLog(pad+" qw: "+qw[0]) Else DebugLog(pad+" qw: Null")
		If qx<>Null Then DebugLog(pad+" qx: "+qx[0]) Else DebugLog(pad+" qx: Null")
		If qy<>Null Then DebugLog(pad+" qy: "+qy[0]) Else DebugLog(pad+" qy: Null")
		If qz<>Null Then DebugLog(pad+" qz: "+qz[0]) Else DebugLog(pad+" qz: Null")
		If alpha_order<>Null Then DebugLog(pad+" alpha_order: "+alpha_order[0]) Else DebugLog(pad+" alpha_order: Null")
		If cull_radius<>Null Then DebugLog(pad+" cull_radius: "+cull_radius[0]) Else DebugLog(pad+" cull_radius: Null")
		If anim_time<>Null Then DebugLog(pad+" anim_time: "+anim_time[0]) Else DebugLog(pad+" anim_time: Null")
		If anim_speed<>Null Then DebugLog(pad+" anim_speed: "+anim_speed[0]) Else DebugLog(pad+" anim_speed: Null")
		If radius_x<>Null Then DebugLog(pad+" radius_x: "+radius_x[0]) Else DebugLog(pad+" radius_x: Null")
		If radius_y<>Null Then DebugLog(pad+" radius_y: "+radius_y[0]) Else DebugLog(pad+" radius_y: Null")
		If box_x<>Null Then DebugLog(pad+" box_x: "+box_x[0]) Else DebugLog(pad+" box_x: Null")
		If box_y<>Null Then DebugLog(pad+" box_y: "+box_y[0]) Else DebugLog(pad+" box_y: Null")
		If box_z<>Null Then DebugLog(pad+" box_z: "+box_z[0]) Else DebugLog(pad+" box_z: Null")
		If box_w<>Null Then DebugLog(pad+" box_w: "+box_w[0]) Else DebugLog(pad+" box_w: Null")
		If box_h<>Null Then DebugLog(pad+" box_h: "+box_h[0]) Else DebugLog(pad+" box_h: Null")
		If box_d<>Null Then DebugLog(pad+" box_d: "+box_d[0]) Else DebugLog(pad+" box_d: Null")
		'If old_x<>Null Then DebugLog(pad+" old_x: "+old_x[0]) Else DebugLog(pad+" old_x: Null")
		'If old_y<>Null Then DebugLog(pad+" old_y: "+old_y[0]) Else DebugLog(pad+" old_y: Null")
		'If old_z<>Null Then DebugLog(pad+" old_z: "+old_z[0]) Else DebugLog(pad+" old_z: Null")
		'If old_pitch<>Null Then DebugLog(pad+" old_pitch: "+old_pitch[0]) Else DebugLog(pad+" old_pitch: Null")
		'If old_yaw<>Null Then DebugLog(pad+" old_yaw: "+old_yaw[0]) Else DebugLog(pad+" old_yaw: Null")
		'If old_roll<>Null Then DebugLog(pad+" old_roll: "+old_roll[0]) Else DebugLog(pad+" old_roll: Null")
		'If new_x<>Null Then DebugLog(pad+" new_x: "+new_x[0]) Else DebugLog(pad+" new_x: Null")
		'If new_y<>Null Then DebugLog(pad+" new_y: "+new_y[0]) Else DebugLog(pad+" new_y: Null")
		'If new_z<>Null Then DebugLog(pad+" new_z: "+new_z[0]) Else DebugLog(pad+" new_z: Null")
		'If dynamic_x<>Null Then DebugLog(pad+" dynamic_x: "+dynamic_x[0]) Else DebugLog(pad+" dynamic_x: Null")
		'If dynamic_y<>Null Then DebugLog(pad+" dynamic_y: "+dynamic_y[0]) Else DebugLog(pad+" dynamic_y: Null")
		'If dynamic_z<>Null Then DebugLog(pad+" dynamic_z: "+dynamic_z[0]) Else DebugLog(pad+" dynamic_z: Null")
		'If dynamic_yaw<>Null Then DebugLog(pad+" dynamic_yaw: "+dynamic_yaw[0]) Else DebugLog(pad+" dynamic_yaw: Null")
		'If dynamic_pitch<>Null Then DebugLog(pad+" dynamic_pitch: "+dynamic_pitch[0]) Else DebugLog(pad+" dynamic_pitch: Null")
		'If dynamic_roll<>Null Then DebugLog(pad+" dynamic_roll: "+dynamic_roll[0]) Else DebugLog(pad+" dynamic_roll: Null")
		
		' string
		If name<>Null Then DebugLog(pad+" name: "+GetString(name)) Else DebugLog(pad+" name: Null")
		If class_name<>Null Then DebugLog(pad+" class_name: "+GetString(class_name)) Else DebugLog(pad+" class_name: Null")
		
		' entity
		DebugLog pad+" parent: "+StringPtr(GetInstance(parent))
		If debug_subobjects And parent<>Null Then parent.DebugFields( debug_subobjects,debug_base_types )
		
		' matrix
		DebugLog pad+" mat: "+StringPtr(TMatrix.GetInstance(mat))
		If debug_subobjects And mat<>Null Then mat.DebugFields( debug_subobjects,debug_base_types )
		DebugLog pad+" rotmat: "+StringPtr(TMatrix.GetInstance(rotmat))
		If debug_subobjects And rotmat<>Null Then rotmat.DebugFields( debug_subobjects,debug_base_types )
		'DebugLog pad+" old_mat: "+StringPtr(TMatrix.GetInstance(old_mat))
		'If debug_subobjects And old_mat<>Null Then old_mat.DebugFields( debug_subobjects,debug_base_types )
		
		' brush
		DebugLog pad+" brush: "+StringPtr(TBrush.GetInstance(brush))
		If debug_subobjects And brush<>Null Then brush.DebugFields( debug_subobjects,debug_base_types )
		
		' lists
		For Local child:TEntity=EachIn child_list
			DebugLog pad+" child_list: "+StringPtr(GetInstance(child))
			If debug_subobjects And child<>Null Then child.DebugFields( debug_subobjects,debug_base_types )
		Next
		
		DebugLog ""
		
	End Method
	
	Method AddList( list:TList ) ' Field list
	
		Select list
			Case child_list
				If EntityListSize_( GetInstance(Self),ENTITY_child_list )
					Local inst:Byte Ptr=EntityIterListEntity_( GetInstance(Self),ENTITY_child_list,Varptr child_list_id )
					Local obj:TEntity=GetObject(inst) ' no CreateObject
					If obj Then ListAddLast( list,obj )
				EndIf
			Case TGlobal3D.root_ent.child_list
				If EntityListSize_( GetInstance(TGlobal3D.root_ent),ENTITY_child_list )
					Local inst:Byte Ptr=EntityIterListEntity_( GetInstance(TGlobal3D.root_ent),ENTITY_child_list,Varptr TGlobal3D.root_ent.child_list_id )
					Local obj:TEntity=GetObject(inst) ' no CreateObject
					If obj And ListContains( list,obj )=0 Then ListAddLast( list,obj )
				EndIf
		End Select
		
	End Method
	
	Function AddList_( list:TList ) ' Global list
	
		Select list
			Case entity_list
				If StaticListSize_( ENTITY_class,ENTITY_entity_list )
					Local inst:Byte Ptr=StaticIterListEntity_( ENTITY_class,ENTITY_entity_list,Varptr entity_list_id )
					Local obj:TEntity=GetObject(inst) ' no CreateObject
					If obj Then ListAddLast( list,obj )
				EndIf
			Case animate_list
				If StaticListSize_( ENTITY_class,ENTITY_animate_list )
					Local inst:Byte Ptr=StaticIterListEntity_( ENTITY_class,ENTITY_animate_list,Varptr animate_list_id )
					Local obj:TEntity=GetObject(inst) ' no CreateObject
					If obj And ListContains( list,obj )=0 Then ListAddLast( list,obj )
				EndIf
		End Select
		
	End Function
	
	Method CopyList( list:TList ) ' Field list
	
		ClearList list
		Local created:Int=0
		
		Select list
			Case child_list
				child_list_id=0
				For Local id:Int=0 To EntityListSize_( GetInstance(Self),ENTITY_child_list )-1
					Local inst:Byte Ptr=EntityIterListEntity_( GetInstance(Self),ENTITY_child_list,Varptr child_list_id )
					Local obj:TEntity=GetObject(inst) ' no CreateObject
					If obj=Null And inst<>Null And ListContains( child_list_queue,Self )=0
						ListAddLast( child_list_queue,Self ) ' store in queue
					EndIf
					If obj Then ListAddLast( list,obj )
				Next
				For Local ent:TEntity=EachIn child_list_queue
					ent.child_list_id=0 ; created=1
					For Local id:Int=0 To EntityListSize_( GetInstance(ent),ENTITY_child_list )-1
						Local inst:Byte Ptr=EntityIterListEntity_( GetInstance(ent),ENTITY_child_list,Varptr ent.child_list_id )
						Local obj:TEntity=GetObject(inst)
						If obj=Null Then created=0 ; Exit ' list not fully created yet
					Next
					If created
						ent.child_list_id=0
						ListRemove( child_list_queue,ent )
						For Local id:Int=0 To EntityListSize_( GetInstance(ent),ENTITY_child_list )-1
							Local inst:Byte Ptr=EntityIterListEntity_( GetInstance(ent),ENTITY_child_list,Varptr ent.child_list_id )
							Local obj:TEntity=GetObject(inst)
							If obj Then ListAddLast( ent.child_list,obj )
						Next
					EndIf
				Next
		End Select
			
	End Method
	
	Function CopyList_( list:TList ) ' Global list
	
		ClearList list
		
		Select list
			Case entity_list
				entity_list_id=0
				For Local id:Int=0 To StaticListSize_( ENTITY_class,ENTITY_entity_list )-1
					Local inst:Byte Ptr=StaticIterListEntity_( ENTITY_class,ENTITY_entity_list,Varptr entity_list_id )
					Local obj:TEntity=GetObject(inst) ' no CreateObject
					If obj Then ListAddLast( list,obj )
				Next
			Case animate_list
				animate_list_id=0
				For Local id:Int=0 To StaticListSize_( ENTITY_class,ENTITY_animate_list )-1
					Local inst:Byte Ptr=StaticIterListEntity_( ENTITY_class,ENTITY_animate_list,Varptr animate_list_id )
					Local obj:TEntity=GetObject(inst) ' no CreateObject
					If obj Then ListAddLast( list,obj )
				Next
			Case TGlobal3D.root_ent.child_list
				TGlobal3D.root_ent.child_list_id=0
				For Local id:Int=0 To EntityListSize_( GetInstance(TGlobal3D.root_ent),ENTITY_child_list )-1
					Local inst:Byte Ptr=EntityIterListEntity_( GetInstance(TGlobal3D.root_ent),ENTITY_child_list,Varptr TGlobal3D.root_ent.child_list_id )
					Local obj:TEntity=GetObject(inst) ' no CreateObject
					If obj Then ListAddLast( list,obj )
				Next
		End Select
		
	End Function
	
	Method EntityListAdd( list:TList,value:Object=Null )
	
		Local ent:TEntity=TEntity(value)
		
		Select list
			Case child_list
				If ent
					EntityListPushBackEntity_( GetInstance(Self),ENTITY_child_list,GetInstance(ent) )
					AddList(list)
				EndIf
			Case TGlobal3D.root_ent.child_list
				If ent
					EntityListPushBackEntity_( GetInstance(TGlobal3D.root_ent),ENTITY_child_list,GetInstance(ent) )
					AddList(list)
				EndIf
			Case entity_list
				GlobalListPushBackEntity_( ENTITY_entity_list,GetInstance(Self) )
				AddList_(list)
			Case animate_list
				GlobalListPushBackEntity_( ENTITY_animate_list,GetInstance(Self) )
				AddList_(list)
		End Select
		
	End Method
	
	Method EntityListRemove( list:TList,value:Object=Null )
	
		Local ent:TEntity=TEntity(value)
		
		Select list
			Case child_list
				If ent
					EntityListRemoveEntity_( GetInstance(Self),ENTITY_child_list,GetInstance(ent) )
					ListRemove( list,value ) ; child_list_id:-1
				EndIf
			Case TGlobal3D.root_ent.child_list
				EntityListRemoveEntity_( GetInstance(TGlobal3D.root_ent),ENTITY_child_list,GetInstance(Self) )
				ListRemove( list,Self ) ; TGlobal3D.root_ent.child_list_id:-1
			Case entity_list
				GlobalListRemoveEntity_( ENTITY_entity_list,GetInstance(Self) )
				ListRemove( list,Self ) ; entity_list_id:-1
			Case animate_list
				GlobalListRemoveEntity_( ENTITY_animate_list,GetInstance(Self) )
				ListRemove( list,Self ) ; animate_list_id:-1
		End Select
		
	End Method
	
	' Openb3d
	
	Method AddAnimSeq:Int( length:Int )
	
		Local seq:Int=AddAnimSeq_( GetInstance(Self),length )
		Local mesh:TMesh=TMesh(Self)
		If mesh<>Null
			If anim[0]=0
				CopyList(mesh.surf_list)
				CopyList(mesh.anim_surf_list)
				For Local surf:TSurface=EachIn mesh.surf_list
					surf.vert_coords=SurfaceFloat_( TSurface.GetInstance(surf),SURFACE_vert_coords )
				Next
				For Local surf:TSurface=EachIn mesh.anim_surf_list
					surf.vert_coords=SurfaceFloat_( TSurface.GetInstance(surf),SURFACE_vert_coords )
					surf.vert_weight4=SurfaceFloat_( TSurface.GetInstance(surf),SURFACE_vert_weight4 )
				Next
			ElseIf anim[0]=1
				anim_seqs_first=EntityInt_( GetInstance(Self),ENTITY_anim_seqs_first )
				anim_seqs_last=EntityInt_( GetInstance(Self),ENTITY_anim_seqs_last )
				For Local bone:TBone=EachIn mesh.bones
					bone.keys.flags=AnimationKeysInt_( TAnimationKeys.GetInstance(bone.keys),ANIMATIONKEYS_flags )
					bone.keys.px=AnimationKeysFloat_( TAnimationKeys.GetInstance(bone.keys),ANIMATIONKEYS_px )
					bone.keys.py=AnimationKeysFloat_( TAnimationKeys.GetInstance(bone.keys),ANIMATIONKEYS_py )
					bone.keys.pz=AnimationKeysFloat_( TAnimationKeys.GetInstance(bone.keys),ANIMATIONKEYS_pz )
					bone.keys.sx=AnimationKeysFloat_( TAnimationKeys.GetInstance(bone.keys),ANIMATIONKEYS_sx )
					bone.keys.sy=AnimationKeysFloat_( TAnimationKeys.GetInstance(bone.keys),ANIMATIONKEYS_sy )
					bone.keys.sz=AnimationKeysFloat_( TAnimationKeys.GetInstance(bone.keys),ANIMATIONKEYS_sz )
					bone.keys.qw=AnimationKeysFloat_( TAnimationKeys.GetInstance(bone.keys),ANIMATIONKEYS_qw )
					bone.keys.qx=AnimationKeysFloat_( TAnimationKeys.GetInstance(bone.keys),ANIMATIONKEYS_qx )
					bone.keys.qy=AnimationKeysFloat_( TAnimationKeys.GetInstance(bone.keys),ANIMATIONKEYS_qy )
					bone.keys.qz=AnimationKeysFloat_( TAnimationKeys.GetInstance(bone.keys),ANIMATIONKEYS_qz )
				Next
			ElseIf anim[0]=2
				For Local surf:TSurface=EachIn mesh.anim_surf_list
					surf.vert_weight4=SurfaceFloat_( TSurface.GetInstance(surf),SURFACE_vert_weight4 )
				Next
			EndIf
		EndIf
		Return seq
		
	End Method
	
	Method SetAnimKey( frame:Float,pos_key:Int=True,rot_key:Int=True,scale_key:Int=True )
	
		SetAnimKey_( GetInstance(Self),frame,pos_key,rot_key,scale_key )
		
	End Method
	
	' Aligns an entity axis to a vector
	Method AlignToVector( x:Float,y:Float,z:Float,axis:Int,rate:Float=1 )
	
		AlignToVector_( GetInstance(Self),x,y,z,axis,rate )
		
	End Method
	
	' Extra
	
	Method GetString:String( strPtr:Byte Ptr )
	
		Select strPtr
			Case name
				Return String.FromCString( EntityString_( GetInstance(Self),ENTITY_name ) )
			Case class_name
				Return String.FromCString( EntityString_( GetInstance(Self),ENTITY_class_name ) )
		End Select
		
	End Method
	
	Method SetString( strPtr:Byte Ptr, strValue:String )
	
		Select strPtr
			Case name
				Local cString:Byte Ptr=strValue.ToCString()
				SetEntityString_( GetInstance(Self),ENTITY_name,cString )
				MemFree cString
				name=EntityString_( GetInstance(Self),ENTITY_name )
			Case class_name
				Local cString:Byte Ptr=strValue.ToCString()
				SetEntityString_( GetInstance(Self),ENTITY_class_name,cString )
				MemFree cString
				class_name=EntityString_( GetInstance(Self),ENTITY_class_name )
		End Select
		
	End Method
	
	' Minib3d
	
	Method New()
	
		If TGlobal3D.Log_New
			DebugLog " New TEntity"
		EndIf
	
	End Method
	
	Method Delete()
	
		If TGlobal3D.Log_Del
			DebugLog " Del TEntity"
		EndIf
	
	End Method
	
	Method FreeEntity()
	
		If exists
			exists=0
			Local inst:Byte Ptr=GetInstance(Self)
			FreeEntityList()
			FreeEntity_(inst)
		EndIf
		
	End Method
	
	' recursively free entity lists and objects
	Method FreeEntityList()
	
		TMatrix.FreeObject( TMatrix.GetInstance(mat) ) ; mat=Null
		TMatrix.FreeObject( TMatrix.GetInstance(rotmat) ) ; rotmat=Null
		'TMatrix.FreeObject( TMatrix.GetInstance(old_mat) ) ; old_mat=Null
		TBrush.FreeObject( TBrush.GetInstance(brush) ) ; brush=Null
		
		ListRemove( entity_list,Self ) ; entity_list_id:-1
		If anim_update[0] Then ListRemove( animate_list,Self ) ; animate_list_id:-1
		If pick_mode[0] Then ListRemove( TPick.ent_list,Self ) ; TPick.ent_list_id:-1
		
		If parent
			ListRemove( parent.child_list,Self ) ; parent.child_list_id:-1
		ElseIf ListContains( TGlobal3D.root_ent.child_list,Self )
			ListRemove( TGlobal3D.root_ent.child_list,Self ) ; TGlobal3D.root_ent.child_list_id:-1
		EndIf
		
		For Local ent:TEntity=EachIn child_list
			If ent.exists
				ent.exists=0
				ent.FreeEntityList() ' recursive
			EndIf
		Next
		
		ClearList(child_list) ; child_list_id=0
		FreeObject( GetInstance(Self) ) ' no FreeEntity_
		
	End Method
	
	' replace parent with new_par
	Method SetParent( new_par:TEntity )
	
		If parent<>Null
			parent.EntityListRemove( parent.child_list,Self )
			parent=Null
		Else
			TGlobal3D.root_ent.EntityListRemove( TGlobal3D.root_ent.child_list,Self )
		EndIf
		
		AddParent( new_par )
		
	End Method
	
	' Entity movement (position)
	
	Method PositionEntity( x:Float,y:Float,z:Float,glob:Int=False )
	
		PositionEntity_( GetInstance(Self),x,y,z,glob )
		
	End Method
	
	Method MoveEntity( x:Float,y:Float,z:Float )
	
		MoveEntity_( GetInstance(Self),x,y,z )
		
	End Method
	
	Method TranslateEntity( x:Float,y:Float,z:Float,glob:Int=False )
	
		TranslateEntity_( GetInstance(Self),x,y,z,glob )
		
	End Method
	
	Method ScaleEntity( x:Float,y:Float,z:Float,glob:Int=False )
	
		ScaleEntity_( GetInstance(Self),x,y,z,glob )
		
	End Method
	
	Method RotateEntity( x:Float,y:Float,z:Float,glob:Int=False )
	
		RotateEntity_( GetInstance(Self),-x,y,z,glob ) ' inverted pitch
		
	End Method
	
	Method TurnEntity( x:Float,y:Float,z:Float,glob:Int=False )
	
		TurnEntity_( GetInstance(Self),-x,y,z,glob ) ' inverted pitch
		
	End Method
	
	Method PointEntity( target_ent:TEntity,roll:Float=0 ) ' Function by mongia2
	
		PointEntity_( GetInstance(Self),GetInstance(target_ent),roll )
		
	End Method
	
	' Entity animation
	
	' load anim seq - copies anim data from mesh to self
	Method LoadAnimSeq:Int( file:String )
	
		Local cString:Byte Ptr=file.ToCString()
		Local seqnum:Int=LoadAnimSeq_( GetInstance(Self),cString )
		MemFree cString
		Return seqnum
		
	End Method
	
	Method ExtractAnimSeq:Int( first_frame:Int,last_frame:Int,seq:Int=0 )
	
		Return ExtractAnimSeq_( GetInstance(Self),first_frame,last_frame,seq )
		
	End Method
	
	Method Animate( Mode:Int=1,speed:Float=1,seq:Int=0,trans:Int=0 )
	
		If anim_list[0]=0 Then ListAddLast( animate_list,Self ) ; animate_list_id:+1
		
		Animate_( GetInstance(Self),Mode,speed,seq,trans )
		
	End Method
	
	Method SetAnimTime( time:Float,seq:Int=0 )
	
		SetAnimTime_( GetInstance(Self),time,seq )
		
	End Method
	
	Method AnimSeq:Int()
	
		Return AnimSeq_( GetInstance(Self) )
		
	End Method
	
	Method AnimLength:Int()
	
		Return AnimLength_( GetInstance(Self) )
		
	End Method
	
	Method AnimTime:Float()
	
		Return AnimTime_( GetInstance(Self) )
		
	End Method
	
	Method Animating:Int()
	
		Return Animating_( GetInstance(Self) )
		
	End Method
	
	' Entity control (material)
	
	Method EntityColor( red:Float,green:Float,blue:Float,recursive:Int=True )
	
		EntityColor_( GetInstance(Self),red,green,blue,recursive )
		
	End Method
	
	Method EntityAlpha( alpha:Float )
	
		EntityAlpha_( GetInstance(Self),alpha )
		
	End Method
	
	Method EntityShininess( shine:Float )
	
		EntityShininess_( GetInstance(Self),shine )
		
	End Method
	
	Method EntityTexture( tex:TTexture,frame:Int=0,index:Int=0 )
	
		EntityTexture_( GetInstance(Self),TTexture.GetInstance(tex),frame,index )
		
		If brush<>Null Then brush.InitFields()
		For Local ent:TEntity=EachIn child_list
			If ent.brush<>Null Then ent.brush.InitFields()
		Next
		
	End Method
	
	Method EntityBlend( blend:Int )
	
		EntityBlend_( GetInstance(Self),blend )
		
	End Method
	
	Method EntityFX( fx:Int )
	
		EntityFX_( GetInstance(Self),fx )
		
	End Method
	
	Method PaintEntity( bru:TBrush )
	
		PaintEntity_( GetInstance(Self),TBrush.GetInstance(bru) )
		
		If brush<>Null Then brush.InitFields()
		
	End Method
	
	Method GetEntityBrush:TBrush() ' same as function in TBrush
	
		Local inst:Byte Ptr=GetEntityBrush_( GetInstance(Self) )
		Local brush:TBrush=TBrush.GetObject(inst)
		If brush=Null And inst<>Null Then brush=TBrush.CreateObject(inst)
		Return brush
		
	End Method
	
	' visibility
	
	Method EntityOrder( order:Int )
	
		EntityOrder_( GetInstance(Self),order )
		
	End Method
	
	Method ShowEntity()
	
		If TCamera(Self) Then TGlobal3D.camera_in_use=TCamera(Self)
		ShowEntity_( GetInstance(Self) )
		
	End Method
	
	Method HideEntity()
	
		HideEntity_( GetInstance(Self) )
		
	End Method
	
	' properties
	
	Method NameEntity( name:String )
	
		Local cString:Byte Ptr=name.ToCString()
		NameEntity_( GetInstance(Self),cString )
		MemFree cString
		
	End Method
	
	' relations
	
	Method EntityParent( parent_ent:TEntity,glob:Int=True )
	
		EntityParent_( GetInstance(Self),GetInstance(parent_ent),glob )
		
	End Method
	
	Method GetParent:TEntity()
	
		Local inst:Byte Ptr=GetParentEntity_( GetInstance(Self) )
		Return GetObject(inst) ' no CreateObject
		
	End Method
	
	' Entity state (position)
	
	Method EntityX:Float( glob:Int=False )
	
		Return EntityX_( GetInstance(Self),glob )
		
	End Method
	
	Method EntityY:Float( glob:Int=False )
	
		Return EntityY_( GetInstance(Self),glob )
		
	End Method
	
	Method EntityZ:Float( glob:Int=False )
	
		Return EntityZ_( GetInstance(Self),glob )
		
	End Method
	
	Method EntityPitch:Float( glob:Int=False )
	
		Return -EntityPitch_( GetInstance(Self),glob ) ' inverted pitch
		
	End Method
	
	Method EntityYaw:Float( glob:Int=False )
	
		Return EntityYaw_( GetInstance(Self),glob )
		
	End Method
	
	Method EntityRoll:Float( glob:Int=True )
	
		Return EntityRoll_( GetInstance(Self),glob )
		
	End Method
	
	' properties
	
	Method EntityClass:String()
	
		Return String.FromCString( EntityString_( GetInstance(Self),ENTITY_class_name ) )
		
	End Method
	
	Method EntityName:String()
	
		Return String.FromCString( EntityString_( GetInstance(Self),ENTITY_name ) )
		
	End Method
	
	' relations
	
	Method CountChildren:Int()
	
		Return CountChildren_( GetInstance(Self) )
		
	End Method
	
	Method GetChild:TEntity( child_no:Int )
	
		Local inst:Byte Ptr=GetChild_( GetInstance(Self),child_no )
		Return GetObject(inst) ' no CreateObject
		
	End Method
	
	Method FindChild:TEntity( child_name:String )
	
		Local cString:Byte Ptr=child_name.ToCString()
		Local inst:Byte Ptr=FindChild_( GetInstance(Self),cString )
		MemFree cString
		Return GetObject(inst) ' no CreateObject
		
	End Method
	
	' picking
	
	Method EntityPick:TEntity( Range:Float ) ' same as function in TPick
	
		Local inst:Byte Ptr=EntityPick_( GetInstance(Self),Range )
		Return GetObject(inst) ' no CreateObject
		
	End Method
	
	' same as function in TPick
	Method LinePick:TEntity( x:Float,y:Float,z:Float,dx:Float,dy:Float,dz:Float,radius:Float=0 )
	
		Local inst:Byte Ptr=LinePick_( x,y,z,dx,dy,dz,radius )
		Return GetObject(inst) ' no CreateObject
		
	End Method
	
	Method EntityVisible:Int( src_ent:TEntity,dest_ent:TEntity ) ' same as function in TPick
	
		Return EntityVisible_( GetInstance(src_ent),GetInstance(dest_ent) )
		
	End Method
	
	' distance
	
	Method EntityDistance:Float( ent2:TEntity )
	
		Return EntityDistance_( GetInstance(Self),GetInstance(ent2) )
		
	End Method
	
	Method DeltaYaw:Float( ent2:TEntity ) ' Function by Vertex
	
		Return DeltaYaw_( GetInstance(Self),GetInstance(ent2) )
		
	End Method
	
	Method DeltaPitch:Float( ent2:TEntity ) ' Function by Vertex
	
		Return -DeltaPitch_( GetInstance(Self),GetInstance(ent2) ) ' inverted pitch
		
	End Method
	
	' tform
	
	Function TFormPoint( x:Float,y:Float,z:Float,src_ent:TEntity,dest_ent:TEntity )
	
		TFormPoint_( x,y,z,GetInstance(src_ent),GetInstance(dest_ent) )
		
	End Function
	
	Function TFormVector( x:Float,y:Float,z:Float,src_ent:TEntity,dest_ent:TEntity )
	
		TFormVector_( x,y,z,GetInstance(src_ent),GetInstance(dest_ent) )
		
	End Function
	
	Function TFormNormal( x:Float,y:Float,z:Float,src_ent:TEntity,dest_ent:TEntity )
	
		TFormNormal_( x,y,z,GetInstance(src_ent),GetInstance(dest_ent) )
		
	End Function
	
	Function TFormedX:Float()
	
		Return TFormedX_()
		
	End Function
	
	Function TFormedY:Float()
	
		Return TFormedY_()
		
	End Function
	
	Function TFormedZ:Float()
	
		Return TFormedZ_()
		
	End Function
	
	Method GetMatElement:Float( row:Int,col:Int )
	
		'Return GetMatElement_( GetInstance(Self),row,col )
		
		Return mat.grid[(4*row)+col]
		
	End Method
	
	' Entity collision
	
	Method ResetEntity()
	
		ResetEntity_( GetInstance(Self) )
		
	End Method
	
	Method EntityRadius( radius_x:Float,radius_y:Float=0 )
	
		EntityRadius_( GetInstance(Self),radius_x,radius_y )
		
	End Method
	
	Method EntityBox( x:Float,y:Float,z:Float,w:Float,h:Float,d:Float )
	
		EntityBox_( GetInstance(Self),x,y,z,w,h,d )
		
	End Method
	
	Method EntityType( type_no:Int,recursive:Int=False )
	
		EntityType_( GetInstance(Self),type_no,recursive )
		
	End Method
	
	' picking
	
	Method EntityPickMode( pick_mode_no:Int,obscurer:Int=True )
	
		EntityPickMode_( GetInstance(Self),pick_mode_no,obscurer )
		
		If pick_mode_no Then TPick.AddList_(TPick.ent_list)
		If pick_mode_no=0 Then ListRemove( TPick.ent_list,Self ) ; TPick.ent_list_id:-1
		
	End Method
	
	' collisions
	
	Method EntityCollided:TEntity( type_no:Int )
	
		Local inst:Byte Ptr=EntityCollided_( GetInstance(Self),type_no )
		Return GetObject(inst) ' no CreateObject
		
	End Method
	
	Method CountCollisions:Int()
	
		Return CountCollisions_( GetInstance(Self) )
		
	End Method
	
	Method CollisionX:Float( index:Int )
	
		Return CollisionX_( GetInstance(Self),index )
		
	End Method
	
	Method CollisionY:Float( index:Int )
	
		Return CollisionY_( GetInstance(Self),index )
		
	End Method
	
	Method CollisionZ:Float( index:Int )
	
		Return CollisionZ_( GetInstance(Self),index )
		
	End Method
	
	Method CollisionNX:Float( index:Int )
	
		Return CollisionNX_( GetInstance(Self),index )
		
	End Method
	
	Method CollisionNY:Float( index:Int )
	
		Return CollisionNY_( GetInstance(Self),index )
		
	End Method
	
	Method CollisionNZ:Float( index:Int )
	
		Return CollisionNZ_( GetInstance(Self),index )
		
	End Method
	
	Method CollisionTime:Float( index:Int )
	
		Return CollisionTime_( GetInstance(Self),index )
		
	End Method
	
	Method CollisionEntity:TEntity( index:Int )
	
		Local inst:Byte Ptr=CollisionEntity_( GetInstance(Self),index )
		Return GetObject(inst) ' no CreateObject
		
	End Method
	
	Method CollisionSurface:TSurface( index:Int )
	
		Local inst:Byte Ptr=CollisionSurface_( GetInstance(Self),index )
		Return TSurface.GetObject(inst) ' no CreateObject
		
	End Method
	
	Method CollisionTriangle:Int( index:Int )
	
		Return CollisionTriangle_( GetInstance(Self),index )
		
	End Method
	
	Method GetEntityType:Int()
	
		Return GetEntityType_( GetInstance(Self) )
		
	End Method
	
	' Sets an entity's mesh cull radius
	Method MeshCullRadius( radius:Float )
	
		MeshCullRadius_( GetInstance(Self),radius )
		
	End Method
	
	' position
	
	Method EntityScaleX:Float( glob:Int=False )
	
		Return EntityScaleX_( GetInstance(Self),glob )
		
	End Method
	
	Method EntityScaleY:Float( glob:Int=False )
	
		Return EntityScaleY_( GetInstance(Self),glob )
		
	End Method
	
	Method EntityScaleZ:Float( glob:Int=False )
	
		Return EntityScaleZ_( GetInstance(Self),glob )
		
	End Method
	
	' Internal - not recommended for general use (helper funcs)
	
	'Method CopyEntity:TEntity( parent:TEntity=Null )
	'Method Update() ' empty
	
	' Returns if an entity or it's parent is hidden
	Method Hidden:Int()
	
		Return Hidden_( GetInstance(Self) )
		
	End Method
	
	' Recursively counts all children of an entity
	Function CountAllChildren:Int( ent:TEntity,no_children:Int=0 )
	
		Return CountAllChildren_( GetInstance(ent),no_children )
		
	End Function
	
	' Returns the specified child entity of a parent entity
	Method GetChildFromAll:TEntity( child_no:Int,no_children:Int Var,ent:TEntity=Null )
	
		Local inst:Byte Ptr=GetChildFromAll_( GetInstance(Self),child_no,Varptr no_children,GetInstance(ent) )
		Return GetObject(inst) ' no CreateObject
		
	End Method
	
	' recursively adds all parents of ent to list, ent.ListParents(list)
	Method ListParents( list:TList )
	
		Local parent:TEntity=GetParent()
		If parent
			ListAddLast( list,parent )
			ListParents(list)
		EndIf
		
	End Method
	
	' update entity matrix - calls MQ_Update
	Method UpdateMat( load_identity:Byte=False )
	
		UpdateMat_( GetInstance(Self),load_identity )
		
	End Method
	
	' add parent to entity
	Method AddParent( parent_ent:TEntity )
	
		AddParent_( GetInstance(Self),GetInstance(parent_ent) )
		
		Local inst:Byte Ptr=EntityEntity_( GetInstance(Self),ENTITY_parent )
		parent=GetObject(inst) ' no CreateObject
		If parent<>Null
			parent.CopyList(parent.child_list)
		Else
			TGlobal3D.root_ent.CopyList(TGlobal3D.root_ent.child_list)
		EndIf
		
	End Method
	
	' update matrix for all child entities - calls UpdateMat
	Function UpdateChildren( ent_p:TEntity )
	
		UpdateChildren_( GetInstance(ent_p) )
		
	End Function
	
	' square of entity distance - called by EntityDistance
	Method EntityDistanceSquared:Float( ent2:TEntity ) ' optimised
	
		Return EntityDistanceSquared_( GetInstance(Self),GetInstance(ent2) )
		
	End Method
	
	' update matrix quaternion - calls MQ_GetMatrix
	Method MQ_Update()
	
		MQ_Update_( GetInstance(Self) )
		
	End Method
	
	' inverted matrix - called in RotateEntity, TFormPoint/Vector
	Method MQ_GetInvMatrix( mat0:TMatrix )
		
		MQ_GetInvMatrix_( GetInstance(Self),TMatrix.GetInstance(mat0) )
		
	End Method
	
	' global position/rotation - called in EntityParent, EntityPitch/Yaw/Roll, TFormPoint/Vector
	Method MQ_GetMatrix( mat3:TMatrix )
		
		MQ_GetMatrix_( GetInstance(Self),TMatrix.GetInstance(mat3) )
		
	End Method
	
	' scaling - called in EntityParent
	Method MQ_GetScaleXYZ( width:Float Var,height:Float Var,depth:Float Var )
		
		MQ_GetScaleXYZ_( GetInstance(Self),Varptr width,Varptr height,Varptr depth )
		
	End Method
	
	' called in TurnEntity
	Method MQ_Turn( ang:Float,vx:Float,vy:Float,vz:Float,glob:Int=False )
		
		MQ_Turn_( GetInstance(Self),ang,vx,vy,vz,glob )
		
	End Method
	
	Rem
	' removed due to having lots of checks per entity - alternative is octrees
	Method EntityAutoFade( near:Float,far:Float )
	
		EntityAutoFade_( GetInstance(Self),near,far )
		
	End Method
	EndRem
	
	Rem
	' Returns an entity's bounding sphere
	Method BoundingSphere:TSphere()
	
		

	End Method
	EndRem
	
	Rem
	' Returns an entity's bounding sphere
	Method BoundingSphereNew(sx# Var,sy# Var,sz# Var,sr# Var)

		

	End Method
	EndRem
	
	Rem
	' unoptimised, unused
	Method EntityDistanceSquared0:Float( ent2:TEntity )

		
		
	End Method
	EndRem
	
	Rem
	Method EntityListAdd(list:TList)
	
		

	End Method
	EndRem
	
End Type
