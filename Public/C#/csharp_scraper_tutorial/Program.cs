using CsvHelper;
using HtmlAgilityPack;
using ScrapySharp.Extensions;
using System.IO;
using System.Collections.Generic;
using System.Globalization;

namespace csharp_scraper_tutorial
{
    class Program{
        static void Main(string[] args)
        {
            //Send request to server
            HtmlWeb web = new HtmlWeb();

            HtmlDocument doc = web.Load("https://modesto.craigslist.org/search/tch");

            //Select a specific node from HTML doc
            var Headers = doc.DocumentNode.CssSelect("h3.result-heading > a");

            var titles = new List<Row>();

            foreach(var item in Headers)
            {
                titles.Add(new Row { Title = item.InnerText});
            }

            using StreamWriter writer = new StreamWriter("craigs.csv");

            using var csv = new CsvWriter(writer, CultureInfo.InvariantCulture);
            csv.WriteRecords(titles);

        }
    }

public class Row
{
    public string Title {get; set;}
}
}