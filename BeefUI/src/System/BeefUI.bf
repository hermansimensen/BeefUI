namespace BeefUI.System
{
	using System;

	enum RenderingBackend
	{
		OpenGL
	}

	static class BeefUI
	{
		private static RenderingBackend mRenderingBackend;

		public static Result<void> SetRenderingBackend(RenderingBackend backend)
		{
			mRenderingBackend = backend;

			switch(mRenderingBackend)
			{
				case .OpenGL: return BeefUI.OpenGL.OpenGLBackend.InitOpenGL();
			}
		}
	}
}