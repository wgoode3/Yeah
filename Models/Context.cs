using Microsoft.EntityFrameworkCore;


namespace Yeah.Models
{
    /// <summary>Context class representing a session with our sqlite
    /// database allowing us to query or save data</summary>
    public class Context : DbContext
    {
        public Context(DbContextOptions options) : base(options) { }

        protected override void OnConfiguring(DbContextOptionsBuilder options) 
            => options.UseSqlite("Data Source=Yeah.db");

    }
}
