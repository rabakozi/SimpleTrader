namespace TraderConsole
{
    static class Options
    {
        public static int NumOfThrerads { get { return 10; } }
        public static int Iterations { get { return 10; } }
    }

    //static class Options
    //{
    //    [Option('r', "reset", HelpText = "Reset tables", Required = false, DefaultValue = false)]
    //    public bool Reset { get; set; }

    //    [Option('t', "threads", HelpText = "Number Of threads", Required = false, DefaultValue = 4)]
    //    public int NumOfThreads { get; set; }

    //    [Option('t', "threads", HelpText = "Number Of threads", Required = false, DefaultValue = 10)]
    //    public int Iterations { get; set; }

    //    [Option('h', "help", HelpText = "Prints this help", Required = false, DefaultValue = false)]
    //    public bool Help { get; set; }
    //}
}
