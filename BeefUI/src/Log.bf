namespace BeefUI
{
	using System;
	using System.Diagnostics;

	static
	{
		/*
			Placeholder functions for now. 
		*/

		public static void WriteError(String text, String file = Compiler.CallerFileName, int num = Compiler.CallerLineNum)
		{
			Debug.WriteLine("{} in {} at line {}.", text, file, num);
		}

		public static void Log(String text)
		{
			Debug.WriteLine(text);
		}
	}
}
