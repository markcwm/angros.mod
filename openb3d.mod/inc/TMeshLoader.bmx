
Private

Global mesh_loaders:TMeshLoader

Public

Rem
bbdoc: Returns a mesh loader capable of loading @extension.
End Rem
Function GetMeshLoader:TMeshLoader(extension:String)

	Local loader:TMeshLoader = mesh_loaders
	
	While loader
		If loader.CanLoadMesh(extension) Then
			Return loader
		End If
		loader = loader._succ
	Wend

End Function

Rem
bbdoc: Mesh loader
End Rem
Type TMeshLoader
	Field _succ:TMeshLoader
	
	Method New()
		_succ = mesh_loaders
		mesh_loaders = Self
	End Method
	
	Method CanLoadMesh:Int(extension:String) Abstract
	
	Rem
	bbdoc: Call mesh loader implementation.
	End Rem
	Method LoadMesh:TMesh(file:TStream, url:Object, parent:TEntity = Null, flags:Int = -1) Abstract

	Rem
	bbdoc: Call animated mesh loader implementation
	End Rem
	Method LoadAnimMesh:TMesh(file:TStream, url:Object, parent:TEntity = Null, flags:Int = -1) Abstract
	
End Type

Type TMeshLoaderOpenB3D Extends TMeshLoader

	Method CanLoadMesh:Int(extension:String)
		Select extension.ToLower()
			Case "b3d"
				Return True
			Case "md2"
				Return True
			Case "3ds"
				Return True
		End Select
	End Method
	
	Method LoadMesh:TMesh(file:TStream, url:Object, parent:TEntity = Null, flags:Int = -1)
	
		If Not (TGlobal3D.Mesh_Loader=0 Or (TGlobal3D.Mesh_Loader & 2)) Then Return Null
		
		Local cString:Byte Ptr=String(url).ToCString()
		Local inst:Byte Ptr=LoadMesh_( cString,TEntity.GetInstance(parent) )
		Local mesh:TMesh=TMesh.CreateObject(inst)
		MemFree cString
		
		Return mesh ' no children, mesh is collapsed
		
	End Method
	
	Method LoadAnimMesh:TMesh(file:TStream, url:Object, parent:TEntity = Null, flags:Int = -1)
	
		If Not (TGlobal3D.Mesh_Loader=0 Or (TGlobal3D.Mesh_Loader & 2)) Then Return Null
		
		Local cString:Byte Ptr=String(url).ToCString()
		Local inst:Byte Ptr=LoadAnimMesh_( cString,TEntity.GetInstance(parent) )
		Local mesh:TMesh=TMesh.CreateObject(inst)
		MemFree cString
		mesh.CreateAllChildren() ' create child mesh objects
		
		Return mesh
		
	End Method
	
End Type

Type TMeshLoaderMax Extends TMeshLoader

	Method CanLoadMesh:Int(extension:String)
		Select extension.ToLower()
			Case "b3d"
				Return True
			Case "md2"
				Return True
			Case "3ds"
				Return True
			Case "obj"
				Return True
		End Select
	End Method
	
	Method LoadMesh:TMesh(file:TStream, url:Object, parent:TEntity = Null, flags:Int = -1)
	
		If Not (TGlobal3D.Mesh_Loader=0 Or (TGlobal3D.Mesh_Loader & 1)) Then Return Null
		
		Local mesh:TMesh, anim_mesh:TMesh
		Select ExtractExt(String(url))
			Case "b3d"
				anim_mesh=TB3D.LoadAnimB3DFromStream(file, url, parent)
			Case "md2"
				anim_mesh=TMD2.LoadMD2FromStream(file, url, parent)
			Case "3ds"
				If TGlobal3D.Loader_3DS2
					Local model:T3DS2 = New T3DS2
					anim_mesh=model.LoadAnim3DSFromStream(file, url, parent, flags)
				Else
					Local model:T3DS = New T3DS
					anim_mesh=model.Load3DSFromStream(file, url, parent, flags)
				EndIf
			Case "obj"
				anim_mesh=TOBJ.LoadOBJFromStream(file, url, parent, flags)
		EndSelect
		
		If anim_mesh=Null
			DebugLog " LoadMesh failed: "+String(url)
			Return Null
		EndIf
		
		anim_mesh.HideEntity()
		mesh=anim_mesh.CollapseAnimMesh()
		mesh.SetString(mesh.name, anim_mesh.GetString(anim_mesh.name))
		mesh.SetString(mesh.class_name, "Mesh")
		mesh.AddParent(parent)
		mesh.EntityListAdd(TEntity.entity_list)
		anim_mesh.FreeEntity()
		
		' update matrix
		If mesh.parent<>Null
			mesh.mat.Overwrite(mesh.parent.mat)
			mesh.UpdateMat()
		Else
			mesh.UpdateMat(True)
		EndIf
		
		Return mesh
		
	End Method
	
	Method LoadAnimMesh:TMesh(file:TStream, url:Object, parent:TEntity = Null, flags:Int = -1)
	
		If Not (TGlobal3D.Mesh_Loader=0 Or (TGlobal3D.Mesh_Loader & 1)) Then Return Null
		
		Local mesh:TMesh
		Select ExtractExt(String(url))
			Case "b3d"
				mesh=TB3D.LoadAnimB3DFromStream(file, url, parent)
			Case "md2"
				mesh=TMD2.LoadMD2FromStream(file, url, parent)
			Case "3ds"
				If TGlobal3D.Loader_3DS2
					Local model:T3DS2 = New T3DS2
					mesh=model.LoadAnim3DSFromStream(file, url, parent, flags)
				Else
					Local model:T3DS = New T3DS
					mesh=model.Load3DSFromStream(file, url, parent, flags)
				EndIf
			Case "obj"
				mesh=TOBJ.LoadOBJFromStream(file, url, parent, flags)
		EndSelect
		
		If mesh=Null
			DebugLog " LoadAnimMesh failed: "+String(url)
			Return Null
		EndIf
		
		Return mesh
		
	End Method
	
End Type

New TMeshLoaderOpenB3D

New TMeshLoaderMax
