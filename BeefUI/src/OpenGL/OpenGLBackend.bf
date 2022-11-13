namespace BeefUI.OpenGL
{
	using System;

	class OpenGLBackend
	{
		/*
			On Windows, OpenGL function pointers are tied to a context, so we need to create one.
			The functions pointers are technically PER context,
			but that is likely not gonna be an issue in reality as long as we aren't using two graphics cards with differing drivers at the same time.
		*/

		public static void InitOpenGL()
		{
#if BF_PLATFORM_WINDOWS
			WNDCLASS wnd;
			wnd.lpfnWndProc = => WindowProc;
			wnd.hInstance = Internal.[Friend]sModuleHandle;
			wnd.hbrBackground = (void*) 1;
			wnd.lpszClassName = "TestWnd";
			wnd.style = 0x0020;

			uint16 c = RegisterClassA(&wnd);
			if(c != 0)
			{
				CreateWindowExA(0L, wnd.lpszClassName, "test", 0x00000000L, 0, 0, 640, 480, null, null, wnd.hInstance, null);
			}
#endif
		}

#if BF_PLATFORM_WINDOWS
		[CRepr]
		struct WNDCLASS
		{
			public uint32      			style;
			public WndProc   			lpfnWndProc;
			public int32       			cbClsExtra;
			public int32       			cbWndExtra;
			public void*			 	hInstance;
			public int	     			hIcon;
			public int		  			hCursor;
			public void*				hbrBackground;
			public char8*				lpszMenuName;
			public char8*				lpszClassName;
		}

		typealias HDC = int;

		[CRepr]
		public struct PIXELFORMATDESCRIPTOR
		{
			public uint16 nSize;
			public uint16 nVersion;
			public uint32 dwFlags;
			public int8 iPixelType;
			public uint8 cColorBits;
			public uint8 cRedBits;
			public uint8 cRedShift;
			public uint8 cGreenBits;
			public uint8 cGreenShift;
			public uint8 cBlueBits;
			public uint8 cBlueShift;
			public uint8 cAlphaBits;
			public uint8 cAlphaShift;
			public uint8 cAccumBits;
			public uint8 cAccumRedBits;
			public uint8 cAccumGreenBits;
			public uint8 cAccumBlueBits;
			public uint8 cAccumAlphaBits;
			public uint8 cDepthBits;
			public uint8 cStencilBits;
			public uint8 cAuxBuffers;
			public int8 iLayerType;
			public uint8 bReserved;
			public uint32 dwLayerMask;
			public uint32 dwVisibleMask;
			public uint32 dwDamageMask;
		}

		private static function int32 WndProc(System.Windows.HWnd hwnd, uint32 uMsg, uint wParam, int lParam);

		[Import("USER32.lib"), CLink, CallingConvention(.Stdcall)]
		public static extern uint16 RegisterClassA(WNDCLASS* lpWndClass);

		[Import("USER32.lib"), CLink, CallingConvention(.Stdcall)]
		public static extern int32 DefWindowProcA(System.Windows.HWnd hwnd, uint32 uMsg, uint wParam, int lParam);

		[Import("USER32.lib"), CLink, CallingConvention(.Stdcall)]
		public static extern HDC GetDC(System.Windows.HWnd hWnd);

		[CallingConvention(.Stdcall)]
		function void* wglCreateContextFunc(HDC hdc);

		[CallingConvention(.Stdcall)]
		function void* wglGetProcAddressFunc(char8* name);

		[Import("USER32.lib"), CLink, CallingConvention(.Stdcall)]
		public static extern void* CreateWindowExA(uint32 dwExStyle, char8* lpClassName, char8* lpWindowName, uint32 dwStyle, int32 X, int32 Y, int32 nWidth, int32 nHeight, void* hWndParent, void* hMenu, void* hInstance, void* lpParam);

		[Import("GDI32.lib"), CLink, CallingConvention(.Stdcall)]
		public static extern int32 ChoosePixelFormat(HDC hdc, PIXELFORMATDESCRIPTOR* ppfd);

		[Import("GDI32.lib"), CLink, CallingConvention(.Stdcall)]
		public static extern int32 SetPixelFormat(HDC hdc, int32 format, PIXELFORMATDESCRIPTOR* ppfd);

		[Import("OPENGL32.lib"), CLink, CallingConvention(.Stdcall)]
		public static extern int32 wglMakeCurrent(HDC param0, void* param1);

		[Import("OPENGL32.lib"), CLink, CallingConvention(.Stdcall)]
		public static extern int32 wglDeleteContext(void* param0);

		[Import("USER32.lib"), CLink, CallingConvention(.Stdcall)]
		public static extern int32 DestroyWindow(Windows.HWnd hWnd);

		public static int32 WindowProc(System.Windows.HWnd hwnd, uint32 uMsg, uint wParam, int lParam)
		{
			switch(uMsg)
			{
				case 0x0001: //WM_CREATE
				{
					System.Diagnostics.Debug.WriteLine("test!");

					PIXELFORMATDESCRIPTOR pfd = .();

					pfd.nSize = sizeof(PIXELFORMATDESCRIPTOR);
					pfd.nVersion = 1;
					pfd.dwFlags = (4 | 32 | 1);
 					pfd.iPixelType = 0;
					pfd.cColorBits = 32;
					pfd.cRedBits = 0;
					pfd.cRedShift = 0;
					pfd.cGreenBits = 0;
					pfd.cGreenShift = 0;
					pfd.cBlueBits = 0;
					pfd.cBlueShift = 0;
					pfd.cAlphaBits = 0;
					pfd.cAlphaShift = 0;
					pfd.cAccumBits = 0;
					pfd.cAccumRedBits = 0;
					pfd.cAccumGreenBits = 0;
					pfd.cAccumBlueBits = 0;
					pfd.cAccumAlphaBits = 0;
					pfd.cDepthBits = 24;
					pfd.cStencilBits = 8;
					pfd.cAuxBuffers = 0;
					pfd.iLayerType = 0;
					pfd.bReserved = 0;
					pfd.dwLayerMask = 0;
					pfd.dwVisibleMask = 0;
					pfd.dwDamageMask = 0;

					HDC handle = GetDC(hwnd);

					int32  letWindowsChooseThisPixelFormat = ChoosePixelFormat(handle, &pfd); 
					SetPixelFormat(handle, letWindowsChooseThisPixelFormat, &pfd);

					Windows.HModule module = Windows.LoadLibraryA("opengl32.dll");
					wglCreateContextFunc wglCreateContext = (.) Windows.GetProcAddress(module, "wglCreateContext");

					void* context = wglCreateContext(handle);
					wglMakeCurrent (handle, context);

					GL.Init(=> GetAnyGLFuncAddress);

					wglDeleteContext(context);

					DestroyWindow(hwnd);
				}
			}

			return DefWindowProcA(hwnd, uMsg, wParam, lParam);
		}

#endif
		private static void* GetAnyGLFuncAddress(char8* name)
		{
#if BF_PLATFORM_WINDOWS
			Windows.HModule module = Windows.LoadLibraryA("opengl32.dll");

			wglGetProcAddressFunc wglGetProcAddress = (.) Windows.GetProcAddress(module, "wglGetProcAddress");

			void *p = wglGetProcAddress(name);
		 	if((p == (void*)0 || (p == (void*)0x1) || (p == (void*)0x2) || (p == (void*)0x3) || (p == (void*)-1)))
			{
				p = Windows.GetProcAddress(module, name);
			}

			return p;
##endif
		}
	}
}