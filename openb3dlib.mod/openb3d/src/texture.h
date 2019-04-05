#ifndef TEXTURE_H
#define TEXTURE_H

/*
 *  texture.h
 *  iminib3d
 *
 *  Created by Simon Harrison.
 *  Copyright Si Design. All rights reserved.
 *
 */

//#import "Texture2D.h"

#include <list>
#include <string>
#include <iostream>

using namespace std;

class Camera;
class DirectDrawSurface;

class Texture{

public:

	unsigned int texture;

	static list<Texture*> tex_list;

	string file;
	unsigned int* frames;

	int flags,blend,coords;
	float u_scale,v_scale,u_pos,v_pos,angle;
	string file_abs;
	int width,height; // returned by Name/Width/Height commands
	int no_frames;
	unsigned int* framebuffer;
	int cube_face,cube_mode;
	
	// extra
	static list<Texture*> tex_list_all;
	int TexEnvi[3][12];
	float TexEnvf[12];
	int TexEnv_count;
	float multitex_factor;
	static int isunique;
	int format; // can be GL_RGBA or one of the DXT compressed ones

	Texture(){

		//texture=NULL;
		file="";frames=NULL;
		flags=0,blend=2,coords=0;
		u_scale=1.0,v_scale=1.0,u_pos=0.0,v_pos=0.0,angle=0.0;
		string file_abs="";
		width=0,height=0; // returned by Name/Width/Height commands
		no_frames=1;
		framebuffer=0;
		cube_face=0,cube_mode=1;

		TexEnv_count=0,multitex_factor=0.5;
	};

	static Texture* LoadTexture(string filename,int flags=0,Texture* tex=NULL);
	static Texture* LoadAnimTexture(string filename,int flags=0, int frame_width=0,int frame_height=0,int first_frame=0,int frame_count=1,Texture* tex=NULL);
	static Texture* CreateTexture(int width=256,int height=256,int flags=3, int frames=0);
	static Texture* NewTexture();

	Texture* Copy(int copyflags);
	void FreeTexture();
	void DrawTexture(int x,int y);
	void TextureBlend(int blend_no);
	void TextureCoords(int coords_no);
	void ScaleTexture(float u_s,float v_s);
	void PositionTexture(float u_p,float v_p);
	void RotateTexture(float ang);
	void BufferToTex(unsigned char* buffer, int frames=0);
	void TexToBuffer(unsigned char* buffer, int frames=0);
	void BackBufferToTex(int frames=0);
	void CameraToTex(Camera* cam, int frames=0);
	void DepthBufferToTex(Camera* cam);
	string TextureName();
	void TextureMultitex(float f);
	static void ClearTextureFilters();
	static void AddTextureFilter(string text_match,int flags);
	Texture* TexInList(list<Texture*>& list_ref);
	void FilterFlags();
	//static string Strip(string filename);
};

#endif
