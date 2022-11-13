namespace BeefUI.OpenGL
{
	using System;
	using System.Collections;
	using BeefUI.OpenGL;

	static class ShaderManager
	{
		static Dictionary<StringView, uint> mShaderPrograms;

		public static this()
		{
			 mShaderPrograms = new .();
		}

		public static ~this()
		{
			delete mShaderPrograms;
		}

		public static uint GetShaderProgram(StringView string)
		{
			return mShaderPrograms.GetValue(string);
		}

		private static uint CompileShader(uint type, char8* source)
		{
			uint id = GL.glCreateShader(type);
			char8* src = source; 
			GL.glShaderSource(id, 1, &src, null);
			GL.glCompileShader(id);

			int result = 0;
			GL.glGetShaderiv(id, GL.GL_COMPILE_STATUS, &result);

			if (result == GL.GL_FALSE)
			{
				int length = 0;
				GL.glGetShaderiv(id, GL.GL_INFO_LOG_LENGTH, &length);
				char8[] message = scope char8[length];
				GL.glGetShaderInfoLog(id, length, &length, &message[0]);
				WriteError( scope .(message, 0, length));
				GL.glDeleteShader(id);
			}

			return id;
		}

		public static uint CreateShader(StringView key, char8* vertexShader, char8* fragmentShader)
		{
			uint program = GL.glCreateProgram();
			uint vs = CompileShader(GL.GL_VERTEX_SHADER, vertexShader);
			uint fs = CompileShader(GL.GL_FRAGMENT_SHADER, fragmentShader);

			GL.glAttachShader(program, vs);
			GL.glAttachShader(program, fs);
			GL.glLinkProgram(program);
			GL.glValidateProgram(program);

			mShaderPrograms.Add(key, program);

			GL.glDeleteShader(vs);
			GL.glDeleteShader(fs);

			return program;
		}
	}
}
