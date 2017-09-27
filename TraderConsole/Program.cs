using System;
using System.Data;

namespace TraderConsole
{
    class Program
    {

        static void Main(string[] args)
        {
            //if (CommandLine.Parser.Default.ParseArguments(args, options))
            //{
            //    if (options.Help)
            //    {
            //        Console.WriteLine(CommandLine.Text.HelpText.AutoBuild(options));
            //        return;
            //    }
            //}

            Scenario.RolledBackBuyCausesOverSale(IsolationLevel.ReadUncommitted);
            Console.ReadLine();
            Scenario.RolledBackBuyCausesOverSale(IsolationLevel.ReadCommitted);
            Console.ReadLine();

            // those causes deadlock:

            //Scenario.RolledBackBuyCausesOverSale(IsolationLevel.RepeatableRead);
            //Console.ReadLine();
            //Scenario.RolledBackBuyCausesOverSale(IsolationLevel.Serializable);
            //Console.ReadLine();

            Scenario.RolledBackBuyCausesOverSale(IsolationLevel.Snapshot);
            Console.ReadLine();
        }
    }
}
