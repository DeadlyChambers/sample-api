
using Microsoft.AspNetCore.Mvc;
using common;
using System.Reflection;
using System.Text;

namespace system.Controllers
{

    [ApiController]
    [Route("[controller]")]
    public class SystemController : ControllerBase
    {
        private readonly ILogger<SystemController> _logger;

        public SystemController(ILogger<SystemController> logger)
        {

            _logger = logger;
        }

        /// <summary>
        /// Basic System Call
        /// </summary>
        /// <returns></returns>

        public SystemModel Get()
        {
            var s = new StringBuilder("EnterGet");
            Logger.Debug(s);
            return new SystemModel
            {
                Name = Assembly.GetEntryAssembly().FullName,
                Version = Assembly.GetEntryAssembly().GetCustomAttribute<AssemblyFileVersionAttribute>().Version

            };
        }
    }
}