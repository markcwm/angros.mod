' openb3dstd.bmx

Strict

Rem
bbdoc: OpenB3DMax standard functions, as in B3D
about: 
Links currently point to kippykip.com
End Rem
Module Openb3dmax.Openb3dstd

ModuleInfo "Version: 1.26"
ModuleInfo "License: zlib"
ModuleInfo "Copyright: Wrapper - 2014-2021 Mark Mcvittie"
ModuleInfo "Copyright: Library - 2010-2021 Angelo Rosina"

' *** Types

' global
Type TGlobal3D
End Type

' entity
Type TEntity
End Type
Type TCamera
End Type
Type TLight
End Type
Type TPivot
End Type
Type TMesh
End Type
Type TSprite
End Type
Type TBone
End Type

' mesh structure
Type TSurface
End Type
Type TTexture
End Type
Type TBrush
End Type
Type TAnimation
End Type

' picking/collision
Type TPick
End Type

' geom
'Type TVector
'End Type
'Type TMatrix
'End Type
'Type TQuaternion
'End Type

' misc
'Type TBuffer
'End Type
Type TTerrain
End Type
Type TShader
End Type
Type TShadowObject
End Type
Type THardwareInfo
End Type

' *** Includes

' functions
Include "functions.bmx"
