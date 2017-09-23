using Dapper;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.Common;
using System.Data.SqlClient;
using System.Diagnostics;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace TraderConsole
{
    public static class Scenario
    {
        static readonly Random random = new Random(DateTime.Now.Millisecond);
        public static Func<DbConnection> ConnectionFactory = () =>
        new SqlConnection(ConfigurationManager.ConnectionStrings["SimpleTrader"].ConnectionString);

        public static void RolledBackBuyCausesOverSale(System.Data.IsolationLevel isolationLevel)
        {
            Console.WriteLine("\n-------------------------------------------------\n");
            Console.WriteLine($"RolledBackBuyCausesOverSale, {SqlIsolationLevel(isolationLevel)}");
            Reset();
            Console.WriteLine();
            DumpArticles();
            Console.WriteLine();
            var tasks = new List<Task>();

            // four selling one failing buying
            for (int i = 0; i < 4; i++)
            {
                int index = i;
                tasks.Add(Task.Run(() => RunActor(Action.Sell, isolationLevel, 4, 0)));
            }
            tasks.Add(Task.Run(() => RunActor(Action.Buy, isolationLevel, 10, 100)));

            Task.WaitAll(tasks.ToArray());
            Console.WriteLine("RolledBackBuyCausesOverSale finished.");
            Console.WriteLine();
            DumpArticles();
        }

        static void RunActor(Action action, IsolationLevel isolationLevel, int quantity, int rollbackProbabilityPercentage)
        {
            using (var conn = ConnectionFactory())
            {
                var stopwatch = new Stopwatch();

                for (int i = 1; i <= Options.Iterations; i++)
                {
                    string name = GetRandomArticleName();
                    bool rollback = IsRollBack(rollbackProbabilityPercentage);
                    string sp = action.ToString();
                    string storedProcedure = $"dbo.{sp}";

                    stopwatch.Restart();
                    conn.Query($"dbo.{sp}",
                       new { Name = name, Quantity = quantity, Rollback = rollback, IsolationLevel = SqlIsolationLevel(isolationLevel) }, commandType: CommandType.StoredProcedure);

                    Console.WriteLine($"iteration:{i}, {sp}ing of {name}, Rollback:{rollback}, Elapsed: {stopwatch.ElapsedMilliseconds} ms");
                }
                stopwatch.Stop();
            }
        }

        public static void DumpArticles()
        {
            using (var conn = ConnectionFactory())
            {
                var articles = conn.Query<Article>("select * from Article");
                
                foreach(var article in articles)
                {
                    var id = article.Id;
                    var name = article.Name.PadRight(20);
                    var price = article.Price.ToString().PadLeft(5);
                    var stock = article.Stock.ToString().PadLeft(5);

                    Console.WriteLine($"{id} | {name} | {price} | {stock}");
                }
            }
        }

        static void Reset()
        {
            using (var conn = ConnectionFactory())
            {
                Console.WriteLine("Reset tables started...");
                conn.Execute("TRUNCATE TABLE Article");
                conn.Execute(@"insert Article(Name, Price, Stock) values (@name, @price, @stock)",
                    Seed.Articles()
                  );
                conn.Execute("TRUNCATE TABLE Account");
                conn.Execute(@"insert Account(Deposit, StockValue) values (@deposit, @stockValue)",
                    Seed.Account()
                  );
                Console.WriteLine($"Reset Done. Press ENTER");
            }
        }

        static bool IsRollBack(int probabilityPercentage)
        {
            return Convert.ToBoolean(random.Next(0, 100) <= probabilityPercentage);
        }

        static string GetRandomArticleName()
        {
            var pos = random.Next(0, 8);
            return Seed.Articles()[pos].Name;
        }

        static string SqlIsolationLevel(IsolationLevel isolationLevel)
        {
            switch(isolationLevel)
            {
                case IsolationLevel.ReadUncommitted:
                    return "READ UNCOMMITTED";
                case IsolationLevel.ReadCommitted:
                    return "READ COMMITTED";
                case IsolationLevel.RepeatableRead:
                    return "REPEATABLE READ";
                case IsolationLevel.Serializable:
                    return "SERIALIZABLE";
                case IsolationLevel.Snapshot:
                    return "SNAPSHOT";
                default:
                    throw new ArgumentException();
            }
        }

        enum Action
        {
            Buy,
            Sell
        }
    }
}
