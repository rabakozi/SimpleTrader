using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace TraderConsole
{
    public static class Seed
    {
        private static Article[] articles;
        private static Account account;

        public static Article[] Articles()
        {
            return articles ?? (articles = new Article[]
            {
                new Article { Name = "Jersey", Price = 38, Stock = 6 },
                new Article { Name = "Shorts", Price = 45, Stock = 3 },
                new Article { Name = "Bib", Price = 47, Stock = 10 },
                new Article { Name = "Tights", Price = 76, Stock = 5 },
                new Article { Name = "Jacket", Price = 110, Stock = 4 },
                new Article { Name = "Gloves", Price = 22, Stock = 6 },
                new Article { Name = "Socks", Price = 9, Stock = 11 },
                new Article { Name = "Shoes", Price = 189, Stock = 4 },
                new Article { Name = "Helmet", Price = 62, Stock = 3 },
            });
        }

        public static Account Account()
        {
            return account ?? (account = new Account
            {
                Deposit = 4000,
                StockValue = 3000
            });
        }
    }
}
