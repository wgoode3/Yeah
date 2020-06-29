using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Yeah.Models;
using Microsoft.AspNetCore.Mvc;


namespace Yeah.Controllers
{
    public class HomeController : Controller
    {
        private Context _context { get; set; }

        public HomeController(Context context)
        {
            _context = context;
        }

        [HttpGet("")]
        public IActionResult Index()
        {
            return View();
        }

    }
}